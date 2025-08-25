select grievance_cat_id, grievance_category_code, grievance_category_desc, status, benefit_scheme_type, parent_office_id
	from cmo_grievance_category_master cgcm 
	where cgcm.benefit_scheme_type = 1 
	and cgcm.status = 1;


select 
		gm.grievance_id, cgcm.grievance_cat_id, cgcm.grievance_category_code, 
		cgcm.grievance_category_desc, cgcm.status, cgcm.benefit_scheme_type, cgcm.parent_office_id  -- matter_taken_up
	from 
		grievance_master gm
	left join
		cmo_grievance_category_master cgcm  on cgcm.parent_office_id = gm.assigned_to_office_id
	where 
		cgcm.benefit_scheme_type = 1 
		and cgcm.status = 1
		and gm.closure_reason_id in (5,9);

	
select * from grievance_master gm where closure_reason_id in (5,9) limit 2;
select * from grievance_master gm limit 10;



SELECT
        COUNT(DISTINCT grievance_id) AS benefit_provided,   -- benefit_provided
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc 
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.closure_reason_id = 1
        and cgcm.benefit_scheme_type = 1
        and cgcm.status = 1
    GROUP by
    	cgcm.grievance_category_code,
        cgcm.parent_office_id,
       	cgcm.grievance_category_desc;
       
--	) table11 ON table1.parent_office_id = table11.office_id

       
              
       
SELECT
        COUNT(DISTINCT grievance_id) AS grv_recvd,		--grievance_received
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.status = 1
        and cgcm.benefit_scheme_type = 1
        and cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
       	cgcm.grievance_category_desc;
       
--) table2 ON table1.parent_office_id = table2.office_id      

       
       
       
SELECT
        COUNT(DISTINCT grievance_id) AS atr_recvd,			--atr-received
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.status = 14
        and cgcm.benefit_scheme_type = 1
        and cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
       	cgcm.grievance_category_desc;
       
--) table3 ON table1.parent_office_id = table3.office_id       

       
SELECT
        COUNT(DISTINCT grievance_id) AS pending_with_hod,			--grievance_pending
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        and cgcm.benefit_scheme_type = 1
        and cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
       	cgcm.grievance_category_desc;
       
--) table6 ON table1.parent_office_id = table6.assigned_to_office_id
       
       
SELECT
        COUNT(DISTINCT grievance_id) AS grievance_disposal,			--grievance_disposal
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.status = 15
        and cgcm.benefit_scheme_type = 1
        and cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
       	cgcm.grievance_category_desc;
       
       
       
       
       
SELECT
        ar.assigned_by_office_id,
        EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff,		--average_days
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm,
        cmo_grievance_category_master cgcm
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
        AND co.assigned_to_office_id = ar.assigned_by_office_id
     	and cgcm.parent_office_id = gm.assigned_to_office_id
     	and cgcm.benefit_scheme_type = 1
        and cgcm.status = 1
    GROUP BY
        ar.assigned_by_office_id,
       	cgcm.grievance_category_code,
        cgcm.parent_office_id,
       	cgcm.grievance_category_desc;
       
       
--) table10 ON table1.parent_office_id = table10.assigned_by_office_id
       
       
SELECT
        COUNT(DISTINCT grievance_id) AS matter_taken_up,			--matter_taken_up
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.closure_reason_id IN (5, 9)
        and cgcm.benefit_scheme_type = 1
        and cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
       	cgcm.grievance_category_desc;
       
--) table12 ON table1.parent_office_id = table12.office_id      
       
       
       
       
       
select
    table1.parent_office_id,
    table1.grievance_category_desc,
    COALESCE(table2.grv_recvd, 0) AS grievances_received,
--    COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_recieved_count,
    COALESCE(table5.total_disposed, 0) AS grievances_disposed,
    COALESCE(table6.pending_with_hod, 0) AS grievances_pending,
    COALESCE(table10.days_diff, 0) AS average_resolved_days,
    COALESCE(table11.benefit_provided, 0) AS benefit_provided,
    COALESCE(table12.mater_taken_up, 0) AS mater_taken_up
