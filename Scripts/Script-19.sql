select
    table1.office_id,
    table1.office_name,
    coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
    coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
    coalesce(table5.total_disposed,0) as total_disposed,
    coalesce(table6.pending_with_hod,0) as atr_pending,
    coalesce(table10.days_diff,0) as average_resolution_days,
    coalesce(table11.benefit_provided,0) as benefit_provided,
    coalesce(table12.mater_taken_up,0) as mater_taken_up,
--  coalesce(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS bsp_percentage,
--	'Good'::text AS performance
  --  coalesce(table8.grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
   -- coalesce(table9.grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
	-- coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER)) AS bsp_percentage,
    coalesce(CAST(((table11.benefit_provided::FLOAT / (table11.benefit_provided + table12.mater_taken_up)::FLOAT) * 100) AS INTEGER), 0) AS bsp_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
	FROM
        (
        select
            com.office_id ,
            com.office_name
        from
            cmo_office_master com
        where
            com.office_category = 2
                ) table1
        -- grv frwded
    left outer join(
        select
            count(distinct grievance_id) as grv_frwd,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            apm.office_id) table2
            on
        table1.office_id = table2.office_id
        -- atr recvd
    left outer join(
        select
            count(distinct grievance_id) as atr_recvd ,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.updated_by_position
        where
           gm.status = 14
        group by
            apm.office_id) table3
            on
        table1.office_id = table3.office_id
        -- total disposed 	
    left outer join(
        select
            count(1) as total_disposed,
            co.assigned_by_office_id
        from
            grievance_master gm
        join atr_submitted_max_records_clone co on
            co.grievance_id = gm.grievance_id
        where
        	gm.status = 15
        group by
            co.assigned_by_office_id) table5
            on
        table1.office_id = table5.assigned_by_office_id	
        -- grv pending with hod
    left outer join(
        select
            count(distinct grievance_id) as pending_with_hod ,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            gm.assigned_to_office_id) table6
            on
        table1.office_id = table6.assigned_to_office_id
 		-- average days for grievance
	left outer join (
	    select
	        ar.assigned_by_office_id,
	        extract (day
	    from
	        avg(ar.max_assigned_on - co.max_assigned_on)) as days_diff
	    from
	        atr_submitted_max_records_clone ar,
	        recvd_from_cmo_max_clone_view co,
	        grievance_master gm
	    where
	        ar.grievance_id = co.grievance_id
	        and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
	    group by
	        ar.assigned_by_office_id) table10
	        on
	    table10.assigned_by_office_id = table1.office_id
	    -- benifit provided
	left outer join (
	   select 
			count(distinct grievance_id) as benefit_provided,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.office_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id = 1
		group by 
			apm.office_id) table11
		on
		table1.office_id = table11.office_id
		-- matter taken up
	left outer join (
		select 
			count(distinct grievance_id) as mater_taken_up,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.position_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id in (5,9)
		group by 
			apm.office_id) table12
		on
		table1.office_id = table12.office_id
		ORDER BY 
		    grievance_forwarded desc;
		   -- atr_recieved_count DESC,
		   -- total_disposed DESC,
		   -- atr_pending DESC,
		   -- average_resolution_days DESC,
		   -- benefit_provided DESC,
		   -- bsp_percentage DESC,
		   -- performance DESC;
		   
select com.office_name, com.office_id, gm.closure_reason_id , gm.assigned_to_office_id 
	from cmo_office_master com 
	join grievance_master gm on gm.assigned_to_office_id = com.office_id
	where gm.closure_reason_id in (5,9);

select com.office_name, apm.office_id, gm.closure_reason_id , gm.assigned_to_office_id , com.office_id , apm.position_id 
	from admin_position_master apm 
	join grievance_master gm on gm.assigned_to_office_id = apm.position_id 
	join cmo_office_master com on com.office_id = apm.office_id 
	where gm.closure_reason_id in (5,9);
	

CREATE OR REPLACE FUNCTION public.grievance_statistics(parent_office_id integer, grievance_category_desc text)
RETURNS TABLE(
    parent_office_id integer,
    grievance_category_desc text,
    grievances_received bigint,
    atr_received_count bigint,
    grievances_disposed bigint,
    grievances_pending bigint,
    average_resolved_days integer,
    benefit_provided bigint,
    mater_taken_up bigint,
    bsp_percentage integer
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        table1.parent_office_id,
        table1.grievance_category_desc,
        COALESCE(table2.grv_recvd, 0) AS grievances_received,
        COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_received_count,
        COALESCE(table5.total_disposed, 0) AS grievances_disposed,
        COALESCE(table6.pending_with_hod, 0) AS grievances_pending,
        COALESCE(table10.days_diff, 0) AS average_resolved_days,
        COALESCE(table11.benefit_provided, 0) AS benefit_provided,
        COALESCE(table12.mater_taken_up, 0) AS mater_taken_up,
        COALESCE(
            CAST((table11.benefit_provided / NULLIF((table11.benefit_provided + table12.mater_taken_up), 0) * 100) AS INTEGER),
            0
        ) AS bsp_percentage
    FROM
        (
            SELECT
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
    -- Average days for grievance resolution
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
    ORDER BY
        parent_office_id DESC,
        grievance_category_desc DESC,
        grievances_received DESC,
        atr_received_count DESC,
        grievances_disposed DESC,
        grievances_pending DESC,
        average_resolved_days DESC,
        benefit_provided DESC,
        bsp_percentage DESC;
END;
$function$
;

--                grievances_received DESC,
SELECT
        table1.parent_office_id,
        table1.grievance_category_desc,
        COALESCE(table2.grv_recvd, 0) AS grievances_received,
        COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_recieved_count,
        COALESCE(table5.total_disposed, 0) AS grievances_disposed,
        COALESCE(table6.pending_with_hod, 0) AS grievances_pending,
        COALESCE(table10.days_diff, 0) AS average_resolved_days,
        COALESCE(table11.benefit_provided, 0) AS benefit_provided,
        COALESCE(table12.mater_taken_up, 0) AS mater_taken_up,
        COALESCE(CAST((table11.benefit_provided / NULLIF((table11.benefit_provided + table12.mater_taken_up), 0) * 100) AS INTEGER), 0) AS BSP_percentage
    FROM
        (
            SELECT
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
    ORDER BY
        grievance_category_desc asc;
--                atr_recieved_count DESC,
--                grievances_disposed DESC,
--                grievances_pending DESC,
--                average_resolved_days DESC,
--                benefit_provided DESC,
--                BSP_percentage DESC;

       
       
       SELECT
                cgcm.grievance_category_desc,
                cgcm.parent_office_id
            FROM
                grievance_master gm
            RIGHT JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_office_id
            WHERE
                cgcm.benefit_scheme_type = 1 AND cgcm.status = 1
            GROUP BY
                cgcm.parent_office_id,
                cgcm.grievance_category_desc;
                
               
 SELECT
    COUNT(DISTINCT grievance_id) AS grv_recvd,
    cgcm.parent_office_id
FROM
    grievance_master gm
JOIN cmo_grievance_category_master cgcm ON cgcm.parent_office_id = gm.assigned_to_position
WHERE
    gm.status = 1
GROUP BY
    cgcm.parent_office_id;
    
   
   select COUNT(DISTINCT grievance_id) AS grv_recvd, cgcm.parent_office_id, cgcm.grievance_category_desc
   from grievance_master gm 
   right join cmo_grievance_category_master cgcm on cgcm.parent_office_id = gm.assigned_to_office_id 
   where cgcm.status = 1 and cgcm.benefit_scheme_type = 1 
   group by cgcm.grievance_category_desc, cgcm.parent_office_id
   order by cgcm.grievance_category_desc asc;
   
  
  SELECT
        table1.grievance_category_desc,
        table1.grievance_cat_id,
        COALESCE(table2.grv_recvd, 0) AS grievances_received,
        COALESCE(table3.atr_recvd, 0) + COALESCE(table4.total_disposed, 0) AS atr_recieved_count,
        COALESCE(table4.total_disposed, 0) AS grievances_disposed,
        COALESCE(table5.pending_with_hod, 0) AS grievances_pending,
        COALESCE(table6.average_days, 0) AS days_diff,
        COALESCE(table7.benefit_provided, 0) AS benefit_provided,
        COALESCE(table8.mater_taken_up, 0) AS mater_taken_up,
	COALESCE(
	    CASE 
	        WHEN (COALESCE(table7.benefit_provided, 0) + COALESCE(table8.mater_taken_up, 0)) > 0 
	        THEN ROUND((COALESCE(table7.benefit_provided, 0)::FLOAT / NULLIF(COALESCE(table7.benefit_provided, 0) + COALESCE(table8.mater_taken_up, 0), 0)) * 100)
	        ELSE 0
    	END, 0
	) AS bsp_percentage
    FROM
        (
            SELECT
                cgcm.grievance_category_desc,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
             right join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                cgcm.benefit_scheme_type = 1 AND cgcm.status = 1
            GROUP BY
                cgcm.grievance_category_desc,
                cgcm.grievance_cat_id
        ) table1
    -- Grievances received
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS grv_recvd,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
        join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status = 1
        GROUP BY
            cgcm.grievance_cat_id
    ) table2 ON table1.grievance_cat_id = table2.grievance_cat_id
    -- ATR received
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS atr_recvd,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status = 14
        GROUP BY
            cgcm.grievance_cat_id
    ) table3 ON table1.grievance_cat_id = table3.grievance_cat_id
    -- Total disposed
    LEFT OUTER JOIN (
        select
        	COUNT(DISTINCT grievance_id) AS total_disposed,
        	cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status = 15
        GROUP BY
            cgcm.grievance_cat_id
    ) table4 ON table1.grievance_cat_id = table4.grievance_cat_id
    -- Grievances pending with HOD
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS pending_with_hod,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        GROUP BY
            cgcm.grievance_cat_id
    ) table5 ON table1.grievance_cat_id = table5.grievance_cat_id
    -- Average days for grievance
    LEFT OUTER JOIN (
       select
			cgcm.grievance_cat_id,
	--    	gm.grievance_category,
	        EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
    	from
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
   	 join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category 
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
     	AND co.grievance_id = gm.grievance_id
    GROUP by
    	cgcm.grievance_cat_id
    ) table6 ON table1.grievance_cat_id = table6.grievance_cat_id
    -- Benefit provided
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS benefit_provided,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.closure_reason_id = 1
        GROUP BY
            cgcm.grievance_cat_id
    ) table7 ON table1.grievance_cat_id = table7.grievance_cat_id
    -- Matter taken up
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS mater_taken_up,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
        join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.closure_reason_id IN (5, 9) 
        GROUP BY
            cgcm.grievance_cat_id
    ) table8 ON table1.grievance_cat_id = table8.grievance_cat_id
    ORDER BY
        grievance_category_desc asc;
       
       
       
 SELECT
--            ar.assigned_by_office_id,
        gm.grievance_category,
            EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
        FROM
            atr_submitted_max_records_clone ar,
            recvd_from_cmo_max_clone_view co,
            grievance_master gm
        WHERE
            ar.grievance_id = co.grievance_id
            AND ar.grievance_id = gm.grievance_id
--            AND co.assigned_to_office_id = ar.assigned_by_office_id
        GROUP BY
            gm.grievance_category
           limit 10;
           
     select * from grievance_master gm where gm.grievance_category = 32;
     select * from grievance_lifecycle gl where grievance_id = 416;
    select * from cmo_grievance_category_master cgcm where grievance_cat_id = 1 limit 1;
 select * from grievance_lifecycle gl limit 1;
	select * from cmo_grievance_category_master cgcm limit 1; 




SELECT DISTINCT
    gl.grievance_id,
    gl.grievance_status,
    gl.assigned_on AS max_assigned_on,
    gl.assigned_by_office_id,
    gl.assigned_to_office_id
FROM
    grievance_lifecycle gl
WHERE
    gl.grievance_status = 14
    AND gl.assigned_on = (
        SELECT MAX(assigned_on)
        FROM grievance_lifecycle
        WHERE grievance_id = gl.grievance_id
          AND grievance_status = 14
    );
    
   
   
   SELECT DISTINCT
    gl.grievance_id,
    gl.grievance_status,
    gl.assigned_on AS max_assigned_on,
    gl.assigned_by_office_id,
    gl.assigned_to_office_id,
    gl.assigned_to_office_cat,
    gl.assigned_by_office_cat
FROM
    grievance_lifecycle gl
WHERE
    gl.grievance_status = 3
    AND gl.assigned_on = (
        SELECT MAX(assigned_on)
        FROM grievance_lifecycle
        WHERE grievance_id = gl.grievance_id
          AND grievance_status = 3
    );

   
 select
		cgcm.grievance_cat_id,
    	gm.grievance_category,
        EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
    from
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
    join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category 
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
     	AND co.grievance_id = gm.grievance_id
    GROUP by
    	cgcm.grievance_cat_id,
        gm.grievance_category;
        
       
       SELECT gm.grievance_category,
        cgcm.grievance_category_desc,
        COUNT(DISTINCT gm.grievance_id) AS category_grievance_count
    FROM grievance_master gm 
    INNER JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    WHERE gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
    AND gm.grievance_source = 5
    and cgcm.benefit_scheme_type = 1 AND cgcm.status = 1
    GROUP BY gm.grievance_category, cgcm.grievance_category_desc
    ORDER BY category_grievance_count DESC ;
--    LIMIT 10;
   
   
   SELECT
        table1.grievance_category_desc,
        table1.grievance_cat_id,
        COALESCE(table2.grv_recvd, 0) AS grievances_received,
--        COALESCE(table3.atr_recvd, 0) + COALESCE(table4.total_disposed, 0) AS atr_recieved_count,
        COALESCE(table4.total_disposed, 0) AS grievances_disposed,
        COALESCE(table5.pending_with_hod, 0) AS grievances_pending,
        COALESCE(table6.days_diff, 0) AS days_diff,
        COALESCE(table7.benefit_provided, 0) AS benefit_provided,
        COALESCE(table8.mater_taken_up, 0) AS mater_taken_up,
	COALESCE(
	    CASE 
	        WHEN (COALESCE(table7.benefit_provided, 0) + COALESCE(table8.mater_taken_up, 0)) > 0 
	        THEN ROUND((COALESCE(table7.benefit_provided, 0)::FLOAT / NULLIF(COALESCE(table7.benefit_provided, 0) + COALESCE(table8.mater_taken_up, 0), 0)) * 100)
	        ELSE 0
    	END, 0
	) AS bsp_percentage
    FROM
        (
            SELECT
                cgcm.grievance_category_desc,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
             right join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                cgcm.benefit_scheme_type = 1 AND cgcm.status = 1 and gm.grievance_source = 5
            GROUP BY
                cgcm.grievance_category_desc,
                cgcm.grievance_cat_id
        ) table1
    -- Grievances received
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS grv_recvd,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
        join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status = 1 
        GROUP BY
            cgcm.grievance_cat_id
    ) table2 ON table1.grievance_cat_id = table2.grievance_cat_id
    -- ATR received
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS atr_recvd,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status = 14
        GROUP BY
            cgcm.grievance_cat_id
    ) table3 ON table1.grievance_cat_id = table3.grievance_cat_id
    -- Total disposed
    LEFT OUTER JOIN (
        select
        	COUNT(DISTINCT grievance_id) AS total_disposed,
        	cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status = 15
        GROUP BY
            cgcm.grievance_cat_id
    ) table4 ON table1.grievance_cat_id = table4.grievance_cat_id
    -- Grievances pending with HOD
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS pending_with_hod,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        GROUP BY
            cgcm.grievance_cat_id
    ) table5 ON table1.grievance_cat_id = table5.grievance_cat_id
    -- Average days for grievance
    LEFT OUTER JOIN (
       select
			cgcm.grievance_cat_id,
	--    	gm.grievance_category,
	        EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
    	from
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
   	 join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category 
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
     	AND co.grievance_id = gm.grievance_id
    GROUP by
    	cgcm.grievance_cat_id
    ) table6 ON table1.grievance_cat_id = table6.grievance_cat_id
    -- Benefit provided
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS benefit_provided,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
         join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.closure_reason_id = 1
        GROUP BY
            cgcm.grievance_cat_id
    ) table7 ON table1.grievance_cat_id = table7.grievance_cat_id
    -- Matter taken up
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS mater_taken_up,
            cgcm.grievance_cat_id
        FROM
            grievance_master gm
        join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
        WHERE
            gm.closure_reason_id IN (5, 9) 
        GROUP BY
            cgcm.grievance_cat_id
    ) table8 ON table1.grievance_cat_id = table8.grievance_cat_id
    ORDER BY
        grievance_category_desc asc;
        
       
       
       
select max(l.official_name) as official_name,
                max(l.role_master_name) as role_master_name ,
                l.position_id,
                max(l.official_and_role_name) as official_and_role_name ,
              	SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
--                SUM(CAST(gm AS INT)) AS new_grievances_forwarded,
                SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
                SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed,
                SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
                SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review ,
                SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod 
