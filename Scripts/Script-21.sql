select aupm.position_id, aud.official_name, aurm.role_master_name
            from admin_user_position_mapping aupm 
            inner join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
            inner join admin_position_master apm on apm.position_id = aupm.position_id 
            inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id;			-- chart id 13 step 1 Office Name With their Sub-Office --
           
            
 select gm.assigned_to_position,  count(1)  as  new_griev_count 
            from grievance_master gm 
            where exists (
                select 1 
                from grievance_lifecycle gl where gm.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 3 and gl.grievance_status in (3,5)  
            )  and gm.status in  (3,4,5,7,8,9,10,12,16,17)  and  gm.assigned_to_office_id = 3  group by gm.assigned_to_position; 	-- chart id 13 step 2 New Grievance Count --
            
            
 select gm.assigned_to_position,  count(1)  as  atr_recv_count 
            from grievance_master gm 
            where exists (
                select 1 
                from grievance_lifecycle gl where gm.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 3 and gl.grievance_status in (3,5)  
            )  and gm.status in (11,13)  and  gm.assigned_to_office_id = 3  group by gm.assigned_to_position; 			-- chart id 13 step 3 ATR Received Count--
            
            
            select gm.assigned_to_position,  count(1)  as  rtrn_atr_count 
            from grievance_master gm 
            where exists (
                select 1 
                from grievance_lifecycle gl where gm.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 3 and gl.grievance_status in (3,5)  
            )  and gm.status = 6  and  gm.assigned_to_office_id = 3  group by gm.assigned_to_position; 				-- chart id 13 step 4 ATR Return Count--
            
           
           
select * from (
    select csom.suboffice_name as office_name,
        Count(distinct gm.grievance_id) as per_hod_count 
    from grievance_master gm 
            inner join admin_position_master apm on apm.position_id = gm.assigned_to_position and apm.office_id = 0 and apm.sub_office_id is not null 
            inner join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id 
    where 
        gm.status  in (8,9,10,12)  group by csom.suboffice_name)q order by q.per_hod_count desc;     -- chart id 16 --
        
       
SELECT * 
FROM (
    SELECT 
        csom.suboffice_name AS office_name,
        COUNT(DISTINCT gm.grievance_id) AS per_hod_count 
    FROM 
        grievance_master gm 
    INNER JOIN admin_position_master apm 
        ON apm.position_id = gm.assigned_to_position 
        AND apm.sub_office_id IS NOT NULL 
    INNER JOIN cmo_sub_office_master csom  
        ON csom.suboffice_id = apm.sub_office_id 
    WHERE 
        gm.status IN (8, 9, 10, 12)
    GROUP BY 
        csom.suboffice_name
	) q 
	ORDER BY 
	    q.per_hod_count DESC;			-- chart 16 update --

	   
	   select 
            com1.office_name as to_office, 
            COUNT(distinct gl.grievance_id) as forwarded_grievances,
            COUNT(distinct gl2.grievance_id) as atr_recieved,
            COUNT(distinct gl.grievance_id) - COUNT(distinct gl2.grievance_id) as atr_pending
            from grievance_lifecycle gl inner join admin_position_master apm on gl.assigned_by_position = apm.position_id 
            inner join cmo_office_master com on com.office_id = apm.office_id 
            inner join admin_position_master apm1 on gl.assigned_to_position = apm1.position_id 
            inner join cmo_office_master com1 on com1.office_id = apm1.office_id 
            left join grievance_lifecycle gl2 on gl.grievance_id = gl2.grievance_id and gl2.grievance_status = 13  
            and gl2.assigned_to_position in (SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = 35)
            where gl.grievance_status = 5 and apm.office_id = 35
            group by  com1.office_name ;								-- chart id 8 --
            
            
            
            select com1.office_name as to_office, 
                COUNT(distinct gl.grievance_id) as recived_grievances,
                COUNT(distinct gl2.grievance_id) as atr_sent,
                COUNT(distinct gl.grievance_id) - COUNT(distinct gl2.grievance_id) as pending_with_me
                from grievance_lifecycle gl  inner join admin_position_master apm on gl.assigned_to_position = apm.position_id 
            inner join cmo_office_master com on com.office_id = apm.office_id 
            inner join admin_position_master apm1 on gl.assigned_by_position = apm1.position_id 
            inner join cmo_office_master com1 on com1.office_id = apm1.office_id 
            left join grievance_lifecycle gl2 on gl.grievance_id = gl2.grievance_id and gl2.grievance_status = 13
                    and gl2.assigned_by_position in (SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = 3)
            where gl.grievance_status = 5 and apm.office_id = 3
            group by  com1.office_name;										-- chart id 9 --
            
            
            
            
 SELECT
    COALESCE(tbl1.grv_frwd, 0) as grievance_forwarded,
    COALESCE(tbl2.atr_sent, 0) as atr_recieved_count,
    CASE 
        WHEN COALESCE(tbl1.grv_frwd, 0) - COALESCE(tbl2.atr_sent, 0) > 0 THEN COALESCE(tbl1.grv_frwd, 0) - COALESCE(tbl2.atr_sent, 0)
        ELSE 0 
    END AS atr_pending,
    tbl1.assigned_to_position,
    tbl1.suboffice_name,
