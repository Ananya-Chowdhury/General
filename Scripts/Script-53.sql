SELECT
    pg_locks.pid,
    mode,
    granted,
    query,
    state
FROM
    pg_locks
JOIN
    pg_stat_activity ON pg_locks.pid = pg_stat_activity.pid
WHERE
    relation IS NOT NULL;

   
   select  a.query , count(1)
	from pg_locks l
	join pg_stat_activity a ON a.pid = l.pid
	join pg_class c ON c.oid = l.relation
	join pg_namespace n ON n.oid = c.relnamespace group by 1
	order by 2 desc;
	
commit;

select pg_terminate_backend(108253) 

select  pg_terminate_backend(pid)
from pg_stat_activity 
where  query like  ' 
                -- /*table_type = ATR Received from Restricted User/HoSO, token_role_id = 5, code :: ['GM011'] NORMAL*/
                WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
          
                    select distinct
                        md.grievance_id, 
                        
                        -- case 
                  '
                
                
                
WITH query_locks AS (
    SELECT 
        a.query, 
        count(1) AS lock_count, 
        string_agg(a.pid::char, ',') AS pids
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
        lock_count DESC
    LIMIT 1
)
SELECT 
    pids 
FROM 
    query_locks;


   
   
   
   
   WITH top_query AS (
    SELECT 
        a.query,
        COUNT(1) AS lock_count,
        STRING_AGG(a.pid::TEXT, ',') AS pids
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
        lock_count DESC
    LIMIT 1
)
SELECT 
    pids
FROM 
    top_query;
