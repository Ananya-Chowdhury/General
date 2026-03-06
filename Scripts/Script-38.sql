------------------ HoD all griverance Tuned ------------------

WITH received_grievances AS (
                    SELECT 
                        a.assigned_to_office_id, 
                        COUNT(a.grievance_id) AS grv_rcvd  
                    FROM 
                        (
                        SELECT 
                            glc.grievance_id, 
                            glc.grievance_status, 
                            glc.assigned_to_office_id, 
                            glc.assigned_by_office_id, 
                            ROW_NUMBER() OVER ( PARTITION BY glc.grievance_id ORDER BY glc.assigned_on DESC) AS rn
                        FROM grievance_lifecycle glc
                        WHERE(
                                (glc.assigned_to_office_id = 
                                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
                                AND glc.grievance_status NOT IN (1, 2))
                                or
                                (glc.assigned_to_office_id != 
                                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
                                AND glc.grievance_status NOT IN (1, 2, 3, 14))
                            )) a 
                    where rn = 1 AND a.assigned_by_office_id = 3
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
                            AND gm.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
--                            {data_source}
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
                            AND gm.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
--                            {data_source}
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
                        AND gm.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
--                        {data_source}
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
                where gm.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
--             {data_source}
                ORDER BY 
                    CASE 
                        WHEN com.office_name = 'Chief Minister''s Office' THEN 0
                        ELSE 1 
                    END, 
                    com.office_name;
                    
 
 SELECT 
    COUNT(1) AS frd, 
    glc.assigned_to_office_id, 
    com.office_name, 
    glc.assigned_by_office_id 
FROM grievance_lifecycle glc 
INNER JOIN cmo_office_master com 
    ON com.office_id = glc.assigned_to_office_id 
WHERE 
    (SELECT 
    	glc.grievance_id,
    	glc.assigned_to_office_id,
    CASE
        WHEN glc.assigned_to_office_id = 5 and glc.grievance_status not in (1,2) then
        ELSE glc.grievance_status not in (1,2,3,14)
    END AS office_category
FROM grievance_lifecycle glc;
    )
    AND glc.assigned_by_office_id = 3
GROUP BY 
    glc.assigned_to_office_id, 
    com.office_name, 
    glc.assigned_by_office_id;

                   

                   
                   
 WITH latest_row AS (
	    SELECT 
	    	COUNT(a.grievance_id) AS grievances_forwarded, 
	    	a.assigned_to_office_id, 
	    	a.assigned_by_office_id
		FROM(select 
				gl.assigned_to_office_id, 
				gl.assigned_by_office_id, 
				gl.grievance_status, 
				gl.grievance_id,
		    	ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn 
		     FROM grievance_lifecycle gl
		     WHERE gl.assigned_by_office_id = 2 
		     AND gl.grievance_status IN (4, 5, 6, 13, 14, 15)
		     and gl.assigned_to_office_id != 2
		    ) a 
	    WHERE rnn = 1     
	    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
	),
	return_for_review AS (
	    SELECT 
	    	COUNT(a.grievance_id) AS atr_returned_for_review, 
	    	a.assigned_to_office_id, 
	    	a.assigned_by_office_id
		FROM(select 
				gl.assigned_to_office_id, 
				gl.assigned_by_office_id, 
				gl.grievance_status, 
				gl.grievance_id,
		    	ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn
		     FROM grievance_lifecycle gl
		     WHERE gl.assigned_by_office_id = 2 
		     AND gl.grievance_status = 6 
		     and gl.assigned_to_office_id != 2
		    ) a 
	    WHERE rnn = 1 
	    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
	)
	SELECT  
	    com.office_name,
	    latest_row.assigned_to_office_id,
	    latest_row.assigned_by_office_id,
	    latest_row.grievances_forwarded,
	    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
	    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
	    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
	    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id THEN 1 ELSE 0 END), 0) AS total_disposed,
	    COALESCE(SUM(CASE WHEN gm.assigned_by_office_id = 2 AND gm.status IN (1, 2, 14, 15, 16, 17) THEN 1 ELSE 0 END), 0) AS pending,
	    return_for_review.atr_returned_for_review
	FROM latest_row 
	left join return_for_review on return_for_review.assigned_to_office_id = latest_row.assigned_to_office_id
	left JOIN grievance_master gm ON gm.assigned_to_office_id = latest_row.assigned_to_office_id
	left JOIN cmo_office_master com ON com.office_id = latest_row.assigned_to_office_id
	where gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-02'
	GROUP BY 
	    com.office_name, 
	    latest_row.grievances_forwarded,
	    return_for_review.atr_returned_for_review, 
	    latest_row.assigned_to_office_id,
	    latest_row.assigned_by_office_id;
	    
	   
	   
