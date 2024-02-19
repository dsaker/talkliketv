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

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheck)

	router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUser)
	router.HandlerFunc(http.MethodPut, "/v1/users/activated", app.activateUser)
	router.HandlerFunc(http.MethodPut, "/v1/users/password", app.updateUserPassword)
	router.HandlerFunc(http.MethodPost, "/v1/users/flipped", app.updateUserFlipped)
	router.Handler(http.MethodPut, "/v1/user/language/switch", protected.ThenFunc(app.updateUserLanguage))

	router.HandlerFunc(http.MethodPost, "/v1/tokens/authentication", app.createAuthenticationToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/password-reset", app.createPasswordResetToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/activation", app.createActivationToken)

	router.Handler(http.MethodGet, "/v1/movies/mp3/:id", protected.ThenFunc(app.moviesMp3))
	router.Handler(http.MethodPatch, "/v1/movies/choose", protected.ThenFunc(app.moviesChoose))
	router.Handler(http.MethodGet, "/v1/movies", protected.ThenFunc(app.listMovies))

	router.Handler(http.MethodGet, "/v1/phrases", protected.ThenFunc(app.listPhrases))
	router.Handler(http.MethodPost, "/v1/phrases/correct", protected.ThenFunc(app.phraseCorrect))

	router.Handler(http.MethodGet, "/v1/account/view", protected.ThenFunc(app.accountView))
	//router.Handler(http.MethodGet, "/account/language/update", protected.ThenFunc(app.accountLanguageUpdate))
	//router.Handler(http.MethodPost, "/account/language/update", protected.ThenFunc(app.accountLanguageUpdatePost))
	//router.Handler(http.MethodGet, "/account/password/update", protected.ThenFunc(app.accountPasswordUpdate))
	//router.Handler(http.MethodPost, "/account/password/update", protected.ThenFunc(app.accountPasswordUpdatePost))
	//
	router.Handler(http.MethodGet, "/debug/vars", expvar.Handler())

	var standard alice.Chain
	if app.Config.ExpVarEnabled {
		standard = alice.New(app.metrics, app.recoverPanic, app.logRequest, app.enableCORS, app.Config.RateLimit, app.authenticate)
	} else {
		standard = alice.New(app.recoverPanic, app.logRequest, app.enableCORS, app.Config.RateLimit, app.authenticate)
	}

	return standard.Then(router)
}
