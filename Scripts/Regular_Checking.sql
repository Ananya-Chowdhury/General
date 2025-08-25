
---- SSM PULL CHECK ----
SELECT * 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-08-18' 
and status = 'S'
ORDER by batch_id desc; -- cbrd.batch_id; --4307 (total data 3433 in 5 status = 2823 data) --22.05.24

SELECT * 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-08-07'
ORDER by data_count desc; 


select * from cmo_emp_batch_run_details cebrd;


------ SSM PUSH DATA CHECK ------
select 
	cspd.push_date,
	cspd.actual_push_date, 
	cspd.status_code, 
	cspd.status,
	cspd.from_row_no,
	cspd.to_row_no,
	cspd.data_count,
	cspd.response
from cmo_ssm_push_details cspd 
order by cmo_ssm_push_details_id desc limit 100;


----------------------- SSM APi PULL CHecK IF Any ID NOT Processed -------------------------------
select * from cmo_batch_time_master c;

select
	a.*
from 
	(select 
		distinct(cbrd.batch_date::date),
		count(cbrd.batch_id) as batchs,
		ARRAY_AGG(cbrd.batch_id)
	from cmo_batch_run_details cbrd
	left join cmo_batch_time_master cbtm on cbtm.batch_time_master_id = cbrd.batch_id
	where status = 'S'
	group by cbrd.batch_date::date
	order by cbrd.batch_date desc) a
where a.batchs < 96;

------------------------ Update Final Query ------------------------------
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
------------------------------------------------------------------------------



------------------------- Update New Query ------------------- 
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
    ) || ']' AS missing_batch_ids
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
WHERE a.batchs < 96;
----------------------------------------------------------------

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
    ) || ']' AS missing_batch_ids
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
WHERE a.batchs <= 96;

--------------------------------------------------------------------


select 
	cbrd.cmo_batch_run_details_id,cbrd.batch_date,cbrd.batch_id,cbrd.from_time,
	cbrd.to_time,cbrd.status,cbrd.data_count, cbrd.error, cbrd.processed
from cmo_batch_run_details cbrd
order by cbrd.batch_id desc;


select 
	cbrd.cmo_batch_run_details_id,cbrd.batch_date,cbrd.batch_id,cbrd.from_time,
	cbrd.to_time,cbrd.status,cbrd.data_count, cbrd.error, cbrd.processed
from cmo_batch_run_details cbrd
where cbrd.batch_date::date = '2025-08-07'::date
order by cbrd.batch_id desc;

-- For CMO Batch Pull Data Count Check
-- ARRAY_AGG(cbrd.batch_id) for list of batch detail ids
-- distinct(cbrd.batch_date::date), for perticular distinct date where the process odne
-- Total Number of Batch = 96 for With Success Status " status = 'S'
-- count(cbrd.batch_id) as batchs, -------- >>>> total number of  batches enters
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

--- Indivitual SSM Pull Data check ---
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 24874 /*and status = 5*/;
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 11606 and status not in (5,2);
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 4894 and status != 2;

select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id in (select cbrd.cmo_batch_run_details_id
from cmo_batch_run_details cbrd where batch_date = '2024-12-05' /*order b y batch_id*/);
select * from public.cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM4385683';
select * from public.cmo_batch_run_details cbrd where cbrd.cmo_batch_run_details_id = '6009';
select * from public.grievance_master gm where grievance_no in ( select griev_id from cmo_batch_grievance_line_item where cmo_batch_run_details_id = 12549 );

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--- SSM Push Details ------ 
select * from cmo_ssm_push_details cspd;
select cspd.cmo_ssm_push_details_id, cspd.status,cspd.data_count,response from cmo_ssm_push_details cspd where cspd.status = 'F';
select * from public.cmo_ssm_api_push_data_count();
select * from master_district_block_grv where atr;
select * from cmo_ssm_api_push_data(50,0);
select * from cmo_ssm_push_details cspd order by cmo_ssm_push_details_id desc limit 1;


--UPDATE public.cmo_ssm_push_details SET response = replace(response, '''', '"');
--UPDATE public.cmo_ssm_push_details SET response = replace(response, 'None,', '"NA",');
--UPDATE public.cmo_ssm_push_details SET request = replace(request, '''', '"');
--UPDATE public.cmo_ssm_push_details SET request = replace(request, 'None,', '"NA",');
--UPDATE public.cmo_ssm_push_details SET request = replace(request, 'Chief Minister"s Office', 'Chief Minister''s Office');
--ALTER TABLE public.cmo_ssm_push_details ALTER COLUMN request TYPE JSONB USING request::JSONB;
--ALTER TABLE public.cmo_ssm_push_details ALTER COLUMN response TYPE JSONB USING response::JSONB;
--ALTER TABLE public.cmo_ssm_push_details ADD column is_reprocessed TYPE boolean DEFAULT FALSE;


---------------- Grievance Query ---------------
select * from public.grievance_master gm where grievance_no in ('SSM4837610');
select * from public.grievance_master gm where gm.grievance_id = 5235053;
select * from public.grievance_lifecycle gl where gl.grievance_id = 5631176;
select * from public.grievance_master gm where gm.grievance_no = 'CMO18754331';
select * from public.admin_position_master apm where apm.position_id = 10140;               -- assigned_to_postion = position_id      admin_postion_master
select * from public.admin_user_position_mapping aupm where aupm.position_id = 11360;       --12745 (6) --10140 --12708 (7) --
select * from public.admin_user au where au.admin_user_id = 10140;
select * from public.user_token ut where ut.user_id = 105 order by ut.token_id desc;
select * from public.cmo_closure_reason_master ccrm ;
select * from public.grievance_master gm where gm.pri_cont_no = '8101859077';
select * from public.grievance_lifecycle gl where gl.grievance_id = 5235362;
select count(1) from public.bulk_griev_status_mesg_assign bgsma;
select * from grievance_master gm where gm.doc_updated ='Y' limit 10;
select * from document_master dm where dm.doc_id = 106657; --100317


----------- Admin Position Fatch Query ----------
select * from cmo_office_master com; --35 --53 --68
select * from cmo_sub_office_master csom where csom.office_id = 53;
select * from admin_user au ;
select * from admin_position_master apm where apm.sub_office_id = 3101;
select * from admin_position_master apm where apm.position_id = 398;
select * from admin_position_master apm ;
select * from admin_user_position_mapping aupm ;


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


select * from public.grievance_master gm where grievance_no = 'SSM4524574'; 
select * from public.cmo_batch_grievance_line_item cbgli where griev_id = 'SSM2962283';
select * from public.grievance_lifecycle gl where gl.grievance_id = 3882162 order by assigned_on ;
select * from public.admin_user_details aud where admin_user_id = 3186; -- Md. Ashif Ikbal

SELECT * FROM public.bulk_griev_status_assign bgsa WHERE 4216861 = ANY (SELECT jsonb_array_elements_text(bgsa.request_grievance_ids)::int);

select * from  grievance_master gm where grievance_id in (69220, 126090, 136420, 137268, 140076, 140437, 137268, 138197, 139500, 137587, 136093, 136420, 62928, 66639, 
18080, 66638, 110885, 117297, 118741, 121266, 121526, 123284, 132995, 134246);


select * from public.cmo_domain_lookup_master cdlm where cdlm.domain_type = 'received_at_location';
select * from public.cmo_grivence_receive_mode_master cgrmm;
select * from public.admin_position_master apm where apm.position_id = 12745;
select * from public.cmo_office_master com; where com.office_id = 80;
select * from public.admin_user_position_mapping aupm where aupm.position_id = 81; --3186
select * from public.user_otp uo where uo.u_phone = '9163479418' order by created_on desc; --["9999999900","9999999999","8101859077","8918939197","8777729301","9775761810","7719357638","7001322965"]
select * from public.user_otp uo limit 1;
select * from public.admin_user au where admin_user_id = 3580;
select * from public.admin_user_details aud where aud.admin_user_id = 3580;
select * from public.admin_user_details aud where aud.official_name = 'Smt. Sima Halder';
select * from public.admin_user au limit 1;
select * from public.cmo_parameter_master cpm;
select * from public.cmo_domain_lookup_master cdlm ;
select * from public.admin_position_master apm where apm.record_status = 1 and apm.role_master_id = 9;
select * from public.admin_user_position_mapping aupm where aupm.status = 1 and aupm.position_id = 1;
select * from public.grievance_master gm where gm.status = 15;
select * from public.grievance_lifecycle gl where gl.grievance_id ='2670392';
select * from public.cmo_office_master com where office_name = 'Backward Classes Welfare Department'; --4
select * from public.cmo_police_station_master cpsm where cpsm.ps_id in (165,183);
select * from public.cmo_sub_districts_master csdm where csdm.sub_district_id in (21,60,26,35);
select * from public.grievance_master gm where gm.grievance_id = 2670392;
select * from public.grievance_lifecycle gl where gl.lifecycle_id = 8186648;  --2670392
 

select * from public.cmo_action_taken_note_master catnm;
select * from public.atn_closure_reason_mapping acrm;
select * from public.cmo_closure_reason_master ccrm;


["9999999900","9999999999","8918939197","8777729301","9775761810","7719357638","7001322965","9297929297",
"6292222444","8334822522","9874263537","9432331563","9434495405","9559000099","9874263537"]


-- Get OTP Query --  
SELECT * 
FROM public.user_otp uo  
WHERE uo.u_phone = '9297929297'
ORDER BY created_on desc limit 5;

SELECT * 
FROM public.user_otp uo  
WHERE uo.u_phone = '9999999999'
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
select * from public.admin_user au where au.u_phone = '9999999999'; --8101859077
select * from public.admin_user_details aud where aud.official_phone = '9999999999'; --9903821521
select * from public.cmo_parameter_master cpm ;
select * from public.grievance_master gm where gm.pri_cont_no = '9163479418';
select * from public.grievance_master gm2 where gm2.grievance_no = 'CMO75581311';
select * from public.cmo_closure_reason_master ccrm;



-- Grievance Lifecycle & Master Count trail Query --
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06';
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date BETWEEN '2024-11-14 00:00:00' AND '2024-11-14 17:00:00';
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06' and gl.grievance_status = 1; -- 1852
SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06' and gl.grievance_status != 1; -- 11826  = 13,678


SELECT COUNT(DISTINCT gm.grievance_id) FROM grievance_master gm WHERE gm.updated_on::date = '2025-08-06'; -- 11826
SELECT COUNT(DISTINCT gm.grievance_id) FROM grievance_master gm WHERE gm.created_on::date = '2025-08-06'; -- 1852
SELECT COUNT(1) FROM grievance_master gm WHERE gm.updated_on::date = '2025-08-06';

SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
WHERE gl.created_on::date = '2025-08-06';

SELECT distinct gm.* FROM grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
WHERE gl.created_on::date = '2025-08-06';

SELECT COUNT(DISTINCT gl.grievance_id) FROM grievance_lifecycle gl WHERE gl.created_on BETWEEN '2024-11-14 00:00:00' AND '2024-11-14 17:00:00';
SELECT COUNT(1) FROM grievance_lifecycle gl WHERE gl.created_on::date = '2025-08-06';
select count(1) from grievance_lifecycle gl where gl.created_on between '2024-11-14 00:00:00' AND '2024-11-14 17:00:00'; 
select count(1) from grievance_master gm where gm.created_on between '2024-11-14 00:00:00' AND '2024-11-14 17:00:00';


select count(distinct gl.grievance_id) from grievance_lifecycle gl where gl.grievance_id in (select bp.grievance_id from grievance_master_sdc_timestamp_issue_20250806_bkp bp);  --12256
select distinct gl.* from grievance_lifecycle gl where gl.grievance_id in (select bp.grievance_id from grievance_master_sdc_timestamp_issue_20250806_bkp bp);
select count(distinct gl.*) from grievance_lifecycle gl where gl.grievance_id in (select bp.grievance_id from grievance_master_sdc_timestamp_issue_20250806_bkp bp);


SELECT distinct gl.* FROM grievance_lifecycle gl 
inner join grievance_master_sdc_timestamp_issue_20250806_bkp gm on gm.grievance_id = gl.grievance_id order by gl.grievance_id asc;

SELECT count(distinct gl.lifecycle_id) FROM grievance_lifecycle gl 
inner join grievance_master_sdc_timestamp_issue_20250806_bkp gm on gm.grievance_id = gl.grievance_id;  --122250

--create table grievance_lifecycle_sdc_timestamp_20250806_bkp;

select count(1) from grievance_lifecycle_sdc_timestamp_20250806_bkp;
---------------------------------------------------------------------------------------------------

-- Connection Count ---
select query, count(1) from pg_stat_activity group by query order by count desc;
select count(1) from pg_stat_activity;
select * from pg_stat_activity;

--- Connection Lock Checking -----
select * from pg_locks;

select * from pg_stat_activity;

-- Proccesed pid query identified --
select pg_stat_activity.query,
count(1) AS query_count
from pg_stat_activity
inner join pg_locks on pg_locks.pid = pg_stat_activity.pid 
group by 1 ;

-- Proccesed pid query identified more than 1000 -- 
SELECT 
    pg_stat_activity.query, 
    COUNT(1) AS query_count
FROM pg_stat_activity
INNER JOIN pg_locks ON pg_locks.pid = pg_stat_activity.pid
GROUP BY pg_stat_activity.query
HAVING 
    COUNT(1) >= 1000;
   

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

------- Find PID Number From Stuck Query ------
select * from pg_stat_activity where query = 'SELECT * FROM "hod_all_weekly_modified_othins"()';
select * from pg_stat_activity where query = 'SELECT * FROM "hcm_mis"()';

--------- Cancel PID Locks ---------
select * from pg_cancel_backend(233362);

 -------- Cancel pid Locks ------
select * from pg_catalog.pg_cancel_backend(1412570);
   
------  kill function query ----------
SELECT * FROM manage_top_query(True);


------------ Table Lock Checked Query ----------
select a.pid, a.usename, a.application_name, a.client_addr, a.state, l.mode, l.granted, n.nspname, c.relname, a.query
	from pg_locks l
	join pg_stat_activity a ON a.pid = l.pid
	join pg_class c ON c.oid = l.relation
	join pg_namespace n ON n.oid = c.relnamespace;



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

-------------------------------------------------------------------------------------------------------


--------------- DATA CHECK -----------------
select max(gl.assigned_on) from grievance_lifecycle gl  
where gl.grievance_status = 4 and gl.assigned_by_office_id != gl.assigned_to_office_id;    -- 2025.02.10   --2025-07-23  14:28:00.229 +0530


---- Atr return for review to HOSO but not Assigned to HOSO ---
select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
       from grievance_lifecycle gl where gl.grievance_status = 12
       and assigned_to_office_cat != 3
       order by gl.assigned_on asc ;
--      limit 15 offset 0;

      
---- Atr return for review to HOD but not Assigned to HOD ---
select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
       from grievance_lifecycle gl where gl.grievance_status = 6
       and assigned_to_office_cat != 2
       order by gl.assigned_on asc ;    
      
      
---- Atr return for review to SO but not Assigned to SO ---
select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
       from grievance_lifecycle gl where gl.grievance_status = 10
       and assigned_to_office_cat != 3 and assigned_by_office_cat = 3
       order by gl.assigned_on asc ;      
      
      


select * from grievance_lifecycle gl where grievance_id = 5734105;
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

----- SSM Push ------
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


-------------------- Bulk Closure chcek --------------------------
select count(1) from grievance_master gm
    where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10; --40392  
    

select count(1) from grievance_master gm
    where gm.status = 14 and gm.atn_id = 5;   ---atn_id = 5 not eligible to get benift
  
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




select
	gm.grievance_id as griev_id,
    gm.grievance_no as griev_no,
    case
        when gm.atn_id is not null then catnm.atn_desc
        else 'NA'
    end as "Action_Taken",
    case 
        when gm.action_taken_note is not null then gm.action_taken_note
        else 'NA'
    end as "Action_Taken_Desc",
    case 
        when gm.atn_id is not null then catnrm.atn_reason_master_desc
        else 'NA'
    end as "ATN_Reason_Desc",
    gm.status as Status_Code,
    cdlm.domain_value as Status_Name,
	gm.grievance_generate_date::date as "Grievance_Lodge_Date",           -- New Required Field Added --
	gm.applicant_name as "Complainant_Name",
	gm.pri_cont_no as "Phone_no",
	case
		when gm.applicant_address is not null then gm.applicant_address
		else 'NA'
	end as "Address",
	case 
		when gm.district_id is not null then cdm3.district_name 
		else 'NA'
	end as "District",
	case 
		when gm.block_id is not null then cbm.block_name
		when gm.municipality_id is not null then cmm.municipality_name
		else 'NA'
	end as "Block_Municipality",
	case
		when gm.gp_id is not null then cgpm.gp_name
		when gm.ward_id is not null then cwm.ward_name
		else 'NA'
	end as "GP_Ward",
	case
		when gm.police_station_id is not null then cpsm.ps_name
		else 'NA'
	end as "Police_Station",
	case
		when gm.received_at is not null then cdlm1.domain_value
		else 'NA'
	end as "Received_at",
	case
		when gm.emergency_flag = 'Y' then 'Yes'
		else 'No'
	end as "Whether_Emergency",
	case
		when gm.grievance_category is not null then cgcm.grievance_category_desc
		else 'NA'
	end as "Grievance_category",
	case
		when gm.grievance_description is not null then gm.grievance_description
		else 'NA'
	end as "Grievance_Description",
	case 
		when gm.status in (3,4,5,6,11,13) and gm.assigned_to_office_id is not null then com.office_name
		else 'NA'
	end as "HOD"
from grievance_master gm 
left join cmo_closure_reason_master ccrm on gm.closure_reason_id = ccrm.closure_reason_id
left join cmo_action_taken_note_master catnm on gm.atn_id = catnm.atn_id
left join cmo_action_taken_note_reason_master catnrm on catnrm.atn_reason_master_id = gm.atn_id
left join admin_user_details aud2 on gm.assigned_to_id = aud2.admin_user_id
left join cmo_domain_lookup_master cdlm on gm.status = cdlm.domain_code and cdlm.domain_type = 'grievance_status'
left join cmo_domain_lookup_master cdlm1 on gm.received_at = cdlm1.domain_code and cdlm1.domain_type = 'received_at_location'
left join cmo_districts_master cdm3 on cdm3.district_id = gm.district_id
left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gm.gp_id
left join cmo_wards_master cwm on cwm.ward_id = gm.ward_id
left join cmo_police_station_master cpsm on cpsm.ps_id = gm.police_station_id
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
left join cmo_office_master com on com.office_id = gm.assigned_by_office_id 
left join cmo_office_master com3 on com3.office_id = gm.atr_submit_by_lastest_office_id
where gm.atn_id in (12,9) and gm.grievance_category = 133 and gm.status in (3,4,5,6,11,13);
	




select * from cmo_sub_office_master csom where csom.suboffice_id = 1462;
select * from cmo_office_master com where com.office_id = 23;





--1) office_ id = 51, sub_office_id = 5740 -- 937 HOSO
--2) office_ id = 117, sub_office_id = 5389
--3) office_ id = 42, sub_office_id = 2610

