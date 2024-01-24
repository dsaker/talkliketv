package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/go-playground/form/v4"
	"github.com/justinas/nosurf"
	"net/http"
	"time"
)

// Define an envelope type.
type envelope map[string]interface{}

func (webApp *webApplication) render(w http.ResponseWriter, r *http.Request, status int, page string, data *templateData) {
	ts, ok := webApp.templateCache[page]
	if !ok {
		err := fmt.Errorf("the template %s does not exist", page)
		webApp.serverError(w, r, err)
		return
	}

	// Initialize a new buffer.
	buf := new(bytes.Buffer)

	// Write the template to the buffer, instead of straight to the
	// http.ResponseWriter. If there's an error, call our serverError() helper
	// and then return.
	err := ts.ExecuteTemplate(buf, "base", data)
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}

	// If the template is written to the buffer without any errors, we are safe
	// to go ahead and write the HTTP status code to http.ResponseWriter.
	w.WriteHeader(status)

	// Write the contents of the buffer to the http.ResponseWriter. Note: this
	// is another time when we pass our http.ResponseWriter to a function that
	// takes an io.Writer.
	_, err = buf.WriteTo(w)
	if err != nil {
		webApp.serverError(w, r, err)
		return
	}
}

func (webApp *webApplication) newTemplateData(r *http.Request) *templateData {
	userId := webApp.sessionManager.GetInt(r.Context(), "authenticatedUserID")
	var email string
	if userId != 0 {
		user, _ := webApp.Models.Users.Get(userId)
		email = user.Email
	} else {
		email = ""
	}

	return &templateData{
		CurrentYear:     time.Now().Year(),
		Flash:           webApp.sessionManager.PopString(r.Context(), "flash"),
		IsAuthenticated: webApp.isAuthenticated(r),
		Email:           email,
		CSRFToken:       nosurf.Token(r), // Add the CSRF token.
	}
}

// Create a new decodePostForm() helper method. The second parameter here, dst,
// is the target destination that we want to decode the form data into.
func (webApp *webApplication) decodePostForm(r *http.Request, dst any) error {
	// Call ParseForm() on the request, in the same way that we did in our
	// createSnippetPost handler.
	err := r.ParseForm()
	if err != nil {
		return err
	}

	// Call Decode() on our decoder instance, passing the target destination as
	// the first parameter.
	err = webApp.formDecoder.Decode(dst, r.PostForm)
	if err != nil {
		// If we try to use an invalid target destination, the Decode() method
		// will return an error with the type *form.InvalidDecoderError.We use
		// errors.As() to check for this and raise a panic rather than returning
		// the error.
		var invalidDecoderError *form.InvalidDecoderError

		if errors.As(err, &invalidDecoderError) {
			panic(err)
		}

		// For all other errors, we return them as normal.
		return err
	}

	return nil
}

func (webApp *webApplication) isAuthenticated(r *http.Request) bool {
	isAuthenticated, ok := r.Context().Value(isAuthenticatedContextKey).(bool)
	if !ok {
		return false
	}

	return isAuthenticated
}

// Change the data parameter to have the type envelope instead of interface{}.
func (webApp *webApplication) writeJSON(w http.ResponseWriter, status int, data envelope, headers http.Header) error {
	js, err := json.MarshalIndent(data, "", "\t")
	if err != nil {
		return err
	}

	js = append(js, '\n')

	for key, value := range headers {
		w.Header()[key] = value
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_, err = w.Write(js)
	if err != nil {
		return err
	}

	return nil
}
