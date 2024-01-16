package main

import (
	"encoding/json"
	"net/http"
	"talkliketv.net/internal/assert"
	"testing"
)

func (suite *ApiTestSuite) TestApiMoviesChoose() {
	t := suite.T()

	const (
		validMovieId = 1
	)

	tests := []struct {
		name     string
		movieId  int
		wantCode int
	}{
		{
			name:     "Valid submission",
			movieId:  validMovieId,
			wantCode: http.StatusOK,
		},
		{
			name:     "Not Found MovieId",
			movieId:  -8,
			wantCode: http.StatusNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			jsonData, err := json.Marshal(map[string]interface{}{
				"movie_id": tt.movieId,
			})
			if err != nil {
				t.Errorf("could not marshal json: %s\n", err)
				return
			}

			code, _, _ := suite.ts.Request(t, jsonData, "/v1/movies/choose", http.MethodPatch, suite.authToken)

			assert.Equal(t, code, tt.wantCode)

		})
	}
}

func (suite *ApiTestSuite) TestApiMoviesMp3() {
	t := suite.T()

	const (
		validMovieId = "1"
	)

	tests := []struct {
		name       string
		movieId    string
		csrfToken  string
		wantCode   int
		wantString string
	}{
		{
			name:     "Valid submission",
			movieId:  validMovieId,
			wantCode: http.StatusOK,
		},
		{
			name:     "Not Found MovieId",
			movieId:  "99999999999999999",
			wantCode: http.StatusNotFound,
		},
		{
			name:     "Negative MovieId",
			movieId:  "-8",
			wantCode: http.StatusBadRequest,
		},
		{
			name:     "Empty MovieId",
			movieId:  "",
			wantCode: http.StatusNotFound,
		},
		{
			name:       "Character MovieId",
			movieId:    "A",
			wantCode:   http.StatusBadRequest,
			wantString: "invalid id parameter",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			code, _, body := suite.ts.Get(t, "/v1/movies/mp3/"+tt.movieId)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantString != "" {
				assert.StringContains(t, body, tt.wantString)
			}

		})
	}

}

func (suite *ApiTestSuite) TestApiListMoviesHandler() {
	t := suite.T()

	tests := []struct {
		name       string
		wantCode   int
		wantString string
	}{
		{
			name:       "Valid submission",
			wantCode:   http.StatusOK,
			wantString: "MissAdrenalineS01E01",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			code, _, body := suite.ts.Request(t, nil, "/v1/movies", http.MethodGet, suite.authToken)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantString != "" {
				assert.StringContains(t, body, tt.wantString)
			}

		})
	}
}
