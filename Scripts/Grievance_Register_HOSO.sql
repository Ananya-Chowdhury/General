
select * from cmo_office_master com where com.office_name = 'State Railway Police, Sealdah'; --11
 --11

---- execl debug ----
select gm.grievance_id, gm.grievance_no
    from  grievance_master_bh_mat as gm
    inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
where gm.status = 15 and gm.atr_submit_by_lastest_office_id = 123
	  and not exists (
	 	select 1
			from atr_latest_14_bh_mat as atr_latest_14_bh_mat
			inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
			where atr_latest_14_bh_mat.current_status in (14,15) and  atr_latest_14_bh_mat.assigned_by_office_id = 123
				  and atr_latest_14_bh_mat.grievance_id = gm.grievance_id);
				  
				 
		
select assigned_by_office_cat, assigned_to_office_cat, assigned_by_office_id , assigned_to_office_id,grievance_status from grievance_lifecycle gl 
where gl.grievance_id = 2638199 order by assigned_on desc;
				 
--==================================================================================================================================================================================================				 
				 
				 
select table_name, key, refreshed_on from mat_view_refresh_scheduler where key in (6,7,8,9,5) and is_refresh_lock is false;			
SELECT * FROM mat_view_refresh_scheduler WHERE key IN (5,6,7,8,9);

				 
				 
				 
select gm.*, cdm.lg_directory_district_code as lgd_dist, cbm.lg_directory_block_code as lgd_block, cmm.lg_directory_block_code as lgd_mun
    from grievance_master gm 
    inner join admin_position_master apm on gm.assigned_to_position = apm.position_id 
    left join cmo_districts_master cdm on cdm.district_id = gm.district_id
    left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
    
    where gm.status = 4 
        and apm.office_id = 53 and apm.sub_office_id is null
--        and gm.grievance_generate_date::date between '{from_date_time}' and '{to_date_time}';
        
        
select count(1) over() as total_length 
        from grievance_master gm 
        inner join admin_position_master apm on gm.assigned_to_position = apm.position_id 
        where gm.status = 4 
              and apm.office_id = 53 and apm.sub_office_id is null
              and gm.grievance_generate_date::date between '2024-11-20' and '2024-11-25';				 
				 
				 
				 
				 
				 
				 
 with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.district_id
        FROM forwarded_latest_3_bh_mat_2 as bh
        where 1 = 1
         and bh.assigned_to_office_id in (35)
        group by bh.district_id
), atr_submitted as (
    SELECT bh.district_id,
        count(distinct bh.grievance_id) as atr_sent_cn
        /*sum(case when bh.current_status = 15 then 1 else 0 end) as _close_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl*/
    FROM atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15)  and bh.assigned_by_office_id in (35)
    group by bh.district_id
), close_count as (
    select  gm.district_id, count(1) as _close_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from  grievance_master_bh_mat_2 as gm
        inner join  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
            where gm.status = 15  and gm.atr_submit_by_lastest_office_id in (35)
    group by gm.district_id
), pending_count as (
    select count(1) as _pndddd_, bh.district_id
    from forwarded_latest_3_bh_mat_2 as bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
     and bh.assigned_to_office_id in (35)
    group by bh.district_id
) select
    row_number() over() as sl_no,
    '2025-01-27 10:30:02.022612+00:00'::timestamp as refresh_time_utc,
    '2025-01-27 10:30:02.022612+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cdm.district_name::text as unit_name,
    cdm.district_id as unit_id,
    coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
    coalesce(ats.atr_sent_cn, 0) as atr_submitted,
    coalesce(close_count._close_, 0) as total_disposed,
    coalesce(close_count.bnft_prvd, 0) as benefit_provided,
    coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
    coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90,
    coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
    coalesce(close_count.not_elgbl, 0) as non_actionable,
    coalesce(pc._pndddd_, 0) as total_pending
    from grievances_recieved gr
    left join cmo_districts_master cdm on gr.district_id = cdm.district_id
    left join atr_submitted ats on gr.district_id = ats.district_id
    left join pending_count pc on gr.district_id = pc.district_id
    left join close_count on gr.district_id = close_count.district_id;

				 
		-- 737381		 
				 
				 

    select  count(1) as _pndddd_
    from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    left join pending_for_hod_wise_mat as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
    /******* filter *********/ where not exists (select 1 from  atr_latest_14_bh_mat as atr_latest_14_bh_mat
                                                    where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                        and atr_latest_14_bh_mat.current_status in (14,15))

                                   /*********** SOURCE **************/
   and forwarded_latest_3_bh_mat.assigned_to_office_id = 35;
  
  
  
  select * from mat_view_refresh_scheduler mvrs ;
				 
				 
				 
				 
				 
   
   
   ----------------------------------------------------------------
   
   
   
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
--         string_agg((case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end)::text, ',') as _avg_rtrn_griev_times_cnt_,
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
--         sum(case when pending_for_hod_wise_mat.days_diff > 7 then 1 else 0 end) as _beyond_7_d_,
    sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_,
