package mocks

import "talkliketv.net/internal/models"

var mockPhrase1 = &models.FrontendPhrase{
	ID:         1,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase2 = &models.FrontendPhrase{
	ID:         2,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase3 = &models.FrontendPhrase{
	ID:         3,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase4 = &models.FrontendPhrase{
	ID:         4,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase5 = &models.FrontendPhrase{
	ID:         5,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase6 = &models.FrontendPhrase{
	ID:         6,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase7 = &models.FrontendPhrase{
	ID:         7,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase8 = &models.FrontendPhrase{
	ID:         8,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase9 = &models.FrontendPhrase{
	ID:         9,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

var mockPhrase10 = &models.FrontendPhrase{
	ID:         10,
	Phrase:     "You can do it. Keep going. Breathe.",
	Translates: "Tú puedes. Sigue, sigue, sigue. Respira.",
	Hint:       "T  p     . S    , s    , s    . R      .",
	MovieId:    1,
}

type PhraseModel struct{}

func (m *PhraseModel) NextTen(id int, id2 int, flipped bool) ([]*models.FrontendPhrase, error) {
	switch id {
	case 1:
		return []*models.FrontendPhrase{
			mockPhrase1,
			mockPhrase2,
			mockPhrase3,
			mockPhrase4,
			mockPhrase5,
			mockPhrase6,
			mockPhrase7,
			mockPhrase8,
			mockPhrase9,
			mockPhrase10,
		}, nil
	default:
		return nil, models.ErrNoRecord
	}
}

func (m *PhraseModel) PhraseCorrect(id int, id2 int, id3 int, flipped bool) error {
	return nil
}

func (m *PhraseModel) PercentageDone(id int, id2 int, flipped bool) (int, int, error) {
	return -1, -1, nil
}
