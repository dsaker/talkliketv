package main

import (
	"bytes"
	"flag"
	"github.com/alexedwards/scs/v2"
	"github.com/go-playground/form/v4"
	"io"
	"net/http"
	"net/http/cookiejar"
	"net/http/httptest"
	"os"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
	"testing"
	"time"
)

func newTestApplication(t *testing.T) *application {
	// Create an instance of the template cache.
	templateCache, err := newTemplateCache()
	if err != nil {
		t.Fatal(err)
	}

	// And a form decoder.
	formDecoder := form.NewDecoder()

	// And a session manager instance. Note that we use the same settings as
	// production, except that we *don't* set a Store for the session manager.
	// If no store is set, the SCS package will default to using a transient
	// in-memory store, which is ideal for testing purposes.
	sessionManager := scs.New()
	sessionManager.Lifetime = 12 * time.Hour
	sessionManager.Cookie.Secure = true

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	var cfg config

	flag.StringVar(&cfg.env, "env", "development", "Environment (development|staging|production)")

	return &application{
		config:         cfg,
		logger:         logger,
		phrases:        &models.PhraseModel{},
		movies:         &models.MovieModel{},
		languages:      &models.LanguageModel{},
		users:          &models.UserModel{},
		templateCache:  templateCache,
		formDecoder:    formDecoder,
		sessionManager: sessionManager,
	}
}

// Define a custom testServer type which embeds a httptest.Server instance.
type testServer struct {
	*httptest.Server
}

func newTestServer(t *testing.T, h http.Handler) *testServer {
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

	return &testServer{ts}
}

// Implement a get() method on our custom testServer type. This makes a GET
// request to a given url path using the test server client, and returns the
// response status code, headers and body.
func (ts *testServer) get(t *testing.T, urlPath string) (int, http.Header, string) {
	rs, err := ts.Client().Get(ts.URL + urlPath)
	if err != nil {
		t.Fatal(err)
	}

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)

	return rs.StatusCode, rs.Header, string(body)
}

// Define a regular expression which captures the CSRF token value from the
// HTML for our user signup page.
//var csrfTokenRX = regexp.MustCompile(`<input type='hidden' name='csrf_token' value='(.+)'>`)

//
//func extractCSRFToken(t *testing.T, body string) string {
//	// Use the FindStringSubmatch method to extract the token from the HTML body.
//	// Note that this returns an array with the entire matched pattern in the
//	// first position, and the values of any captured data in the subsequent
//	// positions.
//	matches := csrfTokenRX.FindStringSubmatch(body)
//	if len(matches) < 2 {
//		t.Fatal("no csrf token found in body")
//	}
//
//	return html.UnescapeString(string(matches[1]))
//}