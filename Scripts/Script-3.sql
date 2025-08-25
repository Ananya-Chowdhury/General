 WITH lastupdates AS (
                        SELECT 
                            grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on AS max_assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_position,
                            grievance_lifecycle.assigned_to_position,
                            grievance_lifecycle.assigned_by_office_id,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM 
                            grievance_lifecycle
                        WHERE 
                            grievance_lifecycle.grievance_status = 3
                    )
                    SELECT 
                        SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
                        SUM(k.total_grievance) AS total_grievance_recieved_count,
                        SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
                        SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
                        SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
                        SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
                        SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
                        SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
                        SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
                        SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
                        SUM(k.total_closed) AS total_closed,
                        SUM(k.matter_taken_up) AS matter_taken_up,
                        SUM(k.benifit_service_provided) AS benifit_service_provided,
                        SUM(k.non_actionable) AS non_actionable,
                        cast(SUM(k.age_0_10) as INTEGER) as age_0_10,
                        cast(SUM(k.age_11_20) as INTEGER) as age_11_20,
                        cast(SUM(k.age_21_30) as INTEGER) as age_21_30,
                        cast(SUM(k.age_31_40) as INTEGER) as age_31_40,
                        cast(SUM(k.age_41_50) as INTEGER) as age_41_50,
                        cast(SUM(k.age_51_60) as INTEGER) as age_51_60,
                        cast(SUM(k.age_61_70) as INTEGER) as age_61_70,
                        cast(SUM(k.age_71_80) as INTEGER) as age_71_80,
                        cast(SUM(k.age_81_90) as INTEGER) as age_81_90,
                        cast(SUM(k.age_91_100) as INTEGER) as age_91_100,
                        cast(SUM(k.age_101_120) as INTEGER) as age_101_120
                    FROM (
                        SELECT  
                            SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
                            COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
                            COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
                            COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
                            COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
                            COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
                            COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
                            COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
                            COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
                            COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
                            COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
                            COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
                            COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
                            COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
                            COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
                            COUNT(1) AS total_grievance,
                            COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
                            cast(SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) as INTEGER) AS atr_pending_at_cmo,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120,
                            lu.assigned_to_office_id
                        FROM 
                            lastupdates lu
                        INNER JOIN 
                            grievance_master gm ON gm.grievance_id = lu.grievance_id 
                        LEFT JOIN 
                            cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
                        WHERE 
                            lu.rn = 1 
                            AND lu.assigned_to_office_id =  80
                            AND gm.status IS NOT NULL 
                            AND gm.grievance_source = 5
                            AND (gm.status = 15 OR gm.assigned_to_office_id = 80) 
                        GROUP BY 
                            lu.assigned_to_office_id) k;

WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable,
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
        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
        COUNT(1) AS total_grievance,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        COUNT(CASE WHEN gm.applicant_caste = 1 THEN 1 END) AS total_general_count,
        COUNT(CASE WHEN gm.applicant_caste = 2 THEN 1 END) AS total_sc_count,
        COUNT(CASE WHEN gm.applicant_caste = 3 THEN 1 END) AS total_st_count,
        COUNT(CASE WHEN gm.applicant_caste = 4 THEN 1 END) AS total_obc_a_count,
        COUNT(CASE WHEN gm.applicant_caste = 5 THEN 1 END) AS total_obc_b_count,
        COUNT(CASE WHEN gm.applicant_caste = 6 THEN 1 END) AS total_not_disclosed_count,
        COUNT(CASE WHEN gm.applicant_caste = 7 THEN 1 END) AS total_test_caste_count,
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
        AND lu.assigned_to_office_id = {office_id}
        AND gm.status IS NOT NULL  
        AND gm.grievance_source = 0
        AND (gm.status = 15 OR gm.assigned_to_office_id = {office_id}) 
    GROUP BY 
        lu.assigned_to_office_id
) k;
                           
                           
                           
 WITH lastupdates AS (
                        SELECT 
                            grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on AS max_assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_position,
                            grievance_lifecycle.assigned_to_position,
                            grievance_lifecycle.assigned_by_office_id,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM 
                            grievance_lifecycle
                        WHERE 
                            grievance_lifecycle.grievance_status = 3
                    )
                    SELECT 
                        SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
                        SUM(k.total_grievance) AS total_grievance_recieved_count,
                        SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
                        SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
                        SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
                        SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
                        SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
                        SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
                        SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
                        SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
                        SUM(k.total_closed) AS total_closed,
                        SUM(k.matter_taken_up) AS matter_taken_up,
                        SUM(k.benifit_service_provided) AS benifit_service_provided,
                        SUM(k.non_actionable) AS non_actionable,
                        cast(SUM(k.age_0_10) as INTEGER) as age_0_10,
                        cast(SUM(k.age_11_20) as INTEGER) as age_11_20,
                        cast(SUM(k.age_21_30) as INTEGER) as age_21_30,
                        cast(SUM(k.age_31_40) as INTEGER) as age_31_40,
                        cast(SUM(k.age_41_50) as INTEGER) as age_41_50,
                        cast(SUM(k.age_51_60) as INTEGER) as age_51_60,
                        cast(SUM(k.age_61_70) as INTEGER) as age_61_70,
                        cast(SUM(k.age_71_80) as INTEGER) as age_71_80,
                        cast(SUM(k.age_81_90) as INTEGER) as age_81_90,
                        cast(SUM(k.age_91_100) as INTEGER) as age_91_100,
                        cast(SUM(k.age_101_120) as INTEGER) as age_101_120
                    FROM (
                        SELECT  
                            SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
                            COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
                            COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
                            COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
                            COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
                            COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
                            COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
                            COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
                            COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
                            COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
                            COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
                            COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
                            COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
                            COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
                            COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
                            COUNT(1) AS total_grievance,
                            COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
                            cast(SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) as INTEGER) AS atr_pending_at_cmo,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120,
                            lu.assigned_to_office_id
                        FROM 
                            lastupdates lu
                        INNER JOIN 
                            grievance_master gm ON gm.grievance_id = lu.grievance_id 
                        LEFT JOIN 
                            cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
                        WHERE 
                            lu.rn = 1 
                            AND lu.assigned_to_office_id =  84
                            AND gm.status IS NOT NULL 
                            AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
                        GROUP BY 
                            lu.assigned_to_office_id) k;
                           
filter_q = ""
            if ssm_id not in (None, "",0):
                filter_q += f" and gm.grievance_source = {ssm_id} "
            query =f"""WITH lastupdates AS (
                SELECT 
			    grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on AS max_assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_position,
                            grievance_lifecycle.assigned_to_position,
                            grievance_lifecycle.assigned_by_office_id,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM 
                            grievance_lifecycle
                        WHERE 
                            grievance_lifecycle.grievance_status = 3
                    )
                    SELECT 
			SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
                        SUM(k.total_grievance) AS total_grievance_recieved_count,
                        SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
                        SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
                        SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
                        SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
                        SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
                        SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
                        SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
                        SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
                        SUM(k.total_closed) AS total_closed,
                        SUM(k.matter_taken_up) AS matter_taken_up,
                        SUM(k.benifit_service_provided) AS benifit_service_provided,
                        SUM(k.non_actionable) AS non_actionable,
                        -- SUM(k.age_0_10) AS age_0_10,
                        -- SUM(k.age_11_20) AS age_11_20,
                        -- SUM(k.age_21_30) AS age_21_30,
                        -- SUM(k.age_31_40) AS age_31_40,
                        -- SUM(k.age_41_50) AS age_41_50,
                        -- SUM(k.age_51_60) AS age_51_60,
                        -- SUM(k.age_61_70) AS age_61_70,
                        -- SUM(k.age_71_80) AS age_71_80,
                        -- SUM(k.age_81_90) AS age_81_90,
                        -- SUM(k.age_91_100) AS age_91_100,
                        -- SUM(k.age_101_120) AS age_101_120

                        cast(SUM(k.age_0_10) as INTEGER) as age_0_10,
                        cast(SUM(k.age_11_20) as INTEGER) as age_11_20,
                        cast(SUM(k.age_21_30) as INTEGER) as age_21_30,
                        cast(SUM(k.age_31_40) as INTEGER) as age_31_40,
                        cast(SUM(k.age_41_50) as INTEGER) as age_41_50,
                        cast(SUM(k.age_51_60) as INTEGER) as age_51_60,
                        cast(SUM(k.age_61_70) as INTEGER) as age_61_70,
                        cast(SUM(k.age_71_80) as INTEGER) as age_71_80,
                        cast(SUM(k.age_81_90) as INTEGER) as age_81_90,
                        cast(SUM(k.age_91_100) as INTEGER) as age_91_100,
                        cast(SUM(k.age_101_120) as INTEGER) as age_101_120


		    FROM (
                        SELECT 
			    COUNT(case when gm.status = 3 then gm.grievance_id END) as recieved_from_cmo,
                            COUNT(case when gm.status = 4 then gm.grievance_id ELSE NULL END) as assigned_to_hod,
                            COUNT(case when gm.status = 5 then gm.grievance_id ELSE NULL END) as recieved_from_other_hod,
                            COUNT(case when gm.status = 6 then gm.grievance_id ELSE NULL END) as atr_returend_to_hod_for_review,
			    COUNT(case when gm.status = 7 then gm.grievance_id ELSE NULL END) as forwarded_to_hoso,
                            COUNT(case when gm.status = 8 then gm.grievance_id ELSE NULL END) as assign_to_so,
                            COUNT(case when gm.status = 9 then gm.grievance_id ELSE NULL END) as atr_submitted_to_hoso,
                            COUNT(case when gm.status = 10 then gm.grievance_id ELSE NULL END) as atr_returned_so_for_review,
                            COUNT(case when gm.status = 11 then gm.grievance_id ELSE NULL END) as atr_submitted_to_hod,
                            COUNT(case when gm.status = 12 then gm.grievance_id ELSE NULL END) as atr_returned_to_hoso_for_review,
			    COUNT(case when gm.status = 13 then gm.grievance_id ELSE NULL END) as atr_submitted_to_other_hod,
                            COUNT(case when gm.status = 14 then gm.grievance_id ELSE NULL END) as atr_submitted_to_cmo,
                            COUNT(case when gm.status = 16 then gm.grievance_id ELSE NULL ENDnd) as recall,
                            COUNT(case when gm.status = 17 then gm.grievance_id ELSE NULL END) as return,
                            COUNT(case when gm.status = 15 then gm.grievance_id ELSE NULL END ) as total_closed,
			    COUNT(1) AS total_grievance,
                            COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
                            SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
			    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120,
                            lu.assigned_to_office_id
                        FROM 
                            lastupdates lu
                        INNER JOIN 
                            grievance_master gm ON gm.grievance_id = lu.grievance_id 
                        LEFT JOIN 
                            cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
                        WHERE 
                            lu.rn = 1 
                            AND lu.assigned_to_office_id =  {office_id}
                            AND gm.status IS NOT NULL 
                            AND gm.grievance_source = 5
                            AND (gm.status = 15 OR gm.assigned_to_office_id = {office_id}) 
                         """
                 if filter_q != "":
                     query += filter_q 
                 query += f
                     GROUP BY 
                 lu.assigned_to_office_id)k;

