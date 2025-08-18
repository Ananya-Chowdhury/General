---- CMO Grievance Register ----- 15.07.2025


select 
	bh.grievance_id,
	bh.grievance_no,
	bh.grievance_source as grievance_source_id,
	cdlm.domain_value as grievance_source,
	bh.grievance_generate_date::date as lodge_date,
	bh.receipt_mode as received_mode_id,
	cgrmm.grivence_source_name as received_mode,
	bh.received_at as received_at_id,
	cdlm2.domain_value as received_at,
	bh.applicant_name as complainant_name,
	bh.pri_cont_no as mobile_number,
	bh.applicant_caste as cast_id,
	ccm.caste_name as caste_name,
	bh.applicant_reigion as religion_id,
	crm.religion_name as religion_name,
	bh.applicant_age as age,
	bh.applicant_gender as gender_id,
	cdlm3.domain_value as gender,
	bh.district_id,
	cdm.district_name,
	bh.block_id,	
	bh.municipality_id,
	case 
		when bh.block_id is not null then concat(cbm.block_name, ' (B)')
		when bh.municipality_id is not null then concat(cmm.municipality_name, ' (M)')
		else 'N/A'
	end as block_or_municipality,
	bh.gp_id,
	bh.ward_id,
	case 
		when bh.gp_id is not null then concat(cgpm.gp_name, ' (G)')
		when bh.ward_id is not null then concat(cwm.ward_name, ' (W)')
		else 'N/A'
	end as gp_or_ward,
	bh.police_station_id,
	cpsm.ps_name as police_station_name,
	bh.sub_district_id as police_district_id,
	csdm.sub_district_name as Police_district,
	bh.assembly_const_id as assembly_id,
	cam.assembly_name as assembly_name,
	bh.grievance_category as grievance_category_id,
	cgcm.grievance_category_desc as grievance_category,
	bh.grievance_description,
	case 
		when bh.assigned_to_office_id is not null then bh.assigned_to_office_id
		else null
	end as forwarded_to_hod_office_id,
	com.office_name as forwarded_to_hod_office,
	bh.status as current_status_id,
	case 
		when bh.status is not null then cdlm4.domain_value 
		else 'N/A'
	end as current_status,
	bh.assigned_to_position,
    case
        when bh.assigned_to_position  is null then 'N/A'
        else concat(ad.official_name, ' -', ad.official_phone, ' [', cdm2.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ']' )
    end as pending_with, ---pending with 
	bh.closure_reason_id,
	case 
		when bh.closure_reason_id is not null then ccrm.closure_reason_name
		else 'N/A'
	end as closure_reason_name,
	bh.grievence_close_date as closure_date,
	glatm.assigned_by_office_id,
	glatm.assigned_by_position,
	glatm.assigned_by_id,
	case 
		when glatm.assigned_by_position is null then 'N/A'
		when glatm.assigned_by_office_id is null then 'N/A'
		when glatm.assigned_by_id is null then 'N/A'
		else concat(ad2.official_name, ' -', ad2.official_phone, ' [', cdm3.designation_name, ' (', com3.office_name, ') - ', aurm2.role_master_name, ']' )
	end as last_atr_submited_by,
	case 
		when bh.action_taken_note is not null then bh.action_taken_note
		else 'N/A'
	end as last_atr_remarks,
	bh.atn_id,
	case 
		when bh.atn_id is not null then catnm.atn_desc
		else 'N/A'
	end as last_action_taken_note
