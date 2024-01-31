package main

import (
	"encoding/json"
	"fmt"
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
		before, err := suite.app.Models.Users.GetByEmail(suite.apiUser.Email)
		if err != nil {
			t.Fatal(err)
		}
		code, _, body := suite.ts.Request(t, nil, "/v1/users/flipped", http.MethodPost, suite.authToken)

		assert.Equal(t, code, http.StatusOK)
		assert.StringContains(t, body, "your language was switched successfully")

		after, err := suite.app.Models.Users.GetByEmail(suite.apiUser.Email)
		if err != nil {
			t.Fatal(err)
		}
		assert.Equal(t, before.Flipped, !after.Flipped)
	})
}

func (suite *ApiTestSuite) TestApiUpdateUserPasswordHandler() {
	t := suite.T()
	prefix := "apiUpdateUserPassword"
	email := prefix + test.TestEmail
	register(prefix, t, suite.ts)
	activate(email, suite.app.Models)

	const (
		fakeToken = "PQR7I6SB6OGKDSWK4ZMQZKWWFQ"
	)

	tests := []struct {
		name        string
		newPassword string
		token       string
		wantCode    int
		wantTag     string
	}{
		{
			name:        "Empty New Password",
			newPassword: "",
			token:       fakeToken,
			wantCode:    http.StatusUnprocessableEntity,
			wantTag:     "This field cannot be blank",
		},
		{
			name:        "Empty New Token",
			newPassword: test.ValidPassword,
			token:       "",
			wantCode:    http.StatusUnprocessableEntity,
			wantTag:     "must be provided",
		},
		{
			name:        "Invalid Token",
			newPassword: test.ValidPassword,
			token:       fakeToken,
			wantCode:    http.StatusUnprocessableEntity,
			wantTag:     "invalid or expired password reset token",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			data := map[string]interface{}{
				"password": tt.newPassword,
				"token":    tt.token,
			}

			jsonData, err := json.Marshal(data)
			if err != nil {
				fmt.Printf("could not marshal json: %s\n", err)
				return
			}

			code, _, body := suite.ts.Request(t, jsonData, "/v1/users/password", http.MethodPut, suite.authToken)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}

func (suite *ApiTestSuite) TestApiUpdateUserPasswordFlow() {
	t := suite.T()
	prefix := "userPasswordFlow"
	email := prefix + test.TestEmail
	apiUser := register(prefix, t, suite.ts)

	token, err := suite.app.Models.Tokens.New(apiUser.ID, 5*time.Second, models.ScopePasswordReset)
	if err != nil {
		t.Fatalf("token creation failed with err: %s", err)
	}

	t.Run("Api Update User Password Flow", func(t *testing.T) {
		data := map[string]interface{}{
			"token":    token.Plaintext,
			"password": test.ValidPassword,
		}

		jsonData, err := json.Marshal(data)
		if err != nil {
			fmt.Printf("could not marshal json: %s\n", err)
			return
		}

		// before activation
		code, _, body := suite.ts.Request(t, jsonData, "/v1/users/password", http.MethodPut, suite.authToken)

		assert.Equal(t, code, http.StatusForbidden)
		assert.StringContains(t, body, "your user account must be activated to access this resource")

		// activate user
		activate(email, suite.app.Models)

		code, _, body = suite.ts.Request(t, jsonData, "/v1/users/password", http.MethodPut, suite.authToken)

		assert.Equal(t, code, http.StatusOK)
		assert.StringContains(t, body, "your password was successfully reset")
	})
}
