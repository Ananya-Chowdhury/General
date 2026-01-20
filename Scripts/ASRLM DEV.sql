select * from candidates c where c.is_verified = false;
select * from candidates c where c.id = 61730;

SELECT *
FROM services
WHERE id = 999
   OR service_code = 999;

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


---
select
    cps.id,
    sm.id as sector_id,
    sm.sector_name,
    sm2.id as skill_id,
    sm2.skill_name,
    cps.candidate_id 
from candidate_preferred_services cps
left join sector_master sm on sm.id = cps.sector_id 
left join skill_master sm2 on sm2.sector_id = sm.id 
        where cps.candidate_id = 2
        
        
        select 
            cpd.id, 
            cpd.day_id,
            dl.domain_value as days_name,
            cpd.candidate_id   
        from candidate_preferred_days cpd
        left join domain_lookup dl on dl.domain_code = cpd.day_id::integer and dl.domain_type = 'preferred_days'
        where cpd.candidate_id  = 2
        
        
select
    cps.id,
    sm.id as sector_id,
    sm.sector_name,
    sm2.id as skill_id,
    sm2.skill_name,
    cps.candidate_id 
from candidate_preferred_services cps
left join sector_master sm on sm.id = cps.sector_id 
left join skill_master sm2 on sm2.sector_id = sm.id 
where cps.candidate_id = 98134





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
    c.first_name as firstname,
    c.last_name as lastname,
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
    c.skill_id,
    sm3.skill_code,
    sm3.skill_name,
    cvd.trained_skill as is_skill_verified,
    cvd.updated_by as updated_cadres_id,
    c.available_start_time,
    c.available_end_time,
    c.interest_freelancer as is_gig_worker,
    c.is_verified,
    c.remarks
from candidates c 
left join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
left join domain_lookup dl2 on dl2.domain_code = c.category::integer and dl2.domain_type = 'category'
left join domain_lookup dl3 on dl3.domain_code = c.pwd::integer and dl3.domain_type = 'pwd'
left join domain_lookup dl4 on dl4.domain_code = c.minority::integer and dl4.domain_type = 'minority'
left join domain_lookup dl5 on dl5.domain_code = c.religion::integer and dl5.domain_type = 'religion'
left join domain_lookup dl6 on dl6.domain_code = c.status::integer and dl6.domain_type = 'status'
left join district_master dm on dm.id = c.district_id and dm.status = 1
left join block_master bm on bm.id = c.block_id and bm.status = 1
left join sector_master sm on sm.id = c.sector_id and sm.status = 1
left join state_master sm2 on sm2.id = c.state_id and sm2.status = 1
left join training_center tc on tc.id = c.training_center_id and tc.status = 1
left join skill_master sm3 on sm3.id = c.skill_id and sm3.status = 1
left join assembly_constituency ac on ac.id = c.constituency_id and ac.status = 1
left join candidate_verification_details cvd on cvd.candidate_id = c.id
where c.status = 1 and c.id = 126678        --98296
        

---         
select
    cpl.id as candidate_preferred_id,
    dm.district_name,
    dm.id as district_id,
    cpl.candidate_id 
from candidate_preferred_location cpl
left join district_master dm on dm.id = cpl.district_id 
where cpl.status = 1 and cpl.candidate_id = 98296;



select 
	c.id,
	dm.doc_id ,
	dm.doc_location,  
	dm.doc_name ,
	dm.doc_path,
	dm.doc_file_type,
	dl.domain_value 
from candidates c 
left join document_master dm on dm.ref_id = c.id 
left join domain_lookup dl on dl.domain_code = dm.upload_doc_type  
where dl.domain_code = 2 and dl.domain_type  = 'doc_type'
and c.id = 97210;


select 
            c.id,
            dm.doc_id ,
            dm.doc_location,  
            dm.doc_name ,
            dm.doc_path,
            dm.doc_file_type,
            dl.domain_value 
        from candidates c 
        left join document_master dm on dm.ref_id = c.id 
        left join domain_lookup dl on dl.domain_code = dm.upload_doc_type and dl.domain_type = 'doc_type'
        where dl.domain_code = 2
        
        
        
        
