package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
)

func (app *application) phraseCorrect(w http.ResponseWriter, r *http.Request) {
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

	err = app.models.Phrases.PhraseCorrect(user.ID, input.PhraseId, input.MovieId, user.Flipped)
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
