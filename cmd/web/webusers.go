package main

import (
	"errors"
	"net/http"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
)

func (webApp *webApplication) accountView(w http.ResponseWriter, r *http.Request) {
	userID := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	user, err := webApp.Models.Users.Get(userID)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	data := webApp.newTemplateData(r)
	data.User = user
	languages, err := webApp.Models.Languages.All()
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

	data.Languages = languages
	webApp.render(w, r, http.StatusOK, "account.gohtml", data)
}

// Update the handler so it displays the signup page.
func (webApp *webApplication) userSignup(w http.ResponseWriter, r *http.Request) {
	data := webApp.newTemplateData(r)
	data.Form = models.UserSignupForm{}
	languages, err := webApp.Models.Languages.All()
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			webApp.notFound(w, r, err)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	data.Languages = languages
	webApp.render(w, r, http.StatusOK, "signup.gohtml", data)
}

func (webApp *webApplication) duplicateError(w http.ResponseWriter, r *http.Request, form models.UserSignupForm, err error) {
	data := webApp.newTemplateData(r)
	data.Form = form
	languages, err2 := webApp.Models.Languages.All()
	if err2 != nil {
		if errors.Is(err2, models.ErrNoRecord) {
			webApp.notFound(w, r, err)
		} else {
			webApp.serverError(w, r, err2)
		}
		return
	}

	data.Languages = languages
	webApp.render(w, r, http.StatusUnprocessableEntity, "signup.gohtml", data)
}

