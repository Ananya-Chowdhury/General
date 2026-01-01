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
 
 
 
 ----- Updated Task Details By User ID ------ 
select 
    tm.task_id,
    tm.task_name,
    tm.task_description,
    dl.domain_value AS task_type_name,
    tm.remarks,
    TO_CHAR(tm.start_date, 'DD/MM/YYYY') as start_date,
    TO_CHAR(tm.end_date , 'DD/MM/YYYY') as end_date,
    tm.status,
    dl3.domain_value AS status_name,
    tm.updated_by,
    tm.updated_on,
    bm.block_name,
    dm.district_name 
from task_master tm 
left join domain_lookup dl on dl.domain_code = tm.task_type::integer and dl.domain_type = 'task_type'
left join domain_lookup dl3 on dl3.domain_code = tm.status::integer and dl3.domain_type = 'task_status'
left join block_master bm on bm.id = tm.block_id    
left join district_master dm on dm.id = bm.district_id 
where tm.block_id = 7 and tm.status = 4
 
 

------ Task Master ----
select *
	from task_master tm 
	where task_id = 1
	order by task_name asc;

select * from "user" where phone = '9163479418';
select * from cadre c where c.id = 3;
select * from block_master bm ;


-------- Cadres Details ----------
select 
    "user".id as user_id,
    "user".user_type,
    dl2.domain_value as user_type_name,
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
    "user".is_active,
    c.experience as cadre_work_expe,
    c.status as cadre_status,
    bm.block_name,
    bm.id as block_id,
    dm.id as district_id,
    dm.district_name 
from cadre c 
inner join "user" on "user".ref_id = c.id 
inner join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
inner join domain_lookup dl2 on dl2.domain_code = "user".user_type::integer and dl2.domain_type = 'user_type'
inner join block_master bm on bm.id = c.block_id 
inner join district_master dm on dm.id = bm.district_id 
where "user".ref_id = 3



--------- Candidate listing by Block Id --------
select 
	c.id as candidate_id,
	c.candidate_code,
	c.kaushal_panjee_id,
	C.sanction_order,
	C.kb_project_id,
	C.village_address,
	C.mpr_project_id,
	C.pincode,
	C.email,
	C.qualification,
	C.father_name,
	C.mpr_id,
	CONCAT_WS(' ', c.first_name, c.last_name) as full_name,
	C.gender as gender_id,
	dl.domain_value as cadre_gender,
	C.category as category_id,
	dl2.domain_value as category_name,
	C.pwd as pwd_id,
	dl3.domain_value as pwd_name,
	C.minority,
	dl4.domain_value as minority_name,
	C.religion as religion_id,
	dl5.domain_value as religion_name,
	C.dob as date_of_birth,
	C.mobile_no,
	C.nature_of_training,
	C.aadhar,
	C.bank_account,
	C.house_no,
	C.permanent_address,
	C.created_on,
	C.updated_on,
--	C.created_by,
--	C.updated_by,
--	coalesce(C.status) as status_id,
	C.status as status_id,
	dl6.domain_value as status,
	C.batch_id,
	C.block_id,
	bm.block_name,
	C.constituency_id,
	C.employer_id,
	C.district_id,
	dm.district_name,
	C.sector_id,
	sm.sector_name,
	C.state_id,
	sm2.state_name,
	C.training_center_id,
	tc.training_center_name,
	C.workplace_postoffice,
	C.available_days,
	C.available_time,
	C.location_pref,
	C.skill_id,
	sm3.skill_code,
	sm3.skill_name 
from candidates c 
left join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
left join domain_lookup dl2 on dl2.domain_code = c.category::integer and dl2.domain_type = 'category'
left join domain_lookup dl3 on dl3.domain_code = c.pwd::integer and dl3.domain_type = 'pwd'
left join domain_lookup dl4 on dl4.domain_code = c.minority::integer and dl4.domain_type = 'minority'
left join domain_lookup dl5 on dl5.domain_code = c.religion::integer and dl5.domain_type = 'religion'
left join domain_lookup dl6 on dl6.domain_code = c.status::integer and dl6.domain_type = 'status'
left join district_master dm on dm.id = c.district_id 
left join block_master bm on bm.id = c.block_id 
left join sector_master sm on sm.id = c.sector_id 
left join state_master sm2 on sm2.id = c.state_id 
left join training_center tc on tc.id = c.training_center_id 
left join skill_master sm3 on sm3.id = c.skill_id 
where c.block_id = 1;