--         sum(case when (pending_for_hod_wise_mat.days_diff >= 30)then 1 else 0 end) as _more_30_d_,
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
)select row_number() over() as sl_no, '2025-01-27 10:30:02.022612+00:00'::timestamp as refresh_time_utc, '2025-01-27 10:30:02.022612+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, office_id, office_name,
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

-------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------ Registerd Grievance For HOSO -------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------- 
		
----- REFERENCE ----
WITH lastupdates AS (
    SELECT grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (3)
)
 Select Count(1)  
    from grievance_master md
    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
	left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
	left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
	left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
	left join admin_position_master apm on apm.position_id = md.updated_by_position 
	left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
	left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
	left join cmo_office_master com2 on com2.office_id = apm2.office_id 
	left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
	left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
	left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
	left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
	left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
	left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
  where lu.assigned_to_office_id = 35   
  and lu.grievance_status::integer in (3) 
--  and (lu.assigned_on::date) between '2025-01-03' and '2025-01-05'

  	
---- UPDTED QUERY ----
  	WITH lastupdates AS (
    SELECT grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (7)
)
 Select count(1)
    from grievance_master md
    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
--    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
--    left join cmo_sub_office_master csom on csom.office_id = md.assigned_to_office_id
    left join admin_position_master apm on apm.position_id = md.assigned_to_position 
    left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
    left join cmo_office_master com on com.office_id = apm.office_id and com.office_id = md.assigned_to_office_id
    left join admin_position_master apm2 on apm2.position_id = md.updated_by_position
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
where lu.assigned_to_position = 398   --9953 --394
and lu.grievance_status::integer in (7) 
--and (lu.assigned_on::date) between '2025-01-03' and '2025-01-05'

 

--- optimised query ---
WITH lastupdates AS (
    SELECT DISTINCT ON (grievance_lifecycle.grievance_id) 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position
    FROM grievance_lifecycle
--    WHERE grievance_lifecycle.grievance_status = 7 
--    AND grievance_lifecycle.assigned_to_position = 398
    ORDER BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_on DESC
)
SELECT COUNT(*)
FROM grievance_master md
INNER JOIN lastupdates lu ON lu.grievance_id = md.grievance_id
LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
LEFT JOIN admin_position_master apm ON apm.position_id = md.assigned_to_position
LEFT JOIN cmo_sub_office_master csom ON csom.suboffice_id = apm.sub_office_id
LEFT JOIN cmo_office_master com ON com.office_id = apm.office_id
LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_type = 'grievance_status' AND cdlm.domain_code = md.status
LEFT JOIN admin_user_details ad ON ad.admin_user_id = md.assigned_to_id
LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm.designation_id
LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id
LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id
LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id;

  	
  	
select * from grievance_master gm where gm.grievance_id = 70115;
select * from grievance_lifecycle gl where gl.grievance_id = 17032;
select * from grievance_master gm where gm.status = 7;
select * from grievance_lifecycle gl where gl.assigned_to_position = 9953 and gl.grievance_status = 7;
select * from grievance_master gm where gm.grievance_id = 526377;
select * from cmo_sub_office_master csom ;
select * from admin_position_master apm where apm.user_type = 3;
select * from cmo_office_master com where com.office_id = 68;
select * from admin_user_role_master aurm ;
select * from admin_user au ;



