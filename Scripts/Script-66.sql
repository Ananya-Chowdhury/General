---------------------------------------------------- dashboard HOD total count for perticular office & ssm ---------------------------------------------------------------
with grievances_recieved as (
		SELECT COUNT(1) as grievances_recieved_cnt FROM forwarded_latest_3_bh_mat bh
		where /*bh.grievance_source = 5 and*/ bh.assigned_to_office_id = 35
), atr_sent as (
	SELECT COUNT(1) as atr_sent_cnt, 
	sum(case when bm.current_status = 15 then 1 else 0 end) as disposed_cnt,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
	FROM atr_latest_14_bh_mat bm
	inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id 
	where bm.current_status in (14,15) /*and bm.grievance_source = 5*/ and bm.assigned_by_office_id = 35
), atr_pending as (
	SELECT COUNT(1) as atr_pending_cnt FROM forwarded_latest_3_bh_mat bh
     WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5*/ and bh.assigned_to_office_id = 35
) select * 
from grievances_recieved
cross join atr_sent
cross join atr_pending;

-----------------------------------------------------------------------------