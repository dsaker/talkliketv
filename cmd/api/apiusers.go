package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
)

func (app *api) registerUser(w http.ResponseWriter, r *http.Request) {

	var form models.UserSignupForm

	err := app.readJSON(w, r, &form)
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
		LanguageId: form.LanguageId,
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

	err = app.SendActivationEmail(user)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusAccepted, envelope{"user": user}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *api) activateUser(w http.ResponseWriter, r *http.Request) {
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

func (app *api) updateUserLanguage(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)

	var input struct {
		Language string `json:"language"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	models.ValidateLanguage(v, input.Language)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}

	languageId, err := app.Models.Languages.GetId(input.Language)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			v.AddFieldError("langauge", "invalid language")
			app.failedValidationResponse(w, r, v.FieldErrors)
			return
		} else {
			app.serverErrorResponse(w, r, err)
		}
	}

	user.LanguageId = languageId

	err = app.Models.Users.Update(user)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}

	// Send the user a confirmation message.
	env := envelope{"message": "your language was updated successfully"}

	err = app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// Verify the password reset token and set a new password for the user.
func (app *api) updateUserPassword(w http.ResponseWriter, r *http.Request) {
	// Parse and validate the user's new password and password reset token.
	var input struct {
		Password       string `json:"password"`
		TokenPlaintext string `json:"token"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	models.ValidatePassword(v, input.Password)
	models.ValidateTokenPlaintext(v, input.TokenPlaintext)

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}

	// Retrieve the details of the user associated with the password reset token,
	// returning an error message if no matching record was found.
	user, err := app.Models.Users.GetForToken(models.ScopePasswordReset, input.TokenPlaintext)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			v.AddFieldError("token", "invalid or expired password reset token")
			app.failedValidationResponse(w, r, v.FieldErrors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if !user.Activated {
		app.inactiveAccountResponse(w, r)
		return
	}

	// Set the new password for the user.
	err = app.Models.Users.PasswordUpdate(user.ID, input.Password)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// If everything was successful, then delete all password reset tokens for the user.
	err = app.Models.Tokens.DeleteAllForUser(models.ScopePasswordReset, user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Send the user a confirmation message.
	env := envelope{"message": "your password was successfully reset"}

	err = app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *api) updateUserFlipped(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	user.Flipped = !user.Flipped
	err := app.Models.Users.Update(user)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Send the user a confirmation message.
	env := envelope{"message": "your language was switched successfully"}

	err = app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *api) accountView(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	dBUser, err := app.Models.Users.Get(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
	err = app.writeJSON(w, http.StatusOK, envelope{"user": dBUser}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
