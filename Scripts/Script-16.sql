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
    apm.office_id;     --grievance forwarded
   
    
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
    gm.assigned_to_office_id;    -- grievance pending with hods    
   
    
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
    apm.office_id;     --atr received
            

select 
	count(distinct grievance_id) as benefit_provided,
	apm.office_id
from
    grievance_master gm
join admin_position_master apm on
	apm.position_id = gm.assigned_to_office_id 
where 
	gm.closure_reason_id = 1
group by 
	apm.office_id ;           --benefit provided
    

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
	apm.office_id ;                  --matter taken up
	
    
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
    co.assigned_by_office_id;       -- total disposed
    
    
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
    ar.assigned_by_office_id;   		-- average days taken
   
   
   

 SELECT 
    table1.office_id,
    table1.benefit_provided,
    table2.mater_taken_up,
    (table1.benefit_provided / (table1.benefit_provided + table2.mater_taken_up ) * 100.0) AS BSP_percentage
FROM 
    (SELECT 
        apm.office_id,
        COUNT(DISTINCT gm.grievance_id) AS benefit_provided
    FROM
        grievance_master gm
    JOIN 
        admin_position_master apm ON apm.position_id = gm.assigned_to_office_id 
    WHERE 
        gm.closure_reason_id = 1
    GROUP BY 
        apm.office_id) AS table1
JOIN 
    (SELECT 
        apm.office_id,
        COUNT(DISTINCT gm.grievance_id) AS mater_taken_up
    FROM
        grievance_master gm
    JOIN 
        admin_position_master apm ON apm.position_id = gm.assigned_to_office_id 
    WHERE 
        gm.closure_reason_id IN (5, 9)
    GROUP BY 
        apm.office_id) AS table2
ON 
    table1.office_id = table2.office_id;
   
   

SELECT 
    table1.office_id,
    table1.office_name,
    COALESCE(table2.grv_frwd, 0) + COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS grievance_forwarded,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_recieved_count,
    COALESCE(table5.total_disposed, 0) AS total_disposed,
    COALESCE(table6.pending_with_hod, 0) AS atr_pending,
    COALESCE(table10.days_diff, 0) AS average_resolution_days,
    COALESCE(table11.benefit_provided, 0) AS benefit_provided,
    COALESCE(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up) * 100, 0) AS BSP_percentage,
    -- Performance Calculation using CASE
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
    -- Grievance forwarded
    LEFT OUTER JOIN (
        SELECT 
            COUNT(DISTINCT grievance_id) AS grv_frwd,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        GROUP BY
            apm.office_id
    ) table2 ON table1.office_id = table2.office_id
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
    ) table3 ON table1.office_id = table3.office_id
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
    ) table5 ON table1.office_id = table5.assigned_by_office_id
    -- Pending with HoD
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
    ) table6 ON table1.office_id = table6.assigned_to_office_id
    -- Average resolution days
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
    ) table10 ON table10.assigned_by_office_id = table1.office_id
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
    ) table11 ON table1.office_id = table11.office_id
    -- Matter taken up
    LEFT OUTER JOIN (
        SELECT 
            COUNT(DISTINCT grievance_id) AS mater_taken_up,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_office_id
        WHERE
            gm.closure_reason_id IN (5,9)
        GROUP BY
            apm.office_id
    ) table12 ON table1.office_id = table12.office_id
-- Order the results by multiple columns in descending order
ORDER BY 
    grievance_forwarded DESC,
    atr_recieved_count DESC,
    total_disposed DESC,
    atr_pending DESC,
    average_resolution_days DESC,
    benefit_provided DESC,
    BSP_percentage DESC,													-- hods table grievance
    performance DESC;

select
    table1.office_id,
    table1.office_name,
--    coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
    coalesce(table2.grv_recvd,0) as grievances_received,
    coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
    coalesce(table5.total_disposed,0) as grievances_disposed,
    coalesce(table6.pending_with_hod,0) as grievances_pending,
    coalesce(table10.days_diff,0) as average_resolved_days,
    coalesce(table11.benefit_provided,0) as benefit_provided,
    coalesce(table12.mater_taken_up,0) as mater_taken_up,
--    coalesce(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100,0) AS BSP_percentage,
    coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER),0) AS BSP_percentage
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
        -- grv received
    left outer join(
        select
            count(distinct grievance_id) as grv_recvd,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status = 1
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
			apm.position_id = gm.assigned_to_office_id 
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
		    grievances_received DESC,
		    atr_recieved_count DESC,
		    grievances_disposed DESC,
		    grievances_pending DESC,
		    average_resolved_days DESC,
		    benefit_provided DESC,
		    BSP_percentage desc;									-- Individual Benefit Scheme Wise Disposed Grievances
		    
		   
		    
SELECT
    table1.office_id,
    table1.office_name,
    COALESCE(table2.grv_frwd, 0) + COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS grievance_forwarded,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_recieved_count,
    COALESCE(table5.total_disposed, 0) AS total_disposed,
    COALESCE(table6.pending_with_hod, 0) AS atr_pending,
    COALESCE(table10.days_diff, 0) AS average_resolution_days,
    COALESCE(table11.benefit_provided, 0) AS benefit_provided,
    COALESCE(table12.mater_taken_up, 0) AS mater_taken_up,
    COALESCE(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER), 0) AS BSP_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
