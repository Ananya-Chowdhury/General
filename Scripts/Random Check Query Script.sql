select count(1) as griev_count ---------------->>> Nodal
        from grievance_master gm
        left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
        left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
        where gm.grievance_id > 0  and (gm.assigned_to_office_id = 58) and gm.status in (11,13,6);

select count(1) as griev_count
from grievance_master gm
left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (6);


select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (11);


select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (13);



select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_office_id = 58) and apm.role_master_id = 4 and gm.status in (6,11,13);   ----- ATR Submitted to HOD
-----------------------------------------------------------------------------------------------------------------------------------------------------------


select * from admin_user_role_master aurm;
select * from cmo_office_master com where com.office_id = 58;




--------------------------------------------

select count(1) as griev_count 
    from grievance_master gm 
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and (gm.assigned_to_office_id = 58) and gm.status in (11,13,6) and ;