--grievance_id = 834, 993, 1627, 1632, 1825



select * from cmo_sub_office_master where suboffice_id = 5740;


select 
	gl.assigned_by_office_cat, gl.assigned_to_office_cat, apm.role_master_id as by_role, apm2.role_master_id as to_role,
	apm.sub_office_id as by_sub, apm2.sub_office_id as to_sub, gl.assigned_by_office_id , gl.assigned_to_office_id ,
	gl.grievance_status , gl.assigned_on , gl.lifecycle_id , gl.*, apm.record_status, apm2.record_status 
from grievance_lifecycle gl
left join admin_position_master apm on apm.position_id = gl.assigned_by_position 
left join admin_position_master apm2 on apm2.position_id = gl.assigned_to_position 
where grievance_id = 834 order by assigned_on ;


select * from admin_position_master apm where sub_office_id = 5740;

select * from admin_position_master apm where sub_office_id = 5740 and role_master_id = 7-- and record_status = 2;





with
		grievance_trail_data as (
			select
				gl.lifecycle_id,
				gl.grievance_id,
				gl.grievance_status,
				gl.assigned_by_position,
				gl.assigned_by_id,
				gl.assigned_to_position,
				gl.assigned_to_id,
	            gl.current_atr_date,
	            gl.created_on,
	            gl.assigned_on,
	            gl.atn_id,
	            gl.action_taken_note,
	            gl.atn_reason_master_id,
	            gl.action_proposed,
	            gl.contact_date,
	            gl.tentative_date,
	            gl.prev_recv_date,
	            gl.prev_atr_date,
	            gl.closure_reason_id,
	            gl.assign_comment
			from grievance_lifecycle gl
			where gl.grievance_status != 1 
				and gl.assigned_on::DATE = effective_date::DATE
				/*and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE*/
				/* and gl.assigned_on::DATE = '2025-04-20'::DATE */
		),
		grievance_master_data as (
			select
				gm.grievance_no as griev_id_no,
			    case 
			        when gm.usb_unique_id is null then gm.grievance_no
			        else gm.usb_unique_id
			    end as "USB_Unique_ID",
			    aud1.official_code as "Sender_Official_Code",
			    aud2.official_code as "Receiver_Official_Code",
			    /*case
			        when LC.closure_reason_id  is not null then ccrm.closure_reason_code
			        else 'NA'
			    end as "Closure_Reason_Code",*/
			    case
			        when gm.closure_reason_id  is not null then ccrm.closure_reason_code
			        else 'NA'
			    end as "Closure_Reason_Code",
			    case 
			        when LC.assign_comment is not null then LC.assign_comment
			        else 'NA'
			    end as "Incoming_Remarks",
			    case
			        when gm.status = 15 then 'C'
			        else 'F'
			    end as "Griev_Active_Status",
			    'NA' as attachments,
			    case
				    when LC.current_atr_date is null then
		    			case 
			    			when LC.grievance_status in (9,11,13,14,15) then LC.assigned_on
		    				else null
		    			end
		    		else LC.current_atr_date
				end as "Action_Taken_Date",
			    case
			        when LC.atn_id is not null then catnm.atn_desc
			        else 'NA'
			    end as "Action_Taken",
			    case 
			        when LC.action_taken_note is not null then LC.action_taken_note
			        else 'NA'
			    end as "Action_Taken_Desc",
			    case
			        when LC.assigned_by_id is not null 
			        then concat(
			            coalesce(aud1.official_name,''), ', ',
			            coalesce(cdm1.designation_name,''), ', ',
			            coalesce(case when apm1.role_master_id in (7,8) then csom1.suboffice_name else com1.office_name end,'')
	                )
			        else 'NA'
			    end as "Action_Taken_By",
			    case 
			        when LC.atn_reason_master_id is not null then catnrm.atn_reason_master_desc
			        else 'NA'
			    end as "ATN_Reason_Desc",
	            LC.grievance_status as griev_trans_no,
			    LC.action_proposed as "Action_Proposed",
			    LC.contact_date as "Contact_Date",
			    LC.tentative_date as "Tentative_Date",
			    LC.prev_recv_date as "Previous_Receipt_Date",
			    LC.prev_atr_date as "Previous_ATR_Date",
			    case
			        when LC.assigned_by_position is not null then case when apm1.role_master_id in (7,8) then csom1.suboffice_name else com1.office_name end
			        else 'NA'
			    end as "Sender_Office_Name",
			    case
			        when LC.assigned_by_position is not null then cdm1.designation_name
			        else 'NA'
			    end as "Sender_Details",
			    case
			        when LC.assigned_to_id is not null then case when apm2.role_master_id in (7,8) then csom2.suboffice_name else com2.office_name end
			        else 'NA'
			    end as "Receiver_Office_Name",
			    case
			        when LC.assigned_to_position is not null then cdm2.designation_name
			        else 'NA'
			    end as "Receiver_Details",
			    case 
			    	when gm.status = 15 then 'Disposed'
			        else 'Pending'
			    end as "Status",
			    cdlm.domain_value as griev_trans_no_description,
				gm.grievance_generate_date as "Grievance_Lodge_Date",           -- New Required Field Added --
				gm.applicant_name as "Complainant_Name",
				gm.pri_cont_no as "Phone_no",
				gm.applicant_address as "Address",
				case 
					when gm.district_id is not null then cdm3.district_name 
					else 'NA'
				end as "District",
				case 
					when gm.block_id is not null then cbm.block_name
					when gm.municipality_id is not null then cmm.municipality_name
					else 'NA'
				end as "Block_Municipality",
				case
					when gm.gp_id is not null then cgpm.gp_name
					when gm.ward_id is not null then cwm.ward_name
					else 'NA'
				end as "GP_Ward",
				case
					when gm.police_station_id is not null then cpsm.ps_name
					else 'NA'
				end as "Police_Station",
				case
					when gm.received_at is not null then cdlm1.domain_value
					else 'NA'
				end as "Received_at",
				case
					when gm.emergency_flag = 'Y' then 'Yes'
					else 'No'
				end as "Whether_Emergency",
				case 
					when gm.status = 15 then gm.grievence_close_date
					else null
				end as "Disposal_Date",
				case
					when gm.grievance_category is not null then cgcm.grievance_category_desc
					else 'NA'
				end as "Grievance_category",
				gm.grievance_description as "Grievance_Description",
				case 
					when gm.status = 15 and gm.atr_submit_by_lastest_office_id is not null then com3.office_name
					when gm.status in (13, 14) and gm.assigned_by_office_id is not null then com.office_name
					else 'NA'
				end as "HOD",
				case
					when gm.status = 14 then gm.action_taken_note
					else 'NA'
				end as "HODs_Last_Remarks",
				case
			        when gm.closure_reason_id  is not null then ccrm.closure_reason_name
			        else 'NA'
			    end as "ATR_Closure_Reason"
			from grievance_trail_data LC
			inner join grievance_master gm on gm.grievance_id = LC.grievance_id and (gm.grievance_source = 5 or gm.received_at = 6) /*gm.received_at = 6*/
			left join admin_position_master apm1 on LC.assigned_by_position = apm1.position_id
			left join admin_position_master apm2 on LC.assigned_to_position = apm2.position_id
			left join cmo_closure_reason_master ccrm on gm.closure_reason_id = ccrm.closure_reason_id
			left join cmo_action_taken_note_master catnm on LC.atn_id = catnm.atn_id
			left join cmo_action_taken_note_reason_master catnrm on catnrm.atn_reason_master_id = LC.atn_reason_master_id
			left join admin_user_details aud1 on LC.assigned_by_id = aud1.admin_user_id
			left join cmo_designation_master cdm1 on apm1.designation_id = cdm1.designation_id
			left join cmo_office_master com1 on com1.office_id = apm1.office_id
			left join cmo_sub_office_master csom1 on csom1.suboffice_id = apm1.sub_office_id
			left join admin_user_details aud2 on LC.assigned_to_id = aud2.admin_user_id
			left join cmo_designation_master cdm2 on apm2.designation_id = cdm2.designation_id
			left join cmo_office_master com2 on com2.office_id = apm2.office_id
			left join cmo_sub_office_master csom2 on csom2.suboffice_id = apm2.sub_office_id
			left join cmo_domain_lookup_master cdlm on LC.grievance_status = cdlm.domain_code and cdlm.domain_type = 'grievance_status'
			left join cmo_domain_lookup_master cdlm1 on gm.received_at = cdlm1.domain_code and cdlm.domain_type = 'received_at_location'
			left join cmo_districts_master cdm3 on cdm3.district_id = gm.district_id
			left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
			left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
			left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gm.gp_id
			left join cmo_wards_master cwm on cwm.ward_id = gm.ward_id
			left join cmo_police_station_master cpsm on cpsm.ps_id = gm.police_station_id
			left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
			left join cmo_office_master com on com.office_id = gm.assigned_by_office_id /*or com.office_id = gm.atr_submit_by_lastest_office_id*/
			left join cmo_office_master com3 on com3.office_id = gm.atr_submit_by_lastest_office_id
			order by LC.grievance_id, LC.lifecycle_id asc
		)
	select
		count(1) as total_count,
		effective_date::DATE AS push_date
		/*(current_date - interval '1 day')::DATE as push_date*/
		/*'2025-04-20'::DATE as push_date */ /* Backdated -> 2024-11-12 to 2025-01-01 | 2025-04-11 - 2025-04-22 */ 
	from grievance_master_data M;







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



