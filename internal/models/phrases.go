package models

import (
	"database/sql"
)

type PhraseModelInterface interface {
	NextTen(id int, id2 int) ([]*Phrase, error)
	PhraseCorrect(id int, id2 int, id3 int) error
}

type Phrase struct {
	ID         int
	Phrase     string
	Translates string
	Hint       string
	MovieId    string
}

type PhraseModel struct {
	DB *sql.DB
}

func (m *PhraseModel) PhraseCorrect(userID int, phraseId int, movieId int) error {
	args := []interface{}{userID, phraseId, movieId}

	//var exists bool
	//
	//query := "SELECT EXISTS(SELECT true FROM users_phrases WHERE user_id = $1 and phrase_id = $2 and movie_id = $3)"
	//
	//ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	//defer cancel()
	//err := m.DB.QueryRowContext(ctx, query, args...).Scan(&exists)

	query := `
			UPDATE users_phrases 
			SET correct = correct + 1 
			WHERE user_id = $1 and phrase_id = $2 and movie_id = $3`
	_, err := m.DB.Exec(query, args...)
	if err != nil {
		return err
	}

	//var query string
	//if exists {
	//	query = `
	//		UPDATE users_phrases
	//		SET correct = correct + 1
	//		WHERE user_id = $1 and phrase_id = $2 and movie_id = $3`
	//} else {
	//	query = `
	//	INSERT INTO users_phrases
	//	VALUES  ($1, $2, $3, 1)`
	//}

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
