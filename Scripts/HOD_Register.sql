----- HOD Register -----
with uinion_part as (
            select grievance_id, grievance_status, assigned_on from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
            union
            select grievance_id, grievance_status, assigned_on from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
    )
   SELECT distinct
            md.grievance_id,
            /*
        CASE
            -- WHEN (lu.grievance_status = 3 OR glsubq.grievance_status = 14) THEN 0
            -- WHEN (lu.grievance_status = 5 OR glsubq.grievance_status = 13) THEN 1
            when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
            when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13) then 1
            ELSE NULL
        END AS received_from_other_hod_flag,
        lu.grievance_status AS last_grievance_status,
        lu.assigned_on AS last_assigned_on,
        lu.assigned_to_office_id AS last_assigned_to_office_id,
        lu.assigned_by_office_id AS last_assigned_by_office_id,
        lu.assigned_by_position AS last_assigned_by_position,
        lu.assigned_to_position AS last_assigned_to_position,
        */
        NULL AS received_from_other_hod_flag,
        NULL AS last_grievance_status,
        NULL AS last_assigned_on,
        NULL AS last_assigned_to_office_id,
        NULL AS last_assigned_by_office_id,
        NULL AS last_assigned_by_position,
        NULL AS last_assigned_to_position,
        case
            when lu.grievance_status = 3 then lu.assigned_on
            when lu.grievance_status = 5 then lu.assigned_on
            else null
        end as grievance_generate_date,
        md.grievance_no,
        md.grievance_description,
        md.grievance_source,
        NULL AS grievance_source_name,
        md.applicant_name,
        md.pri_cont_no,
        md.grievance_generate_date as grievance_generate_date_gm,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        cdm2.district_name,
        md.block_id,
        cbm.block_name,
        md.municipality_id,
        cmm.municipality_name,
        CASE
            WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
            WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
            ELSE NULL
        END AS block_or_municipalty_name,
        md.gp_id,
        cgpm.gp_name,
        md.ward_id,
        cwm.ward_name,
        CASE
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
            ELSE NULL
        END AS gp_or_ward_name,
        md.atn_id,
        COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
        COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
        COALESCE(md.current_atr_date, NULL) AS current_atr_date,
        md.assigned_to_position,
        CASE
            WHEN md.assigned_to_office_id IS NULL THEN 'N/A'
            WHEN md.assigned_to_office_id = 5 THEN 'Pending At CMO'
            -- ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] ')
            -- ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' - ', csom.suboffice_name, ') ]')
            when csom.suboffice_name is not null then CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' - ', csom.suboffice_name, ') ]')
            when csom.suboffice_name is null then CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ') ]')
        END AS assigned_to_office_name,
        md.assigned_to_id,
        CASE
            WHEN md.status = 1 THEN md.grievance_generate_date
            ELSE md.updated_on -- + interval '5 hour 30 Minutes'
        END AS updated_on,
        md.status,
        cdlm.domain_value AS status_name,
        cdlm.domain_abbr AS grievance_status_code,
        md.emergency_flag,
        md.police_station_id,
        cpsm.ps_name,
        lu.grievance_status as grievance_historical_status,
        case
            when lu.grievance_status = 3 then lu.assigned_on
            else null
        end as grievance_received_from_cmo,
        case 
		    when lu.grievance_status = 14 then 0
		    else EXTRACT(DAY from (CURRENT_DATE - lu.assigned_on))
		end as pending_days_to_cmo
    from grievance_master md
    INNER JOIN uinion_part as lu ON lu.grievance_id = md.grievance_id
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
    LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
    LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id
    LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
    LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
    LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
      order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10
            
                  
------ count Query ----
with uinion_part as (
        select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
        union
        select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
)
Select Count(1)
    from grievance_master md
    inner join uinion_part as lu on lu.grievance_id = md.grievance_id
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
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
    
    
    
