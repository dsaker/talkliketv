package main

import (
	"encoding/json"
	"flag"
	"github.com/stretchr/testify/suite"
	"net/http"
	"net/http/httptest"
	"os"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/config"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/test"
	"testing"
)

var cfg config.Config

func init() {
	flag.StringVar(&cfg.Env, "env", "development", "Environment (development|staging|production)")
	flag.BoolVar(&cfg.ExpVarEnabled, "expvar-enabled", false, "Enable expvar (disable for testing")
	flag.IntVar(&cfg.CtxTimeout, "ctx-timeout", 3, "Context timeout for db queries")

}

type ApiTestSuite struct {
	suite.Suite
	ts        *test.TestServer
	testDb    *test.TestDatabase
	authToken string
}

func (suite *ApiTestSuite) SetupSuite() {
	var app *apiApp
	app, suite.testDb = newTestApplication()
	suite.ts = newTestServer(app.routes())
	register("setupsuite", suite.T(), suite.ts)
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
	app    *apiApp
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

func register(prefix string, t *testing.T, ts *test.TestServer) {

	data := map[string]interface{}{
		"name":     prefix + "apiUser",
		"password": "password12",
		"email":    prefix + "test@email.com",
		"language": "Spanish",
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		t.Fatalf("could not marshal json: %s\n", err)
		return
	}
	code, _, body := ts.Post(t, "/v1/users", jsonData)

	assert.Equal(t, code, http.StatusAccepted)
	assert.StringContains(t, body, prefix+"test")
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
		"password": "password12",
		"email":    prefix + "test@email.com",
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

func newTestApplication() (*apiApp, *test.TestDatabase) {
	testDb := test.SetupTestDatabase()

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	flag.Parse()

	return &apiApp{
		config.Application{
			Config: cfg,
			Logger: logger,
			Models: models.NewModels(testDb.DbInstance, 3),
		},
	}, testDb
}

func newTestServer(h http.Handler) *test.TestServer {
	// Initialize the test server as normal.
	ts := httptest.NewTLSServer(h)
	return &test.TestServer{Server: ts}
}
