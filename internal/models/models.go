package models

import (
	"database/sql"
	"errors"
)

var (
	ErrNoRecord = errors.New("models: no matching record found")

	ErrInvalidCredentials = errors.New("models: invalid credentials")

	ErrDuplicateEmail = errors.New("models: duplicate email")

	ErrDuplicateUserName = errors.New("models: duplicate name")

	ErrEditConflict = errors.New("edit conflict")
)

type Models struct {
	Movies    MovieModel
	Languages LanguageModel
	Phrases   PhraseModel
	Users     UserModel
	Tokens    TokenModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		Movies:    MovieModel{DB: db},
		Phrases:   PhraseModel{DB: db},
		Languages: LanguageModel{DB: db},
		Users:     UserModel{DB: db},
		Tokens:    TokenModel{DB: db},
	}
}
