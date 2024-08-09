--
-- PostgreSQL database dump
--

-- Dumped from database version 14.12 (Homebrew)
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: talkliketv
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO talkliketv;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: languages; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.languages (
    id bigint NOT NULL,
    language text NOT NULL,
    tag text NOT NULL
);


ALTER TABLE public.languages OWNER TO talkliketv;

--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: talkliketv
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.languages_id_seq OWNER TO talkliketv;

--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: talkliketv
--

ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;


--
-- Name: movies; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.movies (
    id bigint NOT NULL,
    title text NOT NULL,
    num_subs integer NOT NULL,
    language_id bigint DEFAULT 0 NOT NULL,
    mp3 boolean DEFAULT false
);


ALTER TABLE public.movies OWNER TO talkliketv;

--
-- Name: movies_id_seq; Type: SEQUENCE; Schema: public; Owner: talkliketv
--

CREATE SEQUENCE public.movies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.movies_id_seq OWNER TO talkliketv;

--
-- Name: movies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: talkliketv
--

ALTER SEQUENCE public.movies_id_seq OWNED BY public.movies.id;


--
-- Name: phrases; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.phrases (
    id bigint NOT NULL,
    movie_id bigint NOT NULL,
    phrase text NOT NULL,
    translates text NOT NULL,
    phrase_hint text NOT NULL,
    translates_hint text NOT NULL
);


ALTER TABLE public.phrases OWNER TO talkliketv;

--
-- Name: phrases_id_seq; Type: SEQUENCE; Schema: public; Owner: talkliketv
--

CREATE SEQUENCE public.phrases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.phrases_id_seq OWNER TO talkliketv;

--
-- Name: phrases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: talkliketv
--

ALTER SEQUENCE public.phrases_id_seq OWNED BY public.phrases.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO talkliketv;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.sessions (
    token text NOT NULL,
    data bytea NOT NULL,
    expiry timestamp with time zone NOT NULL
);


ALTER TABLE public.sessions OWNER TO talkliketv;

--
-- Name: tokens; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.tokens (
    hash bytea NOT NULL,
    user_id bigint NOT NULL,
    expiry timestamp(0) with time zone NOT NULL,
    scope text NOT NULL
);


ALTER TABLE public.tokens OWNER TO talkliketv;

--
-- Name: users; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    movie_id bigint NOT NULL,
    name text NOT NULL,
    email public.citext NOT NULL,
    hashed_password bytea NOT NULL,
    flipped boolean DEFAULT false NOT NULL,
    created timestamp(0) without time zone DEFAULT now() NOT NULL,
    language_id bigint DEFAULT 0 NOT NULL,
    activated boolean DEFAULT false NOT NULL,
    version integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.users OWNER TO talkliketv;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: talkliketv
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO talkliketv;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: talkliketv
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_phrases; Type: TABLE; Schema: public; Owner: talkliketv
--

CREATE TABLE public.users_phrases (
    user_id bigint NOT NULL,
    phrase_id bigint NOT NULL,
    movie_id bigint NOT NULL,
    phrase_correct bigint,
    flipped_correct bigint
);


ALTER TABLE public.users_phrases OWNER TO talkliketv;

--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);


--
-- Name: movies id; Type: DEFAULT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.movies ALTER COLUMN id SET DEFAULT nextval('public.movies_id_seq'::regclass);


