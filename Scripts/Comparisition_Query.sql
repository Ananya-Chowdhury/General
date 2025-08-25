-- DROP FUNCTION public.cmo_ssm_api_push_data_count();

--select * from cmo_ssm_api_push_data_count_v2();


-- New Updated --
CREATE OR REPLACE FUNCTION public.cmo_ssm_api_push_data_count_v2()
 RETURNS TABLE(total_count bigint, push_date date)
 LANGUAGE plpgsql
AS $function$
	begin		
		RETURN QUERY
		-- LATEST UPDATE SSM PUSH DATA (OPTIMIZED)
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
					and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE
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
			(current_date - interval '1 day')::DATE as push_date
			/*'2025-04-20'::DATE as push_date */ /* Backdated -> 2024-11-12 to 2025-01-01 | 2025-04-11 - 2025-04-22 */ 
		from grievance_master_data M;
	END;
$function$
;



---- Previous ---
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
			and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE
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
		    cdlm.domain_value as griev_trans_no_description
		from grievance_trail_data LC
		inner join grievance_master gm on gm.grievance_id = LC.grievance_id and gm.grievance_source = 5
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
		order by LC.grievance_id,LC.lifecycle_id asc
	)
select
	count(1) as total_count,
	(current_date - interval '1 day')::DATE as push_date
	/*'2025-04-20'::DATE as push_date */ /* Backdated -> 2024-11-12 to 2025-01-01 | 2025-04-11 - 2025-04-22 */ 
from grievance_master_data M;






-- previous data --

-- DROP FUNCTION public.cmo_ssm_api_push_data_v2();

select * from public.cmo_ssm_api_push_data_v2(100, 0);

-- updated data --
CREATE OR REPLACE FUNCTION public.cmo_ssm_api_push_data_v2(page_size bigint, page_index bigint)
 RETURNS TABLE(griev_id_no character varying, 
 "USB_Unique_ID" character varying, 
"Sender_Official_Code" character varying, 
"Receiver_Official_Code" character varying, 
"Closure_Reason_Code" character varying, 
"Incoming_Remarks" text, 
"Griev_Active_Status" text, 
attachments text, 
"Action_Taken_Date" timestamp without time zone, 
"Action_Taken" text, 
"Action_Taken_Desc" text, 
"Action_Taken_By" text, 
"ATN_Reason_Desc" text, 
 griev_trans_no smallint, 
"Action_Proposed" text, 
"Contact_Date" date, 
"Tentative_Date" date, 
"Previous_Receipt_Date" date, 
"Previous_ATR_Date" date, 
"Sender_Office_Name" character varying, 
"Sender_Details" character varying, 
"Receiver_Office_Name" character varying, 
"Receiver_Details" character varying, 
"Status" text, 
 griev_trans_no_description character varying,  --24
"Grievance_Lodge_Date" date,  
"Complainant_Name" character varying, 
"Phone_no" character varying, 
"Address" character varying, 
"District" character varying, 
"Block_Municipality" character varying, 
"GP_Ward" character varying,
"Police_Station" character varying, 
"Received_at" character varying, 
"Whether_Emergency" text, 
"Disposal_Date" date, 
"Grievance_category" text, 
"Grievance_Description" text, 
"HOD" character varying, 
"HODs_Last_Remarks" text, 
"ATR_Closure_Reason" character varying)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		RETURN QUERY
	    -- LATEST UPDATE SSM PUSH DATA (OPTIMIZED)
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
					and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE
					/* and gl.assigned_on::DATE = '2025-04-20'::DATE */
			),
			grievance_master_data as (
				select
					gm.grievance_no as griev_id_no,
				    case 
				        when gm.usb_unique_id is null then gm.grievance_no
				        else gm.usb_unique_id
				    end as "USB_Unique_ID",
					case
				    	when aud1.official_code is not null then aud1.official_code
						else 'NA'
					end as "Sender_Official_Code",
					case
				    	when aud2.official_code is not null then aud2.official_code
						else 'NA'
					end as "Receiver_Official_Code",
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
					    when LC.current_atr_date::timestamp without time zone is null then
			    			case 
				    			when LC.grievance_status in (9,11,13,14,15) then LC.assigned_on::timestamp without time zone
			    				else null
			    			end
			    		else LC.current_atr_date::timestamp without time zone
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
					case
				    	when LC.action_proposed is not null then LC.action_proposed 
						else 'NA'
					end as "Action_Proposed",
				    LC.contact_date::date as "Contact_Date",
				    LC.tentative_date::date as "Tentative_Date",
				    LC.prev_recv_date::date as "Previous_Receipt_Date",
				    LC.prev_atr_date::date as "Previous_ATR_Date",
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
					gm.grievance_generate_date::date as "Grievance_Lodge_Date",           -- New Required Field Added --
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
						when gm.status = 15 then gm.grievence_close_date::date
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
				left join cmo_domain_lookup_master cdlm1 on gm.received_at = cdlm1.domain_code and cdlm1.domain_type = 'received_at_location'
				left join cmo_districts_master cdm3 on cdm3.district_id = gm.district_id
				left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
				left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
				left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gm.gp_id
				left join cmo_wards_master cwm on cwm.ward_id = gm.ward_id
				left join cmo_police_station_master cpsm on cpsm.ps_id = gm.police_station_id
				left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
				left join cmo_office_master com on com.office_id = gm.assigned_by_office_id /*or com.office_id = gm.atr_submit_by_lastest_office_id*/
				left join cmo_office_master com3 on com3.office_id = gm.atr_submit_by_lastest_office_id
				order by LC.grievance_id, LC.lifecycle_id asc limit page_size offset page_index
			)
		select
			M.*
		from grievance_master_data M;
	END;
$function$
;


----------------------------------------------------------=============================================================================================

---- Listing query ----

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
			and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE
			/* and gl.assigned_on::DATE = '2025-04-20'::DATE */
	),
	grievance_master_data as (
		select
			gm.grievance_no as griev_id_no,
		    case 
		        when gm.usb_unique_id is null then gm.grievance_no
		        else gm.usb_unique_id
		    end as "USB_Unique_ID",
			case
		    	when aud1.official_code is not null then aud1.official_code
				else 'NA'
			end as "Sender_Official_Code",
			case
		    	when aud2.official_code is not null then aud2.official_code
				else 'NA'
			end as "Receiver_Official_Code",
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
			    when LC.current_atr_date::timestamp without time zone is null then
	    			case 
		    			when LC.grievance_status in (9,11,13,14,15) then LC.assigned_on::timestamp without time zone
	    				else null
	    			end
	    		else LC.current_atr_date::timestamp without time zone
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
			case
		    	when LC.action_proposed is not null then LC.action_proposed 
				else 'NA'
			end as "Action_Proposed",
		    LC.contact_date::date as "Contact_Date",
		    LC.tentative_date::date as "Tentative_Date",
		    LC.prev_recv_date::date as "Previous_Receipt_Date",
		    LC.prev_atr_date::date as "Previous_ATR_Date",
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
			gm.grievance_generate_date::date as "Grievance_Lodge_Date",           -- New Required Field Added --
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
				when gm.status = 15 then gm.grievence_close_date::date
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
		left join cmo_domain_lookup_master cdlm1 on gm.received_at = cdlm1.domain_code and cdlm1.domain_type = 'received_at_location'
		left join cmo_districts_master cdm3 on cdm3.district_id = gm.district_id
		left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
		left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
		left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gm.gp_id
		left join cmo_wards_master cwm on cwm.ward_id = gm.ward_id
		left join cmo_police_station_master cpsm on cpsm.ps_id = gm.police_station_id
		left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
		left join cmo_office_master com on com.office_id = gm.assigned_by_office_id /*or com.office_id = gm.atr_submit_by_lastest_office_id*/
		left join cmo_office_master com3 on com3.office_id = gm.atr_submit_by_lastest_office_id
		order by LC.grievance_id, LC.lifecycle_id asc limit page_size offset page_index
	)
select
	M.*
from grievance_master_data M;


---- Total Query ---
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
			and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE
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
	(current_date - interval '1 day')::DATE as push_date
from grievance_master_data M;






























----------------------------------

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
					and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE
					/* and gl.assigned_on::DATE = '2025-04-20'::DATE */
			),
			grievance_master_data as (
				select
					gm.grievance_no as griev_id_no,
				    case 
				        when gm.usb_unique_id is null then gm.grievance_no
				        else gm.usb_unique_id
				    end as "USB_Unique_ID",
					case
				    	when aud1.official_code is not null then aud1.official_code
						else 'NA'
					end as "Sender_Official_Code",
					case
				    	when aud2.official_code is not null then aud2.official_code
						else 'NA'
					end as "Receiver_Official_Code",
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
					    when LC.current_atr_date::timestamp without time zone is null then
			    			case 
				    			when LC.grievance_status in (9,11,13,14,15) then LC.assigned_on::timestamp without time zone
			    				else null
			    			end
			    		else LC.current_atr_date::timestamp without time zone
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
					case
				    	when LC.action_proposed is not null then LC.action_proposed 
						else 'NA'
					end as "Action_Proposed",
				    LC.contact_date::date as "Contact_Date",
				    LC.tentative_date::date as "Tentative_Date",
				    LC.prev_recv_date::date as "Previous_Receipt_Date",
				    LC.prev_atr_date::date as "Previous_ATR_Date",
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
					gm.grievance_generate_date::date as "Grievance_Lodge_Date",           -- New Required Field Added --
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
						when gm.status = 15 then gm.grievence_close_date::date
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
				left join cmo_domain_lookup_master cdlm1 on gm.received_at = cdlm1.domain_code and cdlm1.domain_type = 'received_at_location'
				left join cmo_districts_master cdm3 on cdm3.district_id = gm.district_id
				left join cmo_blocks_master cbm on cbm.block_id = gm.block_id
				left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id
				left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gm.gp_id
				left join cmo_wards_master cwm on cwm.ward_id = gm.ward_id
				left join cmo_police_station_master cpsm on cpsm.ps_id = gm.police_station_id
				left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = gm.grievance_category
				left join cmo_office_master com on com.office_id = gm.assigned_by_office_id /*or com.office_id = gm.atr_submit_by_lastest_office_id*/
				left join cmo_office_master com3 on com3.office_id = gm.atr_submit_by_lastest_office_id
				order by LC.grievance_id, LC.lifecycle_id asc limit 5000 offset 60000
			)
		select
			M.*
		from grievance_master_data M;
		
	
	
	
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
					and gl.assigned_on::DATE = (current_date - interval '1 day')::DATE
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
			(current_date - interval '1 day')::DATE as push_date
			/*'2025-04-20'::DATE as push_date */ /* Backdated -> 2024-11-12 to 2025-01-01 | 2025-04-11 - 2025-04-22 */ 
		from grievance_master_data M;
		
	
	
	----------------------------------------------------------
	
