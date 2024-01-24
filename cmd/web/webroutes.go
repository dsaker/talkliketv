package main

import (
	"github.com/julienschmidt/httprouter"
	"github.com/justinas/alice"
	"net/http"
	"talkliketv.net/ui"
)

func (webApp *webApplication) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		webApp.notFound(w, r, nil)
	})

	router.MethodNotAllowed = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		webApp.methodNotAllowedResponse(w, r)
	})
	// Take the ui.Files embedded filesystem and convert it to a http.FS type so
	// that it satisfies the http.FileSystem interface. We then pass that to the
	// http.FileServer() function to create the file server handler.
	fileServer := http.FileServer(http.FS(ui.Files))

	router.Handler(http.MethodGet, "/static/*filepath", fileServer)

	router.HandlerFunc(http.MethodGet, "/healthcheck", webApp.healthcheckHandler)

	dynamic := alice.New(webApp.sessionManager.LoadAndSave, noSurf, webApp.authenticate)

	router.Handler(http.MethodGet, "/", dynamic.ThenFunc(webApp.home))
	router.Handler(http.MethodGet, "/about", dynamic.ThenFunc(webApp.about))
	router.Handler(http.MethodGet, "/user/signup", dynamic.ThenFunc(webApp.userSignup))
	router.Handler(http.MethodPost, "/user/signup", dynamic.ThenFunc(webApp.userSignupPost))
	router.Handler(http.MethodGet, "/user/login", dynamic.ThenFunc(webApp.userLogin))
	router.Handler(http.MethodPost, "/user/login", dynamic.ThenFunc(webApp.userLoginPost))
	protected := dynamic.Append(webApp.requireAuthentication)

	router.Handler(http.MethodPost, "/user/logout", protected.ThenFunc(webApp.userLogoutPost))
	router.Handler(http.MethodGet, "/movies/view", protected.ThenFunc(webApp.moviesView))
	router.Handler(http.MethodGet, "/movies/mp3/:id", protected.ThenFunc(webApp.moviesMp3))
	router.Handler(http.MethodPost, "/movies/choose", protected.ThenFunc(webApp.moviesChoose))
	router.Handler(http.MethodGet, "/phrase/view", protected.ThenFunc(webApp.phraseView))
	router.Handler(http.MethodGet, "/account/view", protected.ThenFunc(webApp.accountView))
	router.Handler(http.MethodPost, "/phrase/correct", protected.ThenFunc(webApp.phraseCorrect))
	router.Handler(http.MethodPost, "/user/language/switch", protected.ThenFunc(webApp.userLanguageSwitch))
	router.Handler(http.MethodGet, "/account/language/update", protected.ThenFunc(webApp.accountLanguageUpdate))
	router.Handler(http.MethodPost, "/account/language/update", protected.ThenFunc(webApp.accountLanguageUpdatePost))
	router.Handler(http.MethodGet, "/account/password/update", protected.ThenFunc(webApp.accountPasswordUpdate))
	router.Handler(http.MethodPost, "/account/password/update", protected.ThenFunc(webApp.accountPasswordUpdatePost))

	standard := alice.New(webApp.recoverPanic, webApp.logRequest, secureHeaders)
	return standard.Then(router)
}
