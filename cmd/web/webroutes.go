package main

import (
	"github.com/julienschmidt/httprouter"
	"github.com/justinas/alice"
	"net/http"
	"talkliketv.net/ui"
)

func (app *web) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.notFound(w, r, nil)
	})

	router.MethodNotAllowed = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.methodNotAllowedResponse(w, r)
	})
	// Take the ui.Files embedded filesystem and convert it to a http.FS type so
	// that it satisfies the http.FileSystem interface. We then pass that to the
	// http.FileServer() function to create the file server handler.
	fileServer := http.FileServer(http.FS(ui.Files))
	router.Handler(http.MethodGet, "/static/*filepath", fileServer)

	router.HandlerFunc(http.MethodGet, "/healthcheck", app.healthCheckHandler)

	// chain of middleware constructors that allows user to signup or login
	dynamic := alice.New(app.sessionManager.LoadAndSave, noSurf, app.authenticate)

	router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
	router.Handler(http.MethodGet, "/about", dynamic.ThenFunc(app.about))
	router.Handler(http.MethodGet, "/user/signup", dynamic.ThenFunc(app.userSignup))
	router.Handler(http.MethodPost, "/user/signup", dynamic.ThenFunc(app.userSignupPost))
	router.Handler(http.MethodGet, "/user/login", dynamic.ThenFunc(app.userLogin))
	router.Handler(http.MethodPost, "/user/login", dynamic.ThenFunc(app.userLoginPost))

	// add requireAuthentication to chain of middleware constructors to block access for non-logged in users
	protected := dynamic.Append(app.requireAuthentication)

	router.Handler(http.MethodPost, "/user/logout", protected.ThenFunc(app.userLogoutPost))
	router.Handler(http.MethodGet, "/movies/view", protected.ThenFunc(app.moviesView))
	router.Handler(http.MethodGet, "/movies/mp3/:id", protected.ThenFunc(app.moviesMp3))
	router.Handler(http.MethodPost, "/movies/choose", protected.ThenFunc(app.moviesUpdate))

	router.Handler(http.MethodGet, "/phrase/view", protected.ThenFunc(app.phraseView))
	router.Handler(http.MethodPost, "/phrase/correct", protected.ThenFunc(app.phraseCorrect))

	router.Handler(http.MethodPost, "/user/language/switch", protected.ThenFunc(app.userLanguageFlip))
	router.Handler(http.MethodGet, "/user/password/reset", dynamic.ThenFunc(app.userPasswordReset))
	router.Handler(http.MethodPost, "/user/password/reset", dynamic.ThenFunc(app.userPasswordResetPost))
	router.Handler(http.MethodGet, "/user/activate", dynamic.ThenFunc(app.userActivate))
	router.Handler(http.MethodPost, "/user/activate", dynamic.ThenFunc(app.userActivatePost))

	router.Handler(http.MethodPost, "/tokens/password-reset", dynamic.ThenFunc(app.createPasswordResetToken))
	router.Handler(http.MethodPost, "/tokens/activate", dynamic.ThenFunc(app.createActivationToken))

	router.Handler(http.MethodGet, "/account/view", protected.ThenFunc(app.accountView))
	router.Handler(http.MethodGet, "/account/language/update", protected.ThenFunc(app.accountLanguageUpdate))
	router.Handler(http.MethodPost, "/account/language/update", protected.ThenFunc(app.accountLanguageUpdatePost))
	router.Handler(http.MethodGet, "/account/password/update", protected.ThenFunc(app.accountPasswordUpdate))
	router.Handler(http.MethodPost, "/account/password/update", protected.ThenFunc(app.accountPasswordUpdatePost))

	router.Handler(http.MethodPost, "/translate/text", protected.ThenFunc(app.translateTextPost))
	router.Handler(http.MethodGet, "/translate/text", protected.ThenFunc(app.translateText))

	// base chain of middleware constructors invoked on all requests
	standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
	return standard.Then(router)
}
