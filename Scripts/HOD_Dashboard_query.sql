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
----------------------- HOD dashboard ------>>>>>> Grievnace and ATRs Status of My Sub-Office -----------------------------------------
with fwd_union_data as (		
	select 
		admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_to_position, 
	admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, com.office_name,
    aurm.role_master_name, admin_position_master.position_id
        from
            (
              select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                  from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
               where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
                union
              select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                 from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
               where forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
            ) as recev_cmo_othod
        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
        left join admin_user_position_mapping on admin_user_position_mapping.position_id = admin_position_master.position_id 
        left join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
        left join admin_user_details on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
        left join cmo_office_master com on com.office_id = admin_position_master.office_id
        where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (35) and admin_position_master.office_id is not null /*and admin_position_master.role_master_id in (7,8) and 
    admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1*/ 
	), fwd_atr as (
        select fwd_union_data.sub_office_id, count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.assigned_to_position as position, fwd_union_data.official_name, 
        fwd_union_data.official_phone, fwd_union_data.office_id, fwd_union_data.role_master_name, fwd_union_data.position_id, fwd_union_data.office_name
        from fwd_union_data
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_to_position, fwd_union_data.official_name, fwd_union_data.office_name,
        fwd_union_data.official_phone, fwd_union_data.office_id, fwd_union_data.role_master_name, fwd_union_data.position_id
     ), atr_recv as (
	        select fwd_union_data.sub_office_id, count(fwd_union_data.grievance_id) as atr_received
	        	from fwd_union_data
	        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
	        where atr_latest_11_bh_mat.assigned_to_office_id in (35)
	        group by fwd_union_data.sub_office_id
	  ), pnd as (
			    select
	                admin_position_master.sub_office_id, count(1) as pending, ba.days_diff as resolved_days_difference,
	                sum(case when (ba.days_diff > 7) then 1 else 0 end) as more_7_days
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
	        group by admin_position_master.sub_office_id, ba.days_diff
     ), pend as (		
			select 
				admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_to_position, 
			admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, com.office_name,
		    aurm.role_master_name, admin_position_master.position_id, count(1) as atrpending
	        from
	            (
	              select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
	                  from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	               where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
	                union
	              select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
	                 from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
	               where forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
	            ) as recev_cmo_othod
	        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = recev_cmo_othod.grievance_id
	        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
	        left join admin_user_position_mapping on admin_user_position_mapping.position_id = admin_position_master.position_id 
	        left join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
	        left join admin_user_details on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
	        left join cmo_office_master com on com.office_id = admin_position_master.office_id
	        where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (35) and admin_position_master.office_id is not null 
	        and not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm WHERE recev_cmo_othod.grievance_id = bm.grievance_id)
	        group by admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_to_position, 
			admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, com.office_name,
		    aurm.role_master_name, admin_position_master.position_id
	)
     select
       '2025-08-21 16:30:01.231162+00:00':: timestamp as refresh_time_utc,
       '2025-08-21 16:30:01.231162+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
       coalesce(cmo_sub_office_master.suboffice_name,'N/A') as Sub_office_name,
       coalesce(cmo_sub_office_master.suboffice_id, 0) as sub_office_id,
       coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
       coalesce(atr_recv.atr_received, 0) AS atr_received,
       coalesce(fwd_atr.position, 0) AS position,
       coalesce(fwd_atr.official_name) AS official_name,
       coalesce(fwd_atr.official_phone) AS official_phone,
       coalesce(fwd_atr.office_id, 0) AS office_id,
       coalesce(fwd_atr.role_master_name) AS assigned_role_name,
       coalesce(fwd_atr.position_id, 0) AS position_id,
       coalesce(fwd_atr.office_name) AS office_name,
       coalesce(pnd.more_7_days, 0) AS more_7_days,
       coalesce(pnd.pending, 0) AS atr_pending,
--       coalesce(pend.atrpending, 0) AS atrpending,
       coalesce(pnd.resolved_days_difference, 0) AS resolved_days_difference,
--       AVG(pnd.resolved_days_difference) OVER () AS avg_resolved_days_difference
       AVG(COALESCE(pnd.resolved_days_difference, 0))::numeric(10,2) AS avg_resolved_days_difference
        from fwd_atr
        left join atr_recv on fwd_atr.sub_office_id = atr_recv.sub_office_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
        left join pnd on fwd_atr.sub_office_id = pnd.sub_office_id
        left join pend on fwd_atr.sub_office_id = pend.sub_office_id
        where 1=1
        group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, fwd_atr.forwarded, atr_recv.atr_received, fwd_atr.position, fwd_atr.official_name, fwd_atr.official_phone, 
        fwd_atr.office_id, fwd_atr.role_master_name, fwd_atr.position_id, fwd_atr.office_name, pnd.more_7_days, pnd.pending, pnd.resolved_days_difference
        order by cmo_sub_office_master.suboffice_name


     
        
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
