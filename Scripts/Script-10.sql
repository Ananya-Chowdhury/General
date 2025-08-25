WITH lastupdates AS (
                                SELECT 
                                    grievance_lifecycle.grievance_id,
                                    grievance_lifecycle.grievance_status,
                                    grievance_lifecycle.assigned_to_office_id,
                                    row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                                FROM 
                                    grievance_lifecycle
                                WHERE 
                                    grievance_lifecycle.grievance_status = 3
                            )
                            SELECT 
                                cast(SUM(k.total_general_count) as INTEGER) as total_general_count,
                                cast(SUM(k.total_sc_count) as INTEGER) as total_sc_count,
                                cast(SUM(k.total_st_count) as INTEGER) as total_st_count,
                                cast(SUM(k.total_obc_a_count) as INTEGER) as total_obc_a_count,
                                cast(SUM(k.total_obc_b_count) as INTEGER) as total_obc_b_count,
                                cast(SUM(k.total_not_disclosed_count) as INTEGER) as total_not_disclosed_count,
                                cast(SUM(k.total_test_caste_count) as INTEGER) as total_test_caste_count,
                                cast(sum(k.total_general_count_percentage) as integer) AS total_general_count_percentage,
                                cast(sum(k.total_sc_count_percentage) as integer) AS total_sc_count_percentage,
                                cast(sum(k.total_st_count_percentage) as integer) AS total_st_count_percentage,
                                cast(sum(k.total_obc_a_count_percentage) as integer) AS total_obc_a_count_percentage,
                                cast(sum(k.total_obc_b_count_percentage) as integer) AS total_obc_b_count_percentage,
                                cast(sum(k.total_not_disclosed_count_percentage) as integer) AS total_not_disclosed_count_percentage,
                                cast(sum(k.total_test_caste_count_percentage) as integer) AS total_test_caste_count_percentage,
                                cast(SUM(k.grievances_received_hindu) as INTEGER) as grievances_received_hindu,
                                cast(SUM(k.grievances_received_muslim) as INTEGER) as grievances_received_muslim,
                                cast(SUM(k.grievances_received_christian) as INTEGER) as grievances_received_christian,
                                cast(SUM(k.grievances_received_buddhist) as INTEGER) as grievances_received_buddhist,
                                cast(SUM(k.grievances_received_sikh) as INTEGER) as grievances_received_sikh,
                                cast(SUM(k.grievances_received_jain) as INTEGER) as grievances_received_jain,
                                cast(SUM(k.grievances_received_other) as INTEGER) as grievances_received_other,
                                cast(sum(k.grievances_received_not_known) as integer) AS grievances_received_not_known,
                                cast(sum(k.grievances_received_test_religion) as integer) AS grievances_received_test_religion,
                                cast(sum(k.grievances_received_hindu_percentage) as integer) AS grievances_received_hindu_percentage,
                                cast(sum(k.grievances_received_muslim_percentage) as integer) AS grievances_received_muslim_percentage,
                                cast(sum(k.grievances_received_christian_percentage) as integer) AS grievances_received_christian_percentage,
                                cast(sum(k.grievances_received_buddhist_percentage) as integer) AS grievances_received_buddhist_percentage,
                                cast(sum(k.grievances_received_sikh_percentage) as integer) AS grievances_received_sikh_percentage,
                                cast(sum(k.grievances_received_jain_percentage) as integer) AS grievances_received_jain_percentage,
                                cast(sum(k.grievances_received_other_percentage) as integer) AS grievances_received_other_percentage,
                                cast(sum(k.grievances_received_not_known_percentage) as integer) AS grievances_received_not_known_percentage,
                                cast(sum(k.grievances_received_test_religion_percentage) as integer) AS grievances_received_test_religion_percentage
                            FROM (
                                SELECT
                                    COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_hindu,
                                    COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_muslim,
                                    COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_christian,
                                    COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_buddhist,
                                    COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_sikh,
                                    COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_jain,
                                    COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_other,
                                    COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_not_known,
                                    COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_test_religion,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_hindu_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_muslim_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_christian_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_buddhist_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_sikh_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_jain_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_other_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_not_known_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_test_religion_percentage,
                                    COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_general_count,
                                    COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_sc_count,
                                    COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_st_count,
                                    COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_a_count,
                                    COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_b_count,
                                    COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_not_disclosed_count,
                                    COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_test_caste_count,
                                    cast(COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_general_count_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_sc_count_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_st_count_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_a_count_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_b_count_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_not_disclosed_count_percentage,
                                    cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage,
                                    lu.assigned_to_office_id 
                                FROM 
                                    lastupdates lu
                                INNER JOIN 
                                    grievance_master gm ON gm.grievance_id = lu.grievance_id 
                                LEFT JOIN 
                                    cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
                                WHERE 
                                    lu.rn = 1 
                                    AND lu.assigned_to_office_id = 53
                                    AND gm.status IS NOT NULL  
                                    AND gm.grievance_source = 5
                                    AND (gm.status = 15 OR gm.assigned_to_office_id = 53) 
                                GROUP BY 
                                    lu.assigned_to_office_id
                            ) k;
                            
                           
SELECT 
    gm.district_id,
    cdm.district_name,
--    COUNT(gm.grievance_id) AS total_grievance_count,
--    COUNT(CASE WHEN gm.status = 15 THEN 1 END) AS closed_grievance_count,
    COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
FROM 
    grievance_master gm
join
	grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
LEFT JOIN 
    cmo_districts_master cdm ON cdm.district_id = gm.district_id
WHERE 
    gm.district_id IS NOT NULL
GROUP BY 
    gm.district_id, cdm.district_name
ORDER BY
    atr_recevied_count desc,
   atr_pending_count desc;