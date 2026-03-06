
	select * from admin_position_master apm where office_id = 35 and role_master_id = 4;
select * from admin_user_position_mapping aupm where position_id = 10140;
	select * from admin_user_details aud where admin_user_id = 10140; -- 9297929297


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
    --         string_agg((case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end)::text, ',') as _avg_rtrn_griev_times_cnt_,
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
    --         sum(case when pending_for_hod_wise_mat.days_diff > 7 then 1 else 0 end) as _beyond_7_d_,
        sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
        sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
        sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_,
    --         sum(case when (pending_for_hod_wise_mat.days_diff >= 30)then 1 else 0 end) as _more_30_d_,
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
    )select /*row_number() over() as sl_no, '2025-03-27 16:30:01.145158+00:00'::timestamp as refresh_time_utc, '2025-03-27 16:30:01.145158+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, office_id, */
    		office_name,
--            coalesce(_fwd_, 0) as grv_frwd, coalesce(_atr_, 0) as atr_recvd, coalesce(_close_, 0) as total_disposed,
--            benft_pved,
--            mt_t_up_win_90,
--            mt_t_up_bey_90,
--            pnd_policy_dec,
--            non_actionable,
--            COALESCE(ROUND(CASE WHEN (benft_pved + mt_t_up_win_90 + mt_t_up_bey_90 + pnd_policy_dec + non_actionable) = 0 THEN 0
--                                                ELSE (benft_pved::numeric / (benft_pved + mt_t_up_win_90 + mt_t_up_bey_90 + pnd_policy_dec + non_actionable)) * 100
--                                        END,2),0) AS per_bnft_prvd,
            coalesce(_pnd_, 0) as pending_with_hod 
--            _quality_atr_,  coalesce(_beyond_7_d_, 0) as grv_pendng_more_svn_d,
--            /*coalesce(_within_7_d_, 0) as _within_7_d_,*/ coalesce(_within_7_t_15_d_, 0) as within_7_t_15_d, coalesce(_within_16_t_30_d_, 0) as within_16_t_30_d,
--            coalesce(_beyond_30_d_, 0) as beyond_30_d,
--            coalesce(ROUND(_avg_pending_,2),0) as avg_no_days_to_submit_atr,
--            coalesce((case when _within_7_d_ <= 0 then 0 else _within_7_d_ end), 0) as grv_pendng_upto_svn_d,
--            coalesce(ROUND((case when (_beyond_7_d_!= 0) then (_beyond_7_d_::numeric/_pnd_) end)*100, 2),0) as percent_bynd_svn_days,
--            coalesce(ROUND((case when (_quality_atr_!= 0) then (_quality_atr_::numeric/_atr_) end)*100, 2),0) as qual_atr_recv,
--            coalesce(ROUND(_six_avg_atr_pnd_, 2),0) as avg_no_days_to_submit_atr_six,
--            coalesce(_rtrn_griev_cnt_, 0) as rtrn_griev_cnt,
--            coalesce(ROUND(_avg_rtrn_griev_times_cnt_, 2),0) as avg_rtrn_griev_times_cnt,
--            office_type,
--            case
--                when office_type = 1 then 8
--                when office_type = 2 then 1
--                when office_type = 3 then 2
--                when office_type = 4 then 3
--                when office_type = 5 then 4
--                when office_type = 6 then 5
--                when office_type = 7 then 6
--                when office_type = 8 then 7
--            end as office_ord
    from processing_unit
   order by office_name;

   
   
   
   
   
   
   
   
   
   
   
   Select com3.office_name, Count(1)
	from grievance_master_bh_mat md
	inner join forwarded_latest_3_bh_mat as lu on lu.grievance_id = md.grievance_id
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
	left join cmo_office_master com on com.office_id = md.assigned_to_office_id
	left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
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
	  where md.status not in (14,15)
	 group by com3.office_name
	 order by com3.office_name;
	 
	
	

















select com.office_name ,count(1)
    from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    inner join grievance_master_bh_mat as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    left join cmo_office_master com on com.office_id = forwarded_latest_3_bh_mat.assigned_to_office_id
