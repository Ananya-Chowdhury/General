
--===========================================================
---- SSM PULL CHECK ----
SELECT * 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-10-31'  -- 2025-09-26, 2025-10-03 not fatched
and status = 'S'
ORDER by batch_id desc; -- cbrd.batch_id; --4307 (total data 3433 in 5 status = 2823 data) --22.05.24

SELECT * 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-10-23'
and status = 'S'
ORDER by batch_id asc; 


select * from cmo_emp_batch_run_details cebrd;

--===========================================================
------ SSM PUSH DATA CHECK ------
select 
	cspd.push_date,
	cspd.actual_push_date, 
	cspd.status_code, 
	cspd.status,
	cspd.from_row_no,
	cspd.to_row_no,
	cspd.data_count,
--	cspd.request,
	cspd.response,
	cspd.created_no
from cmo_ssm_push_details cspd 
where cspd.actual_push_date::date = '2025-10-30'
order by cmo_ssm_push_details_id desc; -- limit 100;


select 
	cspd.push_date,
	cspd.actual_push_date, 
	cspd.status_code, 
	cspd.status,
	cspd.from_row_no,
	cspd.to_row_no,
	cspd.data_count,
	cspd.response,
	cspd.created_no
from cmo_ssm_push_details cspd 
order by cmo_ssm_push_details_id desc limit 1000;


----- SSM PUSH FAILED ------
select
	cspd.cmo_ssm_push_details_id,
	cspd.push_date,
	cspd.status,
	cspd.actual_push_date,
	cspd.from_row_no,
	cspd.to_row_no,
	cspd.data_count,
	cspd.status_code,
	cspd.response,
	cspd.created_no
from cmo_ssm_push_details cspd 
where status = 'F'
order by push_date desc;


---- SSM PUSH COUNT CHECK --->>> Correct ----
select count(1) as ssm_push_count
from grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
--where gl.assigned_on::date = '2025-10-21'::DATE
where gl.assigned_on::date between '2024-11-12' and '2025-10-21'
and gl.grievance_status != 1
and (gm.grievance_source = 5 or gm.received_at = 6)
--order by gl.grievance_status asc limit 100;


--- Get The SSM API Push Count ----
SELECT * from public.cmo_ssm_api_push_data_count_v2('2025-10-30');


--- SSM PUSH DETAILS ------ 
select * from cmo_ssm_push_details cspd;
select cspd.cmo_ssm_push_details_id, cspd.status,cspd.data_count,response from cmo_ssm_push_details cspd where cspd.status = 'F';
--select * from public.cmo_ssm_api_push_data_count();  --(OLD)
select * from master_district_block_grv ;
select * from cmo_ssm_api_push_data(50,0);
select * from cmo_ssm_push_details cspd order by cmo_ssm_push_details_id desc limit 1;



--==================================================================================================
--========================== SSM API Regular Pulled Batches Check =============================
------------------------ Update Final Query ------------------------------   --06.09.2025 --07.09.2025
SELECT
    a.*,
    '[' || array_to_string(
        ARRAY(
            SELECT g
            FROM generate_series(1, 96) g
            WHERE g <> ALL (string_to_array(a.batch_ids, ', ')::int[])
            ORDER BY g
        ),
        ', '
    ) || ']' AS missing_batch_ids,
    case
    	when a.batchs >= 96 then 'Synced'
    	else
    		array_to_string(
		        ARRAY(
		            SELECT CONCAT(cbtm.from_time,' - ',cbtm.to_time)
		            FROM generate_series(1, 96) g
		            inner join cmo_batch_time_master cbtm on cbtm.batch_time_master_id = g
		            WHERE g <> ALL (string_to_array(a.batch_ids, ', ')::int[])
		            ORDER BY g
		        ),
		        ', '
		    )
    end AS missing_batch_timeslots
FROM 
    (
    SELECT 
        cbrd.batch_date::date,
        COUNT(cbrd.batch_id) AS batchs,
        array_to_string(
            ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
            ', '
        ) AS batch_ids
    FROM cmo_batch_run_details cbrd
    LEFT JOIN cmo_batch_time_master cbtm 
        ON cbtm.batch_time_master_id = cbrd.batch_id
    WHERE status = 'S'
    GROUP BY cbrd.batch_date::date
    ORDER BY cbrd.batch_date::date DESC
) a
WHERE (a.batchs <= 96 or a.batchs > 96) ;

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
-- For CMO Batch Pull Data Count Check
-- ARRAY_AGG(cbrd.batch_id) for list of batch detail ids
-- distinct(cbrd.batch_date::date), for perticular distinct date where the process odne
-- Total Number of Batch = 96 for With Success Status " status = 'S'
-- count(cbrd.batch_id) as batchs, -------- >>>> total number of  batches enters
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

------ SSM PULL DATA CHECK -----
select 
	cbrd.cmo_batch_run_details_id,cbrd.batch_date,cbrd.batch_id,cbrd.from_time,
	cbrd.to_time,cbrd.status,cbrd.data_count, cbrd.error, cbrd.processed
from cmo_batch_run_details cbrd
order by cbrd.batch_id desc limit 1;

select * from cmo_batch_run_details cbrd where cbrd.batch_date::date = '2024-11-12'::date
order by cbrd.batch_id desc;

select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 38582;
select * from cmo_batch_grievance_line_item cbgli where cbgli.status = 2 and cbgli.cmo_batch_run_details_id = 38582;


select 
	cbrd.cmo_batch_run_details_id,cbrd.batch_date,cbrd.batch_id,cbrd.from_time,
	cbrd.to_time,cbrd.status,cbrd.data_count, cbrd.error, cbrd.processed
from cmo_batch_run_details cbrd
where cbrd.batch_date::date = '2025-01-04'::date
order by cbrd.batch_id desc;



--- Indivitual SSM Pull Data check ---
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 37757 /*and status = 5*/;
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 37757 and status in (2);
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 4894 and status != 2;

select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id in (select cbrd.cmo_batch_run_details_id
from cmo_batch_run_details cbrd where batch_date = '2024-12-05' /*order b y batch_id*/);
select * from public.cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM4385683';
select * from public.cmo_batch_run_details cbrd where cbrd.cmo_batch_run_details_id = '6009';
select * from public.grievance_master gm where grievance_no in ( select griev_id from cmo_batch_grievance_line_item where cmo_batch_run_details_id = 12549 );


select * from grievance_lifecycle gl where gl."comment" = 'Pull to basket' limit 2;
select * from grievance_lifecycle gl where gl.grievance_id = 272715 order by gl.assigned_on asc;


select * from cmo_domain_lookup_master cdlm where cdlm.domain_type = ''

---- UPDATE / ALTER PART -----

