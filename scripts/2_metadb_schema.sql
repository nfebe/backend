--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12 (Debian 11.12-0+deb10u1)
-- Dumped by pg_dump version 11.12 (Debian 11.12-0+deb10u1)

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
-- Name: ootest; Type: TYPE; Schema: public; Owner: shovel
--

CREATE TYPE public.ootest AS ENUM (
    'web_connectivity',
    'http_requests',
    'dns_consistency',
    'http_invalid_request_line',
    'bridge_reachability',
    'tcp_connect',
    'http_header_field_manipulation',
    'http_host',
    'multi_protocol_traceroute',
    'meek_fronted_requests_test',
    'whatsapp',
    'vanilla_tor',
    'facebook_messenger',
    'ndt',
    'dash',
    'telegram',
    'psiphon',
    'tor',
    'riseupvpn',
    'dnscheck',
    'urlgetter',
    'signal',
    'stunreachability'
);


ALTER TYPE public.ootest OWNER TO shovel;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_expunge; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.account_expunge (
    account_id text NOT NULL,
    threshold timestamp without time zone NOT NULL
);


ALTER TABLE public.account_expunge OWNER TO shovel;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.accounts (
    account_id text NOT NULL,
    role text
);


ALTER TABLE public.accounts OWNER TO shovel;

--
-- Name: autoclavedlookup; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.autoclavedlookup (
    frame_off integer,
    frame_size integer,
    intra_off integer,
    intra_size integer,
    textname text,
    filename text,
    report_id text,
    input text
);


ALTER TABLE public.autoclavedlookup OWNER TO shovel;

--
-- Name: citizenlab; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.citizenlab (
    domain text NOT NULL,
    url text NOT NULL,
    cc character(2),
    category_code text,
    priority smallint DEFAULT 256
);


ALTER TABLE public.citizenlab OWNER TO shovel;

--
-- Name: COLUMN citizenlab.domain; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON COLUMN public.citizenlab.domain IS 'FQDN or ipaddr without http and port number';


--
-- Name: COLUMN citizenlab.category_code; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON COLUMN public.citizenlab.category_code IS 'Category from Citizen Lab';


--
-- Name: counters; Type: TABLE; Schema: public; Owner: shovel
--

CREATE UNLOGGED TABLE public.counters (
    measurement_start_day date,
    test_name text,
    probe_cc character(2) NOT NULL,
    probe_asn integer NOT NULL,
    input text,
    anomaly_count integer,
    confirmed_count integer,
    failure_count integer,
    measurement_count integer
);


ALTER TABLE public.counters OWNER TO shovel;

--
-- Name: counters_asn_noinput; Type: TABLE; Schema: public; Owner: shovel
--

CREATE UNLOGGED TABLE public.counters_asn_noinput (
    measurement_start_day date,
    test_name text,
    probe_cc character(2),
    probe_asn integer,
    anomaly_count bigint,
    confirmed_count bigint,
    failure_count bigint,
    measurement_count bigint
);


ALTER TABLE public.counters_asn_noinput OWNER TO shovel;

--
-- Name: counters_hourly_software; Type: TABLE; Schema: public; Owner: shovel
--

CREATE UNLOGGED TABLE public.counters_hourly_software (
    measurement_start_hour timestamp without time zone NOT NULL,
    platform text,
    software_name text,
    measurement_count bigint
);


ALTER TABLE public.counters_hourly_software OWNER TO shovel;

--
-- Name: counters_hourly_software2; Type: TABLE; Schema: public; Owner: shovel
--

CREATE UNLOGGED TABLE public.counters_hourly_software2 (
    measurement_start_hour timestamp without time zone,
    platform text,
    software_name text,
    measurement_count bigint
);


ALTER TABLE public.counters_hourly_software2 OWNER TO shovel;

--
-- Name: counters_noinput; Type: TABLE; Schema: public; Owner: shovel
--

CREATE UNLOGGED TABLE public.counters_noinput (
    measurement_start_day date,
    test_name text,
    probe_cc character(2),
    anomaly_count bigint,
    confirmed_count bigint,
    failure_count bigint,
    measurement_count bigint
);


ALTER TABLE public.counters_noinput OWNER TO shovel;

--
-- Name: counters_test_list; Type: MATERIALIZED VIEW; Schema: public; Owner: shovel
--