--    where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            where not exists (
                            select 1 from atr_latest_14_bh_mat as atr_latest_14_bh_mat
                                            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                    and atr_latest_14_bh_mat.current_status in (14,15)
                            )
 group by com.office_name 
order by com.office_name ;









with raw_data as (
    select grievance_master_bh_mat.*
    from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    inner join grievance_master_bh_mat as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            and not exists (
                            select 1 from atr_latest_14_bh_mat as atr_latest_14_bh_mat
                                            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                    and atr_latest_14_bh_mat.current_status in (14,15)
                            )
), unassigned_cmo as (
    select
        'Unassigned (CMO)' as status,
        null as name_and_esignation_of_the_user,
        'N/A' as office,
        null as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from raw_data
    where raw_data.status = 3
), unassigned_other_hod as (
    select
        'Unassigned (Other HoD)' as status,
        null as name_and_esignation_of_the_user,
        'N/A' as office,
        null as user_status,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
), recalled as (
    select
        'Recalled' as status,
        null as name_and_esignation_of_the_user,
        'N/A' as office,
        null as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from raw_data
    where raw_data.status = 16
), user_wise_pndcy as (
    select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_status, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review,
        xx.atr_auto_returned_from_cmo, xx.total_count
    from (
        select 'User wise ATR Pendency' as status,
            admin_user_details.official_name as name_and_esignation_of_the_user,
            cmo_office_master.office_name as office,
            case when admin_position_master.office_id in (35) /*REPLACE*/ then admin_user_role_master.role_master_name
                    else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
            end as "user_status",
            case when admin_position_master.office_id in (35) /*REPLACE*/ then 1 else 2 end as "type",
            sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as "pending_grievances",
            sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
            sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
            case when admin_position_master.office_id in (35) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
                    else null::int
            end as "atr_auto_returned_from_cmo",
            count(1) as total_count
        from raw_data
        left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id
        left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
        left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        where raw_data.status not in (3,16)
        group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name,
                admin_user_role_master.role_master_id, admin_user_role_master.role_master_name
        order by type, admin_user_role_master.role_master_id
    )xx
), union_part as (
    select * from unassigned_cmo
        union all
    select * from unassigned_other_hod
        union all
    select * from recalled
        union all
    select * from user_wise_pndcy
)
select
    row_number() over() as sl_no,
    '2025-03-27 16:30:01.145158+00:00'::timestamp as refresh_time_utc,
    '2025-03-27 16:30:01.145158+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    *
from union_part;
































 with uploaded_count as (
    select grievance_master.grievance_category, count(1) as _uploaded_  from grievance_master_bh_mat as grievance_master
        where grievance_master.grievance_category > 0
            /***** FILTER *****/
    group by grievance_master.grievance_category
), fwd_count as (
    select forwarded_latest_3_bh_mat.grievance_category, cmo_office_master.office_name, count(1) as _fwd_
            from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
            left join cmo_office_master on cmo_office_master.office_id = forwarded_latest_3_bh_mat.assigned_by_office_id
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            /***** FILTER *****/
    group by forwarded_latest_3_bh_mat.grievance_category , cmo_office_master.office_name
), atr_count as (
    select atr_latest_14_bh_mat.grievance_category, count(1) as _atr_
        /*, -- COMMENT OUT --
        sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        */
    from atr_latest_14_bh_mat as atr_latest_14_bh_mat
    inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat  on forwarded_latest_3_bh_mat.grievance_id = atr_latest_14_bh_mat.grievance_id
        where atr_latest_14_bh_mat.assigned_by_office_id in (35) and atr_latest_14_bh_mat.current_status in (14,15)
            /***** FILTER *****/
    group by atr_latest_14_bh_mat.grievance_category
), close_count as (
    select  gm.grievance_category, count(1) as _clse_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from  grievance_master_bh_mat as gm
        inner join  forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
            where gm.status = 15  and gm.atr_submit_by_lastest_office_id in (35)
            /***** FILTER *****/
    group by gm.grievance_category
), pending_count as (
    select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            and not exists (select 1 from atr_latest_14_bh_mat as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                                        and atr_latest_14_bh_mat.current_status in (14,15)
                                                                        /*and atr_latest_14_bh_mat.assigned_by_office_id in (35)*/ )
            /***** FILTER *****/
    group by forwarded_latest_3_bh_mat.grievance_category
)
select
        row_number() over() as sl_no, '2025-03-27 16:30:01.145158+00:00'::timestamp as refresh_time_utc, '2025-03-27 16:30:01.145158+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        cmo_grievance_category_master.grievance_cat_id, cmo_grievance_category_master.grievance_category_desc, fwd_count.office_name,
        coalesce(uploaded_count._uploaded_, 0) as griev_upload, coalesce(fwd_count._fwd_, 0) as grv_fwd, coalesce(atr_count._atr_, 0) as atr_rcvd,
        coalesce(close_count._clse_, 0) as totl_dspsd,  coalesce(close_count.bnft_prvd, 0) as srv_prvd, coalesce(close_count._mt_t_up_win_90_, 0) as mt_t_up_win_90,
        coalesce(close_count._mt_t_up_bey_90_, 0) as mt_t_up_bey_90, coalesce(close_count._pnd_policy_dec_, 0) as pnd_policy_dec,
        coalesce(close_count.not_elgbl, 0) as not_elgbl, coalesce(pending_count._pndddd_, 0) as atr_pndg,
        COALESCE(ROUND(CASE WHEN (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_) = 0 THEN 0
                            ELSE (close_count.bnft_prvd::numeric / (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_)) * 100
                    END,2),0) AS bnft_prcnt
