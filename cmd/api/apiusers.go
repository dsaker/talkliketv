package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
	"time"
)

func (app *apiApp) registerUserHandler(w http.ResponseWriter, r *http.Request) {

	var form models.UserSignupForm

	err := app.readJSON(w, r, &form)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	languageId, err := app.Models.Languages.GetId(form.Language)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	models.ValidateUser(&form)

	if !form.Valid() {
		app.failedValidationResponse(w, r, form.FieldErrors)
		return
	}

	user := &models.User{
		Name:       form.Name,
		Email:      form.Email,
		LanguageId: languageId,
		Activated:  false,
	}

	err = app.Models.Users.Insert(user, form.Password)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrDuplicateEmail):
			form.AddFieldError("email", "a user with this email address already exists")
			app.failedValidationResponse(w, r, form.FieldErrors)
		case errors.Is(err, models.ErrDuplicateUserName):
			form.AddFieldError("username", "a user with this username already exists")
			app.failedValidationResponse(w, r, form.FieldErrors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	_, err = app.Models.Tokens.New(user.ID, 24*time.Hour, models.ScopeActivation)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusAccepted, envelope{"user": user}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *apiApp) activateUserHandler(w http.ResponseWriter, r *http.Request) {
	// Parse the plaintext activation token from the request body.
	var input struct {
		TokenPlaintext string `json:"token"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	// Validate the plaintext token provided by the client.
	v := validator.New()

	if models.ValidateTokenPlaintext(v, input.TokenPlaintext); !v.Valid() {
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}

	// Retrieve the details of the user associated with the token using the
	// GetForToken() method (which we will create in a minute). If no matching record
	// is found, then we let the client know that the token they provided is not valid.
	user, err := app.Models.Users.GetForToken(models.ScopeActivation, input.TokenPlaintext)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			v.AddFieldError("token", "invalid or expired activation token")
			app.failedValidationResponse(w, r, v.FieldErrors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// Update the user's activation status.
	user.Activated = true
	// Save the updated user record in our database, checking for any edit conflicts in
	// the same way that we did for our movie records.
	err = app.Models.Users.Update(user)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrEditConflict):
			app.editConflictResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// If everything went successfully, then we delete all activation tokens for the
	// user.
	err = app.Models.Tokens.DeleteAllForUser(models.ScopeActivation, user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Send the updated user details to the client in a JSON response.
	err = app.writeJSON(w, http.StatusOK, envelope{"user": user}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
