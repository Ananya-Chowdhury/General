select * from public.cmo_grievance_counts(0,0);

select 
	count(1) as grievances_recieved
	from grievance_master gm; --4363461

select  
	COUNT(1) as grievances_forwarded 
	from forwarded_latest_3_bh_mat bm; /*where bm.grievance_source = 5*/  --4089255 4090493

--explain select
select
	count(1) as atr_recieved
	from atr_latest_14_bh_mat bh
	inner join forwarded_latest_3_bh_mat bm on bm.grievance_id = bh.grievance_id
	where bh.current_status in (14,15); --3190017


select
	count(1) as atr_pending
	from forwarded_latest_3_bh_mat bm
--	inner join forwarded_latest_3_bh_mat bm on bm.grievance_id = bh.grievance_id
	where not exists (select 1 from atr_latest_14_bh_mat bh where bm.grievance_id = bh.grievance_id); --859026
	
SELECT 
	COUNT(1) AS atr_pending
	FROM forwarded_latest_3_bh_mat bm
    WHERE NOT EXISTS (SELECT 1 FROM atr_latest_14_bh_mat bh WHERE bm.grievance_id = bh.grievance_id and bh.current_status in (14,15)); --1005756
	

select 
	count(1) as disposed
	from grievance_master gm 
	where gm.status = 15; --3294372 

	
	
select count(1) as disposed 
from atr_latest_14_bh_mat bh 
where bh.current_status = 15 ; -- 3231956
	

select Count(1) as disposed 
from direct_close_bh_mat bh; -- 31972

       
-- total dis = 3230276, dirct clos = 41598, diffrence = 3188678, 

---------------------------------------------------------------------- Testing purpose ---------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------
------------- total count dashboard ----------------
with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt FROM grievance_master
), grievances_forwarded as (
	SELECT COUNT(1) as grievances_forwarded_cnt FROM forwarded_latest_3_bh_mat 
), atr_recieved as (
	SELECT COUNT(1) as atr_recieved FROM atr_latest_14_bh_mat 
	INNER JOIN forwarded_latest_3_bh_mat ON atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id 
	where atr_latest_14_bh_mat.current_status in (14,15)
), atr_pending as (
	SELECT COUNT(1) as atr_pending FROM forwarded_latest_3_bh_mat bm
--	inner join pending_for_hod_wise_mat mp on bm.grievance_id = bm.grievance_id
     WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat bh WHERE bm.grievance_id = bh.grievance_id and bh.current_status in (14,15))
), disposed as (
	SELECT COUNT(1) as disposed FROM grievance_master gm 
	inner join forwarded_latest_3_bh_mat bm on gm.grievance_id = bm.grievance_id 
	WHERE gm.status = 15
) select * 
from grievances_recieved
cross join grievances_forwarded
cross join atr_recieved
cross join atr_pending
cross join disposed;


close_count as (
    select atr_submit_by_lastest_office_id, count(1) as _close_ 
    from grievance_master gm 
    inner join forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        where gm.status = 15 /******* filter *********//* {f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }*/
    group by atr_submit_by_lastest_office_id 


--------------------------------------------------------- dashboard HOD total count for perticular office & ssm ---------------------------------------------------------------
with grievances_recieved as (
		SELECT COUNT(1) as grievances_recieved_cnt FROM forwarded_latest_3_bh_mat bh
		where /*bh.grievance_source = 5 and*/ bh.assigned_to_office_id = 3
), atr_sent as (
	SELECT COUNT(1) as atr_sent_cnt, 
	sum(case when bm.current_status = 15 then 1 else 0 end) as disposed_cnt,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
	FROM atr_latest_14_bh_mat bm
	inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id 
	where bm.current_status in (14,15) /*and bm.grievance_source = 5*/ and bm.assigned_by_office_id = 3
), atr_pending as (
	SELECT COUNT(1) as atr_pending_cnt FROM forwarded_latest_3_bh_mat bh
     WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5*/ and bh.assigned_to_office_id = 3 
) select * 
from grievances_recieved
cross join atr_sent
cross join atr_pending;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    (SELECT COUNT(1) FROM grievance_master gm) AS grievances_recieved,
    (SELECT COUNT(1) FROM forwarded_latest_3_bh_mat bm) AS grievances_forwarded,
    (SELECT COUNT(1) FROM atr_latest_14_bh_mat bh INNER JOIN forwarded_latest_3_bh_mat bm ON bm.grievance_id = bh.grievance_id 
    	where bh.current_status in (14,15)) AS atr_recieved,
    (SELECT COUNT(1) FROM forwarded_latest_3_bh_mat bm
     WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat bh WHERE bm.grievance_id = bh.grievance_id and bh.current_status in (14,15))) AS atr_pending,
    (SELECT COUNT(1) FROM grievance_master gm WHERE gm.status = 15) AS disposed;
   
   
 select atr_latest_14_bh_mat.assigned_by_office_id, count(1) as _atr_ , avg(pending_for_hod_wise_last_six_months_mat.days_diff) as _six_avg_atr_pnd_ 
            from atr_latest_14_bh_mat 
            inner join forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
            left join pending_for_hod_wise_last_six_months_mat on atr_latest_14_bh_mat.grievance_id = pending_for_hod_wise_last_six_months_mat.grievance_id 
            /******* filter *********/ where atr_latest_14_bh_mat.current_status in (14,15) 
            group by atr_latest_14_bh_mat.assigned_by_office_id;
                   
                   
 select atr_submit_by_lastest_office_id, count(1) as _close_ 
            from grievance_master gm 
            inner join forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                where gm.status = 15 /******* filter *********/ 
            group by atr_submit_by_lastest_office_id

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------            
               
with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt 
	FROM grievance_master gm
	where gm.grievance_source = 5 and gm.assigned_to_office_id = 3
), grievances_forwarded as (
	SELECT COUNT(1) as grievances_forwarded_cnt FROM forwarded_latest_3_bh_mat bh
	where bh.grievance_source = 5 and bh.assigned_to_office_id = 3
), atr_recieved as (
	SELECT COUNT(1) as atr_recieved FROM atr_latest_14_bh_mat bm
	INNER JOIN forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id 
	where bm.current_status in (14,15) and bm.grievance_source = 5 and bm.assigned_by_office_id = 3
), atr_pending as (
	SELECT COUNT(1) as atr_pending FROM forwarded_latest_3_bh_mat bh
     WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bh.current_status in (14,15))
     and bh.grievance_source = 5 and bh.assigned_to_office_id = 3
), disposed as (
	SELECT COUNT(1) as disposed FROM grievance_master gm
	WHERE gm.status = 15 and gm.grievance_source = 5 and gm.atr_submit_by_lastest_office_id = 3
) select * 
from grievances_recieved
cross join grievances_forwarded
cross join atr_recieved
cross join atr_pending
cross join disposed;
               
------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 


SELECT 
    COUNT(1) AS grievances_recieved_cnt 
    FROM grievance_master gm
    WHERE 
        gm.grievance_source = 5 
        AND gm.assigned_to_office_id = 3
        AND gm.grievance_generate_date >= CURRENT_DATE - INTERVAL '3 months';
 
       

WITH grievances_recieved AS (
    SELECT 
        COUNT(1) AS grievances_recieved_cnt
    FROM grievance_master gm
    WHERE gm.grievance_source = 5
        AND gm.assigned_to_office_id = 3
        AND gm.grievance_generate_date >= date_trunc('month', CURRENT_DATE - INTERVAL '3 months')
        AND gm.grievance_generate_date < date_trunc('month', CURRENT_DATE)
), grievances_forwarded AS (
    SELECT 
        COUNT(1) AS grievances_forwarded_cnt
    FROM forwarded_latest_3_bh_mat gm
    WHERE gm.grievance_source = 5
        AND gm.assigned_to_office_id = 3
        AND gm.grievance_generate_date >= date_trunc('month', CURRENT_DATE - INTERVAL '3 months')
        AND gm.grievance_generate_date < date_trunc('month', CURRENT_DATE)
), atr_recieved AS (
    SELECT 
        COUNT(1) AS atr_recieved
    FROM atr_latest_14_bh_mat gm
    INNER JOIN forwarded_latest_3_bh_mat bh ON gm.grievance_id = bh.grievance_id
    WHERE gm.current_status IN (14, 15)
        AND gm.grievance_source = 5
        AND gm.assigned_by_office_id = 3
        AND gm.grievance_generate_date >= date_trunc('month', CURRENT_DATE - INTERVAL '3 months')
        AND gm.grievance_generate_date < date_trunc('month', CURRENT_DATE)
), atr_pending AS (
    SELECT 
        COUNT(1) AS atr_pending
    FROM forwarded_latest_3_bh_mat gm
    WHERE NOT EXISTS (
            SELECT 1
            FROM atr_latest_14_bh_mat bm
            WHERE gm.grievance_id = bm.grievance_id
            and bm.current_status in (14,15)
        )
        AND gm.grievance_source = 5
        AND gm.assigned_to_office_id = 3
        AND gm.grievance_generate_date >= date_trunc('month', CURRENT_DATE - INTERVAL '3 months')
        AND gm.grievance_generate_date < date_trunc('month', CURRENT_DATE)
), disposed AS (
    SELECT 
        COUNT(1) AS disposed
    FROM grievance_master gm
    WHERE gm.status = 15
        AND gm.grievance_source = 5
        AND gm.atr_submit_by_lastest_office_id = 3
        AND gm.grievance_generate_date >= date_trunc('month', CURRENT_DATE - INTERVAL '3 months')
        AND gm.grievance_generate_date < date_trunc('month', CURRENT_DATE)
)
SELECT 
    'Previous 3 Full Months' AS duration, *
FROM 
    grievances_recieved
CROSS JOIN grievances_forwarded
CROSS JOIN atr_recieved
CROSS JOIN atr_pending
CROSS JOIN disposed;






-------------------------------------------------- dashboard month wise status ---------------------------------------------------------------------
---------------------------------- old query ------------------------------------
with generate_months as (
    SELECT 
    	EXTRACT(YEAR from generate_series( (now() - interval '3 months')::date ::date, (now() - interval '1 months')::date, '1 month')) AS converted_year,
    	EXTRACT(MONTH from generate_series( (now() - interval '3 months')::date ::date, (now() - interval '1 months')::date, '1 month')) AS converted_month
), filter_conditions as (
    select months.converted_year, months.converted_month, gm.grievance_id, gm.status, gm.assigned_by_office_id, gm.assigned_to_office_id, gm.atr_submit_by_lastest_office_id
    FROM generate_months months
    left join grievance_master gm  on EXTRACT(YEAR from gm.grievance_generate_date) = months.converted_year and EXTRACT(MONTH from gm.grievance_generate_date) = months.converted_month 
    WHERE gm.grievance_id > 0  and gm.grievance_source = 5   --and gm.grievance_source = 5
),grievance_receive as (
    select converted_year, converted_month, count(grievance_id) as gr_rec FROM filter_conditions 
    where status in (3,4,5,6,7,8,9,10,11,12,13,16,17) and assigned_to_office_id = 2  group by converted_year, converted_month
),grievance_forwarded as (
    select converted_year, converted_month, count(grievance_id) as gr_fwd FROM filter_conditions 
    where status in (5) and assigned_by_office_id = 2 group by converted_year, converted_month
),grievance_str_close_14 as (
    select converted_year, converted_month, count(grievance_id) as gr_clse FROM filter_conditions 
    where status in (14) and atr_submit_by_lastest_office_id = 2 group by converted_year, converted_month
),grievance_str_close_15 as (
    select converted_year, converted_month, count(grievance_id) as gr_clse FROM filter_conditions 
    where status in (15) and atr_submit_by_lastest_office_id = 2 group by converted_year, converted_month
),grievance_on_that_departmen as (
    select converted_year, converted_month, count(grievance_id) as gr_odpt FROM filter_conditions 
    where status in (3,4) and assigned_to_office_id = 2  group by converted_year, converted_month
)
select months.converted_year, months.converted_month,
    (coalesce(gr.gr_rec, 0) + coalesce(gf.gr_fwd, 0) + coalesce(gclose_14.gr_clse,0) + coalesce(gclose_15.gr_clse,0)) as grievance_recieved_count,
    coalesce(((coalesce(gr.gr_rec, 0) + coalesce(gf.gr_fwd, 0) + coalesce(gclose_14.gr_clse,0) + coalesce(gclose_15.gr_clse,0)) - gdpt.gr_odpt), 0) as grievance_forwarded_count,
    coalesce(gclose_14.gr_clse,0 + coalesce(gclose_15.gr_clse,0)) as atr_submited_count,
    coalesce(gclose_15.gr_clse,0) as grievance_closed_count
from generate_months months
left join grievance_receive gr on months.converted_year = gr.converted_year and months.converted_month = gr.converted_month
left join grievance_forwarded gf on months.converted_year = gf.converted_year and months.converted_month = gf.converted_month
left join grievance_str_close_14 gclose_14 on months.converted_year = gclose_14.converted_year and months.converted_month = gclose_14.converted_month
left join grievance_str_close_15 gclose_15 on months.converted_year = gclose_15.converted_year and months.converted_month = gclose_15.converted_month
left join grievance_on_that_departmen gdpt on months.converted_year = gdpt.converted_year and months.converted_month = gdpt.converted_month; 


select CURRENT_DATE::date - '2023-08-08'::date ;
     
       

------- updated month wise dashboard-------------
with generate_months as (
    SELECT 
    	EXTRACT(YEAR from generate_series((now() - interval '6 months')::date ::date, (now() - interval '1 months')::date, '1 month')) AS converted_year,
    	EXTRACT(MONTH from generate_series((now() - interval '6 months')::date ::date, (now() - interval '1 months')::date, '1 month')) AS converted_month
), filter_conditions as (
	    select 
	    	months.converted_year, 
	    	months.converted_month, 
	    	gm.grievance_id, 
	    	gm.status, 
	    	gm.assigned_to_office_id, 
	    	gm.atr_submit_by_lastest_office_id
	    FROM generate_months months
	    left join grievance_master gm on EXTRACT(YEAR from gm.grievance_generate_date) = months.converted_year and EXTRACT(MONTH from gm.grievance_generate_date) = months.converted_month
	    WHERE gm.grievance_id > 0 
--	    and gm.grievance_source = 5 
), filter_conditions_a as (
	    select 
	    	months.converted_year, 
	    	months.converted_month, 
	    	bm.grievance_id, 
	    	bm.current_status, 
	    	bm.assigned_to_office_id
	    FROM generate_months months
	    left join forwarded_latest_3_bh_mat bm on EXTRACT(YEAR from bm.assigned_on) = months.converted_year and EXTRACT(MONTH from bm.assigned_on) = months.converted_month
	    WHERE bm.grievance_id > 0 
--	    and bm.grievance_source = 5 
), filter_conditions_b as (
	    select 
	    	months.converted_year, 
	    	months.converted_month, 
	    	bh.grievance_id,
	    	bh.current_status, 
	    	bh.assigned_to_office_id,
	    	bh.assigned_by_office_id
	    FROM generate_months months
	    left join atr_latest_14_bh_mat bh on EXTRACT(YEAR from bh.atr_submit_on) = months.converted_year and EXTRACT(MONTH from bh.atr_submit_on) = months.converted_month
	    WHERE bh.grievance_id > 0 
--	    and bh.grievance_source = 5 
), grievances_recieved as (
		select converted_year, converted_month, count(grievance_id) as g_r_c
		from filter_conditions
		/*where assigned_to_office_id = 2*/  
		group by converted_year, converted_month
), disposed as (
		select converted_year, converted_month, count(grievance_id) as g_d
		from filter_conditions
		where status = 15
		/*and atr_submit_by_lastest_office_id = 2  */
		group by converted_year, converted_month
), grievances_forwarded as (
		select converted_year, converted_month, count(grievance_id) as g_f_c
		from filter_conditions_a
		/*where assigned_to_office_id = 2*/
		group by converted_year, converted_month
), atr_submitted as (
		select converted_year, converted_month, count(grievance_id) as a_r
		from filter_conditions_b
		where current_status IN (14, 15) /*and assigned_by_office_id = 2*/
		group by converted_year, converted_month
)
	select 
		months.converted_year,
		months.converted_month,
		gr.g_r_c as grievances_recieved_cnt,
		gd.g_d as disposed_cnt,
		gf.g_f_c as grievances_forwarded_cnt,
		atrs.a_r as atr_submitted_cnt
	from generate_months months
	left join grievances_recieved gr on months.converted_year = gr.converted_year and months.converted_month = gr.converted_month
	left join disposed gd on months.converted_year = gd.converted_year and months.converted_month = gd.converted_month
	left join grievances_forwarded gf on months.converted_year = gf.converted_year and months.converted_month = gf.converted_month
	left join atr_submitted atrs on months.converted_year = atrs.converted_year and months.converted_month = atrs.converted_month;
	
----------------------------------------------------------------------------------	
	
--- diffreent method ---
with generate_months as (
    SELECT 
    	EXTRACT(YEAR from generate_series((now() - interval '6 months')::date ::date, (now() - interval '1 months')::date, '1 month')) AS converted_year,
    	EXTRACT(MONTH from generate_series((now() - interval '6 months')::date ::date, (now() - interval '1 months')::date, '1 month')) AS converted_month
), filter_conditions as (
	    select 
	    	months.converted_year, 
	    	months.converted_month, 
	    	gm.grievance_id, 
	    	gm.status, 
	    	gm.assigned_to_office_id, 
	    	gm.atr_submit_by_lastest_office_id
	    FROM generate_months months
	    left join grievance_master gm on EXTRACT(YEAR from gm.grievance_generate_date) = months.converted_year and EXTRACT(MONTH from gm.grievance_generate_date) = months.converted_month
	    WHERE gm.grievance_id > 0 
	    and gm.grievance_source = 5 
), grievances_recieved as (
		select converted_year, converted_month, count(grievance_id) as g_r_c
		from filter_conditions
		where assigned_to_office_id = 2  
		group by converted_year, converted_month
), disposed as (
		select converted_year, converted_month, count(grievance_id) as g_d
		from filter_conditions
		where status = 15
		and atr_submit_by_lastest_office_id = 2  
		group by converted_year, converted_month
), grievances_forwarded as (
		select converted_year, converted_month, count(grievance_id) as g_f_c
		from forwarded_latest_3_bh_mat bm 
		left join generate_months months on EXTRACT(YEAR from bm.assigned_on) = months.converted_year and EXTRACT(MONTH from bm.assigned_on) = months.converted_month
	    WHERE bm.grievance_id > 0 
	    and bm.assigned_by_office_id = 2
		group by converted_year, converted_month
)
	select 
		months.converted_year, 
		months.converted_month,
		gr.g_r_c as grievances_recieved_cnt,
		gd.g_d as disposed_cnt,
		gf.g_f_c as grievances_forwarded
	from generate_months months
	left join grievances_recieved gr on months.converted_year = gr.converted_year and months.converted_month = gr.converted_month
	left join disposed gd on months.converted_year = gd.converted_year and months.converted_month = gd.converted_month
	left join grievances_forwarded gf on months.converted_year = gf.converted_year and months.converted_month = gf.converted_month	
