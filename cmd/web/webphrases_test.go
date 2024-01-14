package main

import (
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"testing"
)

func (suite *WebTestSuite) TestPhraseCorrect() {
	t := suite.T()

	const (
		validPhraseId = "2"
		validMovieId  = "1"
	)

	tests := []struct {
		name      string
		phraseId  string
		movieId   string
		csrfToken string
		wantCode  int
	}{
		{
			name:      "Valid submission",
			phraseId:  validPhraseId,
			movieId:   validMovieId,
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusOK,
		},
		{
			name:      "Invalid CSRF Token",
			phraseId:  validPhraseId,
			movieId:   validMovieId,
			csrfToken: "wrongToken",
			wantCode:  http.StatusBadRequest,
		},
		{
			name:      "Not Found PhraseId",
			phraseId:  "-2",
			movieId:   validMovieId,
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusNotFound,
		},
		{
			name:      "Invalid PhraseId String",
			phraseId:  "A",
			movieId:   validMovieId,
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusBadRequest,
		},
		{
			name:      "Not Found MovieId",
			phraseId:  validPhraseId,
			movieId:   "-2",
			csrfToken: suite.validCSRFToken,
			wantCode:  http.StatusNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("phrase_id", tt.phraseId)
			form.Add("movie_id", tt.movieId)
			form.Add("csrf_token", tt.csrfToken)

			code, _, _ := suite.ts.PostForm(t, "/phrase/correct", form)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}

func (suite *WebTestSuite) TestGetPhrase() {

	t := suite.T()

	t.Run("Get Phrases", func(t *testing.T) {
		form := url.Values{}
		form.Add("csrf_token", suite.validCSRFToken)
		code, _, body := suite.ts.Get(t, "/phrase/view")

		assert.Equal(t, code, http.StatusOK)
		assert.StringContains(t, body, "<td><button id=\"startButton\">Start</button></td>")
	})
}