CREATE TABLE public.grievance_lifecycle_sdc_timestamp_20250806_bkp (
	lifecycle_id int8,
	"comment" text NULL,
	grievance_status int2 NOT NULL,
	assigned_on timestamptz(6) NULL,
	assigned_by_id int8 NULL,
	assign_comment text NULL,
	assigned_to_id int8 NULL,
	assign_reply text NULL,
	accepted_on timestamptz(6) NULL,
	atr_type int2 NULL,
	atr_proposed_date timestamptz(6) NULL,
	official_code varchar(100) NULL,
	action_taken_note text NULL,
	atn_id int8 NULL,
	atn_reason_master_id int8 NULL,
	action_proposed text NULL,
	contact_date timestamptz(6) NULL,
	tentative_date timestamptz(6) NULL,
	prev_recv_date timestamptz(6) NULL,
	prev_atr_date timestamptz(6) NULL,
	closure_reason_id int8 NULL,
	atr_submit_on timestamptz(6) NULL,
	created_by int8 NULL,
	created_on timestamptz(6) NULL,
	grievance_id int8 NULL,
	assigned_by_position int8 NULL,
	assigned_to_position int8 NULL,
	urgency_type int2 NULL,
	addl_doc_id jsonb NULL,
	current_atr_date timestamptz(6) NULL,
	atr_doc_id jsonb NULL,
	assigned_by_office_id int8 NULL,
	assigned_to_office_id int8 NULL,
	assigned_by_office_cat int8 NULL,
	assigned_to_office_cat int8 NULL,
	migration_id int4 NULL,
	migration_id_ac_tkn int4 NULL
--	CONSTRAINT grievance_lifecycle_sdc_timestamp_20250806_bkp_pkey PRIMARY KEY (lifecycle_id, grievance_status)
)


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
    WHERE grievance_id IN (75025, 157714, 299802, 347757, 458802, 544040, 639313, 1021208, 1094621, 1120527, 1147925, 1661965, 1689703, 1698324, 1747388, 1756274, 1830198, 1910240, 2021018, 2034237, 2044223, 2327571, 
2486609, 2741316, 2823552, 3035119, 3131366, 3200822, 3231993, 3314679, 3338450, 3406928, 3421217, 4429379, 4829175, 4900916, 
5103231, 5127211, 5163067, 5252572, 5259472, 5271277, 5271743, 5296275, 5331917, 5355401, 5390979, 5398756, 5410585, 5463718, 5488272, 5502972, 5508410, 5510314) 
      AND created_on::date = '2025-08-01'
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
    WHERE grievance_id in (1673522, 3520818, 4027900, 4156486, 4206619, 4219512, 4363175, 4363217, 4678862, 4679163, 4679209, 4679337, 4679466, 4679653, 4680198, 4680219, 4680224, 4680569, 4680890, 4680893, 4680938, 4680957, 4680970, 4681543, 4681776, 4681801, 4681839, 4681862, 4681921, 4682066, 4682116, 4682282, 4682301, 4682362, 4682447, 4682448, 4682589, 4682672, 4682674, 4683017, 4683130, 4683189, 4683209, 4683383, 4683649, 4683821, 4683884, 4684235, 4684270, 4684322, 4684459, 4684609, 4684685, 4684974, 4685251, 4685825, 4685857, 4685934, 4686135, 4686236, 4686255, 4686269, 4686287, 4686374, 4686541, 4686757, 4686867, 4686870, 4687029, 4687237, 4687269, 4687404, 4687428, 4687537, 4687700, 4687716, 4687732, 4687839, 4688085, 4688088, 4688113, 4688114, 4688668, 4688778, 4688850, 4689047, 4689230, 4689352, 4689419, 4689547, 4689641, 4689808, 4690340, 4690411, 4690483, 4690510, 4690557, 4690716, 4690826, 4690871, 4690960, 4691188, 4691359, 4691526, 4691551, 4691653, 4691747, 4691762, 4691932, 4692002, 4692287, 4692693, 4692790, 4693021, 4693089, 4693144, 4693401, 4693595, 4693903, 4694000, 4694091, 4694099, 4694175, 4694647, 4694739, 4694846, 4694912, 4694922, 4694994, 4695244, 4695288, 4695379, 4695664, 4695779, 4696011, 4696040, 4696298, 4696709, 4696731, 4697183, 4697312, 4697376, 4697425, 4697615, 4697674, 4698020, 4698028, 4698176, 4698428, 4698712, 4698902, 4699020, 4699315, 4699670, 4699836, 4699843, 4699871, 4700206, 4700304, 4700662, 4700707, 4700872, 4700974, 4701357, 4701699, 4701901, 4701954, 4702001, 4702061, 4702171, 4702203, 4702467, 4702547, 4702578, 4702614, 4702818, 4702837, 4702992, 4703035, 4703300, 4703303, 4703392, 4703448, 4703532, 4703743, 4703939, 4703995, 4704024, 4704070, 4704104, 4704446, 4704676, 4704684, 4704910, 4704966, 4704984, 4704992, 4705066, 4705354, 4705502, 4705578, 4705737, 4705783, 4705814, 4705929, 4706136, 4706248, 4706378, 4706387, 4706558, 4706565, 4706740, 4706760, 4706969, 4707170, 4707233, 4707332, 4707506, 4707617, 4707753, 4707823, 4707836, 4708134, 4708726, 4708885, 4708934, 4709040, 4709046, 4709279, 4709458, 4709600, 4709944, 4710180, 4710440, 4710618, 4710628, 4710646, 4710739, 4710864, 4711167, 4711271, 4711306, 4711535, 4711896, 4711969, 4712061, 4712089, 4712312, 4712487, 4712512, 4713044, 4713142, 4713300, 4713529, 4713532, 4713554, 4713670, 4713706, 4713783, 4713983, 4714112, 4714420, 4714430, 4714527, 4714584, 4714609, 4714980, 4715027, 4715867, 4715888, 4716026, 4716159, 4716349, 4716354, 4716537, 4717067, 4717129, 4717151, 4717214, 4717298, 4717318, 4717374, 4717430, 4717435, 4717446, 4717836, 4717957, 4717959, 4718130, 4718239, 4718262, 4718425, 4718901, 4718966, 4719072, 4719091, 4719305, 4719549, 4719720, 4719722, 4719724, 4719851, 4720196, 4720410, 4720422, 4720605, 4720801, 4720898, 4721107, 4721161, 4721226, 4721569, 4721573, 4721770, 4721909, 4721955, 4722019, 4722238, 4722432, 4722470, 4722503, 4722542, 4722575, 4722692, 4722767, 4723020, 4723149, 4723620, 4723741, 4723933, 4778408, 4778445, 4778684, 4778787, 4778833, 4779115, 4779198, 4779438, 4779745, 4779752, 4779824, 4780085, 4780108, 4780224, 4780252, 4780338, 4780342, 4780617, 4780708, 4780711, 4780935, 4781022, 4781382, 4781546, 4781573, 4781929, 4782086, 4782270, 4782290, 4782655, 4782710, 4782787, 4783120, 4783124, 4783319, 4783439, 4783567, 4783571, 4783760, 4783764, 4783787, 4783878, 4784735, 4784879, 4784925, 4785040, 4785158, 4785423, 4785424, 4785615, 4785627, 4785697, 4786145, 4786542, 4786653, 4786674, 4786803, 4786839, 4786874, 4786998, 4787156, 4787240, 4787294, 4787320, 4787412, 4787751, 4787978, 4788191, 4788457, 4788973, 4789246, 4789291, 4789367, 4789593, 4789600, 4789766, 4789781, 4789924, 4790050, 4790184, 4790620, 4790992, 4791078, 4791220, 4791575, 4791584, 4791672, 4791900, 4792141, 4792209, 4792426, 4792454, 4792483, 4792753, 4792839, 4793138, 4793186, 4793243, 4793352, 4793415, 4793800, 4794049, 4794060, 4794605, 4794653, 4794803, 4794810, 4794957, 4795021, 4795058, 4795072, 4795132, 4795211, 4795227, 4795410, 4795450, 4795600, 4795608, 4795757, 4795816, 4795914, 4795967, 4796108, 4796220, 4796258, 4796347, 4796446, 4796457, 4796483, 4796484, 4796565, 4796676, 4796862, 4796919, 4796940, 4797026, 4797073, 4797082, 4797151, 4797202, 4797295, 4797304, 4797317, 4797349, 4797397, 4797852, 4797907, 4797931, 4797941, 4797956, 4798094, 4798132, 4798134, 4798188, 4798196, 4798364, 4798456, 4798500, 4798626, 4798780, 4799002, 4799057, 4799139, 4799298, 4799488, 4799493, 4799612, 4799653, 4799885, 4799915, 4799995, 4800063, 4800356, 4800660, 4800699, 4800701, 4800850, 4801053, 4801229, 4801563, 4801594, 4801600, 4801755, 4801919, 4802107, 4802205, 4802457, 4802664, 4802971, 4803079, 4803541, 4803767, 4804026, 4804106, 4804327, 4804564, 4804721, 4804914, 4805041, 4805046, 4805069, 4805269, 4805374, 4805802, 4806151, 4806185, 4806274, 4806287, 4806359, 4806374, 4806418, 4806503, 4806638, 4806729, 4806787, 4806918, 4807015, 4807187, 4807451, 4807604, 4807764, 4807861, 4808206, 4808258, 4808286, 4808406, 4808418, 4808473, 4808535, 4808560, 4808579, 4808581, 4808688, 4808700, 4808724, 4808920, 4809103, 4809249, 4809473, 4809505, 4809537, 4809866, 4809940, 4810020, 4810161, 4810211, 4810374, 4810437, 4810585, 4810594, 4810871, 4810916, 4811027, 4811098, 4811100, 4811235, 4811323, 4811521, 4811817, 4812046, 4812049, 4812104, 4812117, 4812125, 4812130, 4812164, 4812217, 4812390, 4812536, 4812616, 4812914, 4813000, 4813075, 4813147, 4813262, 4813693, 4813695, 4813789, 4814037, 4814224, 4814522, 4814610, 4814853, 4814956, 4814975, 4814979, 4815076, 4815087, 4815091, 4815224, 4815267, 4815350, 4815402, 4815413, 4815440, 4815460, 4815678, 4815744, 4815918, 4815925, 4815952, 4815963, 4816058, 4816171, 4816264, 4816270, 4816280, 4816847, 4816882, 4816983, 4817008, 4817685, 4817721, 4818132, 4818165, 4818406, 4818519, 4818595, 4818722, 4818757, 4818762, 4818785, 4818897, 4819135, 4819327, 4819370, 4819426, 4819560, 4819653, 4819703, 4819712, 4819863, 4819930, 4819973, 4820320, 4820687, 4820945, 4820993, 4820996, 4821282, 4821294, 4821311, 4821597, 4821650, 4821790, 4821941, 4822050, 4822119, 4822390, 4822502, 4822515, 4822623, 4822950, 4823103, 4823336, 4823365, 4823451, 4823696, 4823947, 4824041, 4824117, 4824185, 4824425, 4824515, 4824519, 4824598, 4824934, 4825114, 4825121, 4825153, 4825550, 4825665, 4825698, 4825929, 4826217, 4826661, 4826803, 4827087, 4827290, 4827588, 4827790, 4827814, 4828005, 4828051, 4828790, 4829292, 4829452, 4829531, 4849575, 4849653, 4849870, 4851071, 4851263, 4851420, 4851508, 4851870, 4854165, 4854825, 4855406, 4857406, 4858381, 4858848, 4858905, 4860169, 4860848, 4862448, 4862592, 4862881, 4862890, 4864186, 4864410, 4864652, 4865105, 4865445, 4865561, 4865634, 4868467, 4869921, 4870523, 4871988, 4872149, 4872274, 4872349, 4872985, 4873013, 4873476, 4878621, 4878687, 4879025, 4879865, 4880433, 4880870, 4882302, 4882541, 4882831, 4882886, 4883253, 4883279, 4883900, 4884022, 4884388, 4885112, 4885218, 4885741, 4886280, 4886350, 4886642, 4886654, 4887370, 4887479, 4887714, 4888071, 4888163, 4888194, 4888783, 4890203, 4890490, 4890697, 4890956, 4891110, 4891492, 4891700, 4891954, 4892192, 4892257, 4892392, 4892660, 4892860, 4893210, 4893350, 4893483, 4893748, 4893756, 4893871, 4894086, 4894184, 4895365, 4895410, 4895413, 4895428, 4895880, 4895897, 4895941, 4896267, 4897232, 4897523, 4897527, 4897636, 4898235, 4898848, 4898899, 4899051, 4899134, 4899525, 4899780, 4899889, 4900131, 4900824, 4901874, 4902518, 4903393, 4903405, 4903609, 4904396, 4905000, 4905324, 4905532, 4905760, 4906382, 4906603, 4908270, 4908523, 4908766, 4909556, 4910193, 4910242, 4911136, 4911897, 4912482, 4914078, 4914533, 4915301, 4915940, 4916102, 4916915, 4917120, 4917158, 4917530, 4917630, 4917729, 4917895, 4918030, 4918107, 4918160, 4918385, 4918975, 4918987, 4919139, 4919324, 4919560, 4919753, 4920066, 4921212, 4921264, 4921310, 4921459, 4921866, 4922409, 4922433, 4922580, 4922684, 4923033, 4923606, 4923783, 4923786, 4924366, 4924442, 4924840, 4925584, 4925769, 4925780, 4925789, 4926107, 4926554, 4926598, 4926889, 4926898, 4927290, 4927996, 4928776, 4929166, 4929388, 4929795, 4929908, 4930061, 4930104, 4930147, 4930201, 4930203, 4930323, 4930359, 4930480, 4930551, 4930622, 4930658, 4930775, 4930929, 4930935, 4930952, 4930955, 4930969, 4931214, 4931231, 4931517, 4931633, 4931925, 4931943, 4932272, 4932327, 4932787, 4932915, 4933034, 4934609, 4934620, 4934622, 4935020, 4935076, 4935089, 4935126, 4935145, 4935166, 4935173, 4935250, 4935419, 4935458, 4935468, 4935481, 4935504, 4935650, 4935670, 4935730, 4935777, 4935834, 4935860, 4935868, 4936040, 4936072, 4936107, 4936138, 4936233, 4936345, 4936360, 4936378, 4936405, 4936431, 4936479, 4936556, 4936604, 4936637, 4936729, 4936793, 4936879, 4936880, 4936898, 4936902, 4936929, 4936933, 4937047, 4937660, 4938212, 4938230, 4938327, 4938370, 4938532, 4938548, 4938904, 4938910, 4938911, 4939034, 4939082, 4939289, 4939360, 4939367, 4939440, 4940506, 4941329, 4941798, 4942077, 4942210, 4942222, 4942243, 4942311, 4942332, 4942342, 4942438, 4942491, 4942515, 4942618, 4942654, 4942705, 4942738, 4942767, 4942817, 4942847, 4942856, 4942886, 4943011, 4943126, 4943308, 4943476, 4943489, 4943525, 4943637, 4943748, 4943859, 4943901, 4943910, 4944033, 4944070, 4944078, 4944122, 4944155, 4944160, 4944178, 4944193, 4944221, 4944232, 4944300, 4944409, 4944428, 4944433, 4944448, 4944460, 4944623, 4944660, 4944702, 4944712, 4944777, 4944828, 4945007, 4945066, 4945158, 4945161, 4945189, 4945198, 4945200, 4945272, 4945335, 4945352, 4945431, 4945561, 4945682, 4945683, 4945730, 4945760, 4945808, 4945880, 4945914, 4945930, 4945931, 4945972, 4946041, 4946217, 4946363, 4946425, 4946435, 4946607, 4946655, 4946675, 4946745, 4946774, 4946784, 4946867, 4946937, 4946941, 4947047, 4947063, 4947065, 4947095, 4947156, 4947174, 4947325, 4947343, 4947355, 4947380, 4947505, 4947554, 4947639, 4947668, 4947729, 4947735, 4947798, 4947813, 4947913, 4947951, 4948037, 4948041, 4948147, 4948222, 4948383, 4948392, 4948621, 4948634, 4948639, 4948687, 4948844, 4948881, 4948920, 4948927, 4948979, 4949035, 4949064, 4949066, 4949137, 4949161, 4949176, 4949258, 4949277, 4949278, 4949342, 4949444, 4949481, 4949626, 4949636, 4949673, 4949708, 4949720, 4949722, 4949801, 4949883, 4949947, 4949953, 4950059, 4950123, 4950171, 4950186, 4950252, 4950258, 4950267, 4950311, 4950401, 4950562, 4950611, 4950647, 4950679, 4950697, 4950831, 4950907, 4950935, 4951011, 4951049, 4951050, 4951165, 4951232, 4951252, 4951254, 4951317, 4951328, 4951477, 4951683, 4951702, 4951715, 4952118, 4952139, 4952156, 4952160, 4952205, 4952240, 4952255, 4952305, 4952310, 4952334, 4952442, 4952624, 4952629, 4952656, 4952685, 4952690, 4952707, 4952720, 4952745, 4952761, 4952768, 4952823, 4952861, 4952872, 4952942, 4952965, 4953028, 4953030, 4953127, 4953175, 4953241, 4953249, 4953278, 4953304, 4953346, 4953349, 4953357, 4953374, 4953400, 4953412, 4953454, 4953474, 4953555, 4953569, 4953764, 4953802, 4953865, 4953919, 4953920, 4953946, 4954010, 4954103, 4954104, 4954107, 4954111, 4954129, 4954164, 4954206, 4954249, 4954294, 4954340, 4954360, 4954361, 4954450, 4954461, 4954472, 4954567, 4954674, 4954703, 4954717, 4954766, 4954773, 4954814, 4954827, 4954869, 4955018, 4955036, 4955085, 4955109, 4955157, 4955192, 4955200, 4955247, 4955359, 4955446, 4955453, 4955459, 4955577, 4955605, 4955639, 4955739, 4955740, 4955820, 4955829, 4955841, 4955863, 4955957, 4955982, 4956008, 4956082, 4956208, 4956243, 4956276, 4956428, 4956468, 4956497, 4956539, 4956546, 4956598, 4956615, 4956757, 4956805, 4956954, 4956987, 4957042, 4957083, 4957112, 4957141, 4957149, 4957150, 4957258, 4957262, 4957299, 4957322, 4957434, 4957440, 4957580, 4957589, 4957606, 4957661, 4957732, 4957981, 4958012, 4958018, 4958051, 4958075, 4958168, 4958192, 4958242, 4958355, 4958400, 4958428, 4958546, 4958553, 4958616, 4958617, 4958646, 4958868, 4958877, 4958915, 4958925, 4958938, 4959044, 4959052, 4959055, 4959114, 4959363, 4959379, 4959423, 4959531, 4959559, 4959576, 4959619, 4959718, 4959827, 4960018, 4960074, 4960123, 4960249, 4960273, 4960281, 4960302, 4960353, 4960392, 4960411, 4960418, 4960482, 4960548, 4960555, 4960564, 4960588, 4960745, 4960778, 4960796, 4960818, 4960882, 4960903, 4960971, 4960993, 4961009, 4961078, 4961087, 4961091, 4961101, 4961119, 4961139, 4961173, 4961184, 4961287, 4961323, 4961345, 4961468, 4961506, 4961545, 4961557, 4961619, 4961690, 4961698, 4961736, 4961763, 4961788, 4961817, 4961928, 4961934, 4961949, 4961957, 4962100, 4962189, 4962192, 4962224, 4962239, 4962272, 4962277, 4962352, 4962377, 4962410, 4962468, 4962479, 4962561, 4962615, 4962627, 4962805, 4962806, 4962885, 4962979, 4962987, 4963044, 4963045, 4963061, 4963076, 4963078, 4963082, 4963134, 4963184, 4963265, 4963278, 4963420, 4963423, 4963434, 4963478, 4963530, 4963665, 4963705, 4963724, 4963757, 4963838, 4963935, 4963995, 4964003, 4964056, 4964089, 4964131, 4964299, 4964436, 4964687, 4964693, 4964814, 4964858, 4964990, 4965081, 4965186, 4965201, 4965203, 4965332, 4965375, 4965408, 4965466, 4965531, 4965615, 4965632, 4965651, 4965670, 4965715, 4965775, 4965951, 4965989, 4966102, 4966191, 4966241, 4966274, 4966312, 4966328, 4966339, 4966360, 4966459, 4966513, 4966538, 4966653, 4966671, 4966723, 4966772, 4966824, 4967022, 4967124, 4967126, 4967222, 4967252, 4967314, 4967443, 4967486, 4967563, 4967580, 4967725, 4967858, 4967902, 4967979, 4968007, 4968053, 4968054, 4968068, 4968074, 4968145, 4968230, 4968291, 4968309, 4968462, 4968543, 4968555, 4968575, 4968598, 4968637, 4968709, 4968829, 4968886, 4968887, 4968897, 4968957, 4968998, 4969101, 4969208, 4969214, 4969241, 4969315, 4969348, 4969353, 4969385, 4969406, 4969460, 4969518, 4969531, 4969581, 4969593, 4969620, 4969681, 4969700, 4969773, 4969837, 4969899, 4969999, 4970109, 4970146, 4970191, 4970244, 4970267, 4970302, 4970488, 4970512, 4970565, 4970676, 4970702, 4970805, 4970849, 4970944, 4971097, 4971191, 4971192, 4971218, 4971268, 4971277, 4971306, 4971323, 4971347, 4971382, 4971437, 4971444, 4971524, 4971543, 4971558, 4971598, 4971628, 4971680, 4971747, 4971866, 4971877, 4971878, 4971903, 4971919, 4971996, 4972007, 4972023, 4972063, 4972118, 4972131, 4972168, 4972173, 4972180, 4972280, 4972314, 4972407, 4972459, 4972463, 4972775, 4972809, 4972876, 4972984, 4973010, 4973011, 4973068, 4973078, 4973121, 4973149, 4973292, 4973355, 4973528, 4973533, 4973583, 4973598, 4973609, 4973628, 4973643, 4973837, 4973891, 4974040, 4974055, 4974097, 4974323, 4974338, 4974355, 4974485, 4974499, 4974515, 4974606, 4974659, 4974665, 4974689, 4974720, 4974738, 4974763, 4974773, 4974795, 4974802, 4974825, 4974841, 4974868, 4974894, 4975025, 4975380, 4975593, 4975663, 4975685, 4975797, 4975835, 4975852, 4975954, 4975978, 4976059, 4976077, 4976116, 4976205, 4976207, 4976243, 4976287, 4976451, 4976572, 4976582, 4976591, 4976639, 4976746, 4976748, 4976782, 4976823, 4976853, 4976947, 4976979, 4977012, 4977081, 4977165, 4977230, 4977269, 4977279, 4977335, 4977402, 4977425, 4977436, 4977532, 4977604, 4977690, 4977810, 4977898, 4977916, 4977983, 4977999, 4978025, 4978059, 4978065, 4978078, 4978102, 4978147, 4978150, 4978161, 4978195, 4978214, 4978215, 4978310, 4978594, 4978610, 4978624, 4978628, 4978694, 4978758, 4978771, 4978789, 4978939, 4978997, 4979023, 4979151, 4979173, 4979175, 4979181, 4979255, 4979268, 4979279, 4979408, 4979466, 4979481, 4979530, 4979602, 4979634, 4979677, 4979681, 4979890, 4979946, 4979953, 4980049, 4980082, 4980112, 4980120, 4980166, 4980203, 4980234, 4980293, 4980333, 4980359, 4980460, 4980480, 4980481, 4980494, 4980529, 4980546, 4980576, 4980641, 4980652, 4980665, 4980721, 4980871, 4980933, 4980934, 4980946, 4980952, 4980956, 4981017, 4981116, 4981299, 4981306, 4981373, 4981443, 4981453, 4981506, 4981634, 4981689, 4981704, 4981800, 4981887, 4981936, 4981977, 4982059, 4982071, 4982086, 4982135, 4982155, 4982162, 4982251, 4982264, 4982294, 4982300, 4982326, 4982331, 4982411, 4982413, 4982425, 4982502, 4982538, 4982549, 4982565, 4982571, 4982627, 4982816, 4982936, 4982957, 4982984, 4982991, 4983244, 4983285, 4983291, 4983322, 4983346, 4983357, 4983360, 4983452, 4983456, 4983461, 4983564, 4983586, 4983603, 4983678, 4983690, 4983695, 4983720, 4983752, 4983778, 4983808, 4983909, 4983961, 4984005, 4984030, 4984067, 4984149, 4984158, 4984302, 4984338, 4984531, 4984536, 4984545, 4984561, 4984676, 4984693, 4984694, 4984701, 4984782, 4985101, 4985396, 4985460, 4985504, 4985562, 4985606, 4985623, 4985711, 4985734, 4985781, 4985791, 4986014, 4986104, 4986178, 4986217, 4986227, 4986428, 4986433, 4986435, 4986474, 4986493, 4986564, 4986642, 4986680, 4986699, 4986732, 4986849, 4986917, 4986923, 4987060, 4987062, 4987111, 4987163, 4987164, 4987178, 4987227, 4987245, 4987261, 4987355, 4987388, 4987393, 4987488, 4987510, 4987539, 4987575, 4987633, 4987638, 4987714, 4987760, 4987788, 4987860, 4987906, 4987909, 4987982, 4987983, 4987986, 4988008, 4988026, 4988139, 4988141, 4988159, 4988184, 4988229, 4988256, 4988317, 4988375, 4988455, 4988457, 4988539, 4988671, 4988688, 4988691, 4988725, 4988762, 4988774, 4988809, 4988840, 4988872, 4988963, 4988988, 4988995, 4989023, 4989058, 4989084, 4989092, 4989103, 4989129, 4989161, 4989205, 4989209, 4989230, 4989250, 4989297, 4989353, 4989450, 4989516, 4989569, 4989574, 4989592, 4989646, 4989650, 4989731, 4989750, 4989763, 4989775, 4989854, 4989862, 4989863, 4989906, 4989930, 4989981, 4990009, 4990138, 4990249, 4990396, 4990463, 4990557, 4990659, 4990672, 4990750, 4990823, 4990906, 4990913, 4990937, 4990945, 4991025, 4991085, 4991109, 4991130, 4991249, 4991256, 4991257, 4991269, 4991334, 4991360, 4991385, 4991454, 4991467, 4991504, 4991554, 4991566, 4991576, 4991598, 4991614, 4991636, 4991648, 4991667, 4991670, 4991675, 4991694, 4991698, 4991718, 4991739, 4991796, 4991831, 4991840, 4991869, 4991898, 4991920, 4991929, 4991943, 4991962, 4992008, 4992093, 4992121, 4992249, 4992327, 4992462, 4992524, 4992548, 4992608, 4992609, 4992633, 4992640, 4992745, 4992755, 4992771, 4992811, 4992822, 4992891, 4992913, 4992928, 4992961, 4992970, 4992985, 4992992, 4993040, 4993045, 4993143, 4993144, 4993194, 4993207, 4993221, 4993375, 4993401, 4993437, 4993515, 4993706, 4993711, 4993732, 4993783, 4993840, 4993860, 4993920, 4993921, 4993968, 4994055, 4994058, 4994080, 4994099, 4994108, 4994191, 4994258, 4994286, 4994302, 4994308, 4994331, 4994431, 4994492, 4994494, 4994505, 4994606, 4994610, 4994674, 4994679, 4994709, 4994736, 4994747, 4994769, 4994782, 4994786, 4994825, 4994842, 4994863, 4994896, 4995002, 4995006, 4995014, 4995050, 4995057, 4995070, 4995151, 4995160, 4995219, 4995349, 4995367, 4995399, 4995437, 4995528, 4995545, 4995580, 4995617, 4995755, 4995826, 4996007, 4996010, 4996056, 4996119, 4996247, 4996339, 4996398, 4996414, 4996484, 4996624, 4996679, 4996699, 4996714, 4996768, 4996814, 4996817, 4996820, 4996859, 4996869, 4996900, 4996929, 4997033, 4997036, 4997044, 4997047, 4997063, 4997081, 4997147, 4997184, 4997266, 4997282, 4997356, 4997367, 4997374, 4997435, 4997859, 4997864, 4997880, 4997948, 4997958, 4997987, 4998001, 4998003, 4998077, 4998132, 4998143, 4998150, 4998214, 4998241, 4998316, 4998339, 4998485, 4998518, 4998578, 4998583, 4998605, 4998627, 4998746, 4998860, 4998865, 4998888, 4998972, 4998990, 4999108, 4999116, 4999243, 4999248, 4999313, 4999344, 4999385, 4999420, 4999489, 4999492, 4999523, 4999650, 4999675, 4999680, 4999682, 4999734, 4999738, 4999837, 5000009, 5000085, 5000107, 5000133, 5000191, 5000210, 5000238, 5000245, 5000275, 5000338, 5000390, 5000439, 5000449, 5000519, 5000604, 5000653, 5000914, 5000926, 5000965, 5000979, 5000987, 5001011, 5001047, 5001055, 5001063, 5001101, 5001144, 5001215, 5001216, 5001226, 5001284, 5001411, 5001414, 5001505, 5001578, 5001616, 5001647, 5001767, 5001768, 5001775, 5001837, 5001881, 5001907, 5002026, 5002122, 5002323, 5002648, 5002754, 5002759, 5002848, 5002890, 5002897, 5002910, 5002952, 5002958, 5002977, 5002980, 5003131, 5003133, 5003158, 5003177, 5003258, 5003472, 5003474, 5003500, 5003549, 5003565, 5003745, 5003766, 5003924, 5003943, 5004024, 5004094, 5004108, 5004164, 5004175, 5004186, 5004208, 5004227, 5004246, 5004287, 5004341, 5004373, 5004420, 5004456, 5004485, 5004505, 5004528, 5004532, 5004534, 5004555, 5004568, 5004590, 5004626, 5004643, 5004648, 5004738, 5004746, 5004761, 5004790, 5004792, 5004835, 5004894, 5004952, 5004968, 5005120, 5005189, 5005254, 5005264, 5005403, 5005542, 5005561, 5005578, 5005584, 5005612, 5005626, 5005658, 5005681, 5005684, 5005733, 5005789, 5005911, 5006137, 5006173, 5006202, 5006210, 5006243, 5006246, 5006300, 5006381, 5006412, 5006436, 5006460, 5006462, 5006603, 5006685, 5006767, 5006892, 5006931, 5007006, 5007025, 5007059, 5007086, 5007166, 5007197, 5007231, 5007262, 5007342, 5007663, 5007689, 5007690, 5007713, 5007779, 5007782, 5007825, 5007830, 5007833, 5007844, 5007904, 5008028, 5008150, 5008174, 5008190, 5008209, 5008210, 5008222, 5008362, 5008379, 5008382, 5008465, 5008505, 5008587, 5008607, 5008609, 5008677, 5008717, 5008772, 5008774, 5008796, 5008832, 5008896, 5008910, 5008923, 5009065, 5009066, 5009152, 5009182, 5009186, 5009316, 5009362, 5009412, 5009473, 5009530, 5009539, 5009615, 5009670, 5009673, 5009709, 5009714, 5009750, 5009752, 5009776, 5009817, 5009833, 5009860, 5009903, 5009912, 5009951, 5010030, 5010046, 5010105, 5010138, 5010171, 5010218, 5010232, 5010261, 5010351, 5010354, 5010385, 5010398, 5010623, 5010631, 5010675, 5010790, 5010792, 5010822, 5010877, 5010887, 5010903, 5010923, 5010925, 5011068, 5011187, 5011189, 5011320, 5011326, 5011327, 5011344, 5011384, 5011538, 5011679, 5011713, 5011813, 5011848, 5011873, 5011967, 5011989, 5011996, 5012035, 5012036, 5012046, 5012070, 5012089, 5012174, 5012177, 5012289, 5012347, 5012372, 5012374, 5012475, 5012496, 5012514, 5012520, 5012538, 5012539, 5012640, 5012667, 5012681, 5012714, 5012818, 5012905, 5012935, 5012965, 5012996, 5013006, 5013062, 5013070, 5013139, 5013173, 5013213, 5013256, 5013295, 5013324, 5013396, 5013431, 5013498, 5013505, 5013524, 5013610, 5013632, 5013644, 5013665, 5013670, 5013745, 5013875, 5013935, 5013968, 5014012, 5014016, 5014028, 5014064, 5014089, 5014100, 5014141, 5014199, 5014254, 5014271, 5014304, 5014318, 5014343, 5014395, 5014424, 5014495, 5014500, 5014528, 5014604, 5014611, 5014613, 5014629, 5014631, 5014680, 5014730, 5014759, 5014841, 5014939, 5014959, 5014990, 5014993, 5015010, 5015016, 5015034, 5015159, 5015247, 5015248, 5015327, 5015335, 5015382, 5015387, 5015392, 5015418, 5015441, 5015518, 5015544, 5015566, 5015617, 5015627, 5015715, 5015759, 5015773, 5015778, 5015855, 5015881, 5015945, 5015961, 5015967, 5015976, 5016056, 5016116, 5016118, 5016122, 5016124, 5016159, 5016173, 5016197, 5016240, 5016446, 5016460, 5016603, 5016675, 5016748, 5016753, 5016768, 5016826, 5016868, 5016928, 5017048, 5017085, 5017093, 5017148, 5017152, 5017184, 5017190, 5017209, 5017288, 5017314, 5017331, 5017341, 5017404, 5017439, 5017444, 5017495, 5017638, 5017640, 5017667, 5017720, 5017792, 5017816, 5017834, 5017842, 5017940, 5017958, 5018078, 5018092, 5018151, 5018153, 5018156, 5018164, 5018167, 5018183, 5018243, 5018269, 5018285, 5018307, 5018311, 5018367, 5018414, 5018442, 5018528, 5018531, 5018639, 5018687, 5018699, 5018703, 5018715, 5018755, 5018785, 5018883, 5018891, 5018930, 5018936, 5018941, 5019031, 5019037, 5019084, 5019118, 5019121, 5019183, 5019237, 5019265, 5019268, 5019304, 5019316, 5019343, 5019461, 5019484, 5019503, 5019589, 5019618, 5019786, 5019796, 5019811, 5019842, 5019901, 5019944, 5020079, 5020081, 5020150, 5020197, 5020225, 5020259, 5020305, 5020311, 5020372, 5020381, 5020413, 5020498, 5020724, 5020726, 5020733, 5020767, 5020811, 5020813, 5020866, 5020884, 5020904, 5020909, 5020924, 5020936, 5021031, 5021044, 5021089, 5021164, 5021205, 5021293, 5021311, 5021360, 5021361, 5021454, 5021499, 5021591, 5021635, 5021744, 5021779, 5021795, 5021939, 5022001, 5022034, 5022050, 5022057, 5022070, 5022178, 5022182, 5022213, 5022214, 5022218, 5022279, 5022290, 5022294, 5022320, 5022421, 5022422, 5022426, 5022468, 5022479, 5022520, 5022533, 5022669, 5022673, 5022780, 5022896, 5022948, 5022952, 5022973, 5023032, 5023098, 5023110, 5023129, 5023154, 5023159, 5023182, 5023186, 5023214, 5023511, 5023669, 5023718, 5023727, 5023778, 5023787, 5023933, 5023992, 5024004, 5024036, 5024075, 5024095, 5024096, 5024112, 5024150, 5024153, 5024154, 5024214, 5024319, 5024346, 5024392, 5024393, 5024446, 5024472, 5024480, 5024529, 5024539, 5024581, 5024590, 5024613, 5024650, 5024679, 5024690, 5024767, 5024922, 5024947, 5024962, 5024980, 5024996, 5025032, 5025058, 5025079, 5025176, 5025188, 5025234, 5025301, 5025414, 5025494, 5025517, 5025537, 5025640, 5025660, 5025662, 5025702, 5025725, 5025744, 5025770, 5025784, 5025828, 5025838, 5025850, 5025901, 5025927, 5025944, 5025994, 5026011, 5026045, 5026098, 5026107, 5026134, 5026160, 5026171, 5026178, 5026239, 5026552, 5026553, 5026596, 5026666, 5026695, 5026698, 5026768, 5026942, 5026957, 5026993, 5027035, 5027109, 5027164, 5027186, 5027274, 5027326, 5027365, 5027510, 5027563, 5027572, 5027594, 5027647, 5027649, 5027650, 5027683, 5027684, 5027762, 5027782, 5027811, 5027993, 5027999, 5028008, 5028028, 5028030, 5028122, 5028138, 5028184, 5028192, 5028208, 5028217, 5028220, 5028431, 5028440, 5028463, 5028494, 5028534, 5028539, 5028633, 5028756, 5028804, 5028826, 5028870, 5028884, 5028965, 5029010, 5029038, 5029127, 5029156, 5029176, 5029182, 5029194, 5029448, 5029457, 5029470, 5029521, 5029539, 5029565, 5029597, 5029601, 5029614, 5029619, 5029626, 5029675, 5029692, 5029778, 5029788, 5029798, 5029825, 5030024, 5030107, 5030182, 5030208, 5030211, 5030222, 5030239, 5030266, 5030275, 5030317, 5030330, 5030433, 5030465, 5030479, 5030489, 5030516, 5030518, 5030525, 5030529, 5030532, 5030535, 5030554, 5030572, 5030739, 5030754, 5030777, 5030787, 5030900, 5031147, 5031164, 5031259, 5031269, 5031362, 5031445, 5031452, 5031464, 5031528, 5031580, 5031591, 5031600, 5031613, 5031655, 5031779, 5031822, 5031883, 5031888, 5031893, 5031947, 5031975, 5031986, 5032010, 5032017, 5032028, 5032034, 5032048, 5032056, 5032059, 5032084, 5032087, 5032185, 5032211, 5032253, 5032271, 5032291, 5032373, 5032429, 5032483, 5032512, 5032586, 5032605, 5032682, 5032703, 5032718, 5032736, 5032766, 5032773, 5032806, 5032814, 5032852, 5032862, 5032893, 5032930, 5032932, 5033064, 5033093, 5033131, 5033163, 5033166, 5033194, 5033199, 5033206, 5033228, 5033259, 5033317, 5033335, 5033351, 5033517, 5033538, 5033564, 5033606, 5033627, 5033636, 5033637, 5033644, 5033671, 5033677, 5033703, 5033758, 5033807, 5033813, 5033832, 5033859, 5033874, 5033967, 5034050, 5034088, 5034107, 5034251, 5034320, 5034387, 5034429, 5034454, 5034801, 5034827, 5035020, 5035059, 5035078, 5035142, 5035232, 5035247, 5035386, 5035509, 5035553, 5035567, 5035576, 5035588, 5035641, 5035652, 5035667, 5035710, 5035738, 5035772, 5035802, 5035860, 5035949, 5035963, 5036010, 5036020, 5036045, 5036059, 5036060, 5036098, 5036176, 5036196, 5036241, 5036294, 5036300, 5036335, 5036475, 5036527, 5036585, 5036628, 5036669, 5036688, 5036708, 5036714, 5036725, 5036737, 5036973, 5036978, 5036995, 5037008, 5037014, 5037028, 5037059, 5037090, 5037191, 5037247, 5037310, 5037378, 5037579, 5037586, 5037620, 5037621, 5037628, 5037629, 5037642, 5037694, 5037728, 5037847, 5037857, 5037918, 5037920, 5037923, 5037925, 5038120, 5038167, 5038266, 5038353, 5038359, 5038390, 5038451, 5038481, 5038549, 5038586, 5038616, 5038640, 5038703, 5038745, 5038802, 5038869, 5038926, 5039132, 5039171, 5039266, 5039271, 5039349, 5039362, 5039367, 5039379, 5039449, 5039468, 5039685, 5039713, 5039829, 5039850, 5039869, 5039875, 5039983, 5040000, 5040014, 5040073, 5040186, 5040196, 5040268, 5040272, 5040299, 5040340, 5040354, 5040444, 5040475, 5040485, 5040708, 5040711, 5040776, 5040778, 5040786, 5040903, 5040909, 5040945, 5040972, 5041078, 5041286, 5041362, 5041455, 5041487, 5041488, 5041501, 5041522, 5041576, 5041586, 5041590, 5041613, 5041629, 5041709, 5041794, 5041803, 5041874, 5041893, 5041908, 5041943, 5041979, 5041987, 5042128, 5042236, 5042251, 5042280, 5042318, 5042421, 5042444, 5042626, 5042665, 5042696, 5042776, 5042823, 5042833, 5042843, 5042895, 5042901, 5042924, 5042926, 5042971, 5042974, 5043046, 5043050, 5043143, 5043225, 5043361, 5043388, 5043397, 5043426, 5043429, 5043447, 5043517, 5043547, 5043573, 5043612, 5043618, 5043623, 5043657, 5043668, 5043672, 5043791, 5043805, 5043828, 5043888, 5043891, 5043980, 5043983, 5044029, 5044075, 5044138, 5044211, 5044233, 5044280, 5044303, 5044530, 5044536, 5044545, 5044551, 5044593, 5044695, 5044743, 5044760, 5044797, 5044823, 5044865, 5044871, 5044942, 5044949, 5044998, 5045081, 5045140, 5045182, 5045239, 5045275, 5045293, 5045342, 5045349, 5045353, 5045357, 5045378, 5045404, 5045410, 5045506, 5045566, 5045573, 5045594, 5045652, 5045751, 5045762, 5045799, 5045996, 5046001, 5046007, 5046049, 5046111, 5046113, 5046116, 5046171, 5046289, 5046305, 5046316, 5046335, 5046392, 5046399, 5046425, 5046475, 5046500, 5046585, 5046589, 5046590, 5046599, 5046619, 5046643, 5046703, 5046736, 5046804, 5046925, 5047002, 5047033, 5047075, 5047109, 5047148, 5047239, 5047325, 5047386, 5047427, 5047465, 5047490, 5047514, 5047570, 5047643, 5047652, 5047729, 5047757, 5047825, 5047844, 5047847, 5047891, 5047894, 5047962, 5047967, 5048014, 5048027, 5048086, 5048091, 5048136, 5048147, 5048192, 5048205, 5048309, 5048310, 5048327, 5048366, 5048459, 5048472, 5048476, 5048509, 5048576, 5048718, 5048760, 5048810, 5048821, 5048825, 5048850, 5048941, 5049074, 5049290, 5049488, 5049502, 5049530, 5049541, 5049580, 5049587, 5049611, 5049654, 5049668, 5049697, 5049734, 5049753, 5049762, 5049827, 5049921, 5050023, 5050055, 5050066, 5050091, 5050193, 5050208, 5050253, 5050330, 5050379, 5050382, 5050512, 5050655, 5050668, 5050690, 5050701, 5050734, 5050777, 5050785, 5050857, 5050884, 5050922, 5050978, 5051070, 5051102, 5051145, 5051146, 5051199, 5051259, 5051322, 5051474, 5051491, 5051527, 5051607, 5051624, 5051707, 5051843, 5051851, 5051865, 5051868, 5051897, 5051922, 5052045, 5052121, 5052122, 5052233, 5052255, 5052308, 5052309, 5052341, 5052353, 5052392, 5052405, 5052492, 5052505, 5052523, 5052547, 5052588, 5052662, 5052700, 5052710, 5052724, 5052726, 5052791, 5052805, 5052882, 5052929, 5052971, 5053001, 5053018, 5053034, 5053037, 5053071, 5053184, 5053211, 5053228, 5053235, 5053244, 5053273, 5053375, 5053406, 5053432, 5053563, 5053618, 5053621, 5053653, 5053661, 5053702, 5053778, 5053832, 5053918, 5053969, 5053985, 5054118, 5054178, 5054380, 5054489, 5054506, 5054542, 5054580, 5054602, 5054790, 5054830, 5054843, 5054944, 5055038, 5055053, 5055073, 5055113, 5055162, 5055188, 5055496, 5055500, 5055527, 5055528, 5055565, 5055595, 5055624, 5055634, 5055789, 5055819, 5056003, 5056018, 5056044, 5056054, 5056090, 5056182, 5056263, 5056362, 5056399, 5056432, 5056667, 5056681, 5056704, 5056710, 5056738, 5056916, 5056927, 5057003, 5057052, 5057065, 5057122, 5057130, 5057225, 5057264, 5057271, 5057293, 5057343, 5057372, 5057428, 5057467, 5057470, 5057494, 5057509, 5057546, 5057602, 5057628, 5057703, 5057879, 5057968, 5058001, 5058048, 5058058, 5058065, 5058144, 5058345, 5058386, 5058390, 5058422, 5058501, 5058524, 5058547, 5058697, 5058816, 5058865, 5058873, 5058874, 5058881, 5058893, 5058965, 5059057, 5059060, 5059087, 5059101, 5059357, 5059458, 5059478, 5059482, 5059503, 5059504, 5059507, 5059596, 5059686, 5059703, 5059736, 5059751, 5059888, 5059995, 5060024, 5060056, 5060059, 5060097, 5060118, 5060166, 5060181, 5060238, 5060260, 5060299, 5060373, 5060496, 5060520, 5060556, 5060583, 5060667, 5060677, 5060690, 5060723, 5060759, 5060765, 5060785, 5060795, 5060836, 5060876, 5060983, 5061007, 5061035, 5061086, 5061114, 5061190, 5061265, 5061270, 5061334, 5061486, 5061503, 5061554, 5061561, 5061591, 5061622, 5061672, 5061738, 5061780, 5061802, 5061804, 5061829, 5061868, 5061941, 5061972, 5061973, 5062013, 5062019, 5062090, 5062147, 5062221, 5062292, 5062324, 5062358, 5062359, 5062377, 5062400, 5062446, 5062467, 5062473, 5062528, 5062558, 5062597, 5062637, 5062769, 5062868, 5062899, 5062912, 5062945, 5062950, 5062971, 5063056, 5063066, 5063083, 5063088, 5063096, 5063108, 5063183, 5063195, 5063209, 5063264, 5063309, 5063321, 5063353, 5063401, 5063422, 5063445, 5063447, 5063467, 5063610, 5063623, 5063708, 5063987, 5063996, 5064048, 5064103, 5064178, 5064240, 5064244, 5064292, 5064311, 5064355, 5064449, 5064509, 5064541, 5064554, 5064602, 5064607, 5064614, 5064626, 5064639, 5064689, 5064696, 5064714, 5064720, 5064732, 5064813, 5064818, 5064837, 5064886, 5064916, 5064924, 5064931, 5064932, 5065137, 5065245, 5065306, 5065317, 5065373, 5065638, 5065721, 5065755, 5065809, 5065876, 5065901, 5065960, 5065978, 5066020, 5066245, 5066267, 5066334, 5066339, 5066345, 5066377, 5066397, 5066433, 5066475, 5066565, 5066595, 5066645, 5066803, 5066855, 5067014, 5067158, 5067199, 5067569, 5067605, 5067801, 5067832, 5067833, 5067841, 5067867, 5067872, 5067879, 5067959, 5067974, 5068024, 5068031, 5068033, 5068065, 5068141, 5068200, 5068223, 5068368, 5068379, 5068412, 5068430, 5068453, 5068476, 5068484, 5068508, 5068642, 5068700, 5068733, 5068772, 5068813, 5068814, 5068842, 5068858, 5068898, 5068956, 5069030, 5069035, 5069169, 5069294, 5069335, 5069349, 5069432, 5069436, 5069606, 5069607, 5069618, 5069647, 5069650, 5069660, 5069667, 5069742, 5069937, 5069971, 5070018, 5070032, 5070042, 5070067, 5070128, 5070132, 5070138, 5070174, 5070236, 5070279, 5070340, 5070467, 5070480, 5070535, 5070569, 5070665, 5070741, 5070751, 5070763, 5070832, 5070843, 5070887, 5070900, 5070919, 5070925, 5070989, 5070994, 5071021, 5071041, 5071087, 5071165, 5071166, 5071184, 5071244, 5071356, 5071381, 5071393, 5071403, 5071441, 5071445, 5071487, 5071510, 5071512, 5071550, 5071551, 5071711, 5071718, 5071728, 5071776, 5071778, 5071799, 5071815, 5071816, 5071823, 5071868, 5071939, 5071952, 5071969, 5072003, 5072019, 5072028, 5072049, 5072127, 5072162, 5072170, 5072217, 5072288, 5072310, 5072342, 5072378, 5072388, 5072408, 5072411, 5072496, 5072520, 5072525, 5072638, 5072642, 5072647, 5072759, 5072770, 5072772, 5072847, 5072862, 5072880, 5072988, 5073003, 5073043, 5073175, 5073208, 5073220, 5073240, 5073257, 5073382, 5073389, 5073465, 5073543, 5073559, 5073573, 5073584, 5073611, 5073624, 5073626, 5073660, 5073868, 5074205, 5074206, 5074363, 5074486, 5074580, 5074771, 5074824, 5074981, 5075160, 5075222, 5075373, 5075382, 5075505, 5075560, 5075925, 5076036, 5076090, 5076131, 5076225, 5076400, 5076431, 5076498, 5076560, 5076587, 5076640, 5077443, 5077672, 5077754, 5078048, 5078064, 5078157, 5078400, 5078546, 5078810, 5078969, 5079218, 5079293, 5079340, 5079617, 5079797, 5079943, 5079988, 5080027, 5080176, 5080254, 5080488, 5080620, 5080724, 5080908, 5081032, 5081039, 5081118, 5081124, 5081222, 5081430, 5081435, 5081728, 5081748, 5081906, 5081969, 5082155, 5082419, 5082504, 5082512, 5082740, 5082776, 5082970, 5083035, 5083036, 5083094, 5083141, 5083294, 5083480, 5083696, 5084098, 5084171, 5084214, 5084241, 5084302, 5084415, 5084490, 5084537, 5084643, 5084957, 5084988, 5085338, 5085352, 5085357, 5085998, 5086001, 5086072, 5086145, 5086270, 5086272, 5086317, 5086336, 5086381, 5086519, 5086523, 5086534, 5086545, 5086737, 5087190, 5087388, 5087552, 5087747, 5087795, 5087811, 5087829, 5087880, 5088166, 5088263, 5088379, 5088487, 5088714, 5088944, 5089115, 5089411, 5089438, 5089489, 5089598, 5089856, 5089925, 5089970, 5089999, 5090255, 5090308, 5090328, 5090358, 5090632, 5090783, 5091040, 5091067, 5091091, 5091281, 5091323, 5091659, 5091681, 5091698, 5091726, 5091944, 5092196, 5092205, 5092250, 5092277, 5092282, 5092301, 5092364, 5092522, 5092731, 5092773, 5092789, 5092804, 5092818, 5092860, 5092900, 5092919, 5093082, 5093168, 5093180, 5093232, 5093398, 5093422, 5093537, 5093550, 5093642, 5093678, 5093687, 5093770, 5093882, 5093899, 5094025, 5094131, 5094257, 5094334, 5094566, 5094698, 5094899, 5095132, 5095391, 5095430, 5095561, 5095566, 5095587, 5095869, 5096226, 5096254, 5096372, 5096463, 5096822, 5097195, 5097222, 5097497, 5097509, 5097514, 5097577, 5097696, 5097843, 5097862, 5098065, 5098248, 5098256, 5098941, 5098999, 5099090, 5099396, 5099405, 5099463, 5099963, 5100052, 5100144, 5100161, 5100344, 5100359, 5100750, 5100795, 5101187, 5101286, 5101367, 5101802, 5101923, 5101964, 5102039, 5102143, 5102353, 5102559, 5102608, 5102826, 5103056, 5103589, 5103652, 5103939, 5104135, 5104441, 5105072, 5105375, 5105507, 5105862, 5106056, 5106110, 5106241, 5106292, 5106470, 5106545, 5106776, 5106923, 5106984, 5106998, 5107260, 5107646, 5107876, 5107921, 5108205, 5108303, 5108807, 5109081, 5109245, 5109328, 5109467, 5110262, 5110292, 5110352, 5110668, 5110824, 5110926, 5110960, 5111008, 5111196, 5111323, 5111362, 5111396, 5111995, 5112550, 5112738, 5112748, 5113433, 5113787, 5113821, 5113946, 5114450, 5114499, 5114933, 5115213, 5115300, 5115479, 5115492, 5115898, 5116224, 5116282, 5116329, 5116463, 5116644, 5117316, 5117550, 5117566, 5118333, 5118374, 5118581, 5118651, 5118757, 5118861, 5119033, 5119335, 5119339, 5119385, 5119661, 5119898, 5119995, 5120075, 5120261, 5120482, 5120640, 5120922, 5120952, 5120993, 5121088, 5121141, 5121279, 5121449, 5121497, 5121508, 5121577, 5121585, 5121996, 5122018, 5122199, 5122424, 5122595, 5122897, 5123239, 5123285, 5123291, 5123572, 5123591, 5123614, 5123784, 5123835, 5123843, 5124064, 5124115, 5124185, 5124224, 5124533, 5124603, 5124911, 5125066, 5125246, 5125311, 5125351, 5125675, 5126353, 5126363, 5126796, 5126807, 5126866, 5126937, 5127005, 5127135, 5127154, 5127258, 5127585, 5127878, 5128019, 5128023, 5128126, 5128325, 5128354, 5128382, 5128440, 5128482, 5128515, 5128593, 5128658, 5128972, 5129100, 5129233, 5129386, 5129396, 5129478, 5129551, 5129803, 5129809, 5129938, 5129940, 5130023, 5130282, 5130367, 5130452, 5131212, 5132322, 5132363, 5132589, 5132610, 5132832, 5132859, 5133221, 5133529, 5133552, 5133695, 5133782, 5133838, 5133978, 5134408, 5134561, 5134687, 5134804, 5134827, 5135137, 5135305, 5135365, 5135672, 5135928, 5136339, 5136694, 5137000, 5137073, 5137107, 5137800, 5138236, 5138449, 5138505, 5138782, 5139117, 5139649, 5139774, 5139946, 5140134, 5140337, 5140366, 5140555, 5140634, 5140770, 5140774, 5140860, 5141275, 5141404, 5141504, 5141604, 5141758, 5141789, 5142366, 5142433, 5142581, 5142702, 5142852, 5142909, 5142940, 5142951, 5142962, 5142993, 5143031, 5143158, 5143313, 5143378, 5143416, 5143458, 5143524, 5143526, 5143659, 5143730, 5143839, 5143915, 5144074, 5144082, 5144733, 5144765, 5144928, 5145094, 5145171, 5145395, 5145887, 5145992, 5146317, 5146321, 5146347, 5146670, 5146735, 5146757, 5146813, 5146868, 5146937, 5147079, 5147235, 5147246, 5147275, 5147290, 5147320, 5147366, 5147399, 5147406, 5147648, 5147789, 5148020, 5148123, 5148189, 5148474, 5148481, 5148615, 5148710, 5148861, 5148890, 5149176, 5149433, 5149929, 5150145, 5150367, 5150589, 5150648, 5150765, 5150848, 5150884, 5150915, 5150922, 5151298, 5151464, 5151749, 5151773, 5151825, 5151915, 5152002, 5152182, 5152217, 5152255, 5152339, 5152424, 5152429, 5152460, 5152477, 5152510, 5152819, 5153037, 5153101, 5153214, 5153258, 5153315, 5153496, 5153872, 5154138, 5154145, 5154154, 5154182, 5154249, 5154258, 5154320, 5154333, 5154369, 5154474, 5154488, 5154583, 5154608, 5154623, 5154639, 5154674, 5154679, 5154857, 5154863, 5154946, 5155163, 5155223, 5155245, 5155283, 5155304, 5155324, 5155433, 5155459, 5155496, 5155578, 5155586, 5155675, 5155703, 5155728, 5155760, 5155779, 5155794, 5155806, 5155890, 5155926, 5155972, 5155981, 5156056, 5156172, 5156225, 5156241, 5156442, 5156481, 5156575, 5156644, 5156704, 5156779, 5156822, 5156970, 5157173, 5157296, 5157419, 5157640, 5157724, 5157910, 5157913, 5157988, 5158213, 5158280, 5158294, 5158368, 5158874, 5158943, 5158993, 5159046, 5159052, 5159183, 5159247, 5159398, 5159707, 5159881, 5160012, 5160048, 5160127, 5160304, 5160368, 5160422, 5160622, 5160649, 5160760, 5160785, 5160819, 5161043, 5161067, 5161120, 5161297, 5161307, 5161402, 5161844, 5161846, 5161924, 5162039, 5162279, 5162300, 5162302, 5162429, 5162450, 5162514, 5162586, 5162721, 5162727, 5162761, 5162788, 5162796, 5163666, 5163778, 5163889, 5163907, 5163973, 5164207, 5164372, 5164384, 5165023, 5165353, 5165647, 5165784, 5166286, 5166402, 5166456, 5166580, 5166608, 5166974, 5167231, 5167253, 5167288, 5167349, 5167450, 5167665, 5167686, 5167840, 5168166, 5168494, 5168553, 5168598, 5168755, 5169008, 5169185, 5169213, 5169254, 5169426, 5169478, 5169597, 5169850, 5169904, 5169964, 5170107, 5170327, 5170512, 5170748, 5170905, 5171198, 5171608, 5171641, 5171672, 5171812, 5172186, 5172640, 5172675, 5172939, 5173156, 5173586, 5173734, 5173736, 5173954, 5173988, 5174011, 5174401, 5174438, 5174546, 5174834, 5175187, 5175841, 5175877, 5175913, 5176088, 5176406, 5176549, 5176556, 5176796, 5176804, 5176847, 5176893, 5176950, 5177327, 5177947, 5178048, 5178092, 5178526, 5178648, 5178928, 5179315, 5179752, 5179834, 5180041, 5180335, 5180636, 5180667, 5180766, 5180971, 5181005, 5181832, 5181947, 5182047, 5182153, 5182161, 5182528, 5182853, 5183004, 5183129, 5183428, 5184017, 5184066, 5184076, 5184362, 5184659, 5185472, 5185606, 5185647, 5186133, 5186148, 5186415, 5186579, 5186594, 5187036, 5187111, 5187189, 5187336, 5187377, 5187474, 5187528, 5187730, 5187964, 5187981, 5188067, 5188193, 5188353, 5188396, 5188555, 5188823, 5188836, 5188933, 5189180, 5189307, 5189341, 5189409, 5189499, 5189621, 5189626, 5189632, 5189681, 5189716, 5189975, 5190207, 5190369, 5190630, 5190863, 5190982, 5191549, 5191621, 5191645, 5191833, 5192035, 5192038, 5192340, 5192665, 5192710, 5193185, 5193590, 5193595, 5193684, 5193739, 5193920, 5193965, 5194106, 5194468, 5194594, 5194825, 5194849, 5194958, 5195056, 5195317, 5195373, 5195659, 5195957, 5196265, 5196319, 5196430, 5196448, 5196531, 5196695, 5196811, 5196862, 5197036, 5197837, 5197838, 5198137, 5198406, 5198765, 5198823, 5198964, 5199301, 5199357, 5199497, 5200343, 5200463, 5200472, 5200522, 5201415, 5201462, 5202240, 5202670, 5203679, 5203689, 5204263, 5204906, 5205011, 5205791, 5205908, 5206117, 5206301, 5207090, 5207132, 5207195, 5208001, 5208130, 5208175, 5208634, 5208808, 5208965, 5208999, 5209151, 5209155, 5209420, 5209580, 5209626, 5209805, 5210072, 5210164, 5210324, 5210999, 5211170, 5211416, 5212546, 5212601, 5212686, 5212722, 5212895, 5212903, 5212997, 5213055, 5213444, 5213724, 5213842, 5214197, 5214219, 5214250, 5214328, 5214758, 5214795, 5214902, 5215430, 5215594, 5215788, 5215863, 5216447, 5216554, 5216743, 5217263, 5217372, 5217468, 5217578, 5217877, 5218213, 5218648, 5219143, 5219630, 5219686, 5219736, 5220111, 5220178, 5220269, 5220312, 5220415, 5220463, 5220639, 5220739, 5221077, 5221127, 5221151, 5221387, 5221468, 5221519, 5221589, 5222021, 5222724, 5223060, 5223142, 5223272, 5223295, 5223343, 5223393, 5223428, 5223474, 5223492, 5223509, 5223569, 5223650, 5223651, 5223748, 5223857, 5223933, 5223955, 5224021, 5224092, 5224132, 5224269, 5224278, 5224281, 5224287, 5224288, 5224292, 5224320, 5224324, 5224337, 5224351, 5224408, 5224409, 5224530, 5224577, 5224581, 5224601, 5224632, 5224789, 5224865, 5224886, 5224899, 5224902, 5224969, 5224975, 5225064, 5225065, 5225161, 5225191, 5225231, 5225289, 5225313, 5225412, 5225441, 5225488, 5225497, 5225550, 5225612, 5225614, 5226459, 5226489, 5226647, 5226743, 5226998, 5226999, 5227435, 5227451, 5227555, 5227862, 5227864, 5227878, 5227996, 5228151, 5228170, 5228181, 5228198, 5228222, 5228358, 5228400, 5228417, 5228538, 5228784, 5228851, 5228894, 5229015, 5229017, 5229044, 5229129, 5229201, 5229421, 5229544, 5229563, 5229605, 5229643, 5229683, 5229798, 5229888, 5230303, 5230395, 5230467, 5230483, 5230705, 5230741, 5231252, 5231356, 5231599, 5231782, 5231808, 5231992, 5232080, 5232152, 5232188, 5232344, 5232378, 5232421, 5232457, 5232493, 5232519, 5232603, 5232663, 5232747, 5232759, 5232952, 5232981, 5233011, 5233226, 5233567, 5233618, 5233653, 5233717, 5233731, 5233814, 5233820, 5233827, 5234073, 5234112, 5234151, 5234247, 5234438, 5234474, 5234882, 5234990, 5235037, 5235249, 5235470, 5235493, 5235508, 5235617, 5235720, 5235987, 5236024, 5237006, 5237007, 5237009, 5237240, 5237408, 5237907, 5238334, 5238345, 5238378, 5238428, 5238459, 5238544, 5238727, 5238741, 5238834, 5238837, 5238965, 5238984, 5239314, 5239476, 5239499, 5239538, 5239613, 5239622, 5239831, 5239840, 5239951, 5240043, 5240094, 5240138, 5240166, 5240179, 5240268, 5240369, 5240687, 5240825, 5241128, 5241157, 5241213, 5241508, 5241529, 5241554, 5241657, 5241829, 5242045, 5242164, 5242232, 5242320, 5242365, 5242599, 5242733, 5242761, 5242920, 5242934, 5243063, 5243469, 5243562, 5244277, 5244348, 5244673, 5244784, 5244875, 5244887, 5244952, 5245040, 5245255, 5245319, 5245496, 5245750, 5245860, 5246200, 5246330, 5246373, 5246565, 5246654, 5247220, 5247525, 5247621, 5247916, 5247955, 5248064, 5248542, 5248664, 5248754, 5248806, 5248947, 5249011, 5249023, 5249164, 5249339, 5249496, 5249539, 5249561, 5250072, 5250124, 5250194, 5250329, 5250412, 5250587, 5250804, 5250938, 5251304, 5251582, 5251597, 5251742, 5251874, 5251974, 5252037, 5252098, 5252164, 5252275, 5252336, 5252733, 5252794, 5252828, 5252888, 5252980, 5253211, 5253320, 5253429, 5253624, 5253757, 5253818, 5253916, 5254053, 5254151, 5254349, 5254417, 5254581, 5254637, 5255107, 5255298, 5255352, 5255675, 5255726, 5255895, 5256078, 5256266, 5256694, 5256727, 5256856, 5256907, 5257025, 5257361, 5257689, 5257997, 5258022, 5258341, 5258397, 5258911, 5259022, 5259277, 5259369, 5259376, 5259544, 5259559, 5259699, 5259808, 5260040, 5260049, 5260061, 5260068, 5260099, 5260220, 5260346, 5260431, 5260639, 5260816, 5261031, 5261249, 5261433, 5261723, 5261830, 5261880, 5262027, 5262237, 5262264, 5262447, 5262455, 5262584, 5262636, 5262638, 5262697, 5262801, 5263214, 5263569, 5263639, 5263824, 5264352, 5264655, 5264798, 5264874, 5265023, 5265121, 5265270, 5265429, 5265452, 5265490, 5265566, 5265731, 5265766, 5265920, 5266164, 5266748, 5266799, 5267055, 5267105, 5267203, 5267261, 5267314, 5267358, 5267457, 5267458, 5267642, 5267978, 5268368, 5269251, 5269300, 5269392, 5269540, 5269554, 5269593, 5269631, 5269681, 5269687, 5269842, 5269864, 5269893, 5270220, 5270248, 5270788, 5271024, 5271048, 5271104, 5271288, 5271314, 5271678, 5271740, 5271747, 5271812, 5272070, 5272134, 5272187, 5272259, 5272262, 5272482, 5272560, 5273093, 5273101, 5273118, 5273293, 5273429, 5273465, 5273775, 5273909, 5273973, 5274049, 5274160, 5274216, 5274254, 5274452, 5274547, 5274562, 5274611, 5274634, 5274737, 5274806, 5274812, 5274923, 5275004, 5275248, 5275310, 5275774, 5275892, 5275984, 5276274, 5276474, 5276522, 5276714, 5276789, 5277203, 5277455, 5277465, 5277487, 5277867, 5277948, 5278293, 5278528, 5278641, 5278762, 5279318, 5279337, 5279466, 5279493, 5280045, 5280284, 5280465, 5280525, 5280571, 5280698, 5280935, 5280977, 5281094, 5281280, 5281401, 5281454, 5281464, 5281486, 5281652, 5281653, 5281890, 5281946, 5282013, 5282284, 5282401, 5282445, 5282584, 5282605, 5282686, 5282697, 5282702, 5282855, 5282896, 5282902, 5282925, 5282982, 5283031, 5283033, 5283307, 5283432, 5283504, 5283601, 5283641, 5283836, 5283850, 5283892, 5284231, 5284276, 5284316, 5284323, 5284414, 5284524, 5284611, 5284614, 5284968, 5284978, 5285045, 5285246, 5285247, 5285253, 5285347, 5285468, 5286701, 5286784, 5286802, 5286908, 5286942, 5286963, 5287245, 5287587, 5287643, 5287771, 5287814, 5287822, 5287905, 5288031, 5288119, 5288179, 5288188, 5288198, 5288529, 5288646, 5288689, 5288946, 5288967, 5289147, 5289253, 5289505, 5289878, 5290035, 5290810, 5290986, 5291402, 5291980, 5292394, 5292889, 5293729, 5293915, 5294072, 5294135, 5294268, 5294560, 5294578, 5294697, 5294755, 5294803, 5294950, 5294973, 5295061, 5295078, 5295086, 5295144, 5295361, 5295372, 5295391, 5295416, 5295644, 5295674, 5295808, 5296066, 5296107, 5296152, 5296185, 5296194, 5296289, 5296345, 5296485, 5296498, 5296528, 5296620, 5296819, 5296856, 5297037, 5297062, 5297131, 5297160, 5297478, 5297625, 5297640, 5297744, 5297770, 5297786, 5297796, 5297861, 5297952, 5298031, 5298041, 5298060, 5298069, 5298071, 5298536, 5298741, 5298759, 5298826, 5298841, 5298898, 5298965, 5298978, 5298982, 5299007, 5299130, 5299252, 5299292, 5299647, 5299741, 5299765, 5299838, 5299875, 5299932, 5299952, 5299997, 5300091, 5300098, 5300176, 5300199, 5300208, 5300229, 5300311, 5300340, 5300379, 5300462, 5300642, 5300704, 5300749, 5300921, 5300966, 5301016, 5301056, 5301132, 5301260, 5301401, 5301491, 5301492, 5301614, 5301635, 5301740, 5301813, 5301835, 5301939, 5302167, 5302299, 5302398, 5302403, 5302471, 5302472, 5302581, 5302759, 5302777, 5302861, 5303070, 5303421, 5303426, 5303480, 5303700, 5303770, 5304074, 5304120, 5304155, 5304271, 5304380, 5304407, 5304503, 5304504, 5304578, 5304662, 5304686, 5304791, 5304934, 5304984, 5305014, 5305078, 5305151, 5305172, 5305435, 5305477, 5305487, 5305520, 5305558, 5305581, 5305616, 5305617, 5305827, 5305877, 5305888, 5305942, 5305994, 5306085, 5306347, 5306400, 5306454, 5306575, 5306631, 5306655, 5306759, 5306778, 5306961, 5307038, 5307154, 5307212, 5307313, 5307323, 5307337, 5307414, 5307443, 5307471, 5307530, 5307578, 5307594, 5307623, 5307764, 5307823, 5307851, 5307852, 5307873, 5307883, 5308035, 5308070, 5308131, 5308160, 5308198, 5308340, 5308549, 5308802, 5308849, 5308915, 5308930, 5308974, 5309027, 5309054, 5309117, 5309125, 5309326, 5309552, 5309641, 5309654, 5309668, 5309719, 5309729, 5309740, 5309742, 5309865, 5309923, 5309957, 5310024, 5310089, 5310286, 5310559, 5310584, 5310676, 5310733, 5310878, 5310985, 5311260, 5311339)
      AND created_on::date = '2025-07-03'
      AND grievance_status IN (15, 2, 14, 4, 16)
)
DELETE FROM grievance_lifecycle
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
--    458802,
--    544040,
--    639313,
--    1021208,
--    1094621,
--    1120527,
--    1147925,
--    1747388,
--    2021018,
--    2034237,
--    2159312,
--    2184847,
--    2327571,
--    2486609,
--    2741316,
--    2823552,
--    3035119,
--    3131366,
--    3200822,
--    3231993,
--    3314679,
--    3338450,
--    3421217,
--    4829175,
--    5127211,
--    5163067,
--    5331917,
--    5355401,
--    5390979,
--    5398756,
--    5410585,
--    5463718,
--    5502972,
--    5510314
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

