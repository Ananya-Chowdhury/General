SELECT  
        table0.grievance_cat_id,
        table0.grievance_category_desc,
        table0.office_id,
        table0.suboffice_id,
        COALESCE(table0.office_name) AS office_name,
        COALESCE(table0.suboffice_name) AS suboffice_name,
        COALESCE(table1.grv_frwd, 0) AS grievances_received,
        COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
        COALESCE(table3.action_taken, 0) AS action_taken,
        COALESCE(table4.not_elgbl, 0) AS not_elgbl,
        COALESCE(table5.total_submitted, 0) AS total_submitted,
        COALESCE(table6.atr_pndg, 0) AS atr_pending,
        COALESCE(table7.atr_review, 0) AS atr_return_for_review_from_hod 
    FROM (
        SELECT 
            DISTINCT cgcm.grievance_cat_id, 
            cgcm.grievance_category_desc, 
            com.office_id AS office_id,
            com.office_name,
            csom.suboffice_name,
            csom.suboffice_id
        FROM cmo_grievance_category_master cgcm
        left join grievance_master gm on gm.grievance_category = cgcm.grievance_cat_id
        left join cmo_office_master com ON com.office_id = gm.assigned_to_office_id
        left join cmo_sub_office_master csom ON csom.office_id = com.office_id
        LEFT JOIN admin_position_master apm ON csom.suboffice_id = apm.sub_office_id AND csom.office_id = apm.office_id 
        WHERE cgcm.status = 1
    ) table0
    -- No. of Grievances Received
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS grv_frwd
        FROM cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-12-02'
        and csog.status in (7,8,9,10,11,12,14,15,16,17)
        and csog.grievance_source = (5)
        GROUP BY csog.grievance_cat_id 
    ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id 
    -- Benefit/ Service Provided
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS bnft_prvd
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-12-02'
        and csog.status in (4,11,16,14,15,17) 
        and csog.closure_reason_id = 1
        and csog.grievance_source = (5)
        GROUP BY csog.grievance_cat_id
    ) table2 ON table2.grievance_cat_id = table0.grievance_cat_id 
    -- Action Initiated
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS action_taken
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-12-02'  
        and csog.status in (4,11,16,14,15,17)  
        and csog.closure_reason_id IN (5,9)
        and csog.grievance_source = (5)
        GROUP BY csog.grievance_cat_id
    ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
    -- Not eligible to get benefit
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS not_elgbl
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-12-02'  
        and csog.status in (4,11,16,14,15,17) 
        and csog.closure_reason_id NOT IN (1,5,9)
        and csog.grievance_source = (5)
        GROUP BY csog.grievance_cat_id
    ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
    -- Total submitted
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS total_submitted
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-12-02'  
        and csog.status in (4,11,16,14,15,17) 
        and csog.grievance_source = (5)
        GROUP BY csog.grievance_cat_id
    ) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
    -- ATR Pending
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS atr_pndg,
            glc.grievance_status
        FROM 
            cat_sub_offc_griv csog, grievance_lifecycle glc
        WHERE 
            glc.grievance_id = csog.grievance_id
            AND glc.grievance_status = 7  -- Grievances currently at status 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11  -- Grievances that have received status 11
            )
            and csog.grievance_generate_date BETWEEN '2019-01-01' and '2024-12-02'  
            and csog.grievance_source = (5)
        GROUP BY 
            csog.grievance_cat_id, glc.grievance_status
    ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id 
    -- ATR returned from HOD for review 
    LEFT JOIN (
        SELECT 
            csog.grievance_cat_id,
            COUNT(1) AS atr_review
        from cat_sub_offc_griv csog
        where grievance_generate_date between '2019-01-01' and '2024-12-02'  
        and csog.status = 12
        and csog.grievance_source = (5)
        GROUP BY csog.grievance_cat_id
    ) table7 ON table0.grievance_cat_id = table7.grievance_cat_id where table0.office_id = 3 and table0.suboffice_id = 455;
    
   -----------------------------------------------------------------------------
   ------------------------------------------------------------------------
  
   
   -----HOSO 1 Tuned (correct) -----
  SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table0.office_id,
    table0.suboffice_id,
    COALESCE(table0.office_name, 'N/A') AS office_name,
    COALESCE(table0.suboffice_name, 'N/A') AS suboffice_name,
    COALESCE(table2.grv_frwd, 0) AS grievances_received,
    COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
    COALESCE(table2.action_taken, 0) AS action_taken,
    COALESCE(table2.not_elgbl, 0) AS not_elgbl,
    COALESCE(table2.total_submitted, 0) AS total_submitted,
    COALESCE(table6.atr_pndg, 0) AS atr_pending,
    COALESCE(table2.atr_review, 0) AS atr_return_for_review_from_hod 
