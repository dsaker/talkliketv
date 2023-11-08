CREATE TABLE IF NOT EXISTS phrases (
    id bigserial PRIMARY KEY,
    movie_id bigint NOT NULL REFERENCES movies ON DELETE CASCADE,
    phrase text NOT NULL,
    translates text NOT NULL,
    hint text NOT NULL
)
