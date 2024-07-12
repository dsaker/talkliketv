package main

import (
	"bufio"
	"cloud.google.com/go/translate"
	"context"
	"errors"
	"fmt"
	"golang.org/x/text/language"
	"net/http"
	"strings"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
	"unicode"
)

type TranslateTextForm struct {
	LanguageId          int    `form:"language_id"`
	FromEnglish         string `form:"from_english"`
	Title               string `form:"title"`
	validator.Validator `form:"-"`
}

// Update the handler so it displays the signup page.
func (app *web) translateText(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = TranslateTextForm{}

	data.Languages = app.getLang(w, r)
	app.render(w, r, http.StatusOK, "translate.gohtml", data)
}

func (app *web) translateTextPost(w http.ResponseWriter, r *http.Request) {
	var form TranslateTextForm

	// Maximum upload of 32768 Bytes... this is ~ 4 pages
	err := r.ParseMultipartForm(32768)
	// if file is too big send error
	if err != nil {
		app.sendTranslateError(w, r, "File is too big")
	}

	// Decode TranslateTextForm
	err = app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, fmt.Errorf("error decoding form: %w", err))
		return
	}

	// Validate inputs
	form.CheckField(form.NotBlank(form.Title), "title", "This field cannot be blank")

	// If form is not valid send 422 and error
	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form

		app.render(w, r, http.StatusUnprocessableEntity, "translate.gohtml", data)
		return
	}

	// Get handler for filename, size and headers
	file, handler, err := r.FormFile("text_file")
	if err != nil {
		if errors.Is(err, http.ErrMissingFile) {
			app.sendTranslateError(w, r, "File is missing")
		} else {
			app.serverError(w, r, err)
		}
		return
	}
	defer file.Close()

	// Log filename
	app.Logger.PrintInfo(fmt.Sprintf("File uploaded successfully: %s", handler.Filename), nil)

	// Create phrases slice and count number of lines form movies model
	scanner := bufio.NewScanner(file)
	var phrasesSlice []string
	numLines := 0
	for scanner.Scan() {
		numLines += 1
		phrasesSlice = append(phrasesSlice, scanner.Text())
	}

	// create movie model to insert into database
	movie := &models.Movie{
		Title:      form.Title,
		NumSubs:    numLines,
		LanguageId: form.LanguageId,
	}

	// Insert movie to database, get Id to delete if error inserting phrases
	movieID, err := app.Models.Movies.Insert(movie)
	if err != nil {
		if errors.Is(err, models.ErrDuplicateTitle) {
			form.AddFieldError("title", "Title is already in use")
			app.duplicateError(w, r, form, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	// Get language model from id for tag
	langModel, err := app.Models.Languages.Get(form.LanguageId)
	if err != nil {
		app.serverError(w, r, fmt.Errorf("get language err: %w", err))
		return
	}

	lang, err := language.Parse(langModel.Tag)
	if err != nil {
		app.serverError(w, r, fmt.Errorf("language.Parse: %w", err))
		return
	}

	// create new translate client to connect with google cloud
	ctx := context.Background()
	client, err := translate.NewClient(ctx)
	if err != nil {
		app.serverError(w, r, fmt.Errorf(" client translate error getting new client: %w", err))
		return
	}
	defer client.Close()

	for _, phrase := range phrasesSlice {
		if len(phrase) == 0 {
			continue
		}
		resp, err := client.Translate(ctx, []string{phrase}, lang, nil)
		if err != nil {
			app.serverError(w, r, fmt.Errorf("translate error: %w", err))
			return
		}
		if len(resp) == 0 {
			app.serverError(w, r, fmt.Errorf("translate returned empty response to text: %s", phrasesSlice))
			return
		}

		phraseModel := &models.Phrase{
			Phrase:         phrase,
			Translates:     resp[0].Text,
			PhraseHint:     makeHintString(phrase),
			TranslatesHint: makeHintString(resp[0].Text),
			MovieId:        movieID,
		}

		err = app.Models.Phrases.Insert(phraseModel)
		if err != nil {
			app.serverError(w, r, fmt.Errorf("language.Parse: %w", err))
			return
		}
	}

	// Otherwise add a confirmation flash message to the session confirming that
	// their signup worked.
	app.sessionManager.Put(r.Context(), "flash", "Your file was uploaded successfully.")

	// And redirect the user to the login page.
	http.Redirect(w, r, "/movies/view", http.StatusSeeOther)
}

func (app *web) getLang(w http.ResponseWriter, r *http.Request) []*models.Language {
	languages, err := app.Models.Languages.All(false)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return nil
	}

	return languages
}

func (app *web) sendTranslateError(w http.ResponseWriter, r *http.Request, message string) {
	var form TranslateTextForm

	form.AddNonFieldError(message)

	data := app.newTemplateData(r)
	data.Form = form
	data.Languages = app.getLang(w, r)
	app.render(w, r, http.StatusUnprocessableEntity, "translate.gohtml", data)
}

func makeHintString(s string) string {
	hintString := ""
	words := strings.Fields(s)
	for _, word := range words {
		punctuation := false
		hintString += string(word[0])
		if unicode.IsPunct(rune(word[0])) {
			punctuation = true
		}
		for i := 1; i < len(word); i++ {
			if punctuation {
				hintString += string(word[i])
				punctuation = false
			} else if unicode.IsLetter(rune(word[i])) {
				hintString += "_"
			} else {
				hintString += string(word[i])
			}
		}
		hintString += " "
	}
	return hintString
}
