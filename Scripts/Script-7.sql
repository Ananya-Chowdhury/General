WITH lastupdates AS (
                        SELECT 
                            grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on AS max_assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM 
                            grievance_lifecycle
                        WHERE 
                            grievance_lifecycle.grievance_status = 3
                    )
                    SELECT 
                        cast(SUM(k.age_below_18) as INTEGER) as age_below_18,
                        cast(SUM(k.age_18_30) as INTEGER) as age_18_30,
                        cast(SUM(k.age_31_45) as INTEGER) as age_31_45,
                        cast(SUM(k.age_46_60) as INTEGER) as age_46_60,
                        cast(SUM(k.age_above_60) as INTEGER) as age_above_60,
                        cast(SUM(k.age_below_18_percentage) as INTEGER) as age_below_18_percentage,
                        cast(SUM(k.age_18_30_percentage) as INTEGER) as age_18_30_percentage,
                        cast(SUM(k.age_31_45_percentage) as INTEGER) as age_31_45_percentage,
                        cast(SUM(k.age_46_60_percentage) as INTEGER) as age_46_60_percentage,
                        cast(SUM(k.age_above_60_percentage) as INTEGER) as age_above_60_percentage,
                        cast(SUM(k.age_below_18_male) as INTEGER) as age_below_18_male,
                        cast(SUM(k.age_18_30_male) as INTEGER) as age_18_30_male,
                        cast(SUM(k.age_31_45_male) as INTEGER) as age_31_45_male,
                        cast(SUM(k.age_46_60_male) as INTEGER) as age_46_60_male,
                        cast(SUM(k.age_above_60_male) as INTEGER) as age_above_60_male,
                        cast(SUM(k.age_below_18_female) as INTEGER) as age_below_18_female,
                        cast(SUM(k.age_below_18_percentage) as INTEGER) as age_below_18_percentage,
                        cast(SUM(k.age_18_30_female) as INTEGER) as age_18_30_female,
                        cast(SUM(k.age_31_45_female) as INTEGER) as age_31_45_female,
                        cast(SUM(k.age_46_60_female) as INTEGER) as age_46_60_female,
                        cast(SUM(k.age_above_60_female) as INTEGER) as age_above_60_female
                    FROM (
                        SELECT
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) AS age_below_18,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) AS age_18_30,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) AS age_31_45,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) AS age_46_60,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) AS age_above_60,
                            cast(COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS age_below_18_percentage,
                            cast(COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS age_18_30_percentage,
                            cast(COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS age_31_45_percentage,
                            cast(COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS age_46_60_percentage,
                            cast(COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS age_above_60_percentage,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_below_18_male,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_18_30_male,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_31_45_male,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_46_60_male,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_above_60_male,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_below_18_female,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_18_30_female,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_31_45_female,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_46_60_female,
                            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_above_60_female,
                            lu.assigned_to_office_id
                        FROM 
                            lastupdates lu
                        INNER JOIN 
                            grievance_master gm ON gm.grievance_id = lu.grievance_id 
                        LEFT JOIN 
                            cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
                        WHERE 
                            lu.rn = 1 
                            AND lu.assigned_to_office_id =  53
                            AND gm.status IS NOT NULL 
                            AND gm.grievance_source = 5
                            AND (gm.status = 15 OR gm.assigned_to_office_id = 53) 
                        GROUP BY 
                            lu.assigned_to_office_id) k;
                          