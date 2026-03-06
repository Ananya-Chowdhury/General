--OFFICIAL_USER_QUERY = """
SELECT 
    COUNT(DISTINCT CASE WHEN urm.role_master_id IN (1,2,3,9) THEN ut.user_id END) AS cmo_count,
    COUNT(DISTINCT CASE WHEN urm.role_master_id IN (4,5,6) THEN ut.user_id END) AS hod_count,
    COUNT(DISTINCT CASE WHEN urm.role_master_id = 7 THEN ut.user_id END) AS hoso_count,
    COUNT(DISTINCT CASE WHEN urm.role_master_id = 8 THEN ut.user_id END) AS so_count
FROM user_token ut
JOIN admin_user_position_mapping upm ON ut.user_id = upm.admin_user_id
JOIN admin_position_master pm ON upm.position_id = pm.position_id
JOIN admin_user_role_master urm ON pm.role_master_id = urm.role_master_id
WHERE 
    ut.expiry_time > NOW() 
    AND upm.status = 1;
--"""

--CITIZEN_QUERY = """
SELECT COUNT(token) 
FROM user_token 
WHERE updated_on > (NOW() - interval '15 minutes') 
  AND user_type = 3;
--"""


select * from user_token 
where user_token.updated_on between (now() - interval '1 minutes') and now() or user_token.expiry_time > now() and user_type = 1;

-- =============================================================================================================================================
-- =============================================================================================================================================
-- =============================================================================================================================================

---------------------------
select * from user_token 
where user_token.user_type = 1 and user_token.updated_on::date = '2025-09-08' 
and (user_token.updated_on between '2025-09-08 11:00:00' and '2025-09-08 12:59:00'
	  or user_token.expiry_time > '2025-09-08 11:00:00') ;

----------------------------
select * from user_token 
where user_token.updated_on between '2025-09-08 11:00:00' and '2025-09-08 12:59:00'
	  or user_token.expiry_time > '2025-09-08 11:00:00' ;


------------------------------------

SELECT 
--    aurm.role_master_name AS role_name,
	CASE 
        WHEN aurm.role_master_id IN (1,2,3,9) THEN 'CMO'
        WHEN aurm.role_master_id IN (4,5,6)   THEN 'HOD'
        WHEN aurm.role_master_id = 7          THEN 'HOSO'
        WHEN aurm.role_master_id = 8          THEN 'SO'
    END AS role_group,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 00:00:00' AND '2025-09-08 00:59:59' OR ut.expiry_time > '2025-09-08 00:00:00') THEN 1 END) AS time_at_00,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 01:00:00' AND '2025-09-08 01:59:59' OR ut.expiry_time > '2025-09-08 01:00:00') THEN 1 END) AS time_at_01,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 02:00:00' AND '2025-09-08 02:59:59' OR ut.expiry_time > '2025-09-08 02:00:00') THEN 1 END) AS time_at_02,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 03:00:00' AND '2025-09-08 03:59:59' OR ut.expiry_time > '2025-09-08 03:00:00') THEN 1 END) AS time_at_03,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 04:00:00' AND '2025-09-08 04:59:59' OR ut.expiry_time > '2025-09-08 04:00:00') THEN 1 END) AS time_at_04,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 05:00:00' AND '2025-09-08 05:59:59' OR ut.expiry_time > '2025-09-08 05:00:00') THEN 1 END) AS time_at_05,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 06:00:00' AND '2025-09-08 06:59:59' OR ut.expiry_time > '2025-09-08 06:00:00') THEN 1 END) AS time_at_06,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 07:00:00' AND '2025-09-08 07:59:59' OR ut.expiry_time > '2025-09-08 07:00:00') THEN 1 END) AS time_at_07,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 08:00:00' AND '2025-09-08 08:59:59' OR ut.expiry_time > '2025-09-08 08:00:00') THEN 1 END) AS time_at_08,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 09:00:00' AND '2025-09-08 09:59:59' OR ut.expiry_time > '2025-09-08 09:00:00') THEN 1 END) AS time_at_09,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 10:00:00' AND '2025-09-08 10:59:59' OR ut.expiry_time > '2025-09-08 10:00:00') THEN 1 END) AS time_at_10,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 11:00:00' AND '2025-09-08 11:59:59' OR ut.expiry_time > '2025-09-08 11:00:00') THEN 1 END) AS time_at_11,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 12:00:00' AND '2025-09-08 12:59:59' OR ut.expiry_time > '2025-09-08 12:00:00') THEN 1 END) AS time_at_12,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 13:00:00' AND '2025-09-08 13:59:59' OR ut.expiry_time > '2025-09-08 13:00:00') THEN 1 END) AS time_at_13,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 14:00:00' AND '2025-09-08 14:59:59' OR ut.expiry_time > '2025-09-08 14:00:00') THEN 1 END) AS time_at_14,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 15:00:00' AND '2025-09-08 15:59:59' OR ut.expiry_time > '2025-09-08 15:00:00') THEN 1 END) AS time_at_15,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 16:00:00' AND '2025-09-08 16:59:59' OR ut.expiry_time > '2025-09-08 16:00:00') THEN 1 END) AS time_at_16,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 17:00:00' AND '2025-09-08 17:59:59' OR ut.expiry_time > '2025-09-08 17:00:00') THEN 1 END) AS time_at_17,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 18:00:00' AND '2025-09-08 18:59:59' OR ut.expiry_time > '2025-09-08 18:00:00') THEN 1 END) AS time_at_18,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 19:00:00' AND '2025-09-08 19:59:59' OR ut.expiry_time > '2025-09-08 19:00:00') THEN 1 END) AS time_at_19,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 20:00:00' AND '2025-09-08 20:59:59' OR ut.expiry_time > '2025-09-08 20:00:00') THEN 1 END) AS time_at_20,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 21:00:00' AND '2025-09-08 21:59:59' OR ut.expiry_time > '2025-09-08 21:00:00') THEN 1 END) AS time_at_21,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 22:00:00' AND '2025-09-08 22:59:59' OR ut.expiry_time > '2025-09-08 22:00:00') THEN 1 END) AS time_at_22,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-08 23:00:00' AND '2025-09-08 23:59:59' OR ut.expiry_time > '2025-09-08 23:00:00') THEN 1 END) AS time_at_23
