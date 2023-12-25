package application

import (
	"github.com/alexedwards/scs/v2"
	"github.com/go-playground/form/v4"
	"html/template"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
)

type Config struct {
	Port int
	Env  string
	Db   struct {
		Dsn          string
		MaxOpenConns int
		MaxIdleConns int
		MaxIdleTime  string
	}
}

type Application struct {
	Config         Config
	Logger         *jsonlog.Logger
	Phrases        models.PhraseModelInterface
	Movies         models.MovieModelInterface
	Languages      models.LanguageModelInterface
	Users          models.UserModelInterface
	TemplateCache  map[string]*template.Template
	FormDecoder    *form.Decoder
	SessionManager *scs.SessionManager
	Debug          bool
}

var (
	BuildTime string
	Version   string
)
