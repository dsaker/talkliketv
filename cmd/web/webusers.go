package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
)

func (app *web) accountView(w http.ResponseWriter, r *http.Request) {
	userID := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.Models.Users.Get(userID)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	data := app.newTemplateData(r)
	data.User = user
	languages, err := app.Models.Languages.All(true)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	data.Languages = languages
	app.render(w, r, http.StatusOK, "account.gohtml", data)
}

// Update the handler so it displays the signup page.
func (app *web) userSignup(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = models.UserSignupForm{}
	languages, err := app.Models.Languages.All(true)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	data.Languages = languages
	app.render(w, r, http.StatusOK, "signup.gohtml", data)
}

func (app *web) duplicateError(w http.ResponseWriter, r *http.Request, form models.UserSignupForm, err error) {
	data := app.newTemplateData(r)
	data.Form = form
	languages, err2 := app.Models.Languages.All(true)
	if err2 != nil {
		if errors.Is(err2, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err2)
		}
		return
	}

	data.Languages = languages
	app.render(w, r, http.StatusUnprocessableEntity, "signup.gohtml", data)
}

func (app *web) userSignupPost(w http.ResponseWriter, r *http.Request) {
	var form models.UserSignupForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	models.ValidateUser(&form)

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, r, http.StatusUnprocessableEntity, "signup.gohtml", data)
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
		if errors.Is(err, models.ErrDuplicateEmail) {
			form.AddFieldError("email", "Email address is already in use")
			app.duplicateError(w, r, form, err)
		} else if errors.Is(err, models.ErrDuplicateUserName) {
			form.AddFieldError("name", "Username is already in use")
			app.duplicateError(w, r, form, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	err = app.SendActivationEmail(user)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	// Otherwise add a confirmation flash message to the session confirming that
	// their signup worked.
	app.sessionManager.Put(r.Context(), "flash", "Your signup was successful. Please check your email for activation code.")

	// And redirect the user to the login page.
	http.Redirect(w, r, "/user/activate", http.StatusSeeOther)
}

// Create a new userLoginForm struct.
type userLoginForm struct {
	Email               string `form:"email"`
	Password            string `form:"password"`
	validator.Validator `form:"-"`
}

// Update the handler so it displays the login page.
func (app *web) userLogin(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userLoginForm{}
	app.render(w, r, http.StatusOK, "login.gohtml", data)
}

func (app *web) userLoginPost(w http.ResponseWriter, r *http.Request) {
	var form userLoginForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.Email), "email", "This field cannot be blank")
	form.CheckField(form.IsEmail(form.Email), "email", "This field must be a valid email address")
	form.CheckField(form.NotBlank(form.Password), "password", "This field cannot be blank")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form

		app.render(w, r, http.StatusUnprocessableEntity, "login.gohtml", data)
		return
	}

	id, activated, err := app.Models.Users.Authenticate(form.Email, form.Password)
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.AddNonFieldError("Email or password is incorrect")

			data := app.newTemplateData(r)
			data.Form = form

			app.render(w, r, http.StatusUnprocessableEntity, "login.gohtml", data)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	if !activated {
		app.sessionManager.Put(r.Context(), "flash", "You need to be activated. Please email or text site creator for activation code.")
		// And redirect the user to the login page.
		http.Redirect(w, r, "/user/activate", http.StatusSeeOther)
		return
	}

	err = app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	app.sessionManager.Put(r.Context(), "authenticatedUserID", id)

	// Use the PopString method to retrieve and remove a value from the session
	// data in one step. If no matching key exists this will return the empty
	// string.
	path := app.sessionManager.PopString(r.Context(), "redirectPathAfterLogin")
	if path != "" {
		http.Redirect(w, r, path, http.StatusSeeOther)
		return
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}

func (app *web) userLogoutPost(w http.ResponseWriter, r *http.Request) {
	// Use the RenewToken() method on the current session to change the session
	// ID again.
	err := app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	// Remove the authenticatedUserID from the session data so that the user is
	// 'logged out'.
	app.sessionManager.Remove(r.Context(), "authenticatedUserID")

	// Add a flash message to the session to confirm to the user that they've been
	// logged out.
	app.sessionManager.Put(r.Context(), "flash", "You've been logged out successfully!")

	// Redirect the user to the application home page.
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

type accountPasswordUpdateForm struct {
	CurrentPassword         string `form:"currentPassword"`
	NewPassword             string `form:"newPassword"`
	NewPasswordConfirmation string `form:"newPasswordConfirmation"`
	validator.Validator     `form:"-"`
}

func (app *web) accountPasswordUpdate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = accountPasswordUpdateForm{}

	app.render(w, r, http.StatusOK, "password.gohtml", data)
}

func (app *web) accountPasswordUpdatePost(w http.ResponseWriter, r *http.Request) {
	var form accountPasswordUpdateForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.CurrentPassword), "currentPassword", "This field cannot be blank")
	form.CheckField(form.NotBlank(form.NewPassword), "newPassword", "This field cannot be blank")
	form.CheckField(form.MinChars(form.NewPassword, 8), "newPassword", "This field must be at least 8 characters long")
	form.CheckField(form.NotBlank(form.NewPasswordConfirmation), "newPasswordConfirmation", "This field cannot be blank")
	form.CheckField(form.NewPassword == form.NewPasswordConfirmation, "newPasswordConfirmation", "Passwords do not match")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form

		app.render(w, r, http.StatusUnprocessableEntity, "password.gohtml", data)
		return
	}
	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	err = app.Models.Users.WebPasswordUpdate(userId, form.CurrentPassword, form.NewPassword)
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.AddFieldError("currentPassword", "Current password is incorrect")

			data := app.newTemplateData(r)
			data.Form = form

			app.render(w, r, http.StatusUnprocessableEntity, "password.gohtml", data)
		} else if err != nil {
			app.serverError(w, r, err)
		}
		return
	}

	app.sessionManager.Put(r.Context(), "flash", "Your password has been updated!")

	http.Redirect(w, r, "/account/view", http.StatusSeeOther)
}

