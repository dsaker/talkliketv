package main

import (
	"bytes"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"talkliketv.net/internal/assert"
)

func (suite *ApiTestSuite) TestServerErrorResponse() {
	t := suite.T()
	// Initialize a new httptest.ResponseRecorder and dummy http.Request.
	rr := httptest.NewRecorder()

	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	err = errors.New("testServerErrorResponseError")
	suite.app.serverErrorResponse(rr, r, err)

	// Call the Result() method on the http.ResponseRecorder to get the results
	// of the test.
	rs := rr.Result()

	assert.Equal(t, rs.StatusCode, http.StatusInternalServerError)

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)

	assert.StringContains(t, string(body), "the server encountered a problem and could not process your request")
}

func (suite *ApiTestSuite) TestMethodNotAllowedResponse() {
	t := suite.T()
	// Initialize a new httptest.ResponseRecorder and dummy http.Request.
	rr := httptest.NewRecorder()

	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	suite.app.methodNotAllowedResponse(rr, r)

	// Call the Result() method on the http.ResponseRecorder to get the results
	// of the test.
	rs := rr.Result()

	assert.Equal(t, rs.StatusCode, http.StatusMethodNotAllowed)

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)

	assert.StringContains(t, string(body), "the GET method is not supported for this resource")
}
