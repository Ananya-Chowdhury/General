--==================== WBIDC DATABASE CREDENTIALS ==========================

--GRANT ALL PRIVILEGES ON DATABASE wbidc to wbidc_admin_user;

--SELECT grantee, privilege_type 
--FROM information_schema.role_database_privileges 
--WHERE grantee = 'wbidc_admin_user';

--\c wbidc;

--create database wbicd;
--create role wbidc_admin_user with login password 'WBIDCdev@2025#';
--grant all privileges on database wbicd to wbidc_admin_user; 
--ALTER DATABASE wbicd RENAME TO wbidc;
--\c wbidc;
--GRANT ALL ON SCHEMA public TO wbidc_admin_user;


--- Terminate All the connection ---
--SELECT pg_terminate_backend(pid)
--FROM pg_stat_activity
--WHERE datname = 'wbicd' AND pid <> pg_backend_pid();


---- Check the active user connection on database ---
--SELECT pid, usename, application_name, client_addr
--FROM pg_stat_activity
--WHERE datname = 'wbicd';

---==============================================================================================================================

----- QUery ------
select * from parameter_master pm ;
select * from user_token ut ;
select * from domain_lookup_master dlm ;


select * from districts_master dm ;


select
    iur.inds_user_id,
    iur.industrialist_name,
    iur.industrialist_email,
    iur.industrialist_phone,
    iur.industrialist_desig,
    iur.industrialist_org,
    iur.gst,
    iur.pan_num,
    iur.status,
    case when iur.status = 1 then 'ACTIVE' else 'INACTIVE' end as status_name
from industrial_user_register iur
where 1 = 1;

select
    count(1) as total_count
from industrial_user_register iur
where 1 = 1;
----------------------------------------------
------ User grievance Listing Query ----------
select 
    g.grievance_id,
    g.grievance_code,
    g.grievance_type,
    case 
        when g.grievance_type = 1 then 'Grievance' 
    else 'Query' end as grievance_type_name,
    g.grievance_desc,
    g.grievance_status,
    case 
        when g.grievance_status = 1 then 'Active' 
    else 'Inactive' end as grievance_status_name,
    g.created_by,
    g.created_on,
    g.updated_on,
    g.updated_by,
    g.project_id,
    g.severity,
    case 
        when g.severity = 1 then 'Low' 
        when g.severity = 2 then 'Medium'
    else 'High' end as severity_name,
    g.shilpa_sathi_griv_id,
    p.project_title,
    p.project_desc,
    p.properietor_name,
    p.registered_address,
    p.project_status,
    p.estimate_cost,
    p.estimate_land_required,
    p.district_id,
    dm.district_name,
    p.strategic_importance
from grievance g 
inner join projects p on p.project_id = g.project_id
inner join industrial_user_register iur on iur.inds_user_id = g.created_by
inner join districts_master dm on dm.district_id = p.district_id

------ User Count Query -------
select
    count(1) as total_count
from grievance g 
inner join projects p on p.project_id = g.project_id
inner join industrial_user_register iur on iur.inds_user_id = g.created_by
where 1 = 1;

----------------------------------------------------------

------- Departmental User Count ---------
select * from grievance g;
select * from grievance_departments gd ;
select * from department d ;
select * from projects p;
select * from admin_user au ;
select * from grievance_departments gd ;




select
	g.grievance_id,
	g.grievance_type,
	g.grievance_desc,
	g.grievance_status,
	g.created_on,
	g.created_by,
	g.updated_by,
	g.project_id,
	g.project_id,
	g.severity,
	g.shilpa_sathi_griv_id,
	g.grievance_code,
	gd.department,
	gd.description,
	gd.status,
	gd.griv_dept_code,
	d.dept_name,
	d.dept_code,
	d.status,
	d.dept_abbre
from grievance g
inner join grievance_departments gd on gd.grievance_id = g.grievance_id
inner join department d on d.dept_id = gd.department 
where gd.department = 11;


select
	g.grievance_id,
	g.grievance_type,
	g.grievance_desc,
	g.grievance_status,
	g.created_on,
	g.created_by,
	g.updated_by,
	g.project_id,
	g.project_id,
	g.severity,
	g.shilpa_sathi_griv_id,
	g.grievance_code,
	gd.department,
	gd.description,
	gd.status,
	gd.griv_dept_code
--	d.dept_name,
--	d.dept_code,
--	d.status,
--	d.dept_abbre
from grievance_departments gd
inner join grievance g on gd.grievance_id = g.grievance_id
inner join department d on d.dept_id = gd.department 
--where gd.department = 11;


-- admin_user au dept_id = grievance_department griev_dept_id

select *
	from grievance_departments gd
	inner join grievance g on gd.grievance_id = g.grievance_id
	inner join admin_user au on au.dept_id = gd.griev_dept_id
	where au.user_type_id = 2



