package models

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"
)

type Movie struct {
	ID         int    `json:"id"`
	Title      string `json:"title"`
	NumSubs    int    `json:"num_subs"`
	LanguageId int    `json:"language_id"`
	Mp3        bool   `json:"mp3"`
}

type MovieModel struct {
	DB         *sql.DB
	CtxTimeout time.Duration
}

func (m *MovieModel) UpdateMovie(userId int, movieId int) error {
	args := []interface{}{movieId, userId}
	_, err := m.Get(movieId)
	if err != nil {
		return err
	}
	query := `
			UPDATE users 
			SET movie_id = $1
			WHERE id = $2`

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	_, err = m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}

	query = `select exists(select phrase_correct from users_phrases where user_id = $2 and movie_id = $1)`

	var exists bool
	err = m.DB.QueryRowContext(ctx, query, args...).Scan(&exists)
	if err != nil {
		return err
	}
	if !exists {
		query = `select id from phrases where movie_id = $1`
		var rows *sql.Rows
		rows, err = m.DB.QueryContext(ctx, query, movieId)
		if err != nil {
			return err
		}

		query = `insert into users_phrases (user_id, phrase_id, movie_id, phrase_correct, flipped_correct) values ($1, $2, $3, 0, 0)`
		defer rows.Close()

		for rows.Next() {
			var pi string
			if err = rows.Scan(&pi); err != nil {
				return err
			}
			args = []interface{}{userId, pi, movieId}
			if _, err = m.DB.ExecContext(ctx, query, args...); err != nil {
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

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, "SELECT id, title, num_subs FROM movies WHERE  id = $1", id).Scan(&v.ID, &v.Title, &v.NumSubs)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNoRecord
		} else {
			return nil, err
		}
	}

	return v, nil
}

func (m *MovieModel) Delete(id int) error {
	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	_, err := m.DB.ExecContext(ctx, "DELETE FROM movies WHERE  id = $1", id)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNoRecord
		} else {
			return err
		}
	}

	return nil
}

func (m *MovieModel) Insert(movie *Movie) (int, error) {
	query := `
        INSERT INTO movies (title, num_subs, language_id) 
        VALUES ($1, $2, $3)
        RETURNING id, title, num_subs, language_id`

	args := []interface{}{movie.Title, movie.NumSubs, movie.LanguageId}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(
		&movie.ID,
		&movie.Title,
		&movie.NumSubs,
		&movie.LanguageId)

	if err != nil {
		switch {
		case err.Error() == `pq: duplicate key value violates unique constraint "movies_title_key"`:
			return movie.ID, ErrDuplicateTitle
		default:
			println(fmt.Sprintf("error: %s", err.Error()))
			return movie.ID, err
		}
	}

	return movie.ID, nil
}

func (m *MovieModel) All(languageId int, title string, filters Filters, mp3 int) ([]*Movie, Metadata, error) {
	stmt := `SELECT count(*) OVER(), id, title, similarity(title, $1) AS similarity, num_subs, mp3
		   FROM movies
		   WHERE language_id = $2`

	if mp3 != -1 {
		stmt += "AND mp3 = $5"
	}

	if title != "" {
		stmt += `
		   ORDER BY similarity DESC, id
		   LIMIT $3 OFFSET $4`
	} else {
		stmt += fmt.Sprintf(`
			ORDER BY %s %s, id, $1
			LIMIT $3 OFFSET $4`, filters.sortColumn(), filters.sortDirection())
	}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	args := []interface{}{title, languageId, filters.limit(), filters.offset()}

	if mp3 != -1 {
		args = append(args, mp3)
	}

	rows, err := m.DB.QueryContext(ctx, stmt, args...)
	if err != nil {
		return nil, Metadata{}, err
	}

	defer rows.Close()

	totalRecords := 0
	var movies []*Movie
	var similarity float64

	for rows.Next() {
		v := &Movie{}
		err = rows.Scan(&totalRecords, &v.ID, &v.Title, &similarity, &v.NumSubs, &v.Mp3)

		if err != nil {
			return nil, Metadata{}, err
		}
		movies = append(movies, v)
	}

	// When the rows.Next() loop has finished we call rows.Err() to retrieve any
	// error that was encountered during the iteration. It's important to
	// call this - don't assume that a successful iteration was completed
	// over the whole result set.
	if err = rows.Err(); err != nil {
		return nil, Metadata{}, err
	}

	// Generate a Metadata struct, passing in the total record count and pagination
	// parameters from the client.
	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)
	// If everything went OK then return the Snippets slice.
	return movies, metadata, nil
}
