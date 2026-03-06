  with lastupdates AS (
    select
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 75
)
    select distinct
        md.grievance_id,
        case
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
        md.ps_name,
        'N' as is_bulk_processing,
        md.receipt_mode,
        md.received_at
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id /*and lu.assigned_to_office_id = 75*/
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    where md.status in (11) and md.assigned_to_office_id = 75 and replace(lower(md.emergency_flag),' ','') like '%n%'
--    order by updated_on asc offset 0 limit 30 
    
    
    
    
    ----------------------------------------------------------------------------------
      with lastupdates AS (
    select
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 75
)
    select distinct
        md.grievance_id,
        case
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
        md.ps_name,
        'N' as is_bulk_processing,
        md.receipt_mode,
        md.received_at
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id/* and lu.assigned_to_office_id = 75*/
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    where md.status in (11) and md.assigned_to_office_id = 75 and replace(lower(md.emergency_flag),' ','') like '%n%'
--    order by updated_on asc offset 0 limit 30 
    
    
    /* TAB_ID: 2B2 | TBL: ATR Received from Restricted User/HoSO >> Role: 4 Ofc: 75 | G_Codes: ('GM011') */
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
                    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 75
                )
                -- master_district_block_grv_data AS (            -------- Previously Used  ---------
                    select distinct
                        md.grievance_id,
                        case
                            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
                        md.ps_name,
                        'N' as is_bulk_processing,
                        md.receipt_mode,
                        md.received_at
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id /*and lu.assigned_to_office_id = 75*/
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    -- left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id       ------ Previously Used -------
                    left join admin_position_master apm on apm.position_id = md.updated_by_position
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    -- left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
                    -- left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true
                    -- left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
                    -- left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
                    -- left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
                    -- left join cmo_office_master com3 on com3.office_id = apm3.office_id
                    -- left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
                    where md.status in (11) and md.assigned_to_office_id = 75
                        and replace(lower(md.emergency_flag),' ','') like '%n%'

                        
                        
                        
                        
 /* TAB_ID: 2B1 | TBL: ATR Returned for Review >> Role: 4 Ofc: 75 | G_Codes: ('GM006') */
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
                when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
            md.ps_name,
            'N' as is_bulk_processing,
            md.receipt_mode,
            md.received_at
        from master_district_block_grv md
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
        left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
        left join cmo_office_master com on com.office_id = md.assigned_to_office_id
        left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
        left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
        left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
        left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
        -- left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id      -- Previously it was included currently removed as not required --
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
        left join cmo_office_master com2 on com2.office_id = apm2.office_id
        left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
        left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
        where md.status in (6)
            -- and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)     -- Previously it was included currently removed as not required --
            and md.assigned_to_office_id = 75 and replace(lower(md.emergency_flag),' ','') like '%n%'
