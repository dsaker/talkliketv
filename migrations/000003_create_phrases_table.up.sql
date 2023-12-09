CREATE TABLE IF NOT EXISTS phrases (
    id bigserial PRIMARY KEY,
    movie_id bigint NOT NULL REFERENCES movies,
    phrase text NOT NULL,
    translates text NOT NULL,
    phrase_hint text NOT NULL,
    translates_hint text NOT NULL
)