--    coalesce(cast((sum(table11.benefit_provided) / (sum(table11.benefit_provided) + table12.mater_taken_up)) * 100) AS INTEGER) AS BSP_percentage,
--    COALESCE(
--        CAST(
--            (SUM(table11.benefit_provided) * 100) / NULLIF(SUM(table11.benefit_provided) + SUM(table12.mater_taken_up), 0) AS INTEGER
--        ), 0
--    ) AS BSP_percentage
FROM
    (SELECT
--            COUNT(DISTINCT gm.grievance_category) AS individual_scheme_id,
            cgcm.grievance_category_desc,
            cgcm.parent_office_id
        FROM
            grievance_master gm
        RIGHT JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
        WHERE
            cgcm.benefit_scheme_type = 1 AND cgcm.status = 1
        GROUP BY
            cgcm.parent_office_id,
            cgcm.grievance_category_desc
    ) table1
-- Grievances received
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS grv_recvd,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
    WHERE
        gm.status = 1
    GROUP BY
        apm.office_id
) table2 ON table1.parent_office_id = table2.office_id
-- ATR received
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS atr_recvd,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.updated_by_position
    WHERE
        gm.status = 14
    GROUP BY
        apm.office_id
) table3 ON table1.parent_office_id = table3.office_id
-- Total disposed
LEFT OUTER JOIN (
    SELECT
        COUNT(1) AS total_disposed,
        co.assigned_by_office_id
    FROM
        grievance_master gm
    JOIN atr_submitted_max_records_clone co ON co.grievance_id = gm.grievance_id
    WHERE
        gm.status = 15
    GROUP BY
        co.assigned_by_office_id
) table5 ON table1.parent_office_id = table5.assigned_by_office_id
-- Grievances pending with HOD
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS pending_with_hod,
        gm.assigned_to_office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
    GROUP BY
        gm.assigned_to_office_id
) table6 ON table1.parent_office_id = table6.assigned_to_office_id
-- Average days for grievance
LEFT OUTER JOIN (
    SELECT
        ar.assigned_by_office_id,
        EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
    FROM
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
        AND co.assigned_to_office_id = ar.assigned_by_office_id
    GROUP BY
        ar.assigned_by_office_id
) table10 ON table1.parent_office_id = table10.assigned_by_office_id
-- Benefit provided
	LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS benefit_provided,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_office_id
    WHERE
        gm.closure_reason_id = 1
    GROUP BY
        apm.office_id
) table11 ON table1.parent_office_id = table11.office_id
-- Matter taken up
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS mater_taken_up,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_office_id
    WHERE
        gm.closure_reason_id IN (5, 9)
    GROUP BY
        apm.office_id
) table12 ON table1.parent_office_id = table12.office_id
ORDER by
	parent_office_id,
    grievance_category_desc Asc,
    grievances_received DESC,
--    atr_recieved_count DESC,
    grievances_disposed DESC,
    grievances_pending DESC,
    average_resolved_days DESC,
    benefit_provided DESC
