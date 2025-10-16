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

                            
                            
