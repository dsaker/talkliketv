package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/test"
	"testing"
)

func (suite *ApiNoLoginTestSuite) TestCreateAuthenticationTokenHandler() {
	t := suite.T()
	prefix := "token-handler"
	register(prefix, t, suite.ts)

	tests := []struct {
		name         string
		userEmail    string
		userPassword string
		wantCode     int
		wantToken    bool
	}{
		{
			name:         "Valid Submission",
			userEmail:    prefix + test.TestEmail,
			userPassword: test.ValidPassword,
			wantCode:     http.StatusCreated,
			wantToken:    true,
		},
		{
			name:         "Empty Email",
			userEmail:    "",
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantToken:    false,
		},
		{
			name:         "Email Not Found",
			userEmail:    "emailnotfound@email.com",
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnauthorized,
			wantToken:    false,
		},
		{
			name:         "Malformed Email",
			userEmail:    "malformed.email",
			userPassword: test.ValidPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantToken:    false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			data := map[string]interface{}{
				"password": tt.userPassword,
				"email":    tt.userEmail,
			}

			jsonData, err := json.Marshal(data)
			if err != nil {
				fmt.Printf("could not marshal json: %s\n", err)
				return
			}
			code, _, body := suite.ts.Post(t, "/v1/tokens/authentication", jsonData)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantToken {
				var tokenStruct struct {
					Token models.Token `json:"authentication_token"`
				}

				err = json.Unmarshal([]byte(body), &tokenStruct)
				if err != nil {
					t.Fatal(err)
				}

				assert.Equal(t, len(tokenStruct.Token.Plaintext), 26)
			}
		})
	}
}

func (suite *ApiTestSuite) TestCreatePasswordResetTokenHandler() {
	t := suite.T()
	prefix := "password-token-handler"
	register(prefix, t, suite.ts)
	activate(prefix+test.TestEmail, suite.app.Models)
	tests := []struct {
		name      string
		userEmail string
		wantCode  int
	}{
		{
			name:      "Valid Submission",
			userEmail: prefix + test.TestEmail,
			wantCode:  http.StatusAccepted,
		},
		{
			name:      "Empty Email",
			userEmail: "",
			wantCode:  http.StatusUnprocessableEntity,
		},
		{
			name:      "Email Not Found",
			userEmail: "emailnotfound@email.com",
			wantCode:  http.StatusUnprocessableEntity,
		},
		{
			name:      "Malformed Email",
			userEmail: "malformed.email",
			wantCode:  http.StatusUnprocessableEntity,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			data := map[string]interface{}{
				"email": tt.userEmail,
			}

			jsonData, err := json.Marshal(data)
			if err != nil {
				fmt.Printf("could not marshal json: %s\n", err)
				return
			}
			code, _, _ := suite.ts.Post(t, "/v1/tokens/password-reset", jsonData)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}

func (suite *ApiNoLoginTestSuite) TestCreateAuthenticationTokenHandlerBadRequest() {
	t := suite.T()
	prefix := "badToken-"
	register(prefix, t, suite.ts)

	t.Run("Token Handler No Email", func(t *testing.T) {
		data := map[string]interface{}{
			"password": test.ValidPassword,
		}

		jsonData, err := json.Marshal(data)
		if err != nil {
			fmt.Printf("could not marshal json: %s\n", err)
			return
		}
		code, _, body := suite.ts.Post(t, "/v1/tokens/authentication", jsonData)

		assert.Equal(t, code, http.StatusUnprocessableEntity)
		assert.StringContains(t, body, "This field cannot be blank")
	})

	t.Run("Token Handler No Password", func(t *testing.T) {
		data := map[string]interface{}{
			"email": "password12@email.com",
		}

		jsonData, err := json.Marshal(data)
		if err != nil {
			fmt.Printf("could not marshal json: %s\n", err)
			return
		}
		code, _, body := suite.ts.Post(t, "/v1/tokens/authentication", jsonData)

		assert.Equal(t, code, http.StatusUnprocessableEntity)
		assert.StringContains(t, body, "This field cannot be blank")
	})
}
