package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
)

// Create a new userSignupForm struct.
type userSignupForm struct {
	Name                string `form:"name"`
	Email               string `form:"email"`
	Password            string `form:"password"`
	Language            string `form:"language"`
	validator.Validator `form:"-"`
}

func (app *application) accountView(w http.ResponseWriter, r *http.Request) {
	userID := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := app.models.Users.Get(userID)
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
	languages, err := app.models.Languages.All()
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	data.Languages = languages
	app.render(w, r, http.StatusOK, "account.gohtml", data)
}

// Update the handler so it displays the signup page.
func (app *application) userSignup(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userSignupForm{}
	languages, err := app.models.Languages.All()
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

func (app *application) duplicateError(w http.ResponseWriter, r *http.Request, form userSignupForm, err error) {
	data := app.newTemplateData(r)
	data.Form = form
	languages, err2 := app.models.Languages.All()
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

func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
	var form userSignupForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.Name), "name", "This field cannot be blank")
	form.CheckField(form.NotBlank(form.Email), "email", "This field cannot be blank")
	form.CheckField(form.Matches(form.Email, validator.EmailRX), "email", "This field must be a valid email address")
	form.CheckField(form.NotBlank(form.Password), "password", "This field cannot be blank")
	form.CheckField(form.MinChars(form.Password, 8), "password", "This field must be at least 8 characters long")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, r, http.StatusUnprocessableEntity, "signup.gohtml", data)
		return
	}

	languageId, err := app.models.Languages.GetId(form.Language)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}
	err = app.models.Users.Insert(form.Name, form.Email, form.Password, languageId)
	if err != nil {
		if errors.Is(err, models.ErrDuplicateEmail) {
			form.AddFieldError("email", "Email address is already in use")
			app.duplicateError(w, r, form, err)
		} else if errors.Is(err, models.ErrDuplicateUserName) {
			form.AddFieldError("name", "User name is already in use")
			app.duplicateError(w, r, form, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	// Otherwise add a confirmation flash message to the session confirming that
	// their signup worked.
	app.sessionManager.Put(r.Context(), "flash", "Your signup was successful. Please log in.")

	// And redirect the user to the login page.
	http.Redirect(w, r, "/user/login", http.StatusSeeOther)
}

// Create a new userLoginForm struct.
type userLoginForm struct {
	Email               string `form:"email"`
	Password            string `form:"password"`
	validator.Validator `form:"-"`
}

// Update the handler so it displays the login page.
func (app *application) userLogin(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userLoginForm{}
	app.render(w, r, http.StatusOK, "login.gohtml", data)
}

func (app *application) userLoginPost(w http.ResponseWriter, r *http.Request) {
	var form userLoginForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.Email), "email", "This field cannot be blank")
	form.CheckField(form.Matches(form.Email, validator.EmailRX), "email", "This field must be a valid email address")
	form.CheckField(form.NotBlank(form.Password), "password", "This field cannot be blank")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form

		app.render(w, r, http.StatusUnprocessableEntity, "login.gohtml", data)
		return
	}

	id, err := app.models.Users.Authenticate(form.Email, form.Password)
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

func (app *application) userLogoutPost(w http.ResponseWriter, r *http.Request) {
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

func (app *application) accountPasswordUpdate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = accountPasswordUpdateForm{}

	app.render(w, r, http.StatusOK, "password.gohtml", data)
}

func (app *application) accountPasswordUpdatePost(w http.ResponseWriter, r *http.Request) {
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

	err = app.models.Users.PasswordUpdate(userId, form.CurrentPassword, form.NewPassword)
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

func (app *application) userLanguageSwitch(w http.ResponseWriter, r *http.Request) {

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	err := app.models.Users.FlippedUpdate(userId)
	if err != nil {
		app.serverError(w, r, err)
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}

type accountLanguageUpdateForm struct {
	Language            string `form:"language"`
	validator.Validator `form:"-"`
}

func (app *application) accountLanguageUpdate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = accountLanguageUpdateForm{}

	languages, err := app.models.Languages.All()
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w, r, err)
		} else {
			app.serverError(w, r, err)
		}
		return
	}

	data.Languages = languages
	app.render(w, r, http.StatusOK, "languageUpdate.gohtml", data)
}

func (app *application) accountLanguageUpdatePost(w http.ResponseWriter, r *http.Request) {
	var form accountLanguageUpdateForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	userId := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	languageId, err := app.models.Languages.GetId(form.Language)
	if err != nil {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, r, http.StatusUnprocessableEntity, "languageUpdate.gohtml", data)
		return
	}

	err = app.models.Users.LanguageUpdate(userId, languageId)
	if err != nil {
		app.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	app.sessionManager.Put(r.Context(), "flash", "Your language has been updated!")

	http.Redirect(w, r, "/account/view", http.StatusSeeOther)
}
