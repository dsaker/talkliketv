package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"github.com/alexedwards/scs/v2"
	"github.com/go-playground/form/v4"
	"net/http"
	"os"
	"talkliketv.net/cmd/web/application"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
	"time"

	_ "github.com/lib/pq"
)

func main() {

	var cfg application.Config

	flag.IntVar(&cfg.Port, "port", 4000, "API server port")
	flag.StringVar(&cfg.Env, "env", "development", "Environment (development|staging|production)")

	addr := flag.String("addr", ":4000", "HTTP network address")
	debug := flag.Bool("debug", false, "Enable debug mode")

	// Use the empty string "" as the default value for the db-dsn command-line flag,
	// rather than os.Getenv("TALKTV_DB_DSN") like we were previously.
	flag.StringVar(&cfg.Db.Dsn, "db-dsn", "", "PostgreSQL DSN")

	flag.IntVar(&cfg.Db.MaxOpenConns, "db-max-open-conns", 25, "PostgreSQL max open connections")
	flag.IntVar(&cfg.Db.MaxIdleConns, "db-max-idle-conns", 25, "PostgreSQL max idle connections")
	flag.StringVar(&cfg.Db.MaxIdleTime, "db-max-idle-time", "15m", "PostgreSQL max connection idle time")

	// Create a new version boolean flag with the default value of false.
	displayVersion := flag.Bool("version", false, "Display version and exit")

	flag.Parse()

	if *displayVersion {
		fmt.Printf("Version:\t%s\n", application.Version)
		// Print out the contents of the buildTime variable.
		fmt.Printf("Build time:\t%s\n", application.BuildTime)
		os.Exit(0)
	}

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	db, err := openDB(cfg)
	if err != nil {
		logger.PrintFatal(err, nil)
	}
	defer db.Close()

	logger.PrintInfo("database connection pool established", nil)

	templateCache, err := application.NewTemplateCache()
	if err != nil {
		logger.PrintFatal(err, nil)
	}

	formDecoder := form.NewDecoder()

	sessionManager := scs.New()
	sessionManager.Lifetime = 12 * time.Hour
	// Make sure that the Secure attribute is set on our session cookies.
	// Setting this means that the cookie will only be sent by a user's web
	// browser when an HTTPS connection is being used (and won't be sent over an
	//// unsecure HTTP connection).
	sessionManager.Cookie.Secure = true

	// Initialize a models.UserModel instance and add it to the application
	// dependencies.
	app := &application.Application{
		Config:         cfg,
		Debug:          *debug,
		Logger:         logger,
		Phrases:        &models.PhraseModel{DB: db},
		Movies:         &models.MovieModel{DB: db},
		Languages:      &models.LanguageModel{DB: db},
		Users:          &models.UserModel{DB: db},
		TemplateCache:  templateCache,
		FormDecoder:    formDecoder,
		SessionManager: sessionManager,
	}

	srv := &http.Server{
		Addr:         *addr,
		Handler:      app.Routes(),
		IdleTimeout:  time.Minute,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	logger.PrintInfo("Starting server", map[string]string{
		"address": *addr,
	})

	err = srv.ListenAndServe()
	logger.PrintFatal(err, nil)
}

func openDB(cfg application.Config) (*sql.DB, error) {

	db, err := sql.Open("postgres", cfg.Db.Dsn)
	if err != nil {
		return nil, err
	}

	// Set the maximum number of open (in-use + idle) connections in the pool. Note that
	// passing a value less than or equal to 0 will mean there is no limit.
	db.SetMaxOpenConns(cfg.Db.MaxOpenConns)

	// Set the maximum number of idle connections in the pool. Again, passing a value
	// less than or equal to 0 will mean there is no limit.
	db.SetMaxIdleConns(cfg.Db.MaxIdleConns)

	// Use the time.ParseDuration() function to convert the idle timeout duration string
	// to a time.Duration type.
	duration, err := time.ParseDuration(cfg.Db.MaxIdleTime)
	if err != nil {
		return nil, err
	}

	// Set the maximum idle timeout.
	db.SetConnMaxIdleTime(duration)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}

	return db, nil
}