FROM user_token ut
INNER JOIN admin_position_master apm 
    ON ut.user_id = apm.position_id
INNER JOIN admin_user_role_master aurm 
    ON aurm.role_master_id = apm.role_master_id
   AND aurm.role_master_id IN (1,2,3,4,5,6,7,8,9)
WHERE ut.user_type = 1
  AND ut.updated_on::date = '2025-09-08'
--GROUP BY aurm.role_master_name, aurm.role_master_id
GROUP BY role_group
ORDER BY role_group ASC;




----- PERFECT QUERY WITH TOTAL FOR DEPARTMENTAL ----
WITH role_data AS (
    SELECT 
        CASE 
            WHEN aurm.role_master_id IN (1,2,3,9) THEN 'CMO'
            WHEN aurm.role_master_id IN (4,5,6)   THEN 'HOD'
            WHEN aurm.role_master_id = 7          THEN 'HOSO'
            WHEN aurm.role_master_id = 8          THEN 'SO'
        END AS role_group,
 	COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 00:00:00' AND '2025-09-09 00:59:59' OR ut.expiry_time BETWEEN '2025-09-09 00:00:00' AND '2025-09-09 00:59:59') THEN 1 END) AS time_at_00,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 01:00:00' AND '2025-09-09 01:59:59' OR ut.expiry_time BETWEEN '2025-09-09 01:00:00' AND '2025-09-09 01:59:59') THEN 1 END) AS time_at_01,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 02:00:00' AND '2025-09-09 02:59:59' OR ut.expiry_time BETWEEN '2025-09-09 02:00:00' AND '2025-09-09 02:59:59') THEN 1 END) AS time_at_02,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 03:00:00' AND '2025-09-09 03:59:59' OR ut.expiry_time BETWEEN '2025-09-09 03:00:00' AND '2025-09-09 03:59:59') THEN 1 END) AS time_at_03,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 04:00:00' AND '2025-09-09 04:59:59' OR ut.expiry_time BETWEEN '2025-09-09 04:00:00' AND '2025-09-09 04:59:59') THEN 1 END) AS time_at_04,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 05:00:00' AND '2025-09-09 05:59:59' OR ut.expiry_time BETWEEN '2025-09-09 05:00:00' AND '2025-09-09 05:59:59') THEN 1 END) AS time_at_05,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 06:00:00' AND '2025-09-09 06:59:59' OR ut.expiry_time BETWEEN '2025-09-09 06:00:00' AND '2025-09-09 06:59:59') THEN 1 END) AS time_at_06,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 07:00:00' AND '2025-09-09 07:59:59' OR ut.expiry_time BETWEEN '2025-09-09 07:00:00' AND '2025-09-09 07:59:59') THEN 1 END) AS time_at_07,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 08:00:00' AND '2025-09-09 08:59:59' OR ut.expiry_time BETWEEN '2025-09-09 08:00:00' AND '2025-09-09 08:59:59') THEN 1 END) AS time_at_08,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 09:00:00' AND '2025-09-09 09:59:59' OR ut.expiry_time BETWEEN '2025-09-09 09:00:00' AND '2025-09-09 09:59:59') THEN 1 END) AS time_at_09,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 10:00:00' AND '2025-09-09 10:59:59' OR ut.expiry_time BETWEEN '2025-09-09 10:00:00' AND '2025-09-09 10:59:59') THEN 1 END) AS time_at_10,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 11:00:00' AND '2025-09-09 11:59:59' OR ut.expiry_time BETWEEN '2025-09-09 11:00:00' AND '2025-09-09 11:59:59') THEN 1 END) AS time_at_11,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 12:00:00' AND '2025-09-09 12:59:59' OR ut.expiry_time BETWEEN '2025-09-09 12:00:00' AND '2025-09-09 12:59:59') THEN 1 END) AS time_at_12,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 13:00:00' AND '2025-09-09 13:59:59' OR ut.expiry_time BETWEEN '2025-09-09 13:00:00' AND '2025-09-09 13:59:59') THEN 1 END) AS time_at_13,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 14:00:00' AND '2025-09-09 14:59:59' OR ut.expiry_time BETWEEN '2025-09-09 14:00:00' AND '2025-09-09 14:59:59') THEN 1 END) AS time_at_14,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 15:00:00' AND '2025-09-09 15:59:59' OR ut.expiry_time BETWEEN '2025-09-09 15:00:00' AND '2025-09-09 15:59:59') THEN 1 END) AS time_at_15,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 16:00:00' AND '2025-09-09 16:59:59' OR ut.expiry_time BETWEEN '2025-09-09 16:00:00' AND '2025-09-09 16:59:59') THEN 1 END) AS time_at_16,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 17:00:00' AND '2025-09-09 17:59:59' OR ut.expiry_time BETWEEN '2025-09-09 17:00:00' AND '2025-09-09 17:59:59') THEN 1 END) AS time_at_17,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 18:00:00' AND '2025-09-09 18:59:59' OR ut.expiry_time BETWEEN '2025-09-09 18:00:00' AND '2025-09-09 18:59:59') THEN 1 END) AS time_at_18,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 19:00:00' AND '2025-09-09 19:59:59' OR ut.expiry_time BETWEEN '2025-09-09 19:00:00' AND '2025-09-09 19:59:59') THEN 1 END) AS time_at_19,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 20:00:00' AND '2025-09-09 20:59:59' OR ut.expiry_time BETWEEN '2025-09-09 20:00:00' AND '2025-09-09 20:59:59') THEN 1 END) AS time_at_20,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 21:00:00' AND '2025-09-09 21:59:59' OR ut.expiry_time BETWEEN '2025-09-09 21:00:00' AND '2025-09-09 21:59:59') THEN 1 END) AS time_at_21,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 22:00:00' AND '2025-09-09 22:59:59' OR ut.expiry_time BETWEEN '2025-09-09 22:00:00' AND '2025-09-09 22:59:59') THEN 1 END) AS time_at_22,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-09 23:00:00' AND '2025-09-09 23:59:59' OR ut.expiry_time BETWEEN '2025-09-09 23:00:00' AND '2025-09-09 23:59:59') THEN 1 END) AS time_at_23
    FROM user_token ut
    INNER JOIN admin_position_master apm ON ut.user_id = apm.position_id
    INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id AND aurm.role_master_id IN (1,2,3,4,5,6,7,8,9)
    WHERE ut.user_type = 1 AND ut.updated_on::date = '2025-09-09'
    GROUP BY role_group
)
-- Add total row
SELECT * FROM role_data
UNION ALL
SELECT 
    'TOTAL',
    SUM(time_at_00), SUM(time_at_01), SUM(time_at_02), SUM(time_at_03),
    SUM(time_at_04), SUM(time_at_05), SUM(time_at_06), SUM(time_at_07),
    SUM(time_at_08), SUM(time_at_09), SUM(time_at_10), SUM(time_at_11),
    SUM(time_at_12), SUM(time_at_13), SUM(time_at_14), SUM(time_at_15),
    SUM(time_at_16), SUM(time_at_17), SUM(time_at_18), SUM(time_at_19),
    SUM(time_at_20), SUM(time_at_21), SUM(time_at_22), SUM(time_at_23)