from fwd_count
left join cmo_grievance_category_master on fwd_count.grievance_category = cmo_grievance_category_master.grievance_cat_id
left join uploaded_count on fwd_count.grievance_category = uploaded_count.grievance_category
left join atr_count on fwd_count.grievance_category = atr_count.grievance_category
left join pending_count on fwd_count.grievance_category = pending_count.grievance_category
left join close_count on fwd_count.grievance_category = close_count.grievance_category
/***** FILTER *****/;






select com.office_name, count(1) as _pndddd_ 
from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
left join cmo_office_master com on com.office_id = forwarded_latest_3_bh_mat.assigned_to_office_id
--        where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            where not exists (select 1 from atr_latest_14_bh_mat as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                                        and atr_latest_14_bh_mat.current_status in (14,15) ) 
    group by com.office_name
   order by com.office_name;


select * from cmo_office_master com where office_name = 'Backward Classes Welfare Department'; --4

select  count(1) as _pndddd_ 
from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
left join cmo_office_master com on com.office_id = forwarded_latest_3_bh_mat.assigned_to_office_id
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (4)
            and not exists (select 1 from atr_latest_14_bh_mat as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                                        and atr_latest_14_bh_mat.current_status in (14,15) ) ; -- 5985
                                                                       
                                                                       
                                                                        
select  forwarded_latest_3_bh_mat.grievance_id
from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
left join cmo_office_master com on com.office_id = forwarded_latest_3_bh_mat.assigned_to_office_id
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (4)
            and not exists (select 1 from atr_latest_14_bh_mat as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                                        and atr_latest_14_bh_mat.current_status in (14,15) )
			and not exists (
				   Select 1
					from grievance_master_bh_mat md
					inner join forwarded_latest_3_bh_mat as lu on lu.grievance_id = md.grievance_id
					left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
					left join cmo_office_master com on com.office_id = md.assigned_to_office_id
					left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
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
					  where md.status not in (14,15) and lu.assigned_to_office_id = 4 and md.grievance_id = forwarded_latest_3_bh_mat.grievance_id
			); -- 4661
                                                                       
