package config

import (
	"context"
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/tomasen/realip"
	"golang.org/x/time/rate"
	"net/http"
	"strings"
	"sync"
	"time"
)

// Config Update the config struct to hold the SMTP server settings.
type Config struct {
	Port          int
	Env           string
	ExpVarEnabled bool
	CtxTimeout    time.Duration
	Db            struct {
		Dsn          string
		MaxOpenConns int
		MaxIdleConns int
		MaxIdleTime  string
	}
	Limiter struct {
		Enabled bool
		Rps     float64
		Burst   int
	}
	Smtp struct {
		Host     string
		Port     int
		Username string
		Password string
		Sender   string
	}
	// Add a Cors struct and trustedOrigins field with the type []string.
	Cors struct {
		TrustedOrigins []string
	}
}

func (cfg *Config) SetConfigs() {
	flag.BoolVar(&cfg.ExpVarEnabled, "expvar-enabled", true, "Enable expvar (disable for testing")
	flag.StringVar(&cfg.Env, "env", "development", "Environment (development|staging|production)")
	flag.DurationVar(&cfg.CtxTimeout, "ctx-timeout", 3*time.Second, "Context timeout for db queries in seconds")

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
	flag.IntVar(&cfg.Smtp.Port, "smtp-port", 2525, "SMTP port")
	flag.StringVar(&cfg.Smtp.Username, "smtp-username", "", "SMTP username")
	flag.StringVar(&cfg.Smtp.Password, "smtp-password", "", "SMTP password")
	flag.StringVar(&cfg.Smtp.Sender, "smtp-sender", "TalkLikeTV <no-reply@talkliketv.click>", "SMTP sender")

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

}

func (cfg *Config) RateLimit(next http.Handler) http.Handler {
	// Define a client struct to hold the rate limiter and last seen time for each
	// client.
	type client struct {
		limiter  *rate.Limiter
		lastSeen time.Time
	}

	var (
		mu sync.Mutex
		// Update the map so the values are pointers to a client struct.
		clients = make(map[string]*client)
	)

	// Launch a background goroutine which removes old entries from the clients map once
	// every minute.
	go func() {
		for {
			time.Sleep(time.Minute)

			// Lock the mutex to prevent any rate limiter checks from happening while
			// the cleanup is taking place.
			mu.Lock()

			// Loop through all clients. If they haven't been seen within the last three
			// minutes, delete the corresponding entry from the map.
			for ip, client := range clients {
				if time.Since(client.lastSeen) > 3*time.Minute {
					delete(clients, ip)
				}
			}

			// Importantly, unlock the mutex when the cleanup is complete.
			mu.Unlock()
		}
	}()

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if cfg.Limiter.Enabled {
			// Use the realip.FromRequest() function to get the client's real IP address.
			ip := realip.FromRequest(r)

			mu.Lock()

			if _, found := clients[ip]; !found {
				clients[ip] = &client{
					limiter: rate.NewLimiter(rate.Limit(cfg.Limiter.Rps), cfg.Limiter.Burst),
				}
			}

			clients[ip].lastSeen = time.Now()

			if !clients[ip].limiter.Allow() {
				mu.Unlock()
				rateLimitExceededResponse(w, r)
				return
			}

			mu.Unlock()
		}

		next.ServeHTTP(w, r)
	})
}

func rateLimitExceededResponse(w http.ResponseWriter, r *http.Request) {
	message := "rate limit exceeded"
	type envelope map[string]interface{}
	env := envelope{"error": message}

	js, err := json.MarshalIndent(env, "", "\t")
	if err != nil {
		fmt.Printf("error in rateLimitExceededResponse: %s, %s, %s", err, r.Method, r.URL.String())
		w.WriteHeader(http.StatusInternalServerError)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusTooManyRequests)
	_, err = w.Write(js)
	if err != nil {
		fmt.Printf("error in rateLimitExceededResponse Write: %s, %s, %s", err, r.Method, r.URL.String())
	}
}

func (cfg *Config) OpenDB() (*sql.DB, error) {
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

	ctx, cancel := context.WithTimeout(context.Background(), cfg.CtxTimeout)
	defer cancel()
	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}

	return db, nil
}