griev_ids_pnrd_p3
cmo_bulk_status_update_closure_audit
    
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
select * from grievance_master gm where gm.grievance_id in (1431846);
select * from grievance_master gm where gm.grievance_no in ('629741937004042024185825');	
select * from grievance_lifecycle gl where gl.grievance_id in (1431846) order by gl.assigned_on desc;
select * from cmo_bulk_status_update_closure_audit_noteligible_pnrd where grievance_id = 2021018;
select * from cmo_bulk_status_update_closure_audit where grievance_id = 854866;
select * from cmo_bulk_status_update_closure_audit where id = 2159312;
SELECT id FROM cmo_bulk_status_update_closure_audit ORDER BY id DESC LIMIT 1;
select * from grievance_locking_history glh where glh.grievance_id = 347757;

select * from cmo_grievance_category_master cgcm ;
select * from cmo_griev_cat_office_mapping cgcom ;


select * from grievance_lifecycle WHERE grievance_id IN (271720, 274415, 347431, 392126, 517153, 685447, 686862, 773273, 1100011, 1124673, 1164480, 1201541, 1396843,
1457428, 1709326, 1732554, 1770219, 1938357, 1945691, 1977071, 2003745, 2065567, 2094897, 2297439, 2568000, 2707481, 2742092, 2780972, 2893202, 2893203, 2946135, 3078595, 
3232202, 3251786, 3359392, 3480049, 3549070, 3684784, 4421128, 4580926, 4593571, 4640077, 4779760, 4780748, 4803410, 4809961, 4961991,
5116479, 5216375, 5226903, 5233156, 5259152, 5321549, 5334687, 5362793, 5363163, 5390522, 5437318, 5446925, 5496257, 5500296, 5519725) 
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

