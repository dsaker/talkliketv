
-- INSERT INTO languages (id, language) VALUES (1,
--                                              'Spanish'),
--                                             (2,
--                                              'French'),
--                                             (-1,
--                                              'Not a Language');

INSERT into movies (id, title, num_subs, language_id) VALUES (1,
                                                              'MissAdrenalineS01E01',
                                                              642,
                                                              1),
                                                             (16,
                                                              'TheSimpsonsS32E01',
                                                              325,
                                                              2),
                                                             (25,
                                                              'MissAdrenalineS01E02',
                                                              625,
                                                              1);

INSERT INTO phrases (id, movie_id, phrase, translates, phrase_hint, translates_hint) VALUES (2,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (3,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (4,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (5,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (6,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (7,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (8,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (9,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (10,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (11,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (12,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (13,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.'),
                                                                    (14,
                                                                     1,
                                                                     'Have you always been blind?',
                                                                     '¿Siempre has sido ciego?.',
                                                                     'H   y  a     b   b    ? ',
                                                                     '¿S      h  s   c    ?.');
--   1 |        1 | Have you always been blind?                                                        | ¿Siempre has sido ciego?.                                                                    | H   y  a     b   b    ?                                                | ¿S      h  s   c    ?.
--   2 |        1 | I get asked that a lot.                                                            | Me lo preguntan todo el tiempo.                                                              | Ig  a    t   al  .                                                     | M l p        t   e t     .
--   3 |        1 | For a few seconds, I was able to see the world.                                    | Por unos segundos, pude contemplar el mundo.                                                 | F  af  s      ,Iw  a   t s  t  w    .                                  | P  u   s       ,p   c         e m    .
--   4 |        1 | My mom caught toxoplasmosis at the beginning of her third trimester                | Mi mamá contrajo toxoplasmosis al inicio del tercer trimestre de su embarazo                 | M m  c     t            a t  b        o h  t    t                      | M m   c       t            a i     d  t     t        d s e
--   5 |        1 | after exposure to the feces of our cat, Bowie.                                     | por estar expuesta a las heces de nuestro gato, Bowie.                                       | a    e       t t  f    o o  c  ,B    .                                 | p  e    e       al  h    d n      g   ,B    .
--   6 |        1 | It's his fucking fault.                                                            | Ese es el puto culpable.                                                                     | I ' h  f      f    .                                                   | E  e e p   c       .
--   7 |        1 | Everything's gonna be okay, love!                                                  | Todo va a estar bien, amor.                                                                  | E         ' g    b o   ,l   !                                          | T   v ae    b   ,a   .
--   8 |        1 | She had to have a Csection                                                         | Tuvieron que hacerle una cesárea                                                             | S  h  t h   aC                                                         | T       q  h      u  c
--   9 |        1 | when I was only seven months to prevent me from catching it.                       | cuando yo tenía siete meses para evitar que me contagiara.                                   | w   Iw  o   s    m     t p      m f   c       i .                      | c     y t    s    m    p   e     q  m c         .
--   10 |        1 | What the nurse didn't know was if the incubator oxygen wasn't properly calibrated, | Lo que la enfermera no sabía es que, si el oxígeno de la incubadora no estaba bien calibrado | W   t  n    d   ' k   w  i t  i        o     w   ' p       c         , | L q  l e        n s    e q  ,s e o      d l i         n e     b   c
--   11 |        1 | and they didn't cover my eyes when my retinas were underdeveloped,                 | y no me cubrían los ojos cuando mis retinas no se habían desarrollado,                       | a  t   d   ' c    m e   w   m r      w   u             ,               | yn m c      l  o   c     m  r      n s h     d           ,
--   12 |        1 | it could cause even more serious eye problems.                                     | podía traerme problemas oculares un poquito más graves.                                      | i c    c    e   m   s      e  p       .                                | p    t      p        o       u p      m  g     .
--   13 |        1 | Here are my parents finding out they'd be raising a blind son.                     | Y estos son mis papás enterándose de que tendrían un hijo ciego.                             | H   a  m p      f      o  t   ' b r      ab    s  .                    | Ye    s  m  p    e          d q  t       u h   c    .

INSERT INTO users (id, movie_id, name, email, hashed_password, created, language_id) VALUES (
                                                                                                9999,
                                                                                                -1, 'user2',
                                                                                                'user2@email.com',
                                                                                                '\\x2432612431322445396a71444c59364b5173736e616130536757572f754367383872534367776c314f626b443550365142313958436b476754325836',
                                                                                                '2023-11-14 08:21:57-08',
                                                                                                2);


-- COPY users_phrases (user_id, phrase_id, movie_id, correct) FROM stdin;
-- 1	2093	25	0
-- 1	2094	25	0
-- 1	2095	25	0
-- 1	2096	25	0
-- 1	2097	25	0
-- 1	2098	25	0
-- 1	2099	25	0
-- 1	2100	25	0
-- 1	2101	25	0
-- 1	2102	25	0
-- 1	2103	25	0
-- 1	2104	25	0
-- 1	2105	25	0
-- 1	2106	25	0
-- 1	2107	25	0
-- 1	2108	25	0
-- 1	2109	25	0
-- 1	2110	25	0
-- 1	2111	25	0
-- 1	2112	25	0
-- 1	2113	25	0
-- 1	2114	25	0
-- 1	2115	25	0
-- 1	2116	25	0
-- 1	2117	25	0
-- 1	2118	25	0
-- 1	2119	25	0
-- 1	2120	25	0
-- 1	2121	25	0
-- \.
