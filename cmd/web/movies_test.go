package main

import (
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"testing"
)

func (suite *WebTestSuite) TestMoviesChoose() {
	t := suite.T()

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
			csrfToken: suite.validCSRFToken,
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
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusNotFound,
		},
		{
			name:      "Invalid MovieId String",
			movieId:   "A",
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("movie_id", tt.movieId)
			form.Add("csrf_token", tt.csrfToken)

			code, _, _ := suite.ts.postForm(t, "/movies/choose", form)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}

func (suite *WebTestSuite) TestMoviesMp3() {
	t := suite.T()

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
			movieId:  "",
			wantCode: http.StatusNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			code, _, _ := suite.ts.get(t, "/movies/mp3/"+tt.movieId)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}
