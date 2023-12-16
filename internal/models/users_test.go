package models

import (
	"github.com/stretchr/testify/suite"
	"log"
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

	const (
		validUserId = 9999
	)
	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name   string
		userID int
		want   bool
	}{
		{
			name:   "Valid ID",
			userID: validUserId,
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

func (suite *UserModelTestSuite) TestUserModelInsert() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validUserName     = "testUser"
		validUserEmail    = "testEmail@email.com"
		validUserPassword = "pa$$word"
		validUserLanguage = 1
	)
	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name         string
		userName     string
		userEmail    string
		userPassword string
		userLanguage int
		wantErr      error
	}{
		{
			name:         "Valid Insert",
			userName:     validUserName,
			userEmail:    validUserEmail,
			userPassword: validUserPassword,
			userLanguage: validUserLanguage,
		},
		{
			name:         "Duplicate Email",
			userName:     validUserName,
			userEmail:    "user2@email.com",
			userPassword: validUserPassword,
			userLanguage: validUserLanguage,
			wantErr:      ErrDuplicateEmail,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			// Create a new instance of the UserModel.
			m := UserModel{suite.testDb.DbInstance}

			err := m.Insert(tt.userName, tt.userEmail, tt.userPassword, tt.userLanguage)

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *UserModelTestSuite) TestUserModelAuthenticate() {
	t := suite.T()

	m := UserModel{suite.testDb.DbInstance}

	const (
		validUserEmail    = "authenticateuser@email.com"
		validUserPassword = "password"
	)

	insertErr := m.Insert("newUser", validUserEmail, validUserPassword, 2)
	if insertErr != nil {
		log.Fatal("failed to setup test", insertErr)
	}
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name         string
		userEmail    string
		userPassword string
		wantErr      error
		wantUserId   bool
	}{
		{
			name:         "Valid Authenticate",
			userEmail:    validUserEmail,
			userPassword: validUserPassword,
			wantUserId:   true,
		},
		{
			name:         "Wrong Password",
			userEmail:    validUserEmail,
			userPassword: "wrongPassword",
			wantErr:      ErrInvalidCredentials,
		},
		{
			name:         "Wrong Email",
			userEmail:    "wrongEmail@email.com",
			userPassword: validUserPassword,
			wantErr:      ErrInvalidCredentials,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			// Create a new instance of the UserModel.
			m := UserModel{suite.testDb.DbInstance}

			userId, err := m.Authenticate(tt.userEmail, tt.userPassword)

			if tt.wantUserId {
				assert.NotEqual(t, userId, 0)
			} else {
				assert.Equal(t, userId, 0)
			}

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *UserModelTestSuite) TestUserModelGet() {
	t := suite.T()

	const (
		validUserId = 9999
	)

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name    string
		userId  int
		wantErr error
	}{
		{
			name:   "Valid Authenticate",
			userId: validUserId,
		},
		{
			name:    "Wrong Password",
			userId:  -999999,
			wantErr: ErrNoRecord,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			// Create a new instance of the UserModel.
			m := UserModel{suite.testDb.DbInstance}

			_, err := m.Get(tt.userId)

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func TestUserModelTestSuite(t *testing.T) {
	suite.Run(t, new(UserModelTestSuite))
}
