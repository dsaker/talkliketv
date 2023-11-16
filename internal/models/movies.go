package models

import (
	"database/sql"
	"errors"
)

type MovieModelInterface interface {
	Get(id int) (*Movie, error)
	All(id int) ([]*Movie, error)
	ChooseMovie(id int, i int) error
}

type Movie struct {
	ID      int
	Title   string
	NumSubs string
}

type MovieModel struct {
	DB *sql.DB
}

func (m *MovieModel) ChooseMovie(userId int, movieId int) error {
	args := []interface{}{movieId, userId}
	query := `
			UPDATE users 
			SET movie_id = $1
			WHERE id = $2`

	_, err := m.DB.Exec(query, args...)
	if err != nil {
		return err
	}

	query = `select exists(select correct from users_phrases where user_id = $2 and movie_id = $1 limit 1)`

	var exists bool
	err = m.DB.QueryRow(query, args...).Scan(&exists)

	if !exists {
		query = `select id from phrases where movie_id = $1`
		var rows *sql.Rows
		rows, err = m.DB.Query(query, movieId)
		if err != nil {
			return err
		}

		query = `insert into users_phrases (user_id, phrase_id, movie_id, correct) values ($1, $2, $3, 0)`
		defer func(rows *sql.Rows) {
			err = rows.Close()
			if err != nil {

			}
		}(rows)

		for rows.Next() {
			var pi string
			if err = rows.Scan(&pi); err != nil {
				return err
			}
			args = []interface{}{userId, pi, movieId}
			if _, err = m.DB.Exec(query, args...); err != nil {
				return err
			}
		}
		if err := rows.Err(); err != nil {
			return err
		}
	}
	return nil
}

func (m *MovieModel) Get(id int) (*Movie, error) {
	v := &Movie{}

	err := m.DB.QueryRow("SELECT id, title, num_subs FROM movies WHERE  id = $1", id).Scan(&v.ID, &v.Title, &v.NumSubs)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNoRecord
		} else {
			return nil, err
		}
	}

	return v, nil
}

func (m *MovieModel) All(languageId int) ([]*Movie, error) {
	// Write the SQL statement we want to execute.
	stmt := `SELECT id, title, num_subs FROM movies where language_id = $1 ORDER BY id DESC LIMIT 10`

	rows, err := m.DB.Query(stmt, languageId)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var movies []*Movie

	for rows.Next() {
		v := &Movie{}

		err = rows.Scan(&v.ID, &v.Title, &v.NumSubs)
		if err != nil {
			return nil, err
		}
		movies = append(movies, v)
	}

	// When the rows.Next() loop has finished we call rows.Err() to retrieve any
	// error that was encountered during the iteration. It's important to
	// call this - don't assume that a successful iteration was completed
	// over the whole resultset.
	if err = rows.Err(); err != nil {
		return nil, err
	}

	// If everything went OK then return the Snippets slice.
	return movies, nil
}