--UPDATE public.cmo_ssm_push_details SET response = replace(response, '''', '"');
--UPDATE public.cmo_ssm_push_details SET response = replace(response, 'None,', '"NA",');
--UPDATE public.cmo_ssm_push_details SET request = replace(request, '''', '"');
--UPDATE public.cmo_ssm_push_details SET request = replace(request, 'None,', '"NA",');
--UPDATE public.cmo_ssm_push_details SET request = replace(request, 'Chief Minister"s Office', 'Chief Minister''s Office');
--ALTER TABLE public.cmo_ssm_push_details ALTER COLUMN request TYPE JSONB USING request::JSONB;
--ALTER TABLE public.cmo_ssm_push_details ALTER COLUMN response TYPE JSONB USING response::JSONB;
--ALTER TABLE public.cmo_ssm_push_details ADD column is_reprocessed TYPE boolean DEFAULT FALSE;

------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--=========================================================================================================================================================================

---------------- Grievance Query ---------------
select * from public.grievance_master gm where grievance_no in ('SSM4837610');
select * from public.grievance_master gm where gm.grievance_id = 5235053;
select * from public.grievance_lifecycle gl where gl.grievance_id = 5894923 order by gl.assigned_on desc;
select * from public.grievance_master gm where gm.grievance_no = 'CMO41972931';
select * from public.admin_position_master apm where apm.position_id = 10140;               -- assigned_to_postion = position_id      admin_postion_master
select * from public.admin_user_position_mapping aupm where aupm.position_id = 11360;       --12745 (6) --10140 --12708 (7) --
select * from public.admin_user au where au.admin_user_id = 10920;
select * from public.user_token ut where ut.user_id = 105 order by ut.token_id desc;
select * from public.cmo_closure_reason_master ccrm ;
select * from public.grievance_master gm where gm.pri_cont_no = '9163479418';  --8101859077
select * from public.grievance_lifecycle gl where gl.grievance_id = 5235362;
select count(1) from public.bulk_griev_status_mesg_assign bgsma;
select * from grievance_master gm where gm.doc_updated ='Y' limit 10;
select * from document_master dm where dm.doc_id = 106657; --100317
select * from cmo_grievance_category_master cgcm ;


----------- Admin Position Fatch Query ----------
select * from cmo_office_master com; --35 --53 --68
select * from cmo_sub_office_master csom where csom.office_id = 53;
select * from admin_user au where au.u_phone = '8777729301';
select * from admin_user au where au.admin_user_id = 15001;
select * from admin_user_details aud where aud.admin_user_id in (1227);
select * from admin_position_master apm where apm.sub_office_id = 3101;
select * from admin_position_master apm where apm.position_id = 15405;
select * from admin_user_position_mapping aupm where aupm.admin_user_id = 15001;
select * from admin_user_position_mapping aupm where aupm.position_id = 1227;
select * from admin_position_master apm where apm.office_id = 35 and role_master_id = 7 and record_status = 1;


--select * from grievance_returned_data grd ;
select * from grievance_retruned_data grd ;


--------- Departmental Admin and Nodal User ------------
 select 
    admin_user_details.official_name, 
    admin_user_details.official_phone, 
    admin_position_master.office_id, 
    com.office_name,
    aurm.role_master_name, 
    admin_position_master.position_id,
    admin_user_details.admin_user_id,
    admin_user_position_mapping.status,
    admin_position_master.record_status
    from admin_user_details
        inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
        inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
        inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
        inner join cmo_office_master com on com.office_id = admin_position_master.office_id
    where admin_position_master.office_id is not null and admin_position_master.role_master_id in (4,5,6) and admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1
    and admin_position_master.position_id = 3437
    group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name, 
    admin_user_details.admin_user_id, admin_user_position_mapping.status, admin_position_master.record_status
order by admin_position_master.office_id asc;




select admin_user_details.official_name, admin_user_details.official_phone, admin_user_details.official_email, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name 
from admin_user_details
inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
inner join cmo_office_master com on com.office_id = admin_position_master.office_id
where /*admin_position_master.office_id = 35 and */ admin_position_master.office_id is not null and admin_position_master.role_master_id in (4,5) and 
	  admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1 and admin_user_details.official_phone  in ('9999999900','9999999999','8918939197','8777729301','9775761810','7719357638','7001322965','6292222444',
'8334822522','9874263537','9432331563','9434495405','9559000099','9874263537')
	 group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name, admin_user_details.official_email;



select admin_user_details.official_name, admin_user_details.official_phone, admin_user_details.official_email, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name 
from admin_user_details
inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
inner join cmo_office_master com on com.office_id = admin_position_master.office_id
inner join admin_user au on au.admin_user_id = admin_user_details.admin_user_id 
where /*admin_position_master.office_id = 35 and */ admin_position_master.office_id is not null /*and admin_position_master.role_master_id in (4,5)*/ 
	  admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1 and au.u_phone in ('9999999900','9999999999','8918939197','8777729301','9775761810','7719357638','7001322965','6292222444',
'8334822522','9874263537','9432331563','9434495405','9559000099','9874263537') /*and au.admin_user_id in (3756,76,70,4263,10920,4,14206,16134,12595)*/
	 group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name, admin_user_details.official_email
	order by admin_user_details.official_name asc;



select * from public.admin_user au where au.u_phone in ('9999999900','9999999999','8918939197','8777729301','9775761810','7719357638','7001322965','6292222444',
'8334822522','9874263537','9432331563','9434495405','9559000099','9874263537') and au.status = 1;
select * from admin_user_position_mapping aupm where aupm.admin_user_id = 10920;
select * from admin_position_master apm where apm.position_id = 10920;
select * from admin_user_details aud where aud.admin_user_id  = 10920;
select * from public.admin_user au where au.u_phone in ('8101859077');  --9163479418 9999999999  shovanhalder9@gmail.com  ananyachowdhury002@gmail.com
select * from public.admin_user_details aud where aud.official_phone  in ('8101859077');  --9163479418 9999999999  shovanhalder9@gmail.com  ananyachowdhury002@gmail.com  -- 8101859077


select * from admin_user_details aud where aud.official_name ='Subhendu Basu';
select * from admin_user au where au.admin_user_id = 432;
select * from user_token ut where ut.user_type = 2 limit 100;

--- 9297929297 -- Dr.P Ulaganathan,IAS --- secy.prd-wb@bangla.gov.in --- 10140 -- P&RD
--- 6292222444 -- Sri Sumit Gupta, IAS --- dm-ali@nic.in --- 76 ---- DM.South.24
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


------- Grievance Category Mapping Check ----------
select * from cmo_grievance_category_master cgcm ;
select * from cmo_griev_cat_office_mapping cgcom ;


--------- Grievance Lifecycle Trail Check -------
select 
	gl.lifecycle_id,
	gl.grievance_status,
	gl.assigned_on,
	gl.assigned_by_id,
	gl.assigned_to_id,
	gl.assigned_by_position,
	gl.assigned_to_position,
	gl.assigned_by_office_id,
	gl.assigned_to_office_id
from public.grievance_lifecycle gl 
where gl.grievance_id = 4468914; -- 868643


select * from cmo_domain_lookup_master cdlm;
select * from grievance_lifecycle gl limit 1;
select * from user_otp uo order by created_on desc;
select * from cmo_parameter_master cpm;
select * from admin_user au;


--- SSM PUSH CHECK ---
select 
	cspd.push_date, 
	cspd.actual_push_date, 
	cspd.status_code, 
	cspd.status 
from cmo_ssm_push_details cspd 
order by cmo_ssm_push_details_id desc limit 100;


--- SSM PULL CHECK ---
SELECT 
    cmo_batch_run_details_id AS batch_run_id,
    batch_id,
    status,
    batch_date,
    from_time,
    to_time,
    data_count,
    processed,
    created_no,
    modified_on 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-03-26'
ORDER BY cbrd.batch_id desc;


----- Checking the active running Databases by PSQL -------
SELECT datname FROM pg_database;


select * from cmo_emp_batch_run_details cebrd
WHERE batch_date::date = '2025-03-26'
ORDER BY cebrd.batch_id desc;

select * from cmo_batch_grievance_line_item cbgli order by cbgli.cmo_batch_run_details_id desc;


select * from public.grievance_master gm where grievance_no = 'CMO01794208'; 
select * from public.cmo_batch_grievance_line_item cbgli where griev_id = 'SSM2962283';
select * from public.grievance_lifecycle gl where gl.grievance_id = 3882162 order by assigned_on ;
select * from public.admin_user_details aud where admin_user_id = 3186; -- Md. Ashif Ikbal

SELECT * FROM public.bulk_griev_status_assign bgsa WHERE 4216861 = ANY (SELECT jsonb_array_elements_text(bgsa.request_grievance_ids)::int);

select * from  grievance_master gm where grievance_id in (69220, 126090, 136420, 137268, 140076, 140437, 137268, 138197, 139500, 137587, 136093, 136420, 62928, 66639, 
18080, 66638, 110885, 117297, 118741, 121266, 121526, 123284, 132995, 134246);


select * from public.cmo_domain_lookup_master cdlm where cdlm.domain_type = 'received_at_location';
select * from public.cmo_grivence_receive_mode_master cgrmm;
select * from public.cmo_parameter_master cpm;
select * from public.cmo_domain_lookup_master cdlm ;
select * from public.cmo_office_master com; where com.office_id = 80;
select * from public.cmo_office_master com where office_name = 'Backward Classes Welfare Department'; --4
select * from public.cmo_police_station_master cpsm where cpsm.ps_id in (165,183);
select * from public.cmo_sub_districts_master csdm where csdm.sub_district_id in (21,60,26,35);
select * from public.user_otp uo where uo.u_phone = '9163479418' order by created_on desc; --["9999999900","9999999999","8101859077","8918939197","8777729301","9775761810","7719357638","7001322965"]
select * from public.user_otp uo limit 1;
select * from public.admin_user_position_mapping aupm where aupm.position_id = 81; --3186
select * from public.admin_user_position_mapping aupm where aupm.admin_user_id = 11119; --3186
select * from public.admin_position_master apm where apm.position_id = 12745;
select * from public.admin_user au where admin_user_id = 3580;
select * from public.admin_user_details aud where aud.admin_user_id = 3580;
select * from public.admin_user_details aud where aud.official_name = 'Ananya Majumder';
select * from public.admin_user au limit 1;
select * from public.admin_position_master apm where apm.record_status = 1 and apm.role_master_id = 9;
select * from public.admin_user_position_mapping aupm where aupm.status = 1 and aupm.position_id = 1;
select * from public.grievance_master gm where gm.status = 15;
select * from public.grievance_lifecycle gl where gl.grievance_id = 3554042 order by gl.assigned_on asc;   --5740559
select * from public.grievance_master gm where gm.grievance_id = 12139;
select * from public.grievance_lifecycle gl where gl.lifecycle_id = 8186648;  --2670392
select * from grievance_master gm where gm.pri_cont_no = '9163479418';   --5809393
select * from grievance_locking_history glh where glh.grievance_id = 5809393;
 


select * from public.cmo_action_taken_note_master catnm;
select * from public.atn_closure_reason_mapping acrm;
select * from public.cmo_closure_reason_master ccrm;


["9999999900","9999999999","8918939197","8777729301","9775761810","7719357638","7001322965","9297929297",
"6292222444","8334822522","9874263537","9432331563","9434495405","9559000099","9874263537"]  --SSM3481985

["9999999900","9999999999","8918939197","8777729301","9775761810","7719357638","7001322965","6292222444",
"8334822522","9874263537","9432331563","9434495405","9559000099","9874263537"]

-- Get OTP Query --  
SELECT * 
FROM public.user_otp uo  
WHERE uo.u_phone = '9999999999'   --9147888180
ORDER BY created_on desc limit 5;

SELECT * 
FROM public.user_otp uo  
WHERE uo.u_phone = '7278061035'
ORDER BY created_on desc;

SELECT otp 
FROM public.user_otp uo 
WHERE uo.u_phone = '8017888777' 
and uo.otp != 'USED' 
ORDER BY created_on desc limit 1;


-- Refresh Materialized View --
refresh materialized view public.home_page_map_count; --12721

{"action": "TA", "atn_id": "3", "comment": "test", "atr_doc_id": "[]", "addl_doc_id": "[]", "position_id": "1",
"contact_date": "None", "grievance_id": "None", "urgency_flag": "None", "assign_comment": "None", "tentative_date": "None", "action_proposed": "None", "bulk_grivance_id": "[4836820]",
"grievance_status": "GM014", "action_taken_note": "Benefit/Service Provided", "atn_reason_master_id": "None"}


select * from public.cmo_office_master com where com.office_type =  8;
select * from public.cmo_office_master com where com.office_id = 35;
select * from public.cmo_sub_divisions_master csdm where csdm.district_id = 20;
select * from public.cmo_districts_master cdm;
select * from public.admin_user_details aud where aud.admin_user_id =;
select * from public.admin_user_position_mapping aupm where aupm.admin_user_id = 12660 and aupm.position_id = 3433;
select * from public.admin_user au where au.admin_user_id = 11152;
select * from public.admin_position_master apm where /*apm.position_id = 3433*/ apm.office_type = 9;
select count(1) from public.grievance_master gm where gm.assigned_to_position = 3433 and gm.assigned_to_id = 3433;
select count(1) from public.grievance_lifecycle gl where gl.assigned_to_position = 3433;
select * from cmo_domain_lookup_master cdlm where cdlm.domain_type = 'office_type';
select * from cmo_police_station_master cpsm where cpsm.sub_district_id = 13;
select * from public.admin_user au where au.u_phone = '9999999999'; --8101859077   --->>>> -105 -106 admin_user_id
select * from public.admin_user_details aud where aud.official_phone = '9999999999'; --9903821521
select * from public.cmo_parameter_master cpm ;
select * from public.grievance_master gm where gm.pri_cont_no = '9163479418';
select * from public.grievance_master gm where gm.grievance_id = 2512493;
select * from public.grievance_master gm2 where gm2.grievance_no = 'SSM4767959';
select * from public.grievance_lifecycle gl where gl.grievance_id = 2512493 order by gl.assigned_on  desc;
select * from public.cmo_closure_reason_master ccrm;
select * from cmo_grievance_category_master cgcm ;
select * from user_token ut where ut.c_m_no = '9635821533';
select * from user_token ut order by ut.token_id desc limit 10;


--- FOR CHECKING POSITION AND USER MAPPING ---- ( One Position never HAVE two different User but One User can have two different positions)
select * from admin_user_position_mapping aupm where aupm.position_id = 15380 and aupm.status = 1;  -- position (15380)
select * from admin_position_master apm where apm.position_id = 15380;
select * from admin_user_details aud where aud.admin_user_id in (15586, 16108);
select * from admin_user au where au.admin_user_id in (15586, 16108);


--------------------------------------------------------------------------------------------------------


select * from public.admin_user au where au.u_phone in ('9999999900','9999999999','8918939197','8777729301','9775761810','7719357638','7001322965','6292222444',
'8334822522','9874263537','9432331563','9434495405','9559000099','9874263537');


-- Grievance Lifecycle & Master Count trail Query --
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06';
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date BETWEEN '2024-11-14 00:00:00' AND '2024-11-14 17:00:00';
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06' and gl.grievance_status = 1; -- 1852
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06' and gl.grievance_status != 1; -- 11826  = 13,678


SELECT COUNT(DISTINCT gm.grievance_id) FROM grievance_master gm WHERE gm.updated_on::date = '2025-08-06'; -- 11826
SELECT COUNT(DISTINCT gm.grievance_id) FROM grievance_master gm WHERE gm.created_on::date = '2025-08-06'; -- 1852
SELECT COUNT(1) FROM grievance_master gm WHERE gm.updated_on::date = '2025-08-06';
SELECT COUNT(1) FROM grievance_master gm WHERE gm.updated_on::date = '2025-08-20'; 	
SELECT COUNT(1) FROM grievance_master gm WHERE gm.updated_on >= '2025-08-20 00:00:00' AND gm.updated_on <  '2025-08-20 12:00:00';
select * from grievance_master gm where gm.status = 1;
select * from grievance_lifecycle gl where gl.grievance_id = 5802305;


SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl 
--inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
WHERE gl.assigned_on::date = '2025-08-20';
--WHERE gl.created_on::date = '2025-08-06';


SELECT distinct gm.* FROM grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
WHERE gl.created_on::date = '2025-08-20';
--WHERE gl.created_on::date = '2025-08-06';

SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on BETWEEN '2024-11-14 00:00:00' AND '2024-11-14 17:00:00';
SELECT COUNT(1) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06';

select count(1) from grievance_lifecycle gl where gl.assigned_on between '2025-08-25 00:00:00' AND '2025-08-25 12:00:00'; 
select count(DISTINCT gl.grievance_id) from grievance_lifecycle gl where gl.assigned_on between '2025-08-25 00:00:00' AND '2025-08-25 12:00:00';

select count(1) from grievance_master gm where gm.created_on between '2024-11-14 00:00:00' AND '2024-11-14 17:00:00';


select count(distinct gl.grievance_id) from grievance_lifecycle gl where gl.grievance_id in (select bp.grievance_id from grievance_master_sdc_timestamp_issue_20250806_bkp bp);  --12256
select distinct gl.* from grievance_lifecycle gl where gl.grievance_id in (select bp.grievance_id from grievance_master_sdc_timestamp_issue_20250806_bkp bp);
select count(distinct gl.*) from grievance_lifecycle gl where gl.grievance_id in (select bp.grievance_id from grievance_master_sdc_timestamp_issue_20250806_bkp bp);


SELECT distinct gl.* FROM grievance_lifecycle gl 
inner join grievance_master_sdc_timestamp_issue_20250806_bkp gm on gm.grievance_id = gl.grievance_id order by gl.grievance_id asc;

SELECT count(distinct gl.lifecycle_id) FROM grievance_lifecycle gl 
inner join grievance_master_sdc_timestamp_issue_20250806_bkp gm on gm.grievance_id = gl.grievance_id;  --122250

-- create table grievance_lifecycle_sdc_timestamp_20250806_bkp;

select count(1) from grievance_lifecycle_sdc_timestamp_20250806_bkp;
select count(1) from grievance_master_sdc_timestamp_issue_20250806_bkp;
---------------------------------------------------------------------------------------------------

-- Connection Count ---
select query, count(1) from pg_stat_activity group by query order by count desc;
select count(1) from pg_stat_activity;
select * from pg_stat_activity;

--==================================================================================
--- ===================== Connection Lock Checking =========================== -----
--==================================================================================

select * from pg_locks;
select * from pg_stat_activity;


-- ===== Showing Maximum Connection ===== ---
show max_connections;


-- Proccesed pid query identified --
select 
	pg_stat_activity.query, 
	pg_locks.mode, 
	pg_stat_activity.client_addr,
	count(1) AS query_count
from pg_stat_activity
inner join pg_locks on pg_locks.pid = pg_stat_activity.pid 
group by 1,2,3
order by 2,4 desc;


-- Proccesed pid query identified more than 1000 -- 
SELECT 
    pg_stat_activity.query, 
    COUNT(1) AS query_count
FROM pg_stat_activity
INNER JOIN pg_locks ON pg_locks.pid = pg_stat_activity.pid
GROUP BY pg_stat_activity.query
HAVING 
    COUNT(1) >= 1000;


SELECT 
    pg_stat_activity.query, 
    COUNT(1) AS query_count
FROM pg_stat_activity
left JOIN pg_locks ON pg_locks.pid = pg_stat_activity.pid
GROUP BY pg_stat_activity.query
HAVING 
    COUNT(1) >= 1;
   

   SELECT 
    pg_stat_activity.query, 
    COUNT(1) AS query_count
FROM pg_stat_activity
inner JOIN pg_locks ON pg_locks.pid = pg_stat_activity.pid
GROUP BY pg_stat_activity.query
HAVING 
    COUNT(1) >= 1;
   
   
--- Postgres Locked Query ---
SELECT
    pg_locks.locktype,
    pg_locks.mode,
    pg_locks.granted,
    pg_stat_activity.pid,
    pg_stat_activity.usename,
    pg_stat_activity.query,
    pg_stat_activity.state,
    pg_stat_activity.query_start
FROM pg_locks
JOIN pg_stat_activity ON pg_locks.pid = pg_stat_activity.pid
ORDER BY pg_stat_activity.query_start;



--- Finding Rapidly used query in Main Database ----
--SELECT * FROM "hod_all_weekly_modified_othins"();
--SELECT * FROM "hod_total"();
--SELECT * FROM "get_dept"();
--SELECT * FROM "hcm_mis"();
--select * from public.category_all() --172.19.20.55


--SHOW search_path
--SELECT 1 AS "a" FROM "admin_user" WHERE ("admin_user"."u_phone" = '9547384111' OR "admin_user"."u_email" = '9547384111') LIMIT 1
--SET search_path = public,public,"$user"
--START_REPLICATION SLOT "replica_2" 2B0C/F2000000 TIMELINE 1


--  select * from home_page_grievance_counts 



--SELECT c.relname,a.*,pg_catalog.pg_get_expr(ad.adbin, ad.adrelid, true) as def_value,dsc.description,dep.objid
--FROM pg_catalog.pg_attribute a
--INNER JOIN pg_catalog.pg_class c ON (a.attrelid=c.oid)
--LEFT OUTER JOIN pg_catalog.pg_attrdef ad ON (a.attrelid=ad.adrelid AND a.attnum = ad.adnum)
--LEFT OUTER JOIN pg_catalog.pg_description dsc ON (c.oid=dsc.objoid AND a.attnum = dsc.objsubid)
--LEFT OUTER JOIN pg_depend dep on dep.refobjid = a.attrelid AND dep.deptype = 'i' and dep.refobjsubid = a.attnum and dep.classid = dep.refclassid
--WHERE NOT a.attisdropped AND c.relkind not in ('i','I','c') AND c.oid=$1
--ORDER BY a.attnum


--
------- Find PID Number From Stuck Query ------
select * from pg_stat_activity where query = 'SELECT * FROM "hod_all_weekly_modified_othins"()';
select * from pg_stat_activity where query = 'SELECT * FROM "hcm_mis"()';
select * from pg_stat_activity where query = 'SET search_path = public,public,"$user"';

--------- Cancel PID Locks ---------
select * from pg_cancel_backend(2636372);

 -------- Cancel pid Locks ------
select * from pg_catalog.pg_cancel_backend(3415343);
   
------  kill function query ----------
SELECT * FROM manage_top_query(True);


------------ Table Lock Checked Query ----------
select a.pid, a.usename, a.application_name, a.client_addr, a.state, l.mode, l.granted, n.nspname, c.relname, a.query
	from pg_locks l
	join pg_stat_activity a ON a.pid = l.pid
	join pg_class c ON c.oid = l.relation
	join pg_namespace n ON n.oid = c.relnamespace;


---------- BLOCKED QUERY CHECK -----------------
SELECT 
    pg_stat_activity.pid,
    pg_stat_activity.query AS blocked_query,
    pg_class.relname AS locked_table,
    pg_locks.locktype,
    pg_locks.mode,
    pg_locks.granted,
    pg_stat_activity.state,
    pg_stat_activity.wait_event_type,
    pg_stat_activity.wait_event,
    pg_stat_activity.query_start,
    pg_stat_activity.backend_start,
    pg_stat_activity.application_name,
    pg_stat_activity.client_addr
FROM pg_locks
JOIN pg_stat_activity ON pg_locks.pid = pg_stat_activity.pid
LEFT JOIN pg_class ON pg_locks.relation = pg_class.oid
WHERE pg_locks.relation IS NOT NULL;


-------- Long Running Queries ------------
SELECT pid, now() - query_start AS duration, state, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - query_start > interval '120 seconds'
ORDER BY duration DESC;



--------- Active Blocking Relationships ----------
SELECT
  blocked.pid   AS blocked_pid,
  blocked.query AS blocked_query,
  blocking.pid  AS blocking_pid,
  blocking.query AS blocking_query,
  now() - blocked.query_start AS blocked_duration,
  now() - blocking.query_start AS blocking_duration
FROM pg_catalog.pg_locks blocked_lock
JOIN pg_catalog.pg_stat_activity blocked ON blocked_lock.pid = blocked.pid
JOIN pg_catalog.pg_locks blocking_lock ON (blocked_lock.locktype = blocking_lock.locktype
  AND blocked_lock.database IS NOT DISTINCT FROM blocking_lock.database
  AND blocked_lock.relation IS NOT DISTINCT FROM blocking_lock.relation
  AND blocked_lock.page IS NOT DISTINCT FROM blocking_lock.page
  AND blocked_lock.tuple IS NOT DISTINCT FROM blocking_lock.tuple
  AND blocked_lock.virtualxid IS NOT DISTINCT FROM blocking_lock.virtualxid
  AND blocked_lock.transactionid IS NOT DISTINCT FROM blocking_lock.transactionid
)
JOIN pg_catalog.pg_stat_activity blocking ON blocking_lock.pid = blocking.pid
WHERE blocked_lock.granted = false AND blocking_lock.granted = true;	


-------------------------------------------------------------------------------------------------------

--============================================================
------------------------ DATA CHECK --------------------------
--============================================================
---------- Grievance Status Pattern Check --------
select 
--	count(*)
	flbm.grievance_id 
from forwarded_latest_3_4_bh_mat_2 flbm 
where flbm.previous_status = 3
--AND (flbm.next_status IS DISTINCT FROM 2)
and next_status IN (11)  
--limit 10;


--------
select max(gl.assigned_on) from grievance_lifecycle gl  
where gl.grievance_status = 4 and gl.assigned_by_office_id != gl.assigned_to_office_id;    -- 2025.02.10   --2025-07-23  14:28:00.229 +0530


---- Atr return for review to HOSO but not Assigned to HOSO ---
select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
       from grievance_lifecycle gl where gl.grievance_status = 12
       and assigned_to_office_cat != 3
       order by gl.assigned_on desc ;
--      limit 15 offset 0;

---- Atr return for review to HOSO but not Assigned to That HOD ---
select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
       from grievance_lifecycle gl where gl.grievance_status = 12
       and assigned_to_office_id != assigned_by_office_id
       order by gl.assigned_on desc ;

      
---- Atr return for review to HOD but not Assigned to HOD ---
select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
       from grievance_lifecycle gl where gl.grievance_status = 6
       and assigned_to_office_cat != 2
       order by gl.assigned_on desc ;    
      
      
---- Atr return for review to SO but not Assigned to SO ---
--create materialized view public.return_for_rvw_mismatch as
select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
       from grievance_lifecycle gl where gl.grievance_status = 10
       and assigned_to_office_cat != 3 and assigned_by_office_cat = 3
       order by gl.assigned_on desc ;     
      
      


select * from grievance_lifecycle gl where grievance_id = 5756371 order by gl.assigned_on desc;
select gm.grievance_id, gm.grievance_no from grievance_master gm where grievance_id in (3416651);

select distinct grievance_id from grievance_lifecycle gl   
where gl.grievance_status = 4 and gl.assigned_by_office_id != gl.assigned_to_office_id and assigned_on::date = '2025-03-26';

SELECT  gl.grievance_id,
gl.lifecycle_id , 
gl.grievance_status, 
gl.assigned_on, 
gl.assigned_by_id,
gl.assigned_by_office_id, 
gl.assigned_to_office_id,
gl.assigned_to_id,
gl.atr_type,
gl.action_taken_note,
gl.atn_id,
gl.closure_reason_id,
gl.atr_proposed_date,
gl.assigned_by_position,
gl.assigned_to_position,
gl.assigned_by_office_cat,
gl.assigned_to_office_cat,
gl.created_on 
FROM grievance_lifecycle gl  
WHERE gl.grievance_status = 4 
AND gl.assigned_by_office_id != gl.assigned_to_office_id 
AND DATE(gl.assigned_on) >= '2025.02.10';

select gl.grievance_id,
gl.grievance_status, 
gl.assigned_on,
gl.assigned_by_office_id, 
gl.assigned_to_office_id, 
gl.assigned_by_position,
gl.assigned_to_position,
gl.assigned_by_id,
gl.assigned_to_id,
gl.atr_type,
gl.action_taken_note,
gl.atn_id,
gl.closure_reason_id,
gl.atr_proposed_date,
gl.assigned_by_office_cat,
gl.assigned_to_office_cat,
gl.created_on,
gl.lifecycle_id
from grievance_lifecycle gl where gl.grievance_id = 3818109;

select * from admin_position_master apm where apm.position_id = 195;
select * from admin_user_role_master aurm;


select emergency_flag from grievance_master gm where gm.grievance_no = '745098210812092023040309';

-------- Jay bangla WCD BuLK check -------
select * from jai_bangla_atr_push jbap;
select * from wcd_joy_bangla_transactions wjbt where atr_push_on is not null ;
select * from wcd_joy_bangla_transactions wjbt;
select count(1) from wcd_joy_bangla_transactions wjbt;
select * from wcd_joy_bangla_transactions wjbt where wjbt.grievance_id = 4023588;





------->>>>  Pradipta Da ---- Auto Assigned <<<<------
--insert into grievance_auto_assign_audit (grievance_id, status, created_on) select distinct gl.grievance_id,
--1 as status, now() as created_on
--from grievance_lifecycle gl
--where gl.assign_comment = 'Auto-assigned by System';


select * from grievance_auto_assign_audit;
select gl.* from grievance_lifecycle gl where gl.assign_comment = 'Auto-assigned by System';


---- AUTO ASSIGNED CHCEK ------
select * from grievance_master gm 
inner join grievance_auto_assign_map gaam on gaam.grievance_cat_id = gm.grievance_category 
--where gm.status = 1 and gm.grievance_no like 'SSM%';


--select distinct count(1) from grievance_master gm 
select distinct count(1) from grievance_lifecycle gl
--left join grievance_master gm on gm.grievance_id = gl.grievance_id 
where gl.grievance_status = 2 and gm.grievance_no like 'SSM%' and gl.assign_comment = 'Auto-assigned by System';


--- Auto Assigned/ Forwarded check ---
select * from grievance_auto_assign_audit gaaa limit 10;
select Count(1) from grievance_auto_assign_audit gaaa where gaaa.created_on::date = '2025-07-11';
select * from grievance_auto_assign_map gaam ;
select count(1) from bulk_griev_status_mesg_assign bgsma where bgsma.status ='3' and bgsma.created_on::date = '2025-07-11';


--- Auto Assigned check for that perticular catgory ----
select * from grievance_master gm 
inner join grievance_auto_assign_map gaam on gaam.grievance_cat_id = gm.grievance_category 
inner join grievance_auto_assign_audit gaaa on gaaa.grievance_id = gm.grievance_id 
where grievance_category = 131;

select * from grievance_master gm 
--inner join grievance_auto_assign_map gaam on gaam.grievance_cat_id = gm.grievance_category 
inner join grievance_auto_assign_audit gaaa on gaaa.grievance_id = gm.grievance_id and gaaa.status  = 1
where grievance_category = 131 order by gm.created_on desc;


select * from pg_stat_activity where query = 'START_REPLICATION SLOT "replica_2" 2B0C/F2000000 TIMELINE 1';


-------------- Total Count of Auto Assigned Grievances -------------
select count(1)
from grievance_master gm 
inner join grievance_auto_assign_audit gaaa on gaaa.grievance_id = gm.grievance_id;

------------------------------------------------------------------------------------------------------------------------



--------------- ( Bhandari Da -->>> Bulk Forwarding ---->>> bulk_griev_sts_cng ) ------------------
------------------------------------------------------

select * from bulk_griev_status_assign bgsa where created_on::date between '2025-01-29' and '2025-01-30' order by created_on desc; 
select * from bulk_griev_status_assign bgsa where created_on::date = '2025-01-29' order by created_on desc;                         --id = 46588, 58348, 58349, 46588
select * from grievance_master gm where gm.grievance_id = 4023588; -- 4544530, 4546947, 4547829, 4549344, 4552344, 4552483
select * from grievance_lifecycle gl where gl.grievance_id = 4023588;
select * from grievance_master gm where gm.grievance_no = 'SSM3766198';
select * from bulk_griev_status_assign agsa where agsa.is_rabbit_traversed = false;
[5286400, 5314070, 5347745, 5348556, 5289611, 5291781, 5279922, 5289426, 5297492,

-- is_rabbit_traversed   >> is the batch completed or NOt
-- is_processed  >> All Grievance Ids Of The Batch are processed or not

--request_data >> input batch_processing data
--request_grievance_ids >> requested Grievance Ids
--processed_grievance_ids >> processed Ids among requested Grievance Ids
--failed_grievance_ids >> failed Ids among requested Grievance Ids
--created_on >> when batch is created
--updated_on  >> when Row Is latest Updated
--created_by_position  >> Who Created The Batch His Position ID
-- status >> on which status grievance want to go

-------------------------------------------------------------------------------------------------------------



-- public.master_district_block_grv source

--CREATE OR REPLACE VIEW public.master_district_block_grv
--AS SELECT gm.grievance_id,
--    gm.grievance_no,
--    gm.grievance_category,
--    gm.grievance_description,
--    gm.status,
--    gm.atr_recv_cmo_flag,
--    gm.closure_reason_id,
--    gm.district_id,
--    gm.sub_division_id,
--    gm.block_id,
--    gm.municipality_id,
--    gm.gp_id,
--    gm.ward_id,
--    dm.district_name,
--    csdm.sub_division_name,
--    cbm.block_name,
--    cmm.municipality_name,
--    cgpm.gp_name,
--    cwm.ward_name,
--    gm.grievance_generate_date,
--    gm.grievance_source,
--    gm.address_type,
--    gm.assigned_to_position,
--    gm.updated_by_position,
--    gm.assigned_by_office_id,
--    gm.assigned_to_office_id,
--    gm.assigned_to_id,
--    gm.pri_cont_no,
--    gm.applicant_name,
--    gm.updated_on,
--    gm.atn_id,
--    gm.current_atr_date,
--    gm.action_taken_note,
--    gm.emergency_flag,
--    gm.police_station_id,
--    gm.receipt_mode,
--    gm.received_at,
--    gm.applicant_gender,
--    gm.applicant_age,
--    gm.applicant_caste,
--    gm.applicant_reigion,
--    gm.applicant_address,
--    gm.state_id,
--    gm.assembly_const_id,
--    gm.postoffice_id,
--    gm.employment_type,
--    gm.employment_status,
--    gm.reference_no,
--    gm.alt_cont_no,
--    gm.cont_email,
--    gm.action_requested,
--    gm.usb_unique_id,
--    gm.atr_recv_cmo_date,
--    gm.grievence_close_date,
--    gm.atr_submit_by_lastest_office_id
--   FROM grievance_master gm
--     LEFT JOIN cmo_districts_master dm ON gm.district_id = dm.district_id
--     LEFT JOIN cmo_sub_divisions_master csdm ON csdm.sub_division_id = gm.sub_division_id
--     LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = gm.block_id
--     LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = gm.municipality_id
--     LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = gm.gp_id
--     LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = gm.ward_id;
--
--select * from public.cmo_office_master;






-- public.cmo_bulk_closure_audit definition

-- Drop table

-- DROP TABLE public.cmo_bulk_closure_audit;

--CREATE TABLE public.cmo_bulk_closure_audit (
--	id int8 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
--	griev_id int8 NULL,
--	status varchar(1) NULL,
--	lock_api_request jsonb NULL,
--	lock_api_response jsonb NULL,
--	lock_api_statuscode int4 NULL,
--	status_change_api_request jsonb NULL,
--	status_change_api_response jsonb NULL,
--	status_change_api_statuscode int4 NULL,
--	created_on timestamptz NOT NULL,
--	is_reprocessed bool NOT NULL,
--	reprocessed_on timestamptz NULL,
--	CONSTRAINT cmo_bulk_closure_audit_pkey PRIMARY KEY (id)
--);










select * from grievance_lifecycle gl where gl.assign_comment = 'Auto-assigned by System'
order by assigned_on desc;


--update grievance_lifecycle set assign_comment = 'May please be looked into'
--where assign_comment = 'Auto-assigned by System';


------------------------------------------------------------------------------- GRIEVANCE NO DEBUGGING -------------------------------------------------------------------------------------------

select * from grievance_master gm where gm.grievance_no = '831786393008082023235547'; -- 1502605
select * from grievance_lifecycle gl where gl.grievance_id = 1502605  order by assigned_on ;

select * from admin_position_master apm where apm.position_id = 13;
select * from admin_position_master apm where apm.position_id = 3752;

select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2019/0012';
select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2020/3769';
----------------------------------------------------------------------------------------------------------------------

select * from grievance_master gm where gm.grievance_no = '956412916204072024212234'; -- 2753396
select * from grievance_lifecycle gl where gl.grievance_id = 2753396  order by assigned_on ;

select * from admin_position_master apm where apm.position_id = 13;
select * from admin_position_master apm where apm.position_id = 3754;

select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2019/0012';
select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2020/3769';
-----------------------------------------------------------------------------------------------------------------------

select * from grievance_master gm where gm.grievance_no = 'CMO61470643'; -- 4711728
select * from grievance_lifecycle gl where gl.grievance_id = 4711728  order by assigned_on ;

select * from admin_position_master apm where apm.position_id = 13;
select * from admin_position_master apm where apm.position_id = 3754;

select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2019/0012';
select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2020/3769';
--------------------------------------------------------------------------------------------------------------------------

select * from grievance_master gm where gm.grievance_no = '701969320118072023023431'; -- 403300

select *,
	assigned_by_office_cat, 
	assigned_to_office_cat, 
	assigned_by_office_id, 
	assigned_to_office_id,  
	grievance_status 
from grievance_lifecycle gl where gl.grievance_id = 403300  order by assigned_on ;


select * from admin_position_master apm where apm.position_id = 13;
select * from admin_position_master apm where apm.position_id = 3754;

select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2019/0012';
select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2020/3769';
--------------------------------------------------------------------------------------------------------------------------

select * from grievance_master gm where gm.grievance_no = 'SSM3942654'; -- 4738867

select *,
	assigned_by_office_cat, 
	assigned_to_office_cat, 
	assigned_by_office_id, 
	assigned_to_office_id,  
	grievance_status 
from grievance_lifecycle gl where gl.grievance_id = 4738867  order by assigned_on ;

select * from admin_position_master apm where apm.position_id = 13;
select * from admin_position_master apm where apm.position_id = 3754;

select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2019/0012';
select * from actual_migration.cmro_master_user_1st_pull cmu where cmu.official_code = '2020/3769';
--------------------------------------------------------------------------------------------------------------------------

select * from admin_user_details aud where aud.official_name = 'Shri Prasanta Biswas , WBCS(Exe)';

select * from user_otp uo where u_phone = '8017888777' order by created_on desc;

select * from admin_user_position_mapping aupm where admin_user_id = '11168';





select count(1) from grievance_master gl where gl.assigned_by_office_cat = 2 and gl.assigned_to_office_cat = 1 and status 





select 
	cbrd.status,
	cbrd.batch_id,
	cbrd.batch_date,
	cbrd.from_time,
	cbrd.to_time 
from cmo_batch_grievance_line_item cbgli 
inner join cmo_batch_run_details cbrd on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
inner join cmo_emp_batch_run_details cebrd on cebrd.batch_id = cbrd.batch_id and cbrd.batch_date = cebrd.batch_date
inner join grievance_master gm on gm.grievance_id = cbgli.griev_id;


---- close ----
with atr_closed as (
        SELECT gm.updated_by, gm.updated_by_position, count(1) as disposed
            from grievance_master as gm
        where gm.status = 15
        group by gm.updated_by, gm.updated_by_position
    ) select
concat(admin_user_details.official_name, ' - ', admin_user_role_master.role_master_name) as official_and_role_name,
    coalesce(atr_closed.disposed, 0) as closed
from atr_closed
left join admin_user_details on atr_closed.updated_by = admin_user_details.admin_user_id
left join admin_position_master on atr_closed.updated_by_position = admin_position_master.position_id
left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
where atr_closed.updated_by_position = 3171;



select count(1) from grievance_master gm where gm.status = 15 and gm.updated_by_position = 3171 AND gm.grievence_close_date::date BETWEEN '2025-02-20' AND CURRENT_DATE;
select count(1) from grievance_master gm where gm.status = 15 and gm.updated_by_position = 3171 and gm.grievence_close_date::date >= '2025-02-20';
 

select * from cmo_bulk_closure_audit cbca where cbca.status = 'S' order by cbca.id asc;
select count(1) from cmo_bulk_closure_audit cbca where cbca.status = 'S';


select * from cmo_parameter_master cpm ;
select * from cmo_grievance_category_master cgcm ;
select * from cmo_action_taken_note_master catnm ;
select * from admin_position_master apm where apm.position_id = 3171;
select * from grievance_lifecycle gl where gl.grievance_id = 87856 order by gl.assigned_on desc;


-------------------- Bulk Closure chcek --------------------------
select count(1) from grievance_master gm
    where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10; --40392   --221679  --178957 + 73
    

select count(1) from grievance_master gm
    where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 5;   ---atn_id = 5 not eligible to get benift
  
select count(1) from grievance_master gm
    where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10;
   
 
select * from grievance_master gm
    where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10
   limit 10;
 

select count(1) from grievance_master gm
    where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10 and ;  
  
   
-- SSM PUSH - Updated - Kinnar
   
select
	cspd.cmo_ssm_push_details_id,	
	cspd.status,
	cspd.push_date,
	cspd.from_row_no,
	cspd.to_row_no,
	cspd.data_count,
	cspd.actual_push_date,
	cspd.response
from cmo_ssm_push_details cspd
where cspd.actual_push_date::date = '2025-04-23'::date;

------------------------------------------------------------------------------------------------------------------

select * from grievance_master gm where gm.grievance_no = '831786393008082023235547';
select * from grievance_lifecycle gl where gl.grievance_id = 1502605 order by lifecycle_id;


select
	gl.lifecycle_id,
	gl.assigned_on::date,
	gl.grievance_status,
--	gl.assigned_by_position,
--	gl.assigned_by_id,
	gl.assigned_by_office_id,
--	gl.assigned_to_position,
	gl.assigned_to_office_id
--	gl.assigned_to_id
from grievance_lifecycle gl
where gl.grievance_id = 1502605
order by lifecycle_id asc;

/*
Griev No: 831786393008082023235547
Id: 1502605
Create Date: 2023-08-08 18:25:47.313 +0530
Master Status: 11 (ATR Submitted to HoD)

*/



---- matter taken up --
select * from grievance_master gm where gm.atn_id in (12,9) and gm.grievance_category = 133 and gm.status in (3,4,5,6,11,13) limit 10;
select * from grievance_master gm where gm.atn_id in (9) and gm.grievance_category = 133 and gm.status in (3,4,5,6,11,13);
select * from grievance_master gm where gm.atn_id in (12) and gm.grievance_category = 133 and gm.status in (3,4,5,6,11,13);
 
 

select * from cmo_action_taken_note_master catnm ;   -- beyond 90 days 12 -- within 90 days 9
select * from cmo_action_taken_note_reason_master catnrm ;
select * from atn_closure_reason_mapping acrm ;
select * from cmo_grievance_category_master cgcm ;
select * from cmo_domain_lookup_master cdlm ;
select * from cmo_sub_office_master csom where csom.suboffice_id = 1462;
select * from cmo_office_master com where com.office_id = 23;


--1) office_ id = 51, sub_office_id = 5740 -- 937 HOSO
--2) office_ id = 117, sub_office_id = 5389
--3) office_ id = 42, sub_office_id = 2610

