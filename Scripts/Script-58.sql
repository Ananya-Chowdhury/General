--------------------------------------------------------- Other Hod Wise MIS - 5 ----------------------------------------------------------------------------------

----------------------------------------------------------- Reference --------------------------------------------

select * from atr_latest_13_bh_mat; --- ATR Submitted to Other HOD 
select * from forwarded_latest_5_bh_mat; ---- received from other HOD
select * from pending_for_other_hod_wise_mat_; --- Penindg for Other HOD 
select * from pending_for_other_hod_wise_last_six_months_mat_; --- Penindg for Other HOD 6 moonths 


-------------- State Level and District Level Administrative Review Meeting Report For Other HOD ----------------------
with received_count as (
    select bh.assigned_by_office_id, count(1) as received from forwarded_latest_5_bh_mat bh 
    where bh.assigned_to_office_id in (3)
    group by bh.assigned_by_office_id 
), atr_submitted as (
	select bh.assigned_to_office_id, count(1) as atr_submitted from atr_latest_13_bh_mat bh 
    where bh.assigned_by_office_id in (3)
    group by bh.assigned_to_office_id
), pending_count as (
	select bh.assigned_by_office_id, count(1) as pending,
	    sum(case when (pending_for_other_hod_wise_mat_.days_diff < 7) then 1 else 0 end) as within_7_d,
	    sum(case when (pending_for_other_hod_wise_mat_.days_diff >= 7 and pending_for_other_hod_wise_mat_.days_diff <= 15) then 1 else 0 end) as within_7_t_15_d,
	    sum(case when (pending_for_other_hod_wise_mat_.days_diff > 15 and pending_for_other_hod_wise_mat_.days_diff <= 30) then 1 else 0 end) as within_16_t_30_d,
	    avg(pending_for_other_hod_wise_mat_.days_diff) as avg_pending
	from forwarded_latest_5_bh_mat bh
	left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
	where not exists (select 1 from atr_latest_13_bh_mat where atr_latest_13_bh_mat.grievance_id = bh.grievance_id)
			 and bh.assigned_to_office_id in (3)
	group by bh.assigned_by_office_id
), quality_of_atr as (
		select gl.grievance_id, gl.grievance_status, count(1) as count_status_wise
            from grievance_lifecycle gl
            inner join forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = gl.grievance_id
            where gl.grievance_status in (6,13) 
	group by gl.grievance_id, gl.grievance_status	
), atr_count as (
    select bh.assigned_by_office_id, count(distinct bh.grievance_id) as atr , 
        sum(case when (quality_of_atr.grievance_status = 13 and quality_of_atr.count_status_wise = 1) then 1 else 0 end) as quality_atr, 
        sum(case when (quality_of_atr.grievance_status = 6) then 1 else 0 end) as rtrn_griev_cnt, 
        avg(case when (quality_of_atr.grievance_status = 6) then (quality_of_atr.count_status_wise) end) as avg_rtrn_griev_times_cnt, 
        avg(pending_for_other_hod_wise_last_six_months_mat_.days_diff) as six_avg_atr_pnd
    from atr_latest_13_bh_mat bh
    inner join forwarded_latest_5_bh_mat on bh.grievance_id = forwarded_latest_5_bh_mat.grievance_id
    left join quality_of_atr on quality_of_atr.grievance_id = bh.grievance_id
    left join pending_for_other_hod_wise_last_six_months_mat_ on bh.grievance_id = pending_for_other_hod_wise_last_six_months_mat_.grievance_id and quality_of_atr.grievance_status = 13
    where bh.current_status in (14,15) and bh.assigned_to_office_id in (3)
    group by bh.assigned_by_office_id 
) select row_number() over() as sl_no,
		com.office_id, 
		com.office_name,
		coalesce(rc.assigned_by_office_id, ats.assigned_to_office_id) AS office_id_II,
		coalesce(rc.received, 0) AS grievances_received,
	    coalesce(ats.atr_submitted, 0) AS atr_submitted,
	    coalesce(pc.within_7_d, 0) AS pending_within_7,
	    coalesce(pc.within_7_t_15_d, 0) AS pending_within_7_to_15_days,
	    coalesce(pc.within_16_t_30_d, 0) AS pending_within_16_to_30_days,
	    case
            when coalesce(pc.pending <= 0) then 0 else (coalesce(pc.pending, 0) - coalesce(pc.within_7_d, 0))
	    end as beyond_7_d,
	    case
            when coalesce(pc.pending <= 0) then 0 
            else (coalesce(pc.pending, 0) - coalesce(pc.within_7_d, 0) + coalesce(pc.within_7_t_15_d, 0) + coalesce(pc.within_16_t_30_d, 0))
	    end as beyond_30_d,
		coalesce(pc.pending, 0) AS grievance_pending_with_hod,
		coalesce(pc.avg_pending, 0) AS avg_pending,
    	coalesce(round(
    				case 
        				when coalesce(pc.pending, 0) > 0 
        				then (coalesce(pc.pending, 0) - coalesce(pc.within_7_d, 0))::NUMERIC / coalesce(pc.pending, 1) * 100 
        				ELSE 0 
        			END, 2 ), 0 ) AS percent_bynd_svn_days,
        coalesce(ROUND((case when (ac.quality_atr!= 0) then (ac.quality_atr::numeric/ac.atr) end)*100, 2),0) as qual_atr_recv,
        coalesce(ac.atr, 0) AS atr_count,
    	coalesce(ac.rtrn_griev_cnt, 0) AS atr_return_for_review,
    	coalesce(ac.avg_rtrn_griev_times_cnt, 0) AS avg_atr_return_for_review,
    	coalesce(ac.quality_atr, 0) AS quality_of_atr_receiving,
    	coalesce(ac.six_avg_atr_pnd, 0) AS num_dys_submit_atr,
    	coalesce(ROUND(pc.avg_pending,2),0) as avg_no_days_to_submit_atr,
    	coalesce(ROUND(ac.six_avg_atr_pnd, 2),0) as avg_no_days_to_submit_atr_six
from received_count rc
left join atr_submitted ats on rc.assigned_by_office_id = ats.assigned_to_office_id
left join pending_count pc on pc.assigned_by_office_id = rc.assigned_by_office_id
left join atr_count ac on rc.assigned_by_office_id = ac.assigned_by_office_id
left join cmo_office_master com on com.office_id  = rc.assigned_by_office_id;

