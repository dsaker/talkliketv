ALTER TABLE movies
    ADD COLUMN language_id bigint NOT NULL REFERENCES languages default -1;