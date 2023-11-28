package main

import (
	"encoding/json"
	"net/http"
	"talkliketv.net/internal/assert"
	"testing"
)

func TestHealthCheck(t *testing.T) {
	app := newTestApplication(t)

	ts := newTestServer(t, app.routes())
	defer ts.Close()

	code, _, body := ts.get(t, "/v1/healthcheck")

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
