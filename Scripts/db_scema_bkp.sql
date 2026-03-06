-- ==========================================================
-- FULL PUBLIC SCHEMA BACKUP INTO public_backup
-- Copies:
-- Tables, Data, Sequences, Views, Functions, Triggers
-- ==========================================================

-- Permission Check ---
--dev passwod = Msqube.p
SELECT usename, usesuper FROM pg_user;
SELECT current_user;


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
        WHERE schemaname = 'public_backup'
    LOOP

        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS public_backup_p2.%I (LIKE public_backup.%I INCLUDING ALL)',
            r.tablename,
            r.tablename
        );

        EXECUTE format(
            'INSERT INTO public_backup_p2.%I SELECT * FROM public_backup.%I',
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
        WHERE sequence_schema='public_backup'
    LOOP

        EXECUTE format(
            'CREATE SEQUENCE IF NOT EXISTS public_backup_p2.%I',
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
        WHERE schemaname = 'public_backup'
    LOOP

        EXECUTE format(
            'CREATE OR REPLACE VIEW public_backup_p2.%I AS %s',
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
        WHERE n.nspname = 'public_backup'
    LOOP
        EXECUTE replace(r.func_def, 'public_backup.', 'public_backup_p2.');
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









-- =====================================================
-- run_partition_migration PROCEDURE script
-- =====================================================

CREATE OR REPLACE PROCEDURE public.run_partition_migration()
LANGUAGE plpgsql
AS $procedure$
DECLARE
    i INT;
    v_owner TEXT;
BEGIN

-- =====================================================
-- CLEAN OLD BACKUP TABLES
-- =====================================================

DROP TABLE IF EXISTS citizen_old CASCADE;
DROP TABLE IF EXISTS citizen_address_old CASCADE;
DROP TABLE IF EXISTS service_request_old CASCADE;
DROP TABLE IF EXISTS service_request_lifecycle_old CASCADE;
DROP TABLE IF EXISTS service_review_old CASCADE;


-- =====================================================
-- CITIZEN
-- =====================================================

SELECT pg_get_userbyid(relowner)
INTO v_owner
FROM pg_class
WHERE relname = 'citizen'
AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

DROP TABLE IF EXISTS citizen_new CASCADE;

CREATE TABLE citizen_new
(LIKE citizen INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES)
PARTITION BY HASH (id);

FOR i IN 0..49 LOOP
    EXECUTE format(
        'CREATE TABLE citizen_p%s PARTITION OF citizen_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );
END LOOP;

INSERT INTO citizen_new SELECT * FROM citizen;

ALTER TABLE citizen RENAME TO citizen_old;
ALTER TABLE citizen_new RENAME TO citizen;

EXECUTE format('ALTER TABLE citizen OWNER TO %I', v_owner);

DROP TABLE citizen_old CASCADE;



-- =====================================================
-- CITIZEN ADDRESS
-- =====================================================

SELECT pg_get_userbyid(relowner)
INTO v_owner
FROM pg_class
WHERE relname = 'citizen_address'
AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

DROP TABLE IF EXISTS citizen_address_new CASCADE;

CREATE TABLE citizen_address_new
(LIKE citizen_address INCLUDING DEFAULTS INCLUDING INDEXES)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP
    EXECUTE format(
        'CREATE TABLE citizen_address_p%s PARTITION OF citizen_address_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );
END LOOP;

INSERT INTO citizen_address_new SELECT * FROM citizen_address;

ALTER TABLE citizen_address RENAME TO citizen_address_old;
ALTER TABLE citizen_address_new RENAME TO citizen_address;

EXECUTE format('ALTER TABLE citizen_address OWNER TO %I', v_owner);

DROP TABLE citizen_address_old CASCADE;



-- =====================================================
-- SERVICE REQUEST
-- =====================================================

SELECT pg_get_userbyid(relowner)
INTO v_owner
FROM pg_class
WHERE relname = 'service_request'
AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

DROP TABLE IF EXISTS service_request_new CASCADE;

CREATE TABLE service_request_new
(LIKE service_request INCLUDING DEFAULTS INCLUDING INDEXES)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP
    EXECUTE format(
        'CREATE TABLE service_request_p%s PARTITION OF service_request_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );
END LOOP;

INSERT INTO service_request_new SELECT * FROM service_request;

ALTER TABLE service_request RENAME TO service_request_old;
ALTER TABLE service_request_new RENAME TO service_request;

EXECUTE format('ALTER TABLE service_request OWNER TO %I', v_owner);

DROP TABLE service_request_old CASCADE;



-- =====================================================
-- SERVICE REQUEST LIFECYCLE
-- =====================================================

SELECT pg_get_userbyid(relowner)
INTO v_owner
FROM pg_class
WHERE relname = 'service_request_lifecycle'
AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

DROP TABLE IF EXISTS service_request_lifecycle_new CASCADE;

CREATE TABLE service_request_lifecycle_new
(LIKE service_request_lifecycle INCLUDING DEFAULTS INCLUDING INDEXES)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP
    EXECUTE format(
        'CREATE TABLE service_request_lifecycle_p%s
         PARTITION OF service_request_lifecycle_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );
END LOOP;

INSERT INTO service_request_lifecycle_new
SELECT * FROM service_request_lifecycle;

ALTER TABLE service_request_lifecycle RENAME TO service_request_lifecycle_old;
ALTER TABLE service_request_lifecycle_new RENAME TO service_request_lifecycle;

EXECUTE format('ALTER TABLE service_request_lifecycle OWNER TO %I', v_owner);

DROP TABLE service_request_lifecycle_old CASCADE;



-- =====================================================
-- SERVICE REVIEW
-- =====================================================

SELECT pg_get_userbyid(relowner)
INTO v_owner
FROM pg_class
WHERE relname = 'service_review'
AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

DROP TABLE IF EXISTS service_review_new CASCADE;

CREATE TABLE service_review_new
(LIKE service_review INCLUDING DEFAULTS INCLUDING INDEXES)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP
    EXECUTE format(
        'CREATE TABLE service_review_p%s
         PARTITION OF service_review_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );
END LOOP;

INSERT INTO service_review_new SELECT * FROM service_review;

ALTER TABLE service_review RENAME TO service_review_old;
ALTER TABLE service_review_new RENAME TO service_review;

EXECUTE format('ALTER TABLE service_review OWNER TO %I', v_owner);

DROP TABLE service_review_old CASCADE;



-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_citizen_mobile_number
ON citizen(mobile_number);

CREATE INDEX IF NOT EXISTS idx_citizen_created_on
ON citizen(created_on);

CREATE INDEX IF NOT EXISTS idx_citizen_address_citizen_id
ON citizen_address(citizen_id);

CREATE INDEX IF NOT EXISTS idx_citizen_address_district_id
ON citizen_address(district_id);

CREATE INDEX IF NOT EXISTS idx_service_review_candidate_id
ON service_review(candidate_id);

CREATE INDEX IF NOT EXISTS idx_service_review_request_id
ON service_review(request_id);

CREATE INDEX IF NOT EXISTS idx_service_request_candidate_id
ON service_request(candidate_id);

CREATE INDEX IF NOT EXISTS idx_service_request_service_id
ON service_request(service_id);

CREATE INDEX IF NOT EXISTS idx_service_request_skill_id
ON service_request(skill_id);

CREATE INDEX IF NOT EXISTS idx_service_request_lifecycle_candidate
ON service_request_lifecycle(candidate_id);

END;
$procedure$;


--CALL public_backup_p2.run_partition_migration();
CALL public.run_partition_migration();
--DROP PROCEDURE public_backup_p2.run_partition_migration();
-- DROP PROCEDURE public.run_partition_migration();


SELECT
    relname AS table_name,
    relkind
FROM pg_class
WHERE relname = 'citizen';

SELECT
    inhrelid::regclass AS partition_name
FROM pg_inherits
WHERE inhparent = 'citizen'::regclass;


SELECT COUNT(*) FROM public_backup_p2.citizen;
SELECT current_user;


SELECT tablename, tableowner
FROM pg_tables
WHERE tablename = 'citizen';

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO asrlm_user;


GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public_backup_p2 TO asrlm_user;


ALTER SCHEMA public_backup_p2 OWNER TO asrlm_user;
ALTER SCHEMA public_backup OWNER TO asrlm_user;

ALTER TABLE public_backup_p2.citizen OWNER TO asrlm_user;
ALTER TABLE public_backup_p2.service_review OWNER TO asrlm_user;
ALTER TABLE public_backup_p2.service_request_lifecycle OWNER TO asrlm_user;
ALTER TABLE public_backup_p2.service_request OWNER TO asrlm_user;
ALTER TABLE public_backup_p2.citizen_address OWNER TO asrlm_user;

ALTER TABLE public_backup.citizen OWNER TO asrlm_user;
ALTER TABLE public_backup.service_review OWNER TO asrlm_user;
ALTER TABLE public_backup.service_request_lifecycle OWNER TO asrlm_user;
ALTER TABLE public_backup.service_request OWNER TO asrlm_user;
ALTER TABLE public_backup.citizen_address OWNER TO asrlm_user;