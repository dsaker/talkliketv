ALTER TABLE users
    ADD COLUMN language_id bigint NOT NULL REFERENCES languages DEFAULT 0;