FROM
    (
        SELECT
            com.office_id,
            com.office_name,
--            gm.ssm_id  -- Assuming ssm_id is here
        FROM
            cmo_office_master com
        WHERE
            com.office_category = 2
--            AND gm.ssm_id = 5  -- Filtering for ssm_id = 5
    ) table1
    -- grv frwded
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS grv_frwd,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_position
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        GROUP BY
            apm.office_id
    ) table2 ON
        table1.office_id = table2.office_id
    -- atr recvd
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS atr_recvd,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.updated_by_position
        WHERE
            gm.status = 14
        GROUP BY
            apm.office_id
    ) table3 ON
        table1.office_id = table3.office_id
    -- total disposed
    LEFT OUTER JOIN (
        SELECT
            COUNT(1) AS total_disposed,
            co.assigned_by_office_id
        FROM
            grievance_master gm
        JOIN atr_submitted_max_records_clone co ON
            co.grievance_id = gm.grievance_id
        WHERE
            gm.status = 15
        GROUP BY
            co.assigned_by_office_id
    ) table5 ON
        table1.office_id = table5.assigned_by_office_id
    -- grv pending with hod
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS pending_with_hod,
            gm.assigned_to_office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_position
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        GROUP BY
            gm.assigned_to_office_id
    ) table6 ON
        table1.office_id = table6.assigned_to_office_id
    -- average days for grievance
    LEFT OUTER JOIN (
        SELECT
            ar.assigned_by_office_id,
            EXTRACT (day FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
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
    ) table10 ON
        table10.assigned_by_office_id = table1.office_id
    -- benefit provided
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS benefit_provided,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_office_id
        WHERE
            gm.closure_reason_id = 1
        GROUP BY
            apm.office_id
    ) table11 ON
        table1.office_id = table11.office_id
    -- matter taken up
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT grievance_id) AS mater_taken_up,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_office_id
        WHERE
            gm.closure_reason_id IN (5, 9)
        GROUP BY
            apm.office_id
    ) table12 ON
        table1.office_id = table12.office_id
ORDER BY
    grievance_forwarded DESC,
    atr_recieved_count DESC,
    total_disposed DESC,
    atr_pending DESC,
    average_resolution_days DESC,
    benefit_provided DESC,
    BSP_percentage DESC,
    performance DESC;

   
SELECT
    table1.office_id,
    table1.office_name,
    table13.individual_scheme_id,
    table13.grievance_category_desc,
    COALESCE(table2.grv_frwd, 0) + COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS grievance_forwarded,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_recieved_count,
    COALESCE(table5.total_disposed, 0) AS total_disposed,
    COALESCE(table6.pending_with_hod, 0) AS atr_pending,
    COALESCE(table10.days_diff, 0) AS average_resolution_days,
    COALESCE(table11.benefit_provided, 0) AS benefit_provided,
    COALESCE(table12.mater_taken_up, 0) AS mater_taken_up,
    COALESCE(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER), 0) AS BSP_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
FROM
    (
        SELECT
            com.office_id,
            com.office_name
        FROM
            cmo_office_master com
        WHERE
            com.office_category = 2
    ) table1
    -- grv forwarded
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT gm.grievance_id) AS grv_frwd,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_position
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
--            AND gm.ssm_id = 5  -- Filtering by ssm_id = 5
        GROUP BY
            apm.office_id
    ) table2 ON
        table1.office_id = table2.office_id
    -- atr received
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT gm.grievance_id) AS atr_recvd,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.updated_by_position
        WHERE
            gm.status = 14
--            AND gm.ssm_id = 5  -- Filtering by ssm_id = 5
        GROUP BY
            apm.office_id
    ) table3 ON
        table1.office_id = table3.office_id
    -- total disposed
    LEFT OUTER JOIN (
        SELECT
            COUNT(1) AS total_disposed,
            co.assigned_by_office_id
        FROM
            grievance_master gm
        JOIN atr_submitted_max_records_clone co ON
            co.grievance_id = gm.grievance_id
        WHERE
            gm.status = 15
--            AND gm.ssm_id = 5  -- Filtering by ssm_id = 5
        GROUP BY
            co.assigned_by_office_id
    ) table5 ON
        table1.office_id = table5.assigned_by_office_id
    -- grv pending with hod
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT gm.grievance_id) AS pending_with_hod,
            gm.assigned_to_office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_position
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
--            AND gm.ssm_id = 5  -- Filtering by ssm_id = 5
        GROUP BY
            gm.assigned_to_office_id 
    ) table6 ON
        table1.office_id = table6.assigned_to_office_id
    -- average days for grievance
    LEFT OUTER JOIN (
        SELECT
            ar.assigned_by_office_id,
            EXTRACT (day FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
        FROM
            atr_submitted_max_records_clone ar,
            recvd_from_cmo_max_clone_view co,
            grievance_master gm
        WHERE
            ar.grievance_id = co.grievance_id
            AND ar.grievance_id = gm.grievance_id
            AND co.assigned_to_office_id = ar.assigned_by_office_id
--            AND gm.ssm_id = 5  -- Filtering by ssm_id = 5
        GROUP BY
            ar.assigned_by_office_id
    ) table10 ON
        table10.assigned_by_office_id = table1.office_id
    -- benefit provided
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT gm.grievance_id) AS benefit_provided,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_office_id
        WHERE
            gm.closure_reason_id = 1
