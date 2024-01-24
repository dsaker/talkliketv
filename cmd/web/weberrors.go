package main

import (
	"fmt"
	"net/http"
	"runtime/debug"
)

func (webApp *webApplication) clientError(w http.ResponseWriter, r *http.Request, status int, err error) {
	if err != nil {
		webApp.logError(r, err)
	}
	http.Error(w, http.StatusText(status), status)
}

func (webApp *webApplication) logError(r *http.Request, err error) {
	// Use the PrintError() method to log the error message, and include the current
	// request method and URL as properties in the log entry.
	webApp.Logger.PrintError(err, map[string]string{
		"request_method": r.Method,
		"request_url":    r.URL.String(),
	})
}

func (webApp *webApplication) serverError(w http.ResponseWriter, r *http.Request, err error) {
	trace := fmt.Sprintf("%s\n%s", err.Error(), debug.Stack())
	webApp.logError(r, err)

	if webApp.debug {
		http.Error(w, trace, http.StatusInternalServerError)
		return
	}
	http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

// The notFound() method will be used to send a 404 Not Found status code and
// JSON response to the client.
func (webApp *webApplication) notFound(w http.ResponseWriter, r *http.Request, err error) {
	webApp.clientError(w, r, http.StatusNotFound, err)
}

// The methodNotAllowedResponse() method will be used to send a 405 Method Not Allowed
// status code and JSON response to the client.
func (webApp *webApplication) methodNotAllowedResponse(w http.ResponseWriter, r *http.Request) {
	webApp.clientError(w, r, http.StatusMethodNotAllowed, nil)
}

func (webApp *webApplication) invalidCredentialsResponse(w http.ResponseWriter, r *http.Request) {
	webApp.clientError(w, r, http.StatusUnauthorized, nil)
}