Select 
                        SUM(k.recieved_from_hod+k.total_closed+k.atr_submited_hod) ::bigint as total_grievances,
                        SUM(k.recieved_from_hod) ::bigint AS recieved_from_hod,
                        SUM(k.assign_to_so)::bigint AS assign_to_so,
                        SUM(k.atr_submited_to_hoso)::bigint AS atr_submited_to_hoso,
                        SUM(k.atr_submited_other_hod) ::bigint AS atr_submited_other_hod,
                        SUM(k.atr_submited_hod + k.atr_submited_other_hod)::bigint AS total_atr_submited_count,
                        SUM(k.atr_submited_hod)::bigint AS atr_submited_hod,
                        SUM(k.total_closed)::bigint AS total_closed,
	SUM(k.recieved_from_hod+k.assign_to_so+k.atr_submited_to_hoso+k.atr_submited_to_hoso_review) ::bigint AS total_atr_pending_count,
			SUM(k.matter_taken_up)::bigint AS matter_taken_up,
                        SUM(k.benifit_service_provided )::bigint AS benifit_service_provided,
                        SUM(k.non_actionable )::bigint AS non_actionable,
			cast(SUM(k.age_0_10) as INTEGER) as age_0_10,
                        cast(SUM(k.age_11_20) as INTEGER) as age_11_20,
                        cast(SUM(k.age_21_30) as INTEGER) as age_21_30,
                        cast(SUM(k.age_31_40) as INTEGER) as age_31_40,
                        cast(SUM(k.age_41_50) as INTEGER) as age_41_50,
                        cast(SUM(k.age_51_60) as INTEGER) as age_51_60,
                        cast(SUM(k.age_61_70) as INTEGER) as age_61_70,
                        cast(SUM(k.age_71_80) as INTEGER) as age_71_80,
                        cast(SUM(k.age_81_90) as INTEGER) as age_81_90,
                        cast(SUM(k.age_91_100) as INTEGER) as age_91_100,
                        cast(SUM(k.age_101_120) as INTEGER) as age_101_120
		FROM (
              SELECT 
				SUM(recieved_from_hod) AS recieved_from_hod,
        			SUM(assign_to_so) as assign_to_so,
        			SUM(atr_submited_to_hoso_review) as atr_submited_to_hoso_review, 
        			SUM(atr_submited_to_hoso) as atr_submited_to_hoso,
        			SUM(atr_submited_other_hod) as atr_submited_other_hod,
        			SUM(atr_submited_hod) as atr_submited_hod,
        			SUM(total_closed) as total_closed,
        			SUM(matter_taken_up) as matter_taken_up,
        			SUM(benifit_service_provided) as benifit_service_provided,
        			SUM(non_actionable) as non_actionable,
				COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
                            SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
                            -- cast(SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) as INTEGER) AS atr_pending_at_cmo,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
                            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120,
		from 
			hoso_counts_all_office_received 
		where 
			sub_office_id =  and grievance_source = 5 
        group by sub_office_id)k;

 
Select 
    SUM(k.recieved_from_hod + k.total_closed + k.atr_submited_hod) ::bigint as total_grievances,
    SUM(k.recieved_from_hod) ::bigint AS recieved_from_hod,
    SUM(k.assign_to_so)::bigint AS assign_to_so,
    SUM(k.atr_submited_to_hoso)::bigint AS atr_submited_to_hoso,
    SUM(k.atr_submited_other_hod) ::bigint AS atr_submited_other_hod,
    SUM(k.atr_submited_hod + k.atr_submited_other_hod)::bigint AS total_atr_submited_count,
    SUM(k.atr_submited_hod)::bigint AS atr_submited_hod,
    SUM(k.total_closed)::bigint AS total_closed,
    SUM(k.recieved_from_hod + k.assign_to_so + k.atr_submited_to_hoso + k.atr_submited_to_hoso_review) ::bigint AS total_atr_pending_count,
    SUM(k.matter_taken_up)::bigint AS matter_taken_up,
    SUM(k.benifit_service_provided)::bigint AS benifit_service_provided,
    SUM(k.non_actionable)::bigint AS non_actionable,
    cast(SUM(k.age_0_10) as INTEGER) as age_0_10,
    cast(SUM(k.age_11_20) as INTEGER) as age_11_20,
    cast(SUM(k.age_21_30) as INTEGER) as age_21_30,
    cast(SUM(k.age_31_40) as INTEGER) as age_31_40,
    cast(SUM(k.age_41_50) as INTEGER) as age_41_50,
    cast(SUM(k.age_51_60) as INTEGER) as age_51_60,
    cast(SUM(k.age_61_70) as INTEGER) as age_61_70,
    cast(SUM(k.age_71_80) as INTEGER) as age_71_80,
    cast(SUM(k.age_81_90) as INTEGER) as age_81_90,
    cast(SUM(k.age_91_100) as INTEGER) as age_91_100,
    cast(SUM(k.age_101_120) as INTEGER) as age_101_120
FROM (
    SELECT 
        SUM(recieved_from_hod) AS recieved_from_hod,
        SUM(assign_to_so) as assign_to_so,
        SUM(atr_submited_to_hoso_review) as atr_submited_to_hoso_review, 
        SUM(atr_submited_to_hoso) as atr_submited_to_hoso,
        SUM(atr_submited_other_hod) as atr_submited_other_hod,
        SUM(atr_submited_hod) as atr_submited_hod,
        SUM(total_closed) as total_closed,
        SUM(matter_taken_up) as matter_taken_up,
        SUM(benifit_service_provided) as benifit_service_provided,
        SUM(non_actionable) as non_actionable,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120
    FROM 
        hoso_counts_all_office_received 
    WHERE 
        sub_office_id = 32 AND grievance_source = 5 
    GROUP BY sub_office_id
) k;


SELECT 
    SUM(k.recieved_from_hod + k.total_closed + k.atr_submited_hod) ::bigint as total_grievances,
    SUM(k.recieved_from_hod) ::bigint AS recieved_from_hod,
    SUM(k.assign_to_so)::bigint AS assign_to_so,
    SUM(k.atr_submited_to_hoso)::bigint AS atr_submited_to_hoso,
    SUM(k.atr_submited_other_hod) ::bigint AS atr_submited_other_hod,
    SUM(k.atr_submited_hod + k.atr_submited_other_hod)::bigint AS total_atr_submited_count,
    SUM(k.atr_submited_hod)::bigint AS atr_submited_hod,
    SUM(k.total_closed)::bigint AS total_closed,
    SUM(k.recieved_from_hod + k.assign_to_so + k.atr_submited_to_hoso + k.atr_submited_to_hoso_review) ::bigint AS total_atr_pending_count,
    SUM(k.matter_taken_up)::bigint AS matter_taken_up,
    SUM(k.benifit_service_provided)::bigint AS benifit_service_provided,
    SUM(k.non_actionable)::bigint AS non_actionable,
    -- Adding age-wise grievance counts
    COUNT(CASE WHEN k.applicant_age BETWEEN 0 AND 10 THEN 1 ELSE NULL END) AS age_0_10,
    COUNT(CASE WHEN k.applicant_age BETWEEN 11 AND 20 THEN 1 ELSE NULL END) AS age_11_20,
    COUNT(CASE WHEN k.applicant_age BETWEEN 21 AND 30 THEN 1 ELSE NULL END) AS age_21_30,
    COUNT(CASE WHEN k.applicant_age BETWEEN 31 AND 40 THEN 1 ELSE NULL END) AS age_31_40,
    COUNT(CASE WHEN k.applicant_age BETWEEN 41 AND 50 THEN 1 ELSE NULL END) AS age_41_50,
    COUNT(CASE WHEN k.applicant_age BETWEEN 51 AND 60 THEN 1 ELSE NULL END) AS age_51_60,
    COUNT(CASE WHEN k.applicant_age BETWEEN 61 AND 70 THEN 1 ELSE NULL END) AS age_61_70,
    COUNT(CASE WHEN k.applicant_age BETWEEN 71 AND 80 THEN 1 ELSE NULL END) AS age_71_80,
    COUNT(CASE WHEN k.applicant_age BETWEEN 81 AND 90 THEN 1 ELSE NULL END) AS age_81_90,
    COUNT(CASE WHEN k.applicant_age BETWEEN 91 AND 100 THEN 1 ELSE NULL END) AS age_91_100,
    COUNT(CASE WHEN k.applicant_age BETWEEN 101 AND 120 THEN 1 ELSE NULL END) AS age_101_120