FROM role_data
ORDER BY role_group;



----- PERFECT QUERY WITH TOTAL FOR DEPARTMENTAL ----
WITH role_data AS (
    SELECT 
        CASE 
            WHEN aurm.role_master_id IN (1,2,3,9) THEN 'CMO'
            WHEN aurm.role_master_id IN (4,5,6)   THEN 'HOD'
            WHEN aurm.role_master_id = 7          THEN 'HOSO'
            WHEN aurm.role_master_id = 8          THEN 'SO'
        END AS role_group,
 	COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 00:00:00' AND '2025-09-08 00:59:59' or aula.logout_time between '2025-09-08 00:00:00' AND '2025-09-08 00:59:59') THEN 1 END) AS time_at_00,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 01:00:00' AND '2025-09-08 01:59:59' or aula.logout_time between '2025-09-08 01:00:00' AND '2025-09-08 01:59:59') THEN 1 END) AS time_at_01,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 02:00:00' AND '2025-09-08 02:59:59' or aula.logout_time between '2025-09-08 02:00:00' AND '2025-09-08 02:59:59') THEN 1 END) AS time_at_02,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 03:00:00' AND '2025-09-08 03:59:59' or aula.logout_time between '2025-09-08 03:00:00' AND '2025-09-08 03:59:59') THEN 1 END) AS time_at_03,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 04:00:00' AND '2025-09-08 04:59:59' or aula.logout_time between '2025-09-08 04:00:00' AND '2025-09-08 04:59:59') THEN 1 END) AS time_at_04,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 05:00:00' AND '2025-09-08 05:59:59' or aula.logout_time between '2025-09-08 05:00:00' AND '2025-09-08 05:59:59') THEN 1 END) AS time_at_05,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 06:00:00' AND '2025-09-08 06:59:59' or aula.logout_time between '2025-09-08 06:00:00' AND '2025-09-08 06:59:59') THEN 1 END) AS time_at_06,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 07:00:00' AND '2025-09-08 07:59:59' or aula.logout_time between '2025-09-08 07:00:00' AND '2025-09-08 07:59:59') THEN 1 END) AS time_at_07,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 08:00:00' AND '2025-09-08 08:59:59' or aula.logout_time between '2025-09-08 08:00:00' AND '2025-09-08 08:59:59') THEN 1 END) AS time_at_08,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 09:00:00' AND '2025-09-08 09:59:59' or aula.logout_time between '2025-09-08 09:00:00' AND '2025-09-08 09:59:59') THEN 1 END) AS time_at_09,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 10:00:00' AND '2025-09-08 10:59:59' or aula.logout_time between '2025-09-08 10:00:00' AND '2025-09-08 10:59:59') THEN 1 END) AS time_at_10,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 11:00:00' AND '2025-09-08 11:59:59' or aula.logout_time between '2025-09-08 11:00:00' AND '2025-09-08 11:59:59') THEN 1 END) AS time_at_11,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 12:00:00' AND '2025-09-08 12:59:59' or aula.logout_time between '2025-09-08 12:00:00' AND '2025-09-08 12:59:59') THEN 1 END) AS time_at_12,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 13:00:00' AND '2025-09-08 13:59:59' or aula.logout_time between '2025-09-08 13:00:00' AND '2025-09-08 13:59:59') THEN 1 END) AS time_at_13,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 14:00:00' AND '2025-09-08 14:59:59' or aula.logout_time between '2025-09-08 14:00:00' AND '2025-09-08 14:59:59') THEN 1 END) AS time_at_14,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 15:00:00' AND '2025-09-08 15:59:59' or aula.logout_time between '2025-09-08 15:00:00' AND '2025-09-08 15:59:59') THEN 1 END) AS time_at_15,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 16:00:00' AND '2025-09-08 16:59:59' or aula.logout_time between '2025-09-08 16:00:00' AND '2025-09-08 16:59:59') THEN 1 END) AS time_at_16,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 17:00:00' AND '2025-09-08 17:59:59' or aula.logout_time between '2025-09-08 17:00:00' AND '2025-09-08 17:59:59') THEN 1 END) AS time_at_17,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 18:00:00' AND '2025-09-08 18:59:59' or aula.logout_time between '2025-09-08 18:00:00' AND '2025-09-08 18:59:59') THEN 1 END) AS time_at_18,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 19:00:00' AND '2025-09-08 19:59:59' or aula.logout_time between '2025-09-08 19:00:00' AND '2025-09-08 19:59:59') THEN 1 END) AS time_at_19,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 20:00:00' AND '2025-09-08 20:59:59' or aula.logout_time between '2025-09-08 20:00:00' AND '2025-09-08 20:59:59') THEN 1 END) AS time_at_20,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 21:00:00' AND '2025-09-08 21:59:59' or aula.logout_time between '2025-09-08 21:00:00' AND '2025-09-08 21:59:59') THEN 1 END) AS time_at_21,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 22:00:00' AND '2025-09-08 22:59:59' or aula.logout_time between '2025-09-08 22:00:00' AND '2025-09-08 22:59:59') THEN 1 END) AS time_at_22,
    COUNT(CASE WHEN (aula.login_time BETWEEN '2025-09-08 23:00:00' AND '2025-09-08 23:59:59' or aula.logout_time between '2025-09-08 23:00:00' AND '2025-09-08 23:59:59') THEN 1 END) AS time_at_23
    FROM admin_user_login_activity aula 
    INNER JOIN admin_position_master apm ON aula.admin_user_id = apm.position_id
    INNER JOIN admin_user_role_master aurm ON aurm.role_master_id = apm.role_master_id AND aurm.role_master_id IN (1,2,3,4,5,6,7,8,9)
    WHERE aula.created_on::date = '2025-09-08'
    GROUP BY role_group
)
-- Add total row
SELECT * FROM role_data
UNION ALL
SELECT 
    'TOTAL',
    SUM(time_at_00), SUM(time_at_01), SUM(time_at_02), SUM(time_at_03),
    SUM(time_at_04), SUM(time_at_05), SUM(time_at_06), SUM(time_at_07),
    SUM(time_at_08), SUM(time_at_09), SUM(time_at_10), SUM(time_at_11),
    SUM(time_at_12), SUM(time_at_13), SUM(time_at_14), SUM(time_at_15),
    SUM(time_at_16), SUM(time_at_17), SUM(time_at_18), SUM(time_at_19),
    SUM(time_at_20), SUM(time_at_21), SUM(time_at_22), SUM(time_at_23)
