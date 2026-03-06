select * from public.cmo_grievance_counts(0,0);

select 
	count(1) as grievances_recieved
	from grievance_master gm ; --4122048

select  
	COUNT(1) as grievances_forwarded 
	from forwarded_latest_3_bh bm /*where bm.grievance_source = 5*/;  --4089255

select 
	count(1) as atr_recieved
	from atr_latest_14_bh bh
	inner join forwarded_latest_3_bh bm on bm.grievance_id = bh.grievance_id; --3233461 3184036
	
select 
	count(1) as atr_pending
	from atr_latest_14_bh bh
	inner join forwarded_latest_3_bh bm on bm.grievance_id = bh.grievance_id
	where not exists (select 1 from forwarded_latest_3_bh bm where bm.grievance_id = bh.grievance_id);


select 
	count(1) as atr_done 
	from forwarded_latest_3_bh bm 
	inner join atr_latest_14_bh bh on bm.grievance_id = bh.grievance_id;

select 
	count(1) as disposed
	from grievance_master gm where gm.status = 15;
	