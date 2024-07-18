package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"talkliketv.net/internal/assert"
	"talkliketv.net/internal/models"
	"testing"
)

func (suite *ApiTestSuite) TestReadJson() {
	t := suite.T()
	// Initialize a new httptest.ResponseRecorder and dummy http.Request.

	var token struct {
		Token models.Token `json:"authentication_token"`
	}

	rr := httptest.NewRecorder()

	tests := []struct {
		name    string
		json    string
		wantErr string
	}{
		{
			name:    "Valid Json",
			json:    `{"authentication_token": {"token":"token"}`,
			wantErr: "",
		},
		{
			name:    "Badly Formed Json",
			json:    "buffer",
			wantErr: "body contains badly-formed JSON (at character 1)",
		},
		{
			name:    "Unknown Key",
			json:    `{"buffer": "buffer"}`,
			wantErr: "body contains unknown key \"buffer\"",
		},
		{
			name:    "Test Key",
			json:    `{"authentication_token": {"token": {}}`,
			wantErr: "body contains badly-formed JSON",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r, err := http.NewRequest(http.MethodGet, "/phrases/view", strings.NewReader(tt.json))
			if err != nil {
				t.Fatal(err)
			}
			err = suite.app.readJSON(rr, r, &token)

			assert.StringContains(t, err.Error(), tt.wantErr)

		})
	}
}