--    BSP_percentage DESC;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
WITH query1 AS (
    SELECT
        COUNT(DISTINCT grievance_id) AS grv_recvd,		--grievance_received
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.status = 1
        AND cgcm.benefit_scheme_type = 1
        AND cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
),
query2 AS (
    SELECT
        COUNT(DISTINCT grievance_id) AS grievances_disposed,		--grievance_disposed
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.status = 15
        AND cgcm.benefit_scheme_type = 1
        AND cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
),
query3 AS (
    SELECT
        COUNT(DISTINCT grievance_id) AS grievances_pending,		--grievance_pending
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        AND cgcm.benefit_scheme_type = 1
        AND cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
),
query4 AS (
    SELECT
        COUNT(DISTINCT grievance_id) AS benefit_provided,		--benefit_provided
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.closure_reason_id = 1
        AND cgcm.benefit_scheme_type = 1
        AND cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
),
query5 AS (
    SELECT
        ar.assigned_by_office_id AS parent_office_id,
        EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff,		--average_days
        cgcm.grievance_category_code,
        cgcm.grievance_category_desc
    FROM
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm,
        cmo_grievance_category_master cgcm
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
        AND co.assigned_to_office_id = ar.assigned_by_office_id
        AND cgcm.parent_office_id = gm.assigned_to_office_id
        AND cgcm.benefit_scheme_type = 1
        AND cgcm.status = 1
    GROUP BY
        ar.assigned_by_office_id,
        cgcm.grievance_category_code,
        cgcm.grievance_category_desc
),
query6 AS (
    SELECT
        COUNT(DISTINCT grievance_id) AS matter_taken_up,		--matter_taken_up
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
    WHERE
        gm.closure_reason_id IN (5, 9)
        AND cgcm.benefit_scheme_type = 1
        AND cgcm.status = 1
    GROUP BY
        cgcm.grievance_category_code,
        cgcm.parent_office_id,
        cgcm.grievance_category_desc
)
-- Final query joining all subqueries
SELECT
    q1.parent_office_id,
    q1.grievance_category_code,
    q1.grievance_category_desc,
    q1.grv_recvd,							-- from query1
    COALESCE(q2.grievances_disposed, 0) AS grievances_disposed,		-- from query2
    COALESCE(q3.grievances_pending, 0) AS grievances_pending,		-- from query3
    COALESCE(q4.benefit_provided, 0) AS benefit_provided,			-- from query4
    COALESCE(q5.days_diff, 0) AS average_resolved_days,			-- from query5
    COALESCE(q6.matter_taken_up, 0) AS matter_taken_up				-- from query6
FROM
    query1 q1
    LEFT JOIN query2 q2 ON q1.parent_office_id = q2.parent_office_id AND q1.grievance_category_code = q2.grievance_category_code
    LEFT JOIN query3 q3 ON q1.parent_office_id = q3.parent_office_id AND q1.grievance_category_code = q3.grievance_category_code
    LEFT JOIN query4 q4 ON q1.parent_office_id = q4.parent_office_id AND q1.grievance_category_code = q4.grievance_category_code
    LEFT JOIN query5 q5 ON q1.parent_office_id = q5.parent_office_id AND q1.grievance_category_code = q5.grievance_category_code
    LEFT JOIN query6 q6 ON q1.parent_office_id = q6.parent_office_id AND q1.grievance_category_code = q6.grievance_category_code
ORDER BY
    q1.grievance_category_code;
;




select
	k.grievance_cat_id as grievance_cat_id,
	k.grievance_category_code as grievance_cat_code,
	k.grievance_category_desc as grievance_description,
	COALESCE(SUM(k.grievances_recieved), 0) :: INT AS total_grievance_count,
	COALESCE(k.total_close_grievance_count, 0) :: INT AS close_grievance_count,
	COALESCE(k.atr_pending, 0) :: INT AS grievance_pending,
	COALESCE(k.benefit_provided, 0) :: INT AS benefit_provided
	from (
        select 
			cgcm.grievance_cat_id,
			cgcm.grievance_cat_code,
			cgcm.grievance_description,
			COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
			COUNT(case when gm.status = 15 then gm.grievance_id end) AS total_close_grievance_count,
			COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
			COUNT(case when gm.closure_reason_id = 1 then gm.grievance_id end) as benefit_provided,
			COUNT(1) as grievances_recieved
		from grievance_master gm
		inner join cmo_grievance_category_master cgcm on cgcm.parent_office_id  = gm.assigned_to_office_id  
           WHERE 
           		cgcm.benefit_scheme_type = 1
        		AND cgcm.status = 1
        group by cgcm.grievance_description, cgcm.grievance_cat_code,
		)k group by 
			k.grievance_cat_id,
			k.grievance_category_code,
			k.grievance_category_desc,
			k.grievances_recieved,
			k.total_close_grievance_count,
			k.atr_pending,
			k.benefit_provided;
	
SELECT
    k.grievance_cat_id AS grievance_cat_id,
    k.grievance_category_code AS grievance_category_code,
    k.grievance_category_desc AS grievance_category_desc,
    COALESCE(SUM(k.grievances_recieved), 0) :: INT AS total_grievance_count,
    COALESCE(SUM(k.total_close_grievance_count), 0) :: INT AS close_grievance_count,
    COALESCE(SUM(k.atr_pending), 0) :: INT AS grievance_pending,
    COALESCE(SUM(k.benefit_provided), 0) :: INT AS benefit_provided,
    COALESCE(SUM(k.matter_taken_up), 0) :: INT AS matter_taken_up,
