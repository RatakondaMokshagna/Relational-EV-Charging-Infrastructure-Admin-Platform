--
-- PostgreSQL database dump
--

\restrict J4ZDDkzYZk5trYeycWsIiWpuebAVfRvdr4Pa2ImzGRfsPQmqFzrHFqUCZBtNQCW

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-02-28 16:42:15

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
-- TOC entry 5059 (class 0 OID 16688)
-- Dependencies: 220
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.city (city_id, city_name, country, currency, price_per_kwh) FROM stdin;
1	Bangalore	India	INR	18.00
2	Mumbai	India	INR	20.00
3	Munich	Germany	EUR	0.45
4	London	United Kingdom	GBP	0.52
5	New York City	USA	USD	0.40
\.


--
-- TOC entry 5061 (class 0 OID 16701)
-- Dependencies: 222
-- Data for Name: charging_station; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.charging_station (station_id, city_id, station_name, operator_name, installation_date) FROM stdin;
1	1	BLR-Central	VoltGrid	2026-02-28
2	2	MUM-Central	VoltGrid	2026-02-28
3	3	MUC-Central	VoltGrid	2026-02-28
4	4	LDN-Central	VoltGrid	2026-02-28
5	5	NYC-Central	VoltGrid	2026-02-28
6	1	Bangalore-Station-1	VoltGrid	2026-02-28
7	2	Mumbai-Station-1	VoltGrid	2026-02-28
8	3	Munich-Station-1	VoltGrid	2026-02-28
9	4	London-Station-1	VoltGrid	2026-02-28
10	5	New York City-Station-1	VoltGrid	2026-02-28
11	1	Bangalore-Station-2	VoltGrid	2026-02-28
12	2	Mumbai-Station-2	VoltGrid	2026-02-28
13	3	Munich-Station-2	VoltGrid	2026-02-28
14	4	London-Station-2	VoltGrid	2026-02-28
15	5	New York City-Station-2	VoltGrid	2026-02-28
16	1	Bangalore-Station-3	VoltGrid	2026-02-28
17	2	Mumbai-Station-3	VoltGrid	2026-02-28
18	3	Munich-Station-3	VoltGrid	2026-02-28
19	4	London-Station-3	VoltGrid	2026-02-28
20	5	New York City-Station-3	VoltGrid	2026-02-28
21	1	Bangalore-Station-4	VoltGrid	2026-02-28
22	2	Mumbai-Station-4	VoltGrid	2026-02-28
23	3	Munich-Station-4	VoltGrid	2026-02-28
24	4	London-Station-4	VoltGrid	2026-02-28
25	5	New York City-Station-4	VoltGrid	2026-02-28
\.


--
-- TOC entry 5063 (class 0 OID 16720)
-- Dependencies: 224
-- Data for Name: charging_point; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.charging_point (point_id, station_id, connector_type, max_power_kw, status) FROM stdin;
5	5	AC Type 2	11.00	Available
6	1	AC Type 2	11.00	Available
8	3	AC Type 2	11.00	Available
14	9	AC Type 2	11.00	Available
7	2	AC Type 2	11.00	Available
10	5	AC Type 2	11.00	Available
11	6	AC Type 2	11.00	Available
12	7	AC Type 2	11.00	Available
13	8	AC Type 2	11.00	Available
15	10	AC Type 2	11.00	Available
16	11	AC Type 2	11.00	Available
17	12	AC Type 2	11.00	Available
18	13	AC Type 2	11.00	Available
19	14	AC Type 2	11.00	Available
20	15	AC Type 2	11.00	Available
21	16	AC Type 2	11.00	Available
22	17	AC Type 2	11.00	Available
23	18	AC Type 2	11.00	Available
24	19	AC Type 2	11.00	Available
25	20	AC Type 2	11.00	Available
26	21	AC Type 2	11.00	Available
27	22	AC Type 2	11.00	Available
28	23	AC Type 2	11.00	Available
29	24	AC Type 2	11.00	Available
30	25	AC Type 2	11.00	Available
31	1	AC Type 2	11.00	Available
32	2	AC Type 2	11.00	Available
33	3	AC Type 2	11.00	Available
34	4	AC Type 2	11.00	Available
35	5	AC Type 2	11.00	Available
36	6	AC Type 2	11.00	Available
37	7	AC Type 2	11.00	Available
38	8	AC Type 2	11.00	Available
39	9	AC Type 2	11.00	Available
40	10	AC Type 2	11.00	Available
41	11	AC Type 2	11.00	Available
42	12	AC Type 2	11.00	Available
43	13	AC Type 2	11.00	Available
44	14	AC Type 2	11.00	Available
45	15	AC Type 2	11.00	Available
46	16	AC Type 2	11.00	Available
47	17	AC Type 2	11.00	Available
48	18	AC Type 2	11.00	Available
49	19	AC Type 2	11.00	Available
50	20	AC Type 2	11.00	Available
51	21	AC Type 2	11.00	Available
52	22	AC Type 2	11.00	Available
53	23	AC Type 2	11.00	Available
54	24	AC Type 2	11.00	Available
55	25	AC Type 2	11.00	Available
56	1	AC Type 2	11.00	Available
57	2	AC Type 2	11.00	Available
58	3	AC Type 2	11.00	Available
59	4	AC Type 2	11.00	Available
60	5	AC Type 2	11.00	Available
61	6	AC Type 2	11.00	Available
62	7	AC Type 2	11.00	Available
63	8	AC Type 2	11.00	Available
64	9	AC Type 2	11.00	Available
65	10	AC Type 2	11.00	Available
66	11	AC Type 2	11.00	Available
67	12	AC Type 2	11.00	Available
68	13	AC Type 2	11.00	Available
69	14	AC Type 2	11.00	Available
70	15	AC Type 2	11.00	Available
71	16	AC Type 2	11.00	Available
72	17	AC Type 2	11.00	Available
73	18	AC Type 2	11.00	Available
74	19	AC Type 2	11.00	Available
75	20	AC Type 2	11.00	Available
76	21	AC Type 2	11.00	Available
77	22	AC Type 2	11.00	Available
78	23	AC Type 2	11.00	Available
79	24	AC Type 2	11.00	Available
80	25	AC Type 2	11.00	Available
81	1	AC Type 2	11.00	Available
82	2	AC Type 2	11.00	Available
83	3	AC Type 2	11.00	Available
84	4	AC Type 2	11.00	Available
85	5	AC Type 2	11.00	Available
86	6	AC Type 2	11.00	Available
87	7	AC Type 2	11.00	Available
88	8	AC Type 2	11.00	Available
89	9	AC Type 2	11.00	Available
90	10	AC Type 2	11.00	Available
91	11	AC Type 2	11.00	Available
92	12	AC Type 2	11.00	Available
93	13	AC Type 2	11.00	Available
94	14	AC Type 2	11.00	Available
95	15	AC Type 2	11.00	Available
96	16	AC Type 2	11.00	Available
97	17	AC Type 2	11.00	Available
98	18	AC Type 2	11.00	Available
99	19	AC Type 2	11.00	Available
100	20	AC Type 2	11.00	Available
101	21	AC Type 2	11.00	Available
102	22	AC Type 2	11.00	Available
103	23	AC Type 2	11.00	Available
104	24	AC Type 2	11.00	Available
105	25	AC Type 2	11.00	Available
4	4	AC Type 2	11.00	Available
2	2	AC Type 2	11.00	Available
9	4	AC Type 2	11.00	Available
3	3	AC Type 2	11.00	Available
1	1	AC Type 2	11.00	Available
\.


