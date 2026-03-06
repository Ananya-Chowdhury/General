----- correct mis ------
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
        

       
--- mis 5 correct ---
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
--                {received_at}
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
--                {received_at}
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
--                {received_at}
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
--                {received_at}
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
--                {received_at}
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
--                {received_at}
                GROUP BY cog.grievance_cat_id
            ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id in (9) ;
            

select * from cmo_office_master com ;
select * from cmo_grievance_category_master cgcm ;
select * from grievance_lifecycle gl limit 1;
select * from grievance_master gm limit 1;


----- mis 6 part 3 correct ----
WITH filtered_data AS (
            select *
            from grievance_master gm
            where grievance_generate_date BETWEEN '2019-01-01' and '2024-11-11'
            and gm.status = 3 
            and gm.grievance_source in (5)
            and gm.received_at in (4)
                )
                select  
                    table0.office_id,
                    COALESCE(table0.office_name, 'N/A') AS office_name,
                    COALESCE(table1.grv_frwd_assigned, 0) AS grievances_forwarded_assigned,
                    COALESCE(table2.atr_rcvd, 0) AS atr_received,
                    COALESCE(table3.bnft_prvd, 0) AS benefit_service_provided,
                    COALESCE(table3.action_taken, 0) AS action_taken,
                    COALESCE(table3.not_elgbl, 0) AS not_elgbl,
                    COALESCE(table3.total_closed, 0) AS total_disposed,
                    COALESCE(table4.beyond_svn_days, 0) AS beyond_svn_days,
                    COALESCE(table4.atr_pndg, 0) AS cumulative,
                    COALESCE(table5.atr_retrn_reviw_frm_cmo, 0) AS atr_return_for_review_from_cmo
                from
                    (
                        select 
                            DISTINCT com.office_id, 
                            com.office_name
                        from cmo_office_master com
                        LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id
                        where com.office_category = 2 and com.status = 1
                        group by com.office_id, com.office_name) AS table0
                    -- Grievances forwarded/assigned
            LEFT OUTER JOIN (
                select 
                    COUNT(DISTINCT grievance_id) AS grv_frwd_assigned, 
                    gm.assigned_to_office_id AS office_id
                from filtered_data gm
                where gm.status not in (1, 2)
                group by gm.assigned_to_office_id
            ) table1 ON table1.office_id = table0.office_id
                -- ATR received
        LEFT OUTER JOIN (
                    select 
                        COUNT(DISTINCT grievance_id) AS atr_rcvd,
                        gm.assigned_to_office_id AS office_id
                    from filtered_data gm
                    where gm.status IN (14, 15, 16, 17)
                    group by gm.assigned_to_office_id
                ) table2 ON table2.office_id = table0.office_id
                -- ATR closed
        LEFT OUTER JOIN (
                    select 
                        COUNT(1) AS total_closed, 
                        SUM(CASE WHEN gm.status = 15 and gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
                        SUM(CASE WHEN gm.status = 15 and gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END) AS action_taken,
                        SUM(CASE WHEN gm.status = 15 and gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END) AS not_elgbl,
                        gm.atr_submit_by_lastest_office_id AS office_id 
                    from filtered_data gm
                    where gm.status = 15
                    group by gm.atr_submit_by_lastest_office_id
                ) table3 ON table3.office_id = table0.office_id
                -- ATR pending
        LEFT OUTER JOIN (
                    select 
                        COUNT(DISTINCT grievance_id) AS atr_pndg, 
                        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days,
                        gm.assigned_to_office_id AS office_id
                    from filtered_data gm
                    where gm.status NOT IN (1, 2, 14, 15, 16)
                    group by gm.assigned_to_office_id
                ) table4 ON table4.office_id = table0.office_id
                -- ATR returned for review from CMO
        LEFT OUTER JOIN (
                select 
                    COUNT(grievance_id) AS atr_retrn_reviw_frm_cmo,
                    gm.assigned_to_office_id AS office_id
                from filtered_data gm
                where gm.status = 6
                group by gm.assigned_to_office_id
            ) table5 ON table5.office_id = table0.office_id;
            
           
           
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
                    and gm.status = '3'
                    and gm.grievance_source in (5)
                    and gm.received_at in (4)) a 
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
                    and gm.status = '3'
                    and gm.grievance_source in (5)
                    and gm.received_at in (4)) a 
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
                    and gm.status = '3'
                    and gm.grievance_source in (5)
                    and gm.received_at in (4)) a 
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
                    and gm.status = '3'
                    and gm.grievance_source in (5)
                    and gm.received_at in (4)) a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3    
                    group by a.assigned_to_position
                )
                select  
                    aud.official_name as office_name, 
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
                group by 
               		aud.official_name, 
               		fag.grv_frwd_assigned, 
               		ltr.atr_rcvd, 
               		d.bnft_prvd, 
               		d.action_taken, 
               		d.not_elgbl, 
               		d.total_closed, 
               		p.beyond_svn_days, 
               		p.atr_pndg;
                	
               
     
                
                
 ----------- mis 6 part 1 correct (minor changes needed) -------            
 SELECT  
    table0.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table0.department_name, 'N/A') AS department_name,
    COALESCE(table1.grv_frwd_assigned, 0) AS grievances_forwarded_assigned,
    COALESCE(table2.atr_rcvd, 0) AS atr_received,
    COALESCE(table3.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(table3.action_taken, 0) AS action_taken,
    COALESCE(table3.not_elgbl, 0) AS not_elgbl,
    COALESCE(table3.total_closed, 0) AS total_disposed,
    COALESCE(table4.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(table4.atr_pndg, 0) AS cumulative
FROM (
    SELECT 
        gm.assigned_to_office_id AS office_id, 
        com.office_name AS department_name,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id 
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
    WHERE au.status != 3
      AND com.office_category = 2 
      AND com.status = 1
--      AND gm.assigned_to_office_id = 3 
--      AND gm.atr_submit_by_lastest_office_id = 3
      and com.office_id = 3
    GROUP BY gm.assigned_to_office_id, com.office_name, aud.official_name
) AS table0
-- Grievances forwarded/assigned 
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS grv_frwd_assigned, 
        gm.assigned_to_office_id AS office_id,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status NOT IN (1, 2, 3, 13)
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--	    and gm.grievance_source in (5)
--	    and gm.received_at in (4)
      AND gm.assigned_to_office_id = 3
    GROUP BY gm.assigned_to_office_id, aud.official_name
) table1 ON table1.office_id = table0.office_id AND table1.office_name = table0.office_name
-- ATR received 
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS atr_rcvd,
        gm.assigned_to_office_id AS office_id,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status IN (11, 14, 15, 16, 17)
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--        and gm.grievance_source in (5)
--        and gm.received_at in (4)
      AND gm.assigned_to_office_id = 3
    GROUP BY gm.assigned_to_office_id, aud.official_name
) table2 ON table2.office_id = table0.office_id AND table2.office_name = table0.office_name
-- Disposal (Closed grievances)
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS total_closed, 
        gm.atr_submit_by_lastest_office_id AS office_id,
        aud.official_name AS office_name,
        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.atr_submit_by_lastest_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status = 15
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--        and gm.grievance_source in (5)
--        and gm.received_at in (4)
      AND gm.atr_submit_by_lastest_office_id = 3
    GROUP BY gm.atr_submit_by_lastest_office_id, aud.official_name
) table3 ON table3.office_id = table0.office_id AND table3.office_name = table0.office_name
-- Pending grievances 
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS atr_pndg, 
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days,
        gm.assigned_to_office_id AS office_id,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status NOT IN (1, 2, 14, 15, 16, 17)
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--        and gm.grievance_source in (5)
--        and gm.received_at in (4)
      AND gm.assigned_to_office_id = 3
    GROUP BY gm.assigned_to_office_id, aud.official_name
) table4 ON table4.office_id = table0.office_id AND table4.office_name = table0.office_name;


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
        and gm.status = '3'
        and gm.grievance_source in (5)
        and gm.received_at in (4)) a 
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
        and gm.status = '3'
        and gm.grievance_source in (5)
        and gm.received_at in (4)) a 
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
        and gm.status = '3'
        and gm.grievance_source in (5)
        and gm.received_at in (4)) a 
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
            AND gm.grievance_generate_date BETWEEN '2019-01-01' and '2024-11-11'
            and gm.status = '3'
            and gm.grievance_source in (5)
            and gm.received_at in (4)) a
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




