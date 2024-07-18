package models

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"errors"
	"golang.org/x/crypto/bcrypt"
	"talkliketv.net/internal/validator"
	"time"
)

// AnonymousUser Declare a new AnonymousUser variable.
var AnonymousUser = &User{}

type User struct {
	ID             int       `json:"id"`
	Created        time.Time `json:"created_at"`
	Name           string    `json:"name"`
	Email          string    `json:"email"`
	HashedPassword []byte    `json:"-"`
	Activated      bool      `json:"activated"`
	Version        int       `json:"-"`
	MovieId        int       `json:"movie_id"`
	LanguageId     int       `json:"language_id"`
	Flipped        bool      `json:"flipped"`
}

// UserModel Define a new UserModel type which wraps a database connection pool.
type UserModel struct {
	DB         *sql.DB
	CtxTimeout time.Duration
}

type UserSignupForm struct {
	Name                string `form:"name"`
	Email               string `form:"email"`
	Password            string `form:"password"`
	LanguageId          int    `form:"language_id"`
	validator.Validator `form:"-"`
}

// IsAnonymous Check if a User instance is the AnonymousUser.
func (u *User) IsAnonymous() bool {
	return u == AnonymousUser
}

func ValidateUser(form *UserSignupForm) {
	form.CheckField(form.NotBlank(form.Name), "name", "This field cannot be blank")
	form.CheckField(form.NotBlank(form.Email), "email", "This field cannot be blank")
	form.CheckField(form.IsEmail(form.Email), "email", "This field must be a valid email address")
	form.CheckField(form.NotBlank(form.Password), "password", "This field cannot be blank")
	form.CheckField(form.MinChars(form.Password, 8), "password", "This field must be at least 8 characters long")
}

func ValidatePassword(v *validator.Validator, password string) {
	v.CheckField(v.NotBlank(password), "password", "This field cannot be blank")
	v.CheckField(v.MinChars(password, 8), "password", "This field must be at least 8 characters long")
}

func ValidateEmail(v *validator.Validator, email string) {
	v.CheckField(v.NotBlank(email), "email", "This field cannot be blank")
	v.CheckField(v.IsEmail(email), "email", "This field must be a valid email address")
}

func (m UserModel) Insert(user *User, password string) error {
	// Create a bcrypt hash of the plain-text password.
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	if err != nil {
		return err
	}

	query := `
        INSERT INTO users (name, email, hashed_password, movie_id, language_id) 
        VALUES ($1, $2, $3, -1, $4)
        RETURNING id, created, activated, movie_id, language_id, flipped`

	args := []interface{}{user.Name, user.Email, hashedPassword, user.LanguageId}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err = m.DB.QueryRowContext(ctx, query, args...).Scan(
		&user.ID,
		&user.Created,
		&user.Activated,
		&user.MovieId,
		&user.LanguageId,
		&user.Flipped)

	if err != nil {
		switch {
		case err.Error() == `pq: duplicate key value violates unique constraint "users_email_key"`:
			return ErrDuplicateEmail
		case err.Error() == `pq: duplicate key value violates unique constraint "users_name_unique_key"`:
			return ErrDuplicateUserName
		default:
			return err
		}
	}

	return nil
}

func (m UserModel) Authenticate(email, password string) (int, bool, error) {
	// Retrieve the id and hashed password associated with the given email. If
	// no matching email exists we return the ErrInvalidCredentials error.
	var id int
	var hashedPassword []byte
	var activated bool

	query := "SELECT id, hashed_password, activated FROM users WHERE email = $1"

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, email).Scan(&id, &hashedPassword, &activated)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, false, ErrInvalidCredentials
		} else {
			return 0, false, err
		}
	}

	// Check whether the hashed password and plain-text password provided match.
	// If they don't, we return the ErrInvalidCredentials error.
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return 0, false, ErrInvalidCredentials
		} else {
			return 0, false, err
		}
	}

	// Otherwise, the password is correct. Return the user ID.
	return id, activated, nil
}

func (m UserModel) Exists(id int) (bool, error) {
	var exists bool

	stmt := "SELECT EXISTS(SELECT true FROM users WHERE id = $1)"

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, stmt, id).Scan(&exists)

	return exists, err
}

