package models

// Config Update the config struct to hold the SMTP server settings.
type Config struct {
	Port          int
	Env           string
	ExpVarEnabled bool
	CtxTimeout    int
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
