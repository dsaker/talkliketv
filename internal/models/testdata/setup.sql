CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE languages(
    id bigint NOT NULL,
    language text NOT NULL
);

CREATE TABLE movies (
    id bigint NOT NULL,
    title text NOT NULL,
    num_subs integer NOT NULL,
    language_id bigint DEFAULT 1 NOT NULL
);

CREATE TABLE phrases (
    id bigint NOT NULL,
    movie_id bigint NOT NULL,
    phrase text NOT NULL,
    translates text NOT NULL,
    hint text NOT NULL
);

CREATE TABLE sessions (
    token text NOT NULL,
    data bytea NOT NULL,
    expiry timestamp with time zone NOT NULL
);

CREATE TABLE users (
    id bigint NOT NULL,
    movie_id bigint NOT NULL,
    name text NOT NULL,
    email citext NOT NULL,
    hashed_password bytea NOT NULL,
    created timestamp(0) with time zone DEFAULT now() NOT NULL,
    language_id bigint DEFAULT 1 NOT NULL
);

CREATE TABLE users_phrases (
    user_id bigint NOT NULL,
    phrase_id bigint NOT NULL,
    movie_id bigint NOT NULL,
    correct bigint
);

INSERT INTO languages (id, language) VALUES (1,
                                             'Spanish'),
                                         (2,
                                          'French'),
                                         (-1,
                                          'Not a Language');

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
                                                           1),
                                                          (-1,
                                                           'Not a Movie',
                                                           0,
                                                           -1);

INSERT INTO phrases (id, movie_id, phrase, translates, hint) VALUES (2,
                                                                     1,
                                                                     'You can do it. Keep going. Breathe.',
                                                                     'Tú puedes. Sigue, sigue, sigue. Respira.',
                                                                     'T  p     . S    , s    , s    . R      .'),
                                                                 (3,
                                                                  1,
                                                                  'Dont close your legs. Dont.',
                                                                  'No me cierres las piernas. No las cierres.',
                                                                  'N  m  c       l   p      . N  l   c      .'),
                                                                 (4,
                                                                  1,
                                                                  'Hey, Romina, dont forget you go last here.',
                                                                  'Ey, Romina, no se le olvide que acá va de última.',
                                                                  'E , R     , n  s  l  o      q   a   v  d  ú     .'),
                                                                 (5,
                                                                  1,
                                                                  'Oh, you snooze, you lose.',
                                                                  'Ay, como lo vi tan dormidito.',
                                                                  'A , c    l  v  t   d        .'),
                                                                 (6,
                                                                  1,
                                                                  'Dont you know female centaurs dont exist?',
                                                                  '¡Ja! ¿Usted no sabía que las centauros mujeres no existen?',
                                                                  '¡J ! ¿U     n  s     q   l   c         m       n  e      ?'),
                                                                 (7,
                                                                  1,
                                                                  'Tato, did you know that if theres a male, its because a female gave birth to it?',
                                                                  'Tato, ¿y sabe que si hay un hombre de cada cosa es porque una hembra lo parió? ¿O no?',
                                                                  'T   , ¿y s    q   s  h   u  h      d  c    c    e  p      u   h      l  p    ? ¿O n ?'),
                                                                 (8,
                                                                  1,
                                                                  'You know what you need to do to become a centaur?',
                                                                  '¡Ja! ¿Sabe qué le falta a usted para ser una centauro?',
                                                                  '¡J ! ¿S    q   l  f     a u     p    s   u   c       ?'),
                                                                 (9,
                                                                  1,
                                                                  'Instead of plodding along, learn to fly.',
                                                                  'Volar, porque con lo lenta que es…',
                                                                  'V    , p      c   l  l     q   e …'),
                                                                 (10,
                                                                  1,
                                                                  'Come on, Tato, instead of trying to distract me,',
                                                                  'Venga, Tato. En vez de tratar de desconcentrarme, concéntrese en lo suyo más bien.',
                                                                  'V    , T   . E  v   d  t      d  d              , c           e  l  s    m   b   .'),
                                                                 (11,
                                                                  1,
                                                                  'Because my brunette and I are all in!',
                                                                  '¡Porque mi Morocha y yo vamos con toda!',
                                                                  '¡P      m  M       y y  v     c   t   !');

