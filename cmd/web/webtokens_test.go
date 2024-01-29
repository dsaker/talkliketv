package main

import (
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/test"
	"testing"
)

func (suite *WebNoLoginTestSuite) TestCreatePasswordResetToken() {
	t := suite.T()

	const (
		resetUser      = "passwordReset"
		resetUserEmail = resetUser + test.TestEmail
		wantTag        = "<form action='/user/login' method='POST' novalidate>"
	)
	signup(t, suite.ts, resetUser)
	activate(resetUserEmail, suite.app.Models)

	tests := []struct {
		name      string
		email     string
		csrfToken string
		wantCode  int
		wantTag   string
	}{
		{
			name:      "Valid submission",
			email:     resetUserEmail,
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusOK,
			wantTag:   "An email will be sent to you containing password reset instructions",
		},
		{
			name:      "Invalid CSRF Token",
			email:     resetUserEmail,
			csrfToken: "wrongToken",
			wantCode:  http.StatusBadRequest,
		},
		{
			name:      "Empty Email",
			email:     "",
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusUnprocessableEntity,
			wantTag:   wantTag,
		},
		{
			name:      "Invalid Email",
			email:     "invalidemail.com",
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusUnprocessableEntity,
			wantTag:   wantTag,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("email", tt.email)
			form.Add("csrf_token", tt.csrfToken)

			code, _, body := suite.ts.PostForm(t, "/tokens/password-reset", form)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}

func (suite *WebNoLoginTestSuite) TestCreatePasswordResetTokenNotActivated() {
	t := suite.T()

	const (
		notActiveUser = "notActive"
		wantTag       = "user account must be activated"
	)

	signup(t, suite.ts, notActiveUser)

	t.Run("Password Reset Not Activated", func(t *testing.T) {
		form := url.Values{}
		form.Add("email", notActiveUser+test.TestEmail)
		form.Add("csrf_token", suite.validCSRFToken)

		code, _, body := suite.ts.PostForm(t, "/tokens/password-reset", form)

		assert.Equal(t, code, http.StatusUnprocessableEntity)
		assert.StringContains(t, body, wantTag)
	})
}
