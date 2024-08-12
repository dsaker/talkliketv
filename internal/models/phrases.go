package models

import (
	"context"
	"database/sql"
	"time"
)

type Phrase struct {
	ID             int    `json:"id"`
	Phrase         string `json:"phrase"`
	Translates     string `json:"translates"`
	PhraseHint     string `json:"phrase_hint"`
	TranslatesHint string `json:"translates_hint"`
	MovieId        int    `json:"movie_id"`
}

type FrontendPhrase struct {
	ID         int    `json:"id"`
	Phrase     string `json:"phrase"`
	Translates string `json:"translates"`
	Hint       string `json:"hint"`
	MovieId    int    `json:"movie_id"`
}

type PhraseModel struct {
	DB         *sql.DB
	CtxTimeout time.Duration
}

func (m *PhraseModel) PhraseCorrect(userId int, phraseId int, movieId int, flipped bool) error {

	args := []interface{}{userId, phraseId, movieId}

	var query string
	if flipped {
		query = `
			UPDATE users_phrases 
			SET flipped_correct = flipped_correct + 1 
			WHERE user_id = $1 and phrase_id = $2 and movie_id = $3`
	} else {
		query = `
			UPDATE users_phrases 
			SET phrase_correct = phrase_correct + 1 
			WHERE user_id = $1 and phrase_id = $2 and movie_id = $3`
	}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	result, err := m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrNoRecord
	}

	return nil
}

func (m *PhraseModel) NextTen(userId int, movieId int, flipped bool) ([]*FrontendPhrase, error) {

	var query string
	if flipped {
		query = `
			SELECT p.id, p.phrase, p.translates, p.phrase_hint, p.translates_hint, p.movie_id
			FROM phrases p 
			INNER JOIN users_phrases up 
			ON p.id = up.phrase_id
			WHERE up.user_id = $1 and up.movie_id = $2
			ORDER BY flipped_correct, phrase_id 
			LIMIT 10`
	} else {
		query = `
			SELECT p.id, p.phrase, p.translates, p.phrase_hint, p.translates_hint, p.movie_id
			FROM phrases p 
			INNER JOIN users_phrases up 
			ON p.id = up.phrase_id
			WHERE up.user_id = $1 and up.movie_id = $2
			ORDER BY phrase_correct, phrase_id 
			LIMIT 10`
	}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, userId, movieId)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var frontendPhrases []*FrontendPhrase

	for rows.Next() {
		// Create a pointer to a new zeroed Phrase struct.
		p := &Phrase{}

		err = rows.Scan(&p.ID, &p.Phrase, &p.Translates, &p.PhraseHint, &p.TranslatesHint, &p.MovieId)
		if err != nil {
			return nil, err
		}

		fp := &FrontendPhrase{}
		fp.ID = p.ID
		fp.MovieId = p.MovieId

		if flipped {
			fp.Phrase = p.Translates
			fp.Translates = p.Phrase
			fp.Hint = p.PhraseHint
		} else {
			fp.Phrase = p.Phrase
			fp.Translates = p.Translates
			fp.Hint = p.TranslatesHint
		}
		frontendPhrases = append(frontendPhrases, fp)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return frontendPhrases, nil
}

func (m *PhraseModel) PercentageDone(userId int, movieId int, flipped bool) (int, int, error) {
	var query string
	if flipped {
		query = `
			SELECT SUM(flipped_correct), count(phrase_id) as total
			FROM users_phrases
			WHERE user_id = $1 AND movie_id = $2`
	} else {
		query = `
			SELECT SUM(phrase_correct), count(phrase_id) as total 
			FROM users_phrases
			WHERE user_id = $1 AND movie_id = $2`
	}

	var sum int
	var total int
	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()
	if err := m.DB.QueryRowContext(ctx, query, userId, movieId).Scan(&sum, &total); err != nil {
		return -1, -1, err
	}

	//query = `
	//		SELECT num_subs
	//		FROM movies
	//		WHERE id=$1`

	//var total int
	//if err := m.DB.QueryRowContext(ctx, query, movieId).Scan(&total); err != nil {
	//	return -1, -1, err
	//}

	return sum, total, nil
}

func (m *PhraseModel) Insert(phrase *Phrase) error {

	query := `
        INSERT INTO phrases (movie_id, phrase, translates, phrase_hint, translates_hint) 
        VALUES ($1, $2, $3, $4, $5)`

	args := []interface{}{phrase.MovieId, phrase.Phrase, phrase.Translates, phrase.PhraseHint, phrase.TranslatesHint}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	_, err := m.DB.ExecContext(ctx, query, args...)

	if err != nil {
		return err
	}

	return nil
}
