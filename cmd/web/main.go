package main

import (
	"crypto/tls"
	"flag"
	"fmt"
	"github.com/alexedwards/scs/v2"
	"github.com/go-playground/form/v4"
	"html/template"
	"net/http"
	"os"
	"talkliketv.net/internal/jsonlog"
	"talkliketv.net/internal/models"
	"time"

	_ "github.com/lib/pq"
)

var (
	buildTime string
	version   string
)

type application struct {
	config         models.Config
	logger         *jsonlog.Logger
	models         models.Models
	templateCache  map[string]*template.Template
	formDecoder    *form.Decoder
	sessionManager *scs.SessionManager
	debug          bool
}

func main() {

	var cfg models.Config

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
	defer db.Close()

	logger.PrintInfo("database connection pool established", nil)

	templateCache, err := newTemplateCache()
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
	app := &application{
		config:         cfg,
		debug:          *debug,
		logger:         logger,
		models:         models.NewModels(db),
		templateCache:  templateCache,
		formDecoder:    formDecoder,
		sessionManager: sessionManager,
	}

	tlsConfig := &tls.Config{
		CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
	}

	srv := &http.Server{
		Addr:         *addr,
		Handler:      app.routes(),
		TLSConfig:    tlsConfig,
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
