
select * from grievance_master gm where gm.grievance_no = '831786393008082023235547'; -- 1502605

select * from grievance_lifecycle gl where gl.grievance_id = 1502605  order by assigned_on ;


select * from admin_position_master apm where apm.position_id = 13;
select * from admin_position_master apm where apm.position_id = 3752;


select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2019/0012';
select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2020/3769';