CREATE MATERIALIZED VIEW public.counters_test_list AS
 SELECT counters.probe_cc,
    counters.input,
    sum(counters.measurement_count) AS msmt_cnt
   FROM public.counters
  WHERE ((counters.measurement_start_day < (CURRENT_DATE + '1 day'::interval)) AND (counters.measurement_start_day > (CURRENT_DATE - '8 days'::interval)) AND (counters.test_name = 'web_connectivity'::text))
  GROUP BY counters.probe_cc, counters.input
  WITH NO DATA;


ALTER TABLE public.counters_test_list OWNER TO shovel;

--
-- Name: country_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: shovel
--

CREATE MATERIALIZED VIEW public.country_stats AS
 SELECT min(counters.measurement_start_day) AS first_bucket_date,
    count(DISTINCT counters.probe_asn) AS network_count,
    sum(counters.measurement_count) AS measurement_count,
    counters.probe_cc
   FROM public.counters
  GROUP BY counters.probe_cc
  WITH NO DATA;


ALTER TABLE public.country_stats OWNER TO shovel;

--
-- Name: domain_input; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.domain_input (
    domain text NOT NULL,
    input text NOT NULL,
    input_no integer
);


ALTER TABLE public.domain_input OWNER TO shovel;

--
-- Name: fastpath; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.fastpath (
    measurement_uid text NOT NULL,
    report_id text NOT NULL,
    input text,
    probe_cc character(2) NOT NULL,
    probe_asn integer NOT NULL,
    test_name public.ootest,
    test_start_time timestamp without time zone NOT NULL,
    measurement_start_time timestamp without time zone,
    filename text,
    scores json NOT NULL,
    platform text,
    anomaly boolean,
    confirmed boolean,
    msm_failure boolean,
    domain text,
    software_name text,
    software_version text
);


ALTER TABLE public.fastpath OWNER TO shovel;

--
-- Name: TABLE fastpath; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON TABLE public.fastpath IS 'Measurements created by fastpath';


--
-- Name: COLUMN fastpath.measurement_uid; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON COLUMN public.fastpath.measurement_uid IS 'Trivial ID';


--
-- Name: COLUMN fastpath.filename; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON COLUMN public.fastpath.filename IS 'File served by the fastpath host containing the raw measurement';


--
-- Name: COLUMN fastpath.scores; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON COLUMN public.fastpath.scores IS 'Scoring metadata';


--
-- Name: global_by_month; Type: MATERIALIZED VIEW; Schema: public; Owner: shovel
--

CREATE MATERIALIZED VIEW public.global_by_month AS
 SELECT count(DISTINCT counters_asn_noinput.probe_asn) AS networks_by_month,
    count(DISTINCT counters_asn_noinput.probe_cc) AS countries_by_month,
    sum(counters_asn_noinput.measurement_count) AS measurements_by_month,
    date_trunc('month'::text, (counters_asn_noinput.measurement_start_day)::timestamp with time zone) AS month
   FROM public.counters_asn_noinput
  WHERE (counters_asn_noinput.measurement_start_day > (date_trunc('month'::text, now()) - '2 years'::interval))
  GROUP BY (date_trunc('month'::text, (counters_asn_noinput.measurement_start_day)::timestamp with time zone))
  WITH NO DATA;


ALTER TABLE public.global_by_month OWNER TO shovel;

--
-- Name: global_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: shovel
--

CREATE MATERIALIZED VIEW public.global_stats AS
 SELECT count(DISTINCT counters.probe_asn) AS network_count,
    count(DISTINCT counters.probe_cc) AS country_count,
    sum(counters.measurement_count) AS measurement_count
   FROM public.counters
  WITH NO DATA;


ALTER TABLE public.global_stats OWNER TO shovel;

--
-- Name: jsonl; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.jsonl (
    report_id text NOT NULL,
    input text,
    id integer,
    s3path text NOT NULL,
    linenum integer NOT NULL
);


ALTER TABLE public.jsonl OWNER TO shovel;

--
-- Name: server_ipaddrs; Type: TABLE; Schema: public; Owner: shovel
--

CREATE UNLOGGED TABLE public.server_ipaddrs (
    time_range date,
    report_id text NOT NULL,
    input text NOT NULL,
    domain text NOT NULL,
    probe_cc character(2) NOT NULL,
    orgname text,
    server_asn integer NOT NULL,
    server_ipaddress text NOT NULL,
    anomaly boolean,
    confirmed boolean,
    body_proportion double precision,
    title_match boolean,
    status_code_match boolean,
    blocking_type text
);