select
    cps.id,
    sm.id as sector_id,
    sm.sector_name,
    sm2.id as skill_id,
    sm2.skill_name,
    s.id as service_id,
    s.service_name ,
    s.service_code ,
    cps.candidate_id,
    cps.others_service_name 
from candidate_preferred_services cps
left join sector_master sm on sm.id = cps.sector_id 
left join skill_master sm2 on sm2.id = cps.skill_id
left join services s on s.id = cps.service_id
where cps.status = 1 and cps.candidate_id = 93327;

--387354
select * from candidate_preferred_services cps where cps.candidate_id  = 98212;


SELECT
    dmst.doc_id,
    dl.domain_value AS doc_type_name,
    dl.domain_code AS doc_type_id,
    dmst.doc_path,
    dmst.doc_file_type,
    dmst.doc_name
FROM document_master dmst
JOIN domain_lookup dl
    ON dl.domain_code = dmst.upload_doc_type
AND dl.domain_type = 'doc_type'
WHERE dmst.ref_id =98212
AND dmst.status = 1
AND dl.status = 1
ORDER BY dl.domain_code asc


select
        ce.id as candidate_experience_id,
        ce.candidate_id,
        sm.id as sector_id,
        sm.sector_name,
        sk.id as skill_id,
        sk.skill_name,
        ce.experience_duration,
        ce.self_employed as self_employed,
        ce.organization_name as organization_name,
        ce.job_role
    from candidate_experience ce
    left join sector_master sm on sm.id = ce.sector_id
    left join skill_master sk on sk.id = ce.skill_id
    where ce.status = 1 and ce.candidate_id = 97158
    
    
    select 
            c.id as candidate_id,
            tc.training_center_name,
            bm.start_date as training_start_date,
            bm.end_date as training_end_date,
            sm.id as training_state_id,
            sm.state_name as training_state_name,
            dm.id as training_distict_id,
            dm.district_name as training_district_name,
            sm2.id as training_sector_id,
            sm2.sector_name as training_sector_name,
            ct.sector_others as training_sector_others,
            sm3.id as training_skill_id,
            sm3.skill_name as training_skill_name,
            ct.skill_others as training_skill_others
        from candidates c
        left join candidate_training ct on ct.candidate_id  = c.id 
        left join training_center tc on tc.id  = ct.training_id  and tc.status = 1
        left join batch_master bm on bm.id = c.batch_id and bm.status = 1
        left join state_master sm on sm.id = tc.state_id and sm.status = 1
        left join district_master dm on dm.id = tc.district_id and dm.status = 1
        left join sector_master sm2 on sm2.id = ct.sector_id and sm2.status = 1
        left join skill_master sm3 on sm3.id = ct.skill_id and sm3.status = 1
        where c.status = 1 and c.id = 61730
        
        
        select 
            cpd.id, 
            cpd.day_id,
            dl.domain_value as days_name,
            cpd.candidate_id   
        from candidate_preferred_days cpd
        left join domain_lookup dl on dl.domain_code = cpd.day_id::integer and dl.domain_type = 'preferred_days'
        where cpd.status = 1 and cpd.candidate_id  = 97158
        
        
         select
            cps.id,
            sm.id as sector_id,
            sm.sector_name,
            sm2.id as skill_id,
            sm2.skill_name,
            s.id as service_id,
            s.service_name,
            s.service_code,
            cps.candidate_id,
            cps.others_service_name 
        from candidate_preferred_services cps
        left join sector_master sm on sm.id = cps.sector_id 
        left join skill_master sm2 on sm2.id = cps.skill_id
        left join services s on s.id = cps.service_id
        where cps.status = 1 and cps.candidate_id = 97158
        
        
        select
            cpl.id as candidate_preferred_id,
            dm.district_name,
            dm.id as district_id,
            cpl.candidate_id 
        from candidate_preferred_location cpl
        left join district_master dm on dm.id = cpl.district_id 
        where cpl.status = 1 and cpl.candidate_id = 97158
        
        
        select
            ce.id as candidate_experience_id,
            ce.candidate_id,
            sm.id as sector_id,	
            sm.sector_name,
            sk.id as skill_id,
            sk.skill_name,
            ce.experience_duration,
            ce.self_employed as self_employed,
            ce.organization_name as organization_name,
            ce.job_role
        from candidate_experience ce
        left join sector_master sm on sm.id = ce.sector_id
        left join skill_master sk on sk.id = ce.skill_id
        where ce.status = 1 and ce.candidate_id = 97158
        
        
  select * from citizen c where c.id = 4;
        
        
        SELECT 
            c.id as citizen_id,
            c.first_name,
            c.middle_name,
            c.last_name,
            c.user_type,
            dl2.domain_value as citizen_user_type,
            c.gender,
            dl.domain_value as citizen_gender,
            c.date_of_birth as citizen_dob,
            c.mobile_number,
            c.email,
            c.status,
            c.state_id,
            sm.state_name,
            c.district_id,
            dm.district_name,
            c.block_id,
            bm.block_name,
            c.created_by,
            c.created_on,
            c.updated_by,
            c.updated_on
        from citizen c
        left join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
        left join domain_lookup dl2 on dl2.domain_code = c.user_type::integer and dl2.domain_type = 'user_type'
        left join state_master sm on sm.id = c.state_id and sm.status = 1
        left join block_master bm on bm.id = c.block_id and bm.status = 1
        left join district_master dm on dm.id = c.district_id and dm.status = 1
        where c.id = 4
        
        
        
        
        
        select * from services s where s.id = 21;
 select * from candidates c where c.id = 100645;
 


