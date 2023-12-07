CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
   id bigserial PRIMARY KEY,
   movie_id bigint NOT NULL REFERENCES movies ON DELETE CASCADE,
   name text NOT NULL,
   email citext unique NOT NULL,
   hashed_password bytea NOT NULL,
   flipped bool NOT NUll DEFAULT FALSE,
   created timestamp(0) with time zone NOT NULL DEFAULT NOW()
);

INSERT INTO users (movie_id, name, email, hashed_password) VALUES (-1, 'user1', 'user@email.com', '\x2432612431322468505a714648557253626c49712f59415969345a34756f65766b455a546e7459615a65765950715a5376797731556f437756456c65');
