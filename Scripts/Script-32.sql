select * from grievance_master gm;


select
	gm.grievance_no,
	gm.applicant_name as complainant_name,
	gm.pri_cont_no as complainant_contact_no,
	gm.district_id,
	cdm.district_name,
	gm.sub_division_id,
	csdm.sub_division_name ,
	gm.block_id ,
	cbm.block_name ,
	gm.municipality_id ,
	cmm.municipality_name ,
	gm.gp_id ,
	cgpm.gp_name,
	gm.ward_id ,
	cwm.ward_name,
	gm.police_station_id ,
	cpsm.ps_name,
	gm.grievance_category,
	gm.grievance_description,
	gm.action_taken_note as last_action_taken_note,
	gm.atn_id
from grievance_master gm
left join cmo_districts_master cdm on cdm.district_id = gm.district_id
left join cmo_sub_divisions_master csdm on csdm.sub_division_id = gm.sub_division_id 
left join cmo_blocks_master cbm on cbm.block_id = gm.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id 
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gm.gp_id 
left join cmo_wards_master cwm on cwm.ward_id = gm.ward_id 
left join cmo_police_station_master cpsm on cpsm.ps_id = gm.police_station_id 
where gm.status = 14;


SELECT
    gm.grievance_no,
    gm.applicant_name AS complainant_name,
    gm.pri_cont_no AS complainant_contact_no,
    cdm.district_name,
    csdm.sub_division_name,
    cbm.block_name,
    cmm.municipality_name,
    cgpm.gp_name,
    cwm.ward_name,
    cpsm.ps_name,
    gm.grievance_category,
    gm.grievance_description,
    gm.action_taken_note AS last_action_taken_note
FROM grievance_master gm
LEFT JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
LEFT JOIN cmo_sub_divisions_master csdm ON csdm.sub_division_id = gm.sub_division_id 
LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = gm.block_id 
LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = gm.municipality_id 
LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = gm.gp_id 
LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = gm.ward_id 
LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = gm.police_station_id 
WHERE gm.status = 14;

SELECT
    gm.grievance_no as grievance_number,
    gm.applicant_name AS complainant_name,
    gm.pri_cont_no AS complainant_mobile_no,
    cdm.district_name as district,
    cbm.block_name as block,
    cmm.municipality_name as municipality,
    cgpm.gp_name as gp,
    cwm.ward_name as ward,
    cpsm.ps_name as police_station,
    gm.grievance_category as grievance_category,
    gm.grievance_description as grievance_description,
    gm.atn_id,
    catnm.atn_desc as last_atr,
    gm.action_taken_note AS last_action_taken_note
FROM grievance_master gm
LEFT JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = gm.block_id 
LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = gm.municipality_id 
LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = gm.gp_id 
LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = gm.ward_id 
LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = gm.police_station_id
left join cmo_action_taken_note_master catnm on catnm.atn_id = gm.atn_id 
WHERE gm.status = 14;


select * from grievance_master gm limit 10;
select * from grievance_master gm where grievance_id = 22799;
select * from grievance_master gm where status = 14;
select * from grievance_lifecycle gl where grievance_id = 22799;
select * from grievance_master gm where grievance_no = '832764120520052024135802';
select * from grievance_master gm where gm.grievance_id in (22806,22807,22808);
select * from grievance_master gm limit 10;
select * from grievance_master gm where gm.status = 15 limit 1;
select * from grievance_master gm where gm.grievance_source =3;


select * from cmo_action_taken_note_master catnm where atn_id = 13;
select * from cmo_user_wise_grievance_ssm cuwgs ;
select * from cmo_municipality_master cmm ;
select * from cmo_wards_master cwm ;
select * from cmo_employment_type_master cetm;
select * from cmo_closure_reason_master ccrm ;
select * from cmo_domain_lookup_master cdlm where domain_type ='grievance_source';
select * from cmo_office_master com ;
select * from cmo_domain_lookup_master cdlm limit 1;
select * from cmo_user_wise_grievance_ssm cuwgs ;
select * from cmo_user_wise_pending cuwp ;
select * from cmo_caste_master ccm ;
select * from cmo_domain_lookup_master cdlm where domain_type = 'gender'; 
select * from cmo_domain_lookup_master cdlm where domain_type = 'address_type'; 
select * from cmo_domain_lookup_master cdlm ; 
select * from cmo_domain_lookup_master cdlm where domain_type = 'user_type';
select * from cmo_domain_lookup_master cdlm where domain_type = 'received_at';
select * from cmo_sub_office_master csom limit 10;
select * from cmo_caste_master ccm ;
select * from cmo_religion_master crm ; 
select * from cmo_districts_master cdm ;
select * from cmo_blocks_master cbm ;
select * from cmo_grievance_category_master cgcm;


