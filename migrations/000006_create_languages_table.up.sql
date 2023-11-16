CREATE TABLE IF NOT EXISTS languages (
    id bigserial PRIMARY KEY,
    language text NOT NULL
);

INSERT INTO languages (language) VALUES ('Spanish');
INSERT INTO languages (language) VALUES ('French');
INSERT INTO languages (id, language) VALUES (-1, 'Not a Language');