--	 DROP FUNCTION public.cmo_ssm_api_push_data_count_v2();

CREATE OR REPLACE FUNCTION public.cmo_ssm_api_push_data_count_v2(in_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS TABLE(total_count bigint, push_date date)
 LANGUAGE plpgsql
AS $function$
DECLARE
    effective_date date;
BEGIN
    -- Use the provided date if not null, else use current_date
    effective_date := COALESCE(in_date::date, (current_date - interval '1 day')::date);
	RETURN QUERY
	-- LATEST UPDATE SSM PUSH DATA (OPTIMIZED)
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
	END;
$function$
;




------------------------------------------------------------------------------------------------------------------------------


with uinion_part as (       
        select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35 
        union
        select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35  
)
Select Count(1)  
    from grievance_master md
    inner join uinion_part as lu on lu.grievance_id = md.grievance_id 
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id

    
    ---------------- Listing----------------
with uinion_part as (       
    select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
    union
    select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35            
        )
       SELECT distinct
                md.grievance_id, 
                /* 
        CASE 
            -- WHEN (lu.grievance_status = 3 OR glsubq.grievance_status = 14) THEN 0
            -- WHEN (lu.grievance_status = 5 OR glsubq.grievance_status = 13) THEN 1
            when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
            when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13) then 1
            ELSE NULL
        END AS received_from_other_hod_flag,
        lu.grievance_status AS last_grievance_status,
        lu.assigned_on AS last_assigned_on,
        lu.assigned_to_office_id AS last_assigned_to_office_id,
        lu.assigned_by_office_id AS last_assigned_by_office_id,
        lu.assigned_by_position AS last_assigned_by_position,
        lu.assigned_to_position AS last_assigned_to_position,
        */
        NULL AS received_from_other_hod_flag,
        NULL AS last_grievance_status,
        NULL AS last_assigned_on,
        NULL AS last_assigned_to_office_id,
        NULL AS last_assigned_by_office_id,
        NULL AS last_assigned_by_position,
        NULL AS last_assigned_to_position,
        md.grievance_no,
        md.grievance_description,
        md.grievance_source,
        NULL AS grievance_source_name,
        md.applicant_name,
        md.pri_cont_no,
        md.grievance_generate_date,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        cdm2.district_name,
        md.block_id,
        cbm.block_name,
        md.municipality_id,
        cmm.municipality_name,
        CASE 
            WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
            WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
            ELSE NULL
        END AS block_or_municipalty_name,
        md.gp_id,
        cgpm.gp_name,
        md.ward_id,
        cwm.ward_name,
        CASE 
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
            ELSE NULL
        END AS gp_or_ward_name,
        md.atn_id,
        COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
        COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
        COALESCE(md.current_atr_date, NULL) AS current_atr_date,
        md.assigned_to_position,
        CASE 
            WHEN md.assigned_to_office_id IS NULL THEN 'N/A'
            WHEN md.assigned_to_office_id = 5 THEN 'Pending At CMO'
--            ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, - '( ', cmo_sub_office_master.suboffice_name, ' ) ] ')  
            ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' (', csom.suboffice_name, ') ]')   
        END AS assigned_to_office_name,
        md.assigned_to_id,
        CASE 
            WHEN md.status = 1 THEN md.grievance_generate_date
            ELSE md.updated_on -- + interval '5 hour 30 Minutes' 
        END AS updated_on,
        md.status,
        cdlm.domain_value AS status_name,
        cdlm.domain_abbr AS grievance_status_code,
        md.emergency_flag,
        md.police_station_id,
        cpsm.ps_name  
    FROM grievance_master md
    INNER JOIN uinion_part as lu ON lu.grievance_id = md.grievance_id
    LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
    LEFT JOIN cmo_office_master com ON com.office_id = md.assigned_to_office_id
    LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
    LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_type = 'grievance_status' AND cdlm.domain_code = md.status
    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = md.assigned_to_position AND aupm.status = 1
    LEFT JOIN admin_user_details ad ON ad.admin_user_id = aupm.admin_user_id
    LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
    LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position 
    LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
    LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm2.designation_id
    LEFT JOIN cmo_office_master com2 ON com2.office_id = apm2.office_id 
    LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm2.role_master_id
    LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
    LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id 
    LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
    LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
    LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
      order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc offset 30 limit 10 
    --------------------------------------------------------------------------------- TESTING ----------------------------------------------------------------------
      
      with uinion_part as (       
                    select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
                    union
                    select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
            )
           SELECT distinct
                    md.grievance_id, 
                    /* 
                    CASE 
                        -- WHEN (lu.grievance_status = 3 OR glsubq.grievance_status = 14) THEN 0
                        -- WHEN (lu.grievance_status = 5 OR glsubq.grievance_status = 13) THEN 1
                        when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                        when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13) then 1
                        ELSE NULL
                    END AS received_from_other_hod_flag,
                    lu.grievance_status AS last_grievance_status,
                    lu.assigned_on AS last_assigned_on,
                    lu.assigned_to_office_id AS last_assigned_to_office_id,
                    lu.assigned_by_office_id AS last_assigned_by_office_id,
                    lu.assigned_by_position AS last_assigned_by_position,
                    lu.assigned_to_position AS last_assigned_to_position,
                    */
                    NULL AS received_from_other_hod_flag,
                    NULL AS last_grievance_status,
                    NULL AS last_assigned_on,
                    NULL AS last_assigned_to_office_id,
                    NULL AS last_assigned_by_office_id,
                    NULL AS last_assigned_by_position,
                    NULL AS last_assigned_to_position,
                    md.grievance_no,
                    md.grievance_description,
                    md.grievance_source,
                    NULL AS grievance_source_name,
                    md.applicant_name,
                    md.pri_cont_no,
                    md.grievance_generate_date,
                    md.grievance_category,
                    cgcm.grievance_category_desc,
                    md.assigned_to_office_id,
                    com.office_name,
                    md.district_id,
                    cdm2.district_name,
                    md.block_id,
                    cbm.block_name,
                    md.municipality_id,
                    cmm.municipality_name,
                    CASE 
                        WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
                        WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
                        ELSE NULL
                    END AS block_or_municipalty_name,
                    md.gp_id,
                    cgpm.gp_name,
                    md.ward_id,
                    cwm.ward_name,
                    CASE 
                        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
                        ELSE NULL
                    END AS gp_or_ward_name,
                    md.atn_id,
                    COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
                    COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
                    COALESCE(md.current_atr_date, NULL) AS current_atr_date,
                    md.assigned_to_position,
                    CASE 
                        WHEN md.assigned_to_office_id IS NULL THEN 'N/A'
                        WHEN md.assigned_to_office_id = 5 THEN 'Pending At CMO'
                        -- ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] ')  
                        ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ' - ', csom.suboffice_name, ') ]') 
                    END AS assigned_to_office_name,
                    md.assigned_to_id,
                    CASE 
                        WHEN md.status = 1 THEN md.grievance_generate_date
                        ELSE md.updated_on -- + interval '5 hour 30 Minutes' 
                    END AS updated_on,
                    md.status,
                    cdlm.domain_value AS status_name,
                    cdlm.domain_abbr AS grievance_status_code,
                    md.emergency_flag,
                    md.police_station_id,
                    cpsm.ps_name  
                FROM grievance_master md
                INNER JOIN uinion_part as lu ON lu.grievance_id = md.grievance_id
                LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
                LEFT JOIN cmo_office_master com ON com.office_id = md.assigned_to_office_id
                LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
                LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_type = 'grievance_status' AND cdlm.domain_code = md.status
                LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = md.assigned_to_position AND aupm.status = 1
                LEFT JOIN admin_user_details ad ON ad.admin_user_id = aupm.admin_user_id
                LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
                LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position 
                LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
                LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm2.designation_id
                LEFT JOIN cmo_office_master com2 ON com2.office_id = apm2.office_id 
                LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm2.role_master_id
                LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
                LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id 
                LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
                LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
                LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id    
                left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id        
                  order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 10 
                  
                  
                  
                  
    select count(1) from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
    union
    select count(1) from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
    
    
    
    
with uinion_part as (       
        select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35 
        union
        select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
)
Select Count(1)  
    from grievance_master md
    inner join uinion_part as lu on lu.grievance_id = md.grievance_id 
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
    
    
    
    
    
    with uinion_part as (       
        select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35 
        union
        select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
)
Select Count(1)  
    from grievance_master md
    inner join uinion_part as lu on lu.grievance_id = md.grievance_id