----------- HOD Register Pending for Update -----
with uinion_part as (
            select grievance_id, grievance_status, assigned_on from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
            union
            select grievance_id, grievance_status, assigned_on from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
    )
   SELECT distinct
            md.grievance_id,
            /*
        CASE
            -- WHEN (lu.grievance_status = 3 OR glsubq.grievance_status = 14) THEN 0
            -- WHEN (lu.grievance_status = 5 OR glsubq.grievance_status = 13) THEN 1
            when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
            when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13) then 1
            ELSE NULL
        END AS received_from_other_hod_flag,
        lu.grievance_status AS last_grievance_status,
        lu.assigned_on AS last_assigned_on,
        lu.assigned_to_office_id AS last_assigned_to_office_id,
        lu.assigned_by_office_id AS last_assigned_by_office_id,
        lu.assigned_by_position AS last_assigned_by_position,
        lu.assigned_to_position AS last_assigned_to_position,
        */
        NULL AS received_from_other_hod_flag,
        NULL AS last_grievance_status,
        NULL AS last_assigned_on,
        NULL AS last_assigned_to_office_id,
        NULL AS last_assigned_by_office_id,
        NULL AS last_assigned_by_position,
        NULL AS last_assigned_to_position,
        case
            when lu.grievance_status = 3 then lu.assigned_on
            when lu.grievance_status = 5 then lu.assigned_on
            else null
        end as grievance_generate_date,
        md.grievance_no,
        md.grievance_description,
        md.grievance_source,
        NULL AS grievance_source_name,
        md.applicant_name,
        md.pri_cont_no,
        md.grievance_generate_date as grievance_generate_date_gm,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        cdm2.district_name,
        md.block_id,
        cbm.block_name,
        md.municipality_id,
        cmm.municipality_name,
        CASE
            WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
            WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
            ELSE NULL
        END AS block_or_municipalty_name,
        md.gp_id,
        cgpm.gp_name,
        md.ward_id,
        cwm.ward_name,
        CASE
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
            ELSE NULL
        END AS gp_or_ward_name,
        md.atn_id,
        COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
        COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
        COALESCE(md.current_atr_date, NULL) AS current_atr_date,
        md.assigned_to_position,
        CASE
            WHEN md.assigned_to_office_id IS NULL THEN 'N/A'
            WHEN md.assigned_to_office_id = 5 THEN 'Pending At CMO'
            -- ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] ')
            -- ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' - ', csom.suboffice_name, ') ]')
            when csom.suboffice_name is not null then CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' - ', csom.suboffice_name, ') ]')
            when csom.suboffice_name is null then CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ') ]')
        END AS assigned_to_office_name,
        md.assigned_to_id,
        CASE
            WHEN md.status = 1 THEN md.grievance_generate_date
            ELSE md.updated_on -- + interval '5 hour 30 Minutes'
        END AS updated_on,
        md.status,
        cdlm.domain_value AS status_name,
        cdlm.domain_abbr AS grievance_status_code,
        md.emergency_flag,
        md.police_station_id,
        cpsm.ps_name,
        lu.grievance_status as grievance_historical_status,
--        pa.pending_days as pending_days_at_hod,
--        ph.pending_days as pending_days_at_hoso,
        case 
        	when pa.pending_days is not null then pa.pending_days
        	else 0
        end as pending_days_at_hod, 
        case 
        	when ph.pending_days is not null then ph.pending_days
        	else 0
        end as pending_days_at_hoso
--        CASE
--        	WHEN pa.pending_days BETWEEN 0 AND 100 THEN '0-100 Days'
--        	WHEN pa.pending_days BETWEEN 101 AND 500 THEN '101-500 Days'
--        	WHEN pa.pending_days > 500 THEN '> 500 Days'
--    	END AS pending_day_range
    from grievance_master md
    INNER JOIN uinion_part as lu ON lu.grievance_id = md.grievance_id
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
    LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
    LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id
    LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
    LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
    LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
    left join pending_at_hod_mat_2 pa on pa.grievance_id = md.grievance_id
    left join pending_at_hoso_mat_2 ph on ph.grievance_id = md.grievance_id
    where 1=1 
