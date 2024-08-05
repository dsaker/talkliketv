--
-- PostgreSQL database dump
--

-- Dumped from database version 12.19 (Ubuntu 12.19-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.19 (Ubuntu 12.19-0ubuntu0.20.04.1)

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


ALTER TABLE public.languages_id_seq OWNER TO talkliketv;

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


ALTER TABLE public.movies_id_seq OWNER TO talkliketv;

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


ALTER TABLE public.phrases_id_seq OWNER TO talkliketv;

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


ALTER TABLE public.users_id_seq OWNER TO talkliketv;

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
1	TheMannyS01E01	479	109	f
\.


--
-- Data for Name: phrases; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.phrases (id, movie_id, phrase, translates, phrase_hint, translates_hint) FROM stdin;
1	1	You're going to love being his nanny. They are little angels.	Te va a encantar ser su nana. Son unos angelitos.	Y__'__ g____ t_ l___ b____ h__ n____. T___ a__ l_____ a_____. 	T_ v_ a e_______ s__ s_ n___. S__ u___ a________. 
2	1	Oh, my children behave so well. I love them.	Ay, se portan tan bien mis hijos. Los amo.	O_, m_ c_______ b_____ s_ w___. I l___ t___. 	A_, s_ p_____ t__ b___ m__ h____. L__ a__. 
3	1	I think I arrived at the presentation about 15 minutes late.	Yo creo que llego a la presentación como 15 minutos tarde.	I t____ I a______ a_ t__ p___________ a____ 15 m______ l___. 	Y_ c___ q__ l____ a l_ p__________³_ c___ 15 m______ t____. 
4	1	Oh, mom, she started, she put my shoes in the toilet.	Ay, mamá, ella empezó, metió mis zapatos al excusado.	O_, m__, s__ s______, s__ p__ m_ s____ i_ t__ t_____. 	A_, m___¡, e___ e_____³, m____³ m__ z______ a_ e_______. 
5	1	Do not take it personally.	No lo tomes personal.	D_ n__ t___ i_ p_________. 	N_ l_ t____ p_______. 
6	1	that you try the cake.	que probaras el pastel.	t___ y__ t__ t__ c___. 	q__ p_______ e_ p_____. 
7	1	I don't make it to the meeting.	No llego a la junta.	I d__'_ m___ i_ t_ t__ m______. 	N_ l____ a l_ j____. 
8	1	No no no.	No, no, no.	N_ n_ n_. 	N_, n_, n_. 
9	1	No, excuse me, Mr. Rizo. I'm coming right now.	No, perdóneme, señor Rizo. Ahorita llego.	N_, e_____ m_, M_. R___. I'_ c_____ r____ n__. 	N_, p____³____, s__±__ R___. A______ l____. 
10	1	It's just that I was resolving something with the bank, and...	Es que me quedé resolviendo una cosa con el banco, y…	I_'_ j___ t___ I w__ r________ s________ w___ t__ b___, a__... 	E_ q__ m_ q____© r__________ u__ c___ c__ e_ b____, y_¦ 
11	1	So, do you have experience with… restless children?	Entonces, ¿sí tiene experiencia usted con niños… inquietos?	S_, d_ y__ h___ e_________ w____¦ r_______ c_______? 	E_______, Â¿__­ t____ e__________ u____ c__ n__±___¦ i________? 
12	1	I swear it's plastic. I swear.	Le juro que es de plástico. Se lo juro.	I s____ i_'_ p______. I s____. 	L_ j___ q__ e_ d_ p__¡_____. S_ l_ j___. 
13	1	Mr. Rizo... I haven't arrived.	Señor Rizo… no llego.	M_. R___... I h____'_ a______. 	S__±__ R____¦ n_ l____. 
14	1	for my dad's farewell?	para la despedida de mi papá?	f__ m_ d__'_ f_______? 	p___ l_ d________ d_ m_ p___¡? 
15	1	the mere boss of the company?	la mera jefa de la empresa?	t__ m___ b___ o_ t__ c______? 	l_ m___ j___ d_ l_ e______? 
16	1	All that remains is to finish the financial proposal	Solo falta terminar la propuesta financiera	A__ t___ r______ i_ t_ f_____ t__ f________ p_______ 	S___ f____ t_______ l_ p________ f_________ 
17	1	that I'm going to present to the council and get a good nanny.	que voy a presentar al consejo y conseguir una buena nana.	t___ I'_ g____ t_ p______ t_ t__ c______ a__ g__ a g___ n____. 	q__ v__ a p________ a_ c______ y c________ u__ b____ n___. 
18	1	Get out of that kitchen, please. See you in your office.	Ya salte de esa cocina, por favor. Te veo en tu oficina.	G__ o__ o_ t___ k______, p_____. S__ y__ i_ y___ o_____. 	Y_ s____ d_ e__ c_____, p__ f____. T_ v__ e_ t_ o______. 
19	1	Leo, you will burn down the house and those inside.	Leo, incendiarás la casa y a los de adentro.	L__, y__ w___ b___ d___ t__ h____ a__ t____ i_____. 	L__, i_________¡_ l_ c___ y a l__ d_ a______. 
20	1	It was just an experiment, Mom, and no one wants to live to be 40.	Solo era un experimento, mamá, y nadie quiere vivir hasta los 40.	I_ w__ j___ a_ e_________, M__, a__ n_ o__ w____ t_ l___ t_ b_ 40. 	S___ e__ u_ e__________, m___¡, y n____ q_____ v____ h____ l__ 40. 
21	1	Many do, but surely not you.	Muchos sí, pero seguro tú no.	M___ d_, b__ s_____ n__ y__. 	M_____ s_­, p___ s_____ t__ n_. 
22	1	Because it's been two weeks since he comes back with everything from the lunch box,	Porque van dos semanas que vuelve con todo lo de la lonchera,	B______ i_'_ b___ t__ w____ s____ h_ c____ b___ w___ e_________ f___ t__ l____ b__, 	P_____ v__ d__ s______ q__ v_____ c__ t___ l_ d_ l_ l_______, 
23	1	except the sausages.	menos las salchichas.	e_____ t__ s_______. 	m____ l__ s_________. 
24	1	Because they come out of a package where I can read the ingredients.	Porque salen de un paquete del que puedo leer los ingredientes.	B______ t___ c___ o__ o_ a p______ w____ I c__ r___ t__ i__________. 	P_____ s____ d_ u_ p______ d__ q__ p____ l___ l__ i___________. 
25	1	You don't even know how to read. I learned last year.	Ni siquiera sabes leer. Aprendí el año pasado.	Y__ d__'_ e___ k___ h__ t_ r___. I l______ l___ y___. 	N_ s_______ s____ l___. A______­ e_ a_±_ p_____. 
26	1	Reading your cell phone messages.	Leyendo los mensajes de su celular.	R______ y___ c___ p____ m_______. 	L______ l__ m_______ d_ s_ c______. 
27	1	to mom, dad and Leo…!	a mamá, papá y a Leo…!	t_ m__, d__ a__ L___¦! 	a m___¡, p___¡ y a L___¦! 
28	1	No, no, don't even see me.	No, no, a mí ni me vea.	N_, n_, d__'_ e___ s__ m_. 	N_, n_, a m_­ n_ m_ v__. 
29	1	You know I don't like children.	Ya sabe que no me gustan los niños.	Y__ k___ I d__'_ l___ c_______. 	Y_ s___ q__ n_ m_ g_____ l__ n__±__. 
30	1	If you force me to take care of them, you will be left without a nanny and without a cook. How do you see?	Si me obliga a cuidarlos, se va a quedar sin nana y sin cocinera. ¿Cómo ve?	I_ y__ f____ m_ t_ t___ c___ o_ t___, y__ w___ b_ l___ w______ a n____ a__ w______ a c___. H__ d_ y__ s__? 	S_ m_ o_____ a c________, s_ v_ a q_____ s__ n___ y s__ c_______. Â¿__³__ v_? 
31	1	No, thank you, Martita. The last time,	No, gracias, Martita. La última vez,	N_, t____ y__, M______. T__ l___ t___, 	N_, g______, M______. L_ Ã______ v__, 
32	1	Leo left home, you forgot to send for Sofia	Leo se salió de casa, se te olvidó mandar por Sofía	L__ l___ h___, y__ f_____ t_ s___ f__ S____ 	L__ s_ s____³ d_ c___, s_ t_ o_____³ m_____ p__ S___­_ 
33	1	and we picked her up at eight at night at school.	y la recogimos a las ocho de la noche en la escuela.	a__ w_ p_____ h__ u_ a_ e____ a_ n____ a_ s_____. 	y l_ r________ a l__ o___ d_ l_ n____ e_ l_ e______. 
34	1	The lullaby that Romina sent.	La nana que mandó Romina.	T__ l______ t___ R_____ s___. 	L_ n___ q__ m____³ R_____. 
35	1	Please make it maternal, tender, delicate, loving...	Por favor, que sea maternal, tierna, delicada, amorosa…	P_____ m___ i_ m_______, t_____, d_______, l_____... 	P__ f____, q__ s__ m_______, t_____, d_______, a_______¦ 
36	1	who did not want to work with us.	que no quisieron trabajar con nosotros.	w__ d__ n__ w___ t_ w___ w___ u_. 	q__ n_ q________ t_______ c__ n_______. 
37	1	Eh... it's good that it's here.	Eh… qué bueno que ya está aquí.	E_... i_'_ g___ t___ i_'_ h___. 	E__¦ q__© b____ q__ y_ e___¡ a___­. 
38	1	I need you to do my garden very well… No, I come from Romina.	Necesito que me haga muy bien el jardín… No, vengo de parte de Romina.	I n___ y__ t_ d_ m_ g_____ v___ w____¦ N_, I c___ f___ R_____. 	N_______ q__ m_ h___ m__ b___ e_ j____­__¦ N_, v____ d_ p____ d_ R_____. 
39	1	His ex-nana. I thought the job was taking care of little dogs.	Su exnana. Pensé que el trabajo era cuidar a unos morritos.	H__ e_-____. I t______ t__ j__ w__ t_____ c___ o_ l_____ d___. 	S_ e_____. P____© q__ e_ t______ e__ c_____ a u___ m_______. 
40	1	Romina told me she was coming…	Romina me dijo que venía…	R_____ t___ m_ s__ w__ c______¦ 	R_____ m_ d___ q__ v___­__¦ 
41	1	Gaby, his goddaughter.	Gaby, su ahijada.	G___, h__ g__________. 	G___, s_ a______. 
42	1	Godson. I am Gabriel.	Ahijado. Soy Gabriel.	G_____. I a_ G______. 	A______. S__ G______. 
43	1	Sorry, but the truth is, I was waiting for…	Perdón, pero la verdad, yo estaba esperando a…	S____, b__ t__ t____ i_, I w__ w______ f___¦ 	P____³_, p___ l_ v_____, y_ e_____ e________ a_¦ 
44	1	Yeah, and I get it, huh.	Sí, y lo entiendo, eh.	Y___, a__ I g__ i_, h__. 	S_­, y l_ e_______, e_. 
45	1	But trust me, you have nothing to worry about.	Pero créame, no tiene nada de qué preocuparse.	B__ t____ m_, y__ h___ n______ t_ w____ a____. 	P___ c__©___, n_ t____ n___ d_ q__© p__________. 
46	1	I promise you that I have a lot of experience.	Le prometo que tengo mucha experiencia.	I p______ y__ t___ I h___ a l__ o_ e_________. 	L_ p______ q__ t____ m____ e__________. 
47	1	I helped raise all my nephews.	Ayudé a criar a todos mis sobrinos.	I h_____ r____ a__ m_ n______. 	A____© a c____ a t____ m__ s_______. 
48	1	There's nothing a good tie can't fix.	No hay nada que un buen lazo no puede arreglar.	T____'_ n______ a g___ t__ c__'_ f__. 	N_ h__ n___ q__ u_ b___ l___ n_ p____ a_______. 
49	1	Well, only when it was very necessary,	Bueno, solo cuando ya era muy necesario,	W___, o___ w___ i_ w__ v___ n________, 	B____, s___ c_____ y_ e__ m__ n________, 
50	1	and the well was full of water.	y el pozo estaba lleno de agua.	a__ t__ w___ w__ f___ o_ w____. 	y e_ p___ e_____ l____ d_ a___. 
51	1	A well. What a good idea.	Un pozo. Qué buena idea.	A w___. W___ a g___ i___. 	U_ p___. Q__© b____ i___. 
52	1	Don't even think about it, Martha. I have claustrophobia.	Ni se te ocurra, Martha. Tengo claustrofobia.	D__'_ e___ t____ a____ i_, M_____. I h___ c_____________. 	N_ s_ t_ o_____, M_____. T____ c____________. 
53	1	Don't even think I'm going to leave my children with a... someone like you.	Ni creas que voy a dejar a mis hijos con un… alguien como tú.	D__'_ e___ t____ I'_ g____ t_ l____ m_ c_______ w___ a... s______ l___ y__. 	N_ c____ q__ v__ a d____ a m__ h____ c__ u__¦ a______ c___ t__. 
54	1	But you were going to leave us with five other nannies who didn't want to.	Pero nos ibas a dejar con otras cinco nanas que no quisieron.	B__ y__ w___ g____ t_ l____ u_ w___ f___ o____ n______ w__ d___'_ w___ t_. 	P___ n__ i___ a d____ c__ o____ c____ n____ q__ n_ q________. 
55	1	That's not important.	Eso no es importante.	T___'_ n__ i________. 	E__ n_ e_ i_________. 
56	1	I can't have a man in my house.	No puedo tener un hombre en mi casa.	I c__'_ h___ a m__ i_ m_ h____. 	N_ p____ t____ u_ h_____ e_ m_ c___. 
57	1	In any case, they are already talking about the men she brings into the house.	De todas maneras, ya hablan de los hombres que mete a la casa.	I_ a__ c___, t___ a__ a______ t______ a____ t__ m__ s__ b_____ i___ t__ h____. 	D_ t____ m______, y_ h_____ d_ l__ h______ q__ m___ a l_ c___. 
58	1	Of course, he had never involved a rancher.	Eso sí, nunca había metido a un ranchero.	O_ c_____, h_ h__ n____ i_______ a r______. 	E__ s_­, n____ h___­_ m_____ a u_ r_______. 
59	1	a photo of me in a bra.	una foto mía en brasier.	a p____ o_ m_ i_ a b__. 	u__ f___ m_­_ e_ b______. 
60	1	that you don't get into their privacy?	que no te metas en su privacidad?	t___ y__ d__'_ g__ i___ t____ p______? 	q__ n_ t_ m____ e_ s_ p_________? 
61	1	What happens is that the cache is putting padding in the bra.	Lo que pasa es que la caché poniéndose relleno en el brasier.	W___ h______ i_ t___ t__ c____ i_ p______ p______ i_ t__ b__. 	L_ q__ p___ e_ q__ l_ c____© p____©_____ r______ e_ e_ b______. 
62	1	You should get stuffed somewhere else to talk to the girl you like	Deberías ponerte relleno en otro lado para hablarle a la niña que te gusta	Y__ s_____ g__ s______ s________ e___ t_ t___ t_ t__ g___ y__ l___ 	D_____­__ p______ r______ e_ o___ l___ p___ h_______ a l_ n__±_ q__ t_ g____ 
63	1	who has never been with anyone!	que nunca ha andado con nadie!	w__ h__ n____ b___ w___ a_____! 	q__ n____ h_ a_____ c__ n____! 
64	1	Sofia, that's not good at all.	Sofía, eso no está nada bien.	S____, t___'_ n__ g___ a_ a__. 	S___­_, e__ n_ e___¡ n___ b___. 
65	1	Not dating someone doesn't make you a loser, you're just selective.	No salir con alguien no te convierte en loser, solo eres selectivo.	N__ d_____ s______ d____'_ m___ y__ a l____, y__'__ j___ s________. 	N_ s____ c__ a______ n_ t_ c________ e_ l____, s___ e___ s________. 
66	1	And why do you waste so much wisdom?	y por qué derrochas tanta sabiduría?	A__ w__ d_ y__ w____ s_ m___ w_____? 	y p__ q__© d________ t____ s_______­_? 
67	1	Romina's godson.	El ahijado de Romina.	R_____'_ g_____. 	E_ a______ d_ R_____. 
68	1	Change your mind.	Cambiar de opinión.	C_____ y___ m___. 	C______ d_ o_____³_. 
69	1	If you post your sister's image, the one you like will think you're a jerk.	Si tú posteas la imagen de tu hermana, la que te gusta pensará que eres patán.	I_ y__ p___ y___ s_____'_ i____, t__ o__ y__ l___ w___ t____ y__'__ a j___. 	S_ t__ p______ l_ i_____ d_ t_ h______, l_ q__ t_ g____ p______¡ q__ e___ p___¡_. 
70	1	Besides, it is wrong to expose people and especially your sister.	Además de que está mal exhibir a las personas y sobre todo a tu hermana.	B______, i_ i_ w____ t_ e_____ p_____ a__ e_________ y___ s_____. 	A____¡_ d_ q__ e___¡ m__ e______ a l__ p_______ y s____ t___ a t_ h______. 
71	1	Hurry up, you have to go to school or you'll be late.	Apúrense que deben ir a la escuela o llegarán tarde.	H____ u_, y__ h___ t_ g_ t_ s_____ o_ y__'__ b_ l___. 	A________ q__ d____ i_ a l_ e______ o l______¡_ t____. 
72	1	to make yourself cool at school?	para hacerte el cool en la escuela?	t_ m___ y_______ c___ a_ s_____? 	p___ h______ e_ c___ e_ l_ e______? 
73	1	I didn't realize I had it.	No me di cuenta de que lo traía.	I d___'_ r______ I h__ i_. 	N_ m_ d_ c_____ d_ q__ l_ t___­_. 
74	1	Women don't like this.	Esto no les gusta a las mujeres.	W____ d__'_ l___ t___. 	E___ n_ l__ g____ a l__ m______. 
75	1	You have to talk to them like this, with your pants off.	A ellas hay que hablarles así, a calzón quitado.	Y__ h___ t_ t___ t_ t___ l___ t___, w___ y___ p____ o__. 	A e____ h__ q__ h________ a__­, a c____³_ q______. 
76	1	Tell him something from here.	Dile algo de aquí.	T___ h__ s________ f___ h___. 	D___ a___ d_ a___­. 
77	1	Something like it is the star that lights your path.	Algo como que es la estrella que alumbra tu sendero.	S________ l___ i_ i_ t__ s___ t___ l_____ y___ p___. 	A___ c___ q__ e_ l_ e_______ q__ a______ t_ s______. 
78	1	Make her feel special, so that she doesn't think that you are stinging from flower to flower.	Hazla sentir especial, que no piense que andas picando de flor en flor.	M___ h__ f___ s______, s_ t___ s__ d____'_ t____ t___ y__ a__ s_______ f___ f_____ t_ f_____. 	H____ s_____ e_______, q__ n_ p_____ q__ a____ p______ d_ f___ e_ f___. 
79	1	I saved you from one. Otherwise, you would have made a fool of yourself.	Te salvé de una. Si no, hubieras hecho el ridículo.	I s____ y__ f___ o__. O________, y__ w____ h___ m___ a f___ o_ y_______. 	T_ s____© d_ u__. S_ n_, h_______ h____ e_ r___­____. 
80	1	Thank you for saving my son.	Gracias por salvar a mi hijo.	T____ y__ f__ s_____ m_ s__. 	G______ p__ s_____ a m_ h___. 
81	1	I gave him some advice to convince you to hire me.	Le di una lana para convencerte de que me contrates.	I g___ h__ s___ a_____ t_ c_______ y__ t_ h___ m_. 	L_ d_ u__ l___ p___ c__________ d_ q__ m_ c________. 
82	1	One second. It's okay, you can stay.	Un segundo. Está bien, te puedes quedar.	O__ s_____. I_'_ o___, y__ c__ s___. 	U_ s______. E___¡ b___, t_ p_____ q_____. 
83	1	Martha, show Gaby where she's going to stay the night.	Martha, enséñale a Gaby dónde se va a quedar a dormir.	M_____, s___ G___ w____ s__'_ g____ t_ s___ t__ n____. 	M_____, e___©_±___ a G___ d_³___ s_ v_ a q_____ a d_____. 
84	1	Yes, I'm going there. I need everything from the current accounts...	Sí, ya voy para allá. Necesito todo lo de las cuentas vigentes…	Y__, I'_ g____ t____. I n___ e_________ f___ t__ c______ a_______... 	S_­, y_ v__ p___ a___¡. N_______ t___ l_ d_ l__ c______ v________¦ 
85	1	You call me handsome and I follow you. This way, come.	Tú me dices guapo y yo te sigo. Por acá, vente.	Y__ c___ m_ h_______ a__ I f_____ y__. T___ w__, c___. 	T__ m_ d____ g____ y y_ t_ s___. P__ a__¡, v____. 
86	1	How pretty, cousin. More beautiful every day, really.	Qué guapa, prima. Cada día más guapa, de verdad.	H__ p_____, c_____. M___ b________ e____ d__, r_____. 	Q__© g____, p____. C___ d_­_ m_¡_ g____, d_ v_____. 
87	1	Save your buzzard compliments, cousin.	Ahórrate tus piropos de zopilote, primo.	S___ y___ b______ c__________, c_____. 	A__³_____ t__ p______ d_ z_______, p____. 
88	1	My dad didn't decide who will be the president of the council.	Mi papá no decidió quién será el presidente del consejo.	M_ d__ d___'_ d_____ w__ w___ b_ t__ p________ o_ t__ c______. 	M_ p___¡ n_ d______³ q___©_ s___¡ e_ p_________ d__ c______. 
89	1	I am a partner of this company	que soy socio de esta empresa	I a_ a p______ o_ t___ c______ 	q__ s__ s____ d_ e___ e______ 
90	1	and do I have the same rights as you?	y tengo los mismos derechos que tú?	a__ d_ I h___ t__ s___ r_____ a_ y__? 	y t____ l__ m_____ d_______ q__ t__? 
91	1	Sure, but you work three times less than me.	Claro, pero trabajas tres veces menos que yo.	S___, b__ y__ w___ t____ t____ l___ t___ m_. 	C____, p___ t_______ t___ v____ m____ q__ y_. 
92	1	Don't get your hopes up, cousin.	No te hagas muchas ilusiones, primo.	D__'_ g__ y___ h____ u_, c_____. 	N_ t_ h____ m_____ i________, p____. 
93	1	I'm going to recommend something to you.	Te voy a recomendar algo.	I'_ g____ t_ r________ s________ t_ y__. 	T_ v__ a r_________ a___. 
94	1	You should improve that character a little, otherwise you won't get married.	Deberías mejorar un poquito ese carácter, si no, no te vas a casar.	Y__ s_____ i______ t___ c________ a l_____, o________ y__ w__'_ g__ m______. 	D_____­__ m______ u_ p______ e__ c___¡____, s_ n_, n_ t_ v__ a c____. 
95	1	You already married Joaquín once, who left you for Mich,	Ya te casaste una vez con Joaquín, que te dejó por Mich,	Y__ a______ m______ J_____­_ o___, w__ l___ y__ f__ M___, 	Y_ t_ c______ u__ v__ c__ J_____­_, q__ t_ d___³ p__ M___, 
96	1	Which is like two lives younger, right?	que es como dos vidas más joven, ¿no?	W____ i_ l___ t__ l____ y______, r____? 	q__ e_ c___ d__ v____ m_¡_ j____, Â¿__? 
97	1	The truth is, it doesn't hurt at all, don't worry.	La verdad, no me duele para nada, ni te preocupes.	T__ t____ i_, i_ d____'_ h___ a_ a__, d__'_ w____. 	L_ v_____, n_ m_ d____ p___ n___, n_ t_ p________. 
98	1	In fact, what are you doing here, if it's not yet a fortnight?	De hecho, ¿qué haces aquí, si todavía no es quincena?	I_ f___, w___ a__ y__ d____ h___, i_ i_'_ n__ y__ a f________? 	D_ h____, Â¿___© h____ a___­, s_ t_____­_ n_ e_ q_______? 
99	1	Notice that your daddy sent for me.	Fíjate que tu papi me mandó a llamar.	N_____ t___ y___ d____ s___ f__ m_. 	F_­____ q__ t_ p___ m_ m____³ a l_____. 
100	1	There is a complicated issue that requires a man like me to solve.	Hay un tema complicado que requiere que un hombre como yo resuelva.	T____ i_ a c__________ i____ t___ r_______ a m__ l___ m_ t_ s____. 	H__ u_ t___ c_________ q__ r_______ q__ u_ h_____ c___ y_ r_______. 
101	1	Almost, because there is a lot of shit involved in the matter.	Casi, porque hay bastante mierda involucrada en el asunto.	A_____, b______ t____ i_ a l__ o_ s___ i_______ i_ t__ m_____. 	C___, p_____ h__ b_______ m_____ i__________ e_ e_ a_____. 
102	1	Shit that a girl like you is not going to clean,	Mierda que una niña como tú no va a limpiar,	S___ t___ a g___ l___ y__ i_ n__ g____ t_ c____, 	M_____ q__ u__ n__±_ c___ t__ n_ v_ a l______, 
103	1	but that I have to fix.	pero que yo tengo que arreglar.	b__ t___ I h___ t_ f__. 	p___ q__ y_ t____ q__ a_______. 
104	1	Because if not, and this is serious,	Porque si no, y esto es en serio,	B______ i_ n__, a__ t___ i_ s______, 	P_____ s_ n_, y e___ e_ e_ s____, 
105	1	Your daddy can lose everything.	tu papi lo puede perder todo.	Y___ d____ c__ l___ e_________. 	t_ p___ l_ p____ p_____ t___. 
106	1	See you later.	Luego te veo.	S__ y__ l____. 	L____ t_ v__. 
107	1	I told him I was coming to Guadalajara.	Le dije que venía para Guadalajara.	I t___ h__ I w__ c_____ t_ G__________. 	L_ d___ q__ v___­_ p___ G__________. 
108	1	You kicked me out of there, didn't you?	Usted me corrió de ahí, ¿no?	Y__ k_____ m_ o__ o_ t____, d___'_ y__? 	U____ m_ c_____³ d_ a__­, Â¿__? 
109	1	You are my only son, Gabriel. I trusted you and you let me down.	Eres mi único hijo varón, Gabriel. Confié en ti y me defraudaste.	Y__ a__ m_ o___ s__, G______. I t______ y__ a__ y__ l__ m_ d___. 	E___ m_ Ã_____ h___ v___³_, G______. C_____© e_ t_ y m_ d__________. 
110	1	Yes, that's why I left. To not screw it up anymore.	Sí, por eso me fui. Para ya no cagarla.	Y__, t___'_ w__ I l___. T_ n__ s____ i_ u_ a______. 	S_­, p__ e__ m_ f__. P___ y_ n_ c______. 
111	1	You didn't even take your truck. I don't know what you're thinking about.	Ni siquiera te llevaste tu camioneta. No sé en qué estás pensando.	Y__ d___'_ e___ t___ y___ t____. I d__'_ k___ w___ y__'__ t_______ a____. 	N_ s_______ t_ l_______ t_ c________. N_ s_© e_ q__© e___¡_ p_______. 
112	1	I want to do things differently, and it won't let me.	Quiero hacer las cosas diferentes, y no me deja.	I w___ t_ d_ t_____ d__________, a__ i_ w__'_ l__ m_. 	Q_____ h____ l__ c____ d_________, y n_ m_ d___. 
113	1	If with your foolishness that of your alternative diet,	Si con tu necedad esa de tu alimentación alternativa,	I_ w___ y___ f__________ t___ o_ y___ a__________ d___, 	S_ c__ t_ n______ e__ d_ t_ a__________³_ a__________, 
114	1	The pigs didn't make the weight and I lost a lot of money.	los puercos no dieron el peso y perdí mucho dinero.	T__ p___ d___'_ m___ t__ w_____ a__ I l___ a l__ o_ m____. 	l__ p______ n_ d_____ e_ p___ y p____­ m____ d_____. 
115	1	Now those dogs from the financial company want to ruin my ranch.	Ahora que esos perros de la financiera me quieren chingar el rancho.	N__ t____ d___ f___ t__ f________ c______ w___ t_ r___ m_ r____. 	A____ q__ e___ p_____ d_ l_ f_________ m_ q______ c______ e_ r_____. 
116	1	I asked you for something, and you didn't do it.	Te encargué una cosa, y no cumpliste.	I a____ y__ f__ s________, a__ y__ d___'_ d_ i_. 	T_ e_______© u__ c___, y n_ c________. 
117	1	I always keep my promises.	Yo siempre cumplo mis promesas.	I a_____ k___ m_ p_______. 	Y_ s______ c_____ m__ p_______. 
118	1	I just never committed to doing things the way you wanted.	Nomás nunca me comprometí a hacer las cosas como usted quería.	I j___ n____ c________ t_ d____ t_____ t__ w__ y__ w_____. 	N___¡_ n____ m_ c_________­ a h____ l__ c____ c___ u____ q____­_. 
119	1	Look, whatever it was, you screwed me, Gabriel.	Mira, haiga sido como haiga sido, me jodiste, Gabriel.	L___, w_______ i_ w__, y__ s______ m_, G______. 	M___, h____ s___ c___ h____ s___, m_ j______, G______. 
120	1	I'm leaving now, so my pacemaker isn't going to break down.	Ya me voy, no se me vaya a descomponer el marcapasos.	I'_ l______ n__, s_ m_ p________ i__'_ g____ t_ b____ d___. 	Y_ m_ v__, n_ s_ m_ v___ a d__________ e_ m_________. 
121	1	Yes that's fine.	Sí, está bien.	Y__ t___'_ f___. 	S_­, e___¡ b___. 
122	1	I want it, dad. Take care.	Lo quiero, pa. Cuídese.	I w___ i_, d__. T___ c___. 	L_ q_____, p_. C__­____. 
123	1	Yes, yes, it's okay.	Sí, sí, está bien.	Y__, y__, i_'_ o___. 	S_­, s_­, e___¡ b___. 
124	1	I just found that idiot Rogelio,	Me acabo de encontrar al imbécil de Rogelio,	I j___ f____ t___ i____ R______, 	M_ a____ d_ e________ a_ i___©___ d_ R______, 
125	1	and he tells me that the financial company is in trouble.	y me dice que la financiera está en problemas.	a__ h_ t____ m_ t___ t__ f________ c______ i_ i_ t______. 	y m_ d___ q__ l_ f_________ e___¡ e_ p________. 
126	1	We supposedly did amazing this year with the clients you brought in.	Se supone que nos fue increíble este año con los clientes que trajiste.	W_ s_________ d__ a______ t___ y___ w___ t__ c______ y__ b______ i_. 	S_ s_____ q__ n__ f__ i_____­___ e___ a_±_ c__ l__ c_______ q__ t_______. 
127	1	It's very strange, I didn't understand anything.	Está rarísimo, no entendí nada.	I_'_ v___ s______, I d___'_ u_________ a_______. 	E___¡ r___­____, n_ e______­ n___. 
128	1	Waiting for the noses to return.	Esperando a que los morros regresen.	W______ f__ t__ n____ t_ r_____. 	E________ a q__ l__ m_____ r_______. 
129	1	Oh no. I urgently need to get a lullaby ASAP.	Ay, no. Me urge conseguir una nana ASAP.	O_ n_. I u_______ n___ t_ g__ a l______ A___. 	A_, n_. M_ u___ c________ u__ n___ A___. 
130	1	Romina, my ex-nana, decided to send me someone	Romina, mi exnana, quedó de mandarme alguien	R_____, m_ e_-____, d______ t_ s___ m_ s______ 	R_____, m_ e_____, q____³ d_ m_______ a______ 
131	1	and why not? He decides to send me his… godson.	y, ¿por qué no? Decide mandarme a su… ahijado.	a__ w__ n__? H_ d______ t_ s___ m_ h___¦ g_____. 	y, Â¿___ q__© n_? D_____ m_______ a s__¦ a______. 
132	1	I highly doubt this guy can take care of anyone.	Dudo mucho que este tipo pueda cuidar a alguien.	I h_____ d____ t___ g__ c__ t___ c___ o_ a_____. 	D___ m____ q__ e___ t___ p____ c_____ a a______. 
133	1	In other words, he tied up his nephews at his ranch.	O sea, amarraba a sus sobrinos en su rancho.	I_ o____ w____, h_ t___ u_ h__ n______ a_ h__ r____. 	O s__, a_______ a s__ s_______ e_ s_ r_____. 
134	1	I'm sure I couldn't find a job and Romina wants to screw me over.	Seguro no encontraba trabajo y Romina me lo quiere enjaretar.	I'_ s___ I c_____'_ f___ a j__ a__ R_____ w____ t_ s____ m_ o___. 	S_____ n_ e_________ t______ y R_____ m_ l_ q_____ e________. 
135	1	Well, I don't see anything bad about it, on the contrary.	Pues yo no le veo nada malo, al contrario.	W___, I d__'_ s__ a_______ b__ a____ i_, o_ t__ c_______. 	P___ y_ n_ l_ v__ n___ m___, a_ c________. 
136	1	It looks good everywhere.	Se ve bueno por todos lados.	I_ l____ g___ e_________. 	S_ v_ b____ p__ t____ l____. 
137	1	Everything ready, but it's no longer a surprise.	Todo listo, pero ya no es sorpresa.	E_________ r____, b__ i_'_ n_ l_____ a s_______. 	T___ l____, p___ y_ n_ e_ s_______. 
138	1	Already. All that's left is for you to tell me, eh, well...	Ya. Ya solamente faltaría que me digas, eh, pues…	A______. A__ t___'_ l___ i_ f__ y__ t_ t___ m_, e_, w___... 	Y_. Y_ s________ f______­_ q__ m_ d____, e_, p____¦ 
139	1	who would stay in the presidency.	quién se quedaría en la presidencia.	w__ w____ s___ i_ t__ p_________. 	q___©_ s_ q______­_ e_ l_ p__________. 
140	1	That's a surprise, huh?	Esa es una sorpresa, ¿mm?	T___'_ a s_______, h__? 	E__ e_ u__ s_______, Â¿__? 
141	1	Clear. I met Rogelio…	Claro. Me encontré a Rogelio…	C____. I m__ R_______¦ 	C____. M_ e_______© a R_______¦ 
142	1	No, he's looking at the Dos Caminos ranches.	No, está viendo lo de los ranchos de Dos Caminos.	N_, h_'_ l______ a_ t__ D__ C______ r______. 	N_, e___¡ v_____ l_ d_ l__ r______ d_ D__ C______. 
143	1	They owe us a lot of money.	Nos deben mucho dinero.	T___ o__ u_ a l__ o_ m____. 	N__ d____ m____ d_____. 
144	1	The future of the financial institution and ours depends on getting paid.	El futuro de la financiera y el nuestro depende de que nos paguen.	T__ f_____ o_ t__ f________ i__________ a__ o___ d______ o_ g______ p___. 	E_ f_____ d_ l_ f_________ y e_ n______ d______ d_ q__ n__ p_____. 
145	1	It can get very violent.	Se puede poner muy violento.	I_ c__ g__ v___ v______. 	S_ p____ p____ m__ v_______. 
146	1	Yes, but that's my account. I should take charge.	Sí, pero esa es mi cuenta. Yo me debería hacer cargo.	Y__, b__ t___'_ m_ a______. I s_____ t___ c_____. 	S_­, p___ e__ e_ m_ c_____. Y_ m_ d_____­_ h____ c____. 
147	1	You better finish my speech.	Mejor tú acaba mi discurso.	Y__ b_____ f_____ m_ s_____. 	M____ t__ a____ m_ d_______. 
148	1	Then I'll send it to you. Thank you.	Luego te lo mando. Gracias.	T___ I'__ s___ i_ t_ y__. T____ y__. 	L____ t_ l_ m____. G______. 
149	1	He will surely name you.	Seguro te nombrará a ti.	H_ w___ s_____ n___ y__. 	S_____ t_ n_______¡ a t_. 
150	1	Oh no, Sofía uploaded a new photo to Instagram.	Ay, no, Sofía subió una foto nueva a Instagram.	O_ n_, S___­_ u_______ a n__ p____ t_ I________. 	A_, n_, S___­_ s____³ u__ f___ n____ a I________. 
151	1	I still haven't finished getting divorced,	Todavía no me termino de divorciar,	I s____ h____'_ f_______ g______ d_______, 	T_____­_ n_ m_ t______ d_ d________, 
152	1	and the children are posting a photo with a man that I brought into my house.	y los niños están posteando una foto con un hombre que metí a mi casa.	a__ t__ c_______ a__ p______ a p____ w___ a m__ t___ I b______ i___ m_ h____. 	y l__ n__±__ e___¡_ p________ u__ f___ c__ u_ h_____ q__ m___­ a m_ c___. 
153	1	And what a man...	Y qué hombre…	A__ w___ a m__... 	Y q__© h______¦ 
154	1	I don't see anything wrong with the nano.	Yo no le veo nada malo al nano.	I d__'_ s__ a_______ w____ w___ t__ n___. 	Y_ n_ l_ v__ n___ m___ a_ n___. 
155	1	about the star that illuminates your path,	lo de la estrella que ilumina tu sendero,	a____ t__ s___ t___ i__________ y___ p___, 	l_ d_ l_ e_______ q__ i______ t_ s______, 
156	1	and I ended up making a fool of myself.	y terminé haciendo el ridículo.	a__ I e____ u_ m_____ a f___ o_ m_____. 	y t______© h_______ e_ r___­____. 
157	1	Tania is the one who doesn't pay attention to him.	Tania es la que no le hace caso.	T____ i_ t__ o__ w__ d____'_ p__ a________ t_ h__. 	T____ e_ l_ q__ n_ l_ h___ c___. 
158	1	He's in high school, he's going to my grandfather's company party because his dad works there.	Va en prepa, irá a la fiesta de la empresa de mi abuelo porque su papá trabaja ahí.	H_'_ i_ h___ s_____, h_'_ g____ t_ m_ g__________'_ c______ p____ b______ h__ d__ w____ t____. 	V_ e_ p____, i__¡ a l_ f_____ d_ l_ e______ d_ m_ a_____ p_____ s_ p___¡ t______ a__­. 
159	1	He just uploaded a TikTok, he says he wants to commit suicide.	Acaba de subir un TikTok, dice que se quiere suicidar.	H_ j___ u_______ a T_____, h_ s___ h_ w____ t_ c_____ s______. 	A____ d_ s____ u_ T_____, d___ q__ s_ q_____ s_______. 
160	1	You have to get to him at the party.	Tienes que llegarle en la fiesta.	Y__ h___ t_ g__ t_ h__ a_ t__ p____. 	T_____ q__ l_______ e_ l_ f_____. 
161	1	Not as you think?	No, ¿cómo crees?	N__ a_ y__ t____? 	N_, Â¿__³__ c____? 
162	1	of a party without a girlfriend.	de una fiesta sin novia.	o_ a p____ w______ a g_________. 	d_ u__ f_____ s__ n____. 
163	1	Yes, of course it's in... That doesn't matter right now.	Sí, claro que está en… Eso no importa ahorita.	Y__, o_ c_____ i_'_ i_... T___ d____'_ m_____ r____ n__. 	S_­, c____ q__ e___¡ e__¦ E__ n_ i______ a______. 
164	1	The important thing is to get your brother a good suit.	Lo importante es conseguirle un buen traje a tu hermano.	T__ i________ t____ i_ t_ g__ y___ b______ a g___ s___. 	L_ i_________ e_ c__________ u_ b___ t____ a t_ h______. 
165	1	That's going to be difficult.	Es que eso va a estar difícil.	T___'_ g____ t_ b_ d________. 	E_ q__ e__ v_ a e____ d___­___. 
166	1	Santiago doesn't look good at all, he has SpongeBob arms.	A Santiago no se le ve nada bien, tiene brazos de Bob Esponja.	S_______ d____'_ l___ g___ a_ a__, h_ h__ S________ a___. 	A S_______ n_ s_ l_ v_ n___ b___, t____ b_____ d_ B__ E______. 
167	1	At least I don't have pimples on my face.	Por lo menos no tengo granos en la cara.	A_ l____ I d__'_ h___ p______ o_ m_ f___. 	P__ l_ m____ n_ t____ g_____ e_ l_ c___. 
168	1	You two look like fighting cocks.	Ustedes dos parecen gallos de pelea.	Y__ t__ l___ l___ f_______ c____. 	U______ d__ p______ g_____ d_ p____. 
169	1	They have to learn to get along.	Tienen que aprender a llevarse bien.	T___ h___ t_ l____ t_ g__ a____. 	T_____ q__ a_______ a l_______ b___. 
170	1	No not at all.	No, para nada.	N_ n__ a_ a__. 	N_, p___ n___. 
171	1	But do you want me to tell you something? Someday they will be old,	Pero ¿quieren que les cuente algo? Algún día van a estar viejitos,	B__ d_ y__ w___ m_ t_ t___ y__ s________? S______ t___ w___ b_ o__, 	P___ Â¿_______ q__ l__ c_____ a___? A_____ d_­_ v__ a e____ v_______, 
172	1	and they will want someone to push their wheelchair for them.	y van a querer que alguien les empuje la silla de ruedas.	a__ t___ w___ w___ s______ t_ p___ t____ w_________ f__ t___. 	y v__ a q_____ q__ a______ l__ e_____ l_ s____ d_ r_____. 
173	1	Let's see, Joaquín, I need to send the children to you tonight.	A ver, Joaquín, necesito mandarte a los niños hoy en la noche.	L__'_ s__, J_____­_, I n___ t_ s___ t__ c_______ t_ y__ t______. 	A v__, J_____­_, n_______ m_______ a l__ n__±__ h__ e_ l_ n____. 
174	1	Explain to me what a guy is doing choking our son.	Explícame qué hace un güey ahorcando a nuestro hijo.	E______ t_ m_ w___ a g__ i_ d____ c______ o__ s__. 	E____­____ q__© h___ u_ g_¼__ a________ a n______ h___. 
175	1	It just can't be.	No puede ser.	I_ j___ c__'_ b_. 	N_ p____ s__. 
176	1	And you brought a brother into the house?	y tú metiste un brother a la casa?	A__ y__ b______ a b______ i___ t__ h____? 	y t__ m______ u_ b______ a l_ c___? 
177	1	Gabriel is Romina's godson	Gabriel es el ahijado de Romina	G______ i_ R_____'_ g_____ 	G______ e_ e_ a______ d_ R_____ 
178	1	and he sent him to help me with the children, but he's already leaving.	y lo mandó para ayudarme con los niños, pero ya se va.	a__ h_ s___ h__ t_ h___ m_ w___ t__ c_______, b__ h_'_ a______ l______. 	y l_ m____³ p___ a_______ c__ l__ n__±__, p___ y_ s_ v_. 
179	1	When you already live with someone?	cuando ya vives con alguien?	W___ y__ a______ l___ w___ s______? 	c_____ y_ v____ c__ a______? 
180	1	It will only be a few days, from now until I get a lullaby.	Serán solamente unos días, de aquí a que consiga una nana.	I_ w___ o___ b_ a f__ d___, f___ n__ u____ I g__ a l______. 	S___¡_ s________ u___ d_­__, d_ a___­ a q__ c______ u__ n___. 
181	1	I would love to, you know I adore our children.	Me encantaría, sabes que adoro a nuestros hijos.	I w____ l___ t_, y__ k___ I a____ o__ c_______. 	M_ e________­_, s____ q__ a____ a n_______ h____. 
182	1	But I'm traveling with Mich looking at his new gym.	Pero estoy de viaje con Mich viendo lo de su nuevo gimnasio.	B__ I'_ t________ w___ M___ l______ a_ h__ n__ g__. 	P___ e____ d_ v____ c__ M___ v_____ l_ d_ s_ n____ g_______. 
183	1	I mean, it's the sixth gym you've given Mich.	O sea, es el sexto gimnasio que le pones a Mich.	I m___, i_'_ t__ s____ g__ y__'__ g____ M___. 	O s__, e_ e_ s____ g_______ q__ l_ p____ a M___. 
184	1	On the other hand, you are not in any of them even if they kill you, eh?	En cambio, tú no estás en ninguno ni aunque te maten, ¿eh?	O_ t__ o____ h___, y__ a__ n__ i_ a__ o_ t___ e___ i_ t___ k___ y__, e_? 	E_ c_____, t__ n_ e___¡_ e_ n______ n_ a_____ t_ m____, Â¿__? 
185	1	Hello, Mich. Goodbye, Mich.	Hola, Mich. Adiós, Mich.	H____, M___. G______, M___. 	H___, M___. A___³_, M___. 
186	1	I don't understand what we're doing here.	No entiendo qué hacemos aquí.	I d__'_ u_________ w___ w_'__ d____ h___. 	N_ e_______ q__© h______ a___­. 
187	1	I don't think Santiago will find what to wear in this place.	No creo que Santiago encuentre qué ponerse en este lugar.	I d__'_ t____ S_______ w___ f___ w___ t_ w___ i_ t___ p____. 	N_ c___ q__ S_______ e________ q__© p______ e_ e___ l____. 
188	1	Unless it's a flower apron.	A menos que sea un delantal de flores.	U_____ i_'_ a f_____ a____. 	A m____ q__ s__ u_ d_______ d_ f_____. 
189	1	I think you may be surprised.	Creo que se pueden sorprender.	I t____ y__ m__ b_ s________. 	C___ q__ s_ p_____ s_________. 
190	1	I also wanted to come because I wanted to say hello to someone.	También quería venir porque tenía ganas de saludar a alguien.	I a___ w_____ t_ c___ b______ I w_____ t_ s__ h____ t_ s______. 	T_____©_ q____­_ v____ p_____ t___­_ g____ d_ s______ a a______. 
191	1	Hopefully. My mom has been crazy since you left.	Ojalá. Mi mamá está vuelta loca desde que te fuiste.	H________. M_ m__ h__ b___ c____ s____ y__ l___. 	O____¡. M_ m___¡ e___¡ v_____ l___ d____ q__ t_ f_____. 
192	1	Come back, please. Oh, mija.	Ya regresa, por favor. Ay, mija.	C___ b___, p_____. O_, m___. 	Y_ r______, p__ f____. A_, m___. 
193	1	We welcome you.	O llévanos contigo.	W_ w______ y__. 	O l__©_____ c______. 
194	1	They'll have to put up with it, because I'm not coming back.	Se tendrán que aguantar, porque no voy a regresar.	T___'__ h___ t_ p__ u_ w___ i_, b______ I'_ n__ c_____ b___. 	S_ t_____¡_ q__ a_______, p_____ n_ v__ a r_______. 
195	1	I always dreamed of having my store with products from Gabriel's ranch.	Siempre soñé con tener mi tienda con los productos del rancho de Gabriel.	I a_____ d______ o_ h_____ m_ s____ w___ p_______ f___ G______'_ r____. 	S______ s__±_© c__ t____ m_ t_____ c__ l__ p________ d__ r_____ d_ G______. 
196	1	Well, actually it's my dad's. But I prefer not to talk about that.	Bueno, en realidad es de mi papá. Pero prefiero no hablar de eso.	W___, a_______ i_'_ m_ d__'_. B__ I p_____ n__ t_ t___ a____ t___. 	B____, e_ r_______ e_ d_ m_ p___¡. P___ p_______ n_ h_____ d_ e__. 
197	1	Let's say Gabriel is not what his dad would like him to be.	Digamos que Gabriel no es lo que su papá quisiera que fuera.	L__'_ s__ G______ i_ n__ w___ h__ d__ w____ l___ h__ t_ b_. 	D______ q__ G______ n_ e_ l_ q__ s_ p___¡ q_______ q__ f____. 
198	1	No. There would be nothing wrong with that, my Leo.	No. No habría nada de malo en eso, mi Leo.	N_. T____ w____ b_ n______ w____ w___ t___, m_ L__. 	N_. N_ h____­_ n___ d_ m___ e_ e__, m_ L__. 
199	1	Don't bother me, son.	No te me agüites, mijo.	D__'_ b_____ m_, s__. 	N_ t_ m_ a__¼____, m___. 
200	1	You are the cutest godson in the whole world.	Eres el ahijado más lindo de todo el mundo.	Y__ a__ t__ c_____ g_____ i_ t__ w____ w____. 	E___ e_ a______ m_¡_ l____ d_ t___ e_ m____. 
201	1	You and I are going to change the world. That's where we are, godmother.	Tú y yo vamos a cambiar el mundo. En eso estamos, madrina.	Y__ a__ I a__ g____ t_ c_____ t__ w____. T___'_ w____ w_ a__, g________. 	T__ y y_ v____ a c______ e_ m____. E_ e__ e______, m______. 
202	1	I know how it feels.	Yo sé lo que se siente.	I k___ h__ i_ f____. 	Y_ s_© l_ q__ s_ s_____. 
203	1	My mom hates that I like pink.	Mi mamá odia que me guste el rosa.	M_ m__ h____ t___ I l___ p___. 	M_ m___¡ o___ q__ m_ g____ e_ r___. 
204	1	Maybe you and I should try something different.	A lo mejor tú y yo debemos probar algo diferente.	M____ y__ a__ I s_____ t__ s________ d________. 	A l_ m____ t__ y y_ d______ p_____ a___ d________. 
205	1	Now you have to find something to impress the girl.	Ahora hay que encontrarte algo para que impresione a la morra.	N__ y__ h___ t_ f___ s________ t_ i______ t__ g___. 	A____ h__ q__ e__________ a___ p___ q__ i_________ a l_ m____. 
206	1	That's where sausages come from.	De ahí vienen las salchichas.	T___'_ w____ s_______ c___ f___. 	D_ a__­ v_____ l__ s_________. 
207	1	Yes. Let's see, young man.	Sí. A ver, joven.	Y__. L__'_ s__, y____ m__. 	S_­. A v__, j____. 
208	1	Get ready for the photo.	Pónganse para la foto.	G__ r____ f__ t__ p____. 	P_³______ p___ l_ f___. 
209	1	Well, Jimena tested me, godmother.	Pues, Jimena me puso a prueba, madrina.	W___, J_____ t_____ m_, g________. 	P___, J_____ m_ p___ a p_____, m______. 
210	1	I don't think it will be easy for them to give me the job.	No creo que esté fácil que me den la chamba.	I d__'_ t____ i_ w___ b_ e___ f__ t___ t_ g___ m_ t__ j__. 	N_ c___ q__ e___© f_¡___ q__ m_ d__ l_ c_____. 
211	1	You have to stay there, Gabriel.	Tienes que quedarte ahí, Gabriel.	Y__ h___ t_ s___ t____, G______. 	T_____ q__ q_______ a__­, G______. 
212	1	If you want to save your dad's ranch, you must do everything to get him to hire you.	Si quieres salvar el rancho de tu papá, debes hacer todo para que te contrate.	I_ y__ w___ t_ s___ y___ d__'_ r____, y__ m___ d_ e_________ t_ g__ h__ t_ h___ y__. 	S_ q______ s_____ e_ r_____ d_ t_ p___¡, d____ h____ t___ p___ q__ t_ c_______. 
213	1	And everything is everything.	Y todo es todo.	A__ e_________ i_ e_________. 	Y t___ e_ t___. 
214	1	throughout the city.	en toda la ciudad.	t_________ t__ c___. 	e_ t___ l_ c_____. 
215	1	Oh no. It's not going to be that they end up in bed like they always do when they see each other.	Ay, no. No vaya a ser que terminen en la cama como siempre que se ven.	O_ n_. I_'_ n__ g____ t_ b_ t___ t___ e__ u_ i_ b__ l___ t___ a_____ d_ w___ t___ s__ e___ o____. 	A_, n_. N_ v___ a s__ q__ t_______ e_ l_ c___ c___ s______ q__ s_ v__. 
216	1	That just happened like...	Eso solamente ha pasado como…	T___ j___ h_______ l___... 	E__ s________ h_ p_____ c____¦ 
217	1	And no, he can't, because he went on a trip with Mich.	Y no, no puede, porque se fue de viaje con Mich.	A__ n_, h_ c__'_, b______ h_ w___ o_ a t___ w___ M___. 	Y n_, n_ p____, p_____ s_ f__ d_ v____ c__ M___. 
218	1	Oh, now, relax.	Ay, ya, relájate.	O_, n__, r____. 	A_, y_, r___¡____. 
219	1	You're going to have to trust	Vas a tener que confiar	Y__'__ g____ t_ h___ t_ t____ 	V__ a t____ q__ c______ 
220	1	where the handsome rancher can control your beasts.	en que el ranchero guapo pueda controlar a tus fieras.	w____ t__ h_______ r______ c__ c______ y___ b_____. 	e_ q__ e_ r_______ g____ p____ c________ a t__ f_____. 
221	1	That's the problem: that he is a man and handsome.	Ese es el problema: que es hombre y guapo.	T___'_ t__ p______: t___ h_ i_ a m__ a__ h_______. 	E__ e_ e_ p_______: q__ e_ h_____ y g____. 
222	1	I already see myself on the cover of Club Social Tapatío.	Ya me veo en la portada de Club Social Tapatío.	I a______ s__ m_____ o_ t__ c____ o_ C___ S_____ T_____­_. 	Y_ m_ v__ e_ l_ p______ d_ C___ S_____ T_____­_. 
223	1	And yes, he will be very handsome, but he is a savage.	Y sí, estará muy guapo, pero es un salvaje.	A__ y__, h_ w___ b_ v___ h_______, b__ h_ i_ a s_____. 	Y s_­, e_____¡ m__ g____, p___ e_ u_ s______. 
224	1	show a corpse to children?	enseñar un cadáver a los niños?	s___ a c_____ t_ c_______? 	e____±__ u_ c___¡___ a l__ n__±__? 
225	1	He probably tied them up to put them to bed.	Seguramente los amarró para acostarlos.	H_ p_______ t___ t___ u_ t_ p__ t___ t_ b__. 	S__________ l__ a_____³ p___ a_________. 
226	1	to tie me up, right?	que me amarrara a mí, ¿no?	t_ t__ m_ u_, r____? 	q__ m_ a_______ a m_­, Â¿__? 
227	1	I'll call you later, friend.	Luego te llamo, amiga.	I'__ c___ y__ l____, f_____. 	L____ t_ l____, a____. 
228	1	Leo already fell asleep. And no, I didn't have to tie him up.	Ya se durmió Leo. Y no, no tuve que amarrarlo.	L__ a______ f___ a_____. A__ n_, I d___'_ h___ t_ t__ h__ u_. 	Y_ s_ d_____³ L__. Y n_, n_ t___ q__ a________. 
229	1	Oh, sorry, Gabriel, I didn't want you to hear... that.	Ay, perdón, Gabriel, no quería que escucharas… eso.	O_, s____, G______, I d___'_ w___ y__ t_ h___... t___. 	A_, p____³_, G______, n_ q____­_ q__ e__________¦ e__. 
230	1	or am I handsome?	o que estoy guapo?	o_ a_ I h_______? 	o q__ e____ g____? 
231	1	Because that's the first time they've told me that.	Porque esa es la primera vez que me lo dicen.	B______ t___'_ t__ f____ t___ t___'__ t___ m_ t___. 	P_____ e__ e_ l_ p______ v__ q__ m_ l_ d____. 
232	1	The wild thing.	Lo de salvaje.	T__ w___ t____. 	L_ d_ s______. 
233	1	But I wanted to apologize for the pig photo, Jime.	Pero te quería pedir una disculpa por la foto del cerdo, Jime.	B__ I w_____ t_ a________ f__ t__ p__ p____, J___. 	P___ t_ q____­_ p____ u__ d_______ p__ l_ f___ d__ c____, J___. 
234	1	Understand me, Gabriel. This…	entiéndeme a mí, Gabriel. Este…	U_________ m_, G______. T____¦ 	e____©_____ a m_­, G______. E____¦ 
235	1	For me, tomorrow's meal is super important, because, eh, well...	Para mí es superimportante la comida de mañana, porque, eh, pues…	F__ m_, t_______'_ m___ i_ s____ i________, b______, e_, w___... 	P___ m_­ e_ s______________ l_ c_____ d_ m__±___, p_____, e_, p____¦ 
236	1	It is possible that my dad will finally give me the position of president of the financial company.	Es posible que por fin mi papá me dé el puesto de presidenta de la financiera.	I_ i_ p_______ t___ m_ d__ w___ f______ g___ m_ t__ p_______ o_ p________ o_ t__ f________ c______. 	E_ p______ q__ p__ f__ m_ p___¡ m_ d_© e_ p_____ d_ p_________ d_ l_ f_________. 
237	1	Yes Yes Yes.	Sí, sí, sí.	Y__ Y__ Y__. 	S_­, s_­, s_­. 
238	1	like an important position, right?	como un puesto importante, ¿no?	l___ a_ i________ p_______, r____? 	c___ u_ p_____ i_________, Â¿__? 
239	1	In finance, I can help many people.	En la financiera, puedo ayudar a mucha gente.	I_ f______, I c__ h___ m___ p_____. 	E_ l_ f_________, p____ a_____ a m____ g____. 
240	1	And it's my dream.	Y es mi sueño.	A__ i_'_ m_ d____. 	Y e_ m_ s___±_. 
241	1	I mean, even though sometimes my dad can't understand it.	Digo, aunque a veces mi papá no lo pueda entender.	I m___, e___ t_____ s________ m_ d__ c__'_ u_________ i_. 	D___, a_____ a v____ m_ p___¡ n_ l_ p____ e_______. 
242	1	I have worked very hard to get things handled in a way…	He trabajado muy duro para lograr que las cosas se manejen de una forma…	I h___ w_____ v___ h___ t_ g__ t_____ h______ i_ a w___¦ 	H_ t________ m__ d___ p___ l_____ q__ l__ c____ s_ m______ d_ u__ f_____¦ 
243	1	Yes. I understand perfectly what you are talking about.	Sí. Entiendo perfectamente de lo que hablas.	Y__. I u_________ p________ w___ y__ a__ t______ a____. 	S_­. E_______ p____________ d_ l_ q__ h_____. 
244	1	Even more than you imagine.	Hasta más de lo que te imaginas.	E___ m___ t___ y__ i______. 	H____ m_¡_ d_ l_ q__ t_ i_______. 
245	1	Well, how can I help you?	Bueno, ¿en qué te ayudo yo?	W___, h__ c__ I h___ y__? 	B____, Â¿__ q__© t_ a____ y_? 
246	1	Hey… Help me with the kids. Help me with the…	Eh… Ayúdame con los niños. Ayúdame con los…	H___¦ H___ m_ w___ t__ k___. H___ m_ w___ t___¦ 	E__¦ A_______ c__ l__ n__±__. A_______ c__ l___¦ 
247	1	Because no matter how much I wanted to, I can't be there.	Porque por más que yo quisiera, no puedo estar ahí.	B______ n_ m_____ h__ m___ I w_____ t_, I c__'_ b_ t____. 	P_____ p__ m_¡_ q__ y_ q_______, n_ p____ e____ a__­. 
248	1	Yes, don't worry, I'll take care of the kids.	Sí, no te preocupes, yo me encargo de los niños.	Y__, d__'_ w____, I'__ t___ c___ o_ t__ k___. 	S_­, n_ t_ p________, y_ m_ e______ d_ l__ n__±__. 
249	1	That's what you hired me for.	Para eso me contrataste.	T___'_ w___ y__ h____ m_ f__. 	P___ e__ m_ c__________. 
250	1	And sorry about... No, nothing happens.	Y perdón por lo de… No, no pasa nada.	A__ s____ a____... N_, n______ h______. 	Y p____³_ p__ l_ d__¦ N_, n_ p___ n___. 
251	1	I'm also used to being told I'm pretty.	También estoy acostumbrado a que me digan que estoy guapo.	I'_ a___ u___ t_ b____ t___ I'_ p_____. 	T_____©_ e____ a___________ a q__ m_ d____ q__ e____ g____. 
252	1	No… Well, okay!	No… ¡Bueno, está bien!	N__¦ W___, o___! 	N__¦ Â¡_____, e___¡ b___! 
253	1	I'm not going to impress anyone with this. Except Tania.	Con esto no voy a impresionar a nadie. Menos a Tania.	I'_ n__ g____ t_ i______ a_____ w___ t___. E_____ T____. 	C__ e___ n_ v__ a i__________ a n____. M____ a T____. 
254	1	Don't despair, my Santi.	No te desesperes, mi Santi.	D__'_ d______, m_ S____. 	N_ t_ d_________, m_ S____. 
255	1	You are doing very well, you learn quickly.	Lo estás haciendo muy bien, aprendes rápido.	Y__ a__ d____ v___ w___, y__ l____ q______. 	L_ e___¡_ h_______ m__ b___, a_______ r_¡____. 
256	1	Maybe it works for you to think that the lamp is Tania,	A lo mejor, te funciona pensar que la lámpara es Tania,	M____ i_ w____ f__ y__ t_ t____ t___ t__ l___ i_ T____, 	A l_ m____, t_ f_______ p_____ q__ l_ l_¡_____ e_ T____, 
257	1	and you will catch her with your lasso of love.	y tú la atraparás con tu lazo de amor.	a__ y__ w___ c____ h__ w___ y___ l____ o_ l___. 	y t__ l_ a_______¡_ c__ t_ l___ d_ a___. 
258	1	I think it's most likely that Tania will run away.	Yo creo que lo más probable es que Tania saldrá corriendo.	I t____ i_'_ m___ l_____ t___ T____ w___ r__ a___. 	Y_ c___ q__ l_ m_¡_ p_______ e_ q__ T____ s_____¡ c________. 
259	1	Hey, don't underestimate the power of the lasso, huh?	Oye, no subestimes el poder del lazo, ¿eh?	H__, d__'_ u____________ t__ p____ o_ t__ l____, h__? 	O__, n_ s_________ e_ p____ d__ l___, Â¿__? 
260	1	Give him another one. We already have to go change to go to food.	Dale otra más. Ya nos tenemos que ir a cambiar para ir a la comida.	G___ h__ a______ o__. W_ a______ h___ t_ g_ c_____ t_ g_ t_ f___. 	D___ o___ m_¡_. Y_ n__ t______ q__ i_ a c______ p___ i_ a l_ c_____. 
261	1	If you get this one, I'll show you the golden lasso.	Si te sale esta, te enseño el lazo de oro.	I_ y__ g__ t___ o__, I'__ s___ y__ t__ g_____ l____. 	S_ t_ s___ e___, t_ e____±_ e_ l___ d_ o__. 
262	1	Two laps… One lap, two laps…	Dos vueltas… Una vuelta, dos vueltas…	T__ l____¦ O__ l__, t__ l____¦ 	D__ v_______¦ U__ v_____, d__ v_______¦ 
263	1	It was closer.	Estuvo más cerca.	I_ w__ c_____. 	E_____ m_¡_ c____. 
264	1	They tell me you took it.	me dicen que te la llevaste.	T___ t___ m_ y__ t___ i_. 	m_ d____ q__ t_ l_ l_______. 
265	1	Of course I took her, if they were going to kill her.	Claro que me la llevé, si la iban a matar.	O_ c_____ I t___ h__, i_ t___ w___ g____ t_ k___ h__. 	C____ q__ m_ l_ l____©, s_ l_ i___ a m____. 
266	1	We cannot keep animals that produce nothing.	No podemos mantener animales que no producen nada.	W_ c_____ k___ a______ t___ p______ n______. 	N_ p______ m_______ a_______ q__ n_ p_______ n___. 
267	1	of the financial sector they are wolves	de la financiera son lobos	o_ t__ f________ s_____ t___ a__ w_____ 	d_ l_ f_________ s__ l____ 
268	1	and they are colluding with the government! But I'm not going to leave.	y están coludidos con el gobierno! Pero no me voy a dejar.	a__ t___ a__ c________ w___ t__ g_________! B__ I'_ n__ g____ t_ l____. 	y e___¡_ c________ c__ e_ g_______! P___ n_ m_ v__ a d____. 
269	1	Dad, don't do anything stupid. If you want, I'll come back to help you.	Papá, no haga ninguna tontería. Si quiere, me regreso para ayudarle.	D__, d__'_ d_ a_______ s_____. I_ y__ w___, I'__ c___ b___ t_ h___ y__. 	P___¡, n_ h___ n______ t______­_. S_ q_____, m_ r______ p___ a_______. 
270	1	No, no, thank you, I know how to take care of myself.	No, no, gracias, sé cuidarme solo.	N_, n_, t____ y__, I k___ h__ t_ t___ c___ o_ m_____. 	N_, n_, g______, s_© c_______ s___. 
271	1	Will Tania listen to me?	Tania me hará caso?	W___ T____ l_____ t_ m_? 	T____ m_ h___¡ c___? 
272	1	Man, you look great.	Hombre, si se te ve estupendo.	M__, y__ l___ g____. 	H_____, s_ s_ t_ v_ e________. 
273	1	Remember, it is very important to make a very good second first impression.	Recuerda, es muy importante causar una muy buena segunda primera impresión.	R_______, i_ i_ v___ i________ t_ m___ a v___ g___ s_____ f____ i_________. 	R_______, e_ m__ i_________ c_____ u__ m__ b____ s______ p______ i_______³_. 
274	1	that a tie cannot fix.	que un lazo no pueda arreglar.	t___ a t__ c_____ f__. 	q__ u_ l___ n_ p____ a_______. 
275	1	Now you know.	Ya lo sabes.	N__ y__ k___. 	Y_ l_ s____. 
276	1	I think I do have very long arms. I told you.	Creo que sí tengo los brazos muy largos. Te lo dije.	I t____ I d_ h___ v___ l___ a___. I t___ y__. 	C___ q__ s_­ t____ l__ b_____ m__ l_____. T_ l_ d___. 
277	1	No, that's fine, so you can give that Tania some hugs, eh?	No, pues está bien, así le das unos abrazotes a la Tania esa, ¿eh?	N_, t___'_ f___, s_ y__ c__ g___ t___ T____ s___ h___, e_? 	N_, p___ e___¡ b___, a__­ l_ d__ u___ a________ a l_ T____ e__, Â¿__? 
278	1	I go for Leo and go down.	Voy por Leo y bajo.	I g_ f__ L__ a__ g_ d___. 	V__ p__ L__ y b___. 
279	1	A pleasure. Thanks for joining us.	Un placer. Gracias por acompañarnos.	A p_______. T_____ f__ j______ u_. 	U_ p_____. G______ p__ a______±_____. 
280	1	Don't worry, everything is perfect. I know, my dad looks very happy.	Tranquila, todo está perfecto. Ya sé, mi papá se ve muy contento.	D__'_ w____, e_________ i_ p______. I k___, m_ d__ l____ v___ h____. 	T________, t___ e___¡ p_______. Y_ s_©, m_ p___¡ s_ v_ m__ c_______. 
281	1	Friend, it's a hundred times better in person.	Amiga, está cien veces mejor en persona.	F_____, i_'_ a h______ t____ b_____ i_ p_____. 	A____, e___¡ c___ v____ m____ e_ p______. 
282	1	Hello. No no. Well, everything turned out very nice.	Hola. No, no. Pues sí quedó bien bonito todo.	H____. N_ n_. W___, e_________ t_____ o__ v___ n___. 	H___. N_, n_. P___ s_­ q____³ b___ b_____ t___. 
283	1	Hi, I'm Brenda and I'm single.	Hola, soy Brenda y estoy soltera.	H_, I'_ B_____ a__ I'_ s_____. 	H___, s__ B_____ y e____ s______. 
284	1	Nice to meet you, Brenda. Mm.	Mucho gusto, Brenda. Mm.	N___ t_ m___ y__, B_____. M_. 	M____ g____, B_____. M_. 
285	1	Um, like why did they dress like that?	Eh, ¿como por qué se vistieron así?	U_, l___ w__ d__ t___ d____ l___ t___? 	E_, Â¿____ p__ q__© s_ v________ a__­? 
286	1	I'm trying something new. Less pink.	Estoy probando algo nuevo. Menos rosa.	I'_ t_____ s________ n__. L___ p___. 	E____ p_______ a___ n____. M____ r___. 
287	1	And I want to make a good impression.	Y yo quiero dar una buena impresión.	A__ I w___ t_ m___ a g___ i_________. 	Y y_ q_____ d__ u__ b____ i_______³_. 
288	1	I always dress the same.	Yo siempre me visto igual.	I a_____ d____ t__ s___. 	Y_ s______ m_ v____ i____. 
289	1	Nice to meet you, I'm Gabriel. Nice to meet you.	Mucho gusto, soy Gabriel. Mucho gusto.	N___ t_ m___ y__, I'_ G______. N___ t_ m___ y__. 	M____ g____, s__ G______. M____ g____. 
290	1	Ernesto Lemus. Nice to meet you.	Ernesto Lemus. Mucho gusto.	E______ L____. N___ t_ m___ y__. 	E______ L____. M____ g____. 
291	1	The children were excited to greet him and congratulate their mother	Los niños estaban emocionados por saludarlo y por felicitar a su madre	T__ c_______ w___ e______ t_ g____ h__ a__ c___________ t____ m_____ 	L__ n__±__ e______ e__________ p__ s________ y p__ f________ a s_ m____ 
292	1	as the new president of the company.	como la nueva presidenta de la empresa.	a_ t__ n__ p________ o_ t__ c______. 	c___ l_ n____ p_________ d_ l_ e______. 
293	1	The appointment will be a surprise.	El nombramiento será una sorpresa.	T__ a__________ w___ b_ a s_______. 	E_ n___________ s___¡ u__ s_______. 
294	1	Although I am glad that Jimena has a suitor	Aunque me da gusto que Jimena tenga un pretendiente	A_______ I a_ g___ t___ J_____ h__ a s_____ 	A_____ m_ d_ g____ q__ J_____ t____ u_ p___________ 
295	1	so that he can take her out of work and be able to dedicate herself to her children.	para que la saque de trabajar y pueda dedicarse a sus hijos.	s_ t___ h_ c__ t___ h__ o__ o_ w___ a__ b_ a___ t_ d_______ h______ t_ h__ c_______. 	p___ q__ l_ s____ d_ t_______ y p____ d________ a s__ h____. 
296	1	Dad, Gabriel is not my boyfriend,	Papá, Gabriel no es mi novio,	D__, G______ i_ n__ m_ b________, 	P___¡, G______ n_ e_ m_ n____, 
297	1	nor am I looking for someone to support me.	ni estoy buscando a alguien que me mantenga.	n__ a_ I l______ f__ s______ t_ s______ m_. 	n_ e____ b_______ a a______ q__ m_ m_______. 
298	1	I love to work.	A mí me encanta trabajar.	I l___ t_ w___. 	A m_­ m_ e______ t_______. 
299	1	So much so that, this year, I took finance to the next level.	Tanto que, este año, llevé la financiera al siguiente nivel.	S_ m___ s_ t___, t___ y___, I t___ f______ t_ t__ n___ l____. 	T____ q__, e___ a_±_, l____© l_ f_________ a_ s________ n____. 
300	1	And I thank you very much, mija.	Y te lo agradezco mucho, mija.	A__ I t____ y__ v___ m___, m___. 	Y t_ l_ a________ m____, m___. 
301	1	Excuse me but I have to leave.	Perdón, pero me tengo que ir.	E_____ m_ b__ I h___ t_ l____. 	P____³_, p___ m_ t____ q__ i_. 
302	1	I'm sure he's going to name that idiot Rogelio.	Seguro va a nombrar al imbécil de Rogelio.	I'_ s___ h_'_ g____ t_ n___ t___ i____ R______. 	S_____ v_ a n______ a_ i___©___ d_ R______. 
303	1	My cousin, who wants to push me aside to show off with my dad	Mi primo, que me quiere hacer a un lado para lucirse con mi papá	M_ c_____, w__ w____ t_ p___ m_ a____ t_ s___ o__ w___ m_ d__ 	M_ p____, q__ m_ q_____ h____ a u_ l___ p___ l______ c__ m_ p___¡ 
304	1	and, apparently, it is working.	y, al parecer, está funcionando.	a__, a_________, i_ i_ w______. 	y, a_ p______, e___¡ f__________. 
305	1	A bad idea to come say hello.	Una pésima idea venir a saludar.	A b__ i___ t_ c___ s__ h____. 	U__ p_©____ i___ v____ a s______. 
306	1	I would have worn something black… like this party.	Me hubiera puesto algo negro… como esta fiesta.	I w____ h___ w___ s________ b_____¦ l___ t___ p____. 	M_ h______ p_____ a___ n_____¦ c___ e___ f_____. 
307	1	Let's see, guys, it's not your fault that my dad doesn't trust me, okay?	A ver, chicos, no es su culpa que mi papá no confíe en mí, ¿okey?	L__'_ s__, g___, i_'_ n__ y___ f____ t___ m_ d__ d____'_ t____ m_, o___? 	A v__, c_____, n_ e_ s_ c____ q__ m_ p___¡ n_ c____­_ e_ m_­, Â¿____? 
308	1	Well, I'm going to continue greeting the guests, and there,	Bueno, voy a seguir saludando a los invitados, y por ahí,	W___, I'_ g____ t_ c_______ g_______ t__ g_____, a__ t____, 	B____, v__ a s_____ s________ a l__ i________, y p__ a__­, 
309	1	jump off a cliff.	aventarme de algún precipicio.	j___ o__ a c____. 	a________ d_ a_____ p_________. 
310	1	Tania has arrived. What I do?	Ya llegó Tania. ¿Qué hago?	T____ h__ a______. W___ I d_? 	Y_ l____³ T____. Â¿___© h___? 
311	1	Well, go say hello to her.	Pues ve a saludarla.	W___, g_ s__ h____ t_ h__. 	P___ v_ a s________. 
312	1	Remember that the suit looks better if you lift your chest,	Recuerda que el traje se ve mejor si levantas el pecho,	R_______ t___ t__ s___ l____ b_____ i_ y__ l___ y___ c____, 	R_______ q__ e_ t____ s_ v_ m____ s_ l_______ e_ p____, 
313	1	you grab the belt.	agarras el cinto.	y__ g___ t__ b___. 	a______ e_ c____. 
314	1	I didn't know the party was a costume party.	No sabía que la fiesta era de disfraces.	I d___'_ k___ t__ p____ w__ a c______ p____. 	N_ s___­_ q__ l_ f_____ e__ d_ d________. 
315	1	Wow, I think I really need something to drink now.	Güey, creo que ahora sí necesito algo de tomar.	W__, I t____ I r_____ n___ s________ t_ d____ n__. 	G_¼__, c___ q__ a____ s_­ n_______ a___ d_ t____. 
316	1	I have something to tell you about Santi.	Tengo algo que decirte de Santi.	I h___ s________ t_ t___ y__ a____ S____. 	T____ a___ q__ d______ d_ S____. 
317	1	of Christian Nodal's band?	de la banda de Christian Nodal?	o_ C________ N____'_ b___? 	d_ l_ b____ d_ C________ N____? 
318	1	No, he is not an ordinary person.	No, que no es una persona común.	N_, h_ i_ n__ a_ o_______ p_____. 	N_, q__ n_ e_ u__ p______ c_____. 
319	1	And it will never cease to surprise you.	Y jamás dejará de sorprenderte.	A__ i_ w___ n____ c____ t_ s_______ y__. 	Y j___¡_ d_____¡ d_ s___________. 
320	1	Well, you are right about that, huh. I better go get my drink.	Pues en eso sí tienes razón, eh. Mejor yo voy por mi drink.	W___, y__ a__ r____ a____ t___, h__. I b_____ g_ g__ m_ d____. 	P___ e_ e__ s_­ t_____ r___³_, e_. M____ y_ v__ p__ m_ d____. 
321	1	Thanks for trying to save me.	Gracias por intentar salvarme.	T_____ f__ t_____ t_ s___ m_. 	G______ p__ i_______ s_______. 
322	1	I don't want Leo to push me out of my wheelchair when I'm old.	No quiero que Leo me empuje de la silla de ruedas cuando esté viejita.	I d__'_ w___ L__ t_ p___ m_ o__ o_ m_ w_________ w___ I'_ o__. 	N_ q_____ q__ L__ m_ e_____ d_ l_ s____ d_ r_____ c_____ e___© v______. 
323	1	We can't let Rogelio take my mom's job.	No podemos dejar que Rogelio le quite el puesto a mi mamá.	W_ c__'_ l__ R______ t___ m_ m__'_ j__. 	N_ p______ d____ q__ R______ l_ q____ e_ p_____ a m_ m___¡. 
324	1	He deserves it more than anyone.	Se lo merece más que nadie.	H_ d_______ i_ m___ t___ a_____. 	S_ l_ m_____ m_¡_ q__ n____. 
325	1	You have to convince your grandfather	Hay que convencer a su abuelo	Y__ h___ t_ c_______ y___ g__________ 	H__ q__ c________ a s_ a_____ 
326	1	that his mother is the best candidate.	de que su mamá es la mejor candidata.	t___ h__ m_____ i_ t__ b___ c________. 	d_ q__ s_ m___¡ e_ l_ m____ c________. 
327	1	But how? If you don't listen to us.	Pero ¿cómo? Si no nos hace caso.	B__ h__? I_ y__ d__'_ l_____ t_ u_. 	P___ Â¿__³__? S_ n_ n__ h___ c___. 
328	1	I don't know. You have to think of something to make him listen to them.	No sé. Hay que pensar en algo para que los escuche.	I d__'_ k___. Y__ h___ t_ t____ o_ s________ t_ m___ h__ l_____ t_ t___. 	N_ s_©. H__ q__ p_____ e_ a___ p___ q__ l__ e______. 
329	1	Thank you very much for being here.	Muchas gracias por estar aquí.	T____ y__ v___ m___ f__ b____ h___. 	M_____ g______ p__ e____ a___­. 
330	1	This meal is especially important to me, because,	Esta comida es especialmente importante para mí, porque,	T___ m___ i_ e_________ i________ t_ m_, b______, 	E___ c_____ e_ e____________ i_________ p___ m_­, p_____, 
331	1	As many of you know,	como muchos de ustedes saben,	A_ m___ o_ y__ k___, 	c___ m_____ d_ u______ s____, 
332	1	Today I formally announce my withdrawal from this financial institution that I started	hoy anuncio formalmente mi retiro de esta financiera que yo inicié	T____ I f_______ a_______ m_ w_________ f___ t___ f________ i__________ t___ I s______ 	h__ a______ f__________ m_ r_____ d_ e___ f_________ q__ y_ i_____© 
333	1	When, one day, I lent my savings to my brother, may he rest in peace,	cuando, un día, le presté mis ahorros a mi hermano, que en paz descanse,	W___, o__ d__, I l___ m_ s______ t_ m_ b______, m__ h_ r___ i_ p____, 	c_____, u_ d_­_, l_ p_____© m__ a______ a m_ h______, q__ e_ p__ d_______, 
334	1	to buy a bicycle.	para que comprara una bicicleta.	t_ b__ a b______. 	p___ q__ c_______ u__ b________. 
335	1	Today is a special day.	Hoy es un día especial.	T____ i_ a s______ d__. 	H__ e_ u_ d_­_ e_______. 
336	1	I must leave and entrust my successor	Debo irme y confiar a mi sucesor	I m___ l____ a__ e______ m_ s________ 	D___ i___ y c______ a m_ s______ 
337	1	this finance that has been very important in my life.	esta financiera que ha sido muy importante en mi vida.	t___ f______ t___ h__ b___ v___ i________ i_ m_ l___. 	e___ f_________ q__ h_ s___ m__ i_________ e_ m_ v___. 
338	1	Jimena, my mother, is the hardest working woman there is.	Jimena, mi mamá, es la mujer más trabajadora que existe.	J_____, m_ m_____, i_ t__ h______ w______ w____ t____ i_. 	J_____, m_ m___¡, e_ l_ m____ m_¡_ t__________ q__ e_____. 
339	1	And also the best mom in the world.	Y también la mejor mamá del mundo.	A__ a___ t__ b___ m__ i_ t__ w____. 	Y t_____©_ l_ m____ m___¡ d__ m____. 
340	1	That is why Jimena Lemus deserves to be the new president of the financial company.	Por eso es que Jimena Lemus merece ser la nueva presidenta de la financiera.	T___ i_ w__ J_____ L____ d_______ t_ b_ t__ n__ p________ o_ t__ f________ c______. 	P__ e__ e_ q__ J_____ L____ m_____ s__ l_ n____ p_________ d_ l_ f_________. 
341	1	My daughter is not spoiled.	Mi hija no es ninguna malcriada.	M_ d_______ i_ n__ s______. 	M_ h___ n_ e_ n______ m________. 
342	1	Take it down from there. This is a serious event. Thanks for the support.	Bájala de ahí. Este es un evento serio. Muchas gracias por el apoyo.	T___ i_ d___ f___ t____. T___ i_ a s______ e____. T_____ f__ t__ s______. 	B_¡____ d_ a__­. E___ e_ u_ e_____ s____. M_____ g______ p__ e_ a____. 
343	1	Thank you so much. What nice words, guys, but...	Muchas gracias. Qué lindas palabras, chicos, pero…	T____ y__ s_ m___. W___ n___ w____, g___, b__... 	M_____ g______. Q__© l_____ p_______, c_____, p____¦ 
344	1	It is not Jimena who I am going to name,	no es a Jimena a quien voy a nombrar,	I_ i_ n__ J_____ w__ I a_ g____ t_ n___, 	n_ e_ a J_____ a q____ v__ a n______, 
345	1	but to Rogelio.	sino a Rogelio.	b__ t_ R______. 	s___ a R______. 
346	1	Roger, right? Nice to meet you. Are you OK?	Rogelio, ¿verdad? Mucho gusto. ¿Estás bien?	R____, r____? N___ t_ m___ y__. A__ y__ O_? 	R______, Â¿______? M____ g____. Â¿____¡_ b___? 
347	1	Don't even think you're going to boycott my appointment.	Ni creas que vas a boicotear mi nombramiento.	D__'_ e___ t____ y__'__ g____ t_ b______ m_ a__________. 	N_ c____ q__ v__ a b________ m_ n___________. 
348	1	You see, there's nothing a lasso can't fix. Thank you.	Como ven, no hay nada que un lazo no pueda arreglar. Gracias.	Y__ s__, t____'_ n______ a l____ c__'_ f__. T____ y__. 	C___ v__, n_ h__ n___ q__ u_ l___ n_ p____ a_______. G______. 
349	1	that illuminates my path!	que ilumina mi sendero!	t___ i__________ m_ p___! 	q__ i______ m_ s______! 
350	1	I understand that they wanted to help me, but it is not right to harass people.	Entiendo que me hayan querido ayudar, pero no está bien lazar a la gente.	I u_________ t___ t___ w_____ t_ h___ m_, b__ i_ i_ n__ r____ t_ h_____ p_____. 	E_______ q__ m_ h____ q______ a_____, p___ n_ e___¡ b___ l____ a l_ g____. 
351	1	And they got everyone wet. Jime, don't scold them.	Y mojaron a todos. Jime, no los regañes.	A__ t___ g__ e_______ w__. J___, d__'_ s____ t___. 	Y m______ a t____. J___, n_ l__ r____±__. 
352	1	It wasn't his fault, it was all my idea.	No fue su culpa, todo fue idea mía.	I_ w___'_ h__ f____, i_ w__ a__ m_ i___. 	N_ f__ s_ c____, t___ f__ i___ m_­_. 
353	1	who is a partner of the company!	que es socio de la empresa!	w__ i_ a p______ o_ t__ c______! 	q__ e_ s____ d_ l_ e______! 
354	1	He spoke badly about the children the entire party.	Habló mal de los niños toda la fiesta.	H_ s____ b____ a____ t__ c_______ t__ e_____ p____. 	H____³ m__ d_ l__ n__±__ t___ l_ f_____. 
355	1	Gabriel, not you. Come back, I want to talk to you.	Gabriel, tú no. Regrésate que quiero hablar contigo.	G______, n__ y__. C___ b___, I w___ t_ t___ t_ y__. 	G______, t__ n_. R____©____ q__ q_____ h_____ c______. 
356	1	Jime, it doesn't seem fair to me that that guy, Rogelio, steals your opportunity to be	Jime, no se me hace justo que el tipo ese, Rogelio, te robe la oportunidad de ser	J___, i_ d____'_ s___ f___ t_ m_ t___ t___ g__, R______, s_____ y___ o__________ t_ b_ 	J___, n_ s_ m_ h___ j____ q__ e_ t___ e__, R______, t_ r___ l_ o__________ d_ s__ 
357	1	president of your family company just because, what? Is a man?	presidenta de la empresa de tu familia solo porque, ¿qué? ¿Es hombre?	p________ o_ y___ f_____ c______ j___ b______, w___? I_ a m__? 	p_________ d_ l_ e______ d_ t_ f______ s___ p_____, Â¿___©? Â¿__ h_____? 
358	1	Much less will my dad want me to be the president	Mucho menos querrá mi papá que sea la presidenta	M___ l___ w___ m_ d__ w___ m_ t_ b_ t__ p________ 	M____ m____ q_____¡ m_ p___¡ q__ s__ l_ p_________ 
359	1	after they wet the board of directors.	después de que mojaron al consejo directivo.	a____ t___ w__ t__ b____ o_ d________. 	d_____©_ d_ q__ m______ a_ c______ d________. 
360	1	You're right. And that was not in the plan, Leo overdid it.	Tienes razón. Y eso no estaba en el plan, a Leo se le pasó la mano.	Y__'__ r____. A__ t___ w__ n__ i_ t__ p___, L__ o______ i_. 	T_____ r___³_. Y e__ n_ e_____ e_ e_ p___, a L__ s_ l_ p___³ l_ m___. 
361	1	Look, it's not bad vibes, Gaby, but the truth is this isn't going to work.	Mira, no es mala onda, Gaby, pero la verdad esto no va a funcionar.	L___, i_'_ n__ b__ v____, G___, b__ t__ t____ i_ t___ i__'_ g____ t_ w___. 	M___, n_ e_ m___ o___, G___, p___ l_ v_____ e___ n_ v_ a f________. 
362	1	I can't concentrate?	que no me puedo concentrar?	I c__'_ c__________? 	q__ n_ m_ p____ c_________? 
363	1	I can't fire you when your sixpack is looking me in the eyes.	No te puedo despedir cuando tu sixpack me está viendo a los ojos.	I c__'_ f___ y__ w___ y___ s______ i_ l______ m_ i_ t__ e___. 	N_ t_ p____ d_______ c_____ t_ s______ m_ e___¡ v_____ a l__ o___. 
364	1	I'm sorry, Gaby, but...	Lo siento, Gaby, pero…	I'_ s____, G___, b__... 	L_ s_____, G___, p____¦ 
365	1	I don't think a cowboy can be my children's nano.	yo no creo que un vaquero pueda ser el nano de mis hijos.	I d__'_ t____ a c_____ c__ b_ m_ c_______'_ n___. 	y_ n_ c___ q__ u_ v______ p____ s__ e_ n___ d_ m__ h____. 
366	1	My children need a motherly woman, a loving woman,	Mis hijos necesitan a una mujer maternal, a una mujer cariñosa,	M_ c_______ n___ a m_______ w____, a l_____ w____, 	M__ h____ n________ a u__ m____ m_______, a u__ m____ c____±___, 
367	1	a woman of the house	una mujer de casa.	a w____ o_ t__ h____ 	u__ m____ d_ c___. 
368	1	Because I can't be,	Porque yo no puedo serlo,	B______ I c__'_ b_, 	P_____ y_ n_ p____ s____, 
369	1	no matter how hard I try.	por más que yo lo intente.	n_ m_____ h__ h___ I t__. 	p__ m_¡_ q__ y_ l_ i______. 
370	1	At least, not at this moment.	Al menos, no en este momento.	A_ l____, n__ a_ t___ m_____. 	A_ m____, n_ e_ e___ m______. 
371	1	My dad wants me on the ranch taking care of pigs,	Mi papá me quiere en el rancho cuidando puercos,	M_ d__ w____ m_ o_ t__ r____ t_____ c___ o_ p___, 	M_ p___¡ m_ q_____ e_ e_ r_____ c_______ p______, 
372	1	and your dad wants you at home taking care of orchards.	y tu papá te quiere en la casa cuidando huercos.	a__ y___ d__ w____ y__ a_ h___ t_____ c___ o_ o_______. 	y t_ p___¡ t_ q_____ e_ l_ c___ c_______ h______. 
373	1	Yes, I guess it's not easy to change the world.	Sí, supongo que no está fácil cambiar el mundo.	Y__, I g____ i_'_ n__ e___ t_ c_____ t__ w____. 	S_­, s______ q__ n_ e___¡ f_¡___ c______ e_ m____. 
374	1	At least, not for us.	Al menos, no para nosotros.	A_ l____, n__ f__ u_. 	A_ m____, n_ p___ n_______. 
375	1	But for the children, Jime?	Pero ¿para los niños, Jime?	B__ f__ t__ c_______, J___? 	P___ Â¿____ l__ n__±__, J___? 
376	1	For them it is different.	Para ellos es diferente.	F__ t___ i_ i_ d________. 	P___ e____ e_ d________. 
377	1	And that's why I love being a nano, you know?	Y yo, yo por eso amo ser nano, ¿sabes?	A__ t___'_ w__ I l___ b____ a n___, y__ k___? 	Y y_, y_ p__ e__ a__ s__ n___, Â¿_____? 
378	1	No, it's not criticism. No.	No, no es crítica. No.	N_, i_'_ n__ c________. N_. 	N_, n_ e_ c__­____. N_. 
379	1	about the rancher suit?	lo del traje de ranchero?	a____ t__ r______ s___? 	l_ d__ t____ d_ r_______? 
380	1	Not even a story on their networks.	Ni siquiera una story en sus redes.	N__ e___ a s____ o_ t____ n_______. 	N_ s_______ u__ s____ e_ s__ r____. 
381	1	Being ignored is worse than being trolled.	Ser ignorado es peor que ser troleado.	B____ i______ i_ w____ t___ b____ t______. 	S__ i_______ e_ p___ q__ s__ t_______. 
382	1	Well, maybe it's because he's three years older than you.	Bueno, tal vez es porque es tres años mayor que tú.	W___, m____ i_'_ b______ h_'_ t____ y____ o____ t___ y__. 	B____, t__ v__ e_ p_____ e_ t___ a_±__ m____ q__ t__. 
383	1	I can't sleep.	No puedo dormir.	I c__'_ s____. 	N_ p____ d_____. 
384	1	There's a pig-headed Rogelio hiding in my closet.	Hay un Rogelio con cabeza de cerdo escondido en mi clóset.	T____'_ a p__-______ R______ h_____ i_ m_ c_____. 	H__ u_ R______ c__ c_____ d_ c____ e________ e_ m_ c__³___. 
385	1	And as soon as it appears, you throw it at once?	y, en cuanto aparezca, lo avientas de una?	A__ a_ s___ a_ i_ a______, y__ t____ i_ a_ o___? 	y, e_ c_____ a_______, l_ a_______ d_ u__? 
386	1	No, because he never actually hired me.	No, porque, en realidad, nunca me contrató.	N_, b______ h_ n____ a_______ h____ m_. 	N_, p_____, e_ r_______, n____ m_ c_______³. 
387	1	Of course.	Por supuesto que sí.	O_ c_____. 	P__ s_______ q__ s_­. 
388	1	You are every mother. Hmm?	Ustedes son a toda madre. ¿Mm?	Y__ a__ e____ m_____. H__? 	U______ s__ a t___ m____. Â¿__? 
389	1	But I must return to Tepa while I get another job.	Pero debo regresar a Tepa en lo que consigo otro trabajo.	B__ I m___ r_____ t_ T___ w____ I g__ a______ j__. 	P___ d___ r_______ a T___ e_ l_ q__ c______ o___ t______. 
390	1	I don't know, my Leo, because I screwed up with my dad,	No lo sé, mi Leo, porque metí la pata con mi papá,	I d__'_ k___, m_ L__, b______ I s______ u_ w___ m_ d__, 	N_ l_ s_©, m_ L__, p_____ m___­ l_ p___ c__ m_ p___¡, 
391	1	and he's not very happy with me.	y no está muy contento conmigo.	a__ h_'_ n__ v___ h____ w___ m_. 	y n_ e___¡ m__ c_______ c______. 
392	1	I promise you that I will try to make him forgive me.	Les prometo que le echaré ganas para que me perdone	I p______ y__ t___ I w___ t__ t_ m___ h__ f______ m_. 	L__ p______ q__ l_ e_____© g____ p___ q__ m_ p______ 
393	1	and return as soon as possible.	y regresar lo más pronto posible.	a__ r_____ a_ s___ a_ p_______. 	y r_______ l_ m_¡_ p_____ p______. 
394	1	And if you want, I'll come visit you.	Y si quieren, los paso a visitar.	A__ i_ y__ w___, I'__ c___ v____ y__. 	Y s_ q______, l__ p___ a v______. 
395	1	We are going to miss you a lot.	Te vamos a extrañar mucho.	W_ a__ g____ t_ m___ y__ a l__. 	T_ v____ a e_____±__ m____. 
396	1	Jimena, what are you doing here so early?	Jimena, ¿qué haces aquí tan temprano?	J_____, w___ a__ y__ d____ h___ s_ e____? 	J_____, Â¿___© h____ a___­ t__ t_______? 
397	1	I'm very sorry for what happened yesterday at the party,	Siento mucho lo que pasó ayer en la fiesta,	I'_ v___ s____ f__ w___ h_______ y________ a_ t__ p____, 	S_____ m____ l_ q__ p___³ a___ e_ l_ f_____, 
398	1	but my children taught me a great lesson,	pero mis hijos me dieron una gran lección,	b__ m_ c_______ t_____ m_ a g____ l_____, 	p___ m__ h____ m_ d_____ u__ g___ l_____³_, 
399	1	and more than my children,	y más que mis hijos,	a__ m___ t___ m_ c_______, 	y m_¡_ q__ m__ h____, 
400	1	my children's nano.	el nano de mis hijos.	m_ c_______'_ n___. 	e_ n___ d_ m__ h____. 
401	1	Then I'll explain to you.	Luego te explico.	T___ I'__ e______ t_ y__. 	L____ t_ e______. 
402	1	I'm here to tell you	Estoy aquí para decirte	I'_ h___ t_ t___ y__ 	E____ a___­ p___ d______ 
403	1	I am very sorry for not having been a man.	que siento mucho no haber sido hombre.	I a_ v___ s____ f__ n__ h_____ b___ a m__. 	q__ s_____ m____ n_ h____ s___ h_____. 
404	1	And I'm very sorry for not being what you want me to be,	Y siento mucho no ser lo que tú quieres que yo sea,	A__ I'_ v___ s____ f__ n__ b____ w___ y__ w___ m_ t_ b_, 	Y s_____ m____ n_ s__ l_ q__ t__ q______ q__ y_ s__, 
405	1	and I am very sorry that I like to work, and that...	y siento mucho que me guste trabajar, y que…	a__ I a_ v___ s____ t___ I l___ t_ w___, a__ t___... 	y s_____ m____ q__ m_ g____ t_______, y q___¦ 
406	1	Sometimes I feel like crying when I get frustrated, angry...	que a veces me den ganas de llorar cuando me frustro, me enojo…	S________ I f___ l___ c_____ w___ I g__ f_________, a____... 	q__ a v____ m_ d__ g____ d_ l_____ c_____ m_ f______, m_ e_____¦ 
407	1	or whatever.	o lo que sea.	o_ w_______. 	o l_ q__ s__. 
408	1	But being the president of this company is my dream,	Pero ser la presidenta de esta empresa es mi sueño,	B__ b____ t__ p________ o_ t___ c______ i_ m_ d____, 	P___ s__ l_ p_________ d_ e___ e______ e_ m_ s___±_, 
409	1	and you know I'm the best for the job.	y tú sabes que soy la mejor para el puesto.	a__ y__ k___ I'_ t__ b___ f__ t__ j__. 	y t__ s____ q__ s__ l_ m____ p___ e_ p_____. 
410	1	It doesn't seem fair to me that you don't want to give me the opportunity because I'm a woman.	No me parece justo que no me quieras dar la oportunidad por ser mujer.	I_ d____'_ s___ f___ t_ m_ t___ y__ d__'_ w___ t_ g___ m_ t__ o__________ b______ I'_ a w____. 	N_ m_ p_____ j____ q__ n_ m_ q______ d__ l_ o__________ p__ s__ m____. 
411	1	It's not that, daughter.	No es eso, hija.	I_'_ n__ t___, d_______. 	N_ e_ e__, h___. 
412	1	I just don't want you to be alone.	Es que no quiero que te quedes sola.	I j___ d__'_ w___ y__ t_ b_ a____. 	E_ q__ n_ q_____ q__ t_ q_____ s___. 
413	1	And a woman like you scares men away.	Y una mujer como tú espanta a los hombres.	A__ a w____ l___ y__ s_____ m__ a___. 	Y u__ m____ c___ t__ e______ a l__ h______. 
414	1	I don't need any man by my side, dad.	No necesito ningún hombre a mi lado, papá.	I d__'_ n___ a__ m__ b_ m_ s___, d__. 	N_ n_______ n______ h_____ a m_ l___, p___¡. 
415	1	That's what you think. I'm sure about that.	Eso es lo que tú crees. Estoy segura de eso.	T___'_ w___ y__ t____. I'_ s___ a____ t___. 	E__ e_ l_ q__ t__ c____. E____ s_____ d_ e__. 
416	1	But you know what?	Pero ¿sabes qué?	B__ y__ k___ w___? 	P___ Â¿_____ q__©? 
417	1	That you don't have to worry about that anymore,	Que ya no tienes que preocuparte por eso,	T___ y__ d__'_ h___ t_ w____ a____ t___ a______, 	Q__ y_ n_ t_____ q__ p__________ p__ e__, 
418	1	because I come to resign.	porque vengo a renunciar.	b______ I c___ t_ r_____. 	p_____ v____ a r________. 
419	1	I'm going to look for opportunities elsewhere.	Voy a buscar oportunidades en otros lados.	I'_ g____ t_ l___ f__ o____________ e________. 	V__ a b_____ o____________ e_ o____ l____. 
420	1	I love you Papa.	Te quiero, papá.	I l___ y__ P___. 	T_ q_____, p___¡. 
421	1	I did everything to get him to hire me, godmother, really.	Hice de todo para que me contratara, madrina, de verdad.	I d__ e_________ t_ g__ h__ t_ h___ m_, g________, r_____. 	H___ d_ t___ p___ q__ m_ c_________, m______, d_ v_____. 
422	1	Well, I even cried.	Bueno, hasta lloré.	W___, I e___ c____. 	B____, h____ l____©. 
423	1	Oh, Gabriel, you can't give up, your dad won't forgive you.	Ay, Gabriel, no te puedes dar por vencido, tu papá no te va a perdonar.	O_, G______, y__ c__'_ g___ u_, y___ d__ w__'_ f______ y__. 	A_, G______, n_ t_ p_____ d__ p__ v______, t_ p___¡ n_ t_ v_ a p_______. 
424	1	I already know it. For now, I'm going to return to Tepa to see what I do from there.	Ya lo sé. Por ahora, me voy a regresar a Tepa a ver qué hago desde allá.	I a______ k___ i_. F__ n__, I'_ g____ t_ r_____ t_ T___ t_ s__ w___ I d_ f___ t____. 	Y_ l_ s_©. P__ a____, m_ v__ a r_______ a T___ a v__ q__© h___ d____ a___¡. 
425	1	I don't know who is behind this,	No sé quién esté detrás de esto,	I d__'_ k___ w__ i_ b_____ t___, 	N_ s_© q___©_ e___© d____¡_ d_ e___, 
426	1	but in no way will I allow them to take away our ranch.	pero de ninguna manera permitiré que nos quiten el rancho.	b__ i_ n_ w__ w___ I a____ t___ t_ t___ a___ o__ r____. 	p___ d_ n______ m_____ p________© q__ n__ q_____ e_ r_____. 
427	1	God bless me.	Dios me lo bendiga.	G__ b____ m_. 	D___ m_ l_ b______. 
428	1	I'll let you know when I arrive, godmother.	Le aviso cuando llegue, madrina.	I'__ l__ y__ k___ w___ I a_____, g________. 	L_ a____ c_____ l_____, m______. 
429	1	I resigned, I'm unemployed.	Renuncié, estoy desempleada.	I r_______, I'_ u_________. 	R_______©, e____ d__________. 
430	1	I told you.	Te lo dije.	I t___ y__. 	T_ l_ d___. 
431	1	I quit, and now, they are best friends.	Yo renuncio, y ahora, son los mejores amigos.	I q___, a__ n__, t___ a__ b___ f______. 	Y_ r_______, y a____, s__ l__ m______ a_____. 
432	1	Tania says she had an incredible time at the party,	Tania dice que se la pasó increíble en la fiesta,	T____ s___ s__ h__ a_ i_________ t___ a_ t__ p____, 	T____ d___ q__ s_ l_ p___³ i_____­___ e_ l_ f_____, 
433	1	and now, he wants to go out with me on a date.	y ahora, quiere salir conmigo en un date.	a__ n__, h_ w____ t_ g_ o__ w___ m_ o_ a d___. 	y a____, q_____ s____ c______ e_ u_ d___. 
434	1	Tania was the one who didn't pay attention to him.	Tania era la que no le hacía caso.	T____ w__ t__ o__ w__ d___'_ p__ a________ t_ h__. 	T____ e__ l_ q__ n_ l_ h___­_ c___. 
435	1	I promise I'll push your wheelchair for you.	Prometo que te empujaré la silla de ruedas.	I p______ I'__ p___ y___ w_________ f__ y__. 	P______ q__ t_ e_______© l_ s____ d_ r_____. 
436	1	Martha, did you put strawberries in my lunchbox?	Martha, ¿pusiste fresas en mi lonchera?	M_____, d__ y__ p__ s___________ i_ m_ l_______? 	M_____, Â¿_______ f_____ e_ m_ l_______? 
437	1	It's not always the best for me.	No siempre es lo mejor para mí.	I_'_ n__ a_____ t__ b___ f__ m_. 	N_ s______ e_ l_ m____ p___ m_­. 
438	1	See you in the afternoon, ma.	Nos vemos en la tarde, ma.	S__ y__ i_ t__ a________, m_. 	N__ v____ e_ l_ t____, m_. 
439	1	Wow, I haven't seen them this happy in a long time.	Guau, hace mucho que no los veía así de contentos.	W__, I h____'_ s___ t___ t___ h____ i_ a l___ t___. 	G___, h___ m____ q__ n_ l__ v__­_ a__­ d_ c________. 
440	1	And Gaby only took care of them for one day.	Y eso que Gaby solamente los cuidó un día.	A__ G___ o___ t___ c___ o_ t___ f__ o__ d__. 	Y e__ q__ G___ s________ l__ c____³ u_ d_­_. 
441	1	to fight for the presidency.	de pelear por la presidencia.	t_ f____ f__ t__ p_________. 	d_ p_____ p__ l_ p__________. 
442	1	to be the president of the company!	para ser la presidenta de la empresa!	t_ b_ t__ p________ o_ t__ c______! 	p___ s__ l_ p_________ d_ l_ e______! 
443	1	Return your buttocks immediately before your dad regrets it.	Regresa tus nalgas inmediatamente antes de que tu papá se arrepienta.	R_____ y___ b_______ i__________ b_____ y___ d__ r______ i_. 	R______ t__ n_____ i_____________ a____ d_ q__ t_ p___¡ s_ a_________. 
444	1	You will compete against Rogelio for the presidency.	Competirás contra Rogelio por la presidencia.	Y__ w___ c______ a______ R______ f__ t__ p_________. 	C________¡_ c_____ R______ p__ l_ p__________. 
445	1	Hurry up, your dad wants to have a meeting with you two now.	Apúrate, tu papá quiere tener una junta con ustedes dos ahora.	H____ u_, y___ d__ w____ t_ h___ a m______ w___ y__ t__ n__. 	A_______, t_ p___¡ q_____ t____ u__ j____ c__ u______ d__ a____. 
446	1	But I can't, I don't have anyone to leave the children with.	Pero es que no puedo, no tengo con quien dejar a los niños.	B__ I c__'_, I d__'_ h___ a_____ t_ l____ t__ c_______ w___. 	P___ e_ q__ n_ p____, n_ t____ c__ q____ d____ a l__ n__±__. 
447	1	I need a lullaby. I already had a nano.	Necesito una nana. Ya tenía un nano.	I n___ a l______. I a______ h__ a n___. 	N_______ u__ n___. Y_ t___­_ u_ n___. 
448	1	I hate what I'm going to say right now, but I need that man by my side.	Odio lo que voy a decir en este momento, pero necesito a ese hombre a mi lado.	I h___ w___ I'_ g____ t_ s__ r____ n__, b__ I n___ t___ m__ b_ m_ s___. 	O___ l_ q__ v__ a d____ e_ e___ m______, p___ n_______ a e__ h_____ a m_ l___. 
449	1	He left early for the station.	Se fue temprano a la estación.	H_ l___ e____ f__ t__ s______. 	S_ f__ t_______ a l_ e______³_. 
450	1	Maybe it will be enough. His truck passes in an hour.	A lo mejor lo alcanza. Su camión pasa en una hora.	M____ i_ w___ b_ e_____. H__ t____ p_____ i_ a_ h___. 	A l_ m____ l_ a______. S_ c____³_ p___ e_ u__ h___. 
451	1	I'll take care of your dad, go get the nano.	Yo me encargo de tu papá, ve por el nano.	I'__ t___ c___ o_ y___ d__, g_ g__ t__ n___. 	Y_ m_ e______ d_ t_ p___¡, v_ p__ e_ n___. 
452	1	Tell him anything.	Dile lo que sea.	T___ h__ a_______. 	D___ l_ q__ s__. 
453	1	That it went down on you and you were hormonal, that's why you ran it.	Que te bajó y estabas hormonal, por eso lo corriste.	T___ i_ w___ d___ o_ y__ a__ y__ w___ h_______, t___'_ w__ y__ r__ i_. 	Q__ t_ b___³ y e______ h_______, p__ e__ l_ c_______. 
454	1	You can bring him this bag with rags that you left forgotten.	Le puede llevar este guacal con trapos que dejó olvidado.	Y__ c__ b____ h__ t___ b__ w___ r___ t___ y__ l___ f________. 	L_ p____ l_____ e___ g_____ c__ t_____ q__ d___³ o_______. 
455	1	Whatever, Jimena. Hurry up.	Lo que sea, Jimena. Apúrate.	W_______, J_____. H____ u_. 	L_ q__ s__, J_____. A_______. 
456	1	Yes Yes. Well bye.	Sí, sí. Bueno, bye.	Y__ Y__. W___ b__. 	S_­, s_­. B____, b__. 
457	1	to Tepatitlán, go to platform 7.	a Tepatitlán, pasar al andén 7.	t_ T________¡_, g_ t_ p_______ 7. 	a T________¡_, p____ a_ a___©_ 7. 
458	1	Leaving, second platform.	Saliendo, segundo andén.	L______, s_____ p_______. 	S_______, s______ a___©_. 
459	1	Please, I just have to hand this over. A second, please.	Por favor, nada más debo entregar esto. Un segundo, por favor.	P_____, I j___ h___ t_ h___ t___ o___. A s_____, p_____. 	P__ f____, n___ m_¡_ d___ e_______ e___. U_ s______, p__ f____. 
460	1	Let her pass, my Johnny. Thank you.	Déjala pasar, mi Johnny. Gracias.	L__ h__ p___, m_ J_____. T____ y__. 	D_©____ p____, m_ J_____. G______. 
461	1	You forgot your crate with everything and rags.	Se te olvidó tu guacal con todo y trapos.	Y__ f_____ y___ c____ w___ e_________ a__ r___. 	S_ t_ o_____³ t_ g_____ c__ t___ y t_____. 
462	1	Yeah, that's why I got off the truck, I saw you running with this.	Sí, por eso me bajé del camión, te vi corriendo con esto.	Y___, t___'_ w__ I g__ o__ t__ t____, I s__ y__ r______ w___ t___. 	S_­, p__ e__ m_ b___© d__ c____³_, t_ v_ c________ c__ e___. 
463	1	My dad will give me the opportunity to fight for the presidency.	Mi papá me dará la oportunidad de pelear por la presidencia.	M_ d__ w___ g___ m_ t__ o__________ t_ f____ f__ t__ p_________. 	M_ p___¡ m_ d___¡ l_ o__________ d_ p_____ p__ l_ p__________. 
464	1	I believe that we can change the world...	Yo creo que sí podemos cambiar al mundo…	I b______ t___ w_ c__ c_____ t__ w____... 	Y_ c___ q__ s_­ p______ c______ a_ m_____¦ 
465	1	I need you more than ever, Gabriel.	Te necesito más que nunca, Gabriel.	I n___ y__ m___ t___ e___, G______. 	T_ n_______ m_¡_ q__ n____, G______. 
466	1	My children are different since you arrived.	Mis hijos son otros desde que llegaste.	M_ c_______ a__ d________ s____ y__ a______. 	M__ h____ s__ o____ d____ q__ l_______. 
467	1	So, if you want, you can stay in the house with everything and… your crate.	Así que, si quieres, te puedes quedar en la casa con todo y… tu guacal.	S_, i_ y__ w___, y__ c__ s___ i_ t__ h____ w___ e_________ a___¦ y___ c____. 	A__­ q__, s_ q______, t_ p_____ q_____ e_ l_ c___ c__ t___ y_¦ t_ g_____. 
468	1	Thanks, Jim. That guacal means a lot to me…	Gracias, Jime. Ese guacal significa mucho para mí…	T_____, J__. T___ g_____ m____ a l__ t_ m__¦ 	G______, J___. E__ g_____ s________ m____ p___ m_­_¦ 
469	1	and for Arete.	y para Arete.	a__ f__ A____. 	y p___ A____. 
470	1	She more than anyone would like to stay.	Ella más que nadie quisiera quedarse.	S__ m___ t___ a_____ w____ l___ t_ s___. 	E___ m_¡_ q__ n____ q_______ q_______. 
471	1	Yes Yes Yes.	Sí. Sí, sí.	Y__ Y__ Y__. 	S_­. S_­, s_­. 
472	1	I also want him… to stay.	Yo también quiero que… que se quede.	I a___ w___ h___¦ t_ s___. 	Y_ t_____©_ q_____ q___¦ q__ s_ q____. 
473	1	Well, Arete, now we do have work, eh?	Pues bueno, Arete, ahora sí tenemos trabajo, ¿eh?	W___, A____, n__ w_ d_ h___ w___, e_? 	P___ b____, A____, a____ s_­ t______ t______, Â¿__? 
474	1	They already burned my cellar.	Ya me quemaron la bodega.	T___ a______ b_____ m_ c_____. 	Y_ m_ q_______ l_ b_____. 
475	1	If you don't pay us,	Si no nos paga,	I_ y__ d__'_ p__ u_, 	S_ n_ n__ p___, 
476	1	We are going to burn his fucking ranch.	le vamos a quemar su pinche rancho.	W_ a__ g____ t_ b___ h__ f______ r____. 	l_ v____ a q_____ s_ p_____ r_____. 
477	1	I'm not going to give up!	no me voy a rendir!	I'_ n__ g____ t_ g___ u_! 	n_ m_ v__ a r_____! 
478	1	So let's see how we turn out.	Así que a ver cómo nos toca.	S_ l__'_ s__ h__ w_ t___ o__. 	A__­ q__ a v__ c_³__ n__ t___. 
479	1	Will I be able to handle all this?	vaya a poder con todo esto?	W___ I b_ a___ t_ h_____ a__ t___? 	v___ a p____ c__ t___ e___? 
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
\\x73459ce520aed45fa10682819fe3f75f2ad02ddb94812c5fae007a4578512877	1	2024-08-06 19:23:12+00	activation
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.users (id, movie_id, name, email, hashed_password, flipped, created, language_id, activated, version) FROM stdin;
1	1	user1	user1@email.com	\\x243261243132247535444165613475364f47434d72565a7077774437754b506d4639316b3057433936482e735a57517343414850323738547a436565	f	2024-08-05 19:23:12	109	t	3
\.


--
-- Data for Name: users_phrases; Type: TABLE DATA; Schema: public; Owner: talkliketv
--

COPY public.users_phrases (user_id, phrase_id, movie_id, phrase_correct, flipped_correct) FROM stdin;
1	2	1	0	0
1	3	1	0	0
1	4	1	0	0
1	5	1	0	0
1	6	1	0	0
1	7	1	0	0
1	8	1	0	0
1	9	1	0	0
1	10	1	0	0
1	11	1	0	0
1	12	1	0	0
1	13	1	0	0
1	14	1	0	0
1	15	1	0	0
1	16	1	0	0
1	17	1	0	0
1	18	1	0	0
1	19	1	0	0
1	20	1	0	0
1	21	1	0	0
1	22	1	0	0
1	23	1	0	0
1	24	1	0	0
1	25	1	0	0
1	26	1	0	0
1	27	1	0	0
1	28	1	0	0
1	29	1	0	0
1	30	1	0	0
1	31	1	0	0
1	32	1	0	0
1	33	1	0	0
1	34	1	0	0
1	35	1	0	0
1	36	1	0	0
1	37	1	0	0
1	38	1	0	0
1	39	1	0	0
1	40	1	0	0
1	41	1	0	0
1	42	1	0	0
1	43	1	0	0
1	44	1	0	0
1	45	1	0	0
1	46	1	0	0
1	47	1	0	0
1	48	1	0	0
1	49	1	0	0
1	50	1	0	0
1	51	1	0	0
1	52	1	0	0
1	53	1	0	0
1	54	1	0	0
1	55	1	0	0
1	56	1	0	0
1	57	1	0	0
1	58	1	0	0
1	59	1	0	0
1	60	1	0	0
1	61	1	0	0
1	62	1	0	0
1	63	1	0	0
1	64	1	0	0
1	65	1	0	0
1	66	1	0	0
1	67	1	0	0
1	68	1	0	0
1	69	1	0	0
1	70	1	0	0
1	71	1	0	0
1	72	1	0	0
1	73	1	0	0
1	74	1	0	0
1	75	1	0	0
1	76	1	0	0
1	77	1	0	0
1	78	1	0	0
1	79	1	0	0
1	80	1	0	0
1	81	1	0	0
1	82	1	0	0
1	83	1	0	0
1	84	1	0	0
1	85	1	0	0
1	86	1	0	0
1	87	1	0	0
1	88	1	0	0
1	89	1	0	0
1	90	1	0	0
1	91	1	0	0
1	92	1	0	0
1	93	1	0	0
1	94	1	0	0
1	95	1	0	0
1	96	1	0	0
1	97	1	0	0
1	98	1	0	0
1	99	1	0	0
1	100	1	0	0
1	101	1	0	0
1	102	1	0	0
1	103	1	0	0
1	104	1	0	0
1	105	1	0	0
1	106	1	0	0
1	107	1	0	0
1	108	1	0	0
1	109	1	0	0
1	110	1	0	0
1	111	1	0	0
1	112	1	0	0
1	113	1	0	0
1	114	1	0	0
1	115	1	0	0
1	116	1	0	0
1	117	1	0	0
1	118	1	0	0
1	119	1	0	0
1	120	1	0	0
1	121	1	0	0
1	122	1	0	0
1	123	1	0	0
1	124	1	0	0
1	125	1	0	0
1	126	1	0	0
1	127	1	0	0
1	128	1	0	0
1	129	1	0	0
1	130	1	0	0
1	131	1	0	0
1	132	1	0	0
1	133	1	0	0
1	134	1	0	0
1	135	1	0	0
1	136	1	0	0
1	137	1	0	0
1	138	1	0	0
1	139	1	0	0
1	140	1	0	0
1	141	1	0	0
1	142	1	0	0
1	143	1	0	0
1	144	1	0	0
1	145	1	0	0
1	146	1	0	0
1	147	1	0	0
1	148	1	0	0
1	149	1	0	0
1	150	1	0	0
1	151	1	0	0
1	152	1	0	0
1	153	1	0	0
1	154	1	0	0
1	155	1	0	0
1	156	1	0	0
1	157	1	0	0
1	158	1	0	0
1	159	1	0	0
1	160	1	0	0
1	161	1	0	0
1	162	1	0	0
1	163	1	0	0
1	164	1	0	0
1	165	1	0	0
1	166	1	0	0
1	167	1	0	0
1	168	1	0	0
1	169	1	0	0
1	170	1	0	0
1	171	1	0	0
1	172	1	0	0
1	173	1	0	0
1	174	1	0	0
1	175	1	0	0
1	176	1	0	0
1	177	1	0	0
1	178	1	0	0
1	179	1	0	0
1	180	1	0	0
1	181	1	0	0
1	182	1	0	0
1	183	1	0	0
1	184	1	0	0
1	185	1	0	0
1	186	1	0	0
1	187	1	0	0
1	188	1	0	0
1	189	1	0	0
1	190	1	0	0
1	191	1	0	0
1	192	1	0	0
1	193	1	0	0
1	194	1	0	0
1	195	1	0	0
1	196	1	0	0
1	197	1	0	0
1	198	1	0	0
1	199	1	0	0
1	200	1	0	0
1	201	1	0	0
1	202	1	0	0
1	203	1	0	0
1	204	1	0	0
1	205	1	0	0
1	206	1	0	0
1	207	1	0	0
1	208	1	0	0
1	209	1	0	0
1	210	1	0	0
1	211	1	0	0
1	212	1	0	0
1	213	1	0	0
1	214	1	0	0
1	215	1	0	0
1	216	1	0	0
1	217	1	0	0
1	218	1	0	0
1	219	1	0	0
1	220	1	0	0
1	221	1	0	0
1	222	1	0	0
1	223	1	0	0
1	224	1	0	0
1	225	1	0	0
1	226	1	0	0
1	227	1	0	0
1	228	1	0	0
1	229	1	0	0
1	230	1	0	0
1	231	1	0	0
1	232	1	0	0
1	233	1	0	0
1	234	1	0	0
1	235	1	0	0
1	236	1	0	0
1	237	1	0	0
1	238	1	0	0
1	239	1	0	0
1	240	1	0	0
1	241	1	0	0
1	242	1	0	0
1	243	1	0	0
1	244	1	0	0
1	245	1	0	0
1	246	1	0	0
1	247	1	0	0
1	248	1	0	0
1	249	1	0	0
1	250	1	0	0
1	251	1	0	0
1	252	1	0	0
1	253	1	0	0
1	254	1	0	0
1	255	1	0	0
1	256	1	0	0
1	257	1	0	0
1	258	1	0	0
1	259	1	0	0
1	260	1	0	0
1	261	1	0	0
1	262	1	0	0
1	263	1	0	0
1	264	1	0	0
1	265	1	0	0
1	266	1	0	0
1	267	1	0	0
1	268	1	0	0
1	269	1	0	0
1	270	1	0	0
1	271	1	0	0
1	272	1	0	0
1	273	1	0	0
1	274	1	0	0
1	275	1	0	0
1	276	1	0	0
1	277	1	0	0
1	278	1	0	0
1	279	1	0	0
1	280	1	0	0
1	281	1	0	0
1	282	1	0	0
1	283	1	0	0
1	284	1	0	0
1	285	1	0	0
1	286	1	0	0
1	287	1	0	0
1	288	1	0	0
1	289	1	0	0
1	290	1	0	0
1	291	1	0	0
1	292	1	0	0
1	293	1	0	0
1	294	1	0	0
1	295	1	0	0
1	296	1	0	0
1	297	1	0	0
1	298	1	0	0
1	299	1	0	0
1	300	1	0	0
1	301	1	0	0
1	302	1	0	0
1	303	1	0	0
1	304	1	0	0
1	305	1	0	0
1	306	1	0	0
1	307	1	0	0
1	308	1	0	0
1	309	1	0	0
1	310	1	0	0
1	311	1	0	0
1	312	1	0	0
1	313	1	0	0
1	314	1	0	0
1	315	1	0	0
1	316	1	0	0
1	317	1	0	0
1	318	1	0	0
1	319	1	0	0
1	320	1	0	0
1	321	1	0	0
1	322	1	0	0
1	323	1	0	0
1	324	1	0	0
1	325	1	0	0
1	326	1	0	0
1	327	1	0	0
1	328	1	0	0
1	329	1	0	0
1	330	1	0	0
1	331	1	0	0
1	332	1	0	0
1	333	1	0	0
1	334	1	0	0
1	335	1	0	0
1	336	1	0	0
1	337	1	0	0
1	338	1	0	0
1	339	1	0	0
1	340	1	0	0
1	341	1	0	0
1	342	1	0	0
1	343	1	0	0
1	344	1	0	0
1	345	1	0	0
1	346	1	0	0
1	347	1	0	0
1	348	1	0	0
1	349	1	0	0
1	350	1	0	0
1	351	1	0	0
1	352	1	0	0
1	353	1	0	0
1	354	1	0	0
1	355	1	0	0
1	356	1	0	0
1	357	1	0	0
1	358	1	0	0
1	359	1	0	0
1	360	1	0	0
1	361	1	0	0
1	362	1	0	0
1	363	1	0	0
1	364	1	0	0
1	365	1	0	0
1	366	1	0	0
1	367	1	0	0
1	368	1	0	0
1	369	1	0	0
1	370	1	0	0
1	371	1	0	0
1	372	1	0	0
1	373	1	0	0
1	374	1	0	0
1	375	1	0	0
1	376	1	0	0
1	377	1	0	0
1	378	1	0	0
1	379	1	0	0
1	380	1	0	0
1	381	1	0	0
1	382	1	0	0
1	383	1	0	0
1	384	1	0	0
1	385	1	0	0
1	386	1	0	0
1	387	1	0	0
1	388	1	0	0
1	389	1	0	0
1	390	1	0	0
1	391	1	0	0
1	392	1	0	0
1	393	1	0	0
1	394	1	0	0
1	395	1	0	0
1	396	1	0	0
1	397	1	0	0
1	398	1	0	0
1	399	1	0	0
1	400	1	0	0
1	401	1	0	0
1	402	1	0	0
1	403	1	0	0
1	404	1	0	0
1	405	1	0	0
1	406	1	0	0
1	407	1	0	0
1	408	1	0	0
1	409	1	0	0
1	410	1	0	0
1	411	1	0	0
1	412	1	0	0
1	413	1	0	0
1	414	1	0	0
1	415	1	0	0
1	416	1	0	0
1	417	1	0	0
1	418	1	0	0
1	419	1	0	0
1	420	1	0	0
1	421	1	0	0
1	422	1	0	0
1	423	1	0	0
1	424	1	0	0
1	425	1	0	0
1	426	1	0	0
1	427	1	0	0
1	428	1	0	0
1	429	1	0	0
1	430	1	0	0
1	431	1	0	0
1	432	1	0	0
1	433	1	0	0
1	434	1	0	0
1	435	1	0	0
1	436	1	0	0
1	437	1	0	0
1	438	1	0	0
1	439	1	0	0
1	440	1	0	0
1	441	1	0	0
1	442	1	0	0
1	443	1	0	0
1	444	1	0	0
1	445	1	0	0
1	446	1	0	0
1	447	1	0	0
1	448	1	0	0
1	449	1	0	0
1	450	1	0	0
1	451	1	0	0
1	452	1	0	0
1	453	1	0	0
1	454	1	0	0
1	455	1	0	0
1	456	1	0	0
1	457	1	0	0
1	458	1	0	0
1	459	1	0	0
1	460	1	0	0
1	461	1	0	0
1	462	1	0	0
1	463	1	0	0
1	464	1	0	0
1	465	1	0	0
1	466	1	0	0
1	467	1	0	0
1	468	1	0	0
1	469	1	0	0
1	470	1	0	0
1	471	1	0	0
1	472	1	0	0
1	473	1	0	0
1	474	1	0	0
1	475	1	0	0
1	476	1	0	0
1	477	1	0	0
1	478	1	0	0
1	479	1	0	0
1	1	1	1	0
\.


--
-- Name: languages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.languages_id_seq', 133, true);


--
-- Name: movies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.movies_id_seq', 1, true);


--
-- Name: phrases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.phrases_id_seq', 479, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: talkliketv
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


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
-- PostgreSQL database dump complete
--

