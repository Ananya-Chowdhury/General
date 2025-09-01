--============================================================= 2B1 ===============================================================
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
                    where grievance_lifecycle.grievance_status in (3,5)
                ),
                master_district_block_grv_data AS (
                    select distinct
                        md.grievance_id,
                        
                        
--------------------------------------------------------------------------------------------------------------------
 -----====================== PREVIOUS QUERY ============================--
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
                    where md.status in (6)
                        and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)
                        and replace(lower(md.emergency_flag),' ','') like '%n%'
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;
                        
                        
                        
  ---- LSITING ---
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
                        cpsm.ps_name,
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
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    where md.status in (6)
                        and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)
                        and replace(lower(md.emergency_flag),' ','') like '%n%' 
                    order by updated_on asc offset 0 limit 30
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;
------=====================================================================
                        
                        
                        
--==================================================================================================================
   ----- TUNED OPTIMISED QUERY FOR --- HOD -- ACT ON ATR --- ATR RETURN FOR REVIEW ==============================                     
            
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
                    where md.status in (6) and md.assigned_to_office_id = 75 and replace(lower(md.emergency_flag),' ','') like '%n%'
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;
            
2025-08-28 13:04:36,501   grievance.views  get_any_data_set  326  INFO   Exceuting get_any_data_set Function
2025-08-28 13:04:45,809   grievance.views  grievance_listing_tab_id_2B_1  6780  INFO   

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
--                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    where md.status in (6)
--                        and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)
                        and md.assigned_to_office_id = 75
                        and replace(lower(md.emergency_flag),' ','') like '%n%' 
                    order by updated_on asc offset 0 limit 30
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;
                
               
               
--===================================================================== 2B1 --- END =======================================================================================
--=========================================================================================================================================================================
--====================================================================== 2B2 --- START ====================================================================================
 ---- Previous Count Query ----
 
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
        where grievance_lifecycle.grievance_status in (3,5)
    ), 
    master_district_block_grv_data AS (
        select count(1) 
        from master_district_block_grv md
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (11) and md.assigned_to_office_id = 75 
            and replace(lower(md.emergency_flag),' ','') like '%n%'
    )
    select mdbgd.*
    from master_district_block_grv_data mdbgd;
   
   
 --------- Previous Listing Query -----------
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
                        cpsm.ps_name,
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
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
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
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;   
   

----------- Update Listing Query ------------
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
                    where grievance_lifecycle.grievance_status in (3,5)
                )
--                master_district_block_grv_data AS (
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
--                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
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
                    where md.status in (11) and md.assigned_to_office_id = 75 and replace(lower(md.emergency_flag),' ','') like '%n%' 
                    order by updated_on asc offset 0 limit 30
--                )
--                select mdbgd.*
--                from master_district_block_grv_data mdbgd;
               
                    
  ----------------------------------------------------------------------------
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
                    
    
    
    
    
    ---------------------------------------------------
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
),
  recv_from_other_hod as (
  	select
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3) and grievance_lifecycle.assigned_to_office_id = 75
  )
	select distinct
        md.grievance_id,
--        case
--            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
--            else 1
--        end as received_from_other_hod_flag,
		case
		    when rf.rn = 1 and rf.assigned_to_office_id = 75 then 0
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
    left join recv_from_other_hod rf on rf.rn = 1 and rf.grievance_id = md.grievance_id/* and rf.assigned_to_office_id = 75*/
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
    
----------------------------------------
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
    
    
  ------------------------------------------------

-----------------------------------------------------------------
    
---------------- UPDATED COUNT Querry ------------
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
        select count(1) 
        from master_district_block_grv md
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id/* and lu.assigned_to_office_id = 75*/
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (11) and md.assigned_to_office_id = 75 
            and replace(lower(md.emergency_flag),' ','') like '%n%'    
            
 -----------------------------------------------------------------------------------------------------------------------------------------------------------
--===================================================================== 2B2 --- END =======================================================================================
--=========================================================================================================================================================================
--====================================================================== 2B6 --- START ====================================================================================
  
----- Previous Count Query ----
            
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
        where grievance_lifecycle.grievance_status in (3,5)
    )
    -- master_district_block_grv_data AS (                      --------------- Previously Used --------------
        select count(1)
        from master_district_block_grv md
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.status in (6,11,13) and md.assigned_to_office_id = 75           
            
  
 ------------ Previous Listing Query --------------
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
    where grievance_lifecycle.grievance_status in (3,5)
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
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
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

    
    
   ----- Update Count Query ----
            
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
    select count(1)
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id /*and lu.assigned_to_office_id = 75*/
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    where md.status in (6,11,13) and md.assigned_to_office_id = 75 
    
    
   ------------ Update Listing Query --------------
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
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id /* and lu.assigned_to_office_id = 75*/
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
    where md.status in (6,11,13) and md.assigned_to_office_id = 75
--    order by updated_on asc offset 0 limit 30
    
    
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--===================================================================== 2B6 --- END =======================================================================================   
 
    
    
    
 ---- Total User still Logged in Query  ----
SELECT COUNT(*) AS total_logged_in_users_today
FROM user_token ut
WHERE DATE(ut.updated_on) = CURRENT_DATE;



SELECT COUNT(*) AS total_logged_in_users_today, ut.updated_on 
FROM user_token ut
WHERE DATE(ut.updated_on) = CURRENT_DATE
group by ut.updated_on
order by ut.updated_on desc;



--- Currently logged in User ------
SELECT COUNT(ut.token_id) AS active_logged_in_users
FROM user_token ut
  where (ut.expiry_time IS NULL OR ut.expiry_time > NOW());



SELECT COUNT(ut.token_id) AS active_logged_in_users, ut.updated_on, ut.expiry_time 
FROM user_token ut
  where (ut.expiry_time IS NULL OR ut.expiry_time > NOW())
group by ut.updated_on, ut.expiry_time 
order by ut.expiry_time desc;




select /*count(1) */ *
from admin_user_login_activity aula 
where date(aula.login_time) = CURRENT_DATE   -- Today 1476
and aula.active_status = 1
and aula.logout_time is null
order by aula.login_time desc;




SELECT COUNT(*) AS currently_logged_in_users
FROM admin_user_login_activity aula 
WHERE aula.active_status = 1
  AND aula.logout_time IS NULL
  AND aula.login_time = NOW();




SELECT *
FROM admin_user_login_activity aula 
WHERE aula.active_status = 1
  AND aula.logout_time IS NULL
  AND aula.login_time = NOW();



SELECT *
FROM admin_user_login_activity aula 
WHERE aula.active_status = 1
  AND aula.logout_time IS NULL
  AND DATE_TRUNC('minute', aula.login_time) = DATE_TRUNC('minute', NOW())
ORDER BY aula.login_time DESC;

------------- Re-Indexing -----------
vacuum full grievance_master;
reindex table greivance_master;


vacuum full grievance_lifecyckle;
reindex table grievance_lifecyckle