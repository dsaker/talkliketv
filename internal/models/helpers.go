package models

import (
	"errors"
	"github.com/julienschmidt/httprouter"
	"net/http"
	"net/url"
	"strconv"
	"talkliketv.net/internal/validator"
)

func ReadIDParam(r *http.Request) (int, error) {
	params := httprouter.ParamsFromContext(r.Context())

	id, err := strconv.ParseInt(params.ByName("id"), 10, 64)
	if err != nil || id < 1 {
		return 0, errors.New("invalid id parameter")
	}

	return int(id), nil
}

// ReadString helper returns a string value from the query string, or the provided
// default value if no matching key could be found.
func ReadString(qs url.Values, key string, defaultValue string) string {
	// Extract the value for a given key from the query string. If no key exists this
	// will return the empty string "".
	s := qs.Get(key)

	// If no key exists (or the value is empty) then return the default value.
	if s == "" {
		return defaultValue
	}

	// Otherwise return the string.
	return s
}

// ReadBool helper returns a bool value from the query string, or the provided
// default value if no matching key could be found.
func ReadBool(qs url.Values, key string, defaultValue int, v *validator.Validator) int {
	// Extract the value for a given key from the query string. If no key exists this
	// will return the empty string "".
	s := qs.Get(key)

	// If no key exists (or the value is empty) then return the default value.
	if s == "" {
		return defaultValue
	} else if s == "true" {
		return 1
	} else if s == "false" {
		return 0
	} else {
		v.AddFieldError(key, "must be true or false")
		return defaultValue
	}
}

// ReadInt helper reads a string value from the query string and converts it to an
// integer before returning. If no matching key could be found it returns the provided
// default value. If the value couldn't be converted to an integer, then we record an
// error message in the provided Validator instance.
func ReadInt(qs url.Values, key string, defaultValue int, v *validator.Validator) int {
	// Extract the value from the query string.
	s := qs.Get(key)

	// If no key exists (or the value is empty) then return the default value.
	if s == "" {
		return defaultValue
	}

	// Try to convert the value to an int. If this fails, add an error message to the
	// validator instance and return the default value.
	i, err := strconv.Atoi(s)
	if err != nil {
		v.AddFieldError(key, "must be an integer value")
		return defaultValue
	}

	// Otherwise, return the converted integer value.
	return i
}