------------ Sample by ME ---------
with received_count as (
	    select bh.assigned_by_office_id, count(1) as received from forwarded_latest_5_bh_mat bh 
	    where bh.assigned_to_office_id in (3)
	   /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
	    group by bh.assigned_by_office_id 
	), atr_submitted as (
    	select bh.assigned_to_office_id, count(1) as atr_submitted from atr_latest_13_bh_mat bh 
	    where bh.assigned_by_office_id in (3)
	   /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
	    group by bh.assigned_to_office_id
    ) select 
	    coalesce(rc.assigned_by_office_id, ats.assigned_to_office_id) AS office_id,
	    coalesce(rc.received, 0) AS grievances_received,
	    coalesce(ats.atr_submitted, 0) AS atr_submitted
from received_count rc
full join atr_submitted ats on rc.assigned_by_office_id = ats.assigned_to_office_id;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------- Category wise Grievance Resolution Status MIS - 3 For Other HOD -----------------------------
with received_count as (
		select bh.grievance_category, bh.assigned_by_office_id, count(1) as received 	
		from forwarded_latest_5_bh_mat bh  
	     where bh.grievance_category > 0 and bh.assigned_to_office_id in (3)
	     /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
		group by bh.grievance_category, bh.assigned_by_office_id
), atr_submitted as (
    	select bh.grievance_category, bh.assigned_to_office_id, count(1) as atr_submitted 
    	from atr_latest_13_bh_mat bh 
	    where bh.assigned_by_office_id in (3)
	   /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
	    group by bh.grievance_category, bh.assigned_to_office_id
), pending_count as (
    	select bh.grievance_category, bh.assigned_by_office_id, count(1) as pending
    from forwarded_latest_5_bh_mat bh
    left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
    where not exists (select 1 from atr_latest_13_bh_mat
           where atr_latest_13_bh_mat.grievance_id = bh.grievance_id and atr_latest_13_bh_mat.current_status in (14,15))
     and bh.assigned_to_office_id in (3)
    group by bh.assigned_by_office_id, bh.grievance_category
) select 
	row_number() over() as sl_no,
	cgcm.grievance_category_desc, 
	coalesce(com.office_name,'N/A') as office_name,
    cgcm.parent_office_id, 
    com.office_id,
	    coalesce(rc.received, 0) AS grievances_received,
	    coalesce(ats.atr_submitted, 0) AS atr_submitted,
	    coalesce(pc.pending, 0) AS pending_to_other_hod
	from received_count rc
	left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = rc.grievance_category
	left join atr_submitted ats on ats.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = ats.grievance_category
	left join pending_count pc on pc.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
	order by com.office_name, cgcm.grievance_category_desc

-------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------- Residing District wise and Category wise Grievance Resolution Status MIS - 4 For Other HOD -----------------------
----------------------- reference ------------------
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.district_id
            from forwarded_latest_5_bh_mat_2 as bh
                where 1 = 1  and bh.assigned_to_office_id in (35)
        group by bh.district_id
),  atr_submitted as (
        SELECT bh.district_id,
            count(distinct bh.grievance_id) as atr_sbmt
                from atr_latest_13_bh_mat_2 as bh
                inner join forwarded_latest_5_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
        where bh.current_status in (14,15)  and bh.assigned_by_office_id in (35)
        group by bh.district_id
), pending_count as (
        select count(1) as pending, bh.district_id
            from forwarded_latest_5_bh_mat_2 as bh
            left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
                where not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
                 and bh.assigned_to_office_id in (35)
        group by bh.district_id
), close_count as (
        select  gm.district_id, count(1) as close,
                sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
                sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
                sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
                sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
            from grievance_master_bh_mat_2 as gm
            inner join forwarded_latest_5_bh_mat_2 as bh on gm.grievance_id = bh.grievance_id
                where gm.status = 15  and bh.assigned_to_office_id in (35)  
        group by gm.district_id
) select
        row_number() over() as sl_no,
        '2025-02-04 12:30:02.038000+00:00'::timestamp as refresh_time_utc,
        '2025-02-04 12:30:02.038000+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        cdm.district_name::text as unit_name,
        cdm.district_id as unit_id,
        coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(ats.atr_sbmt, 0) as atr_submitted,
        coalesce(cc.bnft_prvd, 0) as benefit_provided,
        coalesce(cc.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
        coalesce(cc.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90,
        coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
        coalesce(cc.not_elgbl, 0) as non_actionable,
        coalesce(cc.close, 0) as total_disposed,
        coalesce(pc.pending, 0) as total_pending
from grievances_recieved gr
left join cmo_districts_master cdm on gr.district_id = cdm.district_id
left join atr_submitted ats on gr.district_id = ats.district_id
left join pending_count pc on gr.district_id = pc.district_id
left join close_count cc on gr.district_id = cc.district_id;

	   
 --------------------- OTHER HOD -------------
   
--- 1> "====================== All districts ======================"
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.district_id
        	FROM forwarded_latest_5_bh_mat bh
        		where 1 = 1 and bh.assigned_to_office_id in (35) /*{date_range}{data_source}*/
        group by bh.district_id
),  atr_submitted as (
    	SELECT bh.district_id, 
        	count(distinct bh.grievance_id) as atr_sbmt
        /*sum(case when bh.current_status = 15 then 1 else 0 end) as _close_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl*/
	    		FROM atr_latest_13_bh_mat bh 
	    		inner join forwarded_latest_5_bh_mat bm ON bh.grievance_id = bm.grievance_id 
	    where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) /*{data_source}
	    {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }*/
	    group by bh.district_id
), pending_count as (
        select count(1) as pending, bh.district_id
        	from forwarded_latest_5_bh_mat bh
        	left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
        		where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
        and bh.assigned_to_office_id in (35) /*{data_source}{date_range}*/
        group by bh.district_id
), close_count as (
	    select  gm.district_id, count(1) as _close_,
	            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
	            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
	            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
	            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
	        from grievance_master_bh_mat gm
	        inner join forwarded_latest_5_bh_mat bh on gm.grievance_id = bh.grievance_id
	            where gm.status = 15 and bh.assigned_to_office_id in (35) /*{data_source}{date_range}*/
	    group by gm.district_id
) select 
        row_number() over() as sl_no,
