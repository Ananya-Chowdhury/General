select count(1) as griev_count ---------------->>> Nodal
        from grievance_master gm
        left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
        left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
        where gm.grievance_id > 0  and (gm.assigned_to_office_id = 58) and gm.status in (11,13,6);

select count(1) as griev_count
from grievance_master gm
left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (6);


select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (11);


select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (13);



select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_office_id = 58) and apm.role_master_id = 4 and gm.status in (6,11,13);   ----- ATR Submitted to HOD
-----------------------------------------------------------------------------------------------------------------------------------------------------------


select * from admin_user_role_master aurm;
select * from cmo_office_master com where com.office_id = 58;




--------------------------------------------

select count(1) as griev_count 
    from grievance_master gm 
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and (gm.assigned_to_office_id = 58) and gm.status in (11,13,6) and ;




select  atr_type, atr_proposed_date, action_taken_note, gl.atn_id,
    catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
    prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
    gl.assigned_on, gl.assigned_by_id, gl.assign_comment,
    gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position,
    gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
from grievance_lifecycle gl
left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id
where gl.atn_id is not null and gl.lifecycle_id  = 64376032;




select
    apm.position_id,
    case
        when
            case
                when com.district_id = 999 then null
                when com.district_id = 99 then null
                else cdm2.district_name
            end is not null then concat(cdm.designation_name,' - ',
                case
                    when com.district_id = 999 then null
                    when com.district_id = 99 then null
                    else cdm2.district_name
                end,' - ',aurm.role_master_name)
        else concat(cdm.designation_name,' - ',aurm.role_master_name)
    end as position_name,
    apm.user_type,
    apm.role_master_id,
    apm.designation_id,
    apm.office_type,
    apm.office_category,
    apm.office_id,
    apm.sub_office_id,
    case
        when apm.sub_office_id is null then com.office_category
        else csom.office_category
    end as office_category_id,
    apm.record_status,
    cdlm3.domain_value as record_status_name,
    apm.phone_no,
    apm.created_by,
    apm.created_on + interval '5 hour 30 Minutes' as created_on,
    apm.updated_by,
    apm.updated_on + interval '5 hour 30 Minutes' as updated_on,
    aurm.role_master_name,
    aurm.role_code,
    com.office_name,
    cdlm.domain_value as office_category_name,
    cdlm2.domain_value as office_type_name,
    case
        when apm.sub_office_id is null then 'N/A'
        else csom.suboffice_name
    end as suboffice_name,
    aupm.admin_user_id,
    aud.official_name,
    cdm.designation_name
from admin_position_master apm
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
left join cmo_office_master com on com.office_id = apm.office_id
inner join cmo_domain_lookup_master cdlm on cdlm.domain_code = com.office_category and cdlm.domain_type = 'office_category'
inner join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = com.office_type and cdlm2.domain_type = 'office_type'
left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
inner join admin_user_position_mapping aupm on aupm.position_id = apm.position_id /*and aupm.status = 1*/
inner join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
inner join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
left join cmo_districts_master cdm2 on cdm2.district_id = com.district_id
inner join cmo_domain_lookup_master cdlm3 on apm.record_status = cdlm3.domain_code and cdlm3.domain_type = 'status'
where
    apm.position_id > 0 and
    case
        when ( select user_type  from admin_position_master where position_id = 10920 ) = 1 then apm.position_id::text like '%%'
            when ( select user_type  from admin_position_master where position_id = 10920 ) = 2 then apm.position_id in
            ( select position_id  from admin_position_master where office_id in
                ( select office_id from admin_position_master where position_id = 10920 ) )
            when ( select user_type  from admin_position_master where position_id = 10920) = 3 then apm.position_id in
                ( select position_id  from admin_position_master where sub_office_id in
                    ( select sub_office_id  from admin_position_master where position_id = 10920 ) )
        end
 order by com.office_name asc
 
 
 
select
apm.position_id,
case
    when
        case
            when com.district_id = 999 then null
            when com.district_id = 99 then null
            else cdm2.district_name
        end is not null then concat(cdm.designation_name,' - ',
            case
                when com.district_id = 999 then null
                when com.district_id = 99 then null
                else cdm2.district_name
            end,' - ',aurm.role_master_name)
    else concat(cdm.designation_name,' - ',aurm.role_master_name)
end as position_name,
apm.user_type,
apm.role_master_id,
apm.designation_id,
apm.office_type,
apm.office_category,
apm.office_id,
apm.sub_office_id,
case
    when apm.sub_office_id is null then com.office_category
    else csom.office_category
end as office_category_id,
apm.record_status,
cdlm3.domain_value as record_status_name,
apm.phone_no,
apm.created_by,
apm.created_on + interval '5 hour 30 Minutes' as created_on,
apm.updated_by,
apm.updated_on + interval '5 hour 30 Minutes' as updated_on,
aurm.role_master_name,
aurm.role_code,
com.office_name,
cdlm.domain_value as office_category_name,
cdlm2.domain_value as office_type_name,
case
    when apm.sub_office_id is null then 'N/A'
        else csom.suboffice_name
    end as suboffice_name,
    aupm.admin_user_id,
    aud.official_name,
    cdm.designation_name
from admin_position_master apm
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
left join cmo_office_master com on com.office_id = apm.office_id
inner join cmo_domain_lookup_master cdlm on cdlm.domain_code = com.office_category and cdlm.domain_type = 'office_category'
inner join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = com.office_type and cdlm2.domain_type = 'office_type'
left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
inner join admin_user_position_mapping aupm on aupm.position_id = apm.position_id /*and aupm.status = 1*/
inner join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
inner join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
left join cmo_districts_master cdm2 on cdm2.district_id = com.district_id
inner join cmo_domain_lookup_master cdlm3 on apm.record_status = cdlm3.domain_code and cdlm3.domain_type = 'status'
where
    apm.position_id > 0 and
    case
        when ( select user_type  from admin_position_master where position_id = 10920 ) = 1 then apm.position_id::text like '%%'
            when ( select user_type  from admin_position_master where position_id = 10920 ) = 2 then apm.position_id in
            ( select position_id  from admin_position_master where office_id in
                ( select office_id from admin_position_master where position_id = 10920 ) )
            when ( select user_type  from admin_position_master where position_id = 10920) = 3 then apm.position_id in
                ( select position_id  from admin_position_master where sub_office_id in
                    ( select sub_office_id  from admin_position_master where position_id = 10920 ) )
        end
 and (replace(lower(aurm.role_master_name),' ','') like '%mufti%' 
 	or  replace(lower(com.office_name),' ','') like '%mufti%' 
 		or replace(lower(csom.suboffice_name),' ','') like '%mufti%' 
 			or replace(lower(aud.official_name),' ','') like '%mufti%' 
 				or replace(lower(aud.official_phone),' ','') like '%mufti%') 
 order by com.office_name asc

 
 
 
 
 
 
 
 
 
 
 --=====================================================================
 
 
 WITH batch_summary AS (
    SELECT 
        cbrd.batch_date::date,
        COUNT(cbrd.batch_id) AS batchs,
        COUNT(*) FILTER (WHERE cbrd.status = 'S') AS success_pull_count,
        COUNT(*) FILTER (WHERE cbrd.status = 'F') AS failed_pull_count,
        array_to_string(
            ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
            ','
        ) AS batch_ids,
        SUM(cbrd.data_count) AS total_grievances_pulled
    FROM cmo_batch_run_details cbrd
    LEFT JOIN cmo_batch_time_master cbtm ON cbtm.batch_time_master_id = cbrd.batch_id
    GROUP BY cbrd.batch_date::date
),
status_summary AS (
    SELECT
        cbrd.batch_date::date,
        -- status wise counts
        COUNT(*) FILTER (WHERE cbgli.status = 1) AS initiate_count,
        COUNT(*) FILTER (WHERE cbgli.status = 2) AS success_count,
        COUNT(*) FILTER (WHERE cbgli.status = 3) AS failed_count,
        COUNT(*) FILTER (WHERE cbgli.status = 4) AS rectified_count,
        COUNT(*) FILTER (WHERE cbgli.status = 5) AS duplicate_count,
        -- total count of grievances processed
        COUNT(*) AS total_records,
        -- ✅ success grievances that exist in grievance_master
        COUNT(*) FILTER (WHERE cbgli.status = 2 AND EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id)) AS grievances_success_count,
        -- ❌ failed grievances that do NOT exist in grievance_master
        COUNT(*) FILTER (WHERE cbgli.status = 3 AND NOT EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id)) AS grievances_failed_count
    FROM cmo_batch_run_details cbrd
    INNER JOIN cmo_batch_grievance_line_item cbgli ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    GROUP BY cbrd.batch_date::date  
),
pending_batches_summary AS (
    SELECT
        a.batch_date,
        cardinality(
            ARRAY(
                SELECT g
                FROM generate_series(1, 96) g
                WHERE g <> ALL (string_to_array(a.batch_ids, ',')::int[])
            )
        ) AS pending_batches
    FROM (
        SELECT 
            cbrd.batch_date::date,
            array_to_string(
                ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
                ','
            ) AS batch_ids
        FROM cmo_batch_run_details cbrd
        WHERE cbrd.status = 'S'
        GROUP BY cbrd.batch_date::date
    ) a
)
SELECT 
    a.batch_date,
    a.batchs AS total_batches_pulled,
    COALESCE(a.success_pull_count, 0) AS success_pull_count,
    COALESCE(a.failed_pull_count, 0) AS failed_pull_count,
    COALESCE(pb.pending_batches, 0) AS pending_batches,
    COALESCE(a.total_grievances_pulled, 0) AS total_grievances_pulled,
    -- ✅ values from modified status_summary
    COALESCE(s.grievances_success_count, 0) AS grievances_success_count,
    COALESCE(s.grievances_failed_count, 0) AS grievances_failed_count,
    COALESCE(s.success_count, 0) AS success_count,
    COALESCE(s.failed_count, 0) AS failed_count,
    COALESCE(s.duplicate_count, 0) AS grievances_duplicate_count,
    COALESCE(s.initiate_count, 0) AS grievances_initiate_count,
    COALESCE(s.rectified_count, 0) AS grievances_rectified_count,
    COALESCE(s.total_records, 0) AS total_records
FROM batch_summary a
LEFT JOIN status_summary s ON a.batch_date = s.batch_date
LEFT JOIN pending_batches_summary pb ON a.batch_date = pb.batch_date
WHERE a.batch_date::date BETWEEN '2024-11-12' AND '2025-10-15'
ORDER BY a.batch_date DESC;




SELECT cbrd.data_count
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-10-14'  -- 2025-09-26, 2025-10-03 not fatched
--WHERE batch_date::date BETWEEN '2024-11-12' AND '2025-10-15'
and status = 'S'
group by cbrd.batch_id, cbrd.data_count
ORDER by batch_id desc;







    SELECT
        cbrd.batch_date::date,
        -- status wise counts
        COUNT(*) FILTER (WHERE cbgli.status = 1) AS initiate_count,
        COUNT(*) FILTER (WHERE cbgli.status = 2) AS success_count,
        COUNT(*) FILTER (WHERE cbgli.status = 3) AS failed_count,
        COUNT(*) FILTER (WHERE cbgli.status = 4) AS rectified_count,
        COUNT(*) FILTER (WHERE cbgli.status = 5) AS duplicate_count,
        -- total count of grievances processed
        COUNT(*) AS total_records,
--        sum(cbrd.data_count) AS total_records,
        count(cbrd.data_count) AS total_grievances_pulled,
        -- ✅ success grievances that exist in grievance_master
        COUNT(*) FILTER (WHERE cbgli.status = 2 AND EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id)) AS grievances_success_count,
        -- ❌ failed grievances that do NOT exist in grievance_master
        COUNT(*) FILTER (WHERE cbgli.status = 3 AND NOT EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id)) AS grievances_failed_count,
        count(*) filter ( where cbgli.status not in (1,2,3,4,5)) as not_in_sts_count,
        count(*) filter ( where cbgli.status in (1,2,3,4,5)) as in_sts_count
    FROM cmo_batch_run_details cbrd
    INNER JOIN cmo_batch_grievance_line_item cbgli ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    where cbrd.batch_date::date BETWEEN '2024-11-12' AND '2025-10-15' 
    GROUP BY cbrd.batch_date::date  

    
    
    
    
    
    
    
    
 --==========================================================================================================================================================   
 ---========== Listing & MIS Report Cheaking... -----===================   
    
    with raw_data as (
                select grievance_master_bh_mat.*
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
                inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                where forwarded_latest_3_bh_mat.assigned_to_office_id in (40)
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
                            case when admin_position_master.office_id in (40) /*REPLACE*/
                                    then admin_user_role_master.role_master_name
                                else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
                            end as user_role,
                            admin_position_master.record_status as status_id,
                            case
                                when admin_position_master.record_status = 1 then 'Active'
                                when admin_position_master.record_status = 2 then 'Inactive'
                                else null
                            end as user_status,
                            case when admin_position_master.office_id in (40) /*REPLACE*/ then 1 else 2 end as "type",
                            sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as "pending_grievances",
                            sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
                            sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
                            case when admin_position_master.office_id in (40) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
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
                    '2025-10-15 16:30:01.247458+00:00'::timestamp as refresh_time_utc,
                    '2025-10-15 16:30:01.247458+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
                    *
                from union_part

                
                
                
                
                
                
 ----- Pending grievance Check By Position           
--        select grievance_master_bh_mat.*
        select count(1)
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
--                inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                inner join master_district_block_grv as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                where forwarded_latest_3_bh_mat.assigned_to_office_id in (40) and forwarded_latest_3_bh_mat.assigned_to_position = 14031
                    and not exists (
                        select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
                            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                                and atr_latest_14_bh_mat.current_status in (14,15)
                            )
                
                            
                            
    
  ---- Penidng Grievance Check By Position                           
   /* TAB_ID: 2A3 | TBL: My Basket >> Role: 6 Ofc: 40 | G_Codes: ('GM004') */
                select count(1)
                    from master_district_block_grv md
                    where md.grievance_id > 0
                        and md.status in (4) and md.assigned_to_office_id = 40
                        and md.assigned_to_position = 14031
                         
                            
                            
                            
                            
                            
                            
                            
                            /* TAB_ID: 2A3 | TBL: My Basket >> Role: 6 Ofc: 40 | G_Codes: ('GM004') */
                WITH lastupdates AS (
                    select grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                ),
                master_district_block_grv_data AS (
                    select distinct
                        md.grievance_id,
                        case
                            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 40 then 0
                            else 1
                        end as received_from_other_hod_flag,
                        case
                            when apm.role_master_id = 6 and apm2.role_master_id in (4,5) and md.status = 11 and (md.current_atr_date is not null or md.action_taken_note is not null or md.atn_id is not null) then 1
                            else 0
                        end as received_from_restricted_flag,
                        lu.grievance_status as last_grievance_status,
                        lu.assigned_on as last_assigned_on,
                        lu.assigned_to_office_id as last_assigned_to_office_id,
                        lu.assigned_by_position as last_assigned_by_position,
                        lu.assigned_to_position as last_assigned_to_position,
                        md.grievance_no,
                        md.grievance_description,
                        md.grievance_source,
                        null as grievance_source_name,
                        md.applicant_name ,
                        md.pri_cont_no,
                        md.grievance_generate_date,
                        md.grievance_category,
                        cgcm.grievance_category_desc,
                        md.assigned_to_office_id,
                        com.office_name,
                        md.district_id,
                        md.district_name ,
                        md.block_id ,
                        md.block_name ,
                        md.municipality_id ,
                        md.municipality_name,
                        case
                            when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
                            when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
                            else null
                        end as block_or_municipalty_name,
                        md.gp_id,
                        md.gp_name,
                        md.ward_id,
                        md.ward_name,
                        case
                            WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
                            WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
                            ELSE NULL
                        end as gp_or_ward_name,
                        md.atn_id,
                        case
                            when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
                            when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
                            ELSE 'N/A'
                        end as atn_desc,
                        md.action_taken_note,
                        coalesce(md.current_atr_date,null) as current_atr_date,
                        md.assigned_to_position,
                        md.assigned_to_id,
                        case
                            when md.assigned_to_position  is null then 'N/A'
                            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )
                        end as assigned_to_name,
                        case
                            when md.status = 1 then md.grievance_generate_date
                            else md.updated_on -- + interval '5 hour 30 Minutes'
                        end as updated_on,
                        md.status,
                        cdlm.domain_value as status_name,
                        cdlm.domain_abbr as grievance_status_code,
                        md.emergency_flag,
                        md.police_station_id,
                        cpsm.ps_name,
                        case
                            when under_processing_ids.grievance_id is not null then 'Y' else 'N'
                        end as is_bulk_processing,
                        md.receipt_mode,
                        md.received_at
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 40
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
                        and md.status in (4) and md.assigned_to_office_id = 40
                        and md.assigned_to_position = 14031
                        and replace(lower(md.emergency_flag),' ','') like '%n%'
                    order by updated_on asc limit 50 offset 0
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;

                            
 ------------------------------------------------------------------------------------------------------------------------
 
select * from cmo_batch_grievance_line_item where griev_id ='SSM4295122'

select * from grievance_master gm where gm.grievance_no ='SSM5308026';
select * from cmo_police_station_master cpsm where cpsm.ps_id = 627;
select * from cmo_police_station_master cpsm where cpsm.ps_code = '0023';




-----------------------------------------------------------------------------------------------------------------------------------

with raw_data as (
                select grievance_master_bh_mat.*
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
                inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                where forwarded_latest_3_bh_mat.assigned_to_office_id in (18)
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
--                        count(1) as total_count
                        grievance_id
                    from raw_data
                    where raw_data.status = 3
                    group by grievance_id
--                ), unassigned_other_hod as (
--                    select
--                        'Unassigned (Other HoD)' as status,
--                        'N/A' as name_and_esignation_of_the_user,
--                        'N/A' as office,
--                        'N/A' as user_role,
--                        'N/A' as user_status,
--                        'N/A' as status_id,
--                        0 as pending_grievances,
--                        null::int as pending_atrs,
--                        null::int as atr_returned_for_review,
--                        null::int as atr_auto_returned_from_cmo,
----                        0 as total_count
--                        grievance_id
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
--                        count(1) as total_count
                        grievance_id 
                    from raw_data
                    where raw_data.status = 16
                    group by grievance_id
                ), user_wise_pndcy as (
                    select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_role, xx.user_status, xx.status_id::text, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review,
                        xx.atr_auto_returned_from_cmo/*, xx.total_count*/ , xx.grievance_id
                    from (
                        select 'User wise ATR Pendency' as status,
                            -- admin_user_details.official_name as name_and_esignation_of_the_user,
                            case when admin_user_details.official_name is not null then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
                                else null
                            end as name_and_esignation_of_the_user,
                            -- cmo_office_master.office_name as office,
                            case
                                when cmo_sub_office_master.suboffice_name is not null then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
                                else cmo_office_master.office_name
                            end as office,
                            case when admin_position_master.office_id in (18) /*REPLACE*/
                                    then admin_user_role_master.role_master_name
                                else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
                            end as user_role,
                            admin_position_master.record_status as status_id,
                            case
                                when admin_position_master.record_status = 1 then 'Active'
                                when admin_position_master.record_status = 2 then 'Inactive'
                                else null
                            end as user_status,
                            case when admin_position_master.office_id in (18) /*REPLACE*/ then 1 else 2 end as "type",
                            sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as "pending_grievances",
                            sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
                            sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
                            case when admin_position_master.office_id in (18) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
                                    else null::int
                            end as "atr_auto_returned_from_cmo",
--                            count(1) as total_count
                            raw_data.grievance_id
                        from raw_data
                        left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id
                        left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
                        left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
                        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
                        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
                        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
                        where raw_data.status not in (3,16)
                        group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name, admin_user_role_master.role_master_id,
                        admin_user_role_master.role_master_name, cmo_designation_master.designation_name, cmo_sub_office_master.suboffice_name, admin_position_master.record_status, raw_data.grievance_id
                        order by type, admin_user_role_master.role_master_id
                    )xx
                ), union_part as (
                    select * from unassigned_cmo
                        union all
--                    select * from unassigned_other_hod
--                        union all
                    select * from recalled
                        union all
                    select * from user_wise_pndcy
                )
                select
                    row_number() over() as sl_no,
                    '2025-11-03 16:30:01.176202+00:00'::timestamp as refresh_time_utc,
                    '2025-11-03 16:30:01.176202+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
                    *
                from union_part


                
                
                
select 
	gl.grievance_id,
	gl.grievance_status,
	gl.assigned_on,
	gl.assigned_by_id,
	gl.assigned_to_id,
	gl.assigned_by_office_cat,
	gl.assigned_to_office_cat,
	gl.assigned_by_office_id,
	gl.assigned_to_office_id,
	gl.assigned_by_position, 
	gl.assigned_to_position
from grievance_lifecycle gl where gl.grievance_id = 3184193 order by assigned_on desc;

select * from cmo_office_master com where com.office_id = 117

--=================================================================================================================



------ ALL CASE -----
--with lastupdates AS (
--    select
--        grievance_lifecycle.grievance_id,
--        grievance_lifecycle.grievance_status,
--        grievance_lifecycle.assigned_on,
--        grievance_lifecycle.assigned_to_office_id,
--        grievance_lifecycle.assigned_by_position,
--        grievance_lifecycle.assigned_to_position,
--        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
--    from grievance_lifecycle
--    where grievance_lifecycle.grievance_status in (3,5)
--),
--master_district_block_grv_data AS (
    select distinct
        md.grievance_id,
        case
            when glh.id is null then 1
            when glh.id is not null then 2
        end as lockable,
        case
            when glh.locked_by_position  is null then null
            else concat(aud.official_name, ' [', cdm2.designation_name, ' (', com3.office_name, ') - ', aurm2.role_master_name, '] '  )
        end as lock_by_user,
        avar.is_valid,
        avar.reason,
        case
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 5 then 0
            else 1
        end as received_from_other_hod_flag,
        case
            when apm.role_master_id = 6 and apm2.role_master_id in (4,5) and md.status = 11 and (md.current_atr_date is not null or md.action_taken_note is not null or md.atn_id is not null) then 1
            else 0
        end as received_from_restricted_flag,
--        lu.grievance_status as last_grievance_status,
--        lu.assigned_on as last_assigned_on,
--        lu.assigned_to_office_id as last_assigned_to_office_id,
--        lu.assigned_by_position as last_assigned_by_position,
--        lu.assigned_to_position as last_assigned_to_position,
        null as last_grievance_status,
        null as last_assigned_on,
        null as last_assigned_to_office_id,
        null as last_assigned_by_position,
        null as last_assigned_to_position,
        md.grievance_no ,
        md.grievance_description,
        md.grievance_source ,
        null as grievance_source_name,
        md.applicant_name ,
        md.pri_cont_no,
        md.grievance_generate_date,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        md.district_name ,
        md.block_id ,
        md.block_name ,
        md.municipality_id ,
        md.municipality_name,
        case
            when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
            when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
            else null
        end as block_or_municipalty_name,
        md.gp_id,
        md.gp_name,
        md.ward_id,
        md.ward_name,
        case
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
            ELSE NULL
        end as gp_or_ward_name,
        md.atn_id,
        case
            when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
            when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
            ELSE 'N/A'
        end as atn_desc,
        md.action_taken_note,
        coalesce(md.current_atr_date,null) as current_atr_date,
        md.assigned_to_position,
        md.assigned_to_id,
        case
            when md.assigned_to_position  is null then 'N/A'
            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )
        end as assigned_to_name,
        case
            when md.status = 1 then md.grievance_generate_date
            else md.updated_on -- + interval '5 hour 30 Minutes'
        end as updated_on,
        md.status,
        cdlm.domain_value as status_name,
        cdlm.domain_abbr as grievance_status_code,
        md.emergency_flag,
        md.police_station_id,
        cpsm.ps_name,
        case
            when under_processing_ids.grievance_id is not null then 'Y'
            else 'N'
        end as is_bulk_processing,
        md.receipt_mode,
        md.received_at,
        coalesce(grd.is_returned, false) as is_returned
    from master_district_block_grv md
--    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
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
    left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
    left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true
    left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
    left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
    left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
    left join cmo_office_master com3 on com3.office_id = apm3.office_id
    left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
    left join grievance_retruned_data grd on grd.grievance_id = md.grievance_id and grd.status = 1
    where md.grievance_id > 0
        and md.status in (14)
    order by updated_on asc limit 30 offset 0
--)
--select mdbgd.*
--from master_district_block_grv_data mdbgd;




