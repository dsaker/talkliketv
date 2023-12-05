package mocks

import "talkliketv.net/internal/models"

var mockLanguage1 = &models.Language{
	ID:       1,
	Language: "Spanish",
}

var mockLanguage2 = &models.Language{
	ID:       2,
	Language: "French",
}

type LanguageModel struct{}

func (m *LanguageModel) All() ([]*models.Language, error) {
	return []*models.Language{mockLanguage1, mockLanguage2}, nil
}

func (m *LanguageModel) GetId(language string) (int, error) {
	switch language {
	case "Spanish":
		return 1, nil
	default:
		return -1, models.ErrNoRecord
	}
}
