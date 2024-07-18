package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
	"time"
)

// Create a new userLoginForm struct.
type tokenRequestForm struct {
	Email               string `form:"email"`
	validator.Validator `form:"-"`
}

func (app *web) createPasswordResetToken(w http.ResponseWriter, r *http.Request) {
	user := app.decodeEmail(w, r)
	if user == nil {
		return
	}
	// Otherwise, create a new password reset token with a 45-minute expiry time.
	token, err := app.Models.Tokens.New(user.ID, 45*time.Minute, models.ScopePasswordReset)
	if err != nil {
		app.serverError(w, r, err)
		return
	}
	// Email the user with their password reset token.
	app.Background(func() {
		emailData := map[string]interface{}{
			"passwordResetToken": token.Plaintext}
		err = app.Mailer.Send(user.Email, "token_password_reset.gohtml", emailData)
		if err != nil {
			app.Logger.PrintError(err, nil)
		}
	})

	//form.AddNonFieldError("An email will be sent to you containing password reset instructions")
	app.sessionManager.Put(r.Context(), "flash", "An email will be sent to you containing password reset instructions")
	http.Redirect(w, r, "/user/password/reset", http.StatusSeeOther)
}

func (app *web) createActivationToken(w http.ResponseWriter, r *http.Request) {
	user := app.decodeEmail(w, r)
	if user == nil {
		return
	}

	// Otherwise, create a new password reset token with a 45-minute expiry time.
	token, err := app.Models.Tokens.New(user.ID, 45*time.Minute, models.ScopeActivation)
	if err != nil {
		app.serverError(w, r, err)
		return
	}
	// Email the user with their password reset token.
	app.Background(func() {
		emailData := map[string]interface{}{
			"activationToken": token.Plaintext}
		err = app.Mailer.Send(user.Email, "token_activation.gohtml", emailData)
		if err != nil {
			app.Logger.PrintError(err, nil)
		}
	})

	//form.AddNonFieldError("An email will be sent to you containing password reset instructions")
	app.sessionManager.Put(r.Context(), "flash", "An email will be sent to you containing password reset instructions")
	http.Redirect(w, r, "/user/password/reset", http.StatusSeeOther)
}

func (app *web) decodeEmail(w http.ResponseWriter, r *http.Request) *models.User {
	var form tokenRequestForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return nil
	}

	form.CheckField(form.NotBlank(form.Email), "email", "This field cannot be blank")
	form.CheckField(form.IsEmail(form.Email), "email", "This field must be a valid email address")

	// Try to retrieve the corresponding user record for the email address. If it can't
	// be found, return an error message to the client.
	user, err := app.Models.Users.GetByEmail(form.Email)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			form.AddFieldError("email", "no matching email address found")
			data := app.newTemplateData(r)
			data.Form = form

			app.render(w, r, http.StatusUnprocessableEntity, "login.gohtml", data)
		default:
			app.serverError(w, r, err)
		}
		return nil
	}

	// Return an error message if the user is not activated.
	if !user.Activated {
		form.AddNonFieldError("user account must be activated")
		data := app.newTemplateData(r)
		data.Form = form

		app.render(w, r, http.StatusUnprocessableEntity, "login.gohtml", data)
		return nil
	}

	return user
}
