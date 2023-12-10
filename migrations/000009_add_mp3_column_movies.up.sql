ALTER TABLE movies
    ADD COLUMN mp3 bool DEFAULT false;

-- UPDATE movies set mp3 = true where  id > -1;