-- Citizen Booking List ---	
select 
	sr.id as service_request_id,
	sr.service_code,
	sr.status as service_request_status_id,
	dl.domain_value as service_request_status,
	sr.citizen_id,
	concat(c.first_name,' ', c.middle_name,' ', c.last_name) as citizen_name,
	sr.created_on as service_request_created,
	CONCAT_WS(' ', cc.first_name, cc.last_name) AS gigworker_name,
	(
	    SELECT COUNT(*)
	    FROM service_review sr
	    WHERE sr.candidate_id = cc.id
	) AS total_reviews,
	(
	    SELECT COALESCE(ROUND(AVG(sr.ratings), 1), 0)
	    FROM service_review sr
	    WHERE sr.candidate_id = cc.id
	) AS avg_rating,
	sr.district_id,
	dm.district_name,
	sr.sector_id,
	sm.sector_name,
	sr.service_id,
	s.service_name,
	sr.skill_id,
	sm2.skill_name,
	coalesce(sr.service_desc, 'N/A') as service_desc,
	dm_profile.doc_path AS gig_profile_path,
	dm_profile.doc_location  AS doc_location
from service_request sr 
left join domain_lookup dl on dl.domain_code = sr.status and dl.domain_type = 'service_status'
left join citizen c on c.id = sr.citizen_id
left join candidates cc on cc.id = sr.assigned_to 
left join district_master dm on dm.id = sr.district_id
left join sector_master sm on sm.id = sr.sector_id 
left join services s on s.id = sr.service_id 
left join skill_master sm2 on sm2.id = sr.skill_id 
left join document_master dm_profile on dm_profile.ref_id = cc.id and exists (select 1 from domain_lookup dl where dl.domain_code = dm_profile.upload_doc_type and dl.domain_type = 'doc_type' and dl.domain_code = 2)
where sr.citizen_id = 12;