--    inner join forwarded_latest_3_bh_mat_2 as lu on lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
--    inner join forwarded_latest_5_bh_mat_2 as luu on luu.grievance_id = md.grievance_id  and luu.assigned_to_office_id = 35
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
    
    
    
    
    
   Select Count(1)  
    from grievance_master md
    inner join forwarded_latest_3_bh_mat_2 as lu on lu.grievance_id = md.grievance_id 
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id             
  where lu.assigned_to_office_id = 35  
    
  
  
  
  
  -------------------------------------------------------------------------------- MIS NEW CHange --------------------------------------------------------------------------------
  
  with raw_data as (
    select grievance_master_bh_mat.*
    from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
    inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
    where forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
            and not exists (
    select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat 
                    where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id
                            and atr_latest_14_bh_mat.current_status in (14,15))
                ), unassigned_cmo as (
                    select  
                        'Unassigned (CMO)' as status,
                        null as name_and_esignation_of_the_user,
                        'N/A' as office,
                        null as user_role,
                        null as user_status,
                        null as status_id,
                        count(1) as pending_grievances,
                        null::int as pending_atrs,
                        null::int as atr_returned_for_review,
                        null::int as atr_auto_returned_from_cmo,
                        count(1) as total_count
                    from raw_data
                    where raw_data.status = 3 
                ), unassigned_other_hod as (
                    select  
                        'Unassigned (Other HoD)' as status,
                        null as name_and_esignation_of_the_user,
                        'N/A' as office,
                        null as user_role,
                        null as user_status,
                        null as status_id,
                        0 as pending_grievances,
                        null::int as pending_atrs,
                        null::int as atr_returned_for_review,
                        null::int as atr_auto_returned_from_cmo,
                        0 as total_count
                ), recalled as (
                    select  
                        'Recalled' as status,
                        null as name_and_esignation_of_the_user,
                        'N/A' as office,
                        null as user_role,
                        null as user_status,
                        null as status_id,
                        count(1) as pending_grievances,
                        null::int as pending_atrs,
                        null::int as atr_returned_for_review,
                        null::int as atr_auto_returned_from_cmo,
                        count(1) as total_count
                    from raw_data
                    where raw_data.status = 16
                ), user_wise_pndcy as (
                    select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_role, xx.user_status, xx.status_id::text, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review, 
                        xx.atr_auto_returned_from_cmo, xx.total_count
                    from (
                        select 'User wise ATR Pendency' as status,
                            -- admin_user_details.official_name as name_and_esignation_of_the_user, 
                            case when admin_user_details.official_name is not null 
                                    then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )') 
                                else null
                            end as name_and_esignation_of_the_user,
                            -- cmo_office_master.office_name as office,
                            case 
                                when cmo_sub_office_master.suboffice_name is not null 
                                    then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
                                else cmo_office_master.office_name
                            end as office,
                            case when admin_position_master.office_id in (35) /*REPLACE*/ then admin_user_role_master.role_master_name 
                                    else concat(admin_user_role_master.role_master_name, ' (Other HOD)') 
                            end as user_role,
                            admin_position_master.record_status as status_id,
                            case when admin_position_master.record_status = 1 then 'Active'
                            	else 'Inactive'
                            end as user_status,
                            case when admin_position_master.office_id in (35) /*REPLACE*/ then 1 else 2 end as "type",
                            sum(case when raw_data.status in (4,5,7,8,8888) then 1 else 0 end) as "pending_grievances",
                            sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs", 
                            sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review", 
                            case when admin_position_master.office_id in (35) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end) 
                                    else null::int 
                            end as "atr_auto_returned_from_cmo",
                            count(1) as total_count
                        from raw_data
                        left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id 
                        left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
                        left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
                        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
                        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
                        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
                        where raw_data.status not in (3,16)  
                        group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name, 
                                admin_user_role_master.role_master_id, admin_user_role_master.role_master_name, cmo_designation_master.designation_name,
                                cmo_sub_office_master.suboffice_name, admin_position_master.record_status
                        order by type, admin_user_role_master.role_master_id
                    )xx 
                ), union_part as (
                    select * from unassigned_cmo
                        union all 
                    select * from unassigned_other_hod
                        union all
                    select * from recalled
                        union all
                    select * from user_wise_pndcy
                )
                select
                    row_number() over() as sl_no,
                    '2025-05-14 16:30:01.921000+00:00'::timestamp as refresh_time_utc,
                    '2025-05-14 16:30:01.921000+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
                    * 
                from union_part
                
                
                
   --------------------------------------------------------------------------------- MIS REcord UPdate -------------------------------------------------------------------
           
 ------ pending grievance -------               
               
with raw_data as (
    select grievance_master_bh_mat.*
        from forwarded_latest_5_bh_mat_2 as bh
        inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
        where bh.assigned_to_office_id in (35)
            and not exists ( select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id )
), unassigned_cmo as (
    select
        'Unassigned (CMO)' as status,
null as name_and_esignation_of_the_user,
'N/A' as office,
        null as user_status,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
), unassigned_other_hod as (
    select
        'Unassigned (Other HoD)' as status,
null as name_and_esignation_of_the_user,
'N/A' as office,
        null as user_status,
        count(1) as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        count(1) as total_count
        from raw_data
        where raw_data.status = 5
), recalled as (
    select
        'Recalled' as status,
null as name_and_esignation_of_the_user,
'N/A' as office,
        null as user_status,
        0 as pending_grievances,
        null::int as pending_atrs,
        null::int as atr_returned_for_review,
        null::int as atr_auto_returned_from_cmo,
        0 as total_count
), user_wise_pndcy as (
    select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_status, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review,
        xx.atr_auto_returned_from_cmo, xx.total_count
    from (
        select 'User wise ATR Pendency' as status,
    case when admin_user_details.official_name is not null
            then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
        else null
    end as name_and_esignation_of_the_user,
    case
        when cmo_sub_office_master.suboffice_name is not null
            then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
        else cmo_office_master.office_name
    end as office,
    
    
    
    case when admin_position_master.office_id in (35) /*REPLACE*/ then admin_user_role_master.role_master_name
            else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
    end as "user_status",
    case when admin_position_master.office_id in (35) /*REPLACE*/ then 1 else 2 end as "type",
    sum(case when raw_data.status in (4,7,8,8888) then 1 else 0 end) as "pending_grievances",
    sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
    sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
    case when admin_position_master.office_id in (35) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
            else null::int
    end as "atr_auto_returned_from_cmo",
            count(1) as total_count
        from raw_data
        left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id
        left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
        left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
        where raw_data.status != 5
        group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name,
                admin_user_role_master.role_master_id, admin_user_role_master.role_master_name, cmo_designation_master.designation_name,
                cmo_sub_office_master.suboffice_name
        order by type, admin_user_role_master.role_master_id
    )xx
), union_part as (
    select * from unassigned_cmo
        union all
    select * from unassigned_other_hod
        union all
    select * from recalled
        union all
    select * from user_wise_pndcy
)
select
    row_number() over() as sl_no,
    '2025-05-14 16:30:01.921000+00:00'::timestamp as refresh_time_utc,
'2025-05-14 16:30:01.921000+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    *
from union_part



SELECT 
    com.office_id,
    com.office_name,
    COUNT(lu.grievance_id) AS grievance_count
FROM 
    cmo_office_master com
LEFT JOIN forwarded_latest_5_bh_mat_2 lu 
    ON lu.assigned_to_office_id = com.office_id
LEFT JOIN grievance_master_bh_mat_2 md 
    ON md.grievance_id = lu.grievance_id
GROUP BY 
    com.office_id, com.office_name
ORDER BY 
    com.office_name;




SELECT 
    com.office_id,
    com.office_name,
    COUNT(bh.grievance_id) AS grievance_count
FROM 
    cmo_office_master com
LEFT JOIN 
    forwarded_latest_5_bh_mat_2 bh ON com.office_id = bh.assigned_to_office_id
LEFT JOIN 
    grievance_master_bh_mat_2 gm ON gm.grievance_id = bh.grievance_id
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM atr_latest_13_bh_mat_2 bm 
        WHERE bm.grievance_id = bh.grievance_id
    )
GROUP BY 
    com.office_id, com.office_name
ORDER BY 
    com.office_name;




select count(1), com.office_name
    from forwarded_latest_5_bh_mat_2 as bh
    inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
    left join cmo_office_master com on com.office_id = bh.assigned_to_office_id 
--    where bh.assigned_to_office_id in (35)
        and not exists ( select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id )
        group by com.office_name 
        order by com.office_name;


select  grievance_master_bh_mat.*
from forwarded_latest_5_bh_mat_2 as bh
inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
        where bh.assigned_to_office_id in (35)
            and not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id )
			and not exists (
				   Select 1
					from grievance_master_bh_mat md
					inner join forwarded_latest_5_bh_mat_2 as lu on lu.grievance_id = md.grievance_id
					left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
					left join cmo_office_master com on com.office_id = md.assigned_to_office_id
					left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
					left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
					left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
					    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
					    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
					    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
					    left join admin_position_master apm on apm.position_id = md.updated_by_position
					    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
					    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
					    left join cmo_office_master com2 on com2.office_id = apm2.office_id
					    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
					    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
					    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
					    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
					    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
					    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
					  where lu.assigned_to_office_id = 35 and md.grievance_id = lu.grievance_id
			); -- 4661





------------------------------------------------ REGISTER ----------------------------
			
			
SELECT 
    com.office_id,
    com.office_name,
    COUNT(lu.grievance_id) AS grievance_count
FROM 
    cmo_office_master com
LEFT JOIN forwarded_latest_5_bh_mat_2 lu 
    ON lu.assigned_to_office_id = com.office_id
LEFT JOIN grievance_master_bh_mat_2 md 
    ON md.grievance_id = lu.grievance_id
GROUP BY 
    com.office_id, com.office_name
ORDER BY 
    com.office_name;
   
  
   
   ------ Grievance Register For Other HOD ------
   Select 
    com3.office_name, Count(1)
    from grievance_master_bh_mat_2 md
    inner join forwarded_latest_5_bh_mat_2 as lu on lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
--  where lu.assigned_to_office_id = 35
    group by com3.office_name
	order by com3.office_name;
			
			
			
			
Select 
    com3.office_name, Count(1)
    from grievance_master_bh_mat_2 md
    inner join forwarded_latest_5_bh_mat_2 as lu on lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
--  where lu.assigned_to_office_id = 35
    group by com3.office_name
	order by com3.office_name;
   
   


---------
   Select com3.office_name, Count(1)
	from grievance_master_bh_mat md
	inner join forwarded_latest_3_bh_mat as lu on lu.grievance_id = md.grievance_id
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
	left join cmo_office_master com on com.office_id = md.assigned_to_office_id
	left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
	left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
	left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
	    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
	    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
	    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
	    left join admin_position_master apm on apm.position_id = md.updated_by_position
	    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
	    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
	    left join cmo_office_master com2 on com2.office_id = apm2.office_id
	    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
	    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
	    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
	    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
	    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
	    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
	  where md.status not in (14,15)
	 group by com3.office_name
	 order by com3.office_name;


--------------------------------------------------------------------------------------------------------------------------

 with pnd_union_data as (
	select forwarded_latest_3_bh_mat.grievance_id
	from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	left join /* VARIABLE */ atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and
	                                atr_latest_14_bh_mat.current_status in (14,15)
	where atr_latest_14_bh_mat.grievance_id is null
	      /* VARIABLE */  and forwarded_latest_3_bh_mat.assigned_to_office_id in (6)
      /* NEW VARIABLE */
	union
	select bh.grievance_id
		from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
		left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
		where bm.grievance_id is null
		    /* VARIABLE */  and bh.assigned_to_office_id in (36)
		    /* NEW VARIABLE */
), pnd_raw_data as (
    select grievance_master_bh_mat.*
        from pnd_union_data as bh
        inner join /* VARIABLE */ grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
), pnd as (
    select admin_position_master.office_id, pnd_raw_data.grievance_category, count(1) as pending,
        sum(case when ba.days_diff >= 7 then 1 else 0 end) as beyond_7_d
        from pnd_raw_data
    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
    left join /* VARIABLE */ pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
where pnd_raw_data.status not in (3, 5, 16)  and (/* VARIABLE */ admin_position_master.office_id not in (36) or admin_position_master.office_id is null)
    group by admin_position_master.office_id, pnd_raw_data.grievance_category
), fwd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        where /* VARIABLE */ forwarded_latest_3_bh_mat.assigned_to_office_id in (36)
        /* NEW VARIABLE */
    union
