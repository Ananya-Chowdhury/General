--------------->>>>>>  Current HOD Cart Count Query UPDATE  <<<<<------------
with grievances_recieved as (
            SELECT COUNT(1) as grievances_recieved_cnt
            FROM forwarded_latest_3_bh_mat_2 as bh
            where 1 = 1  and bh.assigned_to_office_id = 35
    ), atr_sent as (
        SELECT COUNT(1) as atr_sent_cnt,
        coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt,
        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd,
        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up,
        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl,
        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 2 then 1 else 0 end), 0) as pending_for_policy_decision
        FROM atr_latest_14_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
        where bm.current_status in (14,15)   and bh.assigned_by_office_id = 35
    ), atr_pending as (
        SELECT COUNT(1) as atr_pending_cnt
        FROM forwarded_latest_3_bh_mat_2 as bh
        WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
          and bh.assigned_to_office_id = 35
    ), grievance_received_other_hod as (
            select count(1) as griev_recv_cnt_other_hod
            from forwarded_latest_5_bh_mat_2 as bh
            where 1 = 1  and bh.assigned_to_office_id = 35
    ),
    /*, atr_sent_other_hod as (
            select
                count(1) as atr_sent_cnt_other_hod,
                coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt_other_hod,
                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
            FROM atr_latest_13_bh_mat_2 as bh
        inner join forwarded_latest_5_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
        where 1 = 1   and bh.assigned_by_office_id = 35
    )*/
    atr_sent_other_hod as (
        select count(1) as atr_sent_cnt_other_hod  from atr_latest_13_bh_mat_2 as bh where 1 = 1   and bh.assigned_by_office_id = 35
    ), close_other_hod as (
            select  count(1) as disposed_cnt_other_hod,
                    coalesce(sum(case when bm.closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                    coalesce(sum(case when bm.closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                    coalesce(sum(case when bm.closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod,
                    coalesce(sum(case when bm.closure_reason_id = 2 then 1  else 0 end), 0) as pending_for_policy_deci_other_hod
                FROM forwarded_latest_5_bh_mat_2 as bh
            inner join grievance_master_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id  
            where bm.status = 15  and bh.assigned_to_office_id = 35
    ), atr_pending_other_hod as (
        SELECT
            COUNT(1) as atr_pending_cnt_other_hod
            FROM forwarded_latest_5_bh_mat_2 as bh
            left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
                WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id) /*and bm.current_status in (14,15)*/)
          and bh.assigned_to_office_id = 35
    )
    select * ,
        '2025-08-07 16:30:01.559409+00:00'::timestamp as refresh_time_utc
        from grievances_recieved
        cross join atr_sent
        cross join atr_pending
        cross join grievance_received_other_hod
        cross join atr_sent_other_hod
        cross join atr_pending_other_hod
        cross join close_other_hod;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------- Grievances and ATR status at My Office -------------------------------
select count(1)
from grievance_master gm 
where gm.status in (1,2) and gm.assigned_to_office_id != 35;   ----Unassigned Grievance


----- Pending Grievance at My Office --------
with raw_data as (
	select grievance_master_bh_mat.*
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
	    and not exists (
	        select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
	            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
	                and atr_latest_14_bh_mat.current_status in (14,15)
            )
), unassigned_cmo as (
    select
        'Unassigned (CMO)' as status,
        'N/A' as name_and_esignation_of_the_user,
        'N/A' as office,
        'N/A' as user_role,
        'N/A' as user_status,
        'N/A' as status_id,
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
        'N/A' as name_and_esignation_of_the_user,
        'N/A' as office,
        'N/A' as user_role,
        'N/A' as user_status,
        'N/A' as status_id,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
), recalled as (
    select
        'Recalled' as status,
        'N/A' as name_and_esignation_of_the_user,
        'N/A' as office,
        'N/A' as user_role,
        'N/A' as user_status,
        'N/A' as status_id,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
    from raw_data
    where raw_data.status = 16
), user_wise_pndcy as (
    select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_role, xx.user_status, xx.status_id::text, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review,
        xx.atr_auto_returned_from_cmo, xx.total_count
    from (
        select 'User wise ATR Pendency' as status,
            -- admin_user_details.official_name as name_and_esignation_of_the_user,
            case when admin_user_details.official_name is not null
                    then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
                else null
            end as name_and_esignation_of_the_user,
            -- cmo_office_master.office_name as office,
            case
                when cmo_sub_office_master.suboffice_name is not null
                    then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
                else cmo_office_master.office_name
            end as office,
            case when admin_position_master.office_id in (35) /*REPLACE*/
                    then admin_user_role_master.role_master_name
                else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
            end as user_role,
            admin_position_master.record_status as status_id,
            case
                when admin_position_master.record_status = 1 then 'Active'
                when admin_position_master.record_status = 2 then 'Inactive'
                else null
            end as user_status,
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
        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
        where raw_data.status not in (3,16)
        group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name, admin_user_role_master.role_master_id,
        admin_user_role_master.role_master_name, cmo_designation_master.designation_name, cmo_sub_office_master.suboffice_name, admin_position_master.record_status
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
    '2025-08-07 16:30:01.559409+00:00'::timestamp as refresh_time_utc,
    '2025-08-07 16:30:01.559409+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    *
from union_part



------ District Wise Grievance ------
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
        inner join  forwarded_latest_3_bh_mat_2 as bh on gm.grievance_id = bh.grievance_id
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
    '2025-08-10 16:30:01.149838+00:00'::timestamp as refresh_time_utc,
'2025-08-10 16:30:01.149838+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
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
left join close_count on gr.district_id = close_count.district_id
--------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
----------------------- HOD dashboard ------>>>>>> Grievnace and ATRs Status of My Sub-Office --------- Final ------>>>> --------------------------------
with fwd_union_data as (		
	select 
		admin_position_master.sub_office_id, 
		forwarded_latest_7_bh_mat.grievance_id,
		forwarded_latest_7_bh_mat.assigned_by_office_id
        from
            (
              select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                  from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
               where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
                union
              select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                 from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
               where forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
            ) as recev_cmo_othod
        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
        where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75)
        group by admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_by_office_id   
   ), fwd_atr as (
   		select 
   			count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
   			from fwd_union_data
   			group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
   ), atr_recv as (
	        select 
	        	fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, count(fwd_union_data.grievance_id) as atr_received
	        from fwd_union_data
	        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
	        where atr_latest_11_bh_mat.assigned_to_office_id in (75)
	        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
	), pend as (		
			select 
				fwd_union_data.sub_office_id, count(1) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
	        from fwd_union_data 
	        inner join pending_at_hoso_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
	        where not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm WHERE fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (75))
	        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
	), ave_days as (
			select 
				fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, avg(bh.days_to_resolve) as avg_days_to_resolved
			from fwd_union_data
	        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
			inner join pending_at_hoso_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
			where 1=1 and atr_latest_11_bh_mat.assigned_to_office_id in (75)
			group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
	)
     select
       '2025-08-21 16:30:01.231162+00:00':: timestamp as refresh_time_utc,
       '2025-08-21 16:30:01.231162+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
       coalesce(cmo_sub_office_master.suboffice_name,'N/A') as Sub_office_name,
       coalesce(cmo_sub_office_master.suboffice_id, 0) as sub_office_id_to,
       coalesce(com.office_id, 0) as office_id_by,
       coalesce(com.office_name, 'N/A') as office_name,
       coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
       coalesce(atr_recv.atr_received, 0) AS atr_received,
       coalesce(round(ave_days.avg_days_to_resolved, 2), 0) AS avg_days_to_resolved,
       coalesce(pend.more_7_days, 0) AS more_7_day,
       coalesce(pend.atrpending, 0) AS atr_pending
        from fwd_atr
        left join atr_recv on fwd_atr.sub_office_id = atr_recv.sub_office_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
        left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
        left join ave_days on fwd_atr.sub_office_id = ave_days.sub_office_id
        left join pend on fwd_atr.sub_office_id = pend.sub_office_id
        	where 1=1
        group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, fwd_atr.forwarded, atr_recv.atr_received, 
        com.office_id, com.office_name, ave_days.avg_days_to_resolved, pend.atrpending, pend.more_7_days
        order by cmo_sub_office_master.suboffice_name;






------- FILTERING WITH SSM CALL CENTER -------
with fwd_union_data as (		
	select 
		admin_position_master.sub_office_id, 
		forwarded_latest_7_bh_mat.grievance_id,
		forwarded_latest_7_bh_mat.assigned_by_office_id
        from
            (
              select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                  from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
               where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ and forwarded_latest_3_bh_mat.grievance_source = 5
                union
              select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                 from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
               where forwarded_latest_5_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ and forwarded_latest_5_bh_mat.grievance_source = 5  
            ) as recev_cmo_othod
        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
        where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75) /*and forwarded_latest_7_bh_mat.grievance_source = 5*/
        group by admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_by_office_id   
   ), fwd_atr as (
   		select 
   			count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
   			from fwd_union_data
   			group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
   ), atr_recv as (
	        select 
	        	fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, count(fwd_union_data.grievance_id) as atr_received
	        from fwd_union_data
	        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
	        where atr_latest_11_bh_mat.assigned_to_office_id in (75)
	        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
	), pend as (		
			select 
				fwd_union_data.sub_office_id, count(1) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
	        from fwd_union_data 
	        inner join pending_at_hoso_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
	        where not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm WHERE fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (75))
	        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
	), ave_days as (
			select 
				fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, avg(bh.days_to_resolve) as avg_days_to_resolved
			from fwd_union_data
	        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
			inner join pending_at_hoso_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
			where 1=1 and atr_latest_11_bh_mat.assigned_to_office_id in (75)
			group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
	)
     select
       '2025-08-21 16:30:01.231162+00:00':: timestamp as refresh_time_utc,
       '2025-08-21 16:30:01.231162+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
       coalesce(cmo_sub_office_master.suboffice_name,'N/A') as Sub_office_name,
       coalesce(cmo_sub_office_master.suboffice_id, 0) as sub_office_id_to,
       coalesce(com.office_id, 0) as office_id_by,
       coalesce(com.office_name, 'N/A') as office_name,
       coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
       coalesce(atr_recv.atr_received, 0) AS atr_received,
       coalesce(round(ave_days.avg_days_to_resolved, 2), 0) AS avg_days_to_resolved,
       coalesce(pend.more_7_days, 0) AS more_7_day,
       coalesce(pend.atrpending, 0) AS atr_pending
        from fwd_atr
--        left join grievance_master_bh_mat_2 gmbm on gmbm.assigned_by_office_id = fwd_atr.assigned_by_office_id
        left join atr_recv on fwd_atr.sub_office_id = atr_recv.sub_office_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
        left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
        left join ave_days on fwd_atr.sub_office_id = ave_days.sub_office_id
        left join pend on fwd_atr.sub_office_id = pend.sub_office_id
        	where 1=1
        group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, fwd_atr.forwarded, atr_recv.atr_received, 
        com.office_id, com.office_name, ave_days.avg_days_to_resolved, pend.atrpending, pend.more_7_days
        order by cmo_sub_office_master.suboffice_name;


--=============================================================================================================================================================================================================================
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---====================================================================================================== FINAL ================================================================================================================
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--==============================================================================================================================================================================================================================

	
	





        
----- Pending Days Count For HOSO Level MAT -----
WITH latest_7 AS (
         SELECT DISTINCT ON (gl.grievance_id) gl.grievance_id,
            gl.assigned_on AS last_assigned_on
           FROM grievance_lifecycle gl
          WHERE gl.grievance_status = 7
          ORDER BY gl.grievance_id, gl.assigned_on DESC
        ), latest_11 AS (
         SELECT DISTINCT ON (gl.grievance_id) gl.grievance_id,
            gl.assigned_on AS last_update_on
           FROM grievance_lifecycle gl
          WHERE gl.grievance_status = 11 AND gl.assigned_by_office_cat = 3
          ORDER BY gl.grievance_id, gl.assigned_on DESC
        )
 SELECT l7.grievance_id,
    l7.last_assigned_on,
    l11.last_update_on,
        CASE
            WHEN l11.last_update_on IS NOT NULL AND l11.last_update_on > l7.last_assigned_on THEN 0
            ELSE CURRENT_DATE - l7.last_assigned_on::date
        END AS pending_days,
        CASE
            WHEN l11.last_update_on IS NOT NULL AND l11.last_update_on > l7.last_assigned_on THEN l11.last_update_on::date - l7.last_assigned_on::date
            ELSE CURRENT_DATE - l7.last_assigned_on::date
        END AS days_to_resolve
   FROM latest_7 l7
     LEFT JOIN latest_11 l11 ON l7.grievance_id = l11.grievance_id
    
    
--DROP MATERIALIZED VIEW IF EXISTS pending_at_hoso_mat_2;
    
    
    
 select * from grievance_lifecycle gl where gl.grievance_id = 32 order by gl.assigned_on ;
    
 
 
 ---------------- PREVIOUS MADE BY KINNAR DA ---->>>> Pending Days Count For HOSO Level MAT ------------------------
 WITH latest_7 AS (
         SELECT a.rn,
            a.grievance_id,
            a.assigned_on,
            a.assigned_by_office_id,
            a.assigned_by_position,
            a.assigned_to_position,
            a.assigned_to_office_id
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn,
                    gl.grievance_id,
                    gl.assigned_on,
                    gl.assigned_by_office_id,
                    gl.assigned_by_position,
                    gl.assigned_to_position,
                    gl.assigned_to_office_id
                   FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = 7) a
          WHERE a.rn = 1
        ), latest_11 AS (
         SELECT a.rn,
            a.grievance_id,
            a.assigned_on,
            a.assigned_by_office_id,
            a.assigned_by_position,
            a.assigned_to_position,
            a.assigned_to_office_id
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn,
                    gl.grievance_id,
                    gl.grievance_status,
                    gl.assigned_on,
                    gl.assigned_by_office_id,
                    gl.assigned_by_position,
                    gl.assigned_to_position,
                    gl.assigned_to_office_id
                   FROM grievance_lifecycle gl
                  WHERE (gl.grievance_status = 11 OR gl.grievance_status = 12) AND gl.assigned_by_office_cat = 3) a
--                  WHERE gl.grievance_status = 12 AND gl.assigned_by_office_cat = 3) a
          WHERE a.rn = 1 AND a.grievance_status = 11
        )
 SELECT cte1.grievance_id,
    COALESCE(EXTRACT(day FROM
        CASE
            WHEN cte2.assigned_on IS NULL THEN now()
            WHEN cte2.assigned_on < cte1.assigned_on THEN now()
            ELSE cte2.assigned_on
        END - cte1.assigned_on)::integer, 0) AS days_diff,
    cte1.assigned_on AS rcv_assigned_on,
    cte1.assigned_by_office_id AS rcv_assigned_by_office_id,
    cte1.assigned_by_position AS rcv_assigned_by_position,
    cte1.assigned_to_position AS rcv_assigned_to_position,
    cte1.assigned_to_office_id AS rcv_assigned_to_office_id,
    cte2.assigned_on AS atr_assigned_on,
    cte2.assigned_by_office_id AS atr_assigned_by_office_id,
    cte2.assigned_by_position AS atr_assigned_by_position,
    cte2.assigned_to_position AS atr_assigned_to_position,
    cte2.assigned_to_office_id AS atr_assigned_to_office_id
   FROM latest_7 cte1
     LEFT JOIN latest_11 cte2 ON cte1.grievance_id = cte2.grievance_id
    
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        
----------- HOD DASHBOARD SCHEME WISE QUERY -----------------
with fwd_count as (
    select bh.grievance_category, count(1) as _fwd_
    from forwarded_latest_3_bh_mat_2 as bh
    where bh.grievance_category > 0    and bh.assigned_to_office_id = 75
    group by bh.grievance_category
), atr_count as (
    select bh.grievance_category, count(1) as _atr_,
        sum(case when bh.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up
    from atr_latest_14_bh_mat_2 as bh
    where bh.grievance_category > 0 and bh.current_status in (14,15)    and bh.assigned_by_office_id = 75
    group by bh.grievance_category
), pending_count as (
    select bh.grievance_category, count(1) as _pndddd_ , avg(pm.days_diff) as _avg_pending_/*, pm.days_diff as total_pending*/
    from forwarded_latest_3_bh_mat_2 as bh
    inner join pending_for_hod_wise_mat_2 as pm on bh.grievance_id = pm.grievance_id
    where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
       and bh.assigned_to_office_id = 75
    group by bh.grievance_category/*, pm.days_diff*/
) select
        '2025-09-02 16:30:01.270546+00:00'::timestamp as refresh_time_utc,
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
        
        
        
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        
     select
            admin_position_master.sub_office_id, count(1) as pending,
            sum(case when (ba.days_diff > 7) then 1 else 0 end) as more_7_days
--                sum(case when (15 >= ba.days_diff and ba.days_diff > 7) then 1 else 0 end) as d_7_15,
        from (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
            from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            left join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
            where atr_latest_14_bh_mat.grievance_id is null and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            union
                select bh.grievance_id, bh.assigned_on
                from forwarded_latest_5_bh_mat_2 bh
                left join atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                where bm.grievance_id is null and bh.assigned_to_office_id in (35)
        ) as pnd_union_data
        inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = pnd_union_data.grievance_id
        left join admin_position_master on admin_position_master.position_id = grievance_master_bh_mat.assigned_to_position
        left join pending_for_hoso_wise_mat_2 as ba on grievance_master_bh_mat.grievance_id = ba.grievance_id
        where grievance_master_bh_mat.status not in (3, 5, 16) and admin_position_master.role_master_id in (7,8) and admin_position_master.office_id in (35)
        group by admin_position_master.sub_office_id   
        
        
        
        
        
WITH latest_7 AS (
         SELECT DISTINCT ON (gl.grievance_id) gl.grievance_id,
            gl.assigned_on AS last_assigned_on
           FROM grievance_lifecycle gl
          WHERE gl.grievance_status = 7
          ORDER BY gl.grievance_id, gl.assigned_on DESC
        ), latest_11 AS (
         SELECT DISTINCT ON (gl.grievance_id) gl.grievance_id,
            gl.assigned_on AS last_update_on
           FROM grievance_lifecycle gl
          WHERE gl.grievance_status = 11
          ORDER BY gl.grievance_id, gl.assigned_on DESC
        )
 SELECT l7.grievance_id,
        CASE
            WHEN l11.last_update_on IS NOT NULL AND l11.last_update_on > l7.last_assigned_on THEN 0::numeric
            ELSE EXTRACT(day FROM CURRENT_DATE::timestamp with time zone - l7.last_assigned_on)
        END AS pending_days
   FROM latest_7 l7
     LEFT JOIN latest_11 l11 ON l7.grievance_id = l11.grievance_id




WITH latest_7 AS (
    SELECT DISTINCT ON (gl.grievance_id) 
           gl.grievance_id,
           gl.assigned_on AS last_assigned_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 7
    ORDER BY gl.grievance_id, gl.assigned_on DESC
),
latest_11 AS (
    SELECT DISTINCT ON (gl.grievance_id) 
           gl.grievance_id,
           gl.assigned_on AS last_update_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 11
    ORDER BY gl.grievance_id, gl.assigned_on DESC
),
grievance_calc AS (
    SELECT 
        l7.grievance_id,
        CASE
            WHEN l11.last_update_on IS NOT NULL 
                 AND l11.last_update_on > l7.last_assigned_on 
            THEN 0::numeric
            ELSE EXTRACT(day FROM CURRENT_DATE::timestamp - l7.last_assigned_on)
        END AS pending_days,
        CASE
            WHEN l11.last_update_on > l7.last_assigned_on 
            THEN EXTRACT(day FROM (l11.last_update_on - l7.last_assigned_on))
            ELSE NULL
        END AS days_to_resolve
    FROM latest_7 l7
    LEFT JOIN latest_11 l11 
           ON l7.grievance_id = l11.grievance_id
)
SELECT 
    grievance_id,
    pending_days,
    days_to_resolve,
--    (SELECT AVG(days_to_resolve)::numeric(10,2) 
    AVG(days_to_resolve)
       FROM grievance_calc 
      WHERE days_to_resolve IS NOT NULL) AS avg_days_to_resolve
FROM grievance_calc;




WITH latest_7 AS (
    SELECT DISTINCT ON (gl.grievance_id) 
           gl.grievance_id,
           gl.assigned_on AS last_assigned_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 7
    ORDER BY gl.grievance_id, gl.assigned_on DESC
),
latest_11 AS (
    SELECT DISTINCT ON (gl.grievance_id) 
           gl.grievance_id,
           gl.assigned_on AS last_update_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 11
    ORDER BY gl.grievance_id, gl.assigned_on DESC
),
grievance_calc AS (
    SELECT 
        l7.grievance_id,
        CASE
            WHEN l11.last_update_on IS NOT NULL 
                 AND l11.last_update_on > l7.last_assigned_on 
            THEN EXTRACT(day FROM (l11.last_update_on - l7.last_assigned_on))
            ELSE EXTRACT(day FROM (CURRENT_DATE::timestamp - l7.last_assigned_on))
        END AS days_count
    FROM latest_7 l7
    LEFT JOIN latest_11 l11 
           ON l7.grievance_id = l11.grievance_id
)
SELECT 
    grievance_id,
    days_count,
    (SELECT AVG(days_count)::numeric(10,2) 
       FROM grievance_calc) AS avg_days_to_resolve
FROM grievance_calc;

----------------------------------------------------===========================================================================================
---============================== HOD dashboard ------>>>>>> Grievnace and ATRs Status of My Sub-Office ==========================================
---- MIS ------>>>>
with pnd as (
        select
                admin_position_master.sub_office_id, grievance_master_bh_mat.grievance_category, count(1) as pending,
                sum(case when ba.days_diff <= 7 then 1 else 0 end) as d_0_7_d,
                sum(case when (15 >= ba.days_diff and ba.days_diff > 7) then 1 else 0 end) as d_7_15,
                sum(case when (30 >= ba.days_diff and ba.days_diff > 15) then 1 else 0 end) as d_15_30,
                sum(case when (ba.days_diff > 30) then 1 else 0 end) as more_30_d
        from (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
            from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            left join /* VARIABLE */ atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                                                                                and atr_latest_14_bh_mat.current_status in (14,15)
            where atr_latest_14_bh_mat.grievance_id is null
                /* VARIABLE */  and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            union
                select bh.grievance_id, bh.assigned_on
                from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
                left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                where bm.grievance_id is null
                    /* VARIABLE */  and bh.assigned_to_office_id in (35)
        ) as pnd_union_data
        inner join /* VARIABLE */ grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = pnd_union_data.grievance_id
        left join admin_position_master on admin_position_master.position_id = grievance_master_bh_mat.assigned_to_position
        left join /* VARIABLE */ pending_for_hoso_wise_mat_2 as ba on grievance_master_bh_mat.grievance_id = ba.grievance_id
        where grievance_master_bh_mat.status not in (3, 5, 16) and admin_position_master.role_master_id in (7,8)
            /* VARIABLE */ and admin_position_master.office_id in (35)
            /* VARIABLE */
        group by admin_position_master.sub_office_id, grievance_master_bh_mat.grievance_category
    ), fwd_union_data as (
        select admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_category, forwarded_latest_7_bh_mat.grievance_id
        from
            (
                select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                    from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
                where /* VARIABLE */ forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
                    union
                select bh.grievance_id, bh.assigned_on
                    from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
                where /* VARIABLE */ bh.assigned_to_office_id in (35)
            )as XX
        inner join /* VARIABLE */ forwarded_latest_7_bh_mat_2 forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = XX.grievance_id
        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
        where 1=1 /* VARIABLE */
                /* VARIABLE */ and forwarded_latest_7_bh_mat.assigned_by_office_id in (35)
    ), fwd_atr as (
        select fwd_union_data.sub_office_id, fwd_union_data.grievance_category, count(fwd_union_data.grievance_id) as forwarded
        from fwd_union_data
        group by fwd_union_data.sub_office_id, fwd_union_data.grievance_category
    ), atr as (
        select fwd_union_data.sub_office_id, fwd_union_data.grievance_category, count(fwd_union_data.grievance_id) as atr_received
        from fwd_union_data
        inner join /* VARIABLE */ atr_latest_11_bh_mat_2 atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
        where /* VARIABLE */ atr_latest_11_bh_mat.assigned_to_office_id in (35)
        group by fwd_union_data.sub_office_id, fwd_union_data.grievance_category
    ), processing_unit as (
        select
            /* VARIABLE */ '2025-08-21 16:30:01.231162+00:00':: timestamp as refresh_time_utc,
            /* VARIABLE */ '2025-08-21 16:30:01.231162+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
            coalesce(cmo_sub_office_master.suboffice_name,'N/A') as office_name,
            coalesce(cgcm.grievance_category_desc,'N/A') as grievance_category_desc,
            cmo_sub_office_master.suboffice_id,
            cgcm.parent_office_id,
            coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
            coalesce(atr.atr_received, 0) AS atr_received,
            coalesce(pnd.d_0_7_d, 0) AS d_0_7_d,
            coalesce(pnd.d_7_15, 0) AS d_7_15,
            coalesce(pnd.d_15_30, 0) AS d_15_30,
            coalesce(pnd.more_30_d, 0) AS more_30_d,
            coalesce(pnd.pending, 0) AS atr_pending
        from fwd_atr
        left join atr on fwd_atr.sub_office_id = atr.sub_office_id and fwd_atr.grievance_category = atr.grievance_category
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
        left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fwd_atr.grievance_category
        full join pnd on fwd_atr.sub_office_id = pnd.sub_office_id and fwd_atr.grievance_category = pnd.grievance_category
        where 1=1
                /* VARIABLE */
                /* VARIABLE */
        order by cmo_sub_office_master.suboffice_name, cgcm.grievance_category_desc
    )
    select row_number() over() as sl_no, processing_unit.* from processing_unit

-----------------------------------------------------------------------------------------------------------------------
----- Sample -----------
SELECT COUNT(1) as grievances_recieved_cnt, bh.district_id
        FROM forwarded_latest_3_bh_mat_2 as bh
        where 1 = 1
         and bh.assigned_to_office_id in (35)
        group by bh.district_id
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
select * from cmo_action_taken_note_master catnm ;
select * from cmo_closure_reason_master ccrm  ;

select * from cmo_sub_office_master csom where csom.office_id in (35);
select * from grievance_master gm limit 1;


----------------------------------- HOD DASHBOARD UPDATE ---------------------------------
with grievances_recieved as (
            SELECT COUNT(1) as grievances_recieved_cnt
            FROM forwarded_latest_3_bh_mat_2 as bh
            where 1 = 1  and bh.assigned_to_office_id = 35
    ), atr_sent as (
        SELECT COUNT(1) as atr_sent_cnt,
        coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt,
        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd,
        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up,
        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl
        FROM atr_latest_14_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
        where bm.current_status in (14,15)   and bh.assigned_by_office_id = 35
    ), atr_pending as (
        SELECT COUNT(1) as atr_pending_cnt
        FROM forwarded_latest_3_bh_mat_2 as bh
        WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
          and bh.assigned_to_office_id = 35
    ), grievance_received_other_hod as (
            select count(1) as griev_recv_cnt_other_hod
            from forwarded_latest_5_bh_mat_2 as bh
            where 1 = 1  and bh.assigned_to_office_id = 35
    ),
    /*, atr_sent_other_hod as (
            select
                count(1) as atr_sent_cnt_other_hod,
                coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt_other_hod,
                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
            FROM atr_latest_13_bh_mat_2 as bh
        inner join forwarded_latest_5_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
        where 1 = 1   and bh.assigned_by_office_id = 35
    )*/
    atr_sent_other_hod as (
        select count(1) as atr_sent_cnt_other_hod  from atr_latest_13_bh_mat_2 as bh where 1 = 1   and bh.assigned_by_office_id = 35
    ), close_other_hod as (
            select  count(1) as disposed_cnt_other_hod,
                    coalesce(sum(case when bm.closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                    coalesce(sum(case when bm.closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                    coalesce(sum(case when bm.closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
                FROM forwarded_latest_5_bh_mat_2 as bh
            inner join grievance_master_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
            where bm.status = 15  and bh.assigned_to_office_id = 35
    ), atr_pending_other_hod as (
        SELECT
            COUNT(1) as atr_pending_cnt_other_hod
            FROM forwarded_latest_5_bh_mat_2 as bh
            left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
                WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id /*and bm.current_status in (14,15)*/)
          and bh.assigned_to_office_id = 35
    )
    select * ,
        '2025-08-20 16:30:01.123096+00:00'::timestamp as refresh_time_utc
        from grievances_recieved
        cross join atr_sent
        cross join atr_pending
        cross join grievance_received_other_hod
        cross join atr_sent_other_hod
        cross join atr_pending_other_hod
        cross join close_other_hod;
-------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------- HOD Dashboard ------>>>>>> Grievances Sent To Other HOD --------- Final ------>>>> -------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

with fwd_union_data as (		
    select 
        forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
            ) as recev_cmo_othod
        inner join forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        --left join admin_position_master on forwarded_latest_5_bh_mat.assigned_to_position = admin_position_master.position_id
            where 1=1 and forwarded_latest_5_bh_mat.assigned_by_office_id in (75)
        group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id   
),  fwd_atr as (
        select 
            count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
            from fwd_union_data
            group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
),  atr_recv as (
        select 
            fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id, count(fwd_union_data.grievance_id) as atr_received
        from fwd_union_data
        inner join atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
        where atr_latest_13_bh_mat.assigned_to_office_id in (75)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
),  pend as (		
        select 
            fwd_union_data.assigned_to_office_id, count(fwd_union_data.grievance_id) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
        from fwd_union_data 
        inner join pending_at_other_hod_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (75))
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
 ), ave_days as (
        select 
            fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id, avg(bh.days_to_resolve) as avg_days_to_resolved
        from fwd_union_data
        inner join atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
        inner join pending_at_other_hod_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
        where 1=1 and atr_latest_13_bh_mat.assigned_to_office_id in (75)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
)
select
    '2025-09-09 16:30:01.254974+00:00'::timestamp as refresh_time_utc,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name_by,
    coalesce(com2.office_id, 0) as office_id_to,
    coalesce(com2.office_name, 'N/A') as office_name_to,
    coalesce(fwd_atr.forwarded, 0) as grv_forwarded,
    coalesce(atr_recv.atr_received, 0) as atr_received,
    coalesce(round(ave_days.avg_days_to_resolved, 2), 0) as avg_days_to_resolved,
    coalesce(pend.more_7_days, 0) as more_7_day,
    coalesce(pend.atrpending, 0) as atr_pending
    from fwd_atr
left join atr_recv on fwd_atr.assigned_to_office_id = atr_recv.assigned_to_office_id
left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
left join cmo_office_master com2 on com2.office_id = fwd_atr.assigned_to_office_id
left join ave_days on fwd_atr.assigned_to_office_id = ave_days.assigned_to_office_id
left join pend on fwd_atr.assigned_to_office_id = pend.assigned_to_office_id
    where 1=1
group by com.office_id, com.office_name, fwd_atr.forwarded, atr_recv.atr_received, com2.office_id, com2.office_name, ave_days.avg_days_to_resolved, pend.atrpending, pend.more_7_days
order by com2.office_name;

-- =======================================================================================================================================================================================


-- ================= Pending For Other HOD =======================
WITH latest_5 AS (
         SELECT DISTINCT ON (gl.grievance_id) gl.grievance_id,
            gl.assigned_on AS last_assigned_on
           FROM grievance_lifecycle gl
          WHERE gl.grievance_status = 5
          ORDER BY gl.grievance_id, gl.assigned_on DESC
        ), latest_13 AS (
         SELECT DISTINCT ON (gl.grievance_id) gl.grievance_id,
            gl.assigned_on AS last_update_on
           FROM grievance_lifecycle gl
          WHERE gl.grievance_status = 13
          ORDER BY gl.grievance_id, gl.assigned_on DESC
        )
 SELECT l5.grievance_id,
    l5.last_assigned_on,
    l13.last_update_on,
        CASE
            WHEN l13.last_update_on IS NOT NULL AND l13.last_update_on > l5.last_assigned_on THEN 0
            ELSE CURRENT_DATE - l5.last_assigned_on::date
        END AS pending_days,
        CASE
            WHEN l13.last_update_on IS NOT NULL AND l13.last_update_on > l5.last_assigned_on THEN l13.last_update_on::date - l5.last_assigned_on::date
            ELSE CURRENT_DATE - l5.last_assigned_on::date
        END AS days_to_resolve
   FROM latest_5 l5
     LEFT JOIN latest_13 l13 ON l5.grievance_id = l13.grievance_id
-- ===================================================================


select * from grievance_lifecycle gl where gl.grievance_id = 3640896 order by gl.assigned_on desc;   --492, 1668, 1910
select * from grievance_master gm where gm.grievance_id = 61531;

2507264
3603613
3640896


with fwd_union_data as (		
    select 
        forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
            ) as recev_cmo_othod
        inner join forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        --left join admin_position_master on forwarded_latest_5_bh_mat.assigned_to_position = admin_position_master.position_id
            where 1=1 and forwarded_latest_5_bh_mat.assigned_by_office_id in (75)
        group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id   
)  select 
            fwd_union_data.assigned_to_office_id, fwd_union_data.grievance_id as atrpending, fwd_union_data.assigned_by_office_id
        from fwd_union_data 
        left join pending_at_other_hod_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
--        left join pending_for_other_hod_wise_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (75)) /*and fwd_union_data.assigned_to_office_id = 35*/
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id, fwd_union_data.grievance_id

        
 -- ============================================================       
 -- -------------- HOD MIS sent to Other HOD -------------------   
 -- ============================================================   
 with pnd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id
    from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    left join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
    where atr_latest_14_bh_mat.grievance_id is null and forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
          /* NEW VARIABLE */
    union
    select bh.grievance_id
    from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
    left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
    where bm.grievance_id is null and bh.assigned_to_office_id in (75)
), pnd_raw_data as (
    select grievance_master_bh_mat.*
        from pnd_union_data as bh
        inner join /* VARIABLE */ grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
), pnd as (
    select admin_position_master.office_id, pnd_raw_data.grievance_category, count(1) as pending,
        sum(case when ba.days_diff <= 7 then 1 else 0 end) as d_0_7_d,
        sum(case when (15 >= ba.days_diff and ba.days_diff > 7) then 1 else 0 end) as d_7_15,
        sum(case when (30 >= ba.days_diff and ba.days_diff > 15) then 1 else 0 end) as d_15_30,
        sum(case when (ba.days_diff > 30) then 1 else 0 end) as more_30_d
        from pnd_raw_data
    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
    left join pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
    where pnd_raw_data.status not in (3, 5, 16)  and (admin_position_master.office_id not in (75) or admin_position_master.office_id is null)
    group by admin_position_master.office_id, pnd_raw_data.grievance_category
), fwd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where /* VARIABLE */ forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
            /* NEW VARIABLE */
        union
    select bh.grievance_id from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh where /* VARIABLE */ bh.assigned_to_office_id in (75)
            /* NEW VARIABLE */
), fwd_atr as (
    select forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category,
        count(forwarded_latest_5_bh_mat.grievance_id) as forwarded,
        count(atr_latest_13_bh_mat.grievance_id) as atr_received
    from fwd_union_data
    left join /* VARIABLE */ forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = fwd_union_data.grievance_id
    left join /* VARIABLE */ atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
                                                                and atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
                                                                /* VARIABLE */ and atr_latest_13_bh_mat.assigned_to_office_id in (75)
    where /* VARIABLE */ forwarded_latest_5_bh_mat.assigned_by_office_id in (75)
    group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category
), processing_unit as (
    select
        /* VARIABLE */ '2025-09-21 16:30:01.211741+00:00':: timestamp as refresh_time_utc,
        /* VARIABLE */ '2025-09-21 16:30:01.211741+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        coalesce(com.office_name,'N/A') as office_name,
        coalesce(cgcm.grievance_category_desc,'N/A') as grievance_category_desc,
        com.office_id,
        cgcm.parent_office_id,
        coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
        coalesce(fwd_atr.atr_received, 0) AS atr_received,
        coalesce(pnd.d_0_7_d, 0) AS d_0_7_d,
        coalesce(pnd.d_7_15, 0) AS d_7_15,
        coalesce(pnd.d_15_30, 0) AS d_15_30,
        coalesce(pnd.more_30_d, 0) AS more_30_d,
        coalesce(pnd.pending, 0) AS atr_pending
    from fwd_atr
    left join cmo_office_master com on com.office_id = fwd_atr.assigned_to_office_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fwd_atr.grievance_category
    full join pnd on fwd_atr.assigned_to_office_id = pnd.office_id and fwd_atr.grievance_category = pnd.grievance_category
    where 1=1
            /* VARIABLE */
            /* VARIABLE */  and com.office_id in (35)
    order by com.office_name, cgcm.grievance_category_desc
)
select row_number() over() as sl_no, processing_unit.* from processing_unit

