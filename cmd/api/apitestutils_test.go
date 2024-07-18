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
	app       *api
	ts        *test.TestServer
	testDb    *test.TestDatabase
	authToken string
	apiUser   *models.User
}

func (suite *ApiTestSuite) SetupSuite() {
	suite.app, suite.testDb = newTestApplication()
	suite.ts = newTestServer(suite.app.routes())
	suite.apiUser = register("setupsuite", suite.T(), suite.ts)
	activate(suite.apiUser.Email, suite.app.Models)
	suite.authToken = getAuthToken("setupsuite", suite.T(), suite.ts)
	chooseMovie(suite.T(), suite.ts, suite.authToken)
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
	app    *api
}

func (suite *ApiNoLoginTestSuite) SetupSuite() {
	suite.app, suite.testDb = newTestApplication()
	suite.ts = newTestServer(suite.app.routes())
}

func (suite *ApiNoLoginTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
	defer suite.ts.Close()
}

func TestApiNoLoginTestSuite(t *testing.T) {
	suite.Run(t, new(ApiNoLoginTestSuite))
}

func register(prefix string, t *testing.T, ts *test.TestServer) *models.User {

	email := prefix + test.ValidEmail
	data := map[string]interface{}{
		"name":       prefix + "ApiUser",
		"password":   test.ValidPassword,
		"email":      email,
		"languageId": test.ValidLanguageId,
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

func chooseMovie(t *testing.T, ts *test.TestServer, authToken string) {

	jsonData, err := json.Marshal(map[string]interface{}{
		"movie_id": test.ValidMovieIdInt,
	})

	if err != nil {
		t.Fatalf("could not marshal json: %s\n", err)
		return
	}
	code, _, _ := ts.Request(t, jsonData, "/v1/movies/choose", http.MethodPatch, authToken)

	assert.Equal(t, code, http.StatusOK)
}

func getAuthToken(prefix string, t *testing.T, ts *test.TestServer) string {
	data := map[string]interface{}{
		"password": test.ValidPassword,
		"email":    prefix + test.ValidEmail,
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		t.Fatal(err)
	}
	code, _, body := ts.Post(t, "/v1/tokens/authentication", jsonData)

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

func newTestApplication() (*api, *test.TestDatabase) {
	testDb := test.SetupTestDatabase()

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	flag.Parse()

	return &api{
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
