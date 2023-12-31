package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/alexedwards/scs/v2"
	"github.com/cucumber/godog"
	"github.com/go-playground/form/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	"io"
	"log"
	"net/http/cookiejar"
	"net/http/httptest"
	"net/url"
	"os"
	"talkliketv.net/cmd/web/application"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
	"testing"
	"time"
)

type apiFeature struct {
	server       *httptest.Server
	payload      application.UserSignupForm
	responseCode int
}

var (
	testSuite godog.TestSuite
	testDb    *models.TestDatabase
)

func TestFeatures(t *testing.T) {

	if testing.Short() {
		t.Skip("models: skipping features test")
	}

	testSuite = godog.TestSuite{
		TestSuiteInitializer: InitializeTestSuite,
		ScenarioInitializer:  InitializeScenario,
		Options: &godog.Options{
			Format:   "pretty",
			Paths:    []string{"features"},
			TestingT: t, // Testing instance that will run subtests.
		},
	}

	if testSuite.Run() != 0 {
		t.Fatal("non-zero status returned, failed to run feature tests")
	}
}

func (api *apiFeature) thePayload(payload *godog.DocString) error {

	if payload != nil {
		err := json.Unmarshal([]byte(payload.Content), &api.payload)
		if err != nil {
			return err
		}
	}
	return nil
}

func (api *apiFeature) iSendARequestTo(method, route string) error {

	resp, err := api.server.Client().Get(api.server.URL + "/user/login")
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	bytes.TrimSpace(body)

	validCSRFToken := application.ExtractCSRFToken(testSuite.Options.TestingT, string(body))

	formValues := url.Values{}
	formValues.Add("name", api.payload.Name)
	formValues.Add("email", api.payload.Email)
	formValues.Add("language", api.payload.Language)
	formValues.Add("password", api.payload.Password)
	formValues.Add("csrf_token", validCSRFToken)

	resp, err = api.server.Client().PostForm(api.server.URL+route, formValues)

	if err != nil {
		return err
	}

	api.responseCode = resp.StatusCode

	return nil
}

func (api *apiFeature) theResponseCodeShouldBe(expectedStatus int) error {

	if api.responseCode != expectedStatus {
		return fmt.Errorf("reponse should be %d", expectedStatus)
	}

	return nil
}

func InitializeTestSuite(sc *godog.TestSuiteContext) {

	sc.BeforeSuite(func() {
		testDb = models.SetupTestDatabase()

		time.Sleep(2 * time.Second)

		log.Println("db setup done")
	})

}

func InitializeScenario(ctx *godog.ScenarioContext) {

	api := &apiFeature{}

	ctx.Before(func(ctx context.Context, sc *godog.Scenario) (context.Context, error) {

		templateCache, err := application.NewTemplateCache()
		if err != nil {
			log.Fatal("failed to create NewTemplateCache", err)
		}

		formDecoder := form.NewDecoder()

		sessionManager := scs.New()
		sessionManager.Lifetime = 12 * time.Hour

		logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

		db := testDb.DbInstance
		app := &application.Application{
			Logger:         logger,
			Phrases:        &models.PhraseModel{DB: db},
			Movies:         &models.MovieModel{DB: db},
			Languages:      &models.LanguageModel{DB: db},
			Users:          &models.UserModel{DB: db},
			TemplateCache:  templateCache,
			FormDecoder:    formDecoder,
			SessionManager: sessionManager,
		}

		ts := httptest.NewTLSServer(app.Routes())

		jar, err := cookiejar.New(nil)
		if err != nil {
			log.Fatal("failed to create cookiejar", err)
		}

		ts.Client().Jar = jar

		api.server = ts
		return ctx, nil
	})
	ctx.After(func(ctx context.Context, sc *godog.Scenario, err error) (context.Context, error) {
		api.server.Close()
		return ctx, nil
	})

	ctx.Step(`^I send a "([^"]*)" request to "([^"]*)"$`, api.iSendARequestTo)
	ctx.Step(`^the payload:$`, api.thePayload)
	ctx.Step(`^the response code should be (\d+)$`, api.theResponseCodeShouldBe)

}