select bh.grievance_id from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh where /* VARIABLE */ bh.assigned_to_office_id in (36)
        /* NEW VARIABLE */
), fwd_atr as (
    select forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category,
        count(forwarded_latest_5_bh_mat.grievance_id) as forwarded,
        count(atr_latest_13_bh_mat.grievance_id) as atr_received
    from fwd_union_data
    left join /* VARIABLE */ forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = fwd_union_data.grievance_id
left join /* VARIABLE */ atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
                                                            and atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
                                                            /* VARIABLE */ and atr_latest_13_bh_mat.assigned_to_office_id in (36)
where /* VARIABLE */ forwarded_latest_5_bh_mat.assigned_by_office_id in (36)
    group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category
), processing_unit as (
    select
        /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00':: timestamp as refresh_time_utc,
    /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    coalesce(com.office_name,'N/A') as office_name,
    coalesce(cgcm.grievance_category_desc,'N/A') as grievance_category_desc,
    com.office_id,
    cgcm.parent_office_id,
    coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
    coalesce(fwd_atr.atr_received, 0) AS atr_received,
    coalesce(pnd.beyond_7_d, 0) AS atr_pending_beyond_7d,
    coalesce(pnd.pending, 0) AS atr_pending
from fwd_atr
left join cmo_office_master com on com.office_id = fwd_atr.assigned_to_office_id
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fwd_atr.grievance_category
full join pnd on fwd_atr.assigned_to_office_id = pnd.office_id and fwd_atr.grievance_category = pnd.grievance_category
where 1=1
        /* VARIABLE */
        /* VARIABLE */
    order by com.office_name, cgcm.grievance_category_desc
)
select row_number() over() as sl_no, processing_unit.* from processing_unit




 with pnd_union_data as (
		select forwarded_latest_3_bh_mat.grievance_id
		from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		left join /* VARIABLE */ atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and
		                                atr_latest_14_bh_mat.current_status in (14,15)
		where atr_latest_14_bh_mat.grievance_id is null
		      /* VARIABLE */  and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
		      /* NEW VARIABLE */
		union
		select bh.grievance_id
		from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
		left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
		where bm.grievance_id is null
		    /* VARIABLE */  and bh.assigned_to_office_id in (35)
		    /* NEW VARIABLE */
), pnd_raw_data as (
    select grievance_master_bh_mat.*
        from pnd_union_data as bh
        inner join /* VARIABLE */ grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
), pnd as (
    select admin_position_master.office_id, pnd_raw_data.grievance_category, count(1) as pending,
        sum(case when ba.days_diff >= 7 then 1 else 0 end) as beyond_7_d
        from pnd_raw_data
    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
    left join /* VARIABLE */ pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
where pnd_raw_data.status not in (3, 5, 16)  and (/* VARIABLE */ admin_position_master.office_id not in (35) or admin_position_master.office_id is null)
    group by admin_position_master.office_id, pnd_raw_data.grievance_category
), fwd_union_data as (
    select forwarded_latest_3_bh_mat.grievance_id from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        where /* VARIABLE */ forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
        /* NEW VARIABLE */
    union
select bh.grievance_id from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh where /* VARIABLE */ bh.assigned_to_office_id in (35)
        /* NEW VARIABLE */
), fwd_atr as (
    select forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category,
        count(forwarded_latest_5_bh_mat.grievance_id) as forwarded,
        count(atr_latest_13_bh_mat.grievance_id) as atr_received
    from fwd_union_data
    left join /* VARIABLE */ forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = fwd_union_data.grievance_id
left join /* VARIABLE */ atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = fwd_union_data.grievance_id
                                                            and atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
                                                            /* VARIABLE */ and atr_latest_13_bh_mat.assigned_to_office_id in (35)
where /* VARIABLE */ forwarded_latest_5_bh_mat.assigned_by_office_id in (35)
    group by forwarded_latest_5_bh_mat.assigned_to_office_id, forwarded_latest_5_bh_mat.grievance_category
), processing_unit as (
    select
        /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00':: timestamp as refresh_time_utc,
    /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    coalesce(com.office_name,'N/A') as office_name,
--    coalesce(cgcm.grievance_category_desc,'N/A') as grievance_category_desc,
    com.office_id,
--    cgcm.parent_office_id,
    coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
    coalesce(fwd_atr.atr_received, 0) AS atr_received,
    coalesce(pnd.beyond_7_d, 0) AS atr_pending_beyond_7d,
    coalesce(pnd.pending, 0) AS atr_pending
from fwd_atr
left join cmo_office_master com on com.office_id = fwd_atr.assigned_to_office_id
--left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fwd_atr.grievance_category
full join pnd on fwd_atr.assigned_to_office_id = pnd.office_id and fwd_atr.grievance_category = pnd.grievance_category
where 1=1
        /* VARIABLE */
        /* VARIABLE */
    order by com.office_name, com.office_id
)
select row_number() over() as sl_no, processing_unit.* from processing_unit



---- correct ----

 with pnd_union_data as (
		select forwarded_latest_3_bh_mat.grievance_id
		from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
		left join atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and
		                                atr_latest_14_bh_mat.current_status in (14,15)
		where atr_latest_14_bh_mat.grievance_id is null
		      /* VARIABLE */  and forwarded_latest_3_bh_mat.assigned_to_office_id in (35)
		      /* NEW VARIABLE */
		union
		select bh.grievance_id
		from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
		left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
		where bm.grievance_id is null
		    /* VARIABLE */  and bh.assigned_to_office_id in (35)
		    /* NEW VARIABLE */
), pnd_raw_data as (
    select grievance_master_bh_mat.*
        from pnd_union_data as bh
        inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
), pnd as (
    select admin_position_master.office_id, pnd_raw_data.grievance_category, count(1) as pending,
        sum(case when ba.days_diff >= 7 then 1 else 0 end) as beyond_7_d
        from pnd_raw_data
    left join admin_position_master on admin_position_master.position_id = pnd_raw_data.assigned_to_position
    left join pending_for_other_hod_wise_mat_2 as ba on pnd_raw_data.grievance_id = ba.grievance_id
where pnd_raw_data.status not in (3, 5, 16)  and (admin_position_master.office_id not in (35) or admin_position_master.office_id is null)
    group by admin_position_master.office_id, pnd_raw_data.grievance_category
), processing_unit as (
    select
        '2025-05-15 16:30:01.507109+00:00':: timestamp as refresh_time_utc,
    '2025-05-15 16:30:01.507109+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    coalesce(com.office_name,'N/A') as office_name,
    com.office_id,
    coalesce(pnd.beyond_7_d, 0) AS atr_pending_beyond_7d,
    coalesce(pnd.pending, 0) AS atr_pending
from pnd 
left join cmo_office_master com on com.office_id = pnd.assigned_to_office_id
full join pnd on pnd_union_data.assigned_to_office_id = pnd.office_id
where 1=1
    order by com.office_name, com.office_id
)
select row_number() over() as sl_no, processing_unit.* from processing_unit



WITH pnd_union_data AS (
    SELECT f3.grievance_id
    FROM forwarded_latest_3_bh_mat_2 AS f3
    LEFT JOIN atr_latest_14_bh_mat_2 AS a14 ON a14.grievance_id = f3.grievance_id AND a14.current_status IN (14,15)
    left join cmo_office_master AS com ON com.office_id = f3.assigned_to_office_id
    WHERE a14.grievance_id IS NULL
        /*AND f3.assigned_to_office_id IN (35)*/
    UNION
    SELECT f5.grievance_id
    FROM forwarded_latest_5_bh_mat_2 AS f5
    LEFT JOIN atr_latest_13_bh_mat_2 AS a13 ON a13.grievance_id = f5.grievance_id
    left join cmo_office_master AS com ON com.office_id = f5.assigned_to_office_id
    WHERE a13.grievance_id IS NULL
        /*AND f5.assigned_to_office_id IN (35)*/
),
pnd_raw_data AS (
    SELECT gm.*
    FROM pnd_union_data AS bh
    INNER JOIN grievance_master_bh_mat_2 AS gm ON gm.grievance_id = bh.grievance_id
),
pnd AS (
    SELECT 
        apm.office_id, 
        grv.grievance_category, 
        COUNT(1) AS pending,
        SUM(CASE WHEN pf.days_diff >= 7 THEN 1 ELSE 0 END) AS beyond_7_d
    FROM pnd_raw_data AS grv
    LEFT JOIN admin_position_master AS apm ON apm.position_id = grv.assigned_to_position
    LEFT JOIN pending_for_other_hod_wise_mat_2 AS pf ON grv.grievance_id = pf.grievance_id
    WHERE grv.status NOT IN (3, 5, 16) AND (apm.office_id NOT IN (35) OR apm.office_id IS NULL)
    GROUP BY apm.office_id, grv.grievance_category
),
processing_unit AS (
    SELECT
        '2025-05-15 16:30:01.507109+00:00'::timestamp AS refresh_time_utc,
        '2025-05-15 16:30:01.507109+00:00'::timestamp + INTERVAL '5 hour 30 minutes' AS refresh_time_ist,
        COALESCE(com.office_name, 'N/A') AS office_name,
        pnd.office_id,
        SUM(pnd.beyond_7_d) AS atr_pending_beyond_7d,
        SUM(pnd.pending) AS atr_pending
    FROM pnd
    LEFT JOIN cmo_office_master AS com ON com.office_id = pnd.office_id
    GROUP BY pnd.office_id, com.office_name
)
SELECT 
    ROW_NUMBER() OVER () AS sl_no, 
    processing_unit.*
FROM processing_unit
ORDER BY office_name, office_id;




select * from cmo_office_master com ;