FROM 
    (SELECT 
        SUM(recieved_from_hod) AS recieved_from_hod,
        SUM(assign_to_so) as assign_to_so,
        SUM(atr_submited_to_hoso_review) as atr_submited_to_hoso_review, 
        SUM(atr_submited_to_hoso) as atr_submited_to_hoso,
        SUM(atr_submited_other_hod) as atr_submited_other_hod,
        SUM(atr_submited_hod) as atr_submited_hod,
        SUM(total_closed) as total_closed,
        SUM(matter_taken_up) as matter_taken_up,
        SUM(benifit_service_provided) as benifit_service_provided,
        SUM(non_actionable) as non_actionable,
        gm.applicant_age -- Assuming applicant_age is in your table
    FROM 
        hoso_counts_all_office_received 
    WHERE 
        sub_office_id = {sub_office_id} 
        AND grievance_source = 5 
    GROUP BY 
        sub_office_id, gm.applicant_age -- Add gm.applicant_age to the group by
    ) k;
   
SELECT 
    SUM(k.recieved_from_hod + k.total_closed + k.atr_submited_hod) ::bigint as total_grievances,
    SUM(k.recieved_from_hod) ::bigint AS recieved_from_hod,
    SUM(k.assign_to_so)::bigint AS assign_to_so,
    SUM(k.atr_submited_to_hoso)::bigint AS atr_submited_to_hoso,
    SUM(k.atr_submited_other_hod) ::bigint AS atr_submited_other_hod,
    SUM(k.atr_submited_hod + k.atr_submited_other_hod)::bigint AS total_atr_submited_count,
    SUM(k.atr_submited_hod)::bigint AS atr_submited_hod,
    SUM(k.total_closed)::bigint AS total_closed,
    SUM(k.recieved_from_hod + k.assign_to_so + k.atr_submited_to_hoso + k.atr_submited_to_hoso_review) ::bigint AS total_atr_pending_count,
    SUM(k.matter_taken_up)::bigint AS matter_taken_up,
    SUM(k.benifit_service_provided)::bigint AS benifit_service_provided,
    SUM(k.non_actionable)::bigint AS non_actionable,
    -- Adding age-wise grievance counts
    COUNT(CASE WHEN k.applicant_age BETWEEN 0 AND 10 THEN 1 ELSE NULL END) AS age_0_10,
    COUNT(CASE WHEN k.applicant_age BETWEEN 11 AND 20 THEN 1 ELSE NULL END) AS age_11_20,
    COUNT(CASE WHEN k.applicant_age BETWEEN 21 AND 30 THEN 1 ELSE NULL END) AS age_21_30,
    COUNT(CASE WHEN k.applicant_age BETWEEN 31 AND 40 THEN 1 ELSE NULL END) AS age_31_40,
    COUNT(CASE WHEN k.applicant_age BETWEEN 41 AND 50 THEN 1 ELSE NULL END) AS age_41_50,
    COUNT(CASE WHEN k.applicant_age BETWEEN 51 AND 60 THEN 1 ELSE NULL END) AS age_51_60,
    COUNT(CASE WHEN k.applicant_age BETWEEN 61 AND 70 THEN 1 ELSE NULL END) AS age_61_70,
    COUNT(CASE WHEN k.applicant_age BETWEEN 71 AND 80 THEN 1 ELSE NULL END) AS age_71_80,
    COUNT(CASE WHEN k.applicant_age BETWEEN 81 AND 90 THEN 1 ELSE NULL END) AS age_81_90,
    COUNT(CASE WHEN k.applicant_age BETWEEN 91 AND 100 THEN 1 ELSE NULL END) AS age_91_100,
    COUNT(CASE WHEN k.applicant_age BETWEEN 101 AND 120 THEN 1 ELSE NULL END) AS age_101_120
FROM 
    (SELECT 
        SUM(recieved_from_hod) AS recieved_from_hod,
        SUM(assign_to_so) as assign_to_so,
        SUM(atr_submited_to_hoso_review) as atr_submited_to_hoso_review, 
        SUM(atr_submited_to_hoso) as atr_submited_to_hoso,
        SUM(atr_submited_other_hod) as atr_submited_other_hod,
        SUM(atr_submited_hod) as atr_submited_hod,
        SUM(total_closed) as total_closed,
        SUM(matter_taken_up) as matter_taken_up,
        SUM(benifit_service_provided) as benifit_service_provided,
        SUM(non_actionable) as non_actionable,
        gm.applicant_age -- Assuming applicant_age is in your table
    FROM 
        hoso_counts_all_office_received 
    WHERE 
        sub_office_id = {sub_office_id} 
        AND grievance_source = 5 
    GROUP BY 
        sub_office_id, gm.applicant_age -- Add gm.applicant_age to the group by
    ) k;

WITH grievance_data AS (
    SELECT 
        sub_office_id,  -- Include this so that it can be used in the JOIN
        SUM(recieved_from_hod) AS recieved_from_hod,
        SUM(assign_to_so) AS assign_to_so,
        SUM(atr_submited_to_hoso_review) AS atr_submited_to_hoso_review, 
        SUM(atr_submited_to_hoso) AS atr_submited_to_hoso,
        SUM(atr_submited_other_hod) AS atr_submited_other_hod,
        SUM(atr_submited_hod) AS atr_submited_hod,
        SUM(total_closed) AS total_closed,
        SUM(matter_taken_up) AS matter_taken_up,
        SUM(benifit_service_provided) AS benifit_service_provided,
        SUM(non_actionable) AS non_actionable
    FROM hoso_counts_all_office_received 
    WHERE sub_office_id = 2117
    AND grievance_source = 5
    GROUP BY sub_office_id
)
SELECT 
    SUM(k.recieved_from_hod + k.total_closed + k.atr_submited_hod)::bigint AS total_grievances,
    SUM(k.recieved_from_hod)::bigint AS recieved_from_hod,
    SUM(k.assign_to_so)::bigint AS assign_to_so,
    SUM(k.atr_submited_to_hoso)::bigint AS atr_submited_to_hoso,
    SUM(k.atr_submited_other_hod)::bigint AS atr_submited_other_hod,
    SUM(k.atr_submited_hod + k.atr_submited_other_hod)::bigint AS total_atr_submited_count,
    SUM(k.atr_submited_hod)::bigint AS atr_submited_hod,
    SUM(k.total_closed)::bigint AS total_closed,
    SUM(k.recieved_from_hod + k.assign_to_so + k.atr_submited_to_hoso + k.atr_submited_to_hoso_review)::bigint AS total_atr_pending_count,
    SUM(k.matter_taken_up)::bigint AS matter_taken_up,
    SUM(k.benifit_service_provided)::bigint AS benifit_service_provided,
    SUM(k.non_actionable)::bigint AS non_actionable,
    -- Age counts
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120
FROM grievance_data k
left join admin_position_master apm on apm.sub_office_id = k.sub_office_id
LEFT JOIN grievance_master gm ON gm.assigned_to_position = apm.position_id  -- Proper JOIN condition
WHERE k.sub_office_id = 2117; 


Select 
                        SUM(k.recieved_from_hod+k.total_closed+k.atr_submited_hod) ::bigint as total_grievances,
                        SUM(k.recieved_from_hod) ::bigint AS recieved_from_hod,
                        SUM(k.assign_to_so)::bigint AS assign_to_so,
                        SUM(k.atr_submited_to_hoso)::bigint AS atr_submited_to_hoso,
                        SUM(k.atr_submited_other_hod) ::bigint AS atr_submited_other_hod,
                        SUM(k.atr_submited_hod + k.atr_submited_other_hod)::bigint AS total_atr_submited_count,
                        SUM(k.atr_submited_hod)::bigint AS atr_submited_hod,
                        SUM(k.total_closed)::bigint AS total_closed,
                        SUM(k.recieved_from_hod+k.assign_to_so+k.atr_submited_to_hoso+k.atr_submited_to_hoso_review) ::bigint AS total_atr_pending_count,
                        SUM(k.matter_taken_up)::bigint AS matter_taken_up,
                        SUM(k.benifit_service_provided )::bigint AS benifit_service_provided,
                        SUM(k.non_actionable )::bigint AS non_actionable
                FROM 
        (select 
        SUM(recieved_from_hod) AS recieved_from_hod,
        SUM(assign_to_so) as assign_to_so,
        SUM(atr_submited_to_hoso_review) as atr_submited_to_hoso_review, 
        SUM(atr_submited_to_hoso) as atr_submited_to_hoso,
        SUM(atr_submited_other_hod) as atr_submited_other_hod,
        SUM(atr_submited_hod) as atr_submited_hod,
        SUM(total_closed) as total_closed,
        SUM(matter_taken_up) as matter_taken_up,
        SUM(benifit_service_provided) as benifit_service_provided,
        SUM(non_actionable) as non_actionable
        from hoso_counts_all_office_received where suboffice_id = 1 and grievance_source = 5 
        group by suboffice_id)k;
        

-------------------
select * from 
(select sum(count) as "0_to_10" from (select applicant_age, count(1) from grievance_master gm group by gm.applicant_age) where applicant_age between 0 and 10)a,
(select sum(count) as "11_to_20" from (select applicant_age, count(1) from grievance_master gm group by gm.applicant_age) where applicant_age between 11 and 20)b,   
(select sum(count) as "21_to_30" from (select applicant_age, count(1) from grievance_master gm group by gm.applicant_age) where applicant_age between 21 and 30)c,  
(select sum(count) as "31_to_40" from (select applicant_age, count(1) from grievance_master gm group by gm.applicant_age) where applicant_age between 31 and 40)d,  
(select sum(count) as "41_to_50" from (select applicant_age, count(1) from grievance_master gm group by gm.applicant_age) where applicant_age between 41 and 50)e,  
(select sum(count) as "51_to_60" from (select applicant_age, count(1) from grievance_master gm group by gm.applicant_age) where applicant_age between 51 and 60)f ;