ALTER TABLE public.server_ipaddrs OWNER TO shovel;

--
-- Name: session_expunge; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.session_expunge (
    account_id text NOT NULL,
    threshold timestamp without time zone NOT NULL
);


ALTER TABLE public.session_expunge OWNER TO shovel;

--
-- Name: url_priorities; Type: TABLE; Schema: public; Owner: shovel
--

CREATE TABLE public.url_priorities (
    category_code text,
    cc text,
    domain text,
    url text,
    priority smallint NOT NULL
);


ALTER TABLE public.url_priorities OWNER TO shovel;

--
-- Name: COLUMN url_priorities.category_code; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON COLUMN public.url_priorities.category_code IS 'Category from Citizen Lab';


--
-- Name: COLUMN url_priorities.domain; Type: COMMENT; Schema: public; Owner: shovel
--

COMMENT ON COLUMN public.url_priorities.domain IS 'FQDN or ipaddr without http and port number';


--
-- Name: account_expunge account_expunge_pkey; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.account_expunge
    ADD CONSTRAINT account_expunge_pkey PRIMARY KEY (account_id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: fastpath fastpath_pkey; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.fastpath
    ADD CONSTRAINT fastpath_pkey PRIMARY KEY (measurement_uid);


--
-- Name: server_ipaddrs server_ipaddrs_u; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.server_ipaddrs
    ADD CONSTRAINT server_ipaddrs_u UNIQUE (time_range, report_id, input, domain, probe_cc, orgname, server_asn, server_ipaddress, anomaly, confirmed, body_proportion, title_match, status_code_match, blocking_type);


--
-- Name: session_expunge session_expunge_pkey; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.session_expunge
    ADD CONSTRAINT session_expunge_pkey PRIMARY KEY (account_id);


--
-- Name: counters_asn_noinput unique_counters_asn_noinput_cell; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.counters_asn_noinput
    ADD CONSTRAINT unique_counters_asn_noinput_cell UNIQUE (measurement_start_day, test_name, probe_cc, probe_asn);


--
-- Name: counters unique_counters_cell; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.counters
    ADD CONSTRAINT unique_counters_cell UNIQUE (measurement_start_day, test_name, probe_cc, probe_asn, input);


--
-- Name: counters_hourly_software2 unique_counters_hourly_software2_cell; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.counters_hourly_software2
    ADD CONSTRAINT unique_counters_hourly_software2_cell UNIQUE (measurement_start_hour, platform, software_name);


--
-- Name: counters_hourly_software unique_counters_hourly_software_cell; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.counters_hourly_software
    ADD CONSTRAINT unique_counters_hourly_software_cell UNIQUE (measurement_start_hour, platform, software_name);


--
-- Name: counters_noinput unique_counters_noinput_cell; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.counters_noinput
    ADD CONSTRAINT unique_counters_noinput_cell UNIQUE (measurement_start_day, test_name, probe_cc);


--
-- Name: url_priorities url_priorities_category_code_cc_domain_url_key; Type: CONSTRAINT; Schema: public; Owner: shovel
--

ALTER TABLE ONLY public.url_priorities
    ADD CONSTRAINT url_priorities_category_code_cc_domain_url_key UNIQUE (category_code, cc, domain, url);


--
-- Name: autoclavedlookup_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX autoclavedlookup_idx ON public.autoclavedlookup USING hash (md5((report_id || COALESCE(input, ''::text))));


--
-- Name: autoclavedlookup_report2_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX autoclavedlookup_report2_idx ON public.autoclavedlookup USING hash (report_id);


--
-- Name: citizenlab_cc_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX citizenlab_cc_idx ON public.citizenlab USING btree (cc);


--
-- Name: citizenlab_multi_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX citizenlab_multi_idx ON public.citizenlab USING btree (url, domain, category_code, cc);


--
-- Name: counters_asn_noinput_brin_multi_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX counters_asn_noinput_brin_multi_idx ON public.counters_asn_noinput USING brin (measurement_start_day, test_name, probe_cc, probe_asn, anomaly_count, confirmed_count, failure_count, measurement_count) WITH (pages_per_range='16');


--
-- Name: counters_day_brin_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX counters_day_brin_idx ON public.counters USING brin (measurement_start_day) WITH (pages_per_range='4');


--
-- Name: counters_day_cc_asn_input_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX counters_day_cc_asn_input_idx ON public.counters USING btree (measurement_start_day, probe_cc, probe_asn, input);


--
-- Name: counters_day_cc_brin_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX counters_day_cc_brin_idx ON public.counters USING brin (measurement_start_day, probe_cc) WITH (pages_per_range='4');


--
-- Name: counters_multi_brin_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX counters_multi_brin_idx ON public.counters USING brin (measurement_start_day, test_name, probe_cc, probe_asn, input) WITH (pages_per_range='64');


--
-- Name: counters_noinput_brin_multi_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX counters_noinput_brin_multi_idx ON public.counters_noinput USING brin (measurement_start_day, test_name, probe_cc, anomaly_count, confirmed_count, failure_count, measurement_count) WITH (pages_per_range='32');


--
-- Name: counters_test_list_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX counters_test_list_idx ON public.counters_test_list USING btree (probe_cc);


--
-- Name: fastpath_multi_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX fastpath_multi_idx ON public.fastpath USING btree (measurement_start_time, probe_cc, test_name, domain);


--
-- Name: fastpath_report_id_input_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX fastpath_report_id_input_idx ON public.fastpath USING btree (report_id, input);


--
-- Name: jsonl_lookup_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX jsonl_lookup_idx ON public.jsonl USING btree (report_id, input, id);


--
-- Name: measurement_start_time_btree_idx; Type: INDEX; Schema: public; Owner: shovel
--

CREATE INDEX measurement_start_time_btree_idx ON public.fastpath USING btree (measurement_start_time);


--
-- Name: TABLE account_expunge; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.account_expunge TO amsapi;
GRANT SELECT ON TABLE public.account_expunge TO readonly;


--
-- Name: TABLE accounts; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.accounts TO amsapi;
GRANT SELECT ON TABLE public.accounts TO readonly;


--
-- Name: TABLE citizenlab; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.citizenlab TO readonly;
GRANT SELECT ON TABLE public.citizenlab TO amsapi;


--
-- Name: TABLE counters; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.counters TO readonly;
GRANT SELECT ON TABLE public.counters TO amsapi;


--
-- Name: TABLE counters_hourly_software; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.counters_hourly_software TO readonly;
GRANT SELECT ON TABLE public.counters_hourly_software TO amsapi;


--
-- Name: TABLE counters_hourly_software2; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.counters_hourly_software2 TO amsapi;
GRANT SELECT ON TABLE public.counters_hourly_software2 TO readonly;


--
-- Name: TABLE fastpath; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.fastpath TO readonly;
GRANT SELECT ON TABLE public.fastpath TO amsapi;


--
-- Name: TABLE server_ipaddrs; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.server_ipaddrs TO readonly;
GRANT SELECT ON TABLE public.server_ipaddrs TO amsapi;


--
-- Name: TABLE url_priorities; Type: ACL; Schema: public; Owner: shovel
--

GRANT SELECT ON TABLE public.url_priorities TO readonly;
GRANT SELECT ON TABLE public.url_priorities TO amsapi;


--
-- PostgreSQL database dump complete
--

-- The following statements are missing from
-- sudo -u postgres pg_dump -d metadb -s > 2_metadb_schema.sql

GRANT SELECT ON TABLE public.country_stats TO readonly;
GRANT SELECT ON TABLE public.country_stats TO amsapi;

REFRESH MATERIALIZED VIEW public.country_stats;

GRANT SELECT ON TABLE public.global_stats TO readonly;
GRANT SELECT ON TABLE public.global_stats TO amsapi;

REFRESH MATERIALIZED VIEW public.global_stats;

GRANT SELECT ON TABLE public.counters_noinput TO readonly;
GRANT SELECT ON TABLE public.counters_noinput TO amsapi;

GRANT SELECT ON TABLE public.counters_asn_noinput TO readonly;
GRANT SELECT ON TABLE public.counters_asn_noinput TO amsapi;

GRANT SELECT ON TABLE public.session_expunge TO readonly;
GRANT SELECT ON TABLE public.session_expunge TO amsapi;

-- It's a bit weird that the readonly user actually needs to have UPDATE
-- permissions on the accounts table
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.accounts TO readonly;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.accounts TO amsapi;


GRANT INSERT, UPDATE, DELETE ON TABLE public.url_priorities TO readonly;
GRANT INSERT, UPDATE, DELETE ON TABLE public.url_priorities TO amsapi;
