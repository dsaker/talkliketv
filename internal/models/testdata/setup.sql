--
-- PostgreSQL database dump
--

-- Dumped from database version 14.9 (Homebrew)
-- Dumped by pg_dump version 15.4

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: languages; Type: TABLE; Schema: public; Owner: testdb
--

CREATE TABLE public.languages (
    id bigint NOT NULL,
    language text NOT NULL
);


ALTER TABLE public.languages OWNER TO testdb;

--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: testdb
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.languages_id_seq OWNER TO testdb;

--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testdb
--

ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;


--
-- Name: movies; Type: TABLE; Schema: public; Owner: testdb
--

CREATE TABLE public.movies (
    id bigint NOT NULL,
    title text NOT NULL,
    num_subs integer NOT NULL,
    language_id bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.movies OWNER TO testdb;

--
-- Name: movies_id_seq; Type: SEQUENCE; Schema: public; Owner: testdb
--

CREATE SEQUENCE public.movies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movies_id_seq OWNER TO testdb;

--
-- Name: movies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testdb
--

ALTER SEQUENCE public.movies_id_seq OWNED BY public.movies.id;


--
-- Name: phrases; Type: TABLE; Schema: public; Owner: testdb
--

CREATE TABLE public.phrases (
    id bigint NOT NULL,
    movie_id bigint NOT NULL,
    phrase text NOT NULL,
    translates text NOT NULL,
    hint text NOT NULL
);


ALTER TABLE public.phrases OWNER TO testdb;

--
-- Name: phrases_id_seq; Type: SEQUENCE; Schema: public; Owner: testdb
--

CREATE SEQUENCE public.phrases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.phrases_id_seq OWNER TO testdb;

--
-- Name: phrases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testdb
--

ALTER SEQUENCE public.phrases_id_seq OWNED BY public.phrases.id;


CREATE TABLE public.sessions (
    token text NOT NULL,
    data bytea NOT NULL,
    expiry timestamp with time zone NOT NULL
);


ALTER TABLE public.sessions OWNER TO testdb;

--
-- Name: users; Type: TABLE; Schema: public; Owner: testdb
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    movie_id bigint NOT NULL,
    name text NOT NULL,
    email public.citext NOT NULL,
    hashed_password bytea NOT NULL,
    created timestamp(0) with time zone DEFAULT now() NOT NULL,
    language_id bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.users OWNER TO testdb;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: testdb
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO testdb;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testdb
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_phrases; Type: TABLE; Schema: public; Owner: testdb
--

CREATE TABLE public.users_phrases (
    user_id bigint NOT NULL,
    phrase_id bigint NOT NULL,
    movie_id bigint NOT NULL,
    correct bigint
);


ALTER TABLE public.users_phrases OWNER TO testdb;

--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);


--
-- Name: movies id; Type: DEFAULT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.movies ALTER COLUMN id SET DEFAULT nextval('public.movies_id_seq'::regclass);