--grievance_id = 834, 993, 1627, 1632, 1825


select 
	gl.assigned_by_office_cat, 
	gl.assigned_to_office_cat, 
	apm.role_master_id as by_role, 
	apm2.role_master_id as to_role,
	apm.sub_office_id as by_sub, 
	apm2.sub_office_id as to_sub, 
	gl.assigned_by_office_id , 
	gl.assigned_to_office_id ,
	gl.grievance_status , 
	gl.assigned_on , 
	gl.lifecycle_id , 
	gl.*, 
	apm.record_status, 
	apm2.record_status 
from grievance_lifecycle gl
left join admin_position_master apm on apm.position_id = gl.assigned_by_position 
left join admin_position_master apm2 on apm2.position_id = gl.assigned_to_position 
where grievance_id = 834 order by assigned_on ;


select * from admin_position_master apm where sub_office_id = 5740;
select * from admin_position_master apm where sub_office_id = 5740 and role_master_id = 7-- and record_status = 2;


--------------------------------------------------------------------------------------- BULK STATUS UPDATE CLOSE API ------------------------------------------------------------------------------------------------
--drop table grievance_lifecycle_sdc_timestamp_20250806_bkp;

--create table griev_ids_mas();
--create table griev_ids_mast();
--create table griev_ids_pnrd_p2();
--create table griev_ids_pnrd_nte_p2();
--create table griev_ids_pnrd_e_p2_road();
--create table griev_ids_pnrd_nte_p2_road();
--create table griev_ids_pnrd_nte_p3();
create table grievance_lifecycle_sdc_timestamp_20250806_bkp as SELECT distinct gl.* FROM grievance_lifecycle gl 
inner join grievance_master_sdc_timestamp_issue_20250806_bkp gm on gm.grievance_id = gl.grievance_id order by gl.grievance_id asc;



