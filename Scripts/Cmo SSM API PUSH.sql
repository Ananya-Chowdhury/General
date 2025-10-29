SELECT * from public.cmo_ssm_api_push_data_count_v2('2025-10-28');


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
		from grievance_lifecycle gl   --24039151
		where gl.grievance_status != 1 
--			and gl.assigned_on::DATE = '2025-10-15'::DATE
			and gl.assigned_on::DATE between '2024-11-12'::DATE and '2025-10-28'::DATE
			/*and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE*/
			/* and gl.assigned_on::DATE = '2025-04-20'::DATE */
	),
	grievance_master_data as (
		select
			gm.grievance_no as griev_id_no,
			LC.assigned_on as assigned_on,
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
--	assigned_on::date
	'2025-10-28'::DATE AS push_date
	/*(current_date - interval '1 day')::DATE as push_date*/
	/*'2025-04-20'::DATE as push_date */ /* Backdated -> 2024-11-12 to 2025-01-01 | 2025-04-11 - 2025-04-22 */ 
from grievance_master_data M
--group by assigned_on;



select * from control_json;

select 
	cspd.push_date,
	cspd.actual_push_date, 
	cspd.status_code, 
	cspd.status,
	cspd.from_row_no,
	cspd.to_row_no,
	cspd.data_count,
	cspd.request,
	cspd.response,
	cspd.is_reprocessed,
	cspd.created_no
from cmo_ssm_push_details cspd 
--where cspd.actual_push_date::date = '2025-10-16' 
where cspd.actual_push_date::date between '2024-11-12' and '2025-10-22' and cspd.status = 'E'
order by cmo_ssm_push_details_id desc;


----- DAY WISE PUSH TOTAL COUNT -----
select 
	cspd.push_date,
--	cspd.actual_push_date, 
--	cspd.status_code, 
--	cspd.status,
--	cspd.from_row_no,
--	cspd.to_row_no,
	sum(cspd.data_count) as total_count
--	cspd.request,
--	cspd.response,
--	cspd.created_no
from cmo_ssm_push_details cspd 
--where cspd.actual_push_date::date = '2025-10-27' 
where cspd.actual_push_date::date between '2024-11-12' and '2025-10-22' /*and cspd.status = 'S'*/
group by cspd.push_date/*, cspd.actual_push_date*/
order by cspd.push_date asc




select *
from cmo_ssm_push_details cspd
where cmo_ssm_push_details_id = 1 ;
--where cspd.actual_push_date::date = '2025-10-16' 
--where cspd.actual_push_date::date between '2024-11-12' and '2025-10-22' and cspd.status = 'E'
--order by cmo_ssm_push_details_id desc;




select 
	count(1) as ssm_push_count 
from grievance_lifecycle gl 
where gl.assigned_on::date = '2025-10-15'::DATE;




---- Daily SSM PUSH Count Check --->>> Correct ----
select count(1) as ssm_push_count 
from grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
--where gl.assigned_on::date = '2025-10-28'::DATE
where gl.assigned_on::date between '2024-11-12' and '2025-10-28'
and gl.grievance_status != 1
and (gm.grievance_source = 5 or gm.received_at = 6);


----- Daily SSM PUSH With Unique Grievance Count Check --->>> Correct ----
select count(1) as ssm_push_count, count(distinct gl.grievance_id) as uniq_grie
from grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
where gl.assigned_on::date = '2025-10-17'::DATE
--where gl.assigned_on::date between '2024-11-12' and '2025-10-20'
and gl.grievance_status != 1
and (gm.grievance_source = 5 or gm.received_at = 6);


SELECT 
    COUNT(1) AS ssm_push_count,
    COUNT(DISTINCT gl.grievance_id) AS uniq_grie
FROM grievance_lifecycle gl
INNER JOIN grievance_master gm 
    ON gm.grievance_id = gl.grievance_id
WHERE gl.assigned_on::date = '2025-10-17'::DATE
  -- OR use this for a date range:
  -- gl.assigned_on::date BETWEEN '2024-11-12' AND '2025-10-20'
  AND gl.grievance_status != 1
  AND (gm.grievance_source = 5 OR gm.received_at = 6)
  group by gl.grievance_id ;