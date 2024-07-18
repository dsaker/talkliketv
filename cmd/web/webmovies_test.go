package main

import (
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/test"
	"testing"
)

func (suite *WebTestSuite) TestMoviesChoose() {
	t := suite.T()

	tests := []struct {
		name      string
		movieId   string
		csrfToken string
		wantCode  int
	}{
		{
			name:      "Valid submission",
			movieId:   test.ValidMovieId,
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusSeeOther,
		},
		{
			name:      "Invalid CSRF Token",
			movieId:   test.ValidMovieId,
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

			code, _, _ := suite.ts.PostForm(t, "/movies/choose", form)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}

func (suite *WebTestSuite) TestMoviesMp3() {
	t := suite.T()

	tests := []struct {
		name      string
		movieId   string
		csrfToken string
		wantCode  int
	}{
		{
			name:     "Valid submission",
			movieId:  "2",
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
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			code, _, _ := suite.ts.Get(t, "/movies/mp3/"+tt.movieId)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}
