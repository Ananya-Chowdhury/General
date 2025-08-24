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
                        -- left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true  
                       where lu.grievance_status::integer in ('3') and lu.assigned_to_office_id = 4
                       
                       
  select * from public.cmo_office_master com ;
  
 
 WITH lastupdates AS (
                        SELECT grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_office_id,
                            grievance_lifecycle.assigned_by_position,
                            grievance_lifecycle.assigned_to_position,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id 
                            ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM grievance_lifecycle
                        WHERE grievance_lifecycle.grievance_status in (3,5)
                    )
                        select distinct
                        md.grievance_id, 
                            case 
                                when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                                when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                                else null
                            end as received_from_other_hod_flag,
                            lu.grievance_status as last_grievance_status,
                            lu.assigned_on as last_assigned_on,
                            lu.assigned_to_office_id as last_assigned_to_office_id,
                            lu.assigned_by_office_id as last_assigned_by_office_id,
                            lu.assigned_by_position as last_assigned_by_position,
                            lu.assigned_to_position as last_assigned_to_position,
                            md.grievance_no ,
                            md.grievance_description,
                            md.grievance_source ,
                            null as grievance_source_name,
                            md.applicant_name ,
                            md.pri_cont_no,
                            md.grievance_generate_date ,
                            md.grievance_category,
                            cgcm.grievance_category_desc,
                            md.assigned_to_office_id,
                            com.office_name,
                            md.district_id,
                            cdm2.district_name ,
                            md.block_id ,
                            cbm.block_name ,
                            md.municipality_id ,
                            cmm.municipality_name,
                            case 
                                when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
                            when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
                            else null
                        end as block_or_municipalty_name,
                        md.gp_id,
                        cgpm.gp_name,
                        md.ward_id,
                        cwm.ward_name,
                        case 
                            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
                            ELSE NULL
                        end as gp_or_ward_name,
                        md.atn_id,
                        coalesce(catnm.atn_desc,'N/A') as atn_desc,
                        coalesce(md.action_taken_note,'N/A') as action_taken_note,
                        coalesce(md.current_atr_date,null) as current_atr_date,
                        md.assigned_to_position,
                        case 
                            when md.assigned_to_office_id is null then 'N/A'
                            when md.assigned_to_office_id = 5 then 'Pending At CMO'
                            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                        end as assigned_to_office_name,
                        md.assigned_to_id,
    --                    case 
    --                        when md.assigned_to_position is null then 'N/A'
    --                        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
    --                    end as assigned_to_name,
                        case
                            when md.status = 1 then md.grievance_generate_date
                            else md.updated_on -- + interval '5 hour 30 Minutes' 
                        end as updated_on,
                        md.status,
                        cdlm.domain_value as status_name,
                        cdlm.domain_abbr as grievance_status_code,
                        md.emergency_flag,
                        md.police_station_id,
                        cpsm.ps_name  
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
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_pu
                       
                       
                       
                select * from cmo_parameter_master cpm;
                       
                       




select count(1) from grievance_auto_assign_audit ;
select count(1) from grievance_auto_assign_audit where status = 3;


















