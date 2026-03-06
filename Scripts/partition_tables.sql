CREATE OR REPLACE PROCEDURE public_backup_p2.run_partition_migration()
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