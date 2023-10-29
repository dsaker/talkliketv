CREATE TABLE users (
   id bigserial PRIMARY KEY,
   name text NOT NULL,
   email citext unique NOT NULL,
   hashed_password bytea NOT NULL,
   created timestamp(0) with time zone NOT NULL DEFAULT NOW()
);