--    0 as average_resolution_days,
    COALESCE(tbl3.days_diff, 0) AS average_resolution_days,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
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
                        grievance_lifecycle.assigned_by_position,
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
                    WHERE office_id = 35
                        AND role_master_id = 7
                ) 
        GROUP BY lu.assigned_to_position, csom.suboffice_name
    ) tbl1
LEFT OUTER JOIN 
    (
        WITH lastupdates AS (
            SELECT 
                grievance_lifecycle.grievance_id,
                grievance_lifecycle.grievance_status,
                grievance_lifecycle.assigned_on,
                grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_by_office_id,
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
              WHERE office_id = 35
                AND role_master_id = 7
          ) 
        GROUP BY lu.assigned_by_position, csom.suboffice_name
    ) tbl2
LEFT OUTER JOIN 
    (
        WITH lastupdates AS (
            SELECT 
                grievance_lifecycle.grievance_id,
                grievance_lifecycle.grievance_status,
                grievance_lifecycle.assigned_on,
                grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_by_office_id,
                ROW_NUMBER() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_by_office_id 
                                   ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            FROM grievance_lifecycle
            WHERE grievance_lifecycle.grievance_status = 11
        )
        SELECT 
            ar.assigned_by_office_id,
        	COALESCE(CAST(EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS INTEGER), 0) AS days_diff,
            lu.assigned_by_position,
            csom.suboffice_name
        FROM lastupdates lu,
        	atr_submitted_max_records_clone ar,
	        recvd_from_cmo_max_clone_view co,
	        grievance_master gm
	     WHERE
	        ar.grievance_id = co.grievance_id
	        AND ar.grievance_id = gm.grievance_id
	        AND co.assigned_to_office_id = ar.assigned_by_office_id
        LEFT JOIN admin_position_master apm 
            ON apm.position_id = lu.assigned_by_position
        LEFT JOIN cmo_sub_office_master csom 
            ON csom.suboffice_id = apm.sub_office_id
        WHERE lu.rn = 1 
          AND lu.assigned_by_position IN (
              SELECT DISTINCT position_id 
              FROM admin_position_master 
              WHERE office_id = 35
                AND role_master_id = 7
          ) 
        GROUP BY lu.assigned_by_position, csom.suboffice_name, ar.assigned_by_office_id
    ) tbl3
ON tbl3.assigned_by_position = tbl1.assigned_to_position
AND tbl2.suboffice_name = tbl1.suboffice_name
ORDER BY tbl1.suboffice_name;




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
              WHERE office_id = 35
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
              WHERE office_id = 35
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
              WHERE office_id = 35
                AND role_master_id = 7
          ) 
        GROUP BY lu.assigned_by_position, csom.suboffice_name
    ) tbl3
ON tbl3.assigned_by_position = tbl1.assigned_to_position
AND tbl3.suboffice_name = tbl1.suboffice_name
ORDER BY tbl1.suboffice_name;							-- new updated chart id 14 query --