--- reference --- 
WITH lastupdates AS (
    SELECT grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id 
        ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (3)
)
    select distinct
    md.grievance_id, 
        case 
            when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
            when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
            else null
        end as received_from_other_hod_flag,
        lu.grievance_status as last_grievance_status,
        lu.assigned_on as last_assigned_on,
        lu.assigned_to_office_id as last_assigned_to_office_id,
        lu.assigned_by_office_id as last_assigned_by_office_id,
        lu.assigned_by_position as last_assigned_by_position,
        lu.assigned_to_position as last_assigned_to_position,
        md.grievance_no ,
        md.grievance_description,
        md.grievance_source ,
        null as grievance_source_name,
        md.applicant_name ,
        md.pri_cont_no,
        md.grievance_generate_date ,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        cdm2.district_name ,
        md.block_id ,
        cbm.block_name ,
        md.municipality_id ,
        cmm.municipality_name,
        case 
            when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
        when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
        else null
    end as block_or_municipalty_name,
    md.gp_id,
    cgpm.gp_name,
    md.ward_id,
    cwm.ward_name,
    case 
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
        ELSE NULL
    end as gp_or_ward_name,
    md.atn_id,
    coalesce(catnm.atn_desc,'N/A') as atn_desc,
    coalesce(md.action_taken_note,'N/A') as action_taken_note,
    coalesce(md.current_atr_date,null) as current_atr_date,
    md.assigned_to_position,
    case 
        when md.assigned_to_office_id is null then 'N/A'
        when md.assigned_to_office_id = 5 then 'Pending At CMO'
        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
    end as assigned_to_office_name,
    md.assigned_to_id,
--   case 
--      when md.assigned_to_position is null then 'N/A'
--      else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
--   end as assigned_to_name,
    case
        when md.status = 1 then md.grievance_generate_date
        else md.updated_on -- + interval '5 hour 30 Minutes' 
    end as updated_on,
    md.status,
    cdlm.domain_value as status_name,
    cdlm.domain_abbr as grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name  
from grievance_master md
inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
left join cmo_office_master com on com.office_id = md.assigned_to_office_id
left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
left join admin_position_master apm on apm.position_id = md.updated_by_position 
left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
left join cmo_office_master com2 on com2.office_id = apm2.office_id 
left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
   where lu.assigned_to_office_id = 35   
   and lu.grievance_status::integer in (3) 
  and (lu.assigned_on::date) between '2025-01-03' and '2025-01-03' 
--  order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10 
  
   
   

---- updated query ----
WITH lastupdates AS (
    SELECT grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_office_id,  --new
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (7)
)
  select distinct
    md.grievance_id, 
    lu.grievance_status as last_grievance_status,
    lu.assigned_on as last_assigned_on,
    lu.assigned_to_office_id as last_assigned_to_office_id,
    lu.assigned_by_office_id as last_assigned_by_office_id,
    lu.assigned_by_position as last_assigned_by_position,
    lu.assigned_to_position as last_assigned_to_position,
    md.grievance_no ,
    md.grievance_description,
    md.grievance_source ,
    null as grievance_source_name,
    md.applicant_name ,
    md.pri_cont_no,
    md.grievance_generate_date ,
    md.grievance_category,
    cgcm.grievance_category_desc,
    md.assigned_to_office_id,
    com.office_name,
    csom.suboffice_name,
    md.district_id,
    cdm2.district_name ,
    md.block_id ,
    cbm.block_name ,
    md.municipality_id ,
    cmm.municipality_name,
        case 
            when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
        when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
        else null
    end as block_or_municipalty_name,
    md.gp_id,
    cgpm.gp_name,
    md.ward_id,
    cwm.ward_name,
    case 
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
        ELSE NULL
    end as gp_or_ward_name,
    md.atn_id,
    coalesce(catnm.atn_desc,'N/A') as atn_desc,
    coalesce(md.action_taken_note,'N/A') as action_taken_note,
    coalesce(md.current_atr_date,null) as current_atr_date,
    md.assigned_to_position,
    md.assigned_to_id,
    case
    	when apm.user_type is null then 'N/A'
    	when apm.user_type = 1 then 'Pending At CMO'
    	when apm.user_type = 2 then 'Pending At HOD'
    	else concat(ad.official_name, ' [', cdm.designation_name, ' (', com.office_name, ') - ', aurm.role_master_name, '] ' )
    end as assigned_to_office_name,
    case
        when md.status = 1 then md.grievance_generate_date
        else md.updated_on -- + interval '5 hour 30 Minutes' 
    end as updated_on,
    md.status,
    cdlm.domain_value as status_name,
    cdlm.domain_abbr as grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name  
