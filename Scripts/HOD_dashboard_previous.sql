-------------------------------------- dashboard HOD total count for perticular office & ssm with other hod  -----------------------------------------------

with grievances_recieved as (
		SELECT COUNT(1) as grievances_recieved_cnt FROM forwarded_latest_3_bh_mat_2 bh
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
), grievance_received_other_hod as (
		select count(1) as griev_recv_cnt_other_hod from forwarded_latest_5_bh_mat bh
		where bh.assigned_to_office_id = 35
), atr_sent_other_hod as (
		select 
			count(1) as atr_sent_cnt_other_hod,
			coalesce(sum(case when bm.current_status = 15 then 1 else 0 end), 0) as disposed_cnt_other_hod,
		    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end), 0) as bnft_prvd_other_hod,
		    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end), 0) as matter_taken_up_other_hod,
		    coalesce(sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end), 0) as not_elgbl_other_hod
		FROM atr_latest_13_bh_mat bm
	inner join forwarded_latest_5_bh_mat bh ON bm.grievance_id = bh.grievance_id 
	where bm.assigned_by_office_id = 35 /*and bm.grievance_source = 5*/ 	
), atr_pending_other_hod as (
	SELECT 
		COUNT(1) as atr_pending_cnt_other_hod 
		FROM forwarded_latest_5_bh_mat bh
		left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
     		WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_13_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5*/ and bh.assigned_to_office_id = 35
)
select * 
	from grievances_recieved
	cross join atr_sent
	cross join atr_pending
	cross join grievance_received_other_hod
	cross join atr_sent_other_hod
	cross join atr_pending_other_hod;
--------------------------------------------------ct wise mis --------------------------------------------------------------------------------------
with received_count as (
		select bh.grievance_category, bh.assigned_by_office_id, count(1) as received 	
		from forwarded_latest_5_bh_mat bh  
	     where bh.grievance_category > 0 and bh.assigned_to_office_id in (35)
		group by bh.grievance_category, bh.assigned_by_office_id
), atr_submitted as (
    	select bh.grievance_category, bh.assigned_to_office_id, count(1) as atr_submitted 
    	from atr_latest_13_bh_mat bh 
	    where bh.assigned_by_office_id in (35)
	   /* {f" where bh.assigned_on::date between {from_date} and {to_date}  " if from_date and to_date else "" } */
	    group by bh.grievance_category, bh.assigned_to_office_id
), pending_count as (
    	select bh.grievance_category, bh.assigned_by_office_id, count(1) as pending
    from forwarded_latest_5_bh_mat bh
    left join pending_for_other_hod_wise_mat_ on bh.grievance_id = pending_for_other_hod_wise_mat_.grievance_id
    where not exists (select 1 from atr_latest_13_bh_mat
           where atr_latest_13_bh_mat.grievance_id = bh.grievance_id and atr_latest_13_bh_mat.current_status in (14,15))
     and bh.assigned_to_office_id in (35)
    group by bh.assigned_by_office_id, bh.grievance_category
) select 
	row_number() over() as sl_no,
	cgcm.grievance_category_desc, 
	coalesce(com.office_name,'N/A') as office_name,
    cgcm.parent_office_id, 
    com.office_id,
	    coalesce(rc.received, 0) AS grievances_received,
	    coalesce(ats.atr_submitted, 0) AS atr_submitted,
	    coalesce(pc.pending, 0) AS pending_to_other_hod
	from received_count rc
	left join cmo_office_master com on com.office_id = rc.assigned_by_office_id
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = rc.grievance_category
	left join atr_submitted ats on ats.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = ats.grievance_category
	left join pending_count pc on pc.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
	order by com.office_name, cgcm.grievance_category_desc

--------------------------------------------------------- dashboard HOD total count for perticular office & ssm ---------------------------------------------------------------
with grievances_recieved as (
		SELECT COUNT(1) as grievances_recieved_cnt FROM forwarded_latest_3_bh_mat bh
		where /*bh.grievance_source = 5 and*/ bh.assigned_to_office_id = 3
), atr_sent as (
	SELECT COUNT(1) as atr_sent_cnt, 
	sum(case when bm.current_status = 15 then 1 else 0 end) as disposed_cnt,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up,
    sum(case when bm.current_status = 15 and bm.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
	FROM atr_latest_14_bh_mat bm
	inner join forwarded_latest_3_bh_mat bh ON bm.grievance_id = bh.grievance_id 
	where bm.current_status in (14,15) /*and bm.grievance_source = 5*/ and bm.assigned_by_office_id = 3
), atr_pending as (
	SELECT COUNT(1) as atr_pending_cnt FROM forwarded_latest_3_bh_mat bh
     WHERE NOT EXISTS ( SELECT 1 FROM atr_latest_14_bh_mat bm WHERE bh.grievance_id = bm.grievance_id and bm.current_status in (14,15))
     /*and bh.grievance_source = 5*/ and bh.assigned_to_office_id = 3 
) select * 
from grievances_recieved
cross join atr_sent
cross join atr_pending;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