--------------------------------------------------------------------------------------------------------------------
WITH pnd_union_data AS (
    SELECT f3.grievance_id, f3.assigned_by_office_id
    FROM forwarded_latest_3_bh_mat_2 AS f3
    LEFT JOIN atr_latest_14_bh_mat_2 AS a14 ON a14.grievance_id = f3.grievance_id AND a14.current_status IN (14,15)
--    left join cmo_office_master AS com ON com.office_id = f3.assigned_to_office_id
    WHERE a14.grievance_id IS NULL
        AND f3.assigned_to_office_id IN (35)
    UNION
    SELECT f5.grievance_id, f5.assigned_by_office_id
    FROM forwarded_latest_5_bh_mat_2 AS f5
    LEFT JOIN atr_latest_13_bh_mat_2 AS a13 ON a13.grievance_id = f5.grievance_id
--    left join cmo_office_master AS com ON com.office_id = f5.assigned_to_office_id
    WHERE a13.grievance_id IS NULL
        AND f5.assigned_to_office_id IN (35)
),
pnd_raw_data AS (
    SELECT gm.*
    FROM pnd_union_data AS bh
    INNER JOIN grievance_master_bh_mat_2 AS gm ON gm.grievance_id = bh.grievance_id
),
pnd AS (
    SELECT 
        apm.office_id, 
        grv.assigned_by_office_id,
        COUNT(1) AS pending,
        SUM(CASE WHEN pf.days_diff >= 7 THEN 1 ELSE 0 END) AS beyond_7_d
    FROM pnd_raw_data AS grv
    LEFT JOIN admin_position_master AS apm ON apm.position_id = grv.assigned_to_position
    LEFT JOIN pending_for_other_hod_wise_mat_2 AS pf ON grv.grievance_id = pf.grievance_id
    WHERE grv.status NOT IN (3, 5, 16) AND (apm.office_id NOT IN (35) OR apm.office_id IS NULL)
    GROUP BY apm.office_id, grv.assigned_by_office_id
),
processing_unit AS (
    SELECT
        '2025-05-15 16:30:01.507109+00:00'::timestamp AS refresh_time_utc,
        '2025-05-15 16:30:01.507109+00:00'::timestamp + INTERVAL '5 hour 30 minutes' AS refresh_time_ist,
        COALESCE(com.office_name, 'N/A') AS office_name,
        pnd.office_id,
        pnd.assigned_by_office_id,
        SUM(pnd.beyond_7_d) AS atr_pending_beyond_7d,
        SUM(pnd.pending) AS atr_pending
    FROM pnd
    LEFT JOIN cmo_office_master AS com ON com.office_id = pnd.office_id
    GROUP BY pnd.office_id, com.office_name, pnd.assigned_by_office_id
)
SELECT 
    ROW_NUMBER() OVER () AS sl_no, 
    processing_unit.*
FROM processing_unit
ORDER BY office_name, office_id;
-----------------------------------------------------------------------------------------------------------------





WITH pnd_union_data AS (
    SELECT f3.grievance_id
    FROM forwarded_latest_3_bh_mat_2 AS f3
    LEFT JOIN atr_latest_14_bh_mat_2 AS a14
        ON a14.grievance_id = f3.grievance_id
        AND a14.current_status IN (14,15)
    WHERE a14.grievance_id IS NULL
    UNION
    SELECT f5.grievance_id
    FROM forwarded_latest_5_bh_mat_2 AS f5
    LEFT JOIN atr_latest_13_bh_mat_2 AS a13
        ON a13.grievance_id = f5.grievance_id
    WHERE a13.grievance_id IS NULL
),
pnd_raw_data AS (
    SELECT gm.*
    FROM pnd_union_data AS bh
    INNER JOIN grievance_master_bh_mat_2 AS gm
        ON gm.grievance_id = bh.grievance_id
),
pnd AS (
    SELECT 
        apm.office_id AS assigned_to_office_id, 
        COUNT(*) AS pending,
        SUM(CASE WHEN pf.days_diff >= 7 THEN 1 ELSE 0 END) AS beyond_7_d
    FROM pnd_raw_data AS prd
    LEFT JOIN admin_position_master AS apm
        ON apm.position_id = prd.assigned_to_position
    LEFT JOIN pending_for_other_hod_wise_mat_2 AS pf
        ON prd.grievance_id = pf.grievance_id
    WHERE prd.status NOT IN (3, 5, 16)
    GROUP BY apm.office_id
),
processing_unit AS (
    SELECT
        '2025-05-15 16:30:01.507109+00:00'::timestamp AS refresh_time_utc,
        '2025-05-15 16:30:01.507109+00:00'::timestamp + INTERVAL '5 hour 30 minutes' AS refresh_time_ist,
        COALESCE(com.office_name, 'N/A') AS office_name,
        pnd.assigned_to_office_id,
        COALESCE(pnd.beyond_7_d, 0) AS atr_pending_beyond_7d,
        COALESCE(pnd.pending, 0) AS atr_pending
    FROM pnd
    LEFT JOIN cmo_office_master AS com 
        ON com.office_id = pnd.assigned_to_office_id
)
SELECT 
    ROW_NUMBER() OVER () AS sl_no, 
    processing_unit.*
FROM processing_unit
ORDER BY office_name, assigned_to_office_id;




















with received_count as (
                        select forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id,  count(1) as received
                        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
                        where 1=1
                            /* VARIABLE */
                            /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
                            /* VARIABLE */
                        group by forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id
                ), atr_submitted as (
                        select atr_latest_13_bh_mat.grievance_category, atr_latest_13_bh_mat.assigned_to_office_id, count(1) as atr_submitted
                        from atr_latest_13_bh_mat_2 as atr_latest_13_bh_mat
                        inner join forwarded_latest_5_bh_mat_2 forwarded_latest_5_bh_mat on forwarded_latest_5_bh_mat.grievance_id = atr_latest_13_bh_mat.grievance_id
                        where 1=1
                            /* VARIABLE */
                            /* VARIABLE */  and atr_latest_13_bh_mat.assigned_by_office_id in (35)
                            /* VARIABLE */
                        group by atr_latest_13_bh_mat.grievance_category, atr_latest_13_bh_mat.assigned_to_office_id
                ), pending_count as (
                        select forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id, count(1) as pending
                        from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
                        left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
                        left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
                        where atr_latest_13_bh_mat.grievance_id is null
                            /* VARIABLE */
                            /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
                            /* VARIABLE */
                        group by forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_category
                ) select
                    row_number() over() as sl_no,
                    /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00'::timestamp as refresh_time_utc,
                    /* VARIABLE */ '2025-05-15 16:30:01.507109+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
                    cgcm.grievance_category_desc,
                    coalesce(com.office_name,'N/A') as office_name,
                    cgcm.parent_office_id,
                    com.office_id,
                        coalesce(rc.received, 0) AS grv_fwd,
                        coalesce(ats.atr_submitted, 0) AS atr_rcvd,
                        coalesce(pc.pending, 0) AS atr_pndg
                    from received_count rc
                    left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = rc.grievance_category
                    left join atr_submitted ats on ats.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = ats.grievance_category
                    left join pending_count pc on pc.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
                    order by com.office_name, cgcm.grievance_category_desc






select forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id, count(1) as pending
    from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
    left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
    left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
    where atr_latest_13_bh_mat.grievance_id is null
        /* VARIABLE */
        /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
        /* VARIABLE */
    group by forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_category


----
    select /*forwarded_latest_5_bh_mat.grievance_category, forwarded_latest_5_bh_mat.assigned_by_office_id,*/ count(1) as pending, forwarded_latest_5_bh_mat.assigned_to_office_id, com.office_name
    from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
    left join pending_for_other_hod_wise_mat_2 as pending_for_other_hod_wise_mat on pending_for_other_hod_wise_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
    left join atr_latest_13_bh_mat_2 atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
    left join cmo_office_master com on com.office_id = forwarded_latest_5_bh_mat.assigned_to_office_id
    where atr_latest_13_bh_mat.grievance_id is null
        /* VARIABLE */
