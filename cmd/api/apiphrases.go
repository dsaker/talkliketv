package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
)

func (app *apiApplication) listPhrasesHandler(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)

	user, err := app.Models.Users.Get(user.ID)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if user.MovieId == -1 {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "please choose a movie first")
		return
	}

	phrases, err := app.Models.Phrases.NextTen(user.ID, user.MovieId, user.Flipped)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	sum, total, err := app.Models.Phrases.PercentageDone(user.ID, user.MovieId, user.Flipped)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	movie, err := app.Models.Movies.Get(user.MovieId)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"phrases": phrases, "sum": sum, "total": total, "movie": movie}, nil)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *apiApplication) phraseCorrect(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	var input struct {
		PhraseId int `json:"phrase_id"`
		MovieId  int `json:"movie_id"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	err = app.Models.Phrases.PhraseCorrect(user.ID, input.PhraseId, input.MovieId, user.Flipped)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	w.WriteHeader(http.StatusOK)
}
