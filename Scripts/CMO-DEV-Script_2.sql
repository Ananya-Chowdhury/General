

select  atr_type, atr_proposed_date, action_taken_note, gl.atn_id, 
    catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
    prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
    gl.assigned_on, gl.assigned_by_id, gl.assign_comment, 
    gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position
from grievance_lifecycle gl
left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id 
left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id 
where gl.lifecycle_id  = 29562;


SELECT * 
FROM user_otp uo  
WHERE uo.u_phone = '9477399095'
ORDER BY created_on desc;




select * from grievance_master gm where gm.grievance_id in (22885,22886,22887,22888,22889);
select * from grievance_master gm where gm.grievance_no = 'SSM5341070';
select * from grievance_lifecycle gl where gl.grievance_id = 22905;


select * from cmo_office_master com; -- 13
select * from admin_position_master apm where apm.office_id = 35 and record_status = 1 and apm.role_master_id = 5; -- 2266
select * from admin_user_position_mapping aupm where aupm.position_id = 5;
select * from admin_user_details aud where admin_user_id = 9856;


select * from cmo_office_master com where office_id = 3;
select * from cmo_sub_office_master csom where office_id = 3;
select * from admin_position_master apm where office_id = 3  and sub_office_id = 479;
select * from admin_user_position_mapping aupm  where position_id in (487,488);
select * from admin_user_details aud where admin_user_id in (1093);
select * from admin_user au where admin_user_id in (614);
select * from grievance_master gm where gm.assigned_to_office_id = 3;
select * from admin_user_details aud where aud.official_phone ='8';
select * from grievance_master gm where gm.pri_cont_no = '9163479418'; --8101859077

select * from admin_user au where au.u_phone = '9477399095' ;


select * from admin_user_role_master aurm ;

--=====================================================
--=================== DEV LOGINs ======================

-- CMO Super Admin = 9330027052
-- HOSO = 7865925510, 9434495405
-- HOD Admin = 9434055201, 6292222444 (DM, South 24 Parganas District), 
-- HOD Nodal = 9477399095, 9434172049
-- Data Integrator = 9559000099
-- 

--=====================================================


["9999999900","9999999901","9999999902","9999999903","9999999904","9999999905","9999999906","9999999907","9999999908","9999999909","9999999910","9999999911","9999999912","9999999913","9999999914",
"9999999915","9999999916","9999999917","9999999918","9999999919","9330027052","8170045634","8101859077","9434172049","9477399095","9297929297","9874263537",
"6292222444","9434495405","9559000099","9434055201","7865925510"]

["9999999900","9999999901","9999999902","9999999903","9999999904","9999999905","9999999906","9999999907","9999999908","9999999909","9999999910","9999999911",
"9999999912","9999999913","9999999914","9999999915","9999999916","9999999917","9999999918","9999999919","9999999920","9999999999","9330027052","8170045634","8101859077","9836072377"
,"9434172049","9477399095","9297929297","9874263537","6292222444","9434495405","9559000099","9434055201","7865925510","8101859077","9999999950"]





select * from user_otp uo order by created_on desc;
select * from user_token ut ;
select * from cmo_parameter_master cpm;
select * from admin_user au;
select * from control_json cj;
select * from admin_user_login_activity aula;
select * from admin_user_details aud;
select * from cmo_domain_lookup_master cdlm ;
select * from cmo_domain_lookup_master cdlm where cdlm.domain_type = 'office_type';
select * from public.admin_position_master apm where /*apm.position_id = 3433*/ apm.office_type = 9;



-------------------------------------------------------------------------------------------------------------------------------------------------------------
select gm.*, cdm.lg_directory_district_code as lgd_dist, cbm.lg_directory_block_code as lgd_block, cmm.lg_directory_block_code as lgd_mun
    from grievance_master gm 
    inner join admin_position_master apm on gm.assigned_to_position = apm.position_id 
    left join cmo_districts_master cdm on cdm.district_id = gm.district_id
    left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
    where gm.status = 4 
        and apm.office_id = 53 and apm.sub_office_id is null