--CREATE TABLE public.grievance_lifecycle_sdc_timestamp_20250806_bkp (
--	lifecycle_id int8,
--	"comment" text NULL,
--	grievance_status int2 NOT NULL,
--	assigned_on timestamptz(6) NULL,
--	assigned_by_id int8 NULL,
--	assign_comment text NULL,
--	assigned_to_id int8 NULL,
--	assign_reply text NULL,
--	accepted_on timestamptz(6) NULL,
--	atr_type int2 NULL,
--	atr_proposed_date timestamptz(6) NULL,
--	official_code varchar(100) NULL,
--	action_taken_note text NULL,
--	atn_id int8 NULL,
--	atn_reason_master_id int8 NULL,
--	action_proposed text NULL,
--	contact_date timestamptz(6) NULL,
--	tentative_date timestamptz(6) NULL,
--	prev_recv_date timestamptz(6) NULL,
--	prev_atr_date timestamptz(6) NULL,
--	closure_reason_id int8 NULL,
--	atr_submit_on timestamptz(6) NULL,
--	created_by int8 NULL,
--	created_on timestamptz(6) NULL,
--	grievance_id int8 NULL,
--	assigned_by_position int8 NULL,
--	assigned_to_position int8 NULL,
--	urgency_type int2 NULL,
--	addl_doc_id jsonb NULL,
--	current_atr_date timestamptz(6) NULL,
--	atr_doc_id jsonb NULL,
--	assigned_by_office_id int8 NULL,
--	assigned_to_office_id int8 NULL,
--	assigned_by_office_cat int8 NULL,
--	assigned_to_office_cat int8 NULL,
--	migration_id int4 NULL,
--	migration_id_ac_tkn int4 NULL
----	CONSTRAINT grievance_lifecycle_sdc_timestamp_20250806_bkp_pkey PRIMARY KEY (lifecycle_id, grievance_status)
--)


--create table mobile_sms();


--create table griev_ids_pnrd_p2 (
--	grievance_id varchar(50),
--	action_taken_note varchar(250)
--);


--CREATE TABLE griev_ids_pnrd_nte_p3 (
--	grievance_id int4 NULL,
--	action_taken_note varchar(50) NULL,
--	action_taken_note_reason_for_not_eligible varchar(50) NULL
--);


------------ Bulk Status Update Closure -- Phrase 1 Eligible ----------
select gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_mas gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no;


------------ Bulk Status Update Closure -- Phrase 2 Eligible ----------
select gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_p2 gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no;


------------ Bulk Status Update Closure -- Phrase 2 Not-Eligible ----------
select gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_nte_p2 gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no;

------------ Bulk Status Update Closure -- Phrase 2 Eligible for Road ----------
select gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_e_p2_road gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no;


------------ Bulk Status Update Closure -- Phrase 2 Not-Eligible for Road ----------
select gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_nte_p2_road gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no;


------------ Bulk Status Update Closure -- Phrase 3 Not-Eligible for P&RD ----------
select gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_nte_p3 gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no;


------------ Bulk Status Update Closure -- Phrase 3 Eligible for P&RD ----------
select gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_p3 gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no;


------------ Bulk Status Update Closure -- Phrase 4 Eligible for P&RD ----------
select gim.grievance_id, gim.action_taken_note, gim.remarks , gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_p2 gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gm.status, gm.grievance_no, gim.remarks;


------------ Bulk Status Update Closure -- Phrase 4 Not-Eligible for P&RD ----------
select gim.grievance_id, gim.action_taken_note, gim.remarks, gm.status, gm.grievance_no
from grievance_master gm
inner join griev_ids_pnrd_nte_p2 gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gim.action_taken_note, gim.remarks, gm.status, gm.grievance_no;





------------ Bulk Status Update Closure -- Phrase 2 Not-Eligible Data Fatch for PNRD ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_nte_p2 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible_pnrd cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;


------------ Bulk Status Update Closure -- Phrase 2 Eligible Data Fatch for PNRD ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_p2 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_eligible_pnrd cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;


------------ Bulk Status Update Closure -- Phrase 2 Eligible Data Fatch for PNRD Road ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_e_p2_road gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_eligible_pnrd_road cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;


------------ Bulk Status Update Closure -- Phrase 2 Not-Eligible Data Fatch for PNRD Road ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_nte_p2_road gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_nte_pnrd_road cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;


------------ Bulk Status Update Closure -- Phrase 3 Not-Eligible Data Fatch for PNRD ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_nte_p3 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible_pnrd cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;


------------ Bulk Status Update Closure -- Phrase 3 Eligible Data Fatch for PNRD ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_p3 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_eligible_pnrd cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;


------------ Bulk Status Update Closure -- Phrase 4 Eligible Data Fatch for PNRD ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_p2 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_eligible_pnrd cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;


------------ Bulk Status Update Closure -- Phrase 4 Not-Eligible Data Fatch for PNRD ----------
select gim.grievance_id
    from grievance_master gm
    inner join griev_ids_pnrd_nte_p2 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible_pnrd cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;



---- Status Update Audit Table ---
select count(1) from cmo_bulk_status_update_closure_audit_eligible_pnrd cm ;
select * from cmo_bulk_status_update_closure_audit_eligible_pnrd cm;
select count(1) from cmo_bulk_status_update_closure_audit_noteligible_pnrd cm;
select * from cmo_bulk_status_update_closure_audit_noteligible_pnrd cm;
select count(1) from cmo_bulk_status_update_closure_audit_eligible_pnrd_road cm;
select * from cmo_bulk_status_update_closure_audit_eligible_pnrd_road cm;
select count(1) from cmo_bulk_status_update_closure_audit_nte_pnrd_road cm;
select * from cmo_bulk_status_update_closure_audit_nte_pnrd_road cm;



select gim.grievance_id, gim.action_taken_note, gm.status
from grievance_master gm
inner join griev_ids_mas gim on gm.grievance_id = gim.grievance_id 
order by gim.grievance_id asc;


select gim.grievance_id, gim.action_taken_note, gm.status
    from grievance_master gm
    inner join griev_ids_mas gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10;



select gim.grievance_id, gim.action_taken_note, gm.status, count(1)
    from grievance_master gm
    inner join griev_ids_mas gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit cbsuca where cbsuca.grievance_id = gim.grievance_id)
    group by gim.grievance_id, gim.action_taken_note, gm.status
order by gim.grievance_id asc;




--- testing for grievance proces  ---
select count(1)
    from grievance_master gm
    inner join griev_ids_mas gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit cbsuca where cbsuca.grievance_id = gim.grievance_id)
--    group by gim.grievance_id, gim.action_taken_note, gm.status
--order by gim.grievance_id asc;




select gim.grievance_id, gim.action_taken_note, gm.status
    from grievance_master gm
    inner join griev_ids_mas gim on gm.grievance_id = gim.grievance_id
    inner join cmo_bulk_status_update_closure_audit cbsuca on cbsuca.grievance_id = gim.grievance_id 
order by gim.grievance_id asc limit 2;



select * from grievance_master gm where gm.status = 15 limit 1;
select * from cmo_action_taken_note_master catnm ;


select * from grievance_master gm where gm.grievance_id in (203053) ; 
select * from grievance_lifecycle gl where gl.grievance_id in (1673522) order by gl.assigned_on desc; --2102 2936460

select count(1) from cmo_bulk_status_update_closure_audit cbsuca ;
select count(1) from cmo_bulk_status_update_closure_audit_eligible_pnrd cbsuca ;
select count(1) from griev_ids_mas gim ;


-- has more than one row --
SELECT grievance_id, status, COUNT(*) AS total_count
FROM cmo_bulk_status_update_closure_audit
GROUP BY grievance_id, status
HAVING COUNT(*) > 1;


select * from cmo_bulk_status_update_closure_audit cbsuca where cbsuca.grievance_id in ();
select * from cmo_parameter_master cpm ;

