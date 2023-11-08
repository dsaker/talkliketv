package main

import (
	"errors"
	"net/http"
	"strconv"
	"talkliketv.net/internal/models"
)

func (app *application) phraseView(w http.ResponseWriter, r *http.Request) {

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

	if user.MovieId == -1 {
		app.sessionManager.Put(r.Context(), "flash", "Please choose a movie")
		data := app.newTemplateData(r)
		app.render(w, r, http.StatusOK, "phrases.tmpl", data)
		//http.Redirect(w, r, "/movies/view", http.StatusSeeOther)
		return
	}

	phrases, err := app.phrases.NextTen(userID, user.MovieId)
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

	app.render(w, r, http.StatusOK, "phrases.tmpl", data)
}

func (app *application) phraseCorrect(w http.ResponseWriter, r *http.Request) {
	userID := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	var input struct {
		PhraseId string `form:"phrase_id"`
		MovieId  string `form:"movie_id"`
	}

	err := app.decodePostForm(r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	p, err := strconv.Atoi(input.PhraseId)
	if err != nil {
		app.badRequestResponse(w, r, err)
	}

	m, err := strconv.Atoi(input.MovieId)
	if err != nil {
		app.badRequestResponse(w, r, err)
	}
	err = app.phrases.PhraseCorrect(userID, p, m)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
}