--            AND gm.ssm_id = 5  -- Filtering by ssm_id = 5
        GROUP BY
            apm.office_id
    ) table11 ON
        table1.office_id = table11.office_id
    -- matter taken up
    LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT gm.grievance_id) AS mater_taken_up,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON
            apm.position_id = gm.assigned_to_office_id
        WHERE
            gm.closure_reason_id IN (5, 9)
--            AND gm.ssm_id = 5  -- Filtering by ssm_id = 5
        GROUP BY
            apm.office_id
    ) table12 ON
        table1.office_id = table12.office_id
        LEFT OUTER JOIN (
        SELECT
            COUNT(DISTINCT gm.grievance_category) AS individual_scheme_id,
            cgcm.grievance_category_desc,
            cgcm.parent_office_id
        FROM
            grievance_master gm 
        JOIN cmo_grievance_category_master cgcm ON
            cgcm.parent_office_id = gm.assigned_to_office_id
        WHERE
            cgcm.benefit_scheme_type = 1 and cgcm.status = 1
        GROUP BY
            cgcm.parent_office_id,
            cgcm.grievance_category_desc
    ) table13 ON
        table13.parent_office_id = table1.office_id 
ORDER by
	individual_scheme_id desc,
	grievance_category_desc desc,
    grievance_forwarded DESC,
    atr_recieved_count DESC,
    total_disposed DESC,
    atr_pending DESC,
    average_resolution_days DESC,
    benefit_provided DESC,
    BSP_percentage DESC,
    performance DESC;



select 
--	table1.office_id,
	table1.individual_scheme_id,
	table1.grievance_category_desc,
	coalesce(table2.grv_recvd,0) as grievances_received,
	coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
	coalesce(table5.total_disposed,0) as grievances_disposed,
	coalesce(table6.pending_with_hod,0) as grievances_pending,
	coalesce(table10.days_diff,0) as average_resolved_days,
	coalesce(table11.benefit_provided,0) as benefit_provided,
	coalesce(table12.mater_taken_up,0) as mater_taken_up,
	coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER),0) AS BSP_percentage
	FROM
	    (
	    select
	        COUNT(DISTINCT gm.grievance_category) AS individual_scheme_id,
	        cgcm.grievance_category_desc,
	        cgcm.parent_office_id
	     FROM
	        grievance_master gm 
	    JOIN cmo_grievance_category_master cgcm ON
	        cgcm.parent_office_id = gm.assigned_to_office_id
	    WHERE
	        cgcm.benefit_scheme_type = 1 and cgcm.status = 1
	    GROUP BY
	        cgcm.parent_office_id,
	        cgcm.grievance_category_desc
		) table1 
	    -- grv received
		left outer join(
	    select
	        count(distinct grievance_id) as grv_recvd,
	        apm.office_id
	    from
	        grievance_master gm
	    join admin_position_master apm on
	        apm.position_id = gm.assigned_to_position
	    where
	    gm.status = 1
	    group by
	        apm.office_id) table2
	        on
	    table1.parent_office_id = table2.office_id
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
	    table1.parent_office_id = table3.office_id
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
	    table1.parent_office_id = table5.assigned_by_office_id	
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
	    table1.parent_office_id = table6.assigned_to_office_id
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
	    table10.assigned_by_office_id = table1.parent_office_id
	    -- benifit provided
		left outer join (
		select 
	        count(distinct grievance_id) as benefit_provided,
	        apm.office_id
	    from
	        grievance_master gm
	    join admin_position_master apm on
	        apm.position_id = gm.assigned_to_office_id 
	    where 
	        gm.closure_reason_id = 1
	    group by 
	        apm.office_id) table11
	    on
	    table1.parent_office_id = table11.office_id
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
	    table1.parent_office_id = table12.office_id
	    ORDER BY 
	    	individual_scheme_id desc,
	    	grievance_category_desc desc,
	        grievances_received DESC,
	        atr_recieved_count DESC,
	        grievances_disposed DESC,
	        grievances_pending DESC,
	        average_resolved_days DESC,
	        benefit_provided DESC,
	        BSP_percentage desc;					-- individual_scheme

	                        