--- not has more than one row ---
SELECT grievance_id, status, COUNT(*) AS total_count
FROM cmo_bulk_status_update_closure_audit
GROUP BY grievance_id, status
HAVING not COUNT(*) > 1;


SELECT COUNT(*) AS total_count
FROM cmo_bulk_status_update_closure_audit
GROUP BY grievance_id, status
HAVING not COUNT(*) > 1;



-- delete more than one row occurence ---
--DELETE FROM cmo_bulk_status_update_closure_audit
--WHERE id NOT IN (
--    SELECT latest_id FROM (
--        SELECT MAX(id) AS latest_id
--        FROM cmo_bulk_status_update_closure_audit
--        GROUP BY grievance_id
--    ) AS latest_rows
--);



--- Data Clean UP Query For Double Entries ----
WITH ordered_duplicates AS (
    SELECT lifecycle_id,
           ROW_NUMBER() OVER (
               PARTITION BY grievance_id, created_on::timestamp::date, grievance_status
               ORDER BY lifecycle_id
           ) AS rn
    FROM grievance_lifecycle
    WHERE grievance_id IN (5119427,5119238,5119078,5117978,5122327,5120642,5120995,5114640,5114418,5114247,5117986,5116896,5118983,5113603,5113227,5113063,
    5111565,5102011,5101423,5099887,5099813,5104703,5099635,5099640,5097600,5097065,5095901,5095633,5095932,5095102,5095018,5094834,5094819,5094812,5092114,
    5091653,5095019,5095271,5093301,5094070,5091032,5088889,5088027,5087909,5085056,5084903,5087849,5087201,5077411,5082719,5075832,5099757,5087512,5087306,5084850,
    5120168,5085100,5087439,5085055,5088614,5093520,5089725,5114421,5122141,5094591,5098796,5095068,5097611,5096439,5114420,5113723) 
      AND created_on::date = '2025-07-26'
      AND grievance_status IN (15, 2, 14, 4, 16)
)
DELETE FROM grievance_lifecycle
WHERE lifecycle_id IN (
    SELECT lifecycle_id FROM ordered_duplicates WHERE rn > 1
);



--- Data Clean UP Query For todays entry ----
WITH ordered_duplicates AS (
    SELECT lifecycle_id,
           ROW_NUMBER() OVER (
               PARTITION BY grievance_id, created_on::timestamp::date, grievance_status
               ORDER BY lifecycle_id
           ) AS rn
    FROM grievance_lifecycle
    WHERE grievance_id in (4193915,5113038,5175868,5178912,5238197)
      AND created_on::date = '2025-07-26'
      AND grievance_status IN (15, 2, 14, 4, 16)
)
DELETE FROM grievance_lifecycle
WHERE lifecycle_id IN (
    SELECT lifecycle_id FROM ordered_duplicates WHERE rn > 1
);


select * from grievance_lifecycle gl where gl.grievance_id = 5093301 order by gl.assigned_on desc;
select * from grievance_lifecycle gl where gl.lifecycle_id = 65828034 order by gl.assigned_on desc;
select * from grievance_master gm where gm.grievance_id = 5093301;


WITH ordered_duplicates AS (
    SELECT lifecycle_id,
           ROW_NUMBER() OVER (
               PARTITION BY grievance_id, created_on::date, grievance_status
               ORDER BY lifecycle_id
           ) AS rn
    FROM grievance_lifecycle
--    WHERE grievance_id IN (4193915,5113038,5175868,5178912,5238197)
      where created_on::date = '2025-07-26'
      AND grievance_status IN (15, 2, 14, 4, 16)
)
SELECT lifecycle_id 
FROM grievance_lifecycle
WHERE lifecycle_id IN (
    SELECT lifecycle_id FROM ordered_duplicates WHERE rn > 1
);









--UPDATE grievance_lifecycle gl
--SET assign_comment = NULL
--FROM griev_ids_pnrd_nte_p2 gm
--WHERE gm.grievance_id = gl.grievance_id
--AND gl.lifecycle_id IN (
--    SELECT lifecycle_id
--    FROM (
--        SELECT gl2.lifecycle_id,
--               ROW_NUMBER() OVER (PARTITION BY gl2.grievance_id ORDER BY gl2.assigned_on DESC) AS rn
--        FROM grievance_lifecycle gl2
--        WHERE gl2.grievance_status = 4
--    ) t
--    WHERE t.rn = 1
--);


--UPDATE grievance_master gm
--SET status = 15
--FROM griev_ids_pnrd_p3 gim
--WHERE gm.grievance_id = gim.grievance_id
--  AND gm.grievance_id IN (
--    299802,
--    347757,
--    458802
--  );


------------- Testing for grievancer proces  ------
select gim.grievance_id, gim.action_taken_note, gim.remarks, gim.action_taken_note_reason_only_for_not_eligible, gm.grievance_no, gm.pri_cont_no 
    from grievance_master gm
    inner join griev_ids_pnrd_nte_p2 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible_pnrd cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc;


select gim.grievance_id, gim.action_taken_note, gim.remarks, gim.action_taken_note_reason_only_for_not_eligible, gm.grievance_no, gm.pri_cont_no, gm.status 
    from grievance_master gm
    inner join griev_ids_pnrd_p3 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit cbsuca where cbsuca.grievance_id = gim.grievance_id) /*and gim.grievance_id in (637618, 2565573)*/
order by gim.grievance_id asc 

-----<<<<<<<<<- Pair 1 For Eligible -- Using Currently------=======================>>>>>>>>
griev_ids_pnrd_p3
cmo_bulk_status_update_closure_audit
------------------------------------------------

--DELETE FROM griev_ids_pnrd_p3
--WHERE grievance_no IS NOT NULL;


--ALTER TABLE griev_ids_pnrd_p3
--ADD COLUMN grievance_no VARCHAR(100);

--- Pair 2 for Non Eligible ---
griev_ids_mast
cmo_bulk_status_update_closure_audit_noteligible


griev_ids_mas
griev_ids_pnrd_nte_p2



select gim.grievance_id, gim.grievance_category, gim.action_taken_note, gim.remarks, gim.action_taken_note_reason_only_for_not_eligible, gim.grievance_no, gm.status 
    from grievance_master gm
    inner join griev_ids_pnrd_p3 gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit as cbsuca where cbsuca.grievance_id = gim.grievance_id)
--    and gim.action_taken_note = 'Not Eligible To Get Benefit/Service'
    and gim.grievance_no is not null 
--    and gim.grievance_id in (2078042)
--    and gim.grievance_category is not null 
    and gm.status = 15
order by gim.grievance_id asc;
--limit 2 offset 0;

select * from cmo_parameter_master cpm ;

--DELETE FROM griev_ids_pnrd_p3 a
--USING griev_ids_pnrd_p3 b
--WHERE a.grievance_id = b.grievance_id
--  AND a.ctid > b.ctid;



--WITH duplicates AS (
--    SELECT gim.*,
--           ROW_NUMBER() OVER (PARTITION BY grievance_id ORDER BY grievance_id) AS rn
--    FROM griev_ids_pnrd_p3 gim
--)
--SELECT * FROM duplicates WHERE rn > 1;




--UPDATE griev_ids_pnrd_p3
--SET grievance_no = NULL
--FROM griev_ids_pnrd_p3 gim
--INNER JOIN grievance_master gm 
--    ON gm.grievance_id = gim.grievance_id
--WHERE NOT EXISTS (
--    SELECT 1
--    FROM cmo_bulk_status_update_closure_audit cbsuca
--    WHERE cbsuca.grievance_id = gim.grievance_id
--)
--AND gim.action_taken_note = 'Beyond State Govt. Purview';
-- AND gm.status = 15;



select gim.grievance_id, gim.action_taken_note, gim.remarks
from griev_ids_pnrd_p3 gim
left join cmo_bulk_status_update_closure_audit cbsuca on gim.grievance_id = cbsuca.grievance_id
where cbsuca.grievance_id is null and gim.grievance_no is null;



--delete from griev_ids_pnrd_p3 where grievance_id is null;


select * from griev_ids_pnrd_p3;
select * from cmo_bulk_status_update_closure_audit where grievance_id = 844618;


--==================================================================================================
--======================== CHECKING FOR BULK STATUS UPDATE INFORMATION =============================
--==================================================================================================

select * from griev_ids_mas where grievance_id in ();
select * from griev_ids_mast where grievance_id in (2626049);
select * from griev_ids_pnrd_e_p2_road where grievance_id in (2626049);
select * from griev_ids_pnrd_nte_p2 where grievance_id in (2626049);   ----->>>>>
select * from griev_ids_pnrd_nte_p2_road where grievance_id in (2626049);
select * from griev_ids_pnrd_nte_p3 where grievance_id in (2078042);
select * from griev_ids_pnrd_p2 where grievance_id in (2626049); --->>>>>
select * from griev_ids_pnrd_p3 where grievance_id in (2078042); ------>>>>>
select * from grievance where grievance_id in (2626049); ------>>>>>>

select * from cmo_bulk_status_update_closure_audit where grievance_id in (2078042);    ------->>>>>>
select * from cmo_bulk_status_update_closure_audit_eligible_pnrd where grievance_id in (2078042); ------->>>>>
select * from cmo_bulk_status_update_closure_audit_eligible_pnrd_road where grievance_id in (2078042);
select * from cmo_bulk_status_update_closure_audit_noteligible where grievance_id in (2078042);
select * from cmo_bulk_status_update_closure_audit_noteligible_pnrd where grievance_id in (2078042);
select * from cmo_bulk_status_update_closure_audit_nte_pnrd_road where grievance_id in (2078042);

select * from grievance where grievance_id in (2626049);


select * from grievance_lifecycle gl where gl.grievance_id = 5114418 order by gl.assigned_on desc;
select * from grievance_master gm where gm.grievance_id = 2614497;
select * from cmo_action_taken_note_master catnm ;
select * from cmo_action_taken_note_reason_master catnrm ;
select * from cmo_grievance_category_master cgcm ;



--TRUNCATE TABLE grievance;

select * from grievance where exists ( select 1 from cmo_bulk_status_update_closure_audit as cbsuca where cbsuca.grievance_id = grievance.grievance_id);
select * from grievance where exists ( select 1 from cmo_bulk_status_update_closure_audit_eligible_pnrd as cbsuca where cbsuca.grievance_id = grievance.grievance_id);
select * from grievance where exists ( select 1 from cmo_bulk_status_update_closure_audit_eligible_pnrd_road as cbsuca where cbsuca.grievance_id = grievance.grievance_id);
select * from grievance where exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible as cbsuca where cbsuca.grievance_id = grievance.grievance_id);
select * from grievance where exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible_pnrd as cbsuca where cbsuca.grievance_id = grievance.grievance_id);   --->>>
select * from grievance where exists ( select 1 from cmo_bulk_status_update_closure_audit_nte_pnrd_road as cbsuca where cbsuca.grievance_id = grievance.grievance_id);



---===================================================================================================
--====================================================================================================
--====================================================================================================



--update griev_ids_pnrd_p3
--set grievance_id = (SELECT gm.grievance_id FROM grievance_master gm INNER JOIN griev_ids_pnrd_p3 gim ON gm.grievance_no = gim.grievance_no)
--where grievance_id is null;



---- Update Grievance ID Query -----
UPDATE griev_ids_pnrd_p3 g
SET grievance_id = gm.grievance_id
FROM grievance_master gm
WHERE g.grievance_no = gm.grievance_no
  AND g.grievance_id IS NULL;


---- Delete Multiple Entry From the Table -----
--DELETE FROM griev_ids_pnrd_p3 a
--USING griev_ids_pnrd_p3 b
--WHERE a.grievance_id = b.grievance_id
--  AND a.ctid > b.ctid;



---------------------------------------------------------------------------------
--- Check The Multiple Time Entry In Excel ---
select
a.*
from (
select
	xx.grievance_no,
	xx.grievance_id,
	count(xx.grievance_no) as c,
	xx.action_taken_note_reason_only_for_not_eligible  as not_eligible
from griev_ids_pnrd_p3 xx
where not exists ( select 1 from cmo_bulk_status_update_closure_audit as cbsuca where cbsuca.grievance_id = xx.grievance_id)
group by grievance_no,grievance_id,action_taken_note_reason_only_for_not_eligible
) a
where  a.c > 1 and a.grievance_id is not null and a.grievance_no is not null and a.not_eligible is not null
order by a.c desc;


-------------------------------------------------------------------------------------------
--- Fetching Unique Grievance IDs Only (Having Count = 1) For Processing --- Phrase 2
SELECT 
    gim.grievance_id, gim.action_taken_note, gim.remarks, gim.action_taken_note_reason_only_for_not_eligible, gim.grievance_no, gm.status, gm.updated_on 
FROM grievance_master gm
INNER JOIN (
    SELECT 
        xx.grievance_no, xx.grievance_id
--	count(xx.grievance_no) as maximum_count
--	xx.action_taken_note_reason_only_for_not_eligible  as not_eligible
    FROM griev_ids_pnrd_p3 xx
    WHERE NOT EXISTS (
        SELECT 1 
        FROM cmo_bulk_status_update_closure_audit cbsuca 
        WHERE cbsuca.grievance_id = xx.grievance_id
    )
    GROUP BY xx.grievance_no, xx.grievance_id
    HAVING COUNT(xx.grievance_no) = 1  /*limit 1000 offset 0*/
--    ORDER BY xx.grievance_id
--    LIMIT 1000 
) uniq 
    ON gm.grievance_id = uniq.grievance_id
INNER JOIN griev_ids_pnrd_p3 gim 
    ON gm.grievance_id = gim.grievance_id AND gm.grievance_no = gim.grievance_no
WHERE uniq.grievance_id IS NOT null AND uniq.grievance_no IS NOT null and gim.action_taken_note_reason_only_for_not_eligible is not null and gm.status != 15
ORDER BY gim.grievance_id asc;       --30225


---- Perfect Query ----
WITH filtered AS (
    SELECT gim.grievance_id, gim.action_taken_note, gim.remarks, gim.action_taken_note_reason_only_for_not_eligible, gim.grievance_no, gm.status, gm.updated_on
    FROM grievance_master gm
    INNER JOIN (
        SELECT xx.grievance_no, xx.grievance_id
        FROM griev_ids_pnrd_p3 xx
        WHERE NOT EXISTS (
            SELECT 1
            FROM cmo_bulk_status_update_closure_audit cbsuca
            WHERE cbsuca.grievance_id = xx.grievance_id
        )
        GROUP BY xx.grievance_no, xx.grievance_id
        HAVING COUNT(xx.grievance_no) = 1
    ) uniq 
        ON gm.grievance_id = uniq.grievance_id
    INNER JOIN griev_ids_pnrd_p3 gim ON gm.grievance_id = gim.grievance_id AND gm.grievance_no = gim.grievance_no
    WHERE /*gim.action_taken_note_reason_only_for_not_eligible IS null and*/ gm.status != 15
)
SELECT *
FROM filtered
ORDER BY grievance_id ASC
--LIMIT 1000;