SELECT 
    COUNT(CASE WHEN applicant_age BETWEEN 0 AND 10 THEN grievance_id END) AS "age_0_10",
    COUNT(CASE WHEN applicant_age BETWEEN 11 AND 20 THEN grievance_id END) AS "age_11_20",
    COUNT(CASE WHEN applicant_age BETWEEN 21 AND 30 THEN grievance_id END) AS "age_21_30",
    COUNT(CASE WHEN applicant_age BETWEEN 31 AND 40 THEN grievance_id END) AS "age_31_40",
    COUNT(CASE WHEN applicant_age BETWEEN 41 AND 50 THEN grievance_id END) AS "age_41_50",
    COUNT(CASE WHEN applicant_age BETWEEN 51 AND 60 THEN grievance_id END) AS "age_51_60",
    COUNT(CASE WHEN applicant_age BETWEEN 61 AND 70 THEN grievance_id END) AS "age_61_70",
    COUNT(CASE WHEN applicant_age BETWEEN 71 AND 80 THEN grievance_id END) AS "age_71_80",
    COUNT(CASE WHEN applicant_age BETWEEN 81 AND 90 THEN grievance_id END) AS "age_81_90",
    COUNT(CASE WHEN applicant_age BETWEEN 91 AND 100 THEN grievance_id END) AS "age_91_100",
    COUNT(CASE WHEN applicant_age BETWEEN 101 AND 120 THEN grievance_id END) AS "age_101_120"
FROM grievance_master gm
	inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
	inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
	 gm.grievance_source = 5 
-- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
	and gm.status IS NOT null
-- and assigned_to_office_id =  3
	and apm.sub_office_id = 1097 and apm.office_id = 14;


select apm.*
FROM grievance_master gm
	inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
	inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
	gm.grievance_source = 5; --and apm.office_id = 53;
 

select apm.*
FROM grievance_master gm
	inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
	inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id ; 


select * from grievance_master gm ; ---(position)
select * from admin_position_master apm ; -- CMO_OFFICE = user_type =1, office_category = 1, role_master_id = 9
										  -- cmo - ofc/user_type = 1, office_category = 1, role_master_id = 1,2,3
										  -- HOD - ofc, user_type = 2, office_categopry = 2, role_master_id = 4,5,6
										  -- HOSO -ofc,sub-office, user_type = 3sd, office_category = 3, role_master_id = 7,8 
select * from admin_user_role_master aurm ;
select * from admin_user_details aud ;
select * from admin_user au ;
select * from admin_user_position_mapping aupm;


-- Grievance in current user
select * from grievance_master gm; -- assign_to_position / assign_to_id
select * from admin_position_master;




select * from grievance_master gm 
inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
inner join cmo_office_master com on apm.office_id = com.office_id 
inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
inner join admin_user_role_master aurm on apm.role_master_id = aurm.role_master_id 
inner join cmo_designation_master cdm on apm.designation_id = cdm.designation_id
where user_type in (2,3) and apm.role_master_id in (4,7);


SELECT 
    COUNT(CASE WHEN applicant_age BETWEEN 0 AND 10 THEN grievance_id END) AS "age_0_10",
    COUNT(CASE WHEN applicant_age BETWEEN 11 AND 20 THEN grievance_id END) AS "age_11_20",
    COUNT(CASE WHEN applicant_age BETWEEN 21 AND 30 THEN grievance_id END) AS "age_21_30",
    COUNT(CASE WHEN applicant_age BETWEEN 31 AND 40 THEN grievance_id END) AS "age_31_40",
    COUNT(CASE WHEN applicant_age BETWEEN 41 AND 50 THEN grievance_id END) AS "age_41_50",
    COUNT(CASE WHEN applicant_age BETWEEN 51 AND 60 THEN grievance_id END) AS "age_51_60",
    COUNT(CASE WHEN applicant_age BETWEEN 61 AND 70 THEN grievance_id END) AS "age_61_70",
    COUNT(CASE WHEN applicant_age BETWEEN 71 AND 80 THEN grievance_id END) AS "age_71_80",
    COUNT(CASE WHEN applicant_age BETWEEN 81 AND 90 THEN grievance_id END) AS "age_81_90",
    COUNT(CASE WHEN applicant_age BETWEEN 91 AND 100 THEN grievance_id END) AS "age_91_100",
    COUNT(CASE WHEN applicant_age BETWEEN 101 AND 120 THEN grievance_id END) AS "age_101_120"
FROM grievance_master gm
	inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
	inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
	-- gm.status IS NOT null
-- and assigned_to_office_id =  3
	 apm.sub_office_id = 1097 and apm.office_id = 14;




result = select applicant_age, count(1) from grievance_master gm group by gm.applicant_age;


resp = {
	'0_to_10':0,
	'11_to_20':0,
	'21_to_30':0
}
for item in result:
	if applicant_age in range(0,10):
		resp[0_to_10] = resp.get('0_to_10') + count
		
	if applicant_age in range(11,20):
		resp[0_to_10] = resp.get('11_to_20') + count
	


Select 
                        SUM(k.recieved_from_hod+k.total_closed+k.atr_submited_hod) ::bigint as total_grievances,
                        SUM(k.recieved_from_hod) ::bigint AS recieved_from_hod,
                        SUM(k.assign_to_so)::bigint AS assign_to_so,
                        SUM(k.atr_submited_to_hoso)::bigint AS atr_submited_to_hoso,
                        SUM(k.atr_submited_other_hod) ::bigint AS atr_submited_other_hod,
                        SUM(k.atr_submited_hod + k.atr_submited_other_hod)::bigint AS total_atr_submited_count,
                        SUM(k.atr_submited_hod)::bigint AS atr_submited_hod,
                        SUM(k.total_closed)::bigint AS total_closed,
                        SUM(k.recieved_from_hod+k.assign_to_so+k.atr_submited_to_hoso+k.atr_submited_to_hoso_review) ::bigint AS total_atr_pending_count,
                        SUM(k.matter_taken_up)::bigint AS matter_taken_up,
                        SUM(k.benifit_service_provided )::bigint AS benifit_service_provided,
                        SUM(k.non_actionable )::bigint AS non_actionable
                FROM 
        (select 
        SUM(recieved_from_hod) AS recieved_from_hod,
        SUM(assign_to_so) as assign_to_so,
        SUM(atr_submited_to_hoso_review) as atr_submited_to_hoso_review, 
        SUM(atr_submited_to_hoso) as atr_submited_to_hoso,
        SUM(atr_submited_other_hod) as atr_submited_other_hod,
        SUM(atr_submited_hod) as atr_submited_hod,
        SUM(total_closed) as total_closed,
        SUM(matter_taken_up) as matter_taken_up,
        SUM(benifit_service_provided) as benifit_service_provided,
        SUM(non_actionable) as non_actionable
        from hoso_counts_all_office_received where sub_office_id = 1 and grievance_source = 5 
        group by sub_office_id)k;
       
SELECT COUNT(*)
FROM grievance_master
WHERE grievance_id > 0 AND status = 15;

SELECT
                        COUNT(gm.grievance_id > 0) AS grievances_recieved,
                        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed
                    FROM grievance_master gm
                        inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
                        inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
                    WHERE
                        gm.grievance_source = 5 
                    -- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
                        and gm.status IS NOT null
                    -- and assigned_to_office_id =  3
                        and apm.sub_office_id = 3636 and apm.office_id = 79;
                        
SELECT 
	COUNT(gm.grievance_id > 0) AS grievances_recieved,
    COUNT(CASE WHEN applicant_age BETWEEN 0 AND 10 THEN grievance_id END) AS "age_0_10",
    COUNT(CASE WHEN applicant_age BETWEEN 11 AND 20 THEN grievance_id END) AS "age_11_20",
    COUNT(CASE WHEN applicant_age BETWEEN 21 AND 30 THEN grievance_id END) AS "age_21_30",
    COUNT(CASE WHEN applicant_age BETWEEN 31 AND 40 THEN grievance_id END) AS "age_31_40",
    COUNT(CASE WHEN applicant_age BETWEEN 41 AND 50 THEN grievance_id END) AS "age_41_50",
    COUNT(CASE WHEN applicant_age BETWEEN 51 AND 60 THEN grievance_id END) AS "age_51_60",
    COUNT(CASE WHEN applicant_age BETWEEN 61 AND 70 THEN grievance_id END) AS "age_61_70",
    COUNT(CASE WHEN applicant_age BETWEEN 71 AND 80 THEN grievance_id END) AS "age_71_80",
    COUNT(CASE WHEN applicant_age BETWEEN 81 AND 90 THEN grievance_id END) AS "age_81_90",
    COUNT(CASE WHEN applicant_age BETWEEN 91 AND 100 THEN grievance_id END) AS "age_91_100",
    COUNT(CASE WHEN applicant_age BETWEEN 101 AND 120 THEN grievance_id END) AS "age_101_120"
FROM grievance_master gm
	inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
	inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
	-- gm.status IS NOT null
-- and assigned_to_office_id =  3
	 apm.sub_office_id = 3636 and apm.office_id = 79;
	
SELECT 
	COUNT(gm.grievance_id > 0) AS grievances_recieved,
    COUNT(CASE WHEN applicant_age BETWEEN 0 AND 10 THEN grievance_id END) AS "age_0_10",
    COUNT(CASE WHEN applicant_age BETWEEN 11 AND 20 THEN grievance_id END) AS "age_11_20",
    COUNT(CASE WHEN applicant_age BETWEEN 21 AND 30 THEN grievance_id END) AS "age_21_30",
    COUNT(CASE WHEN applicant_age BETWEEN 31 AND 40 THEN grievance_id END) AS "age_31_40",
    COUNT(CASE WHEN applicant_age BETWEEN 41 AND 50 THEN grievance_id END) AS "age_41_50",
    COUNT(CASE WHEN applicant_age BETWEEN 51 AND 60 THEN grievance_id END) AS "age_51_60",
    COUNT(CASE WHEN applicant_age BETWEEN 61 AND 70 THEN grievance_id END) AS "age_61_70",
    COUNT(CASE WHEN applicant_age BETWEEN 71 AND 80 THEN grievance_id END) AS "age_71_80",
    COUNT(CASE WHEN applicant_age BETWEEN 81 AND 90 THEN grievance_id END) AS "age_81_90",
    COUNT(CASE WHEN applicant_age BETWEEN 91 AND 100 THEN grievance_id END) AS "age_91_100",
    COUNT(CASE WHEN applicant_age BETWEEN 101 AND 120 THEN grievance_id END) AS "age_101_120"
FROM grievance_master gm
    inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
    left join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
    gm.grievance_source = 0 
-- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
    and gm.status IS NOT null
