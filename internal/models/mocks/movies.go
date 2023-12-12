package mocks

import "talkliketv.net/internal/models"

var mockMovie1 = &models.Movie{
	ID:      1,
	Title:   "NothingToSeeHereS01E01",
	NumSubs: "320",
	Mp3:     true,
}

var mockMovie2 = &models.Movie{
	ID:      2,
	Title:   "Movie2",
	NumSubs: "320",
	Mp3:     false,
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
	switch i {
	case 1:
		return nil
	default:
		return models.ErrNoRecord
	}
}
