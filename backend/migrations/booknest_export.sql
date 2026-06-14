--
-- PostgreSQL database dump
--

\restrict mEcrCJYPaFF742DDfbWyY0whA1FYVh9CmspYK4zNJDPPT4Xp867YsX22TUQDPED

-- Dumped from database version 18.3 (Postgres.app)
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-14 15:14:52 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16391)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 16550)
-- Name: book_genres; Type: TABLE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE TABLE public.book_genres (
    book_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE public.book_genres OWNER TO georgianaletitiabocancea;

--
-- TOC entry 225 (class 1259 OID 16461)
-- Name: books; Type: TABLE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE TABLE public.books (
    id integer NOT NULL,
    title character varying(500) NOT NULL,
    author character varying(255) NOT NULL,
    year integer,
    description text,
    cover_url text,
    isbn character varying(20),
    added_by_user_id integer,
    created_at timestamp without time zone DEFAULT now(),
    pages integer
);


ALTER TABLE public.books OWNER TO georgianaletitiabocancea;

--
-- TOC entry 224 (class 1259 OID 16460)
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE SEQUENCE public.books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.books_id_seq OWNER TO georgianaletitiabocancea;

--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 224
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: georgianaletitiabocancea
--

ALTER SEQUENCE public.books_id_seq OWNED BY public.books.id;


--
-- TOC entry 223 (class 1259 OID 16450)
-- Name: genres; Type: TABLE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE TABLE public.genres (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.genres OWNER TO georgianaletitiabocancea;

--
-- TOC entry 222 (class 1259 OID 16449)
-- Name: genres_id_seq; Type: SEQUENCE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE SEQUENCE public.genres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.genres_id_seq OWNER TO georgianaletitiabocancea;

--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 222
-- Name: genres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: georgianaletitiabocancea
--

ALTER SEQUENCE public.genres_id_seq OWNED BY public.genres.id;


--
-- TOC entry 229 (class 1259 OID 16525)
-- Name: nestie_conversations; Type: TABLE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE TABLE public.nestie_conversations (
    id integer NOT NULL,
    user_id integer,
    role character varying(20),
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT nestie_conversations_role_check CHECK (((role)::text = ANY ((ARRAY['user'::character varying, 'assistant'::character varying])::text[])))
);


ALTER TABLE public.nestie_conversations OWNER TO georgianaletitiabocancea;

--
-- TOC entry 228 (class 1259 OID 16524)
-- Name: nestie_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE SEQUENCE public.nestie_conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nestie_conversations_id_seq OWNER TO georgianaletitiabocancea;

--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 228
-- Name: nestie_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: georgianaletitiabocancea
--

ALTER SEQUENCE public.nestie_conversations_id_seq OWNED BY public.nestie_conversations.id;


--
-- TOC entry 227 (class 1259 OID 16496)
-- Name: user_books; Type: TABLE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE TABLE public.user_books (
    id integer NOT NULL,
    user_id integer,
    book_id integer,
    status character varying(20) NOT NULL,
    rating smallint,
    review text,
    progress integer DEFAULT 0,
    start_date date,
    finish_date date,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT user_books_progress_non_negative_check CHECK ((progress >= 0)),
    CONSTRAINT user_books_rating_check CHECK (((rating >= 1) AND (rating <= 5))),
    CONSTRAINT user_books_status_check CHECK (((status)::text = ANY ((ARRAY['to_read'::character varying, 'reading'::character varying, 'read'::character varying])::text[])))
);


ALTER TABLE public.user_books OWNER TO georgianaletitiabocancea;

--
-- TOC entry 226 (class 1259 OID 16495)
-- Name: user_books_id_seq; Type: SEQUENCE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE SEQUENCE public.user_books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_books_id_seq OWNER TO georgianaletitiabocancea;

--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 226
-- Name: user_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: georgianaletitiabocancea
--

ALTER SEQUENCE public.user_books_id_seq OWNED BY public.user_books.id;


--
-- TOC entry 221 (class 1259 OID 16430)
-- Name: users; Type: TABLE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    avatar_url text,
    bio text,
    daily_notification boolean DEFAULT false,
    notif_email character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    is_verified boolean DEFAULT false,
    verification_token character varying(255),
    token_expires_at timestamp without time zone,
    reset_token character varying(255),
    reset_token_expires_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO georgianaletitiabocancea;

--
-- TOC entry 220 (class 1259 OID 16429)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: georgianaletitiabocancea
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO georgianaletitiabocancea;

--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: georgianaletitiabocancea
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3738 (class 2604 OID 16464)
-- Name: books id; Type: DEFAULT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public.books_id_seq'::regclass);


--
-- TOC entry 3737 (class 2604 OID 16453)
-- Name: genres id; Type: DEFAULT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.genres ALTER COLUMN id SET DEFAULT nextval('public.genres_id_seq'::regclass);


--
-- TOC entry 3744 (class 2604 OID 16528)
-- Name: nestie_conversations id; Type: DEFAULT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.nestie_conversations ALTER COLUMN id SET DEFAULT nextval('public.nestie_conversations_id_seq'::regclass);


--
-- TOC entry 3740 (class 2604 OID 16499)
-- Name: user_books id; Type: DEFAULT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.user_books ALTER COLUMN id SET DEFAULT nextval('public.user_books_id_seq'::regclass);


--
-- TOC entry 3732 (class 2604 OID 16433)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3937 (class 0 OID 16550)
-- Dependencies: 230
-- Data for Name: book_genres; Type: TABLE DATA; Schema: public; Owner: georgianaletitiabocancea
--

COPY public.book_genres (book_id, genre_id) FROM stdin;
1	7
1	19
2	7
2	19
3	9
3	14
4	16
4	18
5	6
5	18
6	6
6	4
7	10
7	18
8	22
8	6
9	12
9	9
10	6
10	3
11	22
11	6
12	14
12	6
13	6
13	3
14	14
14	5
15	16
15	6
16	22
16	6
17	6
17	3
18	7
18	22
19	14
19	5
20	18
20	6
21	8
21	14
22	12
22	21
23	8
23	10
24	3
24	6
25	7
25	22
26	10
26	6
27	3
27	18
28	4
28	6
29	4
29	6
30	21
30	14
31	6
31	3
32	15
32	20
33	18
33	3
34	15
34	20
35	16
35	3
36	2
36	11
37	12
37	9
38	11
38	2
39	16
39	3
40	1
40	3
41	10
41	6
42	10
42	6
43	3
43	6
44	3
44	6
45	14
45	5
46	3
46	22
47	14
47	5
48	14
48	21
49	3
49	14
50	3
50	6
51	16
51	15
52	15
52	20
53	4
53	6
54	16
54	3
55	14
55	21
56	5
56	21
57	3
57	10
58	16
58	18
59	3
59	8
60	6
60	18
61	7
61	22
62	7
62	22
63	11
63	15
64	2
64	15
65	14
65	5
66	17
66	3
67	8
67	3
68	8
68	3
69	16
69	6
70	21
70	14
71	16
71	4
72	13
72	4
73	3
73	16
74	3
74	6
75	2
75	11
76	16
76	3
77	6
77	3
78	15
78	11
79	15
79	20
80	21
80	14
81	3
81	18
82	16
82	3
83	10
83	6
84	3
84	7
85	17
85	3
86	5
86	14
87	3
87	6
88	16
88	3
89	10
89	3
90	17
90	3
91	3
91	6
92	11
92	15
93	12
93	9
94	18
94	10
95	16
95	3
96	5
96	14
97	16
97	3
98	20
98	16
99	14
99	5
100	14
100	6
101	14
101	5
102	2
102	16
103	9
103	3
104	13
104	3
105	16
105	15
106	6
106	4
107	3
107	6
108	7
108	19
109	15
109	20
110	16
110	15
111	21
111	14
112	8
112	22
113	8
113	22
114	8
114	22
115	8
115	22
116	8
116	22
117	3
117	6
118	4
118	6
119	8
119	22
120	8
120	22
121	3
121	6
122	6
122	5
123	5
123	14
124	6
124	3
125	16
125	3
126	3
126	6
127	14
127	5
128	3
128	16
129	5
129	6
130	16
130	3
131	18
131	6
132	6
132	3
133	12
133	21
134	5
134	14
135	4
135	6
136	14
136	5
137	15
137	20
138	21
138	14
140	8
140	1
140	25
141	26
141	14
142	3
142	27
142	28
143	8
143	29
144	10
144	27
145	30
145	3
146	30
146	25
147	3
147	31
147	27
148	32
148	30
149	10
149	1
150	3
150	23
150	33
151	10
151	3
151	27
152	3
152	18
152	34
153	3
153	18
153	34
154	35
154	36
155	10
155	1
156	10
156	1
157	3
157	27
157	28
158	19
158	21
159	37
159	2
\.


--
-- TOC entry 3932 (class 0 OID 16461)
-- Dependencies: 225
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: georgianaletitiabocancea
--

COPY public.books (id, title, author, year, description, cover_url, isbn, added_by_user_id, created_at, pages) FROM stdin;
1	1984	George Orwell	1949	A seminal dystopian novel that explores the dangers of totalitarianism, mass surveillance, and the manipulation of language and thought through the life of Winston Smith, a man who attempts to rebel against the all-seeing Party and its leader, Big Brother.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1657781256i/61439040.jpg	9780452284234	\N	2026-04-17 16:08:26.951473	368
2	Fahrenheit 451	Ray Bradbury	1953	A dystopian novel set in a future American society where books are outlawed and 'firemen' burn any that are found, centering on Guy Montag, a fireman who begins to question his role and the state's censorship after encountering a free-thinking neighbor.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1383718290i/13079982.jpg	9780345294661	\N	2026-04-17 16:08:26.951473	249
3	Rebecca	Daphne du Maurier	1938	A classic Gothic suspense novel that follows an unnamed young woman who marries a wealthy widower, only to find herself haunted by the lingering shadow and mysterious legacy of his first wife, Rebecca, within the gloomy estate of Manderley.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1386605169i/17899948.jpg	9780316323703	\N	2026-04-17 16:08:26.951473	449
4	Adam si Eva	Liviu Rebreanu	1925	A psychological and metaphysical novel that explores the theme of metempsychosis, tracing the seven successive reincarnations of a single soul through different historical periods, as it searches for its spiritual soulmate across time and space.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1311180813i/778273.jpg	9789732101056	\N	2026-04-17 16:08:26.951473	202
5	Moartea lebedei	Ion Grecea	1970	A Romanian social and psychological novel that explores moral integrity and human resilience within a mid-20th-century professional environment, focusing on the ethical dilemmas and personal sacrifices of individuals facing institutional pressure.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1454255057i/5676939.jpg	9789735571320	\N	2026-04-17 16:08:26.951473	269
6	Every Note Played	Lisa Genova	2018	A poignant contemporary novel that chronicles the physical and emotional decline of a world-renowned concert pianist diagnosed with ALS, focusing on his complex relationship with his estranged ex-wife who becomes his reluctant caregiver.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1521364066i/36082326.jpg	9781476717807	\N	2026-04-17 16:08:26.951473	307
7	The Tattooist of Auschwitz	Heather Morris	2018	A historical novel based on the true story of Lale Sokolov, a Jewish prisoner at Auschwitz-Birkenau who is tasked with tattooing identification numbers on fellow inmates' arms, and his profound, life-sustaining love story with a young woman named Gita.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1525962117i/38359036.jpg	9780062870674	\N	2026-04-17 16:08:26.951473	272
8	Auma's Long Run	Eucabeth A. Odhiambo	2017	Set in a Kenyan village during the 1980s and 90s, this middle-grade historical novel follows Auma, a young girl with a talent for running, as she struggles to pursue her dreams of a medical career while her community is devastated by the AIDS epidemic.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1492472299i/34007206.jpg	9781512427844	\N	2026-04-17 16:08:26.951473	297
9	The Haunting of Hill House	Shirley Jackson	1959	A foundational work of psychological horror that follows four strangers who arrive at a notorious, labyrinthine mansion to study paranormal phenomena, focusing on the fragile mental state of Eleanor Vance as the house seems to exert a malevolent influence over her mind.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1327871336i/89717.jpg	9780143039983	\N	2026-04-17 16:08:26.951473	182
10	Nerantula	Panait Istrati	1927	A poignant Mediterranean novella that explores the themes of raw passion, tragic love, and the harsh social realities of the port of Brăila through the eyes of its youth.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1220451701i/4530976.jpg	9786064611550	\N	2026-04-17 16:08:26.951473	118
11	Seven Days	Eve Ainsworth	2015	A powerful Young Adult novel told from dual perspectives, examining the brutal cycle of school bullying and the deep-seated insecurities of both the victim and the aggressor.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1415222203i/18679049.jpg	9781407146911	\N	2026-04-17 16:08:26.951473	246
12	Elizabeth Is Missing	Emma Healey	2014	A compelling psychological mystery centered on Maud, an elderly woman struggling with dementia who becomes obsessed with solving the disappearance of her friend, despite her crumbling memory.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1388883559i/18635113.jpg	9780062309662	\N	2026-04-17 16:08:26.951473	320
13	Pygmalion	George Bernard Shaw	1913	A classic satirical play that examines the British class system through the story of Henry Higgins, a phonetics professor who attempts to transform a flower girl into a refined lady.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1453757285i/7714.jpg	9780486282220	\N	2026-04-17 16:08:26.951473	82
14	The Hound of the Baskervilles	Arthur Conan Doyle	1902	The most famous Sherlock Holmes novel, blending detective fiction with gothic horror as Holmes investigates a supernatural curse involving a spectral hound on the Devon moors.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1355929358i/8921.jpg	9781503312753	\N	2026-04-17 16:08:26.951473	256
15	Imperativele adolescentei	Chris Simion	2016	A contemporary Romanian work that explores the emotional and existential challenges of adolescence, focusing on the search for identity and the pressures of modern society.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1514653186i/37775024.jpg	9786064003003	\N	2026-04-17 16:08:26.951473	200
16	The Last Time We Say Goodbye	Cynthia Hand	2015	A heart-wrenching Young Adult novel that follows a teenage girl's journey through the stages of grief and guilt following her brother's unexpected suicide.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1403710453i/17285330.jpg	9780062318473	\N	2026-04-17 16:08:26.951473	386
17	Ion	Liviu Rebreanu	1920	A cornerstone of Romanian realist literature, depicting the brutal struggle for land and social status in a Transylvanian village, embodied by the ambitious and tragic figure of Ion.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1389910264i/778255.jpg	9780720646504	\N	2026-04-17 16:08:26.951473	416
18	The Ballad of Songbirds and Snakes	Suzanne Collins	2020	A prequel to The Hunger Games trilogy, following the youth of Coriolanus Snow and his role as a mentor during the 10th Hunger Games, exploring the origins of his rise to power.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1593892032i/51901147.jpg	9781338635171	\N	2026-04-17 16:08:26.951473	541
19	Murder at the Vicarage	Agatha Christie	1930	The first novel to feature Miss Marple, setting the standard for the "village mystery" as the elderly spinster uses her keen observation of human nature to solve a local murder.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1388386575i/16331.jpg	9781579126254	\N	2026-04-17 16:08:26.951473	288
20	Invitatie la vals	Mihail Drumes	1936	One of the most famous Romanian romance novels, depicting the obsessive and turbulent love story between Tudor and Mihaela, exploring themes of passion, pride, and psychological manipulation.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1430264096i/10886702.jpg	9786067109566	\N	2026-04-17 16:08:26.951473	284
21	Piranesi	Susanna Clarke	2020	A high-concept fantasy novel set in a dreamlike, infinite labyrinth known as the House, following a solitary resident who discovers unsettling truths about the nature of his world and his own identity.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1773750050i/50202953.jpg	9781635575637	\N	2026-04-17 16:08:26.951473	245
22	Misery	Stephen King	1987	A tense psychological thriller about Paul Sheldon, a famous novelist who is rescued from a car crash by his "number one fan," only to realize he is being held captive and forced to write a book to her liking.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1746142586i/10614.jpg	9780450417399	\N	2026-04-17 16:08:26.951473	370
23	Circe	Madeline Miller	2018	A feminist reimagining of Greek mythology that follows the banished daughter of Helios as she hones her witchcraft on the island of Aiaia and crosses paths with famous mythological figures like Odysseus.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1565909496i/35959740.jpg	9780316556347	\N	2026-04-17 16:08:26.951473	393
24	The Great Gatsby	F. Scott Fitzgerald	1925	A definitive American classic set in the Jazz Age, exploring themes of social class, wealth, and the corruption of the American Dream through Jay Gatsby's obsessive pursuit of his lost love, Daisy Buchanan.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1650033243i/41733839.jpg	9781853260414	\N	2026-04-17 16:08:26.951473	180
25	Mockingjay	Suzanne Collins	2010	The final installment of The Hunger Games trilogy, where Katniss Everdeen reluctantly becomes the symbol of a mass rebellion against the Capitol and the manipulative President Snow.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1586722918i/7260188.jpg	9780439023511	\N	2026-04-17 16:08:26.951473	390
26	All Quiet on the Western Front	Erich Maria Remarque	1929	A landmark anti-war novel that depicts the extreme physical and mental stress of German soldiers during World War I, highlighting the "lost generation" destroyed by the horrors of the trenches.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1632027397i/355697.jpg	9780449213940	\N	2026-04-17 16:08:26.951473	296
27	Emma	Jane Austen	1815	A classic novel centered on Emma Woodhouse, a clever and wealthy young woman whose confidence in her matchmaking skills leads to misunderstandings, social complications, and ultimately personal growth.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1373627931i/6969.jpg	9780141439587	\N	2026-04-17 16:08:26.951473	474
28	American Dirt	Jeanine Cummins	2020	A controversial contemporary novel that follows a Mexican mother and her son as they flee from a drug cartel, embarking on a perilous journey across the border as undocumented migrants.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1559127861i/45046527.jpg	9781432872243	\N	2026-04-17 16:08:26.951473	459
29	Dear Edward	Ann Napolitano	2020	A moving story about a twelve-year-old boy who is the sole survivor of a devastating plane crash, following his struggle to find meaning and a sense of belonging in the aftermath of unimaginable loss.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1573865448i/45294613.jpg	9781984854780	\N	2026-04-17 16:08:26.951473	340
30	The Silent Patient	Alex Michaelides	2019	A shocking psychological thriller about a famous painter who shoots her husband five times in the face and then never speaks another word, and the forensic psychotherapist obsessed with uncovering her motive.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1668782119i/40097951.jpg	9781250301697	\N	2026-04-17 16:08:26.951473	336
31	Macbeth	William Shakespeare	1606	A dark and bloody tragedy that explores the corrosive psychological and political effects of ambition, as a Scottish nobleman murders his way to the throne and descends into guilt and paranoia.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1671466418i/43913694.jpg	9780998809106	\N	2026-04-17 16:08:26.951473	214
32	Daring Greatly	Brené Brown	2012	A transformative non-fiction work based on twelve years of research, challenging the cultural myth that vulnerability is a weakness and arguing that it is, instead, our most accurate measure of courage.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1337110319i/13588356.jpg	9781592407330	\N	2026-04-17 16:08:26.951473	287
33	Romeo and Juliet	William Shakespeare	1597	The quintessential tragic romance about two young "star-crossed lovers" whose deaths ultimately reconcile their feuding noble families in Verona.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1640420894i/59926998.jpg	9781497438095	\N	2026-04-17 16:08:26.951473	301
34	Atomic Habits	James Clear	2018	A practical guide to self-improvement that focuses on the power of small, incremental changes (atomic habits) and the biological and psychological systems that govern habit formation.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1655988385i/40121378.jpg	9780735211292	\N	2026-04-17 16:08:26.951473	319
35	The Little Prince	Antoine de Saint-Exupéry	1943	A poetic and philosophical novella that uses the journey of a young prince between planets to critique the absurdity of the adult world and celebrate the importance of human connection and imagination.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1367545443i/157993.jpg	9780152023980	\N	2026-04-17 16:08:26.951473	96
36	First They Killed My Father	Loung Ung	2000	A powerful memoir detailing the author's harrowing childhood experiences in Cambodia under the brutal Khmer Rouge regime, chronicling her survival and eventual escape.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1407105580i/4373.jpg	9780060856267	\N	2026-04-17 16:08:26.951473	238
37	Frankenstein	Mary Shelley	1818	A foundational work of science fiction and Gothic horror that tells the story of Victor Frankenstein, a scientist who creates a sentient creature in an unorthodox experiment, leading to tragic consequences.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1631088473i/35031085.jpg	9780143131847	\N	2026-04-17 16:08:26.951473	260
38	The Family Romanovs	Candace Fleming	2014	A compelling non-fiction historical narrative that weaves together the tragic story of the last Russian imperial family with the broader social and political upheaval of the Russian Revolution.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1387147384i/18691014.jpg	9780375867828	\N	2026-04-17 16:08:26.951473	304
39	Steppenwolf	Hermann Hesse	1927	A profound philosophical novel that explores the duality of the human soul—split between man and wolf—and the existential crisis of an intellectual alienated from modern society.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1389332672i/16631.jpg	9780140282580	\N	2026-04-17 16:08:26.951473	256
40	The Count of Monte Cristo	Alexandre Dumas	1844	An epic adventure novel of revenge and redemption, following Edmond Dantès as he escapes a wrongful imprisonment and uses a hidden fortune to systematically destroy those who betrayed him.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1724863997i/7126.jpg	9780140449266	\N	2026-04-17 16:08:26.951473	1276
41	The Boy in the Striped Pyjamas	John Boyne	2006	A devastating historical novel seen through the innocent eyes of Bruno, the son of a Nazi commandant, who develops a forbidden friendship with a Jewish boy held in a concentration camp.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1366228171i/39999.jpg	9780385751070	\N	2026-04-17 16:08:26.951473	224
42	The Book Thief	Markus Zusak	2005	Narrated by Death, this story follows a young girl in Nazi Germany who finds solace in stealing books and sharing them with others, including the Jewish man hidden in her basement.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1522157426i/19063.jpg	9780375842207	\N	2026-04-17 16:08:26.951473	592
43	The Bell Jar	Sylvia Plath	1963	A semi-autobiographical novel that offers a raw and haunting look into the mental breakdown and search for identity of Esther Greenwood amidst the social pressures of 1950s America.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1668645154i/56616095.jpg	9780060837020	\N	2026-04-17 16:08:26.951473	288
44	Breakfast at Tiffany's	Truman Capote	1958	A stylish novella centered on Holly Golightly, a high-society socialite in New York City, and her complex relationship with the narrator, exploring themes of freedom and loneliness.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1739711613i/251688.jpg	9780679745655	\N	2026-04-17 16:08:26.951473	142
45	Murder on the Orient Express	Agatha Christie	1934	One of Hercule Poirot's most famous cases, where the detective must solve a murder committed on a snowbound train, discovering that every passenger has a motive and a secret.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1733926500i/853510.jpg	9780007119318	\N	2026-04-17 16:08:26.951473	274
46	The Catcher in the Rye	J.D. Salinger	1951	A definitive novel on teenage angst and alienation, following Holden Caulfield as he wanders New York City after being expelled from prep school, critiquing the "phoniness" of the adult world.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1398034300i/5107.jpg	9780316769174	\N	2026-04-17 16:08:26.951473	277
47	And Then There Were None	Agatha Christie	1939	A masterpiece of mystery and suspense where ten strangers are invited to an isolated island, only to be killed off one by one in accordance with a sinister nursery rhyme.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1638425885i/16299.jpg	9780312330873	\N	2026-04-17 16:08:26.951473	264
48	The Dinosaur Feather	Sissel-Jo Gazan	2008	A complex Danish scientific thriller that weaves together a murder investigation in a biology department with academic disputes over the evolution of birds from dinosaurs.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1405289242i/17910827.jpg	9781623650674	\N	2026-04-17 16:08:26.951473	448
49	Baltagul	Mihail Sadoveanu	1930	A fundamental Romanian novel following Vitoria Lipan on a mythic journey through the mountains to uncover the truth behind her husband's disappearance and to seek justice.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1228856909i/5984943.jpg	9786069335505	\N	2026-04-17 16:08:26.951473	146
50	Moara cu noroc	Ioan Slavici	1881	A classic Romanian psychological novella exploring the moral disintegration of Ghiță, a tavern keeper whose greed leads to his downfall in a world of crime and corruption.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1390497510i/1711424.jpg	9786063318467	\N	2026-04-17 16:08:26.951473	114
51	Man's Search for Meaning	Viktor E. Frankl	1946	A profound memoir and psychological exploration of the author's survival in Nazi concentration camps, introducing logotherapy as a way to find meaning in suffering.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1535419394i/4069.jpg	9780807014295	\N	2026-04-17 16:08:26.951473	165
52	25 Ways to Win People Over	John C. Maxwell	2005	A practical leadership and communication guide that provides actionable strategies to build positive relationships and influence people through empathy and integrity.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1400610622i/19844.jpg	9780785260943	\N	2026-04-17 16:08:26.951473	208
53	Fresh Water for Flowers	Valérie Perrin	2018	A beautifully written French contemporary novel about Violette, a cemetery keeper who finds hope and hidden stories of love and life while tending to the graves and their visitors.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1570545558i/52649136.jpg	9781609455958	\N	2026-04-17 16:08:26.951473	476
54	Letters to a Young Poet	Rainer Maria Rilke	1929	A timeless collection of ten letters written to an aspiring writer, offering profound insights on solitude, the creative process, and the necessity of looking inward.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1321994947i/46199.jpg	9780486422459	\N	2026-04-17 16:08:26.951473	80
55	Behind Her Eyes	Sarah Pinborough	2017	A gripping psychological thriller with a supernatural twist, following a complex love triangle that leads to a shocking and mind-bending revelation about identity and obsession.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1485279813i/28965131.jpg	9781250111173	\N	2026-04-17 16:08:26.951473	307
56	The Postman Always Rings Twice	James M. Cain	1934	A seminal hardboiled noir novel about an affair between a drifter and a tavern owner's wife that leads them to plot a murder with devastating consequences.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1344265267i/25807.jpg	9780752861746	\N	2026-04-17 16:08:26.951473	116
57	The Hunchback of Notre-Dame	Victor Hugo	1831	A monumental Gothic novel set in medieval Paris, centering on the tragic lives of the gypsy Esmeralda and the bell-ringer Quasimodo beneath the towers of the cathedral.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1388342667i/30597.jpg	9780451527882	\N	2026-04-17 16:08:26.951473	510
58	Nunta in cer	Mircea Eliade	1938	A lyrical Romanian novel exploring the metaphysical and spiritual dimensions of love through the confessions of two men who unwittingly loved the same woman.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1201699667i/1711463.jpg	9789735004118	\N	2026-04-17 16:08:26.951473	200
59	Povestea lui Harap-Alb	Ion Creanga	1877	A foundational Romanian cult-fairy tale that uses allegorical elements to depict the initiatory journey of a young prince as he overcomes trials to achieve moral maturity.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1387622928i/18110150.jpg	9789731984728	\N	2026-04-17 16:08:26.951473	79
60	Maitreyi	Mircea Eliade	1933	A semi-autobiographical novel of intense passion and cultural clash, detailing the tragic love story between a European engineer and the daughter of his Indian host in Calcutta.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1303896468i/817199.jpg	9789735004101	\N	2026-04-17 16:08:26.951473	200
61	The Hunger Games	Suzanne Collins	2008	The first book in a dystopian trilogy where teenagers are forced to participate in a televised death match, following Katniss Everdeen's fight for survival and rebellion.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1586722975i/2767052.jpg	9780439023481	\N	2026-04-17 16:08:26.951473	374
62	Catching Fire	Suzanne Collins	2009	The second installment of the Hunger Games series, chronicling the escalating unrest in the districts and the Capitol's attempt to crush the growing revolution.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1586722941i/6148028.jpg	9780439023498	\N	2026-04-17 16:08:26.951473	391
63	Cele mai crude femei din istorie	Alain Leclercq	2013	A historical non-fiction work that explores the lives and motives of some of the most notorious and ruthless women throughout history.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1587659388i/53250654.jpg	9786063803475	\N	2026-04-17 16:08:26.951473	216
64	House of Gucci	Sara Gay Forden	2000	A true-crime narrative detailing the sensational story of murder, madness, glamour, and greed behind the multi-generational dynasty of the Gucci fashion house.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1438535288i/61013.jpg	9780060937751	\N	2026-04-17 16:08:26.951473	288
65	Razbunarea slutilor	Rodica Ojog-Brasoveanu	1981	A clever Romanian crime novel featuring the eccentric Melania Lupu, blending mystery with dark humor as she orchestrates a series of sophisticated revenge plots.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1345991921i/13503676.jpg	9786068073460	\N	2026-04-17 16:08:26.951473	400
66	Poezii	George Cosbuc	1893	A fundamental collection of Romanian pastoral and patriotic poetry, celebrating rural life, folklore, and the resilience of the peasantry.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1458915003i/29617285.jpg	9786063622076	\N	2026-04-17 16:08:26.951473	414
67	Alice's Adventures in Wonderland	Lewis Carroll	1865	A masterpiece of literary nonsense that follows young Alice as she falls through a rabbit hole into a fantastical world populated by peculiar creatures.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1647953436i/60671823.jpg	9781529002461	\N	2026-04-17 16:08:26.951473	320
68	Through the Looking-Glass	Lewis Carroll	1871	The sequel to Alice's Adventures in Wonderland, where Alice enters a world of mirrors and chess logic, exploring themes of growth and the nature of reality.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1359299332i/83346.jpg	9780688120498	\N	2026-04-17 16:08:26.951473	228
69	Oscar and the Lady in Pink	Éric Emmanuel Schmitt	2002	A deeply moving philosophical novella written as a series of letters to God by a ten-year-old boy with terminal cancer, guided by a volunteer nurse.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1175843195i/565629.jpg	9781843544500	\N	2026-04-17 16:08:26.951473	96
70	The Promise of a Lie	Howard Roughan	2001	A high-stakes psychological thriller following a psychologist who becomes entangled in a dangerous web of deception and murder after a mysterious patient's confession.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1344268387i/646287.jpg	9780446615358	\N	2026-04-17 16:08:26.951473	432
71	The Midnight Library	Matt Haig	2020	A philosophical fantasy novel about Nora Seed, who finds herself in a library between life and death, where each book allows her to try out the lives she could have lived.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1602190253i/52578297.jpg	9780525559474	\N	2026-04-17 16:08:26.951473	288
72	Barbatii sunt niste porci	Rodica Ojog-Brasoveanu	1992	A witty and satirical Romanian crime novel featuring the beloved character Melania Lupu, blending a complex mystery with sharp social commentary and humor.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1399342773i/6456809.jpg	9786064303165	\N	2026-04-17 16:08:26.951473	313
73	The Prophet	Kahlil Gibran	1923	A masterpiece of philosophical poetry and prose, consisting of 26 fables delivered by the prophet Almustafa, offering spiritual wisdom on love, work, and freedom.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1355046521i/2547.jpg	9780001000391	\N	2026-04-17 16:08:26.951473	127
74	Lord of the Flies	William Golding	1954	An allegorical novel about a group of British schoolboys stranded on an uninhabited island, exploring the dark side of human nature and the breakdown of social order.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1327869409i/7624.jpg	9780140283334	\N	2026-04-17 16:08:26.951473	182
75	The Diary of a Young Girl	Anne Frank	1947	The poignant and world-famous diary of a Jewish girl hiding from the Nazis in occupied Amsterdam, documenting her fears, hopes, and personal growth during the Holocaust.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1696989545i/127441416.jpg	9780385480338	\N	2026-04-17 16:08:26.951473	256
76	Too Loud a Solitude	Bohumil Hrabal	1976	A lyrical Czech novel about an old man who works as a paper crusher in Prague, saving rare books from destruction and finding profound wisdom within their pages.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1359996651i/87280.jpg	9780349102627	\N	2026-04-17 16:08:26.951473	112
77	Setea muntelui de sare	Marin Sorescu	1974	A symbolic dramatic trilogy (including Iona) that uses myth and the absurd to explore the tragic condition of man, solitude, and the search for existential meaning.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1554222976i/44771218.jpg	9786067107586	\N	2026-04-17 16:08:26.951473	194
78	12 creatoare care au schimbat istoria	Bertrand Meyer-Stabley	2013	A biographical work (originally 12 créatrices qui ont changé le monde) detailing the lives and revolutionary impacts of influential women in various fields of art and science.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1405888200i/22749172.jpg	9786068564005	\N	2026-04-17 16:08:26.951473	389
79	How to Win Friends & Influence People	Dale Carnegie	1936	One of the best-selling self-help books of all time, providing timeless principles for effective communication, relationship building, and ethical persuasion.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1442726934i/4865.jpg	9780671027032	\N	2026-04-17 16:08:26.951473	288
80	Sharp Objects	Gillian Flynn	2006	A dark psychological thriller about a reporter who returns to her hometown to cover the murders of two preteen girls, while grappling with her own dysfunctional family and self-destructive past.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1475695315i/18045891.jpg	9780297851530	\N	2026-04-17 16:08:26.951473	254
81	Anna Karenina	Leo Tolstoy	1878	A masterpiece of realist fiction that explores themes of love, betrayal, and social hypocrisy in Imperial Russia, following the tragic fate of a high-society woman entangled in a scandalous affair.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1546091617i/15823480.jpg	9780345803924	\N	2026-04-17 16:08:26.951473	964
82	The Screwtape Letters	C.S. Lewis	1942	A satirical Christian apologetic novel written as a series of letters from a senior demon to his nephew, providing a unique perspective on human temptation, morality, and spiritual warfare.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1760782828i/8130077.jpg	9780060652937	\N	2026-04-17 16:08:26.951473	222
83	A Gentleman in Moscow	Amor Towles	2016	A charming historical novel about Count Alexander Rostov, who is sentenced to lifelong house arrest in a luxury hotel across from the Kremlin, finding richness in his limited world.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1718915012i/34066798.jpg	9780670026197	\N	2026-04-17 16:08:26.951473	495
84	Animal Farm	George Orwell	1945	A brilliant political allegory and satirical novella that uses a group of farm animals who rebel against their human farmer to mirror the events leading up to the Russian Revolution and the Stalinist era.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1325861570i/170448.jpg	9780451526342	\N	2026-04-17 16:08:26.951473	141
85	The Flowers of Evil	Charles Baudelaire	1857	A foundational collection of symbolist poetry (originally Les Fleurs du mal) that shocked 19th-century France by exploring themes of decadence, urban beauty, and the "spleen" of modern life.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1756677317i/536387.jpg	9780192835451	\N	2026-04-17 16:08:26.951473	464
86	Jar City	Arnaldur Indriðason	2000	A gritty Icelandic noir novel featuring Detective Erlendur, who investigates a decades-old cold case involving genetic secrets, family tragedies, and the isolation of Iceland’s landscape.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1316129835i/280366.jpg	9780312340704	\N	2026-04-17 16:08:26.951473	275
87	Mesterul Manole	Lucian Blaga	1927	A monumental Romanian expressionist play based on the myth of the sacrificial creator, exploring the tragic necessity of human sacrifice for the sake of an absolute artistic ideal.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1294234419i/6941240.jpg	9789738852761	\N	2026-04-17 16:08:26.951473	360
88	Notes from Underground	Fyodor Dostoevsky	1864	Considered one of the first existentialist novels, it presents the internal monologue of a bitter, isolated narrator in St. Petersburg who rejects the rationalism and progress of the modern world.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1657562670i/49455.jpg	9780679734529	\N	2026-04-17 16:08:26.951473	136
89	Uncle Tom’s Cabin	Harriet Beecher Stowe	1852	A powerful anti-slavery novel that depicted the harsh reality of enslaved people in America, significantly influencing the abolitionist movement and the path toward the American Civil War.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1414349231i/46787.jpg	9780198606697	\N	2026-04-17 16:08:26.951473	438
90	Poems	Mihai Eminescu	1883	The definitive collection of poetry by Romania's national poet, exploring themes of nature, lost love, history, and existential cosmogony through a Late Romantic lens.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1417512000i/778612.jpg	9789732300824	\N	2026-04-17 16:08:26.951473	214
91	One Flew Over the Cuckoo’s Nest	Ken Kesey	1962	Set in an Oregon psychiatric hospital, the novel examines the struggle between individual freedom and institutional authority through the defiant Randle McMurphy.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1360102214i/12697427.jpg	9780670023233	\N	2026-04-17 16:08:26.951473	277
92	The Unwomanly Face of War	Svetlana Alexievich	1985	A groundbreaking oral history featuring the first-hand accounts of hundreds of Soviet women who fought in World War II, revealing the harsh, non-heroic reality of combat.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1481621902i/32905382.jpg	9780399588723	\N	2026-04-17 16:08:26.951473	331
93	Ghost Stories of an Antiquary	M.R. James	1904	A classic collection of supernatural tales that redefined the ghost story genre, moving away from gothic tropes to focus on academic settings and ancient, malevolent artifacts.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1344670655i/1556093.jpg	9780486227580	\N	2026-04-17 16:08:26.951473	157
94	Ultima noapte de dragoste, intaia noapte de razboi	Camil Petrescu	1930	A cornerstone of the Romanian modern novel, exploring the absolute nature of love and the harrowing experience of the first World War through a highly subjective perspective.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1408862675i/768777.jpg	9789735915889	\N	2026-04-17 16:08:26.951473	252
95	On the Shortness of Life	Seneca	49	A timeless Stoic essay providing profound advice on how to value time, avoid meaningful distractions, and achieve a fulfilling life through wisdom and virtue.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1619107079i/97412.jpg	9780143036326	\N	2026-04-17 16:08:26.951473	106
96	Cianura pentru un suras	Rodica Ojog-Brasoveanu	1975	The first novel in the Melania Lupu series, where a sophisticated elderly lady becomes the mastermind behind a complex plot involving stolen paintings and sharp-witted crime.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1428968588i/6424944.jpg	9786064304315	\N	2026-04-17 16:08:26.951473	222
97	Crime and Punishment	Fyodor Dostoevsky	1866	A deep psychological study of Rodion Raskolnikov, a student who murders a pawnbroker to test his theory of "extraordinary" men, leading to his moral and spiritual breakdown.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1382846449i/7144.jpg	9780679734505	\N	2026-04-17 16:08:26.951473	671
98	The Power of Now	Eckhart Tolle	1997	A modern spiritual guide that emphasizes the importance of living in the present moment as a path to ending suffering and achieving spiritual enlightenment.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1689947880i/6708.jpg	9781577314806	\N	2026-04-17 16:08:26.951473	229
99	A Study in Scarlet	Arthur Conan Doyle	1887	The debut novel of Sherlock Holmes and Dr. Watson, introducing their partnership as they investigate a murder linked to a complex backstory involving a Mormon community in Utah.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1519031842i/102868.jpg	9781420925531	\N	2026-04-17 16:08:26.951473	123
100	Where the Crawdads Sing	Delia Owens	2018	A coming-of-age murder mystery set in the marshes of North Carolina, following Kya, a young girl who grows up isolated from society and becomes a suspect in a local killing.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1582135294i/36809135.jpg	9780735219113	\N	2026-04-17 16:08:26.951473	384
101	The Sign of Four	Arthur Conan Doyle	1890	The second Sherlock Holmes novel, involving a complex plot of stolen treasure, a secret pact among four convicts, and the introduction of Mary Morstan.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1739306203i/608474.jpg	9780140439076	\N	2026-04-17 16:08:26.951473	129
102	When Breath Becomes Air	Paul Kalanithi	2016	A profoundly moving memoir written by a young neurosurgeon facing a terminal lung cancer diagnosis, exploring the meaning of life and the transition from doctor to patient.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1492677644i/25899336.jpg	9780812988413	\N	2026-04-17 16:08:26.951473	208
103	The Picture of Dorian Gray	Oscar Wilde	1890	A philosophical Gothic novel about a young man whose portrait ages and records his moral corruption while he remains youthful and beautiful, exploring aestheticism and hedonism.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1454087681i/489732.jpg	9780141439570	\N	2026-04-17 16:08:26.951473	253
104	The Dictionary of Accepted Ideas	Gustave Flaubert	1911	A satirical collection of clichés and commonplaces (originally Le Dictionnaire des idées reçues) mocking the intellectual laziness and prejudices of the 19th-century French bourgeoisie.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1347363976i/2185.jpg	9780811200547	\N	2026-04-17 16:08:26.951473	92
105	The Little Book of Love	Kahlil Gibran	1923	A collection of aphorisms and poetic insights on the nature of love, often compiled from Gibran's most famous spiritual works and personal correspondence.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1372173542i/6070128.jpg	9781851686278	\N	2026-04-17 16:08:26.951473	96
106	The Queen's Gambit	Walter Tevis	1983	A gripping novel about the life of an orphaned chess prodigy, Beth Harmon, as she struggles with addiction while rising to the top of the male-dominated world of grandmaster chess.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1388265750i/62022.jpg	9781400030606	\N	2026-04-17 16:08:26.951473	258
107	Enigma Otiliei	George Calinescu	1938	A fundamental Romanian Balzacian novel that explores the theme of inheritance and social ambition in Bucharest, centered around the mysterious and enigmatic figure of Otilia.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1203971961i/1150759.jpg	9789735915582	\N	2026-04-17 16:08:26.951473	348
108	The Handmaid’s Tale	Margaret Atwood	1985	A chilling dystopian novel set in the near-future Republic of Gilead, where fertile women are forced into reproductive servitude under a patriarchal, totalitarian regime.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1488552336i/34454589.jpg	9781328879943	\N	2026-04-17 16:08:26.951473	320
109	The 5 Love Languages	Gary Chapman	1992	A highly influential relationship guide that identifies five distinct ways people express and experience love, helping couples improve communication and emotional intimacy.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1432487272i/23878688.jpg	9780802492401	\N	2026-04-17 16:08:26.951473	232
110	Staring at the Sun	Irvin Yalom	2008	A profound psychological work by existential psychiatrist Irvin Yalom, exploring how to overcome the terror of death and live a more meaningful, present life.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1720082396i/2062034.jpg	9780787996680	\N	2026-04-17 16:08:26.951473	306
111	The Da Vinci Code	Dan Brown	2003	A fast-paced conspiracy thriller following symbologist Robert Langdon as he investigates a murder in the Louvre, uncovering a secret religious society and a hidden historical truth.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1597798677i/55019161.jpg	9780307474278	\N	2026-04-17 16:08:26.951473	480
112	Harry Potter and the Philosopher’s Stone	J.K. Rowling	1997	The first book in the series, where young Harry Potter discovers his magical heritage and begins his first year at Hogwarts School of Witchcraft and Wizardry.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1598823299i/42844155.jpg	9780747532699	\N	2026-04-17 16:08:26.951473	333
113	Harry Potter and the Chamber of Secrets	J.K. Rowling	1998	Harry returns for his second year at Hogwarts, only to face a mysterious ancient power that is petrifying students and threatening the school's existence.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1474169725i/15881.jpg	9780439064866	\N	2026-04-17 16:08:26.951473	352
114	Harry Potter and the Prisoner of Azkaban	J.K. Rowling	1999	In his third year, Harry deals with the escape of the dangerous convict Sirius Black, while learning more about his parents' past and the Dementors.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1630547330i/5.jpg	9780439655484	\N	2026-04-17 16:08:26.951473	547
115	Harry Potter and the Goblet of Fire	J.K. Rowling	2000	Harry is unexpectedly chosen to compete in the dangerous Triwizard Tournament, leading to the first direct confrontation with the returned Lord Voldemort.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1627044952i/58613424.jpg	9781408855683	\N	2026-04-17 16:08:26.951473	752
116	Harry Potter and the Order of the Phoenix	J.K. Rowling	2003	As the Ministry of Magic denies Voldemort's return, Harry and his friends form a secret group to defend themselves and fight against the growing darkness.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1627045351i/58613451.jpg	9780439358064	\N	2026-04-17 16:08:26.951473	896
117	The Old Man and the Sea	Ernest Hemingway	1952	A classic novella about an aging Cuban fisherman's epic struggle with a giant marlin, exploring themes of endurance, dignity, and man's place in nature.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1329189714i/2165.jpg	9780684830490	\N	2026-04-17 16:08:26.951473	96
118	The Housekeeper and the Professor	Yōko Ogawa	2003	A touching Japanese novel about the relationship between a brilliant mathematician with an 80-minute memory and the housekeeper who cares for him.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1344313042i/3181564.jpg	9780312427801	\N	2026-04-17 16:08:26.951473	180
119	Harry Potter and the Half-Blood Prince	J.K. Rowling	2005	Harry uncovers Voldemort's past and the secret to his immortality through Horcruxes, while the Wizarding World descends into open war.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1627043894i/58613345.jpg	9780439791328	\N	2026-04-17 16:08:26.951473	672
120	Harry Potter and the Deathly Hallows	J.K. Rowling	2007	The final installment, following Harry, Ron, and Hermione as they hunt for the remaining Horcruxes to destroy Voldemort in a climactic battle.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1627042661i/58613224.jpg	9780545010221	\N	2026-04-17 16:08:26.951473	784
121	A Christmas Carol	Charles Dickens	1843	The classic Victorian tale of Ebenezer Scrooge, a miserly man who is transformed into a kinder person after being visited by three ghosts on Christmas Eve.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1406512317i/5326.jpg	9781561797462	\N	2026-04-17 16:08:26.951473	184
122	Apararea are cuvantul	Petre Bellu	1935	A notable Romanian work consisting of courtroom speeches and legal defenses, reflecting on social justice, morality, and the human condition within the interwar legal system.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1404669200i/12166726.jpg	9786066951203	\N	2026-04-17 16:08:26.951473	205
123	Drive Your Plow Over the Bones of the Dead	Olga Tokarczuk	2009	A metaphysical noir novel set in a remote Polish village, exploring themes of animal rights, astrology, and the mystery of local deaths through an eccentric narrator.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1565725457l/51648276.jpg	9780525541332	\N	2026-04-17 16:08:26.951473	274
124	The Kreutzer Sonata	Leo Tolstoy	1889	A controversial novella that uses a train journey confession to explore themes of sexual jealousy, the nature of marriage, and the moral demands of Christianity.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1657554522i/141077.jpg	9780812968231	\N	2026-04-17 16:08:26.951473	129
125	The Death of Ivan Ilych	Leo Tolstoy	1886	A profound philosophical novella that examines the nature of life and death through the terminal illness of a high-court judge who realizes the emptiness of his superficial existence.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1663546974i/18386.jpg	9780553210354	\N	2026-04-17 16:08:26.951473	86
126	To Kill a Mockingbird	Harper Lee	1960	A seminal American novel set in the Depression-era South, exploring racial injustice and the loss of innocence through the eyes of young Scout Finch and her father, Atticus.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1612238791i/56916837.jpg	9780060935467	\N	2026-04-17 16:08:26.951473	323
127	The Murder of Roger Ackroyd	Agatha Christie	1926	A landmark detective novel featuring Hercule Poirot, famous for its revolutionary and controversial plot twist that redefined the conventions of the mystery genre.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1389734015i/16328.jpg	9781579126278	\N	2026-04-17 16:08:26.951473	288
128	The Metamorphosis	Franz Kafka	1915	An existentialist masterpiece telling the story of Gregor Samsa, a salesman who wakes up to find himself transformed into a giant insect, exploring themes of alienation and absurdity.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1646444605i/485894.jpg	9780553213690	\N	2026-04-17 16:08:26.951473	201
129	Perfume: The Story of a Murderer	Patrick Süskind	1985	A dark historical horror novel set in 18th-century France, following Jean-Baptiste Grenouille, a man with a superhuman sense of smell who commits murders to create the "perfect" scent.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1409112276i/343.jpg	9780141041155	\N	2026-04-17 16:08:26.951473	263
130	The Art of Living	Epictetus	135	A collection of Stoic teachings (Enchiridion) compiled by Arrian, offering practical ethical advice on how to achieve tranquility and resilience by focusing only on what we can control.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1388969321i/24618.jpg	9780062513465	\N	2026-04-17 16:08:26.951473	128
131	Norwegian Wood	Haruki Murakami	1987	A nostalgic and melancholic Japanese novel exploring themes of loss, budding sexuality, and mental health through the reminiscences of Toru Watanabe during his college years in Tokyo.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1713542603i/11297.jpg	9780375704024	\N	2026-04-17 16:08:26.951473	296
132	The Sorrows of Young Werther	Johann Wolfgang von Goethe	1774	A key work of the Sturm und Drang movement, written as a series of letters about a sensitive artist’s obsessive and unrequited love, which became a cultural phenomenon in Europe.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1758424070i/16640.jpg	9780812969900	\N	2026-04-17 16:08:26.951473	149
133	Carrie	Stephen King	1974	Stephen King's debut epistolary horror novel about a bullied high school girl who uses her newly discovered telekinetic powers to exact a violent revenge on her classmates.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1771367607i/10592.jpg	9781416524304	\N	2026-04-17 16:08:26.951473	272
134	Crima prin mica publicitate	Rodica Ojog-Brasoveanu	1991	A classic Romanian "policier" where the author blends suspense with her signature humor, focusing on a clever investigation triggered by a seemingly innocent newspaper advertisement.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1330683794i/13507716.jpg	9786064316868	\N	2026-04-17 16:08:26.951473	96
135	Lessons in Chemistry	Bonnie Garmus	2022	A contemporary historical novel set in the 1960s about Elizabeth Zott, a brilliant chemist turned cooking show host who challenges the gender norms and scientific status quo of her time.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1759925297i/242528917.jpg	9781804990926	\N	2026-04-17 16:08:26.951473	390
136	Evil Under the Sun	Agatha Christie	1941	A classic Hercule Poirot mystery set at a secluded seaside resort, where the detective must unravel a complex web of alibis and motives following the murder of a glamorous guest.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1386922974i/16305.jpg	9781579126285	\N	2026-04-17 16:08:26.951473	220
137	Reasons to Stay Alive	Matt Haig	2015	A candid and moving memoir about the author’s personal battle with depression and anxiety, offering hope and practical insights for those struggling with mental health crises.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1453057036i/25733573.jpg	9780143128724	\N	2026-04-17 16:08:26.951473	256
138	The Perfect Son	Freida McFadden	2019	A fast-paced psychological thriller that follows a mother’s desperate attempt to protect her son when he becomes the prime suspect in a local girl’s disappearance.	https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1570489697l/52616342.jpg	9781464228599	\N	2026-04-17 16:08:26.951473	373
140	The Alchemist	Paulo Coelho	1988	The Alchemist is a novel by Paulo Coelho that tells the story of a young shepherd named Santiago, who is on a quest to fulfill his personal legend and find his treasure. Along the way, he meets various people who teach him valuable life lessons and help him on his journey. The novel is a fable about spiritual journey and self-discovery.	https://covers.openlibrary.org/b/id/11556106-L.jpg	\N	1	2026-05-27 09:13:03.477826	\N
141	Do Not Disturb	Freida McFadden	2020	Do Not Disturb is a psychological thriller novel that follows a couple's seemingly perfect life, but things take a dark turn when the wife goes missing. The novel explores themes of marriage, secrets, and the unreliability of appearances. As the story unfolds, the truth behind the wife's disappearance is slowly revealed.	https://covers.openlibrary.org/b/id/15096889-L.jpg	\N	1	2026-05-27 09:13:27.849753	\N
142	Lolita	Vladimir Nabokov	1955	Lolita is a novel by Vladimir Nabokov that tells the story of a middle-aged literature professor who becomes obsessed with a young girl. The novel explores themes of obsession, desire, and the complexities of human relationships. It is considered one of the most controversial and influential novels of the 20th century.	https://covers.openlibrary.org/b/id/12984540-L.jpg	\N	3	2026-05-27 20:57:43.862601	\N
143	A Song of Ice and Fire	George R. R. Martin	1996	A Song of Ice and Fire is a series of fantasy novels by George R. R. Martin, set in the fictional continents of Westeros and Essos. The series follows a sprawling cast of characters as they navigate a complex web of politics, magic, and war. The first book in the series, also titled A Game of Thrones, was published in 1996.	https://covers.openlibrary.org/b/id/8595260-L.jpg	\N	3	2026-05-29 18:48:50.22655	\N
144	Joseph and His Brothers	Thomas Mann	1943	Joseph and His Brothers is a tetralogy of novels by Thomas Mann, telling the story of Joseph's life, from his early days as a favorite son to his rise as a powerful leader in Egypt. The novels are a retelling of the biblical story of Joseph, exploring themes of family, faith, and identity. The work is considered one of Mann's most important and complex literary achievements.	https://covers.openlibrary.org/b/id/14994499-L.jpg	\N	3	2026-06-09 19:48:29.786808	\N
145	Dodsworth	Sinclair Lewis	1929	Dodsworth is a novel by Sinclair Lewis, telling the story of a retired automobile manufacturer, Samuel Dodsworth, and his wife Fran, as they travel through Europe. The novel explores themes of marriage, identity, and the American middle class. It is a commentary on the social and cultural changes of the time.	https://covers.openlibrary.org/b/id/6985982-L.jpg	\N	3	2026-06-09 19:49:45.612187	\N
146	Sobre héroes y tumbas	Ernesto Sabato	1961	Sobre héroes y tumbas is a novel by Argentine writer Ernesto Sabato, published in 1961. The book is a complex exploration of Argentine history, politics, and culture. It delves into the themes of identity, morality, and the human condition.	https://covers.openlibrary.org/b/id/8078732-L.jpg	\N	3	2026-06-09 19:50:33.800317	\N
147	Little Dorrit	Charles Dickens	1857	Little Dorrit is a novel by Charles Dickens, published in serial form between 1855 and 1857. The story revolves around the Dorrit family and their struggles with poverty and social class. The novel explores themes of love, family, and social commentary.	https://covers.openlibrary.org/b/id/13113263-L.jpg	\N	3	2026-06-09 19:51:18.630228	\N
148	Ulysses	James Augustine Joyce	1922	Ulysses is a novel that follows Leopold Bloom as he navigates Dublin, exploring themes of identity, nationality, and the human experience. The book is known for its experimental style and stream-of-consciousness narrative. It is considered one of the most important works of modernist literature.	https://covers.openlibrary.org/b/id/13136548-L.jpg	\N	3	2026-06-09 19:54:20.593426	\N
149	Shogun	James Clavell	1975	Shogun is a historical fiction novel set in feudal Japan, telling the story of an English sailor who becomes embroiled in the intrigues of the samurai class. The novel explores themes of culture clash, politics, and personal identity. It is the first book in Clavell's Asian Saga series.	https://covers.openlibrary.org/b/isbn/9780440178002-L.jpg?default=false	9780440178002	3	2026-06-09 19:56:05.651161	1152
150	David Copperfield	Charles Dickens	1849	David Copperfield is a coming-of-age novel that follows the life of its titular character, from his childhood to adulthood. The story explores themes of love, friendship, and the struggles of growing up. It is considered one of Charles Dickens' most famous works.	https://covers.openlibrary.org/b/id/1048892-L.jpg	\N	3	2026-06-09 19:56:25.747348	\N
151	War and Peace	Leo Tolstoy	1869	War and Peace is a literary masterpiece that follows the lives of several aristocratic Russian families during the Napoleonic Wars. The novel explores themes of love, family, loyalty, and power, set against the backdrop of war and social change. It is considered one of the greatest novels ever written, known for its complex characters, detailed historical context, and philosophical insights.	https://covers.openlibrary.org/b/id/12621906-L.jpg	\N	3	2026-06-09 19:58:42.561495	\N
152	Shirley	Charlotte Brontë	1849	Shirley is a social novel by Charlotte Brontë, published in 1849. The novel follows the lives of two women, Caroline Helstone and Shirley Keeldar, as they navigate love, friendship, and social change in a small Yorkshire village. The novel explores themes of identity, class, and gender in a society undergoing significant transformation.	https://covers.openlibrary.org/b/id/11024634-L.jpg	\N	3	2026-06-09 20:00:09.170185	\N
153	Adam Bede	George Eliot	1859	Adam Bede is a novel by George Eliot, published in 1859. It is set in the English Midlands and tells the story of a young carpenter who falls in love with a beautiful but flawed woman. The novel explores themes of love, morality, and social class.	https://covers.openlibrary.org/b/id/6379692-L.jpg	\N	3	2026-06-09 20:01:01.84785	\N
154	La Comédie humaine	Honoré de Balzac	1799	La Comédie humaine is a vast collection of novels and short stories by Honoré de Balzac, which offers a panoramic view of French society during the period of the Bourbon Restoration and the July Monarchy. The series is known for its intricate and detailed portrayal of characters and society. It is considered one of the greatest achievements of French literature.	https://covers.openlibrary.org/b/id/978076-L.jpg	\N	3	2026-06-09 20:01:48.914608	\N
155	Valois	Alexandre Dumas	1847	Valois is a historical novel by Alexandre Dumas, set in 16th-century France. The story revolves around the royal court of Catherine de' Medici and the intrigues of the Valois dynasty. It explores themes of power, loyalty, and betrayal.	https://covers.openlibrary.org/b/id/14549566-L.jpg	\N	3	2026-06-09 20:05:06.915735	\N
156	La Reine Margot	Alexandre Dumas	1845	La Reine Margot is a historical novel written by Alexandre Dumas. The story takes place in 16th-century France and revolves around the reign of Charles IX and the events leading up to the St. Bartholomew's Day Massacre. It is a tale of love, politics, and betrayal.	https://covers.openlibrary.org/b/id/14557277-L.jpg	\N	3	2026-06-09 20:05:36.099989	\N
157	No Longer Human	Osamu Dazai	1948	No Longer Human is a novel that tells the story of Yozo Oba, a young man who feels disconnected from society and struggles to find his place in the world. The book is a classic of Japanese literature and explores themes of alienation, identity, and the human condition. Through Yozo's story, Dazai offers a powerful and poignant portrayal of the complexities of human existence.	https://covers.openlibrary.org/b/id/14611513-L.jpg	\N	11	2026-06-12 20:56:27.807335	\N
158	Dark Matter	Blake Crouch	2016	Dark Matter is a science fiction thriller novel that follows Jason Dessen, a physicist who is abducted and finds himself in a world where his wife is not his wife and his son was never born. As Jason navigates this new reality, he must confront the consequences of his own choices and the nature of reality itself. The novel explores themes of identity, free will, and the multiverse.	https://covers.openlibrary.org/b/isbn/9781101904220-L.jpg?default=false	9781101904220	11	2026-06-12 20:56:55.683262	336
159	Will	Will Smith	2021	Will is a memoir by Will Smith, covering his life from childhood to his rise as a Hollywood star. The book offers a candid look at his experiences, relationships, and personal growth. With humor and vulnerability, Smith shares his story, providing insight into his life and career.	https://covers.openlibrary.org/b/id/12386822-L.jpg	978-0593234484	11	2026-06-12 20:58:00.103756	432
\.


--
-- TOC entry 3930 (class 0 OID 16450)
-- Dependencies: 223
-- Data for Name: genres; Type: TABLE DATA; Schema: public; Owner: georgianaletitiabocancea
--

COPY public.genres (id, name) FROM stdin;
1	Adventure
2	Biography
3	Classic
4	Contemporary
5	Crime
6	Drama
7	Dystopia
8	Fantasy
9	Gothic
10	Historical Fiction
11	History
12	Horror
13	Humor
14	Mystery
15	Nonfiction
16	Philosophy
17	Poetry
18	Romance
19	Science Fiction
20	Self-help
21	Thriller
22	Young Adult
23	Fiction
24	Tragedy
25	Philosophical fiction
26	Psychological Thriller
27	Literary Fiction
28	Psychological Fiction
29	Epic Fantasy
30	Novel
31	Social commentary
32	Modernist
33	Coming-of-age
34	Social novel
35	Realist fiction
36	Sociological fiction
37	Memoir
\.


--
-- TOC entry 3936 (class 0 OID 16525)
-- Dependencies: 229
-- Data for Name: nestie_conversations; Type: TABLE DATA; Schema: public; Owner: georgianaletitiabocancea
--

COPY public.nestie_conversations (id, user_id, role, content, created_at) FROM stdin;
\.


--
-- TOC entry 3934 (class 0 OID 16496)
-- Dependencies: 227
-- Data for Name: user_books; Type: TABLE DATA; Schema: public; Owner: georgianaletitiabocancea
--

COPY public.user_books (id, user_id, book_id, status, rating, review, progress, start_date, finish_date, created_at, updated_at) FROM stdin;
6	1	1	to_read	\N	\N	0	\N	\N	2026-04-27 07:44:23.353129	2026-04-27 07:44:23.353139
2	1	2	read	5	frumos	105	\N	\N	2026-04-17 13:23:30.782098	2026-04-27 16:07:36.470261
4	1	83	read	5	frumos\n	203	\N	\N	2026-04-27 06:36:12.603126	2026-04-27 16:35:31.651525
5	1	121	reading	\N	\N	108	\N	\N	2026-04-27 07:07:09.522471	2026-04-28 06:36:12.355248
7	3	143	read	3	merge	0	\N	\N	2026-05-29 18:49:16.245583	2026-05-29 18:50:03.544148
13	3	28	to_read	\N	\N	0	\N	\N	2026-06-09 14:42:51.316069	2026-06-09 14:42:51.316073
14	3	47	to_read	\N	\N	0	\N	\N	2026-06-09 14:43:03.723907	2026-06-09 14:43:03.72391
9	3	1	reading	\N	\N	51	\N	\N	2026-05-29 18:50:16.334411	2026-06-09 14:44:51.034905
15	3	153	to_read	\N	\N	0	\N	\N	2026-06-11 08:18:57.975968	2026-06-11 08:18:57.975975
10	3	83	read	5	ok	0	\N	\N	2026-06-09 14:42:30.076543	2026-06-11 08:23:31.972422
11	3	4	read	4	ok	0	\N	\N	2026-06-09 14:42:32.676397	2026-06-11 08:23:36.856713
16	3	78	to_read	\N	\N	0	\N	\N	2026-06-11 08:31:08.178702	2026-06-11 08:31:08.178709
17	3	80	reading	\N	\N	0	\N	\N	2026-06-11 18:20:44.652371	2026-06-11 18:20:44.652377
12	3	52	read	\N	\N	0	\N	\N	2026-06-09 14:42:45.097106	2026-06-11 18:29:13.910094
20	11	14	reading	\N	\N	0	\N	\N	2026-06-12 20:59:32.477206	2026-06-12 20:59:32.47721
19	11	99	read	3	cinstit	0	\N	\N	2026-06-12 20:58:56.05665	2026-06-12 20:59:55.078629
18	11	83	reading	\N	\N	31	\N	\N	2026-06-12 20:58:48.889884	2026-06-12 21:02:35.761662
\.


--
-- TOC entry 3928 (class 0 OID 16430)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: georgianaletitiabocancea
--

COPY public.users (id, email, username, password_hash, avatar_url, bio, daily_notification, notif_email, created_at, updated_at, is_verified, verification_token, token_expires_at, reset_token, reset_token_expires_at) FROM stdin;
1	test@test.com	testuser	pbkdf2:sha256:1000000$qdGXE06eenldH7si$a505935d107775e60078bd04e14c3b751c055adfce071d4167fb0ba75d9a0ec5	\N		f	\N	2026-04-17 13:17:48.749414	2026-04-17 16:17:48.463843	f	\N	\N	\N	\N
3	gbocancea23@gmail.com	Georgiana	pbkdf2:sha256:1000000$Q6NG7zaPzsV3pDjo$9ee4f29e3c84133cb316b9482804fa8a7710855c5a795377915590ceb81c56e7	\N		f	\N	2026-05-27 20:36:54.894419	2026-05-27 23:36:54.614741	t	\N	\N	j6P7qzdEh46Ef1k22IV-B_h-TR258InxkRgcRE5JZzk	2026-06-09 20:34:49.43658
11	calin.stlncn@gmail.com	Calin	pbkdf2:sha256:1000000$sSVlYNXaYbXpQ9MX$2878981f4caf46fd828702debf1ec54d74142c28d2b8aecdf957cb1caa4afcea	\N	calin citeste	f	\N	2026-06-12 20:54:37.848867	2026-06-12 23:54:37.559723	t	\N	\N	\N	\N
\.


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 224
-- Name: books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: georgianaletitiabocancea
--

SELECT pg_catalog.setval('public.books_id_seq', 159, true);


--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 222
-- Name: genres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: georgianaletitiabocancea
--

SELECT pg_catalog.setval('public.genres_id_seq', 37, true);


--
-- TOC entry 3951 (class 0 OID 0)
-- Dependencies: 228
-- Name: nestie_conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: georgianaletitiabocancea
--

SELECT pg_catalog.setval('public.nestie_conversations_id_seq', 1, false);


--
-- TOC entry 3952 (class 0 OID 0)
-- Dependencies: 226
-- Name: user_books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: georgianaletitiabocancea
--

SELECT pg_catalog.setval('public.user_books_id_seq', 20, true);


--
-- TOC entry 3953 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: georgianaletitiabocancea
--

SELECT pg_catalog.setval('public.users_id_seq', 11, true);


--
-- TOC entry 3773 (class 2606 OID 16556)
-- Name: book_genres book_genres_pkey; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.book_genres
    ADD CONSTRAINT book_genres_pkey PRIMARY KEY (book_id, genre_id);


--
-- TOC entry 3761 (class 2606 OID 16472)
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- TOC entry 3757 (class 2606 OID 16459)
-- Name: genres genres_name_key; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_name_key UNIQUE (name);


--
-- TOC entry 3759 (class 2606 OID 16457)
-- Name: genres genres_pkey; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (id);


--
-- TOC entry 3771 (class 2606 OID 16536)
-- Name: nestie_conversations nestie_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.nestie_conversations
    ADD CONSTRAINT nestie_conversations_pkey PRIMARY KEY (id);


--
-- TOC entry 3766 (class 2606 OID 16511)
-- Name: user_books user_books_pkey; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_pkey PRIMARY KEY (id);


--
-- TOC entry 3768 (class 2606 OID 16513)
-- Name: user_books user_books_user_id_book_id_key; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_user_id_book_id_key UNIQUE (user_id, book_id);


--
-- TOC entry 3751 (class 2606 OID 16446)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3753 (class 2606 OID 16444)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3755 (class 2606 OID 16448)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3762 (class 1259 OID 16544)
-- Name: idx_books_author; Type: INDEX; Schema: public; Owner: georgianaletitiabocancea
--

CREATE INDEX idx_books_author ON public.books USING btree (author);


--
-- TOC entry 3769 (class 1259 OID 16545)
-- Name: idx_nestie_user; Type: INDEX; Schema: public; Owner: georgianaletitiabocancea
--

CREATE INDEX idx_nestie_user ON public.nestie_conversations USING btree (user_id, created_at);


--
-- TOC entry 3763 (class 1259 OID 16543)
-- Name: idx_user_books_status; Type: INDEX; Schema: public; Owner: georgianaletitiabocancea
--

CREATE INDEX idx_user_books_status ON public.user_books USING btree (user_id, status);


--
-- TOC entry 3764 (class 1259 OID 16542)
-- Name: idx_user_books_user; Type: INDEX; Schema: public; Owner: georgianaletitiabocancea
--

CREATE INDEX idx_user_books_user ON public.user_books USING btree (user_id);


--
-- TOC entry 3778 (class 2606 OID 16557)
-- Name: book_genres book_genres_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.book_genres
    ADD CONSTRAINT book_genres_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- TOC entry 3779 (class 2606 OID 16562)
-- Name: book_genres book_genres_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.book_genres
    ADD CONSTRAINT book_genres_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genres(id) ON DELETE CASCADE;


--
-- TOC entry 3774 (class 2606 OID 16473)
-- Name: books books_added_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_added_by_user_id_fkey FOREIGN KEY (added_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 3777 (class 2606 OID 16537)
-- Name: nestie_conversations nestie_conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.nestie_conversations
    ADD CONSTRAINT nestie_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3775 (class 2606 OID 16519)
-- Name: user_books user_books_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- TOC entry 3776 (class 2606 OID 16514)
-- Name: user_books user_books_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: georgianaletitiabocancea
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-06-14 15:14:56 EEST

--
-- PostgreSQL database dump complete
--

\unrestrict mEcrCJYPaFF742DDfbWyY0whA1FYVh9CmspYK4zNJDPPT4Xp867YsX22TUQDPED