-- =============================================================================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ====================================================================================================== FINAL ================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==============================================================================================================================================================================================================================




-- ======================================================================================================================================================================
-- --------------------------------------- HOD Dashboard ------------>>>>>> Grievances Received From Other HOD --------- Final ------>>>> -------------------------------
-- ======================================================================================================================================================================

with received_count as (
        select 
        	forwarded_latest_5_bh_mat.assigned_by_office_id,
        	count(1) as received
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        where 1=1 and forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
        group by forwarded_latest_5_bh_mat.assigned_by_office_id
), atr_submitted as (
        select 
        	forwarded_latest_5_bh_mat.assigned_by_office_id, 
        	count(1) as atr_submitted,
        	avg(pending_at_other_hod_mat.days_to_resolve) as avg_days_to_resolved
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat 
        inner join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
        left join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        where 1=1  and atr_latest_13_bh_mat.assigned_by_office_id in (75)
        group by forwarded_latest_5_bh_mat.assigned_by_office_id
), pending_count as (
        select 
        	forwarded_latest_5_bh_mat.assigned_by_office_id, 
        	count(1) as pending, 
        	sum(case when (pending_at_other_hod_mat.pending_days > 7) then 1 else 0 end) as more_7_days
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        inner join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat where forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id /*and atr_latest_13_bh_mat.assigned_by_office_id in (75)*/)
        and forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
        group by forwarded_latest_5_bh_mat.assigned_by_office_id      
)
select
    '2025-09-09 16:30:01.254974+00:00'::timestamp as refresh_time_utc,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name_by,
    coalesce(rc.received, 0) as grv_received,
    coalesce(ats.atr_submitted, 0) as atr_submitted,
    coalesce(round(ats.avg_days_to_resolved, 2), 0) as avg_days_to_resolved,
    coalesce(pc.more_7_days, 0) as more_7_days,
    coalesce(pc.pending, 0) as atr_pending
    from received_count rc
    left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
    left join atr_submitted ats on ats.assigned_by_office_id = com.office_id 
    left join pending_count pc on pc.assigned_by_office_id = com.office_id 
    where 1=1
	group by com.office_id, com.office_name, rc.received, ats.atr_submitted, ats.avg_days_to_resolved, pc.pending, pc.more_7_days
    order by com.office_name