-- 12	1	Let's see if you can beat this time.	Vamos a ver si supera este tiempo.	V     a v   s  s      e    t     .
-- 13	1	Let's see if you can stay on your bike.	Pues vamos a ver si no se cae.	P    v     a v   s  n  s  c  .
-- 14	1	What a fall, let's help. No, wait.	¡Qué golpe! Vamos a ayudar. No, espere.	¡Q   g    ! V     a a     . N , e     .
-- 15	1	How did nothing happen to that guy?	¿A ese man cómo no le pasó nada?	¿A e   m   c    n  l  p    n   ?
-- 16	1	That guy's fierce. Got up like it was nothing.	Berraco ese pelado porque se paró como si nada.	B       e   p      p      s  p    c    s  n   .
-- 17	1	Let's go see who wins the race. Let's go.	Vamos a ver quién ganó la carrera. Hágale pues.	V     a v   q     g    l  c      . H      p   .
-- 18	1	Romina Páez is the national downhill champion!	¡Romina Páez es la ganadora del campeonato nacional de downhill!	¡R      P    e  l  g        d   c          n        d  d       !
-- 19	1	Laurita, it's turning out beautifully.	Laurita, le está quedando muy bonito, de verdad.	L      , l  e    q        m   b     , d  v     .
-- 20	1	If you say so, Rubén.	Si usted, Rubén, lo dice, yo le creo.	S  u    , R    , l  d   , y  l  c   .
-- 21	1	Oh, Rubén, wait. I have a gift for you.	Ay, Rubén, espere, espere. Yo le tenía un regalito.	A , R    , e     , e     . Y  l  t     u  r       .
-- 22	1	How's your blood sugar?	¿Cómo le salió la glicemia? Bien.	¿C    l  s     l  g       ? B   .
-- 23	1	It's fine, 95 on an empty stomach.	Bien, 95 en ayunas.	B   , 95 e  a     .
-- 24	1	You're my official taste tester. Of course.	Usted es mi catador oficial, Rubén. Claro.	U     e  m  c       o      , R    . C    .
-- 25	1	Hey, new haircut. It looks great on you.	Ay, se cortó el pelo. Le luce mucho.	A , s  c     e  p   . L  l    m    .
-- 26	1	Hi, Moni. How are you?	Hola, Moni. ¿Cómo va?	H   , M   . ¿C    v ?
-- 27	1	Jorge, it's so nice to see you around here again.	Jorge, qué bueno volverlo a ver por aquí.	J    , q   b     v        a v   p   a   .
-- 28	1	Hi, Luzma. How are you, miss? Your juice.	Hola, Luzma. Señorita, ¿cómo está? Su juguito.	H   , L    . S       , ¿c    e   ? S  j      .
-- 29	1	Could you be any sweeter? Thank you. You're welcome.	¿Por qué es tan hermosa? Gracias. Con mucho gusto.	¿P   q   e  t   h      ? G      . C   m     g    .
-- 30	1	I'll be right back. Okay.	Ya vengo. Bueno.	Y  v    . B    .
-- 31	1	What a pleasant surprise to see a woman win this race.	Qué sorpresa tan agradable ver que una chica ganó este campeonato.	Q   s        t   a         v   q   u   c     g    e    c         .
-- 32	1	Because I think it's brave to compete in a high risk sport such as this one.	Porque creo que es de valientes practicar un deporte de alto riesgo como este.	P      c    q   e  d  v         p         u  d       d  a    r      c    e   .
-- 33	1	You know what's actually high risk?	¿Usted sabe qué sí es de alto riesgo?	¿U     s    q   s  e  d  a    r     ?
-- 34	1	Living in this neighborhood. That takes bravery.	Vivir en este barrio. Eso sí es para valientes.	V     e  e    b     . E   s  e  p    v        .
-- 35	1	Why do you say that?	¿Y por qué lo dice?	¿Y p   q   l  d   ?
-- 36	1	Because this neighborhood is full of moneylenders, loan sharks, and payday lenders.	Porque este barrio está lleno de usureros, de prestamistas, de gota a gotas.	P      e    b      e    l     d  u       , d  p           , d  g    a g    .
-- 37	1	They're screwing over the neighborhood.	esos manes tienen jodido a este barrio.	e    m     t      j      a e    b     .
-- 38	1	And what do the police do? Just park wherever they want.	¿Y qué hace la policía? Andar mal parqueado y ya.	¿Y q   h    l  p      ? A     m   p         y y .
-- 39	1	I wish they'd actually do something to keep the neighborhood safe	Ojalá le metieran la ficha y le metieran toda la seguridad al barrio	O     l  m        l  f     y l  m        t    l  s         a  b
-- 40	1	but well, it's kind of complicated.	pero pues como complicado.	p    p    c    c         .
-- 41	1	What a warm welcome for the police!	¿Qué tal esta peladita la bienvenida que le da a la policía?	¿Q   t   e    p        l  b          q   l  d  a l  p      ?
-- 42	1	Buddy, now I want to meet her.	Ahora sí me interesa conocerla, ¿oyó, curso?	A     s  m  i        c        , ¿o  , c    ?
-- 43	1	On top of being beautiful, she's brave and tough.	Aparte de linda, también es valiente y berraca.	A      d  l    , t       e  v        y b      .
-- 44	1	It was love at first pedal.	Eso fue un flechazo al primer pedalazo.	E   f   u  f        a  p      p       .
-- 45	1	You know what I'm curious about? What?	No, ¿sabe qué me intriga? ¿Qué?	N , ¿s    q   m  i      ? ¿Q  ?
-- 46	1	The whole loan shark thing.	Ese tema de la usura.	E   t    d  l  u    .
-- 47	1	Congrats, Rominita. How are you? Did you see me fall?	Felicidades, Rominita. ¿Qué tal? ¿Vieron cómo me caí?	F          , R       . ¿Q   t  ? ¿V      c    m  c  ?
-- 48	1	A round of applause for our national champion!	¡Un aplauso, por favor, para la campeona nacional!	¡U  a      , p   f    , p    l  c        n       !
-- 49	1	Your national downhill champion, ladies and gentlemen!	¡Ey, campeona nacional del downhill, señores! 	¡E , c        n        d   d       , s      !
-- 50	1	The pride of La Mirla!	¡Orgullo de La Mirla!	¡O       d  L  M    !
-- 51	1	Hi, Laura! How are you, sweetheart? 	Hola, Laura, cariño. ¿Qué tal? ¿Cómo estás? 	H   , L    , c     . ¿Q   t  ? ¿C    e    ?
-- 52	1	What's new? Tell me everything.	¿Qué ha pasado? Cuéntame.	¿Q   h  p     ? C       .
-- 53	1	Rubén and I went to the bakery to see how it was coming along.	Andaba con Rubén en la repostería viendo cómo está quedando el local.	A      c   R     e  l  r          v      c    e    q        e  l    .
-- 54	1	And, to answer your question, it's turning out lovely.	Y, para responder tu pregunta, está quedando divino.	Y, p    r         t  p       , e    q        d     .
-- 55	1	Wait. I'll let you talk to your mom.	Espera, cariño. Te dejo con tu mamá, ¿vale?	E     , c     . T  d    c   t  m   , ¿v   ?
-- 56	1	I'm glad everything is going well. Hi, darling!	Me alegro que todo esté bien. Hola, mi amor.	M  a      q   t    e    b   . H   , m  a   .
-- 57	1	I'm so glad to see you. How are you? What I wouldn't give to squeeze you.	Ay, qué alegría verte. ¿Cómo estás? Ay, quiero espicharte.	A , q   a       v    . ¿C    e    ? A , q      e         .
-- 58	1	Mom, explain to me why Dad calls me if he never has time to talk?	¿Mi papá para qué me llama si nunca tiene tiempo para hablar?	¿M  p    p    q   m  l     s  n     t     t      p    h     ?
-- 59	1	Oh, darling. You know what he's like. Yeah.	Ay, amor, ya tú sabes cómo es él. Sí.	A , a   , y  t  s     c    e  é . S .
-- 60	1	But don't let it bother you, darling. That's how he shows his love.	Pero, ven, no te mortifiques, mi amor. Esa es su manera de demostrarnos que nos quiere.	P   , v  , n  t  m          , m  a   . E   e  s  m      d  d            q   n   q     .
-- 61	1	He does the same to me. Don't be so hard on him.	A mí me hace lo mismo. Pero no le des tan duro.	A m  m  h    l  m    . P    n  l  d   t   d   .
-- 62	1	Okay, no big deal.	Vale, no pasa nada.	V   , n  p    n   .
-- 63	1	Everything he does, he does because he loves you.	Todo lo que hace lo hace porque te quiere.	T    l  q   h    l  h    p      t  q     .
-- 64	1	You know all I want from him is time.	Igual tú sabes que lo que yo quiero que él me dé es tiempo.	I     t  s     q   l  q   y  q      q   é  m  d  e  t     .
-- 65	1	But it's fine. I won't make a big deal out of it.	Pero no pasa nada. Yo no haré un problema de esto.	P    n  p    n   . Y  n  h    u  p        d  e   .
-- 66	1	So, tell me, how's the shop? Have you settled on a name?	Pero cuéntame. ¿Cómo va lo del local? ¿Ya le tienes nombre?	P    c       . ¿C    v  l  d   l    ? ¿Y  l  t      n     ?
-- 67	1	but we're really close.	pero estamos muy cerquita.	p    e       m   c       .
-- 68	1	And I was thinking I could celebrate my birthday there	Es más, estaba pensando que de pronto podría celebrar mi cumpleaños en el local	E  m  , e      p        q   d  p      p      c        m  c          e  e  l
-- 69	1	and I wanted to know if you think you'll make it here by then.	y quería preguntarte si tú crees que alcanzan a llegar para esas fechas.	y q      p           s  t  c     q   a        a l      p    e    f     .
-- 70	1	Uh... Well, darling, we actually wanted to talk to you about that.	Eh, pues, mi amor, precisamente de eso te queríamos hablar.	E , p   , m  a   , p            d  e   t  q         h     .
-- 71	1	Something's come up that your dad needs to resolve and we had to postpone our return.	Es que a tu papá le salieron un par de cosas que tiene que resolver y nos tocó prolongar el regreso.	E  q   a t  p    l  s        u  p   d  c     q   t     q   r        y n   t    p         e  r      .
-- 72	1	Don't be like that. Look on the bright side, darling.	Pero… Ay, no te pongas así. Mírale el lado bueno, mi amor.	P   … A , n  t  p      a  . M      e  l    b    , m  a   .
-- 73	1	You'll be home alone.	Te vas a quedar sola en la casa.	T  v   a q      s    e  l  c   .
-- 74	1	With the house to yourself. I have something to tell you.	La casa solo para ti. Oye, espera. Una cosa superimportante, cariño.	L  c    s    p    t . O  , e     . U   c    s              , c     .
-- 75	1	We have a surprise for you that you're going to love.	Tenemos una sorpresa para ti que te va a encantar.	T       u   s        p    t  q   t  v  a e       .
-- 76	1	Go to Roberto's office in three hours, okay?	Tienes que estar en la oficina de Roberto como en tres horitas, ¿vale?	T      q   e     e  l  o       d  R       c    e  t    h      , ¿v   ?
-- 77	1	Sorry, I have another call.	Disculpa que me entró otra llamada.	D        q   m  e     o    l      .
-- 78	1	Hugs, darling. Take care. Mwah!	Besos, mi amor. Cuídate mucho. ¡Mua!	B    , m  a   . C       m    . ¡M  !
-- 79	1	I love you, Mom.	Te amo, ma.	T  a  , m .
-- 80	1	What was that kiss about?	¿Y ese beso qué fue?	¿Y e   b    q   f  ?
-- 81	1	I was celebrating your win. Don't give me that bullshit, Leo.	Estaba celebrando su victoria. Ay, no te pongas con esas bobadas, Leo.	E      c          s  v       . A , n  t  p      c   e    b      , L  .
-- 82	1	Romi, don't be like that. It's all good.	Ya, venga. No se ponga así, Romi. Todo bien.	Y , v    . N  s  p     a  , R   . T    b   .
-- 83	1	We broke up a long time ago.	Nosotros terminamos hace mucho tiempo.	N        t          h    m     t     .
-- 84	1	Romi, I know we broke up, but we still love each other.	Yo sé, Romi, que usted y yo terminamos, pero usted y yo nos seguimos queriendo.	Y  s , R   , q   u     y y  t         , p    u     y y  n   s        q        .
-- 85	1	Don't deny it, honey. I can see it in your eyes.	No me lo niegue, amor, que lo puedo ver en sus ojos.	N  m  l  n     , a   , q   l  p     v   e  s   o   .
-- 86	1	You know exactly why we broke up.	Usted tiene muy claro por qué se acabaron las cosas.	U     t     m   c     p   q   s  a        l   c    .
-- 87	1	How many times do I have to tell you I didn't choose the family I got?	¿Cuántas veces le tengo que explicar que yo no escogí la familia que me tocó?	¿C       v     l  t     q   e        q   y  n  e      l  f       q   m  t   ?
-- 88	1	You're absolutely right, Leo.	Tiene toda la razón, Leo.	T     t    l  r    , L  .
-- 89	1	You can't choose your family,	Uno no escoge la familia que le tocó, 	U   n  e      l  f       q   l  t   ,
-- 90	1	but you did choose to join your brothers' shady business.	pero usted sí escogió meterse en ese negocio tan chimbo que tienen sus hermanos.	p    u     s  e       m       e  e   n       t   c      q   t      s   h       .
-- 91	1	You know who's to blame?	¿Sabe quién tiene la culpa?	¿S    q     t     l  c    ?
-- 92	1	The people in this town, because there'd be no business without them.	La gente de este barrio, porque este negocio sin ellos no existiría.	L  g     d  e    b     , p      e    n       s   e     n  e        .
-- 93	1	It's transactional. They need money. We give it to them. That's it.	Esto es una transacción. Ellos necesitan plata. Nosotros se la damos. Eso es todo.	E    e  u   t          . E     n         p    . N        s  l  d    . E   e  t   .
-- 94	1	People are happy once they're flush with cash.	La gente sale feliz, con los bolsillos llenos de plata.	L  g     s    f    , c   l   b         l      d  p    .
-- 95	1	Do you know how screwed people are once they pay the interest you charge?	¿Vio cómo queda de jodida la gente cuando debe pagar los intereses que les cobran?	¿V   c    q     d  j      l  g     c      d    p     l   i         q   l   c     ?
-- 96	1	Do you know what your brother does when folks can't pay on time?	¿Vio lo que su hermano hace cuando no tienen cómo pagar a tiempo?	¿V   l  q   s  h       h    c      n  t      c    p     a t     ?
-- 97	1	Should I tell you? I'm getting out.	¿O le cuento? Me voy a abrir de esta mierda.	¿O l  c     ? M  v   a a     d  e    m     .
-- 98	1	I'm going to leave this neighborhood, my brothers, my family, all this shit, Romi.	Me voy a abrir del barrio, de mis hermanos, de mi familia, de todo este mierdero, Romi.	M  v   a a     d   b     , d  m   h       , d  m  f      , d  t    e    m       , R   .
-- 99	1	Because I want you back.	Porque la quiero recuperar.	P      l  q      r        .
-- 100	1	And I'll do it for you.	Y lo voy a hacer por usted.	Y l  v   a h     p   u    .
-- 101	1	It's great that you want to change. Really.	Leo, qué chimba que quiera cambiar.	L  , q   c      q   q      c      .
-- 102	1	I'm so happy for you.	Y se lo celebro mucho.	Y s  l  c       m    .
-- 103	1	But if you're going to change, change for yourself.	Pero si va a cambiar, cambie por usted.	P    s  v  a c      , c      p   u    .
-- 104	1	I'll change for both of us, then.	Voy a cambiar por los dos entonces.	V   a c       p   l   d   e       .
-- 105	1	Why so sad, Laurita?	Uy, Laurita, ¿y esa cara de tristeza?	U , L      , ¿y e   c    d  t       ?
-- 106	1	How'd you know? Oh!	¿Quién le dijo que yo estaba triste? ¡Ay!	¿Q     l  d    q   y  e      t     ? ¡A !
-- 107	1	You must've had a fight with your boyfriend.	Supe que peleó con el noviecito.	S    q   p     c   e  n        .
-- 108	1	Keep your disdain for Santiago to yourself, Rubén.	Que no se note, Rubén, que le cae como mal Santiago.	Q   n  s  n   , R    , q   l  c   c    m   S       .
-- 109	1	The thing is I've known you since you were up to here on me.	No, lo que pasa es que a usted la conozco desde que era así de grande.	N , l  q   p    e  q   a u     l  c       d     q   e   a   d  g     .
-- 110	1	But time flies, doesn't it?	Pero bueno, lo que pasa es que el tiempo vuela, ¿no?	P    b    , l  q   p    e  q   e  t      v    , ¿n ?
-- 111	1	I sometimes think it's quite the opposite.	Yo a veces siento que es al contrario, Rubén.	Y  a v     s      q   e  a  c        , R    .
-- 112	1	I think time drags when you're bored.	Yo siento que a veces el tiempo pasa lento cuando uno está aburrido.	Y  s      q   a v     e  t      p    l     c      u   e    a       .
-- 113	1	What are you complaining about, love?	Niña, ¿usted de qué se queja?	N   , ¿u     d  q   s  q    ?
-- 114	1	You should be grateful for all your privilege.	Debería estar agradecida que es una mujer privilegiada.	D       e     a          q   e  u   m     p           .
-- 115	1	Please lay off the scolding, Rubén.	Rubén, no empecemos con el regaño, por favor.	R    , n  e         c   e  r     , p   f    .
-- 116	1	I'm not scolding you. 	No, es que no es regaño.	N , e  q   n  e  r     .
-- 117	1	I want you to understand that now that you're an adult you can do more than before.	Quisiera que entendiera que, ahora que usted es adulta, puede hacer cosas que antes no podía.	Q        q   e          q  , a     q   u     e  a     , p     h     c     q   a     n  p    .
-- 118	1	Like have my own bakery. For example. 	Como sacar adelante mi repostería. Por ejemplo.	C    s     a        m  r         . P   e      .
-- 119	1	Or study in Paris, like you've always dreamed of doing.	O irse a estudiar a París, como siempre ha soñado.	O i    a e        a P    , c    s       h  s     .
-- 120	1	Look, Ma! Another for the collection!	Ma, ¡vea pues! ¡Otro para la colección!	M , ¡v   p   ! ¡O    p    l  c        !
-- 121	1	You can't imagine the epic fall I had.	Ay, y no se imagina la caída tan berraca que me pegué.	A , y n  s  i       l  c     t   b       q   m  p    .
-- 122	1	It was quite the tumble at the end.	Ja. El pique que me pegué al final.	J . E  p     q   m  p     a  f    .
-- 123	1	You should've seen it. I was flying at first.	Ma, me hubiera visto. Yo salí volando.	M , m  h       v    . Y  s    v      .
-- 124	1	I almost fell, but...	Casi me caigo pues, pero ahí…	C    m  c     p   , p    a  …
-- 125	1	What are you doing here?	¿Y usted qué hace aquí?	¿Y u     q   h    a   ?
-- 126	1	How are you, honey?	¿Entonces qué, peladita, bien o no?	¿E        q  , p       , b    o n ?
-- 127	1	A little bird told me you won the race. Congratulations.	Por ahí un pajarito nos contó que ganó la competencia y vinimos a felicitarla.	P   a   u  p        n   c     q   g    l  c           y v       a f          .
-- 128	1	Nice! Yes, we can. Yes, we can.	¡Venga! Sí se pudo, sí se pudo.	¡V    ! S  s  p   , s  s  p   .
-- 129	1	Congratulations, my ass, Marlon. Get out.	Felicitaciones ni chimba, Marlon. Se abren pues.	F              n  c     , M     . S  a     p   .
-- 130	1	Watch that tone. It's rude and we're here to congratulate you.	Bajándole al tonito y no sea grosera, que vinimos fue a felicitarla.	B         a  t      y n  s   g      , q   v       f   a f          .
-- 131	1	Relax, honey, we're here to talk.	Relájese, pelada, que vinimos a hablar.	R       , p     , q   v       a h     .
-- 132	1	I heard what you said to that journalist.	Me enteré lo que le dijo a la periodista.	M  e      l  q   l  d    a l  p         .
-- 133	1	I have ears to the ground in this neighborhood, honey.	Yo tengo muchos pajaritos en mi barrio, peladita.	Y  t     m      p         e  m  b     , p       .
-- 134	1	Well, honey, what I said to the journalist isn't news to anyone.	Pues, peladito, lo que yo le dije a la periodista no es secreto para nadie.	P   , p       , l  q   y  l  d    a l  p          n  e  s       p    n    .
-- 135	1	And know that this is my neighborhood too.	Y entérese de una vez que este también es mi barrio.	Y e        d  u   v   q   e    t       e  m  b     .
-- 136	1	Romina, dear. Don't "Romina, dear" me, Ma.	Romina, hija. No, ¿Romina qué, ma? No, señora.	R     , h   . N , ¿R      q  , m ? N , s     .
-- 137	1	I'll say to your face what I said to that journalist.	Lo que le dije a esa periodista se lo sostengo en la cara a estos manes.	L  q   l  d    a e   p          s  l  s        e  l  c    a e     m    .
-- 138	1	You're a plague that's screwed over the neighborhood.	Ustedes son una plaga que tienen jodido al barrio.	U       s   u   p     q   t      j      a  b     .
-- 139	1	You should be ashamed of yourselves.	Pena es lo que les debería dar.	P    e  l  q   l   d       d  .
-- 140	1	I'm so sorry we rub you the wrong way.	Qué lástima que le caigamos tan mal y que piense eso de nosotros,	Q   l       q   l  c        t   m   y q   p      e   d  n       ,
-- 141	1	Because we got along fine when your mom asked for a loan, right?	porque lo mismo no pensó su mamá cuando me pidió prestado plata, ¿no?	p      l  m     n  p     s  m    c      m  p     p        p    , ¿n ?
-- 142	1	It's almost time to pay up, right?	Ya está siendo hora de que me pague, ¿no?	Y  e    s      h    d  q   m  p    , ¿n ?
-- 143	1	Since you want nothing to do with us,	Como nosotros le caemos tan mal a usted y le damos tanto asco.	C    n        l  c      t   m   a u     y l  d     t     a   .
-- 144	1	pay me and I'll leave you alone.	págueme lo mío y las dejo en paz.	p       l  m   y l   d    e  p  .
-- 145	1	You have two weeks to pay me what you owe me plus interest.	Tienen dos semanas para entregarme lo mío más los intereses.	T      d   s       p    e          l  m   m   l   i        .
-- 146	1	Or else we'll come and clear this pigsty.	Si no, venimos aquí y desocupamos esta pocilga.	S  n , v       a    y d           e    p      .
-- 147	1	I'll see to it. Otherwise, I'll take Ebony.	Yo veré. Si no, me le llevo a la Morocha.	Y  v   . S  n , m  l  l     a l  M      .
-- 148	1	Maybe that'll shut that snitch up.	A ver si esto le amarra la lengua a esa sapa.	A v   s  e    l  a      l  l      a e   s   .
-- 149	1	And if it doesn't? Guess.	Y si no, ¿qué? Adivine.	Y s  n , ¿q  ? A      .
-- 150	1	Leo isn't going to like it when he finds out we came by Romina and her mom's place.	A Leo no le va a gustar ni mierda cuando sepa que vinimos a visitar a la Romina y a la cucha esa.	A L   n  l  v  a g      n  m      c      s    q   v       a v       a l  R      y a l  c     e  .
-- 151	1	Leo needs to end this stupid fling with that girl.	Leo lo que tiene que dejar es la pendejada con esa pelada.	L   l  q   t     q   d     e  l  p         c   e   p     .
-- 152	1	I don't get that guy.	Yo no sé qué le pasa a ese man.	Y  n  s  q   l  p    a e   m  .
-- 153	1	He's always like that with women.	Siempre es lo mismo con las mujeres.	S       e  l  m     c   l   m      .
-- 154	1	Don't you understand we're not like everyone else?	¿Ustedes no han entendido que nosotros no somos como los demás?	¿U       n  h   e         q   n        n  s     c    l   d    ?
-- 155	1	We're the Chitiva brothers and we kneel before no one.	Nosotros somos los Chitiva y no nos arrodillamos frente a nadie.	N        s     l   C       y n  n   a            f      a n    .
-- 156	1	Much less for love.	Y menos por amor.	Y m     p   a   .
-- 157	1	Your parents put this money in a trust for you to have when you turned 21.	Tus papás quisieron dejar este dinero en fideicomiso para ser entregado cuando cumplieras 21 años,	T   p     q         d     e    d      e  f           p    s   e         c      c          21 a   ,
-- 158	1	And since that's in a few weeks,	y como estamos a un par de semanas de que eso ocurra,	y c    e       a u  p   d  s       d  q   e   o     ,
-- 159	1	Wait. What is this?	Espere. ¿Y esto vendría siendo qué?	E     . ¿Y e    v       s      q  ?
-- 160	1	consider it a living inheritance. You can think of it that way.	tómalo como una herencia en vida. Piénsalo de esa manera.	t      c    u   h        e  v   . P        d  e   m     .
-- 161	1	So, all this money is for me?	¿O sea que toda esta plata es para mí?	¿O s   q   t    e    p     e  p    m ?
-- 162	1	For whatever I want? For whatever you want.	¿Para lo que yo quiera? Toda… Lo que tú quieras.	¿P    l  q   y  q     ? T   … L  q   t  q      .
-- 163	1	There is one condition for the disbursement.	Solo hay una condición para el desembolso.	S    h   u   c         p    e  d         .
-- 164	1	There are always conditions with my dad.	Con mi papá siempre hay condiciones.	C   m  p    s       h   c          .
-- 165	1	It's a simple condition.	Es muy fácil la condición.	E  m   f     l  c        .
-- 166	1	Your parents are always thinking of your future.	Eh, tus papás siempre piensan en tu futuro.	E , t   p     s       p       e  t  f     .
-- 167	1	And your dad is very happy about your business venture,	Y tu papá incluso está muy contento con tu emprendimiento en el asunto de la repostería.	Y t  p    i       e    m   c        c   t  e              e  e  a      d  l  r         .
-- 168	1	Your father wants you to join the family business right away	Pues el punto es que tu papá quiere que te vincules inmediatamente a la empresa familiar,	P    e  p     e  q   t  p    q      q   t  v        i              a l  e       f       ,
-- 478	1	The night is young.	Apenas está empezando la noche.	A      e    e         l  n    .
-- 169	1	so that you can gain experience in all areas	para que recorras por tu propia experiencia todas las áreas	p    q   r        p   t  p      e           t     l   á
-- 170	1	just in case, at some point, hopefully not soon, 	por si, en algún momento, Dios no lo quiera,	p   s , e  a     m      , D    n  l  q     ,
-- 171	1	so you'll be able to replace him.	pues estarás en capacidad de reemplazarlo.	p    e       e  c         d  r           .
-- 172	1	Where champions become legends.	Donde los campeones se vuelven leyendas.	D     l   c         s  v       l       .
-- 173	1	Mom, you borrowed the money for this?	Mamá, ¿usted pidió prestada la plata para esto?	M   , ¿u     p     p        l  p     p    e   ?
-- 174	1	Of course. How else did you think we bought Ebony?	Y si no, ¿con qué compramos la Morocha, pues?	Y s  n , ¿c   q   c         l  M      , p   ?
-- 175	1	Yeah. And going to Italy costs a ton of money, too.	Sí. Hija, además irse a Italia cuesta un montón de plata.	S . H   , a      i    a I      c      u  m      d  p    .
-- 176	1	You have to take all those toys so you don't get rusty.	Y debe llevarse todos los juguetes para no desentonar.	Y d    l        t     l   j        p    n  d         .
-- 177	1	You're brave and strong. You deserve all the opportunities.	Usted es una berraca y una dura. Se merece todas las posibilidades.	U     e  u   b       y u   d   . S  m      t     l   p            .
-- 178	1	Thank you so much for doing this for me, really.	Yo le agradezco mucho que usted haya hecho eso por mí, de verdad,	Y  l  a         m     q   u     h    h     e   p   m , d  v     ,
-- 179	1	But we're selling that bicycle.	pero vamos a vender ya esa bicicleta.	p    v     a v      y  e   b        .
-- 180	1	Nobody's selling anything. It's my issue. Maybe I'll sell more empanadas,	Nadie va a vender nada. Es mi problema. Yo veré si vendo más empanadas,	N     v  a v      n   . E  m  p       . Y  v    s  v     m   e        ,
-- 181	1	get another job, sell lottery tickets. I don't know.	si me consigo otro trabajo, si vendo chance, no sé.	s  m  c       o    t      , s  v     c     , n  s .
-- 182	1	I'll do what I have to do. You focus on training, it's important.	Yo veré qué tengo que hacer. Usted ocúpese por entrenar que es lo importante.	Y  v    q   t     q   h    . U     o       p   e        q   e  l  i         .
-- 183	1	Sweetheart, you're almost 21.	Hija, usted ya va a cumplir 21 años.	H   , u     y  v  a c       21 a   .
-- 184	1	I want all your talent to take you far away from here.	Yo quiero que ese talento que usted tiene me la saque bien lejos de aquí.	Y  q      q   e   t       q   u     t     m  l  s     b    l     d  a   .
-- 185	1	Far away? Far away is where I'll send the Chitivas brothers.	¿Bien lejos? Bien lejos es adonde yo voy a mandar a los Chitivas.	¿B    l    ? B    l     e  a      y  v   a m      a l   C       .
-- 186	1	Are you still on that, Romina? Stop. Look at me.	¿Va a seguir con eso, Romina? Ya no más. Míreme.	¿V  a s      c   e  , R     ? Y  n  m  . M     .
-- 187	1	These people are dangerous. Please, sweetheart.	Esa gente es muy peligrosa, hija. Por favor.	E   g     e  m   p        , h   . P   f    .
-- 188	1	Look, Ma, if I'm not afraid of taking on those hills without brakes,	A ver, ma, si a mí no me da miedo tirarme por estas lomas sin frenos,	A v  , m , s  a m  n  m  d  m     t       p   e     l     s   f     ,
-- 189	1	why would I be afraid of those idiots?	¿cree que me da miedo enfrentarme a esos bobos?	¿c    q   m  d  m     e           a e    b    ?
-- 190	1	Enough, Romina. Please, sweetheart.	Ya no más, Romina. Por favor, hija.	Y  n  m  , R     . P   f    , h   .
-- 191	1	Be careful. If not for yourself, then for me.	Cuídese. Si no lo quiere hacer por usted, hágalo por mí.	C      . S  n  l  q      h     p   u    , h      p   m .
-- 192	1	Stay away from those people.	No se meta más con esta gente.	N  s  m    m   c   e    g    .
-- 193	1	No, Santiago. It's not a gift. It's a trap.	No, Santiago, eso no es un regalo. Eso es una trampa.	N , S       , e   n  e  u  r     . E   e  u   t     .
-- 194	1	A trap? You're blowing it out of proportion.	¿Cómo una trampa? Exagerada. ¿Qué decís?	¿C    u   t     ? E        . ¿Q   d    ?
-- 195	1	Santiago, my dad is tying me down with all this money.	Santiago, mi papá me está amarrando aquí con ese montón de plata.	S       , m  p    m  e    a         a    c   e   m      d  p    .
-- 196	1	But say yes. It's a ton of money.	Pero decile que sí. Es un montón de plata.	P    d      q   s . E  u  m      d  p    .
-- 197	1	Say yes to all of his conditions.	Decile que sí a todas las condiciones que te dijo.	D      q   s  a t     l   c           q   t  d   .
-- 198	1	No, Santi. That's not the point. My dad's always like this.	Santi, no. Es que ese no es el punto. La cosa es que con mi papá todo es igual.	S    , n . E  q   e   n  e  e  p    . L  c    e  q   c   m  p    t    e  i    .
-- 199	1	Everything has hidden intentions, the price to pay is too high,	Todo tiene una segunda intención. Todo tiene un precio muy alto.	T    t     u   s       i        . T    t     u  p      m   a   .
-- 200	1	and this time, I'm not sure I want to pay the price.	Y esta vez, no sé si quiero pagar ese precio.	Y e    v  , n  s  s  q      p     e   p     .
-- \.
--
-- --
-- -- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: testdb
-- --
--
INSERT INTO users (id, movie_id, name, email, hashed_password, created, language_id) VALUES (
                                                                                             2,
                                                                                             -1, 'user2',
                                                                                             'user2@email.com',
                                                                                             '\\x2432612431322445396a71444c59364b5173736e616130536757572f754367383872534367776c314f626b443550365142313958436b476754325836',
                                                                                             '2023-11-14 08:21:57-08',
                                                                                             2),
                                                                                         (1,
                                                                                          1,
                                                                                          'user1',
                                                                                          'user1@email.com',
                                                                                          '\\x243261243132246d796679615276486e73457138724e647332727a454f59586c464764393755386f486f57336d2e31696b5135326446344e73666d57',
                                                                                          '2023-11-14 08:13:52-08',
                                                                                          1);

