
CREATE FUNCTION public.update_i18n_perc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

UPDATE i18n SET completion_perc = ( CASE WHEN bg IS NULL THEN 0 ELSE 1 END +
        CASE WHEN ca IS NULL OR ca = '' THEN 0 ELSE 1 END +
        CASE WHEN da IS NULL OR da = '' THEN 0 ELSE 1 END +
        CASE WHEN de IS NULL OR de = '' THEN 0 ELSE 1 END +
        CASE WHEN cs IS NULL OR cs = '' THEN 0 ELSE 1 END +
        CASE WHEN el IS NULL OR el = '' THEN 0 ELSE 1 END +
        CASE WHEN en IS NULL OR en = '' THEN 0 ELSE 1 END +
        CASE WHEN fr IS NULL OR fr = '' THEN 0 ELSE 1 END +
        CASE WHEN hi IS NULL OR hi = '' THEN 0 ELSE 1 END +
        CASE WHEN hr IS NULL OR hr = '' THEN 0 ELSE 1 END +
        CASE WHEN hu IS NULL OR hu = '' THEN 0 ELSE 1 END +
        CASE WHEN it IS NULL OR it = '' THEN 0 ELSE 1 END +
        CASE WHEN ja IS NULL OR ja = '' THEN 0 ELSE 1 END +
        CASE WHEN nl IS NULL OR nl = '' THEN 0 ELSE 1 END +
        CASE WHEN pl IS NULL OR pl = '' THEN 0 ELSE 1 END +
        CASE WHEN pt IS NULL OR pt = '' THEN 0 ELSE 1 END +
        CASE WHEN ro IS NULL OR ro = '' THEN 0 ELSE 1 END +
        CASE WHEN ru IS NULL OR ru = '' THEN 0 ELSE 1 END +
        CASE WHEN es IS NULL OR es = '' THEN 0 ELSE 1 END +
        CASE WHEN th IS NULL OR th = '' THEN 0 ELSE 1 END +
        CASE WHEN tr IS NULL OR tr = '' THEN 0 ELSE 1 END +
        CASE WHEN uk IS NULL OR uk = '' THEN 0 ELSE 1 END +
        CASE WHEN vi IS NULL OR vi = '' THEN 0 ELSE 1 END +
        CASE WHEN zh IS NULL OR zh = '' THEN 0 ELSE 1 END ) * 100 / 24;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_i18n_perc() OWNER TO postgres;

CREATE TABLE public.i18n (
    key character varying(255) NOT NULL,
    user_updated uuid,
    date_updated timestamp with time zone,
    context text,
    completion_perc integer,
    category character varying(255) DEFAULT NULL::character varying,
    autotranslate boolean DEFAULT false,
    en text,
    bg text,
    ca text,
    cs text,
    da text,
    de text,
    el text,
    fr text,
    hi text,
    hr text,
    hu text,
    it text,
    ja text,
    nl text,
    pl text,
    pt text,
    ro text,
    ru text,
    es text,
    th text,
    tr text,
    uk text,
    vi text,
    zh text,
    retranslate boolean DEFAULT false
);


-- COPY public.directus_collections (collection, icon, note, display_template, hidden, singleton, translations, archive_field, archive_app_filter, archive_value, unarchive_value, sort_field, accountability, color, item_duplication_fields, sort, "group", collapse) FROM stdin;
-- i18n	translate	\N	\N	f	f	\N	\N	f	\N	\N	\N	all	\N	\N	\N	\N	open
-- \.