--------------------------------------------------------------------------------------------------------------------------------------------------

---- find the total of a single query -----
SELECT 
    COUNT(gm.grievance_id) AS total_grievances
FROM grievance_master gm
WHERE gm.grievance_source = 5 
	and gm.status = 15
--	and assigned_to_office_id = 2  
  AND gm.grievance_generate_date >= DATE_TRUNC('month', (now() - interval '3 months'))::date
  AND gm.grievance_generate_date < DATE_TRUNC('month', now())::date;

 
 
 SELECT 
    COUNT(gm.grievance_id) AS total_grievances
FROM forwarded_latest_3_bh_mat gm
WHERE gm.grievance_source = 5 
	and assigned_to_office_id = 2  
  AND gm.grievance_generate_date >= DATE_TRUNC('month', (now() - interval '3 months'))::date
  AND gm.grievance_generate_date < DATE_TRUNC('month', now())::date;

 
 
SELECT 
    COUNT(gm.grievance_id) AS total_grievances_submitted
FROM atr_latest_14_bh_mat gm
WHERE gm.assigned_by_office_id = 2
    AND gm.grievance_source = 5 
    AND gm.current_status IN (14, 15)
    AND EXTRACT(MONTH FROM gm.atr_submit_on) = 12
    AND EXTRACT(YEAR FROM gm.atr_submit_on) = 2024;


	select gm.assigned_to_office_id, gm.assigned_by_office_id from atr_latest_14_bh_mat gm where gm.current_status in (14, 15);

	select gm.atr_submit_on 
	from atr_latest_14_bh_mat gm 
	where gm.assigned_by_office_id = 2 
	and gm.current_status in (14,15) 
	and gm.grievance_source = 5
	order by gm.atr_submit_on asc; -- 2024-11-12 07:41:00.000 +0530 last entry
	
	
	
------------------------------------------------------- dashboard male female wise for CMO ---------------------------------------------------------------
----------------------------------------------------------------------- CMO ---------------------------------------------------------------------
	select
		g2.total_count,
		g2.grievances_recieved_male,
		(g2.grievances_recieved_male/g2.total_count::float)*100 as grievances_recieved_male_percentage,
		g2.grievances_recieved_female,
		(g2.grievances_recieved_female/g2.total_count::float)*100 as grievances_recieved_female_percentage,
		g2.grievances_recieved_others,
		(g2.grievances_recieved_others/g2.total_count::float)*100 as grievances_recieved_others_percentage,
		g2.grievances_recived_no_gender,
		(g2.grievances_recived_no_gender/g2.total_count::float)*100 as grievances_recived_no_gender_percentage
	from
		(select
			SUM(g1.gender_wise_count)::bigint as total_count,
			MAX(CASE WHEN g1.applicant_gender = 1  THEN g1.gender_wise_count END) AS grievances_recieved_male,
			MAX(CASE WHEN g1.applicant_gender = 2  THEN g1.gender_wise_count END) AS grievances_recieved_female,
			MAX(CASE WHEN g1.applicant_gender = 3  THEN g1.gender_wise_count END) AS grievances_recieved_others,
			MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_recived_no_gender
		from (select
				count(1) as gender_wise_count,
				gm.applicant_gender,
				cdlm.domain_value as gender_name
			  from grievance_master gm
			  left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
			  where gm.grievance_generate_date >= '2023-06-08' 
					and gm.grievance_source = 5 and 
				  (gm.assigned_to_position in 
					  (select apm.position_id from admin_position_master apm where apm.office_id = 2)
			       or 
			      gm.updated_by_position in 
			    	  (select apm.position_id from admin_position_master apm where apm.office_id = 2))
			  group by gm.applicant_gender,cdlm.domain_value) 
			g1) 
				g2;
				
			
select * from cmo_domain_lookup_master cdlm where cdlm.domain_type = 'gender';

---------------------------------- H ------------------- H O D ---------------------D ---------------------------------------------
select
		g2.total_count,
		g2.grievances_recieved_male,
		(g2.grievances_recieved_male/g2.total_count::float)* 100 as grievances_recieved_male_percentage,
		g2.grievances_recieved_female,
		(g2.grievances_recieved_female/g2.total_count::float)* 100 as grievances_recieved_female_percentage,
		g2.grievances_recieved_others,
		(g2.grievances_recieved_others/g2.total_count::float)* 100 as grievances_recieved_others_percentage,
		g2.grievances_recived_no_gender,
		(g2.grievances_recived_no_gender/g2.total_count::float)* 100 as grievances_recived_no_gender_percentage
	from
		(select
			SUM(g1.gender_wise_count)::bigint as total_count,
			MAX(CASE WHEN g1.applicant_gender = 1  THEN g1.gender_wise_count END) AS grievances_recieved_male,
			MAX(CASE WHEN g1.applicant_gender = 2  THEN g1.gender_wise_count END) AS grievances_recieved_female,
			MAX(CASE WHEN g1.applicant_gender = 3  THEN g1.gender_wise_count END) AS grievances_recieved_others,
			MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_recived_no_gender
		from (select
				count(1) as gender_wise_count,
				gm.applicant_gender,
				cdlm.domain_value as gender_name
			  from forwarded_latest_3_bh_mat gm
			  left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
			  where gm.grievance_generate_date >= '2023-06-08' /*and gm.grievance_source = 5*/ and gm.assigned_to_office_id = 3
			  group by gm.applicant_gender,cdlm.domain_value) 
			g1) 
				g2;
			
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------- dashboard social category and religion ------------------------------------------------------------

SELECT
    'Caste' AS category,
    COUNT(1) AS total_count,
    gm.applicant_caste,
    ccm.caste_name AS social_name,
