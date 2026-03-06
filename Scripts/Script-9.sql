select max(l.official_name) as official_name,
                max(l.role_master_name) as role_master_name ,
                l.position_id,
                max(l.official_and_role_name) as official_and_role_name ,
              	SUM(CAST(l.new_grievances_forwarded AS INT)) AS forwarded,
    			SUM(CAST(l.new_grievances_pending AS INT)) AS new_grievances_pending,
--    SUM(CASE WHEN gm.status = 15 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS closed
--    SUM(CASE WHEN gm.status = 14 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS pending,
--    SUM(CASE WHEN gm.status = 6 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_hod_for_review ,
--    SUM(CASE WHEN gm.status = 13 THEN CAST(l.new_grievances_forwarded AS INT) ELSE 0 END) AS atr_returned_to_other_hod 
                SUM(CAST(l.atr_disposed AS INT)) AS atr_disposed,
                SUM(CAST(l.atr_disposal_pending AS INT)) AS atr_disposal_pending,
                SUM(CAST(l.atr_returned_to_hods AS INT)) AS atr_returned_to_hods
from cmo_user_wise_pending l, grievance_master gm 
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


