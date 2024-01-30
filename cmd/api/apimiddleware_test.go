package main

import (
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"
	"talkliketv.net/internal/assert"
)

func (suite *ApiTestSuite) TestAuthenticate() {
	t := suite.T()
	// Initialize a new httptest.ResponseRecorder and dummy http.Request.
	rr := httptest.NewRecorder()

	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	r.Header.Add("Authorization", "BadValue")
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, err = w.Write([]byte("OK"))
		if err != nil {
			t.Fatal(err)
		}
	})

	suite.app.authenticate(next).ServeHTTP(rr, r)

	rs := rr.Result()

	// Check that the config has correctly set the Content-Security-Policy
	// header on the response.
	expectedValue := "Bearer"
	assert.Equal(t, rs.Header.Get("WWW-Authenticate"), expectedValue)

	assert.Equal(t, rs.StatusCode, http.StatusUnauthorized)

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)
	
	message := "invalid or missing authentication token"
	assert.StringContains(t, string(body), message)
}
