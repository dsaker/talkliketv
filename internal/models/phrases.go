package models

import (
	"database/sql"
	"math"
)

type PhraseModelInterface interface {
	NextTen(id int, id2 int) ([]*Phrase, error)
	PhraseCorrect(id int, id2 int, id3 int) error
	PercentageDone(id int, id2 int) (float64, error)
}

type Phrase struct {
	ID         int
	Phrase     string
	Translates string
	Hint       string
	MovieId    int
}

type PhraseModel struct {
	DB *sql.DB
}

func (m *PhraseModel) PhraseCorrect(userID int, phraseId int, movieId int) error {
	args := []interface{}{userID, phraseId, movieId}

	query := `
			UPDATE users_phrases 
			SET correct = correct + 1 
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

func (m *PhraseModel) NextTen(userId int, movieId int) ([]*Phrase, error) {

	stmt := `
			SELECT p.id, p.phrase, p.translates, p.hint, p.movie_id 
			FROM phrases p 
			INNER JOIN users_phrases up 
			ON p.id = up.phrase_id
			WHERE up.user_id = $1 and up.movie_id = $2
			ORDER BY up.correct, up.phrase_id 
			LIMIT 10`

	rows, err := m.DB.Query(stmt, userId, movieId)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	var phrases []*Phrase

	for rows.Next() {
		// Create a pointer to a new zeroed Phrase struct.
		p := &Phrase{}

		err = rows.Scan(&p.ID, &p.Phrase, &p.Translates, &p.Hint, &p.MovieId)
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

func (m *PhraseModel) PercentageDone(userId int, movieId int) (float64, error) {

	query := `
			SELECT SUM(correct) 
			FROM users_phrases
			WHERE user_id = $1 AND movie_id = $2`

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