SELECT  
    table0.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table0.department_name, 'N/A') AS department_name,
    COALESCE(table1.grv_frwd_assigned, 0) AS grievances_forwarded_assigned,
    COALESCE(table2.atr_rcvd, 0) AS atr_received,
    COALESCE(table3.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(table3.action_taken, 0) AS action_taken,
    COALESCE(table3.not_elgbl, 0) AS not_elgbl,
    COALESCE(table3.total_closed, 0) AS total_disposed,
    COALESCE(table4.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(table4.atr_pndg, 0) AS cumulative
FROM (
    SELECT 
        gm.assigned_to_office_id AS office_id, 
        com.office_name AS department_name,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id 
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
    WHERE au.status != 3
      AND com.office_category = 2 
      AND com.status = 1
--      AND gm.assigned_to_office_id = 3 
--      AND gm.atr_submit_by_lastest_office_id = 3
      and com.office_id = 3
    GROUP BY gm.assigned_to_office_id, com.office_name, aud.official_name
) AS table0
-- Grievances forwarded/assigned 
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS grv_frwd_assigned, 
        gm.assigned_to_office_id AS office_id,
        gm.assigned_by_office_id,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status in (4,5,6,13,14,15)
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--	    and gm.grievance_source in (5)
--	    and gm.received_at in (4)
      AND gm.assigned_by_office_id = 3
    GROUP BY gm.assigned_to_office_id, aud.official_name
) table1 ON table1.office_id = table0.office_id AND table1.office_name = table0.office_name




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
        and gm.status = '3'
        and gm.grievance_source in (5)
        and gm.received_at in (4)) a 
        inner join grievance_master gm on gm.grievance_id = a.grievance_id 
        where rn = 1 and a.assigned_by_office_id = 3   
        group by a.assigned_to_office_id



