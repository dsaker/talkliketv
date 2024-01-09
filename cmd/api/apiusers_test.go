package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"talkliketv.net/internal/assert"
	"testing"
)

func (suite *ApiNoLoginTestSuite) TestRegisterUserHandler() {

	t := suite.T()

	const (
		validName     = "user12"
		validPassword = "validPa$$word"
		validEmail    = "bob@example.com"
		validLanguage = "Spanish"
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
			userLanguage: validLanguage,
			userPassword: validPassword,
			wantCode:     http.StatusAccepted,
		},
		{
			name:         "Empty Name",
			userName:     "",
			userEmail:    "emptyname@email.com",
			userLanguage: validLanguage,
			userPassword: validPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field cannot be blank",
		},
		{
			name:         "Empty Email",
			userName:     "emptyemail",
			userEmail:    "",
			userLanguage: validLanguage,
			userPassword: validPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field cannot be blank",
		},
		{
			name:         "Empty Password",
			userName:     "emptypassword",
			userEmail:    "emptypassword@email.com",
			userLanguage: validLanguage,
			userPassword: "",
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field cannot be blank",
		},
		{
			name:         "Invalid Email",
			userName:     "invalidemail",
			userEmail:    "bob@example.",
			userLanguage: validLanguage,
			userPassword: validPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field must be a valid email address",
		},
		{
			name:         "Short Password",
			userName:     "shorpassword",
			userEmail:    "shorpassword@email.com",
			userLanguage: validLanguage,
			userPassword: "pa$$",
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "This field must be at least 8 characters long",
		},
		{
			name:         "Duplicate Email",
			userName:     "duplicateemail",
			userEmail:    "user2@email.com",
			userLanguage: validLanguage,
			userPassword: validPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "{\n\t\"error\": {\n\t\t\"email\": \"a user with this email address already exists\"\n\t}\n}\n",
		},
		{
			name:         "Invalid Language",
			userName:     "validName1",
			userEmail:    "validName1@email.com",
			userLanguage: "Made Up Language",
			userPassword: validPassword,
			wantCode:     http.StatusBadRequest,
			wantTag:      "{\n\t\"error\": \"models: no matching record found\"\n}\n",
		},
		{
			name:         "Duplicate Name",
			userName:     "user2",
			userEmail:    "validName1@email.com",
			userLanguage: validLanguage,
			userPassword: validPassword,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      "{\n\t\"error\": {\n\t\t\"username\": \"a user with this username already exists\"\n\t}\n}\n",
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
			code, _, body := suite.ts.post(t, "/v1/users", jsonData)

			assert.Equal(t, code, tt.wantCode)
			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}