------ Processed  Grievance ID ------
select gim.grievance_id, gim.action_taken_note, gim.remarks, gim.action_taken_note_reason_only_for_not_eligible, gim.grievance_no, gm.updated_on 
    from grievance_master gm
    inner join (
        select
            xx.grievance_no,
            xx.grievance_id
--            COUNT(xx.grievance_no) AS c
        from griev_ids_pnrd_p3 as xx
        where EXISTS ( select 1 from cmo_bulk_status_update_closure_audit as cbsuca where cbsuca.grievance_id = xx.grievance_id )
        GROUP BY xx.grievance_no, xx.grievance_id
        HAVING COUNT(xx.grievance_no) = 1 
    ) uniq on gm.grievance_id = uniq.grievance_id
    inner join griev_ids_pnrd_p3 as gim ON gm.grievance_id = gim.grievance_id and gm.grievance_no = gim.grievance_no
    where uniq.grievance_id IS not NULL and uniq.grievance_no IS not null and gim.action_taken_note_reason_only_for_not_eligible is not null and gm.status = 15
    ORDER BY gim.grievance_id asc ;

    


--DELETE FROM cmo_bulk_status_update_closure_audit 
--WHERE grievance_id IN (1094621)
--AND created_on::date = '2025-07-23';

 
select * from cmo_parameter_master cpm ;
select * from cmo_action_taken_note_master catnm ;
select * from atn_closure_reason_mapping acrm ;
select * from cmo_closure_reason_master ccrm ;
select * from cmo_action_taken_note_reason_master ;
select * from cmo_grievance_category_master cgcm ;
select * from cmo_office_master com ;
select * from grievance_master gm where gm.grievance_id in (844618, 1039718, 3539655);
select * from grievance_master gm where gm.grievance_no in ('747883829526092024151511');	
select * from grievance_lifecycle gl where gl.grievance_id in (629032240809022024200129) order by gl.assigned_on desc;
select * from cmo_bulk_status_update_closure_audit_noteligible_pnrd where grievance_id = 2021018;
select * from cmo_bulk_status_update_closure_audit where grievance_id = 844618;
select * from cmo_bulk_status_update_closure_audit where id = 2159312;
SELECT id FROM cmo_bulk_status_update_closure_audit ORDER BY id DESC LIMIT 1;
select * from grievance_locking_history glh where glh.grievance_id = 347757;
select * from cmo_parameter_master cpm ;

select * from cmo_grievance_category_master cgcm ;
select * from cmo_griev_cat_office_mapping cgcom ;
select * from cmo_office_master com where com.office_id = 2;


select * from grievance_lifecycle WHERE grievance_id IN (2844618
1039718
3539655) 
AND created_on::date = '2025-08-05';


select grievance_id from grievance_master gm order by grievance_id desc limit 1;

75025, 157714, 299802, 347757, 458802, 544040, 639313, 1021208, 1094621, 1120527, 1147925, 1661965, 1689703, 1698324, 1747388, 1756274, 1830198, 1910240, 2021018, 2034237, 2044223, 2327571, 
2486609, 2741316, 2823552, 3035119, 3131366, 3200822, 3231993, 3314679, 3338450, 3406928, 3421217, 4429379, 4829175, 4900916, 
5103231, 5127211, 5163067, 5252572, 5259472, 5271277, 5271743, 5296275, 5331917, 5355401, 5390979, 5398756, 5410585, 5463718, 5488272, 5502972, 5508410, 5510314

select gm.status from grievance_master gm where gm.grievance_id in (2729424)
select gm.atn_reason_master_id from grievance_master gm where gm.grievance_id in (2729424)
    
----------------------------------------- delete form lifecycle trail --------------------------------------------
--DELETE FROM grievance_lifecycle
--WHERE grievance_id IN (75025, 157714, 299802, 347757, 458802, 544040, 639313, 1021208, 1094621, 1120527, 1147925, 1661965, 1689703, 1698324, 1747388, 1756274, 1830198, 1910240, 2021018, 2034237, 2044223, 2327571, 
--2486609, 2741316, 2823552, 3035119, 3131366, 3200822, 3231993, 3314679, 3338450, 3406928, 3421217, 4429379, 4829175, 4900916, 
--5103231, 5127211, 5163067, 5252572, 5259472, 5271277, 5271743, 5296275, 5331917, 5355401, 5390979, 5398756, 5410585, 5463718, 5488272, 5502972, 5508410, 5510314) 
--AND created_on::date = '2025-08-04';

--
--DELETE FROM cmo_bulk_status_update_closure_audit_eligible_pnrd
--DELETE FROM cmo_bulk_status_update_closure_audit_noteligible_pnrd
--DELETE FROM cmo_bulk_status_update_closure_audit


--DELETE FROM  
--WHERE grievance_id IN (3647330,
--2332941,
--2807129,
--381572,
--370735
--1028073,
--1089627,
--1154916,
--1500619
--);
----AND created_on::date = '2025-08-01';


select * from grievance_lifecycle gl where gl.grievance_id in (4477158) order by gl.assigned_on desc; --2102 2936460
---------------------------------------------------------------------------------

--- Not benifit service ---
select gim.grievance_id, gm.status, gim.action_taken_note, gm.grievance_no 
from grievance_master gm
inner join griev_ids_mast gim on gm.grievance_id = gim.grievance_id 
group by gim.grievance_id, gm.status, gim.action_taken_note, gm.grievance_no
order by gim.grievance_id asc;


select gim.grievance_id, gim.action_taken_note, gm.status
    from grievance_master gm
    inner join griev_ids_mast gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc limit 10 offset 0;


select gim.grievance_id, gim.action_taken_note, gm.status
    from grievance_master gm
    inner join griev_ids_mast gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible cbsuca where cbsuca.grievance_id = gim.grievance_id)
order by gim.grievance_id asc;


select gim.grievance_id, gim.action_taken_note, gm.status, count(1)
    from grievance_master gm
    inner join griev_ids_mast gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible cbsuca where cbsuca.grievance_id = gim.grievance_id)
    group by gim.grievance_id, gim.action_taken_note, gm.status
order by gim.grievance_id asc;


select count(1)
    from grievance_master gm
    inner join griev_ids_mast gim on gm.grievance_id = gim.grievance_id
    where not exists ( select 1 from cmo_bulk_status_update_closure_audit_noteligible cbsuca where cbsuca.grievance_id = gim.grievance_id)
--    group by gim.grievance_id, gim.action_taken_note, gm.status
--order by gim.grievance_id asc;


select * from cmo_parameter_master cpm ;
select count(1) from griev_ids_mast;
select count(1) from cmo_bulk_status_update_closure_audit_noteligible;

select * from grievance_master gm where gm.grievance_id in (15220, 15226, 16885, 16910, 18591) ; 
select * from grievance_lifecycle gl where gl.grievance_id in (3520818) order by gl.assigned_on desc; --2102 2936460



select * from cmo_bulk_status_update_closure_audit cbsuca where cbsuca.status = 'F';

-- public.cmo_bulk_status_update_closure_audit_nte_pnrd_road definition
-- Drop table
-- DROP TABLE public.cmo_bulk_status_update_closure_audit_nte_pnrd_road;

--CREATE TABLE public.cmo_bulk_status_update_closure_audit_nte_pnrd_road (
--	id int8 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
--	grievance_id int8 NULL,
--	status varchar(1) NULL,
--	recall_api_request jsonb NULL,
--	recall_api_response jsonb NULL,
--	recall_api_statuscode int4 NULL,
--	forward_api_request jsonb NULL,
--	forward_api_response jsonb NULL,
--	forward_api_statuscode int4 NULL,
--	atr_submitted_request jsonb NULL,
--	atr_submitted_response jsonb NULL,
--	atr_submitted_statuscode int4 NULL,
--	lock_api_request jsonb NULL,
--	lock_api_response jsonb NULL,
--	lock_api_statuscode int4 NULL,
--	close_api_request jsonb NULL,
--	close_api_response jsonb NULL,
--	close_api_statuscode int4 NULL,
--	created_on timestamptz NOT NULL,
--	is_reprocessed bool NOT NULL,
--	reprocessed_on timestamptz NULL,
--	CONSTRAINT cmo_bulk_status_update_closure_audit_nte_pnrd_road_pkey PRIMARY KEY (id)
--);


------------------------------------------------------------------
select * from grievance_master gm where gm.atn_id = 11;
select * from grievance_master gm where gm.pri_cont_no = '8101859077';


select * from grievance_master gm where gm.grievance_no in ('000000000013122019012610');
select * from grievance_master gm where gm.grievance_id = 13611;
select * from grievance_lifecycle gl where gl.grievance_id = 9898; --2709860, 5651



---=======================================================================
select
        psm.ps_id AS unique_id,
        psm.ps_code AS unique_code,
        psm.ps_name AS unique_name,
        psm.district_id,
        dist.district_name,
        psm.sub_district_id,
        sdist.sub_district_name,
        psm.status
from cmo_police_station_master psm
inner join cmo_districts_master dist on dist.district_id = psm.district_id
-- inner join  cmo_sub_districts_master sdist on sdist.sub_district_id = psm.sub_district_id
left join  cmo_sub_districts_master sdist on sdist.sub_district_id = psm.sub_district_id
where psm.status = 1 and (psm.ps_code LIKE '%bhangar%' or 
lower(dist.district_name) LIKE '%bhangar%' or 
lower(psm.ps_name) LIKE '%bhangar%' or 
lower(sdist.sub_district_name) LIKE '%bhangar%')
order by dist.district_name,sdist.sub_district_name,psm.ps_name asc limit 20 offset 0;

---=====================================================================================


select  gl.lifecycle_id, atr_type, atr_proposed_date, action_taken_note, gl.atn_id, 
    catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
    prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
    gl.assigned_on, gl.assigned_by_id, gl.assign_comment, 
    gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position, 
    gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
from grievance_lifecycle gl
left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id 
where gl.atn_id is not null and gl.lifecycle_id  = 54677608;



select  atr_type, atr_proposed_date, action_taken_note, gl.atn_id,
        catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
        prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
        gl.assigned_on, gl.assigned_by_id, gl.assign_comment,
        gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position,
        gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
    from grievance_lifecycle gl
    left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
    left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id
    where gl.atn_id is not null and gl.lifecycle_id  = 54677609;

 -------------------------------------------------------------------------------------------------------------                  
                   
 select *from grievance_lifecycle gl where gl.lifecycle_id = 54677609;
select * from grievance_lifecycle gl where gl.lifecycle_id = 2;
select * from grievance_lifecycle gl where gl.grievance_id = 2316548;


 -- Dublicate lifecycle id exist ---
 SELECT 
    gl.lifecycle_id,COUNT(*) AS lifecycle_count
FROM grievance_lifecycle gl
GROUP BY gl.lifecycle_id
HAVING COUNT(*) > 1;

SELECT 
    gl.lifecycle_id,
    COUNT(*) AS lifecycle_count,
    STRING_AGG(gl.grievance_id::text, ', ') AS grievance_ids
FROM grievance_lifecycle gl
GROUP BY gl.lifecycle_id
HAVING COUNT(*) > 1;

SELECT 
    gl.lifecycle_id,
    gl.grievance_id
FROM grievance_lifecycle gl
WHERE gl.lifecycle_id IN (
    SELECT lifecycle_id
    FROM grievance_lifecycle
    GROUP BY lifecycle_id
    HAVING COUNT(*) > 1
)
ORDER BY gl.lifecycle_id;


-------------------------------------------------------------------

select * from admin_user au where au.
select * from admin_user_details aud where aud.official_phone ;



--------- Departmental Admin and Nodal user ------------

select admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name 
from admin_user_details
inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
inner join cmo_office_master com on com.office_id = admin_position_master.office_id
where /*admin_position_master.office_id = 35 and */ admin_position_master.office_id is not null and admin_position_master.role_master_id in (4,5) and 
	  admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1
	 group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
select * from bulk_griev_status_mesg_assign_office bgsmao;	
select count(1) from bulk_griev_status_mesg_assign_office bgsmao ;
	
	
select 
    admin_user_details.official_name, 
    admin_user_details.official_phone, 
    admin_position_master.office_id, 
    aurm.role_master_name, 
    admin_position_master.position_id
    from admin_user_details
        inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
        inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
        inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
    where /*admin_position_master.office_id = 35 and*/ admin_position_master.office_id is not null and admin_position_master.role_master_id in (4,5) and 
    admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1 /*and admin_position_master.position_id = 10140*/
    group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id;    ---9297929297  8101859077

    
    select 
        admin_user_details.official_name, 
        admin_user_details.official_phone, 
        admin_position_master.office_id,
        com.office_name,
        aurm.role_master_name, 
        admin_position_master.position_id
        from admin_user_details
            inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
            inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
            inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
            inner join cmo_office_master com on com.office_id = admin_position_master.office_id
        where /*admin_position_master.office_id = 35 and*/ admin_position_master.office_id is not null and admin_position_master.role_master_id in (4,5) and 
        admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1 /*and admin_position_master.position_id = 10140*/
        group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name
       order by admin_position_master.office_id asc;
       
       
    
 select bgsmao.id, bgsmao.request_mobile_no, bgsmao.processed from bulk_griev_status_mesg_assign_office bgsmao where bgsmao.processed is not true;
	
select count(1) from bulk_griev_status_mesg_assign_office_demo_dump bgsmaodd ;
    
select aud.admin_user_id, aud.official_code, aud.official_phone, aud.official_name from admin_user_details aud 
inner join admin_user_position_mapping aupm on aupm.admin_user_id = aud.admin_user_id and aupm.status = 1
inner join admin_user au on au.admin_user_id = aud.admin_user_id 
inner join admin_position_master apm on apm.position_id = aupm.position_id and aupm.status = 1
where au.status = 1 and apm.record_status = 1 and aupm.status = 1 and apm.role_master_id in (4,5) and trim(aud.official_email) in (null, '');


SELECT 
    aud.admin_user_id, 
    aud.official_phone, 
    aud.official_name,
    aud.official_email
FROM admin_user_details aud
INNER JOIN admin_user_position_mapping aupm 
    ON aupm.admin_user_id = aud.admin_user_id AND aupm.status = 1
INNER JOIN admin_user au 
    ON au.admin_user_id = aud.admin_user_id 
INNER JOIN admin_position_master apm 
    ON apm.position_id = aupm.position_id AND apm.record_status = 1
WHERE 
    au.status = 1 
    AND aupm.status = 1 
    AND apm.role_master_id IN (4, 5)
    and aud.official_name is not null
    /*and apm.position_id = 10140*/
    AND (aud.official_email IS NULL OR TRIM(aud.official_email) != ''); ---secy.prd-wb@bangla.gov.in --shovanhalder9@gmail.com
    
    

 -- back track --
select * from admin_user_position_mapping aupm where aupm.position_id = 10112;
select * from admin_user_details aud where aud.admin_user_id = 12527;  --9297929297   --10140

	-------------------------------------------------------------
	
select com.office_name, COUNT(1)  
FROM forwarded_latest_5_bh_mat as bh
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id)
group by com.office_name; -- other hod