func (m UserModel) Get(id int) (*User, error) {
	var user User

	stmt := `SELECT id, name, email, activated, movie_id, language_id, created, flipped, version FROM users WHERE id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, stmt, id).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.Activated,
		&user.MovieId,
		&user.LanguageId,
		&user.Created,
		&user.Flipped,
		&user.Version)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNoRecord
		} else {
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) WebPasswordUpdate(id int, currentPassword, newPassword string) error {
	var currentHashedPassword []byte

	stmt := "SELECT hashed_password FROM users WHERE id = $1"

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, stmt, id).Scan(&currentHashedPassword)
	if err != nil {
		return err
	}

	err = bcrypt.CompareHashAndPassword(currentHashedPassword, []byte(currentPassword))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return ErrInvalidCredentials
		} else {
			return err
		}
	}

	err = m.WebPasswordReset(id, newPassword)
	return err
}

func (m UserModel) WebPasswordReset(id int, newPassword string) error {

	newHashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), 12)
	if err != nil {
		return err
	}

	stmt := "UPDATE users SET hashed_password = $1 WHERE id = $2"

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	_, err = m.DB.ExecContext(ctx, stmt, string(newHashedPassword), id)
	return err
}

func (m UserModel) PasswordUpdate(id int, newPassword string) error {

	newHashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), 12)
	if err != nil {
		return err
	}

	stmt := "UPDATE users SET hashed_password = $1 WHERE id = $2"

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	_, err = m.DB.ExecContext(ctx, stmt, string(newHashedPassword), id)
	return err
}

func (m UserModel) GetForToken(tokenScope, tokenPlaintext string) (*User, error) {
	// Calculate the SHA-256 hash of the plaintext token provided by the client.
	// Remember that this returns a byte *array* with length 32, not a slice.
	tokenHash := sha256.Sum256([]byte(tokenPlaintext))

	// Set up the SQL query.
	query := `
        SELECT u.id, u.activated, u.movie_id, u.language_id, u.flipped, u.version
        FROM users u
        INNER JOIN tokens
        ON u.id = tokens.user_id
        WHERE tokens.hash = $1
        AND tokens.scope = $2 
        AND tokens.expiry > $3`

	// Create a slice containing the query arguments. Notice how we use the [:] operator
	// to get a slice containing the token hash, rather than passing in the array (which
	// is not supported by the pq driver), and that we pass the current time as the
	// value to check against the token expiry.
	args := []interface{}{tokenHash[:], tokenScope, time.Now()}

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	// Execute the query, scanning the return values into a User struct. If no matching
	// record is found we return an ErrRecordNotFound error.
	err := m.DB.QueryRowContext(ctx, query, args...).Scan(
		&user.ID,
		&user.Activated,
		&user.MovieId,
		&user.LanguageId,
		&user.Flipped,
		&user.Version,
	)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrNoRecord
		default:
			return nil, err
		}
	}

	// Return the matching user.
	return &user, nil
}

func (m UserModel) Update(user *User) error {

	query := `
        UPDATE users 
        SET activated = $1, movie_id = $2, language_id = $3, flipped = $4, version = version + 1
        WHERE id = $5 AND version = $6
        RETURNING version`

	args := []interface{}{
		user.Activated,
		user.MovieId,
		user.LanguageId,
		user.Flipped,
		user.ID,
		user.Version,
	}

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&user.Version)
	if err != nil {
		switch {
		case err.Error() == `pq: duplicate key value violates unique constraint "users_email_key"`:
			return ErrDuplicateEmail
		case errors.Is(err, sql.ErrNoRows):
			return ErrEditConflict
		default:
			return err
		}
	}

	return nil
}

func (m UserModel) GetByEmail(email string) (*User, error) {
	query := `
        SELECT id, created, name, email, hashed_password, activated, version, movie_id, language_id, flipped
        FROM users
        WHERE email = $1`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), m.CtxTimeout*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, email).Scan(
		&user.ID,
		&user.Created,
		&user.Name,
		&user.Email,
		&user.HashedPassword,
		&user.Activated,
		&user.Version,
		&user.MovieId,
		&user.LanguageId,
		&user.Flipped,
	)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrNoRecord
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) Matches(plaintextPassword string, passwordHash []byte) (bool, error) {
	err := bcrypt.CompareHashAndPassword(passwordHash, []byte(plaintextPassword))
	if err != nil {
		switch {
		case errors.Is(err, bcrypt.ErrMismatchedHashAndPassword):
			return false, nil
		default:
			return false, err
		}
	}

	return true, nil
}