--    coalesce((k.benefit_provided / nullif(k.benefit_provided + k.matter_taken_up)) * 100, 0) AS benefit_services_provided
    COALESCE(CASE 
	    WHEN (k.benefit_provided + k.matter_taken_up) = 0 THEN 0 
    	ELSE (k.benefit_provided / (k.benefit_provided + k.matter_taken_up)) * 100 END, 0
    		) AS benefit_services_provided
	FROM (
	    SELECT
        cgcm.grievance_cat_id,
        cgcm.grievance_category_code,
        cgcm.grievance_category_desc,
        COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS grievances_recieved,  -- New grievances
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS total_close_grievance_count,  -- Closed grievances
        COUNT(CASE WHEN gm.status NOT IN (1, 2, 14, 15) THEN gm.grievance_id END) AS atr_pending,  -- Pending grievances
        COUNT(CASE WHEN gm.closure_reason_id = 1 THEN gm.grievance_id END) AS benefit_provided,  -- Benefit provided
        COUNT(CASE WHEN gm.closure_reason_id in (5,9) THEN gm.grievance_id END) AS matter_taken_up  -- Matter taken up
    FROM
        grievance_master gm
    right JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id			-- inner join
    WHERE
        cgcm.benefit_scheme_type = 1
        AND cgcm.status = 1
    GROUP BY
        cgcm.grievance_cat_id,
        cgcm.grievance_category_code,
        cgcm.grievance_category_desc
) k
GROUP BY
    k.grievance_cat_id,
    k.grievance_category_code,
    k.grievance_category_desc,
    k.benefit_provided,
    k.matter_taken_up
ORDER BY
    k.grievance_category_desc ASC;

   
   
   
SELECT 
    com.office_name::text,
    COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) AS atr_received_count,
    COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
    CAST(COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) * 100.0 / COUNT(1) AS bigint) AS atr_received_count_percentage,
    CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / COUNT(gm.grievance_id) AS bigint) AS atr_pending_count_percentage
FROM 
    grievance_master gm
LEFT JOIN 
    cmo_office_master com ON com.office_id = gm.assigned_to_office_id 
--LEFT JOIN 
--    admin_position_master apm ON apm.position_id = gm.assigned_to_position
--LEFT JOIN 
--    admin_position_master apm ON apm.office_id = gm.assigned_to_position
--WHERE 
--    (gm.grievance_source = 0 OR 0 IS NULL) AND
--    (gm.assigned_to_position IN (SELECT position_id FROM admin_position_master WHERE office_id = 0) OR 0 IS NULL)
GROUP BY 
    com.office_name
ORDER BY
    atr_pending_count DESC;

   
select * 
	from (
    	select 
	    	com.office_name ,
	        Count(distinct gm.grievance_id) as per_hod_count 
	    from grievance_master gm 
	            inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
	            inner join cmo_office_master com on com.office_id = apm.office_id 
	    where 
	        gm.status  in (3,4,5,6,7,8,9,10,11,12,13,16,17) 
	        and apm.user_type = 2 
	       group by com.office_name) q 
	       order by q.per_hod_count desc ;
       
      
 SELECT * 
	FROM (
	    SELECT 
	        com.office_name,
	        COUNT(DISTINCT gm.grievance_id) AS per_hod_count 
	    FROM 
	        cmo_office_master com
	    LEFT JOIN 
	        admin_position_master apm ON com.office_id = apm.office_id AND apm.user_type = 2
	    LEFT JOIN 
	        grievance_master gm ON gm.assigned_to_position = apm.position_id 
	            AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17)
	    GROUP BY 
	        com.office_name) q 
		ORDER BY 
	    	q.per_hod_count DESC;				-- updated it gives 138 depart names where we not filter out by "where calues"  -- 
	    