--    and pa.pending_days between 8 and 15
--    and ph.pending_days between 8 and 15
      order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10
    
---------------------------------------------------------------------------------------------------------------------------
      
----------- HOD Count Register Pending For Update ---------
with uinion_part as (
    select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
    union
    select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
)
Select Count(1)
    from grievance_master md
    inner join uinion_part as lu on lu.grievance_id = md.grievance_id
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
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
    left join pending_at_hod_mat_2 pa on pa.grievance_id = md.grievance_id
    left join pending_at_hoso_mat_2 ph on ph.grievance_id = md.grievance_id
      
      
      
--------------------------------------------------------------------------------------------------------------------------------
    
    select * from grievance_master gm where gm.status = 14; --2964622'
    select * from grievance_lifecycle gl where gl.grievance_id = 5442634;
    select * from grievance_master gm where gm.grievance_no = 'SSM4690533';
    
    
    
   select * from forwarded_latest_3_bh_mat_2 as bh where bh.assigned_on ;
 ---------------------------------------------------------------------------------------------------------------------------------
   
   ------ Pendning Count For Received From CMO -----
   CREATE MATERIALIZED VIEW pending_at_hod_mat AS
   WITH latest_3 AS (
    SELECT DISTINCT ON (gl.grievance_id)
           gl.grievance_id,
           gl.assigned_on AS last_assigned_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 3
    ORDER BY gl.grievance_id, gl.assigned_on DESC
),
latest_14 AS (
    SELECT DISTINCT ON (gl.grievance_id)
           gl.grievance_id,
           gl.assigned_on AS last_update_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 14
    ORDER BY gl.grievance_id, gl.assigned_on DESC
)
SELECT 
    l3.grievance_id,
    CASE 
        WHEN l14.last_update_on IS NOT NULL AND l14.last_update_on > l3.last_assigned_on then 0
        else EXTRACT(DAY from (CURRENT_DATE - l3.last_assigned_on))
    END AS pending_days
FROM latest_3 l3
LEFT JOIN latest_14 l14 ON l3.grievance_id = l14.grievance_id;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------

------ Pendning Count For Received From HOD -------
CREATE MATERIALIZED VIEW pending_at_hoso_mat AS
WITH latest_7 AS (
    SELECT DISTINCT ON (gl.grievance_id)
           gl.grievance_id,
           gl.assigned_on AS last_assigned_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 7
    ORDER BY gl.grievance_id, gl.assigned_on DESC
),
latest_11 AS (
    SELECT DISTINCT ON (gl.grievance_id)
           gl.grievance_id,
           gl.assigned_on AS last_update_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 11
    ORDER BY gl.grievance_id, gl.assigned_on DESC
)
SELECT 
    l7.grievance_id,
    CASE 
        WHEN l11.last_update_on IS NOT NULL AND l11.last_update_on > l7.last_assigned_on then 0
        else EXTRACT(DAY from (CURRENT_DATE - l7.last_assigned_on))
    END AS pending_days
FROM latest_7 l7
LEFT JOIN latest_11 l11 ON l7.grievance_id = l11.grievance_id;
--------------------------------

--------------------------------------------------------------------------------------------------

------ Pendning Count For Received From Other HOD  -------
CREATE MATERIALIZED VIEW pending_at_other_hod_mat AS
WITH latest_5 AS (
    SELECT DISTINCT ON (gl.grievance_id)
           gl.grievance_id,
           gl.assigned_on AS last_assigned_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 5
    ORDER BY gl.grievance_id, gl.assigned_on DESC
),
latest_13 AS (
    SELECT DISTINCT ON (gl.grievance_id)
           gl.grievance_id,
           gl.assigned_on AS last_update_on
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status = 13
    ORDER BY gl.grievance_id, gl.assigned_on DESC
)
SELECT 
    l5.grievance_id,
    CASE 
        WHEN l13.last_update_on IS NOT NULL AND l13.last_update_on > l5.last_assigned_on then 0
        else EXTRACT(DAY from (CURRENT_DATE - l5.last_assigned_on))
    END AS pending_days