from grievance_master_bh_mat_2 as bh 
left join cmo_domain_lookup_master cdlm on cdlm.domain_code = bh.grievance_source and cdlm.domain_type = 'grievance_source'
left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_id = bh.receipt_mode
left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = bh.received_at and cdlm2.domain_type = 'received_at_location'
left join cmo_caste_master ccm on ccm.caste_id = bh.applicant_caste
left join cmo_religion_master crm on crm.religion_id = bh.applicant_reigion
left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_code = bh.applicant_gender and cdlm3.domain_type = 'gender'
left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = bh.gp_id 
left join cmo_wards_master cwm on cwm.ward_id = bh.ward_id 
left join cmo_police_station_master cpsm on cpsm.ps_id = bh.police_station_id
left join cmo_sub_districts_master csdm on csdm.sub_district_id = cpsm.sub_district_id /*and bh.sub_district_id = csdm.sub_district_id */
left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = bh.grievance_category 
left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
left join cmo_closure_reason_master ccrm on bh.closure_reason_id = ccrm.closure_reason_id 
left join cmo_action_taken_note_master catnm on catnm.atn_id = bh.atn_id  
left join admin_user_position_mapping aupm on aupm.position_id = bh.assigned_to_position and aupm.status = 1
left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
left join admin_position_master apm2 on apm2.position_id = bh.assigned_to_position
left join cmo_designation_master cdm2 on cdm2.designation_id = apm2.designation_id
left join cmo_office_master com2 on com2.office_id = apm2.office_id
left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
left join grievance_latest_atr_trail_mat glatm on glatm.grievance_id = bh.grievance_id
left join admin_user_position_mapping aupm2 on aupm2.position_id = glatm.assigned_by_position and aupm2.status = 1
left join admin_user_details ad2 on ad2.admin_user_id = aupm2.admin_user_id
left join admin_position_master apm3 on apm3.position_id = glatm.assigned_by_position
left join cmo_designation_master cdm3 on cdm3.designation_id = apm3.designation_id
left join cmo_office_master com3 on com3.office_id = apm3.office_id
left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
left join cmo_domain_lookup_master cdlm4 on bh.status = cdlm4.domain_code and cdlm4.domain_type = 'grievance_status'
order by bh.grievance_generate_date desc limit 10 offset 0;


--- CMO GRievance Register Count Query ----

select count(1)
from grievance_master_bh_mat_2 as bh 
--from grievance_master as bh  --2121
left join cmo_domain_lookup_master cdlm on cdlm.domain_code = bh.grievance_source and cdlm.domain_type = 'grievance_source'
left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_id = bh.receipt_mode
left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = bh.received_at and cdlm2.domain_type = 'received_at_location'
left join cmo_caste_master ccm on ccm.caste_id = bh.applicant_caste
left join cmo_religion_master crm on crm.religion_id = bh.applicant_reigion
left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_code = bh.applicant_gender and cdlm3.domain_type = 'gender'
left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = bh.gp_id 
left join cmo_wards_master cwm on cwm.ward_id = bh.ward_id 
left join cmo_police_station_master cpsm on cpsm.ps_id = bh.police_station_id
left join cmo_sub_districts_master csdm on csdm.sub_district_id = cpsm.sub_district_id /*and bh.sub_district_id = csdm.sub_district_id */
left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = bh.grievance_category 
left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
left join cmo_closure_reason_master ccrm on bh.closure_reason_id = ccrm.closure_reason_id 
left join cmo_action_taken_note_master catnm on catnm.atn_id = bh.atn_id 
left join admin_user_position_mapping aupm on aupm.position_id = bh.assigned_to_position and aupm.status = 1
left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
left join admin_position_master apm2 on apm2.position_id = bh.assigned_to_position
left join cmo_designation_master cdm2 on cdm2.designation_id = apm2.designation_id
left join cmo_office_master com2 on com2.office_id = apm2.office_id
left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
left join grievance_latest_atr_trail_mat glatm on glatm.grievance_id = bh.grievance_id
left join admin_user_position_mapping aupm2 on aupm2.position_id = glatm.assigned_by_position and aupm2.status = 1
left join admin_user_details ad2 on ad2.admin_user_id = aupm2.admin_user_id
left join admin_position_master apm3 on apm3.position_id = glatm.assigned_by_position
left join cmo_designation_master cdm3 on cdm3.designation_id = apm3.designation_id
left join cmo_office_master com3 on com3.office_id = apm3.office_id
left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
left join cmo_domain_lookup_master cdlm4 on bh.status = cdlm4.domain_code and cdlm4.domain_type = 'grievance_status';

--------------------------------------------------------------------------------------------------------------------------------------

