package main

import (
	"encoding/json"
	"flag"
	"github.com/stretchr/testify/suite"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"talkliketv.net/internal/application"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/config"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/mailer"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/test"
	"testing"
)

var cfg config.Config

func init() {
	flag.BoolVar(&cfg.ExpVarEnabled, "expvar-enabled", false, "Enable expvar (disable for testing")
	flag.StringVar(&cfg.Env, "env", "development", "Environment (development|staging|production)")
	flag.StringVar(&cfg.Smtp.Host, "smtp-host", "sandbox.smtp.mailtrap.io", "SMTP host")
	flag.IntVar(&cfg.Smtp.Port, "smtp-port", 25, "SMTP port")
	cfg.Smtp.Username = os.Getenv("smtp-username")
	cfg.Smtp.Password = os.Getenv("smtp-password")
	flag.StringVar(&cfg.Smtp.Sender, "smtp-sender", "TalkLikeTV <no-reply@talkliketv.click>", "SMTP sender")
	flag.DurationVar(&cfg.CtxTimeout, "ctx-timeout", test.DbCtxTimeout, "Context timeout for db queries")
}

type ApiTestSuite struct {
	suite.Suite
	app       *apiApplication
	ts        *test.TestServer
	testDb    *test.TestDatabase
	authToken string
}

func (suite *ApiTestSuite) SetupSuite() {
	suite.app, suite.testDb = newTestApplication()
	suite.ts = newTestServer(suite.app.routes())
	apiUser := register("setupsuite", suite.T(), suite.ts)
	activate(apiUser.Email, suite.app.Models)
	suite.authToken = suite.getAuthToken("setupsuite")
	suite.chooseMovie()
}

func (suite *ApiTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
	defer suite.ts.Close()
}

func TestApiTestSuite(t *testing.T) {
	suite.Run(t, new(ApiTestSuite))
}

type ApiNoLoginTestSuite struct {
	suite.Suite
	ts     *test.TestServer
	testDb *test.TestDatabase
	app    *apiApplication
}

func (suite *ApiNoLoginTestSuite) SetupSuite() {
	suite.app, suite.testDb = newTestApplication()
	suite.ts = newTestServer(suite.app.routes())
}

func (suite *ApiNoLoginTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
	defer suite.ts.Close()
}

func TestTestSuite(t *testing.T) {
	suite.Run(t, new(ApiNoLoginTestSuite))
}

func register(prefix string, t *testing.T, ts *test.TestServer) *models.User {

	email := prefix + test.TestEmail
	data := map[string]interface{}{
		"name":     prefix + "apiUser",
		"password": test.ValidPassword,
		"email":    email,
		"language": test.ValidLanguage,
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		t.Fatalf("could not marshal json: %s\n", err)
	}
	code, _, body := ts.Post(t, "/v1/users", jsonData)

	assert.Equal(t, code, http.StatusAccepted)
	assert.StringContains(t, body, email)

	var input struct {
		User models.User `json:"user"`
	}

	err = json.Unmarshal([]byte(body), &input)
	if err != nil {
		t.Fatalf("could not read json: %s\n", err)
		return nil
	}

	assert.Equal(t, input.User.Email, email)
	return &input.User
}

func (suite *ApiTestSuite) chooseMovie() {
	t := suite.T()

	jsonData, err := json.Marshal(map[string]interface{}{
		"movie_id": test.ValidMovieIdInt,
	})

	if err != nil {
		t.Fatalf("could not marshal json: %s\n", err)
		return
	}
	code, _, _ := suite.ts.Request(t, jsonData, "/v1/movies/choose", http.MethodPatch, suite.authToken)

	assert.Equal(t, code, http.StatusOK)
}

func (suite *ApiTestSuite) getAuthToken(prefix string) string {
	t := suite.T()
	data := map[string]interface{}{
		"password": test.ValidPassword,
		"email":    prefix + test.TestEmail,
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		t.Fatal(err)
	}
	code, _, body := suite.ts.Post(t, "/v1/tokens/authentication", jsonData)

	assert.Equal(t, code, http.StatusCreated)
	assert.StringContains(t, body, "authentication_token")

	var authToken struct {
		Token models.Token `json:"authentication_token"`
	}

	err = json.Unmarshal([]byte(body), &authToken)
	if err != nil {
		t.Fatal(err)
	}

	assert.Equal(t, 26, len(authToken.Token.Plaintext))

	return authToken.Token.Plaintext
}

func newTestApplication() (*apiApplication, *test.TestDatabase) {
	testDb := test.SetupTestDatabase()

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	flag.Parse()

	return &apiApplication{
		application.Application{
			Config: cfg,
			Logger: logger,
			Models: models.NewModels(testDb.DbInstance, cfg.CtxTimeout),
			Mailer: mailer.New(cfg.Smtp.Host, cfg.Smtp.Port, cfg.Smtp.Username, cfg.Smtp.Password, cfg.Smtp.Sender),
		},
	}, testDb
}

func newTestServer(h http.Handler) *test.TestServer {
	// Initialize the test server as normal.
	ts := httptest.NewTLSServer(h)
	return &test.TestServer{Server: ts}
}

func activate(email string, models models.Models) {

	user, err := models.Users.GetByEmail(email)
	if err != nil {
		log.Fatalf("could not acitvate user: %s\n", err)
		return
	}
	// Update the user's activation status.
	user.Activated = true
	// Save the updated user record in our database, checking for any edit conflicts in
	// the same way that we did for our movie records.
	err = models.Users.Update(user)
	if err != nil {
		log.Fatalf("could not acitvate user: %s\n", err)
		return
	}
}