--
--
-- --
-- -- Data for Name: users_phrases; Type: TABLE DATA; Schema: public; Owner: testdb
-- --
--
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

--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- Name: phrases phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY phrases
    ADD CONSTRAINT phrases_pkey PRIMARY KEY (id);

--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (token);

--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_phrases users_phrases_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users_phrases
    ADD CONSTRAINT users_phrases_pkey PRIMARY KEY (user_id, phrase_id, movie_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: sessions_expiry_idx; Type: INDEX; Schema: public; Owner: testdb
--

CREATE INDEX sessions_expiry_idx ON sessions USING btree (expiry);


--
-- Name: movies movies_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY movies
    ADD CONSTRAINT movies_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: phrases phrases_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY phrases
    ADD CONSTRAINT phrases_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE;


--
-- Name: users users_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: users users_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE;


--
-- Name: users_phrases users_phrases_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users_phrases
    ADD CONSTRAINT users_phrases_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE;


--
-- Name: users_phrases users_phrases_phrase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users_phrases
    ADD CONSTRAINT users_phrases_phrase_id_fkey FOREIGN KEY (phrase_id) REFERENCES phrases(id) ON DELETE CASCADE;


--
-- Name: users_phrases users_phrases_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testdb
--

ALTER TABLE ONLY users_phrases
    ADD CONSTRAINT users_phrases_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