--                SUM(CAST(l.atr_disposed AS INT)) AS atr_disposed,
--                SUM(CAST(l.atr_disposal_pending AS INT)) AS atr_disposal_pending,
--                SUM(CAST(l.atr_returned_to_hods AS INT)) AS atr_returned_to_hods
            from cmo_user_wise_grievance_ssm l, grievance_master gm 
            where l.position_id = 0 or l.position_id in (
                SELECT 
                apm.position_id
                FROM 
                    admin_position_master apm 
                    INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
                    INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
                    INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
                    left join grievance_master gm ON gm.assigned_to_position = l.position_id
                where apm.role_master_id IN (1,2,3,9) AND apm.office_id = 1
            )
            group by l.position_id
            ORDER BY 
            CASE WHEN max(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
            max(official_name::text);
            
           
select max(l.official_name) as official_name,
        max(l.role_master_name) as role_master_name ,
        l.position_id,
        max(l.official_and_role_name) as official_and_role_name ,
      	SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
--        SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
--        SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed,
--        SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
--        SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review ,
--        SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod 
        SUM(CAST(l.atr_disposed AS INT)) AS atr_disposed,
        SUM(CAST(l.atr_disposal_pending AS INT)) AS atr_disposal_pending,
        SUM(CAST(l.atr_returned_to_hods AS INT)) AS atr_returned_to_hods
    from cmo_user_wise_grievance_ssm l, grievance_master gm 
    where l.position_id = 0 or l.position_id in (
        SELECT 
        apm.position_id
        FROM 
            admin_position_master apm 
            INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
            INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
            INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
--            left join grievance_master gm ON gm.assigned_to_position = l.position_id
        where apm.role_master_id IN (1,2,3,9) AND apm.office_id = 1
    )
    group by l.position_id
    ORDER BY 
    CASE WHEN max(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
    max(official_name::text);
    
   
   
WITH filtered_positions AS (
    SELECT 
        apm.position_id
    FROM 
        admin_position_master apm
        INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
        INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
        INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
    WHERE 
        apm.role_master_id IN (1,2,3,9) 
        AND apm.office_id = 1
)
SELECT 
    MAX(l.official_name) AS official_name,
    MAX(l.role_master_name) AS role_master_name,
    l.position_id,
    MAX(l.official_and_role_name) AS official_and_role_name,
    SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
    SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
    SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed,
    SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
    SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review,
    SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod
FROM 
    cmo_user_wise_grievance_ssm l
    LEFT JOIN grievance_master gm ON gm.assigned_to_position = l.position_id
WHERE 
    l.position_id = 0 
    OR l.position_id IN (SELECT position_id FROM filtered_positions)
GROUP BY 
    l.position_id
ORDER BY 
    CASE WHEN MAX(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
    MAX(official_name::text);
    
   
   select
    table1.office_id,
    table1.office_name,
    coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
    coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
    coalesce(table5.total_disposed,0) as total_disposed,
    coalesce(table6.pending_with_hod,0) as atr_pending,
    coalesce(table10.days_diff,0) as average_resolution_days,
    coalesce(table11.benefit_provided,0) as benefit_provided,
    coalesce(table12.mater_taken_up,0) as mater_taken_up,
--  coalesce(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS bsp_percentage,
--	'Good'::text AS performance
  --  coalesce(table8.grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
   -- coalesce(table9.grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
	-- coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER)) AS bsp_percentage,
    coalesce(CAST(((table11.benefit_provided::FLOAT / (table11.benefit_provided + table12.mater_taken_up)::FLOAT) * 100) AS INTEGER), 0) AS bsp_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
	FROM
        (
        select
            com.office_id ,
            com.office_name
        from
            cmo_office_master com
        where
            com.office_category = 2
                ) table1
        -- grv frwded
    left outer join(
        select
            count(distinct grievance_id) as grv_frwd,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            apm.office_id) table2
            on
        table1.office_id = table2.office_id
        -- atr recvd
    left outer join(
        select
            count(distinct grievance_id) as atr_recvd ,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.updated_by_position
        where
           gm.status = 14
        group by
            apm.office_id) table3
            on
        table1.office_id = table3.office_id
        -- total disposed 	
    left outer join(
        select
            count(1) as total_disposed,
            co.assigned_by_office_id
        from
            grievance_master gm
        join atr_submitted_max_records_clone co on
            co.grievance_id = gm.grievance_id
        where
        	gm.status = 15
        group by
            co.assigned_by_office_id) table5
            on
        table1.office_id = table5.assigned_by_office_id	
        -- grv pending with hod
    left outer join(
        select
            count(distinct grievance_id) as pending_with_hod ,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            gm.assigned_to_office_id) table6
            on
        table1.office_id = table6.assigned_to_office_id
 		-- average days for grievance
	left outer join (
	    select
	        ar.assigned_by_office_id,
	        extract (day
	    from
	        avg(ar.max_assigned_on - co.max_assigned_on)) as days_diff
	    from
	        atr_submitted_max_records_clone ar,
	        recvd_from_cmo_max_clone_view co,
	        grievance_master gm
	    where
	        ar.grievance_id = co.grievance_id
	        and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
	    group by
	        ar.assigned_by_office_id) table10
	        on
	    table10.assigned_by_office_id = table1.office_id
	    -- benifit provided
	left outer join (
	   select 
			count(distinct grievance_id) as benefit_provided,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.office_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id = 1
		group by 
			apm.office_id) table11
		on
		table1.office_id = table11.office_id
		-- matter taken up
	left outer join (
		select 
			count(distinct grievance_id) as mater_taken_up,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.position_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id in (5,9)
		group by 
			apm.office_id) table12
		on
		table1.office_id = table12.office_id
		ORDER BY 
		    office_name asc;
		    
		   
select
    table1.office_id,
    table1.office_name,
    coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
    coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
    coalesce(table5.total_disposed,0) as total_disposed,
    coalesce(table6.pending_with_hod,0) as atr_pending,
    coalesce(table10.days_diff,0) as average_resolution_days,
    coalesce(table11.benefit_provided,0) as benefit_provided,
    coalesce(table12.mater_taken_up,0) as mater_taken_up,
	-- coalesce(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS bsp_percentage,
	--  'Good'::text AS performance
  	-- coalesce(table8.grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
   	-- coalesce(table9.grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
	-- coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER)) AS bsp_percentage,
    coalesce(CAST(((table11.benefit_provided::FLOAT / (table11.benefit_provided + table12.mater_taken_up)::FLOAT) * 100) AS INTEGER), 0) AS bsp_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
	FROM
        (
        select
            com.office_id ,
            com.office_name
        from
            cmo_office_master com
        where
            com.office_category = 2
                ) table1
        -- grv frwded
    left outer join(
        select
            count(distinct grievance_id) as grv_frwd,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            apm.office_id) table2
            on
        table1.office_id = table2.office_id
        -- atr recvd
    left outer join(
        select
            count(distinct grievance_id) as atr_recvd ,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.updated_by_position
        where
           gm.status = 14
        group by
            apm.office_id) table3
            on
        table1.office_id = table3.office_id
        -- total disposed 	
    left outer join(
        select
            count(1) as total_disposed,
            co.assigned_by_office_id
        from
            grievance_master gm
        join atr_submitted_max_records_clone co on
            co.grievance_id = gm.grievance_id
        where
        	gm.status = 15
        group by
            co.assigned_by_office_id) table5
            on
        table1.office_id = table5.assigned_by_office_id	
        -- grv pending with hod
    left outer join(
        select
            count(distinct grievance_id) as pending_with_hod ,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            gm.assigned_to_office_id) table6
            on
        table1.office_id = table6.assigned_to_office_id
	    -- average days for grievance
	left outer join (
	    select
	        ar.assigned_by_office_id,
	        coalesce(CAST(extract(day from avg(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) as days_diff
	    from
	        atr_submitted_max_records_clone ar,
	        recvd_from_cmo_max_clone_view co,
	        grievance_master gm
	    where
	        ar.grievance_id = co.grievance_id
	        and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
	    group by
	        ar.assigned_by_office_id
	) table10
	on table10.assigned_by_office_id = table1.office_id
	    -- benifit provided
	left outer join (
	   select 
			count(distinct grievance_id) as benefit_provided,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.office_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id = 1
		group by 
			apm.office_id) table11
		on
		table1.office_id = table11.office_id
		-- matter taken up
	left outer join (
		select 
			count(distinct grievance_id) as mater_taken_up,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.position_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id in (5,9)
		group by 
			apm.office_id) table12
		on
		table1.office_id = table12.office_id
		ORDER BY 
		    office_name asc;
		    
		   
SELECT
            table1.grievance_category_desc,
            table1.grievance_cat_id,
            COALESCE(table2.grv_recvd, 0) AS grievances_received,
            COALESCE(table3.atr_recvd, 0) + COALESCE(table4.total_disposed, 0) AS atr_recieved_count,
            COALESCE(table4.total_disposed, 0) AS grievances_disposed,
            COALESCE(table5.pending_with_hod, 0) AS grievances_pending,
            COALESCE(table6.days_diff, 0) AS days_diff,
            COALESCE(table7.benefit_provided, 0) AS benefit_provided,
            COALESCE(table8.mater_taken_up, 0) AS mater_taken_up,
        COALESCE(
            CASE 
                WHEN (COALESCE(table7.benefit_provided, 0) + COALESCE(table8.mater_taken_up, 0)) > 0 
                THEN ROUND((COALESCE(table7.benefit_provided, 0)::FLOAT / NULLIF(COALESCE(table7.benefit_provided, 0) + COALESCE(table8.mater_taken_up, 0), 0)) * 100)
                ELSE 0
            END, 0
        ) AS bsp_percentage
        FROM
            (
                SELECT
                    cgcm.grievance_category_desc,
                    cgcm.grievance_cat_id
                FROM
                    grievance_master gm
                right join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
                WHERE
                    cgcm.benefit_scheme_type = 1 AND cgcm.status = 1 and gm.grievance_source = 5
                GROUP BY
                    cgcm.grievance_category_desc,
                    cgcm.grievance_cat_id
            ) table1
        -- Grievances received
        LEFT OUTER JOIN (
            SELECT
                COUNT(DISTINCT grievance_id) AS grv_recvd,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
            join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                gm.status = 1 
            GROUP BY
                cgcm.grievance_cat_id
        ) table2 ON table1.grievance_cat_id = table2.grievance_cat_id
        -- ATR received
        LEFT OUTER JOIN (
            SELECT
                COUNT(DISTINCT grievance_id) AS atr_recvd,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
            join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                gm.status = 14
            GROUP BY
                cgcm.grievance_cat_id
        ) table3 ON table1.grievance_cat_id = table3.grievance_cat_id
        -- Total disposed
        LEFT OUTER JOIN (
            select
                COUNT(DISTINCT grievance_id) AS total_disposed,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
            join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                gm.status = 15
            GROUP BY
                cgcm.grievance_cat_id
        ) table4 ON table1.grievance_cat_id = table4.grievance_cat_id
        -- Grievances pending with HOD
        LEFT OUTER JOIN (
            SELECT
                COUNT(DISTINCT grievance_id) AS pending_with_hod,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
            join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
            GROUP BY
                cgcm.grievance_cat_id
        ) table5 ON table1.grievance_cat_id = table5.grievance_cat_id
        -- Average days for grievance
        LEFT OUTER JOIN (
        select
               cgcm.grievance_cat_id,
				coalesce(CAST(extract(day from avg(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) as days_diff
            from
	            atr_submitted_max_records_clone ar,
	            recvd_from_cmo_max_clone_view co,
	            grievance_master gm
        join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category 
        WHERE
            ar.grievance_id = co.grievance_id
            AND ar.grievance_id = gm.grievance_id
            AND co.grievance_id = gm.grievance_id
        GROUP by
            cgcm.grievance_cat_id
        ) table6 ON table1.grievance_cat_id = table6.grievance_cat_id
        -- Benefit provided
        LEFT OUTER JOIN (
            SELECT
                COUNT(DISTINCT grievance_id) AS benefit_provided,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
            join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                gm.closure_reason_id = 1
            GROUP BY
                cgcm.grievance_cat_id
        ) table7 ON table1.grievance_cat_id = table7.grievance_cat_id
        -- Matter taken up
        LEFT OUTER JOIN (
            SELECT
                COUNT(DISTINCT grievance_id) AS mater_taken_up,
                cgcm.grievance_cat_id
            FROM
                grievance_master gm
            join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
            WHERE
                gm.closure_reason_id IN (5, 9) 
            GROUP BY
                cgcm.grievance_cat_id
        ) table8 ON table1.grievance_cat_id = table8.grievance_cat_id
        ORDER BY
            grievance_category_desc asc;
           
           
         select
                        table1.office_id,
                        table1.office_name,
                        coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
                        coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
                        coalesce(table5.total_disposed,0) as total_disposed,
                        coalesce(table6.pending_with_hod,0) as atr_pending,
                        coalesce(table10.days_diff,0) as average_resolution_days,
                        coalesce(table11.benefit_provided,0) as benefit_provided,
                        coalesce(table12.mater_taken_up,0) as mater_taken_up,
                        -- coalesce(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS bsp_percentage,
                        --  'Good'::text AS performance
                        -- coalesce(table8.grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
                        -- coalesce(table9.grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
                        -- coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER)) AS bsp_percentage,
                        coalesce(CAST(((table11.benefit_provided::FLOAT / (table11.benefit_provided + table12.mater_taken_up)::FLOAT) * 100) AS INTEGER), 0) AS bsp_percentage,
                        CASE
                            WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
                            WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
                            ELSE 'Poor'
                        END AS performance
                        FROM
                            (
                            select
                                com.office_id ,
                                com.office_name
                            from
                                cmo_office_master com
                            where
                                com.office_category = 2
                                    ) table1
                            -- grv frwded
                        left outer join(
                            select
                                count(distinct grievance_id) as grv_frwd,
                                apm.office_id
                            from
                                grievance_master gm
                            join admin_position_master apm on
                                apm.position_id = gm.assigned_to_position
                            where
                            gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
                            group by
                                apm.office_id) table2
                                on
                            table1.office_id = table2.office_id
                            -- atr recvd
                        left outer join(
                            select
                                count(distinct grievance_id) as atr_recvd ,
                                apm.office_id
                            from
                                grievance_master gm
                            join admin_position_master apm on
                                apm.position_id = gm.updated_by_position
                            where
                            gm.status = 14
                            group by
                                apm.office_id) table3
                                on
                            table1.office_id = table3.office_id
                            -- total disposed 	
                        left outer join(
                            select
                                count(1) as total_disposed,
                                co.assigned_by_office_id
                            from
                                grievance_master gm
                            join atr_submitted_max_records_clone co on
                                co.grievance_id = gm.grievance_id
                            where
                                gm.status = 15
                            group by
                                co.assigned_by_office_id) table5
                                on
                            table1.office_id = table5.assigned_by_office_id	
                            -- grv pending with hod
                        left outer join(
                            select
                                count(distinct grievance_id) as pending_with_hod ,
                                gm.assigned_to_office_id
                            from
                                grievance_master gm
                            join admin_position_master apm on
                                apm.position_id = gm.assigned_to_position
                            where
                            gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
                            group by
                                gm.assigned_to_office_id) table6
                                on
                            table1.office_id = table6.assigned_to_office_id
                            -- average days for grievance
                        left outer join (
                            select
                                ar.assigned_by_office_id,
                                coalesce(CAST(extract(day from avg(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) as days_diff
                            from
                                atr_submitted_max_records_clone ar,
                                recvd_from_cmo_max_clone_view co,
                                grievance_master gm
                            where
                                ar.grievance_id = co.grievance_id
                                and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
                            group by
                                ar.assigned_by_office_id
                        ) table10
                        on table10.assigned_by_office_id = table1.office_id
                            -- benifit provided
                        left outer join (
                        select 
                                count(distinct grievance_id) as benefit_provided,
                                apm.office_id
                            from
                                grievance_master gm
                            join admin_position_master apm on
                                apm.office_id = gm.assigned_to_office_id 
                            where 
                                gm.closure_reason_id = 1
                            group by 
                                apm.office_id) table11
                            on
                            table1.office_id = table11.office_id
                            -- matter taken up
                        left outer join (
                            select 
                                count(distinct grievance_id) as mater_taken_up,
                                apm.office_id
                            from
                                grievance_master gm
                            join admin_position_master apm on
                                apm.position_id = gm.assigned_to_office_id 
                            where 
                                gm.closure_reason_id in (5,9)
                            group by 
                                apm.office_id) table12
                            on
                            table1.office_id = table12.office_id
                            ORDER BY 
                                office_name asc;
                                
                               
                               
                               
WITH filtered_positions AS (
            SELECT 
                apm.position_id
            FROM 
                admin_position_master apm
                INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
                INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
                INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
            WHERE 
                apm.role_master_id IN (1,2,3,9) 
                AND apm.office_id = 1
        )
        SELECT 
            MAX(l.official_name) AS official_name,
            MAX(l.role_master_name) AS role_master_name,
            l.position_id,
            MAX(l.official_and_role_name) AS official_and_role_name,
            SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
            SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
            SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed,
            SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
            SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review,
            SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod
        FROM 
            cmo_user_wise_grievance_ssm l
            LEFT JOIN grievance_master gm ON gm.assigned_to_position = l.position_id
        WHERE 
            (l.position_id = 0 
            OR l.position_id IN (SELECT position_id FROM filtered_positions))
            and gm.grievance_source = 5
        GROUP BY 
            l.position_id
        ORDER BY 
--            CASE WHEN MAX(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
            MAX(official_name::text);
            
           
   
   WITH filtered_positions AS (
            SELECT 
                apm.position_id
            FROM 
                admin_position_master apm
                INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
                INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
                INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
            WHERE 
                apm.role_master_id IN (1,2,3,9) 
                AND apm.office_id = 1
        )
        SELECT 
            MAX(l.official_name) AS official_name,
            MAX(l.role_master_name) AS role_master_name,
            l.position_id,
            MAX(l.official_and_role_name) AS official_and_role_name,
            SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
            SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
            SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed,
            SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
            SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review,
            SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod
        FROM 
            cmo_user_wise_grievance_ssm l
            LEFT JOIN grievance_master gm ON gm.assigned_to_position = l.position_id
        WHERE 
            l.position_id = 0 
            OR l.position_id IN (SELECT position_id FROM filtered_positions)
        GROUP BY 
            l.position_id
        ORDER BY 
            CASE WHEN MAX(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
        MAX(official_name::text);
        
 select 
                table1.main_year :: int as converted_year,
                table1.main_month :: int as converted_month,
                coalesce(table2.grv_lodged,0) as grievance_recieved_count,
                coalesce(table3.grv_frwded,0) as grievance_forwarded_count,
                coalesce(table4.atr_recvd,0) as atr_submited_count,
                coalesce(table5.total_disposed,0) as grievance_closed_count
            --	coalesce(table6.atr_pending,0) as atr_pending
            from (
                select 
                    extract(year from a.month_date) as main_year,
                    extract(Month from a.month_date) as main_month	
                from
                (select generate_series('2024-04-01'::date, '2024-09-29'::date, '1 month') AS month_date)a
            )
            table1
    -- grv lodged
            left outer join (
                select count(1) as grv_lodged,
                DATE_PART('year', gm.updated_on) as t_year,
                DATE_PART('month', gm.updated_on) as t_month
                from grievance_master gm 
                where gm.updated_on between date (CURRENT_TIMESTAMP) - interval ' 6 month' and CURRENT_TIMESTAMP  
                group by t_year,t_month
            )table2
            on table1.main_year= table2.t_year and table1.main_month = table2.t_month
        -- grv frwded
            left outer join (
                select count(1) as grv_frwded,
                DATE_PART('year', gm.updated_on) as t_year,
                DATE_PART('month', gm.updated_on) as t_month
                from grievance_master gm 
                where gm.updated_on between date (CURRENT_TIMESTAMP) - interval ' 6 month' and CURRENT_TIMESTAMP 
                and gm.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)  
                group by t_year,t_month
            )table3
            on table1.main_year= table3.t_year and table1.main_month = table3.t_month
            -- atr recvd
            left outer join (
                select count(1) as atr_recvd,
                DATE_PART('year', gm.updated_on) as t_year,
                DATE_PART('month', gm.updated_on) as t_month
                from grievance_master gm 
                where gm.updated_on between date (CURRENT_TIMESTAMP) - interval ' 6 month' and CURRENT_TIMESTAMP 
                and gm.status in (14,15)  
                group by t_year,t_month
            )table4
            on table1.main_year= table4.t_year and table1.main_month = table4.t_month
        -- disposed
        left outer join (
            select count(1) as total_disposed,
            DATE_PART('year', gm.updated_on) as t_year,
            DATE_PART('month', gm.updated_on) as t_month
            from grievance_master gm 
            where gm.updated_on between date (CURRENT_TIMESTAMP) - interval ' 6 month' and CURRENT_TIMESTAMP 
            and gm.status = 15  
            group by t_year,t_month
        )table5
        on table1.main_year= table5.t_year and table1.main_month = table5.t_month
        order by main_year,main_month ; 
        
       
SELECT 
    com.office_name::text,
    COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) AS atr_received_count,
	COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
	CAST(COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_received_count_percentage,
	CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_pending_count_percentage
FROM 
    grievance_master gm
LEFT JOIN
    grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
LEFT JOIN 
    cmo_office_master com on com.office_id = gm.assigned_by_office_id 
WHERE  
     gm.grievance_source = 5
GROUP BY com.office_name
ORDER BY
    atr_pending_count DESC;
    
   
 SELECT 
                    bm.block_name,
                    bm.block_id,
                    NULL AS municipality_id,
                    NULL AS municipality_name,
                    cdm.population AS population, 
                    -- cdm.district_name as district,    
                    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
                    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS map_color_index,
                    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END) / NULLIF(cdm.population, 0)) * 100, 0) AS disposal_district_wise,
                    coalesce((gm.grievance_no::float / cdm.population::float) * 100, 0) AS grievances_lodged_district_wise,
                    coalesce((gm.grievance_no::float / cdm.population::float) * 100, 0) AS map_color_index,
                    coalesce((total_close_grievance_count::float / k.population::float) * 100, 0) as disposal_district_wise,
                    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
                    -- COALESCE(COUNT(gm.grievances_recieved), 0) AS total_grievance_count,
                    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
                    COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
                    COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
             		COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
			    FROM 
                    (SELECT DISTINCT block_id, block_name FROM cmo_blocks_master WHERE district_id = 20) bm
                LEFT JOIN 
                    grievance_master gm ON gm.block_id = bm.block_id AND gm.district_id = 20
                LEFT JOIN 
                    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
                GROUP BY 
                    bm.block_name,
                    bm.block_id,
                    cdm.population
                    -- cdm.district_name
                UNION ALL
                SELECT 
                    NULL AS block_name,
                    NULL AS block_id,
                    mm.municipality_id,
                    mm.municipality_name,
                    cdm.population AS population,
                    -- cdm.district_name as district,
                    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
                    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS map_color_index,
                    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END) / NULLIF(cdm.population, 0)) * 100, 0) AS disposal_district_wise,
                    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
                    -- COALESCE(COUNT(gm.grievances_recieved), 0) AS total_grievance_count,
                    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
                    COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
                    COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
                    COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
                FROM 
                    (SELECT DISTINCT municipality_id, municipality_name FROM cmo_municipality_master WHERE district_id = 20) mm
                LEFT JOIN 
                    grievance_master gm ON gm.municipality_id = mm.municipality_id AND gm.district_id = 20
                LEFT JOIN 
                    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
                GROUP BY 
                    mm.municipality_id,
                    mm.municipality_name,
                    cdm.population
                    --cdm.district_name
                ORDER BY
                    block_name, municipality_name;  
                    
                   
                   
SELECT 
    bm.block_name,
    bm.block_id,
    NULL AS municipality_id,
    NULL AS municipality_name,
    cdm.population, 
    COALESCE((COUNT(gm.grievance_no)::float / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
    COALESCE((COUNT(gm.grievance_no)::float / NULLIF(cdm.population, 0)) * 100, 0) AS map_color_index,
    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END)::float / NULLIF(cdm.population, 0)::float) * 100, 0) AS disposal_district_wise,
    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 14 THEN 1 ELSE 0 END), 0) AS atr_received,
    COALESCE(SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
    COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
from
    (SELECT DISTINCT block_id, block_name FROM cmo_blocks_master WHERE district_id = 20) bm
LEFT JOIN 
    grievance_master gm ON gm.block_id = bm.block_id AND gm.district_id = 20
LEFT JOIN 
    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
GROUP BY 
    bm.block_name,
    bm.block_id,
    cdm.population
UNION ALL
SELECT 
    NULL AS block_name,
    NULL AS block_id,
    mm.municipality_id,
    mm.municipality_name,
    cdm.population AS population, 
    COALESCE((COUNT(gm.grievance_no)::float / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
    COALESCE((COUNT(gm.grievance_no)::float / NULLIF(cdm.population, 0)) * 100, 0) AS map_color_index,
    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END)::float / NULLIF(cdm.population, 0)) * 100, 0) AS disposal_district_wise,
    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 14 THEN 1 ELSE 0 END), 0) AS atr_received,
    COALESCE(SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
    COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
FROM 
    (SELECT DISTINCT municipality_id, municipality_name FROM cmo_municipality_master WHERE district_id = 20) mm
LEFT JOIN 
    grievance_master gm ON gm.municipality_id = mm.municipality_id AND gm.district_id = 20
LEFT JOIN 
    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
GROUP BY 
    mm.municipality_id,
    mm.municipality_name,
    cdm.population
ORDER BY
    block_name, municipality_name;

   
SELECT 
    k.district_id as district_id,
    k.district_name as district_name,
    k.population as population,
    coalesce((k.grievances_recieved / k.population)  * 100, 0) AS grievances_lodged_district_wise,
    -- coalesce((k.grievances_recieved / k.population)  * 100, 0) AS map_color_index,
    coalesce((k.total_close_grievance_count / k.population) * 100, 0) as disposal_district_wise,
    -- coalesce((k.grievances_recieved::float / k.population::float) * 100, 0) AS grievances_lodged_district_wise,
    coalesce((k.grievances_recieved::float / k.population::float) * 100, 0) AS map_color_index,
    -- coalesce((k.total_close_grievance_count::float / k.population::float) * 100, 0) as disposal_district_wise,
    COALESCE(SUM(k.grievances_recieved), 0) :: INT AS total_grievance_count,
--                COALESCE(k.grievance_recieved_count_cmo ) :: INT AS grievance_sent, 
--                COALESCE(k.atr_submitted_to_cmo ) :: INT AS atr_received, 
    COALESCE(k.grievance_recieved_count_other_hod, 0) :: INT AS grievance_recieved_count_other_hod,
    COALESCE(k.total_close_grievance_count, 0) :: INT AS close_grievance_count,
    COALESCE(k.atr_pending, 0) :: INT AS atr_pending,
    COALESCE(k.atr_received, 0) :: INT AS atr_received,
    COALESCE(k.grievance_sent, 0) :: INT AS grievance_sent
    from (
        select  
            cdm.district_id,
            cdm.district_name,
            cdm.population,
            COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
            COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
            COUNT(case when gm.status = 3 then gm.grievance_id end) as grievance_recieved_count_cmo,
            COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
            COUNT(case when gm.status = 5 then gm.grievance_id end) as grievance_recieved_count_other_hod,
            COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
            COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
            COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
            COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
            COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
            COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
            COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
            COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
            COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
            COUNT(case when gm.status = 15 then gm.grievance_id end) AS total_close_grievance_count,
            COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
            COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
            COUNT(1) as grievances_recieved,
            COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
            COUNT(case when gm.status in (14,15) then gm.grievance_id end) as atr_received,
            COUNT(case when gm.status not in (1,2) then gm.grievance_id end) as grievance_sent
            from grievance_master gm
            inner join cmo_districts_master cdm on cdm.district_id  = gm.district_id  
            AND gm.district_id NOT IN (99, 999) 
            WHERE gm.status > 0	/*and gm.grievance_id in (
    select distinct grievance_id from grievance_lifecycle gl2 
    where gl2.grievance_status = 3 and gl2.assigned_by_position in 
    (
    select apm.position_id from admin_position_master apm
    where apm.office_id = 1
    )
    ) */ group by cdm.district_name ,cdm.district_id
    )k
    group by 
    k.district_id,
    k.district_name,
    k.population,
    k.grievances_recieved,
--  k.grievance_recieved_count_cmo,
    k.grievance_recieved_count_other_hod,
    k.atr_pending,
    k.atr_received,
    k.grievance_sent,
    k.total_close_grievance_count,
    k.grievance_recieved_count_cmo,
    k.grievance_recieved_count_other_hod,
    k.atr_submitted_to_cmo;  
    
   
   select
					count(1) as gender_wise_count,
--					SUM(gender_wise_count) as total_count,
--					SUM(count(1)) as total_count
					COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_received_male_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_female_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_others_percentage
					cast((COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END)  / gender_wise_count * 100) as bigint) AS grievances_recieved_male_percentage,
					cast((COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END)  / gender_wise_count * 100) as bigint) AS grievances_recieved_female_percentage,
				    cast((COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END)  / gender_wise_count * 100) as bigint) AS grievances_recieved_others_percentage
				from grievance_master gm
				where gm.grievance_source = ssm_id
				and (gm.assigned_to_position in 
					(select apm.position_id
					from admin_position_master apm
					where apm.office_id = dept_id)
					or gm.updated_by_position in 
						(select apm.position_id
						from admin_position_master apm
						where apm.office_id = dept_id)
					);
					
				
				
				
				
				
				
				
				
				
				
				select * from cmo_grievance_category_master cgcm where cgcm.status = 1;

select grievance_category_desc as grievance_category_name, count(1) as grievance_count
	from cmo_grievance_category_master cgcm 
	left join grievance_master gm on gm.grievance_category = cgcm.grievance_cat_id 
	where gm.status = 3
	group by grievance_category_name;



select  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    coalesce(table0.office_name,'N/A') as office_name,
    table1.office_id,
    coalesce(table1.grv_uploaded,0) as griev_upload,
    coalesce(table2.grv_frwd_assigned,0) as grv_fwd,
    coalesce(table3.atr_recvd,0) as atr_rcvd,
    coalesce(table5.total_closed,0) as totl_dspsd,
    coalesce(table5.bnft_prvd,0) as srv_prvd,
    coalesce(table5.action_taken,0) as action_taken,
    coalesce(table5.not_elgbl,0) as not_elgbl,
    coalesce(table9.atr_pndg, 0) as atr_pndg,
 	COALESCE(ROUND(CASE 
        WHEN (bnft_prvd + action_taken) = 0 THEN 0
            ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
            END,2),0) AS bnft_prcnt
        from
        (
         select distinct grievance_cat_id,grievance_category_desc, parent_office_id, com.office_name
        	from cmo_grievance_category_master cgcm
        	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
        	where cgcm.status = 1
        )table0
	  left outer join
	        (
	        select  cog.grievance_category_desc ,cog.office_name,cog.office_id,
	            cog.grievance_cat_id,count(1) as grv_uploaded
	            from cat_offc_grievances cog 
	            where 
	            grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP
	        group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id
	        )table1
			on table0.grievance_cat_id = table1.grievance_cat_id
	        -- griev frwded
	  left outer join (
	        select count(1) as grv_frwd_assigned, cog.grievance_cat_id  from cat_offc_grievances cog 
	        where grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
	        	and cog.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
	        group by cog.grievance_cat_id) table2
	        on table2.grievance_cat_id=table0.grievance_cat_id
	        -- total atr recieved
	  left outer join (
	        select count(1) as atr_recvd, cog.grievance_cat_id  from cat_offc_grievances cog 
	        where 
			grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP and
	        cog.status in (14,15)
	        group by cog.grievance_cat_id) table3
	        on table3.grievance_cat_id=table0.grievance_cat_id
	        -- total closed
	  left outer join (
	        select count(1) as total_closed, 
	        sum(case when cog.status = 15 and cog.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when cog.status = 15 and cog.closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
	        sum(case when cog.status = 15 and cog.closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl,
	        cog.grievance_cat_id  
	        from cat_offc_grievances cog 
	        where grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
	        and cog.status = 15
	        group by cog.grievance_cat_id) table5
	         on table5.grievance_cat_id=table0.grievance_cat_id
	        -- atr pending
	  left outer join (
	        select count(1) as atr_pndg, cog.grievance_cat_id  from cat_offc_grievances cog 
	        where grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
	        and cog.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)
	        group by cog.grievance_cat_id) table9
	        on table9.grievance_cat_id=table0.grievance_cat_id;
	        
	       
	       
	       
	       
	       
	    select  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            coalesce(table0.office_name,'N/A') as office_name,
            table1.office_id,
            coalesce(table1.grv_uploaded,0) as griev_upload,
            coalesce(table2.grv_frwd_assigned,0) as grv_fwd,
            coalesce(table3.atr_recvd,0) as atr_rcvd,
            coalesce(table5.total_closed,0) as totl_dspsd,
            coalesce(table5.bnft_prvd,0) as srv_prvd,
            coalesce(table5.action_taken,0) as action_taken,
            coalesce(table5.not_elgbl,0) as not_elgbl,
            coalesce(table9.atr_pndg, 0) as atr_pndg,
         	COALESCE(ROUND(CASE 
	            WHEN (bnft_prvd + action_taken) = 0 THEN 0
	            ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
	            END,2),0) AS bnft_prcnt
            from
        (
          select distinct grievance_cat_id,grievance_category_desc, parent_office_id, com.office_name
           	from cmo_grievance_category_master cgcm
            	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
            	where cgcm.status = 1
            )table0
   left outer join(
   	  select cog.grievance_category_desc ,cog.office_name,cog.office_id, cog.grievance_cat_id,count(1) as grv_uploaded
         from cat_offc_grievances cog 
            where grievance_generate_date between {from_date} and {to_date}
                {data_source}
                {scm_cat_q}
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id
            )table1
			on table0.grievance_cat_id = table1.grievance_cat_id
            -- griev frwded
   left outer join (
      select count(1) as grv_frwd_assigned, cog.grievance_cat_id  from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} and cog.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table2
            on table2.grievance_cat_id=table0.grievance_cat_id
            -- total atr recieved
   left outer join (
      select count(1) as atr_recvd, cog.grievance_cat_id  from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} and cog.status in (14,15)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table3
            on table3.grievance_cat_id=table0.grievance_cat_id
            -- total closed
   left outer join (
      select count(1) as total_closed, 
            sum(case when cog.status = 15 and cog.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when cog.status = 15 and cog.closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
	        sum(case when cog.status = 15 and cog.closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl,
            cog.grievance_cat_id  
            from cat_offc_grievances cog 
            where grievance_generate_date between {from_date} and {to_date} and cog.status = 15
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table5
            on table5.grievance_cat_id=table0.grievance_cat_id
            -- atr pending
   left outer join (
       select count(1) as atr_pndg, cog.grievance_cat_id  from cat_offc_grievances cog 
           where grievance_generate_date between {from_date} and {to_date} and cog.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table9
            on table9.grievance_cat_id=table0.grievance_cat_id;
            
           
           
       -- office category wise grievance count --                 
 select  
            table0.grievance_cat_id,
            table0.grievance_category_desc as grievance_cat_name,
            coalesce(table0.office_name,'N/A') as office_name,
            table1.office_id,
            coalesce(table1.grv_rcvd,0) as grievances_received_from_cmo,
            coalesce(table2.grv_frwd_to_suboff,0) as grievances_forwarded_to_suboffice,
            coalesce(table3.grv_frwd_to_hod,0) as grievances_forwarded_to_hod,
            coalesce(table4.grv_frwd,0) as grievance_forwarded,
            coalesce(table5.bnft_prvd,0) as srv_prvd,
            coalesce(table5.action_taken,0) as action_taken,
            coalesce(table7.atr_rcvd,0) as atr_received,
            coalesce(table9.atr_pndg, 0) as atr_pndg,
         	COALESCE(ROUND(CASE 
	            WHEN (bnft_prvd + action_taken) = 0 THEN 0
	            ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
	            END,2),0) AS bnft_prcnt
            from(
      select 
          distinct grievance_cat_id, 
          grievance_category_desc, 
          parent_office_id, 
          com.office_name
           	from cmo_grievance_category_master cgcm
            	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
            	where cgcm.status = 1
            )table0
      -- griv received from cmo --    
   left outer join(
   	select 
		cog.grievance_category_desc,
		cog.office_name,
		cog.office_id,
		cog.grievance_cat_id, 
		count(1) as grv_rcvd
	from cat_offc_grievances cog 
		where grievance_generate_date between {from_date} and {to_date} 
		and cog.status = 3 
		{data_source} 
		{scm_cat_q}
	group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id) table1
			on table0.grievance_cat_id = table1.grievance_cat_id
	-- griev frwded to suboffice
   left outer join (
   	select 
      	count(1) as grv_frwd_to_suboff, 
      	cog.grievance_cat_id  
      from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (7,8,9,10,12)
          {data_source}
          {scm_cat_q}
    group by cog.grievance_cat_id) table2
            on table2.grievance_cat_id = table0.grievance_cat_id
     -- griev frwded to hod
   left outer join (
   	select 
      	count(1) as grv_frwd_to_hod, 
      	cog.grievance_cat_id  
      from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (3,4,5,6,7,8,9,10,11,12,13)
          {data_source}
          {scm_cat_q}
    group by cog.grievance_cat_id) table3
            on table3.grievance_cat_id = table0.grievance_cat_id
     -- griev frwded
   left outer join (
      select 
	      count(1) as grv_frwd, 
	      cog.grievance_cat_id 
     from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
            {data_source}
            {scm_cat_q}
        group by cog.grievance_cat_id) table4
            on table4.grievance_cat_id=table0.grievance_cat_id
    -- total atr recieved
   left outer join (
      select 
	      count(1) as atr_rcvd, 
	      cog.grievance_cat_id  
	  from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (14,15)
            {data_source}
            {scm_cat_q}
         group by cog.grievance_cat_id) table7
            on table7.grievance_cat_id = table0.grievance_cat_id
            
            
            
            
            
            
            
            
            
            
            
            -- view --		
			
CREATE OR REPLACE VIEW public.cat_offc_grievances
AS SELECT gm.grievance_id,
    cm.grievance_cat_id,
    cm.grievance_category_desc,
    om.office_id,
    om.office_name,
    gm.closure_reason_id,
    gm.atr_recv_cmo_flag,
    gm.grievance_generate_date,
    gm.received_at,
    gm.grievance_source,
    cm.benefit_scheme_type,
    gm.status,
    cm.status AS grievance_category_status
   FROM cmo_grievance_category_master cm
     LEFT JOIN grievance_master gm ON cm.grievance_cat_id = gm.grievance_category
     LEFT JOIN cmo_office_master om ON om.office_id = cm.parent_office_id
  WHERE cm.status = 1;
  
-- DROP VIEW IF EXISTS public.cat_offc_grievances;
 
 SELECT gm.grievance_id,
    gm.status,
    gm.grievance_category,
    cgcm.grievance_category_desc,
    cgcm.parent_office_id AS office_id,
    om.office_name,
    gm.assigned_to_position,
    gm.updated_on,
    gm.closure_reason_id,
    cgcm.benefit_scheme_type,
    gm.grievance_source
   FROM grievance_master gm,
    cmo_grievance_category_master cgcm,
    cmo_office_master om
  WHERE gm.grievance_category = cgcm.grievance_cat_id AND om.office_id = cgcm.parent_office_id;
 
 
 select cog.grievance_category_desc ,cog.office_name, cog.office_id, cog.grievance_cat_id, count(1) as grv_rcvd
         from cat_offc_grievances cog 
         LEFT JOIN grievance_master gm ON cog.grievance_cat_id = gm.grievance_category
            where cog.grievance_generate_date between '2024-11-09' and '2023-11-09'
            and gm.status = 3
                and cog.grievance_source in (3,5)--{data_source}
--                and benefit_scheme_type = --{scm_cat_q}
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id;
            
           
           
select 
	cog.grievance_category_desc,
	cog.office_name,
	cog.office_id,
	cog.status,
	cog.grievance_cat_id, count(1) as grv_rcvd
from cat_offc_grievances cog 
where /*grievance_generate_date between {from_date} and {to_date} and */ cog.status in (7,8,9,10,12) and cog.grievance_source in (5,3)--{data_source}
                -- and benefit_scheme_type = --{scm_cat_q}
group by grievance_cat_id,grievance_category_desc,office_name,status,cog.office_id;
           
           

      select 
      	count(1) as grv_frwd_to_suboff, 
      	cog.grievance_cat_id  
      from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (7,8,9,10,12)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table2
            on table2.grievance_cat_id=table0.grievance_cat_id





 select * from cmo_domain_lookup_master cdlm where domain_type = 'grievance_source';
 

select  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            coalesce(table0.office_name,'N/A') as office_name,
            --  table1.office_id,
            coalesce(table1.grv_rcvd,0) as grievances_received_from_cmo,
            coalesce(table2.grv_frwd_to_suboff,0) as grievances_forwarded_to_suboffice,
            coalesce(table3.grv_frwd_to_othr_hod,0) as grievances_forwarded_to_other_hod,
            coalesce(table2.grv_frwd_to_suboff, 0) + coalesce(table3.grv_frwd_to_othr_hod, 0) as total_grievance_forwarded,		-- total_griv_frwd
            coalesce(table4.atr_rcvd_from_suboff,0) as atr_received_from_sub_office,
            coalesce(table5.atr_rcvd_from_othr_hods,0) as atr_received_from_other_hods,
            coalesce(table4.atr_rcvd_from_suboff,0) + coalesce(table5.atr_rcvd_from_othr_hods,0) as total_atr_received, 		-- total_atr_rcvd
            coalesce(table6.atr_rcvd_from_cmo,0) as atr_received_from_cmo
                from(
        select 
            distinct cgcm.grievance_cat_id, 
            cgcm.grievance_category_desc, 
            cgcm.parent_office_id, 
            com.office_name
                    from cmo_grievance_category_master cgcm
                        left join cmo_office_master com on cgcm.parent_office_id = com.office_id
                        where cgcm.status = 1
                    )table0
            -- griv received from cmo --    
        left outer join(
            select 
                cog.grievance_category_desc,
                cog.office_name,
                cog.office_id,
                cog.grievance_cat_id, 
                count(1) as grv_rcvd
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status not in (1,2) 
                {office}
                {data_source} 
                {received_at}
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id) table1
                    on table0.grievance_cat_id = table1.grievance_cat_id
            -- griev frwded to suboffice
        left outer join (
            select 
                count(1) as grv_frwd_to_suboff, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status not in (1,2,3,4)
                {office}
                {data_source}
                {received_at}
            group by cog.grievance_cat_id) table2
                    on table2.grievance_cat_id = table0.grievance_cat_id
            -- griev frwded to other hod
        left outer join (
            select 
                count(1) as grv_frwd_to_othr_hod, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (5,6,13,14,15,16,17)
                {office}
                {data_source}
                {received_at}
            group by cog.grievance_cat_id) table3
                    on table3.grievance_cat_id = table0.grievance_cat_id
            -- atr received from suboffice
        left outer join (
            select 
                count(1) as atr_rcvd_from_suboff, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (9,10,11,12,14,15)
                    {office}
                    {data_source}
                    {received_at}
                group by cog.grievance_cat_id) table4
                    on table4.grievance_cat_id = table0.grievance_cat_id
            -- atr received from other hods
        left outer join (
            select 
                count(1) as atr_rcvd_from_othr_hods, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (13,14,15,16,17)
                    {office}
                    {data_source}
                    {received_at}
                group by cog.grievance_cat_id) table5
                    on table5.grievance_cat_id = table0.grievance_cat_id
            -- atr sent to cmo
        left outer join (
            select 
                count(1) as atr_rcvd_from_cmo, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (14,15)
                    {office}
                    {data_source}
                    {received_at}
                group by cog.grievance_cat_id) table6
                    on table6.grievance_cat_id = table0.grievance_cat_id;
                    
                   
                   
                   
select  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            coalesce(table0.office_name,'N/A') as office_name,
            --  table1.office_id,
            coalesce(table1.grv_rcvd,0) as grievances_received_from_cmo,
            coalesce(table2.grv_frwd_to_suboff,0) as grievances_forwarded_to_suboffice,
            coalesce(table3.grv_frwd_to_othr_hod,0) as grievances_forwarded_to_other_hod,
            coalesce(table2.grv_frwd_to_suboff, 0) + coalesce(table3.grv_frwd_to_othr_hod, 0) as total_grievance_forwarded,		-- total_griv_frwd
            coalesce(table4.atr_rcvd_from_suboff,0) as atr_received_from_sub_office,
            coalesce(table5.atr_rcvd_from_othr_hods,0) as atr_received_from_other_hods,
            coalesce(table4.atr_rcvd_from_suboff,0) + coalesce(table5.atr_rcvd_from_othr_hods,0) as total_atr_received, 		-- total_atr_rcvd
            coalesce(table6.atr_rcvd_from_cmo,0) as atr_received_from_cmo
                from(
        select 
            distinct cgcm.grievance_cat_id, 
            cgcm.grievance_category_desc, 
            cgcm.parent_office_id, 
            com.office_name
                    from cmo_grievance_category_master cgcm
                        left join cmo_office_master com on cgcm.parent_office_id = com.office_id
                        where cgcm.status = 1
                    )table0
            -- griv received from cmo --    
        left outer join(
            select 
                cog.grievance_category_desc,
                cog.office_name,
                cog.office_id,
                cog.grievance_cat_id, 
                count(1) as grv_rcvd
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status not in (1,2) 
                and cog.office_id in (7)
                and cog.grievance_source in (5) 
                
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id) table1
                    on table0.grievance_cat_id = table1.grievance_cat_id
            -- griev frwded to suboffice
        left outer join (
            select 
                count(1) as grv_frwd_to_suboff, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status not in (1,2,3,4)
                and cog.office_id in (7)
                and cog.grievance_source in (5)
                
            group by cog.grievance_cat_id) table2
                    on table2.grievance_cat_id = table0.grievance_cat_id
            -- griev frwded to other hod
        left outer join (
            select 
                count(1) as grv_frwd_to_othr_hod, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (5,6,13,14,15,16,17)
                and cog.office_id in (7)
                and cog.grievance_source in (5)
                
            group by cog.grievance_cat_id) table3
                    on table3.grievance_cat_id = table0.grievance_cat_id
            -- atr received from suboffice
        left outer join (
            select 
                count(1) as atr_rcvd_from_suboff, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (9,10,11,12,14,15)
                    and cog.office_id in (7)
                    and cog.grievance_source in (5)
                    
                group by cog.grievance_cat_id) table4
                    on table4.grievance_cat_id = table0.grievance_cat_id
            -- atr received from other hods
        left outer join (
            select 
                count(1) as atr_rcvd_from_othr_hods, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (13,14,15,16,17)
                    and cog.office_id in (7)
                    and cog.grievance_source in (5)
                    
                group by cog.grievance_cat_id) table5
                    on table5.grievance_cat_id = table0.grievance_cat_id
            -- atr sent to cmo
        left outer join (
            select 
                count(1) as atr_rcvd_from_cmo, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (14,15)
                    and cog.office_id in (7)
                    and cog.grievance_source in (5)
                    
                group by cog.grievance_cat_id) table6
                    on table6.grievance_cat_id = table0.grievance_cat_id;
                    
                   
                   
                   select 
                count(1) as atr_rcvd_from_cmo, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where /*grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
                and*/ cog.status in (14,15)
                    and cog.office_id in (7)
                    group by cog.grievance_cat_id;
                    
                   
                   
SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table1.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table1.grv_rcvd, 0) AS grievances_received_from_cmo,
    COALESCE(table2.grv_frwd_to_suboff, 0) AS grievances_forwarded_to_suboffice,
    COALESCE(table3.grv_frwd_to_othr_hod, 0) AS grievances_forwarded_to_other_hod,
    COALESCE(table2.grv_frwd_to_suboff, 0) + COALESCE(table3.grv_frwd_to_othr_hod, 0) AS total_grievance_forwarded, -- total_griv_frwd
    COALESCE(table4.atr_rcvd_from_suboff, 0) AS atr_received_from_sub_office,
    COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS atr_received_from_other_hods,
    COALESCE(table4.atr_rcvd_from_suboff, 0) + COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS total_atr_received, -- total_atr_rcvd
    COALESCE(table6.atr_rcvd_from_cmo, 0) AS atr_received_from_cmo
FROM (
    SELECT 
        DISTINCT cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        com.office_id AS office_id,
        com.office_name
    FROM cmo_grievance_category_master cgcm
    LEFT JOIN cmo_office_master com ON cgcm.parent_office_id = com.office_id
    WHERE cgcm.status = 1
    AND com.office_id IN (7)  -- Filtering by specific office_id(s)
) table0
-- Grievances received from CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        cog.office_id,
        COUNT(1) AS grv_rcvd
    FROM cat_offc_grievances cog 
    WHERE cog.status NOT IN (1,2) 
    AND cog.office_id IN (7)  -- Apply office filter
    GROUP BY cog.grievance_cat_id, cog.office_id
) table1 ON table0.grievance_cat_id = table1.grievance_cat_id AND table0.office_id = table1.office_id
-- Grievances forwarded to suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        cog.office_id,
        COUNT(1) AS grv_frwd_to_suboff
    FROM cat_offc_grievances cog 
    WHERE cog.status NOT IN (1,2,3,4)
    AND cog.office_id IN (7)  -- Apply office filter
    GROUP BY cog.grievance_cat_id, cog.office_id
) table2 ON table0.grievance_cat_id = table2.grievance_cat_id AND table0.office_id = table2.office_id
-- Grievances forwarded to other HOD
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        cog.office_id,
        COUNT(1) AS grv_frwd_to_othr_hod
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (5,6,13,14,15,16,17)
    AND cog.office_id IN (7)  -- Apply office filter
    GROUP BY cog.grievance_cat_id, cog.office_id
) table3 ON table0.grievance_cat_id = table3.grievance_cat_id AND table0.office_id = table3.office_id
-- ATR received from suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        cog.office_id,
        COUNT(1) AS atr_rcvd_from_suboff
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (9,10,11,12,14,15)
    AND cog.office_id IN (7)  -- Apply office filter
    GROUP BY cog.grievance_cat_id, cog.office_id
) table4 ON table0.grievance_cat_id = table4.grievance_cat_id AND table0.office_id = table4.office_id
-- ATR received from other HODs
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        cog.office_id,
        COUNT(1) AS atr_rcvd_from_othr_hods
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (13,14,15,16,17)
    AND cog.office_id IN (7)  -- Apply office filter
    GROUP BY cog.grievance_cat_id, cog.office_id
) table5 ON table0.grievance_cat_id = table5.grievance_cat_id AND table0.office_id = table5.office_id
-- ATR sent to CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        cog.office_id,
        COUNT(1) AS atr_rcvd_from_cmo
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (14,15)
    AND cog.office_id IN (7)  -- Apply office filter
    GROUP BY cog.grievance_cat_id, cog.office_id
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id AND table0.office_id = table6.office_id;


SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table0.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table1.grv_rcvd, 0) AS grievances_received_from_cmo,
    COALESCE(table2.grv_frwd_to_suboff, 0) AS grievances_forwarded_to_suboffice,
    COALESCE(table3.grv_frwd_to_othr_hod, 0) AS grievances_forwarded_to_other_hod,
    COALESCE(table2.grv_frwd_to_suboff, 0) + COALESCE(table3.grv_frwd_to_othr_hod, 0) AS total_grievance_forwarded,
    COALESCE(table4.atr_rcvd_from_suboff, 0) AS atr_received_from_sub_office,
    COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS atr_received_from_other_hods,
    COALESCE(table4.atr_rcvd_from_suboff, 0) + COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS total_atr_received,
    COALESCE(table6.atr_rcvd_from_cmo, 0) AS atr_received_from_cmo
FROM (
    SELECT 
        DISTINCT cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        com.office_id AS office_id,
        com.office_name
    FROM cmo_grievance_category_master cgcm
    LEFT JOIN cmo_office_master com ON cgcm.parent_office_id = com.office_id
    WHERE cgcm.status = 1
) table0
-- Grievances received from CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_rcvd
    FROM cat_offc_grievances cog 
    WHERE cog.status NOT IN (1, 2)
    GROUP BY cog.grievance_cat_id
) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
-- Grievances forwarded to suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_frwd_to_suboff
    FROM cat_offc_grievances cog 
    WHERE cog.status NOT IN (1, 2, 3, 4)
    GROUP BY cog.grievance_cat_id
) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
-- Grievances forwarded to other HOD
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_frwd_to_othr_hod
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (5, 6, 13, 14, 15, 16, 17)
    GROUP BY cog.grievance_cat_id
) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
-- ATR received from suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_suboff
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (9, 10, 11, 12, 14, 15)
    GROUP BY cog.grievance_cat_id
) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
-- ATR received from other HODs
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_othr_hods
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (13, 14, 15, 16, 17)
    GROUP BY cog.grievance_cat_id
) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
-- ATR sent to CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_cmo
    FROM cat_offc_grievances cog 
    WHERE cog.status IN (14, 15)
    GROUP BY cog.grievance_cat_id
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id WHERE table0.office_id IN (9);  -- Replace with the desired office_id(s)



