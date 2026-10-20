--
-- PostgreSQL database dump
--

\restrict cDdLyT2BrDNZtLB4BRlepQn4uG71xIid7c5cynLBEPAC6dSPgZBU8dQ8GPiHaab

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: daily_nutrition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_nutrition (
    id text NOT NULL,
    user_id text NOT NULL,
    date date NOT NULL,
    total_calories double precision DEFAULT 0 NOT NULL,
    total_protein double precision DEFAULT 0 NOT NULL,
    total_carbs double precision DEFAULT 0 NOT NULL,
    total_fat double precision DEFAULT 0 NOT NULL,
    total_fiber double precision DEFAULT 0 NOT NULL,
    total_scans integer DEFAULT 0 NOT NULL
);


--
-- Name: food_feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.food_feedbacks (
    id text NOT NULL,
    user_id text NOT NULL,
    food_id text,
    food_name text NOT NULL,
    taste_rating integer,
    texture_rating integer,
    aroma_rating integer,
    portion_rating integer,
    satisfaction_rating integer,
    consumption_status text,
    suggestion text,
    submitted_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: food_ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.food_ratings (
    id text NOT NULL,
    user_id text NOT NULL,
    food_id text,
    food_name text NOT NULL,
    rating integer NOT NULL,
    reason text,
    rated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: foods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.foods (
    id text NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    image_url text,
    description text,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: mbg_menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mbg_menu_items (
    id text NOT NULL,
    menu_id text NOT NULL,
    food_id text NOT NULL,
    portion_gram double precision DEFAULT 100 NOT NULL
);


--
-- Name: mbg_menus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mbg_menus (
    id text NOT NULL,
    school_id text NOT NULL,
    date date NOT NULL,
    day_name text NOT NULL
);


--
-- Name: menu_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_requests (
    id text NOT NULL,
    user_id text NOT NULL,
    menu_name text NOT NULL,
    reason text,
    status text DEFAULT 'received'::text NOT NULL,
    admin_note text,
    submitted_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: nutrition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nutrition (
    id text NOT NULL,
    food_id text NOT NULL,
    calories double precision NOT NULL,
    protein double precision NOT NULL,
    carbs double precision NOT NULL,
    fat double precision NOT NULL,
    fiber double precision NOT NULL,
    sugar double precision DEFAULT 0 NOT NULL,
    sodium double precision DEFAULT 0 NOT NULL,
    calcium double precision DEFAULT 0 NOT NULL,
    iron double precision DEFAULT 0 NOT NULL,
    vitamin_c double precision DEFAULT 0 NOT NULL,
    vitamin_a double precision DEFAULT 0 NOT NULL,
    portion_gram double precision DEFAULT 100 NOT NULL,
    cooking_method text,
    data_source text DEFAULT 'TKPI 2017'::text NOT NULL
);


--
-- Name: predictions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.predictions (
    id text NOT NULL,
    scan_id text NOT NULL,
    food_id text NOT NULL,
    confidence double precision NOT NULL,
    portion_estimate_gram double precision DEFAULT 100 NOT NULL,
    weight_input_gram double precision,
    calories double precision,
    protein double precision,
    carbs double precision,
    fat double precision
);


--
-- Name: scan_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scan_history (
    id text NOT NULL,
    user_id text NOT NULL,
    image_url text,
    scanned_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    total_calories double precision DEFAULT 0 NOT NULL,
    total_protein double precision DEFAULT 0 NOT NULL,
    total_carbs double precision DEFAULT 0 NOT NULL,
    total_fat double precision DEFAULT 0 NOT NULL,
    total_fiber double precision DEFAULT 0 NOT NULL,
    status text DEFAULT 'success'::text NOT NULL,
    akg_target text,
    sensory_data jsonb,
    consumption_data jsonb
);


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
    id text NOT NULL,
    name text NOT NULL,
    level text NOT NULL,
    address text,
    city text
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    role text DEFAULT 'student'::text NOT NULL,
    school_id text,
    class text,
    gender text,
    age integer,
    profile_image_url text,
    school_level text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Data for Name: daily_nutrition; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.daily_nutrition (id, user_id, date, total_calories, total_protein, total_carbs, total_fat, total_fiber, total_scans) FROM stdin;
\.


--
-- Data for Name: food_feedbacks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.food_feedbacks (id, user_id, food_id, food_name, taste_rating, texture_rating, aroma_rating, portion_rating, satisfaction_rating, consumption_status, suggestion, submitted_at) FROM stdin;
\.


--
-- Data for Name: food_ratings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.food_ratings (id, user_id, food_id, food_name, rating, reason, rated_at) FROM stdin;
\.


--
-- Data for Name: foods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.foods (id, name, category, image_url, description, is_active) FROM stdin;
\.


--
-- Data for Name: mbg_menu_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mbg_menu_items (id, menu_id, food_id, portion_gram) FROM stdin;
\.


--
-- Data for Name: mbg_menus; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mbg_menus (id, school_id, date, day_name) FROM stdin;
\.


--
-- Data for Name: menu_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.menu_requests (id, user_id, menu_name, reason, status, admin_note, submitted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: nutrition; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.nutrition (id, food_id, calories, protein, carbs, fat, fiber, sugar, sodium, calcium, iron, vitamin_c, vitamin_a, portion_gram, cooking_method, data_source) FROM stdin;
\.


--
-- Data for Name: predictions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.predictions (id, scan_id, food_id, confidence, portion_estimate_gram, weight_input_gram, calories, protein, carbs, fat) FROM stdin;
\.


--
-- Data for Name: scan_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.scan_history (id, user_id, image_url, scanned_at, total_calories, total_protein, total_carbs, total_fat, total_fiber, status, akg_target, sensory_data, consumption_data) FROM stdin;
\.


--
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schools (id, name, level, address, city) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, password_hash, role, school_id, class, gender, age, profile_image_url, school_level, created_at, updated_at) FROM stdin;
796080e4-a3c8-4c14-a631-50cff3ef3f8c	Admin MBG	admin@mbg.test	$2a$12$GW/DplDaUqYMqgHizWgdXeXTxpncuX52OrsNcSt5oR3k0gIBbN56.	admin	\N	\N	\N	\N	\N	\N	2026-10-14 19:15:14.254	2026-10-14 19:15:14.254
\.


--
-- Name: daily_nutrition daily_nutrition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_nutrition
    ADD CONSTRAINT daily_nutrition_pkey PRIMARY KEY (id);


--
-- Name: food_feedbacks food_feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_feedbacks
    ADD CONSTRAINT food_feedbacks_pkey PRIMARY KEY (id);


--
-- Name: food_ratings food_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_ratings
    ADD CONSTRAINT food_ratings_pkey PRIMARY KEY (id);


--
-- Name: foods foods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_pkey PRIMARY KEY (id);


--
-- Name: mbg_menu_items mbg_menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mbg_menu_items
    ADD CONSTRAINT mbg_menu_items_pkey PRIMARY KEY (id);


--
-- Name: mbg_menus mbg_menus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mbg_menus
    ADD CONSTRAINT mbg_menus_pkey PRIMARY KEY (id);


--
-- Name: menu_requests menu_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_requests
    ADD CONSTRAINT menu_requests_pkey PRIMARY KEY (id);


--
-- Name: nutrition nutrition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nutrition
    ADD CONSTRAINT nutrition_pkey PRIMARY KEY (id);


--
-- Name: predictions predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (id);


--
-- Name: scan_history scan_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_history
    ADD CONSTRAINT scan_history_pkey PRIMARY KEY (id);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: daily_nutrition_user_id_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX daily_nutrition_user_id_date_key ON public.daily_nutrition USING btree (user_id, date);


--
-- Name: mbg_menus_school_id_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mbg_menus_school_id_date_key ON public.mbg_menus USING btree (school_id, date);


--
-- Name: nutrition_food_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX nutrition_food_id_key ON public.nutrition USING btree (food_id);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: daily_nutrition daily_nutrition_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_nutrition
    ADD CONSTRAINT daily_nutrition_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: food_feedbacks food_feedbacks_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_feedbacks
    ADD CONSTRAINT food_feedbacks_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: food_feedbacks food_feedbacks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_feedbacks
    ADD CONSTRAINT food_feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: food_ratings food_ratings_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_ratings
    ADD CONSTRAINT food_ratings_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: food_ratings food_ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_ratings
    ADD CONSTRAINT food_ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mbg_menu_items mbg_menu_items_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mbg_menu_items
    ADD CONSTRAINT mbg_menu_items_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mbg_menu_items mbg_menu_items_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mbg_menu_items
    ADD CONSTRAINT mbg_menu_items_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.mbg_menus(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mbg_menus mbg_menus_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mbg_menus
    ADD CONSTRAINT mbg_menus_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: menu_requests menu_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_requests
    ADD CONSTRAINT menu_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: nutrition nutrition_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nutrition
    ADD CONSTRAINT nutrition_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: predictions predictions_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: predictions predictions_scan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_scan_id_fkey FOREIGN KEY (scan_id) REFERENCES public.scan_history(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: scan_history scan_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_history
    ADD CONSTRAINT scan_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict cDdLyT2BrDNZtLB4BRlepQn4uG71xIid7c5cynLBEPAC6dSPgZBU8dQ8GPiHaab