select * from cmo_grievance_category_master cgcm where cgcm.benefit_scheme_type = 1 and cgcm.status = 1;
	        
	        
select
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
ORDER BY
    parent_office_id DESC,
    grievance_category_desc DESC,
    grievances_received DESC,
    atr_recieved_count DESC,
    grievances_disposed DESC,
    grievances_pending DESC,
    average_resolved_days DESC,
    benefit_provided DESC,
    BSP_percentage DESC;						-- individual scheme

    
    select
                table1.office_id,
                table1.office_name,
                coalesce(table2.grv_recvd,0) as grievances_received,
                coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
                coalesce(table5.total_disposed,0) as grievances_disposed,
                coalesce(table6.pending_with_hod,0) as grievances_pending,
                coalesce(table10.days_diff,0) as average_resolved_days,
                coalesce(table11.benefit_provided,0) as benefit_provided,
                coalesce(table12.mater_taken_up,0) as mater_taken_up,
                coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER),0) AS BSP_percentage
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
                    -- grv received
                left outer join(
                    select
                        count(distinct grievance_id) as grv_recvd,
                        apm.office_id
                    from
                        grievance_master gm
                    join admin_position_master apm on
                        apm.position_id = gm.assigned_to_position
                    where
                    gm.status = 1
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
                        apm.position_id = gm.assigned_to_office_id 
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
                        grievances_received DESC,
                        atr_recieved_count DESC,
                        grievances_disposed DESC,
                        grievances_pending DESC,
                        average_resolved_days DESC,
                        benefit_provided DESC,
                        BSP_percentage desc;
                        
 
                       
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
                            RIGHT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                            WHERE
                                cgcm.benefit_scheme_type = 1 
                                AND cgcm.status = 1 
                                AND gm.grievance_source = 5
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
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        WHERE
                            gm.status = 1 
                            AND gm.grievance_source = 5
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
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        WHERE
                            gm.status = 14
                            AND gm.grievance_source = 5
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table3 ON table1.grievance_cat_id = table3.grievance_cat_id
                    -- Total disposed
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT grievance_id) AS total_disposed,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        WHERE
                            gm.status = 15
                            AND gm.grievance_source = 5
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
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        WHERE
                            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
                            AND gm.grievance_source = 5
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table5 ON table1.grievance_cat_id = table5.grievance_cat_id
                    -- Average days for grievance
                    LEFT OUTER JOIN (
                        SELECT
                            cgcm.grievance_cat_id,
                            COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff
                        FROM
                            atr_submitted_max_records_clone ar,
                            recvd_from_cmo_max_clone_view co,
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category 
                        WHERE
                            ar.grievance_id = co.grievance_id
                            AND ar.grievance_id = gm.grievance_id
                            AND co.grievance_id = gm.grievance_id
                            AND gm.grievance_source = 5
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table6 ON table1.grievance_cat_id = table6.grievance_cat_id
                    -- Benefit provided
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT grievance_id) AS benefit_provided,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        WHERE
                            gm.closure_reason_id = 1
                            AND gm.grievance_source = 5
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
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        WHERE
                            gm.closure_reason_id IN (5, 9) 
                            AND gm.grievance_source = 5
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table8 ON table1.grievance_cat_id = table8.grievance_cat_id
                    ORDER BY
                        grievance_category_desc ASC;						--- indivitual scheme chart 29 --
                     
                        
                        
                        
                        
SELECT
    table1.grievance_category_desc,
    table1.grievance_cat_id,
    COALESCE(table2.grv_recvd, 0) AS grievances_received,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table4.total_disposed, 0) AS atr_received_count,
    COALESCE(table4.total_disposed, 0) AS grievances_disposed,
    COALESCE(table5.pending_with_hod, 0) AS grievances_pending,
    COALESCE(table6.days_diff, 0) AS days_diff,
    COALESCE(table7.benefit_provided, 0) AS benefit_provided,
    COALESCE(table8.matter_taken_up, 0) AS matter_taken_up,
    COALESCE(
        CASE 
            WHEN (COALESCE(table7.benefit_provided, 0) + COALESCE(table8.matter_taken_up, 0)) > 0 
            THEN ROUND((COALESCE(table7.benefit_provided, 0)::FLOAT / NULLIF(COALESCE(table7.benefit_provided, 0) + COALESCE(table8.matter_taken_up, 0), 0)) * 100)
            ELSE 0
        END, 0
    ) AS bsp_percentage
FROM
    (
        SELECT
            cgcm.grievance_category_desc,
            cgcm.grievance_cat_id
        FROM
            cmo_grievance_category_master cgcm
        WHERE
            cgcm.benefit_scheme_type = 1 
            AND cgcm.status = 1
    ) table1