SELECT gm.grievance_id,
    cm.grievance_cat_id,
    cm.grievance_category_desc,
    om.office_id,
    om.office_name,
    gm.closure_reason_id,
    gm.atr_recv_cmo_flag,
    gm.grievance_generate_date,
    gm.received_at,
    gm.grievance_source,
    cm.benefit_scheme_type,
    gm.status,
    cm.status AS grievance_category_status
   FROM cmo_grievance_category_master cm
     LEFT JOIN grievance_master gm ON cm.grievance_cat_id = gm.grievance_category
     LEFT JOIN cmo_office_master om ON om.office_id = cm.parent_office_id
  WHERE cm.status = 1 and om.office_id = 9;
  

 
SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table1.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table1.grv_rcvd, 0) AS grievances_received_from_cmo,
    COALESCE(table2.grv_frwd_to_suboff, 0) AS grievances_forwarded_to_suboffice,
    COALESCE(table3.grv_frwd_to_othr_hod, 0) AS grievances_forwarded_to_other_hod,
    COALESCE(table2.grv_frwd_to_suboff, 0) + COALESCE(table3.grv_frwd_to_othr_hod, 0) AS total_grievance_forwarded,
    COALESCE(table4.atr_rcvd_from_suboff, 0) AS atr_received_from_sub_office,
    COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS atr_received_from_other_hods,
    COALESCE(table4.atr_rcvd_from_suboff, 0) + COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS total_atr_received,
    COALESCE(table6.atr_rcvd_from_cmo, 0) AS atr_received_from_cmo,
    table0.grievance_source  -- Include grievance_source in the final output
