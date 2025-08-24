WITH lastupdates AS (
            SELECT grievance_lifecycle.grievance_id,
                grievance_lifecycle.grievance_status,
                grievance_lifecycle.assigned_on,
                grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                grievance_lifecycle.assigned_to_position,
                row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            FROM grievance_lifecycle
            WHERE grievance_lifecycle.grievance_status in (3)
        )
         Select Count(1)  
            from grievance_master md
            inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
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
            left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
            left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
            left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
            left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
            left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
            
  where lu.assigned_to_office_id = 59   and lu.grievance_status::integer in (3) and (lu.assigned_on::date) between '2025-01-03' and '2025-01-05'