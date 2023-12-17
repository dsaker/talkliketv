package models

import (
	"github.com/stretchr/testify/suite"
	"talkliketv.net/internal/assert"
	"testing"
)

type PhraseModelTestSuite struct {
	suite.Suite
	testDb *TestDatabase
	m      PhraseModel
}

func (suite *PhraseModelTestSuite) SetupSuite() {
	suite.testDb = SetupTestDatabase()
	suite.m = PhraseModel{suite.testDb.DbInstance}
}

func (suite *PhraseModelTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
}

func (suite *PhraseModelTestSuite) TestPhraseModelNextTen() {
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
		name       string
		userId     int
		movieId    int
		flipped    bool
		numPhrases int
	}{
		{
			name:       "Valid ID",
			movieId:    validMovieId,
			userId:     validUserId,
			numPhrases: 10,
			flipped:    false,
		},
		{
			name:       "Invalid userId",
			movieId:    validMovieId,
			userId:     -9999,
			flipped:    false,
			numPhrases: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			frontendPhrases, err := suite.m.NextTen(tt.userId, tt.movieId, tt.flipped)

			assert.Equal(t, len(frontendPhrases), tt.numPhrases)
			assert.NilError(t, err)
		})
	}
}

func (suite *PhraseModelTestSuite) TestPhraseModelPhraseCorrect() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validMovieId  = 1
		validPhraseId = 2
		validUserId   = 9999
		validFlipped  = false
	)

	t.Run("Phrase Correct", func(t *testing.T) {

		sumBefore, totalBefore, err := suite.m.PercentageDone(validUserId, validMovieId, validFlipped)
		assert.NilError(t, err)
		err = suite.m.PhraseCorrect(validUserId, validPhraseId, validMovieId, validFlipped)
		assert.NilError(t, err)
		sumAfter, totalAfter, err := suite.m.PercentageDone(validUserId, validMovieId, validFlipped)
		assert.NilError(t, err)
		assert.GreaterThan(t, sumAfter, sumBefore)
		assert.Equal(t, totalBefore, totalAfter)
	})
}

func TestPhraseModelTestSuite(t *testing.T) {
	suite.Run(t, new(PhraseModelTestSuite))
}