FROM latest_5 l5
LEFT JOIN latest_13 l13 ON l5.grievance_id = l13.grievance_id;
--------------------------------------------------------------------------------------------------

--------------- Hod Regiester Received From Other HOD  --------------------
SELECT distinct
    md.grievance_id, 
    CASE 
        -- WHEN (lu.grievance_status = 3 OR glsubq.grievance_status = 14) THEN 0
        -- WHEN (lu.grievance_status = 5 OR glsubq.grievance_status = 13) THEN 1
        when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
        when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13) then 1
        ELSE NULL
    END AS received_from_other_hod_flag,
    lu.grievance_status AS last_grievance_status,
    lu.assigned_on AS last_assigned_on,
    lu.assigned_to_office_id AS last_assigned_to_office_id,
    lu.assigned_by_office_id AS last_assigned_by_office_id,
    lu.assigned_by_position AS last_assigned_by_position,
    lu.assigned_to_position AS last_assigned_to_position,
    case 
        when lu.grievance_status = 5 then lu.assigned_on
        else null
    end AS grievance_generate_date,
    md.grievance_no,
    md.grievance_description,
    md.grievance_source,
    NULL AS grievance_source_name,
    md.applicant_name,
    md.pri_cont_no,
    md.grievance_generate_date as grievance_generate_date_gm,
    md.grievance_category,
    cgcm.grievance_category_desc,
    md.assigned_to_office_id,
    com.office_name,
    md.district_id,
    cdm2.district_name,
    md.block_id,
    cbm.block_name,
    md.municipality_id,
    cmm.municipality_name,
    CASE 
        WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
        WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
        ELSE NULL
    END AS block_or_municipalty_name,
    md.gp_id,
    cgpm.gp_name,
    md.ward_id,
    cwm.ward_name,
    CASE 
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
        ELSE NULL
    END AS gp_or_ward_name,
    md.atn_id,
    COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
    COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
    COALESCE(md.current_atr_date, NULL) AS current_atr_date,
    md.assigned_to_position,
    CASE 
        WHEN md.assigned_to_office_id IS NULL THEN 'N/A'
        WHEN md.assigned_to_office_id = 5 THEN 'Pending At CMO'
        -- ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] ')  
        -- ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' - ', csom.suboffice_name, ') ]') 
        when csom.suboffice_name is not null then CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' - ', csom.suboffice_name, ') ]')
        when csom.suboffice_name is null then CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ') ]')
    END AS assigned_to_office_name,
    md.assigned_to_id,
    CASE 
        WHEN md.status = 1 THEN md.grievance_generate_date
        ELSE md.updated_on -- + interval '5 hour 30 Minutes' 
    END AS updated_on,
    md.status,
    cdlm.domain_value AS status_name,
    cdlm.domain_abbr AS grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name,
    case 
    	when po.pending_days is not null then po.pending_days
    	else 0
    end as pending_days_at_other_hod,
    case 
    	when ph.pending_days is not null then ph.pending_days
    	else 0
    end as pending_days_at_hoso
FROM grievance_master_bh_mat_2 md
INNER JOIN forwarded_latest_5_bh_mat_2 as lu ON lu.grievance_id = md.grievance_id
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
LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id 
LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id   
left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id      
left join pending_at_other_hod_mat_2 po on po.grievance_id = md.grievance_id 
left join pending_at_hoso_mat_2 ph on ph.grievance_id = md.grievance_id
  where lu.assigned_to_office_id = 35   order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10 
  
  

  
  
  
  
  
with uinion_part as (       
                    select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35 
                    union
                    select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
            )
            Select Count(1)  
                from grievance_master md
                inner join uinion_part as lu on lu.grievance_id = md.grievance_id 
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
                left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
              
              
              select table_name, key, refreshed_on from mat_view_refresh_scheduler where key in (1,2,3,4,5,20,21) and is_refresh_lock is false