-- and assigned_to_office_id =  3
                and apm.sub_office_id = 1510 and apm.office_id = 27;
               
 SELECT 
	COUNT(gm.grievance_id > 0) AS grievances_recieved,
    COUNT(CASE WHEN applicant_age BETWEEN 0 AND 10 THEN grievance_id END) AS "age_0_10",
    COUNT(CASE WHEN applicant_age BETWEEN 11 AND 20 THEN grievance_id END) AS "age_11_20",
    COUNT(CASE WHEN applicant_age BETWEEN 21 AND 30 THEN grievance_id END) AS "age_21_30",
    COUNT(CASE WHEN applicant_age BETWEEN 31 AND 40 THEN grievance_id END) AS "age_31_40",
    COUNT(CASE WHEN applicant_age BETWEEN 41 AND 50 THEN grievance_id END) AS "age_41_50",
    COUNT(CASE WHEN applicant_age BETWEEN 51 AND 60 THEN grievance_id END) AS "age_51_60",
    COUNT(CASE WHEN applicant_age BETWEEN 61 AND 70 THEN grievance_id END) AS "age_61_70",
    COUNT(CASE WHEN applicant_age BETWEEN 71 AND 80 THEN grievance_id END) AS "age_71_80",
    COUNT(CASE WHEN applicant_age BETWEEN 81 AND 90 THEN grievance_id END) AS "age_81_90",
    COUNT(CASE WHEN applicant_age BETWEEN 91 AND 100 THEN grievance_id END) AS "age_91_100",
    COUNT(CASE WHEN applicant_age BETWEEN 101 AND 120 THEN grievance_id END) AS "age_101_120"
FROM grievance_master gm
    inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
    left join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
     gm.status IS NOT null
-- and assigned_to_office_id =  3
     and apm.sub_office_id = 18 and apm.office_id = 3;
 
    -- DROP FUNCTION public.cmo_grievance_counts_gender();

CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_gender(ssm_id integer, dept_id integer)
	RETURNS TABLE(new_grievances bigint, assigned_to_cmo bigint, recieved_from_cmo bigint, assigned_to_hod bigint, recieved_from_other_hod bigint, atr_returend_to_hod_for_review bigint, forwarded_to_hoso bigint, assign_to_so bigint, atr_submitted_to_hoso bigint, atr_returned_so_for_review bigint, atr_submitted_to_hod bigint, atr_returned_to_hoso_for_review bigint, atr_submitted_to_other_hod bigint, atr_submitted_to_cmo bigint, disposed bigint, recalled bigint, returned bigint, grievances_recieved bigint, atr_pending bigint, grievances_recieved_male bigint, grievances_recieved_female bigint, grievances_recieved_others bigint)
	LANGUAGE plpgsql
AS $function$
	BEGIN
		if dept_id > 0	then 
			if ssm_id > 0 then
			    return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 1) as INTEGER) as grievances_recieved_male,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 2) as INTEGER) as grievances_recieved_female,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 3) as INTEGER) as grievances_recieved_others,
--				COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
--				COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS grievances_recieved_female,
--				COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others
				from grievance_master gm 
				where gm.grievance_source = ssm_id and (gm.assigned_to_position  in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            ) or gm.updated_by_position in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            ));
	      else
	      		return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 1) as INTEGER) as grievances_recieved_male,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 2) as INTEGER) as grievances_recieved_female,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 3) as INTEGER) as grievances_recieved_others
--				COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
--				COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS grievances_recieved_female,
--				COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others
				from grievance_master gm 
				where (gm.assigned_to_position  in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            ) or gm.updated_by_position in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            )
							);
		 end if;
	      		
		else
			if ssm_id > 0 then
			 	return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 1) as INTEGER) as grievances_recieved_male,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 2) as INTEGER) as grievances_recieved_female,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 3) as INTEGER) as grievances_recieved_others
--				COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
--				COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS grievances_recieved_female,
--				COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others
				from grievance_master gm 
				where gm.grievance_source = ssm_id;
			else
				return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 1) as INTEGER) as grievances_recieved_male,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 2) as INTEGER) as grievances_recieved_female,
				COUNT(cast(gm.grievance_id > 0 AND gm.applicant_gender = 3) as INTEGER) as grievances_recieved_others
--				COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
--				COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS grievances_recieved_female,
--				COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others
				from grievance_master gm;
		  end if ;
		end if;
	END;
$function$
;

select max(l.official_name) as official_name,
                max(l.role_master_name) as role_master_name ,
                l.position_id,
                max(l.official_and_role_name) as official_and_role_name ,
              	SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
