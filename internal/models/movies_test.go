package models

import (
	"github.com/stretchr/testify/suite"
	"talkliketv.net/internal/assert"
	"testing"
)

type MovieModelTestSuite struct {
	suite.Suite
	testDb *TestDatabase
}

func (suite *MovieModelTestSuite) SetupSuite() {
	suite.testDb = SetupTestDatabase()
}

func (suite *MovieModelTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
}

func (suite *MovieModelTestSuite) TestChooseMovie() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validMovieId = 1
		validUserId  = 9999
	)

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name    string
		userId  int
		movieId int
	}{
		{
			name:    "Valid ID",
			movieId: validMovieId,
			userId:  validUserId,
		},
		{
			name:    "Change Movie",
			movieId: 2,
			userId:  validUserId,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			// Create a new instance of the MovieModel.
			m := MovieModel{suite.testDb.DbInstance}

			err := m.ChooseMovie(tt.userId, tt.movieId)
			assert.NilError(t, err)
		})
	}
}

func TestMovieModelTestSuite(t *testing.T) {
	suite.Run(t, new(MovieModelTestSuite))
}
