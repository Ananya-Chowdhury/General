--Before Running ---
SELECT count(*) FROM citizen;
SELECT count(*) FROM service_request;



BEGIN;

-- =====================================================
-- FUNCTION TO PARTITION TABLE AUTOMATICALLY
-- =====================================================

CREATE OR REPLACE FUNCTION partition_table(
    tbl_name TEXT,
    partition_column TEXT,
    pk_columns TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
    new_tbl TEXT := tbl_name || '_new';
    old_tbl TEXT := tbl_name || '_old';
BEGIN

-- -----------------------------------------------------
-- 1. CREATE NEW PARTITIONED TABLE
-- -----------------------------------------------------

EXECUTE format(
'CREATE TABLE %I (LIKE %I INCLUDING ALL) PARTITION BY HASH (%I)',
new_tbl, tbl_name, partition_column
);

-- -----------------------------------------------------
-- 2. CREATE PARTITIONS
-- -----------------------------------------------------

FOR i IN 0..49 LOOP
    EXECUTE format(
        'CREATE TABLE %I_p%s PARTITION OF %I
        FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        tbl_name, i, new_tbl, i
    );
END LOOP;

-- -----------------------------------------------------
-- 3. COPY DATA
-- -----------------------------------------------------

EXECUTE format(
'INSERT INTO %I SELECT * FROM %I',
new_tbl, tbl_name
);

-- -----------------------------------------------------
-- 4. SWAP TABLES
-- -----------------------------------------------------

EXECUTE format(
'ALTER TABLE %I RENAME TO %I',
tbl_name, old_tbl
);

EXECUTE format(
'ALTER TABLE %I RENAME TO %I',
new_tbl, tbl_name
);

-- -----------------------------------------------------
-- 5. DROP OLD TABLE
-- -----------------------------------------------------

EXECUTE format(
'DROP TABLE %I CASCADE',
old_tbl
);

END;
$$;


-- =====================================================
-- PARTITION ALL REQUIRED TABLES
-- =====================================================


-- citizen
SELECT partition_table(
'citizen',
'id',
'id'
);


-- citizen_address
SELECT partition_table(
'citizen_address',
'citizen_id',
'id, citizen_id'
);


-- service_request
SELECT partition_table(
'service_request',
'citizen_id',
'id, citizen_id'
);


-- service_request_lifecycle
SELECT partition_table(
'service_request_lifecycle',
'citizen_id',
'id, citizen_id'
);


-- service_review
SELECT partition_table(
'service_review',
'citizen_id',
'id, citizen_id'
);


-- =====================================================
-- CREATE INDEXES AGAIN (SAFE IF NOT EXISTS)
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

COMMIT;



-- =====================================================
-- VERIFY PARTITIONS
-- =====================================================

SELECT
inhrelid::regclass AS partition
FROM pg_inherits
ORDER BY partition;



-- =====================================================
-- run_partition_migration PROCEDURE script
-- =====================================================

CREATE OR REPLACE PROCEDURE public_backup_p2.run_partition_migration()
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
BEGIN

-- =====================================================
-- CITIZEN
-- =====================================================

DROP TABLE IF EXISTS citizen_new CASCADE;

CREATE TABLE citizen_new (LIKE citizen INCLUDING ALL)
PARTITION BY HASH (id);

FOR i IN 0..49 LOOP

    EXECUTE format('DROP TABLE IF EXISTS citizen_p%s CASCADE', i);

    EXECUTE format(
        'CREATE TABLE citizen_p%s PARTITION OF citizen_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );

END LOOP;

INSERT INTO citizen_new SELECT * FROM citizen;

ALTER TABLE citizen RENAME TO citizen_old;
ALTER TABLE citizen_new RENAME TO citizen;

DROP TABLE citizen_old CASCADE;



-- =====================================================
-- CITIZEN ADDRESS
-- =====================================================

DROP TABLE IF EXISTS citizen_address_new CASCADE;

CREATE TABLE citizen_address_new
(LIKE citizen_address INCLUDING ALL)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP

    EXECUTE format('DROP TABLE IF EXISTS citizen_address_p%s CASCADE', i);

    EXECUTE format(
        'CREATE TABLE citizen_address_p%s PARTITION OF citizen_address_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );

END LOOP;

INSERT INTO citizen_address_new SELECT * FROM citizen_address;

ALTER TABLE citizen_address RENAME TO citizen_address_old;
ALTER TABLE citizen_address_new RENAME TO citizen_address;

DROP TABLE citizen_address_old CASCADE;



-- =====================================================
-- SERVICE REQUEST
-- =====================================================

DROP TABLE IF EXISTS service_request_new CASCADE;

CREATE TABLE service_request_new
(LIKE service_request INCLUDING ALL)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP

    EXECUTE format('DROP TABLE IF EXISTS service_request_p%s CASCADE', i);

    EXECUTE format(
        'CREATE TABLE service_request_p%s PARTITION OF service_request_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );

END LOOP;

INSERT INTO service_request_new SELECT * FROM service_request;

ALTER TABLE service_request RENAME TO service_request_old;
ALTER TABLE service_request_new RENAME TO service_request;

DROP TABLE service_request_old CASCADE;



-- =====================================================
-- SERVICE REQUEST LIFECYCLE
-- =====================================================

DROP TABLE IF EXISTS service_request_lifecycle_new CASCADE;

CREATE TABLE service_request_lifecycle_new
(LIKE service_request_lifecycle INCLUDING ALL)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP

    EXECUTE format('DROP TABLE IF EXISTS service_request_lifecycle_p%s CASCADE', i);

    EXECUTE format(
        'CREATE TABLE service_request_lifecycle_p%s
         PARTITION OF service_request_lifecycle_new
         FOR VALUES WITH (MODULUS 50, REMAINDER %s)',
        i,i
    );

END LOOP;

INSERT INTO service_request_lifecycle_new
SELECT * FROM service_request_lifecycle;

ALTER TABLE service_request_lifecycle
RENAME TO service_request_lifecycle_old;

ALTER TABLE service_request_lifecycle_new
RENAME TO service_request_lifecycle;

DROP TABLE service_request_lifecycle_old CASCADE;



-- =====================================================
-- SERVICE REVIEW
-- =====================================================

DROP TABLE IF EXISTS service_review_new CASCADE;

CREATE TABLE service_review_new
(LIKE service_review INCLUDING ALL)
PARTITION BY HASH (citizen_id);

FOR i IN 0..49 LOOP

    EXECUTE format('DROP TABLE IF EXISTS service_review_p%s CASCADE', i);

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

DROP TABLE service_review_old CASCADE;



-- =====================================================
-- RECREATE INDEXES
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
$$;


CALL public_backup_p2.run_partition_migration();
--DROP PROCEDURE IF EXISTS run_partition_migration();


select * from citizen c ;

SELECT current_user;


SELECT tablename, tableowner
FROM pg_tables
WHERE tablename = 'citizen';



GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public_backup_p2 TO asrlm_user;