--- Update with Materalised View -----
select 
	bh.grievance_id,
	bh.grievance_no,
	bh.grievance_source as grievance_source_id,
	cdlm.domain_value as grievance_source,
	bh.grievance_generate_date::date as lodge_date,
	bh.receipt_mode as received_mode_id,
	cgrmm.grivence_source_name as received_mode,
	bh.received_at as received_at_id,
	cdlm2.domain_value as received_at,
	bh.applicant_name as complainant_name,
	bh.pri_cont_no as mobile_number,
	bh.applicant_caste as cast_id,
	ccm.caste_name as caste_name,
	bh.applicant_reigion as religion_id,
	crm.religion_name as religion_name,
	bh.applicant_age as age,
	bh.applicant_gender as gender_id,
	cdlm3.domain_value as gender,
	bh.district_id,
	cdm.district_name,
	bh.block_id,	
	bh.municipality_id,
	case 
		when bh.block_id is not null then concat(cbm.block_name, ' (B)')
		when bh.municipality_id is not null then concat(cmm.municipality_name, ' (M)')
		else 'N/A'
	end as block_or_municipality,
	bh.gp_id,
	bh.ward_id,
	case 
		when bh.gp_id is not null then concat(cgpm.gp_name, ' (G)')
		when bh.ward_id is not null then concat(cwm.ward_name, ' (W)')
		else 'N/A'
	end as gp_or_ward,
	bh.police_station_id,
	cpsm.ps_name as police_station_name,
	bh.sub_district_id as police_district_id,
	csdm.sub_district_name as Police_district,
	bh.assembly_const_id as assembly_id,
	cam.assembly_name as assembly_name,
	bh.grievance_category as grievance_category_id,
	cgcm.grievance_category_desc as grievance_category,
	bh.grievance_description,
--	case 
--		when bh.assigned_to_office_id is not null then bh.assigned_to_office_id
--		else null
--	end as forwarded_to_hod_office_id,
--	com.office_name as forwarded_to_hod_office,  --- forwarded_to_hod or assigned_to_hod
	case 
		when fl.assigned_to_office_id is not null then fl.assigned_to_office_id
		else null
	end as forwarded_to_hod_office_id,
	com.office_name as forwarded_to_hod_office,  --- forwarded_to_hod or assigned_to_hod
	bh.status as current_status_id,
	case 
		when bh.status is not null then cdlm4.domain_value 
		else 'N/A'
	end as current_status,
	bh.assigned_to_position,
	CASE
	  WHEN bh.assigned_to_position IS NULL THEN 'N/A'
	  ELSE concat(pi.official_name, ' -', pi.official_phone, ' [', pi.designation_name, ' (', pi.office_name, ') - ', pi.role_master_name, ']')
	END AS pending_with, ---pending with 
	bh.closure_reason_id,
	case 
		when bh.closure_reason_id is not null then ccrm.closure_reason_name
		else 'N/A'
	end as closure_reason_name,
	bh.grievence_close_date as closure_date,
	glatm.assigned_by_office_id,
	glatm.assigned_by_position,
	glatm.assigned_by_id,
	CASE 
	  WHEN glatm.assigned_by_position IS NULL THEN 'N/A'
	  ELSE concat(asi.official_name, ' -', asi.official_phone, ' [', asi.designation_name, ' (', asi.office_name, ') - ', asi.role_master_name, ']')
	END AS last_atr_submited_by, --last_atr_submited_by
	case 
		when bh.action_taken_note is not null then bh.action_taken_note
		else 'N/A'
	end as last_atr_remarks,
	bh.atn_id,
	case 
		when bh.atn_id is not null then catnm.atn_desc
		else 'N/A'
	end as last_action_taken_note
