package mocks

import (
	"talkliketv.net/internal/models"
)

var mockPhrase = &models.Phrase{
	ID:         1,
	MovieId:    1,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
}

type PhraseModel struct{}

func (m *PhraseModel) Insert(phrase string, translates string, correct int) (int, error) {
	return 2, nil
}

func (m *PhraseModel) NextTen() ([]*models.Phrase, error) {
	return []*models.Phrase{mockPhrase}, nil
}

func (m *PhraseModel) PhraseCorrect(id int, id2 int) error {
	return nil
}

func (m *PhraseModel) PercentageDone(userId int, movieId int) (float32, error) {
	switch userId {
	case 1:
		return 1.1, nil
	default:
		return -1.0, models.ErrNoRecord
	}
}