select com.office_name, COUNT(1)  
FROM forwarded_latest_5_bh_mat as bh
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id) and com.office_id = 35
group by com.office_name; -- other hod


SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15)) and com.office_id = 35
group by com.office_name ; -- cmo


select com.office_name, COUNT(1)  
FROM forwarded_latest_5_bh_mat as bh
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id) and bh.emergency_flag = 'Y'
	and com.office_id = 35
group by com.office_name; -- other hod emergency


SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15)) and bh.emergency_flag = 'Y'
	and com.office_id = 35
group by com.office_name ; -- cmo emergency


select com.office_name, COUNT(1)  
FROM forwarded_latest_5_bh_mat as bh
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id) and bh.receipt_mode = 3
and com.office_id = 67
group by com.office_name; -- other hod grievance source HCM


SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15)) and bh.receipt_mode = 3
	and com.office_id = 67
group by com.office_name ; -- cmo grievance source HCM



-- testing purpose ---
SELECT com.office_name, bh.grievance_id 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15)) and bh.receipt_mode = 3
	and com.office_id = 67
group by com.office_name, bh.grievance_id  ;



select * from grievance_master gm limit 1;
select count(1) from grievance_master gm where gm.assigned_to_office_id = 2 and gm.receipt_mode = 3 and gm.status not in (14,15);
select * from grievance_master gm where gm.assigned_to_office_id = 2 and gm.receipt_mode = 3 and gm.status not in (14,15);
select * from grievance_master gm where gm.grievance_id = 5430793;



select
	com.office_name, COUNT(1)
	FROM forwarded_latest_5_bh_mat_2 as bh
	left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	    WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id) and bh.receipt_mode = 3
	    and com.office_id = 2
	group by com.office_name;


-----------------------------------------------------------


-----------------------------------------------------------------

--ALTER TABLE bulk_griev_status_mesg_assign
--RENAME COLUMN is_rabbit_traversed TO processed;

--ALTER TABLE bulk_griev_status_mesg_assign
--ADD COLUMN grievance_id BIGINT;

--ALTER TABLE bulk_griev_status_mesg_assign_office
--DROP COLUMN created_by_id,
--DROP COLUMN created_by_position,
--DROP COLUMN status;

--drop table mobile_sms;
--create table mobile_sms();
create table grievance_master_20250806_bkp();
create table grievance_lifecycle_sdc_timestamp_20250806_bkp();

--create table mobile_sms (
--	id varchar(50),
--	request_mobile_no varchar(250)
--);


select 
	gm.grievance_id, 
	gm.grievance_no, 
	ms.request_mobile_no, gm.status, gm.closure_reason_id/*, ccrm.closure_reason_name */
from grievance_master gm
inner join mobile_sms ms on ms.request_mobile_no = gm.pri_cont_no 
where s
--left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = gm.closure_reason_id
--order by ms.request_mobile_no
--inner join bulk_griev_status_mesg_assign bgsma on bgsma.request_mobile_no = gm.pri_cont_no 


select gm.grievance_no, gm.status, ms.request_mobile_no, gm.updated_on 
from grievance_master gm
inner join mobile_sms ms on ms.request_mobile_no = gm.pri_cont_no
where gm.updated_on 
order by gm.grievance_id asc;



SELECT 
	distinct 
    gm.grievance_no, 
    gm.grievance_id,
    gm.status, 
    ms.request_mobile_no, 
    gm.updated_on 
FROM grievance_master gm
INNER JOIN mobile_sms ms 
    ON ms.request_mobile_no = gm.pri_cont_no
--    WHERE gm.updated_on > '2025-07-09'
WHERE gm.updated_on BETWEEN '2025-07-10' AND '2025-07-14'
ORDER BY gm.grievance_id ASC;


select 
distinct 
	gm.grievance_id,
	gm.grievance_no,
	gm.status,
	ms.request_mobile_no,
	gm.grievence_close_date 
from grievance_master gm
inner join mobile_sms ms on ms.request_mobile_no = gm.pri_cont_no
WHERE gm.grievence_close_date BETWEEN '2025-07-10' AND '2025-07-14'
and gm.status = 15;


select
	ms.request_mobile_no,
	ms.grievance_id,
	ms.created_on,
	gm.grievance_id as actual_griev_id,
	gm.pri_cont_no,
	gm.grievence_close_date,
	gm.status,
	gm.closure_reason_id
from mobile_sms ms
inner join grievance_master gm on ms.request_mobile_no = gm.pri_cont_no
WHERE gm.grievence_close_date::timestamptz BETWEEN '2025-07-10 10:32:14.648 +0530'::timestamptz AND '2025-07-14 17:01:08.184 +0530'::timestamptz
and gm.status = 15;



SELECT
    gm.grievance_id AS actual_griev_id,
    ms.request_mobile_no,
    ms.grievance_id,
    ms.created_on,
    gm.pri_cont_no,
    gm.grievence_close_date,
    gm.status,
    gm.closure_reason_id,
    ms.requested_message 
FROM mobile_sms ms
INNER JOIN grievance_master gm ON ms.request_mobile_no = gm.pri_cont_no
WHERE gm.grievence_close_date::timestamptz BETWEEN '2025-07-10 10:32:14.648 +0530'::timestamptz AND '2025-07-14 17:01:08.184 +0530'::timestamptz
  AND gm.status = 15
  AND (
    ms.grievance_id IS NULL OR 
    ms.grievance_id::bigint = gm.grievance_id
)
 order by ms.grievance_id, gm.grievance_id, ms.created_on;


SELECT
    gm.grievance_id AS actual_griev_id,
    ms.request_mobile_no,
    ms.grievance_id,
    ms.created_on,
    gm.pri_cont_no,
    gm.grievence_close_date,
    gm.status,
    gm.closure_reason_id,
    ms.requested_message 
FROM mobile_sms ms
INNER JOIN grievance_master gm 
    ON ms.request_mobile_no = gm.pri_cont_no 
--   AND ms.created_on::timestamptz = gm.grievence_close_date
WHERE gm.grievence_close_date BETWEEN '2025-07-10 10:32:14.648 +0530'::timestamptz AND '2025-07-14 17:01:08.184 +0530'::timestamptz
  AND gm.status = 15
  AND (
    ms.grievance_id IS NULL OR 
    ms.grievance_id::bigint = gm.grievance_id
)
ORDER BY ms.grievance_id, gm.grievance_id, ms.created_on;

---- correct ----------------------------------------------
SELECT
    gm.grievance_id AS actual_griev_id,
    gm.grievance_no,
    ms.request_mobile_no,
    ms.grievance_id,
    ms.created_on,
    gm.pri_cont_no,
    gm.grievence_close_date,
    gm.status,
    gm.closure_reason_id,
    ccrm.closure_reason_name,
    ms.requested_message 
FROM mobile_sms ms
INNER JOIN grievance_master gm ON ms.request_mobile_no = gm.pri_cont_no
inner join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = gm.closure_reason_id 
   AND (
       ms.grievance_id IS NULL OR 
       ms.grievance_id::bigint = gm.grievance_id
   )
   AND ABS(EXTRACT(EPOCH FROM (ms.created_on::timestamptz - gm.grievence_close_date))) < 1
WHERE gm.grievence_close_date BETWEEN 
      '2025-07-11 13:12:27.402+05:30'::timestamptz AND '2025-07-14 16:44:58.406+05:30'::timestamptz
  AND gm.status = 15
ORDER BY ms.grievance_id, gm.grievance_id, ms.created_on;



SELECT DISTINCT ON (gm.grievance_id)
    gm.grievance_id AS actual_griev_id,
    gm.grievance_no,
    ms.request_mobile_no,
    ms.grievance_id,
    ms.created_on,
    gm.pri_cont_no,
    gl.assigned_on,
    gm.status,
    ms.requested_message 
FROM mobile_sms ms
INNER JOIN grievance_master gm 
    ON ms.request_mobile_no = gm.pri_cont_no
INNER JOIN grievance_lifecycle gl 
    ON gl.grievance_id = gm.grievance_id
   AND ABS(EXTRACT(EPOCH FROM (ms.created_on::timestamptz - gl.assigned_on))) < 1
WHERE gl.assigned_on BETWEEN 
        '2025-07-11 13:12:27.402+05:30'::timestamptz AND 
        '2025-07-14 16:44:58.406+05:30'::timestamptz
  AND gm.status = 3
ORDER BY gm.grievance_id, ABS(EXTRACT(EPOCH FROM (ms.created_on::timestamptz - gl.assigned_on)));


----------------------------------------------------------

select * from grievance_lifecycle gl where gl.grievance_id = 1271;
select gm.grievance_id, gm.grievance_no from grievance_master gm where gm.grievance_id in (3771025  
);
 
 SELECT DISTINCT
    gm.grievance_id AS actual_griev_id,
    ms.request_mobile_no,
    ms.grievance_id,
    ms.created_on,
    gm.pri_cont_no,
    gm.grievence_close_date,
    gm.status,
    gm.closure_reason_id
FROM mobile_sms ms
INNER JOIN grievance_master gm ON ms.grievance_id = gm.grievance_id::text and ms.request_mobile_no = gm.pri_cont_no
WHERE gm.grievence_close_date::timestamptz BETWEEN '2025-07-10 10:32:14.648 +0530'::timestamptz AND '2025-07-14 17:01:08.184 +0530'::timestamptz
  AND gm.status = 15;

 


SELECT 
  column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('grievance_master', 'mobile_sms');


select * from grievance_master gm where gm.grievance_id = 15254;
select * from grievance_master gm limit 10;


select * from grievance_master gm where gm.pri_cont_no in ('1111111111') 
and gm.grievence_close_date::timestamptz BETWEEN '2025-07-10 10:32:14.648 +0530'::timestamptz AND '2025-07-14 17:01:08.184 +0530'::timestamptz
and gm.status = 15;



select * from bulk_griev_status_mesg_assign bgsma ;



select * from bulk_griev_status_mesg_assign bgsma where (request_mobile_no = '"1111111111"'::jsonb) AND (status IN ('15')) ;






--CREATE TABLE "public"."bulk_griev_status_mesg_assign_office_demo_dump" (
--  "id" int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY (
--INCREMENT 1
--MINVALUE  1
--MAXVALUE 2147483647
--START 1
--CACHE 1
--),
--  "request_mobile_no" varchar(15) COLLATE "pg_catalog"."default",
--  "request_message" varchar(255) COLLATE "pg_catalog"."default",
--  "created_on" timestamptz(6),
--  "department_id" int8,
--  "department_name" varchar(100) COLLATE "pg_catalog"."default",
--  "designation" varchar(100) COLLATE "pg_catalog"."default",
--  "office_id" int8,
--  PRIMARY KEY ("id")
--)
--;

--ALTER TABLE bulk_griev_status_mesg_assign_office_demo_dump
--Add COLUMN position_id int8;


--ALTER TABLE bulk_griev_status_mesg_assign_office
----ADD COLUMN office_id int8;
--ADD COLUMN designation VARCHAR(100);


--ALTER TABLE bulk_griev_status_mesg_assign
--ALTER COLUMN request_message TYPE VARCHAR(255);


select gm.grievance_id from grievance_master gm where gm.grievance_no = 'CMO62694522';


--create table grievance();

select gm.grievance_id, gm.grievance_description 
from grievance_master gm 
inner join grievance g on g.grievance_id = gm.grievance_id;
--order by gm.grievance_id asc limit 100000 offset 0;


select 
    admin_user_details.official_name, 
    admin_user_details.official_phone, 
    admin_position_master.office_id, 
    com.office_name,
    aurm.role_master_name, 
    admin_position_master.position_id
    from admin_user_details
        inner join admin_user_position_mapping on admin_user_position_mapping.admin_user_id = admin_user_details.admin_user_id 
        inner join admin_position_master on admin_position_master.position_id = admin_user_position_mapping.position_id
        inner join admin_user_role_master aurm on aurm.role_master_id = admin_position_master.role_master_id
        inner join cmo_office_master com on com.office_id = admin_position_master.office_id
    where admin_position_master.office_id is not null and admin_position_master.role_master_id in (4,5) and 
    admin_user_position_mapping.status = 1  and admin_position_master.record_status= 1
    group by admin_user_details.official_name, admin_user_details.official_phone, admin_position_master.office_id, aurm.role_master_name, admin_position_master.position_id, com.office_name
order by admin_position_master.office_id asc;


SELECT 
    com.office_name, com.office_id, COUNT(1) 
    FROM forwarded_latest_3_bh_mat_2 as bh 
    left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
        WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15)) and bh.receipt_mode = 3
--        and com.office_id in (40)
    group by com.office_id, com.office_name;
   
   
SELECT 
    com.office_name, com.office_id, COUNT(1) 
    FROM cmo_office_master com 
    left join forwarded_latest_3_bh_mat_2 as bh on bh.assigned_to_office_id = com.office_id
        WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15)) and bh.receipt_mode = 3
        and com.office_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
    group by com.office_id, com.office_name
   order by com.office_id;
  

select * from cmo_parameter_master cpm;

select com.office_name, count(1)
from forwarded_latest_5_bh_mat as forwarded_latest_5_bh_mat
left join atr_latest_13_bh_mat atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
left join cmo_office_master com on com.office_id = forwarded_latest_5_bh_mat.assigned_to_office_id
where atr_latest_13_bh_mat.grievance_id is null 
group by com.office_name 




select id from cmo_bulk_status_update_closure_audit order by id desc limit 1;


select * from grievance_lifecycle gl where gl.grievance_id = 5734105;
select * from grievance_lifecycle gl where gl.grievance_id = 5734105 and gl.action_taken_note is not null and gl.atn_id is not null
order by gl.lifecycle_id desc ;



select count(1) from grievance_master gm ; -- 5689384
select count(1) from grievance_master_sdc_timestamp_issue_20250806_bkp gmstib  ; -- 12256


--delete from grievance_master gm where gm.grievance_id in (select grievance_id from grievance_master_sdc_timestamp_issue_20250806_bkp);  


---------------------------------------------------------------------------------------------------------------------------
--===================================== Emergency Grievance Query Check ========================================================
---------------------------------------------------------------------------------------------------------------------------

select * from grievance_master gm where gm.pri_cont_no = '9523486551';
select * from grievance_lifecycle gl where gl.grievance_id = 5716260 order by assigned_on ;
select * from grievance_master gm where gm.grievance_id in (5716260); --SSM4997751


select * from admin_user_details aud where aud.admin_user_id = 265;

select * from admin_position_master apm where apm.position_id = 265;
select * from admin_user_position_mapping aupm where aupm.position_id = 265;


select * from user_otp uo where uo.u_phone = '8001165556' order by created_on desc;



select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_office_id = 94 or gm.assigned_by_office_id = 94) and gm.status in (16) and gm.assigned_to_position = 265;


--select count(1) as griev_count
select *
from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'Y' and (gm.assigned_to_office_id = 94 or gm.assigned_by_office_id = 94) and gm.status in (16) and gm.assigned_to_position = 265;