--        '{refresh_time}'::timestamp as refresh_time_utc,
--        '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        cdm.district_name::text as unit_name,
        cdm.district_id as unit_id,
        coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(ats.atr_sbmt, 0) as atr_submitted, 
        coalesce(cc.bnft_prvd, 0) as benefit_provided, 
        coalesce(cc._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
        coalesce(cc._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
        coalesce(cc._pnd_policy_dec_, 0) as pending_for_policy_decision,
        coalesce(cc.not_elgbl, 0) as non_actionable,
        coalesce(cc._close_, 0) as total_disposed,  
        coalesce(pc.pending, 0) as total_pending
        from grievances_recieved gr
        left join cmo_districts_master cdm on gr.district_id = cdm.district_id
        left join atr_submitted ats on gr.district_id = ats.district_id 
        left join pending_count pc on gr.district_id = pc.district_id
        left join close_count cc on gr.district_id = cc.district_id
	            
-- 2> "====================== All sub divisions ======================"
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.sub_division_id
        	FROM forwarded_latest_5_bh_mat bh
        		where bh.sub_division_id is not null and bh.assigned_to_office_id in (35) and bh.district_id in (5) /*{date_range}{data_source}*/
        group by bh.sub_division_id
),  atr_submitted as (
    	SELECT bh.sub_division_id, 
        	count(distinct bh.grievance_id) as atr_sbmt
        /*sum(case when bh.current_status = 15 then 1 else 0 end) as _close_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl*/
	    		FROM atr_latest_13_bh_mat bh 
	    		inner join forwarded_latest_5_bh_mat bm ON bh.grievance_id = bm.grievance_id 
	    where bh.sub_division_id is not null and bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.district_id in (5)
	    /*{data_source}
	    {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" }*/
	    group by bh.sub_division_id  
), pending_count as (
        select count(1) as pending, bh.sub_division_id
        	from forwarded_latest_5_bh_mat bh
        	left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
        		where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
        and bh.assigned_to_office_id in (35) and bh.sub_division_id is not null and bh.district_id in (5) /*{data_source}{date_range}*/
        group by bh.sub_division_id
), close_count as (
	    select  gm.sub_division_id, count(1) as _close_,
	            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
	            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
	            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
	            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
	        from grievance_master_bh_mat gm
	        inner join forwarded_latest_5_bh_mat bh on gm.grievance_id = bh.grievance_id
	        where bh.sub_division_id is not null and gm.status = 15 and bh.assigned_to_office_id in (35) and bh.district_id in (5)
			/*{date_range_p}{data_source}*/
	    group by gm.sub_division_id	    
) select 
        row_number() over() as sl_no,
--        '{refresh_time}'::timestamp as refresh_time_utc,
--        '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        csdm.sub_division_name::text as unit_name,
        csdm.sub_division_id as unit_id,
        coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(ats.atr_sbmt, 0) as atr_submitted,  
        coalesce(cc.bnft_prvd, 0) as benefit_provided, 
        coalesce(cc._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
        coalesce(cc._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
        coalesce(cc._pnd_policy_dec_, 0) as pending_for_policy_decision,
        coalesce(cc.not_elgbl, 0) as non_actionable,
        coalesce(cc._close_, 0) as total_disposed, 
        coalesce(pc.pending, 0) as total_pending
        from grievances_recieved gr
        left join cmo_sub_divisions_master csdm on csdm.sub_division_id = gr.sub_division_id
        left join cmo_districts_master cdm on csdm.district_id = cdm.district_id
        left join atr_submitted ats on csdm.sub_division_id = ats.sub_division_id 
        left join pending_count pc on ats.sub_division_id = pc.sub_division_id
        left join close_count cc on pc.sub_division_id = cc.sub_division_id;  -- mismatch in total pending
        
-- 3> "====================== All blocks and municipalities ======================"
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.block_id, bh.municipality_id
            FROM forwarded_latest_5_bh_mat bh
            where 1 = 1 and bh.assigned_to_office_id in (35) and bh.district_id in (5) and bh.sub_division_id in (20,21,22) /*{date_range} {data_source}*/
        group by bh.block_id, bh.municipality_id	
), atr_submitted as (
    SELECT count(1) as atr_sent_cn, bh.block_id, bh.municipality_id
        FROM atr_latest_13_bh_mat bh
        inner join forwarded_latest_5_bh_mat bm ON bm.grievance_id = bh.grievance_id 
        where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.district_id in (5) and bh.sub_division_id in (20,21,22) 
        /*{date_range} {data_source}*/
    group by bh.block_id, bh.municipality_id
 ), close_count as (
	    select bh.block_id, bh.municipality_id,
	            count(1) as _close_, 
	            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
	            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
	            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
	            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
	        from grievance_master_bh_mat bh
	        inner join forwarded_latest_5_bh_mat bm on bm.grievance_id = bh.grievance_id
	        where bh.status = 15 and bh.assigned_to_office_id in (35) and bh.district_id in (5) and bh.sub_division_id in (20,21,22) 
	        /*{date_range_p} {data_source}*/
	    group by bh.block_id, bh.municipality_id
), pending_count as (
    select count(1) as _pndddd_ , bh.block_id, bh.municipality_id
        from forwarded_latest_5_bh_mat bh
        left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
        	where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
        and bh.assigned_to_office_id in (35) and bh.district_id in (5) and bh.sub_division_id in (20,21,22) 
        /*{date_range} {data_source}*/ 
    group by bh.block_id, bh.municipality_id              
	) select 
	    row_number() over() as sl_no,
--	    '{refresh_time}':: timestamp as refresh_time_utc,
--	    '{refresh_time}':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
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
           
 -- 4> " ====================== All Sub-districts or Police Stations ====================== "         
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.police_station_id
            FROM forwarded_latest_5_bh_mat bh
            where 1=1 and bh.assigned_to_office_id in (35) and bh.sub_district_id in (13) /*and bh.police_station_id in (74)
            {date_range} {data_source}*/ 
        group by bh.police_station_id
), atr_submitted as (
        SELECT count(1) as atr_sent_cn, bh.police_station_id
        FROM atr_latest_13_bh_mat bh
        inner join forwarded_latest_5_bh_mat bm ON bm.grievance_id = bh.grievance_id 
        where bh.current_status in (14, 15) and bh.assigned_by_office_id in (35) and bh.sub_district_id in (13) /*and bh.police_station_id in (74)
          {date_range} {data_source}*/ 
        group by bh.police_station_id    
), pending_count as (
        select count(1) as pndddd , bh.police_station_id
        from forwarded_latest_5_bh_mat bh
        left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
        where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)) 
        and bh.assigned_to_office_id in (35) and bh.sub_district_id in (13) /*and bh.police_station_id in (74)
          {date_range} {data_source}*/
        group by bh.police_station_id             
 ), close_count as (
	    select bh.police_station_id,
	            count(1) as _close_, 
	            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
	            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
	            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
	            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
	        from grievance_master_bh_mat bh
	        inner join forwarded_latest_5_bh_mat bm on bm.grievance_id = bh.grievance_id
	        where bh.status = 15 and bh.assigned_to_office_id in (35) and bh.sub_district_id in (13) /*and bh.police_station_id in (74)
          {date_range} {data_source}*/
	    group by bh.police_station_id
    ) select 
        row_number() over() as sl_no,
        '{refresh_time}'::timestamp as refresh_time_utc,
        '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        cmo_police_station_master.ps_name as unit_name,
        coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
        coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
        coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
        coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
        coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
        coalesce(close_count.not_elgbl, 0) as non_actionable, 
        coalesce(close_count._close_, 0) as total_disposed, 
        coalesce(pending_count.pndddd, 0) as total_pending
    from grievances_recieved   
    left join cmo_police_station_master on cmo_police_station_master.ps_id = grievances_recieved.police_station_id
    left join atr_submitted on grievances_recieved.police_station_id = atr_submitted.police_station_id  
    left join pending_count on grievances_recieved.police_station_id = pending_count.police_station_id  
    left join close_count on grievances_recieved.police_station_id = close_count.police_station_id;    
    
 -- 5> " ====================== All Wards for Municipalities ====================== "   	   
 with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.ward_id
            FROM forwarded_latest_5_bh_mat bh
            where ward_id is not null and bh.assigned_to_office_id in (35) and bh.municipality_id in (2) and bh.ward_id in (33)
            /*{date_range} {data_source} */
        group by bh.ward_id	    
    ), atr_submitted as (
        SELECT count(1) as atr_sent_cn, bh.ward_id
            FROM atr_latest_13_bh_mat bh
            inner join forwarded_latest_5_bh_mat bm ON bm.grievance_id = bh.grievance_id 
            where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.municipality_id in (2) and bh.ward_id in (33) 
            /*{date_range} {data_source} */
        group by bh.ward_id 
    ), close_count as (
        select bh.ward_id,
                count(1) as _close_, 
                sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
                sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
                sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
                sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
            from grievance_master_bh_mat bh
            inner join forwarded_latest_5_bh_mat bm on bm.grievance_id = bh.grievance_id
            where bh.status = 15 and bh.assigned_to_office_id in (35) and bh.municipality_id in (2) and bh.ward_id in (33) 
            /*{date_range} {data_source} */
        group by bh.ward_id
    ), pending_count as (
        select count(1) as pndddd , bh.ward_id
            from forwarded_latest_5_bh_mat bh
            left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
            where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
            and bh.assigned_to_office_id in (35) and bh.municipality_id in (2) and bh.ward_id in (33) 
            /*{date_range} {data_source} */
        group by bh.ward_id  
    ) select 
        row_number() over() as sl_no,
        '{refresh_time}'::timestamp as refresh_time_utc,
        '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        cmo_wards_master.ward_name as unit_name,   
        coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
        coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
        coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
        coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
        coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
        coalesce(close_count.not_elgbl, 0) as non_actionable, 
        coalesce(close_count._close_, 0) as total_disposed, 
        coalesce(pending_count.pndddd, 0) as total_pending
    from grievances_recieved  
    left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
    left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id  
    left join pending_count on grievances_recieved.ward_id = pending_count.ward_id  
    left join close_count on grievances_recieved.ward_id = close_count.ward_id;   

-- 6> " ====================== All Gram Panchayats for Blocks ====================== " 
	with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id
            FROM forwarded_latest_5_bh_mat bh
            where bh.gp_id is not null and bh.assigned_to_office_id in (35) and bh.gp_id in (5) and bh.block_id in (1)
            /*{date_range} {data_source} */
        group by bh.gp_id	   
    ), atr_submitted as (
        SELECT count(1) as atr_sent_cn, bh.gp_id
            FROM atr_latest_13_bh_mat bh
            inner join forwarded_latest_5_bh_mat bm ON bm.grievance_id = bh.grievance_id 
            where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) and bh.gp_id in (5) and bh.block_id in (1)
            /*{date_range} {data_source} */
        group by bh.gp_id   
    ), close_count as (
        select bh.gp_id,
                count(1) as _close_, 
                sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
                sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
                sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
                sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
            from grievance_master_bh_mat bh
            inner join forwarded_latest_5_bh_mat bm on bm.grievance_id = bh.grievance_id
            where bh.status = 15 and bh.assigned_to_office_id in (35) and bh.gp_id in (5) and bh.block_id in (1)
            /*{date_range} {data_source} */
        group by bh.gp_id 
    ), pending_count as (
        select count(1) as pndddd , bh.gp_id
            from forwarded_latest_5_bh_mat bh
            left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
            where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
            and bh.assigned_to_office_id in (35) and bh.gp_id in (5) and bh.block_id in (1)
            /*{date_range} {data_source} */
        group by bh.gp_id
    ) select 
    row_number() over() as sl_no,
--    '{refresh_time}'::timestamp as refresh_time_utc,
--    '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        cmo_gram_panchayat_master.gp_name as unit_name,   
        coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
        coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
        coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
        coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
        coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
        coalesce(close_count.not_elgbl) as non_actionable, 
        coalesce(close_count._close_, 0) as total_disposed, 
        coalesce(pending_count.pndddd, 0) as total_pending
    from grievances_recieved  
    left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
    left join atr_submitted on grievances_recieved.gp_id = atr_submitted.gp_id  
    left join pending_count on grievances_recieved.gp_id = pending_count.gp_id  
    left join close_count on grievances_recieved.gp_id = close_count.gp_id;   
	   
-- 7> " ====================== All Gram Panchayats and Wards for Blocks and Municipalities Both ====================== "	
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id, bh.ward_id
        FROM forwarded_latest_5_bh_mat bh
        where (bh.gp_id is not null or bh.ward_id is not null) and bh.assigned_to_office_id in (35) /*{date_range} {data_source}
        {muniblok}*/
    group by bh.gp_id, bh.ward_id	    
), atr_submitted as (
    SELECT count(1) as atr_sent_cn, bh.gp_id, bh.ward_id
        FROM atr_latest_13_bh_mat bh
        inner join forwarded_latest_5_bh_mat bm ON bm.grievance_id = bh.grievance_id 
        where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) /*{date_range} {data_source}
        {muniblok}*/
    group by bh.gp_id, bh.ward_id    
), close_count as (
    select bh.gp_id, bh.ward_id,
            count(1) as _close_, 
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat bh
        inner join forwarded_latest_5_bh_mat bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15 and bh.assigned_to_office_id in (35) /*{date_range} {data_source}
        {muniblok}*/
    group by bh.gp_id, bh.ward_id  
), pending_count as (
    select count(1) as pndddd, bh.gp_id, bh.ward_id
        from forwarded_latest_5_bh_mat bh
        left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
        where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
        and bh.assigned_to_office_id in (35) /*{date_range} {data_source}
        {muniblok}*/
    group by bh.gp_id, bh.ward_id
) select 
    row_number() over() as sl_no,
