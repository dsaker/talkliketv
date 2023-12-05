package mocks

import "talkliketv.net/internal/models"

var mockMovie1 = &models.Movie{
	ID:      1,
	Title:   "Movie1",
	NumSubs: "320",
}

var mockMovie2 = &models.Movie{
	ID:      2,
	Title:   "Movie2",
	NumSubs: "320",
}

type MovieModel struct{}

func (m *MovieModel) Get(id int) (*models.Movie, error) {
	switch id {
	case 1:
		return mockMovie1, nil
	default:
		return nil, models.ErrNoRecord
	}
}
func (m *MovieModel) All(id int) ([]*models.Movie, error) {
	switch id {
	case 1:
		return []*models.Movie{mockMovie1, mockMovie2}, nil
	default:
		return nil, models.ErrNoRecord
	}
}
func (m *MovieModel) ChooseMovie(id int, i int) error {
	return nil
}
