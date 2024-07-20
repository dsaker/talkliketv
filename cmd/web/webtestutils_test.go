package main

import (
	"flag"
	"github.com/alexedwards/scs/v2"
	"github.com/go-playground/form/v4"
	"github.com/stretchr/testify/suite"
	"html"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/http/httptest"
	"net/url"
	"os"
	"regexp"
	"strconv"
	"talkliketv.net/internal/application"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/config"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/mailer"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/test"
	"testing"
	"time"
)

var cfg config.Config

const (
	testuser = "testUser"
)

func init() {
	flag.StringVar(&cfg.Env, "env", "development", "Environment (development|staging|cloud)")
	flag.StringVar(&cfg.Smtp.Host, "smtp-host", "sandbox.smtp.mailtrap.io", "SMTP host")
	flag.IntVar(&cfg.Smtp.Port, "smtp-port", 25, "SMTP port")
	cfg.Smtp.Username = os.Getenv("smtp-username")
	cfg.Smtp.Password = os.Getenv("smtp-password")
	flag.StringVar(&cfg.Smtp.Sender, "smtp-sender", "TalkLikeTV <no-reply@talkliketv.click>", "SMTP sender")
}

type WebTestSuite struct {
	suite.Suite
	ts             *test.TestServer
	testDb         *test.TestDatabase
	validCSRFToken string
	app            *web
}

func (suite *WebTestSuite) SetupSuite() {
	t := suite.T()
	suite.app, suite.testDb = newTestApplication(t)
	suite.ts = newWebTestServer(t, suite.app.routes())
	signup(t, suite.ts, testuser)
	activate(testuser+test.ValidEmail, suite.app.Models)
	suite.validCSRFToken = login(t, suite.ts, testuser)
	chooseMovie(t, suite.ts, suite.validCSRFToken)
}

func (suite *WebTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
	defer suite.ts.Close()
	suite.T().Run("Valid Logout", func(t *testing.T) {
		logoutForm := url.Values{}
		logoutForm.Add("csrf_token", suite.validCSRFToken)
		code, _, _ := suite.ts.PostForm(t, "/user/logout", logoutForm)

		assert.Equal(t, code, http.StatusSeeOther)
	})
}

func TestWebTestSuite(t *testing.T) {
	suite.Run(t, new(WebTestSuite))
}

type WebNoLoginTestSuite struct {
	suite.Suite
	ts             *test.TestServer
	testDb         *test.TestDatabase
	validCSRFToken string
	app            *web
}

func (suite *WebNoLoginTestSuite) SetupSuite() {
	t := suite.T()
	suite.app, suite.testDb = newTestApplication(t)
	suite.ts = newWebTestServer(t, suite.app.routes())
	_, _, body := suite.ts.Get(t, "/user/login")
	suite.validCSRFToken = extractCSRFToken(t, body)
}

func (suite *WebNoLoginTestSuite) TearDownSuite() {
	defer suite.testDb.TearDown()
	defer suite.ts.Close()
}

func TestWebNoLoginTestSuite(t *testing.T) {
	suite.Run(t, new(WebNoLoginTestSuite))
}

func newTestApplication(t *testing.T) (*web, *test.TestDatabase) {
	testDb := test.SetupTestDatabase()
	templateCache, err := newTemplateCache()
	if err != nil {
		t.Fatal(err)
	}

	formDecoder := form.NewDecoder()

	sessionManager := scs.New()
	sessionManager.Lifetime = 12 * time.Hour

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	flag.Parse()

	return &web{
		templateCache,
		formDecoder,
		sessionManager,
		false,
		application.Application{
			Config: cfg,
			Logger: logger,
			Models: models.NewModels(testDb.DbInstance, test.DbCtxTimeout),
			Mailer: mailer.New(cfg.Smtp.Host, cfg.Smtp.Port, cfg.Smtp.Username, cfg.Smtp.Password, cfg.Smtp.Sender),
		},
	}, testDb

}

func newWebTestServer(t *testing.T, h http.Handler) *test.TestServer {
	// Initialize the test server as normal.
	ts := httptest.NewTLSServer(h)

	// Initialize a new cookie jar.
	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	// Add the cookie jar to the test server client. Any response cookies will
	// now be stored and sent with subsequent requests when using this client.
	ts.Client().Jar = jar

	// Disable redirect-following for the test server client by setting a custom
	// CheckRedirect function. This function will be called whenever a 3xx
	// response is received by the client, and by always returning a
	// http.ErrUseLastResponse error it forces the client to immediately return
	// the received response.
	ts.Client().CheckRedirect = func(req *http.Request, via []*http.Request) error {
		return http.ErrUseLastResponse
	}

	return &test.TestServer{Server: ts}
}

func chooseMovie(t *testing.T, ts *test.TestServer, validToken string) {
	setupUserForm := url.Values{}
	setupUserForm.Add("movie_id", "1")
	setupUserForm.Add("csrf_token", validToken)

	code, _, _ := ts.PostForm(t, "/movies/choose", setupUserForm)

	assert.Equal(t, code, http.StatusSeeOther)
}

func login(t *testing.T, ts *test.TestServer, username string) string {
	_, _, body := ts.Get(t, "/user/login")
	validCSRFToken := extractCSRFToken(t, body)

	loginForm := url.Values{}
	loginForm.Add("email", username+test.ValidEmail)
	loginForm.Add("password", test.ValidPassword)
	loginForm.Add("csrf_token", validCSRFToken)

	code, _, _ := ts.PostForm(t, "/user/login", loginForm)

	assert.Equal(t, code, http.StatusSeeOther)

	return validCSRFToken
}

func signup(t *testing.T, ts *test.TestServer, username string) {
	_, _, body := ts.Get(t, "/user/login")
	validCSRFToken := extractCSRFToken(t, body)

	signupForm := url.Values{}
	signupForm.Add("name", username)
	signupForm.Add("email", username+test.ValidEmail)
	signupForm.Add("password", test.ValidPassword)
	signupForm.Add("language_id", strconv.Itoa(test.ValidLanguageId))
	signupForm.Add("csrf_token", validCSRFToken)

	code, _, _ := ts.PostForm(t, "/user/signup", signupForm)

	assert.Equal(t, code, http.StatusSeeOther)
}

// Define a regular expression which captures the CSRF token value from the
// HTML for our user signup page.
var csrfTokenRX = regexp.MustCompile(`<input type='hidden' name='csrf_token' value='(.+)'>`)

func extractCSRFToken(t *testing.T, body string) string {
	// Use the FindStringSubmatch method to extract the token from the HTML body.
	// Note that this returns an array with the entire matched pattern in the
	// first position, and the values of any captured data in the subsequent
	// positions.
	matches := csrfTokenRX.FindStringSubmatch(body)
	if len(matches) < 2 {
		t.Fatal("no csrf token found in body")
	}

	return html.UnescapeString(matches[1])
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
