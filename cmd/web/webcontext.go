package main

type contextKey string

const isAuthenticatedContextKey = contextKey("isAuthenticated")

// key that is used to store userId in sessionmanager context
const authenticatedUserId = "authenticatedUserID"
