--
-- PostgreSQL database cluster dump
--

\restrict EqU8O0oBZUhoceE6S9p9U10pzmBkufN3UkpZezH5N4Sk3r9tUiBEhP3zIpw2YnT

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE "user";
ALTER ROLE "user" WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:tD+LxkhLaOu91YHeWVirJg==$jaMKucF62nLo/OhBsWDPQ5GX9qhxD8wkRfvQt434KC0=:9cTdieIieFr6MPVzs6TjxR78UUBHdMDMwBzxldUtL2Q=';

--
-- User Configurations
--








\unrestrict EqU8O0oBZUhoceE6S9p9U10pzmBkufN3UkpZezH5N4Sk3r9tUiBEhP3zIpw2YnT

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict tAW7BvQWIfRg8A4cnD4N1RPawoU94x5XbN5r2eWonLIuh3kK4YrMBbFBl69JY2N

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

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
-- PostgreSQL database dump complete
--

\unrestrict tAW7BvQWIfRg8A4cnD4N1RPawoU94x5XbN5r2eWonLIuh3kK4YrMBbFBl69JY2N

--
-- Database "mydb" dump
--

--
-- PostgreSQL database dump
--

\restrict rVUa5sGWA8DOo5gLmHr627UbQnuVb9Zkt0gYu3nFjbH6Dgmvo0g1BTG2PIBNIGe

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

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
-- Name: mydb; Type: DATABASE; Schema: -; Owner: user
--

CREATE DATABASE mydb WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE mydb OWNER TO "user";

\unrestrict rVUa5sGWA8DOo5gLmHr627UbQnuVb9Zkt0gYu3nFjbH6Dgmvo0g1BTG2PIBNIGe
\connect mydb
\restrict rVUa5sGWA8DOo5gLmHr627UbQnuVb9Zkt0gYu3nFjbH6Dgmvo0g1BTG2PIBNIGe

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
-- PostgreSQL database dump complete
--

\unrestrict rVUa5sGWA8DOo5gLmHr627UbQnuVb9Zkt0gYu3nFjbH6Dgmvo0g1BTG2PIBNIGe

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict 36SVyh5ztsuZDgBKdIvH6Esp5c7ZmodGmv1GybNCLB8MNfeozlPJaQxeiKR079E

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

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
-- PostgreSQL database dump complete
--

\unrestrict 36SVyh5ztsuZDgBKdIvH6Esp5c7ZmodGmv1GybNCLB8MNfeozlPJaQxeiKR079E

--
-- PostgreSQL database cluster dump complete
--

