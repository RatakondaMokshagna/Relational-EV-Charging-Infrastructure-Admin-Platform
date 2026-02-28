--
-- PostgreSQL database dump
--

\restrict tGeDbtS7CH4441MMInn6FlhOWehPWNyT9FIw7CUhML8s8dlWZp18AQuP6wVnOd3

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-02-28 16:41:07

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
-- TOC entry 865 (class 1247 OID 16680)
-- Name: point_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.point_status AS ENUM (
    'Available',
    'Occupied',
    'Maintenance'
);


ALTER TYPE public.point_status OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16802)
-- Name: start_charging_session(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.start_charging_session(p_vehicle_id integer, p_point_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_status point_status;
    v_session_id INT;
BEGIN
    SELECT status INTO v_status
    FROM Charging_Point
    WHERE point_id = p_point_id
    FOR UPDATE;

    IF v_status != 'Available' THEN
        RAISE EXCEPTION 'Charging point not available';
    END IF;

    INSERT INTO Charging_Session (vehicle_id, point_id, start_time)
    VALUES (p_vehicle_id, p_point_id, NOW())
    RETURNING session_id INTO v_session_id;

    UPDATE Charging_Point
    SET status = 'Occupied'
    WHERE point_id = p_point_id;

    RETURN v_session_id;
END;
$$;


ALTER FUNCTION public.start_charging_session(p_vehicle_id integer, p_point_id integer) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16803)
-- Name: stop_charging_session(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stop_charging_session(p_session_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_point_id INT;
    v_vehicle_id INT;
    v_duration INT;
    v_max_rate NUMERIC;
    v_battery NUMERIC;
    v_price NUMERIC;
    v_energy NUMERIC;
    v_total NUMERIC;
BEGIN
    SELECT start_time, point_id, vehicle_id
    INTO v_start_time, v_point_id, v_vehicle_id
    FROM Charging_Session
    WHERE session_id = p_session_id
    AND end_time IS NULL
    FOR UPDATE;

    IF v_start_time IS NULL THEN
        RAISE EXCEPTION 'Session not found or already closed';
    END IF;

    v_duration :=
        EXTRACT(EPOCH FROM (NOW() - v_start_time)) / 60;

    SELECT m.max_ac_rate_kw, m.battery_capacity_kwh
    INTO v_max_rate, v_battery
    FROM Vehicle v
    JOIN EV_Model m ON v.model_id = m.model_id
    WHERE v.vehicle_id = v_vehicle_id;

    SELECT c.price_per_kwh
    INTO v_price
    FROM Vehicle v
    JOIN City c ON v.city_id = c.city_id
    WHERE v.vehicle_id = v_vehicle_id;

    v_energy :=
        LEAST((v_max_rate * (v_duration / 60.0)), v_battery);

    v_total := v_energy * v_price;

    UPDATE Charging_Session
    SET end_time = NOW(),
        duration_minutes = v_duration,
        energy_consumed_kwh = v_energy,
        price_per_kwh_snapshot = v_price,
        total_cost = v_total
    WHERE session_id = p_session_id;

    UPDATE Charging_Point
    SET status = 'Available'
    WHERE point_id = v_point_id;
END;
$$;


ALTER FUNCTION public.stop_charging_session(p_session_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16720)
-- Name: charging_point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.charging_point (
    point_id integer NOT NULL,
    station_id integer NOT NULL,
    connector_type character varying(50) NOT NULL,
    max_power_kw numeric(5,2) NOT NULL,
    status public.point_status DEFAULT 'Available'::public.point_status NOT NULL,
    CONSTRAINT charging_point_max_power_kw_check CHECK ((max_power_kw > (0)::numeric))
);


ALTER TABLE public.charging_point OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16719)
-- Name: charging_point_point_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.charging_point_point_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.charging_point_point_id_seq OWNER TO postgres;

--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 223
-- Name: charging_point_point_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.charging_point_point_id_seq OWNED BY public.charging_point.point_id;


--
-- TOC entry 230 (class 1259 OID 16778)
-- Name: charging_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.charging_session (
    session_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    point_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    duration_minutes integer,
    energy_consumed_kwh numeric(8,2),
    price_per_kwh_snapshot numeric(6,2),
    total_cost numeric(10,2),
    CONSTRAINT charging_session_duration_minutes_check CHECK ((duration_minutes >= 0)),
    CONSTRAINT charging_session_energy_consumed_kwh_check CHECK ((energy_consumed_kwh >= (0)::numeric)),
    CONSTRAINT charging_session_total_cost_check CHECK ((total_cost >= (0)::numeric))
);


ALTER TABLE public.charging_session OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16777)
-- Name: charging_session_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.charging_session_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.charging_session_session_id_seq OWNER TO postgres;

--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 229
-- Name: charging_session_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.charging_session_session_id_seq OWNED BY public.charging_session.session_id;


--
-- TOC entry 222 (class 1259 OID 16701)
-- Name: charging_station; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.charging_station (
    station_id integer NOT NULL,
    city_id integer NOT NULL,
    station_name character varying(150) NOT NULL,
    operator_name character varying(150) NOT NULL,
    installation_date date NOT NULL
);


ALTER TABLE public.charging_station OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16700)
-- Name: charging_station_station_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.charging_station_station_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.charging_station_station_id_seq OWNER TO postgres;