-- ATR received 
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS atr_rcvd,
        gm.assigned_to_office_id AS office_id,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status IN (11, 14, 15, 16, 17)
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--        and gm.grievance_source in (5)
--        and gm.received_at in (4)
      AND gm.assigned_to_office_id = 3
    GROUP BY gm.assigned_to_office_id, aud.official_name
) table2 ON table2.office_id = table0.office_id AND table2.office_name = table0.office_name
-- Disposal (Closed grievances)
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS total_closed, 
        gm.atr_submit_by_lastest_office_id AS office_id,
        aud.official_name AS office_name,
        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.atr_submit_by_lastest_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status = 15
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--        and gm.grievance_source in (5)
--        and gm.received_at in (4)
      AND gm.atr_submit_by_lastest_office_id = 3
    GROUP BY gm.atr_submit_by_lastest_office_id, aud.official_name
) table3 ON table3.office_id = table0.office_id AND table3.office_name = table0.office_name
-- Pending grievances 
LEFT OUTER JOIN (
    SELECT 
        COUNT(DISTINCT grievance_id) AS atr_pndg, 
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days,
        gm.assigned_to_office_id AS office_id,
        aud.official_name AS office_name
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    WHERE gm.status NOT IN (1, 2, 14, 15, 16, 17)
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--      and gm.status = 3 
--        and gm.grievance_source in (5)
--        and gm.received_at in (4)
      AND gm.assigned_to_office_id = 3
    GROUP BY gm.assigned_to_office_id, aud.official_name
) table4 ON table4.office_id = table0.office_id AND table4.office_name = table0.office_name;











SELECT 
        DISTINCT gm.assigned_to_office_id AS office_id, 
        COUNT(DISTINCT grievance_id) AS grv_frwd_assigned,
        com.office_name AS department_name,
        aud.official_name AS office_name 
    FROM cmo_office_master com
    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
    LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
    WHERE au.status != 3
      AND com.office_category = 2 
      AND com.status = 1
      AND gm.assigned_to_office_id = 3
      and gm.status IN (1, 2, 14, 15, 16, 17)
--     AND gm.closure_reason_id not in (1,5,9)
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
    GROUP BY gm.assigned_to_office_id, com.office_name, aud.official_name;

		               
  
   
   
   
------- mis 11 hoso cat wise suboffice wise (correct) -----  
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
) table7 ON table0.grievance_cat_id = table7.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (499);
   
   
  





   
   
   
   
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
        and cog.received_at in (4)
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
        and cog.received_at in (4)
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
        and cog.received_at in (4)
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
        and cog.received_at in (4)
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
        and cog.received_at in (4)
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
        and cog.received_at in (4)
        GROUP BY cog.grievance_cat_id
    ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id in (9);   
   
   
   
   
   
   
 ------- mis 7 cat wise mis report ()-----  
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
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (499);
   
   
   
   


		               
		               
select * from admin_user_details aud; 
select * from grievance_master gm where gm.assigned_to_office_id = 3;
--	select * from cmo_sub_office_master csom where office_id = 3 and suboffice_id = 4;
            
select * from admin_position_master apm where office_id = 3  and sub_office_id = 476;
select * from admin_position_master apm where office_id = 3 ;
select * from admin_user_position_mapping aupm  where position_id in (4278,10976);
select * from admin_user_details aud where admin_user_id in (4278,10976);
select * from admin_user au where admin_user_id in (11784,2000);
select * from grievance_master gm where gm.assigned_to_office_id = 3;
select * from cmo_office_master com where office_id = 53;

