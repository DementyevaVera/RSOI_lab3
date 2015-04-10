--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: vera; Tablespace: 
--

CREATE TABLE companies (
    id integer NOT NULL,
    name text,
    description text
);


ALTER TABLE public.companies OWNER TO vera;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: vera
--

CREATE SEQUENCE companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_id_seq OWNER TO vera;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vera
--

ALTER SEQUENCE companies_id_seq OWNED BY companies.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: vera; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    company_id integer NOT NULL,
    name text,
    salary money,
    requirements text
);


ALTER TABLE public.jobs OWNER TO vera;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: vera
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobs_id_seq OWNER TO vera;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vera
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: vera; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    scope integer NOT NULL,
    description text
);


ALTER TABLE public.roles OWNER TO vera;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: vera
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO vera;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vera
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: vera; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    user_id text NOT NULL,
    expiration_date timestamp without time zone NOT NULL,
    token text NOT NULL
);


ALTER TABLE public.sessions OWNER TO vera;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: vera
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO vera;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vera
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: vera; Tablespace: 
--

CREATE TABLE users (
    login text NOT NULL,
    pass_hash text NOT NULL,
    role_id integer NOT NULL,
    company_id integer
);


ALTER TABLE public.users OWNER TO vera;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: vera
--

ALTER TABLE ONLY companies ALTER COLUMN id SET DEFAULT nextval('companies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: vera
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: vera
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: vera
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: vera
--

COPY companies (id, name, description) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: vera
--

COPY jobs (id, company_id, name, salary, requirements) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: vera
--

COPY roles (id, scope, description) FROM stdin;
2	19	manager
1	17	customer
3	819	director
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: vera
--

COPY sessions (id, user_id, expiration_date, token) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: vera
--

COPY users (login, pass_hash, role_id, company_id) FROM stdin;
\.


--
-- Name: firms_pkey; Type: CONSTRAINT; Schema: public; Owner: vera; Tablespace: 
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT firms_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: vera; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: vera; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: vera; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (login);


--
-- Name: works_pkey; Type: CONSTRAINT; Schema: public; Owner: vera; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);


--
-- Name: jobs_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vera
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_company_id_fkey FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;


--
-- Name: sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vera
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(login) ON DELETE CASCADE;


--
-- Name: users_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vera
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_company_id_fkey FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;


--
-- Name: users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vera
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

