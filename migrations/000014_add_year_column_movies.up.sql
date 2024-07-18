ALTER TABLE movies
    ADD COLUMN year integer NOT NULL default -1;

-- UPDATE movies set year = 2023 where  id > -1;