select assigned_by_office_cat , assigned_to_office_cat , assigned_by_office_id, assigned_to_office_id , grievance_status , assigned_on , *
 from grievance_lifecycle gl where gl.grievance_id = 89644 order by assigned_on ;
 



























 with fwd_Count as (
    select forwarded_latest_3_bh_mat.district_id, count(1) as _fwd_ from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    /******* filter *********/
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
                                /*********** SOURCE **************/
    group by forwarded_latest_3_bh_mat.district_id
), quality_of_atr as (
    select grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, count(1) as _count_status_wise_
    from grievance_lifecycle
    inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id
    where grievance_lifecycle.grievance_status in (6,14)
        /******* filter *********/
                                    /*********** SOURCE **************/
                group by grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status
), atr_count as (
    select atr_latest_14_bh_mat.district_id, count(distinct atr_latest_14_bh_mat.grievance_id) as _atr_ ,
        sum(case when (quality_of_atr.grievance_status = 14 and quality_of_atr._count_status_wise_ = 1) then 1 else 0 end) as _quality_atr_,
        sum(case when (quality_of_atr.grievance_status = 6) then 1 else 0 end) as _rtrn_griev_cnt_,
        avg(case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end) as _avg_rtrn_griev_times_cnt_,
        avg(pending_for_hod_wise_last_six_months_mat.days_diff) as _six_avg_atr_pnd_
    from atr_latest_14_bh_mat as atr_latest_14_bh_mat
    inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    left join quality_of_atr on quality_of_atr.grievance_id = atr_latest_14_bh_mat.grievance_id
    left join pending_for_hod_wise_last_six_months_mat as pending_for_hod_wise_last_six_months_mat on atr_latest_14_bh_mat.grievance_id = pending_for_hod_wise_last_six_months_mat.grievance_id and quality_of_atr.grievance_status = 14
    /******* filter *********/ where atr_latest_14_bh_mat.current_status in (14,15)
                                    and atr_latest_14_bh_mat.assigned_by_office_id in (35)
        /*********** SOURCE **************/
    group by atr_latest_14_bh_mat.district_id
), pending_counts as (
    select forwarded_latest_3_bh_mat.district_id, count(1) as _pndddd_,
    sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_,
    avg(pending_for_hod_wise_mat.days_diff) as _avg_pending_
    from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    inner join pending_for_hod_wise_mat as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
    /******* filter *********/ where not exists (select 1 from  atr_latest_14_bh_mat as atr_latest_14_bh_mat
                                                    where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                        and atr_latest_14_bh_mat.current_status in (14,15))
                                    and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
                                /*********** SOURCE **************/
    group by forwarded_latest_3_bh_mat.district_id
), close_count as (
    select forwarded_latest_3_bh_mat.district_id, count(1) as _close_
    from grievance_master_bh_mat as gm
    inner join forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        where gm.status = 15 and gm.atr_submit_by_lastest_office_id in (35)
        /******* filter *********/
    group by forwarded_latest_3_bh_mat.district_id
), processing_unit as (
    select cmo_districts_master.district_id, cmo_districts_master.district_name, fwd_Count._fwd_, atr_count._atr_,
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
    close_count._close_
    from cmo_districts_master
    left join fwd_Count on cmo_districts_master.district_id = fwd_Count.district_id
    left join atr_count on cmo_districts_master.district_id = atr_count.district_id
    left join pending_counts on cmo_districts_master.district_id = pending_counts.district_id
    left join close_count on cmo_districts_master.district_id = close_count.district_id
    where cmo_districts_master.district_name not in ('Department', 'CMO','Outside West Bengal')
          /******* filter *********/
)select
    row_number() over() as sl_no,
    '2025-03-27 16:30:01.145158+00:00'::timestamp as refresh_time_utc,
    '2025-03-27 16:30:01.145158+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    district_id as unit_id,
    district_name as unit_name,
    coalesce(_fwd_, 0) as grv_frwd,
    coalesce(_atr_, 0) as atr_recvd,
    coalesce(_pnd_, 0) as pending_with_hod,
    _quality_atr_,
    coalesce(_beyond_7_d_, 0) as grv_pendng_more_svn_d,
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
    coalesce(_close_, 0) as total_disposed
from processing_unit;