CREATE OR REPLACE VIEW public.cat_sub_offc_griv
AS SELECT gm.grievance_id,
    gm.grievance_category,
    cgcm.grievance_cat_id,
    cgcm.grievance_category_desc,
    gm.assigned_to_office_id AS office_id,
    com.office_name,
    gm.assigned_to_position,
    gm.atr_recv_cmo_flag,
    gm.grievance_generate_date,
    gm.received_at,
    gm.updated_on,
    gm.status,
    gm.closure_reason_id,
    gm.grievance_source,
    csom.suboffice_name,
    csom.suboffice_id,
    cgcm.benefit_scheme_type,
    aud.admin_user_id,
    aud.official_name
   FROM grievance_master gm,
    cmo_grievance_category_master cgcm,
    cmo_office_master com,
    cmo_sub_office_master csom,
    admin_position_master apm,
    admin_user_position_mapping aupm,
    admin_user_details aud,
    admin_user au
  WHERE gm.grievance_category = cgcm.grievance_cat_id AND com.office_id = gm.assigned_to_office_id 
  AND csom.office_id = com.office_id AND csom.office_id = gm.assigned_to_office_id 
  AND csom.office_id = apm.office_id AND csom.suboffice_id = apm.sub_office_id 
  AND gm.assigned_to_office_id = apm.office_id AND aupm.position_id = apm.position_id 
 AND aud.admin_user_id = aupm.admin_user_id AND au.admin_user_id = aud.admin_user_id;
 
-- DROP VIEW IF EXISTS cat_sub_offc_griv;
 
 
 
 ---------->>>>>>> 29.11.29 ----->>>
 
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
    		
    			

    			
    			
SELECT  
    table0.admin_user_id,
    table0.office_id,
    table0.suboffice_id,
    COALESCE(table0.official_name) AS office_name,
    COALESCE(table0.suboffice_name) AS suboffice_name,
    COALESCE(table1.grv_assigned, 0) AS grievances_assigned,
    COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(table3.action_taken, 0) AS action_taken,
    COALESCE(table4.not_elgbl, 0) AS not_elgbl,
    COALESCE(table5.total_received, 0) AS total_received,
    COALESCE(table6.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(table6.atr_pndg, 0) AS cumulative_pendency,
    COALESCE(table7.atr_review, 0) AS atr_returned_from_hod_for_review 
FROM (
    SELECT 
        aud.admin_user_id, 
        aud.official_name, 
        com.office_id AS office_id,
        gm.assigned_to_office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id
    from admin_user au 
    left join admin_user_details aud on aud.admin_user_id = au.admin_user_id 
    left join admin_user_position_mapping aupm on aupm.admin_user_id = aud.admin_user_id 
    LEFT JOIN admin_position_master apm ON aupm.position_id = apm.position_id   
    left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
    left join grievance_master gm on gm.assigned_to_office_id = apm.office_id and gm.assigned_to_office_id = csom.office_id
    left join cmo_office_master com ON com.office_id = gm.assigned_to_office_id and csom.office_id = com.office_id
) table0
-- No. of Grievances Assigned
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS grv_assigned
    FROM cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'
    and csog.status in (8,9,11,12,14,15,16,17,4)
--    and csog.grievance_source IN (5)
    GROUP BY csog.admin_user_id 
) table1 ON table0.admin_user_id = table1.admin_user_id 
-- Benefit/ Service Provided
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS bnft_prvd
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'
    and csog.status in (4,9,11,12,16,14,15,17) 
    and csog.closure_reason_id = 1
--    and csog.grievance_source IN (5)
    GROUP BY csog.admin_user_id
) table2 ON table2.admin_user_id = table0.admin_user_id 
-- Action Initiated
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS action_taken
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status in (4,9,11,12,16,14,15,17) 
    and csog.closure_reason_id IN (5,9)
--    and csog.grievance_source IN (5)
    GROUP BY csog.admin_user_id
) table3 ON table0.admin_user_id = table3.admin_user_id
-- Not eligible to get benefit
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS not_elgbl
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status in (4,9,11,12,16,14,15,17) 
    and csog.closure_reason_id NOT IN (1,5,9)