--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 221
-- Name: charging_station_station_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.charging_station_station_id_seq OWNED BY public.charging_station.station_id;


--
-- TOC entry 220 (class 1259 OID 16688)
-- Name: city; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.city (
    city_id integer NOT NULL,
    city_name character varying(100) NOT NULL,
    country character varying(100) NOT NULL,
    currency character varying(10) NOT NULL,
    price_per_kwh numeric(6,2) NOT NULL,
    CONSTRAINT city_price_per_kwh_check CHECK ((price_per_kwh > (0)::numeric))
);


ALTER TABLE public.city OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16687)
-- Name: city_city_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.city_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.city_city_id_seq OWNER TO postgres;

--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 219
-- Name: city_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.city_city_id_seq OWNED BY public.city.city_id;


--
-- TOC entry 226 (class 1259 OID 16739)
-- Name: ev_model; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ev_model (
    model_id integer NOT NULL,
    manufacturer character varying(100) NOT NULL,
    model_name character varying(100) NOT NULL,
    battery_capacity_kwh numeric(6,2) NOT NULL,
    max_ac_rate_kw numeric(6,2) NOT NULL,
    CONSTRAINT ev_model_battery_capacity_kwh_check CHECK ((battery_capacity_kwh > (0)::numeric)),
    CONSTRAINT ev_model_max_ac_rate_kw_check CHECK ((max_ac_rate_kw > (0)::numeric))
);


ALTER TABLE public.ev_model OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16738)
-- Name: ev_model_model_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ev_model_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ev_model_model_id_seq OWNER TO postgres;

--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 225
-- Name: ev_model_model_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ev_model_model_id_seq OWNED BY public.ev_model.model_id;


--
-- TOC entry 228 (class 1259 OID 16755)
-- Name: vehicle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicle (
    vehicle_id integer NOT NULL,
    model_id integer NOT NULL,
    registration_number character varying(50) NOT NULL,
    city_id integer NOT NULL
);


ALTER TABLE public.vehicle OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16754)
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehicle_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_vehicle_id_seq OWNER TO postgres;

--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 227
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehicle_vehicle_id_seq OWNED BY public.vehicle.vehicle_id;


--
-- TOC entry 4888 (class 2604 OID 16723)
-- Name: charging_point point_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_point ALTER COLUMN point_id SET DEFAULT nextval('public.charging_point_point_id_seq'::regclass);


--
-- TOC entry 4892 (class 2604 OID 16781)
-- Name: charging_session session_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_session ALTER COLUMN session_id SET DEFAULT nextval('public.charging_session_session_id_seq'::regclass);