COPY public.directus_fields (id, collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, translations, note, conditions, required, "group", validation, validation_message) FROM stdin;
33	i18n	retranslate	cast-boolean	boolean	{"iconOn":"done","colorOn":"#2ECDA7","iconOff":"refresh","colorOff":null,"label":"Re-Translate"}	boolean	{"iconOn":null,"iconOff":null}	f	f	7	half	\N	\N	\N	f	\N	\N	\N
7	i18n	cs	\N	input-multiline	\N	\N	\N	f	f	13	fill	\N	\N	\N	f	\N	\N	\N
22	i18n	da	\N	input-multiline	\N	\N	\N	f	f	14	fill	\N	\N	\N	f	\N	\N	\N
23	i18n	de	\N	input-multiline	\N	\N	\N	f	f	15	fill	\N	\N	\N	f	\N	\N	\N
24	i18n	el	\N	input-multiline	\N	\N	\N	f	f	16	fill	\N	\N	\N	f	\N	\N	\N
25	i18n	fr	\N	input-multiline	\N	\N	\N	f	f	17	fill	\N	\N	\N	f	\N	\N	\N
28	i18n	hi	\N	input-multiline	\N	\N	\N	f	f	18	fill	\N	\N	\N	f	\N	\N	\N
29	i18n	hr	\N	input-multiline	\N	\N	\N	f	f	19	fill	\N	\N	\N	f	\N	\N	\N
32	i18n	hu	\N	input-multiline	\N	\N	\N	f	f	20	fill	\N	\N	\N	f	\N	\N	\N
2	i18n	it	\N	input-multiline	\N	\N	\N	f	f	21	fill	\N	\N	\N	f	\N	\N	\N
8	i18n	ja	\N	input-multiline	\N	\N	\N	f	f	22	fill	\N	\N	\N	f	\N	\N	\N
9	i18n	nl	\N	input-multiline	\N	\N	\N	f	f	23	fill	\N	\N	\N	f	\N	\N	\N
1	i18n	key	\N	input	{"font":"monospace"}	formatted-value	{"font":"monospace","bold":true,"background":null,"color":"#3399FF"}	f	f	1	full	\N	Dot notation lowercase	\N	f	\N	\N	\N
18	i18n	date_updated	date-updated,date-created	datetime	\N	datetime	{"relative":true}	t	f	2	half	\N	\N	\N	f	\N	\N	\N
19	i18n	user_updated	user-updated	select-dropdown-m2o	{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"}	user	\N	t	t	3	half	\N	\N	\N	f	\N	\N	\N
5	i18n	completion_perc	\N	input	{"iconLeft":"percent","font":"monospace"}	formatted-value	{"font":"monospace","bold":true,"icon":"percent"}	t	t	4	half	\N	\N	\N	f	\N	\N	\N
16	i18n	autotranslate	cast-boolean	boolean	{"label":"Auto-translated","iconOn":"brightness_auto","iconOff":"fiber_manual_record"}	boolean	{"iconOn":"brightness_auto","iconOff":"fiber_manual_record","colorOff":"#A2B5CD","colorOn":"#3399FF"}	f	f	5	half	\N	Flag to identify auto-translated strings on creation	\N	f	\N	\N	\N
20	i18n	category	\N	select-dropdown	{"allowOther":true,"allowNone":true,"choices":[{"text":"all","value":"all"},{"text":"personal-area","value":"personal-area"}]}	labels	{"font":"monospace","color":"#FFFFFF","background":"#3399FF","icon":"tag","choices":[{"text":"personal-area","value":"personal-area","foreground":"#FFFFFF","background":"#FFC23B"},{"text":"rental-car","value":"rental-car","foreground":"#FFFFFF","background":"#E35169"}]}	f	f	6	half	\N	Optional category to help searching / filtering	\N	f	\N	\N	\N
4	i18n	context	\N	input-multiline	\N	\N	\N	f	f	8	full	\N	Optional brief description of how this string is used	\N	f	\N	\N	\N
17	i18n	en	\N	input-multiline	\N	\N	\N	f	f	9	fill	\N	\N	\N	f	\N	\N	\N
3	i18n	divider	alias,no-data	presentation-divider	{"title":"Languages","color":"#3399FF","inlineTitle":true}	\N	\N	f	f	10	full	\N	\N	\N	f	\N	\N	\N
21	i18n	bg	\N	input-multiline	\N	\N	\N	f	f	11	fill	\N	\N	\N	f	\N	\N	\N
6	i18n	ca	\N	input-multiline	\N	\N	\N	f	f	12	fill	\N	\N	\N	f	\N	\N	\N
10	i18n	pl	\N	input-multiline	\N	\N	\N	f	f	24	fill	\N	\N	\N	f	\N	\N	\N
11	i18n	pt	\N	input-multiline	\N	\N	\N	f	f	25	fill	\N	\N	\N	f	\N	\N	\N
26	i18n	ro	\N	input-multiline	\N	\N	\N	f	f	26	fill	\N	\N	\N	f	\N	\N	\N
27	i18n	ru	\N	input-multiline	\N	\N	\N	f	f	27	fill	\N	\N	\N	f	\N	\N	\N
30	i18n	es	\N	input-multiline	\N	\N	\N	f	f	28	fill	\N	\N	\N	f	\N	\N	\N
31	i18n	th	\N	input-multiline	\N	\N	\N	f	f	29	fill	\N	\N	\N	f	\N	\N	\N
12	i18n	tr	\N	input-multiline	\N	\N	\N	f	f	30	fill	\N	\N	\N	f	\N	\N	\N
13	i18n	uk	\N	input-multiline	\N	\N	\N	f	f	31	fill	\N	\N	\N	f	\N	\N	\N
14	i18n	vi	\N	input-multiline	\N	\N	\N	f	f	32	fill	\N	\N	\N	f	\N	\N	\N
15	i18n	zh	\N	input-multiline	\N	\N	\N	f	f	33	fill	\N	\N	\N	f	\N	\N	\N
\.


COPY public.directus_presets (bookmark, "user", role, collection, search, layout, layout_query, layout_options, refresh_interval, filter, icon, color) FROM stdin;
\N	\N	\N	i18n	\N	tabular	{"tabular":{"fields":["completion_perc","tags","key","en","it","date_updated"],"sort":["date_updated"],"page":9}}	{"tabular":{"widths":{"key":475}}}	\N	\N	bookmark_outline	\N
\.


--
-- Data for Name: directus_relations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_relations (many_collection, many_field, one_collection, one_field, one_collection_field, one_allowed_collections, junction_field, sort_field, one_deselect_action) FROM stdin;
i18n	user_updated	directus_users	\N	\N	\N	\N	\N	nullify
\.




COPY public.directus_settings (project_name, project_url, project_color, project_logo, public_foreground, public_background, public_note, auth_login_attempts, auth_password_policy, storage_asset_transform, storage_asset_presets, custom_css, storage_default_folder, basemaps, mapbox_key, module_bar, project_descriptor, translation_strings, default_language) FROM stdin;
i18n	\N	#3399FF	\N	\N	\N	\N	25	\N	all	\N	#app, #main-content, body {\n  --primary-alt: #F0ECFF !important;\n  --primary-10: #F0ECFF !important;\n  --primary-25: #D9D0FF !important;\n  --primary-50: #9eb3ce !important;\n  --primary-75: #829dbf !important;\n  --primary-90: #496890 !important;\n\n  --primary: #3399FF !important;\n\n  --primary-110: #344a66 !important;\n  --primary-125: #2d4059 !important;\n  --primary-150: #26364b !important;\n  --primary-175: #1f2c3d !important;\n  --primary-190: #1F2C53 !important;\n\n  --v-button-background-color: #18222F !important;\n  --v-button-background-color-hover: #1f2c3d !important;\n  --sidebar-detail-color-active: #26364b !important;\n}\n\n#navigation .module-nav, .modules > div:last-child, #sidebar {\n    display: none !important\n}	\N	\N	\N	[{"type":"module","id":"content","enabled":true},{"type":"module","id":"users","enabled":true},{"type":"module","id":"files","enabled":false},{"type":"module","id":"insights","enabled":false},{"type":"module","id":"docs","enabled":false},{"type":"link","id":"VEUfvpj8yWSbfICskl6JM","name":"Project settings","url":"/settings/project","icon":"public","enabled":true},{"type":"link","id":"GG1NhggWMPY6woZTbdD6y","name":"Data model","url":"/settings/data-model","icon":"list_alt","enabled":true},{"type":"link","id":"VK-dax43RefyjpnZsMJGA","name":"Roles & Permissions","url":"/settings/roles","icon":"shield","enabled":true},{"type":"module","id":"settings","enabled":true,"locked":true}]	Translations	\N	en-US
\.


COPY public.directus_webhooks (name, method, url, status, data, actions, collections, headers) FROM stdin;
Autotranslate	POST	http://i18n.hookserver/autotranslate	active	t	create	i18n	\N
Autotranslate-update	POST	http://i18n.hookserver/autotranslate-update	active	t	update	i18n	\N
\.


ALTER TABLE ONLY public.i18n
    ADD CONSTRAINT i18n_pkey PRIMARY KEY (key);



CREATE TRIGGER update_perc AFTER INSERT OR UPDATE ON public.i18n FOR EACH STATEMENT WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION public.update_i18n_perc();




ALTER TABLE ONLY public.i18n
    ADD CONSTRAINT i18n_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);
