ALTER TABLE movies
    ADD COLUMN language_id bigint NOT NULL REFERENCES languages ON DELETE CASCADE default -1;