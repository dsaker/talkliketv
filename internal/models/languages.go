package models

import (
	"context"
	"database/sql"
	"errors"
	"talkliketv.net/internal/validator"
	"time"
)

type Language struct {
	ID       int    `json:"id"`
	Tag      string `json:"tag"`
	Language string `json:"language"`
}

type LanguageModel struct {
	DB         *sql.DB
	CtxTimeout time.Duration
}

func ValidateLanguage(v *validator.Validator, language string) {
	v.CheckField(v.NotBlank(language), "language", "This field cannot be blank")
}

func (m *LanguageModel) GetId(language string) (int, error) {
	query := `
			SELECT id 
			FROM languages
			WHERE language = $1`

	var id int

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, language).Scan(&id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, ErrNoRecord
		} else {
			return 0, err
		}
	}
	return id, nil
}

func (m *LanguageModel) All(inUse bool) ([]*Language, error) {

	var query string
	if inUse {
		query = `SELECT id, language, tag FROM languages where id in ( 
			SELECT DISTINCT language_id FROM movies where language_id > 0)`
	} else {
		query = `SELECT id, language, tag FROM languages where id > 0`
	}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var languages []*Language

	for rows.Next() {
		l := &Language{}

		err = rows.Scan(&l.ID, &l.Language, &l.Tag)
		if err != nil {
			return nil, err
		}
		languages = append(languages, l)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return languages, nil
}