SELECT * 
	FROM (
	    SELECT 
	        com.office_name,
	        COUNT(DISTINCT gm.grievance_id) AS per_hod_count 
	    FROM 
	        cmo_office_master com
	    LEFT JOIN 
	        admin_position_master apm ON com.office_id = apm.office_id 
	    LEFT JOIN 
	        grievance_master gm ON gm.assigned_to_position = apm.position_id
	     where
	     		apm.user_type = 2
	            AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17)
	    GROUP BY 
	        com.office_name) q 
		ORDER BY 
	    	q.per_hod_count DESC;				--  it gives the resuly in 57 departs that fitter out by "where claues"  --
	    	
	    	
	select * from (
                select csom.suboffice_name as office_name,
                    Count(distinct gm.grievance_id) as per_hod_count 
                from grievance_master gm 
                        inner join admin_position_master apm on apm.position_id = gm.assigned_to_position and apm.office_id = 84 and apm.sub_office_id is not null 
                        inner join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id 
                where 
                    gm.status  in (8,9,10,12)  group by csom.suboffice_name)q order by q.per_hod_count desc;
   
                   
   select * from (select 
        gm.grievance_category,
        cgcm.grievance_category_desc,
        count(distinct gm.grievance_id) as category_grievance_count
        from grievance_master gm 
        inner join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        where 
        gm.status in (3,4,5,6,7,8,9,10,11,12,13,16,17) group by gm.grievance_category, cgcm.grievance_category_desc)q
        order by q.category_grievance_count desc;							-- this can gives only the 46 category names where satus for inner query --
       
       
  SELECT * 
FROM (
    SELECT 
        cgcm.grievance_cat_id AS grievance_category,
        cgcm.grievance_category_desc,
        COUNT(DISTINCT gm.grievance_id) AS category_grievance_count
    FROM 
        cmo_grievance_category_master cgcm
    LEFT JOIN 
        grievance_master gm ON gm.grievance_category = cgcm.grievance_cat_id
            AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17)
--            and gm.grievance_source = 5
    GROUP BY 
        cgcm.grievance_cat_id, cgcm.grievance_category_desc
) q
ORDER BY 															-- updated this can gives all 215 category names where satus for inner query --
    q.category_grievance_count DESC;


   
select														-- chart id 5 with out ssm id filter ---
    table1.office_id,
    table1.office_name,
    COALESCE(table2.grv_frwd, 0) + COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS grievance_forwarded,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_received_count,
    COALESCE(table5.total_disposed, 0) AS total_disposed,
    COALESCE(table6.pending_with_hod, 0) AS atr_pending,
    COALESCE(table10.days_diff, 0) AS average_resolution_days,
    COALESCE(table11.benefit_provided, 0) AS benefit_provided,
    COALESCE(table12.mater_taken_up, 0) AS mater_taken_up,
    COALESCE(CAST(((table11.benefit_provided::FLOAT / (table11.benefit_provided + table12.mater_taken_up)::FLOAT) * 100) AS INTEGER), 0) AS bsp_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
FROM
    (SELECT
        com.office_id,
        com.office_name
    FROM
        cmo_office_master com
    WHERE
        com.office_category = 2) table1
LEFT JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS grv_frwd,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        AND gm.grievance_source = 5
    GROUP BY
        apm.office_id) table2
    ON table1.office_id = table2.office_id
LEFT JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS atr_recvd,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.updated_by_position
    WHERE
        gm.status = 14
        AND gm.grievance_source = 5
    GROUP BY
        apm.office_id) table3
    ON table1.office_id = table3.office_id
LEFT JOIN (
    SELECT
        COUNT(1) AS total_disposed,
        co.assigned_by_office_id
    FROM
        grievance_master gm
    JOIN atr_submitted_max_records_clone co ON co.grievance_id = gm.grievance_id
    WHERE
        gm.status = 15
        AND gm.grievance_source = 5
    GROUP BY
        co.assigned_by_office_id) table5
    ON table1.office_id = table5.assigned_by_office_id
LEFT JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS pending_with_hod,
        gm.assigned_to_office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        AND gm.grievance_source = 5
    GROUP BY
        gm.assigned_to_office_id) table6
    ON table1.office_id = table6.assigned_to_office_id
