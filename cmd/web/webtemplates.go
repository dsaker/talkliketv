package main

import (
	"html/template"
	"io/fs"
	"path/filepath"
	"talkliketv.net/internal/models"
	"talkliketv.net/ui"
	"time"
)

type templateData struct {
	CurrentYear     int
	Phrase          *models.Phrase
	Phrases         []*models.FrontendPhrase
	Form            any
	Flash           string
	IsAuthenticated bool
	Email           string
	CSRFToken       string
	User            *models.User
	Movie           *models.Movie
	Movies          []*models.Movie
	Languages       []*models.Language
	Sum             int
	Total           int
	Mp3             bool
}

func humanDate(t time.Time) string {
	// Return the empty string if time has the zero value.
	if t.IsZero() {
		return ""
	}

	// Convert the time to UTC before formatting it.
	return t.UTC().Format("02 Jan 2006 at 15:04")
}

// Initialize a template.FuncMap object and store it in a global variable. This is
// essentially a string-keyed map which acts as a lookup between the names of our
// custom template functions and the functions themselves.
var functions = template.FuncMap{
	"humanDate": humanDate,
}

func newTemplateCache() (map[string]*template.Template, error) {
	cache := map[string]*template.Template{}

	//Use fs.Glob() to get a slice of all filepaths in the ui.Files embedded
	//filesystem which match the pattern 'html/pages/*.tmpl'. This essentially
	//gives us a slice of all the 'page' templates for the application, just
	//like before.
	pages, err := fs.Glob(ui.Files, "html/pages/*.gohtml")
	if err != nil {
		return nil, err
	}

	for _, page := range pages {
		name := filepath.Base(page)

		// Create a slice containing the filepath patterns for the templates we
		// want to parse.
		patterns := []string{
			"html/base.gohtml",
			"html/partials/*.gohtml",
			page,
		}

		// Use ParseFS() instead of ParseFiles() to parse the template files
		// from the ui.Files embedded filesystem.
		ts, err := template.New(name).Funcs(functions).ParseFS(ui.Files, patterns...)
		if err != nil {
			return nil, err
		}

		cache[name] = ts
	}

	return cache, nil
}