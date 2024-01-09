package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/stretchr/testify/suite"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
	"testing"
)

// Define a custom testServer type which embeds a httptest.Server instance.
type testServer struct {
	*httptest.Server
}

var cfg config

func init() {
	flag.StringVar(&cfg.env, "env", "development", "Environment (development|staging|production)")
}

type ApiTestSuite struct {
	suite.Suite
	ts     *testServer
	testDb *models.TestDatabase
	app    *application
}

func (suite *ApiTestSuite) SetupSuite() {
	suite.app, suite.testDb = newTestApplication()
	suite.ts = newTestServer(suite.app.routes())
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
	ts     *testServer
	testDb *models.TestDatabase
	app    *application
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

func (ts *testServer) register(t *testing.T) {

	data := map[string]interface{}{
		"name":     "apiUser99",
		"password": "password",
		"email":    "apiUser99@email.com",
		"language": "Spanish",
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		fmt.Printf("could not marshal json: %s\n", err)
		return
	}
	code, _, _ := ts.post(t, "/v1/user", jsonData)

	assert.Equal(t, code, http.StatusAccepted)
}

func newResponse(t *testing.T, rs *http.Response) (int, http.Header, string) {
	// Read the response body from the test server.
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {
			t.Fatal(err)
		}
	}(rs.Body)

	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)

	// Return the response status, headers and body.
	return rs.StatusCode, rs.Header, string(body)
}
func (ts *testServer) post(t *testing.T, urlPath string, json []byte) (int, http.Header, string) {
	rs, err := ts.Client().Post(ts.URL+urlPath, "application/json", bytes.NewReader(json))
	if err != nil {
		t.Fatal(err)
	}

	return newResponse(t, rs)
}

func (ts *testServer) put(t *testing.T, urlPath string, json []byte) (int, http.Header, string) {
	req, err := http.NewRequest(http.MethodPut, ts.URL+urlPath, bytes.NewBuffer(json))
	req.Header.Set("Content-Type", "application/json")
	if err != nil {
		log.Fatal(err)
	}

	resp, err := ts.Client().Do(req)
	if err != nil {
		log.Fatal(err)
	}

	return newResponse(t, resp)
}

func newTestApplication() (*application, *models.TestDatabase) {
	testDb := models.SetupTestDatabase()

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	flag.Parse()

	return &application{
		config: cfg,
		logger: logger,
		models: models.NewModels(testDb.DbInstance),
	}, testDb
}

func newTestServer(h http.Handler) *testServer {
	// Initialize the test server as normal.
	ts := httptest.NewTLSServer(h)
	return &testServer{ts}
}
