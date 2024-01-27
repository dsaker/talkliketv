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

func (suite *ApiNoLoginTestSuite) TestRegisterUserHandler() {

	t := suite.T()

	const (
		validName  = "user12"
		validEmail = "bob@example.com"
	)

	tests := []struct {
		name         string
		userName     string
		userEmail    string
		userLanguage string
		userPassword string
		wantCode     int
		wantTag      string
	}{
		{
			name:         "Valid Submission",
			userName:     validName,
			userEmail:    validEmail,
			userLanguage: test.ValidLanguage,
			userPassword: test.ValidPassword,
			wantCode:     http.StatusAccepted,
		},
		{
			name:         "Empty Name",
			userName:     "",
			userEmail:    "emptyname@email.com",
			userLanguage: test.ValidLanguage,
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field cannot be blank",
		},
		{
			name:         "Empty Email",
			userName:     "emptyemail",
			userEmail:    "",
			userLanguage: test.ValidLanguage,
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field cannot be blank",
		},
		{
			name:         "Empty Password",
			userName:     "emptypassword",
			userEmail:    "emptypassword@email.com",
			userLanguage: test.ValidLanguage,
			userPassword: "",
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field cannot be blank",
		},
		{
			name:         "Invalid Email",
			userName:     "invalidemail",
			userEmail:    "bob@example.",
			userLanguage: test.ValidLanguage,
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field must be a valid email address",
		},
		{
			name:         "Short Password",
			userName:     "shorpassword",
			userEmail:    "shorpassword@email.com",
			userLanguage: test.ValidLanguage,
			userPassword: "pa$$",
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field must be at least 8 characters long",
		},
		{
			name:         "Duplicate Email",
			userName:     "duplicateemail",
			userEmail:    "user2@email.com",
			userLanguage: test.ValidLanguage,
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "a user with this email address already exists",
		},
		{
			name:         "Invalid Language",
			userName:     "validName1",
			userEmail:    "validName1@email.com",
			userLanguage: "Made Up Language",
			userPassword: test.ValidPassword,
			wantCode:     http.StatusBadRequest,
			wantTag:      "models: no matching record found",
		},
		{
			name:         "Duplicate Name",
			userName:     "user2",
			userEmail:    "validName1@email.com",
			userLanguage: test.ValidLanguage,
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "a user with this username already exists",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			data := map[string]interface{}{
				"name":     tt.userName,
				"password": tt.userPassword,
				"email":    tt.userEmail,
				"language": tt.userLanguage,
			}

			jsonData, err := json.Marshal(data)
			if err != nil {
				fmt.Printf("could not marshal json: %s\n", err)
				return
			}
			code, _, body := suite.ts.Post(t, "/v1/users", jsonData)

			assert.Equal(t, code, tt.wantCode)
			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}