------ Recevied From Other HOD MIS ---------
with received_count as (
        select forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id,  count(1) as received
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        where 1=1
            /* VARIABLE */
            /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
            /* VARIABLE */
        group by forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id
), atr_submitted as (
        select atr_latest_13_bh_mat.grievance_category, atr_latest_13_bh_mat.assigned_to_office_id, count(1) as atr_submitted
        from atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat
        inner join forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
        where 1=1
            /* VARIABLE */
            /* VARIABLE */  and atr_latest_13_bh_mat.assigned_by_office_id in (75)
            /* VARIABLE */
        group by atr_latest_13_bh_mat.grievance_category, atr_latest_13_bh_mat.assigned_to_office_id
), pending_count as (
        select forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id, count(1) as pending
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        where atr_latest_13_bh_mat.grievance_id is null
            /* VARIABLE */
            /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
            /* VARIABLE */
        group by forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_category
) select
    row_number() over() as sl_no,
    /* VARIABLE */ '2025-09-23 16:30:01.370040+00:00'::timestamp as refresh_time_utc,
    /* VARIABLE */ '2025-09-23 16:30:01.370040+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cgcm.grievance_category_desc,
    coalesce(com.office_name,'N/A') as office_name,
    cgcm.parent_office_id,
    com.office_id,
        coalesce(rc.received, 0) AS grv_fwd,
        coalesce(ats.atr_submitted, 0) AS atr_rcvd,
        coalesce(pc.pending, 0) AS atr_pndg
    from received_count rc
    left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = rc.grievance_category
    left join atr_submitted ats on ats.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = ats.grievance_category
    left join pending_count pc on pc.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
    order by com.office_name, cgcm.grievance_category_desc
    
    -- =================================================================================================================================
    -- =================================================================================================================================
    -- =================================================================================================================================
    
					    
