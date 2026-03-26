

--- Db Table user Owner change Step by step ---
SELECT tablename, tableowner 
FROM pg_tables 
WHERE tablename = 'service_request';

--ALTER TABLE citizen OWNER TO asrlm_user;


--- All Partitioned tables -----
SELECT inhrelid::regclass AS partition
FROM pg_inherits
WHERE inhparent = 'service_request'::regclass;


ALTER TABLE service_request OWNER TO asrlm_user;


--- Give Permisiion to all the partitioned tables change the ownership --
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN (
        SELECT inhrelid::regclass AS partition
        FROM pg_inherits
        WHERE inhparent = 'service_request'::regclass
    )
    LOOP
        EXECUTE 'ALTER TABLE ' || r.partition || ' OWNER TO asrlm_user;';
    END LOOP;
END $$;