func (app *web) userLanguageFlip(w http.ResponseWriter, r *http.Request) {

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.Models.Users.Get(userId)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
		} else {
			app.serverError(w, r, err)
		}
		return
	}
	user.Flipped = !user.Flipped
	err = app.Models.Users.Update(user)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrEditConflict):
			app.editConflictResponse(w, r, err)
		default:
			app.serverError(w, r, err)
		}
		return
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}

type accountLanguageUpdateForm struct {
	Language            string `form:"language"`
	validator.Validator `form:"-"`
}

func (app *web) accountLanguageUpdate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = accountLanguageUpdateForm{}

	languages, err := app.Models.Languages.All(true)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	data.Languages = languages
	app.render(w, r, http.StatusOK, "language-update.gohtml", data)
}

func (app *web) accountLanguageUpdatePost(w http.ResponseWriter, r *http.Request) {
	var form accountLanguageUpdateForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	languageId, err := app.Models.Languages.GetId(form.Language)
	if err != nil {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, r, http.StatusUnprocessableEntity, "language-update.gohtml", data)
		return
	}

	user, err := app.Models.Users.Get(userId)
	if err != nil {
		app.serverError(w, r, err)
		return
	}
	user.LanguageId = languageId

	err = app.Models.Users.Update(user)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrEditConflict):
			app.editConflictResponse(w, r, err)
		default:
			app.serverError(w, r, err)
		}
		return
	}

	app.sessionManager.Put(r.Context(), "flash", "Your language has been updated!")

	http.Redirect(w, r, "/account/view", http.StatusSeeOther)
}

type userPasswordResetForm struct {
	Token               string `form:"token"`
	NewPassword         string `form:"newPassword"`
	ConfirmPassword     string `form:"confirmPassword"`
	validator.Validator `form:"-"`
}

func (app *web) userPasswordReset(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userPasswordResetForm{}

	app.render(w, r, http.StatusOK, "password-reset.gohtml", data)
}

func (app *web) userPasswordResetPost(w http.ResponseWriter, r *http.Request) {
	var form userPasswordResetForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.Token), "token", "This field cannot be blank")
	form.CheckField(form.NotBlank(form.NewPassword), "newPassword", "This field cannot be blank")
	form.CheckField(form.NotBlank(form.ConfirmPassword), "confirmPassword", "This field cannot be blank")
	form.CheckField(form.MinChars(form.NewPassword, 8), "newPassword", "This field must be at least 8 characters long")
	form.CheckField(form.NewPassword == form.ConfirmPassword, "confirmPassword", "Passwords do not match")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form

		app.render(w, r, http.StatusUnprocessableEntity, "password-reset.gohtml", data)
		return
	}

	// Retrieve the details of the user associated with the password reset token,
	// returning an error message if no matching record was found.
	user, err := app.Models.Users.GetForToken(models.ScopePasswordReset, form.Token)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			form.AddFieldError("token", "invalid or expired password reset token")
			data := app.newTemplateData(r)
			data.Form = form
			app.render(w, r, http.StatusUnprocessableEntity, "password-reset.gohtml", data)
		default:
			app.serverError(w, r, err)
		}
		return
	}

	// Set the new password for the user.
	err = app.Models.Users.PasswordUpdate(user.ID, form.NewPassword)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	// If everything was successful, then delete all password reset tokens for the user.
	err = app.Models.Tokens.DeleteAllForUser(models.ScopePasswordReset, user.ID)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	app.sessionManager.Put(r.Context(), "flash", "Your password has been updated!")

	http.Redirect(w, r, "/user/login", http.StatusSeeOther)
}

type userActivateForm struct {
	Token               string `form:"token"`
	validator.Validator `form:"-"`
}

func (app *web) userActivate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userActivateForm{}

	app.render(w, r, http.StatusOK, "activate.gohtml", data)
}

func (app *web) userActivatePost(w http.ResponseWriter, r *http.Request) {
	var form userActivateForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.Token), "token", "This field cannot be blank")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form

		app.render(w, r, http.StatusUnprocessableEntity, "activate.gohtml", data)
		return
	}

	// Retrieve the details of the user associated with the password reset token,
	// returning an error message if no matching record was found.
	user, err := app.Models.Users.GetForToken(models.ScopeActivation, form.Token)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrNoRecord):
			form.AddFieldError("token", "invalid or expired password reset token")
			data := app.newTemplateData(r)
			data.Form = form
			app.render(w, r, http.StatusUnprocessableEntity, "activate.gohtml", data)
		default:
			app.serverError(w, r, err)
		}
		return
	}

	user.Activated = true
	// Set the new password for the user.
	err = app.Models.Users.Update(user)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrEditConflict):
			app.editConflictResponse(w, r, err)
		default:
			app.serverError(w, r, err)
		}
		return
	}

	// If everything was successful, then delete all password reset tokens for the user.
	err = app.Models.Tokens.DeleteAllForUser(models.ScopePasswordReset, user.ID)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	app.sessionManager.Put(r.Context(), "flash", "Your account has been activated!")

	http.Redirect(w, r, "/user/login", http.StatusSeeOther)
}
