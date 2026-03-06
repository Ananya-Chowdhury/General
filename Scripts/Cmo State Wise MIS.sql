
--  ================================== START - API for State Level & District Level Administrative Review Meeting (V2) =================================
with fwd_Count as (
        select forwarded_latest_3_bh_mat.assigned_to_office_id, forwarded_latest_3_bh_mat.grievance_category, count(1) as _fwd_ , forwarded_latest_3_bh_mat.grievance_id 
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        where 1=1 and forwarded_latest_3_bh_mat.grievance_category = 133
        group by forwarded_latest_3_bh_mat.assigned_to_office_id, forwarded_latest_3_bh_mat.grievance_category, forwarded_latest_3_bh_mat.grievance_id 
    ), quality_of_atr as (
        select grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, count(1) as _count_status_wise_
        from grievance_lifecycle
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id
        where grievance_lifecycle.grievance_status in (6,14) and forwarded_latest_3_bh_mat.grievance_category = 133
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
        where atr_latest_14_bh_mat.current_status in (14,15) and forwarded_latest_3_bh_mat.grievance_category = 133
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
        where not exists (select 1 from  atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
        and forwarded_latest_3_bh_mat.grievance_category = 133
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
            where gm.status = 15 and gm.grievance_category = 133
        group by gm.atr_submit_by_lastest_office_id
    ), processing_unit as (
        select 
        	cmo_office_master.office_id, 
        	cmo_office_master.office_name, 
        	cgcm.grievance_cat_id,
        	cgcm.grievance_category_desc,
        	fwd_Count._fwd_, 
        	atr_count._atr_, 
        	close_count._close_,
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
        left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fwd_Count.grievance_category
        where cmo_office_master.office_name != 'Chief Ministers Office' /******* filter *********/
    )select 
    	row_number() over() as sl_no, '2025-08-31 16:30:01.983218+00:00'::timestamp as refresh_time_utc, '2025-08-31 16:30:01.983218+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
    		office_id, 
    		office_name,
    		grievance_cat_id,
    		grievance_category_desc,
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


select * from grievance_lifecycle gl where gl.grievance_id = 3603226; 
select * from grievance_master gm where gm.grievance_id = 3603226;
select * from cmo_griev_cat_office_mapping cgcom ;


--------------------------------- Filtter Added -----------------------------------------
with fwd_Count as (
    select forwarded_latest_3_bh_mat.assigned_to_office_id, count(1) as _fwd_ from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	where 1=1  and forwarded_latest_3_bh_mat.assigned_on::date between '2025-08-01' and '2025-09-01'
    group by forwarded_latest_3_bh_mat.assigned_to_office_id
), quality_of_atr as (
    select grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, count(1) as _count_status_wise_
    from grievance_lifecycle
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_lifecycle.grievance_id
    where grievance_lifecycle.grievance_status in (6,14)
	and forwarded_latest_3_bh_mat.assigned_on::date between '2025-08-01' and '2025-09-01'
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
    /where atr_latest_14_bh_mat.current_status in (14,15) and forwarded_latest_3_bh_mat.assigned_on::date between '2025-08-01' and '2025-09-01'
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
	where not exists (select 1 from  atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
                                                    where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                        and atr_latest_14_bh_mat.current_status in (14,15))
                                   and forwarded_latest_3_bh_mat.assigned_on::date between '2025-08-01' and '2025-09-01'
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
        where gm.status = 15 and forwarded_latest_3_bh_mat.assigned_on::date between '2025-08-01' and '2025-09-01'
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
)select row_number() over() as sl_no, '2025-08-31 16:30:01.983218+00:00'::timestamp as refresh_time_utc, '2025-08-31 16:30:01.983218+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, office_id, office_name,
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