--    and csog.grievance_source IN (5)
    GROUP BY csog.admin_user_id
) table4 ON table0.admin_user_id = table4.admin_user_id
-- Total received
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS total_received
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status in (4,11,16,14,15,17) 
--    and csog.grievance_source IN (5)
    GROUP BY csog.admin_user_id
) table5 ON table0.admin_user_id = table5.admin_user_id
-- ATR Pending
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS atr_pndg,
		SUM(CASE WHEN CURRENT_DATE - csog.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days,
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
        and csog.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-25'  
--        and csog.grievance_source IN (5)
    GROUP BY 
        csog.admin_user_id, glc.grievance_status
) table6 ON table0.admin_user_id = table6.admin_user_id 
-- ATR Returned to SO User for Review
LEFT JOIN (
    SELECT 
        csog.admin_user_id,
        COUNT(1) AS atr_review
    from cat_sub_offc_griv csog
    where grievance_generate_date between '2022-01-01' and '2024-11-25'  
    and csog.status = 10
--    and csog.grievance_source IN (5)
    GROUP BY csog.admin_user_id
) table7 ON table0.admin_user_id = table7.admin_user_id where table0.office_id = (3) and table0.suboffice_id = (499);




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
) table7 ON table0.grievance_cat_id = table7.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (499);




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
    AND apm.sub_office_id = 499
  group by
 		aud.official_name;


 	
 SELECT  
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.office_id,
                table0.suboffice_id,
                COALESCE(table0.office_name) AS office_name,
                COALESCE(table0.suboffice_name) AS suboffice_name,
                COALESCE(table1.grv_frwd, 0) AS grievances_received,
                COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
                COALESCE(table3.action_taken, 0) AS action_taken,
                COALESCE(table4.not_elgbl, 0) AS not_elgbl,
                COALESCE(table5.total_submitted, 0) AS total_submitted,
                COALESCE(table6.atr_pndg, 0) AS atr_pending,
                COALESCE(table7.atr_review, 0) AS atr_return_for_review_from_hod 
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
            -- No. of Grievances Received
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS grv_frwd
                FROM cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'
                and csog.status in (7,8,9,10,11,12,14,15,16,17)
                {data_source}
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
                {data_source}
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
                {data_source}
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
                {data_source}
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
                {data_source}
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
                {data_source}
                GROUP BY csog.grievance_cat_id
            ) table7 ON table0.grievance_cat_id = table7.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (4);
            
           
           
           
           