--- query by sourav da  for booking service
select 
	CONCAT_WS(' ', c2.first_name, c2.last_name) AS citizen_name,
	CONCAT_WS(' ', c.first_name, c.last_name) AS gigworker_name,
	sr.id as service_req_id,
	s.service_name,
	TO_CHAR(sr.assigned_on AT TIME ZONE 'Asia/Kolkata',  'Mon FMDD, YYYY') as assign_date,
	sr.service_code,
	(
	    SELECT COUNT(*)
	    FROM service_review sr
	    WHERE sr.candidate_id = c.id
	) AS total_reviews,
	(
	    SELECT COALESCE(ROUND(AVG(sr.ratings), 1), 0)
	    FROM service_review sr
	    WHERE sr.candidate_id = c.id
	) AS avg_rating,
	dl.domain_value as status,
	dm_profile.doc_path AS gig_profile_path,
	dm_profile.doc_location  AS doc_location
	from service_request sr 
	left join candidates c on c.id = sr.assigned_to 
	left join citizen c2 on c2.id  = sr.citizen_id 
	left join services s on s.id = sr.service_id 
	left join domain_lookup dl on dl.domain_code = sr.status 
	LEFT JOIN document_master dm_profile
	    ON dm_profile.ref_id = c.id
	 AND EXISTS (
	   SELECT 1
	   FROM domain_lookup dl
	   WHERE dl.domain_code = dm_profile.upload_doc_type
	   AND dl.domain_type = 'doc_type'
	   AND dl.domain_code = 2
	)
where dl.domain_type = 'service_status' and 
sr.citizen_id = 12;




SELECT
            c.id as candidate_id,
            c.first_name,
            c.last_name,
            c.gender,
            dl.domain_value as candidate_user_type,
            c.date_of_birth,
            c.mobile_number,
            c.email,
            c.status,
            c.state_id,
            sm.state_name,
            c.district_id,
            dm.district_name,
            c.block_id,
            bm.block_name,
            c.created_by,
            c.created_on,
            c.updated_by,
            c.updated_on
        from candidates c
        left join "user" u on u.ref_id = c.id
        left join domain_lookup dl on dl.domain_code = c.gender::integer and dl.domain_type = 'gender'
        left join domain_lookup dl2 on dl2.domain_code = u.user_type::integer and dl2.domain_type = 'user_type'
        left join state_master sm on sm.id = c.state_id and sm.status = 1
        left join block_master bm on bm.id = c.block_id and bm.status = 1    
        left join district_master dm on dm.id = c.district_id and dm.status = 1
        where c.id = 91061
        
        
        
        
        select 
            sr.id as service_request_id,
            sr.service_code,
            sr.status as service_request_status_id,
            dl.domain_value as service_request_status,
            sr.citizen_id,
            concat(c.first_name,' ', c.middle_name,' ', c.last_name) as citizen_name,
            sr.created_on as service_request_created,
            CONCAT_WS(' ', cc.first_name, cc.last_name) AS gigworker_name,
            (
                select count(*)
                from service_review sr
                where sr.candidate_id = cc.id
            ) as total_reviews,
            (
                select coalesce(round(AVG(sr.ratings), 1), 0)
                from service_review sr
                where sr.candidate_id = cc.id
            ) as avg_rating,
            sr.district_id,
            dm.district_name,
            sr.sector_id,
            sm.sector_name,
            sr.service_id,
            s.service_name,
            sr.skill_id,
            sm2.skill_name,
            coalesce(sr.service_desc, 'N/A') as service_desc,
            ca.
        from service_request sr 
        left join candidates cc on cc.id = sr.assigned_to and sr.status = 1
        left join citizen c on c.id = sr.citizen_id
        left join citizen_address ca on ca.id = sr.address_id and sr.status = 1
        left join domain_lookup dl on dl.domain_code = sr.status and dl.domain_type = 'service_status'
        left join district_master dm on dm.id = sr.district_id
        left join sector_master sm on sm.id = sr.sector_id 
        left join services s on s.id = sr.service_id 
        left join skill_master sm2 on sm2.id = sr.skill_id 
        where cc.id = 100645
        order by sr.created_on desc
        
        
        select * from service_request sr where sr.status = 1