SELECT
          COALESCE(tbl1.grv_frwd, 0) as grievance_forwarded,
    COALESCE(tbl2.atr_sent, 0) as atr_recieved_count,
    CASE 
        WHEN COALESCE(tbl1.grv_frwd, 0) - COALESCE(tbl2.atr_sent, 0) > 0 THEN COALESCE(tbl1.grv_frwd, 0) - COALESCE(tbl2.atr_sent, 0)
        ELSE 0 
    END AS atr_pending,
    tbl1.assigned_to_position,
    tbl1.suboffice_name,
    0 as average_resolution_days,
    'Good' as performance
        FROM
            (
                WITH lastupdates AS (
                    SELECT 
                        grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
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
                    WHERE office_id = 35
                        AND role_master_id = 7
                ) 
        GROUP BY lu.assigned_to_position, csom.suboffice_name
    ) tbl1
LEFT OUTER JOIN 
    (
        WITH lastupdates AS (
            SELECT 
                grievance_lifecycle.grievance_id,
                grievance_lifecycle.grievance_status,
                grievance_lifecycle.assigned_on,
                grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_by_office_id,
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
              WHERE office_id = 35
                AND role_master_id = 7
          ) 
        GROUP BY lu.assigned_by_position, csom.suboffice_name
    ) tbl2
ON tbl2.assigned_by_position = tbl1.assigned_to_position
AND tbl2.suboffice_name = tbl1.suboffice_name
ORDER BY tbl1.suboffice_name;   								 -- old chart id 14 query --




with assign_to_cmo_user_new as (
	select assigned_to_position, count(grievance_id) as new_pending_count from grievance_master where status = 2 group by assigned_to_position
),
assign_to_cmo_user_atr as (
	select assigned_to_position, count(grievance_id) as atr_pending_count from grievance_master where status = 14 group by assigned_to_position
)
select aud.official_name,
	   sum(case when (gm.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)) then 1 else 0 End ) as new_grievance_forwarded,
	   sum(case when (gm.status in (15)) then 1 else 0 End) as closed_count,
	   sum(case when (gm.status in (6)) then 1 else 0 End) as return_to_hod_count,
	   sum(case when (gm.status in (17)) then 1 else 0 End) as return_to_other_hod_count,
	   coalesce(cte1.new_pending_count,0) as new_pending_count,
	   coalesce(cte2.atr_pending_count,0) as atr_pending_count	   
 from grievance_master gm 
inner join admin_position_master apm on gm.updated_by_position = apm.position_id
inner join admin_user_position_mapping aupm on aupm.position_id = apm.position_id 
inner join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id 
inner join admin_user au on aud.admin_user_id = au.admin_user_id and au.status != 3
left join assign_to_cmo_user_new cte1 on cte1.assigned_to_position = gm.updated_by_position
left join assign_to_cmo_user_atr cte2 on cte2.assigned_to_position = gm.updated_by_position
where apm.role_master_id in (1,2,3,9) and apm.office_category = 1  
group by gm.updated_by_position, aud.official_name,cte1.new_pending_count,cte2.atr_pending_count;			-- chart id 3 updated --