--        order by updated_on asc offset 0 limit 30
    )
    select mdbgd.*
    from master_district_block_grv_data mdbgd;

 
 
 
 /* TAB_ID: 2B2 | TBL: ATR Received from Restricted User/HoSO >> Role: 4 Ofc: 75 | G_Codes: ('GM011') */
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
    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 75
)
-- master_district_block_grv_data AS (            -------- Previously Used  ---------
    select distinct
        md.grievance_id,
        case
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
        md.ps_name,
        'N' as is_bulk_processing,
        md.receipt_mode,
        md.received_at
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id /*and lu.assigned_to_office_id = 75*/
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    -- left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id       ------ Previously Used -------
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    -- left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
    -- left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true
    -- left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
    -- left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
    -- left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
    -- left join cmo_office_master com3 on com3.office_id = apm3.office_id
    -- left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
    where md.status in (11) and md.assigned_to_office_id = 75
        and replace(lower(md.emergency_flag),' ','') like '%n%'
    order by updated_on asc offset 0 limit 30

    
    
 /* TAB_ID: 2B3 | TBL: ATR Received from Other HoD >> Role: 4 Ofc: 75 | G_Codes: ('GM013') */
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
)
-- master_district_block_grv_data AS (         --------- Previously Used ------------
    select distinct
        md.grievance_id,
        case
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
        md.ps_name,
        'N' as is_bulk_processing,
        md.receipt_mode,
        md.received_at
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    -- left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id       --------- Previously Used -----------
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    where md.status in (13) and md.assigned_to_office_id = 75
        and replace(lower(md.emergency_flag),' ','') like '%n%'
    order by updated_on asc offset 0 limit 30

    
    
    /* TAB_ID: 2B6 | TBL: All >> Role: 4 Ofc: 75 | G_Codes: ('GM011', 'GM013', 'GM006') */
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
                    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 75
                )
                -- master_district_block_grv_data AS (           ---------- Previously Used -----------
                    select distinct
                        md.grievance_id,
                        case
                            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
                        md.ps_name,
                        'N' as is_bulk_processing,
                        md.receipt_mode,
                        md.received_at
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id /*and lu.assigned_to_office_id = 75*/
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    -- left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id            ----------- Previously Used ---------------
                    left join admin_position_master apm on apm.position_id = md.updated_by_position
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    where md.status in (6,11,13) and md.assigned_to_office_id = 75
                    order by updated_on asc offset 0 limit 30

                    
                    
                    
                    
                    
     /* TAB_ID: 2B1 | TBL: ATR Returned for Review >> Role: 5 Ofc: 35 | G_Codes: ('GM006') */  
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
                    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 35 and grievance_lifecycle.assigned_to_position = 1227
                )
--                master_district_block_grv_data AS (
                    select distinct
                        md.grievance_id,
                        case
                            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 35 then 0
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
                        md.ps_name,       
                        'N' as is_bulk_processing,
                        md.receipt_mode,
                        md.received_at
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    -- left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id      -- Previously it was included currently removed as not required --
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    where md.status in (6) and replace(lower(md.emergency_flag),' ','') like '%n%' 
                        -- and (md.assigned_by_office_id = 35 or md.assigned_to_office_id = 35)     -- Previously it was included currently removed as not required --
--                        and md.assigned_to_office_id = 35
--                         and md.assigned_to_position = 1227
--                        and replace(lower(md.emergency_flag),' ','') like '%n%' 
--                    order by updated_on asc offset 0 limit 50
--                )
--                select mdbgd.*
--                from master_district_block_grv_data mdbgd;               
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    /* TAB_ID: 2B1 | TBL: ATR Returned for Review >> Role: 4 Ofc: 75 | G_Codes: ('GM006') */
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
                            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
                        md.ps_name,
                        'N' as is_bulk_processing,
                        md.receipt_mode,
                        md.received_at
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    -- left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id      -- Previously it was included currently removed as not required --
                    left join admin_position_master apm on apm.position_id = md.updated_by_position
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    where md.status in (6)
                        -- and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)     -- Previously it was included currently removed as not required --
                        and md.assigned_to_office_id = 75
                        and replace(lower(md.emergency_flag),' ','') like '%n%'
--                    order by updated_on asc offset 0 limit 50
--                )
--                select mdbgd.*
--                from master_district_block_grv_data mdbgd;

                        
                        
                        
                        
                        /* TAB_ID: 2B1 | TBL: ATR Returned for Review >> Role: 4 Ofc: 75 | G_Codes: ('GM006') */
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
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
                    left join admin_position_master apm on apm.position_id = md.updated_by_position
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    where md.status in (6) and md.assigned_to_office_id = 75
                       -- and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)    -- Previously it was included currently removed as not required --


                        and replace(lower(md.emergency_flag),' ','') like '%n%'
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;
                        
                        
                        
                        
                        
                        ------------------------------------------------------------------------
                        
                      /* TAB_ID: 2B1 | TBL: ATR Returned for Review >> Role: 5 Ofc: 35 | G_Codes: ('GM006') */  
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
                    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 35
                )
