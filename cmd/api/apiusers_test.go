package main

import (
	"encoding/json"
	"net/http"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/test"
	"testing"
	"time"
)

func (suite *ApiNoLoginTestSuite) TestActivateUserHandler() {
	t := suite.T()
	data := map[string]interface{}{
		"name":     "ActivateUserHandler",
		"password": test.ValidPassword,
		"email":    "activateuserhandler@email.com",
		"language": test.ValidLanguage,
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		t.Fatal(err)
	}

	code, _, body := suite.ts.Post(t, "/v1/users", jsonData)

	assert.Equal(t, code, http.StatusAccepted)

	var userStruct struct {
		User models.User `json:"user"`
	}

	err = json.Unmarshal([]byte(body), &userStruct)

	if err != nil {
		t.Fatal(err)
	}

	token, err := suite.app.Models.Tokens.New(userStruct.User.ID, 24*time.Hour, models.ScopeActivation)
	if err != nil {
		t.Fatal(err)
	}

	data = map[string]interface{}{
		"token": token.Plaintext,
	}

	jsonToken, err := json.Marshal(data)
	if err != nil {
		t.Fatal(err)
	}

	code, _, _ = suite.ts.Request(t, jsonToken, "/v1/users/activated", http.MethodPut, "")

	assert.Equal(t, code, http.StatusOK)
}

func (suite *ApiTestSuite) TestApiFlipped() {
	t := suite.T()

	t.Run("Api Flip Language", func(t *testing.T) {
		code, _, body := suite.ts.Request(t, nil, "/v1/users/flipped", http.MethodPost, suite.authToken)

		assert.Equal(t, code, http.StatusOK)
		assert.StringContains(t, body, "your language was switched successfully")
	})
}
