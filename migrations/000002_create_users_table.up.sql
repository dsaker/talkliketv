CREATE TABLE users (
   id bigserial PRIMARY KEY,
   movie_id bigint NOT NULL REFERENCES movies ON DELETE CASCADE,
   name text NOT NULL,
   email citext unique NOT NULL,
   hashed_password bytea NOT NULL,
   created timestamp(0) with time zone NOT NULL DEFAULT NOW()
);