-- Grievances received
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS grv_recvd,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE
        gm.status = 1 
        AND gm.grievance_source = 5
        AND cdm.district_id = 15
    GROUP BY
        cgcm.grievance_cat_id
) table2 ON table1.grievance_cat_id = table2.grievance_cat_id
-- ATR received
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS atr_recvd,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE
        gm.status = 14
        AND gm.grievance_source = 5
        AND cdm.district_id = 15
    GROUP BY
        cgcm.grievance_cat_id
) table3 ON table1.grievance_cat_id = table3.grievance_cat_id
-- Total disposed
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS total_disposed,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE
        gm.status = 15
        AND gm.grievance_source = 5
        AND cdm.district_id = 15
    GROUP BY
        cgcm.grievance_cat_id
) table4 ON table1.grievance_cat_id = table4.grievance_cat_id
-- Grievances pending with HOD
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS pending_with_hod,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        AND gm.grievance_source = 5
        AND cdm.district_id = 15
    GROUP BY
        cgcm.grievance_cat_id
) table5 ON table1.grievance_cat_id = table5.grievance_cat_id
-- Average days for grievance
LEFT OUTER JOIN (
    SELECT
        cgcm.grievance_cat_id,
        COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff
    FROM
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
        AND co.grievance_id = gm.grievance_id
        AND gm.grievance_source = 5
        AND cdm.district_id = 15
    GROUP BY
        cgcm.grievance_cat_id
) table6 ON table1.grievance_cat_id = table6.grievance_cat_id
-- Benefit provided
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS benefit_provided,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE
        gm.closure_reason_id = 1
        AND gm.grievance_source = 5
        AND cdm.district_id = 15
    GROUP BY
        cgcm.grievance_cat_id
) table7 ON table1.grievance_cat_id = table7.grievance_cat_id
-- Matter taken up
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS matter_taken_up,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE
        gm.closure_reason_id IN (5, 9)
        AND gm.grievance_source = 5
        AND cdm.district_id = 15
    GROUP BY
        cgcm.grievance_cat_id
) table8 ON table1.grievance_cat_id = table8.grievance_cat_id
ORDER BY
    table1.grievance_category_desc ASC;			--- indivitual sceme with cmo --
    
    
    
    
    WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable,
    cast(SUM(k.total_general_count) as INTEGER) as total_general_count,
    cast(SUM(k.total_sc_count) as INTEGER) as total_sc_count,
    cast(SUM(k.total_st_count) as INTEGER) as total_st_count,
    cast(SUM(k.total_obc_a_count) as INTEGER) as total_obc_a_count,
    cast(SUM(k.total_obc_b_count) as INTEGER) as total_obc_b_count,
    cast(SUM(k.total_not_disclosed_count) as INTEGER) as total_not_disclosed_count,
    cast(SUM(k.total_test_caste_count) as INTEGER) as total_test_caste_count,
    cast(sum(k.total_general_count_percentage) as integer) AS total_general_count_percentage,
    cast(sum(k.total_sc_count_percentage) as integer) AS total_sc_count_percentage,
    cast(sum(k.total_st_count_percentage) as integer) AS total_st_count_percentage,
    cast(sum(k.total_obc_a_count_percentage) as integer) AS total_obc_a_count_percentage,
    cast(sum(k.total_obc_b_count_percentage) as integer) AS total_obc_b_count_percentage,
    cast(sum(k.total_not_disclosed_count_percentage) as integer) AS total_not_disclosed_count_percentage,
    cast(sum(k.total_test_caste_count_percentage) as integer) AS total_test_caste_count_percentage,
    cast(SUM(k.grievances_received_hindu) as INTEGER) as grievances_received_hindu,
    cast(SUM(k.grievances_received_muslim) as INTEGER) as grievances_received_muslim,
    cast(SUM(k.grievances_received_christian) as INTEGER) as grievances_received_christian,
    cast(SUM(k.grievances_received_buddhist) as INTEGER) as grievances_received_buddhist,
    cast(SUM(k.grievances_received_sikh) as INTEGER) as grievances_received_sikh,
    cast(SUM(k.grievances_received_jain) as INTEGER) as grievances_received_jain,
    cast(SUM(k.grievances_received_other) as INTEGER) as grievances_received_other,
    cast(sum(k.grievances_received_not_known) as integer) AS grievances_received_not_known,
    cast(sum(k.grievances_received_test_religion) as integer) AS grievances_received_test_religion,
    cast(sum(k.grievances_received_hindu_percentage) as integer) AS grievances_received_hindu_percentage,
    cast(sum(k.grievances_received_muslim_percentage) as integer) AS grievances_received_muslim_percentage,
    cast(sum(k.grievances_received_christian_percentage) as integer) AS grievances_received_christian_percentage,
    cast(sum(k.grievances_received_buddhist_percentage) as integer) AS grievances_received_buddhist_percentage,
    cast(sum(k.grievances_received_sikh_percentage) as integer) AS grievances_received_sikh_percentage,
    cast(sum(k.grievances_received_jain_percentage) as integer) AS grievances_received_jain_percentage,
    cast(sum(k.grievances_received_other_percentage) as integer) AS grievances_received_other_percentage,
    cast(sum(k.grievances_received_not_known_percentage) as integer) AS grievances_received_not_known_percentage,
    cast(sum(k.grievances_received_test_religion_percentage) as integer) AS grievances_received_test_religion_percentage
