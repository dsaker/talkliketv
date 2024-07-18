package models

import (
	"database/sql"
	"errors"
	"time"
)

var (
	ErrNoRecord = errors.New("models: no matching record found")

	ErrInvalidCredentials = errors.New("models: invalid credentials")

	ErrDuplicateEmail = errors.New("models: duplicate email")

	ErrDuplicateUserName = errors.New("models: duplicate name")

	ErrEditConflict = errors.New("edit conflict")

	ErrDuplicateTitle = errors.New("models: duplicate title")
)

type Models struct {
	Movies    MovieModel
	Languages LanguageModel
	Phrases   PhraseModel
	Users     UserModel
	Tokens    TokenModel
}

func NewModels(db *sql.DB, ctxTimeout time.Duration) Models {
	return Models{
		Movies:    MovieModel{DB: db, CtxTimeout: ctxTimeout},
		Phrases:   PhraseModel{DB: db, CtxTimeout: ctxTimeout},
		Languages: LanguageModel{DB: db, CtxTimeout: ctxTimeout},
		Users:     UserModel{DB: db, CtxTimeout: ctxTimeout},
		Tokens:    TokenModel{DB: db, CtxTimeout: ctxTimeout},
	}
}
