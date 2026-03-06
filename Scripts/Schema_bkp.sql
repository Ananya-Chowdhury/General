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