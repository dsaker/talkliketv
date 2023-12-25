package application

import (
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"testing"
)

func TestPhraseCorrect(t *testing.T) {
	app := newTestApplication(t)
	ts := newTestServer(t, app.Routes())
	defer ts.Close()

	validCSRFToken := login(t, ts)

	const (
		validPhraseId = "1"
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
			csrfToken: validCSRFToken,
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
			csrfToken: validCSRFToken,
			wantCode:  http.StatusNotFound,
		},
		{
			name:      "Invalid PhraseId String",
			phraseId:  "A",
			movieId:   validMovieId,
			csrfToken: validCSRFToken,
			wantCode:  http.StatusBadRequest,
		},
		{
			name:      "Not Found MovieId",
			phraseId:  validPhraseId,
			movieId:   "-2",
			csrfToken: validCSRFToken,
			wantCode:  http.StatusNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			form := url.Values{}
			form.Add("phrase_id", tt.phraseId)
			form.Add("movie_id", tt.movieId)
			form.Add("csrf_token", tt.csrfToken)

			code, _, _ := ts.postForm(t, "/phrase/correct", form)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}
