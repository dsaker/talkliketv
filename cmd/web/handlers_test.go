package main

import (
	"encoding/json"
	"net/http"
	"net/url"
	"talkliketv.net/internal/assert"
	"testing"
)

func (suite *WebTestSuite) TestHealthCheck() {
	t := suite.T()
	code, _, body := suite.ts.get(t, "/v1/healthcheck")

	assert.Equal(t, code, http.StatusOK)

	var input struct {
		Status     string `json:"status"`
		SystemInfo struct {
			Environment string `json:"environment"`
			Version     string `json:"version"`
		} `json:"system_info"`
	}

	err := json.Unmarshal([]byte(body), &input)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, input.Status, "available")
	assert.Equal(t, input.SystemInfo.Environment, "development")
	assert.Equal(t, input.SystemInfo.Version, "")
}

func (suite *WebTestSuite) TestMethodNotAllowed() {
	t := suite.T()
	form := url.Values{}
	code, _, body := suite.ts.postForm(t, "/about", form)

	assert.Equal(t, code, http.StatusMethodNotAllowed)
	assert.StringContains(t, body, "Method Not Allowed")
}

func (suite *WebTestSuite) TestViewsLoggedIn() {

	t := suite.T()

	tests := []struct {
		name     string
		urlPath  string
		wantCode int
		wantTag  string
	}{
		{
			name:     "Account View ",
			urlPath:  "/account/view",
			wantCode: http.StatusOK,
			wantTag:  "<td><a href=\"/account/language/update\">Change language</a></td>",
		},
		{
			name:     "Account Language Update",
			urlPath:  "/account/language/update",
			wantCode: http.StatusOK,
			wantTag:  "<form action='/account/language/update' method='POST' novalidate>",
		},
		{
			name:     "Phrase View",
			urlPath:  "/phrase/view",
			wantCode: http.StatusOK,
			wantTag:  "<form action='/user/language/switch' method='POST' id='switchSliderForm'>",
		},
		{
			name:     "Movies View",
			urlPath:  "/movies/view",
			wantCode: http.StatusOK,
			wantTag:  "<form action='/movies/choose' method='POST'>",
		},
		{
			name:     "Account Password Update",
			urlPath:  "/account/password/update",
			wantCode: http.StatusOK,
			wantTag:  "<form action='/account/password/update' method='POST' novalidate>",
		},
		{
			name:     "Get User Logout",
			urlPath:  "/user/logout",
			wantCode: http.StatusMethodNotAllowed,
			wantTag:  "Method Not Allowed",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			code, _, body := suite.ts.get(t, tt.urlPath)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}

func (suite *WebNoLoginTestSuite) TestViewsNotLoggedIn() {
	t := suite.T()
	tests := []struct {
		name     string
		urlPath  string
		wantCode int
		wantTag  string
	}{
		{
			name:     "Home View ",
			urlPath:  "/",
			wantCode: http.StatusOK,
			wantTag:  "<p>There's nothing to see here... yet!</p>",
		},
		{
			name:     "About View",
			urlPath:  "/about",
			wantCode: http.StatusOK,
			wantTag:  "<p>There's nothing to see here... yet!</p>",
		},
		{
			name:     "User Signup View",
			urlPath:  "/user/signup",
			wantCode: http.StatusOK,
			wantTag:  "<form action='/user/signup' method='POST' novalidate>",
		},
		{
			name:     "User Login View",
			urlPath:  "/user/login",
			wantCode: http.StatusOK,
			wantTag:  "<form action='/user/login' method='POST' novalidate>",
		},
		{
			name:     "Account View",
			urlPath:  "/account/view",
			wantCode: http.StatusSeeOther,
		},
		{
			name:     "Movies Mp3",
			urlPath:  "/movies/mp3/1",
			wantCode: http.StatusSeeOther,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			code, _, body := suite.ts.get(t, tt.urlPath)

			assert.Equal(t, code, tt.wantCode)

			if tt.wantTag != "" {
				assert.StringContains(t, body, tt.wantTag)
			}
		})
	}
}