WITH grievances AS (
    SELECT 
        csog.admin_user_id,
        COUNT(CASE WHEN csog.status IN (8, 9, 11, 12, 14, 15, 16, 17, 4) THEN 1 END) AS grv_assigned,
        COUNT(CASE WHEN csog.status IN (4, 9, 11, 12, 16, 14, 15, 17) AND csog.closure_reason_id = 1 THEN 1 END) AS bnft_prvd,
        COUNT(CASE WHEN csog.status IN (4, 9, 11, 12, 16, 14, 15, 17) AND csog.closure_reason_id IN (5, 9) THEN 1 END) AS action_taken,
        COUNT(CASE WHEN csog.status IN (4, 9, 11, 12, 16, 14, 15, 17) AND csog.closure_reason_id NOT IN (1, 5, 9) THEN 1 END) AS not_elgbl,
        COUNT(CASE WHEN csog.status IN (4, 11, 16, 14, 15, 17) THEN 1 END) AS total_received,
        COUNT(CASE WHEN glc.grievance_status = 8 AND NOT EXISTS (
            SELECT 1
            FROM grievance_lifecycle glc2
            WHERE glc2.grievance_id = glc.grievance_id AND glc2.grievance_status = 9
        ) THEN 1 END) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - csog.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days,
        COUNT(CASE WHEN csog.status = 10 THEN 1 END) AS atr_review
    FROM cat_sub_offc_griv csog
    LEFT JOIN grievance_lifecycle glc ON glc.grievance_id = csog.grievance_id
    WHERE csog.grievance_generate_date BETWEEN '2022-01-01' AND '2024-11-25'
    GROUP BY csog.admin_user_id
)
SELECT  
    aud.admin_user_id,
    csom.office_id,
    csom.suboffice_id,
    COALESCE(aud.official_name, 'N/A') AS office_name,
    COALESCE(csom.suboffice_name, 'N/A') AS suboffice_name,
    COALESCE(g.grv_assigned, 0) AS grievances_assigned,
    COALESCE(g.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(g.action_taken, 0) AS action_taken,
    COALESCE(g.not_elgbl, 0) AS not_elgbl,
    COALESCE(g.total_received, 0) AS total_received,
    COALESCE(g.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(g.atr_pndg, 0) AS cumulative_pendency,
    COALESCE(g.atr_review, 0) AS atr_returned_from_hod_for_review 
FROM admin_user au 
LEFT JOIN admin_user_details aud ON aud.admin_user_id = au.admin_user_id 
LEFT JOIN admin_user_position_mapping aupm ON aupm.admin_user_id = aud.admin_user_id 
LEFT JOIN admin_position_master apm ON aupm.position_id = apm.position_id   
LEFT JOIN cmo_sub_office_master csom ON csom.suboffice_id = apm.sub_office_id
LEFT JOIN grievances g ON aud.admin_user_id = g.admin_user_id 
WHERE csom.office_id = 3 AND csom.suboffice_id = 476;



SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table0.office_id,
    table0.suboffice_id,
    COALESCE(table0.office_name) AS office_name,
    COALESCE(table0.suboffice_name) AS suboffice_name,
    COALESCE(table1.grv_frwd, 0) AS grievances_forwarded,
    COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(table3.action_taken, 0) AS action_taken,
    COALESCE(table4.not_elgbl, 0) AS not_elgbl,
    COALESCE(table5.total_submitted, 0) AS total_submitted,
    COALESCE(table6.atr_pndg, 0) AS atr_pending,
    COALESCE(table7.atr_review, 0) AS atr_returned_from_hod_for_review 
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
    LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id 
    left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id 
    left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id 
    left join admin_user au on au.admin_user_id = aud.admin_user_id 
    WHERE cgcm.status = 1
) table0
-- No. of Grievances Received
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
    and csog.status in (4,11,16,14,15,17) 
    and csog.closure_reason_id = 1
--    and csog.grievance_source IN (5)
    GROUP BY csog.grievance_cat_id
) table2 ON table2.grievance_cat_id = table0.grievance_cat_id 
-- Action Initiated
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS action_taken
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status in (4,11,16,14,15,17)  
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
    and csog.status in (4,11,16,14,15,17) 
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
    and csog.status in (4,11,16,14,15,17) 
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
        AND glc.grievance_status = 7  -- Grievances currently at status 8
        AND NOT EXISTS (
            SELECT 1
            FROM grievance_lifecycle glc2
            WHERE 
                glc2.grievance_id = glc.grievance_id
                AND glc2.grievance_status = 11  -- Grievances that have received status 9
        )
        and csog.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-25'  
--        and csog.grievance_source IN (5)
    GROUP BY 
        csog.grievance_cat_id, glc.grievance_status
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id 
-- ATR returned from HOD for review 
LEFT JOIN (
    SELECT 
        csog.grievance_cat_id,
        COUNT(1) AS atr_review
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status = 12
--    and csog.grievance_source IN (5)
    GROUP BY csog.grievance_cat_id
) table7 ON table0.grievance_cat_id = table7.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (476);



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
                    where grievance_lifecycle.grievance_status in (8,9,11,12,14,15,16,17,4)
