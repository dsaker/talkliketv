package models

import (
	"database/sql"
)

type PhraseModelInterface interface {
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

func (m *PhraseModel) NextTen() ([]*Phrase, error) {
	//fmt.Printf("getting next ten phrases for id: %d", id)

	// Write the SQL statement we want to execute.
	stmt := `SELECT id, phrase, translates FROM phrases order by id LIMIT 10`

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

	print("phrases: ")
	println(phrases)
	if err = rows.Err(); err != nil {
		return nil, err
	}

	return phrases, nil
}