------- atr submit to cmo -------
/* TAB_ID: 1B1 | TBL: ATR Submitted to CMO >> Role: 1 Ofc: None | G_Codes: ('GM014') */
select DISTINCT
    md.grievance_id,
    case
        when glh.id is null then 1
        when glh.id is not null then 2
    end as lockable,
    case
        when glh.locked_by_position  is null then null
        else concat(aud.official_name, ' [', cdm2.designation_name, ' (', com3.office_name, ') - ', aurm2.role_master_name, '] '  )
    end as lock_by_user,
    avar.is_valid,
    avar.reason,
    0 as received_from_other_hod_flag,
    0 as received_from_restricted_flag,
    null as last_grievance_status,
    null as last_assigned_on,
    null as last_assigned_to_office_id,
    null as last_assigned_by_position,
    null as last_assigned_to_position,
    md.grievance_no ,
    md.grievance_description,
    md.grievance_source ,
    null as grievance_source_name,
    md.applicant_name ,
    md.pri_cont_no,
    md.grievance_generate_date,
    md.grievance_category,
    cgcm.grievance_category_desc,
    md.assigned_to_office_id,
    com.office_name,
    md.district_id,
    md.district_name ,
    md.block_id ,
    md.block_name ,
    md.municipality_id ,
    md.municipality_name,
    case
        when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
        when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
        else null
    end as block_or_municipalty_name,
    md.gp_id,
    md.gp_name,
    md.ward_id,
    md.ward_name,
    case
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
        ELSE NULL
    end as gp_or_ward_name,
    md.atn_id,
    case
        when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
        when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
        ELSE 'N/A'
    end as atn_desc,
    md.action_taken_note,
    coalesce(md.current_atr_date,null) as current_atr_date,
    md.assigned_to_position,
    md.assigned_to_id,
    case
        when md.assigned_to_position  is null then 'N/A'
        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )
    end as assigned_to_name,
    md.updated_on,
    md.status,
    cdlm.domain_value as status_name,
    cdlm.domain_abbr as grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name,
    'N' as is_bulk_processing,
    md.receipt_mode,
    md.received_at,
    coalesce(grd.is_returned, false) as is_returned
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
left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true
left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
left join cmo_office_master com3 on com3.office_id = apm3.office_id
left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
left join grievance_retruned_data grd on grd.grievance_id = md.grievance_id and grd.status = 1
where glh.id is null and md.status in (14)
        and replace(lower(md.emergency_flag),' ','') like '%n%'
    order by updated_on asc offset 0 limit 30;




---------------------------------------------------------------------------------------------------------
------ MIS ------

with pnd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id
    	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    	left join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
    where atr_latest_14_bh_mat.grievance_id is null and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
   union
    select bh.grievance_id
    	from forwarded_latest_5_bh_mat_2 bh
    	left join atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
    where bm.grievance_id is null and bh.assigned_to_office_id in (35)
), pnd_raw_data as (
    select grievance_master_bh_mat.*
        from pnd_union_data as bh
        inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
), pnd as (
    select admin_position_master.office_id, pnd_raw_data.grievance_category, count(1) as pending,
        sum(case when ba.days_diff <= 7 then 1 else 0 end) as d_0_7_d,
        sum(case when (15 >= ba.days_diff and ba.days_diff > 7) then 1 else 0 end) as d_7_15,
        sum(case when (30 >= ba.days_diff and ba.days_diff > 15) then 1 else 0 end) as d_15_30,
        sum(case when (ba.days_diff > 30) then 1 else 0 end) as more_30_d
        from pnd_raw_data
    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
    left join /* VARIABLE */ pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
    where pnd_raw_data.status not in (3, 5, 16)  and (admin_position_master.office_id not in (35) or admin_position_master.office_id is null)
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
        /* VARIABLE */ '2025-11-27 16:30:01.532149+00:00':: timestamp as refresh_time_utc,
        /* VARIABLE */ '2025-11-27 16:30:01.532149+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
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
            /* VARIABLE */
    order by com.office_name, cgcm.grievance_category_desc
)
select row_number() over() as sl_no, processing_unit.* from processing_unit




----- dashboard -----
with fwd_union_data as (
    select
        forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
            ) as recev_cmo_othod
        inner join forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = recev_cmo_othod.grievance_id
            where 1=1 and forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
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
        where atr_latest_13_bh_mat.assigned_to_office_id in (35)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
),  pend as (
        select
            fwd_union_data.assigned_to_office_id, count(fwd_union_data.grievance_id) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
        from fwd_union_data
        inner join pending_at_other_hod_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (35))
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
), ave_days as (
        select
            fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id, avg(bh.days_to_resolve) as avg_days_to_resolved
        from fwd_union_data
        inner join atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
        inner join pending_at_other_hod_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
        where 1=1 and atr_latest_13_bh_mat.assigned_to_office_id in (35)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
)
select
   '2025-11-27 16:30:01.532149+00:00'::timestamp as refresh_time_utc,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name_by,
    coalesce(com2.office_id, 0) as office_id_to,
    coalesce(com2.office_name, 'N/A') as office_name_to,
    coalesce(fwd_atr.forwarded, 0) as grv_forwarded,
    coalesce(atr_recv.atr_received, 0) as atr_received,
    coalesce(round(ave_days.avg_days_to_resolved, 2), 0) as avg_days_to_resolved,
    coalesce(pend.more_7_days, 0) as more_7_days,
    coalesce(pend.atrpending, 0) as atr_pending
    from fwd_atr
left join atr_recv on fwd_atr.assigned_to_office_id = atr_recv.assigned_to_office_id
left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
left join cmo_office_master com2 on com2.office_id = fwd_atr.assigned_to_office_id
left join ave_days on fwd_atr.assigned_to_office_id = ave_days.assigned_to_office_id
left join pend on fwd_atr.assigned_to_office_id = pend.assigned_to_office_id
    where 1=1
group by com.office_id, com.office_name, fwd_atr.forwarded, atr_recv.atr_received, com2.office_id, com2.office_name, ave_days.avg_days_to_resolved, pend.atrpending, pend.more_7_days
order by com2.office_name









with fwd_union_data as (
    select
        forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
            ) as recev_cmo_othod
        inner join forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = recev_cmo_othod.grievance_id
            where 1=1 and forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
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
        where atr_latest_13_bh_mat.assigned_to_office_id in (35)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
),  pend as (
        select
            fwd_union_data.assigned_to_office_id, count(fwd_union_data.grievance_id) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
        from fwd_union_data
        inner join pending_at_other_hod_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (35))
--        left join atr_latest_13_bh_mat_2 as bm on fwd_union_data.grievance_id = bm.grievance_id where bm.grievance_id is null and fwd_union_data.assigned_to_office_id in (35)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
), ave_days as (
        select
            fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id, avg(bh.days_to_resolve) as avg_days_to_resolved
        from fwd_union_data
        inner join atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
        inner join pending_at_other_hod_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
        where 1=1 and atr_latest_13_bh_mat.assigned_to_office_id in (35)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
)
select
   '2025-11-27 16:30:01.532149+00:00'::timestamp as refresh_time_utc,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name_by,
    coalesce(com2.office_id, 0) as office_id_to,
    coalesce(com2.office_name, 'N/A') as office_name_to,
    coalesce(fwd_atr.forwarded, 0) as grv_forwarded,
    coalesce(atr_recv.atr_received, 0) as atr_received,
    coalesce(round(ave_days.avg_days_to_resolved, 2), 0) as avg_days_to_resolved,
    coalesce(pend.more_7_days, 0) as more_7_days,
    coalesce(pend.atrpending, 0) as atr_pending
    from fwd_atr
left join atr_recv on fwd_atr.assigned_to_office_id = atr_recv.assigned_to_office_id
left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
left join cmo_office_master com2 on com2.office_id = fwd_atr.assigned_to_office_id
left join ave_days on fwd_atr.assigned_to_office_id = ave_days.assigned_to_office_id
left join pend on fwd_atr.assigned_to_office_id = pend.assigned_to_office_id
    where 1=1
group by com.office_id, com.office_name, fwd_atr.forwarded, atr_recv.atr_received, com2.office_id, com2.office_name, ave_days.avg_days_to_resolved, pend.atrpending, pend.more_7_days
order by com2.office_name


----------------------- testing ---------------


with fwd_union_data as ( 
    select
        forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
            ) as recev_cmo_othod
        inner join forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = recev_cmo_othod.grievance_id
            where 1=1 and forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
        group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
),  fwd_atr as (
        select
            count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
            from fwd_union_data
            group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
),  pend as (
        select
            fwd_union_data.assigned_to_office_id, count(fwd_union_data.grievance_id) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
        from fwd_union_data
        inner join pending_at_other_hod_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (35))
--        left join atr_latest_13_bh_mat_2 as bm on fwd_union_data.grievance_id = bm.grievance_id where bm.grievance_id is null and fwd_union_data.assigned_to_office_id in (35)
        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id,fwd_union_data.grievance_id
        )
select
    pend.atrpending
    from fwd_atr
full join pend on fwd_atr.assigned_to_office_id = pend.assigned_to_office_id







with pnd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id
    	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    	left join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
    where atr_latest_14_bh_mat.grievance_id is null and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
   union
    select bh.grievance_id
    	from forwarded_latest_5_bh_mat_2 bh
    	left join atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
    where bm.grievance_id is null and bh.assigned_to_office_id in (35)
), pnd_raw_data as (
    select grievance_master_bh_mat.*
        from pnd_union_data as bh
        inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
), pnd as (
    select admin_position_master.office_id, /*count(1) as pending,*/ pnd_raw_data.grievance_id
        from pnd_raw_data
    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
    left join /* VARIABLE */ pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
    where pnd_raw_data.status not in (3, 5, 16)  and (admin_position_master.office_id not in (35) or admin_position_master.office_id is null)
    group by admin_position_master.office_id
), fwd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where /* VARIABLE */ forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
        union
    select bh.grievance_id from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh where /* VARIABLE */ bh.assigned_to_office_id in (35)
), fwd_atr as (
    select 
    	forwarded_latest_5_bh_mat.assigned_to_office_id,
        count(forwarded_latest_5_bh_mat.grievance_id) as forwarded,
        count(atr_latest_13_bh_mat.grievance_id) as atr_received
    from fwd_union_data
    left join forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = fwd_union_data.grievance_id
    left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
                            and atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id and atr_latest_13_bh_mat.assigned_to_office_id in (35)
    where /* VARIABLE */ forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
    group by forwarded_latest_5_bh_mat.assigned_to_office_id
) select
        coalesce(pnd.pending, 0) AS atr_pending
    from fwd_atr
    full join pnd on fwd_atr.assigned_to_office_id = pnd.office_id

    
    
    
    
    
    
    
    
 ------- findimng difference -------
    with q1 as (
		    -- PUT FULL QUERY 1 HERE
		    with pnd_union_data as (
		    select forwarded_latest_3_bh_mat.grievance_id
		    	from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		    	left join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
		    where atr_latest_14_bh_mat.grievance_id is null and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
		   union
		    select bh.grievance_id
		    	from forwarded_latest_5_bh_mat_2 bh
		    	left join atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
		    where bm.grievance_id is null and bh.assigned_to_office_id in (35)
		), pnd_raw_data as (
		    select grievance_master_bh_mat.*
		        from pnd_union_data as bh
		        inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
		), pnd as (
		    select 
		    	distinct pnd_raw_data.grievance_id,
		    	admin_position_master.office_id /*count(1) as pending,*/ 
		        from pnd_raw_data
		    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
		    left join /* VARIABLE */ pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
		    where pnd_raw_data.status not in (3, 5, 16)  and (admin_position_master.office_id not in (35) or admin_position_master.office_id is null)
		    group by admin_position_master.office_id, pnd_raw_data.grievance_id
		), fwd_union_data as (
		    select forwarded_latest_3_bh_mat.grievance_id from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		            where /* VARIABLE */ forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
		        union
		    select bh.grievance_id from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh where /* VARIABLE */ bh.assigned_to_office_id in (35)
		), fwd_atr as (
		    select 
		    	forwarded_latest_5_bh_mat.assigned_to_office_id,
		        count(forwarded_latest_5_bh_mat.grievance_id) as forwarded,
		        count(atr_latest_13_bh_mat.grievance_id) as atr_received
		    from fwd_union_data
		    left join forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = fwd_union_data.grievance_id
		    left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
		                            and atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id and atr_latest_13_bh_mat.assigned_to_office_id in (35)
		    where /* VARIABLE */ forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
		    group by forwarded_latest_5_bh_mat.assigned_to_office_id
		) select
		        pnd.grievance_id
		    from fwd_atr
		    full join pnd on fwd_atr.assigned_to_office_id = pnd.office_id
	),
