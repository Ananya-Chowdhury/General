---- Regular Update Query ---
select * from department d ; 
select * from admin_user au where au.dept_id = 9;
select * from admin_user_details aud where aud.admin_user_id = 18; --Nodal Officer

--- Grievance Query ---
select * from grievance g where g.grievance_id = 15;




-------
select 
      g.grievance_id,
      g.grievance_code,
      g.grievance_type,
      dlm3.domain_value as grievance_type_name,
      g.grievance_desc
--       g.grievance_status,
--       dlm2.domain_value as grievance_status_name,
--       g.created_by as grievance_created_by,
--       iur.industrialist_name as grievance_lodged_by_name,
--       iur.industrialist_email as grievance_lodged_by_email,
--       iur.industrialist_phone as grievance_lodged_by_phone,
--       iur.industrialist_desig as grievance_lodged_by_desig,
--       iur.industrialist_org as grievance_lodged_by_org,
--       iur.industrialist_address as grievance_lodged_by_address,
--       iur.status as grievance_lodged_by_status,
--       case when iur.status = 1 then 'Active'
--         else 'Inactive'
--       end as grievance_lodged_by_status_name,
--       iur.gst as grievance_lodged_by_gst,
--       iur.pan_num as grievance_lodged_by_pan_num,
--       g.created_on as grievance_created_on,
--       g.updated_on as grievance_updated_on,
--       g.updated_by as grievance_updated_by,
--       g.severity as grievance_severity,
--       dlm.domain_value as grievance_severity_name,
--       g.shilpa_sathi_griv_id as grievance_shilpa_sathi_griv_id,
--       g.project_id,
--       p.project_title,
--       p.project_desc,
--       p.properietor_name as project_properietor_name,
--       p.registered_address as project_registered_address,
--       p.project_status,
--       p.estimate_cost as project_estimate_cost,
--       p.estimate_land_required as project_estimate_land_required,
--       p.district_id as project_district_id,
--       dm.district_name as project_district_name,
--       p.strategic_importance as project_strategic_importance,
--       p.mca_reg_id as project_mca_reg_id,
--       p.category_of_industry as project_category_of_industry,
--       dlm4.domain_value as project_category_of_industry_name,
--       p.employment_generation as project_employment_number,
--       p.pan_or_tan as project_pan_or_tan_number
  from grievance g 
  inner join projects p on p.project_id = g.project_id
  inner join industrial_user_register iur on iur.inds_user_id = g.created_by
  inner join districts_master dm on dm.district_id = p.district_id 
--   inner join domain_lookup_master dlm on dlm.domain_code = g.severity and dlm.domain_type = 'severity'
--   inner join domain_lookup_master dlm2 on dlm2.domain_code = g.grievance_status and dlm2.domain_type = 'grievance_status'
--   inner join domain_lookup_master dlm3 on dlm3.domain_code = g.grievance_type and dlm3.domain_type = 'griev_type'
--   inner join domain_lookup_master dlm4 on dlm4.domain_code = p.category_of_industry and dlm4.domain_type = 'category_of_industry'
  where g.grievance_id = 15
 