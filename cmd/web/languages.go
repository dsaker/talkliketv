package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
)

type accountLanguageUpdateForm struct {
	Language            string `form:"language"`
	validator.Validator `form:"-"`
}

func (app *application) accountLanguageUpdate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = accountLanguageUpdateForm{}

	languages, err := app.languages.All()
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	data.Languages = languages
	app.render(w, r, http.StatusOK, "language.gohtml", data)
}

func (app *application) accountLanguageUpdatePost(w http.ResponseWriter, r *http.Request) {
	var form accountLanguageUpdateForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	languageId, err := app.languages.GetId(form.Language)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	err = app.users.LanguageUpdate(userId, languageId)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	app.sessionManager.Put(r.Context(), "flash", "Your language has been updated!")

	http.Redirect(w, r, "/account/view", http.StatusSeeOther)
}