--        /* VARIABLE */  and forwarded_latest_5_bh_mat.assigned_to_office_id in (35)
        /* VARIABLE */
    group by /*forwarded_latest_5_bh_mat.assigned_by_office_id, forwarded_latest_5_bh_mat.grievance_category,*/ forwarded_latest_5_bh_mat.assigned_to_office_id, com.office_name 
    
    
 ------------------------------------------------------------------------------- Dasboard ------------------------------------------------------------------------------------------------------
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt
        FROM forwarded_latest_3_bh_mat_2 as bh
        where 1 = 1  and bh.assigned_to_office_id = 35
), atr_sent as (
    SELECT COUNT(1) as atr_sent_cnt,
    coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt,
    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd,
    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up,
    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl
    FROM atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
    where bm.current_status in (14,15)   and bh.assigned_by_office_id = 35
), atr_pending as (
    SELECT COUNT(1) as atr_pending_cnt
    FROM forwarded_latest_3_bh_mat_2 as bh
    WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
      and bh.assigned_to_office_id = 35
), grievance_received_other_hod as (
        select count(1) as griev_recv_cnt_other_hod
        from forwarded_latest_5_bh_mat_2 as bh
        where 1 = 1  and bh.assigned_to_office_id = 35
),
atr_sent_other_hod as (
    select count(1) as atr_sent_cnt_other_hod  from atr_latest_13_bh_mat_2 as bh where 1 = 1   and bh.assigned_by_office_id = 35
), close_other_hod as (
        select  count(1) as disposed_cnt_other_hod,
                coalesce(sum(case when bm.closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                coalesce(sum(case when bm.closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                coalesce(sum(case when bm.closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
            FROM forwarded_latest_5_bh_mat_2 as bh
        inner join grievance_master_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
        where bm.status = 15  and bh.assigned_to_office_id = 35
), atr_pending_other_hod as (
    SELECT
        COUNT(1) as atr_pending_cnt_other_hod
        FROM forwarded_latest_5_bh_mat_2 as bh
        left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
            WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id /*and bm.current_status in (14,15)*/)
      and bh.assigned_to_office_id = 35
)
select * ,
    '2025-05-15 16:30:01.507109+00:00'::timestamp as refresh_time_utc
    from grievances_recieved
    cross join atr_sent
    cross join atr_pending
    cross join grievance_received_other_hod
    cross join atr_sent_other_hod
    cross join atr_pending_other_hod
    cross join close_other_hod;


   
   
   
   
   SELECT com.office_name, COUNT(1) as grievances_recieved_cnt
        FROM forwarded_latest_3_bh_mat_2 as bh
        left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
        where 1 = 1  /*and bh.assigned_to_office_id = 35*/
        group by com.office_name
        order by com.office_name
        
        
    SELECT COUNT(1) as atr_sent_cnt, com.office_name
	    FROM atr_latest_14_bh_mat_2 as bh
	    inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
	    left join cmo_office_master com on com.office_id = bh.assigned_by_office_id
	    where bm.current_status in (14,15)   /*and bh.assigned_by_office_id = 35*/
    group by com.office_name
    order by com.office_name
    
    SELECT COUNT(1) as atr_pending_cnt, com.office_name
    FROM forwarded_latest_3_bh_mat_2 as bh
    left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
    WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
      /*and bh.assigned_to_office_id = 35*/
    group by com.office_name
    order by com.office_name

        
        select count(1) as griev_recv_cnt_other_hod, com.office_name 
        from forwarded_latest_5_bh_mat_2 as bh
        left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
        where 1 = 1  /*and bh.assigned_to_office_id = 35*/
		group by com.office_name
        order by com.office_name
        
        
        
        select count(1) as atr_sent_cnt_other_hod, com.office_name 
        from atr_latest_13_bh_mat_2 as bh 
        left join cmo_office_master com on com.office_id = bh.assigned_by_office_id
        where 1 = 1   /*and bh.assigned_by_office_id = 35*/
        group by com.office_name
        order by com.office_name
        
        
        
        
        select COUNT(1) as atr_pending_cnt_other_hod, com.office_name 
        FROM forwarded_latest_5_bh_mat_2 as bh
        left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
        left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
            WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id /*and bm.current_status in (14,15)*/)
      /*and bh.assigned_to_office_id = 35*/ group by com.office_name
        order by com.office_name
        
        -------------------------------------------------------------------------------
        
  ---      DASHBOARD CMO + Other HOD = Total ALL -----
        
WITH grievances_recieved AS (
    SELECT 
        com.office_name, 
        COUNT(1) AS grievances_recieved_cnt
    FROM forwarded_latest_3_bh_mat_2 AS bh
    LEFT JOIN cmo_office_master com ON com.office_id = bh.assigned_to_office_id
    WHERE 1 = 1  
    GROUP BY com.office_name
),
grievance_received_other_hod AS (
    SELECT 
        com.office_name, 
        COUNT(1) AS griev_recv_cnt_other_hod
    FROM forwarded_latest_5_bh_mat_2 AS bh
    LEFT JOIN cmo_office_master com ON com.office_id = bh.assigned_to_office_id
    WHERE 1 = 1  
    GROUP BY com.office_name
)
SELECT 
    COALESCE(grv.office_name, groh.office_name) AS office_name,
    COALESCE(grv.grievances_recieved_cnt, 0) AS grievances_recieved_cnt,
    COALESCE(groh.griev_recv_cnt_other_hod, 0) AS griev_recv_cnt_other_hod,
    COALESCE(grv.grievances_recieved_cnt, 0) + COALESCE(groh.griev_recv_cnt_other_hod, 0) AS total_grievances
FROM grievances_recieved grv
FULL OUTER JOIN grievance_received_other_hod groh ON grv.office_name = groh.office_name
ORDER BY office_name;
        
        

 WITH atr_sent AS (       
  select count(1) as atr_sent_cnt_other_hod,
  	com.office_name 
        from atr_latest_13_bh_mat_2 as bh 
        left join cmo_office_master com on com.office_id = bh.assigned_by_office_id
        where 1 = 1   /*and bh.assigned_by_office_id = 35*/
        group by com.office_name
   ), 
   atr_sent_other_hod as (     
	    SELECT 
	    	com.office_name,
	    	COUNT(1) as atr_sent_cnt
	    FROM atr_latest_14_bh_mat_2 as bh
	    inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
	    left join cmo_office_master com on com.office_id = bh.assigned_by_office_id
	    where bm.current_status in (14,15)   /*and bh.assigned_by_office_id = 35*/
    group by com.office_name
   )
   select 
   		COALESCE(grv.office_name, groh.office_name) AS office_name,
	    COALESCE(grv.atr_sent_cnt_other_hod, 0) AS atr_sent_cnt_other_hod,
	    COALESCE(groh.atr_sent_cnt, 0) AS atr_sent_cnt,
	    COALESCE(grv.atr_sent_cnt_other_hod, 0) + COALESCE(groh.atr_sent_cnt, 0) AS total_atr
	FROM atr_sent grv
	FULL OUTER JOIN atr_sent_other_hod groh ON grv.office_name = groh.office_name
	ORDER BY office_name;
   	
        
    
 WITH atr_pending AS (
    SELECT 
    	COUNT(1) as atr_pending_cnt, 
    	com.office_name
    FROM forwarded_latest_3_bh_mat_2 as bh
    left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
    WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
      /*and bh.assigned_to_office_id = 35*/
    group by com.office_name
  ), 
   atr_pending_other_hod as ( 
    select 
    	com.office_name,
    	COUNT(1) as atr_pending_cnt_other_hod
     FROM forwarded_latest_5_bh_mat_2 as bh
     left join pending_for_other_hod_wise_mat_2 as bm on bh.grievance_id = bm.grievance_id
     left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
        WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat_2 as bm WHERE bh.grievance_id = bm.grievance_id /*and bm.current_status in (14,15)*/)
      /*and bh.assigned_to_office_id = 35*/
        group by com.office_name
  )
   select 
   		COALESCE(grv.office_name, groh.office_name) AS office_name,
	    COALESCE(grv.atr_pending_cnt, 0) AS atr_sent_cnt_other_hod,
	    COALESCE(groh.atr_pending_cnt_other_hod, 0) AS atr_sent_cnt,
	    COALESCE(grv.atr_pending_cnt, 0) + COALESCE(groh.atr_pending_cnt_other_hod, 0) AS total_atr
	FROM atr_pending grv
	FULL OUTER JOIN atr_pending_other_hod groh ON grv.office_name = groh.office_name
	ORDER BY office_name;
        
        
        
        
        
        
        
        
        


---- pending for all -----
        
   with union_data as (
        select forwarded_latest_3_bh_mat.grievance_id
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        where not exists (select 1 from  atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
                                where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and
                                        atr_latest_14_bh_mat.current_status in (14,15)) and
            forwarded_latest_3_bh_mat.assigned_to_office_id in (35) /* REPLACE */
        union
        select bh.grievance_id
        from forwarded_latest_5_bh_mat_2 bh
        where not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id) and bh.assigned_to_office_id in (35) /* REPLACE */
    ), raw_data as (
        select grievance_master_bh_mat.*
            from union_data as bh
            inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
                ), unassigned_cmo as (
                    select
                        'Unassigned (CMO)' as status,
                        null as name_and_esignation_of_the_user,
                        'N/A' as office,
                        null as user_status,
                        count(1) as pending_grievances,
                        null::int as pending_atrs,
                        null::int as atr_returned_for_review,
                        null::int as atr_auto_returned_from_cmo,
                        count(1) as total_count
                    from raw_data
                    where raw_data.status = 3
                ), unassigned_other_hod as (
                    select
                        'Unassigned (Other HoD)' as status,
                        null as name_and_esignation_of_the_user,
                        'N/A' as office,
                        null as user_status,
                        count(1) as pending_grievances,
                        null::int as pending_atrs,
                        null::int as atr_returned_for_review,
                        null::int as atr_auto_returned_from_cmo,
                        count(1) as total_count
                        from raw_data
                        where raw_data.status = 5
                ), recalled as (
                    select
                        'Recalled' as status,
                        null as name_and_esignation_of_the_user,
                        'N/A' as office,
                        null as user_status,
                        count(1) as pending_grievances,
                        null::int as pending_atrs,
                        null::int as atr_returned_for_review,
                        null::int as atr_auto_returned_from_cmo,
                        count(1) as total_count
                    from raw_data
                    where raw_data.status = 16
                ), user_wise_pndcy as (
                    select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_status, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review,
                        xx.atr_auto_returned_from_cmo, xx.total_count
                    from (
                        select 'User wise ATR Pendency' as status,
                            case when admin_user_details.official_name is not null
                                    then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )')
                                else null
                            end as name_and_esignation_of_the_user,
                            case
                                when cmo_sub_office_master.suboffice_name is not null
                                    then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
                                else cmo_office_master.office_name
                            end as office,
                            case when admin_position_master.office_id in (35) /*REPLACE*/ then admin_user_role_master.role_master_name
                                    else concat(admin_user_role_master.role_master_name, ' (Other HOD)')
                            end as "user_status",
                            case when admin_position_master.office_id in (35) /*REPLACE*/ then 1 else 2 end as "type",
                            sum(case when raw_data.status in (4,7,8,8888) then 1 else 0 end) as "pending_grievances",
                            sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs",
                            sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review",
                            case when admin_position_master.office_id in (35) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end)
                                    else null::int
                            end as "atr_auto_returned_from_cmo",
                            count(1) as total_count
                        from raw_data
                        left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id
                        left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
                        left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
                        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
                        left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
                        left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
                        where raw_data.status not in (3, 5, 16)
                        group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name,
                                admin_user_role_master.role_master_id, admin_user_role_master.role_master_name, cmo_designation_master.designation_name,
                                cmo_sub_office_master.suboffice_name
                        order by type, admin_user_role_master.role_master_id
                    )xx
                ), union_part as (
                    select * from unassigned_cmo
                        union all
                    select * from unassigned_other_hod
                        union all
                    select * from recalled
                        union all
                    select * from user_wise_pndcy
                )
                select
                    row_number() over() as sl_no,
                    '2025-05-15 16:30:01.507109+00:00'::timestamp as refresh_time_utc,
                    '2025-05-15 16:30:01.507109+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
                    *
                from union_part;
   
               
               
               
               
               
SELECT 
    com.office_id,
    com.office_name,
    COUNT(bh.grievance_id) AS grievance_count
FROM 
    cmo_office_master com
LEFT JOIN 
    forwarded_latest_5_bh_mat_2 bh ON com.office_id = bh.assigned_to_office_id
LEFT JOIN 
    grievance_master_bh_mat_2 gm ON gm.grievance_id = bh.grievance_id
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM atr_latest_13_bh_mat_2 bm 
        WHERE bm.grievance_id = bh.grievance_id
    )
GROUP BY 
    com.office_id, com.office_name
ORDER BY 
    com.office_name;
   
   
   
WITH union_data AS (
    SELECT f3.grievance_id, com.office_name
    FROM forwarded_latest_3_bh_mat_2 AS f3
    LEFT JOIN cmo_office_master com ON com.office_id = f3.assigned_to_office_id
    WHERE NOT EXISTS (
        SELECT 1 
        FROM atr_latest_14_bh_mat_2 AS a14
        WHERE a14.grievance_id = f3.grievance_id 
            AND a14.current_status IN (14, 15)
    )
    UNION
    SELECT f5.grievance_id, com.office_name
    FROM forwarded_latest_5_bh_mat_2 AS f5
    LEFT JOIN cmo_office_master com ON com.office_id = f5.assigned_to_office_id
    WHERE NOT EXISTS (
        SELECT 1 
        FROM atr_latest_13_bh_mat_2 AS a13
        WHERE a13.grievance_id = f5.grievance_id
    )
),
raw_data AS (
    SELECT gm.*, bh.office_name
    FROM union_data AS bh
    INNER JOIN grievance_master_bh_mat_2 AS gm 
        ON gm.grievance_id = bh.grievance_id
)
SELECT 
    raw_data.office_name,
    COUNT(*) AS total_grievances