--DELETE FROM  
--WHERE grievance_id IN (3647330,
--2332941,
--2807129,
--1913643,
--2053955,
--2862261,
--1764832,
--2976975,
--2116563,
--3054589,
--3701828,
--5153713,
--3483772,
--5247299,
--5288626,
--4166722,
--4211288,
--5361835,
--4434020,
--5500498,
--361511,
--912827,
--1091992,
--1113056,
--5468700,
--2588569,
--2444037,
--1992338,
--2006987,
--2971775,
--2829327,
--2026047,
--2792842,
--2849289,
--2835777,
--571145,
--2348200,
--2402219,
--2444677,
--2447689,
--2418191,
--1942638,
--3051744,
--2151056,
--2479222,
--3100660,
--3101418,
--2508952,
--3153553,
--2162730,
--2527851,
--2518896,
--2527211,
--3183980,
--3557614,
--3605522,
--3214606,
--3652443,
--3413475,
--76693,
--3296065,
--5126419,
--5146250,
--5151369,
--5171353,
--5270174,
--3320543,
--5233343,
--3206936,
--4085878,
--5301801,
--5305101,
--4211215,
--4211216,
--98957,
--3508532,
--3526696,
--4433981,
--4670245,
--4645711,
--1782051,
--1791072,
--1801512,
--1827801,
--1648705,
--5382400,
--73208,
--109144,
--126019,
--129874,
--196520,
--210778,
--271224,
--483948,
--487409,
--496333,
--499683,
--1457567,
--653240,
--697966,
--748953,
--748956,
--1066585,
--1205933,
--1261249,
--1271496,
--1553665,
--1440272,
--1521631,
--1571077,
--5392484,
--5441968,
--2649867,
--2232417,
--2239664,
--2826852,
--2857178,
--2869622,
--2862457,
--2377943,
--1931076,
--2406632,
--2517643,
--3033720,
--781986,
--2163186,
--3138520,
--3140222,
--2506180,
--3140886,
--3148839,
--2178515,
--4835542,
--3212164,
--4893554,
--3585667,
--3635113,
--3385119,
--3387638,
--808360,
--5054424,
--5075324,
--3530338,
--3533681,
--1747261,
--1693995,
--135858,
--141650,
--200519,
--308813,
--324935,
--352090,
--381572,
--370735,
--423391,
--552125,
--793170,
--915974,
--906291,
--970956,
--975533,
--985559,
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


-- public.forwarded_latest_5_bh_mat_2 source

-- public.forwarded_latest_5_bh_mat source

--CREATE MATERIALIZED VIEW public.atr_latest_13_bh_mat_2
--TABLESPACE pg_default
--AS WITH latest_5 AS (
--         SELECT a.grievance_id,
--            a.assigned_on
--           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
--                    gl.grievance_id,
--                    gl.assigned_on,
--                    gl.grievance_status
--                   FROM grievance_lifecycle gl
--                  WHERE gl.grievance_status = ANY (ARRAY[3, 5])) a
--          WHERE a.rnn = 1 AND a.grievance_status = 5
--        ), latest_13 AS (
--         SELECT a.rnn,
--            a.lifecycle_id,
--            a.comment,
--            a.grievance_status,
--            a.assigned_on,
--            a.assigned_by_id,
--            a.assign_comment,
--            a.assigned_to_id,
--            a.assign_reply,
--            a.accepted_on,
--            a.atr_type,
--            a.atr_proposed_date,
--            a.official_code,
--            a.action_taken_note,
--            a.atn_id,
--            a.atn_reason_master_id,
--            a.action_proposed,
--            a.contact_date,
--            a.tentative_date,
--            a.prev_recv_date,
--            a.prev_atr_date,
--            a.closure_reason_id,
--            a.atr_submit_on,
--            a.created_by,
--            a.created_on,
--            a.grievance_id,
--            a.assigned_by_position,
--            a.assigned_to_position,
--            a.urgency_type,
--            a.addl_doc_id,
--            a.current_atr_date,
--            a.atr_doc_id,
--            a.assigned_by_office_id,
--            a.assigned_to_office_id,
--            a.assigned_by_office_cat,
--            a.assigned_to_office_cat,
--            a.migration_id,
--            a.migration_id_ac_tkn
--           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
--                    gl.lifecycle_id,
--                    gl.comment,
--                    gl.grievance_status,
--                    gl.assigned_on,
--                    gl.assigned_by_id,
--                    gl.assign_comment,
--                    gl.assigned_to_id,
--                    gl.assign_reply,
--                    gl.accepted_on,
--                    gl.atr_type,
--                    gl.atr_proposed_date,
--                    gl.official_code,
--                    gl.action_taken_note,
--                    gl.atn_id,
--                    gl.atn_reason_master_id,
--                    gl.action_proposed,
--                    gl.contact_date,
--                    gl.tentative_date,
--                    gl.prev_recv_date,
--                    gl.prev_atr_date,
--                    gl.closure_reason_id,
--                    gl.atr_submit_on,
--                    gl.created_by,
--                    gl.created_on,
--                    gl.grievance_id,
--                    gl.assigned_by_position,
--                    gl.assigned_to_position,
--                    gl.urgency_type,
--                    gl.addl_doc_id,
--                    gl.current_atr_date,
--                    gl.atr_doc_id,
--                    gl.assigned_by_office_id,
--                    gl.assigned_to_office_id,
--                    gl.assigned_by_office_cat,
--                    gl.assigned_to_office_cat,
--                    gl.migration_id,
--                    gl.migration_id_ac_tkn
--                   FROM grievance_lifecycle gl
--                  WHERE gl.grievance_status = 13 OR gl.grievance_status = 6 AND gl.assigned_by_office_cat = 2) a
--             JOIN latest_5 ON latest_5.grievance_id = a.grievance_id
--          WHERE a.rnn = 1 AND a.grievance_status = 13 AND latest_5.assigned_on < a.assigned_on
--        )
-- SELECT cmo_police_station_master.sub_district_id,
--    grievance_master.district_id,
--    grievance_master.block_id,
--    grievance_master.municipality_id,
--    grievance_master.gp_id,
--    grievance_master.ward_id,
--    grievance_master.police_station_id,
--    grievance_master.assembly_const_id,
--    grievance_master.postoffice_id,
--    grievance_master.grievance_category,
--    grievance_master.sub_division_id,
--    grievance_master.status AS current_status,
--    grievance_master.grievance_source,
--    grievance_master.closure_reason_id AS grievance_master_closure_reason_id,
--    grievance_master.grievance_generate_date,
--    grievance_master.applicant_gender,
--    grievance_master.received_at,
--    grievance_master.receipt_mode,
--    grievance_master.applicant_caste,
--    grievance_master.applicant_reigion,
--    grievance_master.applicant_age,
--    grievance_master.atr_submit_by_lastest_office_id,
--    latest_13.rnn,
--    latest_13.lifecycle_id,
--    latest_13.comment,
--    latest_13.grievance_status,
--    latest_13.assigned_on,
--    latest_13.assigned_by_id,
--    latest_13.assign_comment,
--    latest_13.assigned_to_id,
--    latest_13.assign_reply,
--    latest_13.accepted_on,
--    latest_13.atr_type,
--    latest_13.atr_proposed_date,
--    latest_13.official_code,
--    latest_13.action_taken_note,
--    latest_13.atn_id,
--    latest_13.atn_reason_master_id,
--    latest_13.action_proposed,
--    latest_13.contact_date,
--    latest_13.tentative_date,
--    latest_13.prev_recv_date,
--    latest_13.prev_atr_date,
--    latest_13.closure_reason_id,
--    latest_13.atr_submit_on,
--    latest_13.created_by,
--    latest_13.created_on,
--    latest_13.grievance_id,
--    latest_13.assigned_by_position,
--    latest_13.assigned_to_position,
--    latest_13.urgency_type,
--    latest_13.addl_doc_id,
--    latest_13.current_atr_date,
--    latest_13.atr_doc_id,
--    latest_13.assigned_by_office_id,
--    latest_13.assigned_to_office_id,
--    latest_13.assigned_by_office_cat,
--    latest_13.assigned_to_office_cat,
--    latest_13.migration_id,
--    latest_13.migration_id_ac_tkn
--   FROM latest_13
--     JOIN grievance_master ON latest_13.grievance_id = grievance_master.grievance_id
--     LEFT JOIN cmo_police_station_master ON cmo_police_station_master.ps_id = grievance_master.police_station_id
--WITH DATA;


--DROP MATERIALIZED VIEW IF EXISTS public.atr_latest_13_bh_mat CASCADE;
--DROP MATERIALIZED VIEW IF EXISTS public.atr_latest_13_bh_mat_2 CASCADE;






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



select * from grievance_master_20250806_bkp bp 
left join ;









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
 
