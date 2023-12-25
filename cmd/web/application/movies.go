package application

import (
	"errors"
	"io/fs"
	"net/http"
	"strconv"
	"talkliketv.net/internal/models"
	"talkliketv.net/ui"
)

func (app *Application) moviesView(w http.ResponseWriter, r *http.Request) {

	userId := app.SessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.Users.Get(userId)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	movies, err := app.Movies.All(user.LanguageId)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	data := app.newTemplateData(r)
	data.Movies = movies

	app.render(w, r, http.StatusOK, "movies.gohtml", data)
}

func (app *Application) moviesMp3(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	movie, err := app.Movies.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	app.Logger.PrintInfo("movie.Title = "+movie.Title, nil)
	mp3, err := fs.ReadFile(ui.Files, "mp3/"+movie.Title+".mp3")
	if err != nil {
		app.notFound(w, r, err)
		return
	}

	w.Header().Set("Content-Disposition", "attachment; filename="+movie.Title+".mp3")
	w.Header().Set("Content-Type", r.Header.Get("Content-Type"))
	_, err = w.Write(mp3)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

}

func (app *Application) moviesChoose(w http.ResponseWriter, r *http.Request) {

	userId := app.SessionManager.GetInt(r.Context(), "authenticatedUserID")

	var input struct {
		MoviesId string `form:"movie_id"`
	}

	err := app.decodePostForm(r, &input)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	i, err := strconv.Atoi(input.MoviesId)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	err = app.Movies.ChooseMovie(userId, i)
	if err != nil {
		app.notFound(w, r, err)
		return
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}