FROM raw_data
GROUP BY raw_data.office_name
ORDER BY raw_data.office_name;

            


-----------------------------------Grievance Register for all -------------------------
with uinion_part as (
        select grievance_id, forwarded_latest_5_bh_mat_2.assigned_to_office_id 
        from forwarded_latest_5_bh_mat_2
        left join cmo_office_master com3 on com3.office_id = forwarded_latest_5_bh_mat_2.assigned_to_office_id /*where assigned_to_office_id = 35*/
        union
        select grievance_id, forwarded_latest_3_bh_mat_2.assigned_to_office_id
        from forwarded_latest_3_bh_mat_2
        left join cmo_office_master com3 on com3.office_id = forwarded_latest_3_bh_mat_2.assigned_to_office_id /*where assigned_to_office_id = 35*/
)
Select com3.office_name, Count(1)
    from grievance_master md
    inner join uinion_part as lu on lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
    group by com3.office_name
	order by com3.office_name;
                
   

-- Grievance Register - ALL
with uinion_part as (
    select grievance_id, forwarded_latest_5_bh_mat_2.assigned_to_office_id from forwarded_latest_5_bh_mat_2 
    union
    select grievance_id, forwarded_latest_3_bh_mat_2.assigned_to_office_id from forwarded_latest_3_bh_mat_2 
)
Select com3.office_name, Count(1)
    from uinion_part lu 
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id 
    group by com3.office_name
	order by com3.office_name;
  

----- Grievance Register for perticular office for all -----
with uinion_part as (
        select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
        union
        select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
)
Select Count(1)
    from grievance_master md
    inner join uinion_part as lu on lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id






                
                
 Select 
    com3.office_name, Count(1)
    from grievance_master_bh_mat_2 md
    inner join forwarded_latest_5_bh_mat_2 as lu on lu.grievance_id = md.grievance_id
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
    left join cmo_sub_office_master csom on csom.suboffice_id = apm2.sub_office_id
--  where lu.assigned_to_office_id = 35
    group by com3.office_name
	order by com3.office_name;













--------------------------------------------------------------------------------------------------------------------------



    with fwd_Count as (
        select bh.assigned_by_id , bh.assigned_by_position, count(1) as griv_fwd
            from forwarded_latest_3_bh_mat as bh
            where 1 = 1
        group by bh.assigned_by_id, bh.assigned_by_position
    ), new_pending as (
        select gm.assigned_to_id, gm.assigned_to_position, count(1) as griv_pending
            from grievance_master_bh_mat as gm
        where gm.status = 2
        group by gm.assigned_to_id, gm.assigned_to_position
    ), atr_closed as (
        SELECT gm.updated_by, gm.updated_by_position, count(1) as disposed
            from grievance_master_bh_mat as gm
        where gm.status = 15
        group by gm.updated_by, gm.updated_by_position
    ), atr_pending as (
        select grievance_locking_history.locked_by_userid, grievance_locking_history.locked_by_position, count(1) as atr_pnd
            from grievance_master_bh_mat as gm
        inner join grievance_locking_history on grievance_locking_history.grievance_id = gm.grievance_id
        where gm.status = 14 and grievance_locking_history.lock_status = 1
        group by grievance_locking_history.locked_by_userid, grievance_locking_history.locked_by_position
    ), returned_fo_review as (
            select x.assigned_by_id, x.assigned_by_position, count(1) as rtn_fr_rview from (
            SELECT a.assigned_by_id, a.assigned_by_position, a.grievance_id
                FROM (
                SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                        gl.assigned_by_id, gl.assigned_by_position, gl.assigned_by_office_cat, gl.grievance_id
                    FROM grievance_lifecycle gl
                WHERE gl.grievance_status = 6
                ) a
        WHERE a.rnn = 1 and a.assigned_by_office_cat = 1
        )x
        inner join grievance_master_bh_mat as gm on x.grievance_id = gm.grievance_id

        group by x.assigned_by_id, x.assigned_by_position
    ) select
            '2025-05-27 16:30:01.167232+00:00'::timestamp as refresh_time_utc,
concat(admin_user_details.official_name, ' - ', admin_user_role_master.role_master_name) as official_and_role_name,
    coalesce(fwd_Count.griv_fwd, 0) as forwarded,
    coalesce(new_pending.griv_pending, 0) as new_grievances_pending,
    coalesce(atr_closed.disposed, 0) as closed,
    coalesce(atr_pending.atr_pnd, 0) as pending,
    coalesce(returned_fo_review.rtn_fr_rview, 0) as atr_returned_to_hod_for_review
from fwd_Count
left join admin_user_details on fwd_Count.assigned_by_id = admin_user_details.admin_user_id
left join admin_position_master on fwd_Count.assigned_by_position = admin_position_master.position_id
left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
left join new_pending on fwd_Count.assigned_by_id = new_pending.assigned_to_id and fwd_Count.assigned_by_position = new_pending.assigned_to_position
left join atr_closed on fwd_Count.assigned_by_id = atr_closed.updated_by and fwd_Count.assigned_by_position = atr_closed.updated_by_position
left join atr_pending on fwd_Count.assigned_by_id = atr_pending.locked_by_userid and fwd_Count.assigned_by_position = atr_pending.locked_by_position
left join returned_fo_review on fwd_Count.assigned_by_id = returned_fo_review.assigned_by_id and fwd_Count.assigned_by_position = returned_fo_review.assigned_by_position;







with atr_closed as (
        SELECT gm.updated_by, gm.updated_by_position, count(1) as disposed
            from grievance_master_bh_mat as gm
        where gm.status = 15
        group by gm.updated_by, gm.updated_by_position
    ) select
concat(admin_user_details.official_name, ' - ', admin_user_role_master.role_master_name) as official_and_role_name,
    coalesce(atr_closed.disposed, 0) as closed
from atr_closed
left join admin_user_details on atr_closed.updated_by = admin_user_details.admin_user_id
left join admin_position_master on atr_closed.updated_by_position = admin_position_master.position_id
left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id





--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



with union_data as (
        select forwarded_latest_3_bh_mat.grievance_id
        from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
        where not exists (select 1 from  atr_latest_14_bh_mat as atr_latest_14_bh_mat 
                                where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and 
                                        atr_latest_14_bh_mat.current_status in (14,15)) and 
            forwarded_latest_3_bh_mat.assigned_to_office_id in (35) /* REPLACE */
        union
        select bh.grievance_id
        from forwarded_latest_5_bh_mat bh 
        where not exists (select 1 from atr_latest_13_bh_mat as bm where bm.grievance_id = bh.grievance_id) and bh.assigned_to_office_id in (35) /* REPLACE */
    ), raw_data as (
        select grievance_master_bh_mat.*
            from union_data as bh 
            inner join grievance_master_bh_mat as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id
    ), unassigned_cmo as (
        select  
            'Unassigned (CMO)' as status,
            'N/A' as name_and_esignation_of_the_user,
            'N/A' as office,
            'N/A' as user_role,
            'N/A' as user_status,
            'N/A' as status_id,
            count(1) as pending_grievances,
            null::int as pending_atrs,
            null::int as atr_returned_for_review,
            null::int as atr_auto_returned_from_cmo,
            count(1) as total_count 
        from raw_data 
        where raw_data.status = 3
    ), unassigned_other_hod as (
        select  
            'Unassigned (Other HoD)' as status,
            'N/A' as name_and_esignation_of_the_user,
            'N/A' as office,
            'N/A' as user_role,
            'N/A' as user_status,
            'N/A' as status_id,
            count(1) as pending_grievances,
            null::int as pending_atrs,
            null::int as atr_returned_for_review,
            null::int as atr_auto_returned_from_cmo,
            count(1) as total_count
            from raw_data
            where raw_data.status = 5
    ), recalled as (
        select  
            'Recalled' as status,
            'N/A' as name_and_esignation_of_the_user,
            'N/A' as office,
            'N/A' as user_role,
            'N/A' as user_status,
            'N/A' as status_id,
            count(1) as pending_grievances,
            null::int as pending_atrs,
            null::int as atr_returned_for_review,
            null::int as atr_auto_returned_from_cmo,
            count(1) as total_count 
        from raw_data
        where raw_data.status = 16
    ), user_wise_pndcy as (
        select xx.status,  xx.name_and_esignation_of_the_user, xx.office, xx.user_role, xx.user_status, xx.status_id::text, xx.pending_grievances, xx.pending_atrs, xx.atr_returned_for_review, 
            xx.atr_auto_returned_from_cmo, xx.total_count
        from (
            select 'User wise ATR Pendency' as status,
                case when admin_user_details.official_name is not null 
                        then concat(admin_user_details.official_name, ' - (', cmo_designation_master.designation_name ,' )') 
                    else null
                end as name_and_esignation_of_the_user, 
                case 
                    when cmo_sub_office_master.suboffice_name is not null 
                        then concat(cmo_office_master.office_name, ' - ( ', cmo_sub_office_master.suboffice_name, ' )')
                    else cmo_office_master.office_name
                end as office,
                case 
                    when admin_position_master.office_id in (35) /*REPLACE*/ 
                		then admin_user_role_master.role_master_name 
                    else concat(admin_user_role_master.role_master_name, ' (Other HOD)') 
                end as user_role,
                admin_position_master.record_status as status_id,
                case when admin_position_master.record_status = 1 then 'Active'
                	when admin_position_master.record_status = 2 then 'Inactive'
                	else null
                end as user_status,
                case when admin_position_master.office_id in (35) /*REPLACE*/ then 1 else 2 end as "type",
                sum(case when raw_data.status in (4,7,8,8888) then 1 else 0 end) as "pending_grievances",
                sum(case when raw_data.status in (9,11,13) then 1 else 0 end) as "pending_atrs", 
                sum(case when raw_data.status in (6,10,12) then 1 else 0 end) as "atr_returned_for_review", 
                case when admin_position_master.office_id in (35) /*REPLACE*/ then sum(case when raw_data.status in (16,17) then 1 else 0 end) 
                        else null::int 
                end as "atr_auto_returned_from_cmo",
                count(1) as total_count
            from raw_data
            left join admin_user_details on raw_data.assigned_to_id = admin_user_details.admin_user_id 
            left join admin_position_master on raw_data.assigned_to_position = admin_position_master.position_id
            left join cmo_office_master on admin_position_master.office_id = cmo_office_master.office_id
            left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
            left join cmo_designation_master on cmo_designation_master.designation_id = admin_position_master.designation_id
            left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = admin_position_master.sub_office_id
            where raw_data.status not in (3, 5, 16)  
            group by admin_user_details.official_name, admin_position_master.office_id, cmo_office_master.office_name, 
                    admin_user_role_master.role_master_id, admin_user_role_master.role_master_name, cmo_designation_master.designation_name,
                    cmo_sub_office_master.suboffice_name, admin_position_master.record_status
            order by type, admin_user_role_master.role_master_id
        )xx 
    ), union_part as (
        select * from unassigned_cmo
            union all 
        select * from unassigned_other_hod
            union all
        select * from recalled
            union all
        select * from user_wise_pndcy 
    ) 
    select
        row_number() over() as sl_no,
        '2025-05-28 16:30:01.443267+00:00'::timestamp as refresh_time_utc,
        '2025-05-28 16:30:01.443267+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        * 
    from union_part;
    
   
   
   
   
   ------================================================================================================================================------------------------
   ------- Comparison Excel Query -----
   
   ------- ============================ CMO Comparisition QUERY FOR ALL ================================= -------
   
   
