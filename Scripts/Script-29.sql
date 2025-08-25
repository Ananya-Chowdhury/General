select 
	COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others
	from grievance_master gm;


select
	MAX(CASE WHEN gm.applicant_reigion = 1  THEN gm.religionwise_count END) AS grievances_received_hindu,
    MAX(CASE WHEN gm.applicant_reigion = 2 THEN gm.religionwise_count END) AS grievances_received_muslim,
    MAX(CASE WHEN gm.applicant_reigion = 3 THEN gm.religionwise_count END) AS grievances_received_christian,
    MAX(CASE WHEN gm.applicant_reigion = 4  THEN 1 END) AS grievances_received_buddhist,
    MAX(CASE WHEN gm.applicant_reigion = 5 THEN 1 END) AS grievances_received_sikh,
    MAX(CASE WHEN gm.applicant_reigion = 6 THEN 1 END) AS grievances_received_jain,
    MAX(CASE WHEN gm.applicant_reigion = 7 THEN 1 END) AS grievances_received_other,
    MAX(CASE WHEN gm.applicant_reigion = 8 THEN 1 END) AS grievances_received_not_known,
    MAX(CASE WHEN gm.applicant_reigion = 9 THEN 1 END) AS grievances_received_test_religion,
    MAX(CASE WHEN gm.applicant_reigion is null THEN 1 END) AS grievances_received_no_religion
	from (select
			count(1) as religionwise_count,
			gm.applicant_reigion,
			crm.religion_name 
		from grievance_master gm
		left join cmo_religion_master crm on crm.religion_id = gm.applicant_reigion
		where gm.created_on >= '2023-06-08'
		group by gm.applicant_reigion,crm.religion_name) as gm;
	
	
select
	MAX(CASE WHEN gm.applicant_caste = 1  THEN gm.caste_wise_count END) AS grievances_received_hindu,
    MAX(CASE WHEN gm.applicant_caste = 2 THEN gm.caste_wise_count END) AS grievances_received_muslim,
    MAX(CASE WHEN gm.applicant_caste = 3 THEN gm.caste_wise_count END) AS grievances_received_christian,
    MAX(CASE WHEN gm.applicant_caste = 4  THEN gm.caste_wise_count END) AS grievances_received_buddhist,
    MAX(CASE WHEN gm.applicant_caste = 5 THEN gm.caste_wise_count END) AS grievances_received_sikh,
    MAX(CASE WHEN gm.applicant_caste = 6 THEN gm.caste_wise_count END) AS grievances_received_jain,
    MAX(CASE WHEN gm.applicant_caste = 7 THEN gm.caste_wise_count END) AS grievances_received_other
	from (select
			count(1) as caste_wise_count,
			gm.applicant_caste,
			ccm.caste_name
		from grievance_master gm
		left join cmo_caste_master ccm on ccm.caste_id = gm.applicant_caste
		where gm.created_on >= '2023-06-08'
		group by gm.applicant_caste,ccm.caste_name) as gm;
	
	
	select
			count(1) as caste_wise_count,
			gm.applicant_caste,
			ccm.caste_name
		from grievance_master gm
		left join cmo_caste_master ccm on ccm.caste_id = gm.applicant_caste
		where gm.created_on >= '2023-06-08'
		group by gm.applicant_caste,ccm.caste_name
	
	
	
	
	
	select
	g2.grievances_received_general,
	(g2.grievances_received_general/g2.total_count::float)*100 as grievances_received_general_percentage
from
	(select
		SUM(g1.caste_wise_count) as total_count,
		MAX(CASE WHEN g1.applicant_caste = 1  THEN g1.caste_wise_count END) AS grievances_received_general,
		MAX(CASE WHEN g1.applicant_caste = 2  THEN g1.caste_wise_count END) AS grievances_received_sc,
		MAX(CASE WHEN g1.applicant_caste = 3  THEN g1.caste_wise_count END) AS grievances_received_st,
		MAX(CASE WHEN g1.applicant_caste is null THEN g1.caste_wise_count END) AS grievances_received_no_caste
	from 
		(SELECT
    COUNT(1) AS caste_wise_count,
    gm.applicant_caste,
    ccm.caste_name
		FROM grievance_master gm
		LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
		WHERE gm.created_on >= '2023-06-08'
		GROUP BY gm.applicant_caste, ccm.caste_name) g1) g2;
			
	
	
