package main

import (
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"testing"
)

func (suite *WebNoLoginTestSuite) TestUserSignupPost() {

	t := suite.T()

	const (
		validName     = "user12"
		validPassword = "validPa$$word"
		validEmail    = "bob@example.com"
		validLanguage = "Spanish"
		formTag       = "<form action='/user/signup' method='POST' novalidate>"
	)

	tests := []struct {
		name         string
		userName     string
		userEmail    string
		userLanguage string
		userPassword string
		csrfToken    string
		wantCode     int
		wantFormTag  string
	}{
		{
			name:         "Valid Submission",
			userName:     validName,
			userEmail:    validEmail,
			userLanguage: validLanguage,
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusSeeOther,
		},
		{
			name:         "Invalid CSRF Token",
			userName:     "invalidcsrf",
			userEmail:    "invalidcsrf@email.com",
			userLanguage: validLanguage,
			userPassword: validPassword,
			csrfToken:    "wrongToken",
			wantCode:     http.StatusBadRequest,
		},
		{
			name:         "Empty Name",
			userName:     "",
			userEmail:    "emptyname@email.com",
			userLanguage: validLanguage,
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  "This field cannot be blank",
		},
		{
			name:         "Empty Email",
			userName:     "emptyemail",
			userEmail:    "",
			userLanguage: validLanguage,
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  "This field cannot be blank",
		},
		{
			name:         "Empty Password",
			userName:     "emptypassword",
			userEmail:    "emptypassword@email.com",
			userLanguage: validLanguage,
			userPassword: "",
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  "This field cannot be blank",
		},
		{
			name:         "Invalid Email",
			userName:     "invalidemail",
			userEmail:    "bob@example.",
			userLanguage: validLanguage,
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  "This field must be a valid email address",
		},
		{
			name:         "Short Password",
			userName:     "shorpassword",
			userEmail:    "shorpassword@email.com",
			userLanguage: validLanguage,
			userPassword: "pa$$",
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  "This field must be at least 8 characters long",
		},
		{
			name:         "Duplicate Email",
			userName:     "duplicateemail",
			userEmail:    "user2@email.com",
			userLanguage: validLanguage,
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  "Email address is already in use",
		},
		{
			name:         "Invalid Language",
			userName:     "validName1",
			userEmail:    "validName1@email.com",
			userLanguage: "Made Up Language",
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusBadRequest,
			wantFormTag:  "Bad Request",
		},
		{
			name:         "Duplicate Name",
			userName:     "user2",
			userEmail:    "validName1@email.com",
			userLanguage: validLanguage,
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  "Username is already in use",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("name", tt.userName)
			form.Add("email", tt.userEmail)
			form.Add("language", tt.userLanguage)
			form.Add("password", tt.userPassword)
			form.Add("csrf_token", tt.csrfToken)

			code, _, body := suite.ts.PostForm(t, "/user/signup", form)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantFormTag != "" {
				assert.StringContains(t, body, tt.wantFormTag)
			}
		})
	}
}