--
-- Name: phrases id; Type: DEFAULT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.phrases ALTER COLUMN id SET DEFAULT nextval('public.phrases_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.languages (id, language, tag) FROM stdin;
0	Not a Language	NaL
1	Afrikaans	af
2	Albanian	sq
3	Amharic	am
4	Arabic	ar
5	Armenian	hy
6	Assamese	as
7	Aymara	ay
8	Azerbaijani	az
9	Bambara	bm
10	Basque	eu
11	Belarusian	be
12	Bengali	bn
13	Bhojpuri	bho
14	Bosnian	bs
15	Bulgarian	bg
16	Catalan	ca
17	Cebuano	ceb
18	Chinese (Simplified)	zh
19	Chinese (Traditional)	zh-TW
20	Corsican	co
21	Croatian	hr
22	Czech	cs
23	Danish	da
24	Dhivehi	dv
25	Dogri	doi
26	Dutch	nl
27	English	en
28	Esperanto	eo
29	Estonian	et
30	Ewe	ee
31	Filipino (Tagalog)	fil
32	Finnish	fi
33	French	fr
34	Frisian	fy
35	Galician	gl
36	Georgian	ka
37	German	de
38	Greek	el
39	Guarani	gn
40	Gujarati	gu
41	Haitian Creole	ht
42	Hausa	ha
43	Hawaiian	haw
44	Hebrew	he
45	Hindi	hi
46	Hmong	hmn
47	Hungarian	hu
48	Icelandic	is
49	Igbo	ig
50	Ilocano	ilo
51	Indonesian	id
52	Irish	ga
53	Italian	it
54	Japanese	ja
55	Javanese	jv
56	Kannada	kn
57	Kazakh	kk
58	Khmer	km
59	Kinyarwanda	rw
60	Konkani	gom
61	Korean	ko
62	Krio	kri
63	Kurdish	ku
64	Kyrgyz	ky
65	Lao	lo
66	Latin	la
67	Latvian	lv
68	Lingala	ln
69	Lithuanian	lt
70	Luganda	lg
71	Luxembourgish	lb
72	Macedonian	mk
73	Maithili	mai
74	Malagasy	mg
75	Malay	ms
76	Malayalam	ml
77	Maltese	mt
78	Maori	mi
79	Marathi	mr
80	Meiteilon	mni-Mtei
81	Mizo	lus
82	Mongolian	mn
83	Myanmar	my
84	Nepali	ne
85	Norwegian	no
86	Nyanja	ny
87	Odia	or
88	Oromo	om
89	Pashto	ps
90	Persian	fa
91	Polish	pl
92	Portuguese	pt
93	Punjabi	pa
94	Quechua	qu
95	Romanian	ro
96	Russian	ru
97	Samoan	sm
98	Sanskrit	sa
99	Scots Gaelic	gd
100	Sepedi	nso
101	Serbian	sr
102	Sesotho	st
103	Shona	sn
104	Sindhi	sd
105	Sinhala	si
106	Slovak	sk
107	Slovenian	sl
108	Somali	so
109	Spanish	es
110	Sundanese	su
111	Swahili	sw
112	Swedish	sv
113	Tagalog	tl
114	Tajik	tg
115	Tamil	ta
116	Tatar	tt
117	Telugu	te
118	Thai	th
119	Tigrinya	ti
120	Tsonga	ts
121	Turkish	tr
122	Turkmen	tk
123	Twi	ak
124	Ukrainian	uk
125	Urdu	ur
126	Uyghur	ug
127	Uzbek	uz
128	Vietnamese	vi
129	Welsh	cy
130	Xhosa	xh
131	Yiddish	yi
132	Yoruba	yo
133	Zulu	zu
\.


--
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.movies (id, title, num_subs, language_id, mp3) FROM stdin;
-1	Not a Movie	0	0	f
\.


--
-- Data for Name: phrases; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.phrases (id, movie_id, phrase, translates, phrase_hint, translates_hint) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.schema_migrations (version, dirty) FROM stdin;
16	f
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.sessions (token, data, expiry) FROM stdin;
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.tokens (hash, user_id, expiry, scope) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.users (id, movie_id, name, email, hashed_password, flipped, created, language_id, activated, version) FROM stdin;
\.


--
-- Data for Name: users_phrases; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.users_phrases (user_id, phrase_id, movie_id, phrase_correct, flipped_correct) FROM stdin;
\.


--
-- Name: languages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.languages_id_seq', 133, true);


--
-- Name: movies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.movies_id_seq', 1, false);


--
-- Name: phrases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.phrases_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- Name: phrases phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.phrases
    ADD CONSTRAINT phrases_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (token);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (hash);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_name_unique_key; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_name_unique_key UNIQUE (name);


--
-- Name: users_phrases users_phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_pkey PRIMARY KEY (user_id, phrase_id, movie_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: movies_title_trgm_idx; Type: INDEX; Schema: public; Owner: talkliketv
--

CREATE INDEX movies_title_trgm_idx ON public.movies USING gist (title public.gist_trgm_ops);


--
-- Name: sessions_expiry_idx; Type: INDEX; Schema: public; Owner: talkliketv
--

CREATE INDEX sessions_expiry_idx ON public.sessions USING btree (expiry);


--
-- Name: movies movies_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: phrases phrases_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.phrases
    ADD CONSTRAINT phrases_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id);


--
-- Name: tokens tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: users users_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id);


--
-- Name: users_phrases users_phrases_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id);


--
-- Name: users_phrases users_phrases_phrase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_phrase_id_fkey FOREIGN KEY (phrase_id) REFERENCES public.phrases(id);


--
-- Name: users_phrases users_phrases_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: talkliketv
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: talkliketv
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