--
-- TOC entry 5065 (class 0 OID 16739)
-- Dependencies: 226
-- Data for Name: ev_model; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ev_model (model_id, manufacturer, model_name, battery_capacity_kwh, max_ac_rate_kw) FROM stdin;
1	Tesla	Model 3	60.00	11.00
2	BMW	i4	67.00	11.00
3	Hyundai	Kona Electric	64.00	11.00
4	Volkswagen	ID.4	77.00	11.00
5	Tata	Nexon EV	40.00	7.20
\.


--
-- TOC entry 5067 (class 0 OID 16755)
-- Dependencies: 228
-- Data for Name: vehicle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicle (vehicle_id, model_id, registration_number, city_id) FROM stdin;
1	3	TN-22-1001	4
2	2	AP-30-1111	2
3	1	AP-30-1112	1
4	1	AP-30-1113	1
5	3	AP-30-1212	1
6	3	London-56	4
7	4	DE-21	3
8	3	NYC-21-E	5
\.


--
-- TOC entry 5069 (class 0 OID 16778)
-- Dependencies: 230
-- Data for Name: charging_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.charging_session (session_id, vehicle_id, point_id, start_time, end_time, duration_minutes, energy_consumed_kwh, price_per_kwh_snapshot, total_cost) FROM stdin;
3	3	1	2026-02-28 15:05:09.908711	2026-02-28 15:05:22.614509	0	0.00	18.00	0.00
4	4	1	2026-02-28 15:05:22.616901	2026-02-28 15:05:44.478888	0	0.00	18.00	0.00
1	1	4	2026-02-28 14:57:07.917389	2026-02-28 15:19:11.252361	22	4.03	0.52	2.10
2	2	2	2026-02-28 15:01:14.330272	2026-02-28 15:19:31.365776	18	3.30	20.00	66.00
7	3	9	2026-02-28 15:30:50.274142	2026-02-28 15:31:13.009113	0	0.00	18.00	0.00
6	1	3	2026-02-28 15:30:39.822942	2026-02-28 15:31:18.003077	1	0.18	0.52	0.10
5	5	1	2026-02-28 15:30:08.193216	2026-02-28 15:31:21.343059	1	0.18	18.00	3.30
11	8	5	2026-02-28 16:13:51.897298	2026-02-28 16:14:33.029037	1	0.18	0.40	0.07
8	2	6	2026-02-28 16:12:40.799411	2026-02-28 16:15:37.868945	3	0.55	20.00	11.00
10	7	8	2026-02-28 16:13:19.98802	2026-02-28 16:16:08.459284	3	0.55	0.45	0.25
9	6	14	2026-02-28 16:13:06.690714	2026-02-28 16:16:54.28509	4	0.73	0.52	0.38
\.


--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 223
-- Name: charging_point_point_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.charging_point_point_id_seq', 105, true);


--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 229
-- Name: charging_session_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.charging_session_session_id_seq', 11, true);


--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 221
-- Name: charging_station_station_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.charging_station_station_id_seq', 25, true);


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 219
-- Name: city_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.city_city_id_seq', 5, true);


--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 225
-- Name: ev_model_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ev_model_model_id_seq', 5, true);


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 227
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vehicle_vehicle_id_seq', 8, true);


-- Completed on 2026-02-28 16:42:15

--
-- PostgreSQL database dump complete
--

\unrestrict J4ZDDkzYZk5trYeycWsIiWpuebAVfRvdr4Pa2ImzGRfsPQmqFzrHFqUCZBtNQCW