func (suite *WebTestSuite) TestAccountLanguageUpdatePost() {
	t := suite.T()

	const (
		validLanguage = "Spanish"
		formTag       = "<form action='/account/language/update' method='POST' novalidate>"
	)

	tests := []struct {
		name         string
		userLanguage string
		csrfToken    string
		wantCode     int
		wantTag      string
	}{
		{
			name:         "Valid submission",
			userLanguage: validLanguage,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusSeeOther,
		},
		{
			name:         "Invalid CSRF Token",
			userLanguage: validLanguage,
			csrfToken:    "wrongToken",
			wantCode:     http.StatusBadRequest,
		},
		{
			name:         "Empty language",
			userLanguage: "",
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      formTag,
		},
		{
			name:         "Wrong language",
			userLanguage: "Invalid Language",
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantTag:      formTag,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("language", tt.userLanguage)
			form.Add("csrf_token", tt.csrfToken)

			code, _, body := suite.ts.PostForm(t, "/account/language/update", form)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}

func (suite *WebTestSuite) TestUserLoginPost() {
	t := suite.T()

	const (
		validPassword = "pa$$word"
		validEmail    = "alice@example.com"
		formTag       = "<form action='/user/login' method='POST' novalidate>"
	)

	tests := []struct {
		name         string
		userEmail    string
		userPassword string
		csrfToken    string
		wantCode     int
		wantFormTag  string
	}{
		{
			name:         "Invalid CSRF Token",
			userEmail:    validEmail,
			userPassword: validPassword,
			csrfToken:    "wrongToken",
			wantCode:     http.StatusBadRequest,
		},
		{
			name:         "Empty email",
			userEmail:    "",
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  formTag,
		},
		{
			name:         "Empty password",
			userEmail:    validEmail,
			userPassword: "",
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  formTag,
		},
		{
			name:         "Invalid email",
			userEmail:    "bob@example.",
			userPassword: validPassword,
			csrfToken:    suite.validCSRFToken,
			wantCode:     http.StatusUnprocessableEntity,
			wantFormTag:  formTag,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("email", tt.userEmail)
			form.Add("password", tt.userPassword)
			form.Add("csrf_token", tt.csrfToken)

			code, _, body := suite.ts.PostForm(t, "/user/login", form)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantFormTag != "" {
				assert.StringContains(t, body, tt.wantFormTag)
			}
		})
	}
}

func (suite *WebTestSuite) TestAccountPasswordUpdatePost() {
	t := suite.T()

	const (
		validCurrentPassword         = "password"
		validNewPassword             = "newpassword"
		validNewPasswordConfirmation = "newpassword"
		wantTag                      = "<form action='/account/password/update' method='POST' novalidate>"
	)

	tests := []struct {
		name                    string
		currentPassword         string
		newPassword             string
		newPasswordConfirmation string
		csrfToken               string
		wantCode                int
		wantTag                 string
	}{
		{
			name:                    "Valid submission",
			currentPassword:         validCurrentPassword,
			newPassword:             validNewPassword,
			newPasswordConfirmation: validNewPasswordConfirmation,
			csrfToken:               suite.validCSRFToken,
			wantCode:                http.StatusSeeOther,
		},
		{
			name:                    "Invalid CSRF Token",
			currentPassword:         validCurrentPassword,
			newPassword:             validNewPassword,
			newPasswordConfirmation: validNewPasswordConfirmation,
			csrfToken:               "wrongToken",
			wantCode:                http.StatusBadRequest,
		},
		{
			name:                    "Empty Current Password",
			currentPassword:         "",
			newPassword:             validNewPassword,
			newPasswordConfirmation: validNewPasswordConfirmation,
			csrfToken:               suite.validCSRFToken,
			wantCode:                http.StatusUnprocessableEntity,
			wantTag:                 wantTag,
		},
		{
			name:                    "Empty New Password",
			currentPassword:         validCurrentPassword,
			newPassword:             "",
			newPasswordConfirmation: validNewPasswordConfirmation,
			csrfToken:               suite.validCSRFToken,
			wantCode:                http.StatusUnprocessableEntity,
			wantTag:                 wantTag,
		},
		{
			name:                    "Empty Password Confirmation",
			currentPassword:         validCurrentPassword,
			newPassword:             validNewPassword,
			newPasswordConfirmation: "",
			csrfToken:               suite.validCSRFToken,
			wantCode:                http.StatusUnprocessableEntity,
			wantTag:                 wantTag,
		},
		{
			name:                    "Incorrect Current Password",
			currentPassword:         "wrong",
			newPassword:             validNewPassword,
			newPasswordConfirmation: validNewPasswordConfirmation,
			csrfToken:               suite.validCSRFToken,
			wantCode:                http.StatusUnprocessableEntity,
			wantTag:                 wantTag,
		},
		{
			name:                    "New Password And Confirmation Do Not Match",
			currentPassword:         validCurrentPassword,
			newPassword:             "wrong",
			newPasswordConfirmation: validNewPasswordConfirmation,
			csrfToken:               suite.validCSRFToken,
			wantCode:                http.StatusUnprocessableEntity,
			wantTag:                 wantTag,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("currentPassword", tt.currentPassword)
			form.Add("newPassword", tt.newPassword)
			form.Add("newPasswordConfirmation", tt.newPasswordConfirmation)
			form.Add("csrf_token", tt.csrfToken)

			code, _, body := suite.ts.PostForm(t, "/account/password/update", form)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}