select 
	forwarded_latest_5_bh_mat.assigned_by_office_id, 
	count(1) as pending 
--				        	sum(case when (pending_at_other_hod_mat.pending_days > 7) then 1 else 0 end) as more_7_days
from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
/*inner join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id*/
where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat where forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id) 
and forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
group by forwarded_latest_5_bh_mat.assigned_by_office_id       






select forwarded_latest_5_bh_mat.assigned_by_office_id, count(1) as pending
from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
--                        left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
where atr_latest_13_bh_mat.grievance_id is null
    /* VARIABLE */
    /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
    /* VARIABLE */
group by forwarded_latest_5_bh_mat.assigned_by_office_id
                

                        
                        
 select 
	forwarded_latest_5_bh_mat.assigned_by_office_id, 
	count(1) as pending 
from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
/*inner join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id*/
where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat where forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id and atr_latest_13_bh_mat.assigned_by_office_id in (75)) 
and forwarded_latest_5_bh_mat.assigned_to_office_id in (75)
group by forwarded_latest_5_bh_mat.assigned_by_office_id 
                        
	        
	 --------------------------------------------------------------------------------------------------------------------------------------------------------       
	        
	        
select forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_to_office_id
    from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
--                        left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
    left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
    where atr_latest_13_bh_mat.grievance_id is null
        /* VARIABLE */
        /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (75) and forwarded_latest_5_bh_mat.assigned_by_office_id = 57
        /* VARIABLE */
    group by forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_id , forwarded_latest_5_bh_mat.assigned_to_office_id
	        

	        
	        
	        
    select 
    	forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_id , forwarded_latest_5_bh_mat.assigned_to_office_id
    from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
    /*inner join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id*/
    where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat where forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id and atr_latest_13_bh_mat.assigned_by_office_id in (75)) 
    and forwarded_latest_5_bh_mat.assigned_to_office_id in (75) and forwarded_latest_5_bh_mat.assigned_by_office_id = 57
    group by forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_to_office_id  --2454642, 1849738, 1520920
                        
	        
	        
	 select 
		 gl.grievance_id,
		 gl.assigned_on,
		 gl.grievance_status,
		 gl.assigned_by_id,
		 gl.assigned_to_id,
		 gl.assigned_by_office_id,
		 gl.assigned_to_office_id,
		 gl.assigned_by_position,
		 gl.assigned_to_position,
		 gl.assigned_by_office_cat,
		 gl.assigned_to_office_cat
	 from grievance_lifecycle gl where gl.grievance_id = 3669328 order by gl.assigned_on desc;
