package main

import (
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"testing"
)

func TestMoviesChoose(t *testing.T) {
	app := newTestApplication(t)
	ts := newTestServer(t, app.routes())
	defer ts.Close()

	validCSRFToken := login(t, ts)

	const (
		validMovieId = "1"
		validTag     = "<form action=\"/movies/choose\" method=\"POST\">"
	)

	tests := []struct {
		name      string
		movieId   string
		csrfToken string
		wantCode  int
		wantTag   string
	}{
		{
			name:      "Valid submission",
			movieId:   validMovieId,
			csrfToken: validCSRFToken,
			wantCode:  http.StatusSeeOther,
		},
		{
			name:      "Invalid CSRF Token",
			movieId:   validMovieId,
			csrfToken: "wrongToken",
			wantCode:  http.StatusBadRequest,
		},
		//{
		//	name:      "Invalid MovieId",
		//	movieId:   "-1",
		//	csrfToken: validCSRFToken,
		//	wantCode:  http.StatusUnprocessableEntity,
		//	wantTag:   validTag,
		//},
		//{
		//	name:                    "Empty New Password",
		//	currentPassword:         validCurrentPassword,
		//	newPassword:             "",
		//	newPasswordConfirmation: validNewPasswordConfirmation,
		//	csrfToken:               validCSRFToken,
		//	wantCode:                http.StatusUnprocessableEntity,
		//	wantTag:                 wantTag,
		//},
		//{
		//	name:                    "Empty Password Confirmation",
		//	currentPassword:         validCurrentPassword,
		//	newPassword:             validNewPassword,
		//	newPasswordConfirmation: "",
		//	csrfToken:               validCSRFToken,
		//	wantCode:                http.StatusUnprocessableEntity,
		//	wantTag:                 wantTag,
		//},
		//{
		//	name:                    "Incorrect Current Password",
		//	currentPassword:         "wrong",
		//	newPassword:             validNewPassword,
		//	newPasswordConfirmation: validNewPasswordConfirmation,
		//	csrfToken:               validCSRFToken,
		//	wantCode:                http.StatusUnprocessableEntity,
		//	wantTag:                 wantTag,
		//},
		//{
		//	name:                    "New Password And Confirmation Do Not Match",
		//	currentPassword:         validCurrentPassword,
		//	newPassword:             "wrong",
		//	newPasswordConfirmation: validNewPasswordConfirmation,
		//	csrfToken:               validCSRFToken,
		//	wantCode:                http.StatusUnprocessableEntity,
		//	wantTag:                 wantTag,
		//},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("movie_id", tt.movieId)
			form.Add("csrf_token", tt.csrfToken)

			code, _, body := ts.postForm(t, "/movies/choose", form)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}