--                master_district_block_grv_data AS (
                    select count(1) 
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
                    left join admin_position_master apm on apm.position_id = md.updated_by_position
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    where md.status in (6) 
--                    and md.assigned_to_office_id = 35
                       -- and (md.assigned_by_office_id = 35 or md.assigned_to_office_id = 35)    -- Previously it was included currently removed as not required --
                         and md.assigned_to_position = 1227
                        and replace(lower(md.emergency_flag),' ','') like '%n%'
--                )
--                select mdbgd.*
--                from master_district_block_grv_data mdbgd;
                        
                        
                        
                        
                        
                 /* TAB_ID: 2B1 | TBL: ATR Returned for Review >> Role: 5 Ofc: 35 | G_Codes: ('GM006') */  
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
                    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 35
                )
--                master_district_block_grv_data AS (
                    select distinct
                        md.grievance_id,
                        case
                            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 35 then 0
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
                        md.ps_name,       
                        'N' as is_bulk_processing,
                        md.receipt_mode,
                        md.received_at
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    where md.status in (6)
                        -- and (md.assigned_by_office_id = 35 or md.assigned_to_office_id = 35)     -- Previously it was included currently removed as not required --
--                        and md.assigned_to_office_id = 35/
                         and md.assigned_to_position = 1227
                        and replace(lower(md.emergency_flag),' ','') like '%n%' 
                    order by updated_on asc offset 0 limit 50
--                )
--                select mdbgd.*
--                from master_district_block_grv_data mdbgd;
                        

                    
                    
