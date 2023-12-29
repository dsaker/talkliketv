package main

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/alexedwards/scs/v2"
	"github.com/cucumber/godog"
	"github.com/go-playground/form/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	"github.com/ory/dockertest"
	"github.com/ory/dockertest/docker"
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
	db        *sql.DB
	testSuite godog.TestSuite
)

func TestFeatures(t *testing.T) {
	testSuite = godog.TestSuite{
		TestSuiteInitializer: InitializeTestSuite,
		ScenarioInitializer:  InitializeScenario,
		Options: &godog.Options{
			Format:   "pretty",
			Paths:    []string{"features"},
			TestingT: t, // Testing instance that will run subtests.
		},
	}

	if testing.Short() {
		t.Skip("models: skipping integration test")
	} else {
		if testSuite.Run() != 0 {
			t.Fatal("non-zero status returned, failed to run feature tests")
		}
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

	form := url.Values{}
	form.Add("name", api.payload.Name)
	form.Add("email", api.payload.Email)
	form.Add("language", api.payload.Language)
	form.Add("password", api.payload.Password)
	form.Add("csrf_token", validCSRFToken)

	resp, err = api.server.Client().PostForm(api.server.URL+route, form)

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
		// uses a sensible default on windows (tcp/http) and linux/osx (socket)
		pool, err := dockertest.NewPool("")
		if err != nil {
			log.Fatalf("Could not construct pool: %s", err)
		}
		// uses pool to try to connect to Docker
		err = pool.Client.Ping()
		if err != nil {
			log.Fatalf("Could not connect to Docker: %s", err)
		}

		// pulls an image, creates a container based on it and runs it
		//postgres, err := pool.Run("postgres", "14", []string{
		//	"POSTGRES_PASSWORD=secret",
		//	"POSTGRES_USER=user",
		//	"POSTGRES_DB=testdb",
		//})

		postgres, err := pool.RunWithOptions(&dockertest.RunOptions{
			Repository: "postgres",
			Tag:        "14",
			Env: []string{
				"POSTGRES_PASSWORD=secret",
				"POSTGRES_USER=user",
				"POSTGRES_DB=testdb",
			},
		}, func(config *docker.HostConfig) {
			// set AutoRemove to true so that stopped container goes away by itself
			config.AutoRemove = true
			config.RestartPolicy = docker.RestartPolicy{
				Name: "no",
			}
		})

		time.Sleep(2 * time.Second)
		postgres.Expire(60)

		if err != nil {
			log.Fatalf("Could not start resource: %s", err)
		}

		port := postgres.GetPort("5432/tcp")

		time.Sleep(time.Second)

		dbAddr := fmt.Sprintf("localhost:%s", port)
		// migrate db schema
		databaseURL := fmt.Sprintf("postgres://user:secret@%s/testdb?sslmode=disable", dbAddr)

		db, err = sql.Open("postgres", databaseURL)
		if err != nil {
			log.Fatalf("Could not connect to Docker postgres: %s", err)
		}

		err = models.MigrateDb(databaseURL)
		if err != nil {
			log.Fatal(err)
		}

		err = models.SetupDb(db)
		if err != nil {
			log.Fatal(err)
		}

		log.Println("db setup done")
	})

	sc.AfterSuite(func() {
		err := db.Close()
		if err != nil {
			log.Fatalf("Could not close db: %s", err)
		}
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
