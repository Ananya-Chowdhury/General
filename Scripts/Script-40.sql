 ------ mIs HOD bhandari da --------
 WITH assigned_grievances AS (
            select 
                a.assigned_to_position,
                a.assigned_to_office_id,
                a.assigned_by_office_id,
                count(distinct a.grievance_id) as grv_assigned  
            from 
                (SELECT 
                    grievance_lifecycle.grievance_id, 
                    grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    grievance_lifecycle.assigned_by_office_id,
                    row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_lifecycle
                    where grievance_lifecycle.grievance_status in (4,8,9,10,11,12,14,15,16)
                    ) a 
--                    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_by_office_id = 68  
                    group by a.assigned_to_position, a.assigned_to_office_id, a.assigned_by_office_id
                ),
        atr_submitted_to_hoso AS (
                    select 
                        a.assigned_to_position, 
                        a.assigned_to_office_id,
                		a.assigned_by_office_id,
                        count(distinct a.grievance_id) as total_submitted,
                        sum(case when a.grievance_status in (9,10,11,12,14,15) and a.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                        sum(case when a.grievance_status in (9,10,11,12,14,15) and a.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
                        sum(case when a.grievance_status in (9,10,11,12,14,15) and a.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
                    from 
                        (SELECT 
                            grievance_lifecycle.grievance_id, 
                            grievance_lifecycle.assigned_to_position,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.closure_reason_id,
                            grievance_lifecycle.assigned_by_office_id,
                            row_number() over (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_lifecycle
                    where grievance_lifecycle.grievance_status in (9,10,11,12,14,15) 
                    ) a 
                    where rn = 1 and a.assigned_to_office_id = 68   
                    group by a.assigned_to_position, a.assigned_to_office_id, a.assigned_by_office_id
                ),
		 atr_pending AS (
			    SELECT 
			        a.assigned_to_position, 
			        a.assigned_to_office_id,
			        COUNT(distinct a.grievance_id) AS atr_pndg,
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
			            and (case 
                            when gm.status = 1 then gm.grievance_generate_date::date 
                            else gm.updated_on::date 
                        end) between '2019-01-01' and '2024-12-06' 
					) a
			    INNER JOIN 
			        grievance_master gm ON gm.grievance_id = a.grievance_id
			    WHERE 
			        rn = 1 AND a.assigned_to_office_id = 68    
			    GROUP BY 
			        a.assigned_to_position, a.assigned_to_office_id
				)
                select  
                    aud.official_name as office_name, 
                    gm.assigned_to_office_id,
                    csom.suboffice_name, 
    				csom.suboffice_code,
    				apm.sub_office_id,
                    sum(coalesce(CAST(ag.grv_assigned AS INTEGER), 0)) as grievances_assigned,
                    sum(coalesce(CAST(asth.bnft_prvd AS INTEGER), 0)) as benefit_service_provided,
                    sum(coalesce(CAST(asth.action_taken AS INTEGER), 0)) as action_taken,
                    sum(coalesce(CAST(asth.not_elgbl AS INTEGER), 0)) as not_elgbl,
                    sum(coalesce(CAST(asth.total_submitted AS INTEGER), 0)) as total_submitted,
                    sum(coalesce(CAST(ap.beyond_svn_days AS INTEGER), 0)) as beyond_svn_days,
                    sum(coalesce(CAST(ap.atr_pndg AS INTEGER), 0)) as cumulative_pendency
                 FROM cmo_sub_office_master csom
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
				    and apm.office_id = 68
				    and apm.sub_office_id = 4004
				    and (case 
	                        when gm.status = 1 then gm.grievance_generate_date::date 
	                        else gm.updated_on::date 
                    end) between '2019-01-01' and '2024-12-06' 
				 group by 
                	aud.official_name,
				 	csom.suboffice_code,
                	gm.assigned_to_office_id,
                    csom.suboffice_name,
    				apm.sub_office_id;  
    			
    			
 --------------- bhandari da query structure ----------------------			
 with cte1 as (
            select  a.grievance_id, a.assigned_on, a.assigned_by_office_id, a.assigned_to_office_id from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, 
                        assigned_by_office_id, assigned_on ,grievance_id, gl.assigned_to_office_id
                    from grievance_lifecycle gl where gl.grievance_status in (3,5) and gl.assigned_to_office_id = {office}
                and assigned_on::date between {from_date} and {to_date}
            )a 
            {data_source}
            where a.rnn = 1
        ),cte2 as (
            select a.assigned_to_office_id, count(1) as atr_sent, sum(case when atn_id = 6 then 1 else 0 end) as bnft_provided,
                sum(case when atn_id IN (9,12) then 1 else 0 end) as actn_intiated, sum(case when atn_id NOT IN (6,9,12) then 1 else 0 end) as non_actnable  
                from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, assigned_to_office_id,atn_id
                        from grievance_lifecycle gl 
                    where gl.grievance_status in (14,13) and gl.assigned_by_office_id = {office}
                        and assigned_on::date between {from_date} and {to_date}
            )a 
            where a.rnn = 1 group by 1
        ),cte3 as (
            select assigned_by_office_id, count(1) as review_send
            from grievance_lifecycle gl where gl.grievance_status = 6 and gl.assigned_to_office_id = {office}
                and assigned_on::date between {from_date} and {to_date}
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
    			
    			
    			
    			
    			
    			
    			
    			
    			
    			
    			
 select count(1) from grievance_lifecycle gl where  ;
select * from cmo_sub_office_master csom where csom.suboffice_id = 4004 /*csom.office_id = 1*/;
select * from admin_position_master apm where apm.sub_office_id = 4004;
select * from admin_user_position_mapping aupm where aupm.position_id = 4144;
 select * from cmo_office_master com where com.office_id = 1;
  select * from admin_user_details aud where aud.admin_user_id = 4144;
    		
 select * from grievance_lifecycle gl limit 1;
 
 select count(1) from pg_stat_activity;

select * from pg_locks;
 select * from pg_stat_activity;

 select pg_stat_activity.query , count(1)
from pg_stat_activity
inner join pg_locks on pg_locks.pid = pg_stat_activity.pid 
group by 1;
 
                   
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
        WHERE gl.assigned_by_office_id = 1 
        AND gl.grievance_status IN (4, 5, 6, 13, 14, 15)
        AND gl.assigned_to_office_id != 1
    ) a 
    WHERE rnn = 1     
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
        WHERE gl.assigned_by_office_id = 1 
        AND gl.grievance_status = 6 
        AND gl.assigned_to_office_id != 1
    ) a 
    WHERE rnn = 1 
    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
)
SELECT  
    COALESCE(com.office_name, 'Unknown') AS office_name,  -- Replace NULL with 'Unknown'
    latest_row.assigned_to_office_id,
    latest_row.assigned_by_office_id,
    latest_row.grievances_forwarded AS grievances_forwarded,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id THEN 1 ELSE 0 END), 0) AS total_disposed,
    COALESCE(SUM(CASE WHEN gm.assigned_by_office_id = 1 AND gm.status IN (1, 2, 14, 15, 16, 17) THEN 1 ELSE 0 END), 0) AS pending,
    return_for_review.atr_returned_for_review AS atr_returned_for_review
FROM latest_row 
LEFT JOIN return_for_review ON return_for_review.assigned_to_office_id = latest_row.assigned_to_office_id
LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = latest_row.assigned_to_office_id
LEFT JOIN cmo_office_master com ON com.office_id = latest_row.assigned_to_office_id
    AND (CASE 
            WHEN gm.status = 1 THEN gm.grievance_generate_date::date 
            ELSE gm.updated_on::date 
        END) BETWEEN '2019-01-01' AND '2024-12-06'
    AND gm.grievance_source IN (5)
WHERE com.office_name IS NOT NULL  -- This filters out rows with NULL office_name
GROUP BY 
    com.office_name, 
    latest_row.grievances_forwarded,
    return_for_review.atr_returned_for_review, 
    latest_row.assigned_to_office_id,
    latest_row.assigned_by_office_id;

   