--                SUM(CAST(gm AS INT)) AS new_grievances_forwarded,
--                SUM(CASE WHEN gm.status = 4 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS forwarded,
                SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
                SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed,
                SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
                SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review ,
                SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod 
--                SUM(CAST(l.atr_disposed AS INT)) AS atr_disposed,
--                SUM(CAST(l.atr_disposal_pending AS INT)) AS atr_disposal_pending,
--                SUM(CAST(l.atr_returned_to_hods AS INT)) AS atr_returned_to_hods
            from cmo_user_wise_grievance_ssm l, grievance_master gm 
            where l.position_id = 0 or l.position_id in (
                SELECT 
                apm.position_id
                FROM 
                    admin_position_master apm 
                    INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
                    INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
                    INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
                    left join grievance_master gm ON gm.assigned_to_position = l.position_id
                where apm.role_master_id IN (1,2,3,9) AND apm.office_id = 1
            )
            group by l.position_id
            ORDER BY 
            CASE WHEN max(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
            max(official_name::text);
           
select max(l.official_name) as official_name,
                max(l.role_master_name) as role_master_name ,
                l.position_id,
                max(l.official_and_role_name) as official_and_role_name ,
                SUM(CAST(l.new_grievances_forwarded AS INT)) AS new_grievances_forwarded,
                SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
                SUM(CAST(l.atr_disposed AS INT)) AS atr_disposed,
                SUM(CAST(l.atr_disposal_pending AS INT)) AS atr_disposal_pending,
                SUM(CAST(l.atr_returned_to_hods AS INT)) AS atr_returned_to_hods
            from cmo_user_wise_pending l
            where l.position_id = 0 or l.position_id in (
                SELECT 
                apm.position_id
                FROM 
                    admin_position_master apm 
                    INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
                    INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
                    INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
                where apm.role_master_id IN (1,2,3,9) AND apm.office_id = 1
            )
            group by l.position_id
            ORDER BY 
            CASE WHEN max(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
            max(official_name::text);

           
           
           
            
 SELECT 
    MAX(l.official_name) AS official_name,
    MAX(l.role_master_name) AS role_master_name,
    l.position_id,
    MAX(l.official_and_role_name) AS official_and_role_name,
    SUM(CAST(l.new_grievances_forwarded AS INT)) AS new_grievances_forwarded,
    SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
    SUM(CAST(l.atr_disposed AS INT)) AS atr_disposed,
    SUM(CAST(l.atr_disposal_pending AS INT)) AS atr_disposal_pending,
    SUM(CAST(l.atr_returned_to_hods AS INT)) AS atr_returned_to_hods,
    -- New line to sum forwarded grievances where status = 4
    SUM(CASE WHEN gm.status = 4 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS forwarded_with_status_4
FROM 
    cmo_user_wise_grievance_ssm l
LEFT JOIN 
    admin_position_master apm ON l.position_id = apm.position_id
LEFT JOIN 
    admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
LEFT JOIN 
    admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id
LEFT JOIN 
    admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id
LEFT JOIN 
    grievance_master gm ON gm.assigned_to_position = l.position_id -- Join with grievance_master table
WHERE 
    (l.position_id = 0 OR apm.role_master_id IN (1, 2, 3, 9)) 
    AND apm.office_id = 1
GROUP BY 
    l.position_id
ORDER BY 
    CASE 
        WHEN MAX(l.official_name::text) = 'Unassigned' THEN 0 
        ELSE 1 
    END,
    MAX(l.official_name::text);
   
   
   
   
SELECT 
    csom.suboffice_name AS office_name,
    gm.grievance_id,
    COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
FROM 
    grievance_master gm 
    INNER JOIN admin_position_master apm 
        ON apm.position_id = gm.assigned_to_position 
        AND apm.office_id = 0
        AND apm.sub_office_id IS NOT NULL 
    INNER JOIN cmo_sub_office_master csom 
        ON csom.suboffice_id = apm.sub_office_id 
WHERE 
    gm.status IN (8, 9, 10, 12) 
    AND gm.grievance_source = 0  -- Apply if ssm_id is present
GROUP BY 
    csom.suboffice_name 
ORDER BY 
    per_hod_count DESC;
   
   
   
   
   
SELECT gm.grievance_category,
        cgcm.grievance_category_desc,
        COUNT(DISTINCT gm.grievance_id) AS category_grievance_count
FROM grievance_master gm 
INNER JOIN cmo_grievance_category_master cgcm 
ON cgcm.grievance_cat_id = gm.grievance_category
WHERE gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
AND gm.grievance_source = 5
GROUP BY gm.grievance_category, cgcm.grievance_category_desc
ORDER BY category_grievance_count DESC 
LIMIT 10;





SELECT 
   	csom.suboffice_name AS office_name,
    COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
FROM 
    grievance_master gm
left JOIN 
    grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
   INNER JOIN admin_position_master apm 
        ON apm.position_id = gm.assigned_to_position 
        AND apm.office_id = 0
        AND apm.sub_office_id IS NOT NULL 
    INNER JOIN cmo_sub_office_master csom 
        ON csom.suboffice_id = apm.sub_office_id
     left join cmo_sub_office_master csom on csom.sub_division_id = gm.sub_division_id 
GROUP BY 
    csom.suboffice_name, gm.grievance_id 
ORDER BY 
    atr_recevied_count, atr_pending_count DESC;
   
   
SELECT 
--    gm.district_id,
    cdm.district_name,
    -- COUNT(gm.grievance_id) AS total_grievance_count,
    -- COUNT(CASE WHEN gm.status = 15 THEN 1 END) AS closed_grievance_count,
    COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_recevied_count,
    COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
FROM 
    grievance_master gm
LEFT JOIN
    grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
LEFT JOIN 
    cmo_districts_master cdm ON cdm.district_id = gm.district_id
--inner join 
--	admin_position_master apm on apm.position_id = gm.assigned_to_position
WHERE 
    gm.district_id IS NOT NULL
--    AND gm.grievance_source = 5  -- Added 'AND' before this condition
GROUP BY 
    gm.district_id, cdm.district_name
ORDER BY
    atr_recevied_count DESC,
    atr_pending_count DESC; 


select * from (
    select 
    		cdm.district_name,
    		COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_recevied_count,
			COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
    from grievance_master gm 
    		LEFT join grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
    		LEFT JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
            left join admin_position_master apm on apm.position_id = gm.assigned_to_position
    where 
        gm.district_id IS NOT NULL 
       group by cdm.district_name)q order by q.atr_recevied_count desc ; 
      
      
      
      
   
   
select * from (
                select com.office_name ,
                    Count(distinct gm.grievance_id) as per_hod_count 
                from grievance_master gm 
                        inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
                        inner join cmo_office_master com on com.office_id = apm.office_id 
                where 
                    gm.status  in (3,4,5,6,7,8,9,10,11,12,13,16,17) and apm.user_type = 2 
                    group by com.office_name)q order by q.per_hod_count desc ;   
                   
                   
                   
                   

select * from (
                select csom.suboffice_name as office_name,
                    Count(distinct gm.grievance_id) as per_hod_count 
                from grievance_master gm 
                        inner join admin_position_master apm on apm.position_id = gm.assigned_to_position and apm.office_id = 80 and apm.sub_office_id is not null 
                        inner join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id 
                where 
                    gm.status  in (8,9,10,12)  group by csom.suboffice_name)q order by q.per_hod_count desc;
                   
                   
                   
                   
                   select * from grievance_master gm where status = 2;
                  
select distinct gl.grievance_status ,gm.grievance_id from public.grievance_lifecycle gl
inner join grievance_master gm on gm.grievance_id = gl.grievance_id and gm.status = 2
where gl.grievance_id = 2170 
order by assigned_on desc;

with presviuous_status as (
	select row_number() over (partition by grievance_status) , gl.grievance_status ,gm.grievance_id from public.grievance_lifecycle gl
	inner join grievance_master gm on gm.grievance_id = gl.grievance_id and gm.status = 2
	where gl.grievance_id = 2170 
	order by assigned_on desc
),
distinct_status as (
	select distinct grievance_status, grievance_id from presviuous_status
)
select * from presviuous_status;
   
with previous_stayus as (
select distinct gl.grievance_status, gm.grievance_id from public.grievance_lifecycle gl
inner join grievance_master gm on gm.grievance_id = gl.grievance_id and gm.status = 2
where gl.grievance_id = 2170
order by assigned_on desc offset 1 limit 1
)                  


SELECT 
    com.office_name,
--    COUNT(gm.grievance_id) AS total_grievance_count,
--    COUNT(CASE WHEN gm.status = 15 THEN 1 END) AS closed_grievance_count,
    COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
FROM 
    grievance_master gm
join
	grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
LEFT JOIN 
	cmo_office_master com on com.office_id = gm.assigned_to_office_id 
--left join 
--	admin_position_master apm on apm.office_id = com.office_id 
left join 
	admin_position_master apm on apm.office_id = gm.assigned_to_office_id 
--left join 
--	cmo_office_master com on com.office_id = apm.office_id 
--where
--      com.office_category = 2
GROUP BY 
    com.office_name
ORDER BY
    atr_pending_count desc, atr_recevied_count desc;
   
   
SELECT 
    gm.district_id,
    com.office_name,
    com.office_id,
    COUNT(gm.grievance_id) AS total_grievance_count,
    COUNT(CASE WHEN gm.status = 15 THEN 1 END) AS closed_grievance_count,
    COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
FROM 
    grievance_master gm
join
	grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
LEFT JOIN 
    cmo_office_master com ON com.district_id = gm.district_id
WHERE 
    gm.district_id IS NOT null
GROUP BY 
    gm.district_id, com.office_name, com.office_id;
    
   
   

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
            FROM (
                SELECT
                    COUNT(CASE WHEN gm.applicant_caste = 1 THEN 1 END) AS total_general_count,
                    COUNT(CASE WHEN gm.applicant_caste = 2 THEN 1 END) AS total_sc_count,
                    lu.assigned_to_office_id 
                FROM 
                    lastupdates lu
                INNER JOIN 
                    grievance_master gm ON gm.grievance_id = lu.grievance_id 
                WHERE 
                    lu.rn = 1 
                    AND lu.assigned_to_office_id = 53
                    AND gm.status IS NOT NULL  
                    AND gm.grievance_source = 5
                    AND (gm.status = 15 OR gm.assigned_to_office_id = 53) 
                GROUP BY 
                    lu.assigned_to_office_id
            ) k;
           
            
 select max(l.official_name) as official_name,
                max(l.role_master_name) as role_master_name ,
                l.position_id,
                max(l.official_and_role_name) as official_and_role_name ,
              	SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
		        SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
		        SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed,
		        SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
		        SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review ,
		        SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod
--                SUM(CAST(l.atr_disposed AS INT)) AS atr_disposed,
--                SUM(CAST(l.atr_disposal_pending AS INT)) AS atr_disposal_pending,
--                SUM(CAST(l.atr_returned_to_hods AS INT)) AS atr_returned_to_hods
    from cmo_user_wise_pending l, grievance_master gm 
    where l.position_id = 0 or l.position_id in (
        SELECT 
        apm.position_id
        FROM 
            admin_position_master apm 
            INNER JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id 
            INNER JOIN admin_user_details aud ON aud.admin_user_id = aupm.admin_user_id 
            INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id 
--            left join grievance_master gm ON gm.assigned_to_position = l.position_id
        where apm.role_master_id IN (1,2,3,9) AND apm.office_id = 1
    )
    group by l.position_id
    ORDER BY 
    CASE WHEN max(official_name::text) = 'Unassigned' THEN 0 ELSE 1 END,
    max(official_name::text);
    
   
   
   
 select
    table1.office_id,
    table1.office_name,
    coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
    coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
    coalesce(table5.total_disposed,0) as total_disposed,
    coalesce(table6.pending_with_hod,0) as atr_pending,
    coalesce(table10.days_diff,0) as average_resolution_days,
    coalesce(table11.benefit_provided,0) as benefit_provided,
    coalesce(table12.mater_taken_up,0) as mater_taken_up,
--    coalesce(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100,0) AS BSP_percentage,
    coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER),0) AS BSP_percentage,
--	'Good'::text AS performance
  --  coalesce(table8.grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
   -- coalesce(table9.grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
	-- Performance Calculation using CASE
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
	FROM
        (
        select
            com.office_id ,
            com.office_name
        from
            cmo_office_master com
        where
            com.office_category = 2
                ) table1
        -- grv frwded
    left outer join(
        select
            count(distinct grievance_id) as grv_frwd,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            apm.office_id) table2
            on
        table1.office_id = table2.office_id
        -- atr recvd
    left outer join(
        select
            count(distinct grievance_id) as atr_recvd ,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.updated_by_position
        where
           gm.status = 14
        group by
            apm.office_id) table3
            on
        table1.office_id = table3.office_id
        -- total disposed 	
    left outer join(
        select
            count(1) as total_disposed,
            co.assigned_by_office_id
        from
            grievance_master gm
        join atr_submitted_max_records_clone co on
            co.grievance_id = gm.grievance_id
        where
        	gm.status = 15
        group by
            co.assigned_by_office_id) table5
            on
        table1.office_id = table5.assigned_by_office_id	
        -- grv pending with hod
    left outer join(
        select
            count(distinct grievance_id) as pending_with_hod ,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            gm.assigned_to_office_id) table6
            on
        table1.office_id = table6.assigned_to_office_id
 		-- average days for grievance
	left outer join (
	    select
	        ar.assigned_by_office_id,
	        extract (day
	    from
	        avg(ar.max_assigned_on - co.max_assigned_on)) as days_diff
	    from
	        atr_submitted_max_records_clone ar,
	        recvd_from_cmo_max_clone_view co,
	        grievance_master gm
	    where
	        ar.grievance_id = co.grievance_id
	        and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
	    group by
	        ar.assigned_by_office_id) table10
	        on
	    table10.assigned_by_office_id = table1.office_id
	    -- benifit provided
	left outer join (
	   select 
			count(distinct grievance_id) as benefit_provided,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.position_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id = 1
		group by 
			apm.office_id) table11
		on
		table1.office_id = table11.office_id
		-- matter taken up
	left outer join (
		select 
			count(distinct grievance_id) as mater_taken_up,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.position_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id in (5,9)
		group by 
			apm.office_id) table12
		on
		table1.office_id = table12.office_id
		ORDER BY 
		    grievance_forwarded DESC,
		    atr_recieved_count DESC,
		    total_disposed DESC,
		    atr_pending DESC,
		    average_resolution_days DESC,
		    benefit_provided DESC,
		    BSP_percentage DESC,
		    performance DESC;  									-- hods wise grivence table
		
-- without ssm id
select
        table1.office_id,
        table1.office_name,
        coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
        coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
        coalesce(table5.total_disposed,0) as total_disposed,
        coalesce(table6.pending_with_hod,0) as atr_pending,
      --  coalesce(table8.grv_pendng_upto_svn_d,
       -- 0) as grv_pendng_upto_svn_d,
       -- coalesce(table9.grv_pendng_more_svn_d,
      --  0) as grv_pendng_more_svn_d,
        coalesce(days_diff,0) as average_resolution_days,
        'Good'::text AS performance
    from
        (
        select
            com.office_id ,
            com.office_name
        from
            cmo_office_master com
        where
            com.office_category = 2
                ) table1
        -- grv frwded
    left outer join(
        select
            count(distinct grievance_id) as grv_frwd,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            apm.office_id ) table2
            on
        table1.office_id = table2.office_id
        -- atr recvd
    left outer join(
        select
            count(distinct grievance_id) as atr_recvd ,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.updated_by_position
        where
	        gm.status = 14
        group by
            apm.office_id ) table3
            on
        table1.office_id = table3.office_id
        -- total disposed 	
    left outer join(
        select
            count(1) as total_disposed,
            co.assigned_by_office_id
        from
            grievance_master gm
        join atr_submitted_max_records_clone co on
            co.grievance_id = gm.grievance_id
        where
        	gm.status = 15
        group by
            co.assigned_by_office_id
            ) table5
            on
        table1.office_id = table5.assigned_by_office_id	
        -- grv pending with hod
    left outer join(
        select
            count(distinct grievance_id) as pending_with_hod ,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            gm.assigned_to_office_id ) table6
            on
        table1.office_id = table6.assigned_to_office_id
        -- avg no of days submit atr
    left outer join (
        select
            ar.assigned_by_office_id,
            extract (day
        from
            avg(ar.max_assigned_on - co.max_assigned_on)) as days_diff
        from
            atr_submitted_max_records_clone ar,
            recvd_from_cmo_max_clone_view co,
            grievance_master gm
        where
            ar.grievance_id = co.grievance_id
            and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
        group by
            ar.assigned_by_office_id
            ) table10
            on
        table10.assigned_by_office_id = table1.office_id;
	
	

SELECT 
    table1.office_id,
    table1.office_name,
    COALESCE(table2.grv_frwd, 0) + COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS grievance_forwarded,
    COALESCE(table3.atr_recvd, 0) + COALESCE(table5.total_disposed, 0) AS atr_recieved_count,
    COALESCE(table5.total_disposed, 0) AS total_disposed,
    COALESCE(table6.pending_with_hod, 0) AS atr_pending,
    COALESCE(table10.days_diff, 0) AS average_resolution_days,
    COALESCE(table11.benefit_provided, 0) AS benefit_provided,
    COALESCE(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up) * 100, 0) AS BSP_percentage,
    -- Performance Calculation using CASE
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
FROM
    (SELECT 
        com.office_id,
        com.office_name
    FROM
        cmo_office_master com
    WHERE
        com.office_category = 2) table1
    -- Grievance forwarded
    LEFT OUTER JOIN (
        SELECT 
            COUNT(DISTINCT grievance_id) AS grv_frwd,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        GROUP BY
            apm.office_id
    ) table2 ON table1.office_id = table2.office_id
    -- ATR received
    LEFT OUTER JOIN (
        SELECT 
            COUNT(DISTINCT grievance_id) AS atr_recvd,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON apm.position_id = gm.updated_by_position
        WHERE
            gm.status = 14
        GROUP BY
            apm.office_id
    ) table3 ON table1.office_id = table3.office_id
    -- Total disposed
    LEFT OUTER JOIN (
        SELECT 
            COUNT(1) AS total_disposed,
            co.assigned_by_office_id
        FROM
            grievance_master gm
        JOIN atr_submitted_max_records_clone co ON co.grievance_id = gm.grievance_id
        WHERE
            gm.status = 15
        GROUP BY
            co.assigned_by_office_id
    ) table5 ON table1.office_id = table5.assigned_by_office_id
    -- Pending with HoD
    LEFT OUTER JOIN (
        SELECT 
            COUNT(DISTINCT grievance_id) AS pending_with_hod,
            gm.assigned_to_office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_position
        WHERE
            gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        GROUP BY
            gm.assigned_to_office_id
    ) table6 ON table1.office_id = table6.assigned_to_office_id
    -- Average resolution days
    LEFT OUTER JOIN (
        SELECT 
            ar.assigned_by_office_id,
            EXTRACT(DAY FROM AVG(ar.max_assigned_on - co.max_assigned_on)) AS days_diff
        FROM
            atr_submitted_max_records_clone ar,
            recvd_from_cmo_max_clone_view co,
            grievance_master gm
        WHERE
            ar.grievance_id = co.grievance_id
            AND ar.grievance_id = gm.grievance_id
            AND co.assigned_to_office_id = ar.assigned_by_office_id
        GROUP BY
            ar.assigned_by_office_id
    ) table10 ON table10.assigned_by_office_id = table1.office_id
    -- Benefit provided
    LEFT OUTER JOIN (
        SELECT 
            COUNT(DISTINCT grievance_id) AS benefit_provided,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_office_id
        WHERE
            gm.closure_reason_id = 1
        GROUP BY
            apm.office_id
    ) table11 ON table1.office_id = table11.office_id
    -- Matter taken up
    LEFT OUTER JOIN (
        SELECT 
            COUNT(DISTINCT grievance_id) AS mater_taken_up,
            apm.office_id
        FROM
            grievance_master gm
        JOIN admin_position_master apm ON apm.position_id = gm.assigned_to_office_id
        WHERE
            gm.closure_reason_id IN (5, 9)
        GROUP BY
            apm.office_id
    ) table12 ON table1.office_id = table12.office_id;
   
   
SELECT 
                k.district_id as district_id,
                k.district_name as district_name,
                COALESCE(SUM(k.grievances_recieved), 0) :: INT AS total_grievance_count,
--              COALESCE(k.grievance_recieved_count_cmo, 0) :: INT AS grievance_recieved_count_cmo, 
                COALESCE(k.grievance_recieved_count_cmo, 0) :: INT AS grievance_sent, 
                COALESCE(k.atr_submitted_to_cmo, 0) :: INT AS atr_received, 
                COALESCE(k.grievance_recieved_count_other_hod, 0) :: INT AS grievance_recieved_count_other_hod,
                COALESCE(k.total_close_grievance_count, 0) :: INT AS total_close_grievance_count,
                COALESCE(k.atr_pending, 0) :: INT AS atr_pending
                from (
                    select  
                        cdm.district_id,
                        cdm.district_name,
                        COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
                        COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
                        COUNT(case when gm.status = 3 then gm.grievance_id end) as grievance_recieved_count_cmo,
                        COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
                        COUNT(case when gm.status = 5 then gm.grievance_id end) as grievance_recieved_count_other_hod,
                        COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
                        COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
                        COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
                        COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
                        COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
                        COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
                        COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
                        COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
                        COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
                        COUNT(case when gm.status = 15 then gm.grievance_id end) AS total_close_grievance_count,
                        COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
                        COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
                        COUNT(1) as grievances_recieved,
                        COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending
                        from grievance_master gm
                        inner join cmo_districts_master cdm on cdm.district_id  = gm.district_id  
                        AND gm.district_id NOT IN (99, 999) 
                        WHERE gm.status > 0	/*and gm.grievance_id in (
                select distinct grievance_id from grievance_lifecycle gl2 
                where gl2.grievance_status = 3 and gl2.assigned_by_position in 
                (
                select apm.position_id from admin_position_master apm
                where apm.office_id = 1
                )
                ) */ group by cdm.district_name ,cdm.district_id
        )k
        group by 
        k.district_id,
        k.district_name,
--      k.grievance_recieved_count_cmo,
        k.grievance_recieved_count_other_hod,
        k.atr_pending,
        k.total_close_grievance_count,
        k.grievance_recieved_count_cmo,
        k.grievance_recieved_count_other_hod,
       	k.atr_submitted_to_cmo;											-- total map district wise count 

       
SELECT 
        bm.block_name,
        bm.block_id,
        NULL AS municipality_id,
        NULL AS municipality_name,
        COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
        COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS close_total_grievance_count,
 		COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
  FROM 
        (SELECT DISTINCT block_id, block_name FROM cmo_blocks_master WHERE district_id = 1) bm
    LEFT JOIN 
        grievance_master gm ON gm.block_id = bm.block_id AND gm.district_id = 1
    GROUP BY 
        bm.block_name,
        bm.block_id
    UNION ALL
    SELECT 
        NULL AS block_name,
        NULL AS block_id,
        mm.municipality_id,
        mm.municipality_name,
        COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
        COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS close_total_grievance_count,
        COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
    FROM 
        (SELECT DISTINCT municipality_id, municipality_name FROM cmo_municipality_master WHERE district_id = 1) mm
    LEFT JOIN 
        grievance_master gm ON gm.municipality_id = mm.municipality_id AND gm.district_id = 1
    GROUP BY 
        mm.municipality_id,
        mm.municipality_name
    ORDER BY
        block_name, municipality_name;							-- map block/municipality wise count	
        
        
SELECT 
        bm.block_name,
        bm.block_id,
        NULL AS municipality_id,
        NULL AS municipality_name,
        COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
        COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS close_total_grievance_count,
        COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
        COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
 		COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
  FROM 
        (SELECT DISTINCT block_id, block_name FROM cmo_blocks_master WHERE district_id = 1) bm
    LEFT JOIN 
        grievance_master gm ON gm.block_id = bm.block_id AND gm.district_id = 1
    GROUP BY 
        bm.block_name,
        bm.block_id
    UNION ALL
    SELECT 
        NULL AS block_name,
        NULL AS block_id,
        mm.municipality_id,
        mm.municipality_name,
        COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
        COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS close_total_grievance_count,
        COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
        COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
        COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
    FROM 
        (SELECT DISTINCT municipality_id, municipality_name FROM cmo_municipality_master WHERE district_id = 1) mm
    LEFT JOIN 
        grievance_master gm ON gm.municipality_id = mm.municipality_id AND gm.district_id = 1
    GROUP BY 
        mm.municipality_id,
        mm.municipality_name
    ORDER BY
        block_name, municipality_name;				-- map block/municipality wise count update
        
 
SELECT 
    k.district_id as district_id,
    k.district_name as district_name,
    k.population as population,
    coalesce((k.population / k.grievances_recieved)  * 100, 0) AS grievances_lodged_district_wise,
    coalesce((k.total_close_grievance_count / k.population) * 100, 0) as disposal_district_wise,
    COALESCE(SUM(k.grievances_recieved), 0) :: INT AS total_grievance_count,
--  COALESCE(k.grievance_recieved_count_cmo, 0) :: INT AS grievance_recieved_count_cmo, 
    COALESCE(k.grievance_recieved_count_cmo, 0) :: INT AS grievance_sent, 
    COALESCE(k.atr_submitted_to_cmo, 0) :: INT AS atr_received, 
    COALESCE(k.grievance_recieved_count_other_hod, 0) :: INT AS grievance_recieved_count_other_hod,
    COALESCE(k.total_close_grievance_count, 0) :: INT AS close_grievance_count,
    COALESCE(k.atr_pending, 0) :: INT AS atr_pending
--    COALESCE(
--        CASE 
--            WHEN k.total_close_grievance_count > 0 THEN (k.total_close_grievance_count / k.population) * 100
--            ELSE 0
--        END, 0
--    ) AS disposal_district_wiseeeeee
    from (
        select  
            cdm.district_id,
            cdm.district_name,
            cdm.population,
            COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
            COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
            COUNT(case when gm.status = 3 then gm.grievance_id end) as grievance_recieved_count_cmo,
            COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
            COUNT(case when gm.status = 5 then gm.grievance_id end) as grievance_recieved_count_other_hod,
            COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
            COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
            COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
            COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
            COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
            COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
            COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
            COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
            COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
            COUNT(case when gm.status = 15 then gm.grievance_id end) AS total_close_grievance_count,
            COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
            COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
            COUNT(1) as grievances_recieved,
            COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending
            from grievance_master gm
            inner join cmo_districts_master cdm on cdm.district_id  = gm.district_id  
            AND gm.district_id NOT IN (99, 999) 
            WHERE gm.status > 0	/*and gm.grievance_id in (
    select distinct grievance_id from grievance_lifecycle gl2 
    where gl2.grievance_status = 3 and gl2.assigned_by_position in 
    (
    select apm.position_id from admin_position_master apm
    where apm.office_id = 1
    )
    ) */ group by cdm.district_name ,cdm.district_id
)k
group by 
k.district_id,
k.district_name,
k.population,
k.grievances_recieved,
-- k.grievance_recieved_count_cmo,
k.grievance_recieved_count_other_hod,
k.atr_pending,
k.total_close_grievance_count,
k.grievance_recieved_count_cmo,
k.grievance_recieved_count_other_hod,
k.atr_submitted_to_cmo;											-- total map district wise count update 



SELECT 
	    bm.block_name,
	    bm.block_id,
	    NULL AS municipality_id,
	    NULL AS municipality_name,
	    cdm.population as population,
	    coalesce((population / total_grievance_count)  * 100, 0) AS grievances_lodged_district_wise,
	    coalesce((total_close_grievance_count / population) * 100, 0) as disposal_district_wise,
	    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
    -- COALESCE(COUNT(gm.grievances_recieved), 0) AS total_grievance_count,
        COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
        COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
        COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
 		COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
  FROM 
        (SELECT DISTINCT block_id, block_name FROM cmo_blocks_master WHERE district_id = 20) bm
    LEFT JOIN 
        grievance_master gm ON gm.block_id = bm.block_id AND gm.district_id = 20
     left join
        cmo_districts_master cdm on gm.district_id = cdm.district_id and gm.district_id = 20
    GROUP BY 
        bm.block_name,
        bm.block_id
    UNION ALL
    SELECT 
        NULL AS block_name,
        NULL AS block_id,
        mm.municipality_id,
        mm.municipality_name,
        cdm.population as population,
	    coalesce((population / total_grievance_count)  * 100, 0) AS grievances_lodged_district_wise,
	    coalesce((total_close_grievance_count / population) * 100, 0) as disposal_district_wise,
--        COALESCE(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage,
        COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
        -- COALESCE(COUNT(gm.grievances_recieved), 0) AS total_grievance_count,
	    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
	    COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
	    COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
	    COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
FROM 
    (SELECT DISTINCT municipality_id, municipality_name FROM cmo_municipality_master WHERE district_id = 20) mm
LEFT JOIN 
    grievance_master gm ON gm.municipality_id = mm.municipality_id AND gm.district_id = 20
left join
        cmo_districts_master cdm on gm.district_id = cdm.district_id and gm.district_id = 20
GROUP BY 
    mm.municipality_id,
    mm.municipality_name
ORDER BY
    block_name, municipality_name  				-- map block/municipality wise count updated
        

SELECT 
    bm.block_name,
    bm.block_id,
    NULL AS municipality_id,
    NULL AS municipality_name,
    cdm.population AS population,
    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END) / NULLIF(cdm.population, 0)) * 100, 0) AS disposal_district_wise,
    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 14 THEN 1 ELSE 0 END), 0) AS atr_received,
    COALESCE(SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
    COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
FROM 
    (SELECT DISTINCT block_id, block_name FROM cmo_blocks_master WHERE district_id = 20) bm
LEFT JOIN 
    grievance_master gm ON gm.block_id = bm.block_id AND gm.district_id = 20
LEFT JOIN 
    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
GROUP BY 
    bm.block_name,
    bm.block_id,
    cdm.population
UNION ALL
SELECT 
    NULL AS block_name,
    NULL AS block_id,
    mm.municipality_id,
    mm.municipality_name,
    cdm.population AS population,
    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END) / NULLIF(cdm.population, 0)) * 100, 0) AS disposal_district_wise,
    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
    COALESCE(SUM(CASE WHEN gm.status = 14 THEN 1 ELSE 0 END), 0) AS atr_received,
    COALESCE(SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
    COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
FROM 
    (SELECT DISTINCT municipality_id, municipality_name FROM cmo_municipality_master WHERE district_id = 20) mm
LEFT JOIN 
    grievance_master gm ON gm.municipality_id = mm.municipality_id AND gm.district_id = 20
LEFT JOIN 
    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
GROUP BY 
    mm.municipality_id,
    mm.municipality_name,
    cdm.population
ORDER BY 
    block_name NULLS FIRST, 
    municipality_name NULLS FIRST;

   
   SELECT 
                    bm.block_name,
                    bm.block_id,
                    NULL AS municipality_id,
                    NULL AS municipality_name,
                    cdm.district_name as district,
                    cdm.population AS population,     
                    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
                    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END) / NULLIF(cdm.population, 0)) * 100, 0) AS disposal_district_wise,
                    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
                    -- COALESCE(COUNT(gm.grievances_recieved), 0) AS total_grievance_count,
                    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
                    COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
                    COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
             		COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
			  FROM 
                    (SELECT DISTINCT block_id, block_name FROM cmo_blocks_master WHERE district_id = 20) bm
                LEFT JOIN 
                    grievance_master gm ON gm.block_id = bm.block_id AND gm.district_id = 20
                LEFT JOIN 
                    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
                GROUP BY 
                    bm.block_name,
                    bm.block_id,
                    cdm.population,
                    cdm.district_name
                UNION ALL
                SELECT 
                    NULL AS block_name,
                    NULL AS block_id,
                    mm.municipality_id,
                    mm.municipality_name,
                    cdm.district_name as district,
                    cdm.population AS population,
                    COALESCE((COUNT(gm.grievance_no) / NULLIF(cdm.population, 0)) * 100, 0) AS grievances_lodged_district_wise,
                    COALESCE((SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END) / NULLIF(cdm.population, 0)) * 100, 0) AS disposal_district_wise,
                    COALESCE(COUNT(gm.grievance_no), 0) AS total_grievance_count,
                    -- COALESCE(COUNT(gm.grievances_recieved), 0) AS total_grievance_count,
                    COALESCE(SUM(CASE WHEN gm.status = 15 THEN 1 ELSE 0 END), 0) AS total_close_grievance_count,
                    COALESCE(SUM(case when gm.status = 14 then 1 ELSE 0 END), 0) AS atr_received,
                    COALESCE(SUM(case when gm.status = 3 THEN 1 ELSE 0 END), 0) AS grievance_sent,
                    COALESCE(SUM(CASE WHEN gm.status IN (2, 3, 4, 5,6, 7, 8, 9, 10, 11, 12, 13) THEN 1 ELSE 0 END), 0) AS atr_pending
                FROM 
                    (SELECT DISTINCT municipality_id, municipality_name FROM cmo_municipality_master WHERE district_id = 20) mm
                LEFT JOIN 
                    grievance_master gm ON gm.municipality_id = mm.municipality_id AND gm.district_id = 20
                LEFT JOIN 
                    cmo_districts_master cdm ON cdm.district_id = gm.district_id AND gm.district_id = 20
                GROUP BY 
                    mm.municipality_id,
                    mm.municipality_name,
                    cdm.population,
                    cdm.district_name
                ORDER BY
                    block_name, municipality_name;
                    
                
                   
                   