--
-- Name: phrases id; Type: DEFAULT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.phrases ALTER COLUMN id SET DEFAULT nextval('public.phrases_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: testdb
--

COPY public.languages (id, language) FROM stdin;
1	Spanish
2	French
-1	Not a Language
\.


--
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: testdb
--

COPY public.movies (id, title, num_subs, language_id) FROM stdin;
1	MissAdrenalineS01E01	642	1
16	TheSimpsonsS32E01	325	2
25	MissAdrenalineS01E02	625	1
-2	Not a Movie	0	-1
-1	Not a Movie	0	-1
\.


--
-- Data for Name: phrases; Type: TABLE DATA; Schema: public; Owner: testdb
--

COPY public.phrases (id, movie_id, phrase, translates, hint) FROM stdin;
2093	25	Do you want me to tell you what actually happened, Laura?	¿Usted quiere que le cuente cómo son las cosas, Laura?	¿U     q      q   l  c      c    s   l   c    , L    ?
2	1	You can do it. Keep going. Breathe.	Tú puedes. Sigue, sigue, sigue. Respira.	T  p     . S    , s    , s    . R      .
3	1	Don't close your legs. Don't.	No me cierres las piernas. No las cierres.	N  m  c       l   p      . N  l   c      .
4	1	Hey, Romina, don't forget you go last here.	Ey, Romina, no se le olvide que acá va de última.	E , R     , n  s  l  o      q   a   v  d  ú     .
5	1	Oh, you snooze, you lose.	Ay, como lo vi tan dormidito.	A , c    l  v  t   d        .
6	1	Don't you know female centaurs don't exist?	¡Ja! ¿Usted no sabía que las centauros mujeres no existen?	¡J ! ¿U     n  s     q   l   c         m       n  e      ?
7	1	Tato, did you know that if there's a male, it's because a female gave birth to it?	Tato, ¿y sabe que si hay un hombre de cada cosa es porque una hembra lo parió? ¿O no?	T   , ¿y s    q   s  h   u  h      d  c    c    e  p      u   h      l  p    ? ¿O n ?
8	1	You know what you need to do to become a centaur?	¡Ja! ¿Sabe qué le falta a usted para ser una centauro?	¡J ! ¿S    q   l  f     a u     p    s   u   c       ?
9	1	Instead of plodding along, learn to fly.	Volar, porque con lo lenta que es…	V    , p      c   l  l     q   e …
10	1	Come on, Tato, instead of trying to distract me,	Venga, Tato. En vez de tratar de desconcentrarme, concéntrese en lo suyo más bien.	V    , T   . E  v   d  t      d  d              , c           e  l  s    m   b   .
11	1	Because my brunette and I are all in!	¡Porque mi Morocha y yo vamos con toda!	¡P      m  M       y y  v     c   t   !
12	1	Let's see if you can beat this time.	Vamos a ver si supera este tiempo.	V     a v   s  s      e    t     .
13	1	Let's see if you can stay on your bike.	Pues vamos a ver si no se cae.	P    v     a v   s  n  s  c  .
14	1	What a fall, let's help. No, wait.	¡Qué golpe! Vamos a ayudar. No, espere.	¡Q   g    ! V     a a     . N , e     .
15	1	How did nothing happen to that guy?	¿A ese man cómo no le pasó nada?	¿A e   m   c    n  l  p    n   ?
16	1	That guy's fierce. Got up like it was nothing.	Berraco ese pelado porque se paró como si nada.	B       e   p      p      s  p    c    s  n   .
17	1	Let's go see who wins the race. Let's go.	Vamos a ver quién ganó la carrera. Hágale pues.	V     a v   q     g    l  c      . H      p   .
18	1	Romina Páez is the national downhill champion!	¡Romina Páez es la ganadora del campeonato nacional de downhill!	¡R      P    e  l  g        d   c          n        d  d       !
19	1	Laurita, it's turning out beautifully.	Laurita, le está quedando muy bonito, de verdad.	L      , l  e    q        m   b     , d  v     .
20	1	If you say so, Rubén.	Si usted, Rubén, lo dice, yo le creo.	S  u    , R    , l  d   , y  l  c   .
21	1	Oh, Rubén, wait. I have a gift for you.	Ay, Rubén, espere, espere. Yo le tenía un regalito.	A , R    , e     , e     . Y  l  t     u  r       .
22	1	How's your blood sugar?	¿Cómo le salió la glicemia? Bien.	¿C    l  s     l  g       ? B   .
23	1	It's fine, 95 on an empty stomach.	Bien, 95 en ayunas.	B   , 95 e  a     .
24	1	You're my official taste tester. Of course.	Usted es mi catador oficial, Rubén. Claro.	U     e  m  c       o      , R    . C    .
25	1	Hey, new haircut. It looks great on you.	Ay, se cortó el pelo. Le luce mucho.	A , s  c     e  p   . L  l    m    .
26	1	Hi, Moni. How are you?	Hola, Moni. ¿Cómo va?	H   , M   . ¿C    v ?
27	1	Jorge, it's so nice to see you around here again.	Jorge, qué bueno volverlo a ver por aquí.	J    , q   b     v        a v   p   a   .
28	1	Hi, Luzma. How are you, miss? Your juice.	Hola, Luzma. Señorita, ¿cómo está? Su juguito.	H   , L    . S       , ¿c    e   ? S  j      .
29	1	Could you be any sweeter? Thank you. You're welcome.	¿Por qué es tan hermosa? Gracias. Con mucho gusto.	¿P   q   e  t   h      ? G      . C   m     g    .
30	1	I'll be right back. Okay.	Ya vengo. Bueno.	Y  v    . B    .
31	1	What a pleasant surprise to see a woman win this race.	Qué sorpresa tan agradable ver que una chica ganó este campeonato.	Q   s        t   a         v   q   u   c     g    e    c         .
32	1	Because I think it's brave to compete in a high risk sport such as this one.	Porque creo que es de valientes practicar un deporte de alto riesgo como este.	P      c    q   e  d  v         p         u  d       d  a    r      c    e   .
33	1	You know what's actually high risk?	¿Usted sabe qué sí es de alto riesgo?	¿U     s    q   s  e  d  a    r     ?
34	1	Living in this neighborhood. That takes bravery.	Vivir en este barrio. Eso sí es para valientes.	V     e  e    b     . E   s  e  p    v        .
35	1	Why do you say that?	¿Y por qué lo dice?	¿Y p   q   l  d   ?
36	1	Because this neighborhood is full of moneylenders, loan sharks, and payday lenders.	Porque este barrio está lleno de usureros, de prestamistas, de gota a gotas.	P      e    b      e    l     d  u       , d  p           , d  g    a g    .
37	1	They're screwing over the neighborhood.	esos manes tienen jodido a este barrio.	e    m     t      j      a e    b     .
38	1	And what do the police do? Just park wherever they want.	¿Y qué hace la policía? Andar mal parqueado y ya.	¿Y q   h    l  p      ? A     m   p         y y .
39	1	I wish they'd actually do something to keep the neighborhood safe	Ojalá le metieran la ficha y le metieran toda la seguridad al barrio	O     l  m        l  f     y l  m        t    l  s         a  b
40	1	but well, it's kind of complicated.	pero pues como complicado.	p    p    c    c         .
41	1	What a warm welcome for the police!	¿Qué tal esta peladita la bienvenida que le da a la policía?	¿Q   t   e    p        l  b          q   l  d  a l  p      ?
42	1	Buddy, now I want to meet her.	Ahora sí me interesa conocerla, ¿oyó, curso?	A     s  m  i        c        , ¿o  , c    ?
43	1	On top of being beautiful, she's brave and tough.	Aparte de linda, también es valiente y berraca.	A      d  l    , t       e  v        y b      .
44	1	It was love at first pedal.	Eso fue un flechazo al primer pedalazo.	E   f   u  f        a  p      p       .
45	1	You know what I'm curious about? What?	No, ¿sabe qué me intriga? ¿Qué?	N , ¿s    q   m  i      ? ¿Q  ?
46	1	The whole loan shark thing.	Ese tema de la usura.	E   t    d  l  u    .
47	1	Congrats, Rominita. How are you? Did you see me fall?	Felicidades, Rominita. ¿Qué tal? ¿Vieron cómo me caí?	F          , R       . ¿Q   t  ? ¿V      c    m  c  ?
48	1	A round of applause for our national champion!	¡Un aplauso, por favor, para la campeona nacional!	¡U  a      , p   f    , p    l  c        n       !
49	1	Your national downhill champion, ladies and gentlemen!	¡Ey, campeona nacional del downhill, señores! 	¡E , c        n        d   d       , s      !
50	1	The pride of La Mirla!	¡Orgullo de La Mirla!	¡O       d  L  M    !
51	1	Hi, Laura! How are you, sweetheart? 	Hola, Laura, cariño. ¿Qué tal? ¿Cómo estás? 	H   , L    , c     . ¿Q   t  ? ¿C    e    ?
52	1	What's new? Tell me everything.	¿Qué ha pasado? Cuéntame.	¿Q   h  p     ? C       .
53	1	Rubén and I went to the bakery to see how it was coming along.	Andaba con Rubén en la repostería viendo cómo está quedando el local.	A      c   R     e  l  r          v      c    e    q        e  l    .
54	1	And, to answer your question, it's turning out lovely.	Y, para responder tu pregunta, está quedando divino.	Y, p    r         t  p       , e    q        d     .
55	1	Wait. I'll let you talk to your mom.	Espera, cariño. Te dejo con tu mamá, ¿vale?	E     , c     . T  d    c   t  m   , ¿v   ?
56	1	I'm glad everything is going well. Hi, darling!	Me alegro que todo esté bien. Hola, mi amor.	M  a      q   t    e    b   . H   , m  a   .
57	1	I'm so glad to see you. How are you? What I wouldn't give to squeeze you.	Ay, qué alegría verte. ¿Cómo estás? Ay, quiero espicharte.	A , q   a       v    . ¿C    e    ? A , q      e         .
58	1	Mom, explain to me why Dad calls me if he never has time to talk?	¿Mi papá para qué me llama si nunca tiene tiempo para hablar?	¿M  p    p    q   m  l     s  n     t     t      p    h     ?
59	1	Oh, darling. You know what he's like. Yeah.	Ay, amor, ya tú sabes cómo es él. Sí.	A , a   , y  t  s     c    e  é . S .
60	1	But don't let it bother you, darling. That's how he shows his love.	Pero, ven, no te mortifiques, mi amor. Esa es su manera de demostrarnos que nos quiere.	P   , v  , n  t  m          , m  a   . E   e  s  m      d  d            q   n   q     .
61	1	He does the same to me. Don't be so hard on him.	A mí me hace lo mismo. Pero no le des tan duro.	A m  m  h    l  m    . P    n  l  d   t   d   .
62	1	Okay, no big deal.	Vale, no pasa nada.	V   , n  p    n   .
63	1	Everything he does, he does because he loves you.	Todo lo que hace lo hace porque te quiere.	T    l  q   h    l  h    p      t  q     .
64	1	You know all I want from him is time.	Igual tú sabes que lo que yo quiero que él me dé es tiempo.	I     t  s     q   l  q   y  q      q   é  m  d  e  t     .
65	1	But it's fine. I won't make a big deal out of it.	Pero no pasa nada. Yo no haré un problema de esto.	P    n  p    n   . Y  n  h    u  p        d  e   .
66	1	So, tell me, how's the shop? Have you settled on a name?	Pero cuéntame. ¿Cómo va lo del local? ¿Ya le tienes nombre?	P    c       . ¿C    v  l  d   l    ? ¿Y  l  t      n     ?
67	1	but we're really close.	pero estamos muy cerquita.	p    e       m   c       .
68	1	And I was thinking I could celebrate my birthday there	Es más, estaba pensando que de pronto podría celebrar mi cumpleaños en el local	E  m  , e      p        q   d  p      p      c        m  c          e  e  l
69	1	and I wanted to know if you think you'll make it here by then.	y quería preguntarte si tú crees que alcanzan a llegar para esas fechas.	y q      p           s  t  c     q   a        a l      p    e    f     .
70	1	Uh... Well, darling, we actually wanted to talk to you about that.	Eh, pues, mi amor, precisamente de eso te queríamos hablar.	E , p   , m  a   , p            d  e   t  q         h     .
71	1	Something's come up that your dad needs to resolve and we had to postpone our return.	Es que a tu papá le salieron un par de cosas que tiene que resolver y nos tocó prolongar el regreso.	E  q   a t  p    l  s        u  p   d  c     q   t     q   r        y n   t    p         e  r      .
72	1	Don't be like that. Look on the bright side, darling.	Pero… Ay, no te pongas así. Mírale el lado bueno, mi amor.	P   … A , n  t  p      a  . M      e  l    b    , m  a   .
73	1	You'll be home alone.	Te vas a quedar sola en la casa.	T  v   a q      s    e  l  c   .
74	1	With the house to yourself. I have something to tell you.	La casa solo para ti. Oye, espera. Una cosa superimportante, cariño.	L  c    s    p    t . O  , e     . U   c    s              , c     .
75	1	We have a surprise for you that you're going to love.	Tenemos una sorpresa para ti que te va a encantar.	T       u   s        p    t  q   t  v  a e       .
76	1	Go to Roberto's office in three hours, okay?	Tienes que estar en la oficina de Roberto como en tres horitas, ¿vale?	T      q   e     e  l  o       d  R       c    e  t    h      , ¿v   ?
77	1	Sorry, I have another call.	Disculpa que me entró otra llamada.	D        q   m  e     o    l      .
78	1	Hugs, darling. Take care. Mwah!	Besos, mi amor. Cuídate mucho. ¡Mua!	B    , m  a   . C       m    . ¡M  !
79	1	I love you, Mom.	Te amo, ma.	T  a  , m .
80	1	What was that kiss about?	¿Y ese beso qué fue?	¿Y e   b    q   f  ?
81	1	I was celebrating your win. Don't give me that bullshit, Leo.	Estaba celebrando su victoria. Ay, no te pongas con esas bobadas, Leo.	E      c          s  v       . A , n  t  p      c   e    b      , L  .
82	1	Romi, don't be like that. It's all good.	Ya, venga. No se ponga así, Romi. Todo bien.	Y , v    . N  s  p     a  , R   . T    b   .
83	1	We broke up a long time ago.	Nosotros terminamos hace mucho tiempo.	N        t          h    m     t     .
84	1	Romi, I know we broke up, but we still love each other.	Yo sé, Romi, que usted y yo terminamos, pero usted y yo nos seguimos queriendo.	Y  s , R   , q   u     y y  t         , p    u     y y  n   s        q        .
85	1	Don't deny it, honey. I can see it in your eyes.	No me lo niegue, amor, que lo puedo ver en sus ojos.	N  m  l  n     , a   , q   l  p     v   e  s   o   .
86	1	You know exactly why we broke up.	Usted tiene muy claro por qué se acabaron las cosas.	U     t     m   c     p   q   s  a        l   c    .
87	1	How many times do I have to tell you I didn't choose the family I got?	¿Cuántas veces le tengo que explicar que yo no escogí la familia que me tocó?	¿C       v     l  t     q   e        q   y  n  e      l  f       q   m  t   ?
88	1	You're absolutely right, Leo.	Tiene toda la razón, Leo.	T     t    l  r    , L  .
89	1	You can't choose your family,	Uno no escoge la familia que le tocó, 	U   n  e      l  f       q   l  t   ,
90	1	but you did choose to join your brothers' shady business.	pero usted sí escogió meterse en ese negocio tan chimbo que tienen sus hermanos.	p    u     s  e       m       e  e   n       t   c      q   t      s   h       .
91	1	You know who's to blame?	¿Sabe quién tiene la culpa?	¿S    q     t     l  c    ?
92	1	The people in this town, because there'd be no business without them.	La gente de este barrio, porque este negocio sin ellos no existiría.	L  g     d  e    b     , p      e    n       s   e     n  e        .
93	1	It's transactional. They need money. We give it to them. That's it.	Esto es una transacción. Ellos necesitan plata. Nosotros se la damos. Eso es todo.	E    e  u   t          . E     n         p    . N        s  l  d    . E   e  t   .
94	1	People are happy once they're flush with cash.	La gente sale feliz, con los bolsillos llenos de plata.	L  g     s    f    , c   l   b         l      d  p    .
95	1	Do you know how screwed people are once they pay the interest you charge?	¿Vio cómo queda de jodida la gente cuando debe pagar los intereses que les cobran?	¿V   c    q     d  j      l  g     c      d    p     l   i         q   l   c     ?
96	1	Do you know what your brother does when folks can't pay on time?	¿Vio lo que su hermano hace cuando no tienen cómo pagar a tiempo?	¿V   l  q   s  h       h    c      n  t      c    p     a t     ?
97	1	Should I tell you? I'm getting out.	¿O le cuento? Me voy a abrir de esta mierda.	¿O l  c     ? M  v   a a     d  e    m     .
98	1	I'm going to leave this neighborhood, my brothers, my family, all this shit, Romi.	Me voy a abrir del barrio, de mis hermanos, de mi familia, de todo este mierdero, Romi.	M  v   a a     d   b     , d  m   h       , d  m  f      , d  t    e    m       , R   .
99	1	Because I want you back.	Porque la quiero recuperar.	P      l  q      r        .
100	1	And I'll do it for you.	Y lo voy a hacer por usted.	Y l  v   a h     p   u    .
101	1	It's great that you want to change. Really.	Leo, qué chimba que quiera cambiar.	L  , q   c      q   q      c      .
102	1	I'm so happy for you.	Y se lo celebro mucho.	Y s  l  c       m    .
103	1	But if you're going to change, change for yourself.	Pero si va a cambiar, cambie por usted.	P    s  v  a c      , c      p   u    .
104	1	I'll change for both of us, then.	Voy a cambiar por los dos entonces.	V   a c       p   l   d   e       .
105	1	Why so sad, Laurita?	Uy, Laurita, ¿y esa cara de tristeza?	U , L      , ¿y e   c    d  t       ?
106	1	How'd you know? Oh!	¿Quién le dijo que yo estaba triste? ¡Ay!	¿Q     l  d    q   y  e      t     ? ¡A !
107	1	You must've had a fight with your boyfriend.	Supe que peleó con el noviecito.	S    q   p     c   e  n        .
108	1	Keep your disdain for Santiago to yourself, Rubén.	Que no se note, Rubén, que le cae como mal Santiago.	Q   n  s  n   , R    , q   l  c   c    m   S       .
109	1	The thing is I've known you since you were up to here on me.	No, lo que pasa es que a usted la conozco desde que era así de grande.	N , l  q   p    e  q   a u     l  c       d     q   e   a   d  g     .
110	1	But time flies, doesn't it?	Pero bueno, lo que pasa es que el tiempo vuela, ¿no?	P    b    , l  q   p    e  q   e  t      v    , ¿n ?
111	1	I sometimes think it's quite the opposite.	Yo a veces siento que es al contrario, Rubén.	Y  a v     s      q   e  a  c        , R    .
112	1	I think time drags when you're bored.	Yo siento que a veces el tiempo pasa lento cuando uno está aburrido.	Y  s      q   a v     e  t      p    l     c      u   e    a       .
113	1	What are you complaining about, love?	Niña, ¿usted de qué se queja?	N   , ¿u     d  q   s  q    ?
114	1	You should be grateful for all your privilege.	Debería estar agradecida que es una mujer privilegiada.	D       e     a          q   e  u   m     p           .
115	1	Please lay off the scolding, Rubén.	Rubén, no empecemos con el regaño, por favor.	R    , n  e         c   e  r     , p   f    .
116	1	I'm not scolding you. 	No, es que no es regaño.	N , e  q   n  e  r     .
117	1	I want you to understand that now that you're an adult you can do more than before.	Quisiera que entendiera que, ahora que usted es adulta, puede hacer cosas que antes no podía.	Q        q   e          q  , a     q   u     e  a     , p     h     c     q   a     n  p    .
118	1	Like have my own bakery. For example. 	Como sacar adelante mi repostería. Por ejemplo.	C    s     a        m  r         . P   e      .
119	1	Or study in Paris, like you've always dreamed of doing.	O irse a estudiar a París, como siempre ha soñado.	O i    a e        a P    , c    s       h  s     .
120	1	Look, Ma! Another for the collection!	Ma, ¡vea pues! ¡Otro para la colección!	M , ¡v   p   ! ¡O    p    l  c        !
121	1	You can't imagine the epic fall I had.	Ay, y no se imagina la caída tan berraca que me pegué.	A , y n  s  i       l  c     t   b       q   m  p    .
122	1	It was quite the tumble at the end.	Ja. El pique que me pegué al final.	J . E  p     q   m  p     a  f    .
123	1	You should've seen it. I was flying at first.	Ma, me hubiera visto. Yo salí volando.	M , m  h       v    . Y  s    v      .
124	1	I almost fell, but...	Casi me caigo pues, pero ahí…	C    m  c     p   , p    a  …
125	1	What are you doing here?	¿Y usted qué hace aquí?	¿Y u     q   h    a   ?
126	1	How are you, honey?	¿Entonces qué, peladita, bien o no?	¿E        q  , p       , b    o n ?
127	1	A little bird told me you won the race. Congratulations.	Por ahí un pajarito nos contó que ganó la competencia y vinimos a felicitarla.	P   a   u  p        n   c     q   g    l  c           y v       a f          .
128	1	Nice! Yes, we can. Yes, we can.	¡Venga! Sí se pudo, sí se pudo.	¡V    ! S  s  p   , s  s  p   .
129	1	Congratulations, my ass, Marlon. Get out.	Felicitaciones ni chimba, Marlon. Se abren pues.	F              n  c     , M     . S  a     p   .
130	1	Watch that tone. It's rude and we're here to congratulate you.	Bajándole al tonito y no sea grosera, que vinimos fue a felicitarla.	B         a  t      y n  s   g      , q   v       f   a f          .
131	1	Relax, honey, we're here to talk.	Relájese, pelada, que vinimos a hablar.	R       , p     , q   v       a h     .
132	1	I heard what you said to that journalist.	Me enteré lo que le dijo a la periodista.	M  e      l  q   l  d    a l  p         .
133	1	I have ears to the ground in this neighborhood, honey.	Yo tengo muchos pajaritos en mi barrio, peladita.	Y  t     m      p         e  m  b     , p       .
134	1	Well, honey, what I said to the journalist isn't news to anyone.	Pues, peladito, lo que yo le dije a la periodista no es secreto para nadie.	P   , p       , l  q   y  l  d    a l  p          n  e  s       p    n    .
135	1	And know that this is my neighborhood too.	Y entérese de una vez que este también es mi barrio.	Y e        d  u   v   q   e    t       e  m  b     .
136	1	Romina, dear. Don't "Romina, dear" me, Ma.	Romina, hija. No, ¿Romina qué, ma? No, señora.	R     , h   . N , ¿R      q  , m ? N , s     .
137	1	I'll say to your face what I said to that journalist.	Lo que le dije a esa periodista se lo sostengo en la cara a estos manes.	L  q   l  d    a e   p          s  l  s        e  l  c    a e     m    .
138	1	You're a plague that's screwed over the neighborhood.	Ustedes son una plaga que tienen jodido al barrio.	U       s   u   p     q   t      j      a  b     .
139	1	You should be ashamed of yourselves.	Pena es lo que les debería dar.	P    e  l  q   l   d       d  .
140	1	I'm so sorry we rub you the wrong way.	Qué lástima que le caigamos tan mal y que piense eso de nosotros,	Q   l       q   l  c        t   m   y q   p      e   d  n       ,
141	1	Because we got along fine when your mom asked for a loan, right?	porque lo mismo no pensó su mamá cuando me pidió prestado plata, ¿no?	p      l  m     n  p     s  m    c      m  p     p        p    , ¿n ?
142	1	It's almost time to pay up, right?	Ya está siendo hora de que me pague, ¿no?	Y  e    s      h    d  q   m  p    , ¿n ?
143	1	Since you want nothing to do with us,	Como nosotros le caemos tan mal a usted y le damos tanto asco.	C    n        l  c      t   m   a u     y l  d     t     a   .
144	1	pay me and I'll leave you alone.	págueme lo mío y las dejo en paz.	p       l  m   y l   d    e  p  .
145	1	You have two weeks to pay me what you owe me plus interest.	Tienen dos semanas para entregarme lo mío más los intereses.	T      d   s       p    e          l  m   m   l   i        .
146	1	Or else we'll come and clear this pigsty.	Si no, venimos aquí y desocupamos esta pocilga.	S  n , v       a    y d           e    p      .
147	1	I'll see to it. Otherwise, I'll take Ebony.	Yo veré. Si no, me le llevo a la Morocha.	Y  v   . S  n , m  l  l     a l  M      .
148	1	Maybe that'll shut that snitch up.	A ver si esto le amarra la lengua a esa sapa.	A v   s  e    l  a      l  l      a e   s   .
149	1	And if it doesn't? Guess.	Y si no, ¿qué? Adivine.	Y s  n , ¿q  ? A      .
150	1	Leo isn't going to like it when he finds out we came by Romina and her mom's place.	A Leo no le va a gustar ni mierda cuando sepa que vinimos a visitar a la Romina y a la cucha esa.	A L   n  l  v  a g      n  m      c      s    q   v       a v       a l  R      y a l  c     e  .
151	1	Leo needs to end this stupid fling with that girl.	Leo lo que tiene que dejar es la pendejada con esa pelada.	L   l  q   t     q   d     e  l  p         c   e   p     .
152	1	I don't get that guy.	Yo no sé qué le pasa a ese man.	Y  n  s  q   l  p    a e   m  .
153	1	He's always like that with women.	Siempre es lo mismo con las mujeres.	S       e  l  m     c   l   m      .
154	1	Don't you understand we're not like everyone else?	¿Ustedes no han entendido que nosotros no somos como los demás?	¿U       n  h   e         q   n        n  s     c    l   d    ?
155	1	We're the Chitiva brothers and we kneel before no one.	Nosotros somos los Chitiva y no nos arrodillamos frente a nadie.	N        s     l   C       y n  n   a            f      a n    .
156	1	Much less for love.	Y menos por amor.	Y m     p   a   .
157	1	Your parents put this money in a trust for you to have when you turned 21.	Tus papás quisieron dejar este dinero en fideicomiso para ser entregado cuando cumplieras 21 años,	T   p     q         d     e    d      e  f           p    s   e         c      c          21 a   ,
158	1	And since that's in a few weeks,	y como estamos a un par de semanas de que eso ocurra,	y c    e       a u  p   d  s       d  q   e   o     ,
159	1	Wait. What is this?	Espere. ¿Y esto vendría siendo qué?	E     . ¿Y e    v       s      q  ?
160	1	consider it a living inheritance. You can think of it that way.	tómalo como una herencia en vida. Piénsalo de esa manera.	t      c    u   h        e  v   . P        d  e   m     .
161	1	So, all this money is for me?	¿O sea que toda esta plata es para mí?	¿O s   q   t    e    p     e  p    m ?
162	1	For whatever I want? For whatever you want.	¿Para lo que yo quiera? Toda… Lo que tú quieras.	¿P    l  q   y  q     ? T   … L  q   t  q      .
163	1	There is one condition for the disbursement.	Solo hay una condición para el desembolso.	S    h   u   c         p    e  d         .
164	1	There are always conditions with my dad.	Con mi papá siempre hay condiciones.	C   m  p    s       h   c          .
165	1	It's a simple condition.	Es muy fácil la condición.	E  m   f     l  c        .
166	1	Your parents are always thinking of your future.	Eh, tus papás siempre piensan en tu futuro.	E , t   p     s       p       e  t  f     .
167	1	And your dad is very happy about your business venture,	Y tu papá incluso está muy contento con tu emprendimiento en el asunto de la repostería.	Y t  p    i       e    m   c        c   t  e              e  e  a      d  l  r         .
168	1	Your father wants you to join the family business right away	Pues el punto es que tu papá quiere que te vincules inmediatamente a la empresa familiar,	P    e  p     e  q   t  p    q      q   t  v        i              a l  e       f       ,
478	1	The night is young.	Apenas está empezando la noche.	A      e    e         l  n    .
169	1	so that you can gain experience in all areas	para que recorras por tu propia experiencia todas las áreas	p    q   r        p   t  p      e           t     l   á
170	1	just in case, at some point, hopefully not soon, 	por si, en algún momento, Dios no lo quiera,	p   s , e  a     m      , D    n  l  q     ,
171	1	so you'll be able to replace him.	pues estarás en capacidad de reemplazarlo.	p    e       e  c         d  r           .
172	1	Where champions become legends.	Donde los campeones se vuelven leyendas.	D     l   c         s  v       l       .
173	1	Mom, you borrowed the money for this?	Mamá, ¿usted pidió prestada la plata para esto?	M   , ¿u     p     p        l  p     p    e   ?
174	1	Of course. How else did you think we bought Ebony?	Y si no, ¿con qué compramos la Morocha, pues?	Y s  n , ¿c   q   c         l  M      , p   ?
175	1	Yeah. And going to Italy costs a ton of money, too.	Sí. Hija, además irse a Italia cuesta un montón de plata.	S . H   , a      i    a I      c      u  m      d  p    .
176	1	You have to take all those toys so you don't get rusty.	Y debe llevarse todos los juguetes para no desentonar.	Y d    l        t     l   j        p    n  d         .
177	1	You're brave and strong. You deserve all the opportunities.	Usted es una berraca y una dura. Se merece todas las posibilidades.	U     e  u   b       y u   d   . S  m      t     l   p            .
178	1	Thank you so much for doing this for me, really.	Yo le agradezco mucho que usted haya hecho eso por mí, de verdad,	Y  l  a         m     q   u     h    h     e   p   m , d  v     ,
179	1	But we're selling that bicycle.	pero vamos a vender ya esa bicicleta.	p    v     a v      y  e   b        .
180	1	Nobody's selling anything. It's my issue. Maybe I'll sell more empanadas,	Nadie va a vender nada. Es mi problema. Yo veré si vendo más empanadas,	N     v  a v      n   . E  m  p       . Y  v    s  v     m   e        ,
181	1	get another job, sell lottery tickets. I don't know.	si me consigo otro trabajo, si vendo chance, no sé.	s  m  c       o    t      , s  v     c     , n  s .
182	1	I'll do what I have to do. You focus on training, it's important.	Yo veré qué tengo que hacer. Usted ocúpese por entrenar que es lo importante.	Y  v    q   t     q   h    . U     o       p   e        q   e  l  i         .
183	1	Sweetheart, you're almost 21.	Hija, usted ya va a cumplir 21 años.	H   , u     y  v  a c       21 a   .
184	1	I want all your talent to take you far away from here.	Yo quiero que ese talento que usted tiene me la saque bien lejos de aquí.	Y  q      q   e   t       q   u     t     m  l  s     b    l     d  a   .
185	1	Far away? Far away is where I'll send the Chitivas brothers.	¿Bien lejos? Bien lejos es adonde yo voy a mandar a los Chitivas.	¿B    l    ? B    l     e  a      y  v   a m      a l   C       .
186	1	Are you still on that, Romina? Stop. Look at me.	¿Va a seguir con eso, Romina? Ya no más. Míreme.	¿V  a s      c   e  , R     ? Y  n  m  . M     .
187	1	These people are dangerous. Please, sweetheart.	Esa gente es muy peligrosa, hija. Por favor.	E   g     e  m   p        , h   . P   f    .
188	1	Look, Ma, if I'm not afraid of taking on those hills without brakes,	A ver, ma, si a mí no me da miedo tirarme por estas lomas sin frenos,	A v  , m , s  a m  n  m  d  m     t       p   e     l     s   f     ,
189	1	why would I be afraid of those idiots?	¿cree que me da miedo enfrentarme a esos bobos?	¿c    q   m  d  m     e           a e    b    ?
190	1	Enough, Romina. Please, sweetheart.	Ya no más, Romina. Por favor, hija.	Y  n  m  , R     . P   f    , h   .
191	1	Be careful. If not for yourself, then for me.	Cuídese. Si no lo quiere hacer por usted, hágalo por mí.	C      . S  n  l  q      h     p   u    , h      p   m .
192	1	Stay away from those people.	No se meta más con esta gente.	N  s  m    m   c   e    g    .
193	1	No, Santiago. It's not a gift. It's a trap.	No, Santiago, eso no es un regalo. Eso es una trampa.	N , S       , e   n  e  u  r     . E   e  u   t     .
194	1	A trap? You're blowing it out of proportion.	¿Cómo una trampa? Exagerada. ¿Qué decís?	¿C    u   t     ? E        . ¿Q   d    ?
195	1	Santiago, my dad is tying me down with all this money.	Santiago, mi papá me está amarrando aquí con ese montón de plata.	S       , m  p    m  e    a         a    c   e   m      d  p    .
196	1	But say yes. It's a ton of money.	Pero decile que sí. Es un montón de plata.	P    d      q   s . E  u  m      d  p    .
197	1	Say yes to all of his conditions.	Decile que sí a todas las condiciones que te dijo.	D      q   s  a t     l   c           q   t  d   .
198	1	No, Santi. That's not the point. My dad's always like this.	Santi, no. Es que ese no es el punto. La cosa es que con mi papá todo es igual.	S    , n . E  q   e   n  e  e  p    . L  c    e  q   c   m  p    t    e  i    .
199	1	Everything has hidden intentions, the price to pay is too high,	Todo tiene una segunda intención. Todo tiene un precio muy alto.	T    t     u   s       i        . T    t     u  p      m   a   .
200	1	and this time, I'm not sure I want to pay the price.	Y esta vez, no sé si quiero pagar ese precio.	Y e    v  , n  s  s  q      p     e   p     .
201	1	Baby, it makes sense to me that your dad wants you to learn the ropes of the family business,	Bebé, a mí me parece muy lógico que tu papá quiera que conozcas la empresa familiar.	B   , a m  m  p      m   l      q   t  p    q      q   c        l  e       f       .
202	1	so that you can eventually take it over. It makes sense.	Y que eventualmente el día de mañana la puedas dirigir. Es lógico.	Y q   e             e  d   d  m      l  p      d      . E  l     .
203	1	But you know I don't want that.	Pero tú sabes que ese no es mi sueño.	P    t  s     q   e   n  e  m  s    .
204	1	How sure are you of that?	¿Qué tan seguros estamos de eso?	¿Q   t   s       e       d  e  ?
205	1	Let's think about it.	A ver, vení acá.	A v  , v    a  .
206	1	I've thought about it.	Es que ya lo he estado pensando.	E  q   y  l  h  e      p       .
207	1	Santi, when my dad realizes what I'm doing with the money,	Santi, es que cuando mi papá se dé cuenta yo qué estoy haciendo con la plata,	S    , e  q   c      m  p    s  d  c      y  q   e     h        c   l  p    ,
208	1	it'll be too late	ya va a ser demasiado tarde.	y  v  a s   d         t    .
209	1	and eventually he'll learn that he can't manipulate me.	Y él eventualmente se va a tener que dar cuenta que no me puede manipular.	Y é  e             s  v  a t     q   d   c      q   n  m  p     m        .
210	1	Don't laugh. I'm serious. Okay.	No te rías, que es en serio. Okey, está bien.	N  t  r   , q   e  e  s    . O   , e    b   .
211	1	I'm going to use it for my bakery, for my brand,	La voy a utilizar para mi repostería, para abrir mi marca,	L  v   a u        p    m  r         , p    a     m  m    ,
212	1	my business, because that's my dream.	mi negocio, porque ese sí es mi sueño.	m  n      , p      e   s  e  m  s    .
213	1	I won't be an extension or shadow of anybody, Santiago. Period.	Yo no voy a ser la prolongación ni la sombra de absolutamente nadie, Santiago. Punto.	Y  n  v   a s   l  p            n  l  s      d  a             n    , S       . P    .
214	1	I'll support you. It's all good. Mmhmm.	Te banco. Muy bien, muy bien. Mjm.	T  b    . M   b   , m   b   . M  .
215	1	I have a question for you.	Y te hago una pregunta	Y t  h    u   p
216	1	Paris is on? Mmhmm. I'll take part in the workshops.	¿París va? Mjm. Voy, hago mis talleres	¿P     v ? M  . V  , h    m   t
217	1	I'll come back full of new ideas.	y llego llena de nuevas ideas.	y l     l     d  n      i    .
218	1	I'll leave this house that you know I've always found lonely.	me voy de esta casa que tú sabes que siempre se ha sentido muy sola.	m  v   d  e    c    q   t  s     q   s       s  h  s       m   s   .
219	1	First, you'll never feel lonely again	La primera es que sola no te vas a sentir nunca más	L  p       e  q   s    n  t  v   a s      n     m
220	1	so long as you're with me. Mmhmm.	mientras estés conmigo. Mjm.	m        e     c      . M  .
221	1	Okay, second thing. I'm going with you.	Bien, la segunda es que yo me voy con vos.	B   , l  s       e  q   y  m  v   c   v  .
222	1	We're going to Paris? Together.	¿Vamos a París? Nos vamos.	¿V     a P    ? N   v    .
223	1	What's your name? Romina Páez.	¿Cómo te llamas? Romina Páez.	¿C    t  l     ? R      P   .
224	1	We have to turn the car into a helicopter because we have to do 400,000 errands.	nos toca volver a ese carro un helicóptero porque tenemos que hacer como 400 000 vueltas.	n   t    v      a e   c     u  h           p      t       q   h     c    400 000 v      .
225	1	What happened to you?	¿Y a usted qué le pasó?	¿Y a u     q   l  p   ?
226	1	Your sugar is high. I knew I shouldn't have given you chocolate.	Se le subió el azúcar. Yo sabía que no le tenía que dar chocolate.	S  l  s     e  a     . Y  s     q   n  l  t     q   d   c        .
227	1	Of course, but... Who's that?	Claro que sí, pero… ¿Y esta quién es?	C     q   s , p   … ¿Y e    q     e ?
228	1	...this sport isn't very feminine.	…este deporte no es muy femenino.	…     d       n  e  m   f       .
229	1	She has your voice. The two of you are identical.	Es que es la misma voz. Son igualitas.	E  q   e  l  m     v  . S   i        .
230	1	Living in this neighborhood. That takes bravery.	Vivir en este barrio. Eso sí es para valientes.	V     e  e    b     . E   s  e  p    v        .
231	1	BE POSITIVE IN DOWNHILL RACE	PIENSA POSITIVO EN DOWNHILL	P      P        E  D
232	1	That's so weird, Rubén.	Esto está muy raro, Rubén.	E    e    m   r   , R    .
233	1	Because this neighborhood is full of moneylenders, loan sharks,	Porque este barrio está lleno de usureros, de prestamistas,	P      e    b      e    l     d  u       , d  p           ,
234	1	and payday lenders. They're screwing over the neighborhood.	de gota a gotas, y esos manes tienen jodido al barrio. Por eso.	d  g    a g    , y e    m     t      j      a  b     . P   e  .
235	1	Tell me something, officer. Do you want to die young?	Cuénteme una cosita, señor agente. ¿Usted se quiere morir joven?	C        u   c     , s     a     . ¿U     s  q      m     j    ?
236	1	It's great seeing you again.	Bacano volver a verla.	B      v      a v    .
237	1	Didn't your mom teach you that before you cross the street	¿A usted la mamá sí le enseñó que uno antes de cruzar la calle	¿A u     l  m    s  l  e      q   u   a     d  c      l  c
238	1	you should look both ways?	mira a un lado, mira al otro, y ahí sí	m    a u  l   , m    a  o   , y a   s
239	1	Did you realize you were riding into me instead of around me?	¿Y usted se dio cuenta que me estaba pasando por encima y no por los lados?	¿Y u     s  d   c      q   m  e      p       p   e      y n  p   l   l    ?
240	1	Nice to meet you. I'm Cristóbal Ruiz, better known as Whiz.	Mucho gusto, yo soy Cristóbal Ruiz, más conocido como Calidoso.	M     g    , y  s   C         R   , m   c        c    C       .
241	1	That's what people around here call me. But you know what?	Bueno, así me dice la gente por ahí. Pero venga, ¿sabe qué?	B    , a   m  d    l  g     p   a  . P    v    , ¿s    q  ?
242	1	I don't want to miss my chance to congratulate you.	Yo no quiero perder la oportunidad de felicitarla.	Y  n  q      p      l  o           d  f          .
243	1	For two things. First: that elegant jump you did.	Por dos cosas. La primera: ese salto tan elegante que se metió.	P   d   c    . L  p      : e   s     t   e        q   s  m    .
244	1	Really, you have all my respect.	De verdad, mis respetos para usted.	D  v     , m   r        p    u    .
245	1	Second: for having won that really difficult race.	Y la segunda: por haber ganado esa carrera tan difícil.	Y l  s      : p   h     g      e   c       t   d      .
246	1	You really have my respect and admiration too.	De verdad tiene mi respeto y mi admiración también.	D  v      t     m  r       y m  a          t      .
247	1	Could the two of us chat for a minute?	¿Será que usted y yo podemos charlar unos minutos?	¿S    q   u     y y  p       c       u    m      ?
248	1	I'll tell you the truth, so you don't waste your time.	Yo se las voy a cantar, para que no pierda el tiempo.	Y  s  l   v   a c     , p    q   n  p      e  t     .
249	1	I'm not interested in dating.	Yo no estoy interesada en nadie.	Y  n  e     i          e  n    .
250	1	How do you know what I'm going to say?	¿Usted acaso sabe lo que le voy a decir o qué?	¿U     a     s    l  q   l  v   a d     o q  ?
251	1	I don't, so tell me.	No sé. Entonces cuénteme.	N  s . E        c       .
252	1	I'd like to talk about the loan sharks you mentioned to the journalist.	Me gustaría que me hablara sobre los usureros que le comentó a la periodista.	M  g        q   m  h       s     l   u        q   l  c       a l  p         .
253	1	It's an issue I'm very interested in. Do you have a minute?	Ese es un tema que me interesa bastante. ¿Cree que se pueda?	E   e  u  t    q   m  i        b       . ¿C    q   s  p    ?
254	1	Basically, there's a monopoly of moneylenders,	Básicamente, el monopolio de los prestamistas,	B          , e  m         d  l   p           ,
255	1	loan sharks and payday lenders by one neighborhood family	de los cuentagotas, de la usura lo tiene una familia en el barrio,	d  l   c          , d  l  u     l  t     u   f       e  e  b     ,
256	1	and we all know exactly who they are.	y todos tenemos muy claro quiénes son.	y t     t       m   c     q       s  .
257	1	Who? The Chitiva brothers.	¿Quiénes son? Los Chitiva.	¿Q       s  ? L   C      .
258	1	Do you know how many of them there are?	¿Y usted sabe cuántos son ellos?	¿Y u     s    c       s   e    ?
259	1	And what do they do exactly?	¿Y los Chitiva qué es lo que hacen concretamente?	¿Y l   C       q   e  l  q   h     c            ?
260	1	Imagine they're an illegal bank.	Hágase de cuenta que ellos son como un banco, pero ilegal.	H      d  c      q   e     s   c    u  b    , p    i     .
261	1	They lend money to people	Ellos le prestan plata a las personas	E     l  p       p     a l   p
262	1	and then charge astronomical interest rates.	y después les cobran unos intereses por las nubes.	y d       l   c      u    i         p   l   n    .
263	1	Mr. Gonzalo, if you don't pay monthly, the interest increases.	Si usted no paga mensual, le sube el interés, don Gonzalo.	S  u     n  p    m      , l  s    e  i      , d   G      .
264	1	And if you get behind on payments	Y si usted se llega a atrasar,	Y s  u     s  l     a a      ,
265	1	I have to call a friend of mine with a wicked temper.	ahí sí me toca hablar con una amiga mía que tiene un genio de mierda.	a   s  m  t    h      c   u   a     m   q   t     u  g     d  m     .
266	1	Don't worry, Mr. Marlon.	No se preocupe, don Marlon.	N  s  p       , d   M     .
267	1	I'll pay on time.	Usted me tiene que cumplir.	U     m  t     q   c      .
268	1	Do you know what they do if people don't pay up?	¿Sabe qué le hacen a la gente que no paga a tiempo?	¿S    q   l  h     a l  g     q   n  p    a t     ?
269	1	They break into their homes and businesses and steal what little they have.	Se les meten a los negocios y a las casas y les roban lo poquito que tienen.	S  l   m     a l   n        y a l   c     y l   r     l  p       q   t     .
270	1	That's how they collect. Things are going to change.	Así cobran. Las cosas van a cambiar por acá.	A   c     . L   c     v   a c       p   a  .
271	1	I'll see to it myself. Mmm.	Yo me voy a encargar personalmente, ¿oyó?	Y  m  v   a e        p            , ¿o  ?
272	1	What do you say, kitty cat? Let's toast. Yeah.	¿Qué dice, Gatico? Brindemos. Sí.	¿Q   d   , G     ? B        . S .
273	1	Just like that. Cheers.	Así es que es. Salud.	A   e  q   e . S    .
274	1	Hey, what are you doing with my chain?	¿Qué, y usted para dónde va con mi cadena?	¿Q  , y u     p    d     v  c   m  c     ?
275	1	I'm borrowing it because I'm going to a honey's place.	La tomé prestada porque voy para donde una nenita.	L  t    p        p      v   p    d     u   n     .
276	1	Marlon, I want to ask you something else. I know about Yesenia's debt.	Venga, Marlon. Venía a pedirle otra cosa. Es que me enteré de la deuda de Yesenia.	V    , M     . V     a p       o    c   . E  q   m  e      d  l  d     d  Y      .
277	1	Don't go so hard on the old lady.	Cójala suave con la cucha. Todo bien.	C      s     c   l  c    . T    b   .
278	1	Who are you defending? The old lady or Romina?	¿A quién estamos defendiendo? ¿A la cucha o a Romina?	¿A q     e       d          ? ¿A l  c     o a R     ?
279	1	Come on, man. Leave that one to me. 	Ay, manito, venga. Déjeme esa cuenta a mí.	A , m     , v    . D      e   c      a m .
280	1	You know I'll get that money back.	Sabe que yo sé cómo recuperar esa platica con mañita.	S    q   y  s  c    r         e   p       c   m     .
281	1	You know what, Leo?	¿Sabe qué es lo que pasa, Leo?	¿S    q   e  l  q   p   , L  ?
282	1	You're trying to rein in that goat and she's sicced the police on us.	Usted se está enganchando a esa cabra y esa mujer nos tiene a la policía encima.	U     s  e    e           a e   c     y e   m     n   t     a l  p       e     .
283	1	If you don't give that account to me, I'm leaving all this shit behind	Si usted no me da esa cuenta a mí, yo me voy a largar de toda esta mierda	S  u     n  m  d  e   c      a m , y  m  v   a l      d  t    e    m
284	1	because I'm sick and tired.	porque estoy mamado de esto. 	p      e     m      d  e   .
285	1	I want to make money some other way.	Me quiero ganar mi plata de otra manera.	M  q      g     m  p     d  o    m     .
286	1	Check out the balls on this one.	Oigan a este huevoncito.	O     a e    h         .
287	1	Have you forgotten about family loyalty?	¿A usted se le olvida que debe lealtad a la familia?	¿A u     s  l  o      q   d    l       a l  f      ?
288	1	Romina will come out losing. 	Usted se llega a ir, y la que sale perdiendo es Romina.	U     s  l     a i , y l  q   s    p         e  R     .
289	1	Don't mess with her.	No se meta con ella. 	N  s  m    c   e   .
290	1	Hey, calm down. Nobody's leaving. It's all good.	Ey, ey, ya, calmados. Calmados. Aquí nadie se va a ir. Todo bien.	E , e , y , c       . C       . A    n     s  v  a i . T    b   .
291	1	Cut the shit now.	Deje la bobada ya.	D    l  b      y .
292	1	Nothing will happen to her if she keeps her trap shut.	A ella no le va a pasar nada si se calla la jeta.	A e    n  l  v  a p     n    s  s  c     l  j   .
293	1	if you don't forget where you belong.	Y a usted tampoco, si no se le olvida adónde pertenece.	Y a u     t      , s  n  s  l  o      a      p        .
294	1	Laurita, I have good news and bad news. Mmm.	Laurita, le tengo una noticia buena y una mala.	L      , l  t     u   n       b     y u   m   .
295	1	Start with the bad news.	Arranque por la mala.	A        p   l  m   .
296	1	I waited for no reason because the journalist has no idea	Perdí la espera de la periodista esa porque no tiene ni idea	P     l  e      d  l  p          e   p      n  t     n  i
297	1	where your doppelganger lives.	de dónde vive su doble.	d  d     v    s  d    .
298	1	But I asked her about the neighborhood they were filming in,	Ahora bien, averigüé cómo se llama el barrio donde hicieron la nota,	A     b   , a        c    s  l     e  b      d     h        l  n   ,
299	1	where the race was.	donde fue la competencia.	d     f   l  c          .
300	1	Oh, perfect. Let's go then.	Ah, bueno, perfect. Entonces, vamos.	A , b    , p      . E       , v    .
301	1	No. Let's not go.	No. Primero que todo, "vamos" no,	N . P       q   t   , "     " n ,
302	1	The neighborhood is far away and dangerous and I don't want you to go.	porque ese barrio es lejos, es peligroso y yo no quiero ir con usted.	p      e   b      e  l    , e  p         y y  n  q      i  c   u    .
303	1	I'll go first thing tomorrow morning	Pues yo voy mañana a primera hora.	P    y  v   m      a p       h   .
304	1	and I'll figure this out calmly.	Y yo averiguo con calma la cosa.	Y y  a        c   c     l  c   .
305	1	You know I could go with you, Rubencho.	Rubencho, pero usted sabe que yo puedo acompañarlo.	R       , p    u     s    q   y  p     a          .
306	1	I said no. No, Laurita. What if something happens? You never know.	Que no. No, Laurita, no, porque de pronto pasa algo. Uno no sabe.	Q   n . N , L      , n , p      d  p      p    a   . U   n  s   .
307	1	What would I say to your parents?	¿Y yo con qué le salgo a su papá y a su mamá?	¿Y y  c   q   l  s     a s  p    y a s  m   ?
308	1	No, leave it to me. No worries.	No, déjeme eso en mis manos. Tranquila.	N , d      e   e  m   m    . T        .
309	1	So, what was the good news?	¿Entonces cuál era la buena noticia? 	¿E        c    e   l  b     n      ?
310	1	How I like it. Yeah.	Como me gusta. Sí.	C    m  g    . S .
311	1	I'm asking for more patrol officers in La Mirla.	Para solicitarle más presencia de patrulleros en La Mirla.	P    s           m   p         d  p           e  L  M    .
312	1	To learn how loansharking works there so we can stop it.	Es importante ver cómo opera la usura en esa zona para poderla parar.	E  i          v   c    o     l  u     e  e   z    p    p       p    .
313	1	Let me tell you something, Ruiz.	Le voy a decir una cosa, Ruiz.	L  v   a d     u   c   , R   .
314	1	You're a renowned, judicious, disciplined and effective officer.	Usted es un policía destacado, juicioso, disciplinado, efectivo.	U     e  u  p       d        , j       , d           , e       .
315	1	But sometimes you have too much zeal. I don't know if that's a good thing.	Pero a veces le veo mucho afán. No sé si eso sea bueno o malo.	P    a v     l  v   m     a   . N  s  s  e   s   b     o m   .
316	1	I just want things to work.	Yo lo único que quiero es que las cosas funcionen.	Y  l  ú     q   q      e  q   l   c     f        .
317	1	To work well, quickly, and effectively.	Que funcionen bien y que funcionen rápido y efectivamente.	Q   f         b    y q   f         r      y e            .
318	1	And I can make that happen.	Y yo puedo hacer que eso suceda.	Y y  p     h     q   e   s     .
319	1	You're confident, eh, Sergeant?	Se tiene confianza, ¿no, sargento?	S  t     c        , ¿n , s       ?
320	1	Imagine if you were confident in me too.	Ahora imagínese que usted también me la tuviera.	A     i         q   u     t       m  l  t      .
321	1	Everything would be sorted.	Estaríamos del otro lado.	E          d   o    l   .
322	1	I'll do one thing. Two more patrol cars there.	Haré una cosa. Le pondré dos efectivos más allá.	H    u   c   . L  p      d   e         m   a   .
323	1	It's important that people report it.	Lo importante es que la gente denuncie.	L  i          e  q   l  g     d       .
324	1	Otherwise, we won't do anything. Just be present and patrol, nothing more.	O si no, no estamos haciendo nada. Solo presencia, patrullaje y nada más.	O s  n , n  e       h        n   . S    p        , p          y n    m  .
325	1	What's important? That people report it.	¿Qué es lo importante? Que la gente denuncie.	¿Q   e  l  i         ? Q   l  g     d       .
326	1	That people report it. Yes, sir.	Que la gente denuncie. Muy bien. Sí, señor.	Q   l  g     d       . M   b   . S , s    .
327	1	What Ramón says is true. What?	Lo que dice Ramón es cierto. ¿Qué?	L  q   d    R     e  c     . ¿Q  ?
328	1	That people are happy because there are patrol cars around.	Pues que la gente anda toda contenta porque hay pura patrulla, policía por acá.	P    q   l  g     a    t    c        p      h   p    p       , p       p   a  .
329	1	Talking to that reporter worked out, eh?	Le pegó ahí bien hablando con esa presentadora, ¿oyó?	L  p    a   b    h        c   e   p           , ¿o  ?
330	1	Or maybe something else worked.	O puede que otra cosita también haya funcionado.	O p     q   o    c      t       h    f         .
331	1	Some cop who's putting in the work.	Un policía por ahí que se está poniendo la diez.	U  p       p   a   q   s  e    p        l  d   .
332	1	A cop? Some guy named Cristóbal.	¿Un policía? Un tal Cristóbal.	¿U  p      ? U  t   C        .
333	1	What do you mean, "Oh, Whiz"? Is he famous?	¿Cómo que pues: "Ah, Calidoso"? ¿Es que es famoso o qué?	¿C    q   p   : "  , C       "? ¿E  q   e  f      o q  ?
334	1	No, he's not famous, but he is hot.	No, no, famoso no, pero está bueno.	N , n , f      n , p    e    b    .
335	1	Have you seen his lower back?	¿No le miró la espalda baja? 	¿N  l  m    l  e       b   ?
336	1	See it often or what?	¿Usted se la ha visto mucho o qué?	¿U     s  l  h  v     m     o q  ?
337	1	Smitten for authority figures.	¿Enamoradas de la autoridad?	¿E          d  l  a        ?
338	1	Hey, no. You know I'm enjoying being single.	Ay, oigan a esta. Tampoco. Yo en este momento estoy disfrutando de mi soltería.	A , o     a e   . T      . Y  e  e    m       e     d           d  m  s       .
339	1	Ah. With all my toys, girl.	Ah. Y con todos los juguetes, mija.	A . Y c   t     l   j       , m   .
340	1	Girl likes to play.	Pero qué manera de jugar la suya.	P    q   m      d  j     l  s   .
341	1	Until someone great comes around...	Hasta que no llegue alguien bien chimbita…	H     q   n  l      a       b    c       …
342	1	But it seems like someone likes Whiz.	A la que veo que sí está como que le gusta ese Calidoso es a otra.	A l  q   v   q   s  e    c    q   l  g     e   C        e  a o   .
343	1	Oh, I don't even recognize you.	Ay, no me la conociera yo.	A , n  m  l  c         y .
344	1	You like a cop, Romina?	¿Le gusta un polocho, Romina?	¿L  g     u  p      , R     ?
345	1	You like a cop?	¿Le gusta un polocho?	¿L  g     u  p      ?
346	1	No, Nayibe, I don't like him. I'm head over heels for him.	No, Nayibe, a mí no me gusta. A mí me encanta.	N , N     , a m  n  m  g    . A m  m  e      .
347	1	Girl... I can't stop thinking about him.	No me lo puedo sacar de la cabeza. 	N  m  l  p     s     d  l  c     .
348	1	What should I do?	¿Qué hago?	¿Q   h   ?
349	1	Your tastes vary, eh?	Oiga, es de gustos variados usted, ¿no?	O   , e  d  g      v        u    , ¿n ?
350	1	From Leo to a cop, quite the leap you took.	Porque de Leo a polocho, semejante brinco que pegó.	P      d  L   a p      , s         b      q   p   .
351	1	Do you happen to know Romina Páez,	¿Ustedes por casualidad conocen a Romina Páez,	¿U       p   c          c       a R      P   ,
352	1	the girl on the news who won the bike race?	la muchacha que ganó la competencia de ciclismo que salió en los noticieros?	l  m        q   g    l  c           d  c        q   s     e  l   n         ?
353	1	Yeah. Is it for another interview?	Sí, sí. ¿La van a volver a entrevistar?	S , s . ¿L  v   a v      a e          ?
354	1	Yes, but we have to keep it quiet because it's a secret.	Sí, lo que pasa es que no se puede saber porque es secreto.	S , l  q   p    e  q   n  s  p     s     p      e  s      .
355	1	Romina is going to be so famous.	La Romina se va a volver refamosa. 	L  R      s  v  a v      r       .
356	1	Do you know where she lives?	¿Saben dónde vive?	¿S     d     v   ?
357	1	Down this street, by the park.	Sí, bajando por esta, llegando al parque.	S , b       p   e   , l        a  p     .
358	1	You'll see colorful stairs and in the middle, there's a blue house.	Usted ahí ve unas escaleras de colores y en toda la mitad, una casa azul.	U     a   v  u    e         d  c       y e  t    l  m    , u   c    a   .
359	1	It has a drawing of a woman with the body of a horse.	Tiene un dibujo de una mujer con la mitad de cuerpo de caballo.	T     u  d      d  u   m     c   l  m     d  c      d  c      .
360	1	It's a centaur, Romina's signature. Alright, thank you.	Es una centauro. El sello de Romina. Bueno, muchas gracias.	E  u   c       . E  s     d  R     . B    , m      g      .
361	1	No, please leave it. No. No, please.	No, por favor, déjenlo. Ay, no.	N , p   f    , d      . A , n .
362	1	Please don't take our things. It's all we have.	No se nos lleven las cosas, por favor. Es lo único que tenemos.	N  s  n   l      l   c    , p   f    . E  l  ú     q   t      .
363	1	Those bastards have no respect.	Estos hijuemadres no respetan.	E     h           n  r       .
364	1	Without us, these people would lose their homes.	Si no llegamos, esa gente se lleva la casa y todo,	S  n  l       , e   g     s  l     l  c    y t   ,
365	1	They're rats, sewer rats. Yeah.	Positivo para ratas rerratas pero de alcantarilla. No.	P        p    r     r        p    d  a           . N .
366	1	Report it to Benítez. Alright.	¡Ah! Reportémosle a Benítez. Todo bien.	¡A ! R            a B      . T    b   .
367	1	Guarín to Benítez, do you copy?	Guarín a Benítez, ¿me copia?	G      a B      , ¿m  c    ?
368	1	We're going to stake out here in block 14. There are shady guys.	Vamos a iniciar seguimiento acá en la manzana 14 a sospechosos.	V     a i       s           a   e  l  m       14 a s          .
369	1	I've been waiting for you. Empty that quickly, man.	Pero ¿qué son estas horas de llegar? Bajando eso rapidito, hermano.	P    ¿q   s   e     h     d  l     ? B       e   r       , h      .
370	1	Hi, boss. The order arrived. Yes, sir. What do we do with it then?	Aló, patrón. Listo, ya llegó el encargo. Sí, señor. ¿Qué hacemos con eso entonces?	A  , p     . L    , y  l     e  e      . S , s    . ¿Q   h       c   e   e       ?
371	1	As you wish. Alright.	Listo, como ordene. Listo, listo.	L    , c    o     . L    , l    .
372	1	Hurry. That junk needs to be disassembled and sold for parts.	Apure, apure. Esas viejeras toca desenhuesarlas y venderlas por partes.	A    , a    . E    v        t    d              y v         p   p     .
373	1	We'll make more. Marlon's orders. Quickly.	Gana uno más. Órdenes de Marlon. Rápido, rápido.	G    u   m  . Ó       d  M     . R     , r     .
374	1	National Police. Don't move. National Police. Hands up.	Policía Nacional. Quieto, Policía Nacional. Manos arriba.	P       N       . Q     , P       N       . M     a     .
375	1	What's going on? I haven't done anything. 	Pero ¿qué pasa? Yo no he hecho nada. 	P    ¿q   p   ? Y  n  h  h     n   .
376	1	Those goods are stolen.	Toda esta mercancía es robada.	T    e    m         e  r     .
377	1	No, it's all legal. It's collateral.	No, todo es legal, de gente que lo pone en consignación.	N , t    e  l    , d  g     q   l  p    e  c           .
378	1	This is being seized	Esto queda decomisado 	E    q     d
379	1	and you're being charged with robbery and extortion. 	y ustedes quedan a disposición de la fiscalía por el delito de robo y extorsión.	y u       q      a d           d  l  f        p   e  d      d  r    y e        .
380	1	Arrest them!	 ¡Deténganlos!	¡D          !
381	1	Let's go. Against the wall.	Vámonos. Contra la pared.	V      . C      l  p    .
382	1	You have the right to remain silent.	Tiene derecho a guardar silencio.	T     d       a g       s       .
383	1	Anything you say can be used against you in a court of law.	Todo lo que diga puede ser usado en su contra en un tribunal de justicia.	T    l  q   d    p     s   u     e  s  c      e  u  t        d  j       .
384	1	What are you doing here? Did you forget I was picking you up?	¿Tú qué haces aquí? ¿Se te olvidó que te venía a recoger?	¿T  q   h     a   ? ¿S  t  o      q   t  v     a r      ?
385	1	No, Mari, but I have to do a thousand errands for...	No, Mari, lo que pasa es que tengo que hacer como mil vueltas…	N , M   , l  q   p    e  q   t     q   h     c    m   v      …
386	1	Forget it, you don't know what it took to get the appointment	Olvídalo. No sabes lo que demoré en conseguirte la cita	O       . N  s     l  q   d      e  c           l  c
387	1	with the planner you wanted. You don't turn 21 every day, friend.	con la diseñadora que querías. Y los 21 no se cumplen todos los días, my friend.	c   l  d          q   q      . Y l   21 n  s  c       t     l   d   , m  f     .
388	1	So, get in the car because we're leaving now.	Entonces, móntate al carro porque nos vamos ya.	E       , m       a  c     p      n   v     y .
389	1	And Rubencito let it slip	Y el Rubencito también me echó el chisme	Y e  R         t       m  e    e  c
390	1	that there won't be parents around for the party of the year.	de que estamos sin papás en la mejor rumba del año.	d  q   e       s   p     e  l  m     r     d   a  .
391	1	It'll be a blowout, Mari. That it will.	Vamos a hacer la superrumba, Mari. Así es.	V     a h     l  s         , M   . A   e .
392	1	That whole gang was arrested. Really?	Toda esa banda quedó capturada. ¿A lo bien?	T    e   b     q     c        . ¿A l  b   ?
393	1	What? You don't trust me?	Eh, pero bacano ese tonito de confianza, ¿oyó?	E , p    b      e   t      d  c        , ¿o  ?
394	1	No, wait, it's not that I don't believe you.	No, espérate, que no es que yo no le crea.	N , e       , q   n  e  q   y  n  l  c   .
395	1	It's that I'm impressed by how quickly you acted.	Más bien que me tiene impresionada con esa agilidad suya.	M   b    q   m  t     i            c   e   a        s   .
396	1	The party's over for them, Romina.	Es que se les acabó la fiesta, Romina. 	E  q   s  l   a     l  f     , R     .
397	1	It was a warning so they know they can't mess with the community.	Es una advertencia para que sepan que con la gente de la comunidad no se pueden meter.	E  u   a           p    q   s     q   c   l  g     d  l  c         n  s  p      m    .
398	1	I'm starting to think your nickname suits you, Whiz.	Ahora sí le estoy viendo bien puesto ese apodo: Calidoso.	A     s  l  e     v      b    p      e   a    : C       .
399	1	Does it suit me enough to get me an outing or not yet?	¿Tan bien puesto como para aceptarme una salidita o todavía no?	¿T   b    p      c    p    a         u   s        o t       n ?
400	1	An outing among friends, to grab a bite, or go dancing.	Una salidita, pero de parceros, a ir a tomar algo, ir a bailar un ratico.	U   s       , p    d  p       , a i  a t     a   , i  a b      u  r     .
401	1	Would your boyfriend let you? Boyfriend?	¿O no la deja el novio? ¿El novio?	¿O n  l  d    e  n    ? ¿E  n    ?
402	1	I don't have a boyfriend. No?	Yo novio no tengo. ¿No?	Y  n     n  t    . ¿N ?
403	1	What about that guy who congratulated you after the race?	¿Y el man que la vino a felicitar después de la carrera?	¿Y e  m   q   l  v    a f         d       d  l  c      ?
404	1	No, that guy's an ex.	No, ese man es un exflete, ya.	N , e   m   e  u  e      , y .
405	1	Does he know he's an ex? Have you told him?	¿Él sí sabe que es un exflete o no le ha dicho?	¿É  s  s    q   e  u  e       o n  l  h  d    ?
406	1	I've made it very clear to him.	Pues yo ya le dejé las cosas muy claras.	P    y  y  l  d    l   c     m   c     .
407	1	Are we going out?	¿Vamos a salir o qué?	¿V     a s     o q  ?
408	1	If we're going out, it can't be in the neighborhood.	Si me invita a salir, tiene que ser fuera del barrio.	S  m  i      a s    , t     q   s   f     d   b     .
409	1	No problem. 	Ah, pero eso no es problema.	A , p    e   n  e  p       .
410	1	Tell me where you want to go and I'll take you there.	Dígame adónde quiere ir, que yo la llevo donde usted me diga.	D      a      q      i , q   y  l  l     d     u     m  d   .
411	1	I don't know, Whiz. Get creative.	Ay, no sé, Calidoso. Póngase creativo.	A , n  s , C       . P       c       .
412	1	Aren't you asking me out?	¿No es usted el que me está invitando a salir a mí?	¿N  e  u     e  q   m  e    i         a s     a m ?
413	1	Alright, I'll surprise you.	Todo bien, yo la sorprendo.	T    b   , y  l  s        .
414	1	Romina Páez. Deal, Whiz.	Romina Páez. Calidoso, trato hecho.	R      P   . C       , t     h    .
415	1	No. Who's that bombshell?	No, no, no. ¿Y esto tan hermoso qué es?	N , n , n . ¿Y e    t   h       q   e ?
416	1	Where are you going?	¿Usted para dónde va?	¿U     p    d     v ?
417	1	What? Am I that ugly the rest of the time?	¿Cómo así? ¿Es que así de fea me veo siempre?	¿C    a  ? ¿E  q   a   d  f   m  v   s      ?
418	1	No, sweetheart, you're always gorgeous. 	No, mi amor, usted siempre se ve preciosa. 	N , m  a   , u     s       s  v  p       .
419	1	You're the prettiest and you know it.	Usted es la más linda y usted sabe.	U     e  l  m   l     y u     s   .
420	1	But I want to know why you're so dressed up.	Pero yo sí quiero saber el motivo de esa transformación.	P    y  s  q      s     e  m      d  e   t             .
421	1	Well, can you imagine someone asked me out?	Pues ¿cómo le parece que alguien me invitó a salir?	P    ¿c    l  p      q   a       m  i      a s    ?
422	1	No, darling. Stop dragging Leo along.	Ay, hija. Ya no le dé más alas a Leo, pues.	A , h   . Y  n  l  d  m   a    a L  , p   .
423	1	Leo? Oh, no, Ms. Yesenia. Let's get you up to date.	¿A Leo? Ay, no, doña Yesenia. Venga, actualicémonos.	¿A L  ? A , n , d    Y      . V    , a             .
424	1	You think I'd go out with Leo? Then, who?	¿Cree que con Leo? ¿Entonces, con quién?	¿C    q   c   L  ? ¿E       , c   q    ?
425	1	That nice police officer?	¿El policía ese tan simpático?	¿E  p       e   t   s        ?
426	1	If you'd like I can introduce him to you so you two can go out.	Ay, mija, pero si quiere, se lo presento para que salga usted con él.	A , m   , p    s  q     , s  l  p        p    q   s     u     c   é .
427	1	I like him for you.	Ese muchacho me gusta para usted.	E   m        m  g     p    u    .
428	1	Mmm. Where are you going?	Mjm. ¿Y adónde van?	M  . ¿Y a      v  ?
429	1	I don't know, but he's got good ideas, so he's going to surprise me.	No sé. El muchacho tiene buenas ideas, así que me voy a dejar sorprender.	N  s . E  m        t     b      i    , a   q   m  v   a d     s         .
430	1	My kiss? Take care.	¿Mi beso? Se me cuida.	¿M  b   ? S  m  c    .
431	1	I want you home at 12:00.	Vea, a las 12:00 la quiero ver aquí, ¿no?	V  , a l   12:00 l  q      v   a   , ¿n ?
432	1	At 12:00? Yes, ma'am.	¿A las 12:00? Sí, señorita.	¿A l   12:00? S , s       .
433	1	What am I, Cinderella? Yes, ma'am.	¿Qué, Cenicienta o qué? Sí, señorita.	¿Q  , C          o q  ? S , s       .
434	1	Alright, 1:15. Alright, bye.	Bueno, está bien, 1:15. Sí, chao.	B    , e    b   , 1:15. S , c   .
435	1	Be good. Yes, ma'am.	Se me porta bien, ¿no? ¡Sí, señora!	S  m  p     b   , ¿n ? ¡S , s     !
436	1	You sure do look different out of your uniform.	Siempre es que se ve bien distinto sin uniforme.	S       e  q   s  v  b    d        s   u       .
437	1	You look beautiful too.	Usted también se ve superlinda.	U     t       s  v  s         .
438	1	Give me that, I'll hold it for you.	Venga, venga. Yo le colaboro con eso.	V    , v    . Y  l  c        c   e  .
439	1	Did you ride Ebony here?	¿Y usted qué? ¿Se vino en la Morocha o qué?	¿Y u     q  ? ¿S  v    e  l  M       o q  ?
440	1	Of course. How else would I get here?	Obvio. ¿Y cómo me iba a venir?	O    . ¿Y c    m  i   a v    ?
441	1	Thanks. Let's order. I'm starving.	Gracias. Pidamos más bien que qué filo.	G      . P       m   b    q   q   f   .
442	1	So, Whiz, is this the surprise?	Y entonces, Calidoso, ¿esta era la sorpresita?	Y e       , C       , ¿e    e   l  s         ?
443	1	Look me in the eyes, Romina.	Romina, míreme a los ojos.	R     , m      a l   o   .
444	1	You really think this is the surprise?	¿Usted de verdad piensa que esta es la sorpresa?	¿U     d  v      p      q   e    e  l  s       ?
445	1	No, this is to warm up,	No. Vea. Esto es para que entremos en calor,	N . V  . E    e  p    q   e        e  c    ,
446	1	grab a bite, dance a bit,	para que comamos alguito, para que bailemos un ratico,	p    q   c       a      , p    q   b        u  r     ,
447	1	and then I'll take you to the surprise. Alright?	y después la llevo adonde está la sorpresa. ¿Listo?	y d       l  l     a      e    l  s       . ¿L    ?
448	1	Okay, but there's a small problem.	Bueno, pero hay un problemita.	B    , p    h   u  p         .
449	1	What? What do we do with Ebony?	¿Cuál? ¿Qué hacemos con la Morocha?	¿C   ? ¿Q   h       c   l  M      ?
450	1	We'll put Ebony in the car my buddy lent me. It's a tank.	La Morocha la metemos ahí, en el carro que me prestó mi primo que es una nave.	L  M       l  m       a  , e  e  c     q   m  p      m  p     q   e  u   n   .
451	1	Did you think I'd come in the patrol car?	¿Cree que iba a venir en la patrulla o qué?	¿C    q   i   a v     e  l  p        o q  ?
452	1	I'm gonna steal a sip because... Go ahead.	Le voy a robar un poquito porque… Hágale.	L  v   a r     u  p       p     … H     .
453	1	That bike ride and...	Por lo de la bicicleta y…	P   l  d  l  b         y…
454	1	What do you like?	¿Qué le gusta a usted?	¿Q   l  g     a u    ?
455	1	Anything's good for me.	Mijo, lo que sea.	M   , l  q   s  .
456	1	Hey, do you know how to dance?	Uy, ¿usted sabe bailar de verdad?	U , ¿u     s    b      d  v     ?
457	1	Hey, the real question is: Do you know how to dance?	Ay, aquí la pregunta es: ¿usted sabe bailar de verdad?	A , a    l  p        e : ¿u     s    b      d  v     ?
458	1	Have you noticed that we even dance similarly?	¿Se da cuenta que usted y yo hasta bailando nos parecemos?	¿S  d  c      q   u     y y  h     b        n   p        ?
459	1	How else are we similar?	¿Y es que en qué más nos parecemos pues?	¿Y e  q   e  q   m   n   p         p   ?
460	1	We both like going fast, right?	A los dos nos gusta la velocidad, ¿cierto?	A l   d   n   g     l  v        , ¿c     ?
461	1	We like to win too.	Nos gusta ganar también.	N   g     g     t      .
462	1	We like helping people. Mmm.	Nos gusta ayudar a la gente.	N   g     a      a l  g    .
463	1	Among other things, but you know what? What?	Entre otras cosas, pero ¿sabe qué? ¿Qué?	E     o     c    , p    ¿s    q  ? ¿Q  ?
464	1	Sometimes, I also think...	A veces, también yo creo que…	A v    , t       y  c    q  …
465	1	Going slow is cool. Yeah?	Que ir lento es chévere. ¿Sí?	Q   i  l     e  c      . ¿S ?
466	1	Yeah, well, the thing is...	Uy, lo que pasa es que a mí eso	U , l  q   p    e  q   a m  e
467	1	going slow doesn't really work for me.	de ir lento como que no se me da.	d  i  l     c    q   n  s  m  d .
468	1	I don't know how to turn this off.	No sé de dónde apagar esto.	N  s  d  d     a      e   .
469	1	This is where we're going? Come on.	¿Y acá qué o qué? Venga, venga.	¿Y a   q   o q  ? V    , v    .
470	1	What's this beauty's name?	¿Y esta belleza cómo se llama?	¿Y e    b       c    s  l    ?
471	1	Wow, what a beauty!	¡Ay! ¿Qué es esta belleza?	¡A ! ¿Q   e  e    b      ?
472	1	...thought it'd be the perfect place to bring the centaur of La Mirla.	…pensé que era el lugar perfecto para traer a la centaura de La Mirla.	…      q   e   e  l     p        p    t     a l  c        d  L  M    .
473	1	How did you pull this off?	¿Y usted cómo hizo para conseguirse esto, ah?	¿Y u     c    h    p    c           e   , a ?
474	1	I've got friends who are rangers that can pull strings for me.	que uno tiene primos carabineros que le hacen el cuarto a uno.	q   u   t     p      c           q   l  h     e  c      a u  .
475	1	I should go out with your friend.	Me va a tocar es salir más bien con el primo.	M  v  a t     e  s     m   b    c   e  p    .
476	1	All that's left is for us to enjoy this moment.	Ahora solamente nos queda disfrutar de este momento, ¿no?	A     s         n   q     d         d  e    m      , ¿n ?
477	1	Now I'm surprised, Whiz.	Ahora sí me dejó sorprendida, Calidoso.	A     s  m  d    s          , C       .
479	1	I know we'll have a good time.	Yo sé que la vamos a pasar muy bien, ¿oyó?	Y  s  q   l  v     a p     m   b   , ¿o  ?
480	1	A lot of the seized goods were from the neighbors.	Mucha de la mercancía que fue incautada era de los vecinos.	M     d  l  m         q   f   i         e   d  l   v      .
481	1	They were stolen to pay the loan sharks.	La robaron para pagarle a los gota a gota.	L  r       p    p       a l   g    a g   .
482	1	That's good news, Major.	Excelente noticia, mi mayor.	E         n      , m  m    .
483	1	Nothing happened yet. Nobody reported the Chitiva brothers.	Pero ahí no pasó nada. Nadie denunció a los Chitiva.	P    a   n  p    n   . N     d        a l   C      .
484	1	People say it's not them, it's smalltime loan sharks.	La gente dice que no, que le pedían a unos gota a gota menores.	L  g     d    q   n , q   l  p      a u    g    a g    m      .
485	1	No, Major. The Chitiva brothers are involved.	No, mi mayor. Los Chitiva tenían que ver ahí.	N , m  m    . L   C       t      q   v   a  .
486	1	The people who took things to John Alexis' secondhand shop work for the Chitiva brothers.	La gente que se llevó las cosas para la compraventa de John Alexis trabaja para los Chitiva.	L  g     q   s  l     l   c     p    l  c           d  J    A      t       p    l   C      .
487	1	He'd rather pay than rat them out.	Él prefiere pagar que echar al agua a esa gente.	É  p        p     q   e     a  a    a e   g    .
488	1	That's what's happening.	Eso es lo que está pasando, mi mayor.	E   e  l  q   e    p      , m  m    .
489	1	 People are afraid to talk.	La gente no quiere hablar por miedo.	L  g     n  q      h      p   m    .
490	1	They're ruled by fear.	Están gobernados a punta de terror.	E     g          a p     d  t     .
491	1	Prove it, Ruiz, prove it. 	Compruébelo, Ruiz, compruébelo. 	C          , R   , c          .
492	1	Get people to report the Chitiva brothers.	Haga que la gente denuncie a los Chitiva.	H    q   l  g     d        a l   C      .
493	1	If you do that, we'll have a case against them.	Si logra eso, tenemos un caso contra ellos.	S  l     e  , t       u  c    c      e    .
494	1	The first case that you'll be in charge of in La Mirla.	El primer caso en que usted va a estar al mando allá en La Mirla.	E  p      c    e  q   u     v  a e     a  m     a    e  L  M    .
495	1	Let me say something, Sergeant.	Pero le digo una cosa, sargento.	P    l  d    u   c   , s       .
496	1	La Mirla is a rough neighborhood.	La Mirla es un barrio complejo.	L  M     e  u  b      c       .
497	1	I know the responsibility it entails, and I won't let you down.	Y sé la responsabilidad que eso conlleva. Por eso no le voy a quedar mal.	Y s  l  r               q   e   c       . P   e   n  l  v   a q      m  .
498	1	You know what a lot of people here say?	¿Sabe qué dice mucha gente de la institución, Ruiz?	¿S    q   d    m     g     d  l  i          , R   ?
499	1	That you're too green for this.	Que usted está muy biche para esto.	Q   u     e    m   b     p    e   .
500	1	That's what they say. Prove them wrong.	Eso dicen. Demuéstreles que no.	E   d    . D            q   n .
501	1	Show them I'm not wrong for putting you in charge of this.	Demuéstreles que yo no me equivoqué poniéndolo a usted a cargo de esto.	D            q   y  n  m  e         p          a u     a c     d  e   .
502	1	I promise I won't let you down.	Le prometo que no le voy a quedar mal.	L  p       q   n  l  v   a q      m  .
503	1	Thank you for trusting me.	Muchas gracias por la confianza.	M      g       p   l  c        .
504	1	Permission to leave. Go.	Permiso para retirarme. Mar.	P       p    r        . M  .
505	1	Second base right off the bat? Yeah.	¿A segunda base de una? Sisas.	¿A s       b    d  u  ? S    .
506	1	It was so awesome, Nayi. It all just flowed.	Es que todo fue tan chimba, Nayi. Como que todo fluyó.	E  q   t    f   t   c     , N   . C    q   t    f    .
507	1	It's like he and I have known each other our whole lives.	Es como si Cristóbal y yo nos conociéramos de toda la vida.	E  c    s  C         y y  n   c            d  t    l  v   .
508	1	In other words, it was rough, eh?	Mejor dicho, como triciclo en loma usted, ¿no?	M     d    , c    t        e  l    u    , ¿n ?
509	1	That's the way it is. So... So what?	Así es que es. Pero vea, ¿y qué? ¿De qué o qué?	A   e  q   e . P    v  , ¿y q  ? ¿D  q   o q  ?
510	1	But you know what? What?	Pero ¿sabe qué? ¿Qué?	P    ¿s    q  ? ¿Q  ?
511	1	You seem happy. Yeah.	La veo contenta. Sí.	L  v   c       . S .
512	1	And I like it. He treated you well.	Y me gusta. Me la atendieron.	Y m  g    . M  l  a         .
513	1	Very well, girl. As it should be, girl.	Y muy bien, pelada. Así es que es, mija.	Y m   b   , p     . A   e  q   e , m   .
514	1	Tell that man Whiz to keep a low profile.	Dígale a este man de Calidoso que maneje el bajo perfil.	D      a e    m   d  C        q   m      e  b    p     .
515	1	You mean because of Leo?	¿Lo dice por lo de Leo o qué?	¿L  d    p   l  d  L   o q  ?
516	1	No, not just because of that. Then what?	No, no lo digo solo por eso. ¿Entonces?	N , n  l  d    s    p   e  . ¿E       ?
517	1	It's just that Whiz sticks out like a sore thumb here.	Es que, pelada, este man de Calidoso está dando mucho visaje por acá.	E  q  , p     , e    m   d  C        e    d     m     v      p   a  .
518	1	And you know how the Chitiva brothers deal with that.	Y usted sabe cómo manejan los Chitivas esas vainas.	Y u     s    c    m       l   C        e    v     .
519	1	The house is just down this hill.	Aquí después de esta bajada queda la casa.	A    d       d  e    b      q     l  c   .
520	1	But, honey, this neighborhood is dangerous.	Pero, niña, este barrio es peligroso.	P   , n   , e    b      e  p        .
521	1	So I'll wait for you in the car,	Entonces yo la voy a esperar dentro del carro,	E        y  l  v   a e       d      d   c    ,
522	1	but be careful, and please come back soon.	pero se me cuida y, por favor, no se demora.	p    s  m  c     y, p   f    , n  s  d     .
523	1	Don't worry, Rubén. I won't be long. I promise.	Rubén, fresco que yo no me voy a demorar. Se lo prometo.	R    , f      q   y  n  m  v   a d      . S  l  p      .
524	1	Are you expecting someone, Ma?	Ma, ¿usted está esperando a alguien?	M , ¿u     e    e         a a      ?
525	1	No, maybe it's Esperancita coming by for empanadas.	No, de pronto vino Esperancita por sus empanadas.	N , d  p      v    E           p   s   e        .
526	1	Okay, I'll give them to her.	Bueno, yo se las paso.	B    , y  s  l   p   .
527	1	Now we know the Chitivas organization	Hasta hoy sabemos que la organización de los Chitiva	H     h   s       q   l  o            d  l   C
528	1	is made up of loan sharks, debt collectors, mercenaries,	está compuesta por prestamistas, cobradores, sicarios,	e    c         p   p           , c         , s       ,
529	1	and people who make evidence disappear.	gente de limpieza que se encarga de desaparecer la evidencia.	g     d  l        q   s  e       d  d           l  e        .
530	1	No wonder people are scared shitless and won't report them.	Con razón la gente está cagada del susto y no se atreve a denunciarlos.	C   r     l  g     e    c      d   s     y n  s  a      a d           .
531	1	Exactly. And we need to quell that fear.	Exactamente. Y nosotros les tenemos que quitar ese miedo.	E          . Y n        l   t       q   q      e   m    .
532	1	We have to turn off the water to what we call	Nosotros tenemos que cerrarle la llave a lo que denominé	N        t       q   c        l  l     a l  q   d
533	1	the faucet mafia. Are you with me?	como la mafia del grifo, ¿estamos?	c    l  m     d   g    , ¿e      ?
534	1	I saw you on...	Yo te había visto en…	Y  t  h     v     e …
535	1	the news when you were interviewed after the race.	en el noticiero por la entrevista que te hicieron por tu competencia.	e  e  n         p   l  e          q   t  h        p   t  c          .
536	1	And well, I was stunned by...	Y pues yo había quedado en shock por…	Y p    y  h     q       e  s     p  …
537	1	how similar we look.	por el parecido que tenemos.	p   e  p        q   t      .
538	1	in front of me now...	Pues ahoritica que te… que te miro es…	P    a         q   t … q   t  m    e …
539	1	is like looking in a mirror.	Es como estar mirándome a un espejo.	E  c    e     m         a u  e     .
540	1	We're not similar, we're...	Es que no somos parecidas, somos…	E  q   n  s     p        , s    …
541	1	Who are you talking to, hon?	Mi amor, ¿con quién hablas?	M  a   , ¿c   q     h     ?
542	1	Did you know I had a doppelganger, Ma?	Ma, ¿usted sabía que yo tenía una doble?	M , ¿u     s     q   y  t     u   d    ?
543	1	Eh? Like in the movies.	¿Ah? Así como en las películas.	¿A ? A   c    e  l   p        .
544	1	Hey there, what happened?	Ey, pelada, ¿qué le pasó?	E , p     , ¿q   l  p   ?
545	1	Want some water? I'll bring you some water.	¿Le traigo agüita? Le voy a traer agüita.	¿L  t      a     ? L  v   a t     a     .
546	1	It must be quite a shock to see how similar we look, but it's all good.	Le debió dar mucha impresión vernos tan parecidas, pero todo bien.	L  d     d   m     i         v      t   p        , p    t    b   .
547	1	What are your parents' names?	¿Cómo se llaman sus papás?	¿C    s  l      s   p    ?
548	1	Oh my God. Could it be?	Ay, Dios mío. ¿Será posible?	A , D    m  . ¿S    p      ?
549	1	I don't believe it.	Es que no me lo puedo creer.	E  q   n  m  l  p     c    .
550	1	I don't believe it.	No me lo puedo creer.	N  m  l  p     c    .
551	1	No, well, Ma, explain it to us. We don't get what's going on either.	No, pues, ma, explícanos, que nosotras tampoco entendemos qué está pasando.	N , p   , m , e         , q   n        t       e          q   e    p      .
552	1	I don't even know where to start.	No sé ni por dónde empezar.	N  s  n  p   d     e      .
553	1	Please have a seat, both of you.	Por favor, siéntense las dos.	P   f    , s         l   d  .
554	1	I worked as a machine operator	trabajé como operaria	t       c    o
555	1	in your father's family food plant.	en la fábrica de alimentos de la familia de su papá.	e  l  f       d  a         d  l  f       d  s  p   .
556	1	But one day things changed.	Pero un día las cosas cambiaron.	P    u  d   l   c     c        .
557	1	I had to stay late and Sergio was there.	Yo tuve que quedarme hasta tarde y Sergio estaba allí.	Y  t    q   q        h     t     y S      e      a   .
558	1	I heard things were not going well	Y me contaron que él estaba muy mal con la mujer	Y m  c        q   é  e      m   m   c   l  m
559	1	between him and the woman he had just married.	con la que se acababa de casar.	c   l  q   s  a       d  c    .
560	1	And I wanted to be kind,	Y pues yo quise ser amable,	Y p    y  q     s   a     ,
561	1	without ever thinking it would change the rest of my life.	sin imaginar que eso me iba a cambiar el resto de la vida.	s   i        q   e   m  i   a c       e  r     d  l  v   .
562	1	Have you ever felt alone?	¿Alguna vez te has sentido sola?	¿A      v   t  h   s       s   ?
563	1	And how do you fight the loneliness?	¿Y qué haces para quitar la soledad?	¿Y q   h     p    q      l  s      ?
564	1	When he told me	Cuando él me contó	C      é  m  c
565	1	things were rocky with his wife and I saw him so sad, well...	que estaba mal con su esposa y lo vi así tan triste,	q   e      m   c   s  e      y l  v  a   t   t     ,
566	1	it broke my heart.	pues me partió el corazón.	p    m  p      e  c      .
567	1	We started sneaking around, so nobody would know.	Comenzamos a vernos así, a escondidas, sin que nadie lo supiera.	C          a v      a  , a e         , s   q   n     l  s      .
568	1	Oh, sweetheart, I was so in love.	Ay, mi amor, yo estaba tan enamorada.	A , m  a   , y  e      t   e        .
569	1	I was a simp, as you girls say.	Estaba en una tragada maluca, así como ustedes dicen.	E      e  u   t       m     , a   c    u       d    .
570	1	It was like in the movies.	Fue un romance así como de película.	F   u  r       a   c    d  p       .
571	1	Until I got pregnant.	Hasta que quedé embarazada.	H     q   q     e         .
572	1	Of course, I was careful.	Pues claro que me cuidé,	P    c     q   m  c    ,
573	1	But these things happen all the time.	pero esas cosas pasan todo el tiempo.	p    e    c     p     t    e  t     .
574	1	What are we going to do?	¿Y qué vamos a hacer, eh?	¿Y q   v     a h    , e ?
575	1	We have to find a solution.	Hay que buscar una solución.	H   q   b      u   s       .
576	1	There's nothing to solve.	Es que aquí no hay nada que solucionar.	E  q   a    n  h   n    q   s         .
577	1	I'm having this baby with or without you.	Este hijo yo lo voy a tener contigo o sin ti.	E    h    y  l  v   a t     c       o s   t .
578	1	and break up with her.	Y poder separarme de ella.	Y p     s         d  e   .
579	1	A baby would be incredible.	Tener un hijo sería increíble.	T     u  h    s     i        .
580	1	I don't want to miss this chance.	Y no pienso perder esa oportunidad.	Y n  p      p      e   o          .
581	1	And much less, lose you.	Y mucho menos, pienso perderte a ti.	Y m     m    , p      p        a t .
582	1	Everything will be fine, okay?	Todo va a salir bien, ¿vale?	T    v  a s     b   , ¿v   ?
583	1	When Sergio found out I was having twins...	Cuando Sergio supo que eran gemelas…	C      S      s    q   e    g      …
584	1	and he took me to live in a beautiful place, away from everything	y me llevó a vivir a un lugar así bien bonito, apartado de todo,	y m  l     a v     a u  l     a   b    b     , a        d  t   ,
585	1	so I'd be stressfree.	para que yo estuviera bien tranquila.	p    q   y  e         b    t        .
586	1	He even hired a private nurse.	Y hasta me contrató una enfermera privada.	Y h     m  c        u   e         p      .
587	1	Can you imagine? I had a nurse just for me.	¿Ustedes se imaginan? Yo con enfermera para mí y todo.	¿U       s  i       ? Y  c   e         p    m  y t   .
588	1	I spent my pregnancy there and it was a very happy time for me.	Allí pasé mi embarazo y fue una época tan feliz.	A    p    m  e        y f   u   é     t   f    .
589	1	And then I went into labor	Y luego llegó el momento del parto pues.	Y l     l     e  m       d   p     p   .
590	1	and things got complicated.	Y todo se complicó.	Y t    s  c       .
591	1	Harder, come on. Harder.	Tira más fuerte. Vamos. Tira más.	T    m   f     . V    . T    m  .
592	1	Come on, you can do it. Breathe.	Dale, dale, vamos. Respira, respira.	D   , d   , v    . R      , r      .
593	1	You're doing great. Push hard.	Vas muy bien. Empuja, empuja fuerte.	V   m   b   . E     , e      f     .
594	1	The nurse told me that one of the babies was stillborn.	La enfermera me dijo que una de las bebés había nacido muerta.	L  e         m  d    q   u   d  l   b     h     n      m     .
595	1	And that Sergio took her so that I wouldn't see her bruised body	Y que Sergio se la había llevado para que yo no la viera así toda moreteada	Y q   S      s  l  h     l       p    q   y  n  l  v     a   t    m
596	1	because she was strangled by the umbilical cord.	porque se había ahorcado con el cordón umbilical.	p      s  h     a        c   e  c      u        .
597	1	She told me to focus on the baby I still had.	Me dijo que me enfocara en la bebé que me quedaba.	M  d    q   m  e        e  l  b    q   m  q      .
598	1	So that's what I did.	Pues eso fue lo que yo hice.	P    e   f   l  q   y  h   .
599	1	That was you. My Romina.	Y esa fue usted. Mi Romina.	Y e   f   u    . M  R     .
600	1	that I didn't know you were alive.	que yo no sabía que usted estaba viva.	q   y  n  s     q   u     e      v   .
601	1	I swear that I had no idea.	Se lo juro, de verdad. Yo no tenía ni idea.	S  l  j   , d  v     . Y  n  t     n  i   .
602	1	 I'm so sorry.	 Lo siento muchísimo. 	L  s      m        .
603	1	I had no idea.	Yo no tenía ni idea.	Y  n  t     n  i   .
604	1	Then things with Sergio changed. He told me...	Ya después, Sergio cambió conmigo. Me dijo que…	Y  d      , S      c      c      . M  d    q  …
605	1	we couldn't be together.	Que lo nuestro no podía ser.	Q   l  n       n  p     s  .
606	1	That he'd go back to his wife.	Que él iba a volver con su esposa.	Q   é  i   a v      c   s  e     .
607	1	And he gave me money for us to disappear from his life.	Y me dio un dinero para que desapareciéramos de su vida.	Y m  d   u  d      p    q   d                d  s  v   .
608	1	And, sweetheart, the truth is...	Y, mi amor, la verdad es que…	Y, m  a   , l  v      e  q  …
609	1	I took it, because I was thinking of you, my baby.	Es que yo lo acepté, porque estaba pensando en usted, en mi bebé.	E  q   y  l  a     , p      e      p        e  u    , e  m  b   .
610	1	I couldn't go back to the plant and we needed somewhere to live	Yo no podía volver a la fábrica y necesitábamos un lugar donde dormir	Y  n  p     v      a l  f       y n             u  l     d     d
611	1	But it was very little, it wasn't enough. Ma.	Pero fue muy poquito. No me alcanzó. Ma.	P    f   m   p      . N  m  a      . M .
612	1	You don't have to justify anything.	Usted no se tiene que justificar de nada.	U     n  s  t     q   j          d  n   .
613	1	I was so naïve, Romina.	Es que yo fui tan ingenua, Romina.	E  q   y  f   t   i      , R     .
614	1	I should've looked into what happened to the other baby	Yo tendría que haber averiguado qué pasó con la bebé	Y  t       q   h     a          q   p    c   l  b
615	1	that was supposedly stillborn.	que supuestamente había nacido muerta.	q   s             h     n      m     .
616	1	But I was so broken, sweetheart. I was so sad,	Yo estaba tan rota, mi amor. Me sentía tan mal	Y  e      t   r   , m  a   . M  s      t   m
617	1	and only had the energy to focus on the baby I still had.	que solo tenía energía para enfocarme en la bebé que me quedaba.	q   s    t     e       p    e         e  l  b    q   m  q      .
618	1	my mom isn't... No, ma'am.	mi mamá no es… No, señora.	m  m    n  e … N , s     .
619	1	Virginia might have raised you,	Virginia la pudo haber criado,	V        l  p    h     c     ,
620	1	but I'm your mother.	pero su mamá soy yo.	p    s  m    s   y .
621	1	I'm the one who gave birth to you,	Yo fui la que la parió,	Y  f   l  q   l  p    ,
622	1	and carried you in my belly for nine months.	 la que la llevó en su barriga durante nueve meses.	l  q   l  l     e  s  b       d       n     m    .
623	1	The one who loved you from the moment I knew you...	Y la que la amó desde el momento en que sabía que usted	Y l  q   l  a   d     e  m       e  q   s     q   u
624	1	And Sergio didn't let me raise you or see you grow up.	Y Sergio me quitó la posibilidad de criarla, de verla crecer.	Y S      m  q     l  p           d  c      , d  v     c     .
625	1	I don't think my dad could do...	Yo no creo que mi papá haya sido capaz de hacer…	Y  n  c    q   m  p    h    s    c     d  h    …
626	1	So my mom is lying?	¿Entonces es mi mamá la que está diciendo mentiras?	¿E        e  m  m    l  q   e    d        m       ?
627	1	No, I'm not... I'm not saying that, but...	No, yo no estoy… Yo no estoy diciendo eso, pero…	N , y  n  e    … Y  n  e     d        e  , p   …
628	1	But what? Huh? Everything is very clear to me.	Pero ¿qué? ¿Ah? Pues, pelada, para mí las cosas están muy claras.	P    ¿q  ? ¿A ? P   , p     , p    m  l   c     e     m   c     .
629	1	Romina, sweetheart, please. This is a lot for all of us to take in.	Romina, mi amor, por favor. Esto es mucho para asimilar para todos.	R     , m  a   , p   f    . E    e  m     p    a        p    t    .
630	1	I'm so sorry, sweetheart. But everything is going to be fine.	Mi amor, lo siento mucho, pero todo va a estar bien.	M  a   , l  s      m    , p    t    v  a e     b   .
631	1	Everything is going to be fine.	Todo va a estar bien.	T    v  a e     b   .
632	1	Well, that's what we have now.	Pues ahora eso es lo que tenemos.	P    a     e   e  l  q   t      .
633	1	Time to get to know each other and love each other.	Tiempo para conocernos y querernos.	T      p    c          y q        .
634	1	We're short. What happened to Julio Pineda?	Aquí falta. ¿Qué pasó con Julio Pineda?	A    f    . ¿Q   p    c   J     P     ?
635	1	Doesn't he know I'll get him if he doesn't pay?	¿Ese cabrón no entiende que si no paga lo pico?	¿E   c      n  e        q   s  n  p    l  p   ?
636	1	What's up? All good?	¿Qué pasa? ¿Todo bien?	¿Q   p   ? ¿T    b   ?
637	1	They found the snitch passing info on us to the police.	Pillaron al sapo que le está pasando información de nosotros a la policía.	P        a  s    q   l  e    p       i           d  n        a l  p      .
638	1	Who is it? Guess who? Romina Páez.	¿Quién es? Adivine. Romina Páez.	¿Q     e ? A      . R      P   .
639	1	They saw her talking with a cop named Cristóbal Ruiz.	La pillaron hablando con un polocho que se llama Cristóbal Ruiz.	L  p        h        c   u  p       q   s  l     C         R   .
640	1	They call him Whiz.	Al man le dicen el Calidoso.	A  m   l  d     e  C       .
641	1	We should've cut that snitch's tongue out, Benny.	A esa sapa tuvimos que haberle quitado la lengua, Benny.	A e   s    t       q   h       q       l  l     , B    .
642	1	Should we go scare her? You tell me.	Usted dirá. ¿La mandamos asustar o qué?	U     d   . ¿L  m        a       o q  ?
643	1	We have to kill her.	Hay que matarla	H   q   m
2094	25	Your dad kidnapped you and told you lies your whole life.	Su papá la secuestró y le dijo mentiras toda su vida.	S  p    l  s         y l  d    m        t    s  v   .
2095	25	And he told my mom that you had died in the cruelest way possible.	Y a mi mamá le dijo de la manera más cruel posible que se había muerto.	Y a m  m    l  d    d  l  m      m   c     p       q   s  h     m     .
2096	25	And he abandoned me... Romina! 	Y a mí me dejó tirada…   ¡Romina!	Y a m  m  d    t      ¡R     !
2097	25	Let's go to his house and see if he lies to our face.	Vamos a ir su casa a que nos diga todo. A ver si nos vuelve a mentir en la cara.	V     a i  s  c    a q   n   d    t   . A v   s  n   v      a m      e  l  c   .
2098	25	Look, Romina, the time to confront Sergio will come.	Vea, Romina, el momento de confrontar a Sergio va a llegar.	V  , R     , e  m       d  c          a S      v  a l     .
2099	25	Don't worry.	No se preocupe.	N  s  p       .
2100	25	What's important is that we're together and we can get to know each other.	Pero lo importante ahora es que estamos las tres juntas, que nos conozcamos.	P    l  i          a     e  q   e       l   t    j     , q   n   c         .
2101	25	You know what?	¿Sabe qué?	¿S    q  ?
2102	25	I never asked my mom for a sibling.	Yo a mi mamá nunca le pedí un hermano.	Y  a m  m    n     l  p    u  h      .
2103	25	But I always felt like... something was missing.	Pero yo toda la vida sentí como… como si algo me faltara.	P    y  t    l  v    s     c    c    s  a    m  f      .
2104	25	You know what? I completely understand.	¿Sabe qué? La entiendo mucho.	¿S    q  ? L  e        m    .
2105	25	Because I felt the same.	Porque yo sentía lo mismo.	P      y  s      l  m    .
2106	25	It's like...	Era como…	E   c
2107	25	missing someone I didn't even know.	como extrañar algo que no conocía.	c    e        a    q   n  c      .
2108	25	And now I have you in front of me and it's...	Y ahora la tengo enfrente y es…	Y a     l  t     e        y e
2109	25	it's like knowing that's exactly what was missing.	Es como entender qué era ese vacío.	E  c    e        q   e   e   v    .
2110	25	It was that.	Era eso.	E   e  .
2111	25	No remorse. Break into her house and shoot her. That's it.	Sin asco. Se meten a la casa, la despelucan de un balazo y breve.	S   a   . S  m     a l  c   , l  d          d  u  b      y b    .
2112	25	That's it, right? Very easy.	Sí, breve, ¿cierto? Relajado.	S , b    , ¿c     ? R       .
2113	25	What's wrong with you? Don't be stupid.	¿Qué le pasa, Benny? No sea bruto.	¿Q   l  p   , B    ? N  s   b    .
2114	25	Who reported us in front of the journalists?	¿Quién nos denunció frente a los periodistas?	¿Q     n   d        f      a l   p          ?
2115	25	Romina. Romina.	Romina.  Romina.	R     . R     .
2116	25	If something happens to that girl, we'll be the first suspects.	Si a esa hembra le llega a pasar algo, somos los primeros sospechosos.	S  a e   h      l  l     a p     a   , s     l   p        s          .
2117	25	And now there are more cops in the area.	Y ahora hay más tombos campaneando en el barrio.	Y a     h   m   t      c           e  e  b     .
2118	25	All the patrols fucked up a bunch of payments I had.	Se me jodió una vuelta de cobros porque había mucha patrulla.	S  m  j     u   v      d  c      p      h     m     p       .
2119	25	We have to think this through, we can't fuck it up.	Esto hay que pensarlo bien. No podemos cagarla.	E    h   q   p        b   . N  p       c      .
2120	25	This has to look like an accident. You get me?	Esto tiene que parecer un accidente. ¿Me entendieron?	E    t     q   p       u  a        . ¿M  e          ?
2121	25	Another thing, Leo can't find out what we're going to do.	Otra cosa. Leo no puede enterarse de lo que vamos a hacer.	O    c   . L   n  p     e         d  l  q   v     a h    .
2122	25	He's a spineless idiot.	Ese es un tonto ahuevado.	E   e  u  t     a       .
2123	25	I don't want him to snitch. We need to get this girl now.	Y no quiero que se vaya de sapo, y esa hembra se nos escape esta vez.	Y n  q      q   s  v    d  s   , y e   h      s  n   e      e    v  .
2124	25	Laurita, I think it's best we leave. It's getting late.	Laurita, yo creo que lo mejor es que nos vayamos. Se está haciendo tarde.	L      , y  c    q   l  m     e  q   n   v      . S  e    h        t    .
2125	25	Rubencho, I think I'm going to be a little longer.	Rubencho, yo creo que todavía me demoro un poquito.	R       , y  c    q   t       m  d      u  p      .
2126	25	Girl, listen to him.	Pelada, hágale caso al hombre,	P     , h      c    a  h     ,
2127	25	You should leave before it gets dark 	que pues es mejor que ustedes se abran antes de que anochezca	q   p    e  m     q   u       s  a     a     d  q   a
2128	25	because it gets dangerous over here.	porque por acá se pone como peligroso.	p      p   a   s  p    c    p        .
2129	25	Alright, Rubén. Wait for me, I'm coming.	Bueno, Rubén. Espéreme y ya voy.	B    , R    . E        y y  v  .
2130	25	Can you give me you and your mom's phone number?	¿Me puedes dar tu celular y el de tu mamá?	¿M  p      d   t  c       y e  d  t  m   ?
2131	25	What? Is this how you say goodbye to your sister?	Pero ¿qué? ¿Usted se va a despedir así de su hermana?	P    ¿q  ? ¿U     s  v  a d        a   d  s  h      ?
2132	25	No, ma'am, how silly of you!	No, señora. Tan boba, pues.	N , s     . T   b   , p   .
2133	25	Come here.	Venga para acá.	V     p    a  .
2134	25	Oh my God, it can't be.	Es que, Dios mío, no, no puede ser.	E  q  , D    m  , n , n  p     s  .
2135	25	Laurita, right now, you have to think this through,	Laurita, usted tiene en este momento que pensar muy bien,	L      , u     t     e  e    m       q   p      m   b   ,
2136	25	analyze what that lady told you.	analizar lo que esta señora le dijo.	a        l  q   e    s      l  d   .
2137	25	That lady, Rubén, is my real mother.	Esa señora, Rubén, es mi verdadera mamá.	E   s     , R    , e  m  v         m   .
2138	25	I don't understand.	Es que yo no entiendo.	E  q   y  n  e       .
2139	25	I don't get how my dad could be capable of something like this.	Yo no entiendo, de verdad, mi papá cómo fue capaz de hacer algo así.	Y  n  e       , d  v     , m  p    c    f   c     d  h     a    a  .
2140	25	But we don't know for sure if things happened as they said.	Pero no sabemos a ciencia cierta si fue tal como se lo contaron.	P    n  s       a c       c      s  f   t   c    s  l  c       .
2141	25	Rubén, he told my real mother that I was dead!	Rubén, ¡le dijo a mi verdadera mamá que yo estaba muerta!	R    , ¡l  d    a m  v         m    q   y  e      m     !
2142	25	That I was dead, my God! That I was stillborn, Jesus Christ!	¡Por Dios, que estaba muerta! ¡Que había nacido muerta, por Dios!	¡P   D   , q   e      m     ! ¡Q   h     n      m     , p   D   !
2143	25	And now, the person I thought was my mom my whole life,	Y ahora, la que yo pensé toda la vida que era mi mamá,	Y a    , l  q   y  p     t    l  v    q   e   m  m   ,
2144	25	I have no idea if she knows, if she has anything to do with this.	no tengo ni idea, no tengo ni idea si tiene algo que ver con esto, si sabe.	n  t     n  i   , n  t     n  i    s  t     a    q   v   c   e   , s  s   .
2145	25	I didn't grow up with my sister.	No crecí con mi hermana. 	N  c     c   m  h      .
2146	25	I have a twin sister and I didn't grow up with her. Why?	Tenía una hermana gemela y no crecí con mi hermana gemela. ¿Para qué?	T     u   h       g      y n  c     c   m  h       g     . ¿P    q  ?
2147	25	To grow up raised by the nannies?	¿Para que toda la vida hubiera crecido con las nanas?	¿P    q   t    l  v    h       c       c   l   n    ?
2148	25	By the nannies? Was that it, Rubén?	¿Con las niñeras? ¿Para eso, Rubén, para eso?	¿C   l   n      ? ¿P    e  , R    , p    e  ?
2149	25	Calm down, please. You have a lot to process right now.	Ya cálmese, por favor, que usted ahorita tiene mucho que procesar en la cabeza.	Y  c      , p   f    , q   u     a       t     m     q   p        e  l  c     .
2150	25	And no matter what, Mr. Sergio is your dad and Mrs. Virginia raised you.	Y sea como sea, don Sergio es su papá. Doña Virginia la crio.	Y s   c    s  , d   S      e  s  p   . D    V        l  c   .
2151	25	They love you. You have to consider that a little, right?	Los dos la quieren. Tiene que pensar un poquito en eso, ¿no?	L   d   l  q      . T     q   p      u  p       e  e  , ¿n ?
2152	25	What, Mom? Are we not going to talk about it?	Ma, ¿y qué? ¿No vamos a hablar del tema?	M , ¿y q  ? ¿N  v     a h      d   t   ?
2153	25	Talk about what, Romina?	¿Hablar de qué, Romina?	¿H      d  q  , R     ?
2154	25	I told you everything I had to say. That's that.	Yo ya les conté todo lo que les iba a contar. Ya.	Y  y  l   c     t    l  q   l   i   a c     . Y .
2155	25	Well, you can tell me how you feel.	Pues usted me puede contar cómo se siente.	P    u     m  p     c      c    s  s     .
2156	25	How are you with...?	¿Cómo está con…?	¿C    e    c  ?
2157	25	That man's a bastard, Romina!	¡Ese hombre es una basura, Romina!	¡E   h      e  u   b     , R     !
2158	25	A bastard, I'm so stupid. Mom, enough, enough.	Una basura. Yo soy una estúpida.  Ma, ya, ya, ya.	U   b     . Y  s   u   e       . M , y , y , y .
2159	25	Look at me, look at me.	Míreme, míreme, míreme, míreme.	M     , m     , m     , m     .
2160	25	I want you to know that none of this is your fault.	Que le quede claro que usted no tiene la culpa de nada.	Q   l  q     c     q   u     n  t     l  c     d  n   .
2161	25	That jerk's the one to blame.	Toda la culpa la tiene ese desgraciado.	T    l  c     l  t     e   d          .
2162	25	And I promise you that he's gonna pay for what he did to you.	Y yo le prometo que ese tipo va a pagar por todo lo que le hizo.	Y y  l  p       q   e   t    v  a p     p   t    l  q   l  h   .
2163	25	For all he did. I swear.	Por todo. Se lo prometo.	P   t   . S  l  p      .
2164	25	Laurita, as you can see, you have a visitor.	Laurita, como puede ver, tiene visita.	L      , c    p     v  , t     v     .
2165	25	I don't want to see anyone, Rubén.	Y yo no quiero ver a nadie, Rubén.	Y y  n  q      v   a n    , R    .
2166	25	But you have to go in and act like nothing's wrong,	Pero le va a tocar entrar y disimular 	P    l  v  a t     e      y d
2167	25	because if they ask questions and see your face	porque si le hacen preguntas, si le ven esa cara	p      s  l  h     p        , s  l  v   e   c
2168	25	what will you say?	 ¿usted qué les contesta?	¿u     q   l   c       ?
2169	25	We're not gonna tell anyone, Rubén.	Es que no le vamos a decir nada a nadie, Rubén.	E  q   n  l  v     a d     n    a n    , R    .
2170	25	This has to stay between us two,	Esto tiene que quedar entre los dos,	E    t     q   q      e     l   d  ,
2171	25	at least until I talk to my dad.	por lo menos hasta que yo hable con mi papá.	p   l  m     h     q   y  h     c   m  p   .
2172	25	You can count on me, Laurita.	Cuente conmigo, Laurita.	C      c      , L      .
2173	25	Get some rest. Mmhmm.	Descanse.   Mjm.	D       . M  .
2174	25	Listen, I know how to get your dad to respond in court.	Óigame, ya sé cómo lograr que su papá responda ante la ley.	Ó     , y  s  c    l      q   s  p    r        a    l  l  .
2175	25	Get this. If we find the nurse who cared for my mom,	Pelada, pille. Si encontramos a la enfermera que atendió a mi mamá,	P     , p    . S  e           a l  e         q   a       a m  m   ,
2176	25	we'll confirm how things happened and we'll prove everything your dad did.	confirmamos cómo pasaron las cosas, y así probamos todo lo que su papá hizo.	c           c    p       l   c    , y a   p        t    l  q   s  p    h   .
2177	25	And, in doing so, you can also confirm that your dad isn't a saint.	Y de paso, usted también confirma que su papá no es ningún santo.	Y d  p   , u     t       c        q   s  p    n  e  n      s    .
2178	25	But I never said that I believed that.	Pero es que en ningún momento he dicho que yo crea eso.	P    e  q   e  n      m       h  d     q   y  c    e  .
2179	25	Oh, well, make it crystal clear, then.	Ah, bueno, pelada. Entonces que se note,	A , b    , p     . E        q   s  n   ,
2180	25	Otherwise it'll be my mom's word against that kidnapper's.	porque si no va a ser la palabra de mi mamá versus la de ese secuestrador.	p      s  n  v  a s   l  p       d  m  m    v      l  d  e   s           .
2181	25	If he hires a powerful lawyer, we're screwed. You know that.	Y sabe que ese man fijo contrata un abogado bien duro y ahí sí, paila.	Y s    q   e   m   f    c        u  a       b    d    y a   s , p    .
2182	25	don't forget that Santi and Miss Mariana are waiting for you.	recuerde que la están esperando el joven Santi y la señorita Mariana.	r        q   l  e     e         e  j     S     y l  s        M      .
2183	25	Thanks, Luzma. My pleasure.	Gracias, Luzma.   Con gusto.	G      , L    . C   g    .
2184	25	I have to go.	Me toca dejarte.	M  t    d      .
2185	25	Hi, my love. Hi, honey.	Hola, mi amor.  Hola, amor.	H   , m  a   . H   , a   .
2186	25	I was just about to go look for you, but...	Precisamente también me iba a ir a buscarla, pero…	P            t       m  i   a i  a b       , p
2187	25	How's this?	¿Qué le parece eso?	¿Q   l  p      e  ?
2188	25	I don't feel good.	Que no me siento bien.	Q   n  m  s      b   .
2189	25	Oh, you were serious? Yes.	Ah, ¿era verdad eso?  Mjm.	A , ¿e   v      e  ? M  .
2190	25	I thought you made it up to get rid of Mari.	Yo pensé que te lo habías inventado para zafar de Mari.	Y  p     q   t  l  h      i         p    z     d  M   .
2191	25	What's wrong?	¿Qué tenés?	¿Q   t    ?
2192	25	Want to go to sleep? Yes.	¿Vamos a dormir?  Sí.	¿V     a d     ? S .
2193	25	Good night. Good night.	Buenas noches.  Buenas noches.	B      n     . B      n     .
2194	25	Water? Yes.	¿Agüita?  Sí.	¿A     ? S .
2195	25	I'm not complaining or anything like that, but I have to ask.	No es por quejarme ni nada por el estilo, pero yo sí tengo que preguntar.	N  e  p   q        n  n    p   e  e     , p    y  s  t     q   p        .
2196	25	What happened? It was so sudden, so nice.	¿Qué fue lo que pasó, así tan repentino, tan rico?	¿Q   f   l  q   p   , a   t   r        , t   r   ?
2197	25	My God.	Dios mío.	D    m  .
2198	25	What happened to you?	¿A usted qué le ha pasado?	¿A u     q   l  h  p     ?
2199	25	Are you okay?	¿Usted está bien?	¿U     e    b   ?
2200	25	Well, no, I'm not exactly okay.	Pues, bien bien, no.	P   , b    b   , n .
2201	25	Tell me how I can help.	Dígame en qué le puedo ayudar.	D      e  q   l  p     a     .
2202	25	How can we fix it? Let's do it right now.	¿Qué tenemos que solucionar? Lo hacemos de una.	¿Q   t       q   s         ? L  h       d  u  .
2203	25	Listen, mister, calm down.	A ver, autoridad, cálmese,	A v  , a        , c      ,
2204	25	You can't solve everything for me.	que usted no me puede solucionar a mí todo.	q   u     n  m  p     s          a m  t   .
2205	25	I appreciate your concern.	Pero se le agradece la intención.	P    s  l  a        l  i        .
2206	25	I don't like to see you sad or downcast.	Es que a mí no me gusta verla así triste ni cabizbaja ni nada.	E  q   a m  n  m  g     v     a   t      n  c         n  n   .
2207	25	Tell me what's going on.	Dígame qué le pasa.	D      q   l  p   .
2208	25	Why talk about that now? Let's not talk about it.	¿Para qué hablar de eso ahora? No hablemos de eso.	¿P    q   h      d  e   a    ? N  h        d  e  .
2209	25	Look, I already feel better just by being here with you. Hmm?	Mire que yo ya me siento mejor solo con estar aquí con usted. ¿Mmm?	M    q   y  y  m  s      m     s    c   e     a    c   u    . ¿M  ?
2210	25	I feel better too, with you here with me.	Yo también me siento bien aquí con usted.	Y  t       m  s      b    a    c   u    .
2211	25	But that means you're not going to tell me, right?	Pero eso significa que no me va a contar, ¿cierto?	P    e   s         q   n  m  v  a c     , ¿c     ?
2212	25	Trust me.	Confíe en mí.	C      e  m .
2213	25	family problems, that's all.	como problemas familiares. Es eso.	c    p         f         . E  e  .
2214	25	Don't tell me you're having problems with my motherinlaw	No me diga que está teniendo problemas con mi suegrita	N  m  d    q   e    t        p         c   m  s
2215	25	because if that's the case, sorry, but I'll have to take her side.	porque ahí sí me disculpa, pero a mí me toca tomar el lado de ella.	p      a   s  m  d       , p    a m  m  t    t     e  l    d  e   .
2216	25	Oh yeah? You're shameless!	Ah, ¿sí? ¡Descarado!	A , ¿s ? ¡D        !
2217	25	I bet it's very difficult, seeing as her daughter is so much work.	Es que me imagino tremenda papeleta de hija que tiene. Eso debe ser difícil.	E  q   m  i       t        p        d  h    q   t    . E   d    s   d      .
2218	25	Mrs. Yesenia, so cute, all calm and easygoing.	doña Yesenia cómo es de linda, toda tranquilita, toda relajada.	d    Y       c    e  d  l    , t    t          , t    r       .
2219	25	Don't be so sure.	Pero no crea.	P    n  c   .
2220	25	Mrs. Yesenia has a temper too.	Doña Yesenia también tiene su geniecito.	D    Y       t       t     s  g        .
2221	25	Oh, yes, I believe it,	Sí, no, yo me imagino,	S , n , y  m  i      ,
2222	25	because all of this fire had to come from somewhere.	porque todo este voltaje tiene que haber venido de alguna parte.	p      t    e    v       t     q   h     v      d  a      p    .
2223	25	Or maybe it came from your dad's side.	Digo, tal vez también pudo haber venido del lado de tu papá.	D   , t   v   t       p    h     v      d   l    d  t  p   .
2224	25	Because, by the way, you...	Vea, por cierto, usted…	V  , p   c     , u
2225	25	you've never told me anything about your dad.	Usted no me ha contado nada de su papá todavía.	U     n  m  h  c       n    d  s  p    t      .
2226	25	Cristóbal, I only have a mom.	Cristóbal, es que yo solo tengo mamá.	C        , e  q   y  s    t     m   .
2227	25	Come here, come here, come here.	Venga, venga, venga, venga.	V    , v    , v    , v    .
2228	25	Look, sorry...	Venga, dis…	V    , d
2229	25	Do you forgive me?	¿Me disculpa?	¿M  d       ?
2230	25	I didn't know it was a sensitive topic for you.	Yo no sabía que eso era un tema sensible para usted.	Y  n  s     q   e   e   u  t    s        p    u    .
2231	25	I promise I won't mention him again, okay?	Le prometo que no volvemos a hablar de él, ¿sí?	L  p       q   n  v        a h      d  é , ¿s ?
2232	25	It's okay.	Todo bien.	T    b   .
2233	25	It's okay. I'm not mad at you.	No pasa nada. Yo no me estoy poniendo brava con usted.	N  p    n   . Y  n  m  e     p        b     c   u    .
2234	25	Are you really not mad at me? No.	¿De verdad no está brava conmigo?  No.	¿D  v      n  e    b     c      ? N .
2235	25	Besides, I can't get mad at you.	Además, yo no me puedo poner brava con usted.	A     , y  n  m  p     p     b     c   u    .
2236	25	Why not?	¿Por qué no?	¿P   q   n ?
2237	25	Because I love you.	Pues porque yo a usted lo amo.	P    p      y  a u     l  a  .
2238	25	I love you too.	Yo a usted la amo también.	Y  a u     l  a   t      .
2239	25	I've never felt this way about anyone, okay?	Lo que siento por usted nunca lo había sentido por nadie, ¿oyó?	L  q   s      p   u     n     l  h     s       p   n    , ¿o  ?
2240	25	Me neither.	Yo tampoco.	Y  t      .
2241	25	Can I ask you a favor?	¿Yo le puedo pedir un favor?	¿Y  l  p     p     u  f    ?
2242	25	I need you to find the nurse who took care of Yesenia.	Necesito que me ayude a buscar a la enfermera que atendió a Yesenia.	N        q   m  a     a b      a l  e         q   a       a Y      .
2243	25	I'll send you the information I have.	Entonces ya le mando los datos que tengo.	E        y  l  m     l   d     q   t    .
2244	25	Honey, are you okay?	Mi amor, ¿estás bien?	M  a   , ¿e     b   ?
2245	25	Yes! Coming!	¡Sí! ¡Voy!	¡S ! ¡V  !
2246	25	Kind of nauseous.	Como con náuseas.	C    c   n      .
2247	25	Were you talking on the phone? No it was...	¿Hablabas con alguien por teléfono?  No, era…	¿H        c   a       p   t       ? N , e
2248	25	I was watching a video to distract myself.	Es que estaba viendo un video mientras me distraía.	E  q   e      v      u  v     m        m  d       .
2249	25	Did I wake you up? Sorry.	¿Te desperté? Perdón.	¿T  d       ? P     .
2250	25	Sorry, sorry. No, it's okay.	Perdón, perdón.  No pasa nada.	P     , p     . N  p    n   .
2251	25	Want me to look for something for your tummy?	¿Querés que te vaya a buscar algo para la panza?	¿Q      q   t  v    a b      a    p    l  p    ?
2252	25	No, no. A pill?	No, no.  ¿Una pastillita?	N , n . ¿U   p         ?
2253	25	Nothing? No, let's go to sleep.	¿Nada?  No, vamos a dormir.	¿N   ? N , v     a d     .
2254	25	Let's go to sleep. Okay.	Vamos a dormir.  Sí.	V     a d     . S .
2255	25	Come here.	Venga para acá.	V     p    a  .
2256	25	You know what, Romina? I've been thinking that you are so mad,	¿Sabe qué, Romina? Me quedé pensando en que la veo con mucha rabia	¿S    q  , R     ? M  q     p        e  q   l  v   c   m     r
2257	25	and I understand, because, obviously, I feel the same way,	y yo la entiendo, porque, obviamente, yo me siento igual,	y y  l  e       , p     , o         , y  m  s      i    ,
2258	25	but I think that we could use this in a different way.	pero yo creo que esto podríamos usarlo de otra manera.	p    y  c    q   e    p         u      d  o    m     .
2259	25	I don't know, transform it, make it something happy, joyful,	No sé, transformarlo, volverlo una razón de felicidad, de alegría,	N  s , t            , v        u   r     d  f        , d  a      ,
2260	25	because, in the end, it's now the three of us.	porque al final, ahora somos tres, ¿no?	p      a  f    , a     s     t   , ¿n ?
2261	25	Look, I promise that all three of us will decide what to do together.	Vea. Yo le prometo que todas las decisiones que haya que tomar entre las tres, lo vamos a hacer.	V  . Y  l  p       q   t     l   d          q   h    q   t     e     l   t   , l  v     a h    .
2262	25	Promise? I promise.	¿Me lo promete?  Prometido.	¿M  l  p      ? P        .
2263	25	Really? Really.	¿De verdad?  De verdad.	¿D  v     ? D  v     .
2264	25	So change that face, then.	Y cámbieme esa cara, pues.	Y c        e   c   , p   .
2265	25	Like you said, it's us three now,	Que como usted dijo, ya somos tres	Q   c    u     d   , y  s     t
2266	25	and Mom, I promise you, that, from now on,	y yo le prometo, ma, que, de ahora en adelante,	y y  l  p      , m , q  , d  a     e  a       ,
2267	25	only good things will happen for us. I swear.	solo nos van a pasar cosas buenas. Se lo prometo.	s    n   v   a p     c     b     . S  l  p      .
2268	25	God bless you, honey.	Que Dios la bendiga, mi amor.	Q   D    l  b      , m  a   .
2269	25	Listen carefully.	Pónganme cuidado.	P        c      .
2270	25	We're going to follow that girl until we know where she goes and when.	Vamos a seguir a esa cabra hasta saber qué paso da y a qué horas.	V     a s      a e   c     h     s     q   p    d  y a q   h    .
2271	25	And when we know that, you already know what to do.	Y cuando la tengamos clara, ya saben qué hacer.	Y c      l  t        c    , y  s     q   h    .
2272	25	Heads up, Nuche.	En la juega, Nuche.	E  l  j    , N    .
2273	25	We're on alert.	Estamos activos, perro.	E       a      , p    .
2274	25	Damn, we're here.	Jueputa, hasta aquí llegamos.	J      , h     a    l       .
2275	25	She went into the second one, hurry!	Se metió por la segunda. Apurras	S  m     p   l  s      . A
2276	25	She's got it figured out.	La pelada la tiene reclara.	L  p      l  t     r      .
2277	25	She sells empanadas in the morning.	A la mañana vende empanadas en el barrio.	A l  m      v     e         e  e  b     .
2278	25	She changes her afternoon routine according to her clients.	A la tarde cambia la rutina dependiendo de los clientes.	A l  t     c      l  r      d           d  l   c       .
2279	25	It's tough following her because she goes everywhere on that bike.	El seguimiento se vuelve áspero porque la pelada anda a toda mierda en esa cicla.	E  s           s  v      á      p      l  p      a    a t    m      e  e   c    .
2280	25	She goes into little alleys where cars can't even fit.	Se mete en recovecos donde no pasa el carro ni nada.	S  m    e  r         d     n  p    e  c     n  n   .
2281	25	We won't touch that girl until we know everything she does in the hood,	A esa pelada no la vamos a tocar hasta no saber todo lo que haga en el barrio,	A e   p      n  l  v     a t     h     n  s     t    l  q   h    e  e  b     ,
2282	25	because we're doing the hit in our territory.	porque este golpe se lo vamos a dar acá, en nuestro territorio.	p      e    g     s  l  v     a d   a  , e  n       t         .
2283	25	Okay? Yes.	¿Va?   Muy bien.	¿V ? M   b   .
2284	25	Romi. Romi, wait. Romi, come here!	Romi. Romi, espere, espere. Romi, ¡venga!	R   . R   , e     , e     . R   , ¡v    !
2285	25	Come here. I was telling the truth. I'll leave all this shit behind, okay?	Venga. Vea. Lo que le dije es verdad. Me voy a largar de toda esta mierda, ¿oyó?	V    . V  . L  q   l  d    e  v     . M  v   a l      d  t    e    m     , ¿o  ?
2286	25	Leo, I'm not telling you anything.	Leo, yo no le estoy diciendo nada.	L  , y  n  l  e     d        n   .
2287	25	Romi, I know you. Besides, when I make a promise, I keep it.	Romi, yo la conozco. Además, lo que yo prometo, yo lo cumplo.	R   , y  l  c      . A     , l  q   y  p      , y  l  c     .
2288	25	honestly, I couldn't care less about what you do with your life.	lo que usted haga con su vida, a lo bien, me tiene sin cuidado.	l  q   u     h    c   s  v   , a l  b   , m  t     s   c      .
2289	25	But I'll tell you one thing, kid. Sometimes, blood is thicker than water.	Pero eso sí le digo una cosa, pelado. La sangre jala más de lo que uno cree.	P    e   s  l  d    u   c   , p     . L  s      j    m   d  l  q   u   c   .
2290	25	Come on, Romi, let's talk.	Venga, Romi. Hablemos.	V    , R   . H       .
2291	25	Come on. Be careful, kid.	Venga.   Ojo ahí, pelado.	V    . O   a  , p     .
1872	16	It's all too far.	Tout va trop loin.	T    v  t    l   .
2292	25	No, Laurita, it's not good news.	No, Laurita, las noticias no son nada buenas.	N , L      , l   n        n  s   n    b     .
2293	25	No one in this town knows anyone named Sonia Mendigaña.	En este pueblo nadie conoce a ninguna Sonia Mendigaña.	E  e    p      n     c      a n       S     M        .
2294	25	There is no record of her working at the hospital.	En el hospital no figura ningún registro de que ella haya trabajado ahí.	E  e  h        n  f      n      r        d  q   e    h    t         a  .
2295	25	Well, hardly, Laurita, because it's been almost 20 years.	Pues ni tanto, Laurita, porque es que ya van a ser 20 años.	P    n  t    , L      , p      e  q   y  v   a s   20 a   .
2296	25	It's possible she was only hired to assist in the birth, you know.	Es probable que a ella la hayan contratado únicamente para atender el parto. Usted me entiende.	E  p        q   a e    l  h     c          ú          p    a       e  p    . U     m  e       .
2297	25	She's probably not even from here.	De pronto, ella ni siquiera es de por acá.	D  p     , e    n  s        e  d  p   a  .
2298	25	Well, don't worry, Rubén.	Bueno, pues nada que hacer, Rubén.	B    , p    n    q   h    , R    .
2299	25	Just come back because I don't want my dad to find out	Más bien, devuélvase que no quiero que mi papá se entere	M   b   , d          q   n  q      q   m  p    s  e
2300	25	that you left and tell you off because of me.	que usted anda por fuera y lo regañe por mi culpa.	q   u     a    p   f     y l  r      p   m  c    .
2301	25	We'll talk. Thanks, bye.	Hablamos. Chao, gracias.	H       . C   , g      .
2302	25	Good morning, sweetie. Hello.	Buen día, corazón.  Hola.	B    d  , c      . H   .
2303	25	How are you? Good.	¿Cómo estás?  Bien.	¿C    e    ? B   .
2304	25	I love how that sweater looks on you.	Me encanta cómo te queda ese suéter.	M  e       c    t  q     e   s     .
2305	25	And the pants.	Y ese pantalón.	Y e   p       .
2306	25	Good morning, excuse me. Good morning.	Muy buenas. Con permiso.  Buen día.	M   b     . C   p      . B    d  .
2307	25	Hello, Luzma. How are you, ma'am?	Hola, Luzma.  ¿Cómo está, señorita?	H   , L    . ¿C    e   , s       ?
2308	25	I like your boots too. I think it's your favorite look.	Esas botas también me gustan. Creo que es tu pinta favorita.	E    b     t       m  g     . C    q   e  t  p     f       .
2309	25	Excuse me, enjoy! Thanks.	Permiso. Buen provecho.  Gracias.	P      . B    p       . G      .
2310	25	Yes, you're prettier than ever.	Sí, estás más linda que nunca.	S , e     m   l     q   n    .
2311	25	I'm really in love with you.	Estoy como muy enamorado de vos.	E     c    m   e         d  v  .
2312	25	You're the prettiest girl I've ever seen.	Sos la chica más linda que vi en mi vida.	S   l  c     m   l     q   v  e  m  v   .
2313	25	I'm being a bit intense, right? Yes. No, honey.	Estoy como un poco pesado, ¿no? Sí.   No, amor.	E     c    u  p    p     , ¿n ? S . N , a   .
2314	25	No, that's not it. Honey, I'm tired. Yes, I feel...	No. Eso no es. Amor, estoy cansada.  Sí, me siento…	N . E   n  e . A   , e     c      . S , m  s
2315	25	I understand.	Te entiendo, te entiendo.	T  e       , t  e       .
2316	25	I feel like I'm suffocating you a little bit	Siento que te estoy asfixiando un poquito	S      q   t  e     a          u  p
2317	25	these days, and I think I should leave.	estos días, y pues sí, mejor me voy.	e     d   , y p    s , m     m  v  .
2318	25	Don't be like that, Santi.	No te pongas así, Santi.	N  t  p      a  , S    .
2319	25	I think you need time to be alone	Siento que necesitás un tiempo para vos sola	S      q   n         u  t      p    v   s
2320	25	and I'm feeling the same way, because it's not good to feel like this.	y como que lo estoy sintiendo yo, porque no es tan cómodo sentir esto.	y c    q   l  e     s         y , p      n  e  t   c      s      e   .
2321	25	Besides, I have a meeting in Santa Marta.	Además, tengo una reunión en Santa Marta.	A     , t     u   r       e  S     M    .
2322	25	I wanted you to come to the beach for a couple of days,	Te iba a decir que vengas conmigo a la playa unos días,	T  i   a d     q   v      c       a l  p     u    d   ,
2081	25	For Christmas... I'd always ask my parents for a sibling.	De Navidad, yo siempre le pedía a mis papás un hermano de regalo.	D  N      , y  s       l  p     a m   p     u  h       d  r     .
2082	25	Listen, I know that...	A ver, yo sé que…	A v  , y  s  q
2083	25	I am a very privileged woman,	que yo soy una mujer muy privilegiada,	q   y  s   u   m     m   p           ,
2084	25	but I've always felt so alone.	pero siempre me he sentido tan sola.	p    s       m  h  s       t   s   .
1636	16	Lenny, I didn't know you had kids.	Je savais pas que t'avais des gosses.	J  s      p   q   t'      d   g     .
1637	16	I hired them to look like I'm a family man.	J'ai engagé de faux enfants.	J'   e      d  f    e      .
1638	16	How you doing, Lenny Jr.?	Ça va, Lenny Jr ?	Ç  v , L     J  ?
1639	16	Never better, Lenny Sr.	Mieux que jamais, Lenny Sr !	M     q   j     , L     S  !
1640	16	Hey, I just got cast as Krusty's kid at a custody hearing.	Je vais jouer le fils de Krusty dans une audience pour sa garde.	J  v    j     l  f    d  K      d    u   a        p    s  g    .
1641	16	Possible recurring. Later, loser!	Ce sera peutêtre récurent. A plus tard, le nase !	C  s    p        r       . A p    t   , l  n    !
1642	16	Welcome, iso‐tots.	Bienvenue, les atmômes.	B        , l   a      .
1643	16	Are you having fun?	Vous vous amusez ?	V    v    a      ?
1644	16	Now, as your parents leave you alone with me, let's begin the festivities. 	Puisque vos parents s'en vont, commençons les festivités !	P       v   p       s'   v   , c          l   f          !
1645	16	Yes, there they go. Bye‐bye.	Ils sont partis ! Au revoir !	I   s    p      ! A  r      !
1646	16	Last mommy out. Excellent.	Plus une maman ! Excellent !	P    u   m     ! E         !
1647	16	I now declare the start of Put Your Kids to Work Day.	Je déclare ouverte la journée "Mettez vos enfants au travail".	J  d       o       l  j       "       v   e       a  t      ".
1648	16	This plant has over 17,000 contaminated crevices	Cette centrale a plus de 17 000 fissures contaminées	C     c        a p    d  17 000 f        c
1649	16	that only your tiny hands can reach.	que seules vos mains peuvent atteindre.	q   s      v   m     p       a        .
1650	16	Get to work, slackers.	Au travail, fainéants !	A  t      , f         !
1651	16	At least this ride doesn't have a creepy song.	Au moins, y a pas de chanson craignos !	A  m    , y a p   d  c       c        !
1652	16	♪ You'll work for me, or you'll get the lash ♪	Vous travaillerez pour moi ou vous aurez droit au fouet	V    t            p    m   o  v    a     d     a  f
1653	16	♪ You won't get dental, health or cash. ♪	Vous n'aurez ni soins dentaires, ni mutuelle ni paye	V    n'      n  s     d        , n  m        n  p
1654	16	Even Mr. Burns can't get away with this.	Même M. Burns ne peut pas s'en tirer comme ça !	M    M. B     n  p    p   s'   t     c     ç  !
1655	16	Oh, Monty, you've still got it.	Monty, tu as toujours le don	M    , t  a  t        l  d
1656	16	That was like taking eight hours of work from a baby.	pour prendre 8 h de travail à un bébé !	p    p       8 h d  t       à u  b    !
1657	16	Mr. Burns, according to the child labor laws of the United States...	M. Burns, selon les lois sur le travail des enfants des EtatsUnis...	M. B    , s     l   l    s   l  t       d   e       d   E        ...
1658	16	Aah! Accountability?	La responsabilité ?	L  r              ?
1659	16	In this game of cat and mouse,	Dans ce jeu du chat et de la souris,	D    c  j   d  c    e  d  l  s     ,
1660	16	I'm afraid Mr. Mouse is far smarter than...	je crains que M. Souris ne soit plus malin que...	j  c      q   M. S      n  s    p    m     q  ...
1661	16	I know you're in here,	Je sais que vous êtes là.	J  s    q   v    ê    l .
1662	16	and nothing will stop me.	Rien ne m'arrêtera.	R    n  m'        .
1663	16	Wait, this is a men's room.	Mais je suis chez les hommes !	M    j  s    c    l   h      !
1664	16	Is that a tuna sandwich on the sink?	C'est un sandwich au thon sur le lavabo ?	C'    u  s        a  t    s   l  l      ?
1665	16	Ugh! Gross, gross, gross!	C'est dégueu, dégueu, dégueu !	C'    d     , d     , d      !
1666	16	Oh, employee cave drawings.	Des peintures rupestres d'employés ! 	D   p         r         d'         !
1667	16	Let's see what's on their feeble minds.	Voyons ce qu'ils balbutient.	V      c  q '    b         .
1668	16	There once was a lady from China... And North Carolina.	Il était un fois une dame de Chine... qui finit en Caroline.	I  é     u  f    u   d    d  C    ... q   f     e  C       .
1669	16	I assume what's in between is unimportant.	Le reste est sans importance.	L  r     e   s    i         .
1670	16	Someone drew a big, crying cucumber. That's nice.	Quelqu'un a dessiné un concombre en larmes, joli !	Q     '   a d       u  c         e  l     , j    !
1671	16	Ooh! Something about me. I'll need my cheaters for this.	Quelque chose sur moi. Je mets mes bésicles.	Q       c     s   m  . J  m    m   b       .
1672	16	Oh! They hate me.	Ils me détestent!	I   m  d        !
1673	16	Well, maybe things are better in the ladies' room.	Je vais me consoler chez les dames.	J  v    m  c        c    l   d    .
1674	16	Effigies can be burned?	On brûle des effigies ?	O  b     d   e        ?
1675	16	You should have seen those hateful graffitos, Smithers.	Vous auriez dû voir ces graffitis haineux, Smithers !	V    a      d  v    c   g         h      , S        !
1676	16	And the drawing of me was so off‐model.	Et même pas ressemblants !	E  m    p   r            !
1677	16	I wouldn't worry, sir. Our workers are pretty well‐pacified.	Ne vous inquiétez pas, nos employés sont pacifiés.	N  v    i         p  , n   e        s    p       .
1678	16	Intimidation.  Alleged intimidation.	Intimidation.  Intimidation présumée.	I           . I            p       .
1679	16	Beatings.  Alleged beatings. Mm.	Violences présumées.	V         p        .
1680	16	Ah, yes. We've had some alleged good times, haven't we, Smithers?	Oui, on a eu de sacrés bons moments présumés, pas vrai ?	O  , o  a e  d  s      b    m       p       , p   v    ?
1681	16	But there is an undercurrent of contempt for me.	Mais il y a un courant de mépris envers moi.	M    i  y a u  c       d  m      e      m  .
1682	16	No, there isn't.	Non, pas du tout.	N  , p   d  t   .
1683	16	You said Burns is worse than Hitler.	Tu dis que Burns est pire qu'Hitler ?	T  d   q   B     e   p    q '       ?
1684	16	Well, not worse at his job than Hitler, but a worse person.	Il est pas pire dans son boulot, mais en tant que personne.	I  e   p   p    d    s   b     , m    e  t    q   p       .
1685	16	Huh. Was that the work whistle? Eh, who cares.	C'était pour la reprise ?  On s'en fout.	C'      p    l  r       ? O  s'   f   .
1686	16	Everywhere, I'm surrounded by malcontents, termagants and Lennys.	Je suis entouré de mécontents, de harpies et de Lenny !	J  s    e       d  m         , d  h       e  d  L     !
1687	16	Well, we could show the workers some actual respect,	On pourrait respecter les employés, 	O  p        r         l   e       ,
1688	16	uh, considering how many have died.	comptetenu du nombre de morts.	c          d  n      d  m    .
1689	16	Or I could go undercover and infiltrate the workers.	Ou je pourrais me déguiser pour infiltrer les employés.	O  j  p        m  d        p    i         l   e       .
1690	16	I'm beginning to suspect these monitors have been tampered with.	Je soupçonne qu'on a truqué ces moniteurs.	J  s         q '   a t      c   m        .
1691	16	I've assembled a world‐class team to create your undercover disguise.	J'ai réuni une équipe d'experts pour créer votre déguisement.	J'   r     u   é      d'        p    c     v     d          .
1692	16	The face mask specialist from the Mission: Impossible movies.	Le spécialiste des masques de Mission : Impossible.	L  s           d   m       d  M       : I         .
1693	16	I made Ving Rhames look like Kristin Chenoweth.	J'ai fait ressembler Ving Rhames à Kristin Chenoweth.	J'   f    r          V    R      à K       C        .
1694	16	I don't know any of those words, but I'm impressed.	Sans les connaître, je suis impressionné.	S    l   c        , j  s    i           .
1695	16	We'll also provide you with a dynamic new body.	Vous aurez aussi un nouveau corps.	V    a     a     u  n       c    .
1696	16	Ooh. Does everything work?	Estce que tout fonctionne ?	E     q   t    f          ?
1697	16	Everything that works for you now.	Si ça fonctionne chez vous.	S  ç  f          c    v   .
1698	16	Damn it! That's only two things.	Bon sang ! Juste deux choses !	B   s    ! J     d    c      !
1699	16	And we top off the disguise with a voice modulation chip.	Et pour finir, une puce de modulation vocale.	E  p    f    , u   p    d  m          v     .
1700	16	Mr. Burns, I'm gonna make you sound...  hella different.	M. Burns, je vais vous donner une voix très différente !	M. B    , j  v    v    d      u   v    t    d          !
1701	16	Let's get to work.	Mettonsnous au travail.	M           a  t      .
1702	16	Oh, my God. It's extraordinary.	Seigneur ! C'est extraordinaire.	S        ! C'    e             .
1703	16	You now have the body and face of a man half your age.	Vous avez le corps et le visage d'un homme de la moitié de votre âge.	V    a    l  c     e  l  v      d'   h     d  l  m      d  v     â  .
1704	16	Now, enough gallimaufry. I want to see my reflection.	Assez de flatteries, je veux voir mon reflet.	A     d  f         , j  v    v    m   r     .
1705	16	Someone bring me a mountain stream.	Qu'on m'apporte un lac de montagne !	Q '   m'        u  l   d  m        !
1706	16	Say goodbye to Montgomery Burns.	Dites adieu à Montgomery Burns	D     a     à M          B
1707	16	Say hello to Fred Kranepool from turbine maintenance.	et bonjour à Fred Kranepool, de la maintenance de la turbine.	e  b       à F    K        , d  l  m           d  l  t      .
1708	16	Hello, Joe. What do you know?	Bonjour, Joe. Tu sais quoi ?	B      , J  . T  s    q    ?
1709	16	Just got back from the picture show. Beat it, weirdo.	Je suis allé au cinéma parlant.  Dégage !	J  s    a    a  c      p      . D      !
1710	16	You're fired.	Tu es viré !	T  e  v    !
1711	16	You can't fire me.	Tu peux pas me virer !	T  p    p   m  v     !
1712	16	Hey, newbie. Over here.	Le nouveau, par ici !	L  n      , p   i   !
1713	16	You seem like a happy lot here at the nuclear plant,	Vous avez l'air bien, ici, à la centrale nucléaire,	V    a    l'    b   , i  , à l  c        n        ,
1714	16	suckling from the teat of the great C. Montgomery Burns.	tétant la mamelle du grand C. Montgomery Burns.	t      l  m       d  g     C. M          B    .
1715	16	You said "teat."	T'as dit "mamelle".	T'   d   "       ".
1716	16	Yes, I did, didn't I?	Oui, je l'ai dit, pas vrai ?	O  , j  l'   d  , p   v    ?
1717	16	Now that we're chums, what's on your mind?	Dites, les copains, quoi de neuf ?	D    , l   c      , q    d  n    ?
1718	16	Any complaints? Insubordinate remarks?	Des plaintes ? Des remarques rebelles ?	D   p        ? D   r         r        ?
1719	16	Actually, now that you mention it...	Maintenant que t'en parles... 	M          q   t'   p     ...
1720	16	Better get back to work.	Faut retourner bosser !	F    r         b      !
1721	16	Ah, so soon?	Déjà ?	D    ?
1722	16	Sorry, but Mr. Burns has a special way of telling you your lunchtime's over.	Désolé, Burns a une façon à lui de sonner la fin du déjeuner.	D     , B     a u   f     à l   d  s      l  f   d  d       .
1723	16	I heard the craziest thing. Some nuclear plants don't have hounds chasing you.	J'ai entendu parler d'un truc dingue : des centrales sans molosses !	J'   e       p      d'   t    d      : d   c         s    m        !
1724	16	Eh, different world.	Un autre monde.	U  a     m    .
1725	16	Huh. I guess when you're on the other side of it, releasing hounds can be cruel?	C'est vrai que de ce point de vue, lâcher les chiens est assez cruel.	C'    v    q   d  c  p     d  v  , l      l   c      e   a     c    .
1726	16	Oh, yeah. Super cruel.	Oui, super cruel.	O  , s     c    .
1727	16	I had to get rabies shots in my stomach for a month.	Des injections antirabiques pendant un mois !	D   i          a            p       u  m    !
2418	25	Let's put on music.	Pongamos música.	P        m     .
1728	16	Skipped the last couple.	J'ai zappé les deux dernières.	J'   z     l   d    d        .
1729	16	Ugh, you poor guys. Here, please.	Mes pauvres gars ! Tenez, prenez.	M   p       g    ! T    , p     .
1730	16	Here's a Buffalo nickel for each of you.	Voilà un sou pour chacun de vous.	V     u  s   p    c      d  v   .
1731	16	Hey, thanks a lot, man.	Merci beaucoup, mec.	M     b       , m  .
1732	16	Why don't you join us at Moe's tonight?	Tu viens chez Moe ce soir ?	T  v     c    M   c  s    ?
1733	16	Yeah, it's that bar that was featured on I'll Drink What Phil's Drinking with Phil Rosenthal.	C'est ce bar qui est passé dans Je boirai comme Phil avec Phil Rosenthal.	C'    c  b   q   e   p     d    J  b      c     P    a    P    R        .
1734	16	Mmm. What animal is this egg from?	De quel animal vient cet œuf ?	D  q    a      v     c   œ   ?
1735	16	Uh, I want to say horse?	Je dirais un cheval.	J  d      u  c     .
1736	16	Oh. Could I be sick in this?	Je peux vomir làdedans ?	J  p    v     l        ?
1737	16	Somebody take Phil to the hospital.	Qu'on emmène Phil à l'hôpital.	Q '   e      P    à l'       .
1738	16	Fred, buddy, you coming?	Fred, mon pote, tu viens ?	F   , m   p   , t  v     ?
1739	16	I'm in. Just need to signal Smithers.	Je suis infiltré, je le signale à Smithers.	J  s    i       , j  l  s       à S       .
1740	16	I hate that signal.	Je déteste ce signal.	J  d       c  s     .
1741	16	Moe, this is our new pal Fred.	Moe, c'est notre nouveau copain, Fred.	M  , c'    n     n       c     , F   .
1742	16	Apparently, we've been working with him for years. We never noticed.	On bosse avec lui depuis des années sans s'en rendre compte.	O  b     a    l   d      d   a      s    s'   r      c     .
1743	16	Set him up with a beer. On me.	Sers lui une bière. C'est pour moi.	S    l   u   b    . C'    p    m  .
1744	16	Thank you, friend.	Merci, mes amis.	M    , m   a   .
1745	16	I like the way you said that, like it was a foreign concept or something.	J'adore ta façon de le dire comme si c'était un concept étranger.	J'      t  f     d  l  d    c     s  c'      u  c       é       .
1746	16	but you annoying fleas aren't half bad.	mais vous êtes chouettes, les moucherons.	m    v    ê    c        , l   m         .
1747	16	All we're looking for is a little friendship and respect.	Tout ce qu'on veut, c'est un peu d'amitié et de respect.	T    c  q '   v   , c'    u  p   d'       e  d  r      .
1748	16	All right. To friendship and respect.	D'accord. A l'amitié et au respect.	D'      . A l'       e  a  r      .
1749	16	And also evil. I mean, I mean, football.	Et aussi au mal ! Je veux dire, au football.	E  a     a  m   ! J  v    d   , a  f       .
1750	16	Ah, whoa, whoa. Sorry, Barn. Your seat's taken.	Désolé, Barney. Ta place est prise.	D     , B     . T  p     e   p    .
1751	16	Oh, you show up late for your nightly bender just once...	T'arrives en retard pour ta cuite du soir une seule fois...	T'        e  r      p    t  c     d  s    u   s     f   ...
1752	16	Uh, don't you worry. I just instituted drive‐through service.	T'inquiète pas, j'ai mis en place le service au volant.	T'         p  , j'   m   e  p     l  s       a  v     .
1753	16	Drive safely.	Conduis prudemment.	C       p         .
1754	16	♪ Why can't we be friends? ♪	Pourquoi on ne peut pas être amis ?	P        o  n  p    p   ê    a    ?
1755	16	♪ I see you 'round for a long, long time ♪	Je te vois depuis longtemps, très longtemps	J  t  v    d      l        , t    l
1756	16	♪ I remember you ♪	Je me souviens de toi	J  m  s        d  t
1757	16	♪ When you drink my wine ♪	Quand tu buvais mon vin	Q     t  b      m   v
1758	16	♪ Why can't we be friends? ♪	Pourquoi on ne peut pas être amis ?	P        o  n  p    p   ê    a    ?
1759	16	Thank you. Thank you very much.	Merci. Merci beaucoup.	M    . M     b       .
1760	16	Okay, um, your turn to sing, Fred.	Allez, à toi de chanter, Fred.	A    , à t   d  c      , F   .
1761	16	I've got a toe‐tapper everyone can sing along with,	Très bien. J'ai une rengaine que tout le monde connaît.	T    b   . J'   u   r        q   t    l  m     c      .
1762	16	The Spaniard That Blighted My Life.	L'Espagnol qui a gâché ma vie.	L'         q   a g     m  v  .
1763	16	The Spaniard That Blighted My Life, BLH1493. Go.	L'Espagnol qui a gâché ma vie. BLH1493. C'est parti !	L'         q   a g     m  v  . B  1493. C'    p     !
1764	16	♪ List to me, while I tell you ♪	Ecoutemoi, faut que je te parle	E        , f    q   j  t  p
1765	16	♪ Of the Spaniard that blighted my life... ♪	De l'Espagnol qui a gâché ma vie... Avec moi !	D  l'         q   a g     m  v  ... A    m   !
1766	16	♪ List to me, while I tell you ♪	Ecoutemoi, faut que je te parle	E        , f    q   j  t  p
1767	16	♪ Of the man that pinched my future wife. ♪	De l'homme qui a chipé ma petite amie	D  l'      q   a c     m  p      a
1768	16	Those idiots like me for me, Fred Kranepool.	Ces idiots m'aiment pour moi, Fred Kranepool.	C   i      m'       p    m  , F    K        .
1769	16	Uh, sir, I'm worried. The suit just detected a heartbeat.	Je suis inquiet, votre cœur vient de battre.	J  s    i      , v     c    v     d  b     .
1770	16	I'm turning you off.	Je vous éteins.	J  v    é     .
1771	16	Other button, sir.  Shut up.	L'autre bouton, monsieur.  La ferme !	L'      b     , m       . L  f     !
1772	16	Where is he?	Où estil ?	O  e     ?
1773	16	I'm supposed to read him his bedtime story.	C'est l'heure de son histoire.	C'    l'      d  s   h       .
1774	16	Smithers, what are you still doing up?	Smithers, encore debout ?	S       , e      d      ?
1775	16	I was worried about you, sir.	J'étais inquiet pour vous, monsieur.	J'      i       p    v   , m       .
1776	16	I just had the greatest night of my life.	C'était la plus belle soirée de ma vie.	C'      l  p    b     s      d  m  v  .
1777	16	With my friends.  What?	Avec mes amis. Quoi ?	A    m   a   . Q    ?
1919	16	It's okay, Mr. Burns. Fred's gone.	Tout va bien, M. Burns. Fred est parti.	T    v  b   , M. B    . F    e   p    .
1778	16	Oh, you should've seen it, Smithers. They enjoyed my company.	Vous auriez dû voir ça. Ils appréciaient ma compagnie !	V    a      d  v    ç . I   a            m  c         !
1779	16	I've had "frenemies," but they were all French enemies.	J'ai eu des presqu'amis, donc des ennemis français.	J'   e  d   p     '    , d    d   e       f       .
1780	16	Never a friend.	Mais jamais un ami.	M    j      u  a  .
1781	16	I think of you as more than a friend, sir.	Je vous vois comme plus qu’un ami.	J  v    v    c     p    q ’   a  .
1782	16	What did I tell you about thinking?	On vous a demandé votre avis ?	O  v    a d       v     a    ?
1783	16	Well, did you find anything out? Any scuttlebutt from the union?	Qu'avezvous découvert ? Un risque d'union syndicale ?	Q '         d         ? U  r      d'      s         ?
1784	16	The only union that concerns me now is the union of men.	La seule union qui me préoccupe est celle des hommes !	L  s     u     q   m  p         e   c     d   h      !
1785	16	What would you know about that?	Ce n'est pas pour vous.	C  n'    p   p    v   .
1786	16	Where have you been? You missed dinner.	Où étaistu ? Tu as raté le dîner !	O  é       ? T  a  r    l  d     !
1787	16	There's this really cool new guy at the plant.	Il y a ce nouveau gars vraiment cool à la centrale.	I  y a c  n       g    v        c    à l  c       .
1788	16	You know what's cool is spending time with your family.	Ce qui est cool, c'est de passer du temps en famille.	C  q   e   c   , c'    d  p      d  t     e  f      .
1789	16	That's not cool.  Yeah, Mom, it really isn't.	C'est pas cool.  Oui, maman, vraiment pas.	C'    p   c   . O  , m    , v        p  .
1790	16	I agree with Mom on everything but this.	Je suis d'accord avec maman sur tout, sauf ça.	J  s    d'       a    m     s   t   , s    ç .
1791	16	I'm sorry. Definitely not cool.	Pardon, mais c'est pas cool.	P     , m    c'    p   c   .
1792	16	I just don't trust new people in this town.	Mais je me méfie des nouveaux venus en ville.	M    j  m  m     d   n        v     e  v    .
1793	16	Like Lady Gaga? She came, she inspired Lisa	Comme Lady Gaga. Elle est venue, a inspiré Lisa	C     L    G   . E    e   v    , a i       L
1794	16	and we never heard from her again.	et on a plus jamais eu de nouvelles.	e  o  a p    j      e  d  n        .
1795	16	Who needs friends like that?	Qui veut des amis pareils ?	Q   v    d   a    p       ?
1796	16	So, fellows, what's on our social agenda tonight?	Alors, les gars, qu'estce qu'on a à notre agenda ce soir ?	A    , l   g   , q '      q '   a à n     a      c  s    ?
1797	16	More galivanting, I hope?	On repart en vadrouille, j'espère !	O  r      e  v         , j'       !
1798	16	Well, we really should do a little work.	Faudrait vraiment qu'on bosse un peu.	F        v        q '   b     u  p  .
1799	16	Yeah. I have a whole inbox of unsplit atoms I haven't gotten to yet.	J'ai une livraison d'atomes en attente de fission.	J'   u   l         d'       e  a       d  f      .
1800	16	Fred, are these men bothering you?	Fred, ils vous ennuient ?	F   , i   v    e        ?
1801	16	Oh, back off, Smithers. 	Lâchezmoi, Smithers.	L        , S       .
1802	16	I'll box your ears next time you speak to me with such insolence.	Je vous allonge si vous me parlez encore avec insolence !	J  v    a       s  v    m  p      e      a    i         !
1803	16	You totally pwned him.	Tu l'as carrément rembarré !	T  l'   c         r        !
1804	16	Hmm. I suppose I did pwn him. I did.	Oui, je crois que je l'ai rembarré. En effet !	O  , j  c     q   j  l'   r       . E  e     !
1805	16	Ugh, that was quite the kerfuffle. I better go take a three‐hour nap.	Quelle histoire ! Je vais faire une sieste de 3 h.	Q      h        ! J  v    f     u   s      d  3 h.
1806	16	No, no, wait. While Smithers is off drowning his sorrows in a pamplemousse Perrier, 	Attends ! Pendant que Smithers pleure dans son Perrier pamplemousse,	A       ! P       q   S        p      d    s   P       p           ,
1807	16	Burns is unprotected.	Burns est vulnérable.	B     e   v         .
1808	16	This is the perfect time for you to represent us and hit the old skinflint up	Va nous représenter et obtiens du vieux forban	V  n    r           e  o       d  v     f
1809	16	for a decent benefits package.	des avantages décents !	d   a         d       !
1810	16	Me, talk to Burns?	Moi, parler à Burns ?	M  , p      à B     ?
1811	16	Oh, I wouldn't. I‐I couldn't.	Jamais ! Je ne peux pas !	J      ! J  n  p    p   !
1812	16	He's got the sharpest mind in all 46 states.	Il a l'esprit le plus vif des 46 Etats.	I  a l'       l  p    v   d   46 E    .
1813	16	Hey, come on, please. For your friends.	Allez, s'il te plaît, pour tes amis !	A    , s'   t  p    , p    t   a    !
1814	16	I won't let you down. You down, you down, you down.	Je ne vous laisserai pas tomber. Tomber, tomber, tomber...	J  n  v    l         p   t     . T     , t     , t     ...
1815	16	I'll help you, friends.	Je vais vous aider, mes amis.	J  v    v    a    , m   a   .
1816	16	Don't you understand, Burns?	Vous ne comprenez pas, Burns ?	V    n  c         p  , B     ?
1817	16	Without the workers, this plant is nothing.	Sans employés, pas de centrale !	S    e       , p   d  c        !
1818	16	If you give them respect, it comes back to you a hundredfold.	Respectezles, vous y serez gagnant au centuple.	R           , v    y s     g       a  c       .
1819	16	Respect the workers?	Respecter les employés ?	R         l   e        ?
1820	16	What next? Put batteries in the smoke detectors?	Et quoi encore ? Des détecteurs de fumée alimentés ?	E  q    e      ? D   d          d  f     a         ?
1821	16	Have you no heart?	N'avezvous pas de cœur ?	N'         p   d  c    ?
1822	16	I certainly do.	Si j'en ai un !	S  j'   a  u  !
1823	16	I'm not flooding this room with mustard gas right now.	Sinon j'enverrais le gaz moutarde.	S     j'          l  g   m       .
1824	16	I'll give you a chance to tell your buddies that you failed.	Vous pouvez aller dire à vos amis que vous avez échoué.	V    p      a     d    à v   a    q   v    a    é     .
2085	25	What do you mean? And your parents?	¿Cómo así? ¿Y sus papás?	¿C    a  ? ¿Y s   p    ?
1825	16	But then they might not like me anymore.	Mais alors... ils pourraient ne plus m'aimer.	M    a    ... i   p          n  p    m'     .
1826	16	You're right. Friendship is something worth treasuring.	Vous avez raison, l'amitié mérite d'être chérie.	V    a    r     , l'       m      d'     c     .
1827	16	Boy, he's really raking Burns over the coals.	Dites donc, il a coincé Burns dans les cordes.	D     d   , i  a c      B     d    l   c     .
1828	16	Yeah, I like how they're not interrupting each other. So polite. 	Et ils ne s'interrompent pas. Super poli !	E  i   n  s'             p  . S     p    !
1829	16	Yes, spirits, yes. I'll give them everything they want.	Très bien. Je leur donnerai tout ce qu'ils veulent.	T    b   . J  l    d        t    c  q '    v      .
1830	16	He said...  We heard everything.	Il a dit...  On a entendu !	I  a d  ... O  a e       !
1831	16	Clearly it was two people talking.	Deux êtres humains qui parlaient.	D    ê     h       q   p        .
1832	16	We got to spread the good news.	Faut annoncer la nouvelle !	F    a        l  n        !
1833	16	We love you, big guy.	On t'aime, mon grand.	O  t'    , m   g    .
1834	16	Mr. Burns, what have you done? There is no Mr. Burns.	M. Burns, qu'avezvous fait ?  Il n'y a plus de M. Burns.	M. B    , q '         f    ? I  n'  a p    d  M. B    .
1835	16	Only Fred.	Il n'y a plus que Fred !	I  n'  a p    q   F    !
1836	16	What are you saying?	Que ditesvous ?	Q   d         ?
1837	16	Montgomery Burns died when I put on this suit.	Montgomery Burns est mort quand j'ai mis ce costume.	M          B     e   m    q     j'   m   c  c      .
1838	16	And six other times this week.	Et 6 autres fois cette semaine.	E  6 a      f    c     s      .
1839	16	Thank God for the new liver and kidneys.	Dieu soit loué pour ce nouveau foie et ces reins.	D    s    l    p    c  n       f    e  c   r    .
1840	16	Wait up, guys! Beers are on me!	Attendez, les gars ! Les bières sont pour moi !	A       , l   g    ! L   b      s    p    m   !
1841	16	I might have two tonight.	J'en boirai deux ce soir !	J'   b      d    c  s    !
1842	16	That's right: two sips!	Oui ! Deux gorgées !	O   ! D    g       !
1843	16	Hope you're hungry, Homer.	Tu as faim, Homer ?	T  a  f   , H     ?
1844	16	I got up at 2:00 a. m. and slow‐roasted a breakfast turkey.	Je me suis levée à 2 h pour rôtir la dinde pour le petitdéj.	J  m  s    l     à 2 h p    r     l  d     p    l  p       .
1845	16	Sorry, no time for food. I got to get to work.	Pas le temps de manger, je vais au travail.	P   l  t     d  m     , j  v    a  t      .
1846	16	When did Homer turn into someone who wants to go into work?	Depuis quand Homer veutil aller au travail ?	D      q     H     v      a     a  t       ?
1847	16	Oh, no. It's in the air.	Non ! C'est dans l'air !	N   ! C'    d    l'    !
1848	16	Now I want to go to school and make something of myself.	Je veux aller à l'école ! Je veux devenir quelqu'un !	J  v    a     à l'      ! J  v    d       q     '   !
1849	16	Hey, work is amazing now.	Le boulot est devenu génial.	L  b      e   d      g     .
1850	16	A magical place where we get what we deserve and more.	Un endroit magique où on obtient ce qu'on mérite et plus.	U  e       m       o  o  o       c  q '   m      e  p   .
1851	16	And it's all due to Fred.	Et tout ça grâce à Fred.	E  t    ç  g     à F   .
1852	16	Okay, so when are we gonna meet this Fred?	Quand estce qu'on le rencontre, ce Fred ?	Q     e     q '   l  r        , c  F    ?
1853	16	Oh, you've already met him, Marge,	Vous l'avez déjà rencontré,	V    l'     d    r        ,
1854	16	in the smile on my face.	dans le sourire sur mon visage.	d    l  s       s   m   v     .
1855	16	Should we tell him it's a Saturday?	On lui dit qu'on est samedi ?	O  l   d   q '   e   s      ?
1856	16	Eh, not yet. At least we'll get some of the roast turkey for once.	Pas encore. Au moins, on aura de la dinde pour une fois.	P   e     . A  m    , o  a    d  l  d     p    u   f   .
1857	16	Hey, Homer. Look what Fred made Burns give us to handle plutonium.	Regarde ce que Fred nous a eu pour manier le plutonium.	R       c  q   F    n    a e  p    m      l  p        .
1858	16	Look at me. I'm Audrey Hepburn.	Regardezmoi ! Je suis Audrey Hepburn !	R           ! J  s    A      H       !
1859	16	Lenny Leonard, you have exquisite vision and you know it. Give me those.	Lenny, vous voyez très bien et vous le savez. Donnezmoi ça !	L    , v    v     t    b    e  v    l  s    . D         ç  !
1860	16	Oh, I don't care what you think, 'cause Fred doesn't like you.	Vous pouvez toujours causer, Fred vous aime pas.	V    p      t        c     , F    v    a    p  .
1861	16	And once Fred gets around to it, you ain't gonna be working here no more.	Et quand Fred s'en sera occupé, vous ne travaillerez plus ici !	E  q     F    s'   s    o     , v    n  t            p    i   !
1862	16	I've had enough. Simpson, come with me. What the...?	J'en ai assez. Simpson, avec moi !  Quoi ?	J'   a  a    . S      , a    m   ! Q    ?
1863	16	There's something you don't know about your good friend Fred.	Il y a quelque chose que vous ignorez à propos de votre ami Fred.	I  y a q       c     q   v    i       à p      d  v     a   F   .
1864	16	I know everything I need to know	Je sais tout ce qu'il faut	J  s    t    c  q '   f
1865	16	about Fred whatshisname from wherever he comes.	sur Fred machinchose qui vient de je ne sais où.	s   F    m           q   v     d  j  n  s    o .
1866	16	But wait a minute. Isn't that a good thing?	Minute, c'est pas une bonne chose ?	M     , c'    p   u   b     c     ?
1867	16	It means he's nice to us now.	Il est gentil avec nous maintenant.	I  e   g      a    n    m         .
1868	16	His niceness is gonna put us out of business.	Sa gentillesse nous mènera à la faillite.	S  g           n    m      à l  f       .
1869	16	These giveaways are bankrupting us.	Et ses cadeaux, à la banqueroute.	E  s   c      , à l  b          .
1870	16	What should we give our friends next, Fred? Morning yoga? Irish brides?	On leur offre quoi ensuite, Fred ? Yoga ? Belles Irlandaises ?	O  l    o     q    e      , F    ? Y    ? B      I           ?
1871	16	Okay, maybe the yoga is going too far.	D'accord, le yoga, ça va un peu loin.	D'      , l  y   , ç  v  u  p   l   .
1873	16	We're gonna go the way of the Sears catalog and 20th Century Fox.	On va finir comme Sears et la 20th Century Fox.	O  v  f     c     S     e  l  20   C       F  .
1874	16	Are you sure this isn't because you miss the old Burns?	C'est pas plutôt parce que l'ancien Burns vous manque ?	C'    p   p      p     q   l'       B     v    m      ?
1875	16	Of course I miss him. Who wouldn't?	Bien sûr qu'il me manque. C'est normal !	B    s   q '   m  m     . C'    n      !
1876	16	Simpson, if you care about your job, and the jobs of everyone in this plant,	Si vous tenez à votre travail et celui de tous les autres,	S  v    t     à v     t       e  c     d  t    l   a     ,
1877	16	you'll end your friendship with Mr. Burns. Permanently.  	mettez fin à votre amitié avec M. Burns, définitivement.	m      f   à v     a      a    M. B    , d             .
1878	16	No problem. As long as I'm still friends with Fred.	Pas de problème, si je reste ami avec Fred.	P   d  p       , s  j  r     a   a    F   .
1879	16	What's wrong, Homie?  Mm, not much.	Qu'estce qui ne va pas, Homer ? Pas grandchose.	Q '      q   n  v  p  , H     ? P   g         .
1880	16	I lost a friend today because Burns stepped out of him.	J'ai perdu un ami parce que Burns est sorti de lui.	J'   p     u  a   p     q   B     e   s     d  l  .
1881	16	What?  Well, let's just say I can't be friends with Fred anymore 	Quoi ? Je peux plus être ami avec Fred, 	Q    ? J  p    p    ê    a   a    F   ,
1882	16	but I don't know how to tell him.	mais je sais pas comment lui dire.	m    j  s    p   c       l   d   .
1883	16	Well, don't ask me. I suck at it. That's why I can't shake Milhouse.	Je suis nul pour ça aussi, sinon j'aurais décramponné Milhouse.	J  s    n   p    ç  a    , s     j'       d           M       .
1884	16	I'm right here, Bart.	Je suis juste là, Bart !	J  s    j     l , B    !
1885	16	Our sleepover ended two days ago.	La soirée pyjama est finie depuis 2 jours.	L  s      p      e   f     d      2 j    .
1886	16	I'll call my mom again.	Je rappelle ma mère.	J  r        m  m   .
1887	16	Listen, Fred, we can't really hang out with you anymore.	Ecoute, Fred, on peut plus vraiment se voir.	E     , F   , o  p    p    v        s  v   .
1888	16	No offense. I mean, it's just that I got to focus on work.	Le prends pas mal, c'est juste que je dois me concentrer sur le boulot.	L  p      p   m  , c'    j     q   j  d    m  c          s   l  b     .
1889	16	My console's under here somewhere.	Ma console est quelque part làdessous.	M  c       e   q       p    l        .
1890	16	The man of the hour.  Oh...	L'homme de la situation !	L'      d  l  s         !
1891	16	We were just working on a list of new things you can get Old Man Burns to give us.	On bosse sur de nouveaux trucs que tu pourrais obtenir du vieux Burns.	O  b     s   d  n        t     q   t  p        o       d  v     B    .
1892	16	What do you mean "Old Man Burns"?	Comment ça, le "vieux Burns" ?	C       ç , l  "      B    " ?
1893	16	I mean, he's so old.	C'est un ancêtre !	C'    u  a       !
1894	16	Fossilized scarecrow.	Un épouvantail fossilisé !	U  é           f         !
1895	16	You know, I've never seen Fred and Burns at the same time.	Dis donc, j'ai jamais vu Fred et Burns en même temps...	D   d   , j'   j      v  F    e  B     e  m    t    ...
1896	16	Which means you must hate Burns, too.	Tu dois détester Burns aussi !	T  d    d        B     a     !
1897	16	Ooh, well, we‐we don't really hate him.	Enfin, on le déteste pas vraiment...	E    , o  l  d       p   v       ...
1898	16	Mr. Burns is a withered old corn husk with a rotten apple for a head,	Burns est une vieille fane de maïs avec une tête de pomme pourrie !	B     e   u   v       f    d  m    a    u   t    d  p     p       !
1899	16	and I'm getting special clogs made up so I can Riverdance on his grave.	Je me suis fait faire des chaussons pour danser sur sa tombe !	J  m  s    f    f     d   c         p    d      s   s  t     !
1900	16	You ungrateful jackals.	Espèces de chacals ingrats !	E       d  c       i       !
1901	16	Smithers, where's the kill button?	Smithers, quel bouton sert à tuer ? 	S       , q    b      s    à t    ?
1902	16	Um, there isn't one, sir.	Il n'y en a pas.	I  n'  e  a p  .
1903	16	How many times have I told you, everything must have a kill button?	Combien de fois vous aije dit qu'il en faut un sur tout !	C       d  f    v    a    d   q '   e  f    u  s   t    !
1904	16	Unhand me, you ape!	Lâchemoi, chimpanzé !	L       , c         !
1905	16	Why am I always referred to as an ape?	Pourquoi on me traite toujours de chimpanzé,	P        o  m  t      t        d  c        ,
1906	16	Never a gorilla or an orangutan.	et jamais de gorille ou d'orangoutan ?	e  j      d  g       o  d'           ?
1907	16	Aw, monkey want a banana?	Le macaque veut une banane ?	L  m       v    u   b      ?
1908	16	Why, you incredibly complex...	T'es incroyablement complexe...	T'   i              c       ...
1909	16	I thought you were my friends.	Je pensais que vous étiez mes amis.	J  p       q   v    é     m   a   .
1910	16	Huh. Someone's having a day.	Quelqu'un passe une sale journée.	Q     '   p     u   s    j      .
1911	16	Fred, you traitor.	Fred, traître !	F   , t       !
1912	16	You've turned my employees against me.	Tu les as retournés contre moi. 	T  l   a  r         c      m  .
1913	16	Yeah, but they love me.	Oui, mais ils m'aiment.	O  , m    i   m'      .
1914	16	And soon, there'll be no you. Just Fred!	Et bientôt, tu n'existeras plus, il n'y aura plus que Fred !	E  b      , t  n'          p   , i  n'  a    p    q   F    !
1915	16	As all my attorneys keep telling me, why won't you die?	Comme me le disent mes avocats, pourquoi tu ne meurs pas ?	C     m  l  d      m   a      , p        t  n  m     p   ?
1916	16	Because I'm the last spark of goodness in you.	Parce que je suis la dernière étincelle de bonté en toi !	P     q   j  s    l  d        é         d  b     e  t   !
1917	16	It can't be extinguished!	Elle ne peut pas être éteinte !	E    n  p    p   ê    é       !
1918	16	I'm glad I went to the bathroom in you.	Je suis content de t'avoir uriné dedans.	J  s    c       d  t'      u     d     .
1920	16	Oh, why can't I be loved and feared?	Pourquoi ne puisje pas être aimé et craint ?	P        n  p      p   ê    a    e  c      ?
1921	16	Like God?  Why?	Comme Dieu !  Pourquoi ?	C     D    ! P        ?
1922	16	Because you're the boss, we're the workers.	Vous êtes le patron, on est les employés.	V    ê    l  p     , o  e   l   e       .
1923	16	It goes back to caveman days.	Ça remonte aux hommes des cavernes.	Ç  r       a   h      d   c       .
1924	16	Ten guys killed the mammoth while the boss yelled at them.	Ils tuaient le mammouth en se faisant engueuler.	I   t       l  m        e  s  f       e        .
1925	16	Then the boss got all the meat and they got all the toenails.	Le patron prenait la viande et eux avaient les ongles de pieds.	L  p      p       l  v      e  e   a       l   o      d  p    .
1926	16	Because that's the way life works.	Parce que la vie marche comme ça.	P     q   l  v   m      c     ç .
1927	16	Next came the Renaissance, and the invention of the time clock,	Ensuite vint la Renaissance, et l'invention de la pointeuse.	E       v    l  R          , e  l'          d  l  p        .
1928	16	which meant the boss no longer had to waste time checking on his employees	Le patron n'avait plus à perdre de temps à surveiller ses employés	L  p      n'      p    à p      d  t     à s          s   e
1929	16	and could become pope and marry his sister.	et pouvait devenir Pape et épouser sa sœur.	e  p       d       P    e  é       s  s   .
1930	16	With recent times came unions and workers' rights.	Plus récemment sont venus les syndicats et les droits des travailleurs.	P    r         s    v     l   s         e  l   d      d   t           .
1931	16	Which were then taken away in even more recent times.	Qui leur furent retirés à une époque plus récente encore.	Q   l    f      r       à u   é      p    r       e     .
1932	16	Wrap it up, Homer. That catwalk is starting to buckle.	Abrège, Homer ! La passerelle va céder !	A     , H     ! L  p          v  c     !
1933	16	My point is, no matter what, Mr. Burns, the boss sucks, so why shouldn't you?	dans tous les cas, M. Burns, le patron est nul, alors pourquoi pas vous ?	d    t    l   c  , M. B    , l  p      e   n  , a     p        p   v    ?
1934	16	Why indeed.	Pourquoi pas, en effet.	P        p  , e  e    .
1935	16	Back to work, and everything nice is canceled.	Au travail, tous les avantages sont annulés.	A  t      , t    l   a         s    a      .
1936	16	Um, does that include...  If you have to ask, it's canceled.	Ça inclut...  Si vous demandez, c'est annulé !	Ç  i     ... S  v    d       , c'    a      !
1937	16	And Fred, the man I could've been,	Quant à Fred, celui que j'aurais pu être,	Q     à F   , c     q   j'       p  ê   ,
1938	16	I consign to the fires of hell.	je le voue aux feux de l'enfer.	j  l  v    a   f    d  l'     .
1939	16	Somebody stop it. No, no, no, too late.	Arrêtezle ! Non, c'est trop tard !	A         ! N  , c'    t    t    !
1940	16	Oh, poor Fred.  It's a costume, you idiot.	Pauvre Fred.  C'est un costume, idiot !	P      F   . C'    u  c      , i     !
1941	16	A lot of work goes into those.	Mais qui avait coûté cher.	M    q   a     c     c   .
1942	16	Good to have you back, sir. 	Content de vous revoir, monsieur.	C       d  v    r     , m       .
1943	16	I left my car fob in that suit. Go get it.	Ma clé de voiture était dans ce costume. Allez la chercher !	M  c   d  v       é     d    c  c      . A     l  c        !
1944	16	But that's certain death, sir.	C'est la mort assurée...	C'    l  m    a      ...
1945	16	Yes, but for you.  You're back.	Oui, mais la vôtre. Vous êtes de retour !	O  , m    l  v    . V    ê    d  r      !
1946	16	Or am I?	Ou estce moi ?	O  e     m   ?
1947	16	This is your new coworker Don Phoneyman.	C'est votre nouveau collègue, Don Lebidon.	C'    v     n       c       , D   L      .
1948	16	Please show him the ropes.	Montrezlui les ficelles.	M          l   f       .
1949	16	I'm not going through this again. Come on.	On ne va pas me la refaire !	O  n  v  p   m  l  r       !
1950	16	We know it's you, Mr. Burns, and we'll prove it.	On sait que c'est vous, M. Burns. La preuve !	O  s    q   c'    v   , M. B    . L  p      !
1951	16	Release the hounds. They won't touch you.	Lâchez les chiens ! Ils ne vous toucheront pas.	L      l   c      ! I   n  v    t          p  .
1952	16	Well, what do you know? He's real.	Mince, c'était un vrai.	M    , c'      u  v   .
1953	16	I didn't know we could call the hounds.	On peut appeler les chiens ?	O  p    a       l   c      ?
1954	16	We can also operate the trapdoor.	On peut aussi actionner la trappe.	O  p    a     a         l  t     .
1955	16	I'll get you for this!	Tu me le paieras !	T  m  l  p       !
1956	16	Engage karaoke mode.	Passer en mode karaoké.	P      e  m    k      .
1957	16	♪ List to me while I tell you ♪	Ecoutemoi, faut que je te parle	E        , f    q   j  t  p
1958	16	♪ Of the Spaniard that blighted my life ♪	De l'Espagnol qui a gâché ma vie	D  l'         q   a g     m  v
1959	16	♪ List to me, while I tell you ♪	Ecoutemoi, faut que je te parle	E        , f    q   j  t  p
1960	16	♪ Of the man that pinched my future wife. ♪	De l'homme qui a chipé ma petite amie	D  l'      q   a c     m  p      a
2086	25	They're really nice, you know?	Ellos son muy lindos, ¿sabe?	E     s   m   l     , ¿s   ?
2087	25	I love them very much.	Yo los quiero mucho.	Y  l   q      m    .
2088	25	But, well...they travel a lot.	Pero pues…se la pasan de viaje.	P    p      l  p     d  v    .
2089	25	Oh, well, your dad seems like a good guy.	Ah, no, pues se nota lo chimba que es su papá.	A , n , p    s  n    l  c      q   e  s  p   .
2090	25	He's also yours.	También es el tuyo.	T       e  e  t   .
2091	25	A dad's someone who raises their kids, who's there for them.	Papá es un tipo que cría, papá es un tipo que está.	P    e  u  t    q   c   , p    e  u  t    q   e   .
2092	25	Not someone who does that shit to the mother of his kids.	Papá no le hace esa porquería a la mamá de sus hijas.	P    n  l  h    e   p         a l  m    d  s   h    .
2323	25	but I don't think it's a good idea.	pero no me parece una buena idea. Eh…	p    n  m  p      u   b     i   . E
2324	25	I think a bit of space is a better idea.	Me parece que es mejor idea un poquito de aire.	M  p      q   e  m     i    u  p       d  a   .
2325	25	So that's that, then. You're overexaggerating things.	Así que está decidido.  Estás exagerando demasiado la situación.	A   q   e    d       . E     e          d         l  s        .
2326	25	I'm not exaggerating. I'm gonna go.	No estoy exagerando. Me voy.	N  e     e         . M  v  .
2327	25	I'm gonna go. Honey, don't go like this.	Sí, me voy.  Ay. Amor, no te vayas así.	S , m  v  . A . A   , n  t  v     a  .
2328	25	Bye. It's okay. Santi, don't go...	Chau. No pasa nada.  Santi, no te va…	C   . N  p    n   . S    , n  t  v
2329	25	I need to break away from my brothers or Romina won't trust me.	O me abro rápido de donde mis hermanos, o Romina no me creerá.	O m  a    r      d  d     m   h       , o R      n  m  c     .
2330	25	That's gonna be hard.	Eso va a estar difícil.	E   v  a e     d      .
2331	25	Not just because your brothers won't let you,	No solamente porque sus hermanos no lo van a dejar,	N  s         p      s   h        n  l  v   a d    ,
2332	25	but because you and Romi are done.	sino porque ya perdió el año con la Romi, a lo bien. 	s    p      y  p      e  a   c   l  R   , a l  b   .
2333	25	That happened a while back, bro.	Ya eso pasó hace rato, hermano.	Y  e   p    h    r   , h      .
2334	25	It hasn't been a while. She's furious with Marlon.	Ningún rato. Ella está ardida es con Marlon.	N      r   . E    e    a      e  c   M     .
2335	25	Once I tell her everything's set so we can leave, it'll change.	Todo cambiará cuando le diga que tengo todo listo para irnos.	T    c        c      l  d    q   t     t    l     p    i    .
2336	25	That's when everything's gonna change for my Romi.	Ahí, en ese momento, todo va a cambiar con mi Romi.	A  , e  e   m      , t    v  a c       c   m  R   .
2337	25	That's what I'm working on, Estiven.	Y para eso estoy trabajando, Estiven.	Y p    e   e     t         , E      .
2338	25	What? Working on what?	¿Qué? ¿Y trabajando en qué?	¿Q  ? ¿Y t          e  q  ?
2339	25	From what I can see, you're still working day and night with your brothers, right?	Hasta donde yo sé, usted sigue camellando en lo mismo que sus hermanos, ¿o no?	H     d     y  s , u     s     c          e  l  m     q   s   h       , ¿o n ?
2340	25	Yes, but the commission went up.	Sí, pero las comisiones subieron.	S , p    l   c          s       .
2341	25	But my brothers don't know that yet.	Solo que mis hermanos no lo saben.	S    q   m   h        n  l  s    .
2342	25	A pleasure, sir. We are at your service.	Un gusto, papá. Estamos para servirle.	U  g    , p   . E       p    s       .
2343	25	I feel horrible about lying to my boyfriend, Romi.	Yo me siento horrible diciéndole mentiras a mi novio, Romi.	Y  m  s      h        d          m        a m  n    , R   .
2344	25	No, girl, I understand.	No, pues, mija, yo la entiendo.	N , p   , m   , y  l  e       .
2345	25	I'm going through the same thing with my Whiz.	A mí me pasa lo mismo con mi Calidosito.	A m  m  p    l  m     c   m  C         .
2346	25	Is that his name?	¿Así se llama?	¿A   s  l    ?
2347	25	Can you imagine? No, his name is Cristóbal Ruiz.	¿Qué se va a llamar así? No, el man se llama Cristóbal Ruiz.	¿Q   s  v  a l      a  ? N , e  m   s  l     C         R   .
2348	25	But he's great at his job,	Lo que pasa es que el man es un duro	L  q   p    e  q   e  m   e  u  d
2349	25	so that's what he's known by in the hood.	y así le decimos todos en el barrio.	y a   l  d       t     e  e  b     .
2350	25	Well, my Santi is also amazing.	Pues la verdad es que mi Santi también es un divino.	P    l  v      e  q   m  S     t       e  u  d     .
2351	25	Isn't he one of those pretty boys?	¿No será uno de esos gomelos carilindos?	¿N  s    u   d  e    g       c         ?
2352	25	Oh, Laura, don't get upset, I'm just messing with you.	Ay, Laura, no se va a timbrar, que la estoy molestando.	A , L    , n  s  v  a t      , q   l  e     m         .
2353	25	I'm sure that guy's as cool as you.	Estoy segura que ese man debe ser una chimba así como usted.	E     s      q   e   m   d    s   u   c      a   c    u    .
2354	25	Either way, I didn't call about that, Romi.	Igual, yo no te llamaba para eso, Romi.	I    , y  n  t  l       p    e  , R   .
2355	25	I didn't find out anything about the nurse.	¿Cómo te parece que no encontré nada de la enfermera?	¿C    t  p      q   n  e        n    d  l  e        ?
2356	25	But relax, I'll look around here at home.	Pero fresca, porque me voy a poner a buscar acá en la casa.	P    f     , p      m  v   a p     a b      a   e  l  c   .
2357	25	And what are you looking for?	¿Y qué se va a poner a buscar?	¿Y q   s  v  a p     a b     ?
2358	25	Honestly, I have no idea.	La verdad, no tengo ni idea.	L  v     , n  t     n  i   .
2359	25	Anyways, I have to be careful,	Además, me toca con un cuidado,	A     , m  t    c   u  c      ,
2360	25	because if one of the employees finds out I'm going through my dad's things,	porque donde alguna de las empleadas se dé cuenta que estoy esculcando las cosas de mi papá,	p      d     a      d  l   e         s  d  c      q   e     e          l   c     d  m  p   ,
2361	25	they'll go and say something.	fijo van y le dicen todo.	f    v   y l  d     t   .
2362	25	Oh, no. Really, I like him more and more every day.	Ay, no. A mí en serio como que cada vez me cae mejor.	A , n . A m  e  s     c    q   c    v   m  c   m    .
2363	25	Well, we'll talk later. Bye.	Bueno, después hablamos. Bye.	B    , d       h       . B  .
2364	25	From the old man down here.	Del cucho de aquí abajo.	D   c     d  a    a    .
2365	25	There's money missing.	Aquí falta plata.	A    f     p    .
2366	25	Oh, yes. He wasn't able to pay all the interest.	Ah, sí. Es que no pudo pagar todos los intereses.	A , s . E  q   n  p    p     t     l   i        .
2367	25	So what? Do I start crying or what?	¿Qué? ¿Me pongo a llorar o qué?	¿Q  ? ¿M  p     a l      o q  ?
2368	25	Come on, bro. Things are really hard out there.	Ay, manito. Afuera la situación está muy dura.	A , m     . A      l  s         e    m   d   .
2369	25	This guy has always paid on time. 	Este man nunca nos quedó mal.	E    m   n     n   q     m  .
2370	25	I gave him until next week. That's all.	Ya. Le di tiempo hasta la otra semana. Eso es todo.	Y . L  d  t      h     l  o    s     . E   e  t   .
2371	25	No, not until next week. I'm writing here that the client's your problem.	Hasta la otra semana, no. Acá anoto que ese cliente es problema suyo.	H     l  o    s     , n . A   a     q   e   c       e  p        s   .
2372	25	You take care of it.	Usted responde.	U     r       .
2373	25	Come on, Benny.	A ver, Benny.	A v  , B    .
2374	25	You know I get along better with people than with all of you	Usted sabe que afuera la gente me corre más que a todos ustedes	U     s    q   a      l  g     m  c     m   q   a t     u
2375	25	who scare them like Marlon does.	que le meten terror al estilo Marlon.	q   l  m     t      a  e      M     .
2376	25	Oh, what's this? The psychologist. Is that what they say?	Ay, ¿qué es esto? El psicólogo. ¿Cómo le dicen?	A , ¿q   e  e   ? E  p        . ¿C    l  d    ?
2377	25	Not true. Like they say out there.	Pero no es cierto.   Como dicen ahí afuera.	P    n  e  c     . C    d     a   a     .
2378	25	Talking it out is better than war. Remember that.	El diálogo es más importante que la guerra. Apréndase eso.	E  d       e  m   i          q   l  g     . A         e  .
2379	25	Hmm? How about you just charge them what they owe?	¿Mmm? Más bien, ¿por qué no cobra bien?	¿M  ? M   b   , ¿p   q   n  c     b   ?
2380	25	Quit talking shit. Give me Gloria's.	Deje de hablar tanta mierda. Páseme lo de la cucha Gloria.	D    d  h      t     m     . P      l  d  l  c     G     .
2381	25	It's here. This is Gloria's.	Es esto. Esto y esto.	E  e   . E    y e   .
2382	25	Alright then, Romi. I haven't found anything strange here.	Pues nada, Romi. Por aquí no encontré nada raro.	P    n   , R   . P   a    n  e        n    r   .
2383	25	And now I have to clean up this mess. So annoying.	Y lo peor es que ahora me toca organizar todo este desorden. Qué mamera.	Y l  p    e  q   a     m  t    o         t    e    d       . Q   m     .
2384	25	Bad luck.	Qué embarrada.	Q   e        .
2385	25	Come on, then, let's talk about something else.	Venga, pelada, pero más bien hablemos de cosas bonitas.	V    , p     , p    m   b    h        d  c     b      .
2386	25	Are we gonna see each other again?	¿Nos vamos a volver a ver o qué?	¿N   v     a v      a v   o q  ?
2387	25	I'd love to.	A mí me encantaría.	A m  m  e         .
2388	25	there's a bunch of stuff I want to tell you.	hay un montón de cosas que te quiero contar.	h   u  m      d  c     q   t  q      c     .
2389	25	But you know what?	Pelada, pero ¿sabe qué?	P     , p    ¿s    q  ?
2390	25	It's better if we meet up at a different place.	Es mejor vernos en otro lugar que no sea en el barrio.	E  m     v      e  o    l     q   n  s   e  e  b     .
2391	25	So we don't go calling attention to us with that Land Rover of yours.	Pues para no dar tanto visaje con esa nave que usted se manda.	P    p    n  d   t     v      c   e   n    q   u     s  m    .
2392	25	I have the perfect place where we can see each other.	¿Sabes que yo creo que tengo el lugar perfecto para que nos veamos?	¿S     q   y  c    q   t     e  l     p        p    q   n   v     ?
2393	25	I'll send it to you.	Ya te la mando. Te la voy a mandar.	Y  t  l  m    . T  l  v   a m     .
2394	25	Go ahead.	Hágale, pues.	H     , p   .
2395	25	Sir, right here, right here. Thanks, all good.	Señor, aquí, aquí, aquí. Gracias. Todo bien.	S    , a   , a   , a   . G      . T    b   .
2396	25	They're waiting for you. Great seeing you. Yeah? Oh, good.	La están esperando.  Chimba verlo. ¿Sí? Ah, bueno.	L  e     e        . C      v    . ¿S ? A , b    .
2397	25	This place is empty.	Pero este lugar está como solo.	P    e    l     e    c    s   .
2398	25	Girl! Over here, go on.	¡Pelada!  Por aquí. Síguele.	¡P     ! P   a   . S      .
2399	25	And I present to you... my baby.	Y te presento… mi bebé.	Y t  p        m  b   .
2400	25	My first bakery.	Mi primer local de repostería.	M  p      l     d  r         .
2401	25	The idea is to become independent from my parents with this place	Con este local, la idea es independizarme de mis papás	C   e    l    , l  i    e  i              d  m   p
2402	25	and, eventually, be able to live off of this.	y, eventualmente, poder vivir de esto.	y, e            , p     v     d  e   .
2403	25	Laura, this place is amazing.	Laura, pero esto está muy chimba.	L    , p    e    e    m   c     .
2404	25	And it's yours? No.	¿Y esto es suyo?  No.	¿Y e    e  s   ? N .
2405	25	I've just paid the down payment, and we'll go from there.	Solo he pagado la cuota inicial, pero ahí vamos.	S    h  p      l  c     i      , p    a   v    .
2406	25	And how'd you do that?	¿Y usted cómo hizo?	¿Y u     c    h   ?
2407	25	And working, a lot.	Y trabajando mucho.	Y t          m    .
2408	25	I invested every dollar I've ever made into this place.	Cada peso que me he ganado en la vida lo invertí en este local.	C    p    q   m  h  g      e  l  v    l  i       e  e    l    .
2409	25	My wages, my allowances, my bonuses.	Mis salarios, mis mesadas, mis propinas.	M   s       , m   m      , m   p       .
2410	25	Girl, I've also saved my whole life,	Pelada, yo también ahorro de toda la vida,	P     , y  t       a      d  t    l  v   ,
2411	25	but I can't afford to change the brakes on my bike.	pero no me alcanza ni para cambiar los frenos de la Morocha.	p    n  m  a       n  p    c       l   f      d  l  M      .
2412	25	Relax, Romi, we're going to change that together.	Tú fresca, Romi, que eso lo solucionamos juntas.	T  f     , R   , q   e   l  s            j     .
2413	25	Oh, listen to this girl. Uhuh.	No, oigan a mi tía.	N , o     a m  t  .
2414	25	No, no ma'am.	No, no señora.	N , n  s     .
2415	25	Okay, crazy, just walk and I'll show you the kitchen.	A ver, arrebatada, camina más bien y te muestro la cocina	A v  , a         , c      m   b    y t  m       l  c
2416	25	It's actually finished.	que esa sí está terminada.	q   e   s  e    t        .
2417	25	Over here? Yes. Go ahead.	¿Por allá?   Sí. Hágale.	¿P   a   ? S . H     .
2419	25	Laura, no, what's with the boring music?	No, Laura, ¿qué es esa música tan aburrida?	N , L    , ¿q   e  e   m      t   a       ?
2420	25	No, I'm gonna show you the good stuff.	No, yo le voy a mostrar lo que es bueno.	N , y  l  v   a m       l  q   e  b    .
2421	25	No, I can't concentrate with that music.	No, yo no me puedo concentrar con esa música.	N , y  n  m  p     c          c   e   m     .
2422	25	Okay, so here, we'll make a deal.	Entonces venga. Hagamos un trato.	E        v    . H       u  t    .
2423	25	We each get one.	Una y una.	U   y u  .
2424	25	Deal, but I'll start then.	Trato hecho, pero entonces comienzo yo.	T     h    , p    e        c        y .
2425	25	It's just... I feel like I've known you my whole life.	Es que yo siento como si te conociera de toda la vida.	E  q   y  s      c    s  t  c         d  t    l  v   .
2426	25	Well, it's true.	Es que eso es así.	E  q   e   e  a  .
2427	25	Don't you see that you and I met each other in my mom's belly?	¿No ve que usted y yo nos conocemos desde que estábamos en la barriga de mi mamá?	¿N  v  q   u     y y  n   c         d     q   e         e  l  b       d  m  m   ?
2428	25	Alright, time to bake.	Bueno. A cocinar.	B    . A c      .
2429	25	Go on, because I'm getting hungry.	Bueno. Hágale, pues, que la cosa es de hambre.	B    . H     , p   , q   l  c    e  d  h     .
2430	25	What else do we need? Okay... I'll help.	¿Qué más vamos a necesitar? Y… A ver.	¿Q   m   v     a n        ? Y A v  .
2431	25	No! No, no, no, Laura. Oh my God, what is this?	¡No! No, no, no, Laura. Dios mío, ¿qué es esto?	¡N ! N , n , n , L    . D    m  , ¿q   e  e   ?
2432	25	I have no words.	Sin palabras.	S   p       .
2433	25	Oh my God, this is so good.	Ay, Dios mío, eso le quedó muy bueno.	A , D    m  , e   l  q     m   b    .
2434	25	Girl, that talent came from my mom.	Pelada, ese talento se lo sacó a mi mamá.	P     , e   t       s  l  s    a m  m   .
2435	25	You guys are the exact same, both of you are amazing chefs!	En eso sí son igualiticas. Las dos cocinan como los dioses.	E  e   s  s   i          . L   d   c       c    l   d     .
2436	25	Good to know.	Qué bueno saberlo.	Q   b     s      .
2437	25	This is for Yesenia.	Esto es para Yesenia.	E    e  p    Y      .
2438	25	I can't promise this is gonna make it home in one piece.	Pero yo no le prometo que esto llegue completo a la casa.	P    y  n  l  p       q   e    l      c        a l  c   .
2439	25	I want you and Yesenia to be my guests of honor the day I open the shop.	quiero que tú y Yesenia sean mis invitadas de honor el día que yo abra el local.	q      q   t  y Y       s    m   i         d  h     e  d   q   y  a    e  l    .
2440	25	And I hope by that day, we will have spoken to my dad,	Y yo espero que para ese día ya hayamos hablado con mi papá,	Y y  e      q   p    e   d   y  h       h       c   m  p   ,
2441	25	and have resolved everything...	ya todo esté resuelto…	y  t    e    r
2442	25	Well, Lau, that's...	Pues, Lau, es que…	P   , L  , e  q
2443	25	It's best if you don't give him a chance to come and tell you what to do.	Es mejor que usted no le dé pie para que él vaya y le diga cualquier cosa.	E  m     q   u     n  l  d  p   p    q   é  v    y l  d    c         c   .
2444	25	In other words, if you call him, don't tell him about this.	O sea, si lo va a llamar, no le hable del tema.	O s  , s  l  v  a l     , n  l  h     d   t   .
2445	25	Nuche already confirmed that the girl is hanging around with that cop.	Nuche ya me confirmó que la pelada se baila con el polocho ese.	N     y  m  c        q   l  p      s  b     c   e  p       e  .
2446	25	Another snitch we'll have to clean out. But later,	Otro sapo que hay que destripar. Pero después,	O    s    q   h   q   d        . P    d      ,
2447	25	because first, Romina.	porque primero se nos va Romina.	p      p       s  n   v  R     .
2448	25	What's up, bro? What's up?	¿Entonces, manito?  ¿Entonces?	¿E       , m     ? ¿E       ?
2449	25	What are you up to?	¿Y en qué andan o qué?	¿Y e  q   a     o q  ?
2450	25	Hard at work, not that you'd know it.	Camellando, cosa que a usted no le gusta.	C         , c    q   a u     n  l  g    .
2451	25	What are you working on?	¿Y trabajando en qué?	¿Y t          e  q  ?
2452	25	On whatever we need to get this family ahead, right, Benny?	En todo lo necesario para sacar esta familia adelante, ¿no?	E  t    l  n         p    s     e    f       a       , ¿n ?
2453	25	See you later.	Nos vemos.	N   v    .
2454	25	Well, welcome.	Pues bienvenida.	P    b         .
2455	25	Wow, what a beautiful place!	¡No! ¿Qué es esta belleza?	¡N ! ¿Q   e  e    b      ?
2456	25	Did you make this all yourself?	¿Y usted hizo todo esto sola?	¿Y u     h    t    e    s   ?
2457	25	Let's say I did, but I've had a lot of help.	Digamos que sí, pero también me han ayudado un montón.	D       q   s , p    t       m  h   a       u  m     .
2458	25	Oh, don't be modest.	Ay, no sea modesta.	A , n  s   m      .
2459	25	How impressive, you're opening a business all by yourself, and so young!	Que igual, pues muy berraca, creando empresa usted sola y tan jovencita, pues.	Q   i    , p    m   b      , c       e       u     s    y t   j        , p   .
2460	25	Very brave.	Muy valiente.	M   v       .
2461	25	What's wrong? Why do you make that face?	Ay, ¿y a usted qué le pasa? ¿Por qué tiene esa carita?	A , ¿y a u     q   l  p   ? ¿P   q   t     e   c     ?
2462	25	My dad has never said that.	Es que mi papá nunca me ha dicho eso.	E  q   m  p    n     m  h  d     e  .
2463	25	it's like I've never been good enough for him.	Es como si yo nunca diera la talla con absolutamente nada.	E  c    s  y  n     d     l  t     c   a             n   .
2464	25	Let me tell you something.	Yo le voy a decir una cosa.	Y  l  v   a d     u   c   .
2465	25	You're an amazing woman.	Usted es una mujer increíble.	U     e  u   m     i        .
2466	25	And don't ever let anyone tell you otherwise, okay?	Y no deje nunca que nadie diga lo contrario. ¿Sí me oyó?	Y n  d    n     q   n     d    l  c        . ¿S  m  o  ?
2467	25	And for whatever it's worth, I'm very proud of you.	Pues si le sirve de algo, yo me siento muy orgullosa de usted.	P    s  l  s     d  a   , y  m  s      m   o         d  u    .
2468	25	A few more steps, careful. There, there, there.	Un poquito más adelante. Con cuidado. Ahí, ahí, ahí.	U  p       m   a       . C   c      . A  , a  , a  .
2469	25	Ready? Can I open my eyes?	¿Listo? ¿Ya puedo abrir los ojos?	¿L    ? ¿Y  p     a     l   o   ?
2470	25	You don't like it?	¿No le gustó?	¿N  l  g    ?
2471	25	Romi, this is beautiful.	Romi, esto está divino.	R   , e    e    d     .
2472	25	Look, I don't know, but if I ever leave this place,	Mira, no sé, pero si yo algún día me llego a ir de este local,	M   , n  s , p    s  y  a     d   m  l     a i  d  e    l    ,
2473	25	I'm taking this wall with me.	yo me voy a llevar esta pared.	y  m  v   a l      e    p    .
2474	25	Oh, don't be so dramatic!	¡Ay, tan exagerada!	¡A , t   e        !
2475	25	Honey, it looks wonderful.	Mi amor, le quedó precioso.	M  a   , l  q     p       .
2476	25	You're such an artist, Romi.	Eres toda una artista, Romi.	E    t    u   a      , R   .
2477	25	You haven't seen anything yet. My Romina is very talented.	Y eso que no ha visto nada. Mi Romina tiene muchos talentos.	Y e   q   n  h  v     n   . M  R      t     m      t       .
2478	25	Oh, I know. Like with the bike.	Ah, yo sé. Como lo de la bicicleta.	A , y  s . C    l  d  l  b        .
2479	25	Remember we met because of that news story.	Acuérdense que por esa noticia fue que di con ustedes.	A          q   p   e   n       f   q   d  c   u      .
2480	25	And thank God.	Y menos mal.	Y m     m  .
2481	25	Listen, Laura. Thanks for this.	Óigame, Laura. Gracias por eso.	Ó     , L    . G       p   e  .
2482	25	No, thanks to you.	A ti, gracias por esto.	A t , g       p   e   .
2483	25	Romina, you definitely never cease to amaze me.	Definitivamente, Romina, no deja de sorprenderme.	D              , R     , n  d    d  s           .
2484	25	Can I see the kitchen? Of course.	¿Será que yo puedo ver la cocina?  Claro.	¿S    q   y  p     v   l  c     ? C    .
2485	25	Where is it? Over here.	¿Dónde queda?  Acá. 	¿D     q    ? A  .
2486	25	Oh, okay, great.	Ah, bueno, listo.	A , b    , l    .
2487	25	I also wanted to tell you that I gave Rubén the coordinates	Aprovecho para decirle que ya le di unas coordenadas a Rubén	A         p    d       q   y  l  d  u    c           a R
2488	25	to a place I want to take you because I have a surprise for you.	de un lugar al que quiero que la lleve porque le tengo una sorpresita.	d  u  l     a  q   q      q   l  l     p      l  t     u   s         .
2489	25	But don't say anything to my mom because she'll get worried.	Pero no le vaya a decir nada a mi mamá que ella es toda preocupada.	P    n  l  v    a d     n    a m  m    q   e    e  t    p         .
2490	25	And why would she get worried?	¿Y ella por qué se iba a preocupar?	¿Y e    p   q   s  i   a p        ?
2491	25	No, no, no. What a kitchen!	No, no, no. ¿Qué es esta cocina?	N , n , n . ¿Q   e  e    c     ?
2492	25	My dream kitchen. Did you see it, Romina?	La cocina de mis sueños. ¿Usted la vio, Romina?	L  c      d  m   s     . ¿U     l  v  , R     ?
2493	25	Oh, how's the kitchen? Cool, right? This place is beautiful.	Ah, ¿qué tal esa chimba de cocina?   Este lugar es una maravilla.	A , ¿q   t   e   c      d  c     ? E    l     e  u   m        .
2494	25	And ready to welcome you. Thanks, honey.	Y está muy a la orden.  Gracias, mi amor.	Y e    m   a l  o    . G      , m  a   .
2495	25	Thanks. See how happy you look?	¿Sí ve cómo se ve de bien?	¿S  v  c    s  v  d  b   ?
2496	25	This is how you should always be, happy, you know?	Usted debería estar así siempre. Feliz, ¿eh?	U     d       e     a   s      . F    , ¿e ?
2497	25	Rubén, do you know that there's something still on my mind?	Igual, ¿sabe que hay algo que me tiene como pensativa, Rubén?	I    , ¿s    q   h   a    q   m  t     c    p        , R    ?
2498	25	That we haven't found out anything to prove what my dad did.	Que no encontramos ninguna prueba para probar lo que mi papá hizo.	Q   n  e           n       p      p    p      l  q   m  p    h   .
2499	25	I've been looking, and I'm going to the hospitals	Yo he estado buscando cosas. Voy a ir a dos centros de salud	Y  h  e      b        c    . V   a i  a d   c       d  s
2500	25	near Samacá to see if I find anything.	que quedan cerca a Samacá a ver qué.	q   q      c     a S      a v   q  .
2501	25	You know that if we don't find anything, we'll have to keep looking.	Usted sabe que si allá no encontramos nada, nos toca seguir buscando.	U     s    q   s  a    n  e           n   , n   t    s      b       .
2502	25	It won't turn on and I can't find the charger.	No prende y tampoco encontré el cargador.	N  p      y t       e        e  c       .
2503	25	Gregorio, my godson, has a computer shop.	Yo tengo un ahijado, Gregorio, que tiene una tienda de computadores.	Y  t     u  a      , G       , q   t     u   t      d  c           .
2504	25	He can figure it out.	Él le puede cacharrear.	É  l  p     c         .
2505	25	That's a good idea. Of course.	Esa es muy buena idea, Rubén.  Claro.	E   e  m   b     i   , R    . C    .
2506	25	Thanks. Oh, wait!	Gracias.  Ay, espéreme.	G      . A , e       .
2507	25	That girl Romina told me to give this to you	Esta muchacha Romina me dijo que le entregara esto	E    m        R      m  d    q   l  e         e
2508	25	and that later I'll take you to a place she told me about.	y que más tarde la llevara a usted a un lugar que ella me dijo.	y q   m   t     l  l       a u     a u  l     q   e    m  d   .
2509	25	That outfit looks great on you, girl.	Esa pinta le luce, pelada.	E   p     l  l   , p     .
2510	25	Still, I feel super uncomfortable.	Igual, me siento superincómoda.	I    , m  s      s            .
2511	25	Uhuh. You relax, I'm going to make you a pro.	Usted fresquéese, que yo la voy a volver una pro.	U     f         , q   y  l  v   a v      u   p  .
2512	25	Walk. Okay.	Camine a ver.  Okey.	C      a v  . O   .
2604	25	but that is not going to happen.	pero eso no va a pasar por nada.	p    e   n  v  a p     p   n   .
2513	25	Alright, kid, we'll start with this drop so you can see what it's like.	Bueno, pelada, vamos a arrancar con esta bajada para que pille cómo es la vaina.	B    , p     , v     a a        c   e    b      p    q   p     c    e  l  v    .
2514	25	Romi, I even fall out of bed sometimes.	Romi, ¿tú sí sabes que yo me caigo hasta de la cama, o no?	R   , ¿t  s  s     q   y  m  c     h     d  l  c   , o n ?
2515	25	Oh, but you know how to ride a bike.	Ay, pero usted sabe montar bicicleta.	A , p    u     s    m      b        .
2516	25	No, I do know, but... If not, you didn't have a childhood.	No, yo sí sé, pero…  Si no, usted no tuvo infancia.	N , y  s  s , p    S  n , u     n  t    i       .
2517	25	Don't worry about it, kid.	Pero nada, pelada.	P    n   , p     .
2518	25	You taught me how to make desserts, I'll teach you how to be a cycling champ.	Usted me enseñó a hacer postres. Yo le voy a enseñar a dominar mi Morocha.	U     m  e      a h     p      . Y  l  v   a e       a d       m  M      .
2519	25	Check it out.	Pille cómo es la vaina.	P     c    e  l  v    .
2520	25	Come on, kid, it's your turn now.	Bueno, pelada, ahora le toca a usted.	B    , p     , a     l  t    a u    .
2521	25	What happened, dear?	¿Qué pasó, mijita?	¿Q   p   , m     ?
2522	25	What happened? Where are you hurt? Oh!	¿Qué pasó? ¿Dónde se pegó?	¿Q   p   ? ¿D     s  p   ?
2523	25	Does it hurt a lot?	¿Le está doliendo mucho?	¿L  e    d        m    ?
2524	25	Oh, be careful, Rubén.	Ay, cuidado, Rubén.	A , c      , R    .
2525	25	I'm not that fragile, Romina.	yo no soy de porcelana, Romina.	y  n  s   d  p        , R     .
2526	25	Oh, no. What will we do with a pastry chefcyclist?	Ay, no. ¿Qué vamos a hacer con la ciclista repostera pues?	A , n . ¿Q   v     a h     c   l  c        r         p   ?
2527	25	You'll have to stop her, Rubén.	Va a tocar atajarla, Rubén.	V  a t     a       , R    .
2528	25	Listen, you're actually hurt. Look at that face.	Oiga, pero a usted sí le dolió. Véase esa cara que tiene.	O   , p    a u     s  l  d    . V     e   c    q   t    .
2529	25	It's not that.	Pero es que no es por eso.	P    e  q   n  e  p   e  .
2530	25	It's because I just decided not to go to Paris with Santiago.	Es porque acabo de decidir que no voy a ir a París con Santiago.	E  p      a     d  d       q   n  v   a i  a P     c   S       .
2531	25	What? You're going to Paris?	¿Cómo? ¿Usted se iba a París o qué?	¿C   ? ¿U     s  i   a P     o q  ?
2532	25	When? I was going to Paris.	¿Cuándo?  Me iba a París.	¿C     ? M  i   a P    .
2533	25	Come on, help me, Rubén.	Venga, ayúdeme, Rubén.	V    , a      , R    .
2534	25	I don't want to get separated again from you or my mom.	yo no me quiero volver a separar de usted ni de mi mamá.	y  n  m  q      v      a s       d  u     n  d  m  m   .
2535	25	I like how you think, kid.	Qué chimba que piense así, pelada.	Q   c      q   p      a  , p     .
2536	25	Still, you know that we'll be together forever.	Igual, usted sabe que estamos siempre juntas.	I    , u     s    q   e       s       j     .
2537	25	Whatever happens. Together forever.	Para las que sea.  Siempre juntas.	P    l   q   s  . S       j     .
2538	25	So your godson works here? No, it's his business.	¿Entonces su ahijado trabaja acá?  No, el negocito es de él.	¿E        s  a       t       a  ? N , e  n        e  d  é .
2539	25	This is Gregorio, the goto man for computer problems, internet issues,	Este es Gregorio, la flecha de los computadores, del internet,	E    e  G       , l  f      d  l   c           , d   i       ,
2540	25	anything like that.	de todas esas cosas.	d  t     e    c    .
2541	25	Nice to meet you. Laura. A pleasure, Gregorio Restrepo.	Mucho gusto. Laura.  Mucho gusto, Gregorio Restrepo.	M     g    . L    . M     g    , G        R       .
2542	25	You can call me Gregor. Everyone calls me that.	Me puedes decir Gregor. Acá todo el mundo me conoce así.	M  p      d     G     . A   t    e  m     m  c      a  .
2543	25	Can I have my hand back?	¿Me regresa la mano…	¿M  r       l  m
2544	25	Please? Thanks.	porfa? Gracias.	p    ? G      .
2545	25	So, were you able to turn on the tablet? Did you find anything?	Eh, bueno, cuénteme. ¿Sí pudo prender la tableta, encontrar algo? ¿O nada?	E , b    , c       . ¿S  p    p       l  t      , e         a   ? ¿O n   ?
2546	25	Good news: nothing offensive, no naked photos, nothing like that.	Buenas noticias: nada obsceno, nada de fotos de gente en pelotas, ni cosas así.	B      n       : n    o      , n    d  f     d  g     e  p      , n  c     a  .
2547	25	Here is what I found.	Mejor dicho, esto fue lo que encontré.	M     d    , e    f   l  q   e       .
2548	25	I don't understand. These are... Deposits. Yes.	Pero no entiendo. Esto son como…  Consignaciones. Sí.	P    n  e       . E    s   c    C             . S .
2549	25	Deposits that were made since around the year 2000.	Consignaciones que hicieron como desde el 2000.	C              q   h        c    d     e  2000.
2550	25	Is there a way of seeing the date a deposit was made?	¿Y hay forma de ver como la fecha en la que se hizo la consignación o no?	¿Y h   f     d  v   c    l  f     e  l  q   s  h    l  c            o n ?
2551	25	Yes, look, right here. It's this whole column.	Sí, mira, ahí está. Toda esta columna es.	S , m   , a   e   . T    e    c       e .
2552	25	The first one was made on November 10th, 2001, to a Sonia Mendigaña.	La primera la hicieron el 10 de noviembre del 2001 a nombre de Sonia Mendigaña.	L  p       l  h        e  10 d  n         d   2001 a n      d  S     M        .
2553	25	Everything's ready for Romina.	Todo listo para aquello con Romina.	T    l     p    a       c   R     .
2554	25	You just have to say when.	No más es que me diga cuándo.	N  m   e  q   m  d    c     .
2555	25	Later this afternoon, bro.	Hoy en la tarde, bro.	H   e  l  t    , b  .
2556	25	Just do it.	Sin mente.	S   m    .
2557	25	We'll do it when she drinks her juice at Gilbert's stand.	Esa vuelta la vamos a hacer cuando se jarte su jugo en el puesto de Gilberto.	E   v      l  v     a h     c      s  j     s  j    e  e  p      d  G       .
2558	25	After practice?	¿Después del entreno?	¿D       d   e      ?
2559	25	That girl doesn't change her routine. And it's going to cost her her life.	Esa pelada no cambia la rutina. Y eso le va a costar la vida.	E   p      n  c      l  r     . Y e   l  v  a c      l  v   .
2560	25	All set. Whiskey?	Listo.   ¿Un whiskey?	L    . ¿U  w      ?
2561	25	But pour me a double.	Pero sírvamelo lleno.	P    s         l    .
2562	25	Hey! Hey, kid! Oh, "kid"? Yeah right!	¡Ey!  ¡Ey, cachorra!  Cuál cachorra ni qué ocho cuartos.	¡E ! ¡E , c       ! C    c        n  q   o    c      .
2563	25	Come here, wait! I have to tell you something. 	¡Espere! ¡Debo decirle algo!  	¡E     ! ¡D    d       a   !
2564	25	"Kid" was when we were together. 	Cachorra cuando éramos novios.	C        c      é      n     .
2565	25	My brothers want to kill you. Listen to me.	Mis hermanos la quieren matar. ¡Escúcheme!	M   h        l  q       m    . ¡E        !
2566	25	After practice at the juice stand. I'm serious.	Después del entrenamiento en el puesto de los jugos. Esto es en serio.	D       d   e             e  e  p      d  l   j    . E    e  e  s    .
2567	25	We have to do something. Let's leave and go somewhere safe.	Tenemos que hacer algo. Larguémonos ya a un lugar seguro.	T       q   h     a   . L           y  a u  l     s     .
2568	25	If you stick with me, nothing'll happen to you. Let's go.	Sí, venga que conmigo no le va a pasar nada. Vámonos.	S , v     q   c       n  l  v  a p     n   . V      .
2569	25	My mom. No, I have to go get my mom.	Mi mamá. No, yo me tengo que ir por mi mamá.	M  m   . N , y  m  t     q   i  p   m  m   .
2570	25	Romina! I have to go get my mom.	¡Romina!  Me tengo que ir por mi mamá.	¡R     ! M  t     q   i  p   m  m   .
2571	25	No, no, we have to leave! Leo!	¡No, nos tenemos que ir!  ¡Leo!	¡N , n   t       q   i ! ¡L  !
2572	25	If they don't find me, they're going to kill my mom, right?	Si no me encuentran a mí, van a matar a mi mamá, ¿o no?	S  n  m  e          a m , v   a m     a m  m   , ¿o n ?
2573	25	Okay, alright. So let's go get your mom.	Okey, listo, listo. Entonces vamos por su mamá.	O   , l    , l    . E        v     p   s  m   .
2574	25	No, hold on. Hold on. Okay, okay. All good.	No, espérese. Espérese.  Sí, sí. Todo bien.	N , e       . E       . S , s . T    b   .
2575	25	What do we do? Um...	¿Qué hacemos?	¿Q   h      ?
2576	25	You told me it was after practice, right?	Usted me está diciendo que es después del entrenamiento.	U     m  e    d        q   e  d       d   e            .
2577	25	Yes. Alright.	Sí.  Listo.	S . L    .
2578	25	So we still have a few hours. So...	Para eso todavía tenemos un par de horas. Entonces…	P    e   t       t       u  p   d  h    . E
2579	25	I'll go get my mom by myself.	Yo… Yo me voy por mi mamá sola,	Y  Y  m  v   p   m  m    s   ,
2580	25	If they see us together, it'll be a disaster.	porque si me llegan a ver con usted, paila.	p      s  m  l      a v   c   u    , p    .
2581	25	They'll fuck us both up. You go on and act normal.	Ahí sí nos joden a los dos. Usted siga su día normal.	A   s  n   j     a l   d  . U     s    s  d   n     .
2582	25	No tickets, no problems, nothing.	Sin boleta, sin visaje, sin nada.	S   b     , s   v     , s   n   .
2583	25	I get my mom, my things, and I'll meet you outside the neighborhood.	Yo recojo a mi mamá, cojo mis cosas y nos vemos a la salida del barrio.	Y  r      a m  m   , c    m   c     y n   v     a l  s      d   b     .
2584	25	Alright. Okay. sounds good, sounds good. You've got this.	Hágale. Okey. Listo, todo bien, todo bien, todo bien. Ya sabe.	H     . O   . L    , t    b   , t    b   , t    b   . Y  s   .
2585	25	Nothing's gonna happen to you, I promise.	Conmigo no le va a pasar nada. Se lo juro.	C       n  l  v  a p     n   . S  l  j   .
2586	25	Not to you nor your mom, baby, I swear.	Ni a su mamá ni a usted, mi amor. Se lo juro.	N  a s  m    n  a u    , m  a   . S  l  j   .
2587	25	All good. Watch your back. Go on!	Todo bien. No dé papaya. Hágale.	T    b   . N  d  p     . H     .
2588	25	Watch your back.	No dé papaya.	N  d  p     .
2589	25	My dad paid that woman for her silence, Rubén.	Mi papá le pagó a esa mujer por su silencio, Rubén.	M  p    l  p    a e   m     p   s  s       , R    .
2590	25	Look. This...	Mire. Esta…	M   . E
2591	25	is the proof that this man is everything Romina and Yesenia believed to be true.	Esta es la prueba de que ese señor es todo lo que Romina y Yesenia creen de él.	E    e  l  p      d  q   e   s     e  t    l  q   R      y Y       c     d  é .
2592	25	Speak of the devil, look who's calling.	Hablando del rey de Roma, mire quién me está llamando.	H        d   r   d  R   , m    q     m  e    l       .
2593	25	Look. Hmm? Right on the dot.	Mire. ¿Ah? Las horas de llamar.	M   . ¿A ? L   h     d  l     .
2594	25	If I talk to him right now, I'll tell him everything.	Es que si yo hablo con él en este momento, le voy a contar todo.	E  q   s  y  h     c   é  e  e    m      , l  v   a c      t   .
2595	25	And I'm not going to give him the chance to cover things up	Y yo no le voy a dar el gusto de que él tenga el tiempo de tapar las cosas	Y y  n  l  v   a d   e  g     d  q   é  t     e  t      d  t     l   c
2596	25	like he always does, we know how he is.	como es su costumbre, como ya sabemos que él hace.	c    e  s  c        , c    y  s       q   é  h   .
2597	25	I'm not going to answer.	No le voy a contestar.	N  l  v   a c        .
2598	25	You stay over here.	Vos te vas a quedar acá.	V   t  v   a q      a  .
2599	25	I'll get your mom and get protection after you file the report.	Voy por tu mamá y pido protección luego de que den testimonio.	V   p   t  m    y p    p          l     d  q   d   t         .
2600	25	No. I didn't tell you to go and do this.	No. Yo no le conté para que se ponga a hacer esto.	N . Y  n  l  c     p    q   s  p     a h     e   .
2601	25	If I leave and run away,	Donde yo me vaya corriendo del barrio,	D     y  m  v    c         d   b     ,
2602	25	we lose our one real chance at catching Marlon.	perdemos la única oportunidad real de agarrar a Marlon.	p        l  ú     o           r    d  a       a M     .
2603	25	I know you want to be the bait,	A mí no me sorprende que se quiera poner como carnada,	A m  n  m  s         q   s  q      p     c    c      ,
2605	25	Yes, it will.	Eso va a pasar.	E   v  a p    .
2606	25	I don't want anything to happen to you. I'm going to be fine.	No quiero que le pase nada.  A mí no me va a pasar nada malo.	N  q      q   l  p    n   . A m  n  m  v  a p     n    m   .
2607	25	You know that this is our chance to finally get rid of those guys.	Usted sabe que esta es la oportunidad para librarnos de esos manes.	U     s    q   e    e  l  o           p    l         d  e    m    .
2608	25	Do you understand how dangerous this is? Of course.	¿Es consciente de lo peligroso que es esto? Claro. 	¿E  c          d  l  p         q   e  e   ? C    .
2609	25	We both know that there are times where you have to risk it all to win big.	Y los dos sabemos que hay momentos en la vida en que uno debe arriesgar todo si quiere ganar algo grande.	Y l   d   s       q   h   m        e  l  v    e  q   u   d    a         t    s  q      g     a    g     .
2610	25	And this is one of those.	Y ese momento es este.	Y e   m       e  e   .
2611	25	But you know what?	Pero ¿sabe?	P    ¿s   ?
2612	25	I'm very calm.	Yo estoy muy tranquila.	Y  e     m   t        .
2613	25	Because I know the best police sergeant will be taking care of me.	Porque a mí me va a estar cuidando el mejor sargento de la policía.	P      a m  m  v  a e     c        e  m     s        d  l  p      .
2614	25	I truly believe in you.	Yo confío tanto en usted.	Y  c      t     e  u    .
2615	25	Believe in me.	Confíe en mí.	C      e  m .
2616	25	You have to keep up your usual routine. That way, they won't suspect a thing.	Para que los Chitiva no sospechen absolutamente nada, usted debe seguir con su vida normal. 	P    q   l   C       n  s         a             n   , u     d    s      c   s  v    n     .
2617	25	Go to practice	Se va a su entrenamiento	S  v  a s  e
2618	25	and then the juice stand, like always.	y después al puesto de jugos como siempre.	y d       a  p      d  j     c    s      .
2619	25	Are we clear? Clear, Sergeant.	¿Estamos?  Estamos, señor sargento.	¿E      ? E      , s     s       .
2620	25	Smile for me.	Cámbieme esa cara.	C        e   c   .
2621	25	Everything's gonna be okay. I promise.	Todo va a salir bien. Se lo prometo.	T    v  a s     b   . S  l  p      .
2622	25	I know everything's gonna be okay.	Yo sé que todo va a salir bien.	Y  s  q   t    v  a s     b   .
2623	25	I'll be there to watch over you, okay? I know.	Yo voy a estar ahí para cuidarla, ¿oyó?  Yo sé.	Y  v   a e     a   p    c       , ¿o  ? Y  s .
2624	25	I know.	Yo sé.	Y  s .
2625	25	Where are we going, huh?	¿Para dónde nos vamos, ah?	¿P    d     n   v    , a ?
2626	25	With whose money? With whose permission?	¿Con plata de quién y con permiso de quién?	¿C   p     d  q     y c   p       d  q    ?
2627	25	I'm going to go with Estiven and his friends. Why?	Me voy un par de días con el parche de Estiven. ¿Por qué?	M  v   u  p   d  d    c   e  p      d  E      . ¿P   q  ?
2628	25	Nuche saw you talking with Romina. So?	Nuche lo vio hablando con Romina.  ¿Y?	N     l  v   h        c   R     . ¿Y?
2629	25	Now I have to ask for permission to talk to someone?	¿Ahora le tengo que pedir permiso para hablar con alguien?	¿A     l  t     q   p     p       p    h      c   a      ?
2630	25	What did you blab about? About what? What's going on?	¿Qué le dijo a esa bocona?  ¿Qué le dije de qué? ¿Qué le pasa?	¿Q   l  d    a e   b     ? ¿Q   l  d    d  q  ? ¿Q   l  p   ?
2631	25	I already told you, you rat!	¡Yo se las canté, pirobo!	¡Y  s  l   c    , p     !
2632	25	I told you if you betrayed this family, she'd be the one who pays.	Le dije que si traicionaba a la familia, la que iba a salir perdiendo era ella.	L  d    q   s  t           a l  f      , l  q   i   a s     p         e   e   .
2633	25	Be thankful you're my brother, otherwise you'd already be dead.	Agradezca que es de mi misma sangre. Si no, ya estaría muerto.	A         q   e  d  m  m     s     . S  n , y  e       m     .
2634	25	Relax, Marlon. Like Romina's about to be.	Cálmese, Marlon.  Como lo va a estar Romina.	C      , M     . C    l  v  a e     R     .
2635	25	Marlon, no, no. Leave Romina alone.	Marlon, no, no. No se meta con ella.	M     , n , n . N  s  m    c   e   .
2636	25	Please, Marlon, come on. Leave Romina alone.	Por favor, Marlon, venga. No se meta con Romina. Venga,	P   f    , M     , v    . N  s  m    c   R     . V    ,
2637	25	She's gonna leave. Don't mess with her. Come on! Marlon! Marlon!	ella se va a ir. No se meta con ella. ¡Venga, Marlon! ¡Venga, Marlon! ¡Marlon!	e    s  v  a i . N  s  m    c   e   . ¡V    , M     ! ¡V    , M     ! ¡M     !
2638	25	Leave her alone! Come on, Marlon!	No se meta con ella. ¡Venga, Marlon!	N  s  m    c   e   . ¡V    , M     !
2639	25	Marlon! Quit yelling, stop fucking it up.	¡Marlon!   Deje de ladrar. No la cague más.	¡M     ! D    d  l     . N  l  c     m  .
2640	25	Marlon. Marlon, wait. What do you want?	Marlon. Marlon, espere.  ¿Qué quiere?	M     . M     , e     . ¿Q   q     ?
2641	25	Look. If Leo found out what we were gonna do and he told her,	Mire. Si Leo se enteró de lo que vamos a hacer y le contó a esa peladita,	M   . S  L   s  e      d  l  q   v     a h     y l  c     a e   p       ,
2642	25	he's fucked it all up.	se nos jode todo.	s  n   j    t   .
2643	25	We're not gonna waste any more time. It's the perfect time.	No le vamos a dar más largas. Esa vuelta ya está cuadrada.	N  l  v     a d   m   l     . E   v      y  e    c       .
2644	25	So, what? Is it still on?	¿Y entonces qué, la seguimos?	¿Y e        q  , l  s       ?
2645	25	It's the best time to catch them for attempted homicide.	Es la oportunidad perfecta para cogerlos por intento de homicidio.	E  l  o           p        p    c        p   i       d  h        .
2646	25	Yes, but we are risking a civilian's life.	Sí, pero estamos arriesgando la vida de un civil.	S , p    e       a           l  v    d  u  c    .
2647	25	We'll have multiple officers nearby.	Por eso habrá varios efectivos en la zona.	P   e   h     v      e         e  l  z   .
2648	25	I'll be in charge of the operation.	Yo mismo voy a estar a la cabeza del operativo.	Y  m     v   a e     a l  c      d   o        .
2649	25	I promise I won't let anything bad happen to Romina Páez.	Le aseguro que no voy a dejar que nada malo le pase a Romina Páez.	L  a       q   n  v   a d     q   n    m    l  p    a R      P   .
2650	25	We're talking about capturing Marlon Chitiva,	Estamos hablando de capturar a Marlon Chitiva,	E       h        d  c        a M      C      ,
2651	25	the head of the Mafia.	la cabeza de la mafia del grifo.	l  c      d  l  m     d   g    .
2652	25	Do you know something, Sergeant? If this goes south, your career is over.	¿Es consciente de una cosa, sargento? Si esto sale mal, se acaba su carrera.	¿E  c          d  u   c   , s       ? S  e    s    m  , s  a     s  c      .
2653	25	And the civilian could lose her life. 	Y podría perder la vida la civil.	Y p      p      l  v    l  c    .
2654	25	That's why it won't go south.	Y por eso, nada va a salir mal.	Y p   e  , n    v  a s     m  .
2655	25	There is no room for error, sir.	No hay margen de error, mi mayor.	N  h   m      d  e    , m  m    .
2656	25	I need you all focused.	Los necesito enfocados,	L   n        e        ,
2657	25	Remember what we talked about and be ready for anything.	recordando lo que hablamos y atentos a cualquier movimiento.	r          l  q   h        y a       a c         m         .
2658	25	Safety off on the guns, okay?	El arma sin seguro, ¿estamos?	E  a    s   s     , ¿e      ?
2659	25	Yes, sir, Sergeant! Forward!	Como ordene, mi sargento.  ¡Mar!	C    o     , m  s       . ¡M  !
2660	25	I'm really sorry. This must be very hard for you, right?	Lo siento mucho. Esto para usted debe ser bien duro, ¿verdad?	L  s      m    . E    p    u     d    s   b    d   , ¿v     ?
2661	25	Deep down you wanted to believe your dad had nothing to do with it.	Sé que en el fondo quería creer que su papá no tenía nada que ver.	S  q   e  e  f     q      c     q   s  p    n  t     n    q   v  .
2662	25	But like Romi said, we can't bury our heads in the sand.	Pero como dice Romi, tampoco podemos tapar el sol con un dedo.	P    c    d    R   , t       p       t     e  s   c   u  d   .
2663	25	And with this, my dad can't deny anything.	Y con esto, mi papá no me puede negar nada.	Y c   e   , m  p    n  m  p     n     n   .
2664	25	Romi will be very happy to see this.	Romi se pondrá muy contenta al ver esto.	R    s  p      m   c        a  v   e   .
2665	25	Oh, yes, but she's at practice right now.	Ay, sí, pero ahora está entrenando.	A , s , p    a     e    e         .
2666	25	Do you want to show her later?	¿Quiere que se lo mostremos más tarde?	¿Q      q   s  l  m         m   t    ?
2667	25	I... No, honey, don't bother.	Yo…  No, mi amor, ni se moleste.	Y  N , m  a   , n  s  m      .
2668	25	She turns it off during practice. She won't answer.	Cuando entrena, lo apaga. No le va a contestar.	C      e      , l  a    . N  l  v  a c        .
2669	25	And if we go to the park?	¿Y si vamos al parque?	¿Y s  v     a  p     ?
2670	25	Want to see your sister at practice?	¿Quiere ver a su hermana entrenando?	¿Q      v   a s  h       e         ?
2671	25	Yes, I'll take you. She'll feel so proud.	Sí, la llevo. Se va a sentir más orgullosa.	S , l  l    . S  v  a s      m   o        .
2672	25	And we'll show her then. Yes, of course.	Y le mostramos eso de una vez.  Claro, de una vez.	Y l  m         e   d  u   v  . C    , d  u   v  .
2673	25	I'll take it. Alright.	Me lo llevo en la mano.  Bueno.	M  l  l     e  l  m   . B    .
2674	25	Let's go, then.	Vamos pues.	V     p   .
2675	25	Boss, I just saw Romina pass by the bridge.	Jefe, acabo de ver a Romina pasar por el puente del perro.	J   , a     d  v   a R      p     p   e  p      d   p    .
2676	25	She's with her mom.	Está con la mamá.	E    c   l  m   .
2677	25	The idiot didn't go to practice. They're going to Fourth Street.	Esa piroba no fue a entrenar. Van para la cuarta.	E   p      n  f   a e       . V   p    l  c     .
2678	25	Change of plans. Tell me.	Cambio de planes.   Diga.	C      d  p     . D   .
2679	25	Tell Carloncho we're heading to Fourth Street now.	Dígale a Carloncho que la vuelta ahora es en la cuarta.	D      a C         q   l  v      a     e  e  l  c     .
2680	25	Hurry up.	 \\Apúrele.	\\       .
2681	25	Hello, Carloncho, what's up?	Aló. ¿Quiubo, Carloncho?	A  . ¿Q     , C        ?
2682	25	Marmolejo, copy?	Marmolejo, ¿me copia?	M        , ¿m  c    ?
2683	25	Any updates?	¿Alguna novedad?	¿A      n      ?
2684	25	Nothing, Sergeant.	Sin novedad, mi sargento.	S   n      , m  s       .
2685	25	The practice area is right here. We're really close.	La zona de entrenamiento es aquí nomás. Ya estamos bien cerquita.	L  z    d  e             e  a    n    . Y  e       b    c       .
2686	25	Romina is going to be so happy when she sees you here.	La Romina se va a poner tan contenta cuando la vea llegar.	L  R      s  v  a p     t   c        c      l  v   l     .
2687	25	Station, we need reinforcements. There's a car accident.	Central, manden refuerzos acá. Hay un siniestro de carro.	C      , m      r         a  . H   u  s         d  c    .
2688	25	Hey, help me clear the area! Clear the area!	Ey, ayúdenme a despejar la zona. ¡Despéjenme la zona!	E , a        a d        l  z   . ¡D          l  z   !
2689	25	Clear the area!	¡Despejen la zona!	¡D        l  z   !
2690	25	Valencia, clear the area!	Valencia, ¡despéjeme la zona!	V       , ¡d         l  z   !
2691	25	Out of the way!	Señores, ¡pilas!	S      , ¡p    !
2692	25	Clear the area, there may be another explosion!	¡Despejen la zona que esto puede volver a explotar!	¡D        l  z    q   e    p     v      a e       !
2693	25	Get out of here, it might explode again!	¡Fuera, que esto puede volver a explotar!	¡F    , q   e    p     v      a e       !
2694	25	Everyone back off! Back off, please. Everyone back off.	Todos para atrás, para atrás, para atrás, por favor. Háganse todos para atrás.	T     p    a    , p    a    , p    a    , p   f    . H       t     p    a    .
2695	25	Help! Please!	¡Afuera, por favor! ¡Afuera!	¡A     , p   f    ! ¡A     !
2696	25	We need to get everyone out.	Hay que retirar a la gente.	H   q   r       a l  g    .
2697	25	Get back, get back, get back! Get back!	¡Atrás, atrás, atrás, atrás!	¡A    , a    , a    , a    !
2698	25	Get back! Ambulance!	¡Atrás, ambulancia!	¡A    , a         !
2699	25	Station, where's the ambulance and firefighters?	Central, ¿qué pasó con la ambulancia y los bomberos?	C      , ¿q   p    c   l  a          y l   b       ?
2700	25	Get everyone out of here!	¡Saquen a la gente!	¡S      a l  g    !
2701	25	Get everyone out of here! Go!	¡Saquen a la gente! ¡Caminen!	¡S      a l  g    ! ¡C      !
2702	25	Stop, bro. Where are you going?	Quieto, hermano. ¿Adónde vas?	Q     , h      . ¿A      v  ?
2703	25	Stop! Stop! No!	¡Quieto! ¡Quieto!  ¡No!	¡Q     ! ¡Q     ! ¡N !
2704	25	Don't die on me. No, Romina, please.	No se me muera. No, por favor, Romina.	N  s  m  m    . N , p   f    , R     .
2705	25	That's it, breathe, please. Please breathe, Romina.	Así, respire, por favor. Respire, por favor, Romina.	A  , r      , p   f    . R      , p   f    , R     .
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: testdb
--

COPY public.schema_migrations (version, dirty) FROM stdin;
8	f
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: testdb
--

COPY public.sessions (token, data, expiry) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: testdb
--

COPY public.users (id, movie_id, name, email, hashed_password, created, language_id) FROM stdin;
24	-1	user2	user2@email.com	\\x2432612431322445396a71444c59364b5173736e616130536757572f754367383872534367776c314f626b443550365142313958436b476754325836	2023-11-14 08:21:57-08	2
23	1	user1	user1@email.com	\\x243261243132246d796679615276486e73457138724e647332727a454f59586c464764393755386f486f57336d2e31696b5135326446344e73666d57	2023-11-14 08:13:52-08	1
\.


--
-- Data for Name: users_phrases; Type: TABLE DATA; Schema: public; Owner: testdb
--

COPY public.users_phrases (user_id, phrase_id, movie_id, correct) FROM stdin;
23	2093	25	0
23	2094	25	0
23	2095	25	0
23	2096	25	0
23	2097	25	0
23	2098	25	0
23	2099	25	0
23	2100	25	0
23	2101	25	0
23	2102	25	0
23	2103	25	0
23	2104	25	0
23	2105	25	0
23	2106	25	0
23	2107	25	0
23	2108	25	0
23	2109	25	0
23	2110	25	0
23	2111	25	0
23	2112	25	0
23	2113	25	0
23	2114	25	0
23	2115	25	0
23	2116	25	0
23	2117	25	0
23	2118	25	0
23	2119	25	0
23	2120	25	0
23	2121	25	0
23	2122	25	0
23	2123	25	0
23	2124	25	0
23	2125	25	0
23	2126	25	0
23	2127	25	0
23	2128	25	0
23	2129	25	0
23	2130	25	0
23	2131	25	0
23	2132	25	0
23	2133	25	0
23	2134	25	0
23	2135	25	0
23	2136	25	0
23	2137	25	0
23	2138	25	0
23	2139	25	0
23	2140	25	0
23	2141	25	0
23	2142	25	0
23	2143	25	0
23	2144	25	0
23	2145	25	0
23	2146	25	0
23	2147	25	0
23	2148	25	0
23	2149	25	0
23	2150	25	0
23	2151	25	0
23	2152	25	0
23	2153	25	0
23	2154	25	0
23	2155	25	0
23	2156	25	0
23	2157	25	0
23	2158	25	0
23	2159	25	0
23	2160	25	0
23	2161	25	0
23	2162	25	0
23	2163	25	0
23	2164	25	0
23	2165	25	0
23	2166	25	0
23	2167	25	0
23	2168	25	0
23	2169	25	0
23	2170	25	0
23	2171	25	0
23	2172	25	0
23	2173	25	0
23	2174	25	0
23	2175	25	0
23	2176	25	0
23	2177	25	0
23	2178	25	0
23	2179	25	0
23	2180	25	0
23	2181	25	0
23	2182	25	0
23	2183	25	0
23	2184	25	0
23	2185	25	0
23	2186	25	0
23	2187	25	0
23	2188	25	0
23	2189	25	0
23	2190	25	0
23	2191	25	0
23	2192	25	0
23	2193	25	0
23	2194	25	0
23	2195	25	0
23	2196	25	0
23	2197	25	0
23	2198	25	0
23	2199	25	0
23	2200	25	0
23	2201	25	0
23	2202	25	0
23	2203	25	0
23	2204	25	0
23	2205	25	0
23	2206	25	0
23	2207	25	0
23	2208	25	0
23	2209	25	0
23	2210	25	0
23	2211	25	0
23	2212	25	0
23	2213	25	0
23	2214	25	0
23	2215	25	0
23	2216	25	0
23	2217	25	0
23	2218	25	0
23	2219	25	0
23	2220	25	0
23	2221	25	0
23	2222	25	0
23	2223	25	0
23	2224	25	0
23	2225	25	0
23	2226	25	0
23	2227	25	0
23	2228	25	0
23	2229	25	0
23	2230	25	0
23	2231	25	0
23	2232	25	0
23	2233	25	0
23	2234	25	0
23	2235	25	0
23	2236	25	0
23	2237	25	0
23	2238	25	0
23	2239	25	0
23	2240	25	0
23	2241	25	0
23	2242	25	0
23	2243	25	0
23	2244	25	0
23	2245	25	0
23	2246	25	0
23	2247	25	0
23	2248	25	0
23	2249	25	0
23	2250	25	0
23	2251	25	0
23	2252	25	0
23	2253	25	0
23	2254	25	0
23	2255	25	0
23	2256	25	0
23	2257	25	0
23	2258	25	0
23	2259	25	0
23	2260	25	0
23	2261	25	0
23	2262	25	0
23	2263	25	0
23	2264	25	0
23	2265	25	0
23	2266	25	0
23	2267	25	0
23	2268	25	0
23	2269	25	0
23	2270	25	0
23	2271	25	0
23	2272	25	0
23	2273	25	0
23	2274	25	0
23	2275	25	0
23	2276	25	0
23	2277	25	0
23	2278	25	0
23	2279	25	0
23	2280	25	0
23	2281	25	0
23	2282	25	0
23	2283	25	0
23	2284	25	0
23	2285	25	0
23	2286	25	0
23	2287	25	0
23	2288	25	0
23	2289	25	0
23	2290	25	0
23	2291	25	0
23	2292	25	0
23	2293	25	0
23	2294	25	0
23	2295	25	0
23	2296	25	0
23	2297	25	0
23	2298	25	0
23	2299	25	0
23	2300	25	0
23	2301	25	0
23	2302	25	0
23	2303	25	0
23	2304	25	0
23	2305	25	0
23	2306	25	0
23	2307	25	0
23	2308	25	0
23	2309	25	0
23	2310	25	0
23	2311	25	0
23	2312	25	0
23	2313	25	0
23	2314	25	0
23	2315	25	0
23	2316	25	0
23	2317	25	0
23	2318	25	0
23	2319	25	0
23	2320	25	0
23	2321	25	0
23	2322	25	0
23	2081	25	0
23	2082	25	0
23	2083	25	0
23	2084	25	0
23	2418	25	0
23	2085	25	0
23	2086	25	0
23	2087	25	0
23	2088	25	0
23	2089	25	0
23	2090	25	0
23	2091	25	0
23	2092	25	0
23	2323	25	0
23	2324	25	0
23	2325	25	0
23	2326	25	0
23	2327	25	0
23	2328	25	0
23	2329	25	0
23	2330	25	0
23	2331	25	0
23	2332	25	0
23	2333	25	0
23	2334	25	0
23	2335	25	0
23	2336	25	0
23	2337	25	0
23	2338	25	0
23	2339	25	0
23	2340	25	0
23	2341	25	0
23	2342	25	0
23	2343	25	0
23	2344	25	0
23	2345	25	0
23	2346	25	0
23	2347	25	0
23	2348	25	0
23	2349	25	0
23	2350	25	0
23	2351	25	0
23	2352	25	0
23	2353	25	0
23	2354	25	0
23	2355	25	0
23	2356	25	0
23	2357	25	0
23	2358	25	0
23	2359	25	0
23	2360	25	0
23	2361	25	0
23	2362	25	0
23	2363	25	0
23	2364	25	0
23	2365	25	0
23	2366	25	0
23	2367	25	0
23	2368	25	0
23	2369	25	0
23	2370	25	0
23	2371	25	0
23	2372	25	0
23	2373	25	0
23	2374	25	0
23	2375	25	0
23	2376	25	0
23	2377	25	0
23	2378	25	0
23	2379	25	0
23	2380	25	0
23	2381	25	0
23	2382	25	0
23	2383	25	0
23	2384	25	0
23	2385	25	0
23	2386	25	0
23	2387	25	0
23	2388	25	0
23	2389	25	0
23	2390	25	0
23	2391	25	0
23	2392	25	0
23	2393	25	0
23	2394	25	0
23	2395	25	0
23	2396	25	0
23	2397	25	0
23	2398	25	0
23	2399	25	0
23	2400	25	0
23	2401	25	0
23	2402	25	0
23	2403	25	0
23	2404	25	0
23	2405	25	0
23	2406	25	0
23	2407	25	0
23	2408	25	0
23	2409	25	0
23	2410	25	0
23	2411	25	0
23	2412	25	0
23	2413	25	0
23	2414	25	0
23	2415	25	0
23	2416	25	0
23	2417	25	0
23	2419	25	0
23	2420	25	0
23	2421	25	0
23	2422	25	0
23	2423	25	0
23	2424	25	0
23	2425	25	0
23	2426	25	0
23	2427	25	0
23	2428	25	0
23	2429	25	0
23	2430	25	0
23	2431	25	0
23	2432	25	0
23	2433	25	0
23	2434	25	0
23	2435	25	0
23	2436	25	0
23	2437	25	0
23	2438	25	0
23	2439	25	0
23	2440	25	0
23	2441	25	0
23	2442	25	0
23	2443	25	0
23	2444	25	0
23	2445	25	0
23	2446	25	0
23	2447	25	0
23	2448	25	0
23	2449	25	0
23	2450	25	0
23	2451	25	0
23	2452	25	0
23	2453	25	0
23	2454	25	0
23	2455	25	0
23	2456	25	0
23	2457	25	0
23	2458	25	0
23	2459	25	0
23	2460	25	0
23	2461	25	0
23	2462	25	0
23	2463	25	0
23	2464	25	0
23	2465	25	0
23	2466	25	0
23	2467	25	0
23	2468	25	0
23	2469	25	0
23	2470	25	0
23	2471	25	0
23	2472	25	0
23	2473	25	0
23	2474	25	0
23	2475	25	0
23	2476	25	0
23	2477	25	0
23	2478	25	0
23	2479	25	0
23	2480	25	0
23	2481	25	0
23	2482	25	0
23	2483	25	0
23	2484	25	0
23	2485	25	0
23	2486	25	0
23	2487	25	0
23	2488	25	0
23	2489	25	0
23	2490	25	0
23	2491	25	0
23	2492	25	0
23	2493	25	0
23	2494	25	0
23	2495	25	0
23	2496	25	0
23	2497	25	0
23	2498	25	0
23	2499	25	0
23	2500	25	0
23	2501	25	0
23	2502	25	0
23	2503	25	0
23	2504	25	0
23	2505	25	0
23	2506	25	0
23	2507	25	0
23	2508	25	0
23	2509	25	0
23	2510	25	0
23	2511	25	0
23	2512	25	0
23	2604	25	0
23	2513	25	0
23	2514	25	0
23	2515	25	0
23	2516	25	0
23	2517	25	0
23	2518	25	0
23	2519	25	0
23	2520	25	0
23	2521	25	0
23	2522	25	0
23	2523	25	0
23	2524	25	0
23	2525	25	0
23	2526	25	0
23	2527	25	0
23	2528	25	0
23	2529	25	0
23	2530	25	0
23	2531	25	0
23	2532	25	0
23	2533	25	0
23	2534	25	0
23	2535	25	0
23	2536	25	0
23	2537	25	0
23	2538	25	0
23	2539	25	0
23	2540	25	0
23	2541	25	0
23	2542	25	0
23	2543	25	0
23	2544	25	0
23	2545	25	0
23	2546	25	0
23	2547	25	0
23	2548	25	0
23	2549	25	0
23	2550	25	0
23	2551	25	0
23	2552	25	0
23	2553	25	0
23	2554	25	0
23	2555	25	0
23	2556	25	0
23	2557	25	0
23	2558	25	0
23	2559	25	0
23	2560	25	0
23	2561	25	0
23	2562	25	0
23	2563	25	0
23	2564	25	0
23	2565	25	0
23	2566	25	0
23	2567	25	0
23	2568	25	0
23	2569	25	0
23	2570	25	0
23	2571	25	0
23	2572	25	0
23	2573	25	0
23	2574	25	0
23	2575	25	0
23	2576	25	0
23	2577	25	0
23	2578	25	0
23	2579	25	0
23	2580	25	0
23	2581	25	0
23	2582	25	0
23	2583	25	0
23	2584	25	0
23	2585	25	0
23	2586	25	0
23	2587	25	0
23	2588	25	0
23	2589	25	0
23	2590	25	0
23	2591	25	0
23	2592	25	0
23	2593	25	0
23	2594	25	0
23	2595	25	0
23	2596	25	0
23	2597	25	0
23	2598	25	0
23	2599	25	0
23	2600	25	0
23	2601	25	0
23	2602	25	0
23	2603	25	0
23	2605	25	0
23	2606	25	0
23	2607	25	0
23	2608	25	0
23	2609	25	0
23	2610	25	0
23	2611	25	0
23	2612	25	0
23	2613	25	0
23	2614	25	0
23	2615	25	0
23	2616	25	0
23	2617	25	0
23	2618	25	0
23	2619	25	0
23	2620	25	0
23	2621	25	0
23	2622	25	0
23	2623	25	0
23	2624	25	0
23	2625	25	0
23	2626	25	0
23	2627	25	0
23	2628	25	0
23	2629	25	0
23	2630	25	0
23	2631	25	0
23	2632	25	0
23	2633	25	0
23	2634	25	0
23	2635	25	0
23	2636	25	0
23	2637	25	0
23	2638	25	0
23	2639	25	0
23	2640	25	0
23	2641	25	0
23	2642	25	0
23	2643	25	0
23	2644	25	0
23	2645	25	0
23	2646	25	0
23	2647	25	0
23	2648	25	0
23	2649	25	0
23	2650	25	0
23	2651	25	0
23	2652	25	0
23	2653	25	0
23	2654	25	0
23	2655	25	0
23	2656	25	0
23	2657	25	0
23	2658	25	0
23	2659	25	0
23	2660	25	0
23	2661	25	0
23	2662	25	0
23	2663	25	0
23	2664	25	0
23	2665	25	0
23	2666	25	0
23	2667	25	0
23	2668	25	0
23	2669	25	0
23	2670	25	0
23	2671	25	0
23	2672	25	0
23	2673	25	0
23	2674	25	0
23	2675	25	0
23	2676	25	0
23	2677	25	0
23	2678	25	0
23	2679	25	0
23	2680	25	0
23	2681	25	0
23	2682	25	0
23	2683	25	0
23	2684	25	0
23	2685	25	0
23	2686	25	0
23	2687	25	0
23	2688	25	0
23	2689	25	0
23	2690	25	0
23	2691	25	0
23	2692	25	0
23	2693	25	0
23	2694	25	0
23	2695	25	0
23	2696	25	0
23	2697	25	0
23	2698	25	0
23	2699	25	0
23	2700	25	0
23	2701	25	0
23	2702	25	0
23	2703	25	0
23	2704	25	0
23	2705	25	0
23	2	1	0
23	3	1	0
23	4	1	0
23	5	1	0
23	6	1	0
23	7	1	0
23	8	1	0
23	9	1	0
23	10	1	0
23	11	1	0
23	12	1	0
23	13	1	0
23	14	1	0
23	15	1	0
23	16	1	0
23	17	1	0
23	18	1	0
23	19	1	0
23	20	1	0
23	21	1	0
23	22	1	0
23	23	1	0
23	24	1	0
23	25	1	0
23	26	1	0
23	27	1	0
23	28	1	0
23	29	1	0
23	30	1	0
23	31	1	0
23	32	1	0
23	33	1	0
23	34	1	0
23	35	1	0
23	36	1	0
23	37	1	0
23	38	1	0
23	39	1	0
23	40	1	0
23	41	1	0
23	42	1	0
23	43	1	0
23	44	1	0
23	45	1	0
23	46	1	0
23	47	1	0
23	48	1	0
23	49	1	0
23	50	1	0
23	51	1	0
23	52	1	0
23	53	1	0
23	54	1	0
23	55	1	0
23	56	1	0
23	57	1	0
23	58	1	0
23	59	1	0
23	60	1	0
23	61	1	0
23	62	1	0
23	63	1	0
23	64	1	0
23	65	1	0
23	66	1	0
23	67	1	0
23	68	1	0
23	69	1	0
23	70	1	0
23	71	1	0
23	72	1	0
23	73	1	0
23	74	1	0
23	75	1	0
23	76	1	0
23	77	1	0
23	78	1	0
23	79	1	0
23	80	1	0
23	81	1	0
23	82	1	0
23	83	1	0
23	84	1	0
23	85	1	0
23	86	1	0
23	87	1	0
23	88	1	0
23	89	1	0
23	90	1	0
23	91	1	0
23	92	1	0
23	93	1	0
23	94	1	0
23	95	1	0
23	96	1	0
23	97	1	0
23	98	1	0
23	99	1	0
23	100	1	0
23	101	1	0
23	102	1	0
23	103	1	0
23	104	1	0
23	105	1	0
23	106	1	0
23	107	1	0
23	108	1	0
23	109	1	0
23	110	1	0
23	111	1	0
23	112	1	0
23	113	1	0
23	114	1	0
23	115	1	0
23	116	1	0
23	117	1	0
23	118	1	0
23	119	1	0
23	120	1	0
23	121	1	0
23	122	1	0
23	123	1	0
23	124	1	0
23	125	1	0
23	126	1	0
23	127	1	0
23	128	1	0
23	129	1	0
23	130	1	0
23	131	1	0
23	132	1	0
23	133	1	0
23	134	1	0
23	135	1	0
23	136	1	0
23	137	1	0
23	138	1	0
23	139	1	0
23	140	1	0
23	141	1	0
23	142	1	0
23	143	1	0
23	144	1	0
23	145	1	0
23	146	1	0
23	147	1	0
23	148	1	0
23	149	1	0
23	150	1	0
23	151	1	0
23	152	1	0
23	153	1	0
23	154	1	0
23	155	1	0
23	156	1	0
23	157	1	0
23	158	1	0
23	159	1	0
23	160	1	0
23	161	1	0
23	162	1	0
23	163	1	0
23	164	1	0
23	165	1	0
23	166	1	0
23	167	1	0
23	168	1	0
23	478	1	0
23	169	1	0
23	170	1	0
23	171	1	0
23	172	1	0
23	173	1	0
23	174	1	0
23	175	1	0
23	176	1	0
23	177	1	0
23	178	1	0
23	179	1	0
23	180	1	0
23	181	1	0
23	182	1	0
23	183	1	0
23	184	1	0
23	185	1	0
23	186	1	0
23	187	1	0
23	188	1	0
23	189	1	0
23	190	1	0
23	191	1	0
23	192	1	0
23	193	1	0
23	194	1	0
23	195	1	0
23	196	1	0
23	197	1	0
23	198	1	0
23	199	1	0
23	200	1	0
23	201	1	0
23	202	1	0
23	203	1	0
23	204	1	0
23	205	1	0
23	206	1	0
23	207	1	0
23	208	1	0
23	209	1	0
23	210	1	0
23	211	1	0
23	212	1	0
23	213	1	0
23	214	1	0
23	215	1	0
23	216	1	0
23	217	1	0
23	218	1	0
23	219	1	0
23	220	1	0
23	221	1	0
23	222	1	0
23	223	1	0
23	224	1	0
23	225	1	0
23	226	1	0
23	227	1	0
23	228	1	0
23	229	1	0
23	230	1	0
23	231	1	0
23	232	1	0
23	233	1	0
23	234	1	0
23	235	1	0
23	236	1	0
23	237	1	0
23	238	1	0
23	239	1	0
23	240	1	0
23	241	1	0
23	242	1	0
23	243	1	0
23	244	1	0
23	245	1	0
23	246	1	0
23	247	1	0
23	248	1	0
23	249	1	0
23	250	1	0
23	251	1	0
23	252	1	0
23	253	1	0
23	254	1	0
23	255	1	0
23	256	1	0
23	257	1	0
23	258	1	0
23	259	1	0
23	260	1	0
23	261	1	0
23	262	1	0
23	263	1	0
23	264	1	0
23	265	1	0
23	266	1	0
23	267	1	0
23	268	1	0
23	269	1	0
23	270	1	0
23	271	1	0
23	272	1	0
23	273	1	0
23	274	1	0
23	275	1	0
23	276	1	0
23	277	1	0
23	278	1	0
23	279	1	0
23	280	1	0
23	281	1	0
23	282	1	0
23	283	1	0
23	284	1	0
23	285	1	0
23	286	1	0
23	287	1	0
23	288	1	0
23	289	1	0
23	290	1	0
23	291	1	0
23	292	1	0
23	293	1	0
23	294	1	0
23	295	1	0
23	296	1	0
23	297	1	0
23	298	1	0
23	299	1	0
23	300	1	0
23	301	1	0
23	302	1	0
23	303	1	0
23	304	1	0
23	305	1	0
23	306	1	0
23	307	1	0
23	308	1	0
23	309	1	0
23	310	1	0
23	311	1	0
23	312	1	0
23	313	1	0
23	314	1	0
23	315	1	0
23	316	1	0
23	317	1	0
23	318	1	0
23	319	1	0
23	320	1	0
23	321	1	0
23	322	1	0
23	323	1	0
23	324	1	0
23	325	1	0
23	326	1	0
23	327	1	0
23	328	1	0
23	329	1	0
23	330	1	0
23	331	1	0
23	332	1	0
23	333	1	0
23	334	1	0
23	335	1	0
23	336	1	0
23	337	1	0
23	338	1	0
23	339	1	0
23	340	1	0
23	341	1	0
23	342	1	0
23	343	1	0
23	344	1	0
23	345	1	0
23	346	1	0
23	347	1	0
23	348	1	0
23	349	1	0
23	350	1	0
23	351	1	0
23	352	1	0
23	353	1	0
23	354	1	0
23	355	1	0
23	356	1	0
23	357	1	0
23	358	1	0
23	359	1	0
23	360	1	0
23	361	1	0
23	362	1	0
23	363	1	0
23	364	1	0
23	365	1	0
23	366	1	0
23	367	1	0
23	368	1	0
23	369	1	0
23	370	1	0
23	371	1	0
23	372	1	0
23	373	1	0
23	374	1	0
23	375	1	0
23	376	1	0
23	377	1	0
23	378	1	0
23	379	1	0
23	380	1	0
23	381	1	0
23	382	1	0
23	383	1	0
23	384	1	0
23	385	1	0
23	386	1	0
23	387	1	0
23	388	1	0
23	389	1	0
23	390	1	0
23	391	1	0
23	392	1	0
23	393	1	0
23	394	1	0
23	395	1	0
23	396	1	0
23	397	1	0
23	398	1	0
23	399	1	0
23	400	1	0
23	401	1	0
23	402	1	0
23	403	1	0
23	404	1	0
23	405	1	0
23	406	1	0
23	407	1	0
23	408	1	0
23	409	1	0
23	410	1	0
23	411	1	0
23	412	1	0
23	413	1	0
23	414	1	0
23	415	1	0
23	416	1	0
23	417	1	0
23	418	1	0
23	419	1	0
23	420	1	0
23	421	1	0
23	422	1	0
23	423	1	0
23	424	1	0
23	425	1	0
23	426	1	0
23	427	1	0
23	428	1	0
23	429	1	0
23	430	1	0
23	431	1	0
23	432	1	0
23	433	1	0
23	434	1	0
23	435	1	0
23	436	1	0
23	437	1	0
23	438	1	0
23	439	1	0
23	440	1	0
23	441	1	0
23	442	1	0
23	443	1	0
23	444	1	0
23	445	1	0
23	446	1	0
23	447	1	0
23	448	1	0
23	449	1	0
23	450	1	0
23	451	1	0
23	452	1	0
23	453	1	0
23	454	1	0
23	455	1	0
23	456	1	0
23	457	1	0
23	458	1	0
23	459	1	0
23	460	1	0
23	461	1	0
23	462	1	0
23	463	1	0
23	464	1	0
23	465	1	0
23	466	1	0
23	467	1	0
23	468	1	0
23	469	1	0
23	470	1	0
23	471	1	0
23	472	1	0
23	473	1	0
23	474	1	0
23	475	1	0
23	476	1	0
23	477	1	0
23	479	1	0
23	480	1	0
23	481	1	0
23	482	1	0
23	483	1	0
23	484	1	0
23	485	1	0
23	486	1	0
23	487	1	0
23	488	1	0
23	489	1	0
23	490	1	0
23	491	1	0
23	492	1	0
23	493	1	0
23	494	1	0
23	495	1	0
23	496	1	0
23	497	1	0
23	498	1	0
23	499	1	0
23	500	1	0
23	501	1	0
23	502	1	0
23	503	1	0
23	504	1	0
23	505	1	0
23	506	1	0
23	507	1	0
23	508	1	0
23	509	1	0
23	510	1	0
23	511	1	0
23	512	1	0
23	513	1	0
23	514	1	0
23	515	1	0
23	516	1	0
23	517	1	0
23	518	1	0
23	519	1	0
23	520	1	0
23	521	1	0
23	522	1	0
23	523	1	0
23	524	1	0
23	525	1	0
23	526	1	0
23	527	1	0
23	528	1	0
23	529	1	0
23	530	1	0
23	531	1	0
23	532	1	0
23	533	1	0
23	534	1	0
23	535	1	0
23	536	1	0
23	537	1	0
23	538	1	0
23	539	1	0
23	540	1	0
23	541	1	0
23	542	1	0
23	543	1	0
23	544	1	0
23	545	1	0
23	546	1	0
23	547	1	0
23	548	1	0
23	549	1	0
23	550	1	0
23	551	1	0
23	552	1	0
23	553	1	0
23	554	1	0
23	555	1	0
23	556	1	0
23	557	1	0
23	558	1	0
23	559	1	0
23	560	1	0
23	561	1	0
23	562	1	0
23	563	1	0
23	564	1	0
23	565	1	0
23	566	1	0
23	567	1	0
23	568	1	0
23	569	1	0
23	570	1	0
23	571	1	0
23	572	1	0
23	573	1	0
23	574	1	0
23	575	1	0
23	576	1	0
23	577	1	0
23	578	1	0
23	579	1	0
23	580	1	0
23	581	1	0
23	582	1	0
23	583	1	0
23	584	1	0
23	585	1	0
23	586	1	0
23	587	1	0
23	588	1	0
23	589	1	0
23	590	1	0
23	591	1	0
23	592	1	0
23	593	1	0
23	594	1	0
23	595	1	0
23	596	1	0
23	597	1	0
23	598	1	0
23	599	1	0
23	600	1	0
23	601	1	0
23	602	1	0
23	603	1	0
23	604	1	0
23	605	1	0
23	606	1	0
23	607	1	0
23	608	1	0
23	609	1	0
23	610	1	0
23	611	1	0
23	612	1	0
23	613	1	0
23	614	1	0
23	615	1	0
23	616	1	0
23	617	1	0
23	618	1	0
23	619	1	0
23	620	1	0
23	621	1	0
23	622	1	0
23	623	1	0
23	624	1	0
23	625	1	0
23	626	1	0
23	627	1	0
23	628	1	0
23	629	1	0
23	630	1	0
23	631	1	0
23	632	1	0
23	633	1	0
23	634	1	0
23	635	1	0
23	636	1	0
23	637	1	0
23	638	1	0
23	639	1	0
23	640	1	0
23	641	1	0
23	642	1	0
23	643	1	0
23	1872	16	0
23	1636	16	0
23	1637	16	0
23	1638	16	0
23	1639	16	0
23	1640	16	0
23	1641	16	0
23	1642	16	0
23	1643	16	0
23	1644	16	0
23	1645	16	0
23	1646	16	0
23	1647	16	0
23	1648	16	0
23	1649	16	0
23	1650	16	0
23	1651	16	0
23	1652	16	0
23	1653	16	0
23	1654	16	0
23	1655	16	0
23	1656	16	0
23	1657	16	0
23	1658	16	0
23	1659	16	0
23	1660	16	0
23	1661	16	0
23	1662	16	0
23	1663	16	0
23	1664	16	0
23	1665	16	0
23	1666	16	0
23	1667	16	0
23	1668	16	0
23	1669	16	0
23	1670	16	0
23	1671	16	0
23	1672	16	0
23	1673	16	0
23	1674	16	0
23	1675	16	0
23	1676	16	0
23	1677	16	0
23	1678	16	0
23	1679	16	0
23	1680	16	0
23	1681	16	0
23	1682	16	0
23	1683	16	0
23	1684	16	0
23	1685	16	0
23	1686	16	0
23	1687	16	0
23	1688	16	0
23	1689	16	0
23	1690	16	0
23	1691	16	0
23	1692	16	0
23	1693	16	0
23	1694	16	0
23	1695	16	0
23	1696	16	0
23	1697	16	0
23	1698	16	0
23	1699	16	0
23	1700	16	0
23	1701	16	0
23	1702	16	0
23	1703	16	0
23	1704	16	0
23	1705	16	0
23	1706	16	0
23	1707	16	0
23	1708	16	0
23	1709	16	0
23	1710	16	0
23	1711	16	0
23	1712	16	0
23	1713	16	0
23	1714	16	0
23	1715	16	0
23	1716	16	0
23	1717	16	0
23	1718	16	0
23	1719	16	0
23	1720	16	0
23	1721	16	0
23	1722	16	0
23	1723	16	0
23	1724	16	0
23	1725	16	0
23	1726	16	0
23	1727	16	0
23	1728	16	0
23	1729	16	0
23	1730	16	0
23	1731	16	0
23	1732	16	0
23	1733	16	0
23	1734	16	0
23	1735	16	0
23	1736	16	0
23	1737	16	0
23	1738	16	0
23	1739	16	0
23	1740	16	0
23	1741	16	0
23	1742	16	0
23	1743	16	0
23	1744	16	0
23	1745	16	0
23	1746	16	0
23	1747	16	0
23	1748	16	0
23	1749	16	0
23	1750	16	0
23	1751	16	0
23	1752	16	0
23	1753	16	0
23	1754	16	0
23	1755	16	0
23	1756	16	0
23	1757	16	0
23	1758	16	0
23	1759	16	0
23	1760	16	0
23	1761	16	0
23	1762	16	0
23	1763	16	0
23	1764	16	0
23	1765	16	0
23	1766	16	0
23	1767	16	0
23	1768	16	0
23	1769	16	0
23	1770	16	0
23	1771	16	0
23	1772	16	0
23	1773	16	0
23	1774	16	0
23	1775	16	0
23	1776	16	0
23	1777	16	0
23	1919	16	0
23	1778	16	0
23	1779	16	0
23	1780	16	0
23	1781	16	0
23	1782	16	0
23	1783	16	0
23	1784	16	0
23	1785	16	0
23	1786	16	0
23	1787	16	0
23	1788	16	0
23	1789	16	0
23	1790	16	0
23	1791	16	0
23	1792	16	0
23	1793	16	0
23	1794	16	0
23	1795	16	0
23	1796	16	0
23	1797	16	0
23	1798	16	0
23	1799	16	0
23	1800	16	0
23	1801	16	0
23	1802	16	0
23	1803	16	0
23	1804	16	0
23	1805	16	0
23	1806	16	0
23	1807	16	0
23	1808	16	0
23	1809	16	0
23	1810	16	0
23	1811	16	0
23	1812	16	0
23	1813	16	0
23	1814	16	0
23	1815	16	0
23	1816	16	0
23	1817	16	0
23	1818	16	0
23	1819	16	0
23	1820	16	0
23	1821	16	0
23	1822	16	0
23	1823	16	0
23	1824	16	0
23	1825	16	0
23	1826	16	0
23	1827	16	0
23	1828	16	0
23	1829	16	0
23	1830	16	0
23	1831	16	0
23	1832	16	0
23	1833	16	0
23	1834	16	0
23	1835	16	0
23	1836	16	0
23	1837	16	0
23	1838	16	0
23	1839	16	0
23	1840	16	0
23	1841	16	0
23	1842	16	0
23	1843	16	0
23	1844	16	0
23	1845	16	0
23	1846	16	0
23	1847	16	0
23	1848	16	0
23	1849	16	0
23	1850	16	0
23	1851	16	0
23	1852	16	0
23	1853	16	0
23	1854	16	0
23	1855	16	0
23	1856	16	0
23	1857	16	0
23	1858	16	0
23	1859	16	0
23	1860	16	0
23	1861	16	0
23	1862	16	0
23	1863	16	0
23	1864	16	0
23	1865	16	0
23	1866	16	0
23	1867	16	0
23	1868	16	0
23	1869	16	0
23	1870	16	0
23	1871	16	0
23	1873	16	0
23	1874	16	0
23	1875	16	0
23	1876	16	0
23	1877	16	0
23	1878	16	0
23	1879	16	0
23	1880	16	0
23	1881	16	0
23	1882	16	0
23	1883	16	0
23	1884	16	0
23	1885	16	0
23	1886	16	0
23	1887	16	0
23	1888	16	0
23	1889	16	0
23	1890	16	0
23	1891	16	0
23	1892	16	0
23	1893	16	0
23	1894	16	0
23	1895	16	0
23	1896	16	0
23	1897	16	0
23	1898	16	0
23	1899	16	0
23	1900	16	0
23	1901	16	0
23	1902	16	0
23	1903	16	0
23	1904	16	0
23	1905	16	0
23	1906	16	0
23	1907	16	0
23	1908	16	0
23	1909	16	0
23	1910	16	0
23	1911	16	0
23	1912	16	0
23	1913	16	0
23	1914	16	0
23	1915	16	0
23	1916	16	0
23	1917	16	0
23	1918	16	0
23	1920	16	0
23	1921	16	0
23	1922	16	0
23	1923	16	0
23	1924	16	0
23	1925	16	0
23	1926	16	0
23	1927	16	0
23	1928	16	0
23	1929	16	0
23	1930	16	0
23	1931	16	0
23	1932	16	0
23	1933	16	0
23	1934	16	0
23	1935	16	0
23	1936	16	0
23	1937	16	0
23	1938	16	0
23	1939	16	0
23	1940	16	0
23	1941	16	0
23	1942	16	0
23	1943	16	0
23	1944	16	0
23	1945	16	0
23	1946	16	0
23	1947	16	0
23	1948	16	0
23	1949	16	0
23	1950	16	0
23	1951	16	0
23	1952	16	0
23	1953	16	0
23	1954	16	0
23	1955	16	0
23	1956	16	0
23	1957	16	0
23	1958	16	0
23	1959	16	0
23	1960	16	0
\.


--
-- Name: languages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testdb
--

SELECT pg_catalog.setval('public.languages_id_seq', 2, true);


--
-- Name: movies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testdb
--

SELECT pg_catalog.setval('public.movies_id_seq', 25, true);


--
-- Name: phrases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testdb
--

SELECT pg_catalog.setval('public.phrases_id_seq', 2705, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testdb
--

SELECT pg_catalog.setval('public.users_id_seq', 24, true);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- Name: phrases phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.phrases
    ADD CONSTRAINT phrases_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (token);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_phrases users_phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_pkey PRIMARY KEY (user_id, phrase_id, movie_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: sessions_expiry_idx; Type: INDEX; Schema: public; Owner: testdb
--

CREATE INDEX sessions_expiry_idx ON public.sessions USING btree (expiry);


--
-- Name: movies movies_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE;


--
-- Name: phrases phrases_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.phrases
    ADD CONSTRAINT phrases_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id) ON DELETE CASCADE;


--
-- Name: users users_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE;


--
-- Name: users users_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id) ON DELETE CASCADE;


--
-- Name: users_phrases users_phrases_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id) ON DELETE CASCADE;


--
-- Name: users_phrases users_phrases_phrase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_phrase_id_fkey FOREIGN KEY (phrase_id) REFERENCES public.phrases(id) ON DELETE CASCADE;


--
-- Name: users_phrases users_phrases_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY public.users_phrases
    ADD CONSTRAINT users_phrases_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