select 
	g.grievance_id,
	g.grievance_code,
	g.grievance_type,
	g.grievance_desc,
	g.grievance_status,
	g.created_on,
	g.created_by,
	g.updated_by,
	g.project_id,
	g.severity,
	g.shilpa_sathi_griv_id,
	gd.department,
	gd.description,
	gd.status,
	gd.griv_dept_code,
	d.dept_name,
	d.dept_code,
	d.status,
	d.dept_abbre,
	au.admin_user_id 
from grievance_departments gd
inner join grievance g on gd.grievance_id = g.grievance_id
inner join department d on d.dept_id = gd.department 
inner join admin_user au on au.dept_id = d.dept_id
--inner join domain_lookup_master dlm on dlm.domain_type 
where au.admin_user_id = 6;



select 
	g.grievance_id,
	g.grievance_code,
	g.grievance_type,
	dlm.domain_value as grievance_type_name,
	g.grievance_desc,
	g.grievance_status,
	dlm1.domain_value as grievance_status_name,
	g.created_on,
	g.created_by,
	g.updated_on,
	g.updated_by,
	g.project_id,
	g.severity,
	dlm2.domain_value as severity_name,
	g.shilpa_sathi_griv_id,
	p.project_title,
	p.project_desc,
	p.properietor_name,
	p.registered_address,
	p.project_status,
	p.estimate_cost,
	p.estimate_land_required,
	p.strategic_importance,
	p.district_id,
	dm.district_name,
	gd.department,
	gd.description,
	gd.status as grievance_departmental_status,
	gd.griv_dept_code,
	d.dept_name,
	d.dept_code,
	d.status,
	dlm3.domain_value as department_status,
	d.dept_abbre,
	au.admin_user_id 
from grievance_departments gd
inner join grievance g on gd.grievance_id = g.grievance_id
inner join department d on d.dept_id = gd.department 
inner join admin_user au on au.dept_id = d.dept_id
inner join projects p on p.project_id = g.project_id
inner join districts_master dm on dm.district_id = p.district_id
inner join domain_lookup_master dlm on dlm.domain_code = g.grievance_type and dlm.domain_type = 'griev_type'
inner join domain_lookup_master dlm1 on dlm1.domain_code = g.grievance_status and dlm1.domain_type = 'grievance_status'
inner join domain_lookup_master dlm2 on dlm2.domain_code = g.severity and dlm2.domain_type = 'severity'
inner join domain_lookup_master dlm3 on dlm3.domain_code = g.severity and dlm3.domain_type = 'status'
where au.admin_user_id = 6;



inner join projects p on p.project_id = g.project_id
inner join industrial_user_register iur on iur.inds_user_id = g.created_by
inner join districts_master dm on dm.district_id = p.district_id 
inner join domain_lookup_master dlm on dlm.domain_code = g.severity and dlm.domain_type = 'severity'
inner join domain_lookup_master dlm2 on dlm2.domain_code = g.grievance_status and dlm2.domain_type = 'grievance_status'
inner join domain_lookup_master dlm3 on dlm3.domain_code = g.grievance_type and dlm3.domain_type = 'griev_type'

---- login payload : { logged_user_type = 2, logged_user_id = 1}
--- for dept (logged_user_id = admin_user_id = dept_id = grievance_department_id)


select * from admin_user au where au.admin_user_id = 1

select dept_id from admin_user au 
where au.admin_user_id = 6;
 
----------------------------------------------------------------------------- DASHBOARD --------------------------------------------------------------------------------------------------

 WITH received_counts as (
    select count(1) as __rec__, bm.assigned_by_office_id
    from {atr_latest_14_bh_mat_variable} as bm
    inner join {forwarded_latest_3_bh_mat_variable} as bh ON bm.grievance_id = bh.grievance_id
    where bm.current_status in (14,15)
    {ssm_id} {dept_id_p}
    group by bm.assigned_by_office_id
), pending_counts AS (
    select bm.assigned_to_office_id, COUNT(1) AS _pndddd_
    from {forwarded_latest_3_bh_mat_variable} as bm
    where NOT EXISTS (SELECT 1 FROM {atr_latest_14_bh_mat_variable} as bh WHERE bm.grievance_id = bh.grievance_id AND bh.current_status IN (14, 15))
    {ssm_id} {dept_id_r}
    group by bm.assigned_to_office_id
), 
processing_unit AS (
    SELECT com.office_id, com.office_name, COALESCE(pc._pndddd_, 0) AS atr_pending_count, COALESCE(rc.__rec__, 0) as  atr_received_count, com.office_type 
    FROM cmo_office_master com
    LEFT JOIN pending_counts pc ON com.office_id = pc.assigned_to_office_id
    LEFT JOIN received_counts rc ON com.office_id = rc.assigned_by_office_id
    WHERE com.office_name != 'Chief Ministers Office'
)
SELECT 
    '{refresh_time}'::timestamp as refresh_time_utc,
    pu.office_id, 
    pu.office_name, 
    pu.office_type,
    pu.atr_received_count,
    pu.atr_pending_count,
    case when coalesce(atr_received_count,0) > 0 then ((coalesce(atr_received_count,0)::float / ( coalesce(atr_received_count,0) + coalesce(atr_pending_count,0))) * 100) else 0 end as atr_received_count_percentage,
    case when coalesce(atr_pending_count,0) > 0 then ((coalesce(atr_pending_count,0)::float / ( coalesce(atr_received_count,0) + coalesce(atr_pending_count,0))) * 100) else 0 end as atr_pending_count_percentage
