-- ==========================================================
-- FULL PUBLIC SCHEMA BACKUP INTO public_backup
-- Copies:
-- Tables, Data, Sequences, Views, Functions, Triggers
-- ==========================================================

-- 1️⃣ Create Backup Schema
CREATE SCHEMA IF NOT EXISTS public_backup;

-------------------------------------------------------------
-- 2️⃣ COPY TABLE STRUCTURE + DATA
-------------------------------------------------------------

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
    LOOP

        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS public_backup.%I (LIKE public.%I INCLUDING ALL)',
            r.tablename,
            r.tablename
        );

        EXECUTE format(
            'INSERT INTO public_backup.%I SELECT * FROM public.%I',
            r.tablename,
            r.tablename
        );

    END LOOP;
END $$;

-------------------------------------------------------------
-- 3️⃣ COPY SEQUENCES
-------------------------------------------------------------

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT sequence_name
        FROM information_schema.sequences
        WHERE sequence_schema='public'
    LOOP

        EXECUTE format(
            'CREATE SEQUENCE IF NOT EXISTS public_backup.%I',
            r.sequence_name
        );

    END LOOP;
END $$;

-------------------------------------------------------------
-- 4️⃣ COPY VIEWS
-------------------------------------------------------------

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT viewname, definition
        FROM pg_views
        WHERE schemaname = 'public'
    LOOP

        EXECUTE format(
            'CREATE OR REPLACE VIEW public_backup.%I AS %s',
            r.viewname,
            r.definition
        );

    END LOOP;
END $$;

-------------------------------------------------------------
-- 5️⃣ COPY FUNCTIONS
-------------------------------------------------------------

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT pg_get_functiondef(p.oid) as func_def
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
    LOOP
        EXECUTE replace(r.func_def, 'public.', 'public_backup.');
    END LOOP;
END $$;

-------------------------------------------------------------
-- 6️⃣ VERIFY BACKUP
-------------------------------------------------------------

SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname='public_backup'
ORDER BY tablename;

-- ==========================================================
-- BACKUP COMPLETED
-- ==========================================================




-- For Single Table Backup + Data (Faster) --
-- CREATE TABLE public_backup.table_name
-- (LIKE public.table_name INCLUDING ALL);

-- INSERT INTO public_backup.table_name
-- SELECT * FROM public.table_name;

-- ==========================================================
-- Partitions Checking Database 
-- ==========================================================
SELECT
    parent.relname AS partitioned_table,
    child.relname AS partition_name
FROM pg_inherits
JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
JOIN pg_class child ON pg_inherits.inhrelid = child.oid
ORDER BY parent.relname;


-- ==========================================================
-- Partitions Checking For Single Table
-- ==========================================================
SELECT relname, relkind
FROM pg_class
WHERE relname = 'citizen';


-- ==========================================================
-- Indexes Checking Database 
-- ==========================================================
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename;


-- ==========================================================
-- Find Tables Without Index on Primary Key
-- ==========================================================
SELECT
    relname AS table_name
FROM pg_class
WHERE relkind='r'
AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname='public')
AND relname NOT IN (
    SELECT tablename FROM pg_indexes WHERE indexname LIKE '%pkey%'
);


-- ==========================================================
-- Partitioning is useful only for large tables
-- ==========================================================
SELECT
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;


-- ==========================================================
-- Find Tables With High Sequential Scans (Need Index)
-- ==========================================================
SELECT
    relname,
    seq_scan,
    idx_scan
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;


-- ==========================================================
-- Create index: (An index is a data structure that helps the database find rows quickly without scanning the whole table. 
-- If candidates table has 10 million rows, PostgreSQL will check every row. This is called: Sequential Scan)
-- ==========================================================
CREATE INDEX idx_candidates_mobile
ON candidates(mobile_no);


-- ==========================================================
-- 1. Identify Large Tables First
-- ==========================================================
SELECT
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS table_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- large tables
-- candidates, candidate_trained, sms_tracking, icon_master, user, citizen related all tables, citizen, service_request, service_request_lifecycle


-- ==========================================================
-- 1. Analyze Query Performance
-- ==========================================================
EXPLAIN ANALYZE
SELECT *
FROM domain_lookup
WHERE domain_code = 3 and domain_type = 'service_status'