from grievance_master_bh_mat_2 as bh 
left join forwarded_latest_3_5_bh_mat fl on fl.grievance_id = bh.grievance_id and bh.assigned_to_office_id = fl.assigned_to_office_id 
left join cmo_domain_lookup_master cdlm on cdlm.domain_code = bh.grievance_source and cdlm.domain_type = 'grievance_source'
left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_id = bh.receipt_mode
left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = bh.received_at and cdlm2.domain_type = 'received_at_location'
left join cmo_caste_master ccm on ccm.caste_id = bh.applicant_caste
left join cmo_religion_master crm on crm.religion_id = bh.applicant_reigion
left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_code = bh.applicant_gender and cdlm3.domain_type = 'gender'
left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = bh.gp_id 
left join cmo_wards_master cwm on cwm.ward_id = bh.ward_id 
left join cmo_police_station_master cpsm on cpsm.ps_id = bh.police_station_id
left join cmo_sub_districts_master csdm on csdm.sub_district_id = cpsm.sub_district_id /*and bh.sub_district_id = csdm.sub_district_id */
left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = bh.grievance_category 
left join cmo_office_master com on com.office_id = fl.assigned_to_office_id
left join cmo_closure_reason_master ccrm on bh.closure_reason_id = ccrm.closure_reason_id 
left join cmo_action_taken_note_master catnm on catnm.atn_id = bh.atn_id  
left JOIN admin_position_detail_mat pi ON pi.position_id = bh.assigned_to_position and pi.position_id = fl.assigned_to_position 
left join grievance_latest_atr_trail_mat glatm on glatm.grievance_id = bh.grievance_id
left JOIN admin_position_detail_mat asi ON asi.position_id = glatm.assigned_by_position
left join cmo_domain_lookup_master cdlm4 on bh.status = cdlm4.domain_code and cdlm4.domain_type = 'grievance_status'
where fl.assigned_to_office_id = 35 
order by bh.grievance_generate_date desc 
--limit 10 offset 0;



	-- count --
	select count(1)
from grievance_master_bh_mat_2 as bh 
left join forwarded_latest_3_bh_mat fl on fl.grievance_id = bh.grievance_id
--left join forwarded_latest_5_bh_mat fl1 on fl1.grievance_id = bh.grievance_id
--left join forwarded_latest_3_5_bh_mat fl on fl.grievance_id = bh.grievance_id
left join cmo_domain_lookup_master cdlm on cdlm.domain_code = bh.grievance_source and cdlm.domain_type = 'grievance_source'
left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_id = bh.receipt_mode
left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = bh.received_at and cdlm2.domain_type = 'received_at_location'
left join cmo_caste_master ccm on ccm.caste_id = bh.applicant_caste
left join cmo_religion_master crm on crm.religion_id = bh.applicant_reigion
left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_code = bh.applicant_gender and cdlm3.domain_type = 'gender'
left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = bh.gp_id 
left join cmo_wards_master cwm on cwm.ward_id = bh.ward_id 
left join cmo_police_station_master cpsm on cpsm.ps_id = bh.police_station_id
left join cmo_sub_districts_master csdm on csdm.sub_district_id = cpsm.sub_district_id /*and bh.sub_district_id = csdm.sub_district_id */
left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = bh.grievance_category 
left join cmo_office_master com on com.office_id = fl.assigned_to_office_id
left join cmo_closure_reason_master ccrm on bh.closure_reason_id = ccrm.closure_reason_id 
left join cmo_action_taken_note_master catnm on catnm.atn_id = bh.atn_id  
left JOIN admin_position_detail_mat pi ON pi.position_id = bh.assigned_to_position and pi.position_id = fl.assigned_to_position 
left join grievance_latest_atr_trail_mat glatm on glatm.grievance_id = bh.grievance_id
left JOIN admin_position_detail_mat asi ON asi.position_id = glatm.assigned_by_position
left join cmo_domain_lookup_master cdlm4 on bh.status = cdlm4.domain_code and cdlm4.domain_type = 'grievance_status'
--where fl.assigned_to_office_id = 35
	

SELECT com.office_name, COUNT(1) 
FROM forwarded_latest_3_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
where bh.assigned_to_office_id = 35
group by com.office_name;
	

select com.office_name,count(1) 
from forwarded_latest_5_bh_mat as bh 
left join cmo_office_master com on bh.assigned_to_office_id = com.office_id
group by com.office_name;



--- filter count ---
with uinion_part as (       
            select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
            union
            select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
    )
    Select Count(1)  
