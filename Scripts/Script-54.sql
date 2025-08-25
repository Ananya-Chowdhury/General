drop  function manage_top_query;
CREATE OR REPLACE FUNCTION manage_top_query(kill_flag BOOLEAN)
RETURNS TABLE(return_query_text TEXT, return_lock_count INT, return_pids TEXT) AS $$
DECLARE
    top_query_text TEXT;
    top_lock_count INT;
    top_pid_list TEXT;
    pid_array INT[];
    pid INT;
BEGIN
    -- Retrieve the top query and its associated PIDs
    WITH query_locks AS (
        SELECT 
            a.query AS query_text,
            COUNT(1) AS lock_count,
            STRING_AGG(a.pid::TEXT, ',') AS aggregated_pids
        FROM 
            pg_locks l
        JOIN 
            pg_stat_activity a ON a.pid = l.pid
        JOIN 
            pg_class c ON c.oid = l.relation
        JOIN 
            pg_namespace n ON n.oid = c.relnamespace
        GROUP BY 
            a.query
        ORDER BY 
            COUNT(1) DESC
    )
    SELECT 
        query_text, lock_count, aggregated_pids
    INTO 
        top_query_text, top_lock_count, top_pid_list
    FROM 
        query_locks
    LIMIT 1;

    -- If kill_flag is TRUE, terminate the top query's PIDs
    IF kill_flag THEN
        pid_array := string_to_array(top_pid_list, ',')::INT[];
        FOREACH pid IN ARRAY pid_array LOOP
            PERFORM pg_terminate_backend(pid);
        END LOOP;
        RAISE NOTICE 'Terminated processes for query: %', top_query_text;
    END IF;

    -- Return the query information
    RETURN QUERY
    SELECT 
        top_query_text AS return_query_text,
        top_lock_count AS return_lock_count,
        top_pid_list AS return_pids;
END;
$$ LANGUAGE plpgsql;



SELECT * FROM manage_top_query(True);