from processing_unit pu
{dept_id_q}
order by pu.atr_pending_count DESC;


with total_atr_receive AS (
    select count(1) as atr_recieved, bm.district_id
        from {atr_latest_14_bh_mat_variable} as bm
        inner join {forwarded_latest_3_bh_mat_variable} as bh ON bm.grievance_id = bh.grievance_id
        where bm.current_status in (14,15) {ssm_id_p} {dept_id_p}
        group by bm.district_id
),total_atr_pending as (
    select count(1) as atr_pending, bm.district_id 
        from {forwarded_latest_3_bh_mat_variable} as bm
        where not exists ( SELECT 1 FROM {atr_latest_14_bh_mat_variable} as bh WHERE bh.grievance_id = bm.grievance_id and bh.current_status in (14,15))
        {ssm_id_p} {dept_id_q}
        group by bm.district_id
)
select 
    '{refresh_time}'::timestamp as refresh_time_utc,
        cdm.district_name::text,
        coalesce(atr_recieved,0) as atr_received_count,
        coalesce(atr_pending,0) as atr_pending_count,
        case when coalesce(atr_recieved,0) > 0 then ((coalesce(atr_recieved,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_received_count_percentage,
        case when coalesce(atr_pending,0) > 0 then ((coalesce(atr_pending,0)::float / ( coalesce(atr_recieved,0) + coalesce(atr_pending,0))) * 100) else 0 end as atr_pending_count_percentage
        from cmo_districts_master cdm 
    left join total_atr_receive tar on cdm.district_id = tar.district_id
    left join total_atr_pending tap on tar.district_id = tap.district_id
order by 3 desc;


----------------------------------------------------------------------------------------- DASHBOARD  for cs and wb ---------------------------------------------------------
SELECT 
    COUNT(1) AS received,
    COUNT(CASE WHEN g.grievance_status not in (1, 4) THEN 1 END) AS forwarded,
    COUNT(CASE WHEN g.grievance_status = 2 THEN 1 END) AS atr_pending,
    COUNT(CASE WHEN g.grievance_status = 3 THEN 1 END) AS disposed
FROM grievance g
where 1 = 1

---------------------------------------------------------------------------------

select count(1) from grievance g 
inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
inner join department d on d.dept_id = gd.department 
inner join projects p on p.project_id = g.project_id 
where gd.department = 8;

-------------------------------------------------------------------------------

select count(1) from grievance g 
inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
inner join department d on d.dept_id = gd.department 
inner join projects p on p.project_id = g.project_id 
inner join districts_master dm on dm.district_id = p.district_id 
where gd.department = 8;


select count(1) as district_count
from grievance g 
inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
inner join department d on d.dept_id = gd.department 
inner join projects p on p.project_id = g.project_id 
inner join districts_master dm on dm.district_id = p.district_id 
left join admin_user au on au.dept_id = d.dept_id 
where p.district_id = 12;

-------------------------------------district wise------------------------------------------

WITH atr_received_count as (
    select count(1) as atr_recieved, p.district_id
    from grievance g 
		inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where g.grievance_status = 4
    group by p.district_id
 ), atr_pendiing_count as (
  select count(1) as atr_pending, p.district_id
    from grievance g 
		inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where g.grievance_status = 2 
    group by p.district_id
  )
  	select 
  		dm.district_id as district_id,
  		dm.district_name as district_name,
  		coalesce(arc.atr_recieved,0) as received_count,
        coalesce(apc.atr_pending,0) as pending_count
       from districts_master dm
       left join atr_received_count arc on arc.district_id = dm.district_id 
       left join atr_pendiing_count apc on apc.district_id = dm.district_id;
 
      
      ------------------------------- department wise -----------------------------
 WITH atr_received_count as (
    select count(1) as atr_recieved, d.dept_id
    from grievance g 
		inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where g.grievance_status = 4
    group by d.dept_id
 ), atr_pendiing_count as (
  select count(1) as atr_pending, d.dept_id
    from grievance g 
		inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where g.grievance_status = 2 
    group by d.dept_id
  )
  	select 
  		d.dept_id as department_id,
  		d.dept_name as department_name,
  		coalesce(arc.atr_recieved,0) as received_count,
        coalesce(apc.atr_pending,0) as pending_count
       from department d
       left join atr_received_count arc on arc.dept_id = d.dept_id 
       left join atr_pendiing_count apc on apc.dept_id = d.dept_id;
     
      -------------------------------------------------------------------------------------- DASHBOARD for Department --------------------------------------------------------------
      
      
      SELECT 
        COUNT(1) AS received,
        COUNT(CASE WHEN gd.status in (1, 2, 4, 5) THEN 1 END) AS atr_pending,
        COUNT(CASE WHEN gd.status = 3 THEN 1 END) AS disposed
    FROM grievance_departments gd
    INNER JOIN grievance g on g.grievance_id = gd.grievance_id and gd.department = {dept_id}
    where 1 = 1
    
     ------------------------------- department wise -----------------------------
 WITH atr_received_count as (
    select count(1) as atr_recieved, d.dept_id
    from grievance_departments gd 
		inner join grievance g on gd.grievance_id = g.grievance_id and gd.department = {dept_id}
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where gd.status = 3
    group by d.dept_id
 ), atr_pendiing_count as (
  select count(1) as atr_pending, d.dept_id
    from grievance_departments gd
		inner join grievance g on gd.grievance_id = g.grievance_id and gd.department = {dept_id}
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where gd.status in (1, 2, 4, 5)
    group by d.dept_id
  )
  	select 
  		d.dept_id as department_id,
  		d.dept_name as department_name,
  		coalesce(arc.atr_recieved,0) as received_count,
        coalesce(apc.atr_pending,0) as pending_count
       from department d
       left join atr_received_count arc on arc.dept_id = d.dept_id 
       left join atr_pendiing_count apc on apc.dept_id = d.dept_id;
      
     -------------------------------------district wise------------------------------------------

WITH atr_received_count as (
    select count(1) as atr_recieved, p.district_id
    from grievance_departments gd 
		inner join grievance g on gd.grievance_id = g.grievance_id and gd.department = {dept_id}
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where gd.status = 3
    group by p.district_id
 ), atr_pendiing_count as (
  select count(1) as atr_pending, p.district_id
    from grievance_departments gd 
		inner join grievance g on gd.grievance_id = g.grievance_id and gd.department = {dept_id}
		inner join department d on d.dept_id = gd.department 
		inner join projects p on p.project_id = g.project_id 
		inner join districts_master dm on dm.district_id = p.district_id 
		where gd.status in (1, 2, 4, 5)
    group by p.district_id
  )
  	select 
  		dm.district_id as district_id,
  		dm.district_name as district_name,
  		coalesce(arc.atr_recieved,0) as received_count,
        coalesce(apc.atr_pending,0) as pending_count
       from districts_master dm
       left join atr_received_count arc on arc.district_id = dm.district_id 
       left join atr_pendiing_count apc on apc.district_id = dm.district_id;
      
      
  -------------------------------------------------- individual department chart --------------------------
      WITH atr_received_count as (
        select count(1) as atr_recieved, d.dept_id
        from grievance_departments gd 
            inner join grievance g on gd.grievance_id = g.grievance_id and gd.department = {dept_id}
            inner join department d on d.dept_id = gd.department 
            inner join projects p on p.project_id = g.project_id 
            inner join districts_master dm on dm.district_id = p.district_id 
            where gd.status = 3 {query}
        group by d.dept_id
    ), atr_pendiing_count as (
    select count(1) as atr_pending, d.dept_id
        from grievance_departments gd
            inner join grievance g on gd.grievance_id = g.grievance_id and gd.department = {dept_id}
            inner join department d on d.dept_id = gd.department 
            inner join projects p on p.project_id = g.project_id 
            inner join districts_master dm on dm.district_id = p.district_id 
            where gd.status in (1, 2, 4, 5) {query}
        group by d.dept_id
    ), disposed_count as (
    select count(1) as disposed, d.dept_id, 
    0 AS benefit_provided,
    0 AS benefit_provided_percentage,
    0 AS average_days_taken_to_resolved
        from grievance_departments gd
            inner join grievance g on gd.grievance_id = g.grievance_id and gd.department = {dept_id}
            inner join department d on d.dept_id = gd.department 
            inner join projects p on p.project_id = g.project_id 
            inner join districts_master dm on dm.district_id = p.district_id 
            where gd.status = 3 {query}
        group by d.dept_id
    )
    select 
        d.dept_id as department_id,
        d.dept_name as department_name,
        coalesce(arc.atr_recieved,0) as received_count,
        coalesce(apc.atr_pending,0) as pending_count,
        coalesce(dc.disposed,0) as disposed,
        coalesce(dc.benefit_provided,0) as benefit_provided,
        coalesce(dc.benefit_provided_percentage,0) as benefit_provided_percentage,
        coalesce(dc.average_days_taken_to_resolved,0) as average_days_taken_to_resolved
    from department d
    left join atr_received_count arc on arc.dept_id = d.dept_id 
    left join atr_pendiing_count apc on apc.dept_id = d.dept_id
    left join disposed_count dc on dc.dept_id = d.dept_id
    
    ---------------------------------------------------------------------------------------------------------------------------------------------------
   ---- Testing Query -----
   
    select 
    gl.grievance_lifecycle_id,
    gl.grievance_id,
    gl.comment as griev_lifecycle_comment,
    gl.grievance_status as grievance_status,
    gl.assigned_by_type,
    dlm1.domain_value as grievance_assigned_by_name,
    gl.assign_comment,
    gl.assigned_to_type as assigned_type,
    dlm2.domain_value as grievance_assigned_to_name,
    gl.assigned_to_id as assigned_id,
    aud.official_name as assigned_official_name,
    aud.official_code as assigned_official_designation,
    au.dept_id as department_id,
    d.dept_name as department_name,
    gl.created_on as grievance_created_on,
    gl.grievance_lifecycle_status as grievance_lifecycle_status,
    dlm.domain_value as grievance_lifecycle_status_name
from grievance_lifecycle gl
inner join grievance g on g.grievance_id = gl.grievance_id
inner join admin_user au on au.admin_user_id = gl.assigned_to_id
inner join admin_user_details aud on aud.admin_user_id = au.admin_user_id
inner join domain_lookup_master dlm on dlm.domain_code = g.grievance_status and dlm.domain_type = 'status'
inner join domain_lookup_master dlm1 on dlm1.domain_code = gl.assigned_by_type and dlm1.domain_type = 'user_type'
inner join domain_lookup_master dlm2 on dlm2.domain_code = gl.assigned_to_type and dlm2.domain_type = 'user_type'
left join department d on d.dept_id = au.dept_id 
where gl.grievance_status != 2 and gl.grievance_id = 10043 order by gl.grievance_lifecycle_id desc;
  


---- dept details ----
select 
    gd.griev_dept_id,
    gd.department,
    d.dept_name,
    gd.description as griev_dept_description,
    gd.created_on as griev_dept_created_on,
    gd.updated_on as griev_dept_updated_on,
    gd.griv_dept_code,
    gd.status as griev_dept_status,
    dlm.domain_value as griev_dept_status_name
from grievance_departments gd
inner join department d on d.dept_id = gd.department 
inner join domain_lookup_master dlm on dlm.domain_code = gd.status and dlm.domain_type = 'griev_dept_status'
where gd.status = 1 and gd.grievance_id = 10043 order by gd.griev_dept_id desc;
    


-------------------------------------------------------------------------------------------------------------------------------------


select 
    g.grievance_id,
    g.grievance_code,
    g.grievance_type,
    dlm3.domain_value as grievance_type_name,
    g.grievance_desc,
    g.grievance_status,
    dlm2.domain_value as grievance_status_name,
    g.created_by,
    g.created_on,
    g.updated_on,
    g.updated_by,
    g.project_id,
    g.severity,
    dlm.domain_value as severity_name,
    g.shilpa_sathi_griv_id,
    p.project_id,
    p.project_title,
    p.project_desc,
    p.properietor_name,
    p.registered_address,
    p.project_status,
    p.estimate_cost,
    p.estimate_land_required,
    p.district_id,
    dm.district_name,
    p.strategic_importance,
    iur.industrialist_name as lodged_by
from grievance g 
inner join projects p on p.project_id = g.project_id
inner join industrial_user_register iur on iur.inds_user_id = g.created_by
inner join districts_master dm on dm.district_id = p.district_id 
inner join domain_lookup_master dlm on dlm.domain_code = g.severity and dlm.domain_type = 'severity'
inner join domain_lookup_master dlm2 on dlm2.domain_code = g.grievance_status and dlm2.domain_type = 'grievance_status'
inner join domain_lookup_master dlm3 on dlm3.domain_code = g.grievance_type and dlm3.domain_type = 'griev_type'
where iur.inds_user_id = 1;




select 
    gl.grievance_lifecycle_id,
    gl.grievance_id,
    gl.comment as griev_lifecycle_comment,
    gl.grievance_status as grievance_status,
    dlm.domain_value as grievance_status_name,
    gl.assigned_by_type,
    dlm1.domain_value as grievance_assigned_by_name,
    gl.assign_comment,
    gl.assigned_to_type as assigned_type,
    dlm2.domain_value as grievance_assigned_to_name,
    gl.assigned_to_id as assigned_id,
    aud.official_name as assigned_official_name,
    aud.official_code as assigned_official_designation,
    au.dept_id as department_id,
    d.dept_name as department_name,
    gl.created_on as grievance_created_on,
    gl.grievance_lifecycle_status as grievance_lifecycle_status
from grievance_lifecycle gl
inner join grievance g on g.grievance_id = gl.grievance_id
inner join admin_user au on au.admin_user_id = gl.assigned_to_id
inner join admin_user_details aud on aud.admin_user_id = au.admin_user_id
inner join domain_lookup_master dlm on dlm.domain_code = g.grievance_status and dlm.domain_type = 'grievance_status'
inner join domain_lookup_master dlm1 on dlm1.domain_code = gl.assigned_by_type and dlm1.domain_type = 'user_type'
inner join domain_lookup_master dlm2 on dlm2.domain_code = gl.assigned_to_type and dlm2.domain_type = 'user_type'
left join department d on d.dept_id = au.dept_id 
where gl.grievance_status != 2 and gl.grievance_id = 1 order by gl.grievance_lifecycle_id desc





grievance_status_json : {"1" : "2", "2" : "3"}

grievance_dept_status_json : {"1" : "2,4", "2" : "3,4,5", "5" : "6", "6" : "3,4,5"}



select 
    gdl.griev_dept_lifecycle_id,
    gdl.comment as grievance_dept_lifecycle_comment,
    gdl.grievance_status as grievance_status,
    gdl.assigned_to_type as assigned_type,
    gdl.assigned_by_type as assigned_by_type,
    gdl.assign_comment as dept_assign_comment,
    gdl.assigned_to_id as assigned_id,
    gdl.closure_reason_id as closure_reason_id,
    cr.closure_reason_name as closure_reason_name,
    gdl.griev_dept_lifecycle_status as grievance_dept_lifecycle_status,
    dlm.domain_value as griev_dept_status_name,
    gdl.created_by,
    dlm1.domain_value as grievance_created_by_name,
    gdl.department_id as griev_dept_id,
    gdl.grievance_id as grievance_id
from grievance_departments_lifecycle gdl
inner join domain_lookup_master dlm on dlm.domain_code = gdl.griev_dept_lifecycle_status and dlm.domain_type = 'griev_dept_status'
inner join domain_lookup_master dlm1 on dlm1.domain_code = gdl.created_by and dlm1.domain_type = 'user_type'
inner join grievance_departments gd on gd.griev_dept_id = gdl.department_id
inner join department d on d.dept_id = gd.department
inner join grievance g on g.grievance_id = gdl.grievance_id
left join closure_reason cr on cr.closure_reason_id = gdl.closure_reason_id
where gdl.grievance_id = 9


select 
    gd.griev_dept_id,
    gd.department,
    d.dept_name,
    gd.description as griev_dept_description,
    gd.created_on as griev_dept_created_on,
    gd.updated_on as griev_dept_updated_on,
    gd.griv_dept_code,
    gd.status as griev_dept_status,
    dlm.domain_value as griev_dept_status_name
from grievance_departments gd
inner join department d on d.dept_id = gd.department 
inner join domain_lookup_master dlm on dlm.domain_code = gd.status and dlm.domain_type = 'griev_dept_status'
where  gd.grievance_id = 1




select 
    gdl.griev_dept_lifecycle_id,
    gdl.comment as grievance_dept_lifecycle_comment,
    gdl.grievance_status as grievance_status,
    gdl.assigned_to_type as assigned_type,
    gdl.assigned_by_type as assigned_by_type,
    gdl.assign_comment as dept_assign_comment,
    gdl.assigned_to_id as assigned_id,
    gdl.closure_reason_id as closure_reason_id,
    cr.closure_reason_name as closure_reason_name,
    gdl.griev_dept_lifecycle_status as grievance_dept_lifecycle_status,
    dlm.domain_value as griev_dept_status_name,
    gdl.created_by,
    gdl.department_id as griev_dept_id,
    gdl.grievance_id as grievance_id,
    gdl.assigned_on as griev_dept_assigned_on
from grievance_departments_lifecycle gdl
inner join domain_lookup_master dlm on dlm.domain_code = gdl.griev_dept_lifecycle_status and dlm.domain_type = 'griev_dept_status'
inner join grievance_departments gd on gd.griev_dept_id = gdl.department_id
inner join department d on d.dept_id = gd.department
inner join grievance g on g.grievance_id = gdl.grievance_id
left join closure_reason cr on cr.closure_reason_id = gdl.closure_reason_id
where gdl.grievance_id = 9



select 
    gl.grievance_lifecycle_id,
    gl.grievance_id,
    gl.comment as griev_lifecycle_comment,
    gl.grievance_status as grievance_status,
    dlm.domain_value as grievance_status_name,
    gl.assigned_by_type,
    dlm1.domain_value as grievance_assigned_by_name,
    gl.assign_comment,
    gl.assigned_to_type as assigned_type,
    dlm2.domain_value as grievance_assigned_to_name,
    gl.assigned_to_id as assigned_id,
    aud.official_name as assigned_official_name,
    aud.official_code as assigned_official_designation,
    au.dept_id as department_id,
    d.dept_name as department_name,
    gl.created_on as grievance_created_on,
    gl.grievance_lifecycle_status as grievance_lifecycle_status
from grievance_lifecycle gl
inner join grievance g on g.grievance_id = gl.grievance_id
inner join admin_user au on au.admin_user_id = gl.assigned_to_id
inner join admin_user_details aud on aud.admin_user_id = au.admin_user_id
inner join domain_lookup_master dlm on dlm.domain_code = gl.grievance_status and dlm.domain_type = 'grievance_status'
inner join domain_lookup_master dlm1 on dlm1.domain_code = gl.assigned_by_type and dlm1.domain_type = 'user_type'
inner join domain_lookup_master dlm2 on dlm2.domain_code = gl.assigned_to_type and dlm2.domain_type = 'user_type'
left join department d on d.dept_id = au.dept_id 
where gl.grievance_status != 2 and gl.grievance_id = 9 order by gl.grievance_lifecycle_id desc


select 
    g.grievance_id,
    g.grievance_code,
    g.grievance_type,
    dlm3.domain_value as grievance_type_name,
    g.grievance_desc,
    g.grievance_status,
    dlm2.domain_value as grievance_status_name,
    g.created_by,
    g.created_on,
    g.updated_on,
    g.updated_by,
    g.project_id,
    g.severity,
    dlm.domain_value as severity_name,
    g.shilpa_sathi_griv_id,
    p.project_id,
    p.project_title,
    p.project_desc,
    p.properietor_name,
    p.registered_address,
    p.project_status,
    p.estimate_cost,
    p.estimate_land_required,
    p.district_id,
    dm.district_name,
    p.strategic_importance,
    iur.industrialist_name as lodged_by,
    case 
        when g.grievance_status in (3, 4) 
        then DATE_PART('day', g.updated_on - g.created_on)::int 
        else DATE_PART('day', now() - g.created_on)::int
    end AS pending_for,
    case 
        when g.grievance_status in (3, 4) 
        then false 
        else true 
    end AS is_pending
from grievance g 
inner join projects p on p.project_id = g.project_id
inner join industrial_user_register iur on iur.inds_user_id = g.created_by
inner join districts_master dm on dm.district_id = p.district_id 
inner join domain_lookup_master dlm on dlm.domain_code = g.severity and dlm.domain_type = 'severity'
inner join domain_lookup_master dlm2 on dlm2.domain_code = g.grievance_status and dlm2.domain_type = 'grievance_status'
inner join domain_lookup_master dlm3 on dlm3.domain_code = g.grievance_type and dlm3.domain_type = 'griev_type'
    where 1=1 
 and pending_for >= '0' and pending_for <= '7' order by g.grievance_id desc
    limit 10 offset 0;
    
   
   
   
   
 select * from user_otp uo where uo.user_phone = '6666666666' order by uo.created_on desc;
 
select distinct p.* from projects p 
inner join grievance g on g.project_id = p.project_id 
inner join grievance_departments gd on gd.grievance_id = g.grievance_id and gd.department = 3
where 1 = 1  and p.project_id = 1;



select * from grievance_departments_lifecycle gdl where griev_dept_lifecycle_status = 6;
select * from grievance g where g.grievance_id = 17;
select * from grievance_departments gd where gd.griev_dept_id = 27;




WITH atr_pendiing_count as (
select count(1) as atr_pending, d.dept_id
    from grievance g 
        inner join grievance_departments gd on gd.grievance_id = g.grievance_id 
        inner join department d on d.dept_id = gd.department 
        inner join projects p on p.project_id = g.project_id 
        inner join districts_master dm on dm.district_id = p.district_id 
        where g.grievance_status = 2 
    group by d.dept_id
)
select 
    d.dept_id as department_id,
    d.dept_name as department_name,
    coalesce(apc.atr_pending,0) as pending_count
from department d
left join atr_pendiing_count apc on apc.dept_id = d.dept_id

select * from grievance g ;


SELECT 
    g.grievance_id,
--    g.created_on,
    EXTRACT(DAY FROM CURRENT_DATE - g.created_on) AS days_open
FROM 
    grievance g;

   
   
SELECT 
    d.dept_id,
    d.dept_name,
    COUNT(g.grievance_id) AS total_pending_grievances,
    EXTRACT(DAY FROM CURRENT_DATE - g.created_on) AS days_open,
    case 
    	when days_open between 7 to 15 
    	then 7_to_15_days,
    end
    
FROM grievance g
left join grievance_departments gd on gd.grievance_id = g.grievance_id 
left join department d on gd.department = d.dept_id
GROUP BY d.dept_id, d.dept_name, g.created_on
ORDER BY total_pending_grievances DESC;



SELECT 
    d.dept_id,
    d.dept_name,
    COUNT(g.grievance_id) AS total_pending_grievances,
    EXTRACT(DAY FROM CURRENT_DATE - g.created_on) AS days_open,
FROM grievance g
left join grievance_departments gd on gd.grievance_id = g.grievance_id 
left join department d on gd.department = d.dept_id
GROUP BY d.dept_id, d.dept_name, g.created_on
ORDER BY total_pending_grievances DESC;



SELECT 
    d.dept_id,
    d.dept_name,
    count(case 
        when extract(day from CURRENT_DATE - g.created_on) between 8 and 15 
        THEN 1 END) AS "7_15_days",
    count(case 
        when extract(day from CURRENT_DATE - g.created_on) between 16 and 30 
        THEN 1 END) AS "16_30_days",
    count(case 
        when extract(day from CURRENT_DATE - g.created_on) > 30 
        THEN 1 END) AS "beyond_30_days",
    count(g.grievance_id) AS total_pending
FROM department d 
left join grievance_departments gd on gd.department = d.dept_id 
left join grievance g on gd.grievance_id = g.grievance_id and g.grievance_status in (1,2) and g.grievance_type = 1
--where 
group BY d.dept_id, d.dept_name
order BY total_pending DESC;





-------------------------------------------------------------------



select 
      g.grievance_id,
      g.grievance_code,
      g.grievance_type,
      dlm3.domain_value as grievance_type_name,
      g.grievance_desc,
       g.grievance_status,
       dlm2.domain_value as grievance_status_name,
       g.created_by as grievance_created_by,
       iur.industrialist_name as grievance_lodged_by_name,
       iur.industrialist_email as grievance_lodged_by_email,
       iur.industrialist_phone as grievance_lodged_by_phone,
       iur.industrialist_desig as grievance_lodged_by_desig,
       iur.industrialist_org as grievance_lodged_by_org,
       iur.industrialist_address as grievance_lodged_by_address,
       iur.status as grievance_lodged_by_status,
       case when iur.status = 1 then 'Active'
         else 'Inactive'
       end as grievance_lodged_by_status_name,
       iur.gst as grievance_lodged_by_gst,
       iur.pan_num as grievance_lodged_by_pan_num,
       g.created_on as grievance_created_on,
       g.updated_on as grievance_updated_on,
       g.updated_by as grievance_updated_by,
       g.severity as grievance_severity,
       dlm.domain_value as grievance_severity_name,
       g.shilpa_sathi_griv_id as grievance_shilpa_sathi_griv_id,
       g.project_id,
       p.project_title,
       p.project_desc,
       p.properietor_name as project_properietor_name,
       p.registered_address as project_registered_address,
       p.project_status,
       p.estimate_cost as project_estimate_cost,
       p.estimate_land_required as project_estimate_land_required,
       p.prefered_loc_proj as project_prefered_loaction,
       p.district_id as project_district_id,
       dm.district_name as project_district_name,
       p.strategic_importance as project_strategic_importance,
       p.mca_reg_id as project_mca_reg_id,
       p.category_of_industry as project_category_of_industry,
       dlm4.domain_value as project_category_of_industry_name,
       p.employment_generation as project_employment_number,
       p.pan_or_tan as project_pan_or_tan_number
  from grievance g 
  inner join projects p on p.project_id = g.project_id
  inner join industrial_user_register iur on iur.inds_user_id = g.created_by
  inner join districts_master dm on dm.district_id = p.district_id 
   inner join domain_lookup_master dlm on dlm.domain_code = g.severity and dlm.domain_type = 'severity'
   inner join domain_lookup_master dlm2 on dlm2.domain_code = g.grievance_status and dlm2.domain_type = 'grievance_status'
   inner join domain_lookup_master dlm3 on dlm3.domain_code = g.grievance_type and dlm3.domain_type = 'griev_type'
   inner join domain_lookup_master dlm4 on dlm4.domain_code = p.category_of_industry and dlm4.domain_type = 'category_of_industry'
  where g.grievance_id = 15
  
  
  
  select * from grievance g where g.grievance_id=15;