--                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-25' 
--                    and gm.grievance_source IN (5)
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
                        sum(case when gm.status in (4,9,11,12,16,14,15,17) and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                        sum(case when gm.status in (4,9,11,12,16,14,15,17) and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                        sum(case when gm.status in (4,9,11,12,16,14,15,17) and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
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
                    where grievance_lifecycle.grievance_status in (4,9,11,12,16,14,15,17)
--                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-25' 
--                    and gm.grievance_source IN (5)
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
--			            AND gm.grievance_generate_date BETWEEN '2019-01-01' and '2024-11-25' 
--			            and gm.grievance_source IN (5)
					) a
			    INNER JOIN 
			        grievance_master gm ON gm.grievance_id = a.grievance_id
			--    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
			    WHERE 
			        rn = 1 AND a.assigned_to_office_id = 3    
			    GROUP BY 
			        a.assigned_to_position, a.assigned_to_office_id
				),
	atr_return_for_review AS (
            select 
                a.assigned_to_position,
                a.assigned_to_office_id,
                count(distinct a.grievance_id) as atr_return  
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
                    where grievance_lifecycle.grievance_status = 10
--                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-25' 
--                    and gm.grievance_source IN (5)
                    ) a 
                    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3  
                    group by a.assigned_to_position, a.assigned_to_office_id
                )
                select  
                    aud.official_name as office_name, 
                    aud.admin_user_id,
                    gm.assigned_to_office_id,
--                    gm.assigned_to_position,
                    csom.suboffice_name, 
--    				csom.suboffice_id,
    				csom.suboffice_code,
--    				apm.office_id,
    				apm.sub_office_id,
                    coalesce(ag.grv_assigned) as grievances_assigned,
                    coalesce(asth.bnft_prvd) as benefit_service_provided,
                    coalesce(asth.action_taken) as action_taken,
                    coalesce(asth.not_elgbl) as not_elgbl,
                    coalesce(asth.total_submitted) as total_submitted,
                    coalesce(ap.beyond_svn_days) as beyond_svn_days,
                    coalesce(ap.atr_pndg) as cumulative_pendency,
                    coalesce(ar.atr_return) as atr_return_for_review_to_so_user
                from cmo_sub_office_master csom
				LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
				left join grievance_master gm on gm.assigned_to_office_id = apm.office_id and gm.assigned_to_office_id = csom.office_id
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id 
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id 
                left join admin_user au on au.admin_user_id = aud.admin_user_id 
                left join assigned_grievances ag on gm.assigned_to_position = ag.assigned_to_position and ag.assigned_to_office_id = apm.office_id 
                left join atr_submitted_to_hoso asth on asth.assigned_to_position = gm.assigned_to_position and asth.assigned_to_office_id = apm.office_id 
                left join atr_pending ap on ap.assigned_to_position = gm.assigned_to_position and ap.assigned_to_office_id = apm.office_id  
                left join atr_return_for_review ar on ar.assigned_to_position = gm.assigned_to_position and ar.assigned_to_office_id = apm.office_id
                 WHERE 
				    au.status != 3
				    and apm.office_id = 3
				    and apm.sub_office_id = 476
				 group by 
                	aud.official_name,
                	aud.admin_user_id,
--				 	gm.assigned_to_position,
				 	csom.suboffice_code,
                	gm.assigned_to_office_id,
                    csom.suboffice_name,
--    				csom.suboffice_id,
--    				apm.office_id,
    				apm.sub_office_id,
    				ag.grv_assigned,
    				asth.bnft_prvd,
    				asth.action_taken,
    				asth.not_elgbl,
    				asth.total_submitted,
    				ap.beyond_svn_days,
    				ap.atr_pndg,
    				ar.atr_return;
    				
    			
    			
    			
select  atr_type, atr_proposed_date, action_taken_note, gl.atn_id, 
                        catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
                        prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
                        gl.assigned_on, gl.assigned_by_id, gl.assign_comment, 
                        gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position, 
                        gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
                    from grievance_lifecycle gl
                    left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
                    left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id 
