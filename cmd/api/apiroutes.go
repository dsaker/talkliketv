package main

import (
	"expvar"
	"github.com/julienschmidt/httprouter"
	"github.com/justinas/alice"
	"net/http"
)

// Update the routes() method to return a http.Handler instead of a *httprouter.Router.
func (app *apiApplication) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	protected := alice.New(app.requireAuthenticatedUser)

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)

	router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUserHandler)
	router.HandlerFunc(http.MethodPut, "/v1/users/activated", app.activateUserHandler)
	router.HandlerFunc(http.MethodPut, "/v1/users/password", app.updateUserPasswordHandler)
	router.HandlerFunc(http.MethodPost, "/v1/users/flipped", app.updateUserFlippedHandler)

	router.HandlerFunc(http.MethodPost, "/v1/tokens/authentication", app.createAuthenticationTokenHandler)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/password-reset", app.createPasswordResetTokenHandler)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/activation", app.createActivationTokenHandler)

	router.Handler(http.MethodGet, "/v1/movies/mp3/:id", protected.ThenFunc(app.moviesMp3))
	router.Handler(http.MethodPatch, "/v1/movies/choose", protected.ThenFunc(app.moviesChoose))
	router.Handler(http.MethodGet, "/v1/movies", protected.ThenFunc(app.listMoviesHandler))

	router.Handler(http.MethodGet, "/v1/phrases", protected.ThenFunc(app.listPhrasesHandler))
	router.Handler(http.MethodPost, "/v1/phrase/correct", protected.ThenFunc(app.phraseCorrect))

	router.Handler(http.MethodGet, "/debug/vars", expvar.Handler())

	var standard alice.Chain
	if app.Config.ExpVarEnabled {
		standard = alice.New(app.metrics, app.recoverPanic, app.logRequest, app.enableCORS, app.Config.RateLimit, app.authenticate)
	} else {
		standard = alice.New(app.recoverPanic, app.logRequest, app.enableCORS, app.Config.RateLimit, app.authenticate)
	}

	return standard.Then(router)
}
