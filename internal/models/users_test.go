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
	m      UserModel
}

func (suite *UserModelTestSuite) SetupSuite() {
	suite.testDb = SetupTestDatabase()
	suite.m = UserModel{suite.testDb.DbInstance}
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
		userId int
		want   bool
	}{
		{
			name:   "Valid ID",
			userId: validUserId,
			want:   true,
		},
		{
			name:   "Zero ID",
			userId: 0,
			want:   false,
		},
		{
			name:   "Non-existent ID",
			userId: -1,
			want:   false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			// Call the UserModel.Exists() method and check that the return
			// value and error match the expected values for the sub-test.
			exists, err := suite.m.Exists(tt.userId)

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

			err := suite.m.Insert(tt.userName, tt.userEmail, tt.userPassword, tt.userLanguage)

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

	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validUserEmail    = "authenticateuser@email.com"
		validUserPassword = "password"
	)

	insertErr := suite.m.Insert("newUser", validUserEmail, validUserPassword, 2)
	if insertErr != nil {
		log.Fatal("failed to setup test", insertErr)
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

			UserId, err := suite.m.Authenticate(tt.userEmail, tt.userPassword)

			if tt.wantUserId {
				assert.NotEqual(t, UserId, 0)
			} else {
				assert.Equal(t, UserId, 0)
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

	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

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

			_, err := suite.m.Get(tt.userId)

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *UserModelTestSuite) TestUserModelPasswordUpdate() {
	t := suite.T()

	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validUserEmail    = "passwordupdateuser@email.com"
		validUserPassword = "password"
	)

	err := suite.m.Insert("newUser", validUserEmail, validUserPassword, 2)
	if err != nil {
		log.Fatal("failed to insert user: TestUserModelPasswordUpdate ", err)
	}

	validUserId, err := suite.m.Authenticate(validUserEmail, validUserPassword)
	if err != nil {
		log.Fatal("failed to authenticate user: TestUserModelPasswordUpdate ", err)
	}

	tests := []struct {
		name                string
		userId              int
		userCurrentPassword string
		userNewPassword     string
		wantErr             error
	}{
		{
			name:                "Valid Authenticate",
			userId:              validUserId,
			userNewPassword:     "newPassword",
			userCurrentPassword: validUserPassword,
		},
		{
			name:                "Valid Authenticate",
			userId:              validUserId,
			userNewPassword:     "newPassword",
			userCurrentPassword: "wrongPassword",
			wantErr:             ErrInvalidCredentials,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			err := suite.m.PasswordUpdate(tt.userId, tt.userCurrentPassword, tt.userNewPassword)

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *UserModelTestSuite) TestUserModelLanguageUpdate() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validUserId     = 9999
		validLanguageId = 2
	)
	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name       string
		userId     int
		languageId int
	}{
		{
			name:       "Valid ID",
			userId:     validUserId,
			languageId: validLanguageId,
		},
		{
			name:       "Zero User ID",
			userId:     0,
			languageId: validLanguageId,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			err := suite.m.LanguageUpdate(tt.userId, tt.languageId)

			assert.NilError(t, err)
		})
	}
}

func (suite *UserModelTestSuite) TestUserModelFlippedUpdate() {
	t := suite.T()

	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validUserEmail    = "flippedupdateuser@email.com"
		validUserPassword = "password"
	)

	err := suite.m.Insert("newUser", validUserEmail, validUserPassword, 2)
	if err != nil {
		log.Fatal("failed to insert user: TestUserModelFlippedUpdate ", err)
	}

	validUserId, err := suite.m.Authenticate(validUserEmail, validUserPassword)
	if err != nil {
		log.Fatal("failed to authenticate user: TestUserModelFlippedUpdate ", err)
	}

	user, err := suite.m.Get(validUserId)
	if err != nil {
		log.Fatal("failed to get user: TestUserModelFlippedUpdate ", err)
	}

	flippedBefore := user.Flipped

	t.Run("Flipped After", func(t *testing.T) {

		err = suite.m.FlippedUpdate(validUserId)
		assert.NilError(t, err)

		user, err = suite.m.Get(validUserId)
		assert.NotEqual(t, flippedBefore, user.Flipped)
	})
}

func TestUserModelTestSuite(t *testing.T) {
	suite.Run(t, new(UserModelTestSuite))
}