/* TAB_ID: 2B6 | TBL: All >> Role: 5 Ofc: 35 | G_Codes: ('GM011', 'GM013', 'GM006') */  
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
    where grievance_lifecycle.grievance_status in (3,5) /*and grievance_lifecycle.assigned_to_office_id = 35*/
)
-- master_district_block_grv_data AS (                      --------------- Previously Used --------------
select count(1) 
from master_district_block_grv md
left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
left join admin_position_master apm on apm.position_id = md.updated_by_position
left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
where md.status in (6,11,13) 
 and md.assigned_to_office_id = 35
    and md.assigned_to_position = 1227
    
                        
                        
                        
      --------------------------------------------------------------------------------------------------------------------------------------
/* TAB_ID: 2B1 | TBL: ATR Returned for Review >> Role: 4 Ofc: 75 | G_Codes: ('GM006') */
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
    where grievance_lifecycle.grievance_status in (3,5) /*and grievance_lifecycle.assigned_to_office_id = 75*/
)
--master_district_block_grv_data AS (
    select count(1)
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    where md.status in (6)
     and md.assigned_to_office_id = 75
       -- and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)    -- Previously it was included currently removed as not required --
	and replace(lower(md.emergency_flag),' ','') like '%n%'
					
					
					
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
where grievance_lifecycle.grievance_status in (3,5) /*and grievance_lifecycle.assigned_to_office_id = 35*/
)
--master_district_block_grv_data AS (
select count(1)
from master_district_block_grv md
--    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
--    left join admin_position_master apm on apm.position_id = md.updated_by_position
--    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
where md.status in (6)
 and md.assigned_to_office_id = 35
   -- and (md.assigned_by_office_id = 35 or md.assigned_to_office_id = 35)    -- Previously it was included currently removed as not required --
     and md.assigned_to_position = 1227
    and replace(lower(md.emergency_flag),' ','') like '%n%';
								
					
					
					
with lastupdates AS (
	select * from (
	    select
	        grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, grievance_lifecycle.assigned_on, grievance_lifecycle.assigned_to_office_id,
	        grievance_lifecycle.assigned_by_position, grievance_lifecycle.assigned_to_position,
	        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
	    from grievance_lifecycle
	    where grievance_lifecycle.grievance_status in (3,5) 
	) as XX where XX.rn = 1 and XX.assigned_to_office_id = 35
)
	select count(1)
	from (select * from master_district_block_grv YY where YY.status in (6) and YY.assigned_to_office_id = 35 
		  and YY.assigned_to_position = 1227 and replace(lower(YY.emergency_flag),' ','') like '%n%') as md
	left join lastupdates lu on lu.grievance_id = md.grievance_id
	left join admin_position_master apm on apm.position_id = md.updated_by_position
	left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
--	where md.status in (6) and md.assigned_to_office_id = 35 
--		  and md.assigned_to_position = 1227 and replace(lower(md.emergency_flag),' ','') like '%n%';					
					
		
					
					
					
	with lastupdates AS (
    select * from (
	    select
	        grievance_lifecycle.grievance_id, grievance_lifecycle.grievance_status, grievance_lifecycle.assigned_on, grievance_lifecycle.assigned_to_office_id,
	        grievance_lifecycle.assigned_by_position, grievance_lifecycle.assigned_to_position,
	        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
	    from grievance_lifecycle
	    where grievance_lifecycle.grievance_status in (3,5) 
	) as XX where XX.rn = 1 and XX.assigned_to_office_id = 35
) 
    select count(1)
    from master_district_block_grv md
--    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35 
    left join lastupdates lu on lu.grievance_id = md.grievance_id
    where md.status in (6)
     and md.assigned_to_office_id = 35 
         and md.assigned_to_position = 1227
        and replace(lower(md.emergency_flag),' ','') like '%n%';
					
             
                        
--        with lastupdates AS (
--    select
--        grievance_lifecycle.grievance_id,
--        grievance_lifecycle.grievance_status,
--        grievance_lifecycle.assigned_on,
--        grievance_lifecycle.assigned_to_office_id,
--        grievance_lifecycle.assigned_by_position,
--        grievance_lifecycle.assigned_to_position,
--        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
--    from grievance_lifecycle
--    where grievance_lifecycle.grievance_status in (3,5) /*and grievance_lifecycle.assigned_to_office_id = 35*/
--)
--master_district_block_grv_data AS (
    select count(1)
    from master_district_block_grv md
--    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
--    left join admin_position_master apm on apm.position_id = md.updated_by_position
--    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    where md.status in (6)
     and md.assigned_to_office_id = 75
       -- and (md.assigned_by_office_id = 35 or md.assigned_to_office_id = 35)    -- Previously it was included currently removed as not required --
--         and md.assigned_to_position = 1227
        and replace(lower(md.emergency_flag),' ','') like '%n%';
                        
                      
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 with fwd_union_data as (		
	select 
		admin_position_master.sub_office_id, 
		forwarded_latest_7_bh_mat.grievance_id
--		forwarded_latest_7_bh_mat.assigned_to_position,
--		count(forwarded_latest_7_bh_mat.grievance_id) as forwarded
--		admin_user_details.official_name, 
--		admin_user_details.official_phone, 
--		admin_position_master.office_id, 
--		com.office_name,
--	    aurm.role_master_name, 
--	    admin_position_master.position_id
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
        left join admin_user_position_mapping on admin_user_position_mapping.position_id = admin_position_master.position_id 
        left join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
        left join admin_user_details on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
        left join cmo_office_master com on com.office_id = admin_position_master.office_id
        where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75) /*and admin_position_master.office_id is not null */
        group by admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id/*, forwarded_latest_7_bh_mat.assigned_to_position*/
        	/*and admin_position_master.role_master_id in (7,8) and 
    admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1*/    
   ), fwd_atr as (
   		select 
   			count(fwd_union_data.grievance_id) as forwarded,
   			fwd_union_data.sub_office_id
   			from fwd_union_data
   			group by fwd_union_data.sub_office_id
   )/*, atr_recv as (
	        select 
	        	fwd_union_data.sub_office_id, fwd_union_data.grievance_id,
	        	count(fwd_union_data.grievance_id) as atr_received
	        from fwd_union_data
	        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
	        where atr_latest_11_bh_mat.assigned_to_office_id in (75)
	        group by fwd_union_data.sub_office_id, fwd_union_data.grievance_id
	), pend as (		
			select 
				fwd_union_data.sub_office_id, 
				fwd_union_data.grievance_id,
		    	count(1) as atrpending
	        from fwd_union_data
	        where not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm WHERE fwd_union_data.grievance_id = bm.grievance_id)
	        group by fwd_union_data.sub_office_id, fwd_union_data.grievance_id
	), pnd as (
		    select
                fwd_union_data.sub_office_id, 
                count(1) as pending, 
                sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days
	        from fwd_union_data
	        inner join pending_at_hoso_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
	        where not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm WHERE fwd_union_data.grievance_id = bm.grievance_id)
	        group by fwd_union_data.sub_office_id /*, ba.pending_days  */   
	), ave_days as (
			select 
				fwd_union_data.sub_office_id,
				bh.days_to_resolve as total_days_to_resolve,
				avg(bh.days_to_resolve) as avg_days_to_resolved
			from fwd_union_data
	        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
			inner join pending_at_hoso_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
			group by fwd_union_data.sub_office_id, bh.days_to_resolve /*, atr_recv.grievance_id,*/	
	)*/
     select
       '2025-08-21 16:30:01.231162+00:00':: timestamp as refresh_time_utc,
       '2025-08-21 16:30:01.231162+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
       coalesce(cmo_sub_office_master.suboffice_name,'N/A') as Sub_office_name,
       coalesce(cmo_sub_office_master.suboffice_id, 0) as sub_office_id,
       coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
       coalesce(atr_recv.atr_received, 0) AS atr_received,