-- ==============================================================================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ====================================================================================================== FINAL =================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==============================================================================================================================================================================================================================


	 
-- ============================================================================================================================================================================
-- --------------------------------------- HOD Dashboard ------------>>>>>> Grievances And ATRs Status At My Office --------- Final ------>>>> -------------------------------
-- ============================================================================================================================================================================
	
-- ===================== Unassigned Grievance =================== --	
with in_status_3 as ( 
	select 
		count(*) as assigned_to_admin 
from forwarded_latest_3_bh_mat_2 flbm 
where flbm.assigned_to_office_id in (75) 
) 
select count(*) as unassigned_grievance from in_status_3
where not exists (select 1 from grievance_master_bh_mat_2 gmbm where in_status_3.assigned_to_office_id = gmbm.assigned_to_office_id and gmbm.status != 4)	
	

	
	
WITH in_status_3 AS (
    SELECT 
        flbm.grievance_id,
        flbm.assigned_to_office_id
    FROM forwarded_latest_3_bh_mat_2 flbm
    WHERE flbm.assigned_to_office_id IN (75)
)
SELECT 
--    COUNT(*) AS unassigned_grievance
    ins.grievance_id
FROM in_status_3 ins
WHERE NOT EXISTS (
    SELECT 1
    FROM forwarded_latest_4_bh_mat_2 gmbm
    WHERE gmbm.grievance_id = ins.grievance_id
      AND gmbm.assigned_to_office_id = ins.assigned_to_office_id
--      AND gmbm.grievance_status = 4 
);

-- ===================== Unassigned Grievance -- (USING LEAD FUNTION) =================== --	
--DROP MATERIALIZED VIEW IF EXISTS forwarded_latest_3_4_bh_mat;


--CREATE MATERIALIZED VIEW public.forwarded_latest_3_4_bh_mat
--AS
select
--	t.rnn,
	t.grievance_id,
    t.previous_status,
    t.assigned_to_office_id,
    t.assigned_to_position,
    t.assigned_to_id,
    t.grievance_source,
    t.current_status,
    t.next_status,
    t.next_status_assigned_to_office,
    t.next_status_assigned_to_position,
    t.next_status_assigned_to_id
   FROM ( SELECT 
--   FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
   			gl.grievance_id,
            gl.grievance_status AS previous_status,
            gl.assigned_to_office_id,
            gl.assigned_to_position,
            gl.assigned_to_id,
            gm.grievance_source,
            gm.status AS current_status,
            lead(gl.grievance_status) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status,
            lead(gl.assigned_to_office_id) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status_assigned_to_office,
            lead(gl.assigned_to_position) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status_assigned_to_position,
            lead(gl.assigned_to_id) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status_assigned_to_id
           FROM grievance_lifecycle gl
             JOIN grievance_master gm ON gm.grievance_id = gl.grievance_id) t
--             where t.rnn = 1 
and previous_status = 3 and assigned_to_office_id in (75) /*and grievance_source = 5*/ and assigned_to_office_id = next_status_assigned_to_office
-- AND (next_status IS DISTINCT FROM 4) 
--AND (next_status IS NULL OR next_status NOT IN (4, 5, 11, 14, 7))
AND next_status IN (4, 5, 11, 14, 7)



-------------------



---- Correct for Unassigned Grievance -----
select count(*) as unassigned_grievances
from forwarded_latest_3_4_bh_mat_2 bh
WHERE grievance_status = 3 and assigned_to_office_id in (75) /*and grievance_source = 5*/ /*and assigned_to_office_id = next_status_assigned_to_office*/
--  AND (next_status IS DISTINCT FROM 4) ; 
  AND (next_status IS NULL OR next_status NOT IN (4, 5, 11, 14, 7))

  
------- Sample Query ---------
SELECT grievance_id
FROM (
    SELECT 
        gl.grievance_id,
        gl.grievance_status,
        gl.assigned_to_office_id,
        LEAD(gl.grievance_status) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status
    FROM grievance_lifecycle gl 
) t
WHERE grievance_status = 3 /*and assigned_to_office_id in (75)*/
  AND (next_status IS DISTINCT FROM 4);

	
