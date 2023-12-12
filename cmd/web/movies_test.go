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
	)

	tests := []struct {
		name      string
		movieId   string
		csrfToken string
		wantCode  int
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
		{
			name:      "Invalid MovieId",
			movieId:   "-2",
			csrfToken: validCSRFToken,
			wantCode:  http.StatusNotFound,
		},
		{
			name:      "Invalid MovieId String",
			movieId:   "A",
			csrfToken: validCSRFToken,
			wantCode:  http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("movie_id", tt.movieId)
			form.Add("csrf_token", tt.csrfToken)

			code, _, _ := ts.postForm(t, "/movies/choose", form)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}

func TestMoviesMp3(t *testing.T) {
	app := newTestApplication(t)
	ts := newTestServer(t, app.routes())
	defer ts.Close()

	_ = login(t, ts)

	const (
		validMovieId = "1"
	)

	tests := []struct {
		name      string
		movieId   string
		csrfToken string
		wantCode  int
	}{
		{
			name:     "Valid submission",
			movieId:  validMovieId,
			wantCode: http.StatusOK,
		},
		{
			name:     "Invalid MovieId",
			movieId:  "-2",
			wantCode: http.StatusBadRequest,
		},
		{
			name:     "Invalid MovieId String",
			movieId:  "A",
			wantCode: http.StatusBadRequest,
		},
		{
			name:     "Empty Movie String",
			movieId:  "A",
			wantCode: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			code, _, _ := ts.get(t, "/movies/mp3/"+tt.movieId)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}