with latest_row as (
	select * from (
	select row_number() over(partition by grievance_id order by assigned_on desc) as rnn,  * 
		from grievance_lifecycle gl
	where gl.assigned_by_office_id = 2 and gl.grievance_status IN (4, 5, 6, 13, 14, 15)) a where rnn = 1  
),
return_for_review as (
	select count(1) as atr_returned_for_review from (
	select row_number() over(partition by grievance_id order by assigned_on desc) as rnn,  * 
		from grievance_lifecycle gl
	where gl.assigned_by_office_id = 2 and gl.grievance_status = 6 ) a where rnn = 1
)
	select count(1) as grievances_forwarded, com.office_name,
		COALESCE(SUM(CASE WHEN gm.status = 15 and gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
		COALESCE(SUM(CASE WHEN gm.status = 15 and gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
		COALESCE(SUM(CASE WHEN gm.status = 15 and gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
		COALESCE(SUM(CASE WHEN gm.status = 15 and gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id THEN 1 ELSE 0 END), 0) AS total_disposed,
		COALESCE(SUM(CASE WHEN gm.assigned_by_office_id = 2 and gm.status in (1, 2, 14, 15, 16, 17) THEN 1 ELSE 0 END), 0) AS pending,
		return_for_review.atr_returned_for_review
from latest_row
cross join return_for_review
inner join grievance_master gm on gm.grievance_id = latest_row.grievance_id
inner join cmo_office_master com on com.office_id = latest_row.assigned_by_office_id
group by com.office_name, return_for_review.atr_returned_for_review;




WITH latest_row AS (
    SELECT COUNT(a.grievance_id) AS grievances_forwarded, a.assigned_to_office_id, a.assigned_by_office_id
	    FROM(select gl.assigned_to_office_id, gl.assigned_by_office_id, gl.grievance_status, gl.grievance_id,
	    	ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn 
	        FROM grievance_lifecycle gl
	        WHERE gl.assigned_by_office_id = 2 AND gl.grievance_status IN (4, 5, 6, 13, 14, 15)
	    ) a 
    WHERE rnn = 1     
    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
),
return_for_review AS (
    SELECT COUNT(a.grievance_id) AS atr_returned_for_review, a.assigned_to_office_id, a.assigned_by_office_id
	    FROM (select gl.assigned_to_office_id, gl.assigned_by_office_id, gl.grievance_status, gl.grievance_id,
	    	ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn
	        FROM grievance_lifecycle gl
	        WHERE gl.assigned_by_office_id = 2 AND gl.grievance_status = 6 
	    ) a 
    WHERE rnn = 1 
    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
)
SELECT  
    com.office_name,
    latest_row.grievances_forwarded,
    latest_row.assigned_to_office_id,
    latest_row.assigned_by_office_id,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id THEN 1 ELSE 0 END), 0) AS total_disposed,
    COALESCE(SUM(CASE WHEN gm.assigned_by_office_id = 2 AND gm.status IN (1, 2, 14, 15, 16, 17) THEN 1 ELSE 0 END), 0) AS pending,
    return_for_review.atr_returned_for_review
FROM latest_row 
left join return_for_review on return_for_review.assigned_to_office_id = latest_row.assigned_to_office_id
left JOIN grievance_master gm ON gm.grievance_id = latest_row.grievances_forwarded
left JOIN cmo_office_master com ON com.office_id = latest_row.assigned_to_office_id
where gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-02'
GROUP BY 
    com.office_name, 
    grievances_forwarded,
    atr_returned_for_review, 
    latest_row.assigned_to_office_id,
    latest_row.assigned_by_office_id;


   
  select count(distinct gm.grievance_id) from grievance_master gm where gm.status = 15 and gm.closure_reason_id in (1,5,9) and gm.atr_submit_by_lastest_office_id = 2;
  select count(distinct gl.grievance_id) from grievance_lifecycle gl where gl.grievance_status = 16 and gl.assigned_by_office_id = 2;
  
 
 
  WITH latest_row AS (
    SELECT 
        COUNT(a.grievance_id) AS grievances_forwarded, 
        a.assigned_to_office_id, 
        a.assigned_by_office_id
    FROM (
        SELECT 
            gl.assigned_to_office_id, 
            gl.assigned_by_office_id, 
            gl.grievance_status, 
            gl.grievance_id,
            ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn
        FROM grievance_lifecycle gl
        WHERE gl.assigned_by_office_id = 2 AND gl.grievance_status IN (4, 5, 6, 13, 14, 15)
    ) a 
    WHERE a.rnn = 1     
    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
),
return_for_review AS (
    SELECT 
        COUNT(a.grievance_id) AS atr_returned_for_review, 
        a.assigned_to_office_id, 
        a.assigned_by_office_id
    FROM (
        SELECT 
            gl.assigned_to_office_id, 
            gl.assigned_by_office_id, 
            gl.grievance_status, 
            gl.grievance_id,
            ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn
        FROM grievance_lifecycle gl
        WHERE gl.assigned_by_office_id = 2 AND gl.grievance_status = 6 
    ) a 
    WHERE a.rnn = 1
    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
)
SELECT  
    com.office_name,
    latest_row.grievances_forwarded,
    latest_row.assigned_to_office_id,
    latest_row.assigned_by_office_id,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id THEN 1 ELSE 0 END), 0) AS total_disposed,
    COALESCE(SUM(CASE WHEN gm.assigned_by_office_id = 2 AND gm.status IN (1, 2, 14, 15, 16, 17) THEN 1 ELSE 0 END), 0) AS pending,
    return_for_review.atr_returned_for_review
FROM latest_row 
LEFT JOIN return_for_review ON return_for_review.assigned_to_office_id = latest_row.assigned_to_office_id
LEFT JOIN grievance_master gm ON gm.grievance_id = latest_row.grievances_forwarded  -- This line may need adjustment
LEFT JOIN cmo_office_master com ON com.office_id = latest_row.assigned_to_office_id
GROUP BY 
    com.office_name, 
    latest_row.grievances_forwarded,
    return_for_review.atr_returned_for_review,  -- Qualify this column
    latest_row.assigned_to_office_id,
    latest_row.assigned_by_office_id; 
   
   
   
   


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
            from grievance_master gm
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where grievance_lifecycle.grievance_status in (4,5,6,13,14,15)
--            and gm.grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP

            ) a
            inner join grievance_master gm on gm.grievance_id = a.grievance_id
            where rn = 1 and a.assigned_by_office_id = 2
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
            from grievance_master gm
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where grievance_lifecycle.grievance_status = 15
--            and gm.grievance_generate_date between CURRENT_TIMESTAMP and date (CURRENT_TIMESTAMP) - interval '1 month'
            ) a
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id
            where rn = 1 and a.assigned_by_office_id = 2
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
            from grievance_master gm
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where grievance_lifecycle.grievance_status not in (1,2,14,15,16,17)
--            and gm.grievance_generate_date between CURRENT_TIMESTAMP and date (CURRENT_TIMESTAMP) - interval '1 month'
                ) a
        INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
        WHERE rn = 1 and a.assigned_by_office_id = 2
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
--            and gm.grievance_generate_date between CURRENT_TIMESTAMP and date (CURRENT_TIMESTAMP) - interval '1 month'
            ) a
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id
            where rn = 1 and a.assigned_by_office_id = 2
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


select COUNT(DISTINCT gl.grievance_id) from grievance_lifecycle gl ; -- 39878239 / 3865013
select COUNT(DISTINCT gm.grievance_id) from grievance_master gm; --- 3865034



SELECT
    com.office_name AS office_name,
--    com.office_id,
    gl.assigned_to_office_id,
    COALESCE(SUM(CASE WHEN gl.grievance_status IN (4, 5, 6, 13, 14, 15) THEN 1 ELSE 0 END), 0) AS grievances_forwarded,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 and gm.atr_submit_by_lastest_office_id = gl.assigned_by_office_id and gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 AND gm.atr_submit_by_lastest_office_id = gl.assigned_by_office_id and gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 AND gm.atr_submit_by_lastest_office_id = gl.assigned_by_office_id and gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 and gm.atr_submit_by_lastest_office_id = gl.assigned_by_office_id THEN 1 ELSE 0 END), 0) AS total_disposed,
    COALESCE(SUM(CASE WHEN gl.grievance_status NOT IN (1, 2, 14, 15, 16, 17) THEN 1 ELSE 0 END), 0) AS pending,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 6 THEN 1 ELSE 0 END), 0) AS atr_returned_for_review