select
	gl.lifecycle_id,
	gl.grievance_id,
	gl.grievance_status,
	gl.assigned_on,
	gl.assigned_to_office_id,
	gl.assigned_to_position,
	gl.assigned_by_position 
from grievance_lifecycle gl where gl.grievance_id = 302 order by assigned_on desc;

select * from cmo_office_master com where com.office_id = 75;
	


select 
	bh.assigned_to_position,
	bh.assigned_to_id,
	 count(1) as assigned
from forwarded_latest_3_4_bh_mat_2 as bh
where bh.assigned_to_office_id in (75) 
and bh.previous_status = 3 
and assigned_to_office_id = next_status_assigned_to_office /* SSM CALL CENTER */ 
group by bh.assigned_to_position, bh.assigned_to_id		


select count(1) from grievance_lifecycle gl 
inner join (
	select forwarded_latest_3_bh_mat.grievance_id 
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
)xx on xx.grievance_id = gl.grievance_id ;



select 
	forwarded_latest_3_bh_mat.assigned_to_position as assigned_to_position,
	forwarded_latest_3_bh_mat.assigned_to_id as assigned_to_id,
	 count(1) as assigned
from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id
union all




select 
	forwarded_latest_3_bh_mat.assigned_to_position as assigned_to_position,
	forwarded_latest_3_bh_mat.assigned_to_id as assigned_to_id,
	 count(1) as assigned
from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
--inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id




select 
--	bh.next_status_assigned_to_position as assigned_to_position,
--	bh.next_status_assigned_to_id as assigned_to_id,
bh.assigned_to_position,
bh.assigned_to_id ,
	 count(1) as assigned,
--	 bh.grievance_id,
	 bh.assigned_to_office_id
from  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
where bh.assigned_to_office_id in (75) 
and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
and bh.previous_status = 3 
and next_status IN (4, 7) 
and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office 
--group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id	, bh.previous_status , bh.assigned_to_office_id, 
group by bh.assigned_to_position, bh.assigned_to_id	, bh.previous_status , bh.assigned_to_office_id/*, bh.grievance_id*/





select 
	bh.next_status_assigned_to_position as assigned_to_position,
	bh.next_status_assigned_to_id as assigned_to_id,
	 count(1) as assigned
from forwarded_latest_3_4_bh_mat_2 as bh
inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
where bh.assigned_to_office_id in (75)
and not exists (select 
	forwarded_latest_3_bh_mat.assigned_to_position as assigned_to_position,
	forwarded_latest_3_bh_mat.assigned_to_id as assigned_to_id,
	 count(1) as assigned
from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id)
--and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
and bh.previous_status = 3 
and next_status IN (4, 7)
and bh.assigned_to_office_id = forwarded_latest_3_bh_mat.assigned_to_office_id 
and bh.assigned_to_office_id = bh.next_status_assigned_to_office 
/* SSM CALL CENTER */ 
group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id	;






select
	count(1) -- forwarded_latest_3_bh_mat.grievance_id
from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)   ;


select count(1)
from (
	select 
		forwarded_latest_3_bh_mat.grievance_id 
	from  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
	inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
	where bh.assigned_to_office_id in (75) 
	and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
	and bh.previous_status = 3 
	and next_status IN (4, 7) 
	and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
) XX
left join (
	select 
		forwarded_latest_3_bh_mat.grievance_id
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
)YY on XX.grievance_id  = YY.grievance_id 
where YY.grievance_id is not null;


------- Perfect Query For first step -----------
---- Not Assigned Grievance Till date ---
select count(distinct XX.grievance_id ) as not_assigned
from (
	select 
		forwarded_latest_3_bh_mat.grievance_id
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
) XX
left join (
	select 
		forwarded_latest_3_bh_mat.grievance_id 
	from  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
	inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
	where bh.assigned_to_office_id in (75) 
	and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
	and bh.previous_status = 3 
	and next_status IN (4, 7) 
	and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
)YY on XX.grievance_id  = YY.grievance_id 
where YY.grievance_id is null
union all
--- Assigne to the perticular department grievances ----
select
	count(distinct forwarded_latest_3_bh_mat.grievance_id) 
from  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
where bh.assigned_to_office_id in (75) 
and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
and bh.previous_status = 3 
and next_status IN (4, 7) 
and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office

=51144 + 699



select 
	count(distinct XX.grievance_id ) as not_assigned,
	yy.assigned_to_id,
	yy.assigned_to_position 
from (
	select 
		forwarded_latest_3_bh_mat.grievance_id
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
) XX
left join (
	select 
		bh.next_status_assigned_to_position as assigned_to_position,
		bh.next_status_assigned_to_id as assigned_to_id,
		forwarded_latest_3_bh_mat.grievance_id 
	from  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
	inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
	where bh.assigned_to_office_id in (75) 
	and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
	and bh.previous_status = 3 
	and next_status IN (4, 7) 
	and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
)YY on XX.grievance_id  = YY.grievance_id 
where YY.grievance_id is null
group by yy.assigned_to_id, yy.assigned_to_position 








select
--	bh.next_status_assigned_to_position as assigned_to_position,
--	bh.next_status_assigned_to_id as assigned_to_id,
--	count(distinct forwarded_latest_3_bh_mat.grievance_id) as total_assigned
	distinct forwarded_latest_3_bh_mat.grievance_id
from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
where bh.assigned_to_office_id in (75) 
--and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
and bh.previous_status = 3 
and bh.next_status IN (4, 7) 
and bh.next_status_assigned_to_position = 11119
and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
group by forwarded_latest_3_bh_mat.grievance_id
--group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id







SELECT 
    fl3.assigned_to_position,
    fl3.assigned_to_id,
--    COUNT(*) AS assigned
    fl3.grievance_id 
FROM forwarded_latest_3_bh_mat_2 fl3
WHERE fl3.assigned_to_office_id = 75
  AND not EXISTS (
        SELECT 1
        FROM forwarded_latest_3_4_bh_mat_2 bh
        WHERE bh.grievance_id = fl3.grievance_id
          AND bh.previous_status = 3
          AND bh.next_status IN (4, 7)
          AND bh.assigned_to_office_id = fl3.assigned_to_office_id
          AND bh.assigned_to_office_id = bh.next_status_assigned_to_office
  )
GROUP BY fl3.assigned_to_position, fl3.assigned_to_id, fl3.grievance_id 
ORDER BY fl3.assigned_to_position, fl3.assigned_to_id;





select 
--	md.assigned_to_position,
--	md.assigned_to_id,
--	count(1) as yet_to_assigned
	md.grievance_id 
from master_district_block_grv md
where md.grievance_id > 0
and md.status in (4) 
and md.assigned_to_office_id = 75 and md.assigned_to_position = 11119
group by md.grievance_id
--group by md.assigned_to_position, md.assigned_to_id





-- ========================= Grievance At My Office =======================

--------- Updated part 2 ----------

with griev_forwarded as (
	select 
		forwarded_latest_3_bh_mat.assigned_to_position as assigned_to_position,
		forwarded_latest_3_bh_mat.assigned_to_id as assigned_to_id,
		 count(1) as assigned
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
	group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id
	union all
	select
		bh.next_status_assigned_to_position as assigned_to_position,
		bh.next_status_assigned_to_id as assigned_to_id,
		count(distinct forwarded_latest_3_bh_mat.grievance_id) as total_assigned
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
	inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
	where bh.assigned_to_office_id in (75) 
	--and forwarded_latest_3_bh_mat.assigned_to_office_id in (75) 
	and bh.previous_status = 3 
	and next_status IN (4, 7) 
	and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
	group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id
), griev_yet_to_assigned as (
		select 
			md.assigned_to_position,
			md.assigned_to_id,
			count(1) as yet_to_assigned
		from master_district_block_grv md
		where md.grievance_id > 0
		and md.status in (4) 
		and md.assigned_to_office_id = 75 /*and md.assigned_to_position = 76*/
		group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
		select 
--			'Admin & Nodal' as role,
			forwarded_latest_3_bh_mat.assigned_to_position as assigned_to_position,
			forwarded_latest_3_bh_mat.assigned_to_id as assigned_to_id,
			forwarded_latest_3_bh_mat.assigned_to_office_id,
			count(1) as atr_submitted
		from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		inner join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
		left join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_id
		where atr_latest_14_bh_mat.assigned_by_office_id in (75) /* SSM CALL CENTER */ 
		group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, forwarded_latest_3_bh_mat.assigned_to_office_id
		
--			union all
		
		select 
--			'Nodal' as role,
--			forwarded_latest_4_bh_mat.assigned_to_position as assigned_to_position,
--			forwarded_latest_4_bh_mat.assigned_to_id as assigned_to_id,
--			forwarded_latest_4_bh_mat.assigned_to_office_id,
--			atr_latest_4_11_bh_mat.assigned_by_position,
--			atr_latest_4_11_bh_mat.assigned_by_id,
--			atr_latest_4_11_bh_mat.assigned_by_office_id,
--			count(1) as atr_submitted
			forwarded_latest_4_bh_mat.grievance_id 
		from forwarded_latest_4_bh_mat_2 as forwarded_latest_4_bh_mat
		inner join atr_latest_4_11_bh_mat_2 as atr_latest_4_11_bh_mat on atr_latest_4_11_bh_mat.grievance_id = forwarded_latest_4_bh_mat.grievance_id /*and atr_latest_4_11_bh_mat.current_status in (14,15)*/
		left join admin_position_master apm on apm.position_id = forwarded_latest_4_bh_mat.assigned_to_id
		left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id 
		where forwarded_latest_4_bh_mat.assigned_to_office_id in (75) and aurm.role_master_id in (6)  /* SSM CALL CENTER */ 
		and forwarded_latest_4_bh_mat.assigned_to_id != atr_latest_4_11_bh_mat.assigned_by_id 
--		group by forwarded_latest_4_bh_mat.assigned_to_position, forwarded_latest_4_bh_mat.assigned_to_id, forwarded_latest_4_bh_mat.assigned_to_office_id
--		,atr_latest_4_11_bh_mat.assigned_by_position, atr_latest_4_11_bh_mat.assigned_by_id, atr_latest_4_11_bh_mat.assigned_by_office_id
--			
--			
--		select 
----			'Restricted' as role,
--			md.assigned_to_position as assigned_to_position,
--			md.assigned_to_id as assigned_to_id,
--			md.assigned_to_office_id,
--    		count(1) as atr_submitted
--	    from master_district_block_grv md
--	    left join admin_position_master apm on apm.position_id = md.assigned_to_position
--	    left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
--	    where md.status in (11) and md.assigned_to_office_id = 75 and aurm.role_master_id in (4,5)
--	    group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id


--		select
--			bh.assigned_to_position as assigned_to_position,
--			bh.assigned_to_id as assigned_to_id,
--			count(distinct forwarded_latest_3_bh_mat.grievance_id) as atr_submitted
--		from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
--		inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
--		left join admin_position_master apm on apm.position_id = bh.assigned_to_position
--	    left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
--		where bh.assigned_to_office_id in (75) /*and aurm.role_master_id in (4,5)*/
--		and bh.previous_status = 4
--		and next_status IN (11) 
--		and bh.assigned_to_office_id  = bh.next_status_assigned_to_office
--		group by bh.assigned_to_position, bh.assigned_to_id
)/*, atr_yet_to_sent as (
		select 
			forwarded_latest_3_bh_mat.assigned_to_position,
			forwarded_latest_3_bh_mat.assigned_to_id,
			 count(1) as yet_atr_not_submitted
		from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
        and not exists ( select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)) /* SSM CALL CENTER */ 
		group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id
)	*/
	select 
