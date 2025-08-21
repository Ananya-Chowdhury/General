-------------->>>>>>>>>>>> OLD CMO ACT ON ART --- MY Basket Count Query ---- <<<<-------------
with lastupdates AS (
    select 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select count(1) 
    from master_district_block_grv md
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    left join ai_validated_atn_result avar on avar.grievance_id = md.grievance_id and avar.is_latest is true  
    inner join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1 and glh.locked_by_position = 15854
    where md.grievance_id > 0 
        and md.status in (14)
)
select mdbgd.*
from master_district_block_grv_data mdbgd;



----->>>>>>>>>>> OLD CMO ACT ON ART --- MY Basket ---- <<<<-------------
with lastupdates AS (
    select 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select distinct
        md.grievance_id,
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
        lu.grievance_status as last_grievance_status,
        lu.assigned_on as last_assigned_on,
        lu.assigned_to_office_id as last_assigned_to_office_id,
        lu.assigned_by_position as last_assigned_by_position,
        lu.assigned_to_position as last_assigned_to_position,
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
            when under_processing_ids.grievance_id is not null then 'Y' else 'N'
        end as is_bulk_processing,
        md.receipt_mode,
        md.received_at
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id -- and aupm.status = 1
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    -- inner join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1 and glh.locked_by_position = 105
    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id 
    inner join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1 and glh.locked_by_position = 15854
    left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true
    left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
    left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
    left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
    left join cmo_office_master com3 on com3.office_id = apm3.office_id 
    left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
    where md.grievance_id > 0 
        and md.status in (14) 
    order by updated_on asc limit 30 offset 0
)
select mdbgd.*
from master_district_block_grv_data mdbgd;

---------------------------------------------------------------------------------------------------------------------
--------------->>>>>>>>>>> UPDATE CMO ACT ON ART --- MY Basket ---- <<<<-------------

with lastupdates AS (
    select 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select distinct
        md.grievance_id,
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
        lu.grievance_status as last_grievance_status,
        lu.assigned_on as last_assigned_on,
        lu.assigned_to_office_id as last_assigned_to_office_id,
        lu.assigned_by_position as last_assigned_by_position,
        lu.assigned_to_position as last_assigned_to_position,
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
            when under_processing_ids.grievance_id is not null then 'Y' else 'N'
        end as is_bulk_processing,
        md.receipt_mode,
        md.received_at
    from master_district_block_grv md
    inner join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1 and glh.locked_by_position = 15854 
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id -- and aupm.status = 1
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    -- inner join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1 and glh.locked_by_position = 105
    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id 
    left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true
    left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
    left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
    left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
    left join cmo_office_master com3 on com3.office_id = apm3.office_id 
    left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
    where md.grievance_id > 0 
        and md.status in (14) 
    order by updated_on asc limit 30 offset 0
)
select mdbgd.*
from master_district_block_grv_data mdbgd;





left join admin_position_detail_mat_2 pi ON pi.position_id = bh.assigned_to_position


CREATE MATERIALIZED VIEW public.admin_position_detail_mat_2
TABLESPACE pg_default
AS SELECT apm.position_id,
    ad.admin_user_id,
    ad.official_name,
    ad.official_phone,
    cdm.designation_name,
    com.office_name,
    aurm.role_master_name
   FROM admin_user_position_mapping aupm
     JOIN admin_user_details ad ON aupm.admin_user_id = ad.admin_user_id
     JOIN admin_position_master apm ON aupm.position_id = apm.position_id
     JOIN cmo_designation_master cdm ON cdm.designation_id = apm.designation_id
     JOIN cmo_office_master com ON com.office_id = apm.office_id
     JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id
  WHERE aupm.status = 1
WITH DATA;



------------------------------------------------------------------------------------------



------------------------------------------------------------
------- COUNT UPDATE --------
with lastupdates AS (
    select 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select count(1) 
    from master_district_block_grv md
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
--    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    left join ai_validated_atn_result avar on avar.grievance_id = md.grievance_id and avar.is_latest is true  
    inner join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1 and glh.locked_by_position = 15854
    where md.grievance_id > 0 
        and md.status in (14) and md.assigned_to_office_id = 5
)
select mdbgd.*
from master_district_block_grv_data mdbgd;


--------------------------------------------------
---- CLOsed For Test PURPOSE ----
{
    "position_id": 15854,
    "grievance_status": "GM015",
    "grievance_id": 5503037,
    "comment": null,
    "assign_comment": "As per the Action Taken Note and Remarks furnished by the HOD, the Grievance is hereby disposed of",
    "action_proposed": null,
    "urgency_flag": 0,
    "addl_doc_id": [],
    "action_taken_note": null,
    "action": "TA"
}