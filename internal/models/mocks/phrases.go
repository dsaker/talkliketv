package mocks

import (
	"talkliketv.net/internal/models"
)

var mockPhrase = &models.Phrase{
	ID:         1,
	Phrase:     "An old silent pond",
	Translates: "An old silent pond...",
}

type PhraseModel struct{}

func (m *PhraseModel) Insert(phrase string, translates string, correct int) (int, error) {
	return 2, nil
}

func (m *PhraseModel) Get(id int) (*models.Phrase, error) {
	switch id {
	case 1:
		return mockPhrase, nil
	default:
		return nil, models.ErrNoRecord
	}
}

func (m *PhraseModel) NextTen() ([]*models.Phrase, error) {
	return []*models.Phrase{mockPhrase}, nil
}