from grievance_master_bh_mat_2 as bh 
--from grievance_master as bh 
inner join uinion_part as lu on lu.grievance_id = bh.grievance_id 
left join cmo_domain_lookup_master cdlm on cdlm.domain_code = bh.grievance_source and cdlm.domain_type = 'grievance_source'
left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_id = bh.receipt_mode
left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = bh.received_at and cdlm2.domain_type = 'received_at_location'
left join cmo_caste_master ccm on ccm.caste_id = bh.applicant_caste
left join cmo_religion_master crm on crm.religion_id = bh.applicant_reigion
left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_code = bh.applicant_gender and cdlm3.domain_type = 'gender'
left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = bh.gp_id 
left join cmo_wards_master cwm on cwm.ward_id = bh.ward_id 
left join cmo_police_station_master cpsm on cpsm.ps_id = bh.police_station_id
left join cmo_sub_districts_master csdm on csdm.sub_district_id = cpsm.sub_district_id
left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = bh.grievance_category 
left join cmo_office_master com on com.office_id = bh.assigned_to_office_id
left join cmo_closure_reason_master ccrm on bh.closure_reason_id = ccrm.closure_reason_id 
left join cmo_action_taken_note_master catnm on catnm.atn_id = bh.atn_id  
left JOIN admin_position_detail_mat pi ON pi.position_id = bh.assigned_to_position and pi.position_id = bh.assigned_to_position 
left join grievance_latest_atr_trail_mat glatm on glatm.grievance_id = bh.grievance_id
left JOIN admin_position_detail_mat asi ON asi.position_id = glatm.assigned_by_position
left join cmo_domain_lookup_master cdlm4 on bh.status = cdlm4.domain_code and cdlm4.domain_type = 'grievance_status'
--where bh.assigned_to_office_id = 35
where (bh.grievance_generate_date::date) between '2025-07-30' and '2025-07-31'



with uinion_part as (
                    select grievance_id from forwarded_latest_5_bh_mat_2 where assigned_to_office_id = 35
                    union
                    select grievance_id from forwarded_latest_3_bh_mat_2 where assigned_to_office_id = 35
            )
            Select Count(1)
                from grievance_master md
                inner join uinion_part as lu on lu.grievance_id = md.grievance_id
                
                
WITH union_part AS (
    SELECT grievance_id, assigned_to_office_id
    FROM (
        SELECT grievance_id, assigned_to_office_id
        FROM forwarded_latest_5_bh_mat_2 
        WHERE assigned_to_office_id = 35
        UNION
        SELECT grievance_id , assigned_to_office_id
        FROM forwarded_latest_3_bh_mat_2 
        WHERE assigned_to_office_id = 35
    ) x
)
SELECT COUNT(1)
FROM grievance_master md
INNER JOIN union_part lu ON lu.grievance_id = md.grievance_id





WITH union_part AS (
    SELECT grievance_id, assigned_to_office_id
    FROM (
        SELECT grievance_id, assigned_to_office_id
        FROM forwarded_latest_5_bh_mat_2 
        WHERE assigned_to_office_id = 35
        UNION
        SELECT grievance_id , assigned_to_office_id
        FROM forwarded_latest_3_bh_mat_2 
        WHERE assigned_to_office_id = 35
    ) x
)
select 
    bh.grievance_id,
    bh.grievance_no,
    bh.grievance_source as grievance_source_id,
    cdlm.domain_value as grievance_source,
    bh.grievance_generate_date::date as lodge_date,
    bh.receipt_mode as received_mode_id,
    cgrmm.grivence_source_name as received_mode,
    bh.received_at as received_at_id,
    cdlm2.domain_value as received_at,
    bh.applicant_name as complainant_name,
    bh.pri_cont_no as mobile_number,
    bh.applicant_caste as cast_id,
    ccm.caste_name as caste_name,
    bh.applicant_reigion as religion_id,
    crm.religion_name as religion_name,
    bh.applicant_age as age,
    bh.applicant_address,
    bh.applicant_gender as gender_id,
    cdlm3.domain_value as gender,
    bh.district_id,
    cdm.district_name,
    bh.block_id,	
    bh.municipality_id,
    case 
        when bh.block_id is not null then concat(cbm.block_name, ' (B)')
        when bh.municipality_id is not null then concat(cmm.municipality_name, ' (M)')
        else 'N/A'
    end as block_or_municipality,
    bh.gp_id,
    bh.ward_id,
    case 
        when bh.gp_id is not null then concat(cgpm.gp_name, ' (G)')
        when bh.ward_id is not null then concat(cwm.ward_name, ' (W)')
        else 'N/A'
    end as gp_or_ward,
    bh.police_station_id,
    cpsm.ps_name as police_station_name,
    bh.sub_district_id as police_district_id,
    csdm.sub_district_name as police_district,
    bh.assembly_const_id as assembly_id,
    cam.assembly_name as assembly_name,
    bh.grievance_category as grievance_category_id,
    cgcm.grievance_category_desc as grievance_category,
    bh.grievance_description,
    case 
        when lu.assigned_to_office_id is not null then lu.assigned_to_office_id
        else bh.assigned_to_office_id
    end as forwarded_to_hod_office_id,  
    case
    	when lu.assigned_to_office_id is not null then com2.office_name
    	else com.office_name
    end as forwarded_to_hod_office,  --forwarded to office
