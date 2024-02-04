package main

import (
	"encoding/json"
	"net/http"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/test"
	"testing"
)

func (suite *ApiTestSuite) TestApiMoviesChoose() {
	t := suite.T()

	tests := []struct {
		name     string
		movieId  int
		wantCode int
	}{
		{
			name:     "Valid submission",
			movieId:  test.ValidMovieIdInt,
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

	tests := []struct {
		name       string
		movieId    string
		wantCode   int
		wantString string
	}{
		{
			name:     "Valid submission",
			movieId:  test.ValidMovieId,
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

			code, _, body := suite.ts.Request(t, nil, "/v1/movies/mp3/"+tt.movieId, http.MethodGet, suite.authToken)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantString != "" {
				assert.StringContains(t, body, tt.wantString)
			}

		})
	}
}

func (suite *ApiTestSuite) TestApiMoviesMp3Flow() {
	t := suite.T()
	prefix := "mp3flow"
	validUrl := "/v1/movies/mp3/" + test.ValidMovieId
	email := prefix + test.TestEmail
	_ = register(prefix, t, suite.ts)
	t.Run("Api Movies Mp3 Flow", func(t *testing.T) {

		code, _, body := suite.ts.Get(t, validUrl)
		assert.Equal(t, code, http.StatusUnauthorized)
		assert.StringContains(t, body, "you must be authenticated to access this resource")

		activate(email, suite.app.Models)
		authToken := getAuthToken(prefix, t, suite.ts)
		code, _, _ = suite.ts.Request(t, nil, validUrl, http.MethodGet, authToken)
		assert.Equal(t, code, http.StatusOK)
	})
}

func (suite *ApiTestSuite) TestApiListMoviesHandler() {
	t := suite.T()

	tests := []struct {
		name       string
		url        string
		authToken  string
		wantCode   int
		wantString string
		wantSize   int
	}{
		{
			name:       "Valid submission",
			url:        "/v1/movies",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "MissAdrenalineS01E01",
			wantSize:   5,
		},
		{
			name:       "Title Nothing",
			url:        "/v1/movies?title=nothing&page_size=10",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "NothingToSeeHereS01E01",
			wantSize:   5,
		},
		{
			name:       "Mp3 False",
			url:        "/v1/movies?mp3=false",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "GreysAnatomyS05E14",
			wantSize:   2,
		},
		{
			name:       "Mp3 True",
			url:        "/v1/movies?mp3=true",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "NothingToSeeHereS01E01",
			wantSize:   3,
		},
		{
			name:       "Page Size 1",
			url:        "/v1/movies?page_size=1",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "NothingToSeeHereS01E02",
			wantSize:   1,
		},
		{
			name:       "Sort Num Subs Dec",
			url:        "/v1/movies?page_size=1&sort=num_subs",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "NothingToSeeHereS01E02",
			wantSize:   1,
		},
		{
			name:       "Sort Num Subs Asc",
			url:        "/v1/movies?page_size=1&sort=-num_subs",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "MissAdrenalineS01E01",
			wantSize:   1,
		},
		{
			name:       "Sort Title Dec",
			url:        "/v1/movies?page_size=1&sort=title",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "GreysAnatomyS05E14",
			wantSize:   1,
		},
		{
			name:       "Sort Title Asc",
			url:        "/v1/movies?page_size=1&sort=-title",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "TheMannyS01E01",
			wantSize:   1,
		},
		{
			name:       "Movie Page",
			url:        "/v1/movies?page=2&page_size=1&sort=-title",
			authToken:  suite.authToken,
			wantCode:   http.StatusOK,
			wantString: "NothingToSeeHereS01E02",
			wantSize:   1,
		},
		{
			name:       "Movie Page",
			url:        "/v1/movies?page=2&page_size=string&sort=-title",
			authToken:  suite.authToken,
			wantCode:   http.StatusUnprocessableEntity,
			wantString: "must be an integer value",
			wantSize:   0,
		},
		{
			name:       "No Auth Token",
			url:        "/v1/movies",
			authToken:  "",
			wantCode:   http.StatusUnauthorized,
			wantString: "you must be authenticated to access this resource",
			wantSize:   0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			code, _, body := suite.ts.Request(t, nil, tt.url, http.MethodGet, tt.authToken)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantString != "" {
				assert.StringContains(t, body, tt.wantString)
			}

			var moviesStruct struct {
				Movies []*models.Movie `json:"movies"`
			}
			err := json.Unmarshal([]byte(body), &moviesStruct)
			if err != nil {
				t.Errorf("could not marshal json: %s\n", err)
				return
			}
			assert.Equal(t, len(moviesStruct.Movies), tt.wantSize)

		})
	}
}