/* Excel Helping Formula */
-- =IFERROR(INDEX(S:S, MATCH(H4,R:R, 0)), "")


-- Dashbord Card Count Master Query -- 
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt FROM forwarded_latest_3_bh_mat as bh where 1 = 1  and bh.assigned_to_office_id = 2
), atr_sent as (
    SELECT COUNT(1) as atr_sent_cnt,
    coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt,
    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd,
    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up,
    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl
    FROM atr_latest_14_bh_mat as bh
    inner join forwarded_latest_3_bh_mat as bm ON bm.grievance_id = bh.grievance_id
    where bm.current_status in (14,15)   and bh.assigned_by_office_id = 2
), atr_pending as (
    SELECT COUNT(1) as atr_pending_cnt FROM forwarded_latest_3_bh_mat as bh 
    	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
      		  and bh.assigned_to_office_id = 2
), grievance_received_other_hod as (
        select count(1) as griev_recv_cnt_other_hod from forwarded_latest_5_bh_mat as bh where 1 = 1  and bh.assigned_to_office_id = 2
), atr_sent_other_hod as (
    select count(1) as atr_sent_cnt_other_hod  from atr_latest_13_bh_mat as bh where 1 = 1   and bh.assigned_by_office_id = 2
), close_other_hod as (
        select  count(1) as disposed_cnt_other_hod,
                coalesce(sum(case when bm.closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
                coalesce(sum(case when bm.closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
                coalesce(sum(case when bm.closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
            FROM forwarded_latest_5_bh_mat as bh
        inner join grievance_master_bh_mat as bm ON bm.grievance_id = bh.grievance_id
        where bm.status = 15  and bh.assigned_to_office_id = 2
), atr_pending_other_hod as (
    SELECT
        COUNT(1) as atr_pending_cnt_other_hod
        FROM forwarded_latest_5_bh_mat as bh
        left join pending_for_other_hod_wise_mat_ as bm on bh.grievance_id = bm.grievance_id
            WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id /*and bm.current_status in (14,15)*/)
      and bh.assigned_to_office_id = 2
)
select * ,
    '2025-05-25 16:30:01.742251+00:00'::timestamp as refresh_time_utc
from grievances_recieved
cross join atr_sent
cross join atr_pending
cross join grievance_received_other_hod
cross join atr_sent_other_hod
cross join atr_pending_other_hod
cross join close_other_hod;




--- Grievance Receive Dashbord - CMO
SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
group by com.office_name;


--- Grievance Receive Dashbord - CMO
SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
group by com.office_name;



-- ATR Dashbord - CMO
SELECT com.office_name, COUNT(1) 
FROM atr_latest_14_bh_mat as bh
inner join forwarded_latest_3_bh_mat as bm ON bm.grievance_id = bh.grievance_id
left join cmo_office_master com on bh.assigned_by_office_id = com.office_id
where bm.current_status in (14,15)   
group by com.office_name;


-- ATR Dashbord - CMO
SELECT com.office_name, COUNT(1) 
FROM atr_latest_14_bh_mat as bh
inner join forwarded_latest_3_bh_mat as bm ON bm.grievance_id = bh.grievance_id
left join cmo_office_master com on bh.assigned_by_office_id = com.office_id
where bm.current_status in (14,15)   
group by com.office_name;



-- ATR PENDING Dashbord - CMO
SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
group by com.office_name ;


-- ATR PENDING Dashbord - CMO
SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
	WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
group by com.office_name ;



-- Grievance Register - ALL
with uinion_part as (
    select grievance_id, forwarded_latest_5_bh_mat_2.assigned_to_office_id from forwarded_latest_5_bh_mat_2 
    union
    select grievance_id, forwarded_latest_3_bh_mat_2.assigned_to_office_id from forwarded_latest_3_bh_mat_2 
)
Select com3.office_name, Count(1)
    from uinion_part lu 
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id 
    group by com3.office_name
	order by com3.office_name;


-- Grievance Register - ALL
with uinion_part as (
    select grievance_id, forwarded_latest_5_bh_mat_2.assigned_to_office_id from forwarded_latest_5_bh_mat_2 
    union
    select grievance_id, forwarded_latest_3_bh_mat_2.assigned_to_office_id from forwarded_latest_3_bh_mat_2 
)
Select com3.office_name, Count(1)
    from uinion_part lu 
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id 
    group by com3.office_name
	order by com3.office_name;
   
   
-- PENDING Grievance AT My Office -- ALL
with union_data as (
    select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_to_office_id
    from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    where not exists (select 1 from  atr_latest_14_bh_mat as atr_latest_14_bh_mat
                            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and
                                    atr_latest_14_bh_mat.current_status in (14,15))  
    union
    select bh.grievance_id, bh.assigned_to_office_id
    from forwarded_latest_5_bh_mat bh
    where not exists (select 1 from atr_latest_13_bh_mat as bm where bm.grievance_id = bh.grievance_id)  
)
select com3.office_name, count(1) from union_data 
left join cmo_office_master com3 on com3.office_id = union_data.assigned_to_office_id 
group by com3.office_name order by com3.office_name;



-- PENDING Grievance AT My Office -- ALL
with union_data as (
    select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_to_office_id
    from forwarded_latest_3_bh_mat as forwarded_latest_3_bh_mat
    where not exists (select 1 from  atr_latest_14_bh_mat as atr_latest_14_bh_mat
                            where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and
                                    atr_latest_14_bh_mat.current_status in (14,15))  
    union
    select bh.grievance_id, bh.assigned_to_office_id
    from forwarded_latest_5_bh_mat bh
    where not exists (select 1 from atr_latest_13_bh_mat as bm where bm.grievance_id = bh.grievance_id)  
)
select com3.office_name, count(1) from union_data 
left join cmo_office_master com3 on com3.office_id = union_data.assigned_to_office_id 
group by com3.office_name order by com3.office_name;



------- ============================ OTHER HOD Comparisition QUERY ================================= -----


--- Grievance Receive Dashbord - Other Hod
select com.office_name,count(1) from forwarded_latest_5_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
group by com.office_name;


--- Grievance Receive Dashbord - Other Hod
select com.office_name,count(1) from forwarded_latest_5_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
group by com.office_name;


-- ATR Dashbord - Other HOD
select com.office_name, COUNT(1)  
from atr_latest_13_bh_mat as bh 
left join cmo_office_master com on bh.assigned_by_office_id = com.office_id
group by com.office_name;


-- ATR Dashbord - Other HOD
select com.office_name, COUNT(1)  
from atr_latest_13_bh_mat as bh 
left join cmo_office_master com on bh.assigned_by_office_id = com.office_id
group by com.office_name;


-- ATR PENDING Dashbord - Other HOD
select com.office_name, COUNT(1)  
FROM forwarded_latest_5_bh_mat as bh
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id)
group by com.office_name;


-- ATR PENDING Dashbord - Other HOD
select com.office_name, COUNT(1)  
FROM forwarded_latest_5_bh_mat as bh
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat as bm WHERE bh.grievance_id = bm.grievance_id)
group by com.office_name;


-- Grievance Register - Other HOD
with uinion_part as (
    select grievance_id, forwarded_latest_5_bh_mat_2.assigned_to_office_id from forwarded_latest_5_bh_mat_2
)
Select com3.office_name, Count(1)
    from uinion_part lu 
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id 
    group by com3.office_name order by com3.office_name;

   
-- Grievance Register - Other HOD
with uinion_part as (
    select grievance_id, forwarded_latest_5_bh_mat_2.assigned_to_office_id from forwarded_latest_5_bh_mat_2
)
Select com3.office_name, Count(1)
    from uinion_part lu 
    left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id 
    group by com3.office_name order by com3.office_name;

   
   
-- Pending Grievances - Other Hod
 with raw_data as (
    select bh.assigned_to_office_id, bh.grievance_id
        from forwarded_latest_5_bh_mat as bh
        inner join grievance_master_bh_mat as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id 
            and not exists ( select 1 from atr_latest_13_bh_mat as bm where bm.grievance_id = bh.grievance_id )
)select com.office_name, count(1)
from raw_data
left join cmo_office_master com on com.office_id = raw_data.assigned_to_office_id
 group by com.office_name

 
 -- Pending Grievances - Other Hod
 with raw_data as (
    select bh.assigned_to_office_id, bh.grievance_id
        from forwarded_latest_5_bh_mat as bh
        inner join grievance_master_bh_mat as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = bh.grievance_id 
            and not exists ( select 1 from atr_latest_13_bh_mat as bm where bm.grievance_id = bh.grievance_id )
)select com.office_name, count(1)
from raw_data
left join cmo_office_master com on com.office_id = raw_data.assigned_to_office_id
 group by com.office_name	
 
 
-- category wise - MIS - Other HOd
select com.office_name, count(1)
from forwarded_latest_5_bh_mat as forwarded_latest_5_bh_mat
left join atr_latest_13_bh_mat atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
left join cmo_office_master com on com.office_id = forwarded_latest_5_bh_mat.assigned_to_office_id
where atr_latest_13_bh_mat.grievance_id is null 
group by com.office_name 
 
 
-- category wise - MIS - Other HOd
select com.office_name, count(1)
from forwarded_latest_5_bh_mat as forwarded_latest_5_bh_mat
left join atr_latest_13_bh_mat atr_latest_13_bh_mat on atr_latest_13_bh_mat.grievance_id = forwarded_latest_5_bh_mat.grievance_id
left join cmo_office_master com on com.office_id = forwarded_latest_5_bh_mat.assigned_to_office_id
where atr_latest_13_bh_mat.grievance_id is null 
group by com.office_name 

-------------------------------------------------------------------------------------------------------------------------------