FROM (
    SELECT 
        DISTINCT cgcm.grievance_cat_id, 
        cgcm.grievance_category_desc, 
        com.office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id    
    FROM cmo_grievance_category_master cgcm
    LEFT JOIN grievance_master gm ON gm.grievance_category = cgcm.grievance_cat_id
    LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id
    LEFT JOIN cmo_sub_office_master csom ON csom.office_id = com.office_id 
    left join admin_position_master apm on apm.sub_office_id = csom.suboffice_id and csom.office_id = apm.office_id /*AND gm.assigned_to_office_id = apm.office_id*/
    left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
    left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
    left join admin_user au on au.admin_user_id = aud.admin_user_id
    WHERE cgcm.status = 1
    and gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-02'
--    and gm.grievance_source = 5
) table0
-- Number of Grievances Received & Benefit/Service Provided & Action Initiated & Not Eligible for Benefit & Total Submitted & ATR Returned for Review
LEFT JOIN (
    SELECT 
        gm.grievance_category AS grievance_cat_id,
        count(distinct case when gm.status IN (7,8,9,10,11,12,14,15,16,17) THEN gm.grievance_id END) AS grv_frwd,
        count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id = 1 THEN gm.grievance_id END) AS bnft_prvd,
        count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id IN (5,9) THEN gm.grievance_id END) AS action_taken,
        count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id NOT IN (1,5,9) THEN gm.grievance_id END) AS not_elgbl,
        count(distinct case when gm.status IN (4,11,16,14,15,17) THEN gm.grievance_id END) AS total_submitted,
        count(case when gm.status = 12 THEN gm.grievance_id END) AS atr_review
    FROM grievance_master gm
    GROUP BY gm.grievance_category
) table2 
ON table2.grievance_cat_id = table0.grievance_cat_id 
-- ATR Pending
LEFT JOIN (
    SELECT 
        gm.grievance_category AS grievance_cat_id,
        count(distinct gm.grievance_id) AS atr_pndg
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
) table6 
ON table0.grievance_cat_id = table6.grievance_cat_id 
WHERE table0.office_id = 3 
  AND table0.suboffice_id = 499;
 
   

 ------- HOSO 1 Tuned 1 ---------
 with BaseData as (
    SELECT DISTINCT 
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
    WHERE cgcm.status = 1
      AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-02'
),
AggregatedData as (
    SELECT 
        gm.grievance_category AS grievance_cat_id,
        COUNT(DISTINCT CASE WHEN gm.status IN (7,8,9,10,11,12,14,15,16,17) THEN gm.grievance_id END) AS grievances_received,
        COUNT(DISTINCT CASE WHEN gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id = 1 THEN gm.grievance_id END) AS benefit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id IN (5,9) THEN gm.grievance_id END) AS action_taken,
        COUNT(DISTINCT CASE WHEN gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id NOT IN (1,5,9) THEN gm.grievance_id END) AS not_eligible,
        COUNT(DISTINCT CASE WHEN gm.status IN (4,11,16,14,15,17) THEN gm.grievance_id END) AS total_submitted,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id END) AS atr_return_for_review
    FROM grievance_master gm
    GROUP BY gm.grievance_category
),
PendingATR AS (
    SELECT 
        gm.grievance_category AS grievance_cat_id,
        COUNT(DISTINCT gm.grievance_id) AS atr_pending
    FROM grievance_master gm
    LEFT JOIN grievance_lifecycle glc ON glc.grievance_id = gm.grievance_id
    WHERE glc.grievance_status = 7 
      AND NOT EXISTS (
          SELECT 1
          FROM grievance_lifecycle glc2
          WHERE glc2.grievance_id = glc.grievance_id
            AND glc2.grievance_status = 11
      )
    GROUP BY gm.grievance_category
)
SELECT  
    b.grievance_cat_id,
    b.grievance_category_desc,
    b.office_id,
    b.suboffice_id,
    COALESCE(b.office_name, 'N/A') AS office_name,
    COALESCE(b.suboffice_name, 'N/A') AS suboffice_name,
    COALESCE(a.grievances_received, 0) AS grievances_received,
    COALESCE(a.benefit_service_provided, 0) AS benefit_service_provided,
    COALESCE(a.action_taken, 0) AS action_taken,
    COALESCE(a.not_eligible, 0) AS not_eligible,
    COALESCE(a.total_submitted, 0) AS total_submitted,
    COALESCE(p.atr_pending, 0) AS atr_pending,
    COALESCE(a.atr_return_for_review, 0) AS atr_return_for_review_from_hod