LEFT JOIN (
    SELECT
        ar.assigned_by_office_id,
        COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff
    FROM
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
        AND co.assigned_to_office_id = ar.assigned_by_office_id
        AND gm.grievance_source = 5
    GROUP BY
        ar.assigned_by_office_id) table10
    ON table10.assigned_by_office_id = table1.office_id
LEFT JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS benefit_provided,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.office_id = gm.assigned_to_office_id 
    WHERE 
        gm.closure_reason_id = 1
        AND gm.grievance_source = 5
    GROUP BY 
        apm.office_id) table11
    ON table1.office_id = table11.office_id
LEFT JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS mater_taken_up,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_office_id 
    WHERE 
        gm.closure_reason_id IN (5,9)  
        AND gm.grievance_source = 5
    GROUP BY 
        apm.office_id) table12
    ON table1.office_id = table12.office_id
ORDER BY 
    office_name ASC;

   
   
   
select																	-- update chart id 5 filtter with ssm id 5 --
    table1.office_id,
    table1.office_name,
    COALESCE(table2.grv_frwd, 0) + COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS grievance_forwarded,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_received_count,
    COALESCE(table5.total_disposed, 0) AS total_disposed,
    COALESCE(table6.pending_with_hod, 0) AS atr_pending,
    COALESCE(table10.days_diff, 0) AS average_resolution_days,
    COALESCE(table11.benefit_provided, 0) AS benefit_provided,
    COALESCE(table12.mater_taken_up, 0) AS mater_taken_up,
    COALESCE(CAST(((table11.benefit_provided::FLOAT / (table11.benefit_provided + table12.mater_taken_up)::FLOAT) * 100) AS INTEGER), 0) AS bsp_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
FROM
    (SELECT
        com.office_id,
        com.office_name
    FROM
        cmo_office_master com
    WHERE
        com.office_category = 2) table1
LEFT JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS grv_frwd,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
    GROUP BY
        apm.office_id) table2
    ON table1.office_id = table2.office_id
LEFT JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS atr_recvd,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.updated_by_position
    WHERE
        gm.status = 14
    GROUP BY
        apm.office_id) table3
    ON table1.office_id = table3.office_id
LEFT JOIN (
    SELECT
        COUNT(1) AS total_disposed,
        co.assigned_by_office_id
    FROM
        grievance_master gm
    JOIN atr_submitted_max_records_clone co ON co.grievance_id = gm.grievance_id
    WHERE
        gm.status = 15
    GROUP BY
        co.assigned_by_office_id) table5
    ON table1.office_id = table5.assigned_by_office_id
LEFT JOIN (
    SELECT
        COUNT(DISTINCT grievance_id) AS pending_with_hod,
        gm.assigned_to_office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
    GROUP BY
        gm.assigned_to_office_id) table6
    ON table1.office_id = table6.assigned_to_office_id
LEFT JOIN (
    SELECT
        ar.assigned_by_office_id,
        COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff
    FROM
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
        AND co.assigned_to_office_id = ar.assigned_by_office_id
    GROUP BY
        ar.assigned_by_office_id) table10
    ON table10.assigned_by_office_id = table1.office_id
LEFT JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS benefit_provided,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.office_id = gm.assigned_to_office_id 
    WHERE 
        gm.closure_reason_id = 1
    GROUP BY 
        apm.office_id) table11
    ON table1.office_id = table11.office_id
LEFT JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS mater_taken_up,
        apm.office_id
    FROM
        grievance_master gm
    JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_office_id 
    WHERE 
        gm.closure_reason_id IN (5,9)  
        AND gm.grievance_source = 5
    GROUP BY 
        apm.office_id) table12
    ON table1.office_id = table12.office_id
WHERE
    EXISTS (
        SELECT 1
        FROM grievance_master gm
        WHERE gm.grievance_source = 5
        AND gm.assigned_to_office_id = table1.office_id
    )
