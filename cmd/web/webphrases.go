package main

import (
	"errors"
	"net/http"
	"strconv"
	"talkliketv.net/internal/models"
)

// phraseView() is GET route for phrases.gohtml. It gets the next ten phrases for the user
// to learn and puts them in *templateData
func (app *web) phraseView(w http.ResponseWriter, r *http.Request) {

	// get userId from current session
	userId := app.sessionManager.GetInt(r.Context(), authenticatedUserId)

	user, err := app.Models.Users.Get(userId)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	// if user.MovieId is equal to -1 that indicates they haven't chosen a valid movie
	if user.MovieId == -1 {
		app.sessionManager.Put(r.Context(), "flash", "Please choose a movie")
		data := app.newTemplateData(r)
		app.render(w, r, http.StatusOK, "phrases.gohtml", data)
		return
	}

	// get nextTen phrases to learn from database
	phrases, err := app.Models.Phrases.NextTen(userId, user.MovieId, user.Flipped)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	// if phrases length is equal to zero something went wrong when uploading the title
	// so delete movieId and change user.MovieId to default -1
	if len(phrases) == 0 {
		movieId := user.MovieId
		user.MovieId = -1
		err = app.Models.Users.Update(user)
		if err != nil {
			app.serverError(w, r, err)
			return
		}
		err = app.Models.Movies.Delete(movieId)
		if err != nil {
			app.serverError(w, r, err)
			return
		}
		// add message to flash and render movies.gohtml
		app.sessionManager.Put(r.Context(), "flash", "This movie was not uploaded successfully correctly and has been deleted")
		data := app.newTemplateData(r)
		app.render(w, r, http.StatusOK, "movies.gohtml", data)
		return
	}

	// get sum and total to display on phrases.gohtml page
	sum, total, err := app.Models.Phrases.PercentageDone(userId, user.MovieId, user.Flipped)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	// get movie from user.MovieId. title is used in phrases.gohtml
	movie, err := app.Models.Movies.Get(user.MovieId)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	// create newTemplatedata to send data to phrases.gohtml
	data := app.newTemplateData(r)
	data.Phrases = phrases
	data.Sum = sum
	data.Total = total
	data.Movie = movie

	app.render(w, r, http.StatusOK, "phrases.gohtml", data)
}

// phraseCorrect() marks a phrase as correct when user accepts response on phrases.gohtml
func (app *web) phraseCorrect(w http.ResponseWriter, r *http.Request) {
	userId := app.sessionManager.GetInt(r.Context(), authenticatedUserId)

	// get userId from sessionManager context
	user, err := app.Models.Users.Get(userId)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	var input struct {
		PhraseId string `form:"phrase_id"`
		MovieId  string `form:"movie_id"`
	}

	// get phraseId and movieId from post input. send bad request if error in parsing input
	err = app.decodePostForm(r, &input)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	// if phraseId or movieId cannot be converted to int send bad request
	phraseId, err := strconv.Atoi(input.PhraseId)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	movieId, err := strconv.Atoi(input.MovieId)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	// mark phrase as correct in the database
	err = app.Models.Phrases.PhraseCorrect(userId, phraseId, movieId, user.Flipped)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}
}