with fwd_Count as (
    select forwarded_latest_3_bh_mat.district_id, count(1) as _fwd_ from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    /******* filter *********/
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
                                /*********** SOURCE **************/
    group by forwarded_latest_3_bh_mat.district_id
), quality_of_atr as (
    select grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, count(1) as _count_status_wise_
    from grievance_lifecycle
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id
    where grievance_lifecycle.grievance_status in (6,14)
        /******* filter *********/
                                    /*********** SOURCE **************/
                group by grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status
), atr_count as (
    select atr_latest_14_bh_mat.district_id, count(distinct atr_latest_14_bh_mat.grievance_id) as _atr_ ,
        sum(case when (quality_of_atr.grievance_status = 14 and quality_of_atr._count_status_wise_ = 1) then 1 else 0 end) as _quality_atr_,
        sum(case when (quality_of_atr.grievance_status = 6) then 1 else 0 end) as _rtrn_griev_cnt_,
        avg(case when (quality_of_atr.grievance_status = 6) then (quality_of_atr._count_status_wise_) end) as _avg_rtrn_griev_times_cnt_,
        avg(pending_for_hod_wise_last_six_months_mat.days_diff) as _six_avg_atr_pnd_
    from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    left join quality_of_atr on quality_of_atr.grievance_id = atr_latest_14_bh_mat.grievance_id
    left join pending_for_hod_wise_last_six_months_mat_2 as pending_for_hod_wise_last_six_months_mat on atr_latest_14_bh_mat.grievance_id = pending_for_hod_wise_last_six_months_mat.grievance_id and quality_of_atr.grievance_status = 14
    /******* filter *********/ where atr_latest_14_bh_mat.current_status in (14,15)
                                    and atr_latest_14_bh_mat.assigned_by_office_id in (35)
        /*********** SOURCE **************/
    group by atr_latest_14_bh_mat.district_id
), pending_counts as (
    select forwarded_latest_3_bh_mat.district_id, count(1) as _pndddd_,
    sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
    sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_,
    avg(pending_for_hod_wise_mat.days_diff) as _avg_pending_
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join pending_for_hod_wise_mat_2 as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
    /******* filter *********/ where not exists (select 1 from  atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
                                                    where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                        and atr_latest_14_bh_mat.current_status in (14,15))
                                    and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
                                /*********** SOURCE **************/
    group by forwarded_latest_3_bh_mat.district_id
), close_count as (
    select forwarded_latest_3_bh_mat.district_id, count(1) as _close_
    from grievance_master_bh_mat_2 as gm
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
        where gm.status = 15 and gm.atr_submit_by_lastest_office_id in (35)
        /******* filter *********/
    group by forwarded_latest_3_bh_mat.district_id
), processing_unit as (
    select cmo_districts_master.district_id, cmo_districts_master.district_name, fwd_Count._fwd_, atr_count._atr_,
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
    close_count._close_
    from cmo_districts_master
    left join fwd_Count on cmo_districts_master.district_id = fwd_Count.district_id
    left join atr_count on cmo_districts_master.district_id = atr_count.district_id
    left join pending_counts on cmo_districts_master.district_id = pending_counts.district_id
    left join close_count on cmo_districts_master.district_id = close_count.district_id
    where cmo_districts_master.district_name not in ('Department', 'CMO','Outside West Bengal')
          /******* filter *********/
)select
    row_number() over() as sl_no,
    '2025-03-28 05:15:42.920512+00:00'::timestamp as refresh_time_utc,
    '2025-03-28 05:15:42.920512+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    district_id as unit_id,
    district_name as unit_name,
    coalesce(_fwd_, 0) as grv_frwd,
    coalesce(_atr_, 0) as atr_recvd,
    coalesce(_pnd_, 0) as pending_with_hod,
    _quality_atr_,
    coalesce(_beyond_7_d_, 0) as grv_pendng_more_svn_d,
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
    coalesce(_close_, 0) as total_disposed
from processing_unit;


--------------------------------------------------------------------------------------------------------------------------------------

