q2 as (
    -- PUT FULL QUERY 2 HERE
	    with fwd_union_data as ( 
	    select
	        forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
	        from
	            (
	            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
	                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	            where forwarded_latest_3_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
	                union
	            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
	                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
	            where forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
	            ) as recev_cmo_othod
	        inner join forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = recev_cmo_othod.grievance_id
	            where 1=1 and forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
	        group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_by_office_id
	),  fwd_atr as (
	        select
	            count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
	            from fwd_union_data
	            group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id
	),  pend as (
	        select
	            distinct fwd_union_data.grievance_id, fwd_union_data.assigned_to_office_id, /*count(fwd_union_data.grievance_id) as atrpending,*/ sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
	        from fwd_union_data
	        inner join pending_at_other_hod_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
	        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (35))
	--        left join atr_latest_13_bh_mat_2 as bm on fwd_union_data.grievance_id = bm.grievance_id where bm.grievance_id is null and fwd_union_data.assigned_to_office_id in (35)
	        group by fwd_union_data.assigned_to_office_id, fwd_union_data.assigned_by_office_id,fwd_union_data.grievance_id
	        )
	select
	    pend.grievance_id
	    from fwd_atr
	full join pend on fwd_atr.assigned_to_office_id = pend.assigned_to_office_id
)
select grievance_id
from q1
except
select grievance_id
from q2;




-----------------------------------------------------------------------------------------------------------------------

with received_count as (
        select forwarded_latest_5_bh_mat.assigned_by_office_id,  count(1) as received
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        where forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
        group by forwarded_latest_5_bh_mat.assigned_by_office_id
), atr_submitted as (
        select atr_latest_13_bh_mat.assigned_to_office_id, count(1) as atr_submitted
        from atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat
        inner join forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
        where atr_latest_13_bh_mat.assigned_by_office_id in (35)
        group by atr_latest_13_bh_mat.assigned_to_office_id
), pending_count as (
        select forwarded_latest_5_bh_mat.assigned_by_office_id, count(1) as pending
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        where atr_latest_13_bh_mat.grievance_id is null and forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
            /* VARIABLE */
        group by forwarded_latest_5_bh_mat.assigned_by_office_id
) select
        coalesce(rc.received, 0) AS grv_fwd,
        coalesce(ats.atr_submitted, 0) AS atr_rcvd,
        coalesce(pc.pending, 0) AS atr_pndg
    from received_count rc
    left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
    left join atr_submitted ats on ats.assigned_to_office_id = com.office_id
    left join pending_count pc on pc.assigned_by_office_id = com.office_id 
    order by com.office_name
    
    
    with received_count as (
            select
                forwarded_latest_5_bh_mat.assigned_by_office_id,
                count(1) as received
            from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where 1=1 and forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
            group by forwarded_latest_5_bh_mat.assigned_by_office_id
    ), atr_submitted as (
            select
--                forwarded_latest_5_bh_mat.assigned_by_office_id,
            	atr_latest_13_bh_mat.assigned_to_office_id,
                count(1) as atr_submitted,
                avg(pending_at_other_hod_mat.days_to_resolve) as avg_days_to_resolved
            from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            inner join atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
            left join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
            where 1=1  and atr_latest_13_bh_mat.assigned_by_office_id in (35) /* SSM CALL CENTER */
--            group by forwarded_latest_5_bh_mat.assigned_by_office_id
            group by atr_latest_13_bh_mat.assigned_to_office_id
    ), pending_count as (
            select
                forwarded_latest_5_bh_mat.assigned_by_office_id,
                count(1) as pending,
                sum(case when (pending_at_other_hod_mat.pending_days > 7) then 1 else 0 end) as more_7_days
            from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            inner join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
            where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat where forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id /*and atr_latest_13_bh_mat.assigned_by_office_id in (35)*/ )
            and forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
            group by forwarded_latest_5_bh_mat.assigned_by_office_id
    )
    select
        coalesce(rc.received, 0) as grv_received,
        coalesce(ats.atr_submitted, 0) as atr_submitted,
        coalesce(pc.pending, 0) as atr_pending
    from received_count rc
    left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
--    left join atr_submitted ats on ats.assigned_by_office_id = com.office_id
    left join atr_submitted ats on ats.assigned_to_office_id = com.office_id
    left join pending_count pc on pc.assigned_by_office_id = com.office_id
    
    
    
    
            select
                forwarded_latest_5_bh_mat.assigned_by_office_id,
                count(1) as atr_submitted,
                avg(pending_at_other_hod_mat.days_to_resolve) as avg_days_to_resolved
            from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            inner join atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
            left join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
            where 1=1  and atr_latest_13_bh_mat.assigned_by_office_id in (35) /* SSM CALL CENTER */
            group by forwarded_latest_5_bh_mat.assigned_by_office_id
    
    
    
            
            
        select atr_latest_13_bh_mat.assigned_to_office_id, count(1) as atr_submitted
        from atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat
        inner join forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
        where atr_latest_13_bh_mat.assigned_by_office_id in (35)
        group by atr_latest_13_bh_mat.assigned_to_office_id

        
        
        
        
        
        
with received_count as (
        select
            forwarded_latest_5_bh_mat.assigned_by_office_id,
            count(1) as received
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        where 1=1 and forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
        group by forwarded_latest_5_bh_mat.assigned_by_office_id
), atr_submitted as (
		 select
            atr_latest_13_bh_mat.assigned_to_office_id,
                count(1) as atr_submitted,
                avg(pending_at_other_hod_mat.days_to_resolve) as avg_days_to_resolved
            from atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat
            inner join  forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
            left join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
            where atr_latest_13_bh_mat.assigned_by_office_id in (35) 
            group by atr_latest_13_bh_mat.assigned_to_office_id
--        select
--            forwarded_latest_5_bh_mat.assigned_by_office_id,
--            count(1) as atr_submitted,
--            avg(pending_at_other_hod_mat.days_to_resolve) as avg_days_to_resolved
--        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
--        inner join atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
--        left join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
--        where 1=1  and atr_latest_13_bh_mat.assigned_by_office_id in (35) /* SSM CALL CENTER */
--        group by forwarded_latest_5_bh_mat.assigned_by_office_id
), pending_count as (
        select
            forwarded_latest_5_bh_mat.assigned_by_office_id,
            count(1) as pending,
            sum(case when (pending_at_other_hod_mat.pending_days > 7) then 1 else 0 end) as more_7_days
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        inner join pending_at_other_hod_mat_2 as pending_at_other_hod_mat on pending_at_other_hod_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat where forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id /*and atr_latest_13_bh_mat.assigned_by_office_id in (35)*/ )
        and forwarded_latest_5_bh_mat.assigned_to_office_id in (35) /* SSM CALL CENTER */
        group by forwarded_latest_5_bh_mat.assigned_by_office_id
)
select
    '2025-11-27 16:30:01.532149+00:00'::timestamp as refresh_time_utc,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name_by,
    coalesce(rc.received, 0) as grv_received,
    coalesce(ats.atr_submitted, 0) as atr_submitted,
    coalesce(round(ats.avg_days_to_resolved, 2), 0) as avg_days_to_resolved,
    coalesce(pc.more_7_days, 0) as more_7_days,
    coalesce(pc.pending, 0) as atr_pending
from received_count rc
left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
--left join atr_submitted ats on ats.assigned_by_office_id = com.office_id
left join atr_submitted ats on ats.assigned_to_office_id = com.office_id
left join pending_count pc on pc.assigned_by_office_id = com.office_id
where 1=1
group by com.office_id, com.office_name, rc.received, ats.atr_submitted, ats.avg_days_to_resolved, pc.pending, pc.more_7_days
order by com.office_name

    





 with received_count as (
        select forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id,  count(1) as received
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        where 1=1
            /* VARIABLE */
            /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
            /* VARIABLE */
        group by forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id
), atr_submitted as (
        select atr_latest_13_bh_mat.grievance_category, atr_latest_13_bh_mat.assigned_to_office_id, count(1) as atr_submitted
        from atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat
        inner join forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
        where 1=1
            /* VARIABLE */
            /* VARIABLE */  and atr_latest_13_bh_mat.assigned_by_office_id in (35)
            /* VARIABLE */
        group by atr_latest_13_bh_mat.grievance_category, atr_latest_13_bh_mat.assigned_to_office_id
), pending_count as (
        select forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id, count(1) as pending
        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
        left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
        where atr_latest_13_bh_mat.grievance_id is null
            /* VARIABLE */
            /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
            /* VARIABLE */
        group by forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_category
) select
    row_number() over() as sl_no,
    /* VARIABLE */ '2025-11-27 16:30:01.532149+00:00'::timestamp as refresh_time_utc,
    /* VARIABLE */ '2025-11-27 16:30:01.532149+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
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
    
    
    
    
    -----------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------ LISTING UPDATE -------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------------
    
    
/* TAB_ID: 1A1 | TBL: New (Unassigned) >> Role: 1 Ofc: 5 | G_Codes: ('GM001') */
select distinct
    md.grievance_id,
    0 as received_from_other_hod_flag,
    0 as received_from_restricted_flag,
    null as last_grievance_status,
    null as last_assigned_on,
    null as last_assigned_to_office_id,
    null as last_assigned_by_position,
    null as last_assigned_to_position,
    md.grievance_no,
    md.grievance_description,
    md.grievance_source,
    null as grievance_source_name,
    md.applicant_name,
    md.pri_cont_no,
    md.grievance_generate_date,
    md.grievance_category,
    cgcm.grievance_category_desc,
    md.assigned_to_office_id,
    com.office_name,
    md.district_id,
    md.district_name,
    md.block_id,
    md.block_name,
    md.municipality_id,
    md.municipality_name,
    case
        when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
        when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
        else null
    end as block_or_municipalty_name,
    md.gp_id,
    md.gp_name,
    md.ward_id,
    md.ward_name,
    case
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
        ELSE NULL
    end as gp_or_ward_name,
    md.atn_id,
    case
        when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
        when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
        ELSE 'N/A'
    end as atn_desc,
    md.action_taken_note,
    coalesce(md.current_atr_date,null) as current_atr_date,
    md.assigned_to_position,
    md.assigned_to_id,
    case
        when md.assigned_to_position  is null then 'N/A'
        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ']' )
    end as assigned_to_name,
    md.grievance_generate_date,
    md.grievance_generate_date as updated_on,
    md.status,
    cdlm.domain_value as status_name,
    cdlm.domain_abbr as grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name,
    case
        when under_processing_ids.grievance_id is not null then 'Y'
        else 'N'
    end as is_bulk_processing,
    md.receipt_mode,
    md.received_at,
    coalesce(grd.is_returned, false) as is_returned
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
left join grievance_retruned_data grd on grd.grievance_id = md.grievance_id and grd.status = 1
where /*not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status in (1))
and*/ md.status in (1) and md.assigned_to_office_id = 5
        and replace(lower(md.emergency_flag),' ','') like '%n%'
    order by grievance_generate_date asc limit 30 offset 0
    
    
    
    
 
    
  /* TAB_ID: 1A4 | TBL: All >> Role: 1 Ofc: 5 | G_Codes: ('GM001', 'GM002', 'GM016') */
WITH lastupdates AS (
    select grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select distinct
        md.grievance_id,
        case
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 5 then 0
            else 1
        end as received_from_other_hod_flag,
        case
            when apm.role_master_id = 6 and apm2.role_master_id in (4,5) and md.status = 11 and (md.current_atr_date is not null or md.action_taken_note is not null or md.atn_id is not null) then 1
            else 0
        end as received_from_restricted_flag,
        lu.grievance_status as last_grievance_status,
        lu.assigned_on as last_assigned_on,
        lu.assigned_to_office_id as last_assigned_to_office_id,
        lu.assigned_by_position as last_assigned_by_position,
        lu.assigned_to_position as last_assigned_to_position,
        md.grievance_no,
        md.grievance_description,
        md.grievance_source,
        null as grievance_source_name,
        md.applicant_name ,
        md.pri_cont_no,
        md.grievance_generate_date,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        md.district_name ,
        md.block_id ,
        md.block_name ,
        md.municipality_id ,
        md.municipality_name,
        case
            when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
            when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
            else null
        end as block_or_municipalty_name,
        md.gp_id,
        md.gp_name,
        md.ward_id,
        md.ward_name,
        case
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
            ELSE NULL
        end as gp_or_ward_name,
        md.atn_id,
        case
            when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
            when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
            ELSE 'N/A'
        end as atn_desc,
        md.action_taken_note,
        coalesce(md.current_atr_date,null) as current_atr_date,
        md.assigned_to_position,
        md.assigned_to_id,
        case
            when md.assigned_to_position  is null then 'N/A'
            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )
        end as assigned_to_name,
        case
            when md.status = 1 then md.grievance_generate_date
            else md.updated_on -- + interval '5 hour 30 Minutes'
        end as updated_on,
        md.status,
        cdlm.domain_value as status_name,
        cdlm.domain_abbr as grievance_status_code,
        md.emergency_flag,
        md.police_station_id,
        cpsm.ps_name,
        case
            when under_processing_ids.grievance_id is not null then 'Y'
            else 'N'
        end as is_bulk_processing,
        md.receipt_mode,
        md.received_at,
        coalesce(grd.is_returned, false) as is_returned
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
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
    left join grievance_retruned_data grd on grd.grievance_id = md.grievance_id and grd.status = 1
    where md.status in (1,2,16)
    /*and not exists (select 1 from grievance_auto_assign_map gam where gam.grievance_cat_id = md.grievance_category and gam.status = 1)*/
--    order by updated_on asc limit 30 offset 0
)
select mdbgd.*
from master_district_block_grv_data mdbgd;