--        and gm.grievance_generate_date::date between '{from_date_time}' and '{to_date_time}';
        
 -------------------------------------------------------------------------------------------------------------------------------------------------------------
      
 with grievance_lodged as (
                select 
                    count(1) as grievance_lodged_cnt, bh.assembly_const_id, bh.district_id
                from grievance_master_bh_mat_2 as bh
                where bh.assembly_const_id is not null
                 and bh.grievance_generate_date::date between '2021-01-01' and '2025-06-27' 
                group by bh.assembly_const_id, bh.district_id
                order by bh.district_id
            ), atr_received as (
                select 
                    count(distinct bh.grievance_id) as atr_received_cnt, bh.assembly_const_id, bh.district_id
                from atr_latest_14_bh_mat_2 as bh
                inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
                where bh.current_status in (14,15) 
                 and bm.assigned_on::date between '2021-01-01' and '2025-06-27' 
                group by bh.assembly_const_id, bh.district_id
                order by bh.district_id
            ), close_count as (
                select 
                    bh.assembly_const_id, bh.district_id,
                    count(1) as closed,
                    sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                    sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
                    sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
                    sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
                from grievance_master_bh_mat_2 as bh
                    where bh.status = 15 
                     and bh.grievance_generate_date::date between '2021-01-01' and '2025-06-27' 
                group by bh.assembly_const_id, bh.district_id
                order by bh.district_id
            ), pending_count as (
                select 
                    count(1) as pending_cnt, bh.assembly_const_id, bh.district_id
                    from forwarded_latest_3_bh_mat_2 as bh
                    left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
                where bm.grievance_id is null 
                 and bh.assigned_on::date between '2021-01-01' and '2025-06-27' 
                group by bh.assembly_const_id, bh.district_id
                order by bh.district_id
            )
            select
                row_number() over() as sl_no,
                '2025-03-25 02:30:01.720000+00:00'::timestamp as refresh_time_utc,
                '2025-03-25 02:30:01.720000+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
                cdm.district_name as unit_name,
                cdm.district_id as unit_id,
                cam.assembly_name as assembly_name,
                cam.assembly_id as assembly_id,
                coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
                coalesce(ar.atr_received_cnt, 0) as atr_received,
                coalesce(cc.closed, 0) as total_disposed,
                coalesce(cc.bnft_prvd, 0) as benefit_provided,
                coalesce(cc.act_inti, 0) as action_initiated,
                coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
                coalesce(cc.not_elgbl, 0) as non_actionable,
                coalesce(pc.pending_cnt, 0) as total_pending
                from grievance_lodged gl
                left join cmo_assembly_master cam on cam.assembly_id = gl.assembly_const_id
                left join cmo_districts_master cdm on gl.district_id = cdm.district_id
                left join atr_received ar on gl.assembly_const_id = ar.assembly_const_id and gl.district_id = ar.district_id
                left join pending_count pc on gl.assembly_const_id = pc.assembly_const_id and gl.district_id = pc.district_id
                left join close_count cc on gl.assembly_const_id = cc.assembly_const_id and gl.district_id = cc.district_id
--                order by cdm.district_name asc;
                
                
              
                

--CREATE TABLE public.grievance_retruned_data (
--	id int8 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
--	grievance_id int8 NOT NULL,
--	is_returned bool DEFAULT false NOT NULL,
--	status int2 DEFAULT 1 NOT NULL,
--	created_on timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
--	updated_on timestamptz NULL,
--	CONSTRAINT grievance_retruned_data_pkey PRIMARY KEY (id)
--);
                
                
                
                
                
                
                
                
                
                
                
                
select                 
                
                
                
                
                
select * from cmo_domain_lookup_master cdlm where cdlm.domain_type = 'user_type';

select apm.*,
au.admin_user_id,
au.u_phone
from admin_position_master apm 
inner join admin_user_position_mapping aupm on aupm.position_id = apm.position_id and aupm.status = 1
inner join admin_user au on au.admin_user_id = aupm.admin_user_id 
where apm.office_type = 5 and apm.record_status = 1 and au.u_phone = '9732333899';



select * from user_otp where u_phone = '9732333899';

select * from control_json cj;


select * from admin_user_role_master aurm;

select * from user_type_role_mapping utrm;


select current_timestamp;


--======================================================================================
select * from ssm_grievance_data_document_mapping ;




select * from grievance_master gm where gm.grievance_id in (22885,22886,22887,22888,22889);
select * from grievance_master gm where gm.grievance_no in ('SSM5341070','SSM5341071', 'SSM5341073', 'SSM5402913', 'SSM5341072');
select * from grievance_lifecycle gl where gl.grievance_id in (22989
,22990
,22991)



select * from cmo_parameter_master cpm;
select * from cmo_domain_lookup_master cdlm ;

select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 8;
select * from cmo_batch_run_details cbrd where cbrd.data_count > 1;

select * from document_master dm order by doc_id desc;




select * from cmo_grievance_category_master cgcm;


select * from user_token ut where ut.user_id = 10340;