ORDER BY 
    office_name ASC;

   
   
 SELECT 																	-- chart id 26 department wise functions simple form with filtters --
    com.office_name::text,
    COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) AS atr_received_count,
    COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
    CAST(COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_received_count_percentage,
    CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_pending_count_percentage
FROM 
    cmo_office_master com
LEFT JOIN 
    grievance_master gm ON com.office_id = gm.assigned_to_office_id 
    AND (gm.grievance_source = $1 OR $1 <= 0)  -- Assuming $1 is the parameter for ssm_id
LEFT JOIN 
    admin_position_master apm ON apm.position_id = gm.assigned_to_position
WHERE 
    (SELECT COUNT(1) FROM admin_position_master apm WHERE apm.office_id = $2) > 0  -- Assuming $2 is the parameter for dept_id
    OR gm.assigned_to_position IN (SELECT apm.position_id FROM admin_position_master apm WHERE apm.office_id = $2)
    OR gm.updated_by_position IN (SELECT apm.position_id FROM admin_position_master apm WHERE apm.office_id = $2)
GROUP BY 
    com.office_name
ORDER BY 
    atr_pending_count DESC;

   
   
select * form cmo_office_master com where 





------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------ UPDATE MIS  CURRENT Query ---------------------------------------

select gl.assigned_to_office_id from grievance_lifecycle gl where gl.grievance_status in (3,5) ;

with cte1 as (
            select  a.grievance_id, a.assigned_on, a.assigned_by_office_id, a.assigned_to_office_id from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, 
                        assigned_by_office_id, assigned_on ,grievance_id, gl.assigned_to_office_id
                    from grievance_lifecycle gl where gl.grievance_status in (3,5) and gl.assigned_to_office_id = 3
                and assigned_on::date between '2019-01-01' and '2024-12-02'
            )a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id and gm.grievance_source in (5)
            where a.rnn = 1
        ),cte2 as (
            select a.assigned_to_office_id, count(1) as atr_sent, sum(case when atn_id = 6 then 1 else 0 end) as bnft_provided,
                sum(case when atn_id IN (9,12) then 1 else 0 end) as actn_intiated, sum(case when atn_id NOT IN (6,9,12) then 1 else 0 end) as non_actnable  
                from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, assigned_to_office_id,atn_id
                        from grievance_lifecycle gl 
                    where gl.grievance_status in (14,13) and gl.assigned_by_office_id = 3
                        and assigned_on::date between '2019-01-01' and '2024-12-02'
            )a 
            where a.rnn = 1 group by 1
        ),cte3 as (
            select assigned_by_office_id, count(1) as review_send
            from grievance_lifecycle gl where gl.grievance_status = 6 and gl.assigned_to_office_id = 3
                and assigned_on::date between '2019-01-01' and '2024-12-02'
            group by 1
        ) select 
                com.office_name,count(1) as grievances_received, 
                coalesce(cte2.bnft_provided,0) as benefit_service_provided,
                coalesce(cte2.actn_intiated,0) as action_taken,
                coalesce(cte2.non_actnable,0) as not_elgbl,
                coalesce(cte2.atr_sent,0) as total_submitted,
                sum(case 
                        when com.office_category = 1 and pndhd.days_diff > 7 then 1
                        when com.office_category = 2 and pndohd.days_diff > 7 then 1 
                        else 0 
                    end) as beyond_svn_days,   
                sum(case when gm.assigned_to_office_id = cte1.assigned_to_office_id then 1 else 0 end) as cumulative_pendency,
                coalesce(cte3.review_send,0) as atr_return_for_review_from_cmo_other_hod
        from cte1
        left join cte2 on cte1.assigned_by_office_id = cte2.assigned_to_office_id
        left join cte3 on cte1.assigned_by_office_id = cte3.assigned_by_office_id
        left join cmo_office_master com on com.office_id = cte1.assigned_by_office_id
        left join grievance_master gm on gm.grievance_id = cte1.grievance_id
        left join pending_for_hod_wise pndhd on gm.grievance_id = pndhd.grievance_id and com.office_category = 1
        left join pending_for_other_hod_wise pndohd on gm.grievance_id = pndohd.grievance_id and com.office_category != 1
        group by com.office_name,cte2.atr_sent,cte2.bnft_provided, cte2.actn_intiated, cte2.non_actnable, cte3.review_send;