from grievance_master md
    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
--    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
--    left join cmo_sub_office_master csom on csom.office_id = md.assigned_to_office_id
    left join admin_position_master apm on apm.position_id = md.assigned_to_position 
    left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
    left join cmo_office_master com on com.office_id = apm.office_id and com.office_id = md.assigned_to_office_id
    left join admin_position_master apm2 on apm2.position_id = md.updated_by_position
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
   where lu.assigned_to_position = 398
   and lu.grievance_status::integer in (7);
--   and (lu.assigned_on::date) between '2025-01-03' and '2025-01-05'
--   order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10 


-------- testing ------
 WITH lastupdates AS (
    SELECT grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (7)
)
select distinct
    md.grievance_id, 
    lu.grievance_status as last_grievance_status,
    lu.assigned_on as last_assigned_on,
        lu.assigned_to_office_id as last_assigned_to_office_id,
        lu.assigned_by_office_id as last_assigned_by_office_id,
        lu.assigned_by_position as last_assigned_by_position,
        lu.assigned_to_position as last_assigned_to_position,
        md.grievance_no ,
        md.grievance_description,
        md.grievance_source ,
        null as grievance_source_name,
        md.applicant_name ,
        md.pri_cont_no,
        md.grievance_generate_date ,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        csom.suboffice_name,
        md.district_id,
        cdm2.district_name ,
        md.block_id ,
        cbm.block_name ,
        md.municipality_id ,
        cmm.municipality_name,
        case 
            when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
        when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
        else null
    end as block_or_municipalty_name,
    md.gp_id,
    cgpm.gp_name,
    md.ward_id,
    cwm.ward_name,
    case 
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
        ELSE NULL
    end as gp_or_ward_name,
    md.atn_id,
    coalesce(catnm.atn_desc,'N/A') as atn_desc,
    coalesce(md.action_taken_note,'N/A') as action_taken_note,
    coalesce(md.current_atr_date,null) as current_atr_date,
    md.assigned_to_position,
    md.assigned_to_id,
    case
        when apm.user_type is null then 'N/A'
        when apm.user_type = 1 then 'Pending At CMO'
        when apm.user_type = 2 then 'Pending At HOD'
        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com.office_name, ') - ', aurm.role_master_name, '] ' )
    end as assigned_to_office_name,
    case
        when md.status = 1 then md.grievance_generate_date
        else md.updated_on -- + interval '5 hour 30 Minutes' 
    end as updated_on,
    md.status,
    cdlm.domain_value as status_name,
    cdlm.domain_abbr as grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name  
from grievance_master md
    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
--    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
--    left join cmo_sub_office_master csom on csom.office_id = md.assigned_to_office_id
    left join admin_position_master apm on apm.position_id = md.assigned_to_position 
    left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
    left join cmo_office_master com on com.office_id = apm.office_id and com.office_id = md.assigned_to_office_id
    left join admin_position_master apm2 on apm2.position_id = md.updated_by_position
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
        left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
        left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
        left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
        left join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
        left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
        left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
        left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
        left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
        left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
        left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
  where lu.assigned_to_position = 677   
  and lu.grievance_status::integer in (7) 
--  order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10 

              
    ------------------------------------------- grievance register for hod checking -----------------------------------------
              
          WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3)
                )
                 Select Count(1)  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
          where lu.assigned_to_office_id = 35   
--          and lu.grievance_status::integer in (3)    
              
          
          
          
          -----------------------------------------------------------------------
            WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3)
                )
                 Select Count(1)  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
          where lu.assigned_to_office_id = 35   and (md.assigned_on::date) between '2025-01-02' and '2025-03-05'
--          AND lu.assigned_on >= '2025-01-02' AND lu.assigned_on < '2025-03-06'/

              
 WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3)
                )
                 Select Count(1)  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id 
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
          where lu.assigned_to_office_id = 35   and (lu.assigned_on::date) between '2025-01-02' and '2025-03-05'
          
              750518
          
          WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3) and  grievance_lifecycle.assigned_to_office_id = 35
                )
                 Select Count(1)  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id 
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
          where (lu.assigned_on::date) between '2025-01-02' and '2025-03-05';
          
         -------------------------------------------------------FIIINALLLL---------------------------------------
