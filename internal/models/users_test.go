package models

import (
	"github.com/stretchr/testify/suite"
	"talkliketv.net/internal/assert"
	"testing"
)

type UserModelTestSuite struct {
	suite.Suite
	testDb *TestDatabase
}

func (suite *UserModelTestSuite) SetupSuite() {
	suite.testDb = SetupTestDatabase()
}

func (suite *UserModelTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
}

func (suite *UserModelTestSuite) TestUserModelExists() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name   string
		userID int
		want   bool
	}{
		{
			name:   "Valid ID",
			userID: 9999,
			want:   true,
		},
		{
			name:   "Zero ID",
			userID: 0,
			want:   false,
		},
		{
			name:   "Non-existent ID",
			userID: -1,
			want:   false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			// Create a new instance of the UserModel.
			m := UserModel{suite.testDb.DbInstance}

			// Call the UserModel.Exists() method and check that the return
			// value and error match the expected values for the sub-test.
			exists, err := m.Exists(tt.userID)

			assert.Equal(t, exists, tt.want)
			assert.NilError(t, err)
		})
	}
}

func TestUserModelTestSuite(t *testing.T) {
	suite.Run(t, new(UserModelTestSuite))
}