--                    where gl.lifecycle_id  = 36843;
                    where gl.grievance_id = 2435;
                    
select  atr_type, atr_proposed_date, action_taken_note, gl.atn_id, 
    catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
    prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
    gl.assigned_on, gl.assigned_by_id, gl.assign_comment, 
    gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position, 
    gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
from grievance_lifecycle gl
left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id 
where gl.lifecycle_id  = 36843;

select * from grievance_master gm where gm.grievance_id = 2435;








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
         Select Count(1) 
                    from master_district_block_grv md
                    -- from (select * from master_district_block_grv where md.grievance_id > 0  and 1) md
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id -- and aupm.status = 1
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 1 
                                where ( 
                              md.grievance_id > 0 and replace(lower(md.emergency_flag),' ','') like '%n%' and md.status in (1) );
                             
                             
                             
                             
                         



select a.admin_user_id, a.status, a.official_name, a.official_code, a.official_phone, a.alternate_phone, a.official_email, a.created_on, a.created_by, a.updated_by, 
                        a.updated_on, a.status_name, a.role_master_id, a.role_master_name, a.role_code, a.user_type, a.user_type_dtls, a.designation_name
                    from 
                   ((select 
                        distinct au.admin_user_id,
                            au.status,
                            aud.official_name as official_name,
                            aud.official_code,
                            aud.official_phone,
                            CASE 
                                when aud.alternate_phone = '' THEN 'N/A'
                            END as alternate_phone,
                            aud.official_email,
                            aud.created_on + INTERVAL '5 hour 30 Minutes' as created_on,
                            aud.created_by,
                            aud.updated_by,
                            aud.updated_on + INTERVAL '5 hour 30 Minutes' as updated_on,
                            cdlm1.domain_value as status_name,
                             array(
                                select cast(unnested_array as INTEGER)
                                from unnest(string_to_array(string_agg(apm.role_master_id::TEXT,','), ',')) as unnested_array
                            ) as role_master_id,
                            -- string_agg(apm.role_master_id::TEXT,',') as role_master_id,
                             array(
                                select cast(unnested_array as TEXT)
                                from unnest(string_to_array(string_agg(aurm.role_master_name::TEXT,','), ',')) as unnested_array
                            ) as role_master_name,
                            -- string_agg(aurm.role_master_name,',') as role_master_name,
                            array(
                                select cast(unnested_array as TEXT)
                                from unnest(string_to_array(string_agg(aurm.role_code::TEXT,','), ',')) as unnested_array
                            ) as role_code,
                            -- string_agg(aurm.role_code,',') as role_code,
                            array(
                                select cast(unnested_array as INTEGER)
                                from unnest(string_to_array(string_agg(apm.user_type::TEXT,','), ',')) as unnested_array
                            ) as user_type,
                            -- string_agg(apm.user_type::TEXT,',') as user_type,
                            array(
                                select cast(unnested_array as TEXT)
                                from unnest(string_to_array(string_agg(cdlm2.domain_value::TEXT,','), ',')) as unnested_array
                            ) as user_type_dtls,
                            -- string_agg(cdlm2.domain_value,',') as user_type_dtls,
                            array(
                                select cast(unnested_array as TEXT)
                                from unnest(string_to_array(string_agg(cdm.designation_name::TEXT,','), ',')) as unnested_array
                            ) as designation_name
                            -- string_agg(cdm.designation_name,',') as designation_name
                        from admin_position_master apm
                        inner join admin_user_position_mapping aupm on aupm.position_id = apm.position_id and aupm.status = 1
                        inner join admin_user au on au.admin_user_id = aupm.admin_user_id 
                        inner join admin_user_details aud on aud.admin_user_id = au.admin_user_id
                        inner join cmo_domain_lookup_master cdlm1 on cdlm1.domain_code = au.status and cdlm1.domain_type = 'status'
                        inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
                        inner join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = apm.user_type and cdlm2.domain_type = 'user_type'
                        left join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
                        where 
                            case
                                when 1 = 1 then apm.role_master_id::TEXT like '%%' 
                                when 1 = 2 then apm.role_master_id not in (1)
                                when 1 = 3 then apm.role_master_id not in (1,2)
                                when 1 = 4 then apm.role_master_id not in (1,2,3) and apm.user_type not in (1)
                                when 1 = 5 then apm.role_master_id not in (1,2,3,4) and apm.user_type not in (1)
                                when 1 = 6 then apm.role_master_id not in (1,2,3,4,5) and apm.user_type not in (1)
                                when 1 = 7 then apm.role_master_id not in (1,2,3,4,5,6) and apm.user_type not in (1,2)
                                when 1 = 8 then apm.role_master_id not in (1,2,3,4,5,6,7) and apm.user_type not in (1,2)
                        end and au.admin_user_id > 0
                        and 
                            case 
                                when (select user_type from admin_position_master where position_id = 59) = 1 then apm.office_id::text like '%%'
                                when (select user_type from admin_position_master where position_id = 59) = 2 then apm.office_id = (select office_id  from admin_position_master where position_id = 59)
                                when (select user_type from admin_position_master where position_id = 59) = 3 then apm.sub_office_id = (select sub_office_id  from admin_position_master where position_id = 59)
                            end
                        group by au.admin_user_id, aud.official_name, aud.official_code, aud.official_phone, aud.alternate_phone, aud.official_email, aud.created_on,aud.created_by,aud.updated_by,aud.updated_on,cdlm1.domain_value order by au.admin_user_id asc)
                        union all 
                        (
                            select au.admin_user_id, 
                                    au.status,
                                    aud.official_name as official_name,
                                    aud.official_code,
                                    aud.official_phone,
                                    CASE 
                                        when aud.alternate_phone = '' THEN 'N/A'
                                    END as alternate_phone,
                                    aud.official_email,
                                    aud.created_on + INTERVAL '5 hour 30 Minutes' as created_on,
                                    aud.created_by,
                                    aud.updated_by,
                                    aud.updated_on + INTERVAL '5 hour 30 Minutes' as updated_on,
                                    cdlm1.domain_value as status_name,
                                    array(
                                        select cast(unnested_array as INTEGER)
                                        from unnest(string_to_array('', ',')) as unnested_array
                                    ) as role_master_id,
                                    -- 'N/A' as role_master_id,
                                    array(
                                        select cast(unnested_array as TEXT)
                                        from unnest(string_to_array('', ',')) as unnested_array
                                    ) as role_master_name,
                                    -- 'N/A' as role_master_name,
                                    array(
                                        select cast(unnested_array as TEXT)
                                        from unnest(string_to_array('', ',')) as unnested_array
                                    ) as role_code,
                                    -- 'N/A' as role_code,
                                     array(
                                        select cast(unnested_array as INTEGER)
                                        from unnest(string_to_array('', ',')) as unnested_array
                                    ) as user_type,
                                    -- 'N/A' as user_type,
                                    array(
                                        select cast(unnested_array as TEXT)
                                        from unnest(string_to_array('', ',')) as unnested_array
                                    ) as user_type_dtls,
                                    -- 'N/A' as user_type_dtls,
                                    array(
                                        select cast(unnested_array as TEXT)
                                        from unnest(string_to_array('', ',')) as unnested_array
                                    ) as designation_name
                                    -- 'N/A' as designation_name
                                from admin_user au 
                                inner join admin_user_details aud on aud.admin_user_id = au.admin_user_id
                                inner join cmo_domain_lookup_master cdlm1 on cdlm1.domain_code = au.status and cdlm1.domain_type = 'status'
                            where au.admin_user_id not in (select distinct admin_user_id  from admin_user_position_mapping aupm where aupm.status = 1) 
                            group by au.admin_user_id, aud.official_name, aud.official_code, aud.official_phone, aud.alternate_phone, aud.official_email, aud.created_on,aud.created_by,aud.updated_by,aud.updated_on,cdlm1.domain_value order by au.admin_user_id asc 
                        )) as a;

        
   
                       
                              