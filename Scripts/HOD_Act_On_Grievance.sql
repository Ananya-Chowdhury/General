
------------------------------------ Previous Count Query On HOD Act on Grievance -->>> EMERGENCY TAB ------------------------------------
-- /*table_type = Emergency, token_role_id = 4, code :: ['GM003', 'GM004', 'GM005', 'GM016'] NORMAL*/
                WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
         Select Count(1) 
                    from master_district_block_grv md
                    -- from (select * from master_district_block_grv where md.grievance_id > 0  and 3,4,5,16) md
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
                    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35 
                                where ((md.assigned_to_office_id = 35) and replace(lower(md.emergency_flag),' ','') like '%y%' and md.status in (3,4,5,16))
                              
                              
                              
                              
 -------------------------------- Previous Listing Query On HOD Act on Grievance -->>> EMERGENCY TAB -------------------------------------                            
 -- /*table_type = Emergency, token_role_id = 4, code :: ['GM003', 'GM004', 'GM005', 'GM016'] NORMAL*/
WITH lastupdates AS (
    SELECT grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (3,5)
)
    select distinct
        md.grievance_id, 
        -- case 
           -- when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) /*and glsubq.assigned_to_office_id = 35*/ order by glsubq.assigned_on desc limit 1) = 14) then 0
           -- when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) /*and glsubq.assigned_to_office_id = 35*/ order by glsubq.assigned_on desc limit 1) = 13)then 1
           -- else null
        -- end as received_from_other_hod_flag,
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
        -- ----------------------- OT ---------------------------------
        -- coalesce(catnm.atn_desc,'N/A') as atn_desc,
        -- coalesce(md.action_taken_note,'N/A') as action_taken_note,
        -- case 
            -- when md.status = 15 and md.atn_id is not null then (select gl.action_taken_note from grievance_lifecycle gl where gl.grievance_id = md.grievance_id and gl.grievance_status = 14 order by gl.assigned_on desc limit 1)
            -- when md.status = 15 and md.closure_reason_id is not null and md.atn_id is null then coalesce(md.action_taken_note,'N/A')
            -- else coalesce(md.action_taken_note,'N/A')
        -- end as action_taken_note,
        -- ----------------------- OT ---------------------------------
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
    -- from (select * from master_district_block_grv where md.grievance_id > 0  and 3,4,5,16) md
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
    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35 
                where ( 
              (md.assigned_to_office_id = 35) and replace(lower(md.emergency_flag),' ','') like '%y%' and md.status in (3,4,5,16) ) 
              order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 30 
                              
                              
                              
 
                              
                              
  select * from grievance_lifecycle gl where gl.grievance_id = 5388467 order by gl.assigned_on asc;
  select * from admin_user_position_mapping aupm where aupm.position_id = 1227;
  select * from admin_user_details aud where aud.admin_user_id = 1227;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
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
                    where grievance_lifecycle.grievance_status in (3,5) and grievance_lifecycle.assigned_to_office_id = 75
                )
--                master_district_block_grv_data AS (
                    select count(1) 
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
                    left join admin_position_master apm on apm.position_id = md.updated_by_position
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    where md.status in (6) 
                    -- and md.assigned_to_office_id = 75
                       -- and (md.assigned_by_office_id = 75 or md.assigned_to_office_id = 75)    -- Previously it was included currently removed as not required --
                        and replace(lower(md.emergency_flag),' ','') like '%n%'
  
  
  
  
  
  
  
  