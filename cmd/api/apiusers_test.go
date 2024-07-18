package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/test"
	"testing"
	"time"
)

func (suite *ApiNoLoginTestSuite) TestActivateUser() {
	t := suite.T()
	prefix := "activateUser"
	email := prefix + test.ValidEmail
	user := register(prefix, t, suite.ts)

	token, err := suite.app.Models.Tokens.New(user.ID, 24*time.Hour, models.ScopeActivation)
	if err != nil {
		t.Fatal(err)
	}

	data := map[string]interface{}{
		"token": token.Plaintext,
	}

	jsonToken, err := json.Marshal(data)
	if err != nil {
		t.Fatal(err)
	}

	t.Run("Account View Before and After Activation", func(t *testing.T) {
		// before activation
		code, _, _ := suite.ts.Request(t, jsonToken, "/v1/account/view", http.MethodGet, "")

		assert.Equal(t, code, http.StatusUnauthorized)

		// activate account
		code, _, _ = suite.ts.Request(t, jsonToken, "/v1/users/activated", http.MethodPut, "")

		assert.Equal(t, code, http.StatusOK)

		after, _ := suite.app.Models.Users.GetByEmail(email)

		assert.Equal(t, user.Activated, !after.Activated)

		// account view after activation
		authToken := getAuthToken(prefix, t, suite.ts)
		code, _, body := suite.ts.Request(t, nil, "/v1/account/view", http.MethodGet, authToken)
		dec := json.NewDecoder(bytes.NewBufferString(body))

		var input struct {
			ResponseUser models.User `json:"user"`
		}
		err = dec.Decode(&input)
		if err != nil {
			t.Fatalf("error decoding account view response: %s", err)
		}
		assert.Equal(t, code, http.StatusOK)

		assert.Equal(t, input.ResponseUser.Email, email)
		assert.Equal(t, input.ResponseUser.Activated, true)
		assert.Equal(t, input.ResponseUser.Name, prefix+"ApiUser")
		assert.Equal(t, input.ResponseUser.MovieId, -1)
		assert.Equal(t, input.ResponseUser.Flipped, false)
	})
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

func (suite *ApiTestSuite) TestApiUpdateUserPassword() {
	t := suite.T()
	prefix := "apiUpdateUserPassword"
	email := prefix + test.ValidEmail
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

func (suite *ApiTestSuite) TestApiUpdateUserLanguage() {
	t := suite.T()

	tests := []struct {
		name        string
		newLanguage string
		authToken   string
		wantCode    int
		wantTag     string
	}{
		{
			name:        "Valid Langauge",
			newLanguage: "French",
			authToken:   suite.authToken,
			wantCode:    http.StatusOK,
			wantTag:     "your language was updated successfully",
		},
		{
			name:        "Invalid Langauge",
			newLanguage: "Frenc",
			authToken:   suite.authToken,
			wantCode:    http.StatusUnprocessableEntity,
			wantTag:     "invalid language",
		},
		{
			name:        "Empty New Language",
			newLanguage: "",
			authToken:   suite.authToken,
			wantCode:    http.StatusUnprocessableEntity,
			wantTag:     "This field cannot be blank",
		},
		{
			name:        "Empty Auth Token",
			newLanguage: strconv.Itoa(test.ValidLanguageId),
			authToken:   "",
			wantCode:    http.StatusUnauthorized,
			wantTag:     "you must be authenticated to access this resource",
		},
		{
			name:        "Invalid Token",
			newLanguage: strconv.Itoa(test.ValidLanguageId),
			authToken:   "PQR7I6SB6OGKDSWK4ZMQZKWWFQ",
			wantCode:    http.StatusUnauthorized,
			wantTag:     "invalid or missing authentication token",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			data := map[string]interface{}{
				"language": tt.newLanguage,
			}

			jsonData, err := json.Marshal(data)
			if err != nil {
				fmt.Printf("could not marshal json: %s\n", err)
				return
			}

			code, _, body := suite.ts.Request(t, jsonData, "/v1/account/language/update", http.MethodPut, tt.authToken)

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
	email := prefix + test.ValidEmail
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

func (suite *ApiTestSuite) TestRegisterUser() {
	t := suite.T()

	const (
		validUsername = "resgisterUser"
		validEmail    = "registerUser@email.com"
	)
	tests := []struct {
		name         string
		userName     string
		userEmail    string
		userPassword string
		userLanguage any
		wantCode     int
		wantString   string
	}{
		{
			name:         "Invalid Json",
			userName:     validUsername,
			userEmail:    validEmail,
			userPassword: test.ValidPassword,
			userLanguage: "1",
			wantCode:     http.StatusBadRequest,
			wantString:   "body contains incorrect JSON type for field ",
		},
		{
			name:         "Invalid Language",
			userName:     validUsername,
			userEmail:    validEmail,
			userPassword: test.ValidPassword,
			userLanguage: -2,
			wantCode:     http.StatusBadRequest,
			wantString:   "language id invalid",
		},
		{
			name:         "Invalid Email",
			userName:     validUsername,
			userEmail:    "invalidEmail",
			userPassword: test.ValidPassword,
			userLanguage: test.ValidLanguageId,
			wantCode:     http.StatusUnprocessableEntity,
			wantString:   "This field must be a valid email address",
		},
		{
			name:         "Email Already Exists",
			userName:     validUsername,
			userEmail:    suite.apiUser.Email,
			userPassword: test.ValidPassword,
			userLanguage: test.ValidLanguageId,
			wantCode:     http.StatusUnprocessableEntity,
			wantString:   "a user with this email address already exists",
		},
		{
			name:         "Username Already Exists",
			userName:     suite.apiUser.Name,
			userEmail:    validEmail,
			userPassword: test.ValidPassword,
			userLanguage: test.ValidLanguageId,
			wantCode:     http.StatusUnprocessableEntity,
			wantString:   "a user with this username already exists",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			data := map[string]interface{}{
				"name":       tt.userName,
				"email":      tt.userEmail,
				"password":   tt.userPassword,
				"languageId": tt.userLanguage,
			}

			jsonData, err := json.Marshal(data)
			if err != nil {
				fmt.Printf("could not marshal json: %s\n", err)
				return
			}
			code, _, body := suite.ts.Post(t, "/v1/users", jsonData)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantString != "" {
				assert.StringContains(t, body, tt.wantString)
			}

		})
	}
}

func (suite *ApiTestSuite) TestActivateUser() {
	t := suite.T()

	tests := []struct {
		name       string
		token      any
		wantCode   int
		wantString string
	}{
		{
			name:       "Invalid Json",
			token:      1,
			wantCode:   http.StatusBadRequest,
			wantString: "body contains incorrect JSON type for field ",
		},
		{
			name:       "Short Token",
			token:      "invalid",
			wantCode:   http.StatusUnprocessableEntity,
			wantString: "must be 26 bytes long",
		},
		{
			name:       "Invalid Token",
			token:      "26LDI3W4LV2POBDVYL3MCLC3VY",
			wantCode:   http.StatusUnprocessableEntity,
			wantString: "invalid or expired activation token",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			data := map[string]interface{}{
				"token": tt.token,
			}

			jsonData, err := json.Marshal(data)
			if err != nil {
				fmt.Printf("could not marshal json: %s\n", err)
				return
			}
			code, _, body := suite.ts.Request(t, jsonData, "/v1/users/activated", http.MethodPut, "")
			assert.Equal(t, code, tt.wantCode)

			if tt.wantString != "" {
				assert.StringContains(t, body, tt.wantString)
			}

		})
	}
}
