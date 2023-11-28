package main

import (
	"net/http"
	"strconv"
)

func (app *application) moviesView(w http.ResponseWriter, r *http.Request) {

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.users.Get(userId)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	movies, err := app.movies.All(user.LanguageId)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	data := app.newTemplateData(r)
	data.Movies = movies

	app.render(w, r, http.StatusOK, "movies.gohtml", data)
}

func (app *application) moviesChoose(w http.ResponseWriter, r *http.Request) {

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	var input struct {
		MoviesId string `form:"movie_id"`
	}

	err := app.decodePostForm(r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	i, err := strconv.Atoi(input.MoviesId)
	if err != nil {
		app.badRequestResponse(w, r, err)
	}

	err = app.movies.ChooseMovie(userId, i)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}
