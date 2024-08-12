package main

import (
	"errors"
	"io/fs"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
	"talkliketv.net/ui"
)

func (app *api) moviesMp3(w http.ResponseWriter, r *http.Request) {
	id, err := models.ReadIDParam(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	movie, err := app.Models.Movies.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	app.Logger.PrintInfo("movie.Title = "+movie.Title, nil)
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

func (app *api) moviesChoose(w http.ResponseWriter, r *http.Request) {

	var input struct {
		MovieId int `json:"movie_id"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	user := app.contextGetUser(r)
	err = app.Models.Movies.UpdateMovie(user.ID, input.MovieId)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (app *api) listMovies(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	var input struct {
		Title string
		Mp3   int
		models.Filters
	}
	v := validator.New()

	qs := r.URL.Query()

	input.Title = models.ReadString(qs, "title", "")
	input.Mp3 = models.ReadBool(qs, "mp3", -1, v)

	input.Filters.Page = models.ReadInt(qs, "page", 1, v)
	input.Filters.PageSize = models.ReadInt(qs, "page_size", 20, v)

	input.Filters.Sort = models.ReadString(qs, "sort", "id")
	input.Filters.SortSafeList = []string{"id", "title", "year", "num_subs", "-id", "-title", "-year", "-num_subs"}

	if models.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}
	// Accept the metadata struct as a return value.
	movies, metadata, err := app.Models.Movies.All(user.LanguageId, input.Title, input.Filters, input.Mp3)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Include the metadata in the response envelope.
	err = app.writeJSON(w, http.StatusOK, envelope{"movies": movies, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
