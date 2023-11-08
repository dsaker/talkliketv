CREATE TABLE IF NOT EXISTS users_phrases (
     user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
     phrase_id bigint NOT NULL REFERENCES phrases ON DELETE CASCADE,
     movie_id bigint NOT NULL REFERENCES movies ON DELETE CASCADE,
     correct bigint,
     PRIMARY KEY (user_id, phrase_id, movie_id)
    );
