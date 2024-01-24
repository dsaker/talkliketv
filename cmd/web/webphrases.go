package main

import (
	"errors"
	"net/http"
	"strconv"
	"talkliketv.net/internal/models"
)

func (webApp *webApplication) phraseView(w http.ResponseWriter, r *http.Request) {

	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := webApp.Models.Users.Get(userId)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	if user.MovieId == -1 {
		webApp.sessionManager.Put(r.Context(), "flash", "Please choose a movie")
		data := webApp.newTemplateData(r)
		webApp.render(w, r, http.StatusOK, "phrases.gohtml", data)
		return
	}

	phrases, err := webApp.Models.Phrases.NextTen(userId, user.MovieId, user.Flipped)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			webApp.notFound(w, r, err)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	sum, total, err := webApp.Models.Phrases.PercentageDone(userId, user.MovieId, user.Flipped)
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

	movie, err := webApp.Models.Movies.Get(user.MovieId)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			webApp.notFound(w, r, err)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	data := webApp.newTemplateData(r)
	data.Phrases = phrases
	data.Sum = sum
	data.Total = total
	data.Movie = movie

	webApp.render(w, r, http.StatusOK, "phrases.gohtml", data)
}

func (webApp *webApplication) phraseCorrect(w http.ResponseWriter, r *http.Request) {
	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := webApp.Models.Users.Get(userId)
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

	var input struct {
		PhraseId string `form:"phrase_id"`
		MovieId  string `form:"movie_id"`
	}

	err = webApp.decodePostForm(r, &input)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	phraseId, err := strconv.Atoi(input.PhraseId)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	movieId, err := strconv.Atoi(input.MovieId)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	err = webApp.Models.Phrases.PhraseCorrect(userId, phraseId, movieId, user.Flipped)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			webApp.notFound(w, r, err)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}
}