-- ===========================================
-- 🔟 Production Best Practices
--
-- ✔ Partition very large tables only
-- ✔ Index frequently filtered columns
-- ✔ Avoid too many indexes
-- ✔ Monitor with EXPLAIN ANALYZE
-- ✔ Use time-based partitions for logs
-- ============================================

-- ==========================================================
-- Verify the Existing Index
-- ==========================================================
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'domain_lookup';

SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'citizen';


-- ==========================================================
-- Create Index (If It Doesn't Exist)
-- ==========================================================
CREATE INDEX idx_domain_lookup_domain_code
ON domain_lookup(domain_code);


CREATE INDEX idx_domain_lookup_type_code
ON domain_lookup(domain_type, domain_code);


-- ==========================================================
-- +++++++++ INDEXING TABLES STEP BY STEP PROCESS ++++++++++
-- ==========================================================


-- ==========================================================
-- 1. Check Current Table Size
-- ==========================================================
SELECT 
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM pg_catalog.pg_statio_user_tables
WHERE relname = 'service_review';


-- ==========================================================
-- 2. Check if Table Already Has Partition
-- ==========================================================
SELECT 
    relname,
    relkind
FROM pg_class
WHERE relname = 'service_review';


-- ==========================================================
-- 3. Create Index (If It Doesn't Exist)
-- ==========================================================
--CREATE TABLE service_request_new (
--    LIKE service_request INCLUDING ALL
--) PARTITION BY HASH (id, citizen_id);


CREATE TABLE public.service_review_new (
	id int8 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	ratings int2 NULL,
	remarks varchar(500) NULL,
	created_by int8 NULL,
	created_on timestamptz NULL,
	updated_by int8 NULL,
	updated_on timestamptz NULL,
	candidate_id int4 NOT NULL,
	citizen_id int4 NOT NULL,
	request_id int8 NOT NULL,
	is_citizen_ratted bool NOT NULL,
	is_gig_ratted bool NOT NULL,
	PRIMARY KEY (id, citizen_id)
) PARTITION BY HASH (citizen_id);

CREATE INDEX service_review_candidate_id_1c6b8922 ON public.service_review USING btree (candidate_id);
CREATE INDEX service_review_citizen_id_e62e97b9 ON public.service_review USING btree (citizen_id);
CREATE INDEX service_review_request_id_2b6acbdf ON public.service_review USING btree (request_id);


CREATE TABLE public.service_request_lifecycle_new (
	id int8 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	lifecycle_status int2 NULL,
	created_by int8 NULL,
	created_on timestamptz NULL,
	updated_by int8 NULL,
	updated_on timestamptz NULL,
	remarks varchar(255) NULL,
	candidate_id int4 NOT NULL,
	citizen_id int4 NULL,
	service_id int8 NOT NULL,
	service_request_id int8 NOT NULL,
	assigned_by int8 NULL,
	assigned_on timestamptz NULL,
	assigned_to int8 NULL,
	service_desc varchar(1000) NULL,
	PRIMARY KEY (id, citizen_id)
) PARTITION BY HASH (citizen_id);
-- ==========================================================
-- 4. Create Partitions
-- ==========================================================
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 0..49 LOOP
        EXECUTE format(
            'CREATE TABLE service_review_p%s PARTITION OF service_review_new
             FOR VALUES WITH (MODULUS 50, REMAINDER %s);',
            i, i
        );
    END LOOP;
END
$$;


-- ==========================================================
-- 5. Move Existing Data
-- ==========================================================
INSERT INTO service_review_new SELECT * FROM service_review;


-- ==========================================================
-- 6. Swap Tables (Safe Method)
-- ==========================================================
ALTER TABLE service_review RENAME TO service_review_old;   --Rename old table:

ALTER TABLE service_review_new RENAME TO service_review;   ---Rename new table:


-- ==========================================================
-- 7. Create Indexes
-- ==========================================================
CREATE INDEX idx_citizen_mobile_number
ON citizen(mobile_number);

CREATE INDEX idx_citizen_created_on
ON citizen(created_on);

CREATE INDEX idx_service_review_candidate_id
ON service_review(candidate_id);
-- ==========================================================
-- 8. Check Partitions
-- ==========================================================
SELECT
    inhrelid::regclass AS partition
FROM pg_inherits
WHERE inhparent = 'service_review'::regclass;


-- ==========================================================
-- 9. Verify Data Distribution
-- ==========================================================
SELECT
    tableoid::regclass AS partition,
    COUNT(*)
FROM service_review
GROUP BY partition;

