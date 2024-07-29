package main

import (
	"errors"
	"io/fs"
	"net/http"
	"strconv"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
	"talkliketv.net/ui"
)

// moviesView() populates the movies.gohtml page
func (app *web) moviesView(w http.ResponseWriter, r *http.Request) {

	// get userId from context
	userId := app.sessionManager.GetInt(r.Context(), authenticatedUserId)

	// get user from database
	user, err := app.Models.Users.Get(userId)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	var input struct {
		Title string
		Mp3   int
		models.Filters
	}

	// create a new validator
	v := validator.New()
	// Query parses RawQuery and returns the corresponding values.
	qs := r.URL.Query()

	// check if input values are parsed. if not use default
	input.Title = models.ReadString(qs, "title", "")
	input.Mp3 = models.ReadBool(qs, "mp3", -1, v)

	input.Filters.Page = models.ReadInt(qs, "page", 1, v)
	input.Filters.PageSize = models.ReadInt(qs, "page_size", 20, v)

	input.Filters.Sort = models.ReadString(qs, "sort", "id")
	input.Filters.SortSafeList = []string{"id", "title", "num_subs", "-id", "-title", "-num_subs"}

	// query the database for a slice of movies using filters parsed from the url
	movies, _, err := app.Models.Movies.All(user.LanguageId, input.Title, input.Filters, input.Mp3)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	data := app.newTemplateData(r)
	// add slice of movies to the template data
	data.Movies = movies

	app.render(w, r, http.StatusOK, "movies.gohtml", data)
}

// moviesMp3() reads an id parameter from the request url and returns an mp3 matching the title name
// if one exists
func (app *web) moviesMp3(w http.ResponseWriter, r *http.Request) {
	// get id param from the request url
	id, err := models.ReadIDParam(r)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	// check if a movie exists with that parameter
	movie, err := app.Models.Movies.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	// if movie selected does not have MP3 set to true return without continuing
	if !movie.Mp3 {
		app.sessionManager.Put(r.Context(), "flash", "Movie chosen does not have an MP3")
		data := app.newTemplateData(r)
		app.render(w, r, http.StatusOK, "movies.gohtml", data)
		return
	}

	// log info and try to get MP3 using movie title. return not found if error
	app.Logger.PrintInfo("movie.Title = "+movie.Title, nil)
	mp3, err := fs.ReadFile(ui.Files, "mp3/"+movie.Title+".mp3")
	if err != nil {
		app.notFound(w, r, err)
		return
	}

	// set appropriate headers and write MP3 file to response writer
	w.Header().Set("Content-Disposition", "attachment; filename="+movie.Title+".mp3")
	w.Header().Set("Content-Type", r.Header.Get("Content-Type"))
	_, err = w.Write(mp3)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

}

// moviesUpdate() changes the movieId of user
func (app *web) moviesUpdate(w http.ResponseWriter, r *http.Request) {

	// get userId from context
	userId := app.sessionManager.GetInt(r.Context(), authenticatedUserId)

	var input struct {
		MoviesId string `form:"movie_id"`
	}

	// get the movie id to change to from form
	err := app.decodePostForm(r, &input)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	// convert movie id string to int
	i, err := strconv.Atoi(input.MoviesId)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	// update movie id of user
	err = app.Models.Movies.UpdateMovie(userId, i)
	if err != nil {
		app.notFound(w, r, err)
		return
	}

	// redirect to phrases view
	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}
