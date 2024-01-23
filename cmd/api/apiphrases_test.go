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
		phraseId int
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
			code, _, _ := suite.ts.Request(t, jsonData, "/v1/phrase/correct", http.MethodPost, suite.authToken)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}