-----------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- HOD DASHBOARD CHECKING UPDATE --------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
with griev_forwarded as (
        select
            forwarded_latest_3_bh_mat.assigned_to_position,
            forwarded_latest_3_bh_mat.assigned_to_id,
            apm.role_master_id,
            count(1) as assigned
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        inner join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_position
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (49) and apm.role_master_id in (4,5) /* SSM CALL CENTER */
    group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, apm.role_master_id
    union all
    select
        bh.next_status_assigned_to_position as assigned_to_position,
        bh.next_status_assigned_to_id as assigned_to_id,
        apm.role_master_id,
        count(distinct forwarded_latest_3_bh_mat.grievance_id) as total_assigned
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id
    inner join admin_position_master apm on apm.position_id = bh.assigned_to_position
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (49) /*and apm.role_master_id in (5,6)*/ /* SSM CALL CENTER */
    and bh.previous_status = 3
    and bh.next_status IN (4, 7)
    and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
    group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id, apm.role_master_id
), griev_yet_to_assigned as (
        select
            md.assigned_to_position,
            md.assigned_to_id,
            count(1) as yet_to_assigned
        from master_district_block_grv md
        where md.grievance_id > 0
        and md.status in (4)
        and md.assigned_to_office_id = 49 /* SSM CALL CENTER */
        group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
	  select
        assigned_by_id,
        assigned_by_office_id,
--        assigned_by_position,
--        role_master_id,
        sum(atr_submitted) AS atr_submitted
     from (
        select
            /*'Admin & Nodal' as role,*/
            albm.assigned_by_id,
--            albm.assigned_by_office_id,
--            albm.assigned_by_position,
--            apm.role_master_id,
            count(1) as atr_submitted
        from atr_latest_14_bh_mat_2 as albm
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = albm.grievance_id
        inner join admin_position_master apm on apm.position_id = albm.assigned_by_position
        where apm.role_master_id in (4,5) and forwarded_latest_3_bh_mat.current_status in (14,15) and albm.assigned_by_office_id in (49) /* SSM CALL CENTER */
        group by /*apm.role_master_id, albm.assigned_by_position,*/ albm.assigned_by_id/*, apm.role_master_id, albm.assigned_by_office_id*/
        union all
        select
            /*'Restricted' as role,*/
            flbm.assigned_by_id,
--            flbm.assigned_by_office_id,
--            flbm.assigned_by_position,
--            flbm.role_master_id,
            count(*) as atr_submitted
        from atr_latest_4_11_bh_mat_2 as flbm
        where flbm.assigned_to_office_id in (49) /* SSM CALL CENTER */
        group by /*flbm.assigned_by_position,*/ flbm.assigned_by_id/*, flbm.assigned_by_office_id, flbm.role_master_id*/
      ) t
    group by
        assigned_by_id/*,
        assigned_by_office_id,
        assigned_by_position,
        role_master_id*/
 ), atr_yet_to_sent as (
        select
            md.assigned_to_position,
            md.assigned_to_id,
            md.assigned_to_office_id,
            apm2.role_master_id,
            count(1) as yet_atr_not_submitted
        from master_district_block_grv md
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (6,11,13)
        and md.assigned_to_office_id in (49) /* SSM CALL CENTER */
        group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id, apm2.role_master_id
    )
    select
        '2025-12-11 16:30:01.864289+00:00'::timestamp as refresh_time_utc,
        admin_position_master.record_status,
        admin_position_master.position_id,
        admin_position_master.role_master_id,
        case when admin_user_details.official_name is not null then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_designation_of_the_user,
        case when admin_position_master.office_id in (49) then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )') /*8571 14961*/
            else cmo_office_master.office_name
        end as office_of_the_user,
        coalesce(griev_forwarded.assigned, 0) as grievance_asssigned,
        coalesce(griev_yet_to_assigned.yet_to_assigned, 0) as grievance_yet_to_assigned,
        sum(coalesce(griev_forwarded.assigned::int, 0) + coalesce(griev_yet_to_assigned.yet_to_assigned::int, 0)) as grievance_total,
        coalesce(atr_sent.atr_submitted, 0) as atr_sent,
        coalesce(atr_yet_to_sent.yet_atr_not_submitted, 0) as atr_not_submitted,
        sum(coalesce(atr_sent.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0)) as atr_total
        from griev_forwarded
    left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = griev_forwarded.assigned_to_id 
    left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_forwarded.assigned_to_id 
    left join atr_sent on atr_sent.assigned_by_id = griev_forwarded.assigned_to_id
    left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
    left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
    left join cmo_office_master on cmo_office_master.office_id = admin_position_master.office_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name,
    cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted,
    atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id, admin_position_master.position_id, admin_position_master.role_master_id
    order by
        case
            when admin_position_master.role_master_id = 4 then 1
            when admin_position_master.role_master_id = 5 then 2
            when admin_position_master.role_master_id = 6 then 3
            else 4
        end    
        
        
    
        
 ----- Perfect After Update --------
 with griev_forwarded as (
        select
            forwarded_latest_3_bh_mat.assigned_to_position,
            forwarded_latest_3_bh_mat.assigned_to_id,
            apm.role_master_id,
            count(1) as assigned
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        inner join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_position
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (49) and apm.role_master_id in (4,5) /* SSM CALL CENTER */
    group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, apm.role_master_id
    union all
    select
        bh.next_status_assigned_to_position as assigned_to_position,
        bh.next_status_assigned_to_id as assigned_to_id,
        apm.role_master_id,
        count(distinct forwarded_latest_3_bh_mat.grievance_id) as total_assigned
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id
    inner join admin_position_master apm on apm.position_id = bh.assigned_to_position
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (49) /*and apm.role_master_id in (5,6)*/ /* SSM CALL CENTER */
    and bh.previous_status = 3
    and bh.next_status IN (4, 7)
    and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
    group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id, apm.role_master_id
), griev_yet_to_assigned as (
        select
            md.assigned_to_position,
            md.assigned_to_id,
            count(1) as yet_to_assigned
        from master_district_block_grv md
        where md.grievance_id > 0
        and md.status in (4)
        and md.assigned_to_office_id = 49 /* SSM CALL CENTER */
        group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
	  select
            /*'Admin & Nodal' as role,*/
            albm.assigned_by_id,
            albm.assigned_by_office_id,
--            albm.assigned_by_position,
--            apm.role_master_id,
            count(1) as atr_submitted
        from atr_latest_14_bh_mat_2 as albm
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = albm.grievance_id
        inner join admin_position_master apm on apm.position_id = albm.assigned_by_position
        where apm.role_master_id in (4,5) and forwarded_latest_3_bh_mat.current_status in (14,15) and albm.assigned_by_office_id in (49) /* SSM CALL CENTER */
        group by /*apm.role_master_id, albm.assigned_by_position,*/ albm.assigned_by_id, /*apm.role_master_id,*/ albm.assigned_by_office_id
        /*union all
        select
            /*'Restricted' as role,*/
            flbm.assigned_by_id,
--            flbm.assigned_by_office_id,
--            flbm.assigned_by_position,
--            flbm.role_master_id,
            count(*) as atr_submitted
        from atr_latest_4_11_bh_mat_2 as flbm
        where flbm.assigned_to_office_id in (49) /* SSM CALL CENTER */
        group by /*flbm.assigned_by_position,*/ flbm.assigned_by_id/*, flbm.assigned_by_office_id, flbm.role_master_id*/*/
 ), atr_sent_restrict as (
 		select
            /*'Restricted' as role,*/
            flbm.assigned_by_id,
            flbm.assigned_by_office_id,
--            flbm.assigned_by_position,
--            flbm.role_master_id,
            count(*) as atr_submitted
        from atr_latest_4_11_bh_mat_2 as flbm
        where flbm.assigned_to_office_id in (49) /* SSM CALL CENTER */
        group by /*flbm.assigned_by_position,*/ flbm.assigned_by_id, flbm.assigned_by_office_id/*, flbm.role_master_id*/
 ), atr_yet_to_sent as (
        select
            md.assigned_to_position,
            md.assigned_to_id,
            md.assigned_to_office_id,
            apm2.role_master_id,
            count(1) as yet_atr_not_submitted
        from master_district_block_grv md
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (6,11,13)
        and md.assigned_to_office_id in (49) /* SSM CALL CENTER */
        group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id, apm2.role_master_id
    )
    select
        '2025-12-11 16:30:01.864289+00:00'::timestamp as refresh_time_utc,
        admin_position_master.record_status,
        admin_position_master.position_id,
        admin_position_master.role_master_id,
        case when admin_user_details.official_name is not null then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_designation_of_the_user,
        case when admin_position_master.office_id in (49) then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )') /*8571 14961*/
            else cmo_office_master.office_name
        end as office_of_the_user,
        coalesce(griev_forwarded.assigned, 0) as grievance_asssigned,
        coalesce(griev_yet_to_assigned.yet_to_assigned, 0) as grievance_yet_to_assigned,
        sum(coalesce(griev_forwarded.assigned::int, 0) + coalesce(griev_yet_to_assigned.yet_to_assigned::int, 0)) as grievance_total,
--        coalesce(atr_sent.atr_submitted, 0) as atr_sent,
--        coalesce(atr_sent_restrict.atr_submitted, 0) as atr_sent,
        case 
        	when admin_position_master.role_master_id in (4,5) then coalesce(atr_sent.atr_submitted, 0)
        	when admin_position_master.role_master_id in (6) then coalesce(atr_sent_restrict.atr_submitted, 0)
        	else 0
        end as atr_sent,
        coalesce(atr_yet_to_sent.yet_atr_not_submitted, 0) as atr_not_submitted,
        case 
        	when admin_position_master.role_master_id in (4,5) then sum(coalesce(atr_sent.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0))
        	when admin_position_master.role_master_id in (6) then sum(coalesce(atr_sent_restrict.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0))
        	else 0
        end as atr_total
--        sum(coalesce(atr_sent.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0)) as atr_total
        from griev_forwarded
    left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = griev_forwarded.assigned_to_id 
    left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_forwarded.assigned_to_id 
    left join atr_sent on atr_sent.assigned_by_id = griev_forwarded.assigned_to_id
    left join atr_sent_restrict on atr_sent_restrict.assigned_by_id = griev_forwarded.assigned_to_id
    left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
    left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
    left join cmo_office_master on cmo_office_master.office_id = admin_position_master.office_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name,
    cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted,
    atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id, admin_position_master.position_id, admin_position_master.role_master_id, atr_sent_restrict.atr_submitted
    order by
        case
            when admin_position_master.role_master_id = 4 then 1
            when admin_position_master.role_master_id = 5 then 2
            when admin_position_master.role_master_id = 6 then 3
            else 4
        end    
        
        
  
        
        
        
        
        
atr_sent AS (
    SELECT
        assigned_by_id,
        assigned_by_position,
        assigned_by_office_id,
        role_master_id,
        SUM(atr_submitted) AS atr_submitted
    FROM (
        SELECT
            albm.assigned_by_id,
            albm.assigned_by_position,
            albm.assigned_by_office_id,
            COUNT(1) AS atr_submitted
        FROM atr_latest_14_bh_mat_2 albm
        INNER JOIN forwarded_latest_3_bh_mat_2 fl
            ON fl.grievance_id = albm.grievance_id
        WHERE fl.current_status IN (14,15)
          AND albm.assigned_by_office_id = 49
        GROUP BY
            albm.assigned_by_id,
            albm.assigned_by_position,
            albm.assigned_by_office_id
        UNION ALL
        SELECT
            flbm.assigned_by_id,
            flbm.assigned_by_position,
            flbm.assigned_by_office_id,
            COUNT(*) AS atr_submitted
        FROM atr_latest_4_11_bh_mat_2 flbm
        WHERE flbm.assigned_to_office_id = 49
        GROUP BY
            flbm.assigned_by_id,
            flbm.assigned_by_position,
            flbm.assigned_by_office_id
    ) t
    GROUP BY
        assigned_by_id,
        assigned_by_position,
        assigned_by_office_id
)


      
        
 
        
        
 with griev_forwarded as (
        select
            forwarded_latest_3_bh_mat.assigned_to_position,
            forwarded_latest_3_bh_mat.assigned_to_id,
            apm.role_master_id,
            count(1) as assigned
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        inner join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_position
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (49) and apm.role_master_id in (4,5) /* SSM CALL CENTER */
    group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, apm.role_master_id
    union all
    select
        bh.next_status_assigned_to_position as assigned_to_position,
        bh.next_status_assigned_to_id as assigned_to_id,
        apm.role_master_id,
        count(distinct forwarded_latest_3_bh_mat.grievance_id) as total_assigned
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id
    inner join admin_position_master apm on apm.position_id = bh.assigned_to_position
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (49) /*and apm.role_master_id in (5,6)*/ /* SSM CALL CENTER */
    and bh.previous_status = 3
    and bh.next_status IN (4, 7)
    and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
    group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id, apm.role_master_id
), griev_yet_to_assigned as (
        select
            md.assigned_to_position,
            md.assigned_to_id,
            count(1) as yet_to_assigned
        from master_district_block_grv md
        where md.grievance_id > 0
        and md.status in (4)
        and md.assigned_to_office_id = 49 /* SSM CALL CENTER */
        group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
        select
            /*'Admin & Nodal' as role,*/
            albm.assigned_by_position,
            albm.assigned_by_id,
            albm.assigned_by_office_id,
            apm.role_master_id,
            count(1) as atr_submitted
        from atr_latest_14_bh_mat_2 as albm
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = albm.grievance_id
        inner join admin_position_master apm on apm.position_id = albm.assigned_by_position
        where apm.role_master_id in (4,5) and forwarded_latest_3_bh_mat.current_status in (14,15) and albm.assigned_by_office_id in (49) /* SSM CALL CENTER */
        group by apm.role_master_id, albm.assigned_by_position, albm.assigned_by_id, apm.role_master_id, albm.assigned_by_office_id
        union all
        select
            /*'Restricted' as role,*/
            flbm.assigned_by_position,
            flbm.assigned_by_id,
            flbm.assigned_by_office_id,
            flbm.role_master_id,
            count(*) as atr_submitted
        from atr_latest_4_11_bh_mat_2 as flbm
        where flbm.assigned_to_office_id in (49) /* SSM CALL CENTER */
        group by flbm.assigned_by_position, flbm.assigned_by_id, flbm.assigned_by_office_id, flbm.role_master_id
    ), atr_yet_to_sent as (
        select
            md.assigned_to_position,
            md.assigned_to_id,
            md.assigned_to_office_id,
            apm2.role_master_id,
            count(1) as yet_atr_not_submitted
        from master_district_block_grv md
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (6,11,13)
        and md.assigned_to_office_id in (49) /* SSM CALL CENTER */
        group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id, apm2.role_master_id
    )
    select
        '2025-12-11 16:30:01.864289+00:00'::timestamp as refresh_time_utc,
        admin_user_position_mapping.status,
        admin_position_master.record_status,
        admin_position_master.position_id,
        admin_user_details.admin_user_id,
        case when admin_user_details.official_name is not null then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_designation_of_the_user,
        case when admin_position_master.office_id in (49) then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )') /*8571 14961*/
            else cmo_office_master.office_name
        end as office_of_the_user,
        coalesce(griev_forwarded.assigned, 0) as grievance_asssigned,
        coalesce(griev_yet_to_assigned.yet_to_assigned, 0) as grievance_yet_to_assigned,
        sum(coalesce(griev_forwarded.assigned::int, 0) + coalesce(griev_yet_to_assigned.yet_to_assigned::int, 0)) as grievance_total,
        coalesce(atr_sent.atr_submitted, 0) as atr_sent,
        coalesce(atr_yet_to_sent.yet_atr_not_submitted, 0) as atr_not_submitted,
        sum(coalesce(atr_sent.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0)) as atr_total
     from griev_forwarded
     left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
     left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
     left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
     left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
     left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
     left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
     left join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
--     left join admin_user au on au.admin_user_id = admin_user_details.admin_user_id  ---
     left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = admin_user_details.admin_user_id
     left join atr_sent on atr_sent.assigned_by_id = admin_user_details.admin_user_id
     left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = admin_user_details.admin_user_id
--         where cmo_office_master.office_id = 49
    group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name,
    cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted,
    atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id, admin_position_master.position_id, 
    admin_user_details.admin_user_id, admin_user_position_mapping.status
    order by
        case
            when admin_position_master.role_master_id = 4 then 1
            when admin_position_master.role_master_id = 5 then 2
            when admin_position_master.role_master_id = 6 then 3
            else 4
        end
     
        
     
     
     
     
     
    from admin_user_details 
    inner join admin_user au on au.admin_user_id = admin_user_details.admin_user_id 
    inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
    inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
    inner join admin_user_role_master on admin_user_role_master.role_master_id = admin_position_master.role_master_id
    inner join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
    inner join cmo_office_master on cmo_office_master.office_id = admin_position_master.office_id
    inner join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    left join griev_forwarded on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
    left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = admin_user_details.admin_user_id
    left join atr_sent on atr_sent.assigned_by_id = admin_user_details.admin_user_id
    left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = admin_user_details.admin_user_id
    
  
    
    
    
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
        order by type, admin_user_role_master.role_master_id, raw_data.grievance_id 
    
    
    
        
        from griev_forwarded
    left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = griev_forwarded.assigned_to_id /*and griev_yet_to_assigned.assigned_to_position = griev_forwarded.assigned_to_position*/
    left join atr_sent on atr_sent.assigned_by_id = griev_forwarded.assigned_to_id /*and griev_forwarded.assigned_to_position = atr_sent.assigned_by_position*/
    left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_forwarded.assigned_to_id /*and atr_yet_to_sent.assigned_to_position = griev_forwarded.assigned_to_position*/
    left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
    left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
    left join admin_position_master apm on atr_sent.assigned_by_position = apm.position_id
    left join cmo_office_master on cmo_office_master.office_id = admin_position_master.office_id
    left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join admin_user_role_master aurm on apm.role_master_id = admin_user_role_master.role_master_id
    left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    
    
    
    
    where cmo_office_master.office_id = 49
    group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name,
    cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted,
    atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id, admin_position_master.position_id, 
    admin_user_details.admin_user_id, admin_user_position_mapping.status
    order by
        case
            when admin_position_master.role_master_id = 4 then 1
            when admin_position_master.role_master_id = 5 then 2
            when admin_position_master.role_master_id = 6 then 3
            else 4
        end
    
    
    
    
    
    
    select admin_user_details.official_name, admin_user_details.official_phone, admin_user_details.official_email, admin_position_master.office_id, aurm.role_master_name, 
admin_position_master.position_id, com.office_name, admin_position_master.record_status, admin_user_position_mapping.status as mapping_status, admin_user_details.admin_user_id
from admin_user_details
inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
inner join cmo_office_master com on com.office_id = admin_position_master.office_id
inner join admin_user au on au.admin_user_id = admin_user_details.admin_user_id 
where /*admin_position_master.office_id = 35 and */ admin_position_master.office_id is not null /*and admin_position_master.role_master_id in (4,5)*/ 
	 /*and admin_user_position_mapping.status = 1*/  /*and admin_position_master.record_status= 1*/ /*and au.u_phone in ('9999999900','9999999999','8918939197','8777729301','9775761810','7719357638','7001322965','6292222444',
'8334822522','9874263537','9432331563','9434495405','9559000099','9874263537')*/ /*and au.admin_user_id in (8571)*/ and admin_position_master.position_id = 8571
	 group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name, admin_user_details.official_email, 
	 admin_position_master.record_status, admin_position_master.record_status, admin_user_position_mapping.status, admin_user_details.admin_user_id
    
    
        
        
  

   
        
        
        
        
        
        
with griev_forwarded as (
    -- number of forwarded grievances assigned to a position/user
    select
        fl.assigned_to_position,
        fl.assigned_to_id,
        apm.role_master_id,
        count(*) as assigned
    from forwarded_latest_3_bh_mat_2 fl
    join admin_position_master apm on apm.position_id = fl.assigned_to_position
    -- where fl.assigned_to_office_id = 49  -- <-- uncomment if you want only office 49
    group by fl.assigned_to_position, fl.assigned_to_id, apm.role_master_id
),
griev_forwarded_next as (
    -- forwarded -> next status assignments (distinct grievances)
    select
        bh.next_status_assigned_to_position as assigned_to_position,
        bh.next_status_assigned_to_id as assigned_to_id,
        apm.role_master_id,
        count(distinct fl.grievance_id) as total_assigned
    from forwarded_latest_3_bh_mat_2 fl
    join forwarded_latest_3_4_bh_mat_2 bh on fl.grievance_id = bh.grievance_id
    join admin_position_master apm on apm.position_id = bh.next_status_assigned_to_position
    where
        -- fl.assigned_to_office_id = 49  -- uncomment if restricting by office
        bh.previous_status = 3
        and bh.next_status in (4,7)
        and fl.assigned_to_office_id = bh.next_status_assigned_to_office
    group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id, apm.role_master_id
),
griev_yet_to_assigned as (
    -- grievances present in master_district_block_grv which are yet to be assigned (status 4)
    select
        md.assigned_to_position,
        md.assigned_to_id,
        count(*) as yet_to_assigned
    from master_district_block_grv md
    where md.grievance_id > 0
      and md.status in (4)
      -- and md.assigned_to_office_id = 49  -- uncomment if restricting by office
    group by md.assigned_to_position, md.assigned_to_id
),
atr_sent_admin as (
    -- ATRs submitted (admin/nodal flow)
    select
        albm.assigned_by_position,
        albm.assigned_by_id,
        apm.role_master_id,
        count(*) as atr_submitted
    from atr_latest_14_bh_mat_2 albm
    join forwarded_latest_3_bh_mat_2 fl on fl.grievance_id = albm.grievance_id
    join admin_position_master apm on apm.position_id = albm.assigned_by_position
    where apm.role_master_id in (4,5)  -- keep filter if needed
      and fl.current_status in (14,15)
      -- and albm.assigned_by_office_id in (49) -- uncomment if restricting by office
    group by albm.assigned_by_position, albm.assigned_by_id, apm.role_master_id
),
atr_sent_restricted as (
    -- ATRs submitted in restricted flow (other CTE)
    select
        flbm.assigned_by_position,
        flbm.assigned_by_id,
        flbm.role_master_id,
        count(*) as atr_submitted
    from atr_latest_4_11_bh_mat_2 flbm
    where
        -- flbm.assigned_to_office_id in (49)  -- uncomment if restricting by office
        true
    group by flbm.assigned_by_position, flbm.assigned_by_id, flbm.role_master_id
),
atr_sent as (
    -- union both ATR submitted sources, summed per position/user
    select assigned_by_position, assigned_by_id, role_master_id, sum(atr_submitted) as atr_submitted
    from (
        select assigned_by_position, assigned_by_id, role_master_id, atr_submitted from atr_sent_admin
        union all
        select assigned_by_position, assigned_by_id, role_master_id, atr_submitted from atr_sent_restricted
    ) t
    group by assigned_by_position, assigned_by_id, role_master_id
),
atr_yet_to_sent as (
    -- ATRs yet to be submitted (md.status in 6,11,13)
    select
        md.assigned_to_position,
        md.assigned_to_id,
        apm2.role_master_id,
        count(*) as yet_atr_not_submitted
    from master_district_block_grv md
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    where md.status in (6,11,13)
      -- and md.assigned_to_office_id in (49)  -- uncomment if restricting by office
    group by md.assigned_to_position, md.assigned_to_id, apm2.role_master_id
)
select
    now()::timestamp as refresh_time_utc,
    apm_main.record_status,
    apm_main.position_id,
    case when aud.official_name is not null
        then concat(aud.official_name, ' - (', cdm.designation_name ,' )')
        else null
    end as name_and_designation_of_the_user,
    urm.role_master_name as user_role,
    case
        when sm.suboffice_name is not null then concat(cm.office_name, ' - ( ', sm.suboffice_name, ' )')
        else cm.office_name
    end as office_of_the_user,
    coalesce(gf.assigned, 0) + coalesce(gfn.total_assigned,0) as grievance_asssigned,
    coalesce(gy.yet_to_assigned, 0) as grievance_yet_to_assigned,
    -- total grievances (assigned + yet to assigned). If you want distinct de-dup logic, adjust accordingly.
    (coalesce(gf.assigned, 0) + coalesce(gfn.total_assigned,0) + coalesce(gy.yet_to_assigned, 0)) as grievance_total,
    coalesce(at.sent_count, 0) as atr_sent,
    coalesce(ay.yet_atr_not_submitted, 0) as atr_not_submitted,
    (coalesce(at.sent_count, 0) + coalesce(ay.yet_atr_not_submitted, 0)) as atr_total