FROM
    grievance_master gm
JOIN
    grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
JOIN
    cmo_office_master com ON com.office_id = gl.assigned_to_office_id
WHERE
    gm.grievance_generate_date BETWEEN '2019-01-01' and '2024-11-25'
--    {griv_stat}
--    {data_source}
    AND gl.assigned_by_office_id  = 2
GROUP BY
    com.office_name, 
	gl.assigned_to_office_id;
	


SELECT
    com.office_name AS office_name,
--    com.office_id,
    gl.assigned_to_office_id,
    COALESCE(SUM(CASE WHEN gl.grievance_status IN (4, 5, 6, 13, 14, 15) and gl.assigned_by_office_id = 2 THEN 1 ELSE 0 END), 0) AS grievances_forwarded,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 and gm.atr_submit_by_lastest_office_id = 2 and gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 AND gm.atr_submit_by_lastest_office_id = 2 and gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 AND gm.atr_submit_by_lastest_office_id = 2 and gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 15 and gm.atr_submit_by_lastest_office_id = 2 THEN 1 ELSE 0 END), 0) AS total_disposed,
    COALESCE(SUM(CASE WHEN gl.grievance_status NOT IN (1, 2, 14, 15, 16, 17) and gm.atr_submit_by_lastest_office_id = 2 THEN 1 ELSE 0 END), 0) AS pending,
    COALESCE(SUM(CASE WHEN gl.grievance_status = 6 and gl.assigned_by_office_id = 2 THEN 1 ELSE 0 END), 0) AS atr_returned_for_review
FROM
    grievance_master gm
JOIN
    grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
JOIN
    cmo_office_master com ON com.office_id = gl.assigned_to_office_id
WHERE
    gm.grievance_generate_date BETWEEN '2019-01-01' and '2024-11-25'
--    AND gl.assigned_by_office_id  = 2
GROUP BY
    com.office_name, 
	gl.assigned_to_office_id;
	


select count(distinct gl.grievance_id) as grievances_forwarded, com.office_name, gl.assigned_to_office_id, gl.assigned_by_office_id 
from grievance_lifecycle gl 
inner join cmo_office_master com on com.office_id = gl.assigned_by_office_id 
where gl.assigned_by_office_id = 2 and gl.assigned_to_office_id = 2
and gl.grievance_status in (4, 5, 6, 13, 14, 15)
group by com.office_name, gl.assigned_to_office_id, gl.assigned_by_office_id;


------------------------------------------ hod break ------------------------------------------------------------------------------
select count(distinct gl.grievance_id) as frwd, gl.assigned_to_office_id, com.office_name
from grievance_lifecycle gl 
inner join cmo_office_master com on com.office_id = gl.assigned_to_office_id 
where gl.assigned_by_office_id = 2 and gl.assigned_to_office_id != 2     ---242471
and gl.grievance_status in (4, 5, 6, 13, 14, 15)   ----120520
group by 
	gl.assigned_to_office_id, com.office_name ; --- 122025


select count(distinct gl.grievance_id) as benefit_service_provided, gl.assigned_to_office_id, com.office_name
from grievance_lifecycle gl 
inner join cmo_office_master com on com.office_id = gl.assigned_to_office_id 
inner join grievance_master gm on gm.atr_submit_by_lastest_office_id = gl.assigned_by_office_id 
where gm.atr_submit_by_lastest_office_id = 2 and gl.assigned_to_office_id != 2     ---242471
and gm.status = 15
and gm.closure_reason_id = 1
group by 
	gl.assigned_to_office_id, com.office_name;	  
	

select count(distinct gl.grievance_id) as action_taken, gl.assigned_to_office_id, com.office_name
from grievance_lifecycle gl 
inner join cmo_office_master com on com.office_id = gl.assigned_to_office_id 
inner join grievance_master gm on gm.atr_submit_by_lastest_office_id = gl.assigned_by_office_id 
where gm.atr_submit_by_lastest_office_id = 2 and gl.assigned_to_office_id != 2     ---242471
and gm.status = 15
and gm.closure_reason_id IN (5, 9)
group by 
	gl.assigned_to_office_id, com.office_name;
	
	
	
	
	
	
	
	
	
	
