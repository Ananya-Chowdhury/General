----------- ATR RETURN FOR REVIEW NOT ASSIGNED FROM THAT EXACTLY OFFICE FROM IT WAS GIVEN -------------
WITH status_chain AS (
    SELECT 
        grievance_id,
        grievance_status,
        assigned_by_office_id,
        assigned_to_office_id,
        assigned_on,
        LEAD(grievance_status) OVER (PARTITION BY grievance_id ORDER BY assigned_on) AS next_status,
        LEAD(assigned_by_office_id) OVER (PARTITION BY grievance_id ORDER BY assigned_on) AS next_assigned_by,
        LEAD(assigned_on) OVER (PARTITION BY grievance_id ORDER BY assigned_on) AS next_assigned_on
    FROM grievance_lifecycle
)
SELECT DISTINCT grievance_id
FROM status_chain
WHERE grievance_status = 6
  AND next_status IN (7)
  AND DATE(next_assigned_on) BETWEEN '2025-09-09' AND '2025-09-11'
  AND next_assigned_by <> assigned_to_office_id;




SELECT g1.grievance_id, g2.grievance_status, g2.assigned_on
FROM grievance_lifecycle g1
JOIN grievance_lifecycle g2
  ON g2.grievance_id = g1.grievance_id
 AND g2.assigned_on = (
       SELECT MIN(assigned_on)
       FROM grievance_lifecycle
       WHERE grievance_id = g1.grievance_id
         AND assigned_on > g1.assigned_on
   )
WHERE g1.grievance_status = 6
  AND g2.grievance_status IN (4,7)
  AND DATE(g2.assigned_on) BETWEEN '2025-09-09' AND '2025-09-11'
  AND g2.assigned_by_office_id <> g1.assigned_to_office_id
ORDER BY g2.assigned_on DESC;



select * from grievance_lifecycle gl where gl.grievance_status = 4 and gl.assigned_on::date BETWEEN '2025-09-09' AND '2025-09-11';

WITH ordered AS (
    SELECT 
        gl.*,
        LAG(gl.grievance_status) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS prev_status
    FROM grievance_lifecycle gl
)
SELECT *
FROM ordered
WHERE grievance_status = 4
  AND assigned_on::date BETWEEN '2025-09-09' AND '2025-09-11'
  AND prev_status = 6
ORDER BY assigned_on DESC;



WITH ordered AS (
    SELECT 
        gl.*,
        LAG(gl.grievance_status) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS prev_status
    FROM grievance_lifecycle gl
)
SELECT *
FROM ordered
WHERE grievance_status = 7
  AND assigned_on::date BETWEEN '2025-09-09' AND '2025-09-11'
  AND prev_status = 6
ORDER BY assigned_on DESC;





WITH ordered AS (
    SELECT 
        gl.*,
        LAG(gl.grievance_status) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS prev_status,
        LAG(gl.assigned_to_office_id) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS prev_assigned_to_office_id
    FROM grievance_lifecycle gl
)
SELECT *
FROM ordered
WHERE grievance_status = 7
  AND assigned_on::date BETWEEN '2025-09-09' AND '2025-09-11'
  AND prev_status = 6
  AND assigned_by_office_id <> prev_assigned_to_office_id
ORDER BY assigned_on DESC;





WITH ordered AS (
    SELECT 
        gl.*,
        LEAD(gl.grievance_status) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status,
        LEAD(gl.assigned_by_office_id) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_assigned_by_office_id
    FROM grievance_lifecycle gl
)
SELECT *
FROM ordered
WHERE grievance_status = 6
  AND next_status IN (4, 7)
  AND assigned_to_office_id <> next_assigned_by_office_id
ORDER BY assigned_on DESC;


select * from grievance_lifecycle gl where gl.grievance_id = 1939899 order by gl.assigned_on desc;
select * from cmo_office_master com where com.office_id = 63;
select * from grievance_master gm where gm.grievance_id in (2700557, 2409434, 1939899);