with pnd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id
    from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    left join /* VARIABLE */ atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and
                                    atr_latest_14_bh_mat.current_status in (14,15)
    where atr_latest_14_bh_mat.grievance_id is null
          /* VARIABLE */  and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
          /* NEW VARIABLE */
    union
    select bh.grievance_id
    from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
    left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
    where bm.grievance_id is null
        /* VARIABLE */  and bh.assigned_to_office_id in (35)
        /* NEW VARIABLE */
), pnd_raw_data as (
    select grievance_master_bh_mat.*
        from pnd_union_data as bh
        inner join /* VARIABLE */ grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
), pnd as (
    select admin_position_master.office_id, pnd_raw_data.grievance_category, count(1) as pending,
        sum(case when ba.days_diff >= 7 then 1 else 0 end) as beyond_7_d
        from pnd_raw_data
    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
    left join /* VARIABLE */ pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
    where pnd_raw_data.status not in (3, 5, 16)  and (/* VARIABLE */ admin_position_master.office_id not in (35) or admin_position_master.office_id is null)
    group by admin_position_master.office_id, pnd_raw_data.grievance_category
), fwd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where /* VARIABLE */ forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            /* NEW VARIABLE */
        union
    select bh.grievance_id from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh where /* VARIABLE */ bh.assigned_to_office_id in (35)
            /* NEW VARIABLE */
), fwd_atr as (
    select forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category,
        count(forwarded_latest_5_bh_mat.grievance_id) as forwarded,
        count(atr_latest_13_bh_mat.grievance_id) as atr_received
    from fwd_union_data
    left join /* VARIABLE */ forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = fwd_union_data.grievance_id
    left join /* VARIABLE */ atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
                                                                and atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
                                                                /* VARIABLE */ and atr_latest_13_bh_mat.assigned_to_office_id in (35)
    where /* VARIABLE */ forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
    group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category
), processing_unit as (
    select
        /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00':: timestamp as refresh_time_utc,
        /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        coalesce(com.office_name,'N/A') as office_name,
        coalesce(cgcm.grievance_category_desc,'N/A') as grievance_category_desc,
        com.office_id,
        cgcm.parent_office_id,
        coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
        coalesce(fwd_atr.atr_received, 0) AS atr_received,
        coalesce(pnd.beyond_7_d, 0) AS atr_pending_beyond_7d,
        coalesce(pnd.pending, 0) AS atr_pending
    from fwd_atr
    left join cmo_office_master com on com.office_id = fwd_atr.assigned_to_office_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fwd_atr.grievance_category
    full join pnd on fwd_atr.assigned_to_office_id = pnd.office_id and fwd_atr.grievance_category = pnd.grievance_category
    where 1=1
            /* VARIABLE */
            /* VARIABLE */
    order by com.office_name, cgcm.grievance_category_desc
)
select row_number() over() as sl_no, processing_unit.* from processing_unit



--------------------------------------------------------------------------------------------



select * from cmo_office_master com where office_name = 'DM, Bankura District'; -- 56

/*FWD*/
select count(1) as received from forwarded_latest_5_bh_mat_2 bh
    where 1 = 1  and bh.assigned_to_office_id in (35) and bh.assigned_by_office_id = 56  ; -- 11426
    
   
/*ATR*/
   select  count(1) as atr_submitted from atr_latest_13_bh_mat_2 bh
    where 1 = 1  and bh.assigned_by_office_id in (35) and bh.assigned_to_office_id = 56 ; --10
    
   
/*PND*/
   
select  count(1) as pending 
from forwarded_latest_5_bh_mat_2 bh
where not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id)
 and bh.assigned_to_office_id in (35) and  bh.assigned_by_office_id = 56; -- 10696
 
 
 
select bh.grievance_id from forwarded_latest_5_bh_mat_2 bh
    where 1 = 1  and bh.assigned_to_office_id in (35) and bh.assigned_by_office_id = 56 
    			 and not exists (
    			 select  1
						from forwarded_latest_5_bh_mat_2 bh2
						where not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh2.grievance_id)
						 and bh2.assigned_to_office_id in (35) and  bh2.assigned_by_office_id = 56
						 and bh2.grievance_id = bh.grievance_id
				); -- 10696
				
				
select assigned_by_office_cat , assigned_to_office_cat , assigned_by_office_id , assigned_to_office_id , grievance_status , *
from grievance_lifecycle
where grievance_id = 7656 order by assigned_on ;

