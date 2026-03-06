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
                WHERE cgcm.status = 1
            ) table0
            -- No. of Grievances Received
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS grv_frwd
                FROM cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'
                and csog.status in (7,8,9,10,11,12,14,15,16,17)
--                {data_source}
                GROUP BY csog.grievance_cat_id 
            ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id 
            -- Benefit/ Service Provided
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS bnft_prvd
                from cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'
                and csog.status in (4,11,16,14,15,17) 
                and csog.closure_reason_id = 1
--                {data_source}
                GROUP BY csog.grievance_cat_id
            ) table2 ON table2.grievance_cat_id = table0.grievance_cat_id 
            -- Action Initiated
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS action_taken
                from cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'  
                and csog.status in (4,11,16,14,15,17)  
                and csog.closure_reason_id IN (5,9)
--                {data_source}
                GROUP BY csog.grievance_cat_id
            ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
            -- Not eligible to get benefit
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS not_elgbl
                from cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'  
                and csog.status in (4,11,16,14,15,17) 
                and csog.closure_reason_id NOT IN (1,5,9)
--                {data_source}
                GROUP BY csog.grievance_cat_id
            ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
            -- Total submitted
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS total_submitted
                from cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'  
                and csog.status in (4,11,16,14,15,17) 
--                {data_source}
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
                    AND glc.grievance_status = 7  -- Grievances currently at status 8
                    AND NOT EXISTS (
                        SELECT 1
                        FROM grievance_lifecycle glc2
                        WHERE 
                            glc2.grievance_id = glc.grievance_id
                            AND glc2.grievance_status = 11  -- Grievances that have received status 9
                    )
                    and csog.grievance_generate_date BETWEEN '2022-01-01' and '2024-11-25'  
            --        {data_source}
                GROUP BY 
                    csog.grievance_cat_id, glc.grievance_status
            ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id 
            -- ATR returned from HOD for review 
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS atr_review
                from cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'  
                and csog.status = 12
--                {data_source}
                GROUP BY csog.grievance_cat_id
            ) table7 ON table0.grievance_cat_id = table7.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (4);
            
     
           
        SELECT  
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.office_id,
                table0.suboffice_id,
                COALESCE(table0.office_name) AS office_name,
                COALESCE(table0.suboffice_name) AS suboffice_name,
                COALESCE(table1.grv_frwd, 0) AS grievances_received,
--                COALESCE(table2.bnft_prvd, 0) AS benefit_service_provided,
--                COALESCE(table3.action_taken, 0) AS action_taken,
--                COALESCE(table4.not_elgbl, 0) AS not_elgbl,
                COALESCE(table5.total_submitted, 0) AS total_submitted
--                COALESCE(table6.atr_pndg, 0) AS atr_pending,
--                COALESCE(table7.atr_review, 0) AS atr_return_for_review_from_hod 
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
                WHERE cgcm.status = 1
            ) table0
            -- No. of Grievances Received
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS grv_frwd
                FROM cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'
                and csog.status in (7,8,9,10,11,12,14,15,16,17)
--                {data_source}
                GROUP BY csog.grievance_cat_id 
            ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id   
           -- Total submitted
            LEFT JOIN (
                SELECT 
                    csog.grievance_cat_id,
                    COUNT(1) AS total_submitted
                from cat_sub_offc_griv csog
                where grievance_generate_date between '2022-01-01' and '2024-11-25'  
                and csog.status in (4,11,16,14,15,17) 
--                {data_source}
                GROUP BY csog.grievance_cat_id
            ) table5 ON table0.grievance_cat_id = table5.grievance_cat_id where table0.office_id = (3) and table0.suboffice_id = (4);
            
     
  with 
    cross_join as
        (select 
            ccrm.closure_reason_id,
            ccrm.closure_reason_name,
            cgcm.grievance_cat_id,
            cgcm.grievance_category_desc
        from cmo_closure_reason_master ccrm, cmo_grievance_category_master cgcm)
select 
    cj.grievance_cat_id as grievance_category,
    cj.grievance_category_desc,
    cj.closure_reason_id,
    cj.closure_reason_name,
    count(gm.grievance_id) as total_count
from cross_join cj
left join grievance_master gm on gm.grievance_category = cj.grievance_cat_id and cj.closure_reason_id = gm.closure_reason_id and gm.status = 15 
and date(grievance_generate_date) between '2019-01-01' and '2024-12-02'
group by cj.grievance_cat_id,cj.grievance_category_desc,cj.closure_reason_id,cj.closure_reason_name
order by cj.grievance_category_desc,cj.closure_reason_name;  