select * from admin_position_master apm;

select * from atn_closure_reason_mapping acrm ;
select * from 
select count(gm.grievance_id) from grievance_master gm where gm.status = 15;



select applicant_address from grievance_master gm ;
select domain_type from cmo_domain_lookup_master cdlm ;

select address_type from grievance_master gm ;
select * from cmo_office_master com limit 10;
cmo


SELECT office_id, office_name, COUNT(*) AS total_pending_grievances
FROM grievance_master gm, cmo_office_master com 
WHERE gm.status NOT IN (14,15)
  AND office_category = 2
GROUP BY office_id
ORDER BY total_pending_grievances;


select * from user_type_role_mapping utrm limit 10;
select * from ;
select * from admin_user_position_mapping aupm limit 10;


select office_id, office_name, COUNT(*) AS total_pending_grievances
from grievance_master gm, cmo_office_master com
WHERE gm.status NOT IN (14,15)
and office_category = 2
GROUP BY office_id
ORDER BY total_pending_grievances;


select office_id, office_name, COUNT(*) AS total_pending_grievances
from grievance_master gm, cmo_office_master com
WHERE gm.status NOT IN (14,15)
  AND office_category = 2
GROUP BY office_id
ORDER BY total_pending_grievances DESC
LIMIT 10;


select * from grievance_master gm limit 1;


SELECT SUM(total_pending_grievances) AS total_pending_grievances_sum
FROM (
    SELECT com.office_id, com.office_name, COUNT(*) AS total_pending_grievances
    FROM grievance_master gm
    JOIN cmo_office_master com ON gm.assigned_by_office_id = com.office_id
    WHERE gm.status NOT IN (14, 15)
      AND com.office_category = 2
    GROUP BY com.office_id, com.office_name
) AS office_grievances;




SELECT MAX(total_pending_grievances) AS total_pending_grievances_max
FROM (
    SELECT com.office_id, com.office_name, COUNT(*) AS total_pending_grievances
    FROM grievance_master gm
    JOIN cmo_office_master com ON gm.assigned_by_office_id = com.office_id
    WHERE gm.status NOT IN (14, 15)
      AND com.office_category = 2
    GROUP BY com.office_id, com.office_name
) AS office_grievances;



SELECT 
    COUNT(1) AS grievances_recieved,
    COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed
FROM grievance_master gm
    inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
    inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
    gm.grievance_source = 5 
-- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
    and gm.status IS NOT null
-- and assigned_to_office_id =  3
    and apm.sub_office_id = 1510 and apm.office_id = 27;

   
   
select * from cmo_office_master com where com.office_id=2; 

select * from cmo_office_master com limit 10;

select * from cmo_office_master com where com.office_id=50; 

select * from admin_position_master apm where apm.office_id = 2;

select * from cmo_sub_office_master csom;

select * from grievance_master gm where grievance_source = 1;

select grievance_source from grievance_master gm limit 5;

select * from cmo_domain_lookup_master cdlm ;

select 
COUNT(grievance_id > 0) as total 
from grievance_master gm
inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id  
	 where grievance_source = 5
	 and apm.sub_office_id = 1510 and apm.office_id = 27;
	 
	
select 
COUNT(grievance_id > 0 AND gm.status = 15) as total_close
from grievance_master gm
inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id  
	 where grievance_source = 5
	 and apm.sub_office_id = 1510 and apm.office_id = 27;
	
	
SELECT COUNT(*) 
FROM grievance_master 
WHERE grievance_id > 0;


SELECT COUNT(*) 
FROM grievance_master 
WHERE grievance_id > 0 AND status = 15 and grievance_source = 5;


SELECT COUNT(*) as pending
FROM grievance_master gm, cmo_office_master com
WHERE gm.grievance_id > 0 AND gm.status not in (14,15) and com.office_category = 2;


SELECT COUNT(*) as male
FROM grievance_master 
WHERE grievance_id > 0 AND applicant_gender = 1;


select 
COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
COUNT(CASE WHEN gm.address_type = 2 THEN 1 END) AS total_rural_count,
COUNT(CASE WHEN gm.applicant_caste = 1 THEN 1 END) AS total_general_count,
COUNT(case when gm.status not in (14,15) and com.office_category = 2 then gm.grievance_id end) as pending_grievance
from grievance_master gm, cmo_office_master com ;