--       coalesce(fwd_union_data.assigned_to_position, 0) AS position,
--       coalesce(fwd_atr.official_name) AS official_name,
--       coalesce(fwd_atr.official_phone) AS official_phone,
--       coalesce(fwd_atr.office_id, 0) AS office_id,
--       coalesce(fwd_atr.role_master_name) AS assigned_role_name,
--       coalesce(fwd_atr.position_id, 0) AS position_id,
--       coalesce(fwd_atr.office_name) AS office_name,
       coalesce(pnd.more_7_days, 0) AS more_7_days,
       coalesce(pend.atrpending, 0) AS atr_pending,
       coalesce(ave_days.total_days_to_resolve, 0) AS total_days_to_resolve,
       COALESCE(ave_days.avg_days_to_resolved, 0) AS avg_days_to_resolved
        from fwd_union_data
        left join fwd_atr on fwd_union_data.sub_office_id = fwd_atr.sub_office_id
        left join atr_recv on fwd_union_data.sub_office_id = atr_recv.sub_office_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_union_data.sub_office_id
        left join pnd on fwd_union_data.sub_office_id = pnd.sub_office_id
        left join pend on fwd_union_data.sub_office_id = pend.sub_office_id
        left join ave_days on fwd_union_data.sub_office_id = ave_days.sub_office_id
        where 1=1
        group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, fwd_atr.forwarded, atr_recv.atr_received,/* fwd_union_data.assigned_to_position, */pnd.more_7_days, pend.atrpending, 
        ave_days.total_days_to_resolve, ave_days.avg_days_to_resolved/*, fwd_atr.official_name, fwd_atr.official_phone, 
        fwd_atr.office_id, fwd_atr.role_master_name, fwd_atr.position_id, fwd_atr.office_name, */
        order by cmo_sub_office_master.suboffice_name;                       
                        
                        
 
 
 select * from cmo_parameter_master cpm;
 
 
 
 SELECT * FROM get_login_activity('2025-09-08 11:00:00');
