


--1) office_ id = 51, sub_office_id = 5740 -- 937 HOSO
--2) office_ id = 117, sub_office_id = 5389
--3) office_ id = 42, sub_office_id = 2610

--grievance_id = 834, 993, 1627, 1632, 1825



select * from cmo_sub_office_master where suboffice_id = 5740;
select * from admin_position_master apm where position_id = 937;
select * from admin_position_master apm where position_id = 1276;


select 
	gl.assigned_by_office_cat, gl.assigned_to_office_cat, apm.role_master_id as by_role, apm2.role_master_id as to_role,
	apm.sub_office_id as by_sub, apm2.sub_office_id as to_sub, gl.assigned_by_office_id , gl.assigned_to_office_id ,
	gl.grievance_status , gl.assigned_on , gl.lifecycle_id , gl.*, apm.record_status, apm2.record_status 
from grievance_lifecycle gl
left join admin_position_master apm on apm.position_id = gl.assigned_by_position 
left join admin_position_master apm2 on apm2.position_id = gl.assigned_to_position 
where grievance_id = 3560009 order by assigned_on ;


select * from admin_position_master apm where sub_office_id = 5740;

select * from admin_position_master apm where sub_office_id = 5740 and role_master_id = 8-- and record_status = 2;

select gl.grievance_id ,* from grievance_lifecycle gl 
inner join admin_position_master apm on apm.position_id = gl.assigned_to_position 
where gl.assigned_by_office_cat = 2 and apm.role_master_id = 8 and apm.sub_office_id = 5740;