CREATE TABLE IF NOT EXISTS phrases (
    id bigserial PRIMARY KEY,
    phrase text NOT NULL,
    translates text NOT NULL
    )