SELECT 
    cdm.district_id,
    cdm.district_name,
    COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS total_close_grievance_count
FROM
    grievance_master gm
INNER JOIN
    cmo_districts_master cdm ON cdm.district_id = gm.district_id
WHERE 
    gm.district_id NOT IN (99, 999)
GROUP BY
    cdm.district_id, cdm.district_name
HAVING 
    COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) > 0;

   
   
SELECT
    cdm.district_id,
    cdm.district_name,
    cdm.population
FROM
    cmo_districts_master cdm
WHERE 
    cdm.district_id NOT IN (99, 999)
    AND cdm.population > 0;

   
   
   SELECT 
    k.district_id AS district_id,
    k.district_name AS district_name,
    k.population AS population,
    COALESCE(k.total_close_grievance_count, 0) AS close_grievance_count,
    COALESCE((k.total_close_grievance_count / k.population) * 100) AS disposal_district_wise,
    COALESCE(k.grievances_recieved, 0) :: INT AS total_grievance_count
FROM (
    SELECT  
        cdm.district_id,
        cdm.district_name,
        cdm.population,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS total_close_grievance_count,
        COUNT(1) AS grievances_recieved
    FROM 
        grievance_master gm
    INNER JOIN 
        cmo_districts_master cdm ON cdm.district_id = gm.district_id
    WHERE 
        gm.district_id NOT IN (99, 999) 
    GROUP BY 
        cdm.district_name, cdm.district_id
) k
ORDER BY 
    k.district_name;