SELECT
    COUNT(1) AS caste_wise_count,
    gm.applicant_caste,
    ccm.caste_name,
    (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS caste_wise_percentage
FROM grievance_master gm
LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
WHERE gm.created_on >= '2023-06-08'
GROUP BY gm.applicant_caste, ccm.caste_name;

	
select
	count(1) as district_wise_count,
	gm.district_id,
	cdm.district_name,
	(COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS district_wise_percentage
from grievance_master gm
left join cmo_districts_master cdm on cdm.district_id = gm.district_id
group by gm.district_id,cdm.district_name;


-- Query for caste-wise data
SELECT
    'Caste' AS category,
    COUNT(1) AS count,
    gm.applicant_caste,
    ccm.caste_name,
    (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
FROM grievance_master gm
LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
WHERE gm.created_on >= '2023-06-08'
GROUP BY gm.applicant_caste, ccm.caste_name
UNION ALL
-- Query for religion-wise data
SELECT
    'Religion' AS category,
    count(1) AS count,
    gm.applicant_reigion,
    crm.religion_name,
    (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
FROM grievance_master gm
LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
WHERE gm.created_on >= '2023-06-08'
GROUP BY gm.applicant_reigion, crm.religion_name;


-- Query for caste-wise data
SELECT
    'Caste' AS category,
    COUNT(1) AS count,
    gm.applicant_caste,
    ccm.caste_name,
    (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
FROM grievance_master gm
LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
WHERE gm.created_on >= '2023-06-08'
GROUP BY gm.applicant_caste, ccm.caste_name
UNION ALL
-- Query for religion-wise data
SELECT
    'Religion' AS category,
    COUNT(1) AS count,
    gm.applicant_reigion,
    crm.religion_name,
    (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
FROM grievance_master gm
LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
WHERE gm.created_on >= '2023-06-08'
GROUP BY gm.applicant_reigion, crm.religion_name
-- Query for caste-wise data


-- Query for caste-wise data
SELECT
    'Caste' AS category,
    COUNT(1) AS count,
    gm.applicant_caste,
    ccm.caste_name AS name,  -- Alias for caste_name
    (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
FROM grievance_master gm
LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
WHERE gm.created_on >= '2023-06-08'
GROUP BY gm.applicant_caste, ccm.caste_name
UNION ALL
SELECT
    'Religion' AS category,
    COUNT(1) AS count,
    gm.applicant_reigion,
    crm.religion_name AS name,
    (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
FROM grievance_master gm
LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
WHERE gm.created_on >= '2023-06-08'
GROUP BY gm.applicant_reigion, crm.religion_name
ORDER BY category, name;





--2214641--

	
select
	MAX(CASE WHEN gm.applicant_reigion = 1  THEN gm.religionwise_count END) AS grievances_received_hindu,
    MAX(CASE WHEN gm.applicant_reigion = 2 THEN gm.religionwise_count END) AS grievances_received_muslim,
    MAX(CASE WHEN gm.applicant_reigion = 3 THEN gm.religionwise_count END) AS grievances_received_christian,
    MAX(CASE WHEN gm.applicant_reigion = 4  THEN 1 END) AS grievances_received_buddhist,
    MAX(CASE WHEN gm.applicant_reigion = 5 THEN 1 END) AS grievances_received_sikh,
    MAX(CASE WHEN gm.applicant_reigion = 6 THEN 1 END) AS grievances_received_jain,
    MAX(CASE WHEN gm.applicant_reigion = 7 THEN 1 END) AS grievances_received_other,
    MAX(CASE WHEN gm.applicant_reigion = 8 THEN 1 END) AS grievances_received_not_known,
    MAX(CASE WHEN gm.applicant_reigion = 9 THEN 1 END) AS grievances_received_test_religion,
    MAX(CASE WHEN gm.applicant_reigion is null THEN 1 END) AS grievances_received_no_religion
	from (select
			count(1) as religionwise_count,
			gm.applicant_reigion,
			crm.religion_name 
		from grievance_master gm
		left join cmo_religion_master crm on crm.religion_id = gm.applicant_reigion
		where gm.grievance_generate_date >= '2023-06-08'
		group by gm.applicant_reigion,crm.religion_name) as gm;
	
	
	
	
		left join (select
			count(1) as religionwise_count,
			gm.applicant_reigion,
			crm.religion_name 
		from grievance_master gm
		left join cmo_religion_master crm on crm.religion_id = gm.applicant_reigion
		where gm.created_on >= '2023-06-08'
		group by gm.applicant_reigion,crm.religion_name) gm2 on gm2.gri;


select religion_name, religion_code from cmo_religion_master;
from grievance_master gm;
	

select
COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_general_count,
				    COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_sc_count,
				    COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_st_count,
				    COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_a_count,
				    COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_b_count,
				    COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_not_disclosed_count,
				    COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_test_caste_count
		from grievance_master gm;
	
	
select
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) AS age_below_18,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) AS age_18_30,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) AS age_31_45,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) AS age_46_60,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) AS age_above_60
from grievance_master gm;  
				    

select count(1) from grievance_master gm where gm.grievance_generate_date >= '2023-06-08';
and gm.applicant_gender IS NULL;

select count(1) from grievance_master gm where gm.grievance_generate_date >= '2023-06-08'
--and gm.applicant_caste is null 
and gm.applicant_caste in (1,2,3,4,5,6,7);

SELECT COUNT(1) 
FROM grievance_master gm 
-- WHERE gm.applicant_reigion IS NULL;
where gm.applicant_reigion is null /*or gm.applicant_reigion :: text = ''*/ and gm.created_on >= '2023-06-08';


SELECT COUNT(gm.grievance_id) 
FROM grievance_master gm 
WHERE gm.applicant_reigion IS NULL;

SELECT 
    COUNT(1) AS total,
    COUNT(CASE WHEN gm.created_on IS NULL THEN 1 END) AS null_count,
    COUNT(CASE WHEN gm.created_on IS NOT NULL THEN 1 END) AS not_null_count
FROM grievance_master gm;

select
	count(1) as religionwise_count,
	gm.applicant_reigion,
	crm.religion_name 
from grievance_master gm
left join cmo_religion_master crm on crm.religion_id = gm.applicant_reigion
where gm.created_on >= '2023-06-08'
group by gm.applicant_reigion,crm.religion_name;

select * from cmo_domain_lookup_master cdlm;

select count(1) from grievance_master gm where gm.grievance_generate_date >= '2023-06-08';

select count(1) from grievance_master gm /*where gm.created_on >= '2023-06-08'*/;

select
	g2.grievances_received_male,
	(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage
from
	(select
		SUM(g1.gender_wise_count) as total_count,
		MAX(CASE WHEN g1.applicant_gender = 1  THEN g1.gender_wise_count END) AS grievances_received_male,
		MAX(CASE WHEN g1.applicant_gender = 2  THEN g1.gender_wise_count END) AS grievances_received_female,
		MAX(CASE WHEN g1.applicant_gender = 3  THEN g1.gender_wise_count END) AS grievances_received_other,
		MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
	from 
		(select
			count(1) as gender_wise_count,
			gm.applicant_gender,
			cdlm.domain_value as gender_name
		from grievance_master gm
		left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
		where gm.grievance_generate_date >= '2023-06-08'
		group by gm.applicant_gender, cdlm.domain_value) g1) g2;
		
	
	
	
SELECT 
    COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS unassigned_grievance,
    COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS unassigned_atr
FROM grievance_master gm
    where gm.grievance_source = 5;
    
                       
                       
                       
                       
                       
                       
select count(1) from grievance_master gm where gm.grievance_generate_date >= '2023-06-08'
--and gm.applicant_caste is null 
and gm.applicant_gender = 3;            
                       
                      
                       
                       
                       
 select * from public.cmo_grievance_counts_gender(0,0); 
select * from public.cmo_atr_count_district_wise(0,0);       


select
	g2.total_count,
	g2.grievances_received_male,
	(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
	g2.grievances_received_female,
	(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_female_percentage,
	g2.grievances_received_other,
	(g2.grievances_received_other/g2.total_count::float)*100 as grievances_recieved_others_percentage,
	g2.grievances_received_no_gender,
	(g2.grievances_received_no_gender/g2.total_count::float)*100 asgrievances_received_no_gender_percentage
from
	(select
		SUM(g1.gender_wise_count) as total_count,
		MAX(CASE WHEN g1.applicant_gender = 1  THEN g1.gender_wise_count END) AS grievances_received_male,
		MAX(CASE WHEN g1.applicant_gender = 2  THEN g1.gender_wise_count END) AS grievances_received_female,
		MAX(CASE WHEN g1.applicant_gender = 3  THEN g1.gender_wise_count END) AS grievances_received_other,
		MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
	from (select
			count(1) as gender_wise_count,
			gm.applicant_gender,
			cdlm.domain_value as gender_name
		  from grievance_master gm
		  left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
		  where gm.grievance_generate_date >= '2023-06-08' /*and gm.grievance_source = ssm_id and 
			  (gm.assigned_to_position in 
				  (select apm.position_id from admin_position_master apm where apm.office_id = dept_id)
		       or 
		      gm.updated_by_position in 
		    	  (select apm.position_id from admin_position_master apm where apm.office_id = dept_id))*/
		  group by gm.applicant_gender,cdlm.domain_value) g1 ) g2;


select
    g2.total_count,
    g2.total_male_count,
    g2.total_female_count,
    g2.age_below_18,
    g2.age_18_30,
    g2.age_31_45,
	g2.age_46_60,
    g2.age_above_60,
	g2.age_below_18_male,
    g2.age_18_30_male,
    g2.age_31_45_male,
    g2.age_46_60_male,
    g2.age_above_60_male,
    g2.age_below_18_female,
    g2.age_18_30_female,
    g2.age_31_45_female,
    g2.age_46_60_female,
    g2.age_above_60_female,
    (g2.age_below_18 / g2.total_count::float) * 100 AS age_below_18_percentage,
    (g2.age_18_30 / g2.total_count::float) * 100 AS age_18_30_percentage,
	(g2.age_31_45 / g2.total_count::float) * 100 AS age_31_45_percentage,
	(g2.age_46_60 / g2.total_count::float) * 100 AS age_46_60_percentage,
	(g2.age_above_60 / g2.total_count::float) * 100 AS age_above_60_percentage,
	(g2.age_below_18_male / g2.total_male_count::float) * 100 AS age_below_18_male_percentage,
    (g2.age_18_30_male / g2.total_male_count::float) * 100 AS age_18_30_male_percentage,
	(g2.age_31_45_male / g2.total_male_count::float) * 100 AS age_31_45_male_percentage,
	(g2.age_46_60_male / g2.total_male_count::float) * 100 AS age_46_60_male_percentage,
	(g2.age_above_60_male / g2.total_male_count::float) * 100 AS age_above_60_male_percentage,
	(g2.age_below_18_female / g2.total_female_count::float) * 100 AS age_below_18_female_percentage,
    (g2.age_18_30_female / g2.total_female_count::float) * 100 AS age_18_30_female_percentage,
	(g2.age_31_45_female / g2.total_female_count::float) * 100 AS age_31_45_female_percentage,
	(g2.age_46_60_female / g2.total_female_count::float) * 100 AS age_46_60_female_percentage,
	(g2.age_above_60_female / g2.total_female_count::float) * 100 AS age_above_60_female_percentage
from (select
		count(1) as total_count,
		count(case when g1.applicant_gender = 1 THEN 1 end) as total_male_count,
		count(case when g1.applicant_gender = 2 THEN 1 end) as total_female_count,
		COUNT(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
		COUNT(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
		COUNT(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
		COUNT(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 and g1.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 and g1.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 and g1.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
		COUNT(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 and g1.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 and g1.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
		COUNT(CASE WHEN g1.applicant_age BETWEEN 0 AND 17 and g1.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 18 AND 30 and g1.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 31 AND 45 and g1.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
		COUNT(CASE WHEN g1.applicant_age BETWEEN 46 AND 60 and g1.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
	    COUNT(CASE WHEN g1.applicant_age BETWEEN 61 AND 120 and g1.applicant_gender = 2 THEN 1 END) AS age_above_60_female
	from	 
		(select
			gm.applicant_age,
			gm.applicant_gender,
			cdlm.domain_value as gender_name
		from grievance_master gm
		left join cmo_domain_lookup_master cdlm on cdlm.domain_code = gm.applicant_gender and cdlm.domain_type = 'gender'
		where gm.applicant_age is not null) g1 ) g2;
                       
                       
                       
                       
-- public.grievance_lifecycle_latest_3 source

CREATE OR REPLACE VIEW public.grievance_lifecycle_latest_3
AS WITH latest_3 AS (
         SELECT a.row_number,
            a.grievance_id,
            a.assigned_by_position
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS row_number,
                    gl.grievance_id,
                    gl.assigned_by_position
                   FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = 3) a
          WHERE a.row_number = 1
        ), assign_to_cmo_user_new AS (
         SELECT grievance_master.assigned_to_position,
            count(grievance_master.grievance_id) AS new_pending_count
           FROM grievance_master
          WHERE grievance_master.status = 2
          GROUP BY grievance_master.assigned_to_position
        ), assign_to_cmo_user_new_ssm AS (
         SELECT grievance_master.assigned_to_position,
            count(grievance_master.grievance_id) AS new_pending_count_ssm
           FROM grievance_master
          WHERE grievance_master.status = 2 AND grievance_master.grievance_source = 5
          GROUP BY grievance_master.assigned_to_position
        ), assign_to_cmo_user_atr AS (
         SELECT grievance_master.assigned_to_position,
            count(grievance_master.grievance_id) AS atr_pending_count
           FROM grievance_master
          WHERE grievance_master.status = 14
          GROUP BY grievance_master.assigned_to_position
        )
 SELECT apm.position_id,
    count(1) AS fwd_count,
    sum(
        CASE
            WHEN gm_ssm.grievance_source = 5 THEN 1
            ELSE 0
        END) AS ssm_count,
    COALESCE(cte1.new_pending_count, 0::bigint) AS new_grievances_pending,
    COALESCE(cte2.atr_pending_count, 0::bigint) AS pending,
    COALESCE(cte3.new_pending_count_ssm, 0::bigint) AS new_pending_count_ssm
   FROM admin_position_master apm
     JOIN admin_user_position_mapping aupm ON apm.position_id = aupm.position_id
     JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
     JOIN admin_user au ON aud.admin_user_id = au.admin_user_id
     LEFT JOIN latest_3 lat3 ON lat3.assigned_by_position = apm.position_id
     LEFT JOIN grievance_master gm_ssm ON gm_ssm.grievance_id = lat3.grievance_id
     LEFT JOIN assign_to_cmo_user_new cte1 ON cte1.assigned_to_position = apm.position_id
     LEFT JOIN assign_to_cmo_user_atr cte2 ON cte2.assigned_to_position = apm.position_id
     LEFT JOIN assign_to_cmo_user_new_ssm cte3 ON cte3.assigned_to_position = apm.position_id
  WHERE (apm.role_master_id = ANY (ARRAY[1::bigint, 2::bigint, 3::bigint, 9::bigint])) AND au.status <> 3
  GROUP BY apm.position_id, cte1.new_pending_count, cte2.atr_pending_count, cte3.new_pending_count_ssm;
  
 
 

 SELECT 
 	usename AS role_name,
	CASE
	 WHEN usesuper AND usecreatedb THEN
	   CAST('superuser, create database' AS pg_catalog.text)
	 WHEN usesuper THEN
	    CAST('superuser' AS pg_catalog.text)
	 WHEN usecreatedb THEN
	    CAST('create database' AS pg_catalog.text)
	 ELSE
	    CAST('' AS pg_catalog.text)
	END role_attributes
FROM pg_catalog.pg_user;





select com.office_name::text,
		   coalesce(table1.atr_received_count,0) as atr_received_count,
		   coalesce(table2.atr_pending_count,0) as atr_pending_count,
		   coalesce(table1.atr_received_count_percentage,0) as atr_received_count_percentage,
		   coalesce(table2.atr_pending_count_percentage,0) as atr_pending_count_percentage
	from cmo_office_master com
	left join (SELECT 
				    com.office_name::text,
					com.office_id,
				    COUNT(CASE WHEN gm2.status IN (14, 15) THEN gm2.grievance_id END) AS atr_received_count,
				    (COUNT(CASE WHEN gm2.status IN (14, 15) THEN gm2.grievance_id END)::float / NULLIF(COUNT(gm2.grievance_id), 0) * 100) AS atr_received_count_percentage
				    from cmo_office_master com
				LEFT JOIN grievance_master gm2 ON com.office_id = gm2.atr_submit_by_lastest_office_id AND (gm2.grievance_source = ssm_id OR ssm_id >= 0)
				where com.office_category = 2
				GROUP BY com.office_name, com.office_id
			  ) as table1 on com.office_id = table1.office_id
	left join (SELECT 
				    com.office_name::text,
					com.office_id,
				    COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				    (COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END)::float / NULLIF(COUNT(gm.grievance_id), 0) * 100) AS atr_pending_count_percentage
				FROM cmo_office_master com
				LEFT JOIN grievance_master gm ON com.office_id = gm.assigned_to_office_id AND (gm.grievance_source = ssm_id OR ssm_id >= 0)
				where com.office_category = 2
				GROUP BY com.office_name, com.office_id
			  ) as table2 on com.office_id = table2.office_id
	where office_category = 2
    ORDER by table2.atr_pending_count DESC;
   
   
   
   
   
   
   SELECT com.office_name::text,
           COALESCE(table1.atr_received_count, 0) AS atr_received_count,
           COALESCE(table2.atr_pending_count, 0) AS atr_pending_count,
           COALESCE(table1.atr_received_count_percentage, 0) AS atr_received_count_percentage,
           COALESCE(table2.atr_pending_count_percentage, 0) AS atr_pending_count_percentage
    FROM cmo_office_master com
    LEFT JOIN (
        SELECT 
            com.office_name::text,
            com.office_id,
            COUNT(CASE WHEN gm2.status IN (14, 15) THEN gm2.grievance_id END) AS atr_received_count,
            COUNT((CASE WHEN gm2.status IN (14, 15) THEN gm2.grievance_id END)* 100) / sum(COUNT(gm2.grievance_id)::float ) AS atr_received_count_percentage
			--((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER ())::double precision AS percentage
        FROM cmo_office_master com
        LEFT JOIN grievance_master gm2 ON com.office_id = gm2.atr_submit_by_lastest_office_id  AND (gm2.grievance_source = ssm_id OR ssm_id >= 0)
        WHERE com.office_category = 2
        GROUP BY com.office_name, com.office_id
    ) AS table1 ON com.office_id = table1.office_id
    LEFT JOIN (
        SELECT 
            com.office_name::text,
            com.office_id,
            COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
            (COUNT((CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END)* 100) / sum(COUNT(gm.grievance_id)::float ) AS atr_pending_count_percentage
        FROM cmo_office_master com
        LEFT JOIN grievance_master gm ON com.office_id = gm.assigned_to_office_id  AND (gm.grievance_source = ssm_id OR ssm_id >= 0)
        WHERE com.office_category = 2
        GROUP BY com.office_name, com.office_id
    ) AS table2 ON com.office_id = table2.office_id
    WHERE office_category = 2
    ORDER BY table2.atr_pending_count DESC;
 
 
   
   
   
   
   SELECT
                g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
				g2.age_below_18_male,
			    g2.age_18_30_male,
			    g2.age_31_45_male,
			    g2.age_46_60_male,
			    g2.age_above_60_male,
			    g2.age_below_18_female,
			    g2.age_18_30_female,
			    g2.age_31_45_female,
			    g2.age_46_60_female,
			    g2.age_above_60_female,
                (g2.age_below_18/g2.total_count::float)* 100 AS age_below_18_percentage,
                (g2.age_18_30 / g2.total_count::float)* 100 AS age_18_30_percentage,
				(g2.age_31_45 / g2.total_count::float)* 100 AS age_31_45_percentage,
				(g2.age_46_60 / g2.total_count::float)* 100 AS age_46_60_percentage,
				(g2.age_above_60 / g2.total_count::float)* 100 AS age_above_60_percentage,
				(g2.age_below_18_male / g2.total_count::float)* 100 AS age_below_18_male_percentage,
                (g2.age_18_30_male / g2.total_count::float)* 100 AS age_18_30_male_percentage,
				(g2.age_31_45_male / g2.total_count::float)* 100 AS age_31_45_male_percentage,
				(g2.age_46_60_male / g2.total_count::float)* 100 AS age_46_60_male_percentage,
				(g2.age_above_60_male / g2.total_count::float)* 100 AS age_above_60_male_percentage,
				(g2.age_below_18_female / g2.total_count::float)* 100 AS age_below_18_female_percentage,
                (g2.age_18_30_female / g2.total_count::float)* 100 AS age_18_30_female_percentage,
				(g2.age_31_45_female / g2.total_count::float)* 100 AS age_31_45_female_percentage,
				(g2.age_46_60_female / g2.total_count::float)* 100 AS age_46_60_female_percentage,
				(g2.age_above_60_female / g2.total_count::float)* 100 AS age_above_60_female_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
                FROM grievance_master gm
                WHERE gm.grievance_source = 5
                  AND (gm.assigned_to_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = 1)
                       OR gm.updated_by_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = 1)
                  )
            ) g2; --594442
            
            
            
            select * from (
                select com.office_name , Count(distinct gm.grievance_id) as per_hod_count 
                    FROM cmo_office_master com
                -- LEFT JOIN admin_position_master apm ON com.office_id = apm.office_id AND apm.office_category = 2
                -- LEFT JOIN grievance_master gm ON gm.assigned_to_position = apm.position_id AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17)
                LEFT JOIN grievance_master gm ON com.office_id = gm.assigned_to_office_id
                where com.office_category = 2 AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17)  
                group by com.office_name) q 
                     order by q.per_hod_count desc ;
                     
                    
                    
                    
                    select * from (
                    	select /*cgcm.grievance_cat_id AS grievance_category,*/ cgcm.grievance_category_desc,
                            COUNT(DISTINCT gm.grievance_id) AS category_grievance_count
                        from 
                            cmo_grievance_category_master cgcm 
                        LEFT JOIN 
                            grievance_master gm ON gm.grievance_category = cgcm.grievance_cat_id
                            AND gm.status IN (3,4,5,6,7,8,9,10,11,12,13,16,17) GROUP BY 
                        cgcm.grievance_cat_id, cgcm.grievance_category_desc) q
                     ORDER BY 															
                        q.category_grievance_count DESC ;
                        
                       
                       
                       
                       with generate_months as (
                        SELECT EXTRACT(YEAR from generate_series({month}, (now() - interval '1 months')::date, '1 month')) AS converted_year,
                            EXTRACT(MONTH from generate_series({month}, (now() - interval '1 months')::date, '1 month')) AS converted_month
                    ),grievance_receive as (
                        select months.converted_year, months.converted_month, count(gm.grievance_id) as gr_rec FROM generate_months months
                        left join grievance_master gm  on EXTRACT(YEAR from gm.grievance_generate_date) = months.converted_year and EXTRACT(MONTH from gm.grievance_generate_date) = months.converted_month 
                        where {filter_q} gm.status in (1,2) group by months.converted_year, months.converted_month
                    ),grievance_forwarded as (
                        select months.converted_year, months.converted_month, count(gm.grievance_id) as gr_fwd FROM generate_months months
                        left join grievance_master gm  on EXTRACT(YEAR from gm.grievance_generate_date) = months.converted_year and EXTRACT(MONTH from gm.grievance_generate_date) = months.converted_month
                        where {filter_q} gm.status in (3,4,5,6,7,8,9,10,11,12,13,16,17) group by months.converted_year,months.converted_month
                    ),atr_submitted as (
                        select months.converted_year, months.converted_month, count(gm.grievance_id) as atr_sub FROM generate_months months
                        left join grievance_master gm  on EXTRACT(YEAR from gm.grievance_generate_date) = months.converted_year and EXTRACT(MONTH from gm.grievance_generate_date) = months.converted_month
                        where {filter_q} gm.status in (14) group by months.converted_year,months.converted_month
                    ),grievance_disposed as (
                        select months.converted_year, months.converted_month, count(gm.grievance_id) as gr_disp FROM generate_months months
                        left join grievance_master gm  on EXTRACT(YEAR from gm.grievance_generate_date) = months.converted_year and EXTRACT(MONTH from gm.grievance_generate_date) = months.converted_month
                        where {filter_q} gm.status in (15) group by months.converted_year,months.converted_month
                    ), common_coalesce as (
                        select months.converted_year,months.converted_month, coalesce(gr.gr_rec, 0) as gr_rec, coalesce(gf.gr_fwd, 0) as gr_fwd, coalesce(asub.atr_sub, 0) as atr_sub, 
                            coalesce(gd.gr_disp, 0) as gr_disp
                        from generate_months months
                        left join grievance_receive gr on months.converted_year = gr.converted_year and months.converted_month = gr.converted_month
                        left join grievance_forwarded gf on months.converted_year = gf.converted_year and months.converted_month = gf.converted_month
                        left join atr_submitted asub on months.converted_year = asub.converted_year and months.converted_month = asub.converted_month
                        left join grievance_disposed gd on months.converted_year = gd.converted_year and months.converted_month = gd.converted_month
                    ) select converted_year, converted_month,
                            (gr_rec + gr_fwd + atr_sub + gr_disp) as grievance_recieved_count,
                            (gr_fwd + atr_sub + gr_disp) as grievance_forwarded_count,
                            (atr_sub + gr_disp) as atr_submited_count,
                            gr_disp as grievance_closed_count
                            from common_coalesce;
                            
                           
                           
                           
                           
                           
                           
                           
WITH generate_months AS (
    SELECT EXTRACT(YEAR FROM generate_series({month}, (now() - interval '1 months')::date, '1 month')) AS converted_year,
           EXTRACT(MONTH FROM generate_series({month}, (now() - interval '1 months')::date, '1 month')) AS converted_month
), filter_conditions AS (
    SELECT 
        CASE 
            WHEN dept_id > 0 AND ssm_id > 0 THEN 
                'gm.grievance_source = ' || ssm_id || ' AND (gm.assigned_to_position IN ' || 
                '(SELECT apm.position_id FROM admin_position_master apm WHERE apm.office_id = ' || dept_id || ') ' ||
                'OR gm.updated_by_position IN ' || 
                '(SELECT apm.position_id FROM admin_position_master apm WHERE apm.office_id = ' || dept_id || ')) AND '
            WHEN dept_id > 0 AND (ssm_id IS NULL OR ssm_id = 0 OR ssm_id = '') THEN 
                '(gm.assigned_to_position IN ' ||
                '(SELECT apm.position_id FROM admin_position_master apm WHERE apm.office_id = ' || dept_id || ') ' ||
                'OR gm.updated_by_position IN ' || 
                '(SELECT apm.position_id FROM admin_position_master apm WHERE apm.office_id = ' || dept_id || ')) AND '
            WHEN (dept_id IS NULL OR dept_id = 0 OR dept_id = '') AND ssm_id = 5 THEN 
                'gm.grievance_source = ' || ssm_id || ' AND '
            ELSE ''
        END AS filter_q
), grievance_receive AS (
    SELECT months.converted_year, months.converted_month, COUNT(gm.grievance_id) AS gr_rec 
    FROM generate_months months
    LEFT JOIN grievance_master gm 
           ON EXTRACT(YEAR FROM gm.grievance_generate_date) = months.converted_year 
          AND EXTRACT(MONTH FROM gm.grievance_generate_date) = months.converted_month 
    CROSS JOIN filter_conditions
    WHERE {filter_conditions.filter_q} gm.status IN (1, 2) 
    GROUP BY months.converted_year, months.converted_month
), grievance_forwarded AS (
    SELECT months.converted_year, months.converted_month, COUNT(gm.grievance_id) AS gr_fwd 
    FROM generate_months months
    LEFT JOIN grievance_master gm 
           ON EXTRACT(YEAR FROM gm.grievance_generate_date) = months.converted_year 
          AND EXTRACT(MONTH FROM gm.grievance_generate_date) = months.converted_month
    CROSS JOIN filter_conditions
    WHERE {filter_conditions.filter_q} gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) 
    GROUP BY months.converted_year, months.converted_month
), atr_submitted AS (
    SELECT months.converted_year, months.converted_month, COUNT(gm.grievance_id) AS atr_sub 
    FROM generate_months months
    LEFT JOIN grievance_master gm 
           ON EXTRACT(YEAR FROM gm.grievance_generate_date) = months.converted_year 
          AND EXTRACT(MONTH FROM gm.grievance_generate_date) = months.converted_month
    CROSS JOIN filter_conditions
    WHERE {filter_conditions.filter_q} gm.status IN (14) 
    GROUP BY months.converted_year, months.converted_month
), grievance_disposed AS (
    SELECT months.converted_year, months.converted_month, COUNT(gm.grievance_id) AS gr_disp 
    FROM generate_months months
    LEFT JOIN grievance_master gm 
           ON EXTRACT(YEAR FROM gm.grievance_generate_date) = months.converted_year 
          AND EXTRACT(MONTH FROM gm.grievance_generate_date) = months.converted_month
    CROSS JOIN filter_conditions
    WHERE {filter_conditions.filter_q} gm.status IN (15) 
    GROUP BY months.converted_year, months.converted_month
), common_coalesce AS (
    SELECT 
        months.converted_year,
        months.converted_month, 
        COALESCE(gr.gr_rec, 0) AS gr_rec, 
        COALESCE(gf.gr_fwd, 0) AS gr_fwd, 
        COALESCE(asub.atr_sub, 0) AS atr_sub, 
        COALESCE(gd.gr_disp, 0) AS gr_disp
    FROM generate_months months
    LEFT JOIN grievance_receive gr ON months.converted_year = gr.converted_year AND months.converted_month = gr.converted_month
    LEFT JOIN grievance_forwarded gf ON months.converted_year = gf.converted_year AND months.converted_month = gf.converted_month
    LEFT JOIN atr_submitted asub ON months.converted_year = asub.converted_year AND months.converted_month = asub.converted_month
    LEFT JOIN grievance_disposed gd ON months.converted_year = gd.converted_year AND months.converted_month = gd.converted_month
) 
SELECT 
    converted_year, 
    converted_month,
    (gr_rec + gr_fwd + atr_sub + gr_disp) AS grievance_recieved_count,
    (gr_fwd + atr_sub + gr_disp) AS grievance_forwarded_count,
    (atr_sub + gr_disp) AS atr_submited_count,
    gr_disp AS grievance_closed_count
FROM common_coalesce;



select aupm.position_id, aud.official_name, aurm.role_master_name
    from admin_user_position_mapping aupm 
    inner join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
    inner join admin_position_master apm on apm.position_id = aupm.position_id 
    inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id;
            
   
           select gm.assigned_to_position,  count(1)  as  new_griev_count 
            from grievance_master gm 
            where exists (
                select 1 
                from grievance_lifecycle gl where gm.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 53 and gl.grievance_status in (3,5)  
            )  /*and gm.status in  (3,4,5,7,8,9,10,12,16,17)*/  and  gm.assigned_to_office_id = 53  group by gm.assigned_to_position; 
            
           
           select gm.assigned_to_position,  count(1)  as  atr_recv_count 
            from grievance_master gm 
            where exists (
                select 1 
                from grievance_lifecycle gl where gm.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 53 and gl.grievance_status in (3,5)  
            )  and gm.status in  (11,13)  and  gm.assigned_to_office_id = 53  group by gm.assigned_to_position; 
           
           
           select gm.assigned_to_position,  count(1)  as  rtrn_atr_count 
            from grievance_master gm 
            where exists (
                select 1 
                from grievance_lifecycle gl where gm.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 53 and gl.grievance_status in (3,5)  
            )  and gm.status in  (6)  and  gm.assigned_to_office_id = 53  group by gm.assigned_to_position; 
            
           
           
   SELECT aupm.position_id, aud.official_name, aurm.role_master_name FROM admin_user_position_mapping aupm 
	   INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
	   INNER JOIN admin_position_master apm ON apm.position_id = aupm.position_id 
	   INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id WHERE aupm.position_id = 10175;


SELECT 
    aupm.position_id, 
    aud.official_name, 
    aurm.role_master_name, 
    grievance_data.new_griev_count
FROM 
    admin_user_position_mapping aupm
INNER JOIN 
    admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id
INNER JOIN 
    admin_position_master apm ON apm.position_id = aupm.position_id
INNER JOIN 
    admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id
INNER JOIN 
    (
        SELECT 
            gm.assigned_to_position,  
            COUNT(1) AS new_griev_count 
        FROM 
            grievance_master gm 
        WHERE 
            EXISTS (
                SELECT 1 
                FROM grievance_lifecycle gl 
                WHERE gm.grievance_id = gl.grievance_id 
                  AND gl.assigned_to_office_id = 53 
                  AND gl.grievance_status IN (3, 5)
            )  
            AND gm.status IN (3, 4, 5, 7, 8, 9, 10, 12, 16, 17)  
            AND gm.assigned_to_office_id = 53  
        GROUP BY 
            gm.assigned_to_position
    ) AS grievance_data ON aupm.position_id = grievance_data.assigned_to_position
WHERE 
    aupm.position_id = 10175;

   
INSERT INTO chart_position_master_bkp (chart_map_id, chart_id, role_id, status)
SELECT chart_map_id, chart_id, role_id, status
FROM chart_position_master
WHERE chart_map_id NOT IN (SELECT chart_map_id FROM chart_position_master_bkp);
 -- inserting data from one table to existing one table




select * from cmo_grievance_category_master cgcm where cgcm.status = 1;

select grievance_category_desc as grievance_category_name, count(1) as grievance_count
	from cmo_grievance_category_master cgcm 
	left join grievance_master gm on gm.grievance_category = cgcm.grievance_cat_id 
	where gm.status = 3
	group by grievance_category_name;



select  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    coalesce(table0.office_name,'N/A') as office_name,
    table1.office_id,
    coalesce(table1.grv_uploaded,0) as griev_upload,
    coalesce(table2.grv_frwd_assigned,0) as grv_fwd,
    coalesce(table3.atr_recvd,0) as atr_rcvd,
    coalesce(table5.total_closed,0) as totl_dspsd,
    coalesce(table5.bnft_prvd,0) as srv_prvd,
    coalesce(table5.action_taken,0) as action_taken,
    coalesce(table5.not_elgbl,0) as not_elgbl,
    coalesce(table9.atr_pndg, 0) as atr_pndg,
 	COALESCE(ROUND(CASE 
        WHEN (bnft_prvd + action_taken) = 0 THEN 0
            ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
            END,2),0) AS bnft_prcnt
        from
        (
         select distinct grievance_cat_id,grievance_category_desc, parent_office_id, com.office_name
        	from cmo_grievance_category_master cgcm
        	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
        	where cgcm.status = 1
        )table0
	  left outer join
	        (
	        select  cog.grievance_category_desc ,cog.office_name,cog.office_id,
	            cog.grievance_cat_id,count(1) as grv_uploaded
	            from cat_offc_grievances cog 
	            where 
	            grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP
	        group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id
	        )table1
			on table0.grievance_cat_id = table1.grievance_cat_id
	        -- griev frwded
	  left outer join (
	        select count(1) as grv_frwd_assigned, cog.grievance_cat_id  from cat_offc_grievances cog 
	        where grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
	        	and cog.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
	        group by cog.grievance_cat_id) table2
	        on table2.grievance_cat_id=table0.grievance_cat_id
	        -- total atr recieved
	  left outer join (
	        select count(1) as atr_recvd, cog.grievance_cat_id  from cat_offc_grievances cog 
	        where 
			grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP and
	        cog.status in (14,15)
	        group by cog.grievance_cat_id) table3
	        on table3.grievance_cat_id=table0.grievance_cat_id
	        -- total closed
	  left outer join (
	        select count(1) as total_closed, 
	        sum(case when cog.status = 15 and cog.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when cog.status = 15 and cog.closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
	        sum(case when cog.status = 15 and cog.closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl,
	        cog.grievance_cat_id  
	        from cat_offc_grievances cog 
	        where grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
	        and cog.status = 15
	        group by cog.grievance_cat_id) table5
	         on table5.grievance_cat_id=table0.grievance_cat_id
	        -- atr pending
	  left outer join (
	        select count(1) as atr_pndg, cog.grievance_cat_id  from cat_offc_grievances cog 
	        where grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
	        and cog.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)
	        group by cog.grievance_cat_id) table9
	        on table9.grievance_cat_id=table0.grievance_cat_id;
	        
	       
	       
	       
	       
	       
	    select  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            coalesce(table0.office_name,'N/A') as office_name,
            table1.office_id,
            coalesce(table1.grv_uploaded,0) as griev_upload,
            coalesce(table2.grv_frwd_assigned,0) as grv_fwd,
            coalesce(table3.atr_recvd,0) as atr_rcvd,
            coalesce(table5.total_closed,0) as totl_dspsd,
            coalesce(table5.bnft_prvd,0) as srv_prvd,
            coalesce(table5.action_taken,0) as action_taken,
            coalesce(table5.not_elgbl,0) as not_elgbl,
            coalesce(table9.atr_pndg, 0) as atr_pndg,
         	COALESCE(ROUND(CASE 
	            WHEN (bnft_prvd + action_taken) = 0 THEN 0
	            ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
	            END,2),0) AS bnft_prcnt
            from
        (
          select distinct grievance_cat_id,grievance_category_desc, parent_office_id, com.office_name
           	from cmo_grievance_category_master cgcm
            	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
            	where cgcm.status = 1
            )table0
   left outer join(
   	  select cog.grievance_category_desc ,cog.office_name,cog.office_id, cog.grievance_cat_id,count(1) as grv_uploaded
         from cat_offc_grievances cog 
            where grievance_generate_date between {from_date} and {to_date}
                {data_source}
                {scm_cat_q}
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id
            )table1
			on table0.grievance_cat_id = table1.grievance_cat_id
            -- griev frwded
   left outer join (
      select count(1) as grv_frwd_assigned, cog.grievance_cat_id  from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} and cog.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table2
            on table2.grievance_cat_id=table0.grievance_cat_id
            -- total atr recieved
   left outer join (
      select count(1) as atr_recvd, cog.grievance_cat_id  from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} and cog.status in (14,15)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table3
            on table3.grievance_cat_id=table0.grievance_cat_id
            -- total closed
   left outer join (
      select count(1) as total_closed, 
            sum(case when cog.status = 15 and cog.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when cog.status = 15 and cog.closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
	        sum(case when cog.status = 15 and cog.closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl,
            cog.grievance_cat_id  
            from cat_offc_grievances cog 
            where grievance_generate_date between {from_date} and {to_date} and cog.status = 15
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table5
            on table5.grievance_cat_id=table0.grievance_cat_id
            -- atr pending
   left outer join (
       select count(1) as atr_pndg, cog.grievance_cat_id  from cat_offc_grievances cog 
           where grievance_generate_date between {from_date} and {to_date} and cog.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table9
            on table9.grievance_cat_id=table0.grievance_cat_id;
            
           
           
       -- office category wise grievance count --                 
 select  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    coalesce(table0.office_name,'N/A') as office_name,
    table1.office_id,
    coalesce(table1.grv_rcvd,0) as grievances_received_from_cmo,
    coalesce(table2.grv_frwd_to_suboff,0) as grievances_forwarded_to_suboffice,
    coalesce(table3.grv_frwd_to_othr_hod,0) as grievances_forwarded_to_other_hod,
    coalesce(table2.grv_frwd_to_suboff, 0) + coalesce(table3.grv_frwd_to_othr_hod, 0) as total_grievance_forwarded		-- total_griv_frwd
    coalesce(table4.atr_rcvd_from_suboff,0) as atr_received_from_sub_office,
    coalesce(table5.atr_rcvd_from_othr_hods,0) as atr_received_from_other_hods,
    coalesce(table4.atr_rcvd_from_suboff,0) + coalesce(table5.atr_rcvd_from_othr_hods,0) as total_atr_received			-- total_atr_rcvd
    coalesce(table6.atr_rcvd_from_cmo,0) as atr_received_from_cmo
-- 	COALESCE(ROUND(CASE 
--            WHEN (bnft_prvd + action_taken) = 0 THEN 0
--            ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
--            END,2),0) AS bnft_prcnt
        from(     
  select 
      distinct cgcm.grievance_cat_id, 
      cgcm.grievance_category_desc, 
      cgcm.parent_office_id, 
      com.office_name
           	from cmo_grievance_category_master cgcm
            	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
            	where cgcm.status = 1
            )table0
      -- griv received from cmo --    
   left outer join(
   	select 
		cog.grievance_category_desc,
		cog.office_name,
		cog.office_id,
		cog.grievance_cat_id, 
		count(1) as grv_rcvd
	from cat_offc_grievances cog 
		where grievance_generate_date between {from_date} and {to_date} 
		and cog.status not in (1,2) 
		{office_str}
		{data_source} 
		{scm_cat_q}
	group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id) table1
			on table0.grievance_cat_id = table1.grievance_cat_id
	-- griev frwded to suboffice
   left outer join (
   	select 
      	count(1) as grv_frwd_to_suboff, 
      	cog.grievance_cat_id  
      from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status not in (1,2,3,4)
          {office_str}
          {data_source}
          {scm_cat_q}
    group by cog.grievance_cat_id) table2
            on table2.grievance_cat_id = table0.grievance_cat_id
     -- griev frwded to other hod
   left outer join (
   	select 
      	count(1) as grv_frwd_to_othr_hod, 
      	cog.grievance_cat_id  
      from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (5,6,13,14,15,16,17)
          {office_str}
          {data_source}
          {scm_cat_q}
    group by cog.grievance_cat_id) table3
            on table3.grievance_cat_id = table0.grievance_cat_id
     -- atr received from suboffice
   left outer join (
      select 
	      count(1) as atr_rcvd_from_suboff, 
	      cog.grievance_cat_id 
     from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (9,10,11,12,14,15)
         	{office_str}
            {data_source}
            {scm_cat_q}
        group by cog.grievance_cat_id) table4
            on table4.grievance_cat_id = table0.grievance_cat_id
     -- atr received from other hods
   left outer join (
      select 
	      count(1) as atr_rcvd_from_othr_hods, 
	      cog.grievance_cat_id 
     from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (13,14,15,16,17)
         	{office_str}
            {data_source}
            {scm_cat_q}
        group by cog.grievance_cat_id) table5
            on table5.grievance_cat_id = table0.grievance_cat_id
    -- atr sent to cmo
   left outer join (
	  select 
	      count(1) as atr_rcvd_from_cmo, 
	      cog.grievance_cat_id  
	  from cat_offc_grievances cog 
	     where grievance_generate_date between {from_date} and {to_date} 
	     and cog.status in (14,15)
	     	{office_str}
	        {data_source}
	        {scm_cat_q}
	     group by cog.grievance_cat_id) table6
	        on table6.grievance_cat_id = table0.grievance_cat_id;
   
 
			
			
			
			
			
			
			
			
			
			
			
			
			
			
-- view --		
			
SELECT gm.grievance_id,
    cm.grievance_cat_id,
    cm.grievance_category_desc,
    om.office_id,
    om.office_name,
    gm.closure_reason_id,
    gm.atr_recv_cmo_flag,
    gm.grievance_generate_date,
    gm.grievance_source,
    cm.benefit_scheme_type,
    gm.status,
    cm.status AS grievance_category_status
   FROM cmo_grievance_category_master cm
     LEFT JOIN grievance_master gm ON cm.grievance_cat_id = gm.grievance_category
     LEFT JOIN cmo_office_master om ON om.office_id = cm.parent_office_id
  WHERE cm.status = 1;
  
 
 
 select cog.grievance_category_desc ,cog.office_name, cog.office_id, cog.grievance_cat_id, count(1) as grv_rcvd
         from cat_offc_grievances cog 
         LEFT JOIN grievance_master gm ON cog.grievance_cat_id = gm.grievance_category
            where cog.grievance_generate_date between '2024-11-09' and '2023-11-09'
            and gm.status = 3
                and cog.grievance_source in (3,5)--{data_source}
--                and benefit_scheme_type = --{scm_cat_q}
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id;
            
           
           
select 
	cog.grievance_category_desc,
	cog.office_name,
	cog.office_id,
	cog.status,
	cog.grievance_cat_id, count(1) as grv_rcvd
from cat_offc_grievances cog 
where /*grievance_generate_date between {from_date} and {to_date} and */ cog.status in (7,8,9,10,12) and cog.grievance_source in (5,3)--{data_source}
                -- and benefit_scheme_type = --{scm_cat_q}
group by grievance_cat_id,grievance_category_desc,office_name,status,cog.office_id;
           
           

      select 
      	count(1) as grv_frwd_to_suboff, 
      	cog.grievance_cat_id  
      from cat_offc_grievances cog 
         where grievance_generate_date between {from_date} and {to_date} 
         and cog.status in (7,8,9,10,12)
            {data_source}
            {scm_cat_q}
            group by cog.grievance_cat_id) table2
            on table2.grievance_cat_id=table0.grievance_cat_id





 select * from cmo_domain_lookup_master cdlm where domain_type = 'grievance_source';
 




select  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            coalesce(table0.office_name,'N/A') as office_name,
            -- table1.office_id,
            coalesce(table1.grv_rcvd,0) as grievances_received_from_cmo,
            coalesce(table2.grv_frwd_to_suboff,0) as grievances_forwarded_to_suboffice,
            coalesce(table3.grv_frwd_to_othr_hod,0) as grievances_forwarded_to_other_hod,
            coalesce(table2.grv_frwd_to_suboff, 0) + coalesce(table3.grv_frwd_to_othr_hod, 0) as total_grievance_forwarded,		-- total_griv_frwd
            coalesce(table4.atr_rcvd_from_suboff,0) as atr_received_from_sub_office,
            coalesce(table5.atr_rcvd_from_othr_hods,0) as atr_received_from_other_hods,
            coalesce(table4.atr_rcvd_from_suboff,0) + coalesce(table5.atr_rcvd_from_othr_hods,0) as total_atr_received, 		-- total_atr_rcvd
            coalesce(table6.atr_rcvd_from_cmo,0) as atr_received_from_cmo
                from(
        select 
            distinct grievance_cat_id, 
            grievance_category_desc, 
            parent_office_id, 
            com.office_name
                    from cmo_grievance_category_master cgcm
                        left join cmo_office_master com on cgcm.parent_office_id = com.office_id
                        where cgcm.status = 1
                    )table0
            -- griv received from cmo --    
        left outer join(
            select 
                cog.grievance_category_desc,
                cog.office_name,
                cog.office_id,
                cog.grievance_cat_id, 
                count(1) as grv_rcvd
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status not in (1,2) 
                and cog.office_id in (7)   
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id) table1
                    on table0.grievance_cat_id = table1.grievance_cat_id
            -- griev frwded to suboffice
        left outer join (
            select 
                count(1) as grv_frwd_to_suboff, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status not in (1,2,3,4)
                and cog.office_id in (7)  
            group by cog.grievance_cat_id) table2
                    on table2.grievance_cat_id = table0.grievance_cat_id
            -- griev frwded to other hod
        left outer join (
            select 
                count(1) as grv_frwd_to_othr_hod, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (5,6,13,14,15,16,17)
                and cog.office_id in (7)    
            group by cog.grievance_cat_id) table3
                    on table3.grievance_cat_id = table0.grievance_cat_id
            -- atr received from suboffice
        left outer join (
            select 
                count(1) as atr_rcvd_from_suboff, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (9,10,11,12,14,15)
                    and cog.office_id in (7)  
                group by cog.grievance_cat_id) table4
                    on table4.grievance_cat_id = table0.grievance_cat_id
            -- atr received from other hods
        left outer join (
            select 
                count(1) as atr_rcvd_from_othr_hods, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (13,14,15,16,17)
                    and cog.office_id in (7)    
               group by cog.grievance_cat_id) table5
                    on table5.grievance_cat_id = table0.grievance_cat_id
            -- atr sent to cmo
        left outer join (
            select 
                count(1) as atr_rcvd_from_cmo, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (14,15)
                    and cog.office_id in (7)   
                group by cog.grievance_cat_id) table6
                    on table6.grievance_cat_id = table0.grievance_cat_id;
                    
                   
                   
select * from grievance_master gm;             
                   
                   select 
                count(1) as atr_rcvd_from_othr_hods, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where /*grievance_generate_date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
                and*/ cog.status in (13,14,15,16,17)
                    and cog.office_id in (7)
                 group by cog.grievance_cat_id;
                 
                select 
                count(1) as atr_rcvd_from_othr_hods, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between '2019-01-01' and '2024-11-11' 
                and cog.status in (13,14,15,16,17)
                    and cog.office_id in (7)    
               group by cog.grievance_cat_id;
               
              
              
              
 SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table0.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table1.grv_rcvd, 0) AS grievances_received_from_cmo,
    COALESCE(table2.grv_frwd_to_suboff, 0) AS grievances_forwarded_to_suboffice,
    COALESCE(table3.grv_frwd_to_othr_hod, 0) AS grievances_forwarded_to_other_hod,
    COALESCE(table2.grv_frwd_to_suboff, 0) + COALESCE(table3.grv_frwd_to_othr_hod, 0) AS total_grievance_forwarded,
    COALESCE(table4.atr_rcvd_from_suboff, 0) AS atr_received_from_sub_office,
    COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS atr_received_from_other_hods,
    COALESCE(table4.atr_rcvd_from_suboff, 0) + COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS total_atr_received,
    COALESCE(table6.atr_rcvd_from_cmo, 0) AS atr_received_from_cmo
FROM (
    SELECT 
        DISTINCT cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        com.office_id AS office_id,
        com.office_name
    FROM cmo_grievance_category_master cgcm
    LEFT JOIN cmo_office_master com ON cgcm.parent_office_id = com.office_id
    WHERE cgcm.status = 1
) table0
-- Grievances received from CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_rcvd
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status NOT IN (1, 2)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
-- Grievances forwarded to suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_frwd_to_suboff
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status NOT IN (1, 2, 3, 4)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
-- Grievances forwarded to other HOD
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS grv_frwd_to_othr_hod
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status IN (5, 6, 13, 14, 15, 16, 17)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
-- ATR received from suboffice
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_suboff
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status IN (9, 10, 11, 12, 14, 15)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
-- ATR received from other HODs
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_othr_hods
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11'  
    and cog.status IN (13, 14, 15, 16, 17)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
-- ATR sent to CMO
LEFT JOIN (
    SELECT 
        cog.grievance_cat_id,
        COUNT(1) AS atr_rcvd_from_cmo
    FROM cat_offc_grievances cog 
    where grievance_generate_date between '2019-01-01' and '2024-11-11' 
    and cog.status IN (14, 15)
    AND cog.grievance_source IN (5)
    GROUP BY cog.grievance_cat_id
) table6 ON table0.grievance_cat_id = table6.grievance_cat_id WHERE table0.office_id IN (7);


--- 14.11.24 -----

SELECT  
    COALESCE(table0.office_name, 'N/A') AS office_name,
    table0.office_id,
    COALESCE(table1.grv_frwd_assigned, 0) AS grv_fwd,
    COALESCE(table2.atr_rcvd, 0) AS atr_rcvd,
    COALESCE(table3.total_closed, 0) AS total,
    COALESCE(table3.bnft_prvd, 0) AS bnft_srv_prvd,
    COALESCE(table3.action_taken, 0) AS action_taken,
    COALESCE(table3.not_elgbl, 0) AS not_elgbl,
    COALESCE(table4.atr_pndg, 0) AS cumulative,
    COALESCE(table4.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(table5.atr_retrn_reviw_frm_cmo, 0) AS atr_retrn_reviw_frm_cmo
FROM (
    SELECT DISTINCT 
        com.office_id, 
        com.office_name
    FROM cmo_office_master com
) AS table0
-- Grievances forwarded
LEFT JOIN (
    SELECT 
        com.office_id,
        COUNT(DISTINCT owg.grievance_id) AS grv_frwd_assigned
    FROM offc_wise_grievance owg 
    JOIN cmo_office_master com ON com.office_id = owg.office_id
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'  
        AND owg.status NOT IN (1, 2)
        AND owg.grievance_source IN (5)
    GROUP BY com.office_id
) AS table1 ON table1.office_id = table0.office_id
-- Total ATR received
LEFT JOIN (
    SELECT 
        com.office_id,
        COUNT(DISTINCT owg.grievance_id) AS atr_rcvd
    FROM offc_wise_grievance owg 
    JOIN cmo_office_master com ON com.office_id = owg.office_id
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND owg.status IN (14, 15, 16, 17)
        AND owg.grievance_source IN (5)
    GROUP BY com.office_id
) AS table2 ON table2.office_id = table0.office_id
-- ATR closed
LEFT JOIN (
    SELECT 
        com.office_id,
        COUNT(DISTINCT owg.grievance_id) AS total_closed,
        SUM(CASE WHEN owg.status = 15 AND owg.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN owg.status = 15 AND owg.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN owg.status = 15 AND owg.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM offc_wise_grievance owg 
    JOIN cmo_office_master com ON com.office_id = owg.office_id
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND owg.status = 15
        AND owg.grievance_source IN (5)
    GROUP BY com.office_id
) AS table3 ON table3.office_id = table0.office_id
-- ATR pending
LEFT JOIN (
    SELECT 
        com.office_id,
        COUNT(DISTINCT owg.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - owg.updated_on >= INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM offc_wise_grievance owg 
    JOIN cmo_office_master com ON com.office_id = owg.office_id
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND owg.status NOT IN (1, 2, 14, 15, 16)
        AND owg.grievance_source IN (5)
    GROUP BY com.office_id
) AS table4 ON table4.office_id = table0.office_id
-- ATR returned for review from CMO
LEFT JOIN (
    SELECT 
        com.office_id,
        COUNT(*) AS atr_retrn_reviw_frm_cmo
    FROM offc_wise_grievance owg 
    JOIN cmo_office_master com ON com.office_id = owg.office_id
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND owg.status = 6
        AND owg.grievance_source IN (5)
    GROUP BY com.office_id
) AS table5 ON table5.office_id = table0.office_id;



-- DROP VIEW IF EXISTS public.cat_offc_grievances;
DROP VIEW IF EXISTS public.offc_wise_grievance;

CREATE OR REPLACE VIEW public.cat_offc_grievances
AS SELECT gm.grievance_id,
    cm.grievance_cat_id,
    cm.grievance_category_desc,
    om.office_id,
    om.office_name,
    gm.closure_reason_id,
    gm.atr_recv_cmo_flag,
    gm.grievance_generate_date,
    gm.received_at,
    gm.grievance_source,
    cm.benefit_scheme_type,
    gm.status,
    cm.status AS grievance_category_status
   FROM cmo_grievance_category_master cm
     LEFT JOIN grievance_master gm ON cm.grievance_cat_id = gm.grievance_category
     LEFT JOIN cmo_office_master om ON om.office_id = cm.parent_office_id
  WHERE cm.status = 1;
  
 
 CREATE OR REPLACE VIEW public.offc_wise_grievance AS 
SELECT 
    com.office_id,
    com.office_name,
    gm.grievance_id,
    gm.status,
    gm.grievance_category,
    gm.assigned_to_position,
    gm.grievance_generate_date,
    gm.updated_on,
    gm.received_at,
    gm.atr_recv_cmo_flag,
    gm.closure_reason_id,
    gm.grievance_source
FROM cmo_office_master com
LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id;




SELECT  
    table0.office_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table1.grv_frwd_assigned, 0) AS grv_fwd,
    COALESCE(table2.atr_rcvd, 0) AS atr_rcvd,
    COALESCE(table3.total_closed, 0) AS total,
    COALESCE(table3.bnft_prvd, 0) AS bnft_srv_prvd,
    COALESCE(table3.action_taken, 0) AS action_taken,
    COALESCE(table3.not_elgbl, 0) AS not_elgbl,
    COALESCE(table4.atr_pndg, 0) AS cumulative,
    COALESCE(table4.beyond_svn_days, 0) AS beyond_svn_days,
    COALESCE(table5.atr_retrn_reviw_frm_cmo, 0) AS atr_retrn_reviw_frm_cmo
FROM (
    SELECT 
    	DISTINCT com.office_id , com.office_name
    from cmo_office_master com
    left join admin_position_master apm on apm.office_id = com.office_id
    where com.office_category = 2 and com.status = 1
    group by com.office_id ,com.office_name
) AS table0
-- Grievances forwarded
LEFT JOIN (
    SELECT 
        gm.assigned_to_office_id as office_id
        COUNT(DISTINCT grievance_id) AS grv_frwd_assigned,
        max(grievance_generate_date) as grievance_generate_date,
    FROM grievance_master gm
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'  
        AND status NOT IN (1, 2)
        AND grievance_source IN (5)
    GROUP BY office_id
) AS table1 ON table1.office_id = table0.office_id
-- Total ATR received
LEFT JOIN (
    SELECT 
        office_id,
        COUNT(DISTINCT grievance_id) AS atr_rcvd
    FROM offc_wise_grievance
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND status IN (14, 15, 16, 17)
        AND grievance_source IN (5)
    GROUP BY office_id
) AS table2 ON table2.office_id = table0.office_id
-- ATR closed
LEFT JOIN (
    SELECT 
        office_id,
        COUNT(DISTINCT grievance_id) AS total_closed,
        SUM(CASE WHEN status = 15 AND closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN status = 15 AND closure_reason_id IN (5, 9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN status = 15 AND closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM offc_wise_grievance
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND status = 15
        AND grievance_source IN (5)
    GROUP BY office_id
) AS table3 ON table3.office_id = table0.office_id
-- ATR pending
LEFT JOIN (
    SELECT 
        office_id,
        COUNT(DISTINCT grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - updated_on >= INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM offc_wise_grievance
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND status NOT IN (1, 2, 14, 15, 16)
        AND grievance_source IN (5)
    GROUP BY office_id
) AS table4 ON table4.office_id = table0.office_id
-- ATR returned for review from CMO
LEFT JOIN (
    SELECT 
        office_id,
        COUNT(*) AS atr_retrn_reviw_frm_cmo
    FROM offc_wise_grievance
    WHERE 
        grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        AND status = 6
        AND grievance_source IN (5)
    GROUP BY office_id
) AS table5 ON table5.office_id = table0.office_id;


    
    select
            table1.office_id,
            table1.office_name,
            coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grv_frwd,
            coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recvd,
            coalesce(table5.total_disposed,0) as total_disposed,
            coalesce(table6.pending_with_hod,0) as pending_with_hod,
            coalesce(grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
            coalesce(grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
            coalesce(round(((table5.total_disposed::numeric /(coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0)))* 100),2),
            0) as qual_atr_recv ,
            coalesce(ROUND(CASE WHEN pending_with_hod = 0 THEN 0
            ELSE (grv_pendng_more_svn_d::numeric / (pending_with_hod)) * 100
            END,2),0) AS percent_bynd_svn_days,
            coalesce(extract(day from (atr_av_date + disposed_av_date)),0) as avg_no_days_to_submit_atr,
            coalesce(extract(day from (atr_av_date_six + disposed_av_date_six)),0) as avg_no_days_to_submit_atr_six,
            table1.office_type,
            case 
                when office_type = 1 then 8  
                when office_type = 2 then 1
                when office_type = 3 then 2
                when office_type = 4 then 3
                when office_type = 5 then 4
                when office_type = 6 then 5
                when office_type = 7 then 6
                when office_type = 8 then 7
            end as office_ord  
        from
        (
        ---------------------- OT START -------------------------
        -- select com.office_id ,com.office_name, apm.office_type from cmo_office_master com
        -- left join admin_position_master apm on apm.office_id = com.office_id
        -- where com.office_category = 2 and com.status = 1
        -- group by com.office_id ,com.office_name,apm.office_type
        ---------------------- OT END -------------------------
        select com.office_id ,com.office_name, apm.office_type from cmo_office_master com
        left join admin_position_master apm on apm.office_id = com.office_id
        where com.office_category = 2 and com.status = 1 
        group by com.office_id ,com.office_name,apm.office_type
        ) table1
        -- grv frwded
        left outer join(
            select
                count(distinct grievance_id) as grv_frwd,
                max(grievance_generate_date) as grievance_generate_date,
                gm.assigned_to_office_id as office_id
            from
                grievance_master gm
            where
                gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
            group by
                gm.assigned_to_office_id ) table2
        on
            table1.office_id = table2.office_id
        -- atr recvd
        left outer join(
            select
                count(distinct grievance_id) as atr_recvd ,
                avg(atr_recv_cmo_date - grievance_generate_date) as atr_av_date,
                max(grievance_generate_date) as grievance_generate_date,
                gm.assigned_by_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 14
            group by
                assigned_by_office_id) table3
        on
            table1.office_id = table3.office_id
        --  total disposed 	
        left outer join(
            select
                count(1) as total_disposed,
                avg(atr_recv_cmo_date - grievance_generate_date) as disposed_av_date,
                gm.atr_submit_by_lastest_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 15
            group by
                gm.atr_submit_by_lastest_office_id
        ) table5
        on
            table1.office_id = table5.office_id	
        -- grv pending with hod
        left outer join(
            select
                count(distinct grievance_id) as pending_with_hod ,
                sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as grv_pendng_more_svn_d,
                sum(case when  CURRENT_DATE - gm.updated_on <= interval '7 days' then 1 else 0 end) as grv_pendng_upto_svn_d,
                gm.assigned_to_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
            group by
                gm.assigned_to_office_id ) table6
        on
            table1.office_id = table6.office_id
        -- atr recvd / 6 
        left outer join(
            select        
                avg(atr_recv_cmo_date - grievance_generate_date) as atr_av_date_six,
                gm.assigned_by_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 14
            group by
                assigned_by_office_id) table7
        on
            table1.office_id = table7.office_id
        --  total disposed / 6
        left outer join(
            select
                avg(atr_recv_cmo_date - grievance_generate_date) as disposed_av_date_six,
                gm.atr_submit_by_lastest_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 15
            group by
                gm.atr_submit_by_lastest_office_id
        ) table8 on
            table1.office_id = table8.office_id	
        where coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) > 0;
        
       
       
 ----- update for new mis report cmo view ------       
select  
    table0.office_id,
    coalesce(table0.office_name,'N/A') as office_name,
    coalesce(table1.grv_frwd_assigned,0) as grievances_forwarded_assigned,
    coalesce(table2.atr_rcvd,0) as atr_received,
    coalesce(table3.total_closed,0) as total_disposed,
    coalesce(table3.bnft_prvd,0) as benefit_service_provided,
    coalesce(table3.action_taken,0) as action_taken,
    coalesce(table3.not_elgbl,0) as not_elgbl,
    coalesce(table4.atr_pndg, 0) as cumulative,
    coalesce(table4.beyond_svn_days, 0) as beyond_svn_days,
    coalesce(table5.atr_retrn_reviw_frm_cmo, 0) as atr_return_for_review_from_cmo
    from
	    (SELECT 
    		DISTINCT com.office_id , com.office_name
	    from cmo_office_master com
	    left join admin_position_master apm on apm.office_id = com.office_id
	    where com.office_category = 2 and com.status = 1
	    group by com.office_id, com.office_name
	) AS table0
  	-- griev frwded
    left outer join (
        select 
            count(distinct grievance_id) as grv_frwd_assigned, 
            gm.assigned_to_office_id as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'  
        and gm.status NOT IN (1,2)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table1 on table1.office_id = table0.office_id
 -- total atr recieved
    left outer join (
        select 
            count(distinct grievance_id) as atr_rcvd,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status in (14,15,16,17)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table2 on table2.office_id = table0.office_id   
    -- atr closed
    left outer join (
         select 
         	count(1) as total_closed, 
            sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
	        sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl,
            gm.atr_submit_by_lastest_office_id  as office_id 
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 15
        AND gm.grievance_source IN (5)
        group by gm.atr_submit_by_lastest_office_id) table3 on table3.office_id = table0.office_id      
   -- atr pending
   left outer join (
        select 
            count(distinct grievance_id) as atr_pndg, 
            sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as beyond_svn_days,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status not in (1,2,14,15,16)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table4 on table4.office_id = table0.office_id      
   -- atr returned for review from CMO during the time
   left outer join (
   		SELECT 
    		count(grievance_id) AS atr_retrn_reviw_frm_cmo,
    		gm.assigned_to_office_id  as office_id
	    from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 6
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table5 on table5.office_id = table0.office_id;
      
     
       
 ------- new mis view for hods ---------
 select  
    table0.office_id,
    coalesce(table0.office_name,'N/A') as office_name,
    coalesce(table1.grv_frwd_assigned,0) as grievances_forwarded_assigned,
    coalesce(table2.atr_rcvd,0) as atr_received,
    coalesce(table3.total_closed,0) as total_disposed,
    coalesce(table3.bnft_prvd,0) as benefit_service_provided,
    coalesce(table3.action_taken,0) as action_taken,
    coalesce(table3.not_elgbl,0) as not_elgbl,
    coalesce(table4.atr_pndg, 0) as cumulative,
    coalesce(table4.beyond_svn_days, 0) as beyond_svn_days,
    coalesce(table5.atr_retrn_reviw_frm_cmo, 0) as atr_return_for_review_from_cmo
    from
	    (SELECT 
    		DISTINCT com.office_id , com.office_name
	    from cmo_office_master com
	    left join admin_position_master apm on apm.office_id = com.office_id
	    where com.office_category = 2 and com.status = 1
	    group by com.office_id, com.office_name
	) AS table0
  	-- griev frwded
    left outer join (
        select 
            count(distinct grievance_id) as grv_frwd_assigned, 
            gm.assigned_to_office_id as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'  
        and gm.status NOT IN (1,2,3,13)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table1 on table1.office_id = table0.office_id
 -- total atr recieved
    left outer join (
        select 
            count(distinct grievance_id) as atr_rcvd,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status in (14,15,16,17)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table2 on table2.office_id = table0.office_id   
    -- atr closed
    left outer join (
         select 
         	count(1) as total_closed, 
            sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
	        sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl,
            gm.atr_submit_by_lastest_office_id  as office_id 
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 15
        AND gm.grievance_source IN (5)
        group by gm.atr_submit_by_lastest_office_id) table3 on table3.office_id = table0.office_id      
   -- atr pending
   left outer join (
        select 
            count(distinct grievance_id) as atr_pndg, 
            sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as beyond_svn_days,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status not in (1,2,14,15,16)
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table4 on table4.office_id = table0.office_id      
   -- atr returned for review from CMO during the time
   left outer join (
   		SELECT 
    		count(grievance_id) AS atr_retrn_reviw_frm_cmo,
    		gm.assigned_to_office_id  as office_id
	    from grievance_master gm 
        where grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 6
        AND gm.grievance_source IN (5)
        group by gm.assigned_to_office_id) table5 on table5.office_id = table0.office_id;
        
       
       
       
       WITH latest_receive_from_so_hod AS (
                    select a.assigned_to_position, count(a.grievance_id) as atr_submitted  from (SELECT grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_position,
                                                                                                grievance_lifecycle.assigned_to_office_id,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    where grievance_lifecycle.grievance_status in (11,13))a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3   group by a.assigned_to_position
                ), latest_receive_from_cmo AS (
                    select a.assigned_to_position, count(a.grievance_id) as new_grievances from (SELECT grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_position,
                                                                            grievance_lifecycle.assigned_to_office_id,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    where grievance_lifecycle.grievance_status in (3,5))a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3   group by a.assigned_to_position
                ),return_atr_from_cmo AS (
                    select a.assigned_to_position, count(a.grievance_id) as returned_atr_from_cmo  from (SELECT grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_position,
                                                                                                grievance_lifecycle.assigned_to_office_id,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    where grievance_lifecycle.grievance_status = 6)a 
                    inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
                    where rn = 1 and a.assigned_to_office_id = 3    group by a.assigned_to_position
                )
                select  aud.official_name ,coalesce(atr_submitted,0) as atr_submitted, coalesce(new_grievances, 0) as new_grievances,
                        coalesce(returned_atr_from_cmo, 0) as returned_atr_from_cmo
                from latest_receive_from_so_hod hod_so
                left join latest_receive_from_cmo lrfsh on  lrfsh.assigned_to_position = hod_so.assigned_to_position
                left join return_atr_from_cmo retcmo on  retcmo.assigned_to_position = hod_so.assigned_to_position
                left join admin_position_master apm on apm.position_id = hod_so.assigned_to_position
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
                left join admin_user_details aud on aupm.admin_user_id = aud.admin_user_id
                left join admin_user au on au.admin_user_id = aud.admin_user_id
                where au.status != 3
                group by aud.official_name, atr_submitted, new_grievances, returned_atr_from_cmo; 
                
               
               
               
------- mis view for hod ----------
WITH forwarded_and_assigned_grievances AS (
      select 
      	a.assigned_to_position, 
      	count(a.grievance_id) as grv_frwd_assigned  
      from 
      	(SELECT 
      		grievance_lifecycle.grievance_id, 
      		grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            row_number() OVER 
            	(PARTITION BY grievance_lifecycle.grievance_id 
            		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status not in (1,2,3,13)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3   
            group by a.assigned_to_position
        ), 
        latest_atr_received AS (
            select 
            	a.assigned_to_position, 
            	count(a.grievance_id) as atr_rcvd 
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
            		grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (11,14,15,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3   
            group by a.assigned_to_position
        ),
        disposal AS (
            select 
            	a.assigned_to_position, 
            	count(a.grievance_id) as total_closed,
            	sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            	sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
	        	sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
            		grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status = 15
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
        ),
        pending AS (
            select 
            	a.assigned_to_position, 
            	count(distinct a.grievance_id) as atr_pndg,
            sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as beyond_svn_days
            from 
            	(SELECT 
            		grievance_lifecycle.grievance_id, 
            		grievance_lifecycle.assigned_to_position,
                    grievance_lifecycle.assigned_to_office_id,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status not in (1,2,14,15,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
        )
        select  
        	aud.official_name, 
        	coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
        	coalesce(ltr.atr_rcvd, 0) as atr_received,
        	coalesce(d.bnft_prvd, 0) as benefit_service_provided,
        	coalesce(d.action_taken, 0) as action_taken,
        	coalesce(d.not_elgbl, 0) as not_elgbl,
            coalesce(d.total_closed, 0) as total_disposed,
            coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
            coalesce(p.atr_pndg, 0) as cumulative
        from forwarded_and_assigned_grievances fag
        left join latest_atr_received ltr on ltr.assigned_to_position = fag.assigned_to_position
        left join disposal d on d.assigned_to_position = fag.assigned_to_position
        left join pending p on p.assigned_to_position = fag.assigned_to_position
        left join admin_position_master apm on apm.position_id = fag.assigned_to_position
        left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
        left join admin_user_details aud on aupm.admin_user_id = aud.admin_user_id
        left join admin_user au on au.admin_user_id = aud.admin_user_id
        where au.status != 3
        group by aud.official_name, fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg; 
        
       
  WITH forwarded_and_assigned_grievances AS (       
		 select 
		 	a.assigned_to_position, 
      		count(a.grievance_id) as grv_frwd_assigned 
		 from 
		 	(SELECT 
		 		grievance_lifecycle.grievance_id, 
		 		grievance_lifecycle.assigned_to_office_id,
		        grievance_lifecycle.assigned_to_position,
		        	row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on desc) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3
            group by a.assigned_to_position
		),       
	latest_atr_received AS (
         select 
         	a.assigned_by_position, 
            count(a.grievance_id) as atr_rcvd  
         from 
         	(SELECT 
         		grievance_lifecycle.grievance_id, 
         		grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            FROM grievance_lifecycle
            where grievance_lifecycle.grievance_status in (1,4,5,11,14,16,17)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3 group by a.assigned_by_position
   		), 
  	disposal AS (
        select 
        	a.assigned_to_position, 
        	count(a.grievance_id) as total_closed,
        	sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        	sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
        	sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
       	from 
            (SELECT 
        		grievance_lifecycle.grievance_id, 
        		grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_to_office_id,
                row_number() OVER 
                    (PARTITION BY grievance_lifecycle.grievance_id 
                    	ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status = 15
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
         ),
  pending AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (
        SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER 
            (PARTITION BY glc.grievance_id 
                ORDER BY glc.assigned_on DESC) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE 
            glc.grievance_status = 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
    WHERE rn = 1 and a.assigned_to_office_id = 3    
    GROUP BY a.assigned_to_position
  )
  	select  
		csom.suboffice_name, 
		coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
		coalesce(ltr.atr_rcvd, 0) as atr_received,
		coalesce(d.bnft_prvd, 0) as benefit_service_provided,
		coalesce(d.action_taken, 0) as action_taken,
		coalesce(d.not_elgbl, 0) as not_elgbl,
	    coalesce(d.total_closed, 0) as total_disposed,
	    coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
	    coalesce(p.atr_pndg, 0) as cumulative   
 	from forwarded_and_assigned_grievances fag
    left join latest_atr_received ltr on ltr.assigned_by_position = fag.assigned_to_position
    left join disposal d on d.assigned_to_position = fag.assigned_to_position
    left join pending p on p.assigned_to_position = fag.assigned_to_position
    left join admin_position_master apm on apm.position_id = fag.assigned_to_position
    left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id
    group by csom.suboffice_name, fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg;
    
   
   
   
   
   WITH 
	forwarded_grievances AS (       
		 select 
		 	a.assigned_to_position, 
      		count(a.grievance_id) as grv_frwd
		 from 
		 	(SELECT 
		 		grievance_lifecycle.grievance_id, 
		 		grievance_lifecycle.assigned_to_office_id,
		        grievance_lifecycle.assigned_to_position,
		        	row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on desc) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3
            group by a.assigned_to_position
		),
  	atr_submitted AS (
        select 
        	a.assigned_to_position, 
        	count(a.grievance_id) as total_submitted,
        	sum(case when gm.status in (4,11,14,15,16) and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        	sum(case when gm.status in (4,11,14,15,16) and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
        	sum(case when gm.status in (4,11,14,15,16) and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
       	from 
            (SELECT 
        		grievance_lifecycle.grievance_id, 
        		grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_to_office_id,
                row_number() OVER 
                    (PARTITION BY grievance_lifecycle.grievance_id 
                    	ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,11,14,15,16)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
         ),
  atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (
        SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER 
            (PARTITION BY glc.grievance_id 
                ORDER BY glc.assigned_on DESC) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE 
            glc.grievance_status = 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            AND gm.grievance_source IN (5)) a
	    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
	    WHERE rn = 1 and a.assigned_to_office_id = 3    
	    GROUP BY a.assigned_to_position
  	),
 atr_returned_for_review AS (
                SELECT 
                    a.assigned_to_position, 
                    COUNT(a.grievance_id) AS atr_retrn_reviw
                FROM 
                    (
                    SELECT 
                        grievance_lifecycle.grievance_id,  
                        grievance_lifecycle.assigned_to_position,
                        grievance_lifecycle.assigned_to_office_id,
                        row_number() OVER 
                            (PARTITION BY grievance_lifecycle.grievance_id 
                                ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    from grievance_master gm, grievance_lifecycle
                    where grievance_lifecycle.grievance_status = 12
                    and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
                        AND gm.grievance_source IN (5)) a
                INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
                WHERE rn = 1 and a.assigned_to_office_id = 3   
                GROUP BY a.assigned_to_position
              )
	  	select  
			csom.suboffice_name, 
			coalesce(fag.grv_frwd,0) as grievances_forwarded_assigned, 
			coalesce(ats.bnft_prvd, 0) as benefit_service_provided,
			coalesce(ats.action_taken, 0) as action_taken,
			coalesce(ats.not_elgbl, 0) as not_elgbl,
		    coalesce(ats.total_submitted, 0) as total,
		    coalesce(atp.beyond_svn_days, 0) as beyond_svn_days,
		    coalesce(atp.atr_pndg, 0) as cumulative,
		    coalesce(ar.atr_retrn_reviw, 0) as atr_returned_for_review_to_hod   
	 	from forwarded_grievances fag
	    left join atr_submitted ats on ats.assigned_to_position = fag.assigned_to_position
	    left join atr_pending atp on atp.assigned_to_position = fag.assigned_to_position
	    left join atr_returned_for_review ar on ar.assigned_to_position = fag.assigned_to_position
	    left join admin_position_master apm on apm.position_id = fag.assigned_to_position
	    left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id
	    group by csom.suboffice_name, fag.grv_frwd, ats.bnft_prvd, ats.action_taken, ats.not_elgbl, ats.total_submitted, atp.beyond_svn_days, atp.atr_pndg, ar.atr_retrn_reviw;
	    
	   
	   
select csom.suboffice_name as office_name, count(gm.grievance_id) as per_hod_count 
                    from cmo_sub_office_master csom 
                    inner join admin_position_master apm on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id 
                    left join grievance_master gm on apm.position_id = gm.assigned_to_position and  gm.assigned_by_office_id = 3 and gm.status in (7,8,9,10,12) 
                    where apm.office_id = 3
                    group by 1;
                    
 select csom.suboffice_name, csom.suboffice_id, com.office_id, count(1)
from cmo_sub_office_master csom 
left join cmo_office_master com on com.office_id = csom.office_id
left join grievance_master gm on gm.assigned_to_office_id = com.office_id 
where com.office_id = 3
--AND gm.grievance_generate_date BETWEEN '2024-11-11' AND '2019-01-01'
--AND gm.grievance_source IN (3)
group by csom.suboffice_name, csom.suboffice_id, com.office_id;



WITH received_grievances AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS grv_rcvd  
	    FROM 
	        (
	        SELECT 
	            glc.grievance_id, 
	            glc.grievance_status, 
	            glc.assigned_to_office_id, 
	            glc.assigned_by_office_id, 
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_master gm
	        JOIN grievance_lifecycle glc ON gm.grievance_id = glc.grievance_id
	        WHERE 
	            (
	                (glc.assigned_to_office_id = 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status NOT IN (1, 2))
	                OR
	                (glc.assigned_to_office_id != 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status NOT IN (1, 2, 3, 14))
	            )
	            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--	            AND gm.grievance_source = 5
	        ) a 
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	),
	atr_submitted AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS total_submitted,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id = (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (14, 15, 16, 17) AND gm.closure_reason_id = 1 
	            THEN 1 
	            ELSE 0 
	        END) AS bnft_prvd,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id = (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (14, 15, 16, 17) AND gm.closure_reason_id IN (5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS action_taken,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id = (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (14, 15, 16, 17) AND gm.closure_reason_id NOT IN (1, 5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS not_elgbl,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id != (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (11, 14, 15, 16, 17) AND gm.closure_reason_id = 1 
	            THEN 1 
	            ELSE 0 
	        END) AS bnft_prvd_others,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id != (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (11, 14, 15, 16, 17) AND gm.closure_reason_id IN (5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS action_taken_others,
	        SUM(CASE 
	            WHEN a.assigned_to_office_id != (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office') 
	             AND gm.status IN (11, 14, 15, 16, 17) AND gm.closure_reason_id NOT IN (1, 5, 9) 
	            THEN 1 
	            ELSE 0 
	        END) AS not_elgbl_others
	    FROM 
	        (
	        SELECT 
	            glc.grievance_id, 
	            glc.grievance_status, 
	            glc.assigned_to_office_id, 
	            glc.assigned_by_office_id,
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_master gm
	        JOIN grievance_lifecycle glc ON gm.grievance_id = glc.grievance_id
	        WHERE 
	            (
	                (glc.assigned_to_office_id = 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status IN (14, 15, 16, 17))
	                OR
	                (glc.assigned_to_office_id != 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status IN (11, 14, 15, 16, 17))
	            )
	            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--	            AND gm.grievance_source = 5
	        ) a
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 
	      AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	),
	atr_pending AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
	        SUM(CASE 
	            WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' 
	            THEN 1 ELSE 0 
	        END) AS beyond_svn_days
	    FROM 
	        (
	        SELECT 
	            glc.grievance_id, 
	            glc.grievance_status,
	            glc.assigned_to_office_id,
	            glc.assigned_by_office_id,
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_lifecycle glc
	        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
	        WHERE 
	            (
	                (glc.assigned_to_office_id = 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status = 3
	                 AND NOT EXISTS (
	                    SELECT 1
	                    FROM grievance_lifecycle glc2
	                    WHERE glc2.grievance_id = glc.grievance_id
	                      AND glc2.grievance_status = 14
	                 ))
	                OR
	                (glc.assigned_to_office_id != 
	                    (SELECT office_id FROM cmo_office_master WHERE office_name = 'Chief Minister''s Office')
	                 AND glc.grievance_status = 5
	                 AND NOT EXISTS (
	                    SELECT 1
	                    FROM grievance_lifecycle glc2
	                    WHERE glc2.grievance_id = glc.grievance_id
	                      AND glc2.grievance_status = 13
	                 ))
	            )
	            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--	            AND gm.grievance_source = 5
	        ) a
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 
	      AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	),
	atr_returned_for_review AS (
	    SELECT 
	        a.assigned_to_office_id, 
	        COUNT(DISTINCT a.grievance_id) AS atr_retrn_reviw
	    FROM 
	        (
	        SELECT 
	            glc.assigned_by_office_id,
	            glc.grievance_id, 
	            glc.grievance_status,
	            glc.assigned_to_office_id,
	            ROW_NUMBER() OVER (
	                PARTITION BY glc.grievance_id 
	                ORDER BY glc.assigned_on DESC
	            ) AS rn
	        FROM grievance_lifecycle glc
	        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
	        WHERE glc.grievance_status = 6
	          AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
--	          AND gm.grievance_source = 5
	        ) a
	    JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
	    WHERE rn = 1 
	      AND a.assigned_by_office_id = 3
	    GROUP BY a.assigned_to_office_id
	)
	SELECT  
	    com.office_name AS office_name,
	    COALESCE(rg.grv_rcvd, 0) AS grievances_received, 
	    COALESCE(ats.bnft_prvd, 0) + COALESCE(ats.bnft_prvd_others, 0) AS benefit_service_provided,
	    COALESCE(ats.action_taken, 0) + COALESCE(ats.action_taken_others, 0) AS action_taken,
	    COALESCE(ats.not_elgbl, 0) + COALESCE(ats.not_elgbl_others, 0) AS not_elgbl,
	    COALESCE(ats.total_submitted, 0) AS total_submitted,
	    COALESCE(ap.beyond_svn_days, 0) AS beyond_svn_days,
	    COALESCE(ap.atr_pndg, 0) AS cumulative_pendency,
	    COALESCE(arfr.atr_retrn_reviw, 0) AS atr_return_for_review_from_cmo_other_hod
	FROM received_grievances rg
	LEFT JOIN atr_submitted ats ON ats.assigned_to_office_id = rg.assigned_to_office_id
	LEFT JOIN atr_pending ap ON ap.assigned_to_office_id = rg.assigned_to_office_id
	LEFT JOIN atr_returned_for_review arfr ON arfr.assigned_to_office_id = rg.assigned_to_office_id
	LEFT JOIN cmo_office_master com ON com.office_id = rg.assigned_to_office_id
	ORDER BY 
	    CASE 
	        WHEN com.office_name = 'Chief Minister''s Office' THEN 0
	        ELSE 1 
	    END, 
	    com.office_name;
	    
	   
 WITH assigned_grievances AS (
    SELECT 
        a.assigned_to_position,
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS grv_assigned  
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER 
                (PARTITION BY grievance_lifecycle.grievance_id 
                 ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
         FROM grievance_master gm
         JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
         WHERE grievance_lifecycle.grievance_status IN (4,8,9,10,11,12,14,15,16)
           AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        ) a 
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3  
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_submitted_to_hoso AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(DISTINCT a.grievance_id) AS total_submitted,
        SUM(CASE WHEN grievance_lifecycle.grievance_status IN (9,10,11,12,14,15) AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
        SUM(CASE WHEN grievance_lifecycle.grievance_status IN (9,10,11,12,14,15) AND gm.closure_reason_id IN (5,9) THEN 1 ELSE 0 END) AS action_taken,
        SUM(CASE WHEN grievance_lifecycle.grievance_status IN (9,10,11,12,14,15) AND gm.closure_reason_id NOT IN (1,5,9) THEN 1 ELSE 0 END) AS not_elgbl
    FROM 
        (SELECT 
            grievance_lifecycle.grievance_id, 
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_to_office_id,
            ROW_NUMBER() OVER 
                (PARTITION BY grievance_lifecycle.grievance_id 
                 ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
         FROM grievance_master gm
         JOIN grievance_lifecycle ON gm.grievance_id = grievance_lifecycle.grievance_id
         WHERE grievance_lifecycle.grievance_status IN (9,10,11,12,14,15)
           AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        ) a 
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id 
    WHERE rn = 1 AND a.assigned_to_office_id = 3   
    GROUP BY a.assigned_to_position, a.assigned_to_office_id
),
atr_pending AS (
    SELECT 
        a.assigned_to_position, 
        a.assigned_to_office_id,
        COUNT(a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER (PARTITION BY glc.grievance_id ORDER BY glc.assigned_on DESC) AS rn
         FROM 
            grievance_lifecycle glc
         JOIN 
            grievance_master gm ON gm.grievance_id = glc.grievance_id
         WHERE 
            glc.grievance_status = 8
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 9
            ) 
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
        ) a
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    WHERE 
        rn = 1 AND a.assigned_to_office_id = 3    
    GROUP BY 
        a.assigned_to_position, a.assigned_to_office_id
)
SELECT  
    aud.official_name AS office_name, 
    SUM(COALESCE(ag.grv_assigned, 0)) AS total_grievances_assigned,
    SUM(COALESCE(asth.bnft_prvd, 0)) AS total_benefit_service_provided,
    SUM(COALESCE(asth.action_taken, 0)) AS total_action_taken,
    SUM(COALESCE(asth.not_elgbl, 0)) AS total_not_eligible,
    SUM(COALESCE(asth.total_submitted, 0)) AS total_submitted,
    SUM(COALESCE(ap.beyond_svn_days, 0)) AS total_beyond_seven_days,
    SUM(COALESCE(ap.atr_pndg, 0)) AS total_cumulative_pendency
FROM 
    cmo_sub_office_master csom
LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id
LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = apm.office_id AND gm.assigned_to_office_id = csom.office_id
LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
LEFT JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id 
LEFT JOIN assigned_grievances ag ON gm.assigned_to_position = ag.assigned_to_position AND ag.assigned_to_office_id = apm.office_id 
LEFT JOIN atr_submitted_to_hoso asth ON asth.assigned_to_position = gm.assigned_to_position 
LEFT JOIN atr_pending ap ON ap.assigned_to_position = gm.assigned_to_position 
WHERE 
    au.status != 3
    AND apm.office_id = 3
    AND apm.sub_office_id = 4
GROUP BY 
    aud.official_name;
    
   
   
   WITH 
	no_grievaces_fwd AS (       
		 select 
		 	a.assigned_to_position, 
		 	count(a.grievance_id) as giev_fwd  
		 from 
		 	(SELECT 
		 		grievance_lifecycle.grievance_id, 
		 		grievance_lifecycle.assigned_by_office_id,
		        grievance_lifecycle.assigned_to_position,
		        	row_number() OVER 
		        		(PARTITION BY grievance_lifecycle.grievance_id 
		        			ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
		    FROM grievance_lifecycle
		    where grievance_lifecycle.grievance_status in (7,12)) a 
		    inner join grievance_master gm on gm.grievance_id = a.grievance_id 
		    where rn = 1 and a.assigned_by_office_id = 3 group by a.assigned_to_position
		),       
	no_grievaces_atr_rec AS (
         select 
         	a.assigned_by_position, 
         	count(a.grievance_id) as giev_atr_rec  
         from 
         	(SELECT 
         		grievance_lifecycle.grievance_id, 
         		grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            FROM grievance_lifecycle
            where grievance_lifecycle.grievance_status in (11)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3 group by a.assigned_by_position
   		), 
   no_grievaces_atr_pending AS (
        select 
        	assigned_to_position,
        	count(1) as atr_pending 
       	from grievance_master gm 
        where gm.status in (7,8,9,10,12) 
        and gm.assigned_by_office_id = 3  
        group by assigned_to_position), 
  pending_for as (
     select 
       	atr_assigned_to_position, 
       	avg(days_diff)::int as days_diff 
     from pending_for_sub_office_wise pfhw 
     inner join grievance_master gm  on gm.grievance_id = pfhw.grievance_id 
     where rcv_assigned_by_office_id = 3 and atr_assigned_to_office_id = 3
     group by atr_assigned_to_position
   )
  select 
  	csom.suboffice_name, 
  	coalesce(giev_fwd, 0) as grievance_forwarded, 
  	coalesce(giev_atr_rec, 0) as atr_received_count, 
  	coalesce(atr_pending,0) as atr_pending,
    coalesce(days_diff, 0) as average_resolution_days,
        CASE
            WHEN COALESCE(days_diff, 0) <= 7 THEN 'Good'
            WHEN COALESCE(days_diff, 0) > 7 AND COALESCE(days_diff, 0) <= 30 THEN 'Average'
            ELSE 'Poor'
        END AS performance
 	from no_grievaces_atr_rec ngarec
    left join no_grievaces_fwd ngfwd  on ngarec.assigned_by_position = ngfwd.assigned_to_position
    left join no_grievaces_atr_pending atrpnd on atrpnd.assigned_to_position = ngarec.assigned_by_position
    left join pending_for pndfor on pndfor.atr_assigned_to_position = ngarec.assigned_by_position
    left join admin_position_master apm on apm.position_id = ngarec.assigned_by_position
    left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and  csom.office_id = apm.office_id
    group by csom.suboffice_name, giev_fwd, giev_atr_rec,atr_pending, days_diff; 
    
 
   
   
   
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   ------------------------------------------------------------------
   
   
   
   
   SELECT  
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.office_id,
                table0.suboffice_id,
                table0.admin_user_id, 
                table0.office_name,
                COALESCE(table0.official_name, 'N/A') AS office_name,
                COALESCE(table0.suboffice_name, 'N/A') AS suboffice_name,
                COALESCE(table2.grv_frwd, 0) AS grievances_assigned,
                COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
                COALESCE(table2.action_taken, 0) AS action_taken,
                COALESCE(table2.not_elgbl, 0) AS not_elgbl,
                COALESCE(table2.total_submitted, 0) AS total_submitted,
                COALESCE(table3.beyond_svn_days, 0) AS beyond_svn_days,
                COALESCE(table3.atr_pndg, 0) AS cumulative_pendency
            FROM (
                SELECT 
                    DISTINCT aud.admin_user_id, 
                    aud.official_name,
                    cgcm.grievance_cat_id, 
                    cgcm.grievance_category_desc, 
                    com.office_id,
                    com.office_name,
                    csom.suboffice_name,
                    csom.suboffice_id 
                FROM cmo_grievance_category_master cgcm
                LEFT JOIN grievance_master gm ON gm.grievance_category = cgcm.grievance_cat_id
                LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id
                LEFT JOIN cmo_sub_office_master csom ON csom.office_id = com.office_id 
                left join admin_position_master apm on apm.sub_office_id = csom.suboffice_id and csom.office_id = apm.office_id
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
                left join admin_user au on au.admin_user_id = aud.admin_user_id
                WHERE cgcm.status = 1
                and (case 
                        when gm.status = 1 then gm.grievance_generate_date::date 
                        else gm.updated_on::date 
                    end) between '2019-01-01' AND '2024-11-11'
--                {data_source}
            ) table0
            -- Number of Grievances Received & Benefit/Service Provided & Action Initiated & Not Eligible for Benefit & Total Submitted & ATR Returned for Review
            LEFT JOIN (
                SELECT 
                    gm.grievance_category AS grievance_cat_id,
                    count(distinct case when gm.status IN (7,8,9,10,11,12,14,15,16,17) THEN gm.grievance_id END) AS grv_frwd,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id = 1 THEN gm.grievance_id END) AS bnft_prvd,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id IN (5,9) THEN gm.grievance_id END) AS action_taken,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id NOT IN (1,5,9) THEN gm.grievance_id END) AS not_elgbl,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) THEN gm.grievance_id END) AS total_submitted
                FROM grievance_master gm
                GROUP BY gm.grievance_category
            ) table2 
            ON table2.grievance_cat_id = table0.grievance_cat_id 
            -- ATR Pending
            LEFT JOIN (
                SELECT 
                    gm.grievance_category AS grievance_cat_id,
                    count(distinct gm.grievance_id) AS atr_pndg,
                    SUM(distinct CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
                FROM grievance_master gm
                left JOIN grievance_lifecycle glc ON glc.grievance_id = gm.grievance_id
                WHERE glc.grievance_status = 7 
                AND NOT EXISTS (
                    SELECT 1
                    FROM grievance_lifecycle glc2
                    WHERE glc2.grievance_id = glc.grievance_id
                        AND glc2.grievance_status = 11
                )
                GROUP BY gm.grievance_category 
            ) table3 
            ON table0.grievance_cat_id = table3.grievance_cat_id 
            WHERE table0.office_id = 3 
            AND table0.suboffice_id = 479 and table0.grievance_cat_id in (2);
            
   
--    drop view if exists public.cat_offc_grievances;
           
           
select lifecycle_id,grievance_status from grievance_lifecycle gl where gl.grievance_id = 1583626 order by lifecycle_id asc;
           
           
           
 select  atr_type, gl.atr_proposed_date, action_taken_note, gl.atn_id, 
    catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
    prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
    gl.assigned_on, gl.assigned_by_id, gl.assign_comment, 
    gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position, 
    gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
from grievance_lifecycle gl
left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id 
where gl.lifecycle_id  = 40994038;

 select  gl.lifecycle_id, atr_type, atr_proposed_date, action_taken_note, gl.atn_id, 
    catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
    prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
    gl.assigned_on, gl.assigned_by_id, gl.assign_comment, 
    gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position
from grievance_lifecycle gl
left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id 
left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id
where gl.lifecycle_id  = 29562;

select gl.lifecycle_id, gl.atr_proposed_date from grievance_lifecycle gl where gl.atn_id = 12 and gl.grievance_id = ;
select  * from grievance_master gm limit 1 ;
select * from grievance_lifecycle gl limit 1;
select * from grievance_lifecycle gl where gl.lifecycle_id = 40994038;
select * from grievance_lifecycle gl where gl.grievance_id = 3851124;    ---- tentetive 
select * from cmo_domain_lookup_master cdlm ;

select  atr_type, atr_proposed_date, action_taken_note, gl.atn_id, 
                        catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
                        prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
                        gl.assigned_on, gl.assigned_by_id, gl.assign_comment, 
                        gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position, 
                        gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
                    from grievance_lifecycle gl
                    left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
                    left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id 
--                    where gl.lifecycle_id  = 36843;
                    where gl.grievance_id = 2435;