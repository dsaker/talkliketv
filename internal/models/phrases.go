package models

import (
	"database/sql"
)

type PhraseModelInterface interface {
	NextTen(int, int, bool) ([]*FrontendPhrase, error)
	PhraseCorrect(int, int, int, bool) error
	PercentageDone(int, int, bool) (int, int, error)
}

type Phrase struct {
	ID             int
	Phrase         string
	Translates     string
	PhraseHint     string
	TranslatesHint string
	MovieId        int
}

type FrontendPhrase struct {
	ID         int
	Phrase     string
	Translates string
	Hint       string
	MovieId    int
}

type PhraseModel struct {
	DB *sql.DB
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

	result, err := m.DB.Exec(query, args...)
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

	rows, err := m.DB.Query(query, userId, movieId)
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
			SELECT SUM(flipped_correct) 
			FROM users_phrases
			WHERE user_id = $1 AND movie_id = $2`
	} else {
		query = `
			SELECT SUM(phrase_correct) 
			FROM users_phrases
			WHERE user_id = $1 AND movie_id = $2`
	}

	var sum int
	if err := m.DB.QueryRow(query, userId, movieId).Scan(&sum); err != nil {
		return -1, -1, err
	}

	query = `
			SELECT num_subs 
			FROM movies
			WHERE id=$1`

	var total int
	if err := m.DB.QueryRow(query, movieId).Scan(&total); err != nil {
		return -1, -1, err
	}

	return sum, total, nil
}
