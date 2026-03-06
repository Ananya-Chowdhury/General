ITH lastupdates AS (
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
                    -- from (select * from master_district_block_grv where md.grievance_id > 0  and 14,15) md
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
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
                                left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true  
                                left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
                                left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
                                left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
                                left join cmo_office_master com3 on com3.office_id = apm3.office_id 
                                left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 1 
                                where ( 
                              md.grievance_id > 0 and replace(lower(md.emergency_flag),' ','') like '%n%' and md.status in (14,15) )
                              
                              
                              
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
                    -- from (select * from master_district_block_grv where md.grievance_id > 0  and 14,15) md
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
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
                                left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true  
                                left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
                                left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
                                left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
                                left join cmo_office_master com3 on com3.office_id = apm3.office_id 
                                left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 1 
                                where ( 
                              md.grievance_id > 0 and replace(lower(md.emergency_flag),' ','') like '%n%' and md.status in (14,15) )
                              
                              
                              
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
                    -- from (select * from master_district_block_grv where md.grievance_id > 0  and 14,15) md
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
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
                                left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true  
                                left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
                                left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
                                left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
                                left join cmo_office_master com3 on com3.office_id = apm3.office_id 
                                left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 3 
                                where ( 
                              (md.assigned_by_office_id = 3 or md.assigned_to_office_id = 3) and replace(lower(md.emergency_flag),' ','') like '%n%' and md.status in (14,15) )