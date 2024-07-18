package models

import (
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/test"
	"testing"
)

func (suite *ModelTestSuite) TestPhraseModelNextTen() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

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
			movieId:    test.ValidMovieIdInt,
			userId:     test.ValidUserId,
			numPhrases: 10,
			flipped:    false,
		},
		{
			name:       "Invalid userId",
			movieId:    test.ValidMovieIdInt,
			userId:     -9999,
			flipped:    false,
			numPhrases: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			frontendPhrases, err := suite.p.NextTen(tt.userId, tt.movieId, tt.flipped)

			assert.Equal(t, len(frontendPhrases), tt.numPhrases)
			assert.NilError(t, err)
		})
	}
}

func (suite *ModelTestSuite) TestPhraseModelPhraseCorrect() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	t.Run("Phrase Correct", func(t *testing.T) {

		sumBefore, totalBefore, err := suite.p.PercentageDone(test.ValidUserId, test.ValidMovieIdInt, falseFlipped)
		assert.NilError(t, err)
		err = suite.p.PhraseCorrect(test.ValidUserId, test.ValidPhraseIdInt, test.ValidMovieIdInt, falseFlipped)
		assert.NilError(t, err)
		sumAfter, totalAfter, err := suite.p.PercentageDone(test.ValidUserId, test.ValidMovieIdInt, falseFlipped)
		assert.NilError(t, err)
		assert.GreaterThan(t, sumAfter, sumBefore)
		assert.Equal(t, totalBefore, totalAfter)
	})
}