FROM (
    SELECT  
        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
        COUNT(1) AS total_grievance,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        COUNT(CASE WHEN gm.applicant_caste = 1 THEN 1 END) AS total_general_count,
        COUNT(CASE WHEN gm.applicant_caste = 2 THEN 1 END) AS total_sc_count,
        COUNT(CASE WHEN gm.applicant_caste = 3 THEN 1 END) AS total_st_count,
        COUNT(CASE WHEN gm.applicant_caste = 4 THEN 1 END) AS total_obc_a_count,
        COUNT(CASE WHEN gm.applicant_caste = 5 THEN 1 END) AS total_obc_b_count,
        COUNT(CASE WHEN gm.applicant_caste = 6 THEN 1 END) AS total_not_disclosed_count,
        COUNT(CASE WHEN gm.applicant_caste = 7 THEN 1 END) AS total_test_caste_count,
        COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_hindu,
        COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_muslim,
        COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_christian,
        COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_buddhist,
        COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_sikh,
        COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_jain,
        COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_other,
        COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_not_known,
        COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_test_religion,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_hindu_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_muslim_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_christian_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_buddhist_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_sikh_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_jain_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_other_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_not_known_percentage,
        cast(COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_test_religion_percentage,
        COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_general_count,
        COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_sc_count,
        COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_st_count,
        COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_a_count,
        COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_b_count,
        COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_not_disclosed_count,
        COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_test_caste_count,
        cast(COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_general_count_percentage,
        cast(COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_sc_count_percentage,
        cast(COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_st_count_percentage,
        cast(COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_a_count_percentage,
        cast(COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_b_count_percentage,
        cast(COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_not_disclosed_count_percentage,
        cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage,
        lu.assigned_to_office_id 
    FROM 
        lastupdates lu
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = lu.grievance_id 
    LEFT JOIN 
        cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
    WHERE 
        lu.rn = 1 
        AND lu.assigned_to_office_id = {office_id}
        AND gm.status IS NOT NULL  
        AND gm.grievance_source = 0
        AND (gm.status = 15 OR gm.assigned_to_office_id = {office_id}) 
    GROUP BY 
        lu.assigned_to_office_id
) k;										-- hod entry count --







SELECT
                    COALESCE(tbl1.grv_frwd, 0) AS grievance_forwarded,
                    COALESCE(tbl2.atr_sent, 0) AS atr_received_count,
                    CASE 
                        WHEN COALESCE(tbl1.grv_frwd, 0) - COALESCE(tbl2.atr_sent, 0) > 0 THEN COALESCE(tbl1.grv_frwd, 0) - COALESCE(tbl2.atr_sent, 0)
                        ELSE 0 
                    END AS atr_pending,
                    tbl1.assigned_to_position,
                    tbl1.suboffice_name,
                    COALESCE(tbl3.days_diff, 0) AS average_resolution_days,
                    CASE
                        WHEN COALESCE(tbl3.days_diff, 0) <= 7 THEN 'Good'
                        WHEN COALESCE(tbl3.days_diff, 0) > 7 AND COALESCE(tbl3.days_diff, 0) <= 30 THEN 'Average'
                        ELSE 'Poor'
                    END AS performance
                FROM
                    (
                        WITH lastupdates AS (
                            SELECT 
                                grievance_lifecycle.grievance_id,
                                grievance_lifecycle.grievance_status,
                                grievance_lifecycle.assigned_on,
                                grievance_lifecycle.assigned_to_office_id,
                                grievance_lifecycle.assigned_to_position,
                                ROW_NUMBER() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id 
                                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                            FROM grievance_lifecycle
                            WHERE grievance_lifecycle.grievance_status = 7
                        )
                        SELECT 
                            COUNT(DISTINCT lu.grievance_id) AS grv_frwd,
                            lu.assigned_to_position,
                            csom.suboffice_name
                        FROM lastupdates lu
                        LEFT JOIN admin_position_master apm 
                            ON apm.position_id = lu.assigned_to_position
                        LEFT JOIN cmo_sub_office_master csom 
                            ON csom.suboffice_id = apm.sub_office_id
                        WHERE lu.rn = 1 
                        AND lu.assigned_to_position IN (
                            SELECT DISTINCT position_id 
                            FROM admin_position_master 
                            WHERE office_id = {office_id}
                                AND role_master_id = 7
                        ) 
                        GROUP BY lu.assigned_to_position, csom.suboffice_name
                    ) tbl1
                LEFT JOIN 
                    (
                        WITH lastupdates AS (
                            SELECT 
                                grievance_lifecycle.grievance_id,
                                grievance_lifecycle.grievance_status,
                                grievance_lifecycle.assigned_on,
                                grievance_lifecycle.assigned_to_office_id,
                                grievance_lifecycle.assigned_by_position,
                                ROW_NUMBER() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_by_office_id 
                                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                            FROM grievance_lifecycle
                            WHERE grievance_lifecycle.grievance_status = 11
                        )
                        SELECT 
                            COUNT(DISTINCT lu.grievance_id) AS atr_sent,
                            lu.assigned_by_position,
                            csom.suboffice_name
                        FROM lastupdates lu
                        LEFT JOIN admin_position_master apm 
                            ON apm.position_id = lu.assigned_by_position
                        LEFT JOIN cmo_sub_office_master csom 
                            ON csom.suboffice_id = apm.sub_office_id
                        WHERE lu.rn = 1 
                        AND lu.assigned_by_position IN (
                            SELECT DISTINCT position_id 
                            FROM admin_position_master 
                            WHERE office_id = {office_id}
                                AND role_master_id = 7
                        ) 
                        GROUP BY lu.assigned_by_position, csom.suboffice_name
                    ) tbl2
                ON tbl2.assigned_by_position = tbl1.assigned_to_position
                AND tbl2.suboffice_name = tbl1.suboffice_name
                LEFT JOIN 
                    (
                        SELECT 
                            lu.assigned_by_position,
                            csom.suboffice_name,
                            COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff
                        FROM grievance_lifecycle lu
                        JOIN atr_submitted_max_records_clone ar 
                            ON ar.grievance_id = lu.grievance_id
                        JOIN recvd_from_cmo_max_clone_view co 
                            ON co.grievance_id = lu.grievance_id
                        JOIN admin_position_master apm 
                            ON apm.position_id = lu.assigned_by_position
                        JOIN cmo_sub_office_master csom 
                            ON csom.suboffice_id = apm.sub_office_id
                        WHERE lu.grievance_status = 11 
                        AND lu.assigned_by_position IN (
                            SELECT DISTINCT position_id 
                            FROM admin_position_master 
                            WHERE office_id = {office_id}
                                AND role_master_id = 7
                        ) 
                        GROUP BY lu.assigned_by_position, csom.suboffice_name
                    ) tbl3
                ON tbl3.assigned_by_position = tbl1.assigned_to_position
                AND tbl3.suboffice_name = tbl1.suboffice_name
                ORDER BY tbl1.suboffice_name; -- chart id 14 --
                
                
                SELECT
                        table1.grievance_category_desc,
                        table1.grievance_cat_id,
                        COALESCE(table2.grv_recvd, 0) AS grievances_received,
                        COALESCE(table3.atr_recvd, 0) + COALESCE(table4.total_disposed, 0) AS atr_received_count,
                        COALESCE(table4.total_disposed, 0) AS grievances_disposed,
                        COALESCE(table5.pending_with_hod, 0) AS grievances_pending,
                        COALESCE(table6.days_diff, 0) AS days_diff,
                        COALESCE(table7.benefit_provided, 0) AS benefit_provided,
                        COALESCE(table8.matter_taken_up, 0) AS matter_taken_up,
                        COALESCE(
                            CASE 
                                WHEN (COALESCE(table7.benefit_provided, 0) + COALESCE(table8.matter_taken_up, 0)) > 0 
                                THEN ROUND((COALESCE(table7.benefit_provided, 0)::FLOAT / NULLIF(COALESCE(table7.benefit_provided, 0) + COALESCE(table8.matter_taken_up, 0), 0)) * 100)
                                ELSE 0
                            END, 0
                        ) AS bsp_percentage
                    FROM
                        (
                            SELECT
                                cgcm.grievance_category_desc,
                                cgcm.grievance_cat_id
                            FROM
                                cmo_grievance_category_master cgcm
                            WHERE
                                cgcm.benefit_scheme_type = 1 
                                AND cgcm.status = 1
                        ) table1
                    -- Grievances received
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT gm.grievance_id) AS grv_recvd,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
                        WHERE
                            gm.status = 1 
                            AND gm.grievance_source = {ssm_id}
                             {dist_id}
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table2 ON table1.grievance_cat_id = table2.grievance_cat_id
                    -- ATR received
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT gm.grievance_id) AS atr_recvd,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
                        WHERE
                            gm.status = 14
                            AND gm.grievance_source = {ssm_id}
                             {dist_id}
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table3 ON table1.grievance_cat_id = table3.grievance_cat_id
                    -- Total disposed
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT gm.grievance_id) AS total_disposed,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
                        WHERE
                            gm.status = 15
                            AND gm.grievance_source = {ssm_id}
                             {dist_id}
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table4 ON table1.grievance_cat_id = table4.grievance_cat_id
                    -- Grievances pending with HOD
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT gm.grievance_id) AS pending_with_hod,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
                        WHERE
                            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
                            AND gm.grievance_source = {ssm_id}
                             {dist_id}
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table5 ON table1.grievance_cat_id = table5.grievance_cat_id
                    -- Average days for grievance
                    LEFT OUTER JOIN (
                        SELECT
                            cgcm.grievance_cat_id,
                            COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff
                        FROM
                            atr_submitted_max_records_clone ar,
                            recvd_from_cmo_max_clone_view co,
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
                        WHERE
                            ar.grievance_id = co.grievance_id
                            AND ar.grievance_id = gm.grievance_id
                            AND co.grievance_id = gm.grievance_id
                            AND gm.grievance_source = {ssm_id}
                             {dist_id}
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table6 ON table1.grievance_cat_id = table6.grievance_cat_id
                    -- Benefit provided
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT gm.grievance_id) AS benefit_provided,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
                        WHERE
                            gm.closure_reason_id = 1
                            AND gm.grievance_source = {ssm_id}
                             {dist_id}
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table7 ON table1.grievance_cat_id = table7.grievance_cat_id
                    -- Matter taken up
                    LEFT OUTER JOIN (
                        SELECT
                            COUNT(DISTINCT gm.grievance_id) AS matter_taken_up,
                            cgcm.grievance_cat_id
                        FROM
                            grievance_master gm
                        JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
                        JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
                        WHERE
                            gm.closure_reason_id IN (5, 9)
                            AND gm.grievance_source = {ssm_id}
                             {dist_id}
                        GROUP BY
                            cgcm.grievance_cat_id
                    ) table8 ON table1.grievance_cat_id = table8.grievance_cat_id
                    ORDER BY
                        table1.grievance_category_desc ASC; ----chart id 29 ----
                        
                        
                        
                        
                        
SELECT
    table1.grievance_category_desc,
    table1.grievance_cat_id,
    COALESCE(table2.grv_recvd, 0) AS grievances_received,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table4.total_disposed, 0) AS atr_received_count,
    COALESCE(table4.total_disposed, 0) AS grievances_disposed,
    COALESCE(table5.pending_with_hod, 0) AS grievances_pending,
    COALESCE(table6.days_diff, 0) AS days_diff,
    COALESCE(table7.benefit_provided, 0) AS benefit_provided,
    COALESCE(table8.matter_taken_up, 0) AS matter_taken_up,
    COALESCE(
        CASE 
            WHEN (COALESCE(table7.benefit_provided, 0) + COALESCE(table8.matter_taken_up, 0)) > 0 
            THEN ROUND((COALESCE(table7.benefit_provided, 0)::FLOAT / NULLIF(COALESCE(table7.benefit_provided, 0) + COALESCE(table8.matter_taken_up, 0), 0)) * 100)
            ELSE 0
        END, 0
    ) AS bsp_percentage
FROM
    (
        SELECT
            cgcm.grievance_category_desc,
            cgcm.grievance_cat_id
        FROM
            cmo_grievance_category_master cgcm
        WHERE
            cgcm.benefit_scheme_type = 1 
            AND cgcm.status = 1
    ) table1
-- Grievances received
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS grv_recvd,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    JOIN cmo_office_master com ON com.office_id = gm.assigned_to_position
    WHERE
        gm.status = 1 
        AND gm.grievance_source = 5
        AND com.office_id = 53
--         {dist_id}
    GROUP BY
        cgcm.grievance_cat_id
) table2 ON table1.grievance_cat_id = table2.grievance_cat_id
-- ATR received
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS atr_recvd,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    JOIN cmo_office_master com ON com.office_id = gm.assigned_to_position
    WHERE
        gm.status = 14
        AND gm.grievance_source = 5
        AND com.office_id = 53
--         {dist_id}
    GROUP BY
        cgcm.grievance_cat_id
) table3 ON table1.grievance_cat_id = table3.grievance_cat_id
-- Total disposed
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS total_disposed,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    JOIN cmo_office_master com ON com.office_id = gm.assigned_to_position
    WHERE
        gm.status = 15
        AND gm.grievance_source = 5
        AND com.office_id = 53
