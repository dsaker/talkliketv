CREATE TABLE IF NOT EXISTS movies (
    id bigserial PRIMARY KEY,
    title text NOT NULL,
    num_subs int NOT NULL
);

INSERT INTO movies (id, title, num_subs) VALUES (-1, 'Not a Movie', 0);
