package main

import (
	"errors"
	"expvar"
	"fmt"
	"github.com/felixge/httpsnoop"
	"net/http"
	"strconv"
	"strings"
	"talkliketv.net/internal/models"
	"talkliketv.net/internal/validator"
)

func (app *apiApplication) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Create a deferred function (which will always be run in the event of a panic
		// as Go unwinds the stack).
		defer func() {
			// Use the builtin recover function to check if there has been a panic or
			// not.
			if err := recover(); err != nil {
				// If there was a panic, set a "Connection: close" header on the
				// response. This acts as a trigger to make Go's HTTP server
				// automatically close the current connection after a response has been
				// sent.
				w.Header().Set("Connection", "close")
				// The value returned by recover() has the type interface{}, so we use
				// fmt.Errorf() to normalize it into an error and call our
				// serverErrorResponse() helper. In turn, this will log the error using
				// our custom Logger type at the ERROR level and send the client a 500
				// Internal Server Error response.
				app.serverErrorResponse(w, r, fmt.Errorf("%s", err))
			}
		}()

		next.ServeHTTP(w, r)
	})
}

func (app *apiApplication) logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.Logger.PrintInfo(fmt.Sprintf("%s - %s %s %s", r.RemoteAddr, r.Proto, r.Method, r.URL.RequestURI()), nil)

		next.ServeHTTP(w, r)
	})
}

// Create a new requireAuthenticatedUser() middleware to check that a user is not
// anonymous.
func (app *apiApplication) requireAuthenticatedUser(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user := app.contextGetUser(r)

		if user.IsAnonymous() {
			app.authenticationRequiredResponse(w, r)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func (app *apiApplication) authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Add the "Vary: Authorization" header to the response. This indicates to any
		// caches that the response may vary based on the value of the Authorization
		// header in the request.
		w.Header().Add("Vary", "Authorization")

		// Retrieve the value of the Authorization header from the request. This will
		// return the empty string "" if there is no such header found.
		authorizationHeader := r.Header.Get("Authorization")

		// If there is no Authorization header found, use the contextSetUser() helper
		// that we just made to add the AnonymousUser to the request context. Then we
		// call the next handler in the chain and return without executing any of the
		// code below.
		if authorizationHeader == "" {
			r = app.contextSetUser(r, models.AnonymousUser)
			next.ServeHTTP(w, r)
			return
		}

		// Otherwise, we expect the value of the Authorization header to be in the format
		// "Bearer <token>". We try to split this into its constituent parts, and if the
		// header isn't in the expected format we return a 401 Unauthorized response
		// using the invalidAuthenticationTokenResponse() helper (which we will create
		// in a moment).
		headerParts := strings.Split(authorizationHeader, " ")
		if len(headerParts) != 2 || headerParts[0] != "Bearer" {
			app.invalidAuthenticationTokenResponse(w, r)
			return
		}

		// Extract the actual authentication token from the header parts.
		token := headerParts[1]

		// Validate the token to make sure it is in a sensible format.
		v := validator.New()

		// If the token isn't valid, use the invalidAuthenticationTokenResponse()
		// helper to send a response, rather than the failedValidationResponse() helper
		// that we'd normally use.
		if models.ValidateTokenPlaintext(v, token); !v.Valid() {
			app.invalidAuthenticationTokenResponse(w, r)
			return
		}

		// Retrieve the details of the user associated with the authentication token,
		// again calling the invalidAuthenticationTokenResponse() helper if no
		// matching record was found. IMPORTANT: Notice that we are using
		// ScopeAuthentication as the first parameter here.
		user, err := app.Models.Users.GetForToken(models.ScopeAuthentication, token)
		if err != nil {
			switch {
			case errors.Is(err, models.ErrNoRecord):
				app.invalidAuthenticationTokenResponse(w, r)
			default:
				app.serverErrorResponse(w, r, err)
			}
			return
		}

		// Call the contextSetUser() helper to add the user information to the request
		// context.
		r = app.contextSetUser(r, user)

		// Call the next handler in the chain.
		next.ServeHTTP(w, r)
	})
}

func (app *apiApplication) enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Vary", "Origin")

		// Add the "Vary: Access-Control-Request-Method" header.
		w.Header().Add("Vary", "Access-Control-Request-Method")

		origin := r.Header.Get("Origin")

		if origin != "" && len(app.Config.Cors.TrustedOrigins) != 0 {
			for i := range app.Config.Cors.TrustedOrigins {
				if origin == app.Config.Cors.TrustedOrigins[i] {
					w.Header().Set("Access-Control-Allow-Origin", origin)

					// Check if the request has the HTTP method OPTIONS and contains the
					// "Access-Control-Request-Method" header. If it does, then we treat
					// it as a preflight request.
					if r.Method == http.MethodOptions && r.Header.Get("Access-Control-Request-Method") != "" {
						// Set the necessary preflight response headers, as discussed
						// previously.
						w.Header().Set("Access-Control-Allow-Methods", "OPTIONS, PUT, PATCH, DELETE")
						w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type")

						// Write the headers along with a 200 OK status and return from
						// the config with no further action.
						w.WriteHeader(http.StatusOK)
						return
					}
				}
			}
		}
		next.ServeHTTP(w, r)
	})
}

func (app *apiApplication) metrics(next http.Handler) http.Handler {
	totalRequestsReceived := expvar.NewInt("total_requests_received")
	totalResponsesSent := expvar.NewInt("total_responses_sent")
	totalProcessingTimeMicroseconds := expvar.NewInt("total_processing_time_μs")
	// Declare a new expvar map to hold the count of responses for each HTTP status
	// code.
	totalResponsesSentByStatus := expvar.NewMap("total_responses_sent_by_status")

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Increment the requests received count, like before.
		totalRequestsReceived.Add(1)

		// Call the httpsnoop.CaptureMetrics() function, passing in the next handler in
		// the chain along with the existing http.ResponseWriter and http.Request. This
		// returns the metrics struct that we saw above.
		metrics := httpsnoop.CaptureMetrics(next, w, r)

		// Increment the response sent count, like before.
		totalResponsesSent.Add(1)

		// Get the request processing time in microseconds from httpsnoop and increment
		// the cumulative processing time.
		totalProcessingTimeMicroseconds.Add(metrics.Duration.Microseconds())

		// Use the Add() method to increment the count for the given status code by 1.
		// Note that the expvar map is string-keyed, so we need to use the strconv.Itoa()
		// function to convert the status code (which is an integer) to a string.
		totalResponsesSentByStatus.Add(strconv.Itoa(metrics.Code), 1)
	})
}