SELECT  
            table0.grievance_cat_id,
            table0.admin_user_id,
            table0.office_id,
            table0.suboffice_id,
            COALESCE(table0.grievance_category_desc) AS grievance_category_desc,
            COALESCE(table0.official_name) AS office_name,
            COALESCE(table0.suboffice_name) AS suboffice_name,
            CAST(COALESCE(SUM(table1.grv_assigned), 0) AS INTEGER) AS grievances_assigned,
            CAST(COALESCE(SUM(table2.bnft_prvd), 0) AS INTEGER) AS benefit_service_provided,
            CAST(COALESCE(SUM(table3.action_taken), 0) AS INTEGER) AS action_taken,
            CAST(COALESCE(SUM(table4.not_elgbl), 0) AS INTEGER) AS not_elgbl,
            CAST(COALESCE(SUM(table5.total_received), 0) AS INTEGER) AS total_received,
            CAST(COALESCE(SUM(table6.beyond_svn_days), 0) AS INTEGER) AS beyond_svn_days,
            CAST(COALESCE(SUM(table6.atr_pndg), 0) AS INTEGER) AS cumulative_pendency,
            CAST(COALESCE(SUM(table7.atr_review), 0) AS INTEGER) AS atr_return_for_review_to_so_user 
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
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
            AND csog.status IN (8,9,11,12,14,15,16,17,4)
            
            GROUP BY csog.grievance_cat_id 
        ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id 
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS bnft_prvd
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
            AND csog.status IN (4,9,11,12,16,14,15,17) 
            AND csog.closure_reason_id = 1
            
            GROUP BY csog.grievance_cat_id
        ) table2 ON table2.grievance_cat_id = table0.grievance_cat_id 
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS action_taken
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
            AND csog.status IN (4,9,11,12,16,14,15,17) 
            AND csog.closure_reason_id IN (5,9)
            
            GROUP BY csog.grievance_cat_id
        ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS not_elgbl
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
            AND csog.status IN (4,9,11,12,16,14,15,17) 
            AND csog.closure_reason_id NOT IN (1,5,9)
            
            GROUP BY csog.grievance_cat_id
        ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS total_received
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
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
            AND csog.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
            
            GROUP BY csog.grievance_cat_id
        ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id 
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS atr_review
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
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
            
           
           
       SELECT  
            table0.grievance_cat_id,
            table0.admin_user_id,
            table0.office_id,
            table0.suboffice_id,
            COALESCE(table0.grievance_category_desc) AS grievance_category_desc,
            COALESCE(table0.official_name) AS office_name,
            COALESCE(table0.suboffice_name) AS suboffice_name,
            CAST(COALESCE(SUM(table1.grv_assigned), 0) AS INTEGER) AS grievances_assigned,
            CAST(COALESCE(SUM(table2.bnft_prvd), 0) AS INTEGER) AS benefit_service_provided,
            CAST(COALESCE(SUM(table3.action_taken), 0) AS INTEGER) AS action_taken,
            CAST(COALESCE(SUM(table4.not_elgbl), 0) AS INTEGER) AS not_elgbl,
            CAST(COALESCE(SUM(table5.total_received), 0) AS INTEGER) AS total_received,
            CAST(COALESCE(SUM(table6.beyond_svn_days), 0) AS INTEGER) AS beyond_svn_days,
            CAST(COALESCE(SUM(table6.atr_pndg), 0) AS INTEGER) AS cumulative_pendency,
            CAST(COALESCE(SUM(table7.atr_review), 0) AS INTEGER) AS atr_return_for_review_to_so_user 
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
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
            AND csog.status IN (8,9,11,12,14,15,16,17,4)
            
            GROUP BY csog.grievance_cat_id 
        ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id 
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS bnft_prvd
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
            AND csog.status IN (4,9,11,12,16,14,15,17) 
            AND csog.closure_reason_id = 1
            
            GROUP BY csog.grievance_cat_id
        ) table2 ON table2.grievance_cat_id = table0.grievance_cat_id 
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS action_taken
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
            AND csog.status IN (4,9,11,12,16,14,15,17) 
            AND csog.closure_reason_id IN (5,9)
            
            GROUP BY csog.grievance_cat_id
        ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS not_elgbl
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
            AND csog.status IN (4,9,11,12,16,14,15,17) 
            AND csog.closure_reason_id NOT IN (1,5,9)
            
            GROUP BY csog.grievance_cat_id
        ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS total_received
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
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
            AND csog.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
            
            GROUP BY csog.grievance_cat_id
        ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id 
        LEFT JOIN (
            SELECT 
                csog.grievance_cat_id,
                COUNT(1) AS atr_review
            FROM cat_sub_offc_griv csog
            WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
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
            
           
           
           
           
           
           
select row_number() over(partition by grievance_id order by assigned_on desc) as rnn,  * 
	from grievance_lifecycle gl
where gl.assigned_by_office_id = 2 and gl.grievance_status = 5 and gl.grievance_id = 2871519;
	

select * from grievance_lifecycle gl where gl.grievance_id = 2871519 order by assigned_on ;





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
           
          
          
          
