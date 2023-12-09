package main

import (
	"errors"
	"net/http"
	"strconv"
	"talkliketv.net/internal/models"
)

func (app *application) phraseView(w http.ResponseWriter, r *http.Request) {

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.users.Get(userId)
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
		app.render(w, r, http.StatusOK, "phrases.gohtml", data)
		return
	}

	phrases, err := app.phrases.NextTen(userId, user.MovieId, user.Flipped)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	sum, total, err := app.phrases.PercentageDone(userId, user.MovieId, user.Flipped)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}

	movie, err := app.movies.Get(user.MovieId)
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
	data.Sum = sum
	data.Total = total
	data.Movie = movie

	app.render(w, r, http.StatusOK, "phrases.gohtml", data)
}

func (app *application) phraseCorrect(w http.ResponseWriter, r *http.Request) {
	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.users.Get(userId)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	var input struct {
		PhraseId string `form:"phrase_id"`
		MovieId  string `form:"movie_id"`
	}

	err = app.decodePostForm(r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	phraseId, err := strconv.Atoi(input.PhraseId)
	if err != nil {
		app.badRequestResponse(w, r, err)
	}

	movieId, err := strconv.Atoi(input.MovieId)
	if err != nil {
		app.badRequestResponse(w, r, err)
	}

	err = app.phrases.PhraseCorrect(userId, phraseId, movieId, user.Flipped)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
}