FROM role_data
ORDER BY role_group;



SELECT *
    FROM admin_user_login_activity aula 
    WHERE aula.created_on::date = '2025-09-08' and (aula.login_time BETWEEN '2025-09-08 11:00:00' AND '2025-09-08 11:59:59' or aula.logout_time between '2025-09-08 11:00:00' AND '2025-09-08 11:59:59')




select * from admin_user_login_activity aula limit 1;
select * from admin_user_login_activity aula where aula.admin_user_id = 4315;

------ FOR CITIZEN -----
SELECT 
    'Citizen' AS role_group,
 	COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 00:00:00' AND '2025-09-01 01:00:00') THEN 1 END) AS time_at_00,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 01:00:00' AND '2025-09-01 02:00:00') THEN 1 END) AS time_at_01,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 02:00:00' AND '2025-09-01 03:00:00') THEN 1 END) AS time_at_02,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 03:00:00' AND '2025-09-01 04:00:00') THEN 1 END) AS time_at_03,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 04:00:00' AND '2025-09-01 05:00:00') THEN 1 END) AS time_at_04,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 05:00:00' AND '2025-09-01 06:00:00') THEN 1 END) AS time_at_05,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 06:00:00' AND '2025-09-01 07:00:00') THEN 1 END) AS time_at_06,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 07:00:00' AND '2025-09-01 08:00:00') THEN 1 END) AS time_at_07,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 08:00:00' AND '2025-09-01 09:00:00') THEN 1 END) AS time_at_08,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 09:00:00' AND '2025-09-01 10:00:00') THEN 1 END) AS time_at_09,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 10:00:00' AND '2025-09-01 11:00:00') THEN 1 END) AS time_at_10,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 11:00:00' AND '2025-09-01 12:00:00') THEN 1 END) AS time_at_11,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 12:00:00' AND '2025-09-01 13:00:00') THEN 1 END) AS time_at_12,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 13:00:00' AND '2025-09-01 14:00:00') THEN 1 END) AS time_at_13,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 14:00:00' AND '2025-09-01 15:00:00') THEN 1 END) AS time_at_14,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 15:00:00' AND '2025-09-01 16:00:00') THEN 1 END) AS time_at_15,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 16:00:00' AND '2025-09-01 17:00:00') THEN 1 END) AS time_at_16,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 17:00:00' AND '2025-09-01 18:00:00') THEN 1 END) AS time_at_17,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 18:00:00' AND '2025-09-01 19:00:00') THEN 1 END) AS time_at_18,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 19:00:00' AND '2025-09-01 20:00:00') THEN 1 END) AS time_at_19,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 20:00:00' AND '2025-09-01 21:00:00') THEN 1 END) AS time_at_20,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 21:00:00' AND '2025-09-01 22:00:00') THEN 1 END) AS time_at_21,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 22:00:00' AND '2025-09-01 23:00:00') THEN 1 END) AS time_at_22,
    COUNT(CASE WHEN (ut.updated_on BETWEEN '2025-09-01 23:00:00' AND '2025-09-01 00:00:00') THEN 1 END) AS time_at_23
    FROM user_token ut
    WHERE ut.user_type = 3 AND ut.updated_on::date = '2025-09-01'
    GROUP BY role_group
    
    
    
    ------ For Citizen Number of People Login-----
SELECT 
    'Citizen' AS role_group,
    '2025-09-09' as login_date,
 	COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 00:00:00' AND '2025-09-09 01:00:00') THEN 1 END) AS time_at_00,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 01:00:00' AND '2025-09-09 02:00:00') THEN 1 END) AS time_at_01,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 02:00:00' AND '2025-09-09 03:00:00') THEN 1 END) AS time_at_02,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 03:00:00' AND '2025-09-09 04:00:00') THEN 1 END) AS time_at_03,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 04:00:00' AND '2025-09-09 05:00:00') THEN 1 END) AS time_at_04,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 05:00:00' AND '2025-09-09 06:00:00') THEN 1 END) AS time_at_05,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 06:00:00' AND '2025-09-09 07:00:00') THEN 1 END) AS time_at_06,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 07:00:00' AND '2025-09-09 08:00:00') THEN 1 END) AS time_at_07,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 08:00:00' AND '2025-09-09 09:00:00') THEN 1 END) AS time_at_08,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 09:00:00' AND '2025-09-09 10:00:00') THEN 1 END) AS time_at_09,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 10:00:00' AND '2025-09-09 11:00:00') THEN 1 END) AS time_at_10,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 11:00:00' AND '2025-09-09 12:00:00') THEN 1 END) AS time_at_11,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 12:00:00' AND '2025-09-09 13:00:00') THEN 1 END) AS time_at_12,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 13:00:00' AND '2025-09-09 14:00:00') THEN 1 END) AS time_at_13,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 14:00:00' AND '2025-09-09 15:00:00') THEN 1 END) AS time_at_14,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 15:00:00' AND '2025-09-09 16:00:00') THEN 1 END) AS time_at_15,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 16:00:00' AND '2025-09-09 17:00:00') THEN 1 END) AS time_at_16,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 17:00:00' AND '2025-09-09 18:00:00') THEN 1 END) AS time_at_17,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 18:00:00' AND '2025-09-09 19:00:00') THEN 1 END) AS time_at_18,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 19:00:00' AND '2025-09-09 20:00:00') THEN 1 END) AS time_at_19,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 20:00:00' AND '2025-09-09 21:00:00') THEN 1 END) AS time_at_20,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 21:00:00' AND '2025-09-09 22:00:00') THEN 1 END) AS time_at_21,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 22:00:00' AND '2025-09-09 23:00:00') THEN 1 END) AS time_at_22,
    COUNT(CASE WHEN (cla.login_time BETWEEN '2025-09-09 23:00:00' AND '2025-09-09 23:59:59') THEN 1 END) AS time_at_23
    FROM citizen_login_activity cla 
    WHERE cla.login_time::date = '2025-09-09'
    GROUP BY role_group;
    
    select * from citizen_login_activity cla limit 1
------------------------------------------

-------- checking department-----------
select count(1) 
--select *
	from user_token 
	where user_token.user_type = 1 and user_token.updated_on::date = '2025-09-12' 
and (user_token.updated_on BETWEEN '2025-09-12 20:30:00' AND '2025-09-12 21:00:00' OR user_token.expiry_time BETWEEN '2025-09-12 20:30:00' AND '2025-09-12 21:00:00') ;

select *
	from user_token 
	where user_token.user_type = 1 and user_token.updated_on::date = '2025-09-12' 
and user_token.updated_on BETWEEN '2025-09-12 20:30:00' AND '2025-09-12 21:00:00'; /*OR user_token.expiry_time BETWEEN '2025-09-12 20:30:00' AND '2025-09-12 21:00:00') ;*/
------------------------------------------------

select * 
	from user_token 
	where user_token.user_type = 3 and user_token.updated_on::date = '2025-09-01' 
and (user_token.updated_on BETWEEN '2025-09-01 00:00:00' AND '2025-09-01 01:00:00') ;

------ checking CITIZEN -----
select * 
	from citizen_login_activity cla  
	where cla.login_time::date = '2025-09-03'
and cla.login_time BETWEEN '2025-09-03 02:00:00' AND '2025-09-03 03:00:00';

---------
select 
	aurm.role_master_name as role_name,
	count(1),
	'2025-09-02 11:00:00' as login_upto
