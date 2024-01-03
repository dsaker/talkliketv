package models

import (
	"database/sql"
	"errors"
)

type LanguageModelInterface interface {
	All() ([]*Language, error)
	GetId(language string) (int, error)
}

type Language struct {
	ID       int
	Language string
}

type LanguageModel struct {
	DB *sql.DB
}

func (m *LanguageModel) GetId(language string) (int, error) {
	query := `
			SELECT id 
			FROM languages
			WHERE language = $1`

	var id int

	err := m.DB.QueryRow(query, language).Scan(&id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, ErrNoRecord
		} else {
			return 0, err
		}
	}
	return id, nil

	//stmt := "SELECT EXISTS(SELECT true FROM languages WHERE language = $1)"
	//
	//var exists bool
	//err := m.DB.QueryRow(stmt, language).Scan(&exists)
	//
	//if !exists {
	//	return -1, ErrNoRecord
	//}
}

func (m *LanguageModel) All() ([]*Language, error) {
	// Write the SQL statement we want to execute.
	stmt := `SELECT id, language FROM languages where id > 0`

	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var languages []*Language

	for rows.Next() {
		l := &Language{}

		err = rows.Scan(&l.ID, &l.Language)
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
