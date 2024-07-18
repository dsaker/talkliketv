package main

import (
	"database/sql"
	"expvar"
	"flag"
	"fmt"
	_ "github.com/lib/pq"
	"os"
	"runtime"
	"talkliketv.net/internal/application"
	"talkliketv.net/internal/config"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/mailer"
	"talkliketv.net/internal/models"
	"time"
)

var (
	buildTime string
)

const version = "1.0.0"

// Include a sync.WaitGroup in the api struct. The zero-value for a
// sync.WaitGroup type is a valid, usable, sync.WaitGroup with a 'counter' value of 0,
// so we don't need to do anything else to initialize it before we can use it.
type api struct {
	application.Application
}

func main() {
	var cfg config.Config

	cfg.SetConfigs()

	// Create a new version boolean flag with the default value of false.
	displayVersion := flag.Bool("version", false, "Display version and exit")
	flag.IntVar(&cfg.Port, "port", 4001, "API server port")
	flag.Parse()

	if *displayVersion {
		fmt.Printf("Version:\t%s\n", version)
		// Print out the contents of the buildTime variable.
		fmt.Printf("Build time:\t%s\n", buildTime)
		os.Exit(0)
	}

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

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

	if cfg.ExpVarEnabled {
		// Publish a new "version" variable in the expvar handler containing our application
		// version number (currently the constant "1.0.0").
		expvar.NewString("version").Set(version)

		// Publish the number of active goroutines
		expvar.Publish("goroutines", expvar.Func(func() interface{} {
			return runtime.NumGoroutine()
		}))

		// Publish the database connection pool statistics.
		expvar.Publish("database", expvar.Func(func() interface{} {
			return db.Stats()
		}))

		// Publish the current Unix timestamp.
		expvar.Publish("timestamp", expvar.Func(func() interface{} {
			return time.Now().Unix()
		}))
	}

	app := &api{
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