FROM (
    SELECT DISTINCT 
        cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        cgcm.parent_office_id, 
        com.office_id AS office_id,
        com.office_name,
        gm.grievance_source  -- Add grievance_source from the view
    FROM cmo_grievance_category_master cgcm
    LEFT JOIN grievance_master gm ON cgcm.grievance_cat_id = gm.grievance_category
    LEFT JOIN cmo_office_master com ON cgcm.parent_office_id = com.office_id
    WHERE cgcm.status = 1
) AS table0
-- Grievances received from CMO
LEFT OUTER JOIN (
    SELECT 
        cog.grievance_category_desc,
        cog.office_name,
        cog.office_id,
        cog.grievance_cat_id,
        count(1) AS grv_rcvd
    FROM cat_offc_grievances cog
    WHERE cog.status NOT IN (1, 2)
        AND cog.grievance_source IN (5)  -- Apply grievance_source filter
    GROUP BY grievance_cat_id, grievance_category_desc, office_name, cog.office_id
) AS table1 ON table0.grievance_cat_id = table1.grievance_cat_id
-- Grievances forwarded to suboffice
LEFT OUTER JOIN (
    SELECT 
        count(1) AS grv_frwd_to_suboff, 
        cog.grievance_cat_id  
    FROM cat_offc_grievances cog
    WHERE cog.status NOT IN (1, 2, 3, 4)
        AND cog.grievance_source IN (5)  -- Apply grievance_source filter
    GROUP BY cog.grievance_cat_id
) AS table2 ON table2.grievance_cat_id = table0.grievance_cat_id
-- Grievances forwarded to other HOD
LEFT OUTER JOIN (
    SELECT 
        count(1) AS grv_frwd_to_othr_hod, 
        cog.grievance_cat_id  
    FROM cat_offc_grievances cog
    WHERE cog.status IN (5, 6, 13, 14, 15, 16, 17)
        AND cog.grievance_source IN (5)  -- Apply grievance_source filter
    GROUP BY cog.grievance_cat_id
) AS table3 ON table3.grievance_cat_id = table0.grievance_cat_id
-- ATR received from suboffice
LEFT OUTER JOIN (
    SELECT 
        count(1) AS atr_rcvd_from_suboff, 
        cog.grievance_cat_id 
    FROM cat_offc_grievances cog
    WHERE cog.status IN (9, 10, 11, 12, 14, 15)
        AND cog.grievance_source IN (5)  -- Apply grievance_source filter
    GROUP BY cog.grievance_cat_id
) AS table4 ON table4.grievance_cat_id = table0.grievance_cat_id
-- ATR received from other HODs
LEFT OUTER JOIN (
    SELECT 
        count(1) AS atr_rcvd_from_othr_hods, 
        cog.grievance_cat_id 
    FROM cat_offc_grievances cog
    WHERE cog.status IN (13, 14, 15, 16, 17)
        AND cog.grievance_source IN (5)  -- Apply grievance_source filter
    GROUP BY cog.grievance_cat_id
) AS table5 ON table5.grievance_cat_id = table0.grievance_cat_id
-- ATR sent to CMO
LEFT OUTER JOIN (
    SELECT 
        count(1) AS atr_rcvd_from_cmo, 
        cog.grievance_cat_id  
    FROM cat_offc_grievances cog
    WHERE cog.status IN (14, 15)
        AND cog.grievance_source IN (5)  -- Apply grievance_source filter
    GROUP BY cog.grievance_cat_id
) AS table6 ON table6.grievance_cat_id = table0.grievance_cat_id WHERE table0.office_id IN (7);  -- Filter for specific office



SELECT 
        count(1) AS grv_frwd_to_othr_hod, 
        cog.grievance_cat_id  
    FROM cat_offc_grievances cog
    WHERE cog.status IN (5, 6, 13, 14, 15, 16, 17)
    and cog.office_id IN (7)    
    AND cog.grievance_source IN (5)  -- Apply grievance_source filter
    GROUP BY cog.grievance_cat_id

    
    
    
SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table0.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table1.grv_rcvd, 0) AS grievances_received_from_cmo,
    COALESCE(table2.grv_frwd_to_suboff, 0) AS grievances_forwarded_to_suboffice,
    COALESCE(table3.grv_frwd_to_othr_hod, 0) AS grievances_forwarded_to_other_hod,
    COALESCE(table2.grv_frwd_to_suboff, 0) + COALESCE(table3.grv_frwd_to_othr_hod, 0) AS total_grievance_forwarded,
    COALESCE(table4.atr_rcvd_from_suboff, 0) AS atr_received_from_sub_office,
    COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS atr_received_from_other_hods,
    COALESCE(table4.atr_rcvd_from_suboff, 0) + COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS total_atr_received,
    COALESCE(table6.atr_rcvd_from_cmo, 0) AS atr_received_from_cmo
FROM (
    SELECT 
        DISTINCT cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        com.office_id AS office_id,
        com.office_name
    FROM cmo_grievance_category_master cgcm
    LEFT JOIN cmo_office_master com ON cgcm.parent_office_id = com.office_id
    WHERE cgcm.status = 1
) table0
-- Grievances received from CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_rcvd
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status NOT IN (1, 2)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
-- Grievances forwarded to suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_frwd_to_suboff
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status NOT IN (1, 2, 3, 4)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
-- Grievances forwarded to other HOD
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_frwd_to_othr_hod
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status IN (5, 6, 13, 14, 15, 16, 17)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
-- ATR received from suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_suboff
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status IN (9, 10, 11, 12, 14, 15)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
-- ATR received from other HODs
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_othr_hods
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status IN (13, 14, 15, 16, 17)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
-- ATR sent to CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_cmo
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11' 
    and cog.status IN (14, 15)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id WHERE table0.office_id IN (9);


SELECT  
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.office_id,
                COALESCE(table0.office_name, 'N/A') AS office_name,
                COALESCE(table1.grv_rcvd, 0) AS grievances_received_from_cmo,
                COALESCE(table2.grv_frwd_to_suboff, 0) AS grievances_forwarded_to_suboffice,
                COALESCE(table3.grv_frwd_to_othr_hod, 0) AS grievances_forwarded_to_other_hod,
                COALESCE(table2.grv_frwd_to_suboff, 0) + COALESCE(table3.grv_frwd_to_othr_hod, 0) AS total_grievance_forwarded,
                COALESCE(table4.atr_rcvd_from_suboff, 0) AS atr_received_from_sub_office,
                COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS atr_received_from_other_hods,
                COALESCE(table4.atr_rcvd_from_suboff, 0) + COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS total_atr_received,
                COALESCE(table6.atr_rcvd_from_cmo, 0) AS atr_received_from_cmo
            FROM (
                SELECT 
                    DISTINCT cgcm.grievance_cat_id, 
                    cgcm.grievance_category_desc, 
                    com.office_id AS office_id,
                    com.office_name
                FROM cmo_grievance_category_master cgcm
                LEFT JOIN cmo_office_master com ON cgcm.parent_office_id = com.office_id
                WHERE cgcm.status = 1
            ) table0
            -- Grievances received from CMO
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS grv_rcvd
                FROM cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11'
                and cog.status NOT IN (1, 2)
                and cog.grievance_source in (5)
                GROUP BY cog.grievance_cat_id
            ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
            -- Grievances forwarded to suboffice
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS grv_frwd_to_suboff
                FROM cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11'  
                and cog.status NOT IN (1, 2, 3, 4)
                and cog.grievance_source in (5)
                GROUP BY cog.grievance_cat_id
            ) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
            -- Grievances forwarded to other HOD
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS grv_frwd_to_othr_hod
                FROM cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11'  
                and cog.status IN (5, 6, 13, 14, 15, 16, 17)
                and cog.grievance_source in (5)
                GROUP BY cog.grievance_cat_id
            ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
            -- ATR received from suboffice
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS atr_rcvd_from_suboff
                FROM cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11'  
                and cog.status IN (9, 10, 11, 12, 14, 15)
                and cog.grievance_source in (5)
                GROUP BY cog.grievance_cat_id
            ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
            -- ATR received from other HODs
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS atr_rcvd_from_othr_hods
                FROM cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11'  
                and cog.status IN (13, 14, 15, 16, 17)
                and cog.grievance_source in (5)
                GROUP BY cog.grievance_cat_id
            ) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
            -- ATR sent to CMO
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS atr_rcvd_from_cmo
                FROM cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status IN (14, 15)
                and cog.grievance_source in (5)
                GROUP BY cog.grievance_cat_id
            ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id in (7);
            
           
           
 SELECT gm.grievance_id,
