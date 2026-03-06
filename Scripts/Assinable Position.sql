
-- ============================================================================
-- Assignable Position Debug
-- ============================================================================
select
	apm.position_id,
    apm.role_master_id,
    case
        when apm.sub_office_id is null and apm.office_id is not null then apm.office_id
        when apm.sub_office_id is not null and apm.office_id is not null then apm.sub_office_id
    end as office_id,
    case
        when apm.sub_office_id is null and apm.office_id is not null then com.office_name
        when apm.sub_office_id is not null and apm.office_id is not null then csom.suboffice_name
    end as office_name,
    apm.office_category as office_category_id,
    cdlm1.domain_value as office_category_name,
    apm.office_type,
    cdlm2.domain_value as office_type_name,
    com.district_id,
    case
        when com.district_id = 999 then null
        when com.district_id = 99 then null
        else cdm.district_name
    end as district_name,
    aurm.role_master_name,
    aurm.role_code
from admin_position_master apm
left join cmo_office_master com on com.office_id = apm.office_id
left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
inner join cmo_domain_lookup_master cdlm1 on cdlm1.domain_code = apm.office_category and cdlm1.domain_type = 'office_category'
inner join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = apm.office_type and cdlm2.domain_type = 'office_type'
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
left join cmo_districts_master cdm on cdm.district_id = com.district_id
where apm.position_id > 0 
    and apm.record_status = 1
    and apm.position_id in (12658)
    and apm.office_id in (40,40)
    and apm.role_master_id in (4)
order by office_type,role_master_id,office_name asc;







select * from admin_user au where au.admin_user_id = 8485;
select * from admin_user_details aud where aud.admin_user_id = 8485;
select * from admin_user_position_mapping aupm where aupm.admin_user_id = 8485;
select * from admin_position_master apm where apm.position_id = 8485;


select gm.grievance_id, gm.status, gm.assigned_by_office_cat, gm.assigned_by_office_id, gm.updated_by_position, gm.updated_by,
gm.assigned_to_office_cat, gm.assigned_to_office_id, gm.assigned_to_position, gm.assigned_to_id
from  grievance_master gm where gm.grievance_id = 2963321;


select apm.position_id, apm.office_category, apm.role_master_id, apm.office_type, apm.office_id, apm.sub_office_id, apm.record_status 
from admin_position_master apm where apm.position_id in (12658,16551,3195);


select  gl.assigned_on, gl.grievance_status, gl.assigned_by_position, gl.assigned_by_office_id, gl.assigned_by_id, 
gl.assigned_to_position, gl.assigned_to_office_id, gl.assigned_to_id
from grievance_lifecycle gl
where gl.grievance_id = 2963321
order by gl.assigned_on asc;


select * from control_json where status = 1;



select assigned_by_position from grievance_lifecycle 
where grievance_id = 2963321 and grievance_status = 7 and assigned_to_position = 3195
order by assigned_on desc limit 1;


select * from admin_position_master apm where office_id = 40 and apm.role_master_id = 5 and apm.record_status = 1;   --apm.position_id in (12658,15543);