select count (gm.grievance_id) from grievance_master gm where gm.state_id = 15 and gm.assigned_by_office_id = 2;

select count(gl.grievance_id) from grievance_lifecycle gl where gl.grievance_status = 6 and gl.assigned_by_office_id = 2 and assigned_to_office_id != 2;

-- 674
select distinct gl.assigned_by_position from grievance_lifecycle gl where /*gl.assigned_by_position = 674 and*/ gl.grievance_status in (9,10,8); 
select distinct count(1) from grievance_lifecycle gl where gl.assigned_by_position = 951 and gl.grievance_status in (9,10,8); 

--------------------- HOSO 2 Part 1 Tuned -------------------
with cte1 as (
	select a.assigned_to_id, a.grievance_id, a.assigned_on from (
		select row_number() over(partition by grievance_id order by assigned_on desc) as rnn,  
			   assigned_to_id, grievance_id, assigned_on 
		from grievance_lifecycle gl 
		where gl.grievance_status in (8,10) and gl.assigned_by_position = 3995
	)a 
--	inner join grievance_master gm on gm.grievance_id = a.grievance_id and gm.grievance_source in (5)
	where a.rnn = 1
), cte2 as (
	select assigned_by_id, count(1) as atr_count, sum(case when atn_id = 6 then 1 else 0 end) as bnft_provided,
		   sum(case when atn_id IN (9,12) then 1 else 0 end) as actn_intiated, sum(case when atn_id NOT IN (6,9,12) then 1 else 0 end) as non_actnable  
	from (
		select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, assigned_by_id, atn_id
		from grievance_lifecycle gl 
		where gl.grievance_status = 9 and gl.assigned_to_position = 3995 
	)a where a.rnn = 1 group by 1
),cte3 as (
	select assigned_to_id , count(1) as send_for_review from grievance_lifecycle gl where gl.grievance_status = 10 and gl.assigned_by_position = 3995 group by 1
)
select aud.official_name, cte1.assigned_to_id, coalesce(count(cte1.assigned_to_id),0) as no_of_assigned, coalesce(cte2.atr_count,0) as atr_count,
	   coalesce(cte2.bnft_provided,0) as bnft_provided, coalesce(cte2.actn_intiated,0) as actn_intiated, coalesce(cte2.non_actnable,0) as non_actnable,
	   sum(case when gm.status in (8,10) then 1 else 0 end) as pending_count,
	   sum(case when pndg.days_diff > 7 then 1 else 0 end) as beyond_7_days,
	   coalesce(cte3.send_for_review,0) as send_for_review
from cte1
left join cte2 on cte1.assigned_to_id = cte2.assigned_by_id
left join cte3 on cte1.assigned_to_id = cte3.assigned_to_id
left join grievance_master gm on gm.grievance_id = cte1.grievance_id
left join pending_for_so_user_wise pndg on gm.grievance_id = pndg.grievance_id
left join admin_user_details aud on aud.admin_user_id = cte1.assigned_to_id
--where assigned_on::date between '2024-12-01' and '2024-12-02' 
group by aud.official_name, cte1.assigned_to_id, cte2.atr_count, cte2.bnft_provided, cte2.actn_intiated, cte2.non_actnable, cte3.send_for_review;


--drop view if exists public.cat_offc_grievances;

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
    gm.updated_on,
    gm.grievance_source,
    cm.benefit_scheme_type,
    gm.status,
    cm.status AS grievance_category_status
   FROM cmo_grievance_category_master cm
     LEFT JOIN grievance_master gm ON cm.grievance_cat_id = gm.grievance_category
     LEFT JOIN cmo_office_master om ON om.office_id = cm.parent_office_id
  WHERE cm.status = 1;
  
 
 select atn_id from grievance_lifecycle gl ;
 
 with latest_14_atn as (
 	select atn_id, grievance_id from (
 		select row_number() over(partition by gl.grievance_id order by assigned_on desc) as rnnn, gl.atn_id, gl.grievance_id
 			from grievance_lifecycle gl 
 		where gl.grievance_status = 14)a
 	where a.rnnn = 1
 ) select count(1) from latest_14_atn ;
 