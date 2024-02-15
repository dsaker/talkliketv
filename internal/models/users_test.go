package models

import (
	"github.com/stretchr/testify/suite"
	"log"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/test"
	"testing"
)

const (
	falseFlipped = false
)

type ModelTestSuite struct {
	suite.Suite
	testDb *test.TestDatabase
	u      UserModel
	p      PhraseModel
	m      MovieModel
}

func (suite *ModelTestSuite) SetupSuite() {
	suite.testDb = test.SetupTestDatabase()
	suite.u = UserModel{DB: suite.testDb.DbInstance, CtxTimeout: test.DbCtxTimeout}
	suite.p = PhraseModel{DB: suite.testDb.DbInstance, CtxTimeout: test.DbCtxTimeout}
	suite.m = MovieModel{DB: suite.testDb.DbInstance, CtxTimeout: test.DbCtxTimeout}
}

func (suite *ModelTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
}

func TestModelTestSuite(t *testing.T) {
	suite.Run(t, new(ModelTestSuite))
}

func (suite *ModelTestSuite) TestUserModelExists() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name   string
		userId int
		want   bool
	}{
		{
			name:   "Valid ID",
			userId: test.ValidUserId,
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
			exists, err := suite.u.Exists(tt.userId)

			assert.Equal(t, exists, tt.want)
			assert.NilError(t, err)
		})
	}
}

func (suite *ModelTestSuite) TestUserModelInsert() {
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

			user := &User{
				Name:       tt.userName,
				Email:      tt.userEmail,
				LanguageId: tt.userLanguage,
			}
			err := suite.u.Insert(user, tt.userPassword)

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *ModelTestSuite) TestUserModelAuthenticate() {
	t := suite.T()

	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	const (
		validUserEmail = "authenticateuser@email.com"
	)

	user := &User{
		Name:       "newUser",
		Email:      validUserEmail,
		LanguageId: 2,
	}

	insertErr := suite.u.Insert(user, test.ValidPassword)
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
			userPassword: test.ValidPassword,
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
			userPassword: test.ValidPassword,
			wantErr:      ErrInvalidCredentials,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			UserId, _, err := suite.u.Authenticate(tt.userEmail, tt.userPassword)

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

func (suite *ModelTestSuite) TestUserModelGet() {
	t := suite.T()

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name    string
		userId  int
		wantErr error
	}{
		{
			name:   "Valid Authenticate",
			userId: test.ValidUserId,
		},
		{
			name:    "Wrong Password",
			userId:  -999999,
			wantErr: ErrNoRecord,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			_, err := suite.u.Get(tt.userId)

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *ModelTestSuite) TestUserModelPasswordUpdate() {
	t := suite.T()

	const (
		validUserEmail = "passwordupdateuser@email.com"
	)

	user := &User{
		Name:       "passwordUpdateUser",
		Email:      validUserEmail,
		LanguageId: test.ValidLanguageId,
	}

	err := suite.u.Insert(user, test.ValidPassword)
	if err != nil {
		log.Fatal("failed to insert user: TestUserModelPasswordUpdate ", err)
	}

	validUserPasswordId, _, err := suite.u.Authenticate(validUserEmail, test.ValidPassword)
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
			userId:              validUserPasswordId,
			userNewPassword:     "newPassword",
			userCurrentPassword: test.ValidPassword,
		},
		{
			name:                "Valid Authenticate",
			userId:              test.ValidUserId,
			userNewPassword:     "newPassword",
			userCurrentPassword: "wrongPassword",
			wantErr:             ErrInvalidCredentials,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			err = suite.u.WebPasswordUpdate(tt.userId, tt.userCurrentPassword, tt.userNewPassword)

			if err != nil {
				assert.Equal(t, err, tt.wantErr)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}

func (suite *ModelTestSuite) TestUserModelLanguageUpdate() {
	t := suite.T()
	// Skip the test if the "-short" flag is provided when running the test.
	if testing.Short() {
		t.Skip("models: skipping integration test")
	}

	user, _ := suite.u.Get(test.ValidUserId)

	// Set up a suite of table-driven tests and expected results.
	tests := []struct {
		name          string
		languageId    int
		wantErrString string
	}{
		{
			name:       "Valid Id",
			languageId: test.ValidLanguageId,
		},
		{
			name:          "Invalid Language Id",
			languageId:    -99,
			wantErrString: "users_language_id_fkey",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			user.LanguageId = tt.languageId
			err := suite.u.Update(user)

			if err != nil {
				assert.StringContains(t, err.Error(), tt.wantErrString)
			} else {
				assert.NilError(t, err)
			}
		})
	}
}
