package main

import (
	"database/sql"
	"expvar"
	"flag"
	"fmt"
	"os"
	"runtime"
	"strings"
	"sync"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
	"time"

	_ "github.com/lib/pq"
)

var (
	buildTime string
)

const version = "1.0.0"

// Include a sync.WaitGroup in the application struct. The zero-value for a
// sync.WaitGroup type is a valid, usable, sync.WaitGroup with a 'counter' value of 0,
// so we don't need to do anything else to initialize it before we can use it.
type application struct {
	config models.Config
	logger *jsonlog.Logger
	models models.Models
	wg     sync.WaitGroup
}

func main() {
	var cfg models.Config

	flag.BoolVar(&cfg.ExpVarEnabled, "expvar-enabled", true, "Enable expvar (disable for testing")
	flag.IntVar(&cfg.Port, "port", 4001, "API server port")
	flag.StringVar(&cfg.Env, "env", "development", "Environment (development|staging|production)")

	// Use the empty string "" as the default value for the db-dsn command-line flag,
	// rather than os.Getenv("GREENLIGHT_DB_DSN") like we were previously.
	flag.StringVar(&cfg.Db.Dsn, "db-dsn", "", "PostgreSQL DSN")

	flag.IntVar(&cfg.Db.MaxOpenConns, "db-max-open-conns", 25, "PostgreSQL max open connections")
	flag.IntVar(&cfg.Db.MaxIdleConns, "db-max-idle-conns", 25, "PostgreSQL max idle connections")
	flag.StringVar(&cfg.Db.MaxIdleTime, "db-max-idle-time", "15m", "PostgreSQL max connection idle time")

	flag.BoolVar(&cfg.Limiter.Enabled, "limiter-enabled", true, "Enable rate limiter")
	flag.Float64Var(&cfg.Limiter.Rps, "limiter-rps", 2, "Rate limiter maximum requests per second")
	flag.IntVar(&cfg.Limiter.Burst, "limiter-burst", 4, "Rate limiter maximum burst")

	// Read the SMTP server configuration settings into the config.go struct, using the
	// Mailtrap settings as the default values. IMPORTANT: If you're following along,
	// make sure to replace the default values for smtp-username and smtp-password
	// with your own Mailtrap credentials.
	flag.StringVar(&cfg.Smtp.Host, "smtp-host", "sandbox.smtp.mailtrap.io", "SMTP host")
	flag.IntVar(&cfg.Smtp.Port, "smtp-port", 25, "SMTP port")
	flag.StringVar(&cfg.Smtp.Username, "smtp-username", "0a20d74a5f27e0", "SMTP username")
	flag.StringVar(&cfg.Smtp.Password, "smtp-password", "4285fac8b700cc", "SMTP password")
	flag.StringVar(&cfg.Smtp.Sender, "smtp-sender", "Greenlight <no-reply@greenlight.alexedwards.net>", "SMTP sender")

	// Use the flag.Func() function to process the -cors-trusted-origins command line
	// flag. In this we use the strings.Fields() function to split the flag value into a
	// slice based on whitespace characters and assign it to our config.go struct.
	// Importantly, if the -cors-trusted-origins flag is not present, contains the empty
	// string, or contains only whitespace, then strings.Fields() will return an empty
	// []string slice.
	flag.Func("cors-trusted-origins", "Trusted CORS origins (space separated)", func(val string) error {
		cfg.Cors.TrustedOrigins = strings.Fields(val)
		return nil
	})

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

	db, err := models.OpenDB(cfg)
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

	app := &application{
		config: cfg,
		logger: logger,
		models: models.NewModels(db),
	}

	err = app.serve()
	if err != nil {
		logger.PrintFatal(err, nil)
	}
}