--       case 
--          when bh.assigned_to_office_id is not null then bh.assigned_to_office_id
--          else null
--       end as forwarded_to_hod_office_id,   
--  com.office_name as forwarded_to_hod_office,  --forwarded to office
    bh.status as current_status_id,
    case 
        when bh.status is not null then cdlm4.domain_value 
        else 'N/A'
    end as current_status,
    bh.assigned_to_position,
    case
        when bh.assigned_to_position IS null THEN 'N/A'
        else concat(pi.official_name, ' -', pi.official_phone, ' [', pi.designation_name, ' (', pi.office_name, ') - ', pi.role_master_name, ']')
    end AS pending_with,     ---pending with 
    bh.closure_reason_id,
    case 
        when bh.closure_reason_id is not null then ccrm.closure_reason_name
        else 'N/A'
    end as closure_reason_name,
    bh.grievence_close_date as closure_date,
    glatm.assigned_by_office_id,
    glatm.assigned_by_position,
    glatm.assigned_by_id,
    case 
        when glatm.assigned_by_position IS NULL THEN 'N/A'
        else concat(asi.official_name, ' -', asi.official_phone, ' [', asi.designation_name, ' (', asi.office_name, ') - ', asi.role_master_name, ']')
    end AS last_atr_submited_by,     --last_atr_submited_by
    case 
        when bh.action_taken_note is not null then bh.action_taken_note
        else 'N/A'
    end as last_atr_remarks, --- last atr remarks
    bh.atn_id,
    case 
        when bh.atn_id is not null then catnm.atn_desc
        else 'N/A'
    end as last_action_taken_note   -- last_action_taken_note
    from grievance_master_bh_mat_2 as bh 
    inner join union_part as lu on lu.grievance_id = bh.grievance_id 
    left join cmo_domain_lookup_master cdlm on cdlm.domain_code = bh.grievance_source and cdlm.domain_type = 'grievance_source'
    left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_id = bh.receipt_mode
    left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = bh.received_at and cdlm2.domain_type = 'received_at_location'
    left join cmo_caste_master ccm on ccm.caste_id = bh.applicant_caste
    left join cmo_religion_master crm on crm.religion_id = bh.applicant_reigion
    left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_code = bh.applicant_gender and cdlm3.domain_type = 'gender'
    left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
    left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
    left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = bh.gp_id 
    left join cmo_wards_master cwm on cwm.ward_id = bh.ward_id 
    left join cmo_police_station_master cpsm on cpsm.ps_id = bh.police_station_id
    left join cmo_sub_districts_master csdm on csdm.sub_district_id = cpsm.sub_district_id
    left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = bh.grievance_category 
    left join cmo_office_master com on com.office_id = bh.assigned_to_office_id 
    left join cmo_office_master com2 on lu.assigned_to_office_id = com2.office_id 
    left join cmo_closure_reason_master ccrm on bh.closure_reason_id = ccrm.closure_reason_id 
    left join cmo_action_taken_note_master catnm on catnm.atn_id = bh.atn_id  
    left join admin_position_detail_mat_2 pi ON pi.position_id = bh.assigned_to_position
    left join grievance_latest_atr_trail_mat_2 glatm on glatm.grievance_id = bh.grievance_id
    left join admin_position_detail_mat_2 asi on asi.position_id = glatm.assigned_by_position
    left join cmo_domain_lookup_master cdlm4 on bh.status = cdlm4.domain_code and cdlm4.domain_type = 'grievance_status'
    where 1 = 1 
--                and bh.status::integer in (15)
--    and (bh.grievance_generate_date::date) between '2025-07-30' and '2025-07-31'
    order by bh.grievance_generate_date desc  offset 0 limit 10 
--                offset 0 limit 10

    
    
    select * from grievance_lifecycle gl where gl.grievance_id = 5713383;






	--------------------------------------------------------------------------------------------------------------------------------
