CREATE TABLE IF NOT EXISTS users_phrases (
     user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
     phrase_id bigint NOT NULL REFERENCES phrases ON DELETE CASCADE,
     correct bigint NOT NULL,
     PRIMARY KEY (user_id, phrase_id)
    );