from admin_position_master apm_main
left join admin_user_role_master urm on urm.role_master_id = apm_main.role_master_id
left join admin_user_details aud on aud.admin_user_id = apm_main.user_id  -- use the correct FK for your schema; if it's aud.admin_user_id = apm_main.user_id or another column, adjust
left join cmo_designation_master cdm on cdm.designation_id = apm_main.designation_id
left join cmo_office_master cm on cm.office_id = apm_main.office_id
left join cmo_sub_office_master sm on sm.suboffice_id = apm_main.sub_office_id
/* metrics joined by position_id and/or user id (assigned id) */
left join griev_forwarded gf on gf.assigned_to_position = apm_main.position_id and gf.assigned_to_id = apm_main.user_id
left join griev_forwarded_next gfn on gfn.assigned_to_position = apm_main.position_id and gfn.assigned_to_id = apm_main.user_id
left join griev_yet_to_assigned gy on gy.assigned_to_position = apm_main.position_id and gy.assigned_to_id = apm_main.user_id
left join atr_sent at on at.assigned_by_position = apm_main.position_id and at.assigned_by_id = apm_main.user_id
left join atr_yet_to_sent ay on ay.assigned_to_position = apm_main.position_id and ay.assigned_to_id = apm_main.user_id
order by
    case
        when apm_main.role_master_id = 4 then 1
        when apm_main.role_master_id = 5 then 2
        when apm_main.role_master_id = 6 then 3
        else 4
    end,
    apm_main.position_id;

                            
    WITH griev_forwarded AS (
    SELECT
        forwarded_latest_3_bh_mat.assigned_to_id,
        SUM(1) AS assigned
    FROM forwarded_latest_3_bh_mat_2 AS forwarded_latest_3_bh_mat
    INNER JOIN admin_position_master apm 
        ON apm.position_id = forwarded_latest_3_bh_mat.assigned_to_position
    WHERE forwarded_latest_3_bh_mat.assigned_to_office_id = 49 
      AND apm.role_master_id IN (4,5)
    GROUP BY forwarded_latest_3_bh_mat.assigned_to_id

    UNION ALL

    SELECT
        bh.next_status_assigned_to_id AS assigned_to_id,
        COUNT(DISTINCT forwarded_latest_3_bh_mat.grievance_id) AS assigned
    FROM forwarded_latest_3_bh_mat_2 AS forwarded_latest_3_bh_mat
    INNER JOIN forwarded_latest_3_4_bh_mat_2 AS bh 
        ON forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id
    WHERE forwarded_latest_3_bh_mat.assigned_to_office_id = 49
      AND bh.previous_status = 3
      AND bh.next_status IN (4,7)
    GROUP BY bh.next_status_assigned_to_id
),
griev_forwarded_final AS (
    SELECT assigned_to_id, SUM(assigned) AS assigned
    FROM griev_forwarded
    GROUP BY assigned_to_id
),

griev_yet_to_assigned AS (
    SELECT
        md.assigned_to_id,
        COUNT(1) AS yet_to_assigned
    FROM master_district_block_grv md
    WHERE md.status = 4
      AND md.assigned_to_office_id = 49
    GROUP BY md.assigned_to_id
),

atr_sent AS (
    SELECT
        albm.assigned_by_id,
        COUNT(1) AS atr_submitted
    FROM atr_latest_14_bh_mat_2 AS albm
    INNER JOIN forwarded_latest_3_bh_mat_2 AS fl 
        ON fl.grievance_id = albm.grievance_id
    INNER JOIN admin_position_master apm 
        ON apm.position_id = albm.assigned_by_position
    WHERE apm.role_master_id IN (4,5)
      AND fl.current_status IN (14,15)
      AND albm.assigned_by_office_id = 49
    GROUP BY albm.assigned_by_id
),
atr_yet_to_sent AS (
    SELECT
        md.assigned_to_id,
        COUNT(1) AS yet_atr_not_submitted
    FROM master_district_block_grv md
    WHERE md.status IN (6,11,13)
      AND md.assigned_to_office_id = 49
    GROUP BY md.assigned_to_id
)
SELECT
    now()::timestamp AS refresh_time_utc,
    admin_position_master.record_status,
    admin_position_master.position_id,
    admin_user_details.admin_user_id,
    CONCAT(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name, ')') AS user_name,
    admin_user_role_master.role_master_name AS user_role,
    CASE 
        WHEN cmo_sub_office_master.suboffice_name IS NOT NULL 
            THEN CONCAT(cmo_office_master.office_name, ' - (', cmo_sub_office_master.suboffice_name, ')')
        ELSE cmo_office_master.office_name
    END AS office_of_user,

    COALESCE(gf.assigned, 0) AS grievance_assigned,
    COALESCE(gya.yet_to_assigned, 0) AS grievance_yet_to_assigned,
    COALESCE(gf.assigned, 0) + COALESCE(gya.yet_to_assigned, 0) AS grievance_total,

    COALESCE(asent.atr_submitted, 0) AS atr_sent,
    COALESCE(ayts.yet_atr_not_submitted, 0) AS atr_not_submitted,
    COALESCE(asent.atr_submitted, 0) + COALESCE(ayts.yet_atr_not_submitted, 0) AS atr_total

FROM admin_user_details
INNER JOIN admin_user_position_mapping upm 
    ON upm.admin_user_id = admin_user_details.admin_user_id
INNER JOIN admin_position_master 
    ON admin_position_master.position_id = upm.position_id
INNER JOIN admin_user_role_master 
    ON admin_user_role_master.role_master_id = admin_position_master.role_master_id
INNER JOIN cmo_designation_master 
    ON cmo_designation_master.designation_id = admin_position_master.designation_id
INNER JOIN cmo_office_master 
    ON cmo_office_master.office_id = admin_position_master.office_id
LEFT JOIN cmo_sub_office_master 
    ON cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id

LEFT JOIN griev_forwarded_final gf ON gf.assigned_to_id = admin_user_details.admin_user_id
LEFT JOIN griev_yet_to_assigned gya ON gya.assigned_to_id = admin_user_details.admin_user_id
LEFT JOIN atr_sent asent ON asent.assigned_by_id = admin_user_details.admin_user_id
LEFT JOIN atr_yet_to_sent ayts ON ayts.assigned_to_id = admin_user_details.admin_user_id

WHERE cmo_office_master.office_id = 49

ORDER BY admin_position_master.role_master_id;
                        
                            
                            
                            
------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------- MIS REALTED QUERY CHECKING ---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------         
                