from user_token 
inner join admin_position_master apm on user_token.user_id  = apm.position_id
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id and aurm.role_master_id in (1,2,3,4,5,6,7,8)
where user_token.user_type = 1 and user_token.updated_on::date = '2025-09-02' 
and (user_token.updated_on between '2025-09-02 00:00:00' and '2025-09-02 00:59:00' or user_token.expiry_time between '2025-09-02 00:00:00' and '2025-09-02 00:59:00') 
group by aurm.role_master_name, aurm.role_master_id
order by aurm.role_master_id asc;
---------------------------------


-------------------------
SELECT 
    ut.token_id,
    ut.user_id,
    ut.updated_on,
    ut.expiry_time,
    aurm.role_master_id,
    ut.user_type,
    CASE 
        WHEN aurm.role_master_id IN (1,2,3,9) THEN 'CMO'
        WHEN aurm.role_master_id IN (4,5,6)   THEN 'HOD'
        WHEN aurm.role_master_id = 7          THEN 'HOSO'
        WHEN aurm.role_master_id = 8          THEN 'SO'
    END AS role_group,
    CASE 
        WHEN ((ut.updated_on BETWEEN '2025-09-08 23:00:00' AND '2025-09-08 23:59:59') OR (ut.expiry_time BETWEEN '2025-09-08 23:00:00' AND '2025-09-08 23:59:59')) THEN 'COUNTED_IN_12AM'
        ELSE 'NOT_INCLUDED'
    END AS bucket_flag
FROM user_token ut
JOIN admin_position_master apm 
    ON ut.user_id = apm.position_id
JOIN admin_user_role_master aurm 
    ON aurm.role_master_id = apm.role_master_id
WHERE ut.user_type = 1
  AND (ut.updated_on BETWEEN '2025-09-08 23:00:00' AND '2025-09-08 23:59:59' OR ut.expiry_time BETWEEN '2025-09-08 23:00:00' AND '2025-09-08 23:59:59')
ORDER BY ut.updated_on;

-- =======================================================================================================================================================================================