----listing query -----
select distinct
        md.grievance_id,
        md.grievance_no,
        md.grievance_source as grievance_source_id,
        cdlm2.domain_value as grievance_source,
        md.grievance_generate_date::date as lodge_date,
        md.receipt_mode as received_mode_id,
		cgrmm.grivence_source_name as received_mode,
		md.received_at as received_at_id,
		cdlm3.domain_value as received_at,
        md.applicant_name as complainant_name,
        md.pri_cont_no as mobile_number,
        md.applicant_caste as cast_id,
		ccm.caste_name as caste_name,
		md.applicant_reigion as religion_id,
		crm.religion_name as religion_name,
		md.applicant_age as age,
		md.applicant_gender as gender_id,
		cdlm4.domain_value as gender,
		md.district_id,
		md.district_name,
		md.block_id,	
		md.municipality_id,
		case 
			when md.block_id is not null then concat(md.block_name, ' (B)')
			when md.municipality_id is not null then concat(md.municipality_name, ' (M)')
			else 'NA'
		end as block_or_municipality, 
        md.block_name,
        md.municipality_name,
        case
            when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
            when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
            else null
        end as block_or_municipalty_name,
        md.gp_id,
		md.ward_id,
		case 
			when md.gp_id is not null then concat(md.gp_name, ' (G)')
			when md.ward_id is not null then concat(md.ward_name, ' (W)')
			else 'NA'
		end as gp_or_ward,
        md.gp_id,
        md.ward_id,
        case
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
            ELSE NULL
        end as gp_or_ward_name,
        md.police_station_id,
		cpsm.ps_name as police_station_name,
        csdm.sub_district_id as police_district_id,
		csdm.sub_district_name as Police_district,
		md.assembly_const_id as assembly_id,
		cam.assembly_name as assembly_name,
		md.grievance_category as grievance_category_id,
		cgcm.grievance_category_desc as grievance_category,
        md.grievance_description,
        case 
			when md.assigned_to_office_id is not null then md.assigned_to_office_id
			else Null
		end as forwarded_to_hod_office_id,
		case 
			when md.assigned_to_office_id is not null then com.office_name
		end as forwarded_to_hod_office,
		md.status as status,
		cdlm.domain_value as current_status,
		md.assigned_to_position,
        case
            when md.assigned_to_position  is null then 'N/A'
            else concat(ad.official_name, ' -', ad.official_phone, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ']' )
        end as pending_with,
        md.closure_reason_id,
		ccrm.closure_reason_name,
		md.grievence_close_date as closure_date,
		md.atr_submit_by_lastest_office_id, ---last_atr_submited_by
		md.atn_id,
		catnm.atn_desc as last_action_taken_note
		md.action_taken_note as last_atr_remarks
    from master_district_block_grv md
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join cmo_sub_districts_master csdm on csdm.sub_district_id = cpsm.sub_district_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = md.grievance_source and cdlm2.domain_type = 'grievance_source'
    left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_id = md.receipt_mode
    left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_code = md.received_at and cdlm3.domain_type = 'received_at_location'
    left join cmo_caste_master ccm on ccm.caste_id = md.applicant_caste
    left join cmo_religion_master crm on crm.religion_id = md.applicant_reigion
    left join cmo_domain_lookup_master cdlm4 on cdlm4.domain_code = md.applicant_gender and cdlm4.domain_type = 'gender'
    left join cmo_assembly_master cam on cam.assembly_id = md.assembly_const_id 
--    and md.assigned_to_office_id = 5
        order by grievance_generate_date asc limit 1 offset 0

        
        
------------------------------------------------------------------
    
 select * from grievance_master gm where gm.status = 15 limit 1;
 select count(1) from grievance_master gm;  --2121
 select count(1) from grievance_master_bh_mat_2 gmbm;  
 
   
 select distinct gl.grievance_id, gl.lifecycle_id, gl.assigned_on
 from grievance_lifecycle gl where gl.grievance_status = 12 
 and assigned_to_office_cat != 3
 order by gl.assigned_on asc ;
  
select * from grievance_lifecycle gl where gl.lifecycle_id = 36940060;
select * from grievance_lifecycle gl where gl.grievance_id = 987564;
select * from grievance_master gm where gm.grievance_id = 987564;
   
select * from admin_position_master apm ;
select * from admin_user_role_master aurm ;
     
      -- back track --