WITH lastupdates AS (
    SELECT gl.grievance_id,
                gl.grievance_status,
                gl.assigned_on,
                gl.assigned_to_office_id,
                gl.assigned_by_position,
                gl.assigned_to_position,
                row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
            FROM grievance_lifecycle gl 
            WHERE gl.grievance_status in (3) 
            and gl.assigned_to_office_id = 35
            AND gl.assigned_on::DATE BETWEEN '2025-01-02' AND '2025-03-05'
    )
        Select Count(1)  
        from grievance_master md
        inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id 
        left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
        left join cmo_office_master com on com.office_id = md.assigned_to_office_id
        left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
        left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
        left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
        left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
        left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
        left join cmo_office_master com2 on com2.office_id = apm2.office_id 
        left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
        left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
        left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
        left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
        left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
        left join cmo_wards_master cwm on cwm.ward_id = md.ward_id;

         
         
         ----------------------------------------------------------------------------------------------------------------
          
      WITH lastupdates AS (
                        SELECT grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_office_id,
                            grievance_lifecycle.assigned_by_position,
                            grievance_lifecycle.assigned_to_position,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id 
                            ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM grievance_lifecycle
                        WHERE grievance_lifecycle.grievance_status in (3) and grievance_lifecycle.assigned_to_office_id = 35
                    )
                        select distinct
                        md.grievance_id, 
                            case 
                                when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                                when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                                else null
                            end as received_from_other_hod_flag,
                            lu.grievance_status as last_grievance_status,
                            lu.assigned_on as last_assigned_on,
                            lu.assigned_to_office_id as last_assigned_to_office_id,
                            lu.assigned_by_office_id as last_assigned_by_office_id,
                            lu.assigned_by_position as last_assigned_by_position,
                            lu.assigned_to_position as last_assigned_to_position,
                            md.grievance_no ,
                            md.grievance_description,
                            md.grievance_source ,
                            null as grievance_source_name,
                            md.applicant_name ,
                            md.pri_cont_no,
                            md.grievance_generate_date ,
                            md.grievance_category,
                            cgcm.grievance_category_desc,
                            md.assigned_to_office_id,
                            com.office_name,
                            md.district_id,
                            cdm2.district_name ,
                            md.block_id ,
                            cbm.block_name ,
                            md.municipality_id ,
                            cmm.municipality_name,
                            case 
                                when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
                            when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
                            else null
                        end as block_or_municipalty_name,
                        md.gp_id,
                        cgpm.gp_name,
                        md.ward_id,
                        cwm.ward_name,
                        case 
                            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
                            ELSE NULL
                        end as gp_or_ward_name,
                        md.atn_id,
                        coalesce(catnm.atn_desc,'N/A') as atn_desc,
                        coalesce(md.action_taken_note,'N/A') as action_taken_note,
                        coalesce(md.current_atr_date,null) as current_atr_date,
                        md.assigned_to_position,
                        case 
                            when md.assigned_to_office_id is null then 'N/A'
                            when md.assigned_to_office_id = 5 then 'Pending At CMO'
                            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                        end as assigned_to_office_name,
                        md.assigned_to_id,
    --                    case 
    --                        when md.assigned_to_position is null then 'N/A'
    --                        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
    --                    end as assigned_to_name,
                        case
                            when md.status = 1 then md.grievance_generate_date
                            else md.updated_on -- + interval '5 hour 30 Minutes' 
                        end as updated_on,
                        md.status,
                        cdlm.domain_value as status_name,
                        cdlm.domain_abbr as grievance_status_code,
                        md.emergency_flag,
                        md.police_station_id,
                        cpsm.ps_name  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
                       where (lu.assigned_on::date) between '2025-01-02' and '2025-03-05' order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10 
          
                    
WITH lastupdates AS (
    SELECT 
        gl.grievance_id,
        gl.grievance_status,
        gl.assigned_on,
        gl.assigned_to_office_id,
        gl.assigned_by_office_id,
        gl.assigned_by_position,
        gl.assigned_to_position,
        ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 3 
      AND gl.assigned_to_office_id = 35 
      AND gl.assigned_on::DATE BETWEEN '2025-01-02' AND '2025-03-05'
)
SELECT 
    md.grievance_id, 
    CASE 
        WHEN (lu.grievance_status = 3 OR glsubq.grievance_status = 14) THEN 0
        WHEN (lu.grievance_status = 5 OR glsubq.grievance_status = 13) THEN 1
        ELSE NULL
    END AS received_from_other_hod_flag,
    lu.grievance_status AS last_grievance_status,
    lu.assigned_on AS last_assigned_on,
    lu.assigned_to_office_id AS last_assigned_to_office_id,
    lu.assigned_by_office_id AS last_assigned_by_office_id,
    lu.assigned_by_position AS last_assigned_by_position,
    lu.assigned_to_position AS last_assigned_to_position,
    md.grievance_no,
    md.grievance_description,
    md.grievance_source,
    NULL AS grievance_source_name,
    md.applicant_name,
    md.pri_cont_no,
    md.grievance_generate_date,
    md.grievance_category,
    cgcm.grievance_category_desc,
    md.assigned_to_office_id,
    com.office_name,
    md.district_id,
    cdm2.district_name,
    md.block_id,
    cbm.block_name,
    md.municipality_id,
    cmm.municipality_name,
    CASE 
        WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
        WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
        ELSE NULL
    END AS block_or_municipalty_name,
    md.gp_id,
    cgpm.gp_name,
    md.ward_id,
    cwm.ward_name,
    CASE 
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
        ELSE NULL
    END AS gp_or_ward_name,
    md.atn_id,
    COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
    COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
    COALESCE(md.current_atr_date, NULL) AS current_atr_date,
    md.assigned_to_position,
    CASE 
        WHEN md.assigned_to_office_id IS NULL THEN 'N/A'
        WHEN md.assigned_to_office_id = 5 THEN 'Pending At CMO'
        ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] ')  
    END AS assigned_to_office_name,
    md.assigned_to_id,
    CASE 
        WHEN md.status = 1 THEN md.grievance_generate_date
        ELSE md.updated_on 
    END AS updated_on,
    md.status,
    cdlm.domain_value AS status_name,
    cdlm.domain_abbr AS grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name  
