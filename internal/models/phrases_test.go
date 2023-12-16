package models

import (
	"github.com/stretchr/testify/suite"
	"talkliketv.net/internal/assert"
	"testing"
)

type PhraseModelTestSuite struct {
	suite.Suite
	testDb *TestDatabase
}

func (suite *PhraseModelTestSuite) SetupSuite() {
	suite.testDb = SetupTestDatabase()
}

func (suite *PhraseModelTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
}

func (suite *PhraseModelTestSuite) TestNextTen() {
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
			movieId:    1,
			userId:     9999,
			numPhrases: 10,
			flipped:    false,
		},
		{
			name:       "Invalid userId",
			movieId:    1,
			userId:     -9999,
			flipped:    false,
			numPhrases: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			// Create a new instance of the PhraseModel.
			m := PhraseModel{suite.testDb.DbInstance}

			frontendPhrases, err := m.NextTen(tt.userId, tt.movieId, tt.flipped)

			assert.Equal(t, len(frontendPhrases), tt.numPhrases)
			assert.NilError(t, err)
		})
	}
}

func TestPhraseModelTestSuite(t *testing.T) {
	suite.Run(t, new(PhraseModelTestSuite))
}