--------- Candidate Details by Id --------
select 
    c.id as candidate_id,
    c.candidate_code,
    c.kaushal_panjee_id,
    c.sanction_order,
    c.kb_project_id,
    c.village_address,
    c.mpr_project_id,
    c.pincode,
    c.email,
    c.qualification,
    c.father_name,
    c.mpr_id,
    CONCAT_WS(' ', c.first_name, c.last_name) as full_name,
    c.gender as gender_id,
    dl.domain_value as gender_name,
    c.category as category_id,
    dl2.domain_value as category_name,
    c.pwd as pwd_id,
    dl3.domain_value as pwd_name,
    c.minority,
    dl4.domain_value as minority_name,
    c.religion as religion_id,
    dl5.domain_value as religion_name,
    c.dob as date_of_birth,
    c.mobile_no,
    c.nature_of_training,
    c.aadhar,
    c.bank_account,
    c.house_no,
    c.permanent_address,
    c.created_on,
    c.updated_on,
--	c.created_by,
--	c.updated_by,
--	coalesce(c.status) as status_id,
    c.status as status_id,
    dl6.domain_value as status,
    c.batch_id,
    c.block_id,
    bm.block_name,
    avd.block as is_block_verified,
    c.constituency_id,
    ac.constituency_name,
    c.employer_id,
    c.district_id,
    dm.district_name,
    avd.district as is_dist_verified,
    c.sector_id,
    sm.sector_name,
    c.state_id,
    sm2.state_name,
    c.training_center_id,
    tc.training_center_name,
    c.available_days,
    c.available_time,
    c.skill_id,
    sm3.skill_code,
    sm3.skill_name 
from candidates c 
left join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
left join domain_lookup dl2 on dl2.domain_code = c.category::integer and dl2.domain_type = 'category'
left join domain_lookup dl3 on dl3.domain_code = c.pwd::integer and dl3.domain_type = 'pwd'
left join domain_lookup dl4 on dl4.domain_code = c.minority::integer and dl4.domain_type = 'minority'
left join domain_lookup dl5 on dl5.domain_code = c.religion::integer and dl5.domain_type = 'religion'
left join domain_lookup dl6 on dl6.domain_code = c.status::integer and dl6.domain_type = 'status'
left join district_master dm on dm.id = c.district_id 
left join block_master bm on bm.id = c.block_id 
left join sector_master sm on sm.id = c.sector_id 
left join state_master sm2 on sm2.id = c.state_id 
left join training_center tc on tc.id = c.training_center_id 
left join skill_master sm3 on sm3.id = c.skill_id 
left join assembly_constituency ac on ac.id = c.constituency_id 
left join candidate_verification_details avd on avd.candidate_id = c.id 
where c.id = 14773 


-------- District MAster ------
select * 
    from district_master dm 
where 1=1 and dm.id = 41
----------------------

