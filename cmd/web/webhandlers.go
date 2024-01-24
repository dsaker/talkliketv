package main

import (
	"net/http"
)

func (webApp *webApplication) home(w http.ResponseWriter, r *http.Request) {
	data := webApp.newTemplateData(r)

	webApp.render(w, r, http.StatusOK, "home.gohtml", data)
}

func (webApp *webApplication) about(w http.ResponseWriter, r *http.Request) {
	data := webApp.newTemplateData(r)
	webApp.render(w, r, http.StatusOK, "about.gohtml", data)
}

func (webApp *webApplication) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	env := envelope{
		"status": "available",
		"system_info": map[string]string{
			"environment": webApp.Config.Env,
			"version":     version,
		},
	}

	err := webApp.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		webApp.serverError(w, r, err)
	}
}
