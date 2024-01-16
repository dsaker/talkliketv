package test

import (
	"bytes"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"
)

type TestServer struct {
	*httptest.Server
}

// Get Implement a get() method on our custom testServer type. This makes a GET
// request to a given url path using the test server client, and returns the
// response status code, headers and body.
func (ts *TestServer) Get(t *testing.T, urlPath string) (int, http.Header, string) {
	rs, err := ts.Client().Get(ts.URL + urlPath)
	if err != nil {
		t.Fatal(err)
	}

	defer func(Body io.ReadCloser) {
		err = Body.Close()
		if err != nil {
			t.Fatal(err)
		}
	}(rs.Body)

	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)

	return rs.StatusCode, rs.Header, string(body)
}

func (ts *TestServer) PostForm(t *testing.T, urlPath string, form url.Values) (int, http.Header, string) {
	rs, err := ts.Client().PostForm(ts.URL+urlPath, form)
	if err != nil {
		t.Fatal(err)
	}

	// Read the response body from the test server.
	defer func(Body io.ReadCloser) {
		err = Body.Close()
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

func readResponse(t *testing.T, rs *http.Response) (int, http.Header, string) {
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

func (ts *TestServer) do(t *testing.T, req *http.Request) (int, http.Header, string) {
	req.Header.Set("Content-Type", "application/json")
	resp, err := ts.Client().Do(req)
	if err != nil {
		log.Fatal(err)
	}

	return readResponse(t, resp)
}

func (ts *TestServer) Post(t *testing.T, urlPath string, json []byte) (int, http.Header, string) {
	rs, err := ts.Client().Post(ts.URL+urlPath, "application/json", bytes.NewReader(json))
	if err != nil {
		t.Fatal(err)
	}

	return readResponse(t, rs)
}

func (ts *TestServer) Request(t *testing.T, json []byte, urlPath, method, authToken string) (int, http.Header, string) {
	req, err := http.NewRequest(method, ts.URL+urlPath, bytes.NewBuffer(json))
	if authToken != "" {
		req.Header.Set("Authorization", "Bearer "+authToken)
	}
	if err != nil {
		t.Fatal(err)
	}
	return ts.do(t, req)
}
