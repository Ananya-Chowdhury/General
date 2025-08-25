WITH lastupdates AS (
    SELECT DISTINCT ON (grievance_id, assigned_to_office_id) 
        grievance_id,
        grievance_status,
        assigned_on,
        assigned_to_office_id,
        assigned_by_position,
        assigned_to_position
    FROM grievance_lifecycle
    WHERE grievance_status IN (3, 5)
    ORDER BY grievance_id, assigned_to_office_id, assigned_on DESC
)
SELECT DISTINCT
    md.grievance_id,
    CASE
        WHEN (lu.grievance_status = 3 OR EXISTS (
            SELECT 1 FROM grievance_lifecycle glsubq
            WHERE glsubq.grievance_id = md.grievance_id 
              AND glsubq.grievance_status = 14
            ORDER BY glsubq.assigned_on DESC LIMIT 1
        )) THEN 0
        WHEN (lu.grievance_status = 5 OR EXISTS (
            SELECT 1 FROM grievance_lifecycle glsubq
            WHERE glsubq.grievance_id = md.grievance_id 
              AND glsubq.grievance_status = 13
            ORDER BY glsubq.assigned_on DESC LIMIT 1
        )) THEN 1
        ELSE NULL
    END AS received_from_other_hod_flag,
    CASE
        WHEN apm.role_master_id = 6 
             AND apm2.role_master_id IN (4, 5) 
             AND md.status = 11 
             AND (md.current_atr_date IS NOT NULL OR md.action_taken_note IS NOT NULL OR md.atn_id IS NOT NULL) 
        THEN 1
        ELSE 0
    END AS received_from_restricted_flag,
    lu.grievance_status AS last_grievance_status,
    lu.assigned_on AS last_assigned_on,
    lu.assigned_to_office_id AS last_assigned_to_office_id,
    lu.assigned_by_position AS last_assigned_by_position,
    lu.assigned_to_position AS last_assigned_to_position,
    md.grievance_no,
    md.grievance_description,
    md.grievance_source,
    NULL AS grievance_source_name,
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
    CASE
        WHEN md.address_type = 2 THEN CONCAT(md.municipality_name, ' ', '(M)')
        WHEN md.address_type = 1 THEN CONCAT(md.block_name, ' ', '(B)')
        ELSE NULL
    END AS block_or_municipalty_name,
    md.gp_id,
    md.gp_name,
    md.ward_id,
    md.ward_name,
    CASE
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name, ' ', '(GP)')
        ELSE NULL
    END AS gp_or_ward_name,
    md.atn_id,
    CASE
        WHEN md.atn_id IS NOT NULL THEN COALESCE(catnm.atn_desc, 'N/A')
        WHEN md.closure_reason_id IS NOT NULL AND md.atn_id IS NULL THEN COALESCE(ccrm.closure_reason_name, 'N/A')
        ELSE 'N/A'
    END AS atn_desc,
    md.action_taken_note,
    COALESCE(md.current_atr_date, NULL) AS current_atr_date,
    md.assigned_to_position,
    md.assigned_to_id,
    CASE
        WHEN md.assigned_to_position IS NULL THEN 'N/A'
        ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ']')
    END AS assigned_to_name,
    CASE
        WHEN md.status = 1 THEN md.grievance_generate_date
        ELSE md.updated_on
    END AS updated_on,
    md.status,
    cdlm.domain_value AS status_name,
    cdlm.domain_abbr AS grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name
FROM master_district_block_grv md
LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
LEFT JOIN cmo_office_master com ON com.office_id = md.assigned_to_office_id
LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_type = 'grievance_status' AND cdlm.domain_code = md.status
LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = md.assigned_to_position AND aupm.status = 1
LEFT JOIN admin_user_details ad ON ad.admin_user_id = aupm.admin_user_id
LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position
LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm2.designation_id
LEFT JOIN cmo_office_master com2 ON com2.office_id = apm2.office_id
LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm2.role_master_id
LEFT JOIN cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = md.closure_reason_id
LEFT JOIN lastupdates lu ON lu.grievance_id = md.grievance_id AND lu.assigned_to_office_id = 35
WHERE (
    (md.assigned_by_office_id = 35 OR md.assigned_to_office_id = 35)
    AND md.status IN (6, 11, 13)
    AND apm2.role_master_id = 4
    AND md.district_id = '19'
)
ORDER BY updated_on ASC
OFFSET 0 LIMIT 30;


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
                    case
                        when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                        when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                        else null
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
                        else md.updated_on
                    end as updated_on,
                    md.status,
                    cdlm.domain_value as status_name,
                    cdlm.domain_abbr as grievance_status_code,
                    md.emergency_flag,
                    md.police_station_id,
                    cpsm.ps_name
                from master_district_block_grv md
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
                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
                where (
                        (md.assigned_by_office_id = 35 or md.assigned_to_office_id = 35)
                        and md.status in (6,11,13)
                        and apm2.role_master_id = 4
         and md.district_id in ('19') ) order by updated_on  asc  offset 0 limit 30;