select * 
from cmo_office_master
join grievance_master gm on gm.assigned_to_office_id = com.office_id
where gm.status in (14, 15);