select count(1) as griev_count
        from grievance_master gm
        left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
        left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
        where gm.grievance_id > 0  and gm.emergency_flag = 'Y' and (gm.assigned_to_office_id = 94) and gm.status in (3,4,5);

--select count(1) as griev_count
select *
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and (gm.assigned_to_office_id = 94) and gm.status in (11,13,6);



 select count(1) as griev_count
        from grievance_master gm
        left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
        left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
        where gm.grievance_id > 0  and gm.emergency_flag = 'Y' and (gm.assigned_to_office_id = 94) and gm.status in (6,11,13);

 
 
 select count(1) as griev_count
        from grievance_master gm
        left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
        left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
        where gm.grievance_id > 0  and gm.emergency_flag = 'Y' and (gm.assigned_to_office_id = 94) and gm.status in (3,4,5);

------------------------------------------------------------------------------------------------------------------------------
----------------------- ====================== CREDENTIALS ======================== -----------------------------------
       
 ------ trancate Table Query -----
-- TRUNCATE your_table_name RESTART IDENTITY;

       
-----------------------------------------
--- pg_dump -U cmo_admin_dev -h 15.206.132.5 -p 5444 -d migration_testing -f cmo_dev_bkp_dump.sql
 
 ------------------------------------------------------------------------------------------------------------------------
 
 
 ---------------- Vacuum and Reindexing of Database ----------------------------
--vacuum full grievance_master;
--reindex table greivance_master;
--
--
--vacuum full grievance_lifecyckle;
--reindex table grievance_lifecyckle
 
 -------------------------------------------------------------------------------------------------
 ----============================= Current Login User Count Check ================================
 --===============================================================================================
 
select * from user_otp;

select aud.official_name ,user_token.* 
from user_token 
left join admin_user_details aud on aud.admin_user_id = user_token.user_id
left join admin_user_position_mapping aupm on aupm.admin_user_id = aud.admin_user_id and aupm.status = 1
left join admin_position_master apm on apm.position_id = aupm.position_id 
where user_id is not null and user_token.updated_on::date = '2025-09-04' and expiry_time > now()  and apm.user_type = 1;



select aud.official_name ,user_token.* 
from user_token 
left join admin_user_details aud on aud.admin_user_id = user_token.user_id
left join admin_user_position_mapping aupm on aupm.admin_user_id = aud.admin_user_id and aupm.status = 1
left join admin_position_master apm on apm.position_id = aupm.position_id 
where /*user_id is not null and*/ user_token.updated_on::date = '2025-09-03' and expiry_time > now()  /*and apm.user_type = 3*/;



select aud.official_name ,user_token.* 
from user_token 
left join admin_user_details aud on aud.admin_user_id = user_token.user_id
where user_id is not null and user_token.updated_on::date = '2025-09-04' and expiry_time > now();



select aud.official_name ,user_token.* 
from user_token 
left join admin_user_details aud on aud.admin_user_id = user_token.user_id
where /*user_id is not null and*/ user_token.updated_on::date = '2025-09-08' --and expiry_time > now();


select aud.official_name ,user_token.* 
from user_token 
left join admin_user_details aud on aud.admin_user_id = user_token.user_id
where user_id is not null and user_token.updated_on::date = '2025-09-08' --and expiry_time > now();
 

-- Active User Count Details For 
 select * from citizen_login_activity cla order by cla.id desc limit 1;
 select * from user_token ut where ut.c_m_no = '8597510571';
 select * from admin_user_login_activity aula order by aula.la_id desc limit 2000;
 select * from admin_user_login_activity aula order by aula.la_id desc limit 1;
select * from user_token ut limit 1;
select * from cmo_parameter_master cpm ;
 
-------------------- ACTIVE USER LOGIN COUNT QUERY -------------------------
(
select
	-- apm.role_master_id,
    aurm.role_master_name as role_name,
	count(aula.la_id),
	'2025-09-08 11:00:00' as login_upto
from admin_user_login_activity aula
inner join admin_position_master apm on aula.position_id = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
where aula.login_time::date = current_timestamp::date and aula.login_time::timestamp <= '2025-09-08 11:00:00'::timestamp and aula.logout_time is Null
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc
)
union all
(
select
	'Citizen' as role_name,
	count(cla.id),
	'2025-09-08 11:00:00' as login_upto
from citizen_login_activity cla
where cla.login_time::date = current_timestamp::date and cla.login_time::timestamp <= '2025-09-08 11:00:00'::timestamp and cla.logout_time is Null
)
------------------------------------------------------------------
 
 ---- Total User still Logged in Query  ----
SELECT COUNT(*) AS total_logged_in_users_today
FROM user_token ut
WHERE DATE(ut.updated_on) = CURRENT_DATE;
 
---===================================================================================================================================================== 
 
 SELECT * FROM get_login_activity('2025-09-08 17:00:00');
 

(
select
	-- apm.role_master_id,
    aurm.role_master_name as role_name,
	count(aula.la_id),
	'2025-09-08 11:00:00' as login_upto
from admin_user_login_activity aula
inner join admin_position_master apm on aula.position_id = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
left join user_token ut on ut.user_id = aula.admin_user_id 
where aula.login_time::date = current_timestamp::date and aula.login_time::timestamp <= '2025-09-08 11:00:00'::timestamp and aula.logout_time is null and ut.expiry_time::timestamp >= '2025-09-08 11:00:00'::timestamp and ut.user_type = 1
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc
)
union all
(
select
	'Citizen' as role_name,
	count(cla.id),
	'2025-09-08 11:00:00' as login_upto
from citizen_login_activity cla
left join user_token ut on ut.c_m_no  = cla.m_no  
where cla.login_time::date = current_timestamp::date and cla.login_time::timestamp <= '2025-09-08 11:00:00'::timestamp and cla.logout_time is null and ut.expiry_time::timestamp >= '2025-09-08 11:00:00'::timestamp
)




SELECT
    aurm.role_master_name AS role_name,
    COUNT(aula.la_id) AS login_count,
    '2025-09-08 11:00:00'::timestamp AS login_upto
FROM admin_user_login_activity aula
INNER JOIN admin_position_master apm 
    ON aula.position_id = apm.position_id
INNER JOIN admin_user_role_master aurm 
    ON aurm.role_master_id = apm.role_master_id 
   AND aurm.role_master_id IN (1,2,3,4,5,6,7,8)
LEFT JOIN user_token ut ON ut.user_id = aula.admin_user_id AND ut.user_type = 1
WHERE aula.login_time::date = current_timestamp::date
  AND aula.login_time <= '2025-09-08 11:00:00'::timestamp
  AND aula.logout_time IS NOT NULL
  AND (
        ut.expiry_time >= '2025-09-08 11:00:00'::timestamp
        OR ut.expiry_time <= now()
      )
GROUP BY aurm.role_master_name, aurm.role_master_id
ORDER BY aurm.role_master_id ASC;





------ PERFECT ----
select
	-- apm.role_master_id,
    aurm.role_master_name as role_name,
--	count(aula.la_id),
	count(distinct aula.position_id),
	'2025-09-08 11:00:00' as login_upto
from admin_user_login_activity aula
inner join admin_position_master apm on aula.position_id = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
where aula.login_time::date = current_timestamp::date and aula.logout_time is null and aula.login_time::timestamp <= '2025-09-08 11:00:00'::timestamp
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc


select
	-- apm.role_master_id,
    aurm.role_master_name as role_name,
	count(aula.la_id),
	'2025-09-08 11:00:00' as login_upto
from admin_user_login_activity aula
inner join admin_position_master apm on aula.position_id = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
where aula.login_time::date = current_timestamp::date and aula.logout_time is null AND aula.login_time::timestamp BETWEEN '2025-09-08 15:00:00'::timestamp AND '2025-09-08 17:00:00'::timestamp
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc




SELECT
    apm.position_id,
    aurm.role_master_name AS role_name,
    COUNT(aula.la_id) AS login_count,
    '2025-09-08 11:00:00'::timestamp AS login_upto
FROM admin_user_login_activity aula
INNER JOIN admin_position_master apm 
    ON aula.position_id = apm.position_id
INNER JOIN admin_user_role_master aurm 
    ON aurm.role_master_id = apm.role_master_id 
   AND aurm.role_master_id IN (1,2,3,4,5,6,7,8)
WHERE aula.login_time::date = current_timestamp::date
  AND aula.logout_time IS NULL
  AND aula.login_time <= '2025-09-08 11:00:00'::timestamp
GROUP BY apm.position_id, aurm.role_master_name, aurm.role_master_id
ORDER BY aurm.role_master_id ASC, apm.position_id ASC;


select
	-- apm.role_master_id,
    aurm.role_master_name as role_name,
	count(aula.la_id),
	'2025-09-08 11:00:00' as login_upto
from admin_user_login_activity aula
inner join admin_position_master apm on aula.position_id = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
left join user_token ut on ut.user_id = aula.admin_user_id 
where aula.login_time::date = current_timestamp::date and aula.login_time::timestamp <= '2025-09-08 11:00:00'::timestamp and aula.logout_time is null and ut.expiry_time::timestamp >= '2025-09-08 11:00:00'::timestamp and ut.user_type = 1
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc

select
	-- apm.role_master_id,
    aurm.role_master_name as role_name,
	count(aula.la_id),
	'2025-09-08 11:00:00' as login_upto
from admin_user_login_activity aula
inner join admin_position_master apm on aula.position_id = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
left join user_token ut on ut.user_id = aula.admin_user_id 
where aula.login_time::date = current_timestamp::date 
--and ut.expiry_time::timestamp between '2025-09-08 11:00:00'::timestamp and '2025-09-08 12:59:00'::timestamp 
and aula.login_time::timestamp between '2025-09-08 11:00:00'::timestamp and '2025-09-08 12:59:00'::timestamp 
/*and aula.logout_time is not null*/ /*and ut.expiry_time::timestamp = '2025-09-08 11:00:00'::timestamp*/ and ut.user_type = 1
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc


select *
from admin_user_login_activity aula
inner join admin_position_master apm on aula.position_id = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
left join user_token ut on ut.user_id = aula.admin_user_id 
where aula.login_time::date = current_timestamp::date 
and (ut.expiry_time::timestamp between '2025-09-08 11:00:00'::timestamp and '2025-09-08 12:59:00'::timestamp 
or aula.login_time::timestamp between '2025-09-08 11:00:00'::timestamp and '2025-09-08 12:59:00'::timestamp )
/*and aula.logout_time is not null*/ /*and ut.expiry_time::timestamp = '2025-09-08 11:00:00'::timestamp*/ and ut.user_type = 1
--group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc



select 
	aurm.role_master_name as role_name,
	count(1),
	'2025-09-02 11:00:00' as login_upto
from user_token 
inner join admin_position_master apm on user_token.user_id  = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
where user_token.user_type = 1 and user_token.updated_on::date = '2025-09-02' 
and (user_token.updated_on between '2025-09-02 00:00:00' and '2025-09-02 00:59:00' or user_token.expiry_time between '2025-09-02 00:00:00' and '2025-09-02 00:59:00') 
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc;



select 
	aurm.role_master_name as role_name,
	count(user_token.token_id) as active_login,
	'2025-09-08 11:00:00' as login_upto
from user_token 
inner join admin_position_master apm on user_token.user_id  = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
where user_token.user_type = 1 and (user_token.updated_on between '2025-09-08 11:00:00' and '2025-09-08 12:59:00' or user_token.expiry_time > '2025-09-08 11:00:00' )
--where user_token.user_type = 1 and (user_token.updated_on between '2025-09-08 11:00:00' and '2025-09-08 12:59:00' or user_token.expiry_time > '2025-09-08 11:00:00' )
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc;


----- PERFECT -----
select aurm.role_master_name as role_name,
count(user_token.token_id) as active_login, 
'2025-09-08 17:00:00' as login_upto 
from user_token 
inner join admin_position_master apm on user_token.user_id = apm.position_id 
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8) 
--where user_token.updated_on::date = '2025-09-08' and user_token.user_type = 1 and (user_token.updated_on between '2025-09-08 15:00:00' and '2025-09-08 16:59:00' or user_token.expiry_time > '2025-09-08 15:00:00' ) 
where user_token.updated_on::date = '2025-09-08' and user_token.user_type = 1 and (user_token.updated_on > '2025-09-08 17:00:00' or user_token.expiry_time > '2025-09-08 17:00:00' ) 
group by aurm.role_master_name, aurm.role_master_id 
order by aurm.role_master_id asc;

-------------------------------------------------


--INSERT INTO cmo_ssm_push_details(push_date, status_code, request, from_row_no, to_row_no, actual_push_date) VALUES (current_date, 404,'{"token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImNtb0B3Yi5nb3YuaW4iLCJwYXNzd29yZCI6IjdJZ3BMQlc5YzhANSJ9.uT8d-px2vEIw3n39X9GIBDq-8Kt_LSA0_VRbeBpmvf5z-b0E3ZmbXKHAYM-LCe6zA4UpLnHcK-eVNHE-tDKmUw",
-- "No_of_Recs": 5000, "data":[{"Griev_ID": "SSM2933069", "Closure_Reason_Code": "002", "Action_Remarks": "Benefit/Service Provided", "Sender_Office_Name": "Chief Ministers Office", "Sender_Details": "Senior Software Developer", "Receiver_Office_Name": "NA", "Receiver_Details": "NA", "Status": "Disposed", "Action_DateTime": "2025-08-27 00:00:00", "Document_Link": "NA", 
--"Action_taken_Date": "2025-08-27 00:34:04", "Action_taken": "NA", "Action_Desc": "Benefit/Service Provided", "Action_taken_by": "CMO Administrator, Senior Software Developer,
-- Chief Ministers Office", "ATN_Reason_Desc": "NA", "griev_trans_no": 15, "Action_Proposed": "NA", "Contact_Date": null, "Tentative_Dat




----====================== SMS BULK STATUS UPDATE QUERY =========================
select * from bulk_griev_status_mesg_assign where request_mobile_no::bigint = 8967050522; ---6295603699
select * from bulk_griev_status_mesg_assign bgsa order by bgsa.id desc limit 200;




select * from cmo_ssm_push_details cspd where cspd.is_reprocessed = true order by cspd.cmo_ssm_push_details_id desc limit 3;


select * from bulk_griev_status_mesg_assign bgsa order by bgsa.id desc limit 45000;


select * from bulk_griev_status_mesg_assign bgsa 
where bgsa.request_mobile_no is NULL
order by bgsa.id limit 500;

-- update bulk_griev_status_mesg_assign
-- set processed_mobile_no = request_mobile_no 
-- where processed = TRUE


select bgsa.*, gm.grievance_id, gm.pri_cont_no 
from bulk_griev_status_mesg_assign bgsa 
inner join grievance_master gm on gm.grievance_id = bgsa.grievance_id
where bgsa.request_mobile_no is NULL
order by bgsa.id limit 500;



-- update bulk_griev_status_mesg_assign as abb
-- set request_mobile_no = gm.pri_cont_no
-- from grievance_master gm 
-- where gm.grievance_id = abb.grievance_id and abb.published = TRUE


select count(*) from bulk_griev_status_mesg_assign;
