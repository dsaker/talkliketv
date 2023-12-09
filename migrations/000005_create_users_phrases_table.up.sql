CREATE TABLE IF NOT EXISTS users_phrases (
     user_id bigint NOT NULL REFERENCES users,
     phrase_id bigint NOT NULL REFERENCES phrases,
     movie_id bigint NOT NULL REFERENCES movies,
     phrase_correct bigint,
     flipped_correct bigint,
     PRIMARY KEY (user_id, phrase_id, movie_id)
    );