select 
COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
COUNT(CASE WHEN gm.address_type = 2 THEN 1 END) AS total_rural_count,
COUNT(CASE WHEN gm.applicant_caste = 1 THEN 1 END) AS total_general_count,
COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance
from grievance_master gm;


select 
COUNT(case when gm.status not in (14,15) and com.office_category = 2 and office_id = then gm.grievance_id end) as pending_grievance
from grievance_master gm, cmo_office_master com;


SELECT 
    COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
    COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS grievances_recieved_female,
    COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others,
    COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
    COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count,
    COUNT(CASE WHEN gm.applicant_caste   = 1 THEN 1 END) AS total_general_count,
    COUNT(CASE WHEN gm.applicant_caste   = 2 THEN 1 END) AS total_sc_count,
    COUNT(CASE WHEN gm.applicant_caste   = 3 THEN 1 END) AS total_st_count,
    COUNT(CASE WHEN gm.applicant_caste   = 4 THEN 1 END) AS total_obc_a_count,
    COUNT(CASE WHEN gm.applicant_caste   = 5 THEN 1 END) AS total_obc_b_count,
    COUNT(CASE WHEN gm.applicant_caste   = 6 THEN 1 END) AS total_not_disclosed_count,
    COUNT(CASE WHEN gm.applicant_caste   = 7 THEN 1 END) AS total_test_caste_count,
    COUNT(case when gm.status not in (14,15) and com.office_category = 2 then gm.grievance_id end) as pending_grievance
--address_type, *
FROM cmo_office_master com, grievance_master gm 
    inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
    inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
    gm.grievance_source = 5 
-- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
    and gm.status IS NOT null
-- and assigned_to_office_id =  3
    and apm.sub_office_id = 1097 and apm.office_id = 14;

   
SELECT 
    COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
    COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS grievances_recieved_female,
    COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others,
    COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
    COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count,
    COUNT(CASE WHEN gm.applicant_caste   = 1 THEN 1 END) AS total_general_count,
    COUNT(CASE WHEN gm.applicant_caste   = 2 THEN 1 END) AS total_sc_count,
    COUNT(CASE WHEN gm.applicant_caste   = 3 THEN 1 END) AS total_st_count,
    COUNT(CASE WHEN gm.applicant_caste   = 4 THEN 1 END) AS total_obc_a_count,
    COUNT(CASE WHEN gm.applicant_caste   = 5 THEN 1 END) AS total_obc_b_count,
    COUNT(CASE WHEN gm.applicant_caste   = 6 THEN 1 END) AS total_not_disclosed_count,
    COUNT(CASE WHEN gm.applicant_caste   = 7 THEN 1 END) AS total_test_caste_count,
    COUNT(case when gm.status not in (14,15) and com.office_category = 2 then gm.grievance_id end) as pending_grievance
--address_type, *
FROM cmo_office_master com, grievance_master gm 
    inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
    inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
    gm.grievance_source = 5 
-- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
    and gm.status IS NOT null
-- and assigned_to_office_id =  3
    and apm.sub_office_id = 1097 and apm.office_id = 14;
 
  
   
SELECT COUNT(*) 
  FROM grievance_master gm,
	WHERE grievance_id > 0 
	and grievance_source = 5
	AND address_type = 1;
	

SELECT COUNT(*) 
FROM grievance_master 
WHERE grievance_id > 0 
  AND applicant_caste = 1;
	

select count(1) as g_count,
--	COUNT(DISTINCT grievance_id) AS mater_taken_up,
	com.office_name
 from 
 	grievance_lifecycle gl 
 left join 
 	cmo_office_master com on com.office_id = gl.assigned_by_office_id 
 where 
 	gl.grievance_status = 14
 	and com.office_category =2
 group by 
 	com.office_name ;
 	
 select count(1) as g_count,
--	COUNT(DISTINCT grievance_id) AS mater_taken_up,
	com.office_name
 from 
 	grievance_master gm 
 left join 
 	cmo_office_master com on com.office_id = gm.assigned_by_office_id 
 where 
 	gm.status = 14
 	and com.office_category =2
 group by 
 	com.office_name ;
 	
 
 
 select
	count(1) as district_wise_count,
	gm.district_id,
	cdm.district_name,
	(COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS district_wise_percentage
from grievance_master gm
left join cmo_districts_master cdm on cdm.district_id = gm.district_id
group by gm.district_id,cdm.district_name