--		coalesce(atr_sent.role, 'N/A') as roleee,
--		case 
--			when admin_position_master.role_master_id in (4) then admin_user_role_master.role_master_name
--			when admin_position_master.role_master_id in (5) then admin_user_role_master.role_master_name
--			when admin_position_master.role_master_id in (6) then admin_user_role_master.role_master_name
--			else 'N/A'
--		end as admin_role,
		admin_position_master.record_status,
		case when admin_user_details.official_name is not null then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_designation_of_the_user,
		case when admin_position_master.office_id in (75) then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
            else cmo_office_master.office_name
        end as office_of_the_user,
        coalesce(griev_forwarded.assigned, 0) as grievance_asssigned,
        coalesce(griev_yet_to_assigned.yet_to_assigned, 0) as grievance_yet_to_assigned,
        sum(coalesce(griev_forwarded.assigned, 0) + coalesce(griev_yet_to_assigned.yet_to_assigned, 0)) as grievance_total,
        coalesce(atr_sent.atr_submitted, 0) as atr_sent
--        atr_yet_to_sent.yet_atr_not_submitted as atr_not_submitted,
--        sum(atr_sent.atr_submitted + atr_yet_to_sent.yet_atr_not_submitted) as atr_total
	from griev_forwarded
	left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = griev_forwarded.assigned_to_id
	left join atr_sent on atr_sent.assigned_to_id = griev_forwarded.assigned_to_id
--	left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_forwarded.assigned_to_id
    left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
	left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
    left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
	group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name, 
	cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted/*, 
	atr_yet_to_sent.yet_atr_not_submitted*/,admin_position_master.record_status,admin_position_master.role_master_id
	 
	
	
	
------- Updated part 1 ----------
with griev_forwarded as (
		select 
			forwarded_latest_3_bh_mat.assigned_to_position,
			forwarded_latest_3_bh_mat.assigned_to_id,
			 count(1) as assigned
		from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
		group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id
), griev_yet_to_assigned as (
		select 
			md.assigned_to_position,
			md.assigned_to_id,
			count(1) as yet_to_assigned
		from master_district_block_grv md
		where md.grievance_id > 0
		and md.status in (4) 
		and md.assigned_to_office_id = 75 /*and md.assigned_to_position = 76*/
		group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
		select 
--			'Admin & Nodal' as role,
			forwarded_latest_3_bh_mat.assigned_to_position,
			forwarded_latest_3_bh_mat.assigned_to_id,
			forwarded_latest_3_bh_mat.assigned_to_office_id,
			count(1) as atr_submitted
		from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		inner join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
		left join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_id
		where atr_latest_14_bh_mat.assigned_by_office_id in (75) /* SSM CALL CENTER */ 
		group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, forwarded_latest_3_bh_mat.assigned_to_office_id
			union all
		select 
--			'Restricted' as role,
			md.assigned_to_position,
			md.assigned_to_id,
			md.assigned_to_office_id,
    		count(1) as atr_submitted
	    from master_district_block_grv md
	    left join admin_position_master apm on apm.position_id = md.assigned_to_position
	    left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
	    where md.status in (11) and md.assigned_to_office_id = 75 and aurm.role_master_id in (4,5)
	    group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id
), atr_yet_to_sent as (
		select 
			forwarded_latest_3_bh_mat.assigned_to_position,
			forwarded_latest_3_bh_mat.assigned_to_id,
			 count(1) as yet_atr_not_submitted
		from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
        and not exists ( select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)) /* SSM CALL CENTER */ 
		group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id
)	
	select 
--		coalesce(atr_sent.role, 'N/A') as roleee,
		case 
			when admin_position_master.role_master_id in (4) then admin_user_role_master.role_master_name
			when admin_position_master.role_master_id in (5) then admin_user_role_master.role_master_name
			when admin_position_master.role_master_id in (6) then admin_user_role_master.role_master_name
			else 'N/A'
		end as admin_role,
		admin_position_master.record_status,
		case when admin_user_details.official_name is not null then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_designation_of_the_user,
		case when admin_position_master.office_id in (75) then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
            else cmo_office_master.office_name
        end as office_of_the_user,
        griev_forwarded.assigned as grievance_asssigned,
        griev_yet_to_assigned.yet_to_assigned as grievance_yet_to_assigned,
        sum(griev_forwarded.assigned + griev_yet_to_assigned.yet_to_assigned) as grievance_total,
        atr_sent.atr_submitted as atr_sent,
        atr_yet_to_sent.yet_atr_not_submitted as atr_not_submitted,
        sum(atr_sent.atr_submitted + atr_yet_to_sent.yet_atr_not_submitted) as atr_total
	from griev_forwarded
	left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = griev_forwarded.assigned_to_id
	left join atr_sent on atr_sent.assigned_to_id = griev_forwarded.assigned_to_id
	left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_forwarded.assigned_to_id
    left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
	left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
    left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
	group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name, 
	cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted, 
	atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id	

	
	
	
	
	
	
with griev_forwarded as (
	select 
		forwarded_latest_3_bh_mat.assigned_to_position,
		forwarded_latest_3_bh_mat.assigned_to_id,
		 count(1) as assigned
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER *//* and grievance_master_bh_mat.status in (3,4,7,8)*/
	group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id
), griev_yet_to_assigned as (
	select 
		md.assigned_to_position,
		md.assigned_to_id,
		count(1) as yet_to_assigned
	from master_district_block_grv md
	where md.grievance_id > 0
	and md.status in (4) 
	and md.assigned_to_office_id = 75 /*and md.assigned_to_position = 76*/
	group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
	select 
--			'Admin & Nodal' as role,
		forwarded_latest_3_bh_mat.assigned_to_position,
		forwarded_latest_3_bh_mat.assigned_to_id,
		forwarded_latest_3_bh_mat.assigned_to_office_id,
		count(1) as atr_submitted
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
	inner join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
	left join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_id
	where atr_latest_14_bh_mat.assigned_by_office_id in (75) /* SSM CALL CENTER */ 
	group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, forwarded_latest_3_bh_mat.assigned_to_office_id
		union all
	select 
--			'Restricted' as role,
		md.assigned_to_position,
		md.assigned_to_id,
		md.assigned_to_office_id,
		count(1) as atr_submitted
    from master_district_block_grv md
    left join admin_position_master apm on apm.position_id = md.assigned_to_position
    left join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
    where md.status in (11) and md.assigned_to_office_id = 75 and aurm.role_master_id in (4,5)
    group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id
), atr_yet_to_sent as (
	select 
		forwarded_latest_3_bh_mat.assigned_to_position,
		forwarded_latest_3_bh_mat.assigned_to_id,
		 count(1) as yet_atr_not_submitted
	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
    and not exists ( select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)) /* SSM CALL CENTER */ 
	group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id
)	
	select 
		case 
			when admin_position_master.role_master_id in (4) then admin_user_role_master.role_master_name
			when admin_position_master.role_master_id in (5) then admin_user_role_master.role_master_name
			when admin_position_master.role_master_id in (6) then admin_user_role_master.role_master_name
			else 'N/A'
		end as admin_role,
		admin_position_master.record_status,
		case when admin_user_details.official_name is not null then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_designation_of_the_user,
		case when admin_position_master.office_id in (75) then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
            else cmo_office_master.office_name
        end as office_of_the_user,
        coalesce(griev_forwarded.assigned, 0) as grievance_asssigned,
        coalesce(griev_yet_to_assigned.yet_to_assigned, 0) as grievance_yet_to_assigned,
        coalesce(sum(griev_forwarded.assigned + griev_yet_to_assigned.yet_to_assigned), 0) as grievance_total,
        coalesce(atr_sent.atr_submitted, 0) as atr_sent,
        coalesce(atr_yet_to_sent.yet_atr_not_submitted, 0) as atr_not_submitted,
        coalesce(sum(atr_sent.atr_submitted + atr_yet_to_sent.yet_atr_not_submitted), 0) as atr_total
	from griev_yet_to_assigned
	left join admin_user_details on griev_yet_to_assigned.assigned_to_id = admin_user_details.admin_user_id
    left join admin_position_master on griev_yet_to_assigned.assigned_to_position = admin_position_master.position_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id 
    left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
	left join griev_forwarded on griev_forwarded.assigned_to_id = griev_yet_to_assigned.assigned_to_id and griev_forwarded.assigned_to_position = griev_yet_to_assigned.assigned_to_position
	left join atr_sent on atr_sent.assigned_to_id = griev_yet_to_assigned.assigned_to_id and griev_yet_to_assigned.assigned_to_position = atr_sent.assigned_to_position
	left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_yet_to_assigned.assigned_to_id and griev_yet_to_assigned.assigned_to_position = atr_yet_to_sent.assigned_to_position
	group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name, 
	cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted, 
	atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id, griev_forwarded.assigned
	order by admin_role asc;
	

	
	case when admin_position_master.office_id in (75) /*REPLACE*/ then 1 else 2 end as "type",
                sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as "pending_grievances",
                sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
