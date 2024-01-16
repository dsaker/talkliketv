package main

import (
	"expvar"
	"github.com/julienschmidt/httprouter"
	"net/http"
)

// Update the routes() method to return a http.Handler instead of a *httprouter.Router.
func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)

	router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUserHandler)
	router.HandlerFunc(http.MethodPut, "/v1/users/activated", app.activateUserHandler)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/authentication", app.createAuthenticationTokenHandler)

	router.HandlerFunc(http.MethodGet, "/v1/movies/mp3/:id", app.moviesMp3)
	router.HandlerFunc(http.MethodPatch, "/v1/movies/choose", app.moviesChoose)
	router.HandlerFunc(http.MethodGet, "/v1/movies/language/:id", app.listMoviesHandler)
	router.HandlerFunc(http.MethodPost, "/v1/phrase/correct", app.phraseCorrect)

	router.Handler(http.MethodGet, "/debug/vars", expvar.Handler())

	if app.config.expVarEnabled {
		return app.metrics(app.recoverPanic(app.enableCORS(app.rateLimit(app.authenticate(router)))))
	}
	return app.recoverPanic(app.enableCORS(app.rateLimit(app.authenticate(router))))
}