--    '{refresh_time}'::timestamp as refresh_time_utc,
--    '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
    case 
        when cmo_wards_master.ward_name is not null then concat(cmo_wards_master.ward_name, ' (W)')
        when cmo_gram_panchayat_master.gp_name is not null then concat(cmo_gram_panchayat_master.gp_name, ' (G)')
    end as unit_name,   
    coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
    coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted, 
    coalesce(close_count.bnft_prvd, 0) as benefit_provided, 
    coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
    coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90, 
    coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
    coalesce(close_count.not_elgbl, 0) as non_actionable, 
    coalesce(close_count._close_, 0) as total_disposed, 
    coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved  
left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id or grievances_recieved.gp_id = atr_submitted.gp_id
left join pending_count on grievances_recieved.ward_id = pending_count.ward_id or grievances_recieved.gp_id = pending_count.gp_id  
left join close_count on grievances_recieved.ward_id = close_count.ward_id or grievances_recieved.gp_id = close_count.gp_id;

-- 8> " ====================== All Gram Panchayats and Wards Filtter as per Blocks and Municipalities Both ====================== "        
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id, bh.ward_id
            FROM forwarded_latest_5_bh_mat bh
            where (bh.gp_id is not null or bh.ward_id is not null) and bh.assigned_to_office_id in (35) /*{date_range} {data_source}
            {gpblk}*/
	group by bh.gp_id, bh.ward_id	
    ), atr_submitted as (
        SELECT count(1) as atr_sent_cn, bh.gp_id, bh.ward_id
            FROM atr_latest_13_bh_mat bh
            inner join forwarded_latest_5_bh_mat bm ON bm.grievance_id = bh.grievance_id 
            where bh.current_status in (14,15) and bh.assigned_by_office_id in (35) /*{date_range} {data_source}
            {gpblk}*/
        group by bh.gp_id, bh.ward_id   
    ), close_count as (
        select bh.gp_id, bh.ward_id,
                count(1) as _close_, 
                sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
                sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
                sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
                sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
            from grievance_master_bh_mat bh
            inner join forwarded_latest_5_bh_mat bm on bm.grievance_id = bh.grievance_id
            where bh.status = 15 and bh.assigned_to_office_id in (35)) /*{date_range_p} {data_source}
            {gpblk}*/
        group by bh.gp_id, bh.ward_id     
    ), pending_count as (
        select count(1) as pndddd , bh.gp_id, bh.ward_id
            from forwarded_latest_5_bh_mat bh
            left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
            where not exists (select 1 from atr_latest_13_bh_mat bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
            and bh.assigned_to_office_id in (35) /*{date_range} {data_source}
            {gpblk}*/
        group by bh.gp_id, bh.ward_id    
    ) select 
        row_number() over() as sl_no,
--        '{refresh_time}'::timestamp as refresh_time_utc,
--        '{refresh_time}'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
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
  
   
   
   select * from cmo_sub_divisions_master csdm where csdm.district_id = 10;
   select * from cmo_municipality_master cmm where cmm.sub_division_id = 91;
  select * from cmo_wards_master cwm where cwm.municipality_id = 124;
 select * from cmo_blocks_master cbm where cbm.sub_division_id = 91;
select * from cmo_gram_panchayat_master cgpm where cgpm.block_id = 331;
   block = 331 gp = 3229
   munici = 124 ward = 2731
   
   
----------------------------- Status of Category wise Pending Grievances at Sub Offices / Other HoDs MIS - 4 For Other HOD -----------------------
----------------------- reference ------------------
with received_count as (
		select bh.grievance_category, bh.assigned_by_office_id, count(1) as received 	
		from forwarded_latest_5_bh_mat bh  
	     where bh.grievance_category > 0 and bh.assigned_to_office_id in (3)
	     /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
		group by bh.grievance_category, bh.assigned_by_office_id
), atr_submitted as (
    	select bh.grievance_category, bh.assigned_to_office_id, count(1) as atr_submitted 
    	from atr_latest_13_bh_mat bh 
	    where bh.assigned_by_office_id in (3)
	   /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
	    group by bh.grievance_category, bh.assigned_to_office_id
), pending_count as (
    	select bh.grievance_category, bh.assigned_by_office_id, count(1) as pending
    from forwarded_latest_5_bh_mat bh
    left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
    where not exists (select 1 from atr_latest_13_bh_mat
           where atr_latest_13_bh_mat.grievance_id = bh.grievance_id and atr_latest_13_bh_mat.current_status in (14,15))
     and bh.assigned_to_office_id in (3)
    group by bh.assigned_by_office_id, bh.grievance_category
) select 
	row_number() over() as sl_no,
	cgcm.grievance_category_desc, 
	coalesce(com.office_name,'N/A') as office_name,
    cgcm.parent_office_id, 
    com.office_id,
	    coalesce(rc.received, 0) AS grievances_received,
	    coalesce(ats.atr_submitted, 0) AS atr_submitted,
	    coalesce(pc.pending, 0) AS pending_to_other_hod
	from received_count rc
	left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = rc.grievance_category
	left join atr_submitted ats on ats.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = ats.grievance_category
	left join pending_count pc on pc.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
	    

------------------- Updated ----------------
with forwarded_count as (
	select bh.grievance_category, bh.assigned_to_office_id, count(1) as forwarded 	
	from forwarded_latest_5_bh_mat bh  
     where bh.assigned_by_office_id in (3)
	group by bh.grievance_category, bh.assigned_to_office_id
), atr_received as (
	select bh.grievance_category, bh.assigned_by_office_id, count(1) as atr_received 
	from atr_latest_13_bh_mat bh 
    where bh.assigned_to_office_id in (3)
   /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
    group by bh.grievance_category, bh.assigned_by_office_id
), pending_count as (
    	select bh.grievance_category, bh.assigned_to_office_id, count(1) as pending,
    	sum(case when ba.days_diff >= 7 then 1 else 0 end) as beyond_7_d
    from forwarded_latest_5_bh_mat bh
    left join pending_for_other_hod_wise_mat_ as ba on bh.grievance_id = ba.grievance_id
    where not exists (select 1 from atr_latest_13_bh_mat 
    		where atr_latest_13_bh_mat.grievance_id = bh.grievance_id and atr_latest_13_bh_mat.current_status in (14,15))
     and bh.assigned_by_office_id in (3)
    group by bh.assigned_to_office_id, bh.grievance_category 
 ) select 
	row_number() over() as sl_no,
	coalesce(com.office_name,'N/A') as office_name,
	cgcm.grievance_category_desc,
	com.office_id,
    cgcm.parent_office_id,
	    coalesce(fc.forwarded, 0) AS grievances_forwarded,
	    coalesce(atr.atr_received, 0) AS atr_received,
	    coalesce(pc.pending, 0) AS pending_to_other_hod,
	    coalesce(pc.beyond_7_d, 0) AS pending_beyond_7_days
    from forwarded_count fc
	left join cmo_office_master com on com.office_id = fc.assigned_to_office_id    
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fc.grievance_category
	left join atr_received atr on atr.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = atr.grievance_category
	left join pending_count pc on pc.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
	where com.office_id = 15 or cgcm.grievance_cat_id = 18
	order by com.office_name, cgcm.grievance_category_desc;
	





with forwarded_count as (
    select bh.grievance_category, bh.assigned_to_office_id, count(1) as forwarded 	
    from forwarded_latest_5_bh_mat_2 as bh  
    where 1 = 1  and bh.assigned_by_office_id in (35)    
    group by bh.grievance_category, bh.assigned_to_office_id
), atr_received as (
    select bh.grievance_category, bh.assigned_by_office_id, count(1) as atr_received 
    from atr_latest_13_bh_mat_2 as bh 
    where 1 = 1  and bh.assigned_to_office_id in (35)   
    group by bh.grievance_category, bh.assigned_by_office_id
), pending_count as (
        select bh.grievance_category, bh.assigned_to_office_id, count(1) as pending,
        sum(case when ba.days_diff >= 7 then 1 else 0 end) as beyond_7_d
    from forwarded_latest_5_bh_mat_2 as bh
    left join pending_for_other_hod_wise_mat_2 as ba on bh.grievance_id = ba.grievance_id
    where not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
     and bh.assigned_by_office_id in (35)   
    group by bh.assigned_to_office_id, bh.grievance_category 
) select 
    row_number() over() as sl_no,
    '2025-02-04 12:30:02.038000+00:00':: timestamp as refresh_time_utc,
    '2025-02-04 12:30:02.038000+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
    coalesce(com.office_name,'N/A') as office_name,
    cgcm.grievance_category_desc,
    com.office_id,
    cgcm.parent_office_id,
        coalesce(fc.forwarded, 0) AS grv_forwarded,
        coalesce(atr.atr_received, 0) AS atr_received,
        coalesce(pc.beyond_7_d, 0) AS atr_pending_beyond_7d,
        coalesce(pc.pending, 0) AS atr_pending
    from forwarded_count fc
    left join cmo_office_master com on com.office_id = fc.assigned_to_office_id    
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fc.grievance_category
    left join atr_received atr on atr.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = atr.grievance_category
    left join pending_count pc on pc.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
    where 1 = 1
        order by com.office_name, cgcm.grievance_category_desc;
------------------------------------------------------------------------------------------------------------------------------------------------------------	

    
  ------ MIS 2 
with
    fwd_count as (
        select 
            forwarded_latest_7_bh_mat.assigned_to_position,
            forwarded_latest_7_bh_mat.grievance_category,
            count(1) as fwd
        from forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat
        /* ===== FILTER ===== */
        where 1 = 1
            and forwarded_latest_7_bh_mat.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP::date
            and forwarded_latest_7_bh_mat.assigned_to_office_id = 53
            and forwarded_latest_7_bh_mat.assigned_to_position in (991,865,12314,674,675,676,677,678,679,680,681,719,721,722,723,724,725,726,727,728,729,730,732,733,734,735,736,737,738,816,823,825,827,828,829,831,832,833,834,842,843,848,850,866,867,868,869,870,871,936,973,974,975,976,977,978,980,981,982,985,988,989,994,996,997,999,1003,1006,1243,3124,3198,3861,3881,3941,4249,8556,9855,10271,10570,11139,13216,4269,13217,3123)
        /* ===== GROUPING ===== */
        group by forwarded_latest_7_bh_mat.assigned_to_position,forwarded_latest_7_bh_mat.grievance_category
    ),
    atr_count as (
        select
            atr_latest_11_bh_mat.assigned_by_position,
            atr_latest_11_bh_mat.grievance_category,
            count(1) as atr
        from atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat
        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = atr_latest_11_bh_mat.grievance_id
        
        /* ===== FILTER ===== */
        where 1 = 1
            and forwarded_latest_7_bh_mat.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP::date
            and atr_latest_11_bh_mat.assigned_by_position in (991,865,12314,674,675,676,677,678,679,680,681,719,721,722,723,724,725,726,727,728,729,730,732,733,734,735,736,737,738,816,823,825,827,828,829,831,832,833,834,842,843,848,850,866,867,868,869,870,871,936,973,974,975,976,977,978,980,981,982,985,988,989,994,996,997,999,1003,1006,1243,3124,3198,3861,3881,3941,4249,8556,9855,10271,10570,11139,13216,4269,13217,3123)
        
        /* ===== GROUPING ===== */
        group by atr_latest_11_bh_mat.assigned_by_position,atr_latest_11_bh_mat.grievance_category
    ),
    pending_count as (
        select 
            forwarded_latest_7_bh_mat.assigned_to_position,
            forwarded_latest_7_bh_mat.grievance_category,
            count(1) as pndddd,
            sum(case when pending_for_hoso_wise_mat.days_diff >= 7 then 1 else 0 end) as beyond_7_d
        from forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat
        inner join pending_for_hoso_wise_mat_2 as pending_for_hoso_wise_mat on forwarded_latest_7_bh_mat.grievance_id = pending_for_hoso_wise_mat.grievance_id
        
        /* ===== FILTER ===== */
        where 1 = 1
            and not exists (select 1 from atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat where atr_latest_11_bh_mat.grievance_id = forwarded_latest_7_bh_mat.grievance_id)
            and forwarded_latest_7_bh_mat.assigned_to_position in (991,865,12314,674,675,676,677,678,679,680,681,719,721,722,723,724,725,726,727,728,729,730,732,733,734,735,736,737,738,816,823,825,827,828,829,831,832,833,834,842,843,848,850,866,867,868,869,870,871,936,973,974,975,976,977,978,980,981,982,985,988,989,994,996,997,999,1003,1006,1243,3124,3198,3861,3881,3941,4249,8556,9855,10271,10570,11139,13216,4269,13217,3123)
            and forwarded_latest_7_bh_mat.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP::date
        /* ===== GROUPING ===== */
        group by forwarded_latest_7_bh_mat.assigned_to_position,forwarded_latest_7_bh_mat.grievance_category
    ),
    processing_unit as (
        select
            '2025-02-04 02:30:01.750000+00:00'::timestamp as refresh_time_utc,
            '2025-02-04 02:30:01.750000+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
            cmo_sub_office_master.suboffice_name as office_name,
            cmo_grievance_category_master.grievance_cat_id as grievance_category,
            cmo_grievance_category_master.grievance_category_desc,
            coalesce(fwd_count.fwd, 0) as grv_forwarded,
            coalesce(atr_count.atr, 0) as atr_received,
            coalesce(pending_count.pndddd, 0) as atr_pending,
            coalesce(pending_count.beyond_7_d, 0) as atr_pending_beyond_7d
        from fwd_count
        left join atr_count on fwd_count.grievance_category = atr_count.grievance_category and atr_count.assigned_by_position = fwd_count.assigned_to_position
        left join pending_count on pending_count.grievance_category = fwd_count.grievance_category and pending_count.assigned_to_position = fwd_count.assigned_to_position
        left join cmo_grievance_category_master on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category
        left join admin_position_master on admin_position_master.position_id = fwd_count.assigned_to_position
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
          /* ===== FILTER ===== */
        where 1 = 1
          /* ===== ORDER ===== */
        order by cmo_sub_office_master.suboffice_name,cmo_grievance_category_master.grievance_category_desc
    )
select
    row_number() over() as sl_no,
    processing_unit.*
from processing_unit;


) select 
	row_number() over() as sl_no,
	cgcm.grievance_category_desc, 
	coalesce(com.office_name,'N/A') as office_name,
    cgcm.parent_office_id, 
    com.office_id,
	    coalesce(fc.forwarded, 0) AS grievances_forwarded,
	    coalesce(atr.atr_received, 0) AS atr_received,
	    coalesce(pc.pending, 0) AS pending_to_other_hod