func (webApp *webApplication) userSignupPost(w http.ResponseWriter, r *http.Request) {
	var form models.UserSignupForm

	err := webApp.decodePostForm(r, &form)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	models.ValidateUser(&form)

	if !form.Valid() {
		data := webApp.newTemplateData(r)
		data.Form = form
		webApp.render(w, r, http.StatusUnprocessableEntity, "signup.gohtml", data)
		return
	}

	languageId, err := webApp.Models.Languages.GetId(form.Language)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	user := &models.User{
		Name:       form.Name,
		Email:      form.Email,
		LanguageId: languageId,
		Activated:  false,
	}

	err = webApp.Models.Users.Insert(user, form.Password)
	if err != nil {
		if errors.Is(err, models.ErrDuplicateEmail) {
			form.AddFieldError("email", "Email address is already in use")
			webApp.duplicateError(w, r, form, err)
		} else if errors.Is(err, models.ErrDuplicateUserName) {
			form.AddFieldError("name", "Username is already in use")
			webApp.duplicateError(w, r, form, err)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	// Otherwise add a confirmation flash message to the session confirming that
	// their signup worked.
	webApp.sessionManager.Put(r.Context(), "flash", "Your signup was successful. Please log in.")

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
func (webApp *webApplication) userLogin(w http.ResponseWriter, r *http.Request) {
	data := webApp.newTemplateData(r)
	data.Form = userLoginForm{}
	webApp.render(w, r, http.StatusOK, "login.gohtml", data)
}

func (webApp *webApplication) userLoginPost(w http.ResponseWriter, r *http.Request) {
	var form userLoginForm

	err := webApp.decodePostForm(r, &form)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.Email), "email", "This field cannot be blank")
	form.CheckField(form.IsEmail(form.Email), "email", "This field must be a valid email address")
	form.CheckField(form.NotBlank(form.Password), "password", "This field cannot be blank")

	if !form.Valid() {
		data := webApp.newTemplateData(r)
		data.Form = form

		webApp.render(w, r, http.StatusUnprocessableEntity, "login.gohtml", data)
		return
	}

	id, err := webApp.Models.Users.Authenticate(form.Email, form.Password)
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.AddNonFieldError("Email or password is incorrect")

			data := webApp.newTemplateData(r)
			data.Form = form

			webApp.render(w, r, http.StatusUnprocessableEntity, "login.gohtml", data)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	err = webApp.sessionManager.RenewToken(r.Context())
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

	webApp.sessionManager.Put(r.Context(), "authenticatedUserID", id)

	// Use the PopString method to retrieve and remove a value from the session
	// data in one step. If no matching key exists this will return the empty
	// string.
	path := webApp.sessionManager.PopString(r.Context(), "redirectPathAfterLogin")
	if path != "" {
		http.Redirect(w, r, path, http.StatusSeeOther)
		return
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}

func (webApp *webApplication) userLogoutPost(w http.ResponseWriter, r *http.Request) {
	// Use the RenewToken() method on the current session to change the session
	// ID again.
	err := webApp.sessionManager.RenewToken(r.Context())
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

	// Remove the authenticatedUserID from the session data so that the user is
	// 'logged out'.
	webApp.sessionManager.Remove(r.Context(), "authenticatedUserID")

	// Add a flash message to the session to confirm to the user that they've been
	// logged out.
	webApp.sessionManager.Put(r.Context(), "flash", "You've been logged out successfully!")

	// Redirect the user to the application home page.
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

type accountPasswordUpdateForm struct {
	CurrentPassword         string `form:"currentPassword"`
	NewPassword             string `form:"newPassword"`
	NewPasswordConfirmation string `form:"newPasswordConfirmation"`
	validator.Validator     `form:"-"`
}

func (webApp *webApplication) accountPasswordUpdate(w http.ResponseWriter, r *http.Request) {
	data := webApp.newTemplateData(r)
	data.Form = accountPasswordUpdateForm{}

	webApp.render(w, r, http.StatusOK, "password.gohtml", data)
}

func (webApp *webApplication) accountPasswordUpdatePost(w http.ResponseWriter, r *http.Request) {
	var form accountPasswordUpdateForm

	err := webApp.decodePostForm(r, &form)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	form.CheckField(form.NotBlank(form.CurrentPassword), "currentPassword", "This field cannot be blank")
	form.CheckField(form.NotBlank(form.NewPassword), "newPassword", "This field cannot be blank")
	form.CheckField(form.MinChars(form.NewPassword, 8), "newPassword", "This field must be at least 8 characters long")
	form.CheckField(form.NotBlank(form.NewPasswordConfirmation), "newPasswordConfirmation", "This field cannot be blank")
	form.CheckField(form.NewPassword == form.NewPasswordConfirmation, "newPasswordConfirmation", "Passwords do not match")

	if !form.Valid() {
		data := webApp.newTemplateData(r)
		data.Form = form

		webApp.render(w, r, http.StatusUnprocessableEntity, "password.gohtml", data)
		return
	}
	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	err = webApp.Models.Users.PasswordUpdate(userId, form.CurrentPassword, form.NewPassword)
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.AddFieldError("currentPassword", "Current password is incorrect")

			data := webApp.newTemplateData(r)
			data.Form = form

			webApp.render(w, r, http.StatusUnprocessableEntity, "password.gohtml", data)
		} else if err != nil {
			webApp.serverError(w, r, err)
		}
		return
	}

	webApp.sessionManager.Put(r.Context(), "flash", "Your password has been updated!")

	http.Redirect(w, r, "/account/view", http.StatusSeeOther)
}

func (webApp *webApplication) userLanguageSwitch(w http.ResponseWriter, r *http.Request) {

	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	err := webApp.Models.Users.FlippedUpdate(userId)
	if err != nil {
		webApp.serverError(w, r, err)
	}

	http.Redirect(w, r, "/phrase/view", http.StatusSeeOther)
}

type accountLanguageUpdateForm struct {
	Language            string `form:"language"`
	validator.Validator `form:"-"`
}

func (webApp *webApplication) accountLanguageUpdate(w http.ResponseWriter, r *http.Request) {
	data := webApp.newTemplateData(r)
	data.Form = accountLanguageUpdateForm{}

	languages, err := webApp.Models.Languages.All()
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			webApp.notFound(w, r, err)
		} else {
			webApp.serverError(w, r, err)
		}
		return
	}

	data.Languages = languages
	webApp.render(w, r, http.StatusOK, "languageUpdate.gohtml", data)
}

func (webApp *webApplication) accountLanguageUpdatePost(w http.ResponseWriter, r *http.Request) {
	var form accountLanguageUpdateForm

	err := webApp.decodePostForm(r, &form)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")

	languageId, err := webApp.Models.Languages.GetId(form.Language)
	if err != nil {
		data := webApp.newTemplateData(r)
		data.Form = form
		webApp.render(w, r, http.StatusUnprocessableEntity, "languageUpdate.gohtml", data)
		return
	}

	err = webApp.Models.Users.LanguageUpdate(userId, languageId)
	if err != nil {
		webApp.clientError(w, r, http.StatusBadRequest, err)
		return
	}

	webApp.sessionManager.Put(r.Context(), "flash", "Your language has been updated!")

	http.Redirect(w, r, "/account/view", http.StatusSeeOther)
}
