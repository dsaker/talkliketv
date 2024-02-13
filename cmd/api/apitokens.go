package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
	"time"
)

func (app *apiApplication) createAuthenticationTokenHandler(w http.ResponseWriter, r *http.Request) {
	// Parse the email and password from the request body.
	var input struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	// Validate the email and password provided by the client.
	v := validator.New()

	models.ValidateEmail(v, input.Email)
	models.ValidatePassword(v, input.Password)

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}

	// Lookup the user record based on the email address. If no matching user was
	// found, then we call the app.invalidCredentialsResponse() helper to send a 401
	// Unauthorized response to the client.
	user, err := app.Models.Users.GetByEmail(input.Email)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			app.invalidCredentialsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if !user.Activated {
		app.inactiveAccountResponse(w, r)
		return
	}

	// Check if the provided password matches the actual password for the user.
	match, err := app.Models.Users.Matches(input.Password, user.HashedPassword)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// If the passwords don't match, then we call the app.invalidCredentialsResponse()
	// helper again and return.
	if !match {
		app.invalidCredentialsResponse(w, r)
		return
	}

	// Otherwise, if the password is correct, we generate a new token with a 24-hour
	// expiry time and the scope 'authentication'.
	token, err := app.Models.Tokens.New(user.ID, 24*time.Hour, models.ScopeAuthentication)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Encode the token to JSON and send it in the response along with a 201 Created
	// status code.
	err = app.writeJSON(w, http.StatusCreated, envelope{"authentication_token": token}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *apiApplication) createActivationTokenHandler(w http.ResponseWriter, r *http.Request) {
	// Parse and validate the user's email address.
	var input struct {
		Email string `json:"email"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	if models.ValidateEmail(v, input.Email); !v.Valid() {
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}

	// Try to retrieve the corresponding user record for the email address. If it can't
	// be found, return an error message to the client.
	user, err := app.Models.Users.GetByEmail(input.Email)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			v.AddFieldError("email", "no matching email address found")
			app.failedValidationResponse(w, r, v.FieldErrors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// Return an error if the user has already been activated.
	if user.Activated {
		v.AddFieldError("email", "user has already been activated")
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}

	// Otherwise, create a new activation token.
	token, err := app.Models.Tokens.New(user.ID, 3*24*time.Hour, models.ScopeActivation)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Email the user with their additional activation token.
	app.Background(func() {
		data := map[string]interface{}{
			"activationToken": token.Plaintext,
		}

		// Since email addresses MAY be case sensitive, notice that we are sending this
		// email using the address stored in our database for the user --- not to the
		// input.Email address provided by the client in this request.
		err = app.Mailer.Send(user.Email, "token_activation.tmpl", data)
		if err != nil {
			app.Logger.PrintError(err, nil)
		}
	})

	// Send a 202 Accepted response and confirmation message to the client.
	env := envelope{"message": "an email will be sent to you containing activation instructions"}

	err = app.writeJSON(w, http.StatusAccepted, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *apiApplication) createPasswordResetTokenHandler(w http.ResponseWriter, r *http.Request) {

	// Parse and validate the user's email address.
	var input struct {
		Email string `json:"email"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	if models.ValidateEmail(v, input.Email); !v.Valid() {
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}

	// Try to retrieve the corresponding user record for the email address. If it can't
	// be found, return an error message to the client.
	user, err := app.Models.Users.GetByEmail(input.Email)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			v.AddFieldError("email", "no matching email address found")
			app.failedValidationResponse(w, r, v.FieldErrors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// Return an error message if the user is not activated.
	if !user.Activated {
		v.AddFieldError("email", "user account must be activated")
		app.failedValidationResponse(w, r, v.FieldErrors)
		return
	}
	// Otherwise, create a new password reset token with a 45-minute expiry time.
	token, err := app.Models.Tokens.New(user.ID, 45*time.Minute, models.ScopePasswordReset)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	// Email the user with their password reset token.
	app.Background(func() {
		data := map[string]interface{}{
			"passwordResetToken": token.Plaintext}
		err = app.Mailer.Send(user.Email, "token_password_reset.gohtml", data)
		if err != nil {
			app.Logger.PrintError(err, nil)
		}
	})

	// Send a 202 Accepted response and confirmation message to the client.
	env := envelope{"message": "an email will be sent to you containing password reset instructions"}
	err = app.writeJSON(w, http.StatusAccepted, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
