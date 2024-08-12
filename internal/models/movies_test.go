package models

import (
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/test"
	"testing"
)

func (suite *ModelTestSuite) TestMovieModelChooseMovie() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name    string
		userId  int
		movieId int
	}{
		{
			name:    "Valid ID",
			movieId: test.ValidMovieIdInt,
			userId:  test.ValidUserId,
		},
		{
			name:    "Change Movie",
			movieId: 2,
			userId:  test.ValidUserId,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			err := suite.m.UpdateMovie(tt.userId, tt.movieId)
			assert.NilError(t, err)
		})
	}
}

func (suite *ModelTestSuite) TestMovieModelGet() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	tests := []struct {
		name    string
		userId  int
		movieId int
		wantErr error
	}{
		{
			name:    "Valid Id",
			movieId: test.ValidMovieIdInt,
		},
		{
			name:    "Invalid Movie Id",
			movieId: -99,
			wantErr: ErrNoRecord,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			_, err := suite.m.Get(tt.movieId)
			if tt.wantErr != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *ModelTestSuite) TestMovieModelAll() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validLanguageId = 1
	)

	tests := []struct {
		name       string
		userId     int
		languageId int
		wantErr    error
		numMovies  int
	}{
		{
			name:       "Valid Id",
			languageId: validLanguageId,
			numMovies:  0,
		},
		{
			name:       "Invalid Language Id",
			languageId: -99,
			numMovies:  0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			filters := Filters{
				Page:         1,
				PageSize:     20,
				Sort:         "id",
				SortSafeList: []string{"id"},
			}
			movies, _, err := suite.m.All(tt.languageId, "", filters, -1)
			if tt.wantErr != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
			assert.Equal(t, len(movies), tt.numMovies)
		})
	}
}
