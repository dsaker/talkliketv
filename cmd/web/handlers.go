package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
)

func (app *application) home(w http.ResponseWriter, r *http.Request) {
	// Because httprouter matches the "/" path exactly, we can now remove the
	// manual check of r.URL.Path != "/" from this handler.

	//phrases, err := app.phrases.NextTen()
	//if err != nil {
	//	app.serverErrorResponse(w, r, err)
	//	return
	//}

	data := app.newTemplateData(r)
	//data.Snippets = phrases

	app.render(w, r, http.StatusOK, "home.tmpl", data)
}

func (app *application) phraseView(w http.ResponseWriter, r *http.Request) {

	//params := httprouter.ParamsFromContext(r.Context())

	// We can then use the ByName() method to get the value of the "id" named
	// parameter from the slice and validate it as normal.
	//id, err := strconv.Atoi(params.ByName("id"))
	//if err != nil || id < 1 {
	//	app.notFoundResponse(w, r)
	//	return
	//}

	phrases, err := app.phrases.NextTen()
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	data := app.newTemplateData(r)
	data.Phrases = phrases

	app.render(w, r, http.StatusOK, "view.tmpl", data)
}

func (app *application) about(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	app.render(w, r, http.StatusOK, "about.tmpl", data)
}

func (app *application) accountView(w http.ResponseWriter, r *http.Request) {
	userID := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.users.Get(userID)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	data := app.newTemplateData(r)
	data.User = user

	app.render(w, r, http.StatusOK, "account.tmpl", data)
}

func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	env := envelope{
		"status": "available",
		"system_info": map[string]string{
			"environment": app.config.env,
			"version":     version,
		},
	}

	err := app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		// Use the new serverErrorResponse() helper.
		app.serverErrorResponse(w, r, err)
	}
}