--                sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
--                case when admin_position_master.office_id in (75) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
--                        else null::int
--                end as "atr_auto_returned_from_cmo",
                count(1) as total_count
            from raw_data
            left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id
            left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
            left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
            left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
            left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
            left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
            where raw_data.status not in (3,16)
	
	
	
	
	SELECT
            '2025-10-07 16:30:01.818299+00:00'::timestamp as refresh_time_utc,
                        COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS unassigned_grievance,
                        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS unassigned_atr
                    FROM grievance_master_bh_mat_2 as gm
                ;
	
	
with fwd_Count as (
    select bh.assigned_by_id , bh.assigned_by_position, count(1) as griv_fwd
        from forwarded_latest_3_bh_mat_2 as bh
        where 1 = 1
    group by bh.assigned_by_id, bh.assigned_by_position
), new_pending as (
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
) select
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

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	----- ATR RECIVED From Restricted User --------
	select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 1227) and gm.status in (11);
	
	
	
	/* TAB_ID: 2B2 | TBL: ATR Received from Restricted User/HoSO >> Role: 5 Ofc: 35 | G_Codes: ('GM011') */
    select 
    	count(1) as restricted_user
    from master_district_block_grv md
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    where md.status in (11) and md.assigned_to_office_id = 35 and aurm.role_master_id in (4,5)
--        and md.assigned_to_position = 3897
	--------------------------------------------------------------------------------------
	
	
	
	
	
	
	
	
	
	
select * from grievance_master gm where gm.status = 3 limit 10;
select * from admin_position_master apm where apm.position_id = 12133;
select * from admin_user_position_mapping aupm where aupm.position_id = 11650;
select * from admin_user_position_mapping aupm where aupm.admin_user_id = 10988;
select * from admin_user_details aud where aud.admin_user_id = 11435;
select * from cmo_office_master com where com.office_id = 53;
select * from admin_position_master apm where apm.role_master_id in (6) and apm.office_id = 35 and apm.record_status = 1;
	
	 
	 select *
  from master_district_block_grv md
    where md.grievance_id > 0
        and md.status in (4) and md.assigned_to_office_id = 75
        and md.assigned_to_position = 76
        and replace(lower(md.emergency_flag),' ','') like '%n%'  	 
	 
	 
        
        
        
   ----- Act on Grievance My Basket ----     
select *
    from master_district_block_grv md
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
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
    where md.grievance_id > 0
        and md.status in (4) and md.assigned_to_office_id = 75
        and md.assigned_to_position = 76
        and replace(lower(md.emergency_flag),' ','') like '%n%'
	 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
	 
with fwd_union_data as (		
    select 
        recev_cmo_othod.grievance_id, recev_cmo_othod.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on, forwarded_latest_3_bh_mat.assigned_by_office_id
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
--                union
--            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
--                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
--            where forwarded_latest_5_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
            ) as recev_cmo_othod
            where 1=1 and recev_cmo_othod.assigned_by_office_id in (75) 
),  fwd_atr as (
        select 
            count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.assigned_by_office_id
            from fwd_union_data
            group by fwd_union_data.assigned_by_office_id
),
	 






with raw_data as (
    select grievance_master_bh_mat.*
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
        and not exists (
            select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
                where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                    and atr_latest_14_bh_mat.current_status in (14,15)
                )
	 
	 
	 
	 
	 
	 
----- Received From CMO ------	 
with raw_data as (
    select grievance_master_bh_mat.*
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
        and not exists (
            select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
                where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                    and atr_latest_14_bh_mat.current_status in (14,15)
                )
    ), user_wise_pndcy as (
        select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_role, xx.user_status, xx.status_id::text, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review,
            xx.atr_auto_returned_from_cmo, xx.total_count
        from (
            select 'User wise ATR Pendency' as status,
                -- admin_user_details.official_name as name_and_esignation_of_the_user,
                case when admin_user_details.official_name is not null
                        then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
                    else null
                end as name_and_esignation_of_the_user,
                -- cmo_office_master.office_name as office,
                case
                    when cmo_sub_office_master.suboffice_name is not null
                        then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
                    else cmo_office_master.office_name
                end as office,
                case when admin_position_master.office_id in (75) /*REPLACE*/
                        then admin_user_role_master.role_master_name
                    else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
                end as user_role,
                admin_position_master.record_status as status_id,
                case
                    when admin_position_master.record_status = 1 then 'Active'
                    when admin_position_master.record_status = 2 then 'Inactive'
                    else null
                end as user_status,
                case when admin_position_master.office_id in (75) /*REPLACE*/ then 1 else 2 end as "type",
                sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as "pending_grievances",
                sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
--                sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
--                case when admin_position_master.office_id in (75) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
--                        else null::int
--                end as "atr_auto_returned_from_cmo",
                count(1) as total_count
            from raw_data
            left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id
            left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
            left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
            left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
            left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
            left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
            where raw_data.status not in (3,16)
            group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name, admin_user_role_master.role_master_id,
            admin_user_role_master.role_master_name, cmo_designation_master.designation_name, cmo_sub_office_master.suboffice_name, admin_position_master.record_status
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
        '2025-10-05 16:30:01.602693+00:00'::timestamp as refresh_time_utc,
        '2025-10-05 16:30:01.602693+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        *
    from union_part

	 
    
  ---- Recevied from Other HOD ----
with raw_data as (
    select grievance_master_bh_mat.*
        from forwarded_latest_5_bh_mat_2 as bh
        inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
        where bh.assigned_to_office_id in (75)
            and not exists ( select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id )
), unassigned_cmo as (
    select
        'Unassigned (CMO)' as status,
        'N/A' as name_and_esignation_of_the_user,
        'N/A' as office,
        'N/A' as user_role,
        'N/A' as user_status,
        'N/A' as status_id,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
), unassigned_other_hod as (
    select
        'Unassigned (Other HoD)' as status,
        'N/A' as name_and_esignation_of_the_user,
        'N/A' as office,
        'N/A' as user_role,
        'N/A' as user_status,
        'N/A' as status_id,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
        from raw_data
        where raw_data.status = 5
), recalled as (
    select
        'Recalled' as status,
        'N/A' as name_and_esignation_of_the_user,
        'N/A' as office,
        'N/A' as user_role,
        'N/A' as user_status,
        'N/A' as status_id,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
), user_wise_pndcy as (
    select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_role, xx.user_status, xx.status_id::text, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review,
        xx.atr_auto_returned_from_cmo, xx.total_count
    from (
        select 'User wise ATR Pendency' as status,
            case when admin_user_details.official_name is not null
                    then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
                else null
            end as name_and_esignation_of_the_user,
            case
                when cmo_sub_office_master.suboffice_name is not null
                    then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
                else cmo_office_master.office_name
            end as office,
            case when admin_position_master.office_id in (75) /*REPLACE*/ then admin_user_role_master.role_master_name
                    else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
            end as user_role,
            admin_position_master.record_status as status_id,
            case
                when admin_position_master.record_status = 1 then 'Active'
                when admin_position_master.record_status = 2 then 'Inactive'
                else null
            end as user_status,
            case when admin_position_master.office_id in (75) /*REPLACE*/ then 1 else 2 end as "type",
            sum(case when raw_data.status in (4,7,8,8888) then 1 else 0 end) as "pending_grievances",
            sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
            sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
            case when admin_position_master.office_id in (75) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
                    else null::int
            end as "atr_auto_returned_from_cmo",
            count(1) as total_count
        from raw_data
        left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id
        left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
        left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
        where raw_data.status != 5
        group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name,
                admin_user_role_master.role_master_id, admin_user_role_master.role_master_name, cmo_designation_master.designation_name,
                cmo_sub_office_master.suboffice_name, admin_position_master.record_status
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
    '2025-10-05 16:30:01.602693+00:00'::timestamp as refresh_time_utc,
    '2025-10-05 16:30:01.602693+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    *
from union_part

 -- ==============================================================================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ====================================================================================================== FINAL =================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==============================================================================================================================================================================================================================
	 
    
    
    
    
    
-- ==============================================================================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ====================================================================================================== TESTING ===============================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==============================================================================================================================================================================================================================

	 
	 
	 
