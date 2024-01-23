CREATE EXTENSION IF NOT EXISTS pg_trgm ;

CREATE INDEX IF NOT EXISTS movies_title_trgm_idx ON movies USING gist (title gist_trgm_ops);