select 
        c.id as candidate_id,
        c.candidate_code,
        c.kaushal_panjee_id,
        c.sanction_order,
        c.kb_project_id,
        c.village_address,
        c.mpr_project_id,
        c.pincode,
        c.email,
        c.qualification,
        c.father_name,
        c.mpr_id,
        CONCAT_WS(' ', c.first_name, c.last_name) as full_name,
        c.gender as gender_id,
        dl.domain_value as gender_name,
        c.category as category_id,
        dl2.domain_value as category_name,
        c.pwd as pwd_id,
        dl3.domain_value as pwd_name,
        c.minority,
        dl4.domain_value as minority_name,
        c.religion as religion_id,
        dl5.domain_value as religion_name,
        c.dob as date_of_birth,
        c.mobile_no,
        c.nature_of_training,
        c.aadhar,
        c.bank_account,
        c.house_no,
        c.permanent_address,
        c.created_on,
        c.updated_on,
    --	c.created_by,
    --	c.updated_by,
    --	coalesce(C.status) as status_id,
        c.status as status_id,
        dl6.domain_value as status,
        c.batch_id,
        c.block_id,
        bm.block_name,
        c.constituency_id,
        c.constituency_id,
        ac.constituency_name,
        c.employer_id,
        c.district_id,
        dm.district_name,
        c.sector_id,
        sm.sector_name,
        c.state_id,
        sm2.state_name,
        c.training_center_id,
        tc.training_center_name,
        c.available_days,
        c.available_time,
        c.skill_id,
        sm3.skill_code,
        sm3.skill_name 
    from candidates c 
    left join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
    left join domain_lookup dl2 on dl2.domain_code = c.category::integer and dl2.domain_type = 'category'
    left join domain_lookup dl3 on dl3.domain_code = c.pwd::integer and dl3.domain_type = 'pwd'
    left join domain_lookup dl4 on dl4.domain_code = c.minority::integer and dl4.domain_type = 'minority'
    left join domain_lookup dl5 on dl5.domain_code = c.religion::integer and dl5.domain_type = 'religion'
    left join domain_lookup dl6 on dl6.domain_code = c.status::integer and dl6.domain_type = 'status'
    left join district_master dm on dm.id = c.district_id 
    left join block_master bm on bm.id = c.block_id 
    left join sector_master sm on sm.id = c.sector_id 
    left join state_master sm2 on sm2.id = c.state_id 
    left join training_center tc on tc.id = c.training_center_id 
    left join skill_master sm3 on sm3.id = c.skill_id 
    left join assembly_constituency ac on ac.id = c.constituency_id 
    where c.block_id = 7  limit 10 offset 1 * 10

        
        
        
        select 
            c.id as candidate_id,
            c.candidate_code,
            c.kaushal_panjee_id,
            c.sanction_order,
            c.kb_project_id,
            c.village_address,
            c.mpr_project_id,
            c.pincode,
            c.email,
            cvd.email as is_email_verified,
            c.qualification,
            c.father_name,
            c.mpr_id,
            CONCAT_WS(' ', c.first_name, c.last_name) as full_name,
            cvd.first_name as is_firstname_verified,
            cvd.last_name as is_lastname_verified,
            c.gender as gender_id,
            dl.domain_value as gender_name,
            cvd.gender as is_gender_verified,
            c.category as category_id,
            dl2.domain_value as category_name,
            c.pwd as pwd_id,
            dl3.domain_value as pwd_name,
            c.minority,
            dl4.domain_value as minority_name,
            c.religion as religion_id,
            dl5.domain_value as religion_name,
            cvd.religion as is_religion_verified,
            c.dob as date_of_birth,
            c.mobile_no,
            cvd.mobile_no as is_mobile_verified,
            c.nature_of_training,
            c.aadhar,
            c.bank_account,
            c.house_no,
            c.permanent_address,
            c.created_on,
            c.updated_on,
        --	c.created_by,
        --	c.updated_by,
        --	coalesce(c.status) as status_id,
            c.status as status_id,
            dl6.domain_value as status,
            c.batch_id,
            c.block_id,
            bm.block_name,
            cvd.block as is_block_verified,
            c.constituency_id,
	        ac.constituency_name,
            c.employer_id,
            c.district_id,
            dm.district_name,
            cvd.district as is_district_verified,
            c.sector_id,
            sm.sector_name,
            cvd.trained_sector as is_sector_verified,
            c.state_id,
            sm2.state_name,
            c.training_center_id,
            tc.training_center_name,
            c.available_days,
            c.available_time,
            c.skill_id,
            sm3.skill_code,
            sm3.skill_name,
            cvd.trained_skill as is_skill_verified,
            cvd.updated_by as updated_cadres_id
        from candidates c 
        left join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
        left join domain_lookup dl2 on dl2.domain_code = c.category::integer and dl2.domain_type = 'category'
        left join domain_lookup dl3 on dl3.domain_code = c.pwd::integer and dl3.domain_type = 'pwd'
        left join domain_lookup dl4 on dl4.domain_code = c.minority::integer and dl4.domain_type = 'minority'
        left join domain_lookup dl5 on dl5.domain_code = c.religion::integer and dl5.domain_type = 'religion'
        left join domain_lookup dl6 on dl6.domain_code = c.status::integer and dl6.domain_type = 'status'
        left join district_master dm on dm.id = c.district_id 
        left join block_master bm on bm.id = c.block_id 
        left join sector_master sm on sm.id = c.sector_id 
        left join state_master sm2 on sm2.id = c.state_id 
        left join training_center tc on tc.id = c.training_center_id 
        left join skill_master sm3 on sm3.id = c.skill_id 
        left join assembly_constituency ac on ac.id = c.constituency_id 
        left join candidate_verification_details cvd on cvd.candidate_id = c.id 
        where c.id = 14773;
        
        
----- available time ------        
select c.id,
	c.available_start_time,
	c.available_end_time
from candidates c where c.id  = 2;