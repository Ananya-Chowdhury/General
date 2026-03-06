select gm.*, cdm.lg_directory_district_code as lgd_dist, cbm.lg_directory_block_code as lgd_block, cmm.lg_directory_block_code as lgd_mun
    from grievance_master gm 
    inner join admin_position_master apm on gm.assigned_to_position = apm.position_id 
    left join cmo_districts_master cdm on cdm.district_id = gm.district_id
    left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
    where gm.status = 4 
        and apm.office_id = 53 and apm.sub_office_id is null
--        and gm.grievance_generate_date::date between '{from_date_time}' and '{to_date_time}';