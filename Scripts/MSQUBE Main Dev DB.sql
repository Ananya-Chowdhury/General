
SELECT tablename, tableowner 
FROM pg_tables 
WHERE tablename = 'service_request_lifecycle';

--ALTER TABLE citizen OWNER TO asrlm_user;


--- All Partitioned tables -----
SELECT inhrelid::regclass AS partition
FROM pg_inherits
WHERE inhparent = 'service_request_lifecycle'::regclass;


ALTER TABLE service_request_lifecycle OWNER TO asrlm_user;


--- Give Permisiion to all the partitioned tables change the ownership --
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN (
        SELECT inhrelid::regclass AS partition
        FROM pg_inherits
        WHERE inhparent = 'service_request_lifecycle'::regclass
    )
    LOOP
        EXECUTE 'ALTER TABLE ' || r.partition || ' OWNER TO asrlm_user;';
    END LOOP;
END $$;