from cmo_grievance_category_master cgcm
left join cmo_office_master com on com.office_id = cgcm.parent_office_id
left join forwarded_count fc on cgcm.grievance_cat_id = fc.grievance_category
left join atr_received atr on cgcm.grievance_cat_id = atr.grievance_category
left join pending_count pc on cgcm.grievance_cat_id = pc.grievance_category
where cgcm.grievance_cat_id  > 0;    
    
    
   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------- Cat Wise Count -----------------
with uploaded_count as (
    select grievance_master.grievance_category, count(1) as _uploaded_ 	from grievance_master_bh_mat_2 as grievance_master 
     where grievance_master.grievance_category > 0
	group by grievance_master.grievance_category
), direct_close as (
    select direct_close_bh_mat.grievance_category, count(1) as _drct_cls_cnt_ from direct_close_bh_mat
        where direct_close_bh_mat.grievance_category > 0
	group by direct_close_bh_mat.grievance_category
), fwd_count as (
    select forwarded_latest_3_bh_mat.grievance_category, count(1) as _fwd_ from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
        where forwarded_latest_3_bh_mat.grievance_category > 0 
   group by forwarded_latest_3_bh_mat.grievance_category 
), atr_count as (
    select atr_latest_14_bh_mat.grievance_category, count(1) as _atr_ /*, 
        sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
--        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_*/
from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat 
inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = atr_latest_14_bh_mat.grievance_id
    where atr_latest_14_bh_mat.grievance_category > 0 and atr_latest_14_bh_mat.current_status in (14,15)
    group by atr_latest_14_bh_mat.grievance_category
), pending_count as (
    select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ ,
        sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
        sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
        sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
    inner join pending_for_hod_wise_mat_2 as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
        where not exists (select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
	group by forwarded_latest_3_bh_mat.grievance_category
), close_count as (
    select gm.grievance_category, count(1) as _clse_,
        sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_
    from  grievance_master_bh_mat_2 as gm
    inner join  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        where gm.status = 15 
 		group by gm.grievance_category
)
select
    row_number() over() as sl_no, '2025-01-16 07:06:18.413198+00:00'::timestamp as refresh_time_utc, '2025-01-16 07:06:18.413198+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, cmo_grievance_category_master.grievance_cat_id, 
	cmo_grievance_category_master.grievance_category_desc, 
	coalesce(cmo_office_master.office_name,'N/A') as office_name,
    cmo_grievance_category_master.parent_office_id, 
    cmo_office_master.office_id, 
    coalesce(uploaded_count._uploaded_, 0) as griev_upload, 
    coalesce(fwd_count._fwd_, 0) as grv_fwd, 
    coalesce(atr_count._atr_, 0) as atr_rcvd, 
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
    COALESCE(ROUND(CASE WHEN (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_) = 0 THEN 0 
                            ELSE (close_count.bnft_prvd::numeric / (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_)) * 100 
                        END,2),0) AS bnft_prcnt,
    coalesce(direct_close._drct_cls_cnt_ ,0) as drct_cls_cnt
from cmo_grievance_category_master
left join cmo_office_master on cmo_office_master.office_id = cmo_grievance_category_master.parent_office_id
left join uploaded_count on cmo_grievance_category_master.grievance_cat_id = uploaded_count.grievance_category
left join fwd_count on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category 
left join atr_count on cmo_grievance_category_master.grievance_cat_id = atr_count.grievance_category
left join pending_count on cmo_grievance_category_master.grievance_cat_id = pending_count.grievance_category
left join close_count on cmo_grievance_category_master.grievance_cat_id = close_count.grievance_category
left join direct_close on cmo_grievance_category_master.grievance_cat_id = direct_close.grievance_category
where cmo_grievance_category_master.grievance_cat_id  > 0

-----------------------------------------------------------------------------------------------------------------------------------------
------------- state wise --------------
with fwd_Count as (
        select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _fwd_ from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        /******* filter *********/ where 1=1   
                                     /*********** SOURCE **************/
        group by forwarded_latest_3_bh_mat.assigned_to_office_id
    ), quality_of_atr as (
        select grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, count(1) as _count_status_wise_
        from grievance_lifecycle
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id
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
        from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        left join quality_of_atr on quality_of_atr.grievance_id = atr_latest_14_bh_mat.grievance_id
        left join pending_for_hod_wise_last_six_months_mat_2 as pending_for_hod_wise_last_six_months_mat on atr_latest_14_bh_mat.grievance_id = pending_for_hod_wise_last_six_months_mat.grievance_id and quality_of_atr.grievance_status = 14
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
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        inner join pending_for_hod_wise_mat_2 as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
        /******* filter *********/ where not exists (select 1 from  atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat 
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
        from  grievance_master_bh_mat_2 as gm
        inner join  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
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
    )select row_number() over() as sl_no, '2025-01-16 07:06:18.413198+00:00'::timestamp as refresh_time_utc, '2025-01-16 07:06:18.413198+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, office_id, office_name,
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


               select * from cmo_office_master com where com.office_id = 35;
select * from grievance_lifecycle gl where grievance_id = 7133 order by assigned_on;  --2024-02-19 08:14:28.310 +0530 (5) --2024-06-27 10:02:14.743 +0530 (13

-----------------------------------------------------------------------------------------------------------------------------------------------------------
with received_count as (
                    select bh.assigned_by_office_id, count(1) as received from forwarded_latest_5_bh_mat_2 bh 
                    where 1 = 1  and bh.assigned_to_office_id in (35)   
                    group by bh.assigned_by_office_id 
                ), atr_submitted as (
                    select bh.assigned_to_office_id, count(1) as atr_submitted from atr_latest_13_bh_mat_2 bh 
                    where 1 = 1  and bh.assigned_by_office_id in (35)   
                    group by bh.assigned_to_office_id
                ), pending_count as (
                    select bh.assigned_by_office_id, count(1) as pending,
                        sum(case when (pm.days_diff < 7) then 1 else 0 end) as within_7_d,
                        sum(case when (pm.days_diff >= 7 and pm.days_diff <= 15) then 1 else 0 end) as within_7_t_15_d,
                        sum(case when (pm.days_diff > 15 and pm.days_diff <= 30) then 1 else 0 end) as within_16_t_30_d,
                        avg(pm.days_diff) as avg_pending
                    from forwarded_latest_5_bh_mat_2 bh
                    left join pending_for_other_hod_wise_mat_2 as pm on bh.grievance_id = pm.grievance_id
                    where not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id)
                     and bh.assigned_to_office_id in (35)   
                    group by bh.assigned_by_office_id
                ), quality_of_atr as (
                        select gl.grievance_id, gl.grievance_status, count(1) as count_status_wise
                            from grievance_lifecycle gl
                            inner join forwarded_latest_5_bh_mat_2 as bm on bm.grievance_id = gl.grievance_id
                            where gl.grievance_status in (6,13) 
                    group by gl.grievance_id, gl.grievance_status	
                ), atr_count as (
                    select bh.assigned_by_office_id, count(distinct bh.grievance_id) as atr, 
                        sum(case when (quality_of_atr.grievance_status = 13 and quality_of_atr.count_status_wise = 1) then 1 else 0 end) as quality_atr, 
                        sum(case when (quality_of_atr.grievance_status = 6) then 1 else 0 end) as rtrn_griev_cnt, 
                        avg(case when (quality_of_atr.grievance_status = 6) then (quality_of_atr.count_status_wise) end) as avg_rtrn_griev_times_cnt, 
                        avg(ba.days_diff) as six_avg_atr_pnd
                    from atr_latest_13_bh_mat_2 bh
                    inner join forwarded_latest_5_bh_mat_2 as bm on bh.grievance_id = bm.grievance_id
                    left join quality_of_atr on quality_of_atr.grievance_id = bh.grievance_id
                    left join pending_for_other_hod_wise_last_six_months_mat_2 as ba on bh.grievance_id = ba.grievance_id and quality_of_atr.grievance_status = 13
                    where bh.current_status in (14,15)  and bh.assigned_to_office_id in (35)   
                    group by bh.assigned_by_office_id 
                ) select 
                    row_number() over() as sl_no,
                    '2025-02-04 12:30:02.038000+00:00'::timestamp as refresh_time_utc, 
                    '2025-02-04 12:30:02.038000+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
                    com.office_id as unit_id, 
                    com.office_name as unit_name,
                    coalesce(rc.assigned_by_office_id, ats.assigned_to_office_id) AS office_id_II,
                    coalesce(rc.received, 0) AS grv_frwd,
                    coalesce(ats.atr_submitted, 0) AS atr_recvd,
                    coalesce(pc.within_7_d, 0) AS grv_pendng_upto_svn_d,
                    coalesce(pc.within_7_t_15_d, 0) AS within_7_t_15_d,
                    coalesce(pc.within_16_t_30_d, 0) AS within_16_t_30_d,
                    case
                        when coalesce(pc.pending <= 0) then 0 else (coalesce(pc.pending, 0) - coalesce(pc.within_7_d, 0))
                    end as beyond_7_d, 
                    case
                        when coalesce(pc.pending <= 0) then 0 
                        else (coalesce(pc.pending, 0) - (coalesce(pc.within_7_d, 0) + coalesce(pc.within_7_t_15_d, 0) + coalesce(pc.within_16_t_30_d, 0)))
                    end as beyond_30_d,
                    coalesce(pc.pending, 0) AS pending_with_hod,
                    coalesce(round(pc.avg_pending, 2), 2) AS avg_pending,
                    coalesce(round(
                        case 
                            when coalesce(pc.pending, 0) > 0 
                            then (coalesce(pc.pending, 0) - coalesce(pc.within_7_d, 0))::NUMERIC / coalesce(pc.pending, 1) * 100 
                            ELSE 0 
                        END, 2 ), 0 ) AS percent_bynd_svn_days,
                    coalesce(ROUND((case when (ac.quality_atr!= 0) then (ac.quality_atr::numeric/ac.atr) end)*100, 2), 2) as qual_atr_recv,
                    coalesce(ac.atr, 0) AS atr_count,
                    coalesce(ac.rtrn_griev_cnt, 0) AS rtrn_griev_cnt,
                    coalesce(ac.avg_rtrn_griev_times_cnt, 0) AS avg_rtrn_griev_times_cnt,
                    coalesce(ac.quality_atr, 0) AS qual_atr_recived,
                    coalesce(round(ac.six_avg_atr_pnd, 2), 2) AS num_dys_submit_atr,
                    coalesce(round(pc.avg_pending, 2), 2) as avg_no_days_to_submit_atr,
                    coalesce(round(ac.six_avg_atr_pnd, 2), 2) as avg_no_days_to_submit_atr_six
                from received_count rc
                left join atr_submitted ats on rc.assigned_by_office_id = ats.assigned_to_office_id
                left join pending_count pc on pc.assigned_by_office_id = rc.assigned_by_office_id
                left join atr_count ac on rc.assigned_by_office_id = ac.assigned_by_office_id
                left join cmo_office_master com on com.office_id  = rc.assigned_by_office_id;




