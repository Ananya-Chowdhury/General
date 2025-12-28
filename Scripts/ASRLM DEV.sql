CREATE TABLE user_token (
    token_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    user_type INTEGER,
    token TEXT NOT NULL,
    created_on TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_time TIMESTAMP WITH TIME ZONE,
    updated_on TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT user_token_user_id_fk
        FOREIGN KEY (user_id)
        REFERENCES auth_user (id)
        ON DELETE CASCADE
);



-- DB LOCK QUERY --
SELECT pid, state, query
FROM pg_stat_activity
WHERE state = 'active';


---- TERMINATE QUERY ----
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'asrlm_dev'
AND pid <> pg_backend_pid();


SELECT tablename FROM pg_tables WHERE schemaname = 'public';


SELECT token_id, user_id, user_type
FROM user_token
WHERE user_id = 5 AND user_type = 2;



--- Cadre Details by Id API ---
select 
	"user".id as user_id,
	c.id as cadre_id,
  	CONCAT_WS(' ', c.first_name, c.middle_name, c.last_name) as full_name,
  	c.address as full_address,
  	bm.block_name as block_name,
  	c.cadre_code,
  	dl.domain_value as cadre_gender,
  	c.designation,
  	c.mobile_no,
  	c.email,
  	c.pan_no,
  	c.dob as date_of_birth,
  	c.education,
  	c.qualication,
  	c.designation,
  	c.experience as cadre_work_expe,
  	c.status as cadre_status
  from cadre c 
  inner join "user" on "user".ref_id = c.id 
  inner join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
  inner join block_master bm on bm.id = c.block_id 
  where "user".id = 5;
  
 
 ---- Task Details By User ID ------
 select 
 	tm.task_id,
 	tm.task_name,
 	tm.task_description,
 	tm.task_type,
 	dl.domain_value as task_type_name,
 	tm.remarks,
 	tm.start_date,
 	tm.end_date,
 	tm.assigned_user_id,
 	CONCAT_WS(' ', c.first_name, c.middle_name, c.last_name) as cadrec_full_name,
 	tm.assigned_user_type,
 	dl2.domain_value as user_type_name,
 	tm.status,
 	dl3.domain_value as status_name,
 	tm.created_by,
 	tm.created_on
from task_master tm 
left join "user" on "user".id = tm.assigned_user_id
left join domain_lookup dl on dl.domain_code = tm.task_type::integer and dl.domain_type = 'task_type'
left join domain_lookup dl2 on dl2.domain_code = tm.assigned_user_type::integer and dl2.domain_type = 'user_type'
left join domain_lookup dl3 on dl3.domain_code = tm.assigned_user_type::integer and dl3.domain_type = 'status'
left join cadre c on c.id = "user".ref_id
 where "user".id = 1;
 

------ Task Master ----
select *
	from task_master tm 
	where task_id = 1
	order by task_name asc;