select * from admin_user_position_mapping aupm where aupm.position_id = 10112;
select * from admin_user_details aud where aud.admin_user_id = 10112;
select * from admin_user au where au.admin_user_id = 10112;
select * from admin_position_master apm where apm.position_id = 10112;
     
     
   ------------ Latest ATR Sent By Materialised View ------------
--DROP MATERIALIZED VIEW IF EXISTS public.grievance_latest_atr_trail_mat CASCADE;
     
CREATE MATERIALIZED VIEW public.grievance_latest_atr_trail_mat_2
TABLESPACE pg_default
as WITH ranked_trails AS (
	SELECT
        gl.*,
        ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
    FROM
        grievance_lifecycle gl
    WHERE
        gl.grievance_status IN (6, 9, 10, 11, 12, 13, 14)
)
SELECT 
	rt.grievance_id,
    rt.grievance_status,
    rt.assigned_by_office_id,
    rt.assigned_to_office_id,
    rt.assigned_by_position,
    rt.assigned_to_position,
    rt.assigned_by_id,
    rt.assigned_to_id,
    rt.assigned_on
    from ranked_trails rt
--   FROM grievance_master gm
--     LEFT JOIN ranked_trails rt ON gm.grievance_id = rt.grievance_id
WHERE
    rt.rn = 1;
---------------------------------------------------------------------------------   
   
   
--------  Admin Position Details Materalised View -------------
CREATE MATERIALIZED VIEW admin_position_detail_mat_2 AS
SELECT
  apm.position_id,
  ad.admin_user_id,
  ad.official_name,
  ad.official_phone,
  cdm.designation_name,
  com.office_name,
  aurm.role_master_name
FROM admin_user_position_mapping aupm
JOIN admin_user_details ad ON aupm.admin_user_id = ad.admin_user_id
JOIN admin_position_master apm ON aupm.position_id = apm.position_id
JOIN cmo_designation_master cdm ON cdm.designation_id = apm.designation_id
JOIN cmo_office_master com ON com.office_id = apm.office_id
JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id
WHERE aupm.status = 1;
-------------------------------------------------------------------------------


------ Recived From CMO and Other HOD Aggregation Total Result Meterialized View -------
--DROP MATERIALIZED VIEW IF EXISTS public.forwaded_latest_3_5_total_bh_mat CASCADE;

--CREATE MATERIALIZED VIEW forwaded_latest_3_5_total_bh_mat AS
SELECT
    assigned_to_office_id,
    SUM(count_val) AS total_count
FROM (
    SELECT assigned_to_office_id, COUNT(*) AS count_val
    FROM forwarded_latest_3_bh_mat mat1
    GROUP BY assigned_to_office_id
    UNION ALL
    SELECT assigned_to_office_id, COUNT(*) AS count_val
    FROM forwarded_latest_5_bh_mat mat2
    GROUP BY assigned_to_office_id
) combined
GROUP BY assigned_to_office_id;
----------------------------------------------------------------------------------------------


----- Listing Fixed ------- Act on grievance -----

select count(1) as griev_count 
--select *
    from grievance_master gm 
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where not exists ( select 1 from grievance_auto_assign_map gam where gm.grievance_category = gam.grievance_cat_id and gam.status in (1)) and gm.grievance_id > 0  and gm.emergency_flag = 'N' and gm.status in (1) 
   
   
   
select count(1) 
    from master_district_block_grv md
    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    where not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status in (1))
    and md.grievance_id > 0
            and md.status in (1) 
            and md.assigned_to_office_id = 5 
        and replace(lower(md.emergency_flag),' ','') like '%n%'
        
        
        
 ------------------------------------------------------------------
        
  ------------- Listing fixed -------- act on atr --------
        
select count(1) as griev_count 
from grievance_master gm 
left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
where gm.grievance_id > 0  and gm.status in (14);



with lastupdates AS (
                    select 
                        grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_lifecycle
                    where grievance_lifecycle.grievance_status in (3,5)
                ),
                master_district_block_grv_data AS (
                    select count(1) 
                    from master_district_block_grv md
                    left join admin_position_master apm on apm.position_id = md.updated_by_position
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
                    left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
                    where md.grievance_id > 0
                        and md.status in (14)    
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd;