 SELECT  
                    table0.office_id,
                    COALESCE(table0.office_name, 'N/A') AS office_name,
                    COALESCE(table0.department_name, 'N/A') AS department_name,
                    COALESCE(table1.grv_frwd_assigned, 0) AS grievances_forwarded_assigned,
                    COALESCE(table2.atr_rcvd, 0) AS atr_received,
                    COALESCE(table3.bnft_prvd, 0) AS benefit_service_provided,
                    COALESCE(table3.action_taken, 0) AS action_taken,
                    COALESCE(table3.not_elgbl, 0) AS not_elgbl,
                    COALESCE(table3.total_closed, 0) AS total_disposed,
                    COALESCE(table4.beyond_svn_days, 0) AS beyond_svn_days,
                    COALESCE(table4.atr_pndg, 0) AS cumulative
                FROM (
                    SELECT 
                        gm.assigned_to_office_id AS office_id, 
                        com.office_name AS department_name,
                        aud.official_name AS office_name
                    FROM cmo_office_master com
                    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id 
                    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
                    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
                    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
                    LEFT JOIN admin_user au ON au.admin_user_id = aud.admin_user_id
                    WHERE au.status != 3
                    AND com.office_category = 2 
                    AND com.status = 1
                    AND com.office_id = 1
                --    AND gm.assigned_to_office_id = 3 
                --      AND gm.atr_submit_by_lastest_office_id = 3
                    GROUP BY gm.assigned_to_office_id, com.office_name, aud.official_name
                ) AS table0
                -- Grievances forwarded/assigned 
                LEFT OUTER JOIN (
                    SELECT 
                        COUNT(DISTINCT grievance_id) AS grv_frwd_assigned, 
                        gm.assigned_to_office_id AS office_id,
                        aud.official_name AS office_name
                    FROM cmo_office_master com
                    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
                    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
                    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
                    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
                    WHERE gm.status NOT IN (1, 2, 3, 13)
--                    and (case 
--                            when gm.status = 1 then gm.grievance_generate_date::date 
--                            else gm.updated_on::date 
--			            end) between {from_date} and {to_date}
--                    {griv_stat}
--                    {data_source}
--                    {received_at}
                    AND gm.assigned_to_office_id = 1
                    GROUP BY gm.assigned_to_office_id, aud.official_name
                ) table1 ON table1.office_id = table0.office_id AND table1.office_name = table0.office_name
                -- ATR received 
                LEFT OUTER JOIN (
                    SELECT 
                        COUNT(DISTINCT grievance_id) AS atr_rcvd,
                        gm.assigned_to_office_id AS office_id,
                        aud.official_name AS office_name
                    FROM cmo_office_master com
                    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
                    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
                    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
                    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
                    WHERE gm.status IN (11, 14, 15, 16, 17)
--                    and (case 
--                            when gm.status = 1 then gm.grievance_generate_date::date 
--                            else gm.updated_on::date 
--			            end) between {from_date} and {to_date}
--                    {griv_stat}
--                    {data_source}
--                    {received_at}
                    AND gm.assigned_to_office_id = 1
                    GROUP BY gm.assigned_to_office_id, aud.official_name
                ) table2 ON table2.office_id = table0.office_id AND table2.office_name = table0.office_name
                -- Disposal (Closed grievances)
                LEFT OUTER JOIN (
                    SELECT 
                        COUNT(DISTINCT grievance_id) AS total_closed, 
                        gm.atr_submit_by_lastest_office_id AS office_id,
                        aud.official_name AS office_name,
                        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
                        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END) AS action_taken,
                        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END) AS not_elgbl
                    FROM cmo_office_master com
                    LEFT JOIN grievance_master gm ON gm.atr_submit_by_lastest_office_id = com.office_id
                    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
                    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
                    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
                    WHERE gm.status = 15
--                    and (case 
--                            when gm.status = 1 then gm.grievance_generate_date::date 
--                            else gm.updated_on::date 
--			            end) between {from_date} and {to_date}
--                    {griv_stat}
--                    {data_source}
--                    {received_at}
                    AND gm.atr_submit_by_lastest_office_id = 1
                    GROUP BY gm.atr_submit_by_lastest_office_id, aud.official_name
                ) table3 ON table3.office_id = table0.office_id AND table3.office_name = table0.office_name
                -- Pending grievances 
                LEFT OUTER JOIN (
                    SELECT 
                        COUNT(DISTINCT grievance_id) AS atr_pndg, 
                        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days,
                        gm.assigned_to_office_id AS office_id,
                        aud.official_name AS office_name
                    FROM cmo_office_master com
                    LEFT JOIN grievance_master gm ON gm.assigned_to_office_id = com.office_id
                    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id AND apm.position_id = gm.assigned_to_position
                    LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = apm.position_id
                    LEFT JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
                    WHERE gm.status NOT IN (1, 2, 14, 15, 16, 17)
--                    and (case 
--                            when gm.status = 1 then gm.grievance_generate_date::date 
--                            else gm.updated_on::date 
--			            end) between {from_date} and {to_date}
--                    {griv_stat}
--                    {data_source}
--                    {received_at}
                    AND gm.assigned_to_office_id = 1
                    GROUP BY gm.assigned_to_office_id, aud.official_name
                ) table4 ON table4.office_id = table0.office_id AND table4.office_name = table0.office_name;