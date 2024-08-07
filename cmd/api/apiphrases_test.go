package main

import (
	"encoding/json"
	"net/http"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/test"
	"testing"
)

func (suite *ApiTestSuite) TestApiPhraseCorrect() {
	t := suite.T()

	tests := []struct {
		name     string
		phraseId any
		movieId  int
		wantCode int
	}{
		{
			name:     "Valid submission",
			phraseId: test.ValidPhraseIdInt,
			movieId:  test.ValidMovieIdInt,
			wantCode: http.StatusOK,
		},
		{
			name:     "Not Found PhraseId",
			phraseId: -2,
			movieId:  test.ValidPhraseIdInt,
			wantCode: http.StatusNotFound,
		},
		{
			name:     "Not Found MovieId",
			phraseId: test.ValidPhraseIdInt,
			movieId:  -2,
			wantCode: http.StatusNotFound,
		},
		{
			name:     "Bad Request",
			phraseId: "string",
			movieId:  test.ValidMovieIdInt,
			wantCode: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			jsonData, err := json.Marshal(map[string]interface{}{
				"phrase_id": tt.phraseId,
				"movie_id":  tt.movieId,
			})
			if err != nil {
				t.Errorf("could not marshal json: %s\n", err)
				return
			}
			code, _, _ := suite.ts.Request(t, jsonData, "/v1/phrases/correct", http.MethodPost, suite.authToken)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}

func (suite *ApiNoLoginTestSuite) TestListPhrasesHandler() {
	t := suite.T()
	prefix := "listphrases"
	email := prefix + test.ValidEmail
	register(prefix, t, suite.ts)
	activate(email, suite.app.Models)

	_, err := suite.app.Models.Users.GetByEmail(email)
	if err != nil {
		t.Fatalf("could not get user by email: %s", err)
	}
	t.Run("List Phrases Flow", func(t *testing.T) {

		code, _, body := suite.ts.Get(t, "/v1/phrases")

		assert.Equal(t, code, http.StatusUnauthorized)
		assert.StringContains(t, body, "you must be authenticated to access this resource")

		authToken := getAuthToken(prefix, t, suite.ts)
		code, _, body = suite.ts.Request(t, nil, "/v1/phrases", http.MethodGet, authToken)
		assert.Equal(t, code, http.StatusUnprocessableEntity)
		assert.StringContains(t, body, "please choose a movie first")

		chooseMovie(t, suite.ts, authToken)
		code, _, body = suite.ts.Request(t, nil, "/v1/phrases", http.MethodGet, authToken)
		assert.Equal(t, code, http.StatusOK)
		assert.StringContains(t, body, test.MovieString)
	})
}
