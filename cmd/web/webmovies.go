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

func (webApp *webApplication) moviesView(w http.ResponseWriter, r *http.Request) {

	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := webApp.Models.Users.Get(userId)
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

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

	movies, _, err := webApp.Models.Movies.All(user.LanguageId, input.Title, input.Filters, input.Mp3)
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

	data := webApp.newTemplateData(r)
	data.Movies = movies

	webApp.render(w, r, http.StatusOK, "movies.gohtml", data)
}

func (webApp *webApplication) moviesMp3(w http.ResponseWriter, r *http.Request) {
	id, err := models.ReadIDParam(r)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	movie, err := webApp.Models.Movies.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			webApp.notFound(w, r, err)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	webApp.Logger.PrintInfo("movie.Title = "+movie.Title, nil)
	mp3, err := fs.ReadFile(ui.Files, "mp3/"+movie.Title+".mp3")
	if err != nil {
		webApp.notFound(w, r, err)
		return
	}

	w.Header().Set("Content-Disposition", "attachment; filename="+movie.Title+".mp3")
	w.Header().Set("Content-Type", r.Header.Get("Content-Type"))
	_, err = w.Write(mp3)
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

}

func (webApp *webApplication) moviesChoose(w http.ResponseWriter, r *http.Request) {

	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	var input struct {
		MoviesId string `form:"movie_id"`
	}

	err := webApp.decodePostForm(r, &input)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	i, err := strconv.Atoi(input.MoviesId)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	err = webApp.Models.Movies.ChooseMovie(userId, i)
	if err != nil {
		webApp.notFound(w, r, err)
		return
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}