--    cm.grievance_cat_id,
--    cm.grievance_category_desc,
    com.office_id,
    com.office_name,
    gm.closure_reason_id,
    gm.atr_recv_cmo_flag,
    gm.grievance_generate_date,
    gm.received_at,
    gm.grievance_source,
    cm.benefit_scheme_type,
    gm.status,
    cm.status AS grievance_category_status
   FROM cmo_grievance_category_master cm
     LEFT JOIN grievance_master gm ON cm.grievance_cat_id = gm.grievance_category
     LEFT JOIN cmo_office_master com ON com.office_id = cm.parent_office_id
  WHERE cm.status = 1 /*and com.office_id = 9*/;
  
 
 ------14.11.24-------
 
 
 select  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            coalesce(table0.office_name,'N/A') as office_name,
            table1.office_id,
            coalesce(table1.grv_uploaded,0) as griev_upload,
            coalesce(table2.grv_frwd_assigned,0) as grv_fwd,
            coalesce(table3.atr_recvd,0) as atr_rcvd,
            coalesce(table5.total_closed,0) as totl_dspsd,
            coalesce(table5.bnft_prvd,0) as srv_prvd,
            coalesce(table5.action_taken,0) as action_taken,
            coalesce(table5.not_elgbl,0) as not_elgbl,
            coalesce(table9.atr_pndg, 0) as atr_pndg,
         	COALESCE(ROUND(CASE 
	            WHEN (bnft_prvd + action_taken) = 0 THEN 0
	            ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
	            END,2),0) AS bnft_prcnt
            from
            (
             select distinct grievance_cat_id,grievance_category_desc, parent_office_id, com.office_name
            	from cmo_grievance_category_master cgcm
            	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
            	where cgcm.status = 1
            )table0
            
            left outer join
            (
            select  cog.grievance_category_desc ,cog.office_name,cog.office_id,
                cog.grievance_cat_id,count(1) as grv_uploaded
                from cat_offc_grievances cog 
                where 
                grievance_generate_date between {from_date} and {to_date}
                {data_source}
                {scm_cat_q}
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id
            )table1
			on table0.grievance_cat_id = table1.grievance_cat_id
			
            -- griev frwded
            left outer join (
            select count(1) as grv_frwd_assigned, cog.grievance_cat_id  from cat_offc_grievances cog 
            where 
        	grievance_generate_date between {from_date} and {to_date} and
            cog.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table2

            on table2.grievance_cat_id=table0.grievance_cat_id

            -- total atr recieved
            left outer join (
            select count(1) as atr_recvd, cog.grievance_cat_id  from cat_offc_grievances cog 
            where 
			grievance_generate_date between {from_date} and {to_date} and
            cog.status in (14,15)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table3

            on table3.grievance_cat_id=table0.grievance_cat_id

            -- total closed
            left outer join (
            select count(1) as total_closed, 
            sum(case when cog.status = 15 and cog.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when cog.status = 15 and cog.closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
	        sum(case when cog.status = 15 and cog.closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl,
            cog.grievance_cat_id  
            from cat_offc_grievances cog 
            where 
			grievance_generate_date between {from_date} and {to_date} and
            cog.status = 15
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table5

            on table5.grievance_cat_id=table0.grievance_cat_id

            -- atr pending
            left outer join (
            select count(1) as atr_pndg, cog.grievance_cat_id  from cat_offc_grievances cog 
            where 
			grievance_generate_date between {from_date} and {to_date} and
            cog.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table9

            on table9.grievance_cat_id=table0.grievance_cat_id;
           
           
         


----- new mis large report ----- 
           
            
 select  
    table0.office_id,
    coalesce(table0.office_name,'N/A') as office_name,
    coalesce(table1.grv_frwd_assigned,0) as grv_fwd,
    coalesce(table2.atr_rcvd,0) as atr_rcvd,
    coalesce(table3.total_closed,0) as total,
    coalesce(table3.bnft_prvd,0) as bnft_srv_prvd,
    coalesce(table3.action_taken,0) as action_taken,
    coalesce(table3.not_elgbl,0) as not_elgbl,
    coalesce(table4.atr_pndg, 0) as cumulative,
    coalesce(table4.beyond_svn_days, 0) as beyond_svn_days,
    coalesce(table5.atr_retrn_reviw_frm_cmo, 0) as atr_retrn_reviw_frm_cmo
    from
	    (SELECT 
    		DISTINCT com.office_id , com.office_name
	    from cmo_office_master com
	    left join admin_position_master apm on apm.office_id = com.office_id
	    where com.office_category = 2 and com.status = 1
	    group by com.office_id, com.office_name
	) AS table0
  	-- griev frwded
    left outer join (
        select 
            count(distinct grievance_id) as grv_frwd_assigned, 
            gm.assigned_to_office_id as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'  
        and gm.status NOT IN (1,2)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table1 on table1.office_id = table0.office_id
 -- total atr recieved
    left outer join (
        select 
            count(distinct grievance_id) as atr_rcvd,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status in (14,15,16,17)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table2 on table2.office_id = table0.office_id   
    -- atr closed
    left outer join (
         select 
         	count(1) as total_closed, 
            sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
	        sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl,
            gm.atr_submit_by_lastest_office_id  as office_id 
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 15
        AND gm.grievance_source IN (5)
        group by gm.atr_submit_by_lastest_office_id) table3 on table3.office_id = table0.office_id      
   -- atr pending
   left outer join (
        select 
            count(distinct grievance_id) as atr_pndg, 
            sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as beyond_svn_days,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status not in (1,2,14,15,16)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table4 on table4.office_id = table0.office_id      
   -- atr returned for review from CMO during the time
   left outer join (
   		SELECT 
    		count(grievance_id) AS atr_retrn_reviw_frm_cmo,
    		gm.assigned_to_office_id  as office_id
	    from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 6
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table5 on table5.office_id = table0.office_id;

       
       
       
select  
    table0.office_id,
    coalesce(table0.office_name,'N/A') as office_name,
    coalesce(table1.grv_frwd_assigned,0) as grievances_forwarded_assigned,
    coalesce(table2.atr_rcvd,0) as atr_received,
    coalesce(table3.total_closed,0) as total_disposed,
    coalesce(table3.bnft_prvd,0) as benefit_service_provided,
    coalesce(table3.action_taken,0) as action_taken,
    coalesce(table3.not_elgbl,0) as not_elgbl,
    coalesce(table4.atr_pndg, 0) as cumulative,
    coalesce(table4.beyond_svn_days, 0) as beyond_svn_days,
    coalesce(table5.atr_retrn_reviw_frm_cmo, 0) as atr_return_for_review_from_cmo
    from
	    (SELECT 
    		DISTINCT com.office_id , com.office_name
	    from cmo_office_master com
	    left join admin_position_master apm on apm.office_id = com.office_id
	    where com.office_category = 2 and com.status = 1
	    group by com.office_id, com.office_name
	) AS table0
  	-- griev frwded
    left outer join (
        select 
            count(distinct grievance_id) as grv_frwd_assigned, 
            gm.assigned_to_office_id as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'  
        and gm.status NOT IN (1,2)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table1 on table1.office_id = table0.office_id
 -- total atr recieved
    left outer join (
        select 
            count(distinct grievance_id) as atr_rcvd,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status in (14,15,16,17)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table2 on table2.office_id = table0.office_id   
    -- atr closed
    left outer join (
         select 
         	count(1) as total_closed, 
            sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
	        sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl,
            gm.atr_submit_by_lastest_office_id  as office_id 
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 15
        AND gm.grievance_source IN (5)
        group by gm.atr_submit_by_lastest_office_id) table3 on table3.office_id = table0.office_id      
   -- atr pending
   left outer join (
        select 
            count(distinct grievance_id) as atr_pndg, 
            sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as beyond_svn_days,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status not in (1,2,14,15,16)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table4 on table4.office_id = table0.office_id      
   -- atr returned for review from CMO during the time
   left outer join (
   		SELECT 
    		count(grievance_id) AS atr_retrn_reviw_frm_cmo,
    		gm.assigned_to_office_id  as office_id
	    from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 6
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table5 on table5.office_id = table0.office_id;
      


-- DROP VIEW IF EXISTS public.offc_wise_grievance;
CREATE OR REPLACE VIEW public.offc_wise_grievance
AS SELECT gm.grievance_id,
    gm.status,
    gm.grievance_category,
    com.office_name,
    com.office_id,
    gm.assigned_to_position,
    gm.grievance_generate_date,
    gm.updated_on,
    gm.received_at,
    gm.atr_recv_cmo_flag,
    gm.closure_reason_id,
    gm.grievance_source
   FROM cmo_office_master com
   left join grievance_master gm on gm.assigned_to_position = com.office_id;
  
--   DROP VIEW IF EXISTS public.offc_wise_grievance;
--   DROP VIEW IF EXISTS public.off_wise_hod_user_view;
--   DROP VIEW IF EXISTS public.cat_sub_offc_griv; 
  
  CREATE OR REPLACE VIEW public.cat_sub_offc_griv
	AS SELECT gm.grievance_id,
    gm.grievance_category,
    cgcm.grievance_cat_id,
    cgcm.grievance_category_desc,
    cgcm.parent_office_id AS office_id,
    com.office_name,
    gm.assigned_to_position,
    gm.atr_recv_cmo_flag,
    gm.grievance_generate_date,
    gm.received_at,
    gm.status,
    gm.closure_reason_id,
    gm.grievance_source,
    csom.suboffice_name,
    csom.suboffice_id,
    cgcm.benefit_scheme_type
   FROM grievance_master gm,
    cmo_grievance_category_master cgcm,
    cmo_office_master com,
    cmo_sub_office_master csom
  WHERE gm.grievance_category = cgcm.grievance_cat_id AND com.office_id = cgcm.parent_office_id AND csom.office_id = com.office_id AND csom.office_id = cgcm.parent_office_id;
 
  CREATE OR REPLACE VIEW public.offc_wise_grievance AS 
SELECT 
    com.office_id,
    com.office_name,
    gm.grievance_id,
    gm.status,
    gm.grievance_category,
    gm.assigned_to_position,
    gm.grievance_generate_date,
    gm.updated_on,
    gm.received_at,
    gm.atr_recv_cmo_flag,
    gm.closure_reason_id,
    gm.grievance_source
FROM cmo_office_master com
LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id;
        
       
       
 ---- new mis query report making for hods user -----     
WITH forwarded_and_assigned_grievances AS (
      select 
      	a.assigned_to_position, 
      	count(a.grievance_id) as grv_frwd_assigned  
      from 
      	(SELECT 
      		grievance_lifecycle.grievance_id, 
      		grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            row_number() OVER 
            	(PARTITION BY grievance_lifecycle.grievance_id 
            		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status not in (1,2,3,13)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3   
            group by a.assigned_to_position
        ), 
        latest_atr_received AS (
            select 
            	a.assigned_to_position, 
            	count(a.grievance_id) as atr_rcvd 
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
            		grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (11,14,15,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3   
            group by a.assigned_to_position
        ),
        disposal AS (
            select 
            	a.assigned_to_position, 
            	count(a.grievance_id) as total_closed,
            	sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            	sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
	        	sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
            		grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status = 15
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
        ),
        pending AS (
            select 
            	a.assigned_to_position, 
            	count(distinct a.grievance_id) as atr_pndg,
            sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as beyond_svn_days
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
            		grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status not in (1,2,14,15,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
        )
        select  
        	aud.official_name, 
        	coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
        	coalesce(ltr.atr_rcvd, 0) as atr_received,
        	coalesce(d.bnft_prvd, 0) as benefit_service_provided,
        	coalesce(d.action_taken, 0) as action_taken,
        	coalesce(d.not_elgbl, 0) as not_elgbl,
            coalesce(d.total_closed, 0) as total_disposed,
            coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
            coalesce(p.atr_pndg, 0) as cumulative
        from forwarded_and_assigned_grievances fag
        left join latest_atr_received ltr on ltr.assigned_to_position = fag.assigned_to_position
        left join disposal d on d.assigned_to_position = fag.assigned_to_position
        left join pending p on p.assigned_to_position = fag.assigned_to_position
        left join admin_position_master apm on apm.position_id = fag.assigned_to_position
        left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
        left join admin_user_details aud on aupm.admin_user_id = aud.admin_user_id
        left join admin_user au on au.admin_user_id = aud.admin_user_id
        where au.status != 3
        group by aud.official_name, fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg; 
        
       
-------- new mis report for sub_offices reference ------------
WITH 
	no_grievaces_fwd AS (       
		 select 
		 	a.assigned_to_position, 
		 	count(a.grievance_id) as giev_fwd  
		 from 
		 	(SELECT 
		 		grievance_lifecycle.grievance_id, 
		 		grievance_lifecycle.assigned_by_office_id,
		        grievance_lifecycle.assigned_to_position,
		        	row_number() OVER 
		        		(PARTITION BY grievance_lifecycle.grievance_id 
		        			ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
		    FROM grievance_lifecycle
		    where grievance_lifecycle.grievance_status in (7,12)) a 
		    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
		    where rn = 1 and a.assigned_by_office_id = 3 group by a.assigned_to_position
		),       
	no_grievaces_atr_rec AS (
         select 
         	a.assigned_by_position, 
         	count(a.grievance_id) as giev_atr_rec  
         from 
         	(SELECT 
         		grievance_lifecycle.grievance_id, 
         		grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            FROM grievance_lifecycle
            where grievance_lifecycle.grievance_status in (11)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3 group by a.assigned_by_position
   		), 
   no_grievaces_atr_pending AS (
        select 
        	assigned_to_position,
        	count(1) as atr_pending 
       	from grievance_master gm 
        where gm.status in (7,8,9,10,12) 
        and gm.assigned_by_office_id = 3  
        group by assigned_to_position), 
  pending_for as (
     select 
       	atr_assigned_to_position, 
       	avg(days_diff)::int as days_diff 
     from pending_for_sub_office_wise pfhw 
     inner join grievance_master gm  on gm.grievance_id = pfhw.grievance_id 
     where rcv_assigned_by_office_id = 3 and atr_assigned_to_office_id = 3
     group by atr_assigned_to_position
   )
  select 
  	csom.suboffice_name, 
  	coalesce(giev_fwd, 0) as grievance_forwarded, 
  	coalesce(giev_atr_rec, 0) as atr_received_count, 
  	coalesce(atr_pending,0) as atr_pending,
    coalesce(days_diff, 0) as average_resolution_days,
        CASE
            WHEN COALESCE(days_diff, 0) <= 7 THEN 'Good'
            WHEN COALESCE(days_diff, 0) > 7 AND COALESCE(days_diff, 0) <= 30 THEN 'Average'
            ELSE 'Poor'
        END AS performance
 	from no_grievaces_atr_rec ngarec
    left join no_grievaces_fwd ngfwd  on ngarec.assigned_by_position = ngfwd.assigned_to_position
    left join no_grievaces_atr_pending atrpnd on atrpnd.assigned_to_position = ngarec.assigned_by_position
    left join pending_for pndfor on pndfor.atr_assigned_to_position = ngarec.assigned_by_position
    left join admin_position_master apm on apm.position_id = ngarec.assigned_by_position
    left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and  csom.office_id = apm.office_id
    group by csom.suboffice_name, giev_fwd, giev_atr_rec,atr_pending, days_diff; 
    
   
-------- new mis report for sub_offices ------------
WITH 
	forwarded_and_assigned_grievances AS (       
		 select 
		 	a.assigned_to_position, 
      		count(a.grievance_id) as grv_frwd_assigned 
		 from 
		 	(SELECT 
		 		grievance_lifecycle.grievance_id, 
		 		grievance_lifecycle.assigned_to_office_id,
		        grievance_lifecycle.assigned_to_position,
		        	row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on desc) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3
            group by a.assigned_to_position
		),       
	latest_atr_received AS (
         select 
         	a.assigned_by_position, 
            count(a.grievance_id) as atr_rcvd  
         from 
         	(SELECT 
         		grievance_lifecycle.grievance_id, 
         		grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (1,4,5,11,14,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3 
            group by a.assigned_by_position
   		), 
  	disposal AS (
        select 
        	a.assigned_to_position, 
        	count(a.grievance_id) as total_closed,
        	sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        	sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
        	sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
       	from 
            (SELECT 
        		grievance_lifecycle.grievance_id, 
        		grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_to_office_id,
                row_number() OVER 
                    (PARTITION BY grievance_lifecycle.grievance_id 
                    	ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status = 15
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
         ),
  pending AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (
        SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER 
            (PARTITION BY glc.grievance_id 
                ORDER BY glc.assigned_on DESC) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE 
            glc.grievance_status = 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            and gm.status = 15
            AND gm.grievance_source IN (5)) a
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
    WHERE rn = 1 and a.assigned_to_office_id = 3    
    GROUP BY a.assigned_to_position
  )
  	select  
		csom.suboffice_name, 
		coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
		coalesce(ltr.atr_rcvd, 0) as atr_received,
		coalesce(d.bnft_prvd, 0) as benefit_service_provided,
		coalesce(d.action_taken, 0) as action_taken,
		coalesce(d.not_elgbl, 0) as not_elgbl,
	    coalesce(d.total_closed, 0) as total_disposed,
	    coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
	    coalesce(p.atr_pndg, 0) as cumulative   
 	from forwarded_and_assigned_grievances fag
    left join latest_atr_received ltr on ltr.assigned_by_position = fag.assigned_to_position
    left join disposal d on d.assigned_to_position = fag.assigned_to_position
    left join pending p on p.assigned_to_position = fag.assigned_to_position
    left join admin_position_master apm on apm.position_id = fag.assigned_to_position
    left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id
    group by csom.suboffice_name, fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg;
    
   
        
------ mis new report other hods report reference -----
with total_forwarded AS (
      select 
       	a.assigned_to_office_id, 
       	count(a.grievance_id) as fwd 
      from 
      	(
      	SELECT 
      		grievance_lifecycle.grievance_id, 
      		grievance_lifecycle.grievance_status, 
            grievance_lifecycle.assigned_to_office_id, 
            grievance_lifecycle.assigned_by_office_id,                                         
                 row_number() OVER 
                 	(PARTITION BY grievance_lifecycle.grievance_id 
                 		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM grievance_lifecycle
        where grievance_lifecycle.grievance_status in (5)) a 
        inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
        where rn = 1 and a.assigned_by_office_id = 3   
        group by a.assigned_to_office_id
      ), 
      max_assign_on as (
          select a.* 
          from 
          	(
          	SELECT 
          		grievance_lifecycle.grievance_id, 
          		grievance_lifecycle.assigned_on, 
          		grievance_lifecycle.assigned_by_office_id,                                         
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    	ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
           	FROM grievance_lifecycle
            where grievance_lifecycle.grievance_status in (5)) a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_by_office_id = 3    
     ), 
     atr_receive as (
         select 
         	a.assigned_by_office_id, 
         	count(a.grievance_id) as atr 
         from 
         	(
         	SELECT 
         		grievance_lifecycle.grievance_id, 
         		grievance_lifecycle.assigned_on , 
                grievance_lifecycle.assigned_to_office_id, 
                grievance_lifecycle.assigned_by_office_id,                                         
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    	ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            FROM grievance_lifecycle
            where grievance_lifecycle.grievance_status in (13)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3 
            and exists 
            	(select 1 
            		from max_assign_on mxon 
            		where mxon.grievance_id = a.grievance_id 
            		and a.assigned_on > mxon.assigned_on)   
           	group by a.assigned_by_office_id
         )
           select 
           	com.office_name as to_office , 
           	coalesce(fwd,0) as forwarded_grievances, 
           	coalesce(atr,0) as atr_recieved, 
           	case when (coalesce(fwd,0) - coalesce(atr,0)) < 0 then 0 
                else (coalesce(fwd,0) - coalesce(atr,0))
            end as atr_pending
          from total_forwarded tlfwd
		  left join atr_receive atrc on tlfwd.assigned_to_office_id = atrc.assigned_by_office_id
          left join cmo_office_master com on com.office_id = tlfwd.assigned_to_office_id
           group by com.office_name ,assigned_to_office_id,fwd, atr;
         
          
          
----- mis new report for other hods report ----------      
 WITH forwarded_and_assigned_grievances AS (
      select 
      	a.assigned_to_office_id, 
      	count(a.grievance_id) as grv_frwd_assigned  
      from 
      	(SELECT 
      		grievance_lifecycle.grievance_id, 
      		grievance_lifecycle.grievance_status, 
      		grievance_lifecycle.assigned_to_office_id, 
            grievance_lifecycle.assigned_by_office_id, 
            row_number() OVER 
            	(PARTITION BY grievance_lifecycle.grievance_id 
            		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,5,6,13,14,15)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_by_office_id = 3   
            group by a.assigned_to_office_id
        ), 
 	latest_atr_received AS (
            select 
            	a.assigned_to_office_id, 
            	count(a.grievance_id) as atr_rcvd 
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
		      		grievance_lifecycle.grievance_status, 
		      		grievance_lifecycle.assigned_to_office_id, 
		            grievance_lifecycle.assigned_by_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (1,4,5,13,14,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_by_office_id = 3   
            group by a.assigned_to_office_id
        ),
	disposal AS (
            select 
            	a.assigned_to_office_id, 
            	count(a.grievance_id) as total_closed,
            	sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            	sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
	        	sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
		      		grievance_lifecycle.grievance_status, 
		      		grievance_lifecycle.assigned_to_office_id, 
		            grievance_lifecycle.assigned_by_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status = 15
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_by_office_id = 3    
            group by a.assigned_to_office_id
        ),
     pending AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
	        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
	    FROM 
	        (
	        SELECT 
	            glc.grievance_id, 
	            glc.grievance_status,
	            glc.assigned_to_office_id,
	            glc.assigned_by_office_id,
	            ROW_NUMBER() OVER 
	            (PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC) AS rn
	        FROM grievance_lifecycle glc
	        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
	        WHERE 
	            glc.grievance_status = 6
	            AND NOT EXISTS (
	                SELECT 1
	                FROM grievance_lifecycle glc2
	                WHERE 
	                    glc2.grievance_id = glc.grievance_id
	                    AND glc2.grievance_status = 13
	            )
	            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
	            and gm.status = 15
	            AND gm.grievance_source IN (5)) a
	    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    inner join grievance_lifecycle glc on glc.assigned_to_office_id = a.assigned_to_office_id
	    WHERE rn = 1 and a.assigned_by_office_id = 3    
	    GROUP BY a.assigned_to_office_id
       )
		 select  
        	com.office_name as to_other_hods,
        	coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
        	coalesce(ltr.atr_rcvd, 0) as atr_received,
        	coalesce(d.bnft_prvd, 0) as benefit_service_provided,
        	coalesce(d.action_taken, 0) as action_taken,
        	coalesce(d.not_elgbl, 0) as not_elgbl,
            coalesce(d.total_closed, 0) as total_disposed,
            coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
            coalesce(p.atr_pndg, 0) as cumulative
        from forwarded_and_assigned_grievances fag
        left join latest_atr_received ltr on ltr.assigned_to_office_id = fag.assigned_to_office_id
        left join disposal d on d.assigned_to_office_id = fag.assigned_to_office_id
        left join pending p on p.assigned_to_office_id = fag.assigned_to_office_id
        left join cmo_office_master com on com.office_id = fag.assigned_to_office_id
        group by com.office_name, fag.assigned_to_office_id,  fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg;
        
      










----->>> 20.11.24 
       
----------- mis 7 process onward -------------
WITH 
	forwarded_grievances AS (       
		 select 
		 	a.assigned_to_position, 
      		count(a.grievance_id) as grv_frwd
		 from 
		 	(SELECT 
		 		grievance_lifecycle.grievance_id, 
		 		grievance_lifecycle.assigned_to_office_id,
		        grievance_lifecycle.assigned_to_position,
		        	row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on desc) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3
            group by a.assigned_to_position
		),
  	atr_submitted AS (
        select 
        	a.assigned_to_position, 
        	count(a.grievance_id) as total_submitted,
        	sum(case when gm.status in (4,11,14,15,16) and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        	sum(case when gm.status in (4,11,14,15,16) and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
        	sum(case when gm.status in (4,11,14,15,16) and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
       	from 
            (SELECT 
        		grievance_lifecycle.grievance_id, 
        		grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_to_office_id,
                row_number() OVER 
                    (PARTITION BY grievance_lifecycle.grievance_id 
                    	ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,11,14,15,16)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
         ),
  atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (
        SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER 
            (PARTITION BY glc.grievance_id 
                ORDER BY glc.assigned_on DESC) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE 
            glc.grievance_status = 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a
	    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
	    WHERE rn = 1 and a.assigned_to_office_id = 3    
	    GROUP BY a.assigned_to_position
  	),
 atr_returned_for_review AS (
                SELECT 
                    a.assigned_to_position, 
                    COUNT(a.grievance_id) AS atr_retrn_reviw
                FROM 
                    (
                    SELECT 
                        grievance_lifecycle.grievance_id,  
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm, grievance_lifecycle
                    where grievance_lifecycle.grievance_status = 12
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                        AND gm.grievance_source IN (5)) a
                INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
                WHERE rn = 1 and a.assigned_to_office_id = 3   
                GROUP BY a.assigned_to_position
              )
	  	select  
			csom.suboffice_name, 
			coalesce(fag.grv_frwd,0) as grievances_forwarded_assigned, 
			coalesce(ats.bnft_prvd, 0) as benefit_service_provided,
			coalesce(ats.action_taken, 0) as action_taken,
			coalesce(ats.not_elgbl, 0) as not_elgbl,
		    coalesce(ats.total_submitted, 0) as total,
		    coalesce(atp.beyond_svn_days, 0) as beyond_svn_days,
		    coalesce(atp.atr_pndg, 0) as cumulative,
		    coalesce(ar.atr_retrn_reviw, 0) as atr_returned_for_review_to_hod
	   from forwarded_grievances fag
	    left join atr_submitted ats on ats.assigned_to_position = fag.assigned_to_position
	    left join atr_pending atp on atp.assigned_to_position = fag.assigned_to_position
	    left join atr_returned_for_review ar on ar.assigned_to_position = fag.assigned_to_position
	    left join admin_position_master apm on apm.position_id = fag.assigned_to_position
	    left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id 
	    left join cmo_office_master com on com.office_id = csom.office_id
	    group by csom.suboffice_name, fag.grv_frwd, ats.bnft_prvd, ats.action_taken, ats.not_elgbl, ats.total_submitted, atp.beyond_svn_days, atp.atr_pndg, ar.atr_retrn_reviw;
	  
	   ---------------- chart 16 query referance -----------------------
	   
   select csom.suboffice_name as office_name, count(gm.grievance_id) as per_hod_count 
                    from cmo_sub_office_master csom 
                    left join admin_position_master apm on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id 
                    left join grievance_master gm on apm.position_id = gm.assigned_to_position and  gm.assigned_by_office_id = 3 and gm.status in (7,8,9,10,12) 
                    where apm.office_id = 3
                    group by 1
                    order by 2 desc;
                    
select * from cmo_sub_office_master csom limit 1; 
select * from grievance_lifecycle gl limit 1;
                   
                   
WITH 
forwarded_grievances AS (       
    SELECT 
        a.assigned_to_position, 
        COUNT(distinct a.grievance_id) AS grv_frwd
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_office_id,
            grievance_lifecycle.assigned_to_position,
            ROW_NUMBER() OVER 
                (PARTITION BY grievance_lifecycle.grievance_id 
                 ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM grievance_master gm
        JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE grievance_lifecycle.grievance_status IN (4,7,8,9,10,11,12,14,15)
          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
          AND gm.grievance_source IN (5)) a 
    WHERE rn = 1 AND a.assigned_to_office_id = 3
    GROUP BY a.assigned_to_position
),
atr_submitted AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(distinct a.grievance_id) AS total_submitted,
        SUM(CASE WHEN gm.status IN (4,11,14,15,16) AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN gm.status IN (4,11,14,15,16) AND gm.closure_reason_id IN (5,9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN gm.status IN (4,11,14,15,16) AND gm.closure_reason_id NOT IN (1,5,9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER 
                (PARTITION BY grievance_lifecycle.grievance_id 
                 ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM grievance_master gm
        JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE grievance_lifecycle.grievance_status IN (4,11,14,15,16)
          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
          AND gm.grievance_source IN (5)) a 
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    WHERE rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY a.assigned_to_position
),
atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER 
            (PARTITION BY glc.grievance_id 
                ORDER BY glc.assigned_on DESC) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE 
            glc.grievance_status = 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    WHERE rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY a.assigned_to_position
),
atr_returned_for_review AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(a.grievance_id) AS atr_retrn_reviw
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id,  
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER 
                (PARTITION BY grievance_lifecycle.grievance_id 
                    ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM grievance_master gm
        JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE grievance_lifecycle.grievance_status = 12
          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
          AND gm.grievance_source IN (5)) a
    WHERE rn = 1 AND a.assigned_to_office_id = 3   
    GROUP BY a.assigned_to_position
)
SELECT  
    distinct csom.suboffice_name, 
    COALESCE(fag.grv_frwd, 0) AS grievances_forwarded_assigned, 
    COALESCE(ats.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(ats.action_taken, 0) AS action_taken,
    COALESCE(ats.not_elgbl, 0) AS not_elgbl,
    COALESCE(ats.total_submitted, 0) AS total,
    COALESCE(atp.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(atp.atr_pndg, 0) AS cumulative,
    COALESCE(ar.atr_retrn_reviw, 0) AS atr_returned_for_review_to_hod
FROM cmo_sub_office_master csom
LEFT JOIN admin_position_master apm 
    ON apm.sub_office_id = csom.suboffice_id AND apm.office_id = csom.office_id
LEFT JOIN forwarded_grievances fag 
    ON apm.position_id = fag.assigned_to_position
LEFT JOIN atr_submitted ats 
    ON ats.assigned_to_position = fag.assigned_to_position
LEFT JOIN atr_pending atp 
    ON atp.assigned_to_position = fag.assigned_to_position
LEFT JOIN atr_returned_for_review ar 
    ON ar.assigned_to_position = fag.assigned_to_position
WHERE csom.office_id = 3
GROUP BY csom.suboffice_name, fag.grv_frwd, ats.bnft_prvd, ats.action_taken, ats.not_elgbl, 
         ats.total_submitted, atp.beyond_svn_days, atp.atr_pndg, ar.atr_retrn_reviw;


        
        SELECT suboffice_name, office_id, suboffice_id 
FROM cmo_sub_office_master 
WHERE office_id = 3;

SELECT COUNT(*) AS total_suboffices
FROM cmo_sub_office_master
WHERE office_id = 3;

SELECT COUNT(*) AS total_positions
FROM admin_position_master
WHERE office_id = 3;

SELECT DISTINCT apm.position_id
FROM admin_position_master apm
LEFT JOIN cmo_sub_office_master csom ON csom.suboffice_id = apm.sub_office_id
WHERE csom.office_id = 3;

SELECT csom.suboffice_name
FROM cmo_sub_office_master csom
LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
WHERE csom.office_id = 3 AND apm.position_id IS NULL;













----- all sub_offices prints ------
WITH 
forwarded_grievances AS (       
    SELECT 
        a.assigned_to_position, 
        COUNT(distinct a.grievance_id) AS grv_frwd
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_office_id,
            grievance_lifecycle.assigned_to_position,
            ROW_NUMBER() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM 
            grievance_master gm /*,grievance_lifecycle*/
        JOIN 
            grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE 
            grievance_lifecycle.grievance_status IN (4,7,8,9,10,11,12,14,15)
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a 
    WHERE 
        rn = 1 AND a.assigned_to_office_id = 3
    GROUP BY 
        a.assigned_to_position
),
atr_submitted AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(distinct a.grievance_id) AS total_submitted,
        SUM(CASE WHEN gm.status IN (4,11,14,15,16) AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN gm.status IN (4,11,14,15,16) AND gm.closure_reason_id IN (5,9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN gm.status IN (4,11,14,15,16) AND gm.closure_reason_id NOT IN (1,5,9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM 
            grievance_master gm /*,grievance_lifecycle*/
        JOIN 
            grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE 
            grievance_lifecycle.grievance_status IN (4,11,14,15,16)
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a 
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = a.grievance_id
    WHERE 
        rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY 
        a.assigned_to_position
),
atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER (PARTITION BY glc.grievance_id ORDER BY glc.assigned_on DESC) AS rn
        FROM 
            grievance_lifecycle glc
        JOIN 
            grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE 
            glc.grievance_status = 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = a.grievance_id
--    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
    WHERE 
        rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY 
        a.assigned_to_position
),
atr_returned_for_review AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(a.grievance_id) AS atr_retrn_reviw
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id ,  
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM 
            grievance_master gm /*,grievance_lifecycle*/
        JOIN 
            grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE 
            grievance_lifecycle.grievance_status = 12
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = a.grievance_id
    WHERE 
        rn = 1 AND a.assigned_to_office_id = 3   
    GROUP BY 
        a.assigned_to_position
)
SELECT  
    csom.suboffice_name, csom.suboffice_code,
    COALESCE(fag.grv_frwd, 0) AS grievances_forwarded_assigned 
    ,COALESCE(ats.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(ats.action_taken, 0) AS action_taken,
    COALESCE(ats.not_elgbl, 0) AS not_elgbl,
    COALESCE(ats.total_submitted, 0) AS total,
    COALESCE(atp.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(atp.atr_pndg, 0) AS cumulative_pendency,
    COALESCE(ar.atr_retrn_reviw, 0) AS atr_returned_for_review_to_hod
FROM 
    cmo_sub_office_master csom
LEFT JOIN 
    admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
LEFT JOIN 
    forwarded_grievances fag ON fag.assigned_to_position = apm.position_id
LEFT JOIN 
    atr_submitted ats ON ats.assigned_to_position = apm.position_id
LEFT JOIN 
    atr_pending atp ON atp.assigned_to_position = apm.position_id
LEFT JOIN 
    atr_returned_for_review ar ON ar.assigned_to_position = apm.position_id
WHERE 
    csom.office_id = 3
GROUP BY 
    csom.suboffice_name , csom.suboffice_code,
    fag.grv_frwd ,
    ats.bnft_prvd, 
    ats.action_taken, 
    ats.not_elgbl, 
    ats.total_submitted, 
    atp.beyond_svn_days, 
    atp.atr_pndg, 
    ar.atr_retrn_reviw;


   
   
----- report 6 update  -----
WITH forwarded_grievances AS (       
                select 
                    a.assigned_to_position, 
                    count(distinct a.grievance_id) as grv_frwd_assigned 
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_to_position,
                            row_number() OVER 
                                (PARTITION BY grievance_lifecycle.grievance_id 
                                    ORDER BY grievance_lifecycle.assigned_on desc) AS rn
                    from grievance_master gm
                    JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
                    and gm.grievance_generate_date between {from_date} and {to_date}
                    {griv_stat}
                    {data_source}
                    ) a 
                    -- inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3
                    group by a.assigned_to_position
               ),
	 atr_received AS (
                select 
                    a.assigned_to_position, 
                    count(distinct a.grievance_id) as total_closed,
                    sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                    sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                    sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status = 15
                    and gm.grievance_generate_date between {from_date} and {to_date}
                    {griv_stat}
                    {data_source}
                    ) a 
                    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3    
                    group by a.assigned_to_position
                ),
		pending AS (
                SELECT 
                    a.assigned_to_position, 
                    COUNT(DISTINCT a.grievance_id) AS atr_pndg
                FROM 
                    (SELECT 
                        grievance_lifecycle.grievance_id,  
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status not in (1,2,14,15,16,17)
                    and gm.grievance_generate_date between {from_date} and {to_date}
                     {griv_stat}
                     {data_source}
                       ) a
                    inner join grievance_master gm ON gm.grievance_id = a.grievance_id
                    WHERE rn = 1 and a.assigned_to_office_id = 3    
                    GROUP BY a.assigned_to_position
                ),
	atr_returned_for_review AS (
                SELECT 
                    a.assigned_to_position, 
                    COUNT(a.grievance_id) AS atr_retrn_reviw
                FROM 
                    (
                    SELECT 
                        grievance_lifecycle.grievance_id,  
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status = 6
                    and gm.grievance_generate_date between {from_date} and {to_date}
                    {griv_stat}
                    {data_source}
                        ) a
                inner join grievance_master gm ON gm.grievance_id = a.grievance_id
                WHERE rn = 1 and a.assigned_to_office_id = 3    
                GROUP BY a.assigned_to_position
            )
            select  
                csom.suboffice_name as office_name, csom.suboffice_code,
                coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded, 
                coalesce(ar.bnft_prvd, 0) as benefit_service_provided,
                coalesce(ar.action_taken, 0) as action_taken,
                coalesce(ar.not_elgbl, 0) as not_elgbl,
                coalesce(ar.total_closed, 0) as total_disposed,
                coalesce(p.atr_pndg, 0) as pending,
                coalesce(atr.atr_retrn_reviw, 0) as atr_returned_for_review
            from cmo_sub_office_master csom
            left join admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
            left join forwarded_grievances fag ON fag.assigned_to_position = apm.position_id
            LEFT JOIN atr_received ar ON ar.assigned_to_position = apm.position_id
            LEFT JOIN pending p on p.assigned_to_position = apm.position_id
            LEFT JOIN atr_returned_for_review atr on atr.assigned_to_position = apm.position_id
			WHERE 
    			csom.office_id = 3
            group by 
            	csom.suboffice_name, 
            	csom.suboffice_code,
            	fag.grv_frwd_assigned, 
            	ar.bnft_prvd, 
            	ar.action_taken, 
            	ar.not_elgbl, 
            	ar.total_closed, 
            	p.atr_pndg, 
            	atr.atr_retrn_reviw;
            	
--- report 7 categoey wise suboffice ----
SELECT  
        table0.grievance_cat_id,
        table0.grievance_category_desc,
        table0.office_id,
        table0.suboffice_id,
        COALESCE(table0.suboffice_name) AS office_name,
        COALESCE(table1.grv_frwd, 0) AS grievances_forwarded,
        COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
        COALESCE(table3.action_taken, 0) AS action_taken,
        COALESCE(table4.not_elgbl, 0) AS not_elgbl,
        COALESCE(table5.total_submitted, 0) AS total,
        COALESCE(table6.atr_pndg, 0) AS atr_pending
    FROM (
        SELECT 
            DISTINCT cgcm.grievance_cat_id, 
            cgcm.grievance_category_desc, 
            com.office_id AS office_id,
            csom.suboffice_name,
            csom.suboffice_id
        FROM cmo_grievance_category_master cgcm
        left join cmo_office_master com ON cgcm.parent_office_id = com.office_id
        left join cmo_sub_office_master csom ON csom.office_id = com.office_id
        WHERE cgcm.status = 1
    ) table0
    -- No. of Grievances Forwarded
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS grv_frwd
        FROM cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and csog.status in (4,8,9,10,11,12,14,15,16)
        and csog.grievance_source = 5
        GROUP BY csog.grievance_cat_id
    ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
    -- Benefit/ Service Provided
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS bnft_prvd
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and csog.status in (9,10,11,12,14,15) 
        and csog.closure_reason_id = 1
        and csog.grievance_source = 5
        GROUP BY csog.grievance_cat_id
    ) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
    -- Action Initiated
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS action_taken
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-11-11'  
        and csog.status in (9,10,11,12,14,15)  
        and csog.closure_reason_id IN (5,9)
        and csog.grievance_source = 5
        GROUP BY csog.grievance_cat_id
    ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
    -- Not eligible to get benefit
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS not_elgbl
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-11-11'  
        and csog.status in (9,10,11,12,14,15)
        and csog.closure_reason_id NOT IN (1,5,9)
        and csog.grievance_source = 5
        GROUP BY csog.grievance_cat_id
    ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
    -- Total submitted
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS total_submitted
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-11-11'  
        and csog.status in (9,10,11,12,14,15)
        and csog.grievance_source = 5
        GROUP BY csog.grievance_cat_id
    ) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
    -- ATR Pending
	LEFT JOIN (
	    SELECT 
	        csog.grievance_cat_id,
	        COUNT(1) AS atr_pndg,
	        glc.grievance_status
	    FROM 
	        cat_sub_offc_griv csog, grievance_lifecycle glc
	    WHERE 
	    	glc.grievance_id = csog.grievance_id
	        AND glc.grievance_status = 8  -- Grievances currently at status 8
	        AND NOT EXISTS (
	            SELECT 1
	            FROM grievance_lifecycle glc2
	            WHERE 
	            	glc2.grievance_id = glc.grievance_id
	                AND glc2.grievance_status = 9  -- Grievances that have received status 9
	        )
	        and csog.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'  
	        and csog.grievance_source = 5
	    GROUP BY 
	        csog.grievance_cat_id, glc.grievance_status
	) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id = 3 and table0.suboffice_id = 15;


   


----- mis report 7 part 2 -----
 SELECT  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            table0.office_id,
            table0.suboffice_id,
            COALESCE(table0.suboffice_name) AS office_name,
            COALESCE(table1.grv_frwd, 0) AS grievances_forwarded,
            COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
            COALESCE(table3.action_taken, 0) AS action_taken,
            COALESCE(table4.not_elgbl, 0) AS not_elgbl,
            COALESCE(table5.total_submitted, 0) AS total,
            COALESCE(table6.atr_pndg, 0) AS atr_pending
        FROM (
            SELECT 
                DISTINCT cgcm.grievance_cat_id, 
                cgcm.grievance_category_desc, 
                com.office_id AS office_id,
                csom.suboffice_name,
                csom.suboffice_id
            FROM cmo_grievance_category_master cgcm
            left join cmo_office_master com ON cgcm.parent_office_id = com.office_id
            left join cmo_sub_office_master csom ON csom.office_id = com.office_id
            WHERE cgcm.status = 1
        ) table0
        -- No. of Grievances Forwarded
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS grv_frwd
            FROM cat_sub_offc_griv csog
            where grievance_generate_date between '2019-01-01' and '2024-11-11'
            and csog.status in (4,8,9,10,11,12,14,15,16)
            GROUP BY csog.grievance_cat_id
        ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
        -- Benefit/ Service Provided
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS bnft_prvd
            from cat_sub_offc_griv csog
            where grievance_generate_date between '2019-01-01' and '2024-11-11'
            and csog.status in (9,10,11,12,14,15) 
            and csog.closure_reason_id = 1
            GROUP BY csog.grievance_cat_id
        ) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
        -- Action Initiated
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS action_taken
            from cat_sub_offc_griv csog
            where grievance_generate_date between '2019-01-01' and '2024-11-11'  
            and csog.status in (9,10,11,12,14,15)  
            and csog.closure_reason_id IN (5,9) 
            GROUP BY csog.grievance_cat_id
        ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
        -- Not eligible to get benefit
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS not_elgbl
            from cat_sub_offc_griv csog
            where grievance_generate_date between '2019-01-01' and '2024-11-11'  
            and csog.status in (9,10,11,12,14,15)
            and csog.closure_reason_id NOT IN (1,5,9)
            GROUP BY csog.grievance_cat_id
        ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
        -- Total submitted
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS total_submitted
            from cat_sub_offc_griv csog
            where grievance_generate_date between '2019-01-01' and '2024-11-11'  
            and csog.status in (9,10,11,12,14,15)
            GROUP BY csog.grievance_cat_id
        ) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
        -- ATR Pending
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS atr_pndg,
                glc.grievance_status
            FROM 
                cat_sub_offc_griv csog, grievance_lifecycle glc
            WHERE 
                glc.grievance_id = csog.grievance_id
                AND glc.grievance_status = 8  -- Grievances currently at status 8
                AND NOT EXISTS (
                    SELECT 1
                    FROM grievance_lifecycle glc2
                    WHERE 
                        glc2.grievance_id = glc.grievance_id
                        AND glc2.grievance_status = 9  -- Grievances that have received status 9
                )
                and csog.grievance_generate_date BETWEEN '2019-01-01' and '2024-11-11'        
            GROUP BY 
                csog.grievance_cat_id, glc.grievance_status
        ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (4);
   
       
       
       
 ----- >>>>> 22.11.24 ------->>>>>>> MIS report 7 part 3
      ---- No. of Grievances Assigned by HoSo (update 1 )
WITH assigned_grievances AS (
            select 
                a.assigned_to_position,
                a.assigned_to_office_id,
                count(distinct a.grievance_id) as grv_assigned  
            from 
                (SELECT 
                    gl.grievance_id, 
                    gl.assigned_to_position,
                    gl.assigned_to_office_id,
                    row_number() OVER 
                        (PARTITION BY grievance_lifecycle.grievance_id 
                            ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_lifecycle gl
                    where grievance_lifecycle.grievance_status in (4,8,9,10,11,12,14,15,16)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11' 
--                    {griv_stat}
--                    {data_source}
--                    {received_at}
                    ) a 
                    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3  
                    group by a.assigned_to_position, a.assigned_to_office_id
                ),
        atr_submitted_to_hoso AS (
                    select 
                        a.assigned_to_position, 
                        a.assigned_to_office_id,
                        count(distinct a.grievance_id) as total_submitted,
                        sum(case when gm.status in (9,10,11,12,14,15) and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                        sum(case when gm.status in (9,10,11,12,14,15) and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                        sum(case when gm.status in (9,10,11,12,14,15) and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                    from 
                        (SELECT 
                            grievance_lifecycle.grievance_id, 
                            grievance_lifecycle.assigned_to_position,
                            grievance_lifecycle.assigned_to_office_id,
                            row_number() OVER 
                                (PARTITION BY grievance_lifecycle.grievance_id 
                                    ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status in (9,10,11,12,14,15)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11' 
--                    {griv_stat}
--                    {data_source}
--                    {received_at}
                    ) a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3   
                    group by a.assigned_to_position, a.assigned_to_office_id
                ),
		 atr_pending AS (
			    SELECT 
			        a.assigned_to_position, 
			        a.assigned_to_office_id,
			        COUNT(a.grievance_id) AS atr_pndg,
			        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
			    FROM 
			        (SELECT 
			            glc.grievance_id, 
			            glc.assigned_to_position,
			            glc.assigned_to_office_id,
			            ROW_NUMBER() OVER (PARTITION BY glc.grievance_id ORDER BY glc.assigned_on DESC) AS rn
			        FROM 
			            grievance_lifecycle glc
			        JOIN 
			            grievance_master gm ON gm.grievance_id = glc.grievance_id
			        WHERE 
			            glc.grievance_status = 8
			            AND NOT EXISTS (
			                SELECT 1
			                FROM grievance_lifecycle glc2
			                WHERE 
			                    glc2.grievance_id = glc.grievance_id
			                    AND glc2.grievance_status = 9
			            ) 
			            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--			            AND gm.grievance_source IN (5)
					) a
			    INNER JOIN 
			        grievance_master gm ON gm.grievance_id = a.grievance_id
			--    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
			    WHERE 
			        rn = 1 AND a.assigned_to_office_id = 3    
			    GROUP BY 
			        a.assigned_to_position, a.assigned_to_office_id
				)
                select  
                    aud.official_name as office_name, 
                    gm.assigned_to_office_id,
--                    gm.assigned_to_position,
                    csom.suboffice_name, 
--    				csom.suboffice_id,
    				csom.suboffice_code,
--    				apm.office_id,
    				apm.sub_office_id,
                    sum(coalesce(ag.grv_assigned,0)) as grievances_assigned,
                    sum(coalesce(asth.bnft_prvd, 0)) as benefit_service_provided,
                    sum(coalesce(asth.action_taken, 0)) as action_taken,
                    sum(coalesce(asth.not_elgbl, 0)) as not_elgbl,
                    sum(coalesce(asth.total_submitted, 0)) as total_submitted,
                    sum(coalesce(ap.beyond_svn_days, 0)) as beyond_svn_days,
                    sum(coalesce(ap.atr_pndg, 0)) as cumulative_pendency
                 FROM 
				    cmo_sub_office_master csom
				LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
				left join grievance_master gm on gm.assigned_to_office_id = apm.office_id and gm.assigned_to_office_id = csom.office_id
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id 
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id 
                left join admin_user au on au.admin_user_id = aud.admin_user_id 
                left join assigned_grievances ag on gm.assigned_to_position = ag.assigned_to_position and ag.assigned_to_office_id = apm.office_id 
                left join atr_submitted_to_hoso asth on asth.assigned_to_position = gm.assigned_to_position and asth.assigned_to_office_id = apm.office_id 
                left join atr_pending ap on ap.assigned_to_position = gm.assigned_to_position and ap.assigned_to_office_id = apm.office_id  
                 WHERE 
				    au.status != 3
				    and apm.office_id = 3
				    and apm.sub_office_id = 4
				 group by 
                	aud.official_name,
--				 	gm.assigned_to_position,
				 	csom.suboffice_code,
                	gm.assigned_to_office_id,
                    csom.suboffice_name,
--    				csom.suboffice_id,
--    				apm.office_id,
    				apm.sub_office_id;
                    
    			
    ---- No. of Grievances Assigned by HoSo (update 2 correct)
   WITH assigned_grievances AS (
    SELECT 
        a.assigned_to_position,
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS grv_assigned  
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER 
                (PARTITION BY grievance_lifecycle.grievance_id 
                 ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
         FROM grievance_master gm
         JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
         WHERE grievance_lifecycle.grievance_status IN (4,8,9,10,11,12,14,15,16)
           AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        ) a 
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3  
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_submitted_to_hoso AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS total_submitted,
        SUM(CASE WHEN gm.status IN (9,10,11,12,14,15) AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN gm.status IN (9,10,11,12,14,15) AND gm.closure_reason_id IN (5,9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN gm.status IN (9,10,11,12,14,15) AND gm.closure_reason_id NOT IN (1,5,9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER 
                (PARTITION BY grievance_lifecycle.grievance_id 
                 ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
         FROM grievance_master gm
         JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
         WHERE grievance_lifecycle.grievance_status IN (9,10,11,12,14,15)
           AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        ) a 
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3   
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER (PARTITION BY glc.grievance_id ORDER BY glc.assigned_on DESC) AS rn
         FROM 
            grievance_lifecycle glc
         JOIN 
            grievance_master gm ON gm.grievance_id = glc.grievance_id
         WHERE 
            glc.grievance_status = 8
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 9
            ) 
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        ) a
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    WHERE 
        rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY 
        a.assigned_to_position, a.assigned_to_office_id
)
SELECT  
    aud.official_name AS office_name, 
    SUM(COALESCE(ag.grv_assigned, 0)) AS total_grievances_assigned,
    SUM(COALESCE(asth.bnft_prvd, 0)) AS total_benefit_service_provided,
    SUM(COALESCE(asth.action_taken, 0)) AS total_action_taken,
    SUM(COALESCE(asth.not_elgbl, 0)) AS total_not_eligible,
    SUM(COALESCE(asth.total_submitted, 0)) AS total_submitted,
    SUM(COALESCE(ap.beyond_svn_days, 0)) AS total_beyond_seven_days,
    SUM(COALESCE(ap.atr_pndg, 0)) AS total_cumulative_pendency
FROM 
    cmo_sub_office_master csom
LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = apm.office_id AND gm.assigned_to_office_id = csom.office_id
LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
LEFT JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id 
LEFT JOIN assigned_grievances ag ON gm.assigned_to_position = ag.assigned_to_position AND ag.assigned_to_office_id = apm.office_id 
LEFT JOIN atr_submitted_to_hoso asth ON asth.assigned_to_position = gm.assigned_to_position 
LEFT JOIN atr_pending ap ON ap.assigned_to_position = gm.assigned_to_position 
WHERE 
    au.status != 3
    AND apm.office_id = 3
    AND apm.sub_office_id = 4
GROUP BY 
    aud.official_name;
                    
                    
                    
                from grievance_master gm
                LEFT JOIN admin_position_master apm ON apm.office_id = gm.assigned_to_office_id and gm.assigned_to_position = apm.position_id
                left join assigned_grievances ag on gm.assigned_to_position = ag.assigned_to_position and ag.assigned_to_office_id = apm.office_id 
                left join atr_submitted_to_hoso asth on asth.assigned_to_position = gm.assigned_to_position and asth.assigned_to_office_id = apm.office_id 
                left join atr_pending ap on ap.assigned_to_position = gm.assigned_to_position and ap.assigned_to_office_id = apm.office_id 
                left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id 
                LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
                LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id 
                LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
                WHERE 
				    au.status != 3
				    AND gm.assigned_to_office_id = 3
				    AND csom.suboffice_id = 5
                group by 
                	gm.assigned_to_position, 
                	aud.official_name, 
                	gm.assigned_to_office_id,
                    csom.suboffice_name, 
    				csom.suboffice_id,
    				ag.grv_assigned,
                	asth.bnft_prvd,
                	asth.action_taken,
               		asth.not_elgbl,
               		asth.total_submitted,
               		ap.beyond_svn_days,
               		ap.atr_pndg;
               		
               
               	
			
--			select * from cmo_sub_office_master csom where office_id = 3 and suboffice_id = 4;
            
               select * from admin_position_master apm where office_id = 3  and sub_office_id = 4;
            
               select * from admin_user_position_mapping aupm  where position_id in (2572,2582);
            
              select * from admin_user_details aud where admin_user_id in (11784,2000);
            
             select * from admin_user au where admin_user_id in (11784,2000);
            
            select * from grievance_master gm limit 10;
   
 select * from cmo_office_master com where com.office_id = 3;
            
               	
               	
SELECT 
    gm.assigned_to_office_id, 
    gm.assigned_to_position, 
    aud.official_name AS office_name, 
    csom.suboffice_name, 
    csom.suboffice_id
FROM 
    grievance_master gm
LEFT JOIN cmo_sub_office_master csom ON gm.assigned_to_office_id = csom.office_id
LEFT JOIN admin_position_master apm ON gm.assigned_to_position = apm.position_id AND apm.office_id = gm.assigned_to_office_id
LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
WHERE 
    au.status != 3
    AND gm.assigned_to_office_id = 3
    AND csom.suboffice_id = 4
GROUP BY 
    gm.assigned_to_position, 
    gm.assigned_to_office_id, 
    aud.official_name, 
    csom.suboffice_name, 
    csom.suboffice_id;
                
           	select * from cmo_sub_office_master csom where office_id = 3 and suboffice_id = 4;
            select * from admin_position_master apm where office_id = 3  and sub_office_id = 4;
            select * from admin_user_position_mapping aupm  where position_id in (2572,2582);
            select * from admin_user_details aud where admin_user_id in (11784,2000);
            select * from admin_user au where admin_user_id in (11784,2000);
            select * from grievance_master gm limit 10;
           select * from grievance_lifecycle gl limit 1;
           where gm.assigned_to_office_id = csom.office_id;
            
SELECT 
    gm.assigned_to_position, 
    gm.assigned_to_office_id, 
    aud.official_name AS office_name, 
    csom.suboffice_name, 
    csom.suboffice_id
FROM 
    cmo_sub_office_master csom
LEFT JOIN grievance_master gm 
    ON gm.assigned_to_office_id = csom.office_id
    AND csom.suboffice_id = 4
LEFT JOIN admin_position_master apm 
    ON gm.assigned_to_position = apm.position_id
    AND apm.office_id = gm.assigned_to_office_id
    AND apm.sub_office_id = csom.suboffice_id
LEFT JOIN admin_user_position_mapping aupm 
    ON aupm.position_id = apm.position_id
LEFT JOIN admin_user_details aud 
    ON aupm.admin_user_id = aud.admin_user_id
LEFT JOIN admin_user au 
    ON au.admin_user_id = aud.admin_user_id
WHERE 
    au.status != 3
    AND gm.assigned_to_office_id = 3
    AND csom.suboffice_id = 4
GROUP BY 
    gm.assigned_to_position,
    gm.assigned_to_office_id,
    aud.official_name,
    csom.suboffice_name, 
    csom.suboffice_id;

           
           
           select 
           	gm.assigned_to_office_id, 
           	gm.assigned_to_position , 
           	aud.official_name as office_name, 
           	csom.suboffice_name, 
           	csom.suboffice_id
           from admin_user_details aud
           left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id 
           left join grievance_master gm on gm.assigned_to_office_id = csom.office_id
           left join admin_position_master apm on gm.assigned_to_position = apm.position_id and apm.office_id = gm.assigned_to_office_id 
           left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id 
           left join admin_user_details aud on aupm.admin_user_id = aud.admin_user_id
           left join admin_user au on au.admin_user_id = aud.admin_user_id
           where au.status != 3
           and gm.assigned_to_office_id = 3
           and csom.suboffice_id = 4
           group by gm.assigned_to_position;
          
          
           
        ------   HOD wise prticular HOSO wise users  -------
SELECT 
    gm.assigned_to_office_id, 
    gm.assigned_to_position, 
    aud.official_name AS office_name, 
    csom.suboffice_name, 
    csom.suboffice_id
FROM 
    grievance_master gm
LEFT JOIN cmo_sub_office_master csom 
    ON gm.assigned_to_office_id = csom.office_id
LEFT JOIN admin_position_master apm 
    ON gm.assigned_to_position = apm.position_id 
    AND apm.office_id = gm.assigned_to_office_id
LEFT JOIN admin_user_position_mapping aupm 
    ON aupm.position_id = apm.position_id
LEFT JOIN admin_user_details aud 
    ON aupm.admin_user_id = aud.admin_user_id
LEFT JOIN admin_user au 
    ON au.admin_user_id = aud.admin_user_id
WHERE 
    au.status != 3
    AND gm.assigned_to_office_id = 3
    AND csom.suboffice_id = 5
GROUP BY 
    gm.assigned_to_position, 
    gm.assigned_to_office_id, 
    aud.official_name, 
    csom.suboffice_name, 
    csom.suboffice_id;


WITH assigned_grievances AS (
    SELECT 
        a.assigned_to_position,
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS grv_assigned  
    FROM (
        SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER (
                PARTITION BY grievance_lifecycle.grievance_id 
                ORDER BY grievance_lifecycle.assigned_on DESC
            ) AS rn
        FROM grievance_master gm
        JOIN grievance_lifecycle 
            ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE grievance_lifecycle.grievance_status IN (4,8,9,10,11,12,14,15,16)
        AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
    ) a 
    INNER JOIN grievance_master gm 
        ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3  
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_submitted_to_hoso AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS total_submitted,
        SUM(CASE WHEN gm.status IN (9,10,11,12,14,15) AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN gm.status IN (9,10,11,12,14,15) AND gm.closure_reason_id IN (5,9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN gm.status IN (9,10,11,12,14,15) AND gm.closure_reason_id NOT IN (1,5,9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM (
        SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER (
                PARTITION BY grievance_lifecycle.grievance_id 
                ORDER BY grievance_lifecycle.assigned_on DESC
            ) AS rn
        FROM grievance_master gm
        JOIN grievance_lifecycle 
            ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE grievance_lifecycle.grievance_status IN (9,10,11,12,14,15)
        AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
    ) a 
    INNER JOIN grievance_master gm 
        ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3   
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM (
        SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER (
                PARTITION BY glc.grievance_id 
                ORDER BY glc.assigned_on DESC
            ) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm 
            ON gm.grievance_id = glc.grievance_id
        WHERE glc.grievance_status = 8
        AND NOT EXISTS (
            SELECT 1
            FROM grievance_lifecycle glc2
            WHERE glc2.grievance_id = glc.grievance_id
            AND glc2.grievance_status = 9
        )
        AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND gm.grievance_source IN (5)
    ) a
    INNER JOIN grievance_master gm 
        ON gm.grievance_id = a.grievance_id
    WHERE rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
)
SELECT  
    aud.official_name AS office_name, 
    gm.assigned_to_office_id,
    gm.assigned_to_position, 
    csom.suboffice_name, 
    csom.suboffice_id,
    COALESCE(ag.grv_assigned, 0) AS grievances_assigned, 
    COALESCE(asth.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(asth.action_taken, 0) AS action_taken,
    COALESCE(asth.not_elgbl, 0) AS not_elgbl,
    COALESCE(asth.total_submitted, 0) AS total_submitted,
    COALESCE(ap.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(ap.atr_pndg, 0) AS cumulative_pendency
FROM grievance_master gm
LEFT JOIN admin_position_master apm 
    ON apm.office_id = gm.assigned_to_office_id AND gm.assigned_to_position = apm.position_id
LEFT JOIN assigned_grievances ag 
    ON gm.assigned_to_position = ag.assigned_to_position AND ag.assigned_to_office_id = apm.office_id 
LEFT JOIN atr_submitted_to_hoso asth 
    ON asth.assigned_to_position = gm.assigned_to_position AND asth.assigned_to_office_id = apm.office_id 
LEFT JOIN atr_pending ap 
    ON ap.assigned_to_position = gm.assigned_to_position AND ap.assigned_to_office_id = apm.office_id 
LEFT JOIN cmo_sub_office_master csom 
    ON csom.suboffice_id = apm.sub_office_id 
LEFT JOIN admin_user_position_mapping aupm 
    ON aupm.position_id = apm.position_id
LEFT JOIN admin_user_details aud 
    ON aupm.admin_user_id = aud.admin_user_id 
LEFT JOIN admin_user au 
    ON au.admin_user_id = aud.admin_user_id
WHERE 
    au.status != 3
    AND gm.assigned_to_office_id = 3
    AND csom.suboffice_id = 5
GROUP BY 
    gm.assigned_to_position, 
    aud.official_name, 
    gm.assigned_to_office_id,
    csom.suboffice_name, 
    csom.suboffice_id,
    ag.grv_assigned,
    asth.bnft_prvd,
    asth.action_taken,
    asth.not_elgbl,
    asth.total_submitted,
    ap.beyond_svn_days,
    ap.atr_pndg;

   
   
---- 25.11.24 -------->>>>>>>
   ------- MIS report 7 update --------
   
WITH received_grievances AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS grv_rcvd  
	    FROM 
	        (
	        SELECT 
	            glc.grievance_id, 
	            glc.grievance_status, 
	            glc.assigned_to_office_id, 
	            glc.assigned_by_office_id, 
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_master gm
	        JOIN grievance_lifecycle glc ON gm.grievance_id = glc.grievance_id
	        WHERE 
	            (
	                (glc.assigned_to_office_id = 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status NOT IN (1, 2))
	                OR
	                (glc.assigned_to_office_id != 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status NOT IN (1, 2, 3, 14))
	            )
	            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
	            AND gm.grievance_source = 5
	        ) a 
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	),
	atr_submitted AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS total_submitted,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id = (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (14, 15, 16, 17) AND gm.closure_reason_id = 1 
	            THEN 1 
	            ELSE 0 
	        END) AS bnft_prvd,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id = (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (14, 15, 16, 17) AND gm.closure_reason_id IN (5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS action_taken,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id = (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (14, 15, 16, 17) AND gm.closure_reason_id NOT IN (1, 5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS not_elgbl,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id != (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (11, 14, 15, 16, 17) AND gm.closure_reason_id = 1 
	            THEN 1 
	            ELSE 0 
	        END) AS bnft_prvd_others,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id != (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (11, 14, 15, 16, 17) AND gm.closure_reason_id IN (5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS action_taken_others,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id != (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (11, 14, 15, 16, 17) AND gm.closure_reason_id NOT IN (1, 5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS not_elgbl_others
	    FROM 
	        (
	        SELECT 
	            glc.grievance_id, 
	            glc.grievance_status, 
	            glc.assigned_to_office_id, 
	            glc.assigned_by_office_id,
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_master gm
	        JOIN grievance_lifecycle glc ON gm.grievance_id = glc.grievance_id
	        WHERE 
	            (
	                (glc.assigned_to_office_id = 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status IN (14, 15, 16, 17))
	                OR
	                (glc.assigned_to_office_id != 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status IN (11, 14, 15, 16, 17))
	            )
	            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
	            AND gm.grievance_source = 5
	        ) a
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 
	      AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	),
	atr_pending AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
	        SUM(CASE 
	            WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' 
	            THEN 1 ELSE 0 
	        END) AS beyond_svn_days
	    FROM 
	        (
	        SELECT 
	            glc.grievance_id, 
	            glc.grievance_status,
	            glc.assigned_to_office_id,
	            glc.assigned_by_office_id,
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_lifecycle glc
	        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
	        WHERE 
	            (
	                (glc.assigned_to_office_id = 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status = 3
	                 AND NOT EXISTS (
	                    SELECT 1
	                    FROM grievance_lifecycle glc2
	                    WHERE glc2.grievance_id = glc.grievance_id
	                      AND glc2.grievance_status = 14
	                 ))
	                OR
	                (glc.assigned_to_office_id != 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status = 5
	                 AND NOT EXISTS (
	                    SELECT 1
	                    FROM grievance_lifecycle glc2
	                    WHERE glc2.grievance_id = glc.grievance_id
	                      AND glc2.grievance_status = 13
	                 ))
	            )
	            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
	            AND gm.grievance_source = 5
	        ) a
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 
	      AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	),
	atr_returned_for_review AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS atr_retrn_reviw
	    FROM 
	        (
	        SELECT 
	            glc.assigned_by_office_id,
	            glc.grievance_id, 
	            glc.grievance_status,
	            glc.assigned_to_office_id,
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_lifecycle glc
	        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
	        WHERE glc.grievance_status = 6
	          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
	          AND gm.grievance_source = 5
	        ) a
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 
	      AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	)
	SELECT  
	    com.office_name AS office_name,
	    COALESCE(rg.grv_rcvd, 0) AS grievances_received, 
	    COALESCE(ats.bnft_prvd, 0) + COALESCE(ats.bnft_prvd_others, 0) AS benefit_service_provided,
	    COALESCE(ats.action_taken, 0) + COALESCE(ats.action_taken_others, 0) AS action_taken,
	    COALESCE(ats.not_elgbl, 0) + COALESCE(ats.not_elgbl_others, 0) AS not_elgbl,
	    COALESCE(ats.total_submitted, 0) AS total_submitted,
	    COALESCE(ap.beyond_svn_days, 0) AS beyond_svn_days,
	    COALESCE(ap.atr_pndg, 0) AS cumulative_pendency,
	    COALESCE(arfr.atr_retrn_reviw, 0) AS atr_return_for_review_from_cmo_other_hod
	FROM received_grievances rg
	LEFT JOIN atr_submitted ats ON ats.assigned_to_office_id = rg.assigned_to_office_id
	LEFT JOIN atr_pending ap ON ap.assigned_to_office_id = rg.assigned_to_office_id
	LEFT JOIN atr_returned_for_review arfr ON arfr.assigned_to_office_id = rg.assigned_to_office_id
	LEFT JOIN cmo_office_master com ON com.office_id = rg.assigned_to_office_id
	ORDER BY 
	    CASE 
	        WHEN com.office_name = 'Chief Minister''s Office' THEN 0
	        ELSE 1 
	    END, 
	    com.office_name;



WITH forwarded_and_assigned_grievances AS (
                select 
                    a.assigned_to_office_id, 
                    count(a.grievance_id) as grv_frwd_assigned  
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.grievance_status, 
                        grievance_lifecycle.assigned_to_office_id, 
                        grievance_lifecycle.assigned_by_office_id, 
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        from grievance_master gm, grievance_lifecycle
                        where grievance_lifecycle.grievance_status in (4,5,6,13,14,15)
                        and gm.grievance_generate_date between '2019-01-01' AND '2024-11-11'
--                        {griv_stat}
--                        {data_source}
--                        {received_at}
                        ) a 
                        inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                        where rn = 1 and a.assigned_by_office_id = 3   
                        group by a.assigned_to_office_id
                    ), 
                latest_atr_received AS (
                        select 
                            a.assigned_to_office_id, 
                            count(a.grievance_id) as atr_rcvd 
                        from 
                            (SELECT 
                                grievance_lifecycle.grievance_id, 
                                grievance_lifecycle.grievance_status, 
                                grievance_lifecycle.assigned_to_office_id, 
                                grievance_lifecycle.assigned_by_office_id,
                                row_number() OVER 
                                    (PARTITION BY grievance_lifecycle.grievance_id 
                                        ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        from grievance_master gm, grievance_lifecycle
                        where grievance_lifecycle.grievance_status in (1,4,5,13,14,16,17)
                        and gm.grievance_generate_date between '2019-01-01' AND '2024-11-11'
--                        {griv_stat}
--                        {data_source}
--                        {received_at}
                        ) a 
                        inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                        where rn = 1 and a.assigned_by_office_id = 3   
                        group by a.assigned_to_office_id
                    ),
                disposal AS (
                        select 
                            a.assigned_to_office_id, 
                            count(a.grievance_id) as total_closed,
                            sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                            sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                            sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                        from 
                            (SELECT 
                                grievance_lifecycle.grievance_id, 
                                grievance_lifecycle.grievance_status, 
                                grievance_lifecycle.assigned_to_office_id, 
                                grievance_lifecycle.assigned_by_office_id,
                                row_number() OVER 
                                    (PARTITION BY grievance_lifecycle.grievance_id 
                                        ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        from grievance_master gm, grievance_lifecycle
                        where grievance_lifecycle.grievance_status = 15
                        and gm.grievance_generate_date between '2019-01-01' AND '2024-11-11'
--                        {griv_stat}
--                        {data_source}
--                        {received_at}
                        ) a 
                        inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                        where rn = 1 and a.assigned_by_office_id = 3    
                        group by a.assigned_to_office_id
                    ),
                pending AS (
                    SELECT 
                        a.assigned_to_office_id, 
                        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
                        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
                    FROM 
                        (
                        SELECT 
                            glc.grievance_id, 
                            glc.grievance_status,
                            glc.assigned_to_office_id,
                            glc.assigned_by_office_id,
                            ROW_NUMBER() OVER 
                            (PARTITION BY glc.grievance_id 
                                ORDER BY glc.assigned_on DESC) AS rn
                        FROM grievance_lifecycle glc
                        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
                        WHERE 
                            glc.grievance_status = 6
                            AND NOT EXISTS (
                                SELECT 1
                                FROM grievance_lifecycle glc2
                                WHERE 
                                    glc2.grievance_id = glc.grievance_id
                                    AND glc2.grievance_status = 13
                            )
                            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--                            {griv_stat}
--                            {data_source}
--                            {received_at}
                            ) a
                    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
                    inner join grievance_lifecycle glc on glc.assigned_to_office_id = a.assigned_to_office_id
                    WHERE rn = 1 and a.assigned_by_office_id = 3   
                    GROUP BY a.assigned_to_office_id
                )
                    select  
                        com.office_name as office_name,
                        coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
                        coalesce(ltr.atr_rcvd, 0) as atr_received,
                        coalesce(d.bnft_prvd, 0) as benefit_service_provided,
                        coalesce(d.action_taken, 0) as action_taken,
                        coalesce(d.not_elgbl, 0) as not_elgbl,
                        coalesce(d.total_closed, 0) as total_disposed,
                        coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
                        coalesce(p.atr_pndg, 0) as cumulative
                    from forwarded_and_assigned_grievances fag
                    left join latest_atr_received ltr on ltr.assigned_to_office_id = fag.assigned_to_office_id
                    left join disposal d on d.assigned_to_office_id = fag.assigned_to_office_id
                    left join pending p on p.assigned_to_office_id = fag.assigned_to_office_id
                    left join cmo_office_master com on com.office_id = fag.assigned_to_office_id
                    group by com.office_name, fag.assigned_to_office_id,  fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg; 
					   
					   
WITH forwarded_and_assigned_grievances AS (
    SELECT 
        a.assigned_to_office_id, 
        COUNT(a.grievance_id) AS grv_frwd_assigned  
    FROM (
        SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.grievance_status, 
            grievance_lifecycle.assigned_to_office_id, 
            grievance_lifecycle.assigned_by_office_id, 
            ROW_NUMBER() OVER (
                PARTITION BY grievance_lifecycle.grievance_id 
                ORDER BY grievance_lifecycle.assigned_on DESC
            ) AS rn
        FROM 
            grievance_master gm
        JOIN 
            grievance_lifecycle 
            ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE 
            -- Apply specific filters for "Chief Minister's Office" and general filters for others
            (
                (grievance_lifecycle.assigned_to_office_id = 
                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
                 AND grievance_lifecycle.grievance_status IN (4, 5, 13, 14)) -- Filters for Chief Minister's Office
                OR
                (grievance_lifecycle.assigned_to_office_id != 
                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
                 AND grievance_lifecycle.grievance_status IN (4, 5, 6, 13, 14, 15)) -- Filters for others
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source = 5
    ) a 
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = a.grievance_id 
    WHERE 
        rn = 1 AND a.assigned_by_office_id = 3   
    GROUP BY 
        a.assigned_to_office_id
)
-- Continue with the rest of your query logic
SELECT * 
FROM forwarded_and_assigned_grievances;


----- mis 7 cat_wise_mis_report_hod_7_v3 -----
SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table0.office_id,
    table0.suboffice_id,
    COALESCE(table0.suboffice_name) AS office_name,
    COALESCE(table1.grv_frwd, 0) AS grievances_forwarded,
    COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(table3.action_taken, 0) AS action_taken,
    COALESCE(table4.not_elgbl, 0) AS not_elgbl,
    COALESCE(table5.total_submitted, 0) AS total_submitted,
    COALESCE(table6.atr_pndg, 0) AS atr_pending
FROM (
    SELECT 
        DISTINCT cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        com.office_id AS office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id
    FROM cmo_grievance_category_master cgcm
    left join grievance_master gm on gm.grievance_category = cgcm.grievance_cat_id
    left join cmo_office_master com ON com.office_id = gm.assigned_to_office_id
    left join cmo_sub_office_master csom ON csom.office_id = com.office_id
    WHERE cgcm.status = 1
) table0
-- No. of Grievances Forwarded
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS grv_frwd
    FROM cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'
    and csog.status in (7,8,9,10,11,12,14,15,16,17)
--    and csog.grievance_source IN (5)
    GROUP BY csog.grievance_cat_id
) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
-- Benefit/ Service Provided
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS bnft_prvd
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'
    and csog.status in (9,10,11,12,14,15)
    and csog.closure_reason_id = 1
--    and csog.grievance_source IN (5)
    GROUP BY csog.grievance_cat_id
) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
-- Action Initiated
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS action_taken
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status in (9,10,11,12,14,15)  
    and csog.closure_reason_id IN (5,9)
--    and csog.grievance_source IN (5)
    GROUP BY csog.grievance_cat_id
) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
-- Not eligible to get benefit
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS not_elgbl
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status in (9,10,11,12,14,15)
    and csog.closure_reason_id NOT IN (1,5,9)
--    and csog.grievance_source IN (5)
    GROUP BY csog.grievance_cat_id
) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
-- Total submitted
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS total_submitted
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status in (9,10,11,12,14,15)
--    and csog.grievance_source IN (5)
    GROUP BY csog.grievance_cat_id
) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
-- ATR Pending
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS atr_pndg,
        glc.grievance_status
    FROM 
        cat_sub_offc_griv csog, grievance_lifecycle glc
    WHERE 
        glc.grievance_id = csog.grievance_id
        AND glc.grievance_status = 8  -- Grievances currently at status 8
        AND NOT EXISTS (
            SELECT 1
            FROM grievance_lifecycle glc2
            WHERE 
                glc2.grievance_id = glc.grievance_id
                AND glc2.grievance_status = 9  -- Grievances that have not received status 9
        )
        and csog.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-25'  
--        and csog.grievance_source IN (5)
    GROUP BY 
        csog.grievance_cat_id, glc.grievance_status
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (4);


----- mis 7 suboff_wise_mis_report_hod_7_v3 ----------
WITH assigned_grievances AS (
            select 
                a.assigned_to_position,
                a.assigned_to_office_id,
                count(distinct a.grievance_id) as grv_assigned  
            from 
                (SELECT 
                    grievance_lifecycle.grievance_id, 
                    grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    row_number() OVER 
                        (PARTITION BY grievance_lifecycle.grievance_id 
                            ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status in (4,8,9,10,11,12,14,15,16)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-25' 
                    and gm.grievance_source IN (5)
                    ) a 
                    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3  
                    group by a.assigned_to_position, a.assigned_to_office_id
                ),
        atr_submitted_to_hoso AS (
                    select 
                        a.assigned_to_position, 
                        a.assigned_to_office_id,
                        count(distinct a.grievance_id) as total_submitted,
                        sum(case when gm.status in (9,10,11,12,14,15) and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                        sum(case when gm.status in (9,10,11,12,14,15) and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                        sum(case when gm.status in (9,10,11,12,14,15) and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                    from 
                        (SELECT 
                            grievance_lifecycle.grievance_id, 
                            grievance_lifecycle.assigned_to_position,
                            grievance_lifecycle.assigned_to_office_id,
                            row_number() OVER 
                                (PARTITION BY grievance_lifecycle.grievance_id 
                                    ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status in (9,10,11,12,14,15)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-25' 
                    and gm.grievance_source IN (5)
                    ) a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3   
                    group by a.assigned_to_position, a.assigned_to_office_id
                ),
		 atr_pending AS (
			    SELECT 
			        a.assigned_to_position, 
			        a.assigned_to_office_id,
			        COUNT(a.grievance_id) AS atr_pndg,
			        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
			    FROM 
			        (SELECT 
			            glc.grievance_id, 
			            glc.assigned_to_position,
			            glc.assigned_to_office_id,
			            ROW_NUMBER() OVER (PARTITION BY glc.grievance_id ORDER BY glc.assigned_on DESC) AS rn
			        FROM 
			            grievance_lifecycle glc
			        JOIN 
			            grievance_master gm ON gm.grievance_id = glc.grievance_id
			        WHERE 
			            glc.grievance_status = 8
			            AND NOT EXISTS (
			                SELECT 1
			                FROM grievance_lifecycle glc2
			                WHERE 
			                    glc2.grievance_id = glc.grievance_id
			                    AND glc2.grievance_status = 9
			            ) 
			            AND gm.grievance_generate_date BETWEEN '2019-01-01' and '2024-11-25' 
			            and gm.grievance_source IN (5)
					) a
			    INNER JOIN 
			        grievance_master gm ON gm.grievance_id = a.grievance_id
			--    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
			    WHERE 
			        rn = 1 AND a.assigned_to_office_id = 3    
			    GROUP BY 
			        a.assigned_to_position, a.assigned_to_office_id
				)
                select  
                    aud.official_name as office_name, 
                    gm.assigned_to_office_id,
--                    gm.assigned_to_position,
                    csom.suboffice_name, 
--    				csom.suboffice_id,
    				csom.suboffice_code,
--    				apm.office_id,
    				apm.sub_office_id,
                    sum(coalesce(CAST(ag.grv_assigned AS INTEGER), 0)) as grievances_assigned,
                    sum(coalesce(CAST(asth.bnft_prvd AS INTEGER), 0)) as benefit_service_provided,
                    sum(coalesce(CAST(asth.action_taken AS INTEGER), 0)) as action_taken,
                    sum(coalesce(CAST(asth.not_elgbl AS INTEGER), 0)) as not_elgbl,
                    sum(coalesce(CAST(asth.total_submitted AS INTEGER), 0)) as total_submitted,
                    sum(coalesce(CAST(ap.beyond_svn_days AS INTEGER), 0)) as beyond_svn_days,
                    sum(coalesce(CAST(ap.atr_pndg AS INTEGER), 0)) as cumulative_pendency
                 FROM 
				    cmo_sub_office_master csom
				LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
				left join grievance_master gm on gm.assigned_to_office_id = apm.office_id and gm.assigned_to_office_id = csom.office_id
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id 
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id 
                left join admin_user au on au.admin_user_id = aud.admin_user_id 
                left join assigned_grievances ag on gm.assigned_to_position = ag.assigned_to_position and ag.assigned_to_office_id = apm.office_id 
                left join atr_submitted_to_hoso asth on asth.assigned_to_position = gm.assigned_to_position and asth.assigned_to_office_id = apm.office_id 
                left join atr_pending ap on ap.assigned_to_position = gm.assigned_to_position and ap.assigned_to_office_id = apm.office_id  
                 WHERE 
				    au.status != 3
				    and apm.office_id = 3
				    and apm.sub_office_id = 4
				 group by 
                	aud.official_name,
--				 	gm.assigned_to_position,
				 	csom.suboffice_code,
                	gm.assigned_to_office_id,
                    csom.suboffice_name,
--    				csom.suboffice_id,
--    				apm.office_id,
    				apm.sub_office_id;
    			
  WITH assigned_grievances AS (
    SELECT 
        a.assigned_to_position,
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS grv_assigned  
    FROM (
        SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER (
                PARTITION BY grievance_lifecycle.grievance_id 
                ORDER BY grievance_lifecycle.assigned_on DESC
            ) AS rn
        FROM grievance_master gm
        JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE grievance_lifecycle.grievance_status IN (4,8,9,10,11,12,14,15,16)
          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-25' 
          AND gm.grievance_source IN (5)
    ) a 
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3  
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_submitted_to_hoso AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS total_submitted
    FROM (
        SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER (
                PARTITION BY grievance_lifecycle.grievance_id 
                ORDER BY grievance_lifecycle.assigned_on DESC
            ) AS rn
        FROM grievance_master gm
        JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
        WHERE grievance_lifecycle.grievance_status IN (9,10,11,12,14,15)
          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-25' 
          AND gm.grievance_source IN (5)
    ) a 
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3   
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(a.grievance_id) AS atr_pndg
    FROM (
        SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER (PARTITION BY glc.grievance_id ORDER BY glc.assigned_on DESC) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE glc.grievance_status = 8
          AND NOT EXISTS (
              SELECT 1
              FROM grievance_lifecycle glc2
              WHERE glc2.grievance_id = glc.grievance_id
                AND glc2.grievance_status = 9
          ) 
          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-25' 
          AND gm.grievance_source IN (5)
    ) a
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    WHERE rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
)
SELECT  
    aud.official_name AS office_name, 
    aud.admin_user_id,
    gm.assigned_to_office_id,
    csom.suboffice_name, 
    csom.suboffice_code,
    apm.sub_office_id,
    COALESCE(CAST(ag.grv_assigned AS INTEGER), 0) AS grievances_assigned,
    COALESCE(CAST(asth.total_submitted AS INTEGER), 0) AS total_submitted,
    COALESCE(CAST(ap.atr_pndg AS INTEGER), 0) AS cumulative_pendency
FROM cmo_sub_office_master csom
LEFT JOIN admin_position_master apm 
    ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
LEFT JOIN grievance_master gm 
    ON gm.assigned_to_office_id = apm.office_id AND gm.assigned_to_office_id = csom.office_id
LEFT JOIN admin_user_position_mapping aupm 
    ON aupm.position_id = apm.position_id 
LEFT JOIN admin_user_details aud 
    ON aud.admin_user_id = aupm.admin_user_id 
LEFT JOIN admin_user au 
    ON au.admin_user_id = aud.admin_user_id 
LEFT JOIN assigned_grievances ag 
    ON gm.assigned_to_position = ag.assigned_to_position AND ag.assigned_to_office_id = apm.office_id 
LEFT JOIN atr_submitted_to_hoso asth 
    ON asth.assigned_to_position = gm.assigned_to_position AND asth.assigned_to_office_id = apm.office_id 
LEFT JOIN atr_pending ap 
    ON ap.assigned_to_position = gm.assigned_to_position AND ap.assigned_to_office_id = apm.office_id  
WHERE 
    au.status != 3
    AND apm.office_id = 3
    AND apm.sub_office_id = 4
GROUP BY 
    aud.official_name,
    aud.admin_user_id,
    csom.suboffice_code,
    gm.assigned_to_office_id,
    csom.suboffice_name,
    apm.sub_office_id,
   	ag.grv_assigned,
   	asth.total_submitted,
   	ap.atr_pndg
  order by 
 	 aud.official_name,
    csom.suboffice_code;

	
--   DROP VIEW IF EXISTS cat_sub_offc_griv;
    			
    			
    			
 ------- mis 6 sub_off_report_6_v3 -----  			
  WITH forwarded_and_assigned_grievances AS (       
                select 
                    a.assigned_to_position, 
                    count(a.grievance_id) as grv_frwd_assigned 
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_to_position,
                            row_number() OVER 
                                (PARTITION BY grievance_lifecycle.grievance_id 
                                    ORDER BY grievance_lifecycle.assigned_on desc) AS rn
                    from grievance_master gm, grievance_lifecycle
                    where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                    and gm.status = '3'
                    and gm.grievance_source in (5)
                    and gm.received_at in (4)) a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3
                    group by a.assigned_to_position
                ),       
            latest_atr_received AS (
                select 
                    a.assigned_by_position, 
                    count(a.grievance_id) as atr_rcvd  
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                            row_number() OVER 
                                (PARTITION BY grievance_lifecycle.grievance_id 
                                    ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm, grievance_lifecycle
                    where grievance_lifecycle.grievance_status in (1,4,5,11,14,16,17)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                    and gm.status = '3'
                    and gm.grievance_source in (5)
                    and gm.received_at in (4)) a 
                    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3 
                    group by a.assigned_by_position
                ), 
            disposal AS (
                select 
                    a.assigned_to_position, 
                    count(a.grievance_id) as total_closed,
                    sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                    sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                    sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm, grievance_lifecycle
                    where grievance_lifecycle.grievance_status = 15
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                    and gm.status = '3'
                    and gm.grievance_source in (5)
                    and gm.received_at in (4)) a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3    
                    group by a.assigned_to_position
                ),
            pending AS (
                SELECT 
                    a.assigned_to_position, 
                    COUNT(DISTINCT a.grievance_id) AS atr_pndg,
                    SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
                FROM 
                    (
                    SELECT 
                        glc.grievance_id, 
                        glc.assigned_to_position,
                        glc.assigned_to_office_id,
                        ROW_NUMBER() OVER 
                        (PARTITION BY glc.grievance_id 
                            ORDER BY glc.assigned_on DESC) AS rn
                    FROM grievance_lifecycle glc
                    JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
                    WHERE 
                        glc.grievance_status = 7
                        AND NOT EXISTS (
                            SELECT 1
                            FROM grievance_lifecycle glc2
                            WHERE 
                                glc2.grievance_id = glc.grievance_id
                                AND glc2.grievance_status = 11
                        )
                        AND gm.grievance_generate_date BETWEEN '2019-01-01' and '2024-11-11'
                        and gm.status = '3'
                        and gm.grievance_source in (5)
                        and gm.received_at in (4)) a
                INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
                inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
                WHERE rn = 1 and a.assigned_to_office_id = 3    
                GROUP BY a.assigned_to_position
            )
            select  
                csom.suboffice_name as office_name, 
                coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
                coalesce(ltr.atr_rcvd, 0) as atr_received,
                coalesce(d.bnft_prvd, 0) as benefit_service_provided,
                coalesce(d.action_taken, 0) as action_taken,
                coalesce(d.not_elgbl, 0) as not_elgbl,
                coalesce(d.total_closed, 0) as total_disposed,
                coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
                coalesce(p.atr_pndg, 0) as cumulative   
            from forwarded_and_assigned_grievances fag
            left join latest_atr_received ltr on ltr.assigned_by_position = fag.assigned_to_position
            left join disposal d on d.assigned_to_position = fag.assigned_to_position
            left join pending p on p.assigned_to_position = fag.assigned_to_position
            left join admin_position_master apm on apm.position_id = fag.assigned_to_position
            left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id
            group by csom.suboffice_name, fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg;
            
     
 -------- mis 6 hod other_hods_mis_report_hod_6_v3 --------
           WITH forwarded_grievances AS (
                select 
                    a.assigned_to_office_id, 
                    count(a.grievance_id) as grv_frwd 
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.grievance_status, 
                        grievance_lifecycle.assigned_to_office_id, 
                        grievance_lifecycle.assigned_by_office_id, 
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        from grievance_master gm, grievance_lifecycle
                        where grievance_lifecycle.grievance_status in (4,5,6,13,14,15)
                        and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                        
                        ) a 
                        inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                        where rn = 1 and a.assigned_by_office_id = 3   
                        group by a.assigned_to_office_id
                    ), 
                atr_received AS (
                        select 
                            a.assigned_to_office_id, 
                            count(a.grievance_id) as total_closed,
                            sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                            sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                            sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                        from 
                            (SELECT 
                                grievance_lifecycle.grievance_id, 
                                grievance_lifecycle.grievance_status, 
                                grievance_lifecycle.assigned_to_office_id, 
                                grievance_lifecycle.assigned_by_office_id,
                                row_number() OVER 
                                    (PARTITION BY grievance_lifecycle.grievance_id 
                                        ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        from grievance_master gm, grievance_lifecycle
                        where grievance_lifecycle.grievance_status = 15
                        and gm.grievance_generate_date between '2024-11-11' and '2019-01-01'
                        
                        ) a 
                        inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                        where rn = 1 and a.assigned_by_office_id = 3    
                        group by a.assigned_to_office_id
                    ),
                pending AS (
                    SELECT 
                        a.assigned_to_office_id, 
                        COUNT(DISTINCT a.grievance_id) AS atr_pndg
                    FROM 
                        (
                        SELECT 
                            grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_office_id,
                            ROW_NUMBER() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        from grievance_master gm, grievance_lifecycle
                        where grievance_lifecycle.grievance_status not in (1,2,14,15,16,17)
                        and gm.grievance_generate_date between '2024-11-11' and '2019-01-01'
                            
                            ) a
                    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
                    WHERE rn = 1 and a.assigned_by_office_id = 3    
                    GROUP BY a.assigned_to_office_id
                    ),
                atr_returned_for_review AS (
                        select 
                            a.assigned_to_office_id, 
                            COUNT(DISTINCT a.grievance_id) AS atr_retrn_reviw
                        from 
                            (SELECT 
                                grievance_lifecycle.grievance_id, 
                                grievance_lifecycle.grievance_status, 
                                grievance_lifecycle.assigned_to_office_id, 
                                grievance_lifecycle.assigned_by_office_id,
                                row_number() OVER 
                                    (PARTITION BY grievance_lifecycle.grievance_id 
                                        ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        from grievance_master gm, grievance_lifecycle
                        where grievance_lifecycle.grievance_status = 6
                        and gm.grievance_generate_date between '2024-11-11' and '2019-01-01'
                        
                        ) a 
                        inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                        where rn = 1 and a.assigned_by_office_id = 3   
                        group by a.assigned_to_office_id
                    )
                    select  
                        com.office_name as office_name,
                        coalesce(fag.grv_frwd,0) as grievances_forwarded, 
                        coalesce(ar.bnft_prvd, 0) as benefit_service_provided,
                        coalesce(ar.action_taken, 0) as action_taken,
                        coalesce(ar.not_elgbl, 0) as not_elgbl,
                        coalesce(ar.total_closed, 0) as total_disposed,
                        coalesce(p.atr_pndg, 0) as pending,
                        coalesce(atr.atr_retrn_reviw, 0) as atr_returned_for_review
                    from forwarded_grievances fag
                    left join atr_received ar on ar.assigned_to_office_id = fag.assigned_to_office_id
                    left join pending p on p.assigned_to_office_id = fag.assigned_to_office_id
                    left join atr_returned_for_review atr on atr.assigned_to_office_id = fag.assigned_to_office_id
                    left join cmo_office_master com on com.office_id = fag.assigned_to_office_id
                    group by com.office_name, fag.grv_frwd, ar.bnft_prvd, ar.action_taken, ar.not_elgbl, ar.total_closed, p.atr_pndg, atr.atr_retrn_reviw; 
                    
                   
 -------------- mis 6 hod sub_off_report_hod_6_v3 ----------    
     WITH forwarded_grievances AS (       
                select 
                    a.assigned_to_position, 
                    count(distinct a.grievance_id) as grv_frwd_assigned 
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_to_position,
                            row_number() OVER 
                                (PARTITION BY grievance_lifecycle.grievance_id 
                                    ORDER BY grievance_lifecycle.assigned_on desc) AS rn
                    from grievance_master gm
                    JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                    
                    
                    ) a 
                    -- inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3
                    group by a.assigned_to_position
               ),
	 atr_received AS (
                select 
                    a.assigned_to_position, 
                    count(distinct a.grievance_id) as total_closed,
                    sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                    sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                    sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                from 
                    (SELECT 
                        grievance_lifecycle.grievance_id, 
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status = 15
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                    
                    
                    ) a 
                    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3    
                    group by a.assigned_to_position
                ),
		pending AS (
                SELECT 
                    a.assigned_to_position, 
                    COUNT(DISTINCT a.grievance_id) AS atr_pndg
                FROM 
                    (SELECT 
                        grievance_lifecycle.grievance_id,  
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status not in (1,2,14,15,16,17)
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                     
                     
                       ) a
                    inner join grievance_master gm ON gm.grievance_id = a.grievance_id
                    WHERE rn = 1 and a.assigned_to_office_id = 3    
                    GROUP BY a.assigned_to_position
                ),
	atr_returned_for_review AS (
                SELECT 
                    a.assigned_to_position, 
                    COUNT(a.grievance_id) AS atr_retrn_reviw
                FROM 
                    (
                    SELECT 
                        grievance_lifecycle.grievance_id,  
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm
                    join grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
                    where grievance_lifecycle.grievance_status = 6
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                    
                    
                        ) a
                inner join grievance_master gm ON gm.grievance_id = a.grievance_id
                WHERE rn = 1 and a.assigned_to_office_id = 3    
                GROUP BY a.assigned_to_position
            )
            select  
                csom.suboffice_name as office_name, csom.suboffice_code,
                coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded, 
                coalesce(ar.bnft_prvd, 0) as benefit_service_provided,
                coalesce(ar.action_taken, 0) as action_taken,
                coalesce(ar.not_elgbl, 0) as not_elgbl,
                coalesce(ar.total_closed, 0) as total_disposed,
                coalesce(p.atr_pndg, 0) as pending,
                coalesce(atr.atr_retrn_reviw, 0) as atr_returned_for_review
            from cmo_sub_office_master csom
            left join admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
            left join forwarded_grievances fag ON fag.assigned_to_position = apm.position_id
            LEFT JOIN atr_received ar ON ar.assigned_to_position = apm.position_id
            LEFT JOIN pending p on p.assigned_to_position = apm.position_id
            LEFT JOIN atr_returned_for_review atr on atr.assigned_to_position = apm.position_id
			WHERE 
    			csom.office_id = 3
            group by 
            	csom.suboffice_name, 
            	csom.suboffice_code,
            	fag.grv_frwd_assigned, 
            	ar.bnft_prvd, 
            	ar.action_taken, 
            	ar.not_elgbl, 
            	ar.total_closed, 
            	p.atr_pndg, 
            	atr.atr_retrn_reviw;
                   
            
            
            
 SELECT 
    COUNT(DISTINCT gm.grievance_id) AS grievance_count,
    aud.official_name
FROM 
    cmo_sub_office_master csom 
LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = apm.office_id AND gm.assigned_to_office_id = csom.office_id
LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
LEFT JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id
LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
WHERE 
    gm.status IN (8, 9, 10, 11, 14, 16, 17, 15)
    AND au.status != 3
    AND apm.office_id = 3
    AND apm.sub_office_id = 4
  group by
 		aud.official_name;

 	
SELECT 
	    COUNT(DISTINCT gm.grievance_id) AS grievance_count,
	    aud.official_name 	
	FROM 
	    cmo_sub_office_master csom 
	LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
	LEFT JOIN grievance_master gm ON gm.atr_submit_by_lastest_office_id = apm.office_id AND gm.atr_submit_by_lastest_office_id = csom.office_id
	LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
	LEFT JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id
	LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
	WHERE 
	    gm.status IN (4, 9, 11, 14, 16, 17, 15)
	    and gm.closure_reason_id in (1,5,9)
	    AND au.status != 3
	    AND apm.office_id = 3
	    AND apm.sub_office_id = 4
	  group by
 		aud.official_name;

 	
----- hoso 3 part 2 ----- done
SELECT  
    table0.admin_user_id,
    table0.office_id,
    table0.suboffice_id,
    COALESCE(table0.official_name) AS office_name,
    COALESCE(table0.suboffice_name) AS suboffice_name,
    COALESCE(SUM(table1.grv_assigned), 0) AS grievances_assigned,
    COALESCE(SUM(table2.bnft_prvd), 0) AS benefit_service_provided,
    COALESCE(SUM(table3.action_taken), 0) AS action_taken,
    COALESCE(SUM(table4.not_elgbl), 0) AS not_elgbl,
    COALESCE(SUM(table5.total_received), 0) AS total_received,
    COALESCE(SUM(table6.beyond_svn_days), 0) AS beyond_svn_days,
    COALESCE(SUM(table6.atr_pndg), 0) AS cumulative_pendency,
    COALESCE(SUM(table7.atr_review), 0) AS atr_returned_from_hod_for_review 
FROM (
    SELECT 
        aud.admin_user_id, 
        aud.official_name, 
        com.office_id AS office_id,
        gm.assigned_to_office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id
    FROM admin_user au 
    LEFT JOIN admin_user_details aud ON aud.admin_user_id = au.admin_user_id 
    LEFT JOIN admin_user_position_mapping aupm ON aupm.admin_user_id = aud.admin_user_id 
    LEFT JOIN admin_position_master apm ON aupm.position_id = apm.position_id   
    LEFT JOIN cmo_sub_office_master csom ON csom.suboffice_id = apm.sub_office_id
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = apm.office_id AND gm.assigned_to_office_id = csom.office_id
    LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id AND csom.office_id = com.office_id
) table0
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS grv_assigned
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'
      AND csog.status IN (8,9,11,12,14,15,16,17,4)
    GROUP BY csog.admin_user_id 
) table1 ON table0.admin_user_id = table1.admin_user_id 
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS bnft_prvd
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id = 1
    GROUP BY csog.admin_user_id
) table2 ON table2.admin_user_id = table0.admin_user_id 
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS action_taken
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id IN (5,9)
    GROUP BY csog.admin_user_id
) table3 ON table0.admin_user_id = table3.admin_user_id
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS not_elgbl
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id NOT IN (1,5,9)
    GROUP BY csog.admin_user_id
) table4 ON table0.admin_user_id = table4.admin_user_id
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS total_received
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,11,16,14,15,17) 
    GROUP BY csog.admin_user_id
) table5 ON table0.admin_user_id = table5.admin_user_id
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - csog.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM cat_sub_offc_griv csog
    JOIN grievance_lifecycle glc ON glc.grievance_id = csog.grievance_id
    WHERE glc.grievance_status = 8
      AND NOT EXISTS (
          SELECT 1
          FROM grievance_lifecycle glc2
          WHERE glc2.grievance_id = glc.grievance_id
            AND glc2.grievance_status = 9
      )
      AND csog.grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
    GROUP BY csog.admin_user_id
) table6 ON table0.admin_user_id = table6.admin_user_id 
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS atr_review
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status = 10
    GROUP BY csog.admin_user_id
) table7 ON table0.admin_user_id = table7.admin_user_id
WHERE table0.office_id = 3 AND table0.suboffice_id = 4
GROUP BY 
    table0.admin_user_id, 
    table0.office_id, 
    table0.suboffice_id, 
    table0.official_name, 
    table0.suboffice_name;


  ----- hoso 3 part 2 --- done 
SELECT  
	table0.grievance_cat_id,
    table0.admin_user_id,
    table0.office_id,
    table0.suboffice_id,
    COALESCE(table0.grievance_category_desc) AS grievance_category_desc,
    COALESCE(table0.official_name) AS office_name,
    COALESCE(table0.suboffice_name) AS suboffice_name,
    COALESCE(SUM(table1.grv_assigned), 0) AS grievances_assigned,
    COALESCE(SUM(table2.bnft_prvd), 0) AS benefit_service_provided,
    COALESCE(SUM(table3.action_taken), 0) AS action_taken,
    COALESCE(SUM(table4.not_elgbl), 0) AS not_elgbl,
    COALESCE(SUM(table5.total_received), 0) AS total_received,
    COALESCE(SUM(table6.beyond_svn_days), 0) AS beyond_svn_days,
    COALESCE(SUM(table6.atr_pndg), 0) AS cumulative_pendency,
    COALESCE(SUM(table7.atr_review), 0) AS atr_returned_from_hod_for_review 
FROM (
    SELECT 
    	DISTINCT cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        aud.admin_user_id, 
        aud.official_name, 
        com.office_id AS office_id,
--        gm.assigned_to_office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id
    FROM cmo_grievance_category_master cgcm
    left join grievance_master gm on gm.grievance_category = cgcm.grievance_cat_id
    left join cmo_office_master com ON com.office_id = gm.assigned_to_office_id
    left join cmo_sub_office_master csom ON csom.office_id = com.office_id
    LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id 
    left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id 
    left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id 
    left join admin_user au on au.admin_user_id = aud.admin_user_id   
) table0
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS grv_assigned
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'
      AND csog.status IN (8,9,11,12,14,15,16,17,4)
    GROUP BY csog.grievance_cat_id 
) table1 ON table0.grievance_cat_id = table1.grievance_cat_id 
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS bnft_prvd
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id = 1
    GROUP BY csog.grievance_cat_id
) table2 ON table2.grievance_cat_id = table0.grievance_cat_id 
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS action_taken
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id IN (5,9)
    GROUP BY csog.grievance_cat_id
) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS not_elgbl
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id NOT IN (1,5,9)
    GROUP BY csog.grievance_cat_id
) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS total_received
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,11,16,14,15,17) 
    GROUP BY csog.grievance_cat_id
) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - csog.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM cat_sub_offc_griv csog
    JOIN grievance_lifecycle glc ON glc.grievance_id = csog.grievance_id
    WHERE glc.grievance_status = 8
      AND NOT EXISTS (
          SELECT 1
          FROM grievance_lifecycle glc2
          WHERE glc2.grievance_id = glc.grievance_id
            AND glc2.grievance_status = 9
      )
      AND csog.grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
    GROUP BY csog.grievance_cat_id
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id 
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS atr_review
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status = 10
    GROUP BY csog.grievance_cat_id
) table7 ON table0.grievance_cat_id = table7.grievance_cat_id
WHERE table0.office_id = 3 AND table0.suboffice_id = 4 AND table0.admin_user_id = 2000
GROUP BY 
	table0.grievance_cat_id,
	table0.grievance_category_desc,
    table0.admin_user_id, 
    table0.office_id, 
    table0.suboffice_id, 
    table0.official_name, 
    table0.suboffice_name;
  
   
   select * from grievance_master gm limit 1;
   ---------
  
  
 ------------ hoso 4 done -------------
  SELECT  
  	table0.grievance_cat_id,
  	table0.grievance_category_desc,
    table0.admin_user_id,
    table0.office_id,
    table0.suboffice_id,
    COALESCE(table0.official_name) AS office_name,
    COALESCE(table0.suboffice_name) AS suboffice_name,
    COALESCE(SUM(table1.grv_assigned), 0) AS grievances_assigned,
    COALESCE(SUM(table2.bnft_prvd), 0) AS benefit_service_provided,
    COALESCE(SUM(table3.action_taken), 0) AS action_taken,
    COALESCE(SUM(table4.not_elgbl), 0) AS not_elgbl,
    COALESCE(SUM(table5.total_received), 0) AS total_received,
    COALESCE(SUM(table6.beyond_svn_days), 0) AS beyond_svn_days,
    COALESCE(SUM(table6.atr_pndg), 0) AS cumulative_pendency,
    COALESCE(SUM(table7.atr_review), 0) AS atr_returned_from_hod_for_review 
FROM (
    SELECT 
    	cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc,
        aud.admin_user_id, 
        aud.official_name, 
        com.office_id AS office_id,
        gm.assigned_to_office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id
    FROM admin_user au 
    LEFT JOIN admin_user_details aud ON aud.admin_user_id = au.admin_user_id 
    LEFT JOIN admin_user_position_mapping aupm ON aupm.admin_user_id = aud.admin_user_id 
    LEFT JOIN admin_position_master apm ON aupm.position_id = apm.position_id   
    LEFT JOIN cmo_sub_office_master csom ON csom.suboffice_id = apm.sub_office_id
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = apm.office_id AND gm.assigned_to_office_id = csom.office_id
    LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id AND csom.office_id = com.office_id
    left join cmo_grievance_category_master cgcm on gm.grievance_category = cgcm.grievance_cat_id
) table0
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS grv_assigned
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'
      AND csog.status IN (8,9,11,12,14,15,16,17,4)
    GROUP BY csog.admin_user_id 
) table1 ON table0.admin_user_id = table1.admin_user_id 
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS bnft_prvd
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id = 1
    GROUP BY csog.admin_user_id
) table2 ON table2.admin_user_id = table0.admin_user_id 
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS action_taken
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id IN (5,9)
    GROUP BY csog.admin_user_id
) table3 ON table0.admin_user_id = table3.admin_user_id
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS not_elgbl
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,9,11,12,16,14,15,17) 
      AND csog.closure_reason_id NOT IN (1,5,9)
    GROUP BY csog.admin_user_id
) table4 ON table0.admin_user_id = table4.admin_user_id
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS total_received
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status IN (4,11,16,14,15,17) 
    GROUP BY csog.admin_user_id
) table5 ON table0.admin_user_id = table5.admin_user_id
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - csog.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM cat_sub_offc_griv csog
    JOIN grievance_lifecycle glc ON glc.grievance_id = csog.grievance_id
    WHERE glc.grievance_status = 8
      AND NOT EXISTS (
          SELECT 1
          FROM grievance_lifecycle glc2
          WHERE glc2.grievance_id = glc.grievance_id
            AND glc2.grievance_status = 9
      )
      AND csog.grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
    GROUP BY csog.admin_user_id
) table6 ON table0.admin_user_id = table6.admin_user_id 
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS atr_review
    FROM cat_sub_offc_griv csog
    WHERE grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'  
      AND csog.status = 10
    GROUP BY csog.admin_user_id
) table7 ON table0.admin_user_id = table7.admin_user_id
WHERE table0.office_id = 3 AND table0.suboffice_id = 4 and table0.grievance_cat_id in (1,4,10)
GROUP BY 
	table0.grievance_cat_id,
  	table0.grievance_category_desc,
    table0.admin_user_id, 
    table0.office_id, 
    table0.suboffice_id, 
    table0.official_name, 
    table0.suboffice_name;
    
   
   
   
   
   
   
   
 select * from admin_user_details aud;