with raw_data as (
select grievance_master_bh_mat.*
from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
where forwarded_latest_3_bh_mat.assigned_to_office_id in (49)
    and not exists (
        select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                and atr_latest_14_bh_mat.current_status in (14,15)
                order by grievance_master_bh_mat.grievance_id 
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
        xx.atr_auto_returned_from_cmo, xx.grievance_id 
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
            case when admin_position_master.office_id in (49) /*REPLACE*/
                    then admin_user_role_master.role_master_name
                else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
            end as user_role,
            admin_position_master.record_status as status_id,
            case
                when admin_position_master.record_status = 1 then 'Active'
                when admin_position_master.record_status = 2 then 'Inactive'
                else null
            end as user_status,
            case when admin_position_master.office_id in (49) /*REPLACE*/ then 1 else 2 end as "type",
            sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as "pending_grievances",
            sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
            sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
            case when admin_position_master.office_id in (49) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
                    else null::int
            end as "atr_auto_returned_from_cmo",
--            count(1) as total_count
            grievance_id 
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
        order by type, admin_user_role_master.role_master_id, raw_data.grievance_id 
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
    '2025-12-11 16:30:01.864289+00:00'::timestamp as refresh_time_utc,
    '2025-12-11 16:30:01.864289+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    *
from union_part






with raw_data as (
    select grievance_master_bh_mat.*
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join grievance_master_bh_mat_2 as grievance_master_bh_mat 
        on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (49)
      and not exists (
            select 1 
            from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
              and atr_latest_14_bh_mat.current_status in (14,15)
      )
), 
user_wise_pndcy as (
    select 
        'User wise ATR Pendency' as status,
        case 
            when admin_user_details.official_name is not null
                then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_esignation_of_the_user,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
            else cmo_office_master.office_name
        end as office,
        case 
            when admin_position_master.office_id in (49) 
                then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        case 
            when admin_position_master.record_status = 1 then 'Active'
            when admin_position_master.record_status = 2 then 'Inactive'
            else null
        end as user_status,
        admin_position_master.record_status as status_id,
        sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as pending_grievances,
        sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as pending_atrs,
        sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as atr_returned_for_review,
        case 
            when admin_position_master.office_id in (49) 
                then sum(case when raw_data.status in (16,17) then 1 else 0 end)
            else null::int
        end as atr_auto_returned_from_cmo,
--        count(*) as total_count,
        raw_data.grievance_id
    from raw_data
    left join admin_user_details 
        on raw_data.assigned_to_id = admin_user_details.admin_user_id
    left join admin_position_master 
        on raw_data.assigned_to_position = admin_position_master.position_id
    left join cmo_office_master 
        on admin_position_master.office_id = cmo_office_master.office_id
    left join admin_user_role_master 
        on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join cmo_designation_master 
        on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master 
        on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    where raw_data.status not in (3,16)
    group by 
        admin_user_details.official_name,
        admin_position_master.office_id,
        cmo_office_master.office_name,
        admin_user_role_master.role_master_id,
        admin_user_role_master.role_master_name,
        cmo_designation_master.designation_name,
        cmo_sub_office_master.suboffice_name,
        admin_position_master.record_status,
        raw_data.grievance_id
) select * from user_wise_pndcy




with raw_data as (
    select grievance_master_bh_mat.*
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join grievance_master_bh_mat_2 as grievance_master_bh_mat 
        on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    where not exists (
            select 1 
            from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
              and atr_latest_14_bh_mat.current_status in (14,15)
      )
), 
user_wise_pndcy as (
    select 
        'User wise ATR Pendency' as status,
        case 
            when admin_user_details.official_name is not null
                then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
            else null
        end as name_and_esignation_of_the_user,
        case
            when cmo_sub_office_master.suboffice_name is not null
                then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
            else cmo_office_master.office_name
        end as office,
        case 
            when admin_position_master.office_id in (49) 
                then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
        end as user_role,
        admin_user_role_master.role_master_name as user_role,
        case 
            when admin_position_master.record_status = 1 then 'Active'
            when admin_position_master.record_status = 2 then 'Inactive'
            else null
        end as user_status,
        admin_position_master.record_status as status_id,
        sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as pending_grievances,
        sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as pending_atrs,
        sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as atr_returned_for_review,
        -- FIXED: Show auto-return for all offices
        sum(case when raw_data.status in (16,17) then 1 else 0 end) as atr_auto_returned_from_cmo,
        raw_data.grievance_id
    from raw_data
    left join admin_user_details 
        on raw_data.assigned_to_id = admin_user_details.admin_user_id
    left join admin_position_master 
        on raw_data.assigned_to_position = admin_position_master.position_id
    left join cmo_office_master 
        on admin_position_master.office_id = cmo_office_master.office_id
    left join admin_user_role_master 
        on admin_position_master.role_master_id = admin_user_role_master.role_master_id
    left join cmo_designation_master 
        on cmo_designation_master.designation_id = admin_position_master.designation_id
    left join cmo_sub_office_master 
        on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    where raw_data.status not in (3,16)
    group by 
        admin_user_details.official_name,
        admin_position_master.office_id,
        cmo_office_master.office_name,
        admin_user_role_master.role_master_id,
        admin_user_role_master.role_master_name,
        cmo_designation_master.designation_name,
        cmo_sub_office_master.suboffice_name,
        admin_position_master.record_status,
        raw_data.grievance_id
) 
select * from user_wise_pndcy;



--================================================================================================================================

with grievances_recieved as (
                            select COUNT(1) as grievances_recieved_cnt
                            from forwarded_latest_3_bh_mat_2 as bh
                            where 1 = 1  and bh.assigned_to_office_id = 75
                    ), atr_sent as (
                        select COUNT(1) as atr_sent_cnt,
                        coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9, 2) then 1 else 0 end), 0) as not_elgbl,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 2 then 1 else 0 end), 0) as pending_for_policy_decision
                        from atr_latest_14_bh_mat_2 as bh
                        inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                        where bm.current_status in (14,15)   and bh.assigned_by_office_id = 75
                    ), atr_pending as (
                        select COUNT(1) as atr_pending_cnt
                        from forwarded_latest_3_bh_mat_2 as bh
                        WHERE NOT EXISTS ( select 1 from atr_latest_14_bh_mat_2 as bm where bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
                          and bh.assigned_to_office_id = 75
                    ), grievance_received_other_hod as (
                            select count(1) as griev_recv_cnt_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            where 1 = 1  and bh.assigned_to_office_id = 75
                            union all
                            select COUNT(1) as grievances_recieved_cnt
                            from forwarded_latest_3_bh_mat_2 as bh
                            where 1 = 1  and bh.assigned_to_office_id = 75
                    
                    ),
                    /*, atr_sent_other_hod as (
                            select
                                count(1) as atr_sent_cnt_other_hod,
                                coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
                            from atr_latest_13_bh_mat_2 as bh
                        inner join forwarded_latest_5_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
                        where 1 = 1   and bh.assigned_by_office_id = 75
                    )*/
                    atr_sent_other_hod as (
                        select count(1) as atr_sent_cnt_other_hod  from atr_latest_13_bh_mat_2 as bh where 1 = 1   and bh.assigned_by_office_id = 75
                    ), close_other_hod as (
                            select
                                count(1) as disposed_cnt_other_hod,
                                coalesce(sum(case when bm.closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                                coalesce(sum(case when bm.closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                                coalesce(sum(case when bm.closure_reason_id not in (1, 5, 9, 2) then 1 else 0 end), 0) as not_elgbl_other_hod,
                                coalesce(sum(case when bm.closure_reason_id = 2 then 1 else 0 end), 0) as pending_for_policy_deci_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            inner join grievance_master_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                            where bm.status = 15  and bh.assigned_to_office_id = 75
                    ), atr_pending_other_hod as (
                        select
                            COUNT(1) as atr_pending_cnt_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
                                WHERE NOT EXISTS ( select 1 from atr_latest_13_bh_mat_2 as bm where bh.grievance_id = bm.grievance_id) /*and bm.current_status in (14,15)*/
                          and bh.assigned_to_office_id = 75
                    )
                    select * ,
                        '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc
                        from grievances_recieved
                        cross join atr_sent
                        cross join atr_pending
                        cross join grievance_received_other_hod
                        cross join atr_sent_other_hod
                        cross join atr_pending_other_hod
                        cross join close_other_hod;

                       
     
                       
       -------- SSM COUNT -----
                       with grievances_recieved as (
                            select COUNT(1) as grievances_recieved_cnt
                            from forwarded_latest_3_bh_mat_2 as bh
                            where 1 = 1  and bh.grievance_source = 5  and bh.assigned_to_office_id = 75
                    ), atr_sent as (
                        select COUNT(1) as atr_sent_cnt,
                        coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 2 then 1 else 0 end), 0) as pending_for_policy_decision
                        from atr_latest_14_bh_mat_2 as bh
                        inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                        where bm.current_status in (14,15)  and bh.grievance_source = 5   and bh.assigned_by_office_id = 75
                    ), atr_pending as (
                        select COUNT(1) as atr_pending_cnt
                        from forwarded_latest_3_bh_mat_2 as bh
                        WHERE NOT EXISTS ( select 1 from atr_latest_14_bh_mat_2 as bm where bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
                         and bh.grievance_source = 5   and bh.assigned_to_office_id = 75
                    ), grievance_received_other_hod as (
                    		select COUNT(1) as grievances_recieved_cnt
                            from forwarded_latest_3_bh_mat_2 as bh
                            where 1 = 1  and bh.grievance_source = 5  and bh.assigned_to_office_id = 75
                            union all
                            select count(1) as griev_recv_cnt_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            where 1 = 1  and bh.grievance_source = 5  and bh.assigned_to_office_id = 75
                    ),
                    /*, atr_sent_other_hod as (
                            select
                                count(1) as atr_sent_cnt_other_hod,
                                coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
                            from atr_latest_13_bh_mat_2 as bh
                        inner join forwarded_latest_5_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
                        where 1 = 1  and bh.grievance_source = 5   and bh.assigned_by_office_id = 75
                    )*/
                    atr_sent_other_hod as (
                        select count(1) as atr_sent_cnt_other_hod  from atr_latest_13_bh_mat_2 as bh where 1 = 1  and bh.grievance_source = 5   and bh.assigned_by_office_id = 75
                    ), close_other_hod as (
                            select
                                count(1) as disposed_cnt_other_hod,
                                coalesce(sum(case when bm.closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                                coalesce(sum(case when bm.closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                                coalesce(sum(case when bm.closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod,
                                coalesce(sum(case when bm.closure_reason_id = 2 then 1 else 0 end), 0) as pending_for_policy_deci_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            inner join grievance_master_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                            where bm.status = 15  and bh.assigned_to_office_id = 75   and bh.grievance_source = 5
                    ), atr_pending_other_hod as (
                        select
                            COUNT(1) as atr_pending_cnt_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
                                WHERE NOT EXISTS ( select 1 from atr_latest_13_bh_mat_2 as bm where bh.grievance_id = bm.grievance_id) /*and bm.current_status in (14,15)*/
                         and bh.grievance_source = 5   and bh.assigned_to_office_id = 75
                    )
                    select * ,
                        '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc
                        from grievances_recieved
                        cross join atr_sent
                        cross join atr_pending
                        cross join grievance_received_other_hod
                        cross join atr_sent_other_hod
                        cross join atr_pending_other_hod
                        cross join close_other_hod;

                       
                       
                       
                       
                       
                       
   --=========================== HOD DASHBOARD MALE FEMALE COUNT =================================================                    
  select
        '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
            from forwarded_latest_3_bh_mat_2 as gm
            left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
            where /*gm.grievance_generate_date >= '2023-06-08'
             and*/ gm.assigned_to_office_id = 75
            group by gm.applicant_gender, cdlm.domain_value)
            g1)
                g2;
             
               
               
         ---- tetsting ----      
       	select
    		'2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
            count(1) as gender_wise_count,
            gm.applicant_gender,
            cdlm.domain_value as gender_name
        from forwarded_latest_3_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where /*gm.grievance_generate_date >= '2023-06-08'
         and*/ gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value
               
     
        	
        	
     select coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt
        from atr_latest_14_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
        where bm.current_status in (14,15) and bh.assigned_by_office_id = 75   	
      union all
     select
        count(1) as disposed_cnt
    from forwarded_latest_5_bh_mat_2 as bh
    inner join grievance_master_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
    where bm.status = 15  and bh.assigned_to_office_id = 75 
        	
     ------ SSM -------
 select
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
        from forwarded_latest_3_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value)
        g1)
            g2;   	
        	
        	
        	
---=============================== HOD DASHBOARD RELIGION CASTE ====================================
SELECT
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
    'Caste' AS category,
    COUNT(1) AS total_count,
    gm.applicant_caste,
    ccm.caste_name AS social_name,
((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
FROM forwarded_latest_3_bh_mat_2 as gm
LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
WHERE /*gm.grievance_generate_date >= '2023-06-08'
 and*/ gm.assigned_to_office_id = 75
GROUP BY gm.applicant_caste, ccm.caste_name


SELECT
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
    'Religion' AS category,
    COUNT(1) AS total_count,
    gm.applicant_reigion,
    crm.religion_name AS social_name,
    ((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
from forwarded_latest_3_bh_mat_2 as gm
LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
WHERE /*gm.grievance_generate_date >= '2023-06-08'
 and */gm.assigned_to_office_id = 75
GROUP BY gm.applicant_reigion, crm.religion_name;



------- Perfect After Update------
select 
	'2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
	'Caste' AS category,
	SUM(g1.total_count)::bigint as total_count,
	g1.applicant_caste,
	g1.social_name,
	ROUND(sum(g1.percentage)::numeric, 2) as percentage
from (
	select
		/*Received From CMO*/
	    COUNT(1) AS total_count,
	    gm.applicant_caste,
	    ccm.caste_name AS social_name,
	((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
	FROM forwarded_latest_3_bh_mat_2 as gm
	LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
	WHERE gm.grievance_generate_date >= '2023-06-08'
	 and gm.assigned_to_office_id = 75
	GROUP BY gm.applicant_caste, ccm.caste_name
	union all
	select
		/*Received From Other HOD*/
	    COUNT(1) AS total_count,
	    gm.applicant_caste,
	    ccm.caste_name AS social_name,
	((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
	FROM forwarded_latest_5_bh_mat_2 as gm
	LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
	WHERE gm.grievance_generate_date >= '2023-06-08'
	 and gm.assigned_to_office_id = 75
	GROUP BY gm.applicant_caste, ccm.caste_name
) as g1
group by g1.applicant_caste, g1.social_name


-------- religion --------

select 
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
    'Religion' AS category,
	SUM(g1.total_count)::bigint as total_count,
	g1.applicant_reigion,
	g1.social_name,
	ROUND(sum(g1.percentage)::numeric, 2) as percentage
  from (
		select
			/* Received From CMO */
		    COUNT(1) AS total_count,
		    gm.applicant_reigion,
		    crm.religion_name AS social_name,
		    ((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
		from forwarded_latest_3_bh_mat_2 as gm
		LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
		WHERE gm.grievance_generate_date >= '2023-06-08'
		 and gm.assigned_to_office_id = 75
		GROUP BY gm.applicant_reigion, crm.religion_name
		union all
		select
			/* Received From Other HOD */
		    COUNT(1) AS total_count,
		    gm.applicant_reigion,
		    crm.religion_name AS social_name,
		    ((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
		from forwarded_latest_5_bh_mat_2 as gm
		LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
		WHERE gm.grievance_generate_date >= '2023-06-08'
		 and gm.assigned_to_office_id = 75
		GROUP BY gm.applicant_reigion, crm.religion_name
	) as g1
	group by g1.applicant_reigion, g1.social_name


	
---------------------------------------
---- perfect 
select
    		/*Received From CMO*/
            count(1) as gender_wise_count,
            gm.applicant_gender,
            cdlm.domain_value as gender_name
        from forwarded_latest_3_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where /*gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and*/ gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value
        union all 
        select
        	/*Received From Other HOD*/
            count(1) as gender_wise_count,
            gm.applicant_gender,
            cdlm.domain_value as gender_name
        from forwarded_latest_5_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where /*gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and*/ gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value
      


---=================================== CMO DASHBOARD FEMALE Breakdown ============================



select
'2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
        from grievance_master_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
    where gm.grievance_generate_date >= '2023-06-08'
    group by gm.applicant_gender,cdlm.domain_value)
    g1 )
        g2;


   ----- ssm
   with grievances_recieved as (
                            SELECT COUNT(1) as grievances_recieved_cnt FROM grievance_master_bh_mat_2 as gm
     where gm.grievance_source = 5
                    ), grievances_forwarded as (
                            SELECT COUNT(1) as grievances_forwarded_cnt FROM forwarded_latest_3_bh_mat_2 as bm
                             where bm.grievance_source = 5
                    ), atr_recieved as (
                            SELECT COUNT(1) as atr_recieved_cnt FROM atr_latest_14_bh_mat_2 as bm
                            INNER JOIN forwarded_latest_3_bh_mat_2 as bh ON bm.grievance_id = bh.grievance_id
                            where bm.current_status in (14,15)  and bm.grievance_source = 5
                    ), atr_pending as (
                            SELECT COUNT(1) as atr_pending_cnt FROM forwarded_latest_3_bh_mat_2 as bm
                        WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_ 	mat_2 as bh WHERE bh.grievance_id = bm.grievance_id and bh.current_status in (14,15))
                         and bm.grievance_source = 5
                    ), disposed as (
                            SELECT COUNT(1) as disposed_cnt FROM grievance_master_bh_mat_2 as gm
                            WHERE gm.status = 15  and gm.grievance_source = 5
                    ) select * , '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc
                    from grievances_recieved
                    cross join grievances_forwarded
                    cross join atr_recieved
                    cross join atr_pending
                    cross join disposed;
             
   select
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
        from grievance_master_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5
        group by gm.applicant_gender,cdlm.domain_value)
        g1 )
            g2;            
               
               
with grievances_recieved as (
            SELECT COUNT(1) as grievances_recieved_cnt FROM grievance_master_bh_mat_2 as gm

    ), grievances_forwarded as (
            SELECT COUNT(1) as grievances_forwarded_cnt FROM forwarded_latest_3_bh_mat_2 as bm

    ), atr_recieved as (
            SELECT COUNT(1) as atr_recieved_cnt FROM atr_latest_14_bh_mat_2 as bm
            INNER JOIN forwarded_latest_3_bh_mat_2 as bh ON bm.grievance_id = bh.grievance_id
            where bm.current_status in (14,15)
    ), atr_pending as (
            SELECT COUNT(1) as atr_pending_cnt FROM forwarded_latest_3_bh_mat_2 as bm
        WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bh WHERE bh.grievance_id = bm.grievance_id and bh.current_status in (14,15))

    ), disposed as (
            SELECT COUNT(1) as disposed_cnt FROM grievance_master_bh_mat_2 as gm
            WHERE gm.status = 15
    ) select * , '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc
    from grievances_recieved
    cross join grievances_forwarded
    cross join atr_recieved
    cross join atr_pending
    cross join disposed;

   
   
   
   ---============================= HOD CHART SSM DASHBOARAD ================================
   
   with grievances_recieved as (
                            select COUNT(1) as grievances_recieved_cnt
                            from forwarded_latest_3_bh_mat_2 as bh
                            where 1 = 1  and bh.grievance_source = 5  and bh.assigned_to_office_id = 75
                    ), atr_sent as (
                        select COUNT(1) as atr_sent_cnt,
                        coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl,
                        coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 2 then 1 else 0 end), 0) as pending_for_policy_decision
                        from atr_latest_14_bh_mat_2 as bh
                        inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                        where bm.current_status in (14,15)  and bh.grievance_source = 5   and bh.assigned_by_office_id = 75
                    ), atr_pending as (
                        select COUNT(1) as atr_pending_cnt
                        from forwarded_latest_3_bh_mat_2 as bh
                        WHERE NOT EXISTS ( select 1 from atr_latest_14_bh_mat_2 as bm where bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
                         and bh.grievance_source = 5   and bh.assigned_to_office_id = 75
                    ), grievance_received_other_hod as (
                            select count(1) as griev_recv_cnt_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            where 1 = 1  and bh.grievance_source = 5  and bh.assigned_to_office_id = 75
                    ),
                    /*, atr_sent_other_hod as (
                            select
                                count(1) as atr_sent_cnt_other_hod,
                                coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                                coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
                            from atr_latest_13_bh_mat_2 as bh
                        inner join forwarded_latest_5_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
                        where 1 = 1  and bh.grievance_source = 5   and bh.assigned_by_office_id = 75
                    )*/
                    atr_sent_other_hod as (
                        select count(1) as atr_sent_cnt_other_hod  from atr_latest_13_bh_mat_2 as bh where 1 = 1  and bh.grievance_source = 5   and bh.assigned_by_office_id = 75
                    ), close_other_hod as (
                            select
                                count(1) as disposed_cnt_other_hod,
                                coalesce(sum(case when bm.closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                                coalesce(sum(case when bm.closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                                coalesce(sum(case when bm.closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod,
                                coalesce(sum(case when bm.closure_reason_id = 2 then 1 else 0 end), 0) as pending_for_policy_deci_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            inner join grievance_master_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
                            where bm.status = 15  and bh.assigned_to_office_id = 75   and bh.grievance_source = 5
                    ), atr_pending_other_hod as (
                        select
                            COUNT(1) as atr_pending_cnt_other_hod
                            from forwarded_latest_5_bh_mat_2 as bh
                            left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
                                WHERE NOT EXISTS ( select 1 from atr_latest_13_bh_mat_2 as bm where bh.grievance_id = bm.grievance_id) /*and bm.current_status in (14,15)*/
                         and bh.grievance_source = 5   and bh.assigned_to_office_id = 75
                    )
                    select * ,
                        '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc
                        from grievances_recieved
                        cross join atr_sent
                        cross join atr_pending
                        cross join grievance_received_other_hod
                        cross join atr_sent_other_hod
                        cross join atr_pending_other_hod
                        cross join close_other_hod;

                       
   select
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
        from forwarded_latest_3_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where /*gm.grievance_generate_date >= '2023-06-08'
         and*/ gm.grievance_source = 5  and gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value)
        g1)
            g2;                    
 
           
 ------- real query  -------          
select
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
        from forwarded_latest_3_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value)
        g1)
            g2; 
            
           
           
  ------ perfect after testing  ------------
select
    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
    		/*Received From CMO*/
            count(1) as gender_wise_count,
            gm.applicant_gender,
            cdlm.domain_value as gender_name
        from forwarded_latest_3_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value
        union all 
        select
        	/*Received From Other HOD*/
            count(1) as gender_wise_count,
            gm.applicant_gender,
            cdlm.domain_value as gender_name
        from forwarded_latest_5_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value
      )
        g1)
            g2; 
            
    ------------------------------------------------------ HOD DASHBOARD AGE CHART -------------------------
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
                FROM forwarded_latest_3_bh_mat_2 as gm
                LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
                WHERE gm.applicant_age IS NOT NULL  and gm.grievance_source = 5   and gm.assigned_to_office_id = 75
                )
                SELECT
                    '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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

               
               
     -------- PERFECT After Update ------- HOD DASHBOARD ------------------ NEW UPDATE ------------
select 
	'2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
   		SUM(g1.total_count)::bigint as total_count,
   		SUM(g1.total_male_count)::bigint as total_male_count,
   		SUM(g1.total_female_count)::bigint as total_female_count,
   		SUM(g1.age_below_18)::bigint as age_below_18,
   		CASE WHEN g1.total_count > 0 THEN round((g1.age_below_18::NUMERIC / g1.total_count::NUMERIC) * 100, 2) ELSE 0 END AS age_below_18_percentage,
   		SUM(g1.age_18_30)::bigint as age_18_30,
    	CASE WHEN g1.total_count > 0 THEN round((g1.age_18_30::NUMERIC / g1.total_count::NUMERIC) * 100, 2) ELSE 0 END AS age_18_30_percentage,
   		SUM(g1.age_31_45)::bigint as age_31_45,
    	CASE WHEN g1.total_count > 0 THEN round((g1.age_31_45::NUMERIC / g1.total_count::NUMERIC) * 100, 2) ELSE 0 END AS age_31_45_percentage,
   		SUM(g1.age_46_60)::bigint as age_46_60,
    	CASE WHEN g1.total_count > 0 THEN round((g1.age_46_60::NUMERIC / g1.total_count::NUMERIC) * 100, 2) ELSE 0 END AS age_46_60_percentage,
   		SUM(g1.age_above_60)::bigint as age_above_60,
    	CASE WHEN g1.total_count > 0 THEN round((g1.age_above_60::NUMERIC / g1.total_count::NUMERIC) * 100, 2) ELSE 0 END AS age_above_60_percentage,
   		SUM(g1.age_below_18_male)::bigint as age_below_18_male,
    	CASE WHEN g1.total_male_count > 0 THEN round((g1.age_below_18_male::NUMERIC / g1.total_male_count::NUMERIC) * 100, 2) ELSE 0 END AS age_below_18_male_percentage,
   		SUM(g1.age_18_30_male)::bigint as age_18_30_male,
    	CASE WHEN g1.total_male_count > 0 THEN round((g1.age_18_30_male::NUMERIC / g1.total_male_count::NUMERIC) * 100, 2) ELSE 0 END AS age_18_30_male_percentage,
   		SUM(g1.age_31_45_male)::bigint as age_31_45_male,
    	CASE WHEN g1.total_male_count > 0 THEN round((g1.age_31_45_male::NUMERIC / g1.total_male_count::NUMERIC) * 100, 2) ELSE 0 END AS age_31_45_male_percentage,
   		SUM(g1.age_46_60_male)::bigint as age_46_60_male,
    	CASE WHEN g1.total_male_count > 0 THEN round((g1.age_46_60_male::NUMERIC / g1.total_male_count::NUMERIC) * 100, 2) ELSE 0 END AS age_46_60_male_percentage,
   		SUM(g1.age_above_60_male)::bigint as age_above_60_male,
   	 	CASE WHEN g1.total_male_count > 0 THEN round((g1.age_above_60_male::NUMERIC / g1.total_male_count::NUMERIC) * 100, 2) ELSE 0 END AS age_above_60_male_percentage,
   		SUM(g1.age_below_18_female)::bigint as age_below_18_female,
    	CASE WHEN g1.total_female_count > 0 THEN round((g1.age_below_18_female::NUMERIC / g1.total_female_count::NUMERIC) * 100, 2) ELSE 0 END AS age_below_18_female_percentage,
   		SUM(g1.age_18_30_female)::bigint as age_18_30_female,
    	CASE WHEN g1.total_female_count > 0 THEN round((g1.age_18_30_female::NUMERIC / g1.total_female_count::NUMERIC) * 100, 2) ELSE 0 END AS age_18_30_female_percentage,
   		SUM(g1.age_31_45_female)::bigint as age_31_45_female,
    	CASE WHEN g1.total_female_count > 0 THEN round((g1.age_31_45_female::NUMERIC / g1.total_female_count::NUMERIC) * 100, 2) ELSE 0 END AS age_31_45_female_percentage,
   		SUM(g1.age_46_60_female)::bigint as age_46_60_female,
    	CASE WHEN g1.total_female_count > 0 THEN round((g1.age_46_60_female::NUMERIC / g1.total_female_count::NUMERIC) * 100, 2) ELSE 0 END AS age_46_60_female_percentage,
   		SUM(g1.age_above_60_female)::bigint as age_above_60_female,
    	CASE WHEN g1.total_female_count > 0 THEN round((g1.age_above_60_female::NUMERIC / g1.total_female_count::NUMERIC) * 100, 2) ELSE 0 END AS age_above_60_female_percentage
   from (
        select
        	/* Received From CMO */
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
    WHERE gm.applicant_age IS NOT NULL  and gm.grievance_source = 5   and gm.assigned_to_office_id = 75
    union all
    select
    	/* Received From Other HOD */
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
    FROM forwarded_latest_5_bh_mat_2 as gm
    LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
    WHERE gm.applicant_age IS NOT NULL  and gm.grievance_source = 5  and gm.assigned_to_office_id = 75
) as g1
group by g1.total_count, g1.age_below_18, g1.age_18_30, g1.age_31_45, g1.age_46_60, g1.age_above_60, g1.total_male_count, g1.age_below_18_male, 
g1.age_18_30_male, g1.age_31_45_male, g1.age_46_60_male, g1.age_above_60_male, g1.total_female_count, g1.age_below_18_female, g1.age_18_30_female,
g1.age_31_45_female, g1.age_46_60_female, g1.age_above_60_female

               
               
   select
    		/*Received From CMO*/
            count(1) as gender_wise_count,
            gm.applicant_gender,
            cdlm.domain_value as gender_name
        from forwarded_latest_3_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value
        union all 
        select
        	/*Received From Other HOD*/
            count(1) as gender_wise_count,
            gm.applicant_gender,
            cdlm.domain_value as gender_name
        from forwarded_latest_5_bh_mat_2 as gm
        left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
        where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75
        group by gm.applicant_gender, cdlm.domain_value
        
        
        
        
        
        
 -----------------------------------------------------------------------------------------
        ---------------------- QUERY CHECKING PART -----------------------------
 ------------------------------------------------------------------------------------------
        
        
         select
                        '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
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
                                /* Received From CMO */
                                count(1) as gender_wise_count,
                                gm.applicant_gender,
                                cdlm.domain_value as gender_name
                            from forwarded_latest_3_bh_mat_2 as gm
                            left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
                            where /*gm.grievance_generate_date >= '2023-06-08'
                             and gm.grievance_source = 5  and*/ gm.assigned_to_office_id = 28
                            group by gm.applicant_gender, cdlm.domain_value
                            union all
                            select
                                /* Received From Other HOD */
                                count(1) as gender_wise_count,
                                gm.applicant_gender,
                                cdlm.domain_value as gender_name
                            from forwarded_latest_5_bh_mat_2 as gm
                            left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
                            where /*gm.grievance_generate_date >= '2023-06-08'
                             and gm.grievance_source = 5  and*/ gm.assigned_to_office_id = 28
                            group by gm.applicant_gender, cdlm.domain_value)
                        g1)
                    g2

                    
                    
                    
   ------------------
                    WITH date_range AS (
                    SELECT
                        current_date - INTERVAL '1 day' AS end_date,
                        current_date - INTERVAL '7 days' AS start_date
                    ),
                    days AS (
                        SELECT generate_series(
                            (SELECT start_date FROM date_range),
                            (SELECT end_date FROM date_range),
                            INTERVAL '1 day'
                        )::date AS day_date
                    ),
                    grievances_recieved AS (
                        SELECT
                            bh.assigned_on::date AS day_date,
                            COUNT(*) AS grievances_recieved_cnt
                        FROM forwarded_latest_3_bh_mat_2 as bh
                        WHERE bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    ),
                    atr_sent AS (
                        SELECT
                            bh.assigned_on::date AS day_date,
                            COUNT(*) AS atr_sent_cnt
                        FROM atr_latest_14_bh_mat_2 bh
                        INNER JOIN forwarded_latest_3_bh_mat_2 as bm
                            ON bm.grievance_id = bh.grievance_id
                        WHERE bm.current_status IN (14,15)
                        AND bh.assigned_by_office_id in (75)  /* SSM CALL CENTER */
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    ),
                    grievance_received_other_hod AS (
                        SELECT
                            bh.assigned_on::date AS day_date,
                            COUNT(*) AS griev_recv_cnt_other_hod
                        FROM forwarded_latest_5_bh_mat_2 as bh
                        WHERE bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    ),
                    atr_pending_other_hod AS (
                        SELECT
                            bh.assigned_on::date AS day_date,
                            COUNT(*) AS atr_pending_cnt_other_hod
                        FROM forwarded_latest_5_bh_mat_2 as bh
                        LEFT JOIN pending_for_other_hod_wise_mat_2 bm
                            ON bh.grievance_id = bm.grievance_id
                        WHERE NOT EXISTS (
                            SELECT 1 FROM atr_latest_13_bh_mat_2 as bm2
                            WHERE bm2.grievance_id = bh.grievance_id
                        )
                        AND bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    )
                    SELECT
                        '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
                        TO_CHAR(d.day_date, 'DD-MM-YYYY') AS day_date,
--                        d.day_date,
                        COALESCE(gr.grievances_recieved_cnt, 0) AS grievances_recieved_cnt,
                        COALESCE(at.atr_sent_cnt, 0) AS atr_sent_cnt,
                        COALESCE(oh.griev_recv_cnt_other_hod, 0) AS griev_recv_cnt_other_hod,
                        COALESCE(ap.atr_pending_cnt_other_hod, 0) AS atr_pending_cnt_other_hod
                    FROM days d
                    LEFT JOIN grievances_recieved gr ON gr.day_date = d.day_date
                    LEFT JOIN atr_sent at ON at.day_date = d.day_date
                    LEFT JOIN grievance_received_other_hod oh ON oh.day_date = d.day_date
                    LEFT JOIN atr_pending_other_hod ap ON ap.day_date = d.day_date
                    ORDER BY d.day_date DESC;

                   
-------------------------------------------------------------------------------------------------
                   
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
                FROM {forwarded_latest_3_bh_mat_variable} as gm
                LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
                WHERE gm.applicant_age IS NOT NULL {ssm_id_p} {dept_id_p}
                union all
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
                FROM {forwarded_latest_3_bh_mat_variable} as gm
                LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
                WHERE gm.applicant_age IS NOT NULL {ssm_id_p} {dept_id_p}
                )
                SELECT 
                    '{refresh_time}'::timestamp as refresh_time_utc,
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
                FROM age_gender_counts
                
                
                
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
                FROM forwarded_latest_3_bh_mat_2 as gm
                LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
                WHERE gm.applicant_age IS NOT NULL  and gm.grievance_source = 5   and gm.assigned_to_office_id = 28
                union all
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
                FROM forwarded_latest_5_bh_mat_2 as gm
                LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_code = gm.applicant_gender AND cdlm.domain_type = 'gender'
                WHERE gm.applicant_age IS NOT NULL  and gm.grievance_source = 5   and gm.assigned_to_office_id = 28
                )
                SELECT
                    '2025-12-16 16:30:02.006500+00:00'::timestamp as refresh_time_utc,
                    SUM(total_count)::bigint as total_count,
                    SUM(total_male_count)::bigint as total_male_count,
                    SUM(total_female_count)::bigint as total_female_count,
                    SUM(age_below_18)::bigint as age_below_18,
                    SUM(age_18_30)::bigint as age_18_30,
                    SUM(age_31_45)::bigint as age_31_45,
                    SUM(age_46_60)::bigint as age_46_60,
                    SUM(age_below_18_male)::bigint as age_below_18_male,
                    SUM(age_above_60)::bigint as age_above_60,
                    SUM(age_18_30_male)::bigint as age_18_30_male,
                    SUM(age_46_60_female)::bigint as age_46_60_female,
                    SUM(age_18_30_female)::bigint as age_18_30_female,
                    SUM(age_above_60_female)::bigint as age_above_60_female,
                    SUM(age_below_18_female)::bigint as age_below_18_female,
                    SUM(age_above_60_male)::bigint as age_above_60_male,
                    SUM(age_46_60_male)::bigint as age_46_60_male,
                    SUM(age_31_45_female)::bigint as age_31_45_female,
                    SUM(age_31_45_male)::bigint as age_31_45_male/*,
                    CASE WHEN total_count > 0 THEN (age_below_18 / total_count::float) * 100 ELSE 0 END AS age_below_18_percentage,
                    CASE WHEN total_count > 0 THEN (age_18_30 / total_count::float) * 100 ELSE 0 END AS age_18_30_percentage,
                    CASE WHEN total_count > 0 THEN (age_31_45 / total_count::float) * 100 ELSE 0 END AS age_31_45_percentage,
                    CASE WHEN total_count > 0 THEN (age_46_60 / total_count::float) * 100 ELSE 0 END AS age_46_60_percentage,
                    CASE WHEN total_count > 0 THEN (age_above_60 / total_count::float) * 100 ELSE 0 END AS age_above_60_percentage,
                    CASE WHEN total_male_count > 0 THEN (age_below_18_male / total_male_count::float) * 100 ELSE 0 END AS age_below_18_male_percentage,
                    CASE WHEN total_male_count > 0 THEN (age_18_30_male / total_male_count::float) * 100 ELSE 0 END AS age_18_30_male_percentage,
                    CASE WHEN total_male_count > 0 THEN (age_31_45_male / total_male_count::float) * 100 ELSE 0 END AS age_31_45_male_percentage,
                    CASE WHEN total_male_count > 0 THEN (age_46_60_male / total_male_count::float) * 100 ELSE 0 END AS age_46_60_male_percentage,
                    CASE WHEN total_male_count > 0 THEN (age_above_60_male / total_male_count::float) * 100 ELSE 0 END AS age_above_60_male_percentage,
                    CASE WHEN total_female_count > 0 THEN (age_below_18_female / total_female_count::float) * 100 ELSE 0 END AS age_below_18_female_percentage,
                    CASE WHEN total_female_count > 0 THEN (age_18_30_female / total_female_count::float) * 100 ELSE 0 END AS age_18_30_female_percentage,
                    CASE WHEN total_female_count > 0 THEN (age_31_45_female / total_female_count::float) * 100 ELSE 0 END AS age_31_45_female_percentage,
                    CASE WHEN total_female_count > 0 THEN (age_46_60_female / total_female_count::float) * 100 ELSE 0 END AS age_46_60_female_percentage,
                    CASE WHEN total_female_count > 0 THEN (age_above_60_female / total_female_count::float) * 100 ELSE 0 END AS age_above_60_female_percentage*/
                FROM age_gender_counts
--                group by total_count, age_below_18, age_18_30, age_31_45, age_46_60,age_above_60,age_below_18_male,age_18_30_male,
--                age_31_45_male,age_46_60_male,age_above_60_male,age_below_18_female,age_18_30_female,age_31_45_female,age_46_60_female, age_above_60_female, total_male_count, total_female_count

                
                
                ---------------------------------------------
                
                
                
     select
        '2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
        'Religion' AS category,
        SUM(g1.total_count)::bigint as total_count,
        g1.applicant_reigion,
        g1.social_name,
        round((SUM(g1.total_count) * 100.0) / SUM(SUM(g1.total_count)) OVER (), 2) AS percentage
--        ROUND(sum(g1.percentage)::numeric, 2) as percentage
        from (
            select
                /* Received From CMO */
                COUNT(1) AS total_count,
                gm.applicant_reigion,
                crm.religion_name AS social_name/*,
                ((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage*/
            from forwarded_latest_3_bh_mat_2 as gm
            LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
            WHERE gm.grievance_generate_date >= '2023-06-08'
             and gm.assigned_to_office_id = 28
            GROUP BY gm.applicant_reigion, crm.religion_name
            union all
            select
                /* Received From Other HOD */
                COUNT(1) AS total_count,
                gm.applicant_reigion,
                crm.religion_name AS social_name/*,
                ((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage*/
            from forwarded_latest_5_bh_mat_2 as gm
            LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
            WHERE gm.grievance_generate_date >= '2023-06-08'
             and gm.assigned_to_office_id = 28
            GROUP BY gm.applicant_reigion, crm.religion_name
        ) as g1
        group by g1.applicant_reigion, g1.social_name

        
        
        
   with total_rece_cmo as (
   	select
        /* Received From CMO */
        COUNT(1) AS total_count_cmo,
        gm.applicant_reigion
    from forwarded_latest_3_bh_mat_2 as gm
    WHERE gm.grievance_generate_date >= '2023-06-08' and gm.assigned_to_office_id = 28
    GROUP BY gm.applicant_reigion
   ), total_rece_other_hod as (
   		select
            /* Received From Other HOD */
            COUNT(1) AS total_count_other,
            gm.applicant_reigion
        from forwarded_latest_5_bh_mat_2 as gm
        left join cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
        WHERE gm.grievance_generate_date >= '2023-06-08' and gm.assigned_to_office_id = 28
        GROUP BY gm.applicant_reigion
   ) select 
   		'2025-12-15 16:30:01.392671+00:00'::timestamp as refresh_time_utc,
   		'Religion' AS category,
   		SUM(COALESCE(total_rece_cmo.total_count_cmo, 0) + COALESCE(total_rece_other_hod.total_count_other, 0))::bigint AS total_count,
   		total_rece_cmo.applicant_reigion,
   		crm.religion_name AS social_name,
   		ROUND((SUM(COALESCE(total_rece_cmo.total_count_cmo, 0) + COALESCE(total_rece_other_hod.total_count_other, 0)) * 100.0) 
   				/ SUM(SUM(COALESCE(total_rece_cmo.total_count_cmo, 0) + COALESCE(total_rece_other_hod.total_count_other, 0))) OVER (), 2) AS percentage
	from total_rece_cmo 
	left join total_rece_other_hod on total_rece_other_hod.applicant_reigion = total_rece_cmo.applicant_reigion
	left join cmo_religion_master crm ON crm.religion_id = COALESCE(total_rece_other_hod.applicant_reigion, total_rece_cmo.applicant_reigion)
GROUP BY total_rece_cmo.applicant_reigion, crm.religion_name;
   		








WITH date_range AS (
        SELECT 
            current_date - INTERVAL '1 day' AS end_date,
            current_date - INTERVAL '7 days' AS start_date
        ),
        days AS (
            SELECT generate_series(
                (SELECT start_date FROM date_range),
                (SELECT end_date FROM date_range),
                INTERVAL '1 day'
            )::date AS month
        ),
        grievances_recieved AS (
            SELECT 
                bh.assigned_on::date AS month,
                COUNT(*) AS grievances_recieved_cnt
            FROM forwarded_latest_3_bh_mat_2 as bh
            WHERE bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */ 
            AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
            AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
            GROUP BY 1
        ),
        atr_sent AS (
            SELECT 
                bh.assigned_on::date AS month,
                COUNT(*) AS atr_sent_cnt
            FROM atr_latest_14_bh_mat_2 bh
            INNER JOIN forwarded_latest_3_bh_mat_2 as bm 
                ON bm.grievance_id = bh.grievance_id
            WHERE bm.current_status IN (14,15)
            AND bh.assigned_by_office_id in (75)  /* SSM CALL CENTER */ 
            AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
            AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
            GROUP BY 1
        ),
        grievance_received_other_hod AS (
            SELECT 
                bh.assigned_on::date AS month,
                COUNT(*) AS griev_recv_cnt_other_hod
            FROM forwarded_latest_5_bh_mat_2 as bh
            WHERE bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */ 
            AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
            AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
            GROUP BY 1
        ),
        atr_pending_other_hod AS (
            SELECT
                bh.assigned_on::date AS month,
                COUNT(*) AS atr_pending_cnt_other_hod
            FROM forwarded_latest_5_bh_mat_2 as bh
            LEFT JOIN pending_for_other_hod_wise_mat_2 bm 
                ON bh.grievance_id = bm.grievance_id
            WHERE NOT EXISTS (
                SELECT 1 FROM atr_latest_13_bh_mat_2 as bm2
                WHERE bm2.grievance_id = bh.grievance_id
            )
            AND bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */ 
            AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
            AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
            GROUP BY 1
        )
        SELECT 
            '2025-12-16 16:30:02.006500+00:00'::timestamp as refresh_time_utc,
            to_char(d.month, 'DD-MM-YYYY') as month,
            SUM(COALESCE(gr.grievances_recieved_cnt, 0) + COALESCE(oh.griev_recv_cnt_other_hod, 0)) AS grievances_recieved_cnt,
            SUM(COALESCE(at.atr_sent_cnt, 0) + COALESCE(ap.atr_pending_cnt_other_hod, 0)) AS atr_sent_cnt
        FROM days d
        LEFT JOIN grievances_recieved gr ON gr.month = d.month
        LEFT JOIN atr_sent at ON at.month = d.month
        LEFT JOIN grievance_received_other_hod oh ON oh.month = d.month
        LEFT JOIN atr_pending_other_hod ap ON ap.month = d.month
        group by d.month
        ORDER BY d.month desc
        
        
        
        WITH date_range AS (
                    SELECT 
                        current_date - INTERVAL '1 day' AS end_date,
                        current_date - INTERVAL '7 days' AS start_date
                    ),
                    days AS (
                        SELECT generate_series(
                            (SELECT start_date FROM date_range),
                            (SELECT end_date FROM date_range),
                            INTERVAL '1 day'
                        )::date AS month
                    ),
                    grievances_recieved AS (
                        SELECT 
                            bh.assigned_on::date AS month,
                            COUNT(*) AS grievances_recieved_cnt
                        FROM forwarded_latest_3_bh_mat_2 as bh
                        WHERE bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */ 
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    ),
                    atr_sent AS (
                        SELECT 
                            bh.assigned_on::date AS month,
                            COUNT(*) AS atr_sent_cnt
                        FROM atr_latest_14_bh_mat_2 bh
                        INNER JOIN forwarded_latest_3_bh_mat_2 as bm 
                            ON bm.grievance_id = bh.grievance_id
                        WHERE bm.current_status IN (14,15)
                        AND bh.assigned_by_office_id in (75)  /* SSM CALL CENTER */ 
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    ),
                    grievance_received_other_hod AS (
                        SELECT 
                            bh.assigned_on::date AS month,
                            COUNT(*) AS griev_recv_cnt_other_hod
                        FROM forwarded_latest_5_bh_mat_2 as bh
                        WHERE bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */ 
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    ),
                    atr_pending_other_hod AS (
                        SELECT
                            bh.assigned_on::date AS month,
                            COUNT(*) AS atr_pending_cnt_other_hod
                        FROM forwarded_latest_5_bh_mat_2 as bh
                        LEFT JOIN pending_for_other_hod_wise_mat_2 bm 
                            ON bh.grievance_id = bm.grievance_id
                        WHERE NOT EXISTS (
                            SELECT 1 FROM atr_latest_13_bh_mat_2 as bm2
                            WHERE bm2.grievance_id = bh.grievance_id
                        )
                        AND bh.assigned_to_office_id in (75)  /* SSM CALL CENTER */ 
                        AND bh.assigned_on::date >= (SELECT start_date FROM date_range)
                        AND bh.assigned_on::date <= (SELECT end_date FROM date_range)
                        GROUP BY 1
                    )
                    SELECT 
                        '2025-12-16 16:30:02.006500+00:00'::timestamp as refresh_time_utc,
                        to_char(d.month, 'DD-MM-YYYY') as month,
                        COALESCE(gr.grievances_recieved_cnt, 0) AS grievances_recieved_cnt,
                        COALESCE(at.atr_sent_cnt, 0) AS atr_sent_cnt,
                        COALESCE(oh.griev_recv_cnt_other_hod, 0) AS griev_recv_cnt_other_hod,
                        COALESCE(ap.atr_pending_cnt_other_hod, 0) AS atr_pending_cnt_other_hod
                    FROM days d
                    LEFT JOIN grievances_recieved gr ON gr.month = d.month
                    LEFT JOIN atr_sent at ON at.month = d.month
                    LEFT JOIN grievance_received_other_hod oh ON oh.month = d.month
                    LEFT JOIN atr_pending_other_hod ap ON ap.month = d.month
                    ORDER BY d.month DESC;
        
        
        
        
        
   ------------------------------------------------------------------------------------------------------------
select
	'2025-12-17 16:30:01.787016+00:00'::timestamp as refresh_time_utc,
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
--        MAX(CASE WHEN g1.applicant_gender = 1  THEN g1.gender_wise_count END) AS grievances_recieved_male,
        MAX(CASE WHEN g1.applicant_gender = 1  THEN SUM(g1.gender_wise_count)::bigint END) AS grievances_recieved_male,
        MAX(CASE WHEN g1.applicant_gender = 2  THEN SUM(g1.gender_wise_count)::bigint END) AS grievances_recieved_female,
        MAX(CASE WHEN g1.applicant_gender = 3  THEN SUM(g1.gender_wise_count)::bigint END) AS grievances_recieved_others,
        MAX(CASE WHEN g1.applicant_gender is null  THEN SUM(g1.gender_wise_count)::bigint END) AS grievances_recived_no_gender
    from (select
            /* Received From CMO */
        count(1) as gender_wise_count,
        gm.applicant_gender,
        cdlm.domain_value as gender_name
    from forwarded_latest_3_bh_mat_2 as gm
    left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
    where gm.grievance_generate_date >= '2023-06-08' 
     and gm.grievance_source = 5  and gm.assigned_to_office_id = 75 
    group by gm.applicant_gender, cdlm.domain_value
    union all 
    select
        /* Received From Other HOD */
        count(1) as gender_wise_count,
        gm.applicant_gender,
        cdlm.domain_value as gender_name
    from forwarded_latest_5_bh_mat_2 as gm
    left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
    where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75 
        group by gm.applicant_gender, cdlm.domain_value) 
    g1) 
g2




select
	'2025-12-17 16:30:01.787016+00:00'::timestamp as refresh_time_utc,
    g2.total_count,
    g2.grievances_recieved_male,
    round((g2.grievances_recieved_male::numeric/g2.total_count)* 100, 0) as grievances_recieved_male_percentage,
    g2.grievances_recieved_female,
    round((g2.grievances_recieved_female::numeric/g2.total_count)* 100, 0) as grievances_recieved_female_percentage,
    g2.grievances_recieved_others,
    round((g2.grievances_recieved_others::numeric/g2.total_count)* 100, 0) as grievances_recieved_others_percentage,
    g2.grievances_recived_no_gender,
    round((g2.grievances_recived_no_gender::numeric/g2.total_count)* 100, 0) as grievances_recived_no_gender_percentage
from
    (select
        SUM(g1.gender_wise_count)::bigint as total_count,
        SUM(g1.grievances_recieved_male)::bigint as grievances_recieved_male,
        SUM(g1.grievances_recieved_female)::bigint as grievances_recieved_female,
        SUM(g1.grievances_recieved_others)::bigint as grievances_recieved_others,
        SUM(g1.grievances_recived_no_gender)::bigint as grievances_recived_no_gender
    from (select
            /* Received From CMO */
	        COUNT(*) AS gender_wise_count,
		    COUNT(*) FILTER (WHERE gm.applicant_gender = 1) AS grievances_recieved_male,
		    COUNT(*) FILTER (WHERE gm.applicant_gender = 2) AS grievances_recieved_female,
		    COUNT(*) FILTER (WHERE gm.applicant_gender = 3) AS grievances_recieved_others,
		    COUNT(*) FILTER (WHERE gm.applicant_gender IS NULL) AS grievances_recived_no_gender,
		    gm.applicant_gender,
		    cdlm.domain_value as gender_name
		FROM forwarded_latest_3_bh_mat_2 gm
		left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
		WHERE gm.grievance_generate_date >= '2023-06-08'
		  AND gm.grievance_source = 5 AND gm.assigned_to_office_id = 75
		  group by gm.applicant_gender, cdlm.domain_value
    union all 
    select
        /* Received From Other HOD */
        count(*) as gender_wise_count,
        COUNT(*) FILTER (WHERE gm.applicant_gender = 1) AS grievances_recieved_male,
	    COUNT(*) FILTER (WHERE gm.applicant_gender = 2) AS grievances_recieved_female,
	    COUNT(*) FILTER (WHERE gm.applicant_gender = 3) AS grievances_recieved_others,
	    COUNT(*) FILTER (WHERE gm.applicant_gender IS NULL) AS grievances_recived_no_gender,
        gm.applicant_gender,
        cdlm.domain_value as gender_name
    from forwarded_latest_5_bh_mat_2 as gm
    left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
    where gm.grievance_generate_date >= '2023-06-08'
         and gm.grievance_source = 5  and gm.assigned_to_office_id = 75 
        group by gm.applicant_gender, cdlm.domain_value) 
    g1) 
g2





---------------------------------------------------------------------

with griev_forwarded as (
    select 
        forwarded_latest_3_bh_mat.assigned_to_position,
        forwarded_latest_3_bh_mat.assigned_to_id,
        apm.role_master_id,
        count(1) as assigned
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_position 
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) and apm.role_master_id in (4,5) /* SSM CALL CENTER */  and forwarded_latest_3_bh_mat.grievance_source in (5) 
    group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, apm.role_master_id
    union all
    select
        bh.next_status_assigned_to_position as assigned_to_position,
        bh.next_status_assigned_to_id as assigned_to_id,
        apm.role_master_id,
        count(distinct forwarded_latest_3_bh_mat.grievance_id) as total_assigned
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
    inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
    inner join admin_position_master apm on apm.position_id = bh.assigned_to_position 
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /*and apm.role_master_id in (5,6)*/ /* SSM CALL CENTER */  and forwarded_latest_3_bh_mat.grievance_source in (5) 
    and bh.previous_status = 3 
    and bh.next_status IN (4, 7) 
    and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
    group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id, apm.role_master_id
), griev_yet_to_assigned as (
        select 
            md.assigned_to_position,
            md.assigned_to_id,
            count(1) as yet_to_assigned
        from master_district_block_grv md
        where md.grievance_id > 0
        and md.status in (4) 
        and md.assigned_to_office_id = 75 /* SSM CALL CENTER */  and md.grievance_source in (5) 
        group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
        select 
            /*'Admin & Nodal' as role,*/
            albm.assigned_by_id,
            albm.assigned_by_position,
            albm.assigned_by_office_id,
            count(1) as atr_submitted
        from atr_latest_14_bh_mat_2 as albm
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = albm.grievance_id 
        inner join admin_position_master apm on apm.position_id = albm.assigned_by_position 
        where apm.role_master_id in (4,5) and forwarded_latest_3_bh_mat.current_status in (14,15) and albm.assigned_by_office_id in (75) /* SSM CALL CENTER */  and forwarded_latest_3_bh_mat.grievance_source in (5) 
        group by apm.role_master_id, albm.assigned_by_position, albm.assigned_by_id, albm.assigned_by_office_id	
        /*union all
        select 
            /*'Restricted' as role,*/
            flbm.assigned_by_position,
            flbm.assigned_by_id,
            flbm.assigned_by_office_id,
            flbm.role_master_id,
            count(*) as atr_submitted
        from atr_latest_4_11_bh_mat_2 as flbm  
        where flbm.assigned_to_office_id in (75) /* SSM CALL CENTER */  and flbm.grievance_source in (5) 
        group by flbm.assigned_by_position, flbm.assigned_by_id, flbm.assigned_by_office_id, flbm.role_master_id*/
), atr_sent_restrict as (
        select 
            /*'Restricted' as role,*/
            flbm.assigned_by_id,
            flbm.assigned_by_position,
            flbm.assigned_by_office_id,
            count(*) as atr_submitted
        from atr_latest_4_11_bh_mat_2 as flbm  
        where flbm.assigned_to_office_id in (75) /* SSM CALL CENTER */  and flbm.grievance_source in (5) 
        group by flbm.assigned_by_position, flbm.assigned_by_id, flbm.assigned_by_office_id
), atr_yet_to_sent as (
        select 
            md.assigned_to_position,
            md.assigned_to_id,
            md.assigned_to_office_id,
            apm2.role_master_id,
            count(1) as yet_atr_not_submitted
        from master_district_block_grv md
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (6,11,13)
        and md.assigned_to_office_id in (75) /* SSM CALL CENTER */  and md.grievance_source in (5) 
        group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id, apm2.role_master_id
    )	
    select 
        '2025-12-18 16:30:01.947310+00:00'::timestamp as refresh_time_utc,
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
        sum(coalesce(griev_forwarded.assigned::int, 0) + coalesce(griev_yet_to_assigned.yet_to_assigned::int, 0)) as grievance_total,
        case 
            when admin_position_master.role_master_id in (4,5) then coalesce(atr_sent.atr_submitted, 0)
            when admin_position_master.role_master_id in (6) then coalesce(atr_sent_restrict.atr_submitted, 0)
            else 0
        end as atr_sent,
        coalesce(atr_yet_to_sent.yet_atr_not_submitted, 0) as atr_not_submitted,
        case 
            when admin_position_master.role_master_id in (4,5) then sum(coalesce(atr_sent.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0))
            when admin_position_master.role_master_id in (6) then sum(coalesce(atr_sent_restrict.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0))
            else 0
        end as atr_total
--        coalesce(atr_sent.atr_submitted, 0) as atr_sent,
--        coalesce(atr_sent_restrict.atr_submitted, 0) as atr_sent,
--        sum(coalesce(atr_sent.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0)) as atr_total
    from griev_forwarded
        left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = griev_forwarded.assigned_to_id 
        left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_forwarded.assigned_to_id 
        left join atr_sent on atr_sent.assigned_by_id = griev_forwarded.assigned_to_id
        left join atr_sent_restrict on atr_sent_restrict.assigned_by_id = griev_forwarded.assigned_to_id
        left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
        left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
        left join cmo_office_master on cmo_office_master.office_id = admin_position_master.office_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name,
        cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted,
        atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id, admin_position_master.position_id, 
        admin_position_master.role_master_id, atr_sent_restrict.atr_submitted
    order by
        case
            when admin_position_master.role_master_id = 4 then 1
            when admin_position_master.role_master_id = 5 then 2
            when admin_position_master.role_master_id = 6 then 3
            else 4
        end   
 
        
        -------- TETSING --------
with griev_forwarded as (
    select 
        forwarded_latest_3_bh_mat.assigned_to_position,
        forwarded_latest_3_bh_mat.assigned_to_id,
        apm.role_master_id,
        count(1) as assigned
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join admin_position_master apm on apm.position_id = forwarded_latest_3_bh_mat.assigned_to_position 
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) and apm.role_master_id in (4,5) /* SSM CALL CENTER */  and forwarded_latest_3_bh_mat.grievance_source in (5) 
    group by forwarded_latest_3_bh_mat.assigned_to_position, forwarded_latest_3_bh_mat.assigned_to_id, apm.role_master_id
    union all
    select
        bh.next_status_assigned_to_position as assigned_to_position,
        bh.next_status_assigned_to_id as assigned_to_id,
        apm.role_master_id,
        count(distinct forwarded_latest_3_bh_mat.grievance_id) as total_assigned
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
    inner join forwarded_latest_3_4_bh_mat_2 as bh on forwarded_latest_3_bh_mat.grievance_id = bh.grievance_id 
    inner join admin_position_master apm on apm.position_id = bh.assigned_to_position 
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /*and apm.role_master_id in (5,6)*/ /* SSM CALL CENTER */  and forwarded_latest_3_bh_mat.grievance_source in (5) 
    and bh.previous_status = 3 
    and bh.next_status IN (4, 7) 
    and forwarded_latest_3_bh_mat.assigned_to_office_id  = bh.next_status_assigned_to_office
    group by bh.next_status_assigned_to_position, bh.next_status_assigned_to_id, apm.role_master_id
), griev_yet_to_assigned as (
        select 
            md.assigned_to_position,
            md.assigned_to_id,
            count(1) as yet_to_assigned,
            count(1) filter (where (CURRENT_DATE - md.updated_on::date) > 7) as is_more_than_7_days
--            case 
--            	when (CURRENT_DATE - md.updated_on::date) > 7 then 1 
--            	else 0
--            end as is_more_than_7_days
        from master_district_block_grv md
        where md.grievance_id > 0
        and md.status in (4) 
        and md.assigned_to_office_id = 75
        /* SSM CALL CENTER */  and md.grievance_source in (5) 
        group by md.assigned_to_position, md.assigned_to_id
), atr_sent as (
        select 
            /*'Admin & Nodal' as role,*/
            albm.assigned_by_id,
            albm.assigned_by_position,
            albm.assigned_by_office_id,
            count(1) as atr_submitted
        from atr_latest_14_bh_mat_2 as albm
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = albm.grievance_id 
        inner join admin_position_master apm on apm.position_id = albm.assigned_by_position 
        where apm.role_master_id in (4,5) and forwarded_latest_3_bh_mat.current_status in (14,15) and albm.assigned_by_office_id in (75) /* SSM CALL CENTER */  and forwarded_latest_3_bh_mat.grievance_source in (5) 
        group by apm.role_master_id, albm.assigned_by_position, albm.assigned_by_id, albm.assigned_by_office_id
), atr_sent_restrict as (
        select 
            /*'Restricted' as role,*/
            flbm.assigned_by_id,
            flbm.assigned_by_position,
            flbm.assigned_by_office_id,
            count(*) as atr_submitted
        from atr_latest_4_11_bh_mat_2 as flbm  
        where flbm.assigned_to_office_id in (75) /* SSM CALL CENTER */  and flbm.grievance_source in (5) 
        group by flbm.assigned_by_position, flbm.assigned_by_id, flbm.assigned_by_office_id
), atr_yet_to_sent as (
        select 
            md.assigned_to_position,
            md.assigned_to_id,
            md.assigned_to_office_id,
            apm2.role_master_id,
            count(1) as yet_atr_not_submitted,
            count(1) filter (where (CURRENT_DATE - md.updated_on::date) > 7) as atr_more_than_7_days
        from master_district_block_grv md
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (6,11,13)
        and md.assigned_to_office_id in (75) /* SSM CALL CENTER */  and md.grievance_source in (5) 
        group by md.assigned_to_position, md.assigned_to_id, md.assigned_to_office_id, apm2.role_master_id
    )	
    select 
        '2025-12-18 16:30:01.947310+00:00'::timestamp as refresh_time_utc,
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
        coalesce(griev_yet_to_assigned.is_more_than_7_days, 0) as grievance_more_than_7_days,
        sum(coalesce(griev_forwarded.assigned::int, 0) + coalesce(griev_yet_to_assigned.yet_to_assigned::int, 0)) as grievance_total,
        case 
            when admin_position_master.role_master_id in (4,5) then coalesce(atr_sent.atr_submitted, 0)
            when admin_position_master.role_master_id in (6) then coalesce(atr_sent_restrict.atr_submitted, 0)
            else 0
        end as atr_sent,
        coalesce(atr_yet_to_sent.yet_atr_not_submitted, 0) as atr_not_submitted,
        coalesce(atr_yet_to_sent.atr_more_than_7_days, 0) as atr_more_than_7_days,
        case 
            when admin_position_master.role_master_id in (4,5) then sum(coalesce(atr_sent.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0))
            when admin_position_master.role_master_id in (6) then sum(coalesce(atr_sent_restrict.atr_submitted::int, 0) + coalesce(atr_yet_to_sent.yet_atr_not_submitted::int, 0))
            else 0
        end as atr_total
    from griev_forwarded
        left join griev_yet_to_assigned on griev_yet_to_assigned.assigned_to_id = griev_forwarded.assigned_to_id 
        left join atr_yet_to_sent on atr_yet_to_sent.assigned_to_id = griev_forwarded.assigned_to_id 
        left join atr_sent on atr_sent.assigned_by_id = griev_forwarded.assigned_to_id
        left join atr_sent_restrict on atr_sent_restrict.assigned_by_id = griev_forwarded.assigned_to_id
        left join admin_user_details on griev_forwarded.assigned_to_id = admin_user_details.admin_user_id
        left join admin_position_master on griev_forwarded.assigned_to_position = admin_position_master.position_id
        left join cmo_office_master on cmo_office_master.office_id = admin_position_master.office_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
    group by admin_user_details.official_name, cmo_designation_master.designation_name,admin_position_master.office_id, admin_user_role_master.role_master_name,
        cmo_sub_office_master.suboffice_name, cmo_office_master.office_name, griev_forwarded.assigned, griev_yet_to_assigned.yet_to_assigned,atr_sent.atr_submitted,
        atr_yet_to_sent.yet_atr_not_submitted,admin_position_master.record_status,admin_position_master.role_master_id, admin_position_master.position_id, 
        admin_position_master.role_master_id, atr_sent_restrict.atr_submitted, griev_yet_to_assigned.is_more_than_7_days, atr_yet_to_sent.atr_more_than_7_days
    order by
        case
            when admin_position_master.role_master_id = 4 then 1
            when admin_position_master.role_master_id = 5 then 2
            when admin_position_master.role_master_id = 6 then 3
            else 4
        end   
        