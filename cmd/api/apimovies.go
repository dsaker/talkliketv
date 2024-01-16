package main

import (
	"errors"
	"io/fs"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/ui"
)

func (app *application) moviesMp3(w http.ResponseWriter, r *http.Request) {
	id, err := models.ReadIDParam(r)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, err.Error())
		return
	}

	movie, err := app.models.Movies.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	app.logger.PrintInfo("movie.Title = "+movie.Title, nil)
	mp3, err := fs.ReadFile(ui.Files, "mp3/"+movie.Title+".mp3")
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	w.Header().Set("Content-Disposition", "attachment; filename="+movie.Title+".mp3")
	w.Header().Set("Content-Type", r.Header.Get("Content-Type"))
	_, err = w.Write(mp3)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

}

func (app *application) moviesChoose(w http.ResponseWriter, r *http.Request) {

	var input struct {
		MovieId int `json:"movie_id"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	user := app.contextGetUser(r)
	err = app.models.Movies.ChooseMovie(int(user.ID), input.MovieId)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (app *application) listMoviesHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	// Accept the metadata struct as a return value.
	movies, err := app.models.Movies.Get(user.LanguageId)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Include the metadata in the response envelope.
	err = app.writeJSON(w, http.StatusOK, envelope{"movies": movies}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