FROM BaseData b
LEFT JOIN AggregatedData a ON b.grievance_cat_id = a.grievance_cat_id
LEFT JOIN PendingATR p ON b.grievance_cat_id = p.grievance_cat_id
WHERE b.office_id = 3 
  AND b.suboffice_id = 499;

 
 
 ------ HoSO 3 Tuned (correct)-----------
 SELECT  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    table0.office_id,
    table0.suboffice_id,
    table0.admin_user_id, 
    table0.office_name,
    COALESCE(table0.official_name, 'N/A') AS office_name,
    COALESCE(table0.suboffice_name, 'N/A') AS suboffice_name,
    COALESCE(table2.grv_frwd, 0) AS grievances_received,
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
    and gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-02'
--    and gm.grievance_source = 5
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
  AND table0.suboffice_id = 499 and table0.grievance_cat_id = 18;
 
 
 ------ HOSO 2 part 2 Tuned (Correct)--------
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
    COALESCE(table3.atr_pndg, 0) AS cumulative_pendency,
    COALESCE(table2.atr_review, 0) AS atr_return_for_review
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
    and gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-02'
--    and gm.grievance_source = 5
) table0
-- Number of Grievances Received & Benefit/Service Provided & Action Initiated & Not Eligible for Benefit & Total Submitted & ATR Returned for Review
LEFT JOIN (
    SELECT 
        gm.grievance_category AS grievance_cat_id,
        count(distinct case when gm.status IN (8,9,11,12,14,15,16,17,4) THEN gm.grievance_id END) AS grv_frwd,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) AND gm.closure_reason_id = 1 THEN gm.grievance_id END) AS bnft_prvd,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) AND gm.closure_reason_id IN (5,9) THEN gm.grievance_id END) AS action_taken,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) AND gm.closure_reason_id NOT IN (1,5,9) THEN gm.grievance_id END) AS not_elgbl,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) THEN gm.grievance_id END) AS total_submitted,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id END) AS atr_review
    FROM grievance_master gm
    GROUP BY gm.grievance_category
) table2 
ON table2.grievance_cat_id = table0.grievance_cat_id 
-- ATR Pending
LEFT JOIN (
    SELECT 
        gm.grievance_category AS grievance_cat_id,
        count(distinct gm.grievance_id) AS atr_pndg,
        count(distinct CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM grievance_master gm
    left JOIN grievance_lifecycle glc ON glc.grievance_id = gm.grievance_id
    WHERE glc.grievance_status = 8 
      AND NOT EXISTS (
          SELECT 1
          FROM grievance_lifecycle glc2
          WHERE glc2.grievance_id = glc.grievance_id
            AND glc2.grievance_status = 9
      )
    GROUP BY gm.grievance_category 
) table3 
ON table0.grievance_cat_id = table3.grievance_cat_id 
WHERE table0.office_id = 3 
  AND table0.suboffice_id = 499 and table0.admin_user_id = 2757;
 
 
 
 ---- HOSO 3 part 1 Tuned --------
 SELECT  
 	table0.position_id,
 	table0.assigned_to_office_id,
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
    COALESCE(table3.atr_pndg, 0) AS cumulative_pendency,
    COALESCE(table2.atr_review, 0) AS atr_return_for_review
FROM (
    SELECT 
        DISTINCT aud.admin_user_id, 
        aud.official_name,
        apm.position_id,
        gm.assigned_to_office_id,
        com.office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id 
    from grievance_master gm 
    LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id  
    LEFT JOIN cmo_sub_office_master csom ON csom.office_id = com.office_id 
    left join admin_position_master apm on apm.sub_office_id = csom.suboffice_id and csom.office_id = apm.office_id
    left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id and gm.assigned_to_position = apm.position_id
    left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
    left join admin_user au on au.admin_user_id = aud.admin_user_id
    and gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-03'
--    and gm.grievance_source = 5
) table0
-- Number of Grievances Received & Benefit/Service Provided & Action Initiated & Not Eligible for Benefit & Total Submitted & ATR Returned for Review
LEFT JOIN (
    SELECT 
        gm.assigned_to_office_id,
        count(distinct case when gm.status IN (8,9,11,12,14,15,16,17,4) THEN gm.grievance_id END) AS grv_frwd,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) AND gm.closure_reason_id = 1 THEN gm.grievance_id END) AS bnft_prvd,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) AND gm.closure_reason_id IN (5,9) THEN gm.grievance_id END) AS action_taken,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) AND gm.closure_reason_id NOT IN (1,5,9) THEN gm.grievance_id END) AS not_elgbl,
        count(distinct case when gm.status IN (4,9,11,12,16,14,15,17) THEN gm.grievance_id END) AS total_submitted,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id END) AS atr_review
    from grievance_master gm 
    GROUP BY gm.assigned_to_office_id
) table2 
ON table2.assigned_to_office_id = table0.assigned_to_office_id 
-- ATR Pending
LEFT JOIN (
    SELECT 
        gm.assigned_to_office_id,
        count(distinct gm.grievance_id) AS atr_pndg,
        count(distinct CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    from grievance_master gm 
    left JOIN grievance_lifecycle glc ON glc.grievance_id = gm.grievance_id
    WHERE glc.grievance_status = 8 
      AND NOT EXISTS (
          SELECT 1
          FROM grievance_lifecycle glc2
          WHERE glc2.grievance_id = glc.grievance_id
            AND glc2.grievance_status = 9
      )
    GROUP BY gm.assigned_to_office_id 
) table3 
ON table0.assigned_to_office_id = table3.assigned_to_office_id 
WHERE table0.office_id = 3
  AND table0.suboffice_id = 479 and table0.position_id in (487,488) and table0.admin_user_id in (487,488);
 
 
 
 
 
  SELECT 
        count(gm.grievance_id) as grv_frwd,
        gm.assigned_to_position,
        aud.official_name,
        gm.assigned_to_office_id,
        com.office_id,
        com.office_name,
        csom.suboffice_name,
        csom.suboffice_id 
    from grievance_master gm 
    LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id
    LEFT JOIN cmo_sub_office_master csom ON csom.office_id = com.office_id 
    left join admin_position_master apm on apm.sub_office_id = csom.suboffice_id and csom.office_id = apm.office_id
    left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
    left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
    left join admin_user au on au.admin_user_id = aud.admin_user_id
    and gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-12-02'
 where gm.status IN (8,9,11,12,14,15,16,17,4)
 and gm.assigned_to_office_id = 3
 and csom.suboffice_id in (select sub_office_id from cmo_sub_office_master csom2 where csom2.office_id = 3)
group by 
	gm.assigned_to_position,
	aud.official_name,
	gm.assigned_to_office_id,
	com.office_id,
    com.office_name,
    csom.suboffice_name,
    csom.suboffice_id;
	
 
 select
 	count(1) as grv_frwd,
 	gm.assigned_to_position as assigned_to_position
 from grievance_master gm
 where gm.status in (8,9,11,12,14,15,16,17,4)
 	and gm.assigned_to_office_id = 3
 group by gm.assigned_to_position;
 
 
 
 
 
 
 
 
   
   SELECT  
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.admin_user_id,
                table0.office_id,
                table0.suboffice_id,
                COALESCE(table0.official_name) AS office_name,
                COALESCE(table0.suboffice_name) AS suboffice_name,
                COALESCE(SUM(table1.grv_assigned), 0) AS grievances_assigned,
                COALESCE(SUM(table2.bnft_prvd), 0) AS benefit_service_provided,
                COALESCE(SUM(table3.action_taken), 0) AS action_taken,
                COALESCE(SUM(table4.not_elgbl), 0) AS not_elgbl,
                COALESCE(SUM(table5.total_submitted), 0) AS total_submitted,
                COALESCE(SUM(table6.beyond_svn_days), 0) AS beyond_svn_days,
                COALESCE(SUM(table6.atr_pndg), 0) AS cumulative_pendency
            FROM (
                SELECT 
                    cgcm.grievance_cat_id, 
                    cgcm.grievance_category_desc,
                    aud.admin_user_id, 
                    aud.official_name, 
                    com.office_id AS office_id,
                    gm.assigned_to_office_id,
                    com.office_name,
                    csom.suboffice_name,
                    csom.suboffice_id
                FROM admin_user au 
                LEFT JOIN admin_user_details aud ON aud.admin_user_id = au.admin_user_id 
                LEFT JOIN admin_user_position_mapping aupm ON aupm.admin_user_id = aud.admin_user_id 
                LEFT JOIN admin_position_master apm ON aupm.position_id = apm.position_id   
                LEFT JOIN cmo_sub_office_master csom ON csom.suboffice_id = apm.sub_office_id
                LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = apm.office_id 
                LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id AND csom.office_id = com.office_id
                left join cmo_grievance_category_master cgcm on gm.grievance_category = cgcm.grievance_cat_id
                WHERE gm.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
            ) table0
            LEFT JOIN (
                SELECT 
                    aud.admin_user_id,
                    COUNT(1) AS grv_assigned
                FROM admin_user au 
                LEFT JOIN admin_user_details aud ON aud.admin_user_id = au.admin_user_id 
                LEFT JOIN admin_user_position_mapping aupm ON aupm.admin_user_id = aud.admin_user_id 
                LEFT JOIN admin_position_master apm ON aupm.position_id = apm.position_id   
                LEFT JOIN cmo_sub_office_master csom ON csom.suboffice_id = apm.sub_office_id
                LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = apm.office_id 
                LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id AND csom.office_id = com.office_id
                left join cmo_grievance_category_master cgcm on gm.grievance_category = cgcm.grievance_cat_id
                AND gm.status IN (8,9,11,12,14,15,16,17,4)
                GROUP BY aud.admin_user_id 
            ) table1 ON table0.admin_user_id = table1.admin_user_id 
            LEFT JOIN (
                SELECT 
                    csog.admin_user_id,
                    COUNT(1) AS bnft_prvd
                FROM cat_sub_offc_griv csog
                WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'
                AND csog.status IN (4,9,11,12,16,14,15,17) 
                AND csog.closure_reason_id = 1
                
                GROUP BY csog.admin_user_id
            ) table2 ON table2.admin_user_id = table0.admin_user_id 
            LEFT JOIN (
                SELECT 
                    csog.admin_user_id,
                    COUNT(1) AS action_taken
                FROM cat_sub_offc_griv csog
                WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
                AND csog.status IN (4,9,11,12,16,14,15,17) 
                AND csog.closure_reason_id IN (5,9)
                
                GROUP BY csog.admin_user_id
            ) table3 ON table0.admin_user_id = table3.admin_user_id
            LEFT JOIN (
                SELECT 
                    csog.admin_user_id,
                    COUNT(1) AS not_elgbl
                FROM cat_sub_offc_griv csog
                WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
                AND csog.status IN (4,9,11,12,16,14,15,17) 
                AND csog.closure_reason_id NOT IN (1,5,9)
                
                GROUP BY csog.admin_user_id
            ) table4 ON table0.admin_user_id = table4.admin_user_id
            LEFT JOIN (
                SELECT 
                    csog.admin_user_id,
                    COUNT(1) AS total_submitted
                FROM cat_sub_offc_griv csog
                WHERE grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
                AND csog.status IN (4,11,16,14,15,17) 
                
                GROUP BY csog.admin_user_id
            ) table5 ON table0.admin_user_id = table5.admin_user_id
            LEFT JOIN (
                SELECT 
                    csog.admin_user_id,
                    COUNT(1) AS atr_pndg,
                    SUM(CASE WHEN CURRENT_DATE - csog.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
                FROM cat_sub_offc_griv csog
                JOIN grievance_lifecycle glc ON glc.grievance_id = csog.grievance_id
                WHERE glc.grievance_status = 8
                AND NOT EXISTS (
                    SELECT 1
                    FROM grievance_lifecycle glc2
                    WHERE glc2.grievance_id = glc.grievance_id
                        AND glc2.grievance_status = 9
                )
                AND csog.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-11'  
                
                GROUP BY csog.admin_user_id
            ) table6 ON table0.admin_user_id = table6.admin_user_id 
            WHERE table0.office_id = 3 AND table0.suboffice_id = 4 and table0.grievance_cat_id in (10)
            GROUP BY 
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.admin_user_id, 
                table0.office_id, 
                table0.suboffice_id, 
                table0.official_name, 
                table0.suboffice_name;
 
 
 

   

  
           
           
           
  -------- Pradipta da ----------------
select gm.grievance_id, cad.griev_id_no, cad.griev_trans_no, cad.srl_no, cad.doc_type, 
cad.attach_file_name, cad.generated_file_name, cad.official_code,
cad.opr_date, cad.user_id, cad.attach_id
from cmro_attach_doc_2 cad 
inner join grievance_master gm on gm.grievance_no = cad.griev_id_no and gm.doc_updated = 'N'
where cad.griev_trans_no = 1 and cad.doc_type is null and gm.status <> 15;
--order by gm.grievance_id desc;


select gm.grievance_id, cad.griev_id_no, cad.griev_trans_no, cad.srl_no, cad.doc_type, 
cad.attach_file_name, cad.generated_file_name, cad.official_code,
cad.opr_date, cad.user_id, cad.attach_id 
from cmro_attach_doc_2 cad 
inner join grievance_master gm on gm.grievance_no = cad.griev_id_no
 inner join atr_doc_upload adu on adu.grievance_id = gm.grievance_id and adu.atr_doc_upload = 'N'
where cad.griev_trans_no > 1 and cad.doc_type ='Action Taken';
--and gm.status <> 15;






SELECT  
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.office_id,
                table0.suboffice_id,
                COALESCE(table0.office_name, 'N/A') AS office_name,
                COALESCE(table0.suboffice_name, 'N/A') AS suboffice_name,
                COALESCE(table2.grv_frwd, 0) AS grievances_received,
                COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
                COALESCE(table2.action_taken, 0) AS action_taken,
                COALESCE(table2.not_elgbl, 0) AS not_elgbl,
                COALESCE(table2.total_submitted, 0) AS total_submitted,
                COALESCE(table6.atr_pndg, 0) AS atr_pending,
                COALESCE(table2.atr_review, 0) AS atr_return_for_review_from_hod 
            FROM (
                SELECT 
                    DISTINCT cgcm.grievance_cat_id, 
                    cgcm.grievance_category_desc, 
                    com.office_id,
                    com.office_name,
                    csom.suboffice_name,
                    csom.suboffice_id    
                FROM cmo_grievance_category_master cgcm
                LEFT JOIN grievance_master gm ON gm.grievance_category = cgcm.grievance_cat_id
                LEFT JOIN cmo_office_master com ON com.office_id = gm.assigned_to_office_id
                LEFT JOIN cmo_sub_office_master csom ON csom.office_id = com.office_id 
                left join admin_position_master apm on apm.sub_office_id = csom.suboffice_id and csom.office_id = apm.office_id /*AND gm.assigned_to_office_id = apm.office_id*/
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
                left join admin_user au on au.admin_user_id = aud.admin_user_id
                WHERE cgcm.status = 1
                and gm.grievance_generate_date BETWEEN date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP
                and gm.grievance_source = (5)
            ) table0
            -- Number of Grievances Received & Benefit/Service Provided & Action Initiated & Not Eligible for Benefit & Total Submitted & ATR Returned for Review
            LEFT JOIN (
                SELECT 
                    gm.grievance_category AS grievance_cat_id,
                    count(distinct case when gm.status IN (7,8,9,10,11,12,14,15,16,17) THEN gm.grievance_id END) AS grv_frwd,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id = 1 THEN gm.grievance_id END) AS bnft_prvd,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id IN (5,9) THEN gm.grievance_id END) AS action_taken,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) AND gm.closure_reason_id NOT IN (1,5,9) THEN gm.grievance_id END) AS not_elgbl,
                    count(distinct case when gm.status IN (4,11,16,14,15,17) THEN gm.grievance_id END) AS total_submitted,
                    count(case when gm.status = 12 THEN gm.grievance_id END) AS atr_review
                FROM grievance_master gm
                GROUP BY gm.grievance_category
            ) table2 
            ON table2.grievance_cat_id = table0.grievance_cat_id 
            -- ATR Pending
            LEFT JOIN (
                SELECT 
                    gm.grievance_category AS grievance_cat_id,
                    count(distinct gm.grievance_id) AS atr_pndg
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
            ) table6 
            ON table0.grievance_cat_id = table6.grievance_cat_id 
            where table0.office_id = (2) 
            and table0.suboffice_id = (455);
            \
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            WITH lastupdates AS (
                        SELECT grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_office_id,
                            grievance_lifecycle.assigned_by_position,
                            grievance_lifecycle.assigned_to_position,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id 
                            ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM grievance_lifecycle
                        WHERE grievance_lifecycle.grievance_status in (3,5)
                    )
                        select distinct
                        md.grievance_id, 
                            case 
                                when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                                when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                                else null
                            end as received_from_other_hod_flag,
                            lu.grievance_status as last_grievance_status,
                            lu.assigned_on as last_assigned_on,
                            lu.assigned_to_office_id as last_assigned_to_office_id,
                            lu.assigned_by_office_id as last_assigned_by_office_id,
                            lu.assigned_by_position as last_assigned_by_position,
                            lu.assigned_to_position as last_assigned_to_position,
                            md.grievance_no ,
                            md.grievance_description,
                            md.grievance_source ,
                            null as grievance_source_name,
                            md.applicant_name ,
                            md.pri_cont_no,
                            md.grievance_generate_date ,
                            md.grievance_category,
                            cgcm.grievance_category_desc,
                            md.assigned_to_office_id,
                            com.office_name,
                            md.district_id,
                            cdm2.district_name ,
                            md.block_id ,
                            cbm.block_name ,
                            md.municipality_id ,
                            cmm.municipality_name,
                            case 
                                when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
                            when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
                            else null
                        end as block_or_municipalty_name,
                        md.gp_id,
                        cgpm.gp_name,
                        md.ward_id,
                        cwm.ward_name,
                        case 
                            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
                            ELSE NULL
                        end as gp_or_ward_name,
                        md.atn_id,
                        coalesce(catnm.atn_desc,'N/A') as atn_desc,
                        coalesce(md.action_taken_note,'N/A') as action_taken_note,
                        coalesce(md.current_atr_date,null) as current_atr_date,
                        md.assigned_to_position,
                        case 
                            when md.assigned_to_office_id is null then 'N/A'
                            when md.assigned_to_office_id = 5 then 'Pending At CMO'
                            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                        end as assigned_to_office_name,
                        md.assigned_to_id,
    --                    case 
    --                        when md.assigned_to_position is null then 'N/A'
    --                        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
    --                    end as assigned_to_name,
                        case
                            when md.status = 1 then md.grievance_generate_date
                            else md.updated_on -- + interval '5 hour 30 Minutes' 
                        end as updated_on,
                        md.status,
                        cdlm.domain_value as status_name,
                        cdlm.domain_abbr as grievance_status_code,
                        md.emergency_flag,
                        md.police_station_id,
                        cpsm.ps_name  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
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
                       where lu.assigned_to_office_id = 2  
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
                       
   --- filter ---
 select * from atn_closure_reason_mapping acrm ;              
select * from cmo_closure_reason_master ccrm ; -- 5=9,9=12,2=10
select * from grievance_master gm where gm.status = 15;
select * from grievance_master gm limit 1 ;
select * from cmo_domain_lookup_master cdlm ;












WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
         Select Count(1) 
                    from master_district_block_grv md
                    -- from (select * from master_district_block_grv where md.grievance_id > 0  and 14,15) md
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id -- and aupm.status = 1
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id left join grievance_locking_history glh on md.grievance_id = glh.grievance_id and glh.lock_status = 1
                                left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true  
                                left join admin_user_details aud on aud.admin_user_id = glh.locked_by_userid
                                left join admin_position_master apm3 on apm3.position_id = glh.locked_by_position
                                left join cmo_designation_master cdm2 on cdm2.designation_id = apm3.designation_id
                                left join cmo_office_master com3 on com3.office_id = apm3.office_id 
                                left join admin_user_role_master aurm2 on aurm2.role_master_id = apm3.role_master_id
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35 
                                where ( not exists (select 1 from under_processing_ids where under_processing_ids.grievance_id = md.grievance_id) and 
                              (md.assigned_by_office_id = 35 or md.assigned_to_office_id = 35) and md.status in (14,15) and md.atn_id in (10) )
                       
