package main

import (
	"database/sql"
	"flag"
	"fmt"
	"github.com/alexedwards/scs/v2"
	"github.com/go-playground/form/v4"
	"html/template"
	"os"
	"talkliketv.net/internal/application"
	"talkliketv.net/internal/config"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/mailer"
	"talkliketv.net/internal/models"
	"time"

	_ "github.com/lib/pq"
)

var (
	buildTime string
	version   string
)

type web struct {
	templateCache  map[string]*template.Template
	formDecoder    *form.Decoder
	sessionManager *scs.SessionManager
	debug          bool
	application.Application
}

func main() {

	var cfg config.Config

	cfg.SetConfigs()

	// get port and debug from commandline flags... if not present use defaults
	flag.IntVar(&cfg.Port, "port", 4000, "API server port")
	debug := flag.Bool("debug", false, "Enable debug mode")

	// Create a new version boolean flag with the default value of false.
	displayVersion := flag.Bool("version", false, "Display version and exit")

	flag.Parse()

	if *displayVersion {
		fmt.Printf("Version:\t%s\n", version)
		// Print out the contents of the buildTime variable.
		fmt.Printf("Build time:\t%s\n", buildTime)
		os.Exit(0)
	}

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	// open db connection. if err fail immediately
	db, err := cfg.OpenDB()
	if err != nil {
		logger.PrintFatal(err, nil)
	}
	defer func(db *sql.DB) {
		err = db.Close()
		if err != nil {
			logger.PrintFatal(err, nil)
		}
	}(db)

	logger.PrintInfo("database connection pool established", nil)

	templateCache, err := newTemplateCache()
	if err != nil {
		logger.PrintFatal(err, nil)
	}

	// create form decoder to parse forms sent from UI
	formDecoder := form.NewDecoder()

	sessionManager := scs.New()
	sessionManager.Lifetime = 12 * time.Hour
	// Make sure that the Secure attribute is set on our session cookies.
	// Setting this means that the cookie will only be sent by a user's web
	// browser when an HTTPS connection is being used (and won't be sent over an
	//// unsecure HTTP connection).
	sessionManager.Cookie.Secure = true

	app := &web{
		templateCache,
		formDecoder,
		sessionManager,
		*debug,
		application.Application{
			Config: cfg,
			Logger: logger,
			Models: models.NewModels(db, cfg.CtxTimeout),
			Mailer: mailer.New(cfg.Smtp.Host, cfg.Smtp.Port, cfg.Smtp.Username, cfg.Smtp.Password, cfg.Smtp.Sender),
		},
	}

	err = app.Serve(app.routes())
	if err != nil {
		logger.PrintFatal(err, nil)
	}

}