--         {dist_id}
    GROUP BY
        cgcm.grievance_cat_id
) table4 ON table1.grievance_cat_id = table4.grievance_cat_id
-- Grievances pending with HOD
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS pending_with_hod,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    JOIN cmo_office_master com ON com.office_id = gm.assigned_to_position
    WHERE
        gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        AND gm.grievance_source = 5
        AND com.office_id = 53
--         {dist_id}
    GROUP BY
        cgcm.grievance_cat_id
) table5 ON table1.grievance_cat_id = table5.grievance_cat_id
-- Average days for grievance
LEFT OUTER JOIN (
    SELECT
        cgcm.grievance_cat_id,
        COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff
    FROM
        atr_submitted_max_records_clone ar,
        recvd_from_cmo_max_clone_view co,
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    JOIN cmo_office_master com ON com.office_id = gm.assigned_to_position
    WHERE
        ar.grievance_id = co.grievance_id
        AND ar.grievance_id = gm.grievance_id
        AND co.grievance_id = gm.grievance_id
        AND gm.grievance_source = 5
        AND com.office_id = 53
--         {dist_id}
    GROUP BY
        cgcm.grievance_cat_id
) table6 ON table1.grievance_cat_id = table6.grievance_cat_id
-- Benefit provided
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS benefit_provided,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    JOIN cmo_office_master com ON com.office_id = gm.assigned_to_position
    WHERE
        gm.closure_reason_id = 1
        AND gm.grievance_source = 5
        AND com.office_id = 53
--         {dist_id}
    GROUP BY
        cgcm.grievance_cat_id
) table7 ON table1.grievance_cat_id = table7.grievance_cat_id
-- Matter taken up
LEFT OUTER JOIN (
    SELECT
        COUNT(DISTINCT gm.grievance_id) AS matter_taken_up,
        cgcm.grievance_cat_id
    FROM
        grievance_master gm
    JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = gm.grievance_category
    JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
    JOIN cmo_office_master com ON com.office_id = gm.assigned_to_position
    WHERE
        gm.closure_reason_id IN (5, 9)
        AND gm.grievance_source = 5
        AND com.office_id = 53
--         {dist_id}
    GROUP BY
        cgcm.grievance_cat_id
) table8 ON table1.grievance_cat_id = table8.grievance_cat_id
ORDER BY
    table1.grievance_category_desc ASC;

   
--drop view if exists public.cat_offc_grievances;