FROM grievance_master md
INNER JOIN lastupdates lu ON lu.rn = 1 AND lu.grievance_id = md.grievance_id
LEFT JOIN LATERAL (
    SELECT glsubq.grievance_status
    FROM grievance_lifecycle glsubq
    WHERE glsubq.grievance_id = md.grievance_id 
      AND glsubq.grievance_status IN (14, 13)
    ORDER BY glsubq.assigned_on DESC 
    LIMIT 1
) glsubq ON TRUE
LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
LEFT JOIN cmo_office_master com ON com.office_id = md.assigned_to_office_id
LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_type = 'grievance_status' AND cdlm.domain_code = md.status
LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = md.assigned_to_position AND aupm.status = 1
LEFT JOIN admin_user_details ad ON ad.admin_user_id = aupm.admin_user_id
LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position 
LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm2.designation_id
LEFT JOIN cmo_office_master com2 ON com2.office_id = apm2.office_id 
LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm2.role_master_id
LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id 
LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id
ORDER BY updated_on ASC
OFFSET 0 LIMIT 10;
               
                       
------ after my optimization ----
WITH lastupdates AS (
                SELECT 
                    gl.grievance_id,
                    gl.grievance_status,
                    gl.assigned_on,
                    gl.assigned_to_office_id,
                    gl.assigned_by_office_id,
                    gl.assigned_by_position,
                    gl.assigned_to_position,
                    ROW_NUMBER() OVER (PARTITION BY gl.grievance_id 
                    ORDER BY gl.assigned_on DESC) AS rn
                FROM grievance_lifecycle gl
                WHERE gl.grievance_status in (3) 
                AND gl.assigned_to_office_id = 35 
                AND gl.assigned_on::DATE BETWEEN '2025-01-02' AND '2025-03-05'
            )     
        SELECT distinct
            md.grievance_id, 
            CASE 
                -- WHEN (lu.grievance_status = 3 OR glsubq.grievance_status = 14) THEN 0
                -- WHEN (lu.grievance_status = 5 OR glsubq.grievance_status = 13) THEN 1
                when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                ELSE NULL
            END AS received_from_other_hod_flag,
            lu.grievance_status AS last_grievance_status,
            lu.assigned_on AS last_assigned_on,
            lu.assigned_to_office_id AS last_assigned_to_office_id,
            lu.assigned_by_office_id AS last_assigned_by_office_id,
            lu.assigned_by_position AS last_assigned_by_position,
            lu.assigned_to_position AS last_assigned_to_position,
            md.grievance_no,
            md.grievance_description,
            md.grievance_source,
            NULL AS grievance_source_name,
            md.applicant_name,
            md.pri_cont_no,
            md.grievance_generate_date,
            md.grievance_category,
            cgcm.grievance_category_desc,
            md.assigned_to_office_id,
            com.office_name,
            md.district_id,
            cdm2.district_name,
            md.block_id,
            cbm.block_name,
            md.municipality_id,
            cmm.municipality_name,
            CASE 
                WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
                WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
                ELSE NULL
            END AS block_or_municipalty_name,
            md.gp_id,
            cgpm.gp_name,
            md.ward_id,
            cwm.ward_name,
            CASE 
                WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
                ELSE NULL
            END AS gp_or_ward_name,
            md.atn_id,
            COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
            COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
            COALESCE(md.current_atr_date, NULL) AS current_atr_date,
            md.assigned_to_position,
            CASE 
                WHEN md.assigned_to_office_id IS NULL THEN 'N/A'
                WHEN md.assigned_to_office_id = 5 THEN 'Pending At CMO'
                ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] ')  
            END AS assigned_to_office_name,
            md.assigned_to_id,
            CASE 
                WHEN md.status = 1 THEN md.grievance_generate_date
                ELSE md.updated_on -- + interval '5 hour 30 Minutes' 
            END AS updated_on,
            md.status,
            cdlm.domain_value AS status_name,
            cdlm.domain_abbr AS grievance_status_code,
            md.emergency_flag,
            md.police_station_id,
            cpsm.ps_name  
        FROM grievance_master md
        INNER JOIN lastupdates lu ON lu.rn = 1 AND lu.grievance_id = md.grievance_id
        -- LEFT JOIN LATERAL (
        --     SELECT glsubq.grievance_status
        --     FROM grievance_lifecycle glsubq
        --     WHERE glsubq.grievance_id = md.grievance_id 
        --     AND glsubq.grievance_status IN (14, 13)
        --     ORDER BY glsubq.assigned_on DESC 
        --     LIMIT 1
        -- ) glsubq ON TRUE
        LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
        LEFT JOIN cmo_office_master com ON com.office_id = md.assigned_to_office_id
        LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
        LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_type = 'grievance_status' AND cdlm.domain_code = md.status
        LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = md.assigned_to_position AND aupm.status = 1
        LEFT JOIN admin_user_details ad ON ad.admin_user_id = aupm.admin_user_id
        LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
        LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position 
        LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
        LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm2.designation_id
        LEFT JOIN cmo_office_master com2 ON com2.office_id = apm2.office_id 
        LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm2.role_master_id
        LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
        LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id 
        LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
        LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
        LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id
        order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10 ;
        -- ORDER BY updated_on ASC
        -- OFFSET 0 LIMIT 10;                       
       
 ------------------------------------------------------------------------------------------------------------------------------------                     
                            ---753804  ---750625  ---7215
   WITH lastupdates AS (
        SELECT gl.grievance_id,
            gl.grievance_status,
            gl.assigned_on,
            gl.assigned_to_office_id,
            gl.assigned_by_position,
            gl.assigned_to_position,
            row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
        FROM grievance_lifecycle gl
        WHERE gl.grievance_status in (3,5)
         and gl.assigned_to_office_id = 35 
--         and gl.assigned_on::date between '2025-01-02' and '2025-03-05'
    )
        Select Count(1)  
        from grievance_master md
        inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id 
        left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
        left join cmo_office_master com on com.office_id = md.assigned_to_office_id
        left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
        left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
        left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
        left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
        left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
        left join cmo_office_master com2 on com2.office_id = apm2.office_id 
        left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
        left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
        left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
        left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
        left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
        left join cmo_wards_master cwm on cwm.ward_id = md.ward_id                  
                      
       
 -------------------------------------------------------------------------------------------------------------------------------------
                       
select a.pid, a.usename, a.application_name, a.client_addr, a.state, l.mode, l.granted, n.nspname, c.relname, a.query
	from pg_locks l
	join pg_stat_activity a ON a.pid = l.pid
	join pg_class c ON c.oid = l.relation
	join pg_namespace n ON n.oid = c.relnamespace;

              