((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
FROM grievance_master gm
LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
WHERE gm.grievance_generate_date >= '2023-06-08'
  AND gm.grievance_source = 5
  AND (gm.assigned_to_position IN (
        SELECT apm.position_id
        FROM admin_position_master apm
        WHERE apm.office_id = 2)
      OR gm.updated_by_position IN (
        SELECT apm.position_id
        FROM admin_position_master apm
        WHERE apm.office_id = 2)
  )
GROUP BY gm.applicant_caste, ccm.caste_name

---------------------------------------------------------------------- HOD View --------------------------------------------------------------------------

SELECT
    'Caste' AS category,
    COUNT(1) AS total_count,
    gm.applicant_caste,
    ccm.caste_name AS social_name,
((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
FROM forwarded_latest_3_bh_mat gm
LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
WHERE gm.grievance_generate_date >= '2023-06-08'
  /*AND gm.grievance_source = 5*/
  and gm.assigned_to_office_id = 3
GROUP BY gm.applicant_caste, ccm.caste_name

--------------------------------------------- dashboard religion ------------------------------------------------------------

SELECT
    'Religion' AS category,
    COUNT(1) AS total_count,
    gm.applicant_reigion,
    crm.religion_name AS social_name,
    ((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
FROM grievance_master gm
LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
WHERE gm.grievance_generate_date >= '2023-06-08'
  AND gm.grievance_source = 5
  AND (gm.assigned_to_position IN (
        SELECT apm.position_id
        FROM admin_position_master apm
        WHERE apm.office_id = 2)
      OR gm.updated_by_position IN (
        SELECT apm.position_id
        FROM admin_position_master apm
        WHERE apm.office_id = 2)
  )
GROUP BY gm.applicant_reigion, crm.religion_name
ORDER BY category, social_name;

---------------------------------------------------------------------- HOD View -----------------------------------------------------------------------------

SELECT
    'Religion' AS category,
    COUNT(1) AS total_count,
    gm.applicant_reigion,
    crm.religion_name AS social_name,
    ((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
from forwarded_latest_3_bh_mat gm
LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
WHERE gm.grievance_generate_date >= '2023-06-08'
/*and gm.grievance_source = 5*/
and gm.assigned_to_office_id = 3
GROUP BY gm.applicant_reigion, crm.religion_name;


-------------------------------------------------------- dashboard Age ---------------------------------------------------------------------
------------------------- old query -----------------
SELECT
    g2.total_count,
    g2.total_male_count,
    g2.total_female_count,
    g2.age_below_18,
    g2.age_18_30,
    g2.age_31_45,
	g2.age_46_60,
    g2.age_above_60,
	g2.age_below_18_male,
    g2.age_18_30_male,
    g2.age_31_45_male,
    g2.age_46_60_male,
    g2.age_above_60_male,
    g2.age_below_18_female,
    g2.age_18_30_female,
    g2.age_31_45_female,
    g2.age_46_60_female,
    g2.age_above_60_female,
    (g2.age_below_18 / g2.total_count::float) * 100 AS age_below_18_percentage,
    (g2.age_18_30 / g2.total_count::float) * 100 AS age_18_30_percentage,
	(g2.age_31_45 / g2.total_count::float) * 100 AS age_31_45_percentage,
	(g2.age_46_60 / g2.total_count::float) * 100 AS age_46_60_percentage,
	(g2.age_above_60 / g2.total_count::float) * 100 AS age_above_60_percentage,
	(g2.age_below_18_male / g2.total_male_count::float) * 100 AS age_below_18_male_percentage,
    (g2.age_18_30_male / g2.total_male_count::float) * 100 AS age_18_30_male_percentage,
	(g2.age_31_45_male / g2.total_male_count::float) * 100 AS age_31_45_male_percentage,
	(g2.age_46_60_male / g2.total_male_count::float) * 100 AS age_46_60_male_percentage,
	(g2.age_above_60_male / g2.total_male_count::float) * 100 AS age_above_60_male_percentage,
	(g2.age_below_18_female / g2.total_female_count::float) * 100 AS age_below_18_female_percentage,
    (g2.age_18_30_female / g2.total_female_count::float) * 100 AS age_18_30_female_percentage,
	(g2.age_31_45_female / g2.total_female_count::float) * 100 AS age_31_45_female_percentage,
	(g2.age_46_60_female / g2.total_female_count::float) * 100 AS age_46_60_female_percentage,
	(g2.age_above_60_female / g2.total_female_count::float) * 100 AS age_above_60_female_percentage
from (select
		count(1) as total_count,
		count(case when g1.applicant_gender = 1 THEN 1 end) as total_male_count,
		count(case when g1.applicant_gender = 2 THEN 1 end) as total_female_count,
		count(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
		count(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
	    count(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
		count(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
	    count(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
		count(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 and g1.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
	    count(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 and g1.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
	    count(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 and g1.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
		count(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 and g1.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
	    count(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 and g1.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
		count(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 and g1.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
	    count(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 and g1.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
	    count(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 and g1.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
		count(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 and g1.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
	    count(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 and g1.applicant_gender = 2 THEN 1 END) AS age_above_60_female
	from 
		(select
			count(1) as age_wise_count,
			gm.applicant_age,
			gm.applicant_gender
            FROM grievance_master gm
		left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
		where gm.applicant_age is not null /*and gm.grievance_source = 5
      AND (gm.assigned_to_position IN (
            SELECT apm.position_id
            FROM admin_position_master apm
            WHERE apm.office_id = 3)
           OR gm.updated_by_position IN (
            SELECT apm.position_id
            FROM admin_position_master apm
            WHERE apm.office_id = 3)
     )*/ group by gm.applicant_age, gm.applicant_gender) g1 ) g2;
    
    ----------------------------------------------- CMO View Update -------------------------------------------
   
  select
	COUNT(1) AS count,
    COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS total_male_count,
    COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS total_female_count,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
FROM grievance_master gm
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
WHERE gm.applicant_age IS NOT null;
/*and gm.applicant_gender != 3;
  AND gm.assigned_to_office_id = 3;   */


WITH age_gender_counts AS (
    SELECT
        COUNT(1) AS total_count,
        COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS total_male_count,
        COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS total_female_count,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
    FROM grievance_master gm
    LEFT JOIN cmo_domain_lookup_master cdlm 
        ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
    WHERE gm.applicant_age IS NOT NULL
)
SELECT 
    total_count,
    total_male_count,
    total_female_count,
    age_below_18,
    (age_below_18 / total_count::float) * 100 AS age_below_18_percentage,
    age_18_30,
    (age_18_30 / total_count::float) * 100 AS age_18_30_percentage,
    age_31_45,
    (age_31_45 / total_count::float) * 100 AS age_31_45_percentage,
    age_46_60,
    (age_46_60 / total_count::float) * 100 AS age_46_60_percentage,
    age_above_60,
    (age_above_60 / total_count::float) * 100 AS age_above_60_percentage,
    age_below_18_male,
    (age_below_18_male / total_male_count::float) * 100 AS age_below_18_male_percentage,
    age_18_30_male,
    (age_18_30_male / total_male_count::float) * 100 AS age_18_30_male_percentage,
    age_31_45_male,
    (age_31_45_male / total_male_count::float) * 100 AS age_31_45_male_percentage,
    age_46_60_male,
    (age_46_60_male / total_male_count::float) * 100 AS age_46_60_male_percentage,
    age_above_60_male,
    (age_above_60_male / total_male_count::float) * 100 AS age_above_60_male_percentage,
    age_below_18_female,
    (age_below_18_female / total_female_count::float) * 100 AS age_below_18_female_percentage,
    age_18_30_female,
    (age_18_30_female / total_female_count::float) * 100 AS age_18_30_female_percentage,
    age_31_45_female,
    (age_31_45_female / total_female_count::float) * 100 AS age_31_45_female_percentage,
    age_46_60_female,
    (age_46_60_female / total_female_count::float) * 100 AS age_46_60_female_percentage,
    age_above_60_female,
    (age_above_60_female / total_female_count::float) * 100 AS age_above_60_female_percentage
FROM age_gender_counts;

    
---------------------------------------------------------------- HOD View ------------------------------------------------------------------------------------
   ---------- old query ----------
 SELECT
    g2.total_count,
    g2.total_male_count,
    g2.total_female_count,
    g2.age_below_18,
    g2.age_18_30,
    g2.age_31_45,
	g2.age_46_60,
    g2.age_above_60,
	g2.age_below_18_male,
    g2.age_18_30_male,
    g2.age_31_45_male,
    g2.age_46_60_male,
    g2.age_above_60_male,
    g2.age_below_18_female,
    g2.age_18_30_female,
    g2.age_31_45_female,
    g2.age_46_60_female,
    g2.age_above_60_female,
    (g2.age_below_18 / g2.total_count::float) * 100 AS age_below_18_percentage,
    (g2.age_18_30 / g2.total_count::float) * 100 AS age_18_30_percentage,
	(g2.age_31_45 / g2.total_count::float) * 100 AS age_31_45_percentage,
	(g2.age_46_60 / g2.total_count::float) * 100 AS age_46_60_percentage,
	(g2.age_above_60 / g2.total_count::float) * 100 AS age_above_60_percentage,
	(g2.age_below_18_male / g2.total_male_count::float) * 100 AS age_below_18_male_percentage,
    (g2.age_18_30_male / g2.total_male_count::float) * 100 AS age_18_30_male_percentage,
	(g2.age_31_45_male / g2.total_male_count::float) * 100 AS age_31_45_male_percentage,
	(g2.age_46_60_male / g2.total_male_count::float) * 100 AS age_46_60_male_percentage,
	(g2.age_above_60_male / g2.total_male_count::float) * 100 AS age_above_60_male_percentage,
	(g2.age_below_18_female / g2.total_female_count::float) * 100 AS age_below_18_female_percentage,
    (g2.age_18_30_female / g2.total_female_count::float) * 100 AS age_18_30_female_percentage,
	(g2.age_31_45_female / g2.total_female_count::float) * 100 AS age_31_45_female_percentage,
	(g2.age_46_60_female / g2.total_female_count::float) * 100 AS age_46_60_female_percentage,
	(g2.age_above_60_female / g2.total_female_count::float) * 100 AS age_above_60_female_percentage
from (select
		count(1) as total_count,
		count(case when g1.applicant_gender = 1 THEN 1 end) as total_male_count,
		count(case when g1.applicant_gender = 2 THEN 1 end) as total_female_count,
		count(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
		count(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
	    count(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
		count(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
	    count(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
		count(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 and g1.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
	    count(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 and g1.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
	    count(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 and g1.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
		count(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 and g1.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
	    count(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 and g1.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
		count(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 and g1.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
	    count(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 and g1.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
	    count(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 and g1.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
		count(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 and g1.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
	    count(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 and g1.applicant_gender = 2 THEN 1 END) AS age_above_60_female
	from 
		(select
			count(1) as age_wise_count,
			gm.applicant_age,
			gm.applicant_gender
            FROM forwarded_latest_3_bh_mat gm
		left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
		where gm.applicant_age is not null 
		/*and gm.grievance_source = 5*/
      and gm.assigned_to_office_id = 3
     group by gm.applicant_age,gm.applicant_gender) g1 ) g2; 
    
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------   
    

SELECT
    COUNT(1) AS gender_wise_count,
    cdlm.domain_type AS gender_description
FROM forwarded_latest_3_bh_mat gm
LEFT JOIN cmo_domain_lookup_master cdlm 
    ON cdlm.domain_code = gm.applicant_gender 
   AND cdlm.domain_type = 'gender'
WHERE gm.applicant_age IS NOT NULL 
  AND gm.assigned_to_office_id = 3
GROUP BY cdlm.domain_type;

   
SELECT
    COUNT(1) AS gender_wise_count,
    cdlm.domain_type AS gender_description
FROM grievance_master gm
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
WHERE gm.applicant_age IS NOT NULL 
  /*AND gm.assigned_to_office_id = 3*/
GROUP BY cdlm.domain_type; -- 4376321 4373526

--total--
select 
	count(1) as grievances_recieved
	from grievance_master gm;


SELECT
    COUNT(1) AS gender_wise_count,
    cdlm.domain_type AS gender_description
FROM grievance_master gm
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
WHERE gm.applicant_age IS NULL -- 2789 has gender but age is null + 6 gender and age is null
GROUP BY cdlm.domain_type;


SELECT
    COUNT(1) AS gender_wise_count,
    cdlm.domain_type AS gender_description
FROM grievance_master gm
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
WHERE gm.applicant_age IS not NULL 
GROUP BY cdlm.domain_type;


SELECT
    COUNT(1) AS count,
    CASE
        WHEN gm.applicant_age BETWEEN 0 AND 17 THEN '0-17'
        WHEN gm.applicant_age BETWEEN 18 AND 30 THEN '18-30'
        WHEN gm.applicant_age BETWEEN 31 AND 45 THEN '31-45'
        WHEN gm.applicant_age BETWEEN 46 AND 60 THEN '46-60'
        WHEN gm.applicant_age BETWEEN 61 AND 120 THEN '61-120'
        ELSE 'Unknown'
    END AS age_range,
    gm.applicant_gender
FROM forwarded_latest_3_bh_mat gm
LEFT JOIN cmo_domain_lookup_master cdlm 
    ON cdlm.domain_code = gm.applicant_gender 
   AND cdlm.domain_type = 'gender'
WHERE gm.applicant_age IS NOT NULL 
  AND gm.assigned_to_office_id = 3
  and gm.applicant_gender != 3
GROUP BY 
    age_range,
    gm.applicant_gender
ORDER BY 
    age_range, 
    gm.applicant_gender; --1135 with including others & 1127 without including others 

    
    
select
	COUNT(1) AS total_count,
    COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS total_male_count,
    COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS total_female_count,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
FROM forwarded_latest_3_bh_mat gm
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
WHERE gm.applicant_age IS NOT NULL 
  AND gm.assigned_to_office_id = 3;

  
 WITH age_gender_counts AS (
	 select
		COUNT(1) AS total_count,
	    COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS total_male_count,
	    COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS total_female_count,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
	    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
	FROM forwarded_latest_3_bh_mat gm
	LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
	WHERE gm.applicant_age IS NOT NULL 
	  AND gm.assigned_to_office_id = 3
	 )
	SELECT 
	    total_count,
	    total_male_count,
	    total_female_count,
	    age_below_18,
	    (age_below_18 / total_count::float) * 100 AS age_below_18_percentage,
	    age_18_30,
	    (age_18_30 / total_count::float) * 100 AS age_18_30_percentage,
	    age_31_45,
	    (age_31_45 / total_count::float) * 100 AS age_31_45_percentage,
	    age_46_60,
	    (age_46_60 / total_count::float) * 100 AS age_46_60_percentage,
	    age_above_60,
	    (age_above_60 / total_count::float) * 100 AS age_above_60_percentage,
	    age_below_18_male,
	    (age_below_18_male / total_male_count::float) * 100 AS age_below_18_male_percentage,
	    age_18_30_male,
	    (age_18_30_male / total_male_count::float) * 100 AS age_18_30_male_percentage,
	    age_31_45_male,
	    (age_31_45_male / total_male_count::float) * 100 AS age_31_45_male_percentage,
	    age_46_60_male,
	    (age_46_60_male / total_male_count::float) * 100 AS age_46_60_male_percentage,
	    age_above_60_male,
	    (age_above_60_male / total_male_count::float) * 100 AS age_above_60_male_percentage,
	    age_below_18_female,
	    (age_below_18_female / total_female_count::float) * 100 AS age_below_18_female_percentage,
	    age_18_30_female,
	    (age_18_30_female / total_female_count::float) * 100 AS age_18_30_female_percentage,
	    age_31_45_female,
	    (age_31_45_female / total_female_count::float) * 100 AS age_31_45_female_percentage,
	    age_46_60_female,
	    (age_46_60_female / total_female_count::float) * 100 AS age_46_60_female_percentage,
	    age_above_60_female,
	    (age_above_60_female / total_female_count::float) * 100 AS age_above_60_female_percentage
	FROM age_gender_counts;
 
 
WITH age_gender_counts AS (
                select
                    '2025-01-16 07:06:18.413198+00:00'::timestamp as refresh_time_utc,
                    COUNT(1) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS total_male_count,
                    COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS total_female_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 AND gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 AND gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 AND gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 AND gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 AND gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
                FROM forwarded_latest_3_bh_mat_2 as gm
                LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
                WHERE gm.applicant_age IS NOT NULL  and gm.grievance_source = 5   and gm.assigned_to_office_id = 3 
                )
                SELECT 
                    total_count,
                    total_male_count,
                    total_female_count,
                    age_below_18,
				    CASE WHEN total_count > 0 THEN (age_below_18 / total_count::float) * 100 ELSE 0 END AS age_below_18_percentage,
				    age_18_30,
				    CASE WHEN total_count > 0 THEN (age_18_30 / total_count::float) * 100 ELSE 0 END AS age_18_30_percentage,
				    age_31_45,
				    CASE WHEN total_count > 0 THEN (age_31_45 / total_count::float) * 100 ELSE 0 END AS age_31_45_percentage,
				    age_46_60,
				    CASE WHEN total_count > 0 THEN (age_46_60 / total_count::float) * 100 ELSE 0 END AS age_46_60_percentage,
				    age_above_60,
				    CASE WHEN total_count > 0 THEN (age_above_60 / total_count::float) * 100 ELSE 0 END AS age_above_60_percentage,
				    age_below_18_male,
				    CASE WHEN total_male_count > 0 THEN (age_below_18_male / total_male_count::float) * 100 ELSE 0 END AS age_below_18_male_percentage,
				    age_18_30_male,
				    CASE WHEN total_male_count > 0 THEN (age_18_30_male / total_male_count::float) * 100 ELSE 0 END AS age_18_30_male_percentage,
				    age_31_45_male,
				    CASE WHEN total_male_count > 0 THEN (age_31_45_male / total_male_count::float) * 100 ELSE 0 END AS age_31_45_male_percentage,
				    age_46_60_male,
				    CASE WHEN total_male_count > 0 THEN (age_46_60_male / total_male_count::float) * 100 ELSE 0 END AS age_46_60_male_percentage,
				    age_above_60_male,
				    CASE WHEN total_male_count > 0 THEN (age_above_60_male / total_male_count::float) * 100 ELSE 0 END AS age_above_60_male_percentage,
				    age_below_18_female,
				    CASE WHEN total_female_count > 0 THEN (age_below_18_female / total_female_count::float) * 100 ELSE 0 END AS age_below_18_female_percentage,
				    age_18_30_female,
				    CASE WHEN total_female_count > 0 THEN (age_18_30_female / total_female_count::float) * 100 ELSE 0 END AS age_18_30_female_percentage,
				    age_31_45_female,
				    CASE WHEN total_female_count > 0 THEN (age_31_45_female / total_female_count::float) * 100 ELSE 0 END AS age_31_45_female_percentage,
				    age_46_60_female,
				    CASE WHEN total_female_count > 0 THEN (age_46_60_female / total_female_count::float) * 100 ELSE 0 END AS age_46_60_female_percentage,
				    age_above_60_female,
				    CASE WHEN total_female_count > 0 THEN (age_above_60_female / total_female_count::float) * 100 ELSE 0 END AS age_above_60_female_percentage
				FROM age_gender_counts;
			
--------------------------------------------------------- dashboard district wise status -----------------------------------------------------------------------
------------------------------------ CMO ----------------------------------------
 with total_atr_receive AS (
    select count(1) as atr_recieved, bm.district_id
    from atr_latest_14_bh_mat bm
    inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id
    where bm.current_status in (14,15) /*and bm.grievance_source = 5 and bm.assigned_by_office_id = 3*/
    group by bm.district_id
),total_atr_pending as (
    select count(1) as atr_pending, bh.district_id 
    from forwarded_latest_3_bh_mat bh
    where not exists ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5 and bh.assigned_to_office_id = 3*/
     group by bh.district_id
)
select 
	cdm.district_name::text,
	coalesce(atr_recieved,0) as atr_received_count,
	coalesce(atr_pending,0) as atr_pending_count,
    case when coalesce(atr_recieved,0) > 0 then ((coalesce(atr_recieved,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_received_count_percentage,
    case when coalesce(atr_pending,0) > 0 then ((coalesce(atr_pending,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_pending_count_percentage
    from cmo_districts_master cdm 
left join total_atr_receive tar on cdm.district_id = tar.district_id
left join total_atr_pending tap on tar.district_id = tap.district_id
order by 3 desc;

---------------------------------------------------- HOD ----------------------------------------
with total_atr_receive AS (
    select count(1) as atr_recieved, bm.district_id
    from atr_latest_14_bh_mat bm
    inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id
    where bm.current_status in (14,15) /*and bm.grievance_source = 5*/ and bm.assigned_by_office_id = 3
    group by bm.district_id
),total_atr_pending as (
    select count(1) as atr_pending, bh.district_id 
    from forwarded_latest_3_bh_mat bh
    where not exists ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5*/ and bh.assigned_to_office_id = 3
     group by bh.district_id
)
select 
	cdm.district_name::text,
	coalesce(atr_recieved,0) as atr_received_count,
	coalesce(atr_pending,0) as atr_pending_count,
    case when coalesce(atr_recieved,0) > 0 then ((coalesce(atr_recieved,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_received_count_percentage,
    case when coalesce(atr_pending,0) > 0 then ((coalesce(atr_pending,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_pending_count_percentage
    from cmo_districts_master cdm 
left join total_atr_receive tar on cdm.district_id = tar.district_id
left join total_atr_pending tap on tar.district_id = tap.district_id
order by 3 desc;


------------------------------------------------------ dashboard department wise --------------------------------------------------------------------------
 
----------------- tuned -----------------
-------
atr_recieved as (
	SELECT COUNT(1) as atr_recieved_cnt FROM atr_latest_14_bh_mat bm
	INNER JOIN forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id 
	where bm.current_status in (14,15) and bm.grievance_source = ssm_id and bm.assigned_by_office_id = dept_id
	
--------- Correct Version ----------

WITH received_counts as (
	select count(1) as __rec__, bm.assigned_by_office_id
	from atr_latest_14_bh_mat bm
	inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id
	where bm.current_status in (14,15)
	/*and bm.grievance_source = 5 and bm.assigned_by_office_id = 3*/
	group by bm.assigned_by_office_id
), pending_counts AS (
    select bh.assigned_to_office_id, COUNT(1) AS _pndddd_
    from forwarded_latest_3_bh_mat bh
    where NOT EXISTS (SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bm.grievance_id = bh.grievance_id AND bm.current_status IN (14, 15))
    /*and bh.grievance_source = 5 and bh.assigned_to_office_id = 3*/
    group by bh.assigned_to_office_id
), 
processing_unit AS (
    SELECT com.office_id, com.office_name, COALESCE(pc._pndddd_, 0) AS atr_pending, COALESCE(rc.__rec__, 0) as  atr_recieved, com.office_type 
    FROM cmo_office_master com
    LEFT JOIN pending_counts pc ON com.office_id = pc.assigned_to_office_id
    LEFT JOIN received_counts rc ON com.office_id = rc.assigned_by_office_id
    WHERE com.office_name != 'Chief Ministers Office'
)
SELECT 
    ROW_NUMBER() OVER () AS sl_no, 
    pu.office_id, 
    pu.office_name, 
    pu.office_type,
    pu.atr_recieved,
    pu.atr_pending,
    case when coalesce(atr_recieved,0) > 0 then ((coalesce(atr_recieved,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_received_count_percentage,
    case when coalesce(atr_pending,0) > 0 then ((coalesce(atr_pending,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_pending_count_percentage
from processing_unit pu
--where pu.office_id =  3
order by pu.atr_pending DESC;


------- v3 ---------
with total_atr_receive AS (
    select count(1) as atr_recieved, bm.assigned_to_office_id
    from atr_latest_14_bh_mat bm
    inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id
    where bm.current_status in (14,15) /*and bm.grievance_source = 5 and bm.assigned_by_office_id = 3*/
    group by bm.assigned_to_office_id
),total_atr_pending as (
    select count(1) as atr_pending, bh.assigned_to_office_id 
    from forwarded_latest_3_bh_mat bh
    where not exists ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5 and bh.assigned_to_office_id = 3*/
     group by bh.assigned_to_office_id
)
select 
	com.office_name::text,
	coalesce(atr_recieved,0) as atr_received_count,
	coalesce(atr_pending,0) as atr_pending_count,
    case when coalesce(atr_recieved,0) > 0 then ((coalesce(atr_recieved,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_received_count_percentage,
    case when coalesce(atr_pending,0) > 0 then ((coalesce(atr_pending,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_pending_count_percentage
    from cmo_office_master com
left join total_atr_receive tar on com.office_id = tar.assigned_to_office_id
left join total_atr_pending tap on tar.assigned_to_office_id = tap.assigned_to_office_id
where com.office_category = 2
order by atr_received_count desc ; 

----------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------- dashboard Top 5 HoDs having more pendency ---------------------------------------------------------------------------

-- old ---
select * from (
    select com.office_name , Count(distinct gm.grievance_id) as per_hod_count 
        FROM cmo_office_master com
    -- LEFT JOIN admin_position_master apm ON com.office_id = apm.office_id AND apm.office_category = 2
    -- LEFT JOIN grievance_master gm ON gm.assigned_to_position = apm.position_id AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17)
    LEFT JOIN grievance_master gm ON com.office_id = gm.assigned_to_office_id
    where com.office_category = 2 AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17)  
    group by com.office_name) q 
    order by q.per_hod_count desc;


   -- new v1---
 with pending_counts as (
    select bh.assigned_to_office_id, count(1) as _pndddd_
    from forwarded_latest_3_bh_mat bh
    where not exists (select 1 from atr_latest_14_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)) 
    group by bh.assigned_to_office_id   
), processing_unit as (
    select com.office_id, com.office_name, COALESCE(pc._pndddd_, 0) AS atr_pending, com.office_type 
    from cmo_office_master com
    left join pending_counts pc on com.office_id = pc.assigned_to_office_id
    where com.office_name != 'Chief Ministers Office'
)
select row_number() over() as sl_no, 
	pu.office_id, 
	pu.office_name, 
	pu.office_type, 
	pu.atr_pending
from processing_unit pu
order by pu.atr_pending DESC;
   

--- Correct Code  ----
WITH pending_counts AS (
    select bh.assigned_to_office_id, COUNT(1) AS _pndddd_
    from forwarded_latest_3_bh_mat bh
    where NOT EXISTS (SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bm.grievance_id = bh.grievance_id AND bm.current_status IN (14, 15))
    /*and bh.grievance_source = 5 and bh.assigned_to_office_id = 3*/
    GROUP BY bh.assigned_to_office_id
), 
processing_unit AS (
    SELECT com.office_id, com.office_name, COALESCE(pc._pndddd_, 0) AS atr_pending, com.office_type 
    FROM cmo_office_master com
    LEFT JOIN pending_counts pc ON com.office_id = pc.assigned_to_office_id
    WHERE com.office_name != 'Chief Ministers Office'
)
SELECT 
    ROW_NUMBER() OVER () AS sl_no, 
    pu.office_id, 
    pu.office_name, 
    pu.office_type, 
    pu.atr_pending
from processing_unit pu
--where pu.office_id =  3
order by pu.atr_pending DESC;

   
   --- new v2 ----
 select * from (
    select com.office_name , Count(distinct bm.grievance_id) as atr_pending 
        FROM cmo_office_master com
    LEFT JOIN forwarded_latest_3_bh_mat bm ON com.office_id = bm.assigned_to_office_id
    where not exists ( SELECT 1 FROM atr_latest_14_bh_mat bh WHERE bh.grievance_id = bm.grievance_id and bh.current_status in (14,15))
    and com.office_category = 2 /*and bm.grievance_source = 5 and bm.assigned_to_office_id = 3*/
    group by com.office_name) q 
    order by q.atr_pending desc;
   
   
	SELECT COUNT(1) as atr_pending FROM forwarded_latest_3_bh_mat bm
     WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat bh WHERE bm.grievance_id = bh.grievance_id and bh.current_status in (14,15))
    and bm.grievance_source = 5 and bm.assigned_to_office_id = 3; -- 949352 231

 
    -------------------------------------------- dashboard Top 5 Categories having more pendency ---------------------------------------------------------------------------
    ---------------- CMO -------------
    
with pending_count as (
	select bm.grievance_category, 
	count(1) as _pndddd_ from forwarded_latest_3_bh_mat bm
	    where not exists (select 1 from atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = bm.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
		/*and bm.grievance_source = 5 and bm.assigned_to_office_id = 3*/
	    group by bm.grievance_category
	)
select 
		cgcm.grievance_cat_id, 
		cgcm.grievance_category_desc, 
		coalesce(com.office_name,'N/A') as office_name,
    cgcm.parent_office_id, 
    com.office_id, 
    coalesce(pc._pndddd_, 0) as atr_pndg
from cmo_grievance_category_master cgcm
left join cmo_office_master com on com.office_id = cgcm.parent_office_id
left join pending_count pc on cgcm.grievance_cat_id = pc.grievance_category
/***** FILTER *****/
where cgcm.grievance_cat_id  > 0
--and com.office_id = 3
order by atr_pndg desc;


-------------------------------- HOD ---------------------------------

with pending_count as (
	select bm.grievance_category, bm.assigned_to_office_id,
	count(1) as _pndddd_ from forwarded_latest_3_bh_mat bm
	    where not exists (select 1 from atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = bm.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
		/*and bm.grievance_source = 5*/ and bm.assigned_to_office_id = 3
	    group by bm.grievance_category, bm.assigned_to_office_id
	)
select 
		cgcm.grievance_cat_id, 
		cgcm.grievance_category_desc, 
		coalesce(com.office_name,'N/A') as office_name,
    cgcm.parent_office_id, 
    com.office_id, 
    pc.assigned_to_office_id,
    coalesce(pc._pndddd_, 0) as atr_pndg
from cmo_grievance_category_master cgcm
left join cmo_office_master com on com.office_id = cgcm.parent_office_id
left join pending_count pc on cgcm.grievance_cat_id = pc.grievance_category
/***** FILTER *****/
where cgcm.grievance_cat_id  > 0
--and com.office_id = 3
order by atr_pndg desc;


--------------------------------------- dashboard Individual Benefit Scheme Wise Disposed Grievances ----------------------------------------
 with fwd_count as (
    select bh.grievance_category, count(1) as _fwd_ 
    from forwarded_latest_3_bh_mat bh
        where bh.grievance_category > 0 /*and bh.grievance_source = 5 and bh.district_id = 5*/
    group by bh.grievance_category
 ), atr_count as (
    select bh.grievance_category, count(1) as _atr_, 
        sum(case when bh.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up
    from atr_latest_14_bh_mat bh
    where bh.grievance_category > 0 and bh.current_status in (14,15) /*and bh.grievance_source = 5 and bh.district_id = 5*/
    group by bh.grievance_category
), pending_count as (
    select bm.grievance_category, count(1) as _pndddd_ , avg(pm.days_diff) as _avg_pending_
    from forwarded_latest_3_bh_mat bm
    inner join pending_for_hod_wise_mat pm on bm.grievance_id = pm.grievance_id
    where not exists (select 1 from atr_latest_14_bh_mat bh where bh.grievance_id = bm.grievance_id and bh.current_status in (14,15))
	/*and bm.grievance_source = 5 and bm.district_id = 5*/
    group by bm.grievance_category
) select 
		row_number() over() as sl_no,
		cgcm.grievance_cat_id, 
		cgcm.grievance_category_desc, 
		coalesce(com.office_name,'N/A') as office_name,
		cgcm.parent_office_id, 
		com.office_id, 
		coalesce(fc._fwd_, 0) as grievances_received,
		coalesce(ac._clse_, 0) as grievances_disposed,  
    	coalesce(ac.bnft_prvd, 0) as benefit_provided, 
    	coalesce(ac.matter_taken_up, 0) as matter_taken_up,
    	coalesce(pc._pndddd_, 2) as grievances_pending,
    	coalesce(round(pc._avg_pending_, 0)) as days_diff,
    	coalesce(ROUND(CASE WHEN (ac.bnft_prvd + ac.matter_taken_up) = 0 THEN 0 
    	ELSE (ac.bnft_prvd::numeric / (ac.bnft_prvd + ac.matter_taken_up)) * 100 END,2),0) AS bsp_percentage
from cmo_grievance_category_master cgcm
left join cmo_office_master com on com.office_id = cgcm.parent_office_id
left join atr_count ac on cgcm.grievance_cat_id = ac.grievance_category
left join pending_count pc on cgcm.grievance_cat_id = pc.grievance_category
left join fwd_count fc on cgcm.grievance_cat_id = fc.grievance_category
where cgcm.grievance_cat_id  > 0 and coalesce(fc._fwd_, 0) > 0
order by cgcm.grievance_category_desc;


------------------------------------------------------------- HOD View ----------------------------------------------------------------------------------------
with fwd_count as (
    select bh.grievance_category, count(1) as _fwd_ 
    from forwarded_latest_3_bh_mat_2 as bh
    where bh.grievance_category > 0 and bh.assigned_to_office_id = 3
    group by bh.grievance_category
), atr_count as (
    select bh.grievance_category, count(1) as _atr_, 
        sum(case when bh.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up
    from atr_latest_14_bh_mat_2 as bh
    where bh.grievance_category > 0 and bh.current_status in (14,15) and bh.assigned_by_office_id = 3
    group by bh.grievance_category
), pending_count as (
    select bh.grievance_category, count(1) as _pndddd_ , avg(pm.days_diff) as _avg_pending_
    from forwarded_latest_3_bh_mat_2 as bh
    inner join pending_for_hod_wise_mat_2 as pm on bh.grievance_id = pm.grievance_id
    where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 3 
    group by bh.grievance_category
) select 
        '2025-01-22 10:30:01.291455+00:00'::timestamp as refresh_time_utc,
        row_number() over() as sl_no,
        cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        coalesce(com.office_name,'N/A') as office_name,
        cgcm.parent_office_id, 
        com.office_id, 
        coalesce(fc._fwd_, 0) as grievances_received,
        coalesce(ac._clse_, 0) as grievances_disposed,  
        coalesce(ac.bnft_prvd, 0) as benefit_provided, 
        coalesce(ac.matter_taken_up, 0) as matter_taken_up,
        coalesce(pc._pndddd_, 2) as grievances_pending,
        coalesce(round(pc._avg_pending_, 0)) as days_diff,
        coalesce(ROUND(CASE WHEN (ac.bnft_prvd + ac.matter_taken_up) = 0 THEN 0 
        ELSE (ac.bnft_prvd::numeric / (ac.bnft_prvd + ac.matter_taken_up)) * 100 END,2),0) AS bsp_percentage
from cmo_grievance_category_master cgcm
left join cmo_office_master com on com.office_id = cgcm.parent_office_id
left join atr_count ac on cgcm.grievance_cat_id = ac.grievance_category
left join pending_count pc on cgcm.grievance_cat_id = pc.grievance_category
left join fwd_count fc on cgcm.grievance_cat_id = fc.grievance_category
where cgcm.grievance_cat_id  > 0 and coalesce(fc._fwd_, 0) > 0
order by cgcm.grievance_category_desc;

-----------------------------------------------------------------------------------------------------
------------------- old query ----------------

with common_join as (
    select gm.status,gm.grievance_category,cgcm.grievance_category_desc, gm.closure_reason_id , gm.grievance_id 
    from grievance_master gm 
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id  = gm.grievance_category 
    where cgcm.benefit_scheme_type = 1 and cgcm.status = 1
          /*{f" and gm.district_id = {dist_id} " if dist_id else ""}
          {f" and gm.grievance_source = {ssm_id} " if ssm_id else ""}*/
), porcessing_unit as (
    select cj.grievance_category_desc, count(1) as grievances_received, 
            coalesce(sum(case when cj.status = 15 then 1 else 0 end), 0) as grievances_disposed,
            coalesce(sum(case when cj.status != 15 then 1 else 0 end), 0) as grievances_pending,
            coalesce(sum(case when cj.closure_reason_id = 1 then 1 else 0 end), 0) as benefit_provided,
            coalesce(sum(case when cj.closure_reason_id in (5,9) then 1 else 0 end), 0) as matter_taken_up,
            coalesce(avg(pnd_hwise.days_diff)::int, 0) as days_diff
    from common_join cj
    left join pending_for_hod_wise pnd_hwise on pnd_hwise.grievance_id = cj.grievance_id
    group by cj.grievance_category, cj.grievance_category_desc
)
select *,
        COALESCE (
            CASE 
                WHEN (benefit_provided + matter_taken_up) > 0 
                THEN ROUND((benefit_provided::FLOAT / NULLIF(benefit_provided + matter_taken_up, 0)) * 100)
                ELSE 0
            END, 0
        ) AS bsp_percentage
from porcessing_unit order by grievance_category_desc;

---------------------------------------------------- dashboard HoD Wise Grievance Status ---------------------------------------------------------
   ------------------------------- new update -----------------------------
with fwd_Count as (
    select bh.assigned_to_office_id, count(1) as _fwd_ 
    from forwarded_latest_3_bh_mat bh
    /*where bh.grievance_source = 5*/
    group by bh.assigned_to_office_id
), atr_count as (
    select bh.assigned_by_office_id, count(1) as _atr_ ,
    	sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
    	sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up
    from atr_latest_14_bh_mat bh
--    inner join forwarded_latest_3_bh_mat bm on bm.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) /*and bh.grievance_source = 5*/
    group by bh.assigned_by_office_id
 ), pending_counts as (
    select 
    	bm.assigned_to_office_id, 
    	count(1) as _pndddd_, 
    	avg(pm.days_diff) as _avg_pending_, 
    	sum(case when pm.days_diff > 7 then 1 else 0 end) as _beyond_7_d_
    from forwarded_latest_3_bh_mat bm
    inner join pending_for_hod_wise_mat pm on bm.grievance_id = pm.grievance_id
    where not exists (select 1 from atr_latest_14_bh_mat bh where bh.grievance_id = bm.grievance_id and bh.current_status in (14,15)) 
    /*and bm.grievance_source = 5*/
    group by bm.assigned_to_office_id    
 ) select 
 	com.office_id, 
 	com.office_name,
   	coalesce(fc._fwd_, 0) as grievance_forwarded,
    coalesce(ac._atr_, 0) as atr_received_count,
    coalesce(pc._pndddd_, 0) as atr_pending,
    coalesce(ac.bnft_prvd, 0) as benefit_provided,
    coalesce(ac.matter_taken_up, 0) as matter_taken_up,
    coalesce(ROUND(pc._avg_pending_,2),0) as average_resolution_days,
    coalesce(CAST(((ac.bnft_prvd::FLOAT / NULLIF(ac.bnft_prvd + ac.matter_taken_up, 0)) * 100) AS INTEGER), 0) AS bsp_percentage,
    CASE
            WHEN coalesce(pc._avg_pending_, 0) <= 7 THEN 'Good'
            WHEN coalesce(pc._avg_pending_, 0) > 7 AND coalesce(pc._avg_pending_, 0) <= 30 THEN 'Average'
            ELSE 'Poor'
    END AS performance
    from cmo_office_master com
    left join fwd_Count fc on com.office_id  = fc.assigned_to_office_id 
    left join atr_count ac on com.office_id = ac.assigned_by_office_id
    left join pending_counts pc on com.office_id = pc.assigned_to_office_id
    where com.office_name != 'Chief Ministers Office' and coalesce(fc._fwd_, 0) > 0;
   
   ----------------------------------------------------- with refresh query ------------------------------
  

   
   ------------- mis with referesh query ---------

                   
  
--------------------------------------------------- Dashboard User Wise Grievance Status at CMO -------------------------------------------------------------------------------------------  
 --------------------------- old query ---------------------------
  		 ---- part 1 ---
  SELECT 
        COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS unassigned_grievance,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS unassigned_atr
    FROM grievance_master gm;
    /*where gm.grievance_source = 5 ;*/
   
   -------- part 2 --------- 
select concat(aud.official_name, ' - ', aurm.role_master_name) as  official_and_role_name, 
    lat3.fwd_count as forwarded,
    lat3.new_grievances_pending as new_grievances_pending,
    lat3.pending,
    sum(case when (gm.status = 15) then 1 else 0 End) as closed,
    sum(case when (gm.status in (6)) then 1 else 0 End) as atr_returned_to_hod_for_review,
    sum(case when (gm.status in (17)) then 1 else 0 End) as atr_returned_to_other_hod
from admin_position_master apm 
inner join admin_user_position_mapping aupm on apm.position_id = aupm.position_id 
inner join admin_user_details aud on aupm.admin_user_id = aud.admin_user_id 
inner join admin_user au on aud.admin_user_id = au.admin_user_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
left join grievance_master gm on gm.updated_by_position = apm.position_id 
left join grievance_lifecycle_latest_3 lat3 on lat3.position_id = apm.position_id 
where  apm.role_master_id in (1,2,3,9) and au.status != 3  
group by apm.position_id, aud.official_name,lat3.new_grievances_pending,lat3.pending,lat3.fwd_count,aurm.role_master_name

------------------------- New update chart -----------------
with fwd_Count as (
    select bh.assigned_by_id , bh.assigned_by_position, count(1) as griv_fwd 
    	from forwarded_latest_3_bh_mat bh 
    group by bh.assigned_by_id, bh.assigned_by_position
 ), new_pending as (
    select gm.assigned_to_id, gm.assigned_to_position, count(1) as griv_pending
    	from grievance_master gm
    where gm.status = 2 
    group by gm.assigned_to_id, gm.assigned_to_position
), atr_closed as (
	SELECT gm.updated_by, gm.updated_by_position, count(1) as disposed 
		from grievance_master gm
	where gm.status = 15
	group by gm.updated_by, gm.updated_by_position
), atr_pending as (   
	select grievance_locking_history.locked_by_userid, grievance_locking_history.locked_by_position, count(1) as atr_pnd
    	from grievance_master bh  
    inner join grievance_locking_history on grievance_locking_history.grievance_id = bh.grievance_id
    where bh.status = 14 and grievance_locking_history.lock_status = 1
    group by grievance_locking_history.locked_by_userid, grievance_locking_history.locked_by_position
), returned_fo_review as (
	SELECT a.assigned_by_id, a.assigned_by_position, count(1) as rtn_fr_rview
   	FROM ( 
	   	   SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn, 
	            gl.assigned_by_id, gl.assigned_by_position, gl.assigned_by_office_cat
	           FROM grievance_lifecycle gl
	       WHERE gl.grievance_status = 6
        ) a
	  WHERE a.rnn = 1 and a.assigned_by_office_cat = 1 
    group by a.assigned_by_id , a.assigned_by_position
) 
select 
	concat(admin_user_details.official_name, ' - ', admin_user_role_master.role_master_name) as official_and_role_name, 
	coalesce(fwd_Count.griv_fwd, 0) as forwarded, 
	coalesce(new_pending.griv_pending, 0) as new_grievances_pending, 
	coalesce(atr_closed.disposed, 0) as closed, 
	coalesce(atr_pending.atr_pnd, 0) as pending, 
	coalesce(returned_fo_review.rtn_fr_rview, 0) as atr_returned_to_hod_for_review
from fwd_Count
left join admin_user_details on fwd_Count.assigned_by_id = admin_user_details.admin_user_id
left join admin_position_master on fwd_Count.assigned_by_position = admin_position_master.position_id
left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
left join new_pending on fwd_Count.assigned_by_id = new_pending.assigned_to_id and fwd_Count.assigned_by_position = new_pending.assigned_to_position
left join atr_closed on fwd_Count.assigned_by_id = atr_closed.updated_by and fwd_Count.assigned_by_position = atr_closed.updated_by_position
left join atr_pending on fwd_Count.assigned_by_id = atr_pending.locked_by_userid and fwd_Count.assigned_by_position = atr_pending.locked_by_position
left join returned_fo_review on fwd_Count.assigned_by_id = returned_fo_review.assigned_by_id and fwd_Count.assigned_by_position = returned_fo_review.assigned_by_position;

------------------------------------------------------------------- testing -------------------------------------------------------------------------

with fwd_Count as (
        select bh.assigned_by_id , bh.assigned_by_position, /*count(1) as griv_fwd,*/ bh.grievance_id as grievance_id
            from forwarded_latest_3_bh_mat_2 as bh 
            where 1 = 1 
        group by bh.assigned_by_id, bh.assigned_by_position, bh.grievance_id
    /*), new_pending as (
        select gm.assigned_to_id, gm.assigned_to_position, count(1) as griv_pending
            from grievance_master_bh_mat_2 as gm
        where gm.status = 2 
        group by gm.assigned_to_id, gm.assigned_to_position
    ), atr_closed as (
        SELECT gm.updated_by, gm.updated_by_position, count(1) as disposed 
            from grievance_master_bh_mat_2 as gm
        where gm.status = 15 
        group by gm.updated_by, gm.updated_by_position
    ), atr_pending as (   
        select grievance_locking_history.locked_by_userid, grievance_locking_history.locked_by_position, count(1) as atr_pnd
            from grievance_master_bh_mat_2 as gm  
        inner join grievance_locking_history on grievance_locking_history.grievance_id = gm.grievance_id
        where gm.status = 14 and grievance_locking_history.lock_status = 1 
        group by grievance_locking_history.locked_by_userid, grievance_locking_history.locked_by_position
    ), returned_fo_review as (
            select x.assigned_by_id, x.assigned_by_position, count(1) as rtn_fr_rview from (
            SELECT a.assigned_by_id, a.assigned_by_position, a.grievance_id
                FROM ( 
                SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn, 
                        gl.assigned_by_id, gl.assigned_by_position, gl.assigned_by_office_cat, gl.grievance_id
                    FROM grievance_lifecycle gl
                WHERE gl.grievance_status = 6
                ) a
        WHERE a.rnn = 1 and a.assigned_by_office_cat = 1
        )x
        inner join grievance_master_bh_mat_2 as gm on x.grievance_id = gm.grievance_id
        group by x.assigned_by_id, x.assigned_by_position
   */ ) select 
            '2025-03-04 02:30:01.825158+00:00'::timestamp as refresh_time_utc,
            coalesce(admin_user_details.admin_user_id, 0) as admin_user_id,
            concat(admin_user_details.official_name, ' - ', admin_user_role_master.role_master_name) as official_and_role_name, 
            --coalesce(fwd_Count.griv_fwd, 0) as forwarded,
            coalesce(fwd_Count.grievance_id, 0) as grievance_id
            --coalesce(new_pending.griv_pending, 0) as new_grievances_pending, 
            --coalesce(atr_closed.disposed, 0) as closed, 
            --coalesce(atr_pending.atr_pnd, 0) as pending, 
            --coalesce(returned_fo_review.rtn_fr_rview, 0) as atr_returned_to_hod_for_review
        from fwd_Count
        left join admin_user_details on fwd_Count.assigned_by_id = admin_user_details.admin_user_id
        left join admin_position_master on fwd_Count.assigned_by_position = admin_position_master.position_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        --left join new_pending on fwd_Count.assigned_by_id = new_pending.assigned_to_id and fwd_Count.assigned_by_position = new_pending.assigned_to_position
        --left join atr_closed on fwd_Count.assigned_by_id = atr_closed.updated_by and fwd_Count.assigned_by_position = atr_closed.updated_by_position
        --left join atr_pending on fwd_Count.assigned_by_id = atr_pending.locked_by_userid and fwd_Count.assigned_by_position = atr_pending.locked_by_position
        --left join returned_fo_review on fwd_Count.assigned_by_id = returned_fo_review.assigned_by_id and fwd_Count.assigned_by_position = returned_fo_review.assigned_by_position;
		where admin_user_details.admin_user_id = 12708;
       
       select * from grievance_master gm where gm.grievance_id = 4738867;
      select * from grievance_lifecycle gl where gl.grievance_id = 4738867;
      
      select
      	gl.grievance_id,
      	gl.grievance_status,
      	gl.assigned_on,
--      	gl.assigned_by_id,
      	gl.assigned_by_position,
--      	apm1.role_master_id as assigned_by_role,
      	aurm1.role_master_name,
      	com1.office_name as assigned_by_office,
--      	gl.assigned_by_office_id,
--      	gl.assigned_by_office_cat,
--      	gl.assigned_to_id,
      	gl.assigned_to_position,
--      	gl.assigned_to_office_id,
--      	gl.assigned_to_office_cat,
--      	apm2.role_master_id as assigned_to_role,
      	aurm2.role_master_name,
      	com2.office_name as assigned_to_office
      from grievance_lifecycle gl
      inner join admin_position_master apm1 on apm1.position_id = gl.assigned_by_position
      inner join admin_user_role_master aurm1 on aurm1.role_master_id = apm1.role_master_id
      inner join cmo_office_master com1 on com1.office_id = gl.assigned_by_office_id
      inner join admin_position_master apm2 on apm2.position_id = gl.assigned_to_position
      inner join admin_user_role_master aurm2 on aurm2.role_master_id = apm2.role_master_id
      inner join cmo_office_master com2 on com2.office_id = gl.assigned_to_office_id
      where grievance_id = 4738867
     order by gl.assigned_on;
       
       
   select * from admin_user_details ad where ad.admin_user_id = 12708;
   select * from admin_user_details ad where ad.admin_user_id = 11168;
  select * from admin_position_master apm where apm.position_id = 12787;
 select * from admin_user_role_master aurm ;
select * from admin_user_position_mapping aupm where aupm.admin_user_id = 12708;
    
------------------------------------------------------ Office wise cat wise MIS at CMO -----------------------------------------------------
with fwd_count as (
        select 
            forwarded_latest_3_bh_mat.grievance_category,
            forwarded_latest_3_bh_mat.assigned_to_office_id,
            count(1) as _fwd_
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        /* ===== FILTER ===== */
        where 1 = 1
            and forwarded_latest_3_bh_mat.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP 
        /* ===== GROUPING ===== */
        group by forwarded_latest_3_bh_mat.grievance_category, forwarded_latest_3_bh_mat.assigned_to_office_id
), atr_review_count as (
        select count(1) as _review_, 
            grievance_lifecycle.grievance_id
        from grievance_lifecycle
        where grievance_lifecycle.grievance_status = 6
        group by grievance_lifecycle.grievance_id
    ),
    atr_count as (
        select 
            atr_latest_14_bh_mat.grievance_category,
            atr_latest_14_bh_mat.assigned_by_office_id,
            count(1) as _atr_,
            count(atr_review_count.grievance_id) as _rtrn_griev_cnt_,
            avg(atr_review_count._review_) as _avg_rtrn_griev_
            -- sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
            -- sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            -- sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            -- sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            -- sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            -- sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_
        from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat 
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = atr_latest_14_bh_mat.grievance_id
        left join  atr_review_count on atr_review_count.grievance_id = atr_latest_14_bh_mat.grievance_id
        /* ===== FILTER ===== */
        where atr_latest_14_bh_mat.current_status in (14,15)
            and forwarded_latest_3_bh_mat.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP 
        /* ===== GROUPING ===== */
        group by atr_latest_14_bh_mat.assigned_by_office_id, atr_latest_14_bh_mat.grievance_category
    ),
    close_count as (
        select
            gm.grievance_category,
            gm.atr_submit_by_lastest_office_id,
            count(1) as _clse_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_
        from  grievance_master_bh_mat as gm
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        
        /* ===== FILTER ===== */
        where gm.status = 15
            and forwarded_latest_3_bh_mat.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP 
            
        /* ===== GROUPING ===== */
        group by gm.grievance_category, gm.atr_submit_by_lastest_office_id
    ),
    pending_count as (
        select 
            forwarded_latest_3_bh_mat.grievance_category,
            forwarded_latest_3_bh_mat.assigned_to_office_id,
            count(1) as _pndddd_,
            sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
            sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
            sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
        inner join pending_for_hod_wise_mat_2 as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
        /* ===== FILTER ===== */
        where not exists (select 1 from atr_latest_14_bh_mat as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
            and forwarded_latest_3_bh_mat.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP    
        /* ===== GROUPING ===== */                       
        group by forwarded_latest_3_bh_mat.assigned_to_office_id, forwarded_latest_3_bh_mat.grievance_category
    ),
    processing_unit as (
        select
            '2025-02-09 02:30:01.163428+00:00'::timestamp as refresh_time_utc,
            '2025-02-09 02:30:01.163428+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
            cmo_office_master.office_name,
            cmo_office_master.office_id,
            cmo_grievance_category_master.grievance_cat_id as grievance_category,
            cmo_grievance_category_master.grievance_category_desc,
            coalesce(fwd_count._fwd_, 0) as grv_fwd,
            coalesce(atr_count._atr_, 0) as atr_rcvd,
            -- coalesce(atr_count._clse_, 0) as totl_dspsd,
            -- coalesce(atr_count.bnft_prvd, 0) as srv_prvd,
            -- coalesce(atr_count._mt_t_up_win_90_, 0) as mt_t_up_win_90,
            -- coalesce(atr_count._mt_t_up_bey_90_, 0) as mt_t_up_bey_90,
            -- coalesce(atr_count._pnd_policy_dec_, 0) as pnd_policy_dec, 
            -- coalesce(atr_count._non_actionable_, 0) as non_actionable,
            coalesce(close_count._clse_, 0) as totl_dspsd,
            coalesce(close_count.bnft_prvd, 0) as srv_prvd,
            coalesce(close_count._mt_t_up_win_90_, 0) as mt_t_up_win_90,
            coalesce(close_count._mt_t_up_bey_90_, 0) as mt_t_up_bey_90,
            coalesce(close_count._pnd_policy_dec_, 0) as pnd_policy_dec,
            coalesce(close_count._non_actionable_, 0) as non_actionable,
            coalesce(pending_count._pndddd_, 0) as atr_pndg,
            coalesce(pending_count._within_7_d_, 0) as within_7_d,
            coalesce(pending_count._within_7_t_15_d_, 0) as within_7_t_15_d,
            coalesce(pending_count._within_16_t_30_d_, 0) as within_16_t_30_d, 
            (coalesce(pending_count._pndddd_, 0) - (coalesce(pending_count._within_7_d_, 0) + coalesce(pending_count._within_7_t_15_d_, 0) +  coalesce(pending_count._within_16_t_30_d_, 0))) as beyond_30_d,
            -- coalesce(round(CASE
            --                     WHEN (atr_count.bnft_prvd + atr_count._mt_t_up_win_90_ + atr_count._mt_t_up_bey_90_ + atr_count._pnd_policy_dec_) = 0 THEN 0 
            --                     ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count._mt_t_up_win_90_ + atr_count._mt_t_up_bey_90_ + atr_count._pnd_policy_dec_)) * 100 
            --                 END,2),0) AS bnft_prcnt,
            coalesce(round(CASE
                WHEN (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_) = 0 THEN 0 
                ELSE (close_count.bnft_prvd::numeric / (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_)) * 100 
            END,2),0) AS bnft_prcnt,
            coalesce(atr_count._rtrn_griev_cnt_, 0) as rtrn_griev_cnt,
            coalesce(round(atr_count._avg_rtrn_griev_,2), 0) as avg_rtrn_griev_times_cnt
        from fwd_count
        left join cmo_office_master on cmo_office_master.office_id = fwd_count.assigned_to_office_id
        left join cmo_grievance_category_master on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category
        left join atr_count on fwd_count.grievance_category = atr_count.grievance_category and atr_count.assigned_by_office_id = fwd_count.assigned_to_office_id
        left join close_count on close_count.grievance_category = fwd_count.grievance_category and close_count.atr_submit_by_lastest_office_id = fwd_Count.assigned_to_office_id
        left join pending_count on pending_count.grievance_category = fwd_count.grievance_category and pending_count.assigned_to_office_id = fwd_count.assigned_to_office_id
        
        /* ===== FILTER ===== */
        where 1 = 1   
        /* ===== ORDERING ===== */
        order by cmo_office_master.office_type, cmo_office_master.office_name
    )
select
	row_number() over() as sl_no,
	processing_unit.* 
from processing_unit;


  --------------------------------------------------------------------------------------------------------------------------------------------------------
 select count(1) as frw from forwarded_latest_3_bh_mat bh; --4290312
select count(1) as upld from grievance_master gm; -- 4327753
select count(1) as neww from grievance_master gm where gm.status = 1;   --6187
   

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--------------=============================================================================================================================================
  ----------------------------------------------- HOD END CHART --------------------------------------------------------------------------------------



------------------- new mis district wise -------------------
with fwd_Count as (
    select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _fwd_ from forwarded_latest_3_bh_mat 
   /* /******* filter *********/ {f" where forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
    group by forwarded_latest_3_bh_mat.assigned_to_office_id
), quality_of_atr as (
    select grievance_lifecycle.grievance_id 
    from grievance_lifecycle 
    inner join forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id 
    where grievance_lifecycle.grievance_status = 14    
    /*    /******* filter *********/ {f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }  */
                group by grievance_lifecycle.grievance_id  having count(grievance_lifecycle.grievance_id) = 1
), atr_count as (
    select atr_latest_14_bh_mat.assigned_by_office_id, count(1) as _atr_ , count(quality_of_atr.grievance_id) as _quality_atr_,
            avg(pending_for_hod_wise_last_six_months_mat.days_diff) as _six_avg_atr_pnd_ 
    from atr_latest_14_bh_mat 
    inner join forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    left join quality_of_atr on quality_of_atr.grievance_id = atr_latest_14_bh_mat.grievance_id
    left join pending_for_hod_wise_last_six_months_mat on atr_latest_14_bh_mat.grievance_id = pending_for_hod_wise_last_six_months_mat.grievance_id 
    /******* filter *********/ where atr_latest_14_bh_mat.current_status in (14,15)
   /* {f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }  */
    group by atr_latest_14_bh_mat.assigned_by_office_id
), pending_counts as (
    select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _pndddd_, sum(case when pending_for_hod_wise_mat.days_diff > 7 then 1 else 0 end) as _beyond_7_d_,
        avg(pending_for_hod_wise_mat.days_diff) as _avg_pending_
    from forwarded_latest_3_bh_mat 
    inner join pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
    /******* filter *********/ where not exists (select 1 from atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)) 
    /*{f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }*/
    group by forwarded_latest_3_bh_mat.assigned_to_office_id   
), close_count as (
    select atr_submit_by_lastest_office_id, count(1) as _close_ 
    from grievance_master gm 
    inner join forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        where gm.status = 15 /******* filter *********//* {f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }*/
    group by atr_submit_by_lastest_office_id 
), processing_unit as (
    select cmo_office_master.office_id, 
    cmo_office_master.office_name, 
    fwd_Count._fwd_, 
    atr_count._atr_, 
    close_count._close_, 
--    case when (fwd_Count._fwd_ - atr_count._atr_) <= 0 then 0 else (fwd_Count._fwd_ - atr_count._atr_) end as _pnd_, -- show Pending only when (fwd - atr) not less than 0
    pending_counts._pndddd_ as _pnd_,
    case 
            when (pending_counts._pndddd_ <= 0) then 0 else pending_counts._beyond_7_d_
    end as _beyond_7_d_, -- show 7 dayes beyond pending when (fwd - atr) not less than 0
    case 
            when (pending_counts._pndddd_ <= 0) then 0
            else  ((case when pending_counts._pndddd_ <= 0 then 0 else pending_counts._pndddd_ end) - pending_counts._beyond_7_d_)
    end as _before_7_d_,  -- show 7 dayes before pending when (fwd - atr) not less than 0 and (total_pending - _beyond_7_d_)
    pending_counts._avg_pending_,  
    atr_count._quality_atr_, 
    atr_count._six_avg_atr_pnd_,
    cmo_office_master.office_type 
    from cmo_office_master
    left join fwd_Count on cmo_office_master.office_id  = fwd_Count.assigned_to_office_id 
    left join atr_count on cmo_office_master.office_id = atr_count.assigned_by_office_id
    left join pending_counts on cmo_office_master.office_id = pending_counts.assigned_to_office_id
    left join close_count on cmo_office_master.office_id = close_count.atr_submit_by_lastest_office_id
    where cmo_office_master.office_name != 'Chief Ministers Office' /******* filter *********//* { f" and cmo_office_master.district_id in ({','.join(str(i) for i in district_id)})  " if district_id else "" }*/
)select row_number() over() as sl_no, 
		office_id, 
		office_name, 
        coalesce(_fwd_, 0) as grv_frwd, 
        coalesce(_atr_, 0) as atr_recvd, 
        coalesce(_close_, 0) as total_disposed, 
        coalesce(_pnd_, 0) as pending_with_hod, _quality_atr_,  
        coalesce(_beyond_7_d_, 0) as grv_pendng_more_svn_d, 
        coalesce(ROUND(_avg_pending_,2),0) as avg_no_days_to_submit_atr,
        coalesce((case when _before_7_d_ <= 0 then 0 else _before_7_d_ end), 0) as grv_pendng_upto_svn_d,
        coalesce(ROUND((case when (_beyond_7_d_!= 0) then (_beyond_7_d_::numeric/_pnd_) end)*100, 2),0) as percent_bynd_svn_days,
        coalesce(ROUND((case when (_quality_atr_!= 0) then (_quality_atr_::numeric/_atr_) end)*100, 2),0) as qual_atr_recv,
        coalesce(ROUND(_six_avg_atr_pnd_, 2),0) as avg_no_days_to_submit_atr_six,
        office_type,
        case
            when office_type = 1 then 8  
            when office_type = 2 then 1
            when office_type = 3 then 2
            when office_type = 4 then 3
            when office_type = 5 then 4
            when office_type = 6 then 5
            when office_type = 7 then 6
            when office_type = 8 then 7
        end as office_ord 
from processing_unit;



------------------------------------------------------------- category mis new -------------------------------------------------------------------------
with uploaded_count as (
    select grievance_master.grievance_category, count(1) as _uploaded_ 	from grievance_master 
        where grievance_master.grievance_category > 0
                /***** FILTER *****/ 
               /* { f" and grievance_master.grievance_generate_date::date between {from_date} and {to_date} " if from_date and to_date else "" }
                { f" and grievance_master.grievance_source in ({source_string}) " if source_string else "" }*/
    group by grievance_master.grievance_category
), fwd_count as (
    select forwarded_latest_3_bh_mat.grievance_category, count(1) as _fwd_ from forwarded_latest_3_bh_mat 
        where forwarded_latest_3_bh_mat.grievance_category > 0 
                /***** FILTER *****/
              /*  { f" and forwarded_latest_3_bh_mat.grievance_generate_date::date between {from_date} and {to_date} " if from_date and to_date else "" }
                { f" and forwarded_latest_3_bh_mat.grievance_source in ({source_string}) " if source_string else "" }*/
    group by forwarded_latest_3_bh_mat.grievance_category 
), atr_count as (
    select atr_latest_14_bh_mat.grievance_category, count(1) as _atr_, 
        sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
    from atr_latest_14_bh_mat 
        where atr_latest_14_bh_mat.grievance_category > 0 and atr_latest_14_bh_mat.current_status in (14,15)
                /***** FILTER *****/
               /* { f" and atr_latest_14_bh_mat.grievance_generate_date::date between {from_date} and {to_date} " if from_date and to_date else "" }
                { f" and atr_latest_14_bh_mat.grievance_source in ({source_string}) " if source_string else "" }*/
    group by atr_latest_14_bh_mat.grievance_category
), pending_count as (
    select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ from forwarded_latest_3_bh_mat 
        where not exists (select 1 from atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
                /***** FILTER *****/
              /*  { f" and forwarded_latest_3_bh_mat.grievance_generate_date::date between {from_date} and {to_date} " if from_date and to_date else "" }
                { f" and forwarded_latest_3_bh_mat.grievance_source in ({source_string}) " if source_string else "" }*/
    group by forwarded_latest_3_bh_mat.grievance_category
)
select row_number() over() as sl_no, cmo_grievance_category_master.grievance_cat_id, cmo_grievance_category_master.grievance_category_desc, coalesce(cmo_office_master.office_name,'N/A') as office_name,
    cmo_grievance_category_master.parent_office_id, cmo_office_master.office_id, 
    coalesce(uploaded_count._uploaded_, 0) as griev_upload, 
    coalesce(fwd_count._fwd_, 0) as grv_fwd, 
    coalesce(atr_count._atr_, 0) as atr_rcvd, 
    coalesce(atr_count._clse_, 0) as totl_dspsd,  
    coalesce(atr_count.bnft_prvd, 0) as srv_prvd, 
    coalesce(atr_count.action_taken, 0) as action_taken,
    coalesce(atr_count.not_elgbl, 0) as not_elgbl, 
    coalesce(pending_count._pndddd_, 0) as atr_pndg,
    COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count.action_taken) = 0 THEN 0 
                                        ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count.action_taken)) * 100 
                                    END,2),0) AS bnft_prcnt
from cmo_grievance_category_master
left join cmo_office_master on cmo_office_master.office_id = cmo_grievance_category_master.parent_office_id
left join uploaded_count on cmo_grievance_category_master.grievance_cat_id = uploaded_count.grievance_category
left join fwd_count on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category 
left join atr_count on cmo_grievance_category_master.grievance_cat_id = atr_count.grievance_category
left join pending_count on cmo_grievance_category_master.grievance_cat_id = pending_count.grievance_category
/***** FILTER *****/
where cmo_grievance_category_master.grievance_cat_id  > 0
/*{ f" and cmo_grievance_category_master.parent_office_id in ({office_str}) " if office_str else "" } 
    { f" and cmo_grievance_category_master.benefit_scheme_type = {scm_cat} " if scm_cat else "" }*/
   

----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------ New Upgrated Category MIS ----------------------------------------------------------

 with uploaded_count as (
            select grievance_master.grievance_category, count(1) as _uploaded_ 	from grievance_master_bh_mat grievance_master 
                where grievance_master.grievance_category > 0
                        /***** FILTER *****/ 
                        /*{ f" and grievance_master.grievance_generate_date::date between {from_date} and {to_date} " if from_date and to_date else "" }
                        { f" and grievance_master.grievance_source in ({source_string}) " if source_string else "" }
                        { f" and grievance_master.district_id in ({','.join(str(i) for i in district_id)}) " if  district_id else "" }*/
            group by grievance_master.grievance_category
        ), direct_close as (
            select direct_close_bh_mat.grievance_category, count(1) as _drct_cls_cnt_ from direct_close_bh_mat
                where direct_close_bh_mat.grievance_category > 0
                /***** FILTER *****/ 
                       /* { f" and direct_close_bh_mat.grievance_generate_date::date between {from_date} and {to_date} " if from_date and to_date else "" }
                        { f" and direct_close_bh_mat.grievance_source in ({source_string}) " if source_string else "" }
                        { f" and direct_close_bh_mat.district_id in ({','.join(str(i) for i in district_id)}) " if  district_id else "" }*/
            group by direct_close_bh_mat.grievance_category
        ), fwd_count as (
            select forwarded_latest_3_bh_mat.grievance_category, count(1) as _fwd_ from forwarded_latest_3_bh_mat 
                where forwarded_latest_3_bh_mat.grievance_category > 0 
                        /***** FILTER *****/
                        /*{ f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date} " if from_date and to_date else "" }
                        { f" and forwarded_latest_3_bh_mat.grievance_source in ({source_string}) " if source_string else "" }
                        { f" and forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)}) " if  district_id else "" }*/
            group by forwarded_latest_3_bh_mat.grievance_category 
        ), atr_count as (
            select atr_latest_14_bh_mat.grievance_category, count(1) as _atr_, 
                sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
                sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
                sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
                sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        --        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
                sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_
            from atr_latest_14_bh_mat 
            inner join forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = atr_latest_14_bh_mat.grievance_id
                where atr_latest_14_bh_mat.grievance_category > 0 and atr_latest_14_bh_mat.current_status in (14,15)
                        /***** FILTER *****/
                        /*{ f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date} " if from_date and to_date else "" }
                        { f" and atr_latest_14_bh_mat.grievance_source in ({source_string}) " if source_string else "" }
                        { f" and forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)}) " if  district_id else "" }*/
            group by atr_latest_14_bh_mat.grievance_category
        ), pending_count as (
            select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ ,
                sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
                sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
                sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_
            from forwarded_latest_3_bh_mat 
            inner join pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
                where not exists (select 1 from atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
                        /***** FILTER *****/
                       /* { f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date} " if from_date and to_date else "" }
                        { f" and forwarded_latest_3_bh_mat.grievance_source in ({source_string}) " if source_string else "" }
                        { f" and forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)}) " if  district_id else "" }*/
            group by forwarded_latest_3_bh_mat.grievance_category
        )
        select
            row_number() over() as sl_no, cmo_grievance_category_master.grievance_cat_id, 
            cmo_grievance_category_master.grievance_category_desc, coalesce(cmo_office_master.office_name,'N/A') as office_name,
            cmo_grievance_category_master.parent_office_id, cmo_office_master.office_id, 
            coalesce(uploaded_count._uploaded_, 0) as griev_upload, coalesce(fwd_count._fwd_, 0) as grv_fwd, coalesce(atr_count._atr_, 0) as atr_rcvd, 
            coalesce(atr_count._clse_, 0) as totl_dspsd,  coalesce(atr_count.bnft_prvd, 0) as srv_prvd, coalesce(atr_count._mt_t_up_win_90_, 0) as mt_t_up_win_90,
            coalesce(atr_count._mt_t_up_bey_90_, 0) as mt_t_up_bey_90, coalesce(atr_count._pnd_policy_dec_, 0) as pnd_policy_dec, 
            coalesce(atr_count._non_actionable_, 0) as non_actionable,
            coalesce(pending_count._pndddd_, 0) as atr_pndg, coalesce(pending_count._within_7_d_, 0) as within_7_d,
            coalesce(pending_count._within_7_t_15_d_, 0) as within_7_t_15_d, coalesce(pending_count._within_16_t_30_d_, 0) as within_16_t_30_d, 
            (coalesce(pending_count._pndddd_, 0) - (coalesce(pending_count._within_7_d_, 0) + coalesce(pending_count._within_7_t_15_d_, 0) +  coalesce(pending_count._within_16_t_30_d_, 0))) as beyond_30_d,
            COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count._mt_t_up_win_90_ + atr_count._mt_t_up_bey_90_ + atr_count._pnd_policy_dec_) = 0 THEN 0 
                                                ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count._mt_t_up_win_90_ + atr_count._mt_t_up_bey_90_ + atr_count._pnd_policy_dec_)) * 100 
                                            END,2),0) AS bnft_prcnt,
            coalesce(direct_close._drct_cls_cnt_ ,0) as drct_cls_cnt
        from cmo_grievance_category_master
        left join cmo_office_master on cmo_office_master.office_id = cmo_grievance_category_master.parent_office_id
        left join uploaded_count on cmo_grievance_category_master.grievance_cat_id = uploaded_count.grievance_category
        left join fwd_count on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category 
        left join atr_count on cmo_grievance_category_master.grievance_cat_id = atr_count.grievance_category
        left join pending_count on cmo_grievance_category_master.grievance_cat_id = pending_count.grievance_category
        left join direct_close on cmo_grievance_category_master.grievance_cat_id = direct_close.grievance_category
        /***** FILTER *****/
        where cmo_grievance_category_master.grievance_cat_id  > 0
           /* { f" and cmo_grievance_category_master.parent_office_id in ({office_str}) " if office_str else "" } 
            { f" and cmo_grievance_category_master.benefit_scheme_type = {scm_cat} " if scm_cat else "" }*/

        
-------------------------------------------------- New Upgrated State Level MIS -----------------------------------------------------------------------------
   with office_id_by_dist_id as (
        select office_id from cmo_office_master com /*where com.district_id in ({','.join(str(i) for i in district_id)})*/
    ),remove_dm_sp_cp as (
        select office_id from cmo_office_master com /*where com.district_id not in ({','.join(str(i) for i in district_id)}) and office_type in (2,3,4)*/
    ), fwd_Count as (
        select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _fwd_ from forwarded_latest_3_bh_mat
            where (forwarded_latest_3_bh_mat.assigned_to_office_id in (select office_id from office_id_by_dist_id) /*or forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)})*/)
        /******* filter *********/  
        /*{f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } 
        {f" and forwarded_latest_3_bh_mat.grievance_source in ({','.join(str(i) for i in grievance_source)}) " if grievance_source else "" } */
        /*********** SOURCE **************/
        group by forwarded_latest_3_bh_mat.assigned_to_office_id
    ), quality_of_atr as (
        select grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, count(1) as _count_status_wise_
        from grievance_lifecycle
        inner join forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id
        where grievance_lifecycle.grievance_status in (6,14)
            /******* filter *********/
        /*{f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } 
        {f" and forwarded_latest_3_bh_mat.grievance_source in ({','.join(str(i) for i in grievance_source)}) " if grievance_source else "" }*/
        /*********** SOURCE **************/
                    group by grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status
    ), atr_count as (
        select atr_latest_14_bh_mat.assigned_by_office_id, count(distinct atr_latest_14_bh_mat.grievance_id) as _atr_ , 
            sum(case when (quality_of_atr.grievance_status = 14 and quality_of_atr._count_status_wise_ = 1) then 1 else 0 end) as _quality_atr_, 
            sum(case when (quality_of_atr.grievance_status = 6) then 1 else 0 end) as _rtrn_griev_cnt_, 
            avg(case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end) as _avg_rtrn_griev_times_cnt_, 
    --    	   string_agg((case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end)::text, ',') as _avg_rtrn_griev_times_cnt_, 
            avg(pending_for_hod_wise_last_six_months_mat.days_diff) as _six_avg_atr_pnd_
        from atr_latest_14_bh_mat
        inner join forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        left join quality_of_atr on quality_of_atr.grievance_id = atr_latest_14_bh_mat.grievance_id
        left join pending_for_hod_wise_last_six_months_mat on atr_latest_14_bh_mat.grievance_id = pending_for_hod_wise_last_six_months_mat.grievance_id and quality_of_atr.grievance_status = 14
        /******* filter *********/ where atr_latest_14_bh_mat.current_status in (14,15)
                                        and (forwarded_latest_3_bh_mat.assigned_to_office_id in (select office_id from office_id_by_dist_id) /*or forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)})*/)
            /* {f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }  
             {f" and forwarded_latest_3_bh_mat.grievance_source in ({','.join(str(i) for i in grievance_source)}) " if grievance_source else "" } */
             /*********** SOURCE **************/
        group by atr_latest_14_bh_mat.assigned_by_office_id 
    ), pending_counts as (
        select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _pndddd_, 
    --	   sum(case when pending_for_hod_wise_mat.days_diff > 7 then 1 else 0 end) as _beyond_7_d_,
        sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
        sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
        sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_,
    --	   sum(case when (pending_for_hod_wise_mat.days_diff >= 30)then 1 else 0 end) as _more_30_d_,
        avg(pending_for_hod_wise_mat.days_diff) as _avg_pending_
        from forwarded_latest_3_bh_mat
        inner join pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
        /******* filter *********/ where not exists (select 1 from  atr_latest_14_bh_mat 
                                                        where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id 
                                                            and atr_latest_14_bh_mat.current_status in (14,15))
                                                            and (forwarded_latest_3_bh_mat.assigned_to_office_id in (select office_id from office_id_by_dist_id) /*or forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)})*/)
     /*{f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }
     {f" and forwarded_latest_3_bh_mat.grievance_source in ({','.join(str(i) for i in grievance_source)}) " if grievance_source else "" } */
     /*********** SOURCE **************/
        group by forwarded_latest_3_bh_mat.assigned_to_office_id
    ), close_count as (
        select gm.atr_submit_by_lastest_office_id, count(1) as _close_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as _benft_pved_,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_
        from grievance_master gm
        inner join forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
            where gm.status = 15 
                and (forwarded_latest_3_bh_mat.assigned_to_office_id in (select office_id from office_id_by_dist_id) /*or forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)})*/)
                /******* filter *********/
                /* {f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }
                	{f" and forwarded_latest_3_bh_mat.grievance_source in ({','.join(str(i) for i in grievance_source)}) " if grievance_source else "" } 
                	/*********** SOURCE **************/ */
        group by gm.atr_submit_by_lastest_office_id
    ), processing_unit as (
        select cmo_office_master.office_id, cmo_office_master.office_name, fwd_Count._fwd_, atr_count._atr_, close_count._close_,
        pending_counts._pndddd_ as _pnd_,
        pending_counts._within_7_d_,
        pending_counts._within_7_t_15_d_,
        pending_counts._within_16_t_30_d_,    
        case
                when (pending_counts._pndddd_ <= 0) then 0 else (pending_counts._pndddd_ - pending_counts._within_7_d_)
        end as _beyond_7_d_, -- show 7 dayes beyond pending when (fwd - atr) not less than 0
        case
                when (pending_counts._pndddd_ <= 0) then 0 else (pending_counts._pndddd_ - (pending_counts._within_7_d_ + pending_counts._within_7_t_15_d_ + pending_counts._within_16_t_30_d_))
        end as _beyond_30_d_, -- show 7 dayes beyond pending when (fwd - atr) not less than 0
        pending_counts._avg_pending_,
        atr_count._quality_atr_,
        atr_count._six_avg_atr_pnd_,
        atr_count._rtrn_griev_cnt_,
        atr_count._avg_rtrn_griev_times_cnt_,
        cmo_office_master.office_type,
        coalesce(close_count._benft_pved_,0) as benft_pved,
        coalesce(close_count._mt_t_up_win_90_,0) as mt_t_up_win_90,
        coalesce(close_count._mt_t_up_bey_90_,0) as mt_t_up_bey_90,
        coalesce(close_count._pnd_policy_dec_,0) as pnd_policy_dec,
        coalesce(close_count._non_actionable_,0) as non_actionable
        from fwd_Count
        left join cmo_office_master on cmo_office_master.office_id  = fwd_Count.assigned_to_office_id
        left join atr_count on fwd_Count.assigned_to_office_id = atr_count.assigned_by_office_id
        left join pending_counts on fwd_Count.assigned_to_office_id = pending_counts.assigned_to_office_id
        left join close_count on fwd_Count.assigned_to_office_id = close_count.atr_submit_by_lastest_office_id
        where cmo_office_master.office_name != 'Chief Ministers Office' and cmo_office_master.office_id not in (select remove_dm_sp_cp.office_id from remove_dm_sp_cp) 
        /******* filter *********/
    ), order_by_unit as (
        select office_id, office_name,
            coalesce(_fwd_, 0) as grv_frwd, coalesce(_atr_, 0) as atr_recvd, coalesce(_close_, 0) as total_disposed,
            benft_pved,
            mt_t_up_win_90,
            mt_t_up_bey_90,
            pnd_policy_dec,
            non_actionable,
            COALESCE(ROUND(CASE WHEN (benft_pved + mt_t_up_win_90 + mt_t_up_bey_90 + pnd_policy_dec + non_actionable) = 0 THEN 0 
                                                ELSE (benft_pved::numeric / (benft_pved + mt_t_up_win_90 + mt_t_up_bey_90 + pnd_policy_dec + non_actionable)) * 100 
                                        END,2),0) AS per_bnft_prvd,
            coalesce(_pnd_, 0) as pending_with_hod, _quality_atr_,  coalesce(_beyond_7_d_, 0) as grv_pendng_more_svn_d,
            /*coalesce(_within_7_d_, 0) as _within_7_d_,*/ coalesce(_within_7_t_15_d_, 0) as within_7_t_15_d, coalesce(_within_16_t_30_d_, 0) as within_16_t_30_d,
            coalesce(_beyond_30_d_, 0) as beyond_30_d, 
            coalesce(ROUND(_avg_pending_,2),0) as avg_no_days_to_submit_atr,
            coalesce((case when _within_7_d_ <= 0 then 0 else _within_7_d_ end), 0) as grv_pendng_upto_svn_d,
            coalesce(ROUND((case when (_beyond_7_d_!= 0) then (_beyond_7_d_::numeric/_pnd_) end)*100, 2),0) as percent_bynd_svn_days,
            coalesce(ROUND((case when (_quality_atr_!= 0) then (_quality_atr_::numeric/_atr_) end)*100, 2),0) as qual_atr_recv,
            coalesce(ROUND(_six_avg_atr_pnd_, 2),0) as avg_no_days_to_submit_atr_six,
            coalesce(_rtrn_griev_cnt_, 0) as rtrn_griev_cnt, 
            coalesce(ROUND(_avg_rtrn_griev_times_cnt_, 2),0) as avg_rtrn_griev_times_cnt,
            office_type,
            case
                when office_type = 1 then 4  
                when office_type = 2 then 1
                when office_type = 3 then 2
                when office_type = 4 then 3
                when office_type = 5 then 4
                when office_type = 6 then 4
                when office_type = 7 then 4
                when office_type = 8 then 4
            end as office_ord 
        from processing_unit order by office_ord,office_name
    ) select row_number() over() as sl_no, * from order_by_unit;     

   ----------------------------------------------------------------  CAT wise MIS  ---------------------------------------------------------------------------
with fwd_Count as (
    select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _fwd_ from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    /******* filter *********/ where 1=1   
                                 /*********** SOURCE **************/
    group by forwarded_latest_3_bh_mat.assigned_to_office_id
), quality_of_atr as (
    select grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, count(1) as _count_status_wise_
    from grievance_lifecycle
    inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id
    where grievance_lifecycle.grievance_status in (6,14)
        /******* filter *********/  
                                     /*********** SOURCE **************/
                group by grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status
), atr_count as (
    select atr_latest_14_bh_mat.assigned_by_office_id, count(distinct atr_latest_14_bh_mat.grievance_id) as _atr_ , 
        sum(case when (quality_of_atr.grievance_status = 14 and quality_of_atr._count_status_wise_ = 1) then 1 else 0 end) as _quality_atr_, 
        sum(case when (quality_of_atr.grievance_status = 6) then 1 else 0 end) as _rtrn_griev_cnt_, 
        avg(case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end) as _avg_rtrn_griev_times_cnt_, 
--    	   string_agg((case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end)::text, ',') as _avg_rtrn_griev_times_cnt_, 
        avg(pending_for_hod_wise_last_six_months_mat.days_diff) as _six_avg_atr_pnd_
    from atr_latest_14_bh_mat as atr_latest_14_bh_mat
    inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    left join quality_of_atr on quality_of_atr.grievance_id = atr_latest_14_bh_mat.grievance_id
    left join pending_for_hod_wise_last_six_months_mat as pending_for_hod_wise_last_six_months_mat on atr_latest_14_bh_mat.grievance_id = pending_for_hod_wise_last_six_months_mat.grievance_id and quality_of_atr.grievance_status = 14
    /******* filter *********/ where atr_latest_14_bh_mat.current_status in (14,15)
          /*********** SOURCE **************/
    group by atr_latest_14_bh_mat.assigned_by_office_id 
), pending_counts as (
    select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _pndddd_, 
--	   sum(case when pending_for_hod_wise_mat.days_diff > 7 then 1 else 0 end) as _beyond_7_d_,
    sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_,
--	   sum(case when (pending_for_hod_wise_mat.days_diff >= 30)then 1 else 0 end) as _more_30_d_,
    avg(pending_for_hod_wise_mat.days_diff) as _avg_pending_
    from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    inner join pending_for_hod_wise_mat as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
    /******* filter *********/ where not exists (select 1 from  atr_latest_14_bh_mat as atr_latest_14_bh_mat 
                                                    where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id 
                                                        and atr_latest_14_bh_mat.current_status in (14,15))
                                   /*********** SOURCE **************/
    group by forwarded_latest_3_bh_mat.assigned_to_office_id
), close_count as (
    select gm.atr_submit_by_lastest_office_id, count(1) as _close_,
        sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as _benft_pved_,
        sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_
    from  grievance_master_bh_mat as gm
    inner join  forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        where gm.status = 15 /******* filter *********/ 
               /*********** SOURCE **************/
    group by gm.atr_submit_by_lastest_office_id
), processing_unit as (
    select cmo_office_master.office_id, cmo_office_master.office_name, fwd_Count._fwd_, atr_count._atr_, close_count._close_,
    pending_counts._pndddd_ as _pnd_,
    pending_counts._within_7_d_,
    pending_counts._within_7_t_15_d_,
    pending_counts._within_16_t_30_d_,    
    case
            when (pending_counts._pndddd_ <= 0) then 0 else (pending_counts._pndddd_ - pending_counts._within_7_d_)
    end as _beyond_7_d_, -- show 7 dayes beyond pending when (fwd - atr) not less than 0
    case
            when (pending_counts._pndddd_ <= 0) then 0 else (pending_counts._pndddd_ - (pending_counts._within_7_d_ + pending_counts._within_7_t_15_d_ + pending_counts._within_16_t_30_d_))
    end as _beyond_30_d_, -- show 7 dayes beyond pending when (fwd - atr) not less than 0
    pending_counts._avg_pending_,
    atr_count._quality_atr_,
    atr_count._six_avg_atr_pnd_,
    atr_count._rtrn_griev_cnt_,
    atr_count._avg_rtrn_griev_times_cnt_,
    cmo_office_master.office_type,
    coalesce(close_count._benft_pved_,0) as benft_pved,
    coalesce(close_count._mt_t_up_win_90_,0) as mt_t_up_win_90,
    coalesce(close_count._mt_t_up_bey_90_,0) as mt_t_up_bey_90,
    coalesce(close_count._pnd_policy_dec_,0) as pnd_policy_dec,
    coalesce(close_count._non_actionable_,0) as non_actionable
    from fwd_Count
    left join cmo_office_master on cmo_office_master.office_id  = fwd_Count.assigned_to_office_id
    left join atr_count on fwd_Count.assigned_to_office_id = atr_count.assigned_by_office_id
    left join pending_counts on fwd_Count.assigned_to_office_id = pending_counts.assigned_to_office_id
    left join close_count on fwd_Count.assigned_to_office_id = close_count.atr_submit_by_lastest_office_id
    where cmo_office_master.office_name != 'Chief Ministers Office' /******* filter *********/
)select row_number() over() as sl_no, '2025-01-21 09:30:01.519151+00:00'::timestamp as refresh_time_utc, '2025-01-21 09:30:01.519151+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, office_id, office_name,
        coalesce(_fwd_, 0) as grv_frwd, 
        coalesce(_atr_, 0) as atr_recvd, 
        coalesce(_close_, 0) as total_disposed,
        benft_pved,
        mt_t_up_win_90,
        mt_t_up_bey_90,
        pnd_policy_dec,
        non_actionable,
        COALESCE(ROUND(CASE WHEN (benft_pved + mt_t_up_win_90 + mt_t_up_bey_90 + pnd_policy_dec + non_actionable) = 0 THEN 0 
                                            ELSE (benft_pved::numeric / (benft_pved + mt_t_up_win_90 + mt_t_up_bey_90 + pnd_policy_dec + non_actionable)) * 100 
                                    END,2),0) AS per_bnft_prvd,
        coalesce(_pnd_, 0) as pending_with_hod, _quality_atr_,  
        coalesce(_beyond_7_d_, 0) as grv_pendng_more_svn_d,
        /*coalesce(_within_7_d_, 0) as _within_7_d_,*/ 
        coalesce(_within_7_t_15_d_, 0) as within_7_t_15_d, 
        coalesce(_within_16_t_30_d_, 0) as within_16_t_30_d,
        coalesce(_beyond_30_d_, 0) as beyond_30_d, 
        coalesce(ROUND(_avg_pending_,2),0) as avg_no_days_to_submit_atr,
        coalesce((case when _within_7_d_ <= 0 then 0 else _within_7_d_ end), 0) as grv_pendng_upto_svn_d,
        coalesce(ROUND((case when (_beyond_7_d_!= 0) then (_beyond_7_d_::numeric/_pnd_) end)*100, 2),0) as percent_bynd_svn_days,
        coalesce(ROUND((case when (_quality_atr_!= 0) then (_quality_atr_::numeric/_atr_) end)*100, 2),0) as qual_atr_recv,
        coalesce(ROUND(_six_avg_atr_pnd_, 2),0) as avg_no_days_to_submit_atr_six,
        coalesce(_rtrn_griev_cnt_, 0) as rtrn_griev_cnt, 
        coalesce(ROUND(_avg_rtrn_griev_times_cnt_, 2),0) as avg_rtrn_griev_times_cnt,
        office_type,
        case
            when office_type = 1 then 8
            when office_type = 2 then 1
            when office_type = 3 then 2
            when office_type = 4 then 3
            when office_type = 5 then 4
            when office_type = 6 then 5
            when office_type = 7 then 6
            when office_type = 8 then 7
        end as office_ord
from processing_unit;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--=============================================================================================================================================================
--================================================================== MIS 4 ====================================================================================
--=============================================================================================================================================================
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------- ALL District for HOD ------->>
select count(1), com.office_id, com.office_name, cdm.district_id, cdm.district_name, gm.current_status
from forwarded_latest_3_bh_mat gm 
inner join cmo_office_master com on com.office_id = gm.assigned_to_office_id  
inner join cmo_districts_master cdm on cdm.district_id = gm.district_id 
where gm.assigned_to_office_id = 55
group by com.office_id, com.office_name, cdm.district_id, cdm.district_name, gm.current_status;
------------- ALL Sub-district for HOD ------->>
select count(1), com.office_id, com.office_name, cdm.district_id, cdm.district_name, gm.current_status, csdm.sub_division_name, csdm.sub_division_id 
from forwarded_latest_3_bh_mat gm 
inner join cmo_office_master com on com.office_id = gm.assigned_to_office_id  
inner join cmo_districts_master cdm on cdm.district_id = gm.district_id
inner join cmo_sub_divisions_master csdm ON cdm.district_id = csdm.district_id 
where gm.assigned_to_office_id = 55 and csdm.district_id = 23
group by com.office_id, com.office_name, cdm.district_id, cdm.district_name, gm.current_status, csdm.sub_division_name, csdm.sub_division_id;
------------- ALL Block-Municipallity for HOD ------->>
select count(1), csdm.sub_division_name, cbm.block_id, cbm.block_name, cmm.municipality_id, cmm.municipality_name 
from forwarded_latest_3_bh_mat gm 
inner join cmo_office_master com on com.office_id = gm.assigned_to_office_id  
inner join cmo_districts_master cdm on cdm.district_id = gm.district_id
inner join cmo_sub_divisions_master csdm ON cdm.district_id = csdm.district_id 
inner join cmo_blocks_master cbm on cbm.sub_division_id = csdm.sub_division_id and cbm.district_id = cdm.district_id 
inner join cmo_municipality_master cmm on cmm.sub_division_id = csdm.sub_division_id and cmm.district_id = cdm.district_id 
where gm.assigned_to_office_id = 55 and csdm.district_id = 23 and csdm.sub_division_id = 17
group by csdm.sub_division_name, cbm.block_id, cbm.block_name, cmm.municipality_id, cmm.municipality_name;


select * from cmo_blocks_master cbm where cbm.district_id = 23;
select * from cmo_municipality_master cmm ;
select * from cmo_office_master com where com.office_id = 23;
select * from cmo_districts_master cdm where cdm.district_id = 23;


----------------------------------------------
with total_atr_receive AS (
    select count(1) as atr_recieved, bm.district_id
    from atr_latest_14_bh_mat bm
    inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id
    where bm.current_status in (14,15) /*and bm.grievance_source = 5*/ and bm.assigned_by_office_id = 3
    group by bm.district_id
),total_atr_pending as (
    select count(1) as atr_pending, bh.district_id 
    from forwarded_latest_3_bh_mat bh
    where not exists ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5*/ and bh.assigned_to_office_id = 3
     group by bh.district_id
)
select 
	cdm.district_name::text,
	coalesce(atr_recieved,0) as atr_received_count,
	coalesce(atr_pending,0) as atr_pending_count,
    case when coalesce(atr_recieved,0) > 0 then ((coalesce(atr_recieved,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_received_count_percentage,
    case when coalesce(atr_pending,0) > 0 then ((coalesce(atr_pending,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_pending_count_percentage
    from cmo_districts_master cdm 
left join total_atr_receive tar on cdm.district_id = tar.district_id
left join total_atr_pending tap on tar.district_id = tap.district_id
order by 3 desc;


-------- update mis --------
with grievances_recieved as (
		SELECT COUNT(1) as grievances_recieved_cnt, bh.district_id
		FROM forwarded_latest_3_bh_mat bh
		where 1 = 1 and bh.assigned_to_office_id in (35)
		group by bh.district_id		
), atr_submitted as (
	SELECT bm.district_id, 
		count(distinct bm.grievance_id) as atr_sent_cn
		/*sum(case when bm.current_status = 15 then 1 else 0 end) as _close_,
	    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
	    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
	    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
	    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl*/
	FROM atr_latest_14_bh_mat bm
	inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id 
	where bm.current_status in (14,15) and bm.assigned_by_office_id in (35)
	group by bm.district_id
), close_count as (
    select gm.district_id, count(1) as _close_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from  grievance_master_bh_mat_2 as gm
        inner join forwarded_latest_3_bh_mat bh on gm.grievance_id = bh.grievance_id
            where gm.status = 15 and gm.atr_submit_by_lastest_office_id in (35) 
    group by gm.district_id
), pending_count as (
    select count(1) as _pndddd_ , bh.district_id
    from forwarded_latest_3_bh_mat bh
    where not exists (select 1 from atr_latest_14_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35
    group by bh.district_id
) select 
       row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
		cdm.district_name::text as unit_name,
		cdm.district_id as unit_id,
		coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
		coalesce(ats.atr_sent_cn, 0) as atr_submitted, 
		coalesce(cc.bnft_prvd, 0) as benefit_provided, 
		coalesce(cc._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
		coalesce(cc._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
		coalesce(cc._pnd_policy_dec_, 0) as pending_for_policy_decision,
		coalesce(cc.not_elgbl, 0) as non_actionable, 
		coalesce(cc._close_, 0) as total_disposed, 
		coalesce(pc._pndddd_, 0) as total_pending
		from grievances_recieved gr
        left join cmo_districts_master cdm on gr.district_id = cdm.district_id
		left join atr_submitted ats on gr.district_id = ats.district_id 
        left join pending_count pc on ats.district_id = pc.district_id
       	left join close_count cc on gr.district_id = cc.district_id;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
       ------------------------------ subdivition ------------------------------------
       
with grievances_recieved as (
		SELECT COUNT(1) as grievances_recieved_cnt, bh.sub_division_id
		FROM forwarded_latest_3_bh_mat_2 bh
		where 1 = 1 and bh.assigned_to_office_id in (35) and bh.district_id = 23
		group by bh.sub_division_id		
), atr_submitted as (
	SELECT bm.sub_division_id, 
		count(distinct bm.grievance_id) as atr_sent_cn
	FROM atr_latest_14_bh_mat_2 bm
	inner join forwarded_latest_3_bh_mat_2 bh ON bm.grievance_id = bh.grievance_id 
	where bm.current_status in (14,15) and bm.assigned_by_office_id in (35) and bm.district_id = 23
	group by bm.sub_division_id
), close_count as (
    select gm.sub_division_id, count(1) as _close_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from  grievance_master_bh_mat_2 as gm
        inner join forwarded_latest_3_bh_mat_2 bh on gm.grievance_id = bh.grievance_id
            where gm.status = 15 and gm.atr_submit_by_lastest_office_id in (35) and gm.district_id = 23
    group by gm.sub_division_id
), pending_count as (
    select count(1) as _pndddd_ , bh.sub_division_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35 and bh.district_id = 23
    group by bh.sub_division_id
) select 
       row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
		csdm.sub_division_name::text as unit_name,
		csdm.sub_division_id as unit_id,
		coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
		coalesce(ats.atr_sent_cn, 0) as atr_submitted, 
		coalesce(cc.bnft_prvd, 0) as benefit_provided, 
		coalesce(cc._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
		coalesce(cc._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
		coalesce(cc._pnd_policy_dec_, 0) as pending_for_policy_decision,
		coalesce(cc.not_elgbl, 0) as non_actionable, 
		coalesce(cc._close_, 0) as total_disposed, 
		coalesce(pc._pndddd_, 0) as total_pending
		from grievances_recieved gr
		left join cmo_sub_divisions_master csdm on csdm.sub_division_id = gr.sub_division_id
        left join cmo_districts_master cdm on csdm.district_id = cdm.district_id
		left join atr_submitted ats on csdm.sub_division_id = ats.sub_division_id 
        left join pending_count pc on ats.sub_division_id = pc.sub_division_id
       	left join close_count cc on pc.sub_division_id = cc.sub_division_id;

        ------------------------------ block-municipality  -----------------------------------
with grievances_recieved as (
		SELECT COUNT(1) as grievances_recieved_cnt, bh.block_id, bh.municipality_id
		FROM forwarded_latest_3_bh_mat_2 bh
		where 1 = 1 and bh.assigned_to_office_id in (35) and bh.district_id in (23) and bh.sub_division_id in (17)
		group by bh.block_id, bh.municipality_id	
), atr_submitted as (
	SELECT count(1) as atr_sent_cn, bh.block_id, bh.municipality_id
	FROM atr_latest_14_bh_mat_2 bh
	inner join forwarded_latest_3_bh_mat_2 bm ON bm.grievance_id = bh.grievance_id 
	where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.district_id = 23 and bh.sub_division_id in (17) 
	group by bh.block_id, bh.municipality_id
), close_count as (
    select bh.block_id, bh.municipality_id,
    		count(1) as _close_, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 bh
        inner join forwarded_latest_3_bh_mat_2 bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.atr_submit_by_lastest_office_id in (35) and bh.district_id = 23 and bh.sub_division_id in (17)
    group by bh.block_id, bh.municipality_id
), pending_count as (
    select count(1) as _pndddd_ , bh.block_id, bh.municipality_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35 and bh.district_id = 23 and bh.sub_division_id in (17)
    group by bh.block_id, bh.municipality_id
) select 
       row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
       case 
       	when cmo_blocks_master.block_name is not null then concat(cmo_blocks_master.block_name,'(B)')
       	when cmo_municipality_master.municipality_name is not null then concat(cmo_municipality_master.municipality_name, '(M)')
       end as unit_name,   
		coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
		coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
		coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
		coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
		coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
		coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
		coalesce(close_count.not_elgbl) as non_actionable, 
		coalesce(close_count._close_, 0) as total_disposed, 
		coalesce(pending_count._pndddd_, 0) as total_pending
		from grievances_recieved 
		left join cmo_blocks_master on cmo_blocks_master.block_id = grievances_recieved.block_id 
		left join cmo_municipality_master on cmo_municipality_master.municipality_id = grievances_recieved.municipality_id
		left join atr_submitted on grievances_recieved.block_id = atr_submitted.block_id or grievances_recieved.municipality_id = atr_submitted.municipality_id
        left join pending_count on grievances_recieved.block_id = pending_count.block_id or grievances_recieved.municipality_id = pending_count.municipality_id
       	left join close_count on grievances_recieved.block_id = close_count.block_id or grievances_recieved.municipality_id = close_count.municipality_id;
       
  ------------------------------------------------- GPS For Blocks ----------------------------------------------------------
              
SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id, bh.ward_id
FROM forwarded_latest_3_bh_mat_2 bh
where 1 = 1 and bh.assigned_to_office_id in (35) and bh.district_id in (23) and bh.sub_division_id in (17) and  (bh.block_id in (29, 30) or bh.municipality_id in (15,16))
group by bh.gp_id , bh.ward_id 
     

with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id
	FROM forwarded_latest_3_bh_mat_2 bh
	where 1 = 1 and bh.assigned_to_office_id in (35) and bh.district_id in (23) and bh.sub_division_id in (17) and bh.block_id in (30)
	group by bh.gp_id	
), atr_submitted as (
	SELECT count(1) as atr_sent_cn, bh.gp_id
	FROM atr_latest_14_bh_mat_2 bh
	inner join forwarded_latest_3_bh_mat_2 bm ON bm.grievance_id = bh.grievance_id 
	where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.district_id = 23 and bh.sub_division_id in (17) and bh.block_id in (30)
	group by bh.gp_id
), close_count as (
    select bh.gp_id,
    		count(1) as close, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 bh
        inner join forwarded_latest_3_bh_mat_2 bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.atr_submit_by_lastest_office_id in (35) and bh.district_id = 23 and bh.sub_division_id in (17) and bh.block_id in (30)
	group by bh.gp_id
), pending_count as (
    select count(1) as pndddd , bh.gp_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35 and bh.district_id = 23 and bh.sub_division_id in (17) and bh.block_id in (30)
	group by bh.gp_id
) select 
   row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
    cmo_gram_panchayat_master.gp_name as unit_name,   
	coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
	coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
	coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
	coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
	coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90, 
	coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
	coalesce(close_count.not_elgbl) as non_actionable, 
	coalesce(close_count.close, 0) as total_disposed, 
	coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved  
left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
left join atr_submitted on grievances_recieved.gp_id = atr_submitted.gp_id  
left join pending_count on grievances_recieved.gp_id = pending_count.gp_id  
left join close_count on grievances_recieved.gp_id = close_count.gp_id;

------------------------------------------------------------ Ward For Municipality -------------------------------------------------------------------

with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt, bh.ward_id
	FROM forwarded_latest_3_bh_mat_2 bh
	where 1 = 1 and bh.assigned_to_office_id in (35) and bh.district_id in (23) and bh.sub_division_id in (17) and bh.municipality_id in (16)
		  and ward_id is not null
	group by bh.ward_id	
), atr_submitted as (
	SELECT count(1) as atr_sent_cn, bh.ward_id
	FROM atr_latest_14_bh_mat_2 bh
	inner join forwarded_latest_3_bh_mat_2 bm ON bm.grievance_id = bh.grievance_id 
	where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.district_id = 23 and bh.sub_division_id in (17) and bh.municipality_id in (16)
	group by bh.ward_id
), close_count as (
    select bh.ward_id,
    		count(1) as close, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 bh
        inner join forwarded_latest_3_bh_mat_2 bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.atr_submit_by_lastest_office_id in (35) and bh.district_id = 23 and bh.sub_division_id in (17) and bh.municipality_id in (16)
	group by bh.ward_id
), pending_count as (
    select count(1) as pndddd , bh.ward_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35 and bh.district_id = 23 and bh.sub_division_id in (17) and bh.municipality_id in (16)
	group by bh.ward_id
) select 
   row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
    cmo_wards_master.ward_name as unit_name,   
	coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
	coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
	coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
	coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
	coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90, 
	coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
	coalesce(close_count.not_elgbl, 0) as non_actionable, 
	coalesce(close_count.close, 0) as total_disposed, 
	coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved  
left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id  
left join pending_count on grievances_recieved.ward_id = pending_count.ward_id  
left join close_count on grievances_recieved.ward_id = close_count.ward_id;


-------------------------------------------------------------- Ward AND GP BOTH -----------------------------------------------------------------------------------

with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id, bh.ward_id
	FROM forwarded_latest_3_bh_mat_2 bh
	where (bh.gp_id is not null or bh.ward_id is not null) and bh.assigned_to_office_id in (35) --and bh.district_id in (23) and bh.sub_division_id in (17) 
		and (bh.block_id in (30) or bh.municipality_id in (16))
	group by bh.gp_id, bh.ward_id	
), atr_submitted as (
	SELECT count(1) as atr_sent_cn, bh.gp_id, bh.ward_id
	FROM atr_latest_14_bh_mat_2 bh
	inner join forwarded_latest_3_bh_mat_2 bm ON bm.grievance_id = bh.grievance_id 
	where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) --and bh.district_id = 23 and bh.sub_division_id in (17) 
		and (bh.block_id in (30) or bh.municipality_id in (16))
	group by bh.gp_id, bh.ward_id
), close_count as (
    select bh.gp_id, bh.ward_id,
    		count(1) as close, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 bh
        inner join forwarded_latest_3_bh_mat_2 bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.atr_submit_by_lastest_office_id in (35) --and bh.district_id = 23 and bh.sub_division_id in (17) 
        	and (bh.block_id in (30) or bh.municipality_id in (16))
	group by bh.gp_id, bh.ward_id
), pending_count as (
    select count(1) as pndddd , bh.gp_id, bh.ward_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35 --and bh.district_id = 23 and bh.sub_division_id in (17) 
    	and (bh.block_id in (30) or bh.municipality_id in (16))
	group by bh.gp_id, bh.ward_id
) select 
   row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
   case 
   	when cmo_wards_master.ward_name is not null then concat(cmo_wards_master.ward_name, ' (W)')
   	when cmo_gram_panchayat_master.gp_name is not null then concat(cmo_gram_panchayat_master.gp_name, ' (G)')
   end as unit_name,   
	coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
	coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
	coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
	coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
	coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90, 
	coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
	coalesce(close_count.not_elgbl, 0) as non_actionable, 
	coalesce(close_count.close, 0) as total_disposed, 
	coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved  
left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id or grievances_recieved.gp_id = atr_submitted.gp_id
left join pending_count on grievances_recieved.ward_id = pending_count.ward_id or grievances_recieved.gp_id = pending_count.gp_id  
left join close_count on grievances_recieved.ward_id = close_count.ward_id or grievances_recieved.gp_id = close_count.gp_id;

--------------------------------------- GP and ward filtter ------------------------------

with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id, bh.ward_id
	FROM forwarded_latest_3_bh_mat_2 bh
	where (bh.gp_id is not null or bh.ward_id is not null) and bh.assigned_to_office_id in (35)  --and (bh.block_id in (30) or bh.municipality_id in (16)) 
		and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id	
), atr_submitted as (
	SELECT count(1) as atr_sent_cn, bh.gp_id, bh.ward_id	
	FROM atr_latest_14_bh_mat_2 bh
	inner join forwarded_latest_3_bh_mat_2 bm ON bm.grievance_id = bh.grievance_id 
	where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) -- and (bh.block_id in (30) or bh.municipality_id in (16))
		and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id
), close_count as (
    select bh.gp_id, bh.ward_id,
    		count(1) as close, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 bh
        inner join forwarded_latest_3_bh_mat_2 bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.atr_submit_by_lastest_office_id in (35) -- and (bh.block_id in (30) or bh.municipality_id in (16)) 
        	and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id
), pending_count as (
    select count(1) as pndddd , bh.gp_id, bh.ward_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35 -- and (bh.block_id in (30) or bh.municipality_id in (16)) 
    	and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id
) select 
   row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
   case 
   	when cmo_wards_master.ward_name is not null then concat(cmo_wards_master.ward_name, ' (W)')
   	when cmo_gram_panchayat_master.gp_name is not null then concat(cmo_gram_panchayat_master.gp_name, ' (G)')
   end as unit_name,   
	coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
	coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
	coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
	coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
	coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90, 
	coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
	coalesce(close_count.not_elgbl, 0) as non_actionable, 
	coalesce(close_count.close, 0) as total_disposed, 
	coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved  
left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id or grievances_recieved.gp_id = atr_submitted.gp_id
left join pending_count on grievances_recieved.ward_id = pending_count.ward_id or grievances_recieved.gp_id = pending_count.gp_id  
left join close_count on grievances_recieved.ward_id = close_count.ward_id or grievances_recieved.gp_id = close_count.gp_id;

-------------------------------------------------------------------- Police station and subdistrict wise ------------------------------------------------------
with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt, bh.police_station_id
	FROM forwarded_latest_3_bh_mat_2 bh
	where 1=1 and bh.assigned_to_office_id in (35) and bh.sub_district_id in (25) /*/ and bh.police_station_id in (100)*/
	group by bh.police_station_id
), atr_submitted as (
	SELECT count(1) as atr_sent_cn, bh.police_station_id
	FROM atr_latest_14_bh_mat_2 bh
	inner join forwarded_latest_3_bh_mat_2 bm ON bm.grievance_id = bh.grievance_id 
	where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.sub_district_id in (25) /*/ and bh.police_station_id in (100)*/
	group by bh.police_station_id
), close_count as (
    select bh.police_station_id,
    		count(1) as close, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 bh
        inner join forwarded_latest_3_bh_mat_2 bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.atr_submit_by_lastest_office_id in (35) and bh.sub_district_id in (25) /*/ and bh.police_station_id in (100)*/
	group by bh.police_station_id
), pending_count as (
    select count(1) as pndddd , bh.police_station_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)) 
    and bh.assigned_to_office_id = 35 and bh.sub_district_id in (25) 									/*/ and bh.police_station_id in (100)*/
	group by bh.police_station_id
) select 
   row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
 	cmo_police_station_master.ps_name as unit_name,
	coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
	coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
	coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
	coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
	coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90, 
	coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
	coalesce(close_count.not_elgbl, 0) as non_actionable, 
	coalesce(close_count.close, 0) as total_disposed, 
	coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved   
left join cmo_police_station_master on cmo_police_station_master.ps_id = grievances_recieved.police_station_id
left join atr_submitted on grievances_recieved.police_station_id = atr_submitted.police_station_id  
left join pending_count on grievances_recieved.police_station_id = pending_count.police_station_id  
left join close_count on grievances_recieved.police_station_id = close_count.police_station_id ;

-----------------------------------------------------------------STATE MIS-----------------------------------------------------------------------------------------
with uploaded_count as (
    select grievance_master.grievance_category, count(1) as _uploaded_ 	from grievance_master 
        where grievance_master.grievance_category > 0
    group by grievance_master.grievance_category
), fwd_count as (
    select forwarded_latest_3_bh_mat.grievance_category, cmo_office_master.office_name, count(1) as _fwd_ 
            from forwarded_latest_3_bh_mat 
            left join cmo_office_master on cmo_office_master.office_id = forwarded_latest_3_bh_mat.assigned_by_office_id 
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (3)
            /***** FILTER *****/
                        /*{ f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date} " if from_date and to_date else "" }
                        { f" and forwarded_latest_3_bh_mat.grievance_source in ({source_string}) " if source_string else "" }
                        { f" and forwarded_latest_3_bh_mat.district_id in ({','.join(str(i) for i in district_id)}) " if district_id else "" }*/
    group by forwarded_latest_3_bh_mat.grievance_category , cmo_office_master.office_name
), atr_count as (
    select atr_latest_14_bh_mat.grievance_category, count(1) as _atr_, 
        sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
    from atr_latest_14_bh_mat 
    inner join forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = atr_latest_14_bh_mat.grievance_id
        where atr_latest_14_bh_mat.assigned_by_office_id in (53) and atr_latest_14_bh_mat.current_status in (14,15)
            /***** FILTER *****/
--                        { f" and forwarded_latest_3_bh_mat.assigned_on::date between {from_date} and {to_date} " if from_date and to_date else "" }
--                        { f" and atr_latest_14_bh_mat.grievance_source in ({source_string}) " if source_string else "" }
--                        { f" and atr_latest_14_bh_mat.district_id in ({','.join(str(i) for i in district_id)}) " if district_id else "" }
    group by atr_latest_14_bh_mat.grievance_category
), pending_count as (
    select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ from forwarded_latest_3_bh_mat 
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (53) 
            and not exists (select 1 from atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id 
            and atr_latest_14_bh_mat.current_status in (14,15)
                                                                        /*and atr_latest_14_bh_mat.assigned_by_office_id in ({offc})*/ )
    group by forwarded_latest_3_bh_mat.grievance_category
)
select  
        row_number() over() as sl_no, '{refresh_time}'::timestamp as refresh_time_utc, '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        cmo_grievance_category_master.grievance_cat_id, cmo_grievance_category_master.grievance_category_desc, fwd_count.office_name,
        coalesce(uploaded_count._uploaded_, 0) as griev_upload, coalesce(fwd_count._fwd_, 0) as grv_fwd, coalesce(atr_count._atr_, 0) as atr_rcvd, 
        coalesce(atr_count._clse_, 0) as totl_dspsd,  coalesce(atr_count.bnft_prvd, 0) as srv_prvd, coalesce(atr_count._mt_t_up_win_90_, 0) as mt_t_up_win_90,
        coalesce(atr_count._mt_t_up_bey_90_, 0) as mt_t_up_bey_90, coalesce(atr_count._pnd_policy_dec_, 0) as pnd_policy_dec,
        coalesce(atr_count.not_elgbl, 0) as not_elgbl, coalesce(pending_count._pndddd_, 0) as atr_pndg,
        COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count._mt_t_up_win_90_ + atr_count._mt_t_up_bey_90_ + atr_count._pnd_policy_dec_) = 0 THEN 0 
                            ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count._mt_t_up_win_90_ + atr_count._mt_t_up_bey_90_ + atr_count._pnd_policy_dec_)) * 100 
                    END,2),0) AS bnft_prcnt
from fwd_count 
left join cmo_grievance_category_master on fwd_count.grievance_category = cmo_grievance_category_master.grievance_cat_id 
left join uploaded_count on fwd_count.grievance_category = uploaded_count.grievance_category 
left join atr_count on fwd_count.grievance_category = atr_count.grievance_category
left join pending_count on fwd_count.grievance_category = pending_count.grievance_category
/***** FILTER *****/
--    { f" where cmo_grievance_category_master.benefit_scheme_type = {scm_cat} " if scm_cat else "" }

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select * from grievance_master_bh_mat_2 limit 1;
select * from cmo_sub_office_master csom ;
select * from admin_position_master apm where apm.office_id = 75;
select * from cmo_office_master com ;
select * from cmo_designation_master;

-------------------- raference --------------------
with unassigned_cmo as (
    select 
        grievance_master_bh_mat.assigned_to_office_id,  
        'Unassigned (CMO)' as status,
        null as name_and_esignation_of_the_user,
        null as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    where grievance_master_bh_mat.status = 3 
            and grievance_master_bh_mat.assigned_to_office_id in (35) /*Variable*/
    group by grievance_master_bh_mat.assigned_to_office_id
), unassigned_other_hod as (
    select 
        grievance_master_bh_mat.assigned_to_office_id,  
        'Unassigned (Other HoD)' as status,
        null as name_and_esignation_of_the_user,
        null as user_status,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    where grievance_master_bh_mat.status = 5 
            and grievance_master_bh_mat.assigned_to_office_id in (35) /*Variable*/
    group by grievance_master_bh_mat.assigned_to_office_id
 ), recalled as (
    select 
        grievance_master_bh_mat.assigned_by_office_id,  
        'Recalled' as status,
        null as name_and_esignation_of_the_user,
        null as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    where grievance_master_bh_mat.status = 16
            and grievance_master_bh_mat.assigned_by_office_id in (35) /*Variable*/
    group by grievance_master_bh_mat.assigned_by_office_id
), user_wise_atr_pendancy as (
    select               
        grievance_master_bh_mat.assigned_to_office_id,  
        'User wise ATR Pendency' as status,
        concat(admin_user_details.official_name,' (', cmo_designation_master.designation_name, ') ')as name_and_esignation_of_the_user,
        admin_user_role_master.role_master_name as user_status,
        sum(case when grievance_master_bh_mat.status in (4,7,8) then 1 else 0 end) as pending_grievances,
        sum(case when grievance_master_bh_mat.status in (9,11) then 1 else 0 end) as pending_atrs,
        sum(case when grievance_master_bh_mat.status in (6,10,12) then 1 else 0 end) as atr_returned_for_review,
        case
            when admin_user_role_master.role_master_id in (4,5) then sum(case when grievance_master_bh_mat.status in (16,17) then 1 else 0 end)
            else null
        end::int as atr_auto_returned_from_cmo,
        sum(case when grievance_master_bh_mat.status in (4,7,8,9,11,6,10,12) then 1 else 0 end) as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_master_bh_mat.grievance_id
    left join admin_position_master on grievance_master_bh_mat.assigned_to_position = admin_position_master.position_id
    left join cmo_designation_master on admin_position_master.designation_id = cmo_designation_master.designation_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join admin_user_details on grievance_master_bh_mat.assigned_to_id = admin_user_details.admin_user_id
    where grievance_master_bh_mat.assigned_to_office_id in (35) /*Variable*/
    group by grievance_master_bh_mat.assigned_to_office_id, admin_user_details.official_name, cmo_designation_master.designation_name,
            admin_user_role_master.role_master_name, admin_user_role_master.role_master_id
    order by admin_user_role_master.role_master_id
                ), user_wise_atr_pendancy_otr_hod as (
                    select               
                        grievance_master_bh_mat.assigned_by_office_id,  
                        'User wise ATR Pendency' as status,
                        concat(admin_user_details.official_name,' (', cmo_designation_master.designation_name, ') ')as name_and_esignation_of_the_user,
                        concat(admin_user_role_master.role_master_name, ' (Other HOD)') as user_status,
                        count(1) as pending_grievances,
                        null::int as pending_atrs,
                        sum(case when grievance_master_bh_mat.status in (6) then 1 else 0 end) as atr_returned_for_review,
                        null::int as atr_auto_returned_from_cmo,
                        count(1) as total_count
                    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
                    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_master_bh_mat.grievance_id
                    left join admin_position_master on grievance_master_bh_mat.assigned_to_position = admin_position_master.position_id
                    left join cmo_designation_master on admin_position_master.designation_id = cmo_designation_master.designation_id
                    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
                    left join admin_user_details on grievance_master_bh_mat.assigned_to_id = admin_user_details.admin_user_id
                    where grievance_master_bh_mat.assigned_by_office_id in (35) /*Variable*/
                        and grievance_master_bh_mat.assigned_to_office_id not in (35) /*Variable*/
                        and grievance_master_bh_mat.assigned_to_office_cat != 1
                    group by grievance_master_bh_mat.assigned_by_office_id, admin_user_details.official_name, cmo_designation_master.designation_name,
                            admin_user_role_master.role_master_name, admin_user_role_master.role_master_id
                    order by admin_user_role_master.role_master_id
                ), union_part as (
                    select * from unassigned_cmo
                        union all 
                    select * from unassigned_other_hod
                        union all
                    select * from recalled
                        union all
                    select * from user_wise_atr_pendancy
                        union all
                    select * from user_wise_atr_pendancy_otr_hod
                )
                select
                        row_number() over() as sl_no,
                        '2025-02-18 02:30:01.703349+00:00'::timestamp as refresh_time_utc,
                        '2025-02-18 02:30:01.703349+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
                        * 
                from union_part
                
----------------- update ------------------
with unassigned_cmo as (
    select 
        grievance_master_bh_mat.assigned_to_office_id,  
        'Unassigned (CMO)' as status,
        'Unknown Office' as office,
        null as name_and_esignation_of_the_user,
        null as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    where grievance_master_bh_mat.status = 3 
            and grievance_master_bh_mat.assigned_to_office_id in (75) /*Variable*/
    group by grievance_master_bh_mat.assigned_to_office_id
), unassigned_other_hod as (
    select 
        grievance_master_bh_mat.assigned_to_office_id,  
        'Unassigned (Other HoD)' as status,
        'Unknown Office' as office,
        null as name_and_esignation_of_the_user,
        null as user_status,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    where grievance_master_bh_mat.status = 5 
            and grievance_master_bh_mat.assigned_to_office_id in (75) /*Variable*/
    group by grievance_master_bh_mat.assigned_to_office_id
 ), recalled as (
    select 
        grievance_master_bh_mat.assigned_by_office_id,  
        'Recalled' as status,
        'Unknown Office' as office,
        null as name_and_esignation_of_the_user,
        null as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    where grievance_master_bh_mat.status = 16
            and grievance_master_bh_mat.assigned_by_office_id in (75) /*Variable*/
    group by grievance_master_bh_mat.assigned_by_office_id
), user_wise_atr_pendancy as (
    select               
        grievance_master_bh_mat.assigned_to_office_id,  
        'User wise ATR Pendency' as status,
        case 
	        when csom.suboffice_id is not null then csom.suboffice_name
	        when com.office_id is not null then com.office_name
	        else 'Unknown Office'
    	end as office_or_suboffice_name,
        concat(admin_user_details.official_name,' (', cmo_designation_master.designation_name, ') ')as name_and_esignation_of_the_user,
        admin_user_role_master.role_master_name as user_status,
        sum(case when grievance_master_bh_mat.status in (4,7,8) then 1 else 0 end) as pending_grievances,
        sum(case when grievance_master_bh_mat.status in (9,11) then 1 else 0 end) as pending_atrs,
        sum(case when grievance_master_bh_mat.status in (6,10,12) then 1 else 0 end) as atr_returned_for_review,
        case
            when admin_user_role_master.role_master_id in (4,5) then sum(case when grievance_master_bh_mat.status in (16,17) then 1 else 0 end)
            else null
        end::int as atr_auto_returned_from_cmo,
        sum(case when grievance_master_bh_mat.status in (4,7,8,9,11,6,10,12) then 1 else 0 end) as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_master_bh_mat.grievance_id
    left join admin_position_master on grievance_master_bh_mat.assigned_to_position = admin_position_master.position_id
    left join cmo_designation_master on admin_position_master.designation_id = cmo_designation_master.designation_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join admin_user_details on grievance_master_bh_mat.assigned_to_id = admin_user_details.admin_user_id
    left join cmo_office_master com on com.office_id = admin_position_master.office_id
    left join cmo_sub_office_master csom on csom.suboffice_id = admin_position_master.sub_office_id and  csom.office_id = admin_position_master.office_id
    where grievance_master_bh_mat.assigned_to_office_id in (75) /*Variable*/
    group by grievance_master_bh_mat.assigned_to_office_id, csom.suboffice_id, com.office_id, admin_user_details.official_name, cmo_designation_master.designation_name,
            admin_user_role_master.role_master_name, admin_user_role_master.role_master_id
    order by admin_user_role_master.role_master_id
 ), user_wise_atr_pendancy_otr_hod as (
    select               
        grievance_master_bh_mat.assigned_by_office_id,  
        'User wise ATR Pendency' as status,
        case 
	        when csom.suboffice_id is not null then csom.suboffice_name
	        when com.office_id is not null then com.office_name
	        else 'Unknown Office'
    	end as office_or_suboffice_name,
        concat(admin_user_details.official_name,' (', cmo_designation_master.designation_name, ') ')as name_and_esignation_of_the_user,
        concat(admin_user_role_master.role_master_name, ' (Other HOD)') as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        sum(case when grievance_master_bh_mat.status in (6) then 1 else 0 end) as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from grievance_master_bh_mat_2 as grievance_master_bh_mat 
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_master_bh_mat.grievance_id
    left join admin_position_master on grievance_master_bh_mat.assigned_to_position = admin_position_master.position_id
    left join cmo_designation_master on admin_position_master.designation_id = cmo_designation_master.designation_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join admin_user_details on grievance_master_bh_mat.assigned_to_id = admin_user_details.admin_user_id
    left join cmo_office_master com on com.office_id = admin_position_master.office_id
    left join cmo_sub_office_master csom on csom.suboffice_id = admin_position_master.sub_office_id and  csom.office_id = admin_position_master.office_id
    where grievance_master_bh_mat.assigned_by_office_id in (75) /*Variable*/
        and grievance_master_bh_mat.assigned_to_office_id not in (75) /*Variable*/
        and grievance_master_bh_mat.assigned_to_office_cat != 1
    group by grievance_master_bh_mat.assigned_by_office_id, csom.suboffice_id, com.office_id, admin_user_details.official_name, cmo_designation_master.designation_name,
            admin_user_role_master.role_master_name, admin_user_role_master.role_master_id
    order by admin_user_role_master.role_master_id
), union_part as (
                    select * from unassigned_cmo
                        union all 
                    select * from unassigned_other_hod
                        union all
                    select * from recalled
                        union all
                    select * from user_wise_atr_pendancy
                        union all
                    select * from user_wise_atr_pendancy_otr_hod
                )
                select
                        row_number() over() as sl_no,
                        '2025-02-18 02:30:01.703349+00:00'::timestamp as refresh_time_utc,
                        '2025-02-18 02:30:01.703349+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
                        * 
                from union_part


select * from cmo_office_master com;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
with grievances_recieved as (
	SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id, bh.ward_id
	FROM forwarded_latest_3_bh_mat_2 bh
	where (bh.gp_id is not null or bh.ward_id is not null) and bh.assigned_to_office_id in (35)  --and (bh.block_id in (30) or bh.municipality_id in (16)) 
		and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id	
), atr_submitted as (
	SELECT count(1) as atr_sent_cn, bh.gp_id, bh.ward_id
	FROM atr_latest_14_bh_mat_2 bh
	inner join forwarded_latest_3_bh_mat_2 bm ON bm.grievance_id = bh.grievance_id 
	where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) -- and (bh.block_id in (30) or bh.municipality_id in (16))
		and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id
), close_count as (
    select bh.gp_id, bh.ward_id,
    		count(1) as close, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 bh
        inner join forwarded_latest_3_bh_mat_2 bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.atr_submit_by_lastest_office_id in (35) -- and (bh.block_id in (30) or bh.municipality_id in (16)) 
        	and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id
), pending_count as (
    select count(1) as pndddd , bh.gp_id, bh.ward_id
    from forwarded_latest_3_bh_mat_2 bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
    and bh.assigned_to_office_id = 35 -- and (bh.block_id in (30) or bh.municipality_id in (16)) 
    	and ( bh.gp_id in (309) or bh.ward_id in (2786) )
	group by bh.gp_id, bh.ward_id
) select 
   row_number() over() as sl_no,
--	   '{refresh_time}'::timestamp as refresh_time_utc,
--		'{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
   case 
   	when cmo_wards_master.ward_name is not null then concat(cmo_wards_master.ward_name, ' (W)')
   	when cmo_gram_panchayat_master.gp_name is not null then concat(cmo_gram_panchayat_master.gp_name, ' (G)')
   end as unit_name,   
	coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
	coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
	coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
	coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
	coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90, 
	coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
	coalesce(close_count.not_elgbl, 0) as non_actionable, 
	coalesce(close_count.close, 0) as total_disposed, 
	coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved  
left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id or grievances_recieved.gp_id = atr_submitted.gp_id
left join pending_count on grievances_recieved.ward_id = pending_count.ward_id or grievances_recieved.gp_id = pending_count.gp_id  
left join close_count on grievances_recieved.ward_id = close_count.ward_id or grievances_recieved.gp_id = close_count.gp_id;


select * from cmo_districts_master cdm where cdm.district_name = 'South Twenty Four Parganas';


select sub_division_name , gm.sub_division_id, count(1) from grievance_master gm 
left join cmo_sub_divisions_master csdm on csdm.sub_division_id = gm.sub_division_id
where  gm.district_id = 22 group by gm.sub_division_id, sub_division_name;


select * from grievance_master where sub_division_id = 81 and district_id = 22;


select * from actual_migration.cmro_griev_master cgm where cgm.griev_id_no = '983604349013052024190749'; -- 17 -- 056


select * from cmo_sub_divisions_master csdm where csdm.sub_division_code = '056';

select * from cmo_districts_master cdm where district_id = 20;
select * from cmo_districts_master cdm where district_id = 22;





