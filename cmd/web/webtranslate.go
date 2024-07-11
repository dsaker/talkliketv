package main

import (
	"errors"
	"mime/multipart"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
)

type TranslateTextForm struct {
	TranslateTo         string         `form:"translateTo"`
	TextFile            multipart.File `form:"textFile"`
	validator.Validator `form:"-"`
}

// Update the handler so it displays the signup page.
func (app *web) translateText(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = TranslateTextForm{}
	languages, err := app.Models.Languages.All(false)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	data.Languages = languages
	println(languages)
	app.render(w, r, http.StatusOK, "translate.gohtml", data)
}
