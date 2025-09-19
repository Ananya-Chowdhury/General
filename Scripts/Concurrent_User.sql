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