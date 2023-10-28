package models

import (
	"database/sql"
	"errors"
)

type PhraseModelInterface interface {
	Insert(phrase string, translates string) (int, error)
	Get(id int) (*Phrase, error)
	NextTen() ([]*Phrase, error)
}

type Phrase struct {
	ID         int
	Phrase     string
	Translates string
}

type PhraseModel struct {
	DB *sql.DB
}

func (m *PhraseModel) Insert(phrase string, translates string) (int, error) {

	stmt := `INSERT INTO phrases (phrase, translates, correct)
    VALUES(?, ?, ?)`

	result, err := m.DB.Exec(stmt, phrase, translates, 0)
	if err != nil {
		return 0, err
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, err
	}

	return int(id), nil
}

func (m *PhraseModel) Get(id int) (*Phrase, error) {
	s := &Phrase{}

	err := m.DB.QueryRow("SELECT id, phrase, translates FROM phrases WHERE id = ?", id).Scan(&s.ID)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNoRecord
		} else {
			return nil, err
		}
	}

	return s, nil
}

func (m *PhraseModel) NextTen() ([]*Phrase, error) {
	// Write the SQL statement we want to execute.
	stmt := `SELECT id, phrase, translates FROM phrases 
                                            WHERE ORDER BY correct ASC LIMIT 10`

	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var phrases []*Phrase

	for rows.Next() {
		// Create a pointer to a new zeroed Phrase struct.
		p := &Phrase{}

		err = rows.Scan(&p.ID, &p.Phrase, &p.Translates)
		if err != nil {
			return nil, err
		}
		// Append it to the slice of phrases.
		phrases = append(phrases, p)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return phrases, nil
}
