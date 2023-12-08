package models

import (
	"database/sql"
	"math"
)

type PhraseModelInterface interface {
	NextTen(int, int, bool) ([]*FrontendPhrase, error)
	PhraseCorrect(int, int, int, bool) error
	PercentageDone(int, int, bool) (float64, error)
}

type Phrase struct {
	Id             int
	Phrase         string
	Translates     string
	PhraseHint     string
	TranslatesHint string
	MovieId        int
}

type FrontendPhrase struct {
	Id         int
	Phrase     string
	Translates string
	Hint       string
	MovieId    int
}

type PhraseModel struct {
	DB *sql.DB
}

func returnFlipped(flipped bool) string {
	var correct string
	if flipped {
		correct = "flipped_correct"
	} else {
		correct = "phrase_correct"
	}
	return correct
}

func (m *PhraseModel) PhraseCorrect(userId int, phraseId int, movieId int, flipped bool) error {
	correct := returnFlipped(flipped)

	args := []interface{}{userId, phraseId, movieId, correct}

	query := `
			UPDATE users_phrases 
			SET $4 = $4 + 1 
			WHERE user_id = $1 and phrase_id = $2 and movie_id = $3`
	_, err := m.DB.Exec(query, args...)
	if err != nil {
		return err
	}

	_, err = m.DB.Exec(query, args...)
	if err != nil {
		return err
	}
	return nil
}

func (m *PhraseModel) NextTen(userId int, movieId int, flipped bool) ([]*FrontendPhrase, error) {

	correct := returnFlipped(flipped)

	stmt := `
			SELECT p.id, p.phrase, p.translates, p.phrase_hint, p.translates_hint, p.movie_id
			FROM phrases p 
			INNER JOIN users_phrases up 
			ON p.id = up.phrase_id
			WHERE up.user_id = $1 and up.movie_id = $2
			ORDER BY $3, phrase_id 
			LIMIT 10`

	rows, err := m.DB.Query(stmt, userId, movieId, correct)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var frontendPhrases []*FrontendPhrase

	for rows.Next() {
		// Create a pointer to a new zeroed Phrase struct.
		p := &Phrase{}

		err = rows.Scan(&p.Id, &p.Phrase, &p.Translates, &p.PhraseHint, &p.TranslatesHint, &p.MovieId)
		if err != nil {
			return nil, err
		}

		fp := &FrontendPhrase{}
		fp.Id = p.Id
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

func (m *PhraseModel) PercentageDone(userId int, movieId int, flipped bool) (float64, error) {
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

	var sum float64
	if err := m.DB.QueryRow(query, userId, movieId).Scan(&sum); err != nil {
		return -1, err
	}

	query = `
			SELECT num_subs 
			FROM movies
			WHERE id=$1`

	var total float64
	if err := m.DB.QueryRow(query, movieId).Scan(&total); err != nil {
		return -1, err
	}
	//fmt.Println(math.Round(x*100)/100)
	x := sum / total
	//return math.Round((sum / total * 100) / 100), nil
	return math.Ceil(x*100) / 100, nil
}