--
-- TOC entry 4887 (class 2604 OID 16704)
-- Name: charging_station station_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_station ALTER COLUMN station_id SET DEFAULT nextval('public.charging_station_station_id_seq'::regclass);


--
-- TOC entry 4886 (class 2604 OID 16691)
-- Name: city city_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city ALTER COLUMN city_id SET DEFAULT nextval('public.city_city_id_seq'::regclass);


--
-- TOC entry 4890 (class 2604 OID 16742)
-- Name: ev_model model_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ev_model ALTER COLUMN model_id SET DEFAULT nextval('public.ev_model_model_id_seq'::regclass);


--
-- TOC entry 4891 (class 2604 OID 16758)
-- Name: vehicle vehicle_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicle_vehicle_id_seq'::regclass);


--
-- TOC entry 4907 (class 2606 OID 16732)
-- Name: charging_point charging_point_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_point
    ADD CONSTRAINT charging_point_pkey PRIMARY KEY (point_id);


--
-- TOC entry 4917 (class 2606 OID 16790)
-- Name: charging_session charging_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_session
    ADD CONSTRAINT charging_session_pkey PRIMARY KEY (session_id);


--
-- TOC entry 4903 (class 2606 OID 16713)
-- Name: charging_station charging_station_city_id_station_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_station
    ADD CONSTRAINT charging_station_city_id_station_name_key UNIQUE (city_id, station_name);


--
-- TOC entry 4905 (class 2606 OID 16711)
-- Name: charging_station charging_station_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_station
    ADD CONSTRAINT charging_station_pkey PRIMARY KEY (station_id);


--
-- TOC entry 4901 (class 2606 OID 16699)
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_id);


--
-- TOC entry 4909 (class 2606 OID 16753)
-- Name: ev_model ev_model_manufacturer_model_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ev_model
    ADD CONSTRAINT ev_model_manufacturer_model_name_key UNIQUE (manufacturer, model_name);


--
-- TOC entry 4911 (class 2606 OID 16751)
-- Name: ev_model ev_model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ev_model
    ADD CONSTRAINT ev_model_pkey PRIMARY KEY (model_id);


--
-- TOC entry 4913 (class 2606 OID 16764)
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (vehicle_id);


--
-- TOC entry 4915 (class 2606 OID 16766)
-- Name: vehicle vehicle_registration_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_registration_number_key UNIQUE (registration_number);


--
-- TOC entry 4918 (class 1259 OID 16801)
-- Name: one_active_session_per_point; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX one_active_session_per_point ON public.charging_session USING btree (point_id) WHERE (end_time IS NULL);


--
-- TOC entry 4920 (class 2606 OID 16733)
-- Name: charging_point charging_point_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_point
    ADD CONSTRAINT charging_point_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.charging_station(station_id) ON DELETE CASCADE;


--
-- TOC entry 4923 (class 2606 OID 16796)
-- Name: charging_session charging_session_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_session
    ADD CONSTRAINT charging_session_point_id_fkey FOREIGN KEY (point_id) REFERENCES public.charging_point(point_id);


--
-- TOC entry 4924 (class 2606 OID 16791)
-- Name: charging_session charging_session_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_session
    ADD CONSTRAINT charging_session_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicle(vehicle_id);


--
-- TOC entry 4919 (class 2606 OID 16714)
-- Name: charging_station charging_station_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charging_station
    ADD CONSTRAINT charging_station_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.city(city_id) ON DELETE CASCADE;


--
-- TOC entry 4921 (class 2606 OID 16772)
-- Name: vehicle vehicle_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.city(city_id);


--
-- TOC entry 4922 (class 2606 OID 16767)
-- Name: vehicle vehicle_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.ev_model(model_id);


-- Completed on 2026-02-28 16:41:08

--
-- PostgreSQL database dump complete
--

\unrestrict tGeDbtS7CH4441MMInn6FlhOWehPWNyT9FIw7CUhML8s8dlWZp18AQuP6wVnOd3

