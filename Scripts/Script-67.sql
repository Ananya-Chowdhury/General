with fwd_union_data as (		
    select 
        admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
            ) as recev_cmo_othod
        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
            where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75) 
),  fwd_atr as (
        select 
            count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
            from fwd_union_data
            group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
),  atr_recv as (
        select 
            fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, count(fwd_union_data.grievance_id) as atr_received
        from fwd_union_data
        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
        where atr_latest_11_bh_mat.assigned_to_office_id in (75)
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
),  pend as (		
        select 
            fwd_union_data.sub_office_id, count(1) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
        from fwd_union_data 
        inner join pending_at_hoso_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (75))
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
 ), ave_days as (
        select 
            fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, avg(bh.days_to_resolve) as avg_days_to_resolved
        from fwd_union_data
        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
        inner join pending_at_hoso_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
        where 1=1 and atr_latest_11_bh_mat.assigned_to_office_id in (75)
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
)
select
    '2025-10-05 16:30:01.602693+00:00'::timestamp as refresh_time_utc,
    coalesce(cmo_sub_office_master.suboffice_name,'N/A') as sub_office_name,
    coalesce(cmo_sub_office_master.suboffice_id, 0) as sub_office_id_to,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name,
    coalesce(fwd_atr.forwarded, 0) as grv_forwarded,
    coalesce(atr_recv.atr_received, 0) as atr_received,
    coalesce(round(ave_days.avg_days_to_resolved, 2), 0) as avg_days_to_resolved,
    coalesce(pend.more_7_days, 0) as more_7_day,
    coalesce(pend.atrpending, 0) as atr_pending
    from fwd_atr
left join atr_recv on fwd_atr.sub_office_id = atr_recv.sub_office_id
left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
left join ave_days on fwd_atr.sub_office_id = ave_days.sub_office_id
left join pend on fwd_atr.sub_office_id = pend.sub_office_id
    where 1=1
group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, fwd_atr.forwarded, atr_recv.atr_received, com.office_id, com.office_name, ave_days.avg_days_to_resolved, pend.atrpending, pend.more_7_days
order by cmo_sub_office_master.suboffice_name;






with pnd as (
	select
	        admin_position_master.sub_office_id, grievance_master_bh_mat.grievance_category, count(1) as pending,
	        sum(case when ba.days_diff <= 7 then 1 else 0 end) as d_0_7_d,
	        sum(case when (15 >= ba.days_diff and ba.days_diff > 7) then 1 else 0 end) as d_7_15,
	        sum(case when (30 >= ba.days_diff and ba.days_diff > 15) then 1 else 0 end) as d_15_30,
	        sum(case when (ba.days_diff > 30) then 1 else 0 end) as more_30_d
	from (
	    select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
	    from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	    left join /* VARIABLE */ atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
	    where atr_latest_14_bh_mat.grievance_id is null
	        /* VARIABLE */  and forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
	    union
	        select bh.grievance_id, bh.assigned_on
	        from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
	        left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
	        where bm.grievance_id is null
	            /* VARIABLE */  and bh.assigned_to_office_id in (75)
	) as pnd_union_data
	inner join /* VARIABLE */ grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = pnd_union_data.grievance_id
	left join admin_position_master on admin_position_master.position_id = grievance_master_bh_mat.assigned_to_position
	left join /* VARIABLE */ pending_for_hoso_wise_mat_2 as ba on grievance_master_bh_mat.grievance_id = ba.grievance_id
	where grievance_master_bh_mat.status not in (3, 5, 16) and admin_position_master.role_master_id in (7,8)
	    /* VARIABLE */ and admin_position_master.office_id in (75)
	    /* VARIABLE */
	    group by admin_position_master.sub_office_id, grievance_master_bh_mat.grievance_category
	), fwd_union_data as (
	    select admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_category, forwarded_latest_7_bh_mat.grievance_id
	    from
	        (
	            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
	                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	        where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
	            union
	        select bh.grievance_id, bh.assigned_on
	            from forwarded_latest_5_bh_mat_2 bh
	        where bh.assigned_to_office_id in (75)
	    )as XX
	inner join forwarded_latest_7_bh_mat_2 forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = XX.grievance_id
	left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
	where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75)
	), fwd_atr as (
	    select fwd_union_data.sub_office_id, fwd_union_data.grievance_category, count(fwd_union_data.grievance_id) as forwarded
	    from fwd_union_data
	    group by fwd_union_data.sub_office_id, fwd_union_data.grievance_category
	), atr as (
	    select fwd_union_data.sub_office_id, fwd_union_data.grievance_category, count(fwd_union_data.grievance_id) as atr_received
	    from fwd_union_data
	    inner join /* VARIABLE */ atr_latest_11_bh_mat_2 atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
	where /* VARIABLE */ atr_latest_11_bh_mat.assigned_to_office_id in (75)
	    group by fwd_union_data.sub_office_id, fwd_union_data.grievance_category
	), processing_unit as (
	    select
	        /* VARIABLE */ '2025-10-05 16:30:01.602693+00:00':: timestamp as refresh_time_utc,
	    /* VARIABLE */ '2025-10-05 16:30:01.602693+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
	    coalesce(cmo_sub_office_master.suboffice_name,'N/A') as office_name,
	    coalesce(cgcm.grievance_category_desc,'N/A') as grievance_category_desc,
	    cmo_sub_office_master.suboffice_id,
	    cgcm.parent_office_id,
	    coalesce(fwd_atr.forwarded, 0) AS grv_forwarded,
	    coalesce(atr.atr_received, 0) AS atr_received,
	    coalesce(pnd.d_0_7_d, 0) AS d_0_7_d,
	    coalesce(pnd.d_7_15, 0) AS d_7_15,
	    coalesce(pnd.d_15_30, 0) AS d_15_30,
	    coalesce(pnd.more_30_d, 0) AS more_30_d,
	    coalesce(pnd.pending, 0) AS atr_pending
	from fwd_atr
	left join atr on fwd_atr.sub_office_id = atr.sub_office_id and fwd_atr.grievance_category = atr.grievance_category
	left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fwd_atr.grievance_category
	full join pnd on fwd_atr.sub_office_id = pnd.sub_office_id and fwd_atr.grievance_category = pnd.grievance_category
	where 1=1
	        /* VARIABLE */
	        /* VARIABLE */
	    order by cmo_sub_office_master.suboffice_name, cgcm.grievance_category_desc
	)
	select row_number() over() as sl_no, processing_unit.* from processing_unit
	
--------------------------------------------------------------------------------	
	
with fwd_union_data as (		
    select 
        admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
            ) as recev_cmo_othod
        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
            where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75) 
),  fwd_atr as (
        select 
            count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
            from fwd_union_data
            group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
),  pend as (		
        select 
            fwd_union_data.sub_office_id, count(1) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
        from fwd_union_data 
        inner join pending_at_hoso_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (75))
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
 )
select
    coalesce(cmo_sub_office_master.suboffice_name,'N/A') as sub_office_name,
    coalesce(cmo_sub_office_master.suboffice_id, 0) as sub_office_id_to,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name,
    coalesce(pend.atrpending, 0) as atr_pending
    from fwd_atr
left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
left join pend on fwd_atr.sub_office_id = pend.sub_office_id
    where 1=1
group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, fwd_atr.forwarded, com.office_id, com.office_name,  pend.atrpending, pend.more_7_days
order by cmo_sub_office_master.suboffice_name;






with pnd as (
	select
	        admin_position_master.sub_office_id, count(1) as pending
	from (
	    select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
	    from /* VARIABLE */ forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	    left join /* VARIABLE */ atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat on atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15)
	    where atr_latest_14_bh_mat.grievance_id is null
	        /* VARIABLE */  and forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
	    union
	        select bh.grievance_id, bh.assigned_on
	        from /* VARIABLE */ forwarded_latest_5_bh_mat_2 bh
	        left join /* VARIABLE */ atr_latest_13_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
	        where bm.grievance_id is null and bh.assigned_to_office_id in (75)
	) as pnd_union_data
	inner join grievance_master_bh_mat_2 as grievance_master_bh_mat on grievance_master_bh_mat.grievance_id = pnd_union_data.grievance_id
	left join admin_position_master on admin_position_master.position_id = grievance_master_bh_mat.assigned_to_position
	left join pending_for_hoso_wise_mat_2 as ba on grievance_master_bh_mat.grievance_id = ba.grievance_id
	where grievance_master_bh_mat.status not in (3, 5, 16) and admin_position_master.role_master_id in (7,8) and admin_position_master.office_id in (75)
	group by admin_position_master.sub_office_id
	), fwd_union_data as (
	    select admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id
	    from
	        (
	            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
	                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
	        where forwarded_latest_3_bh_mat.assigned_to_office_id in (75)
	            union
	        select bh.grievance_id, bh.assigned_on
	            from forwarded_latest_5_bh_mat_2 bh
	        where bh.assigned_to_office_id in (75)
	    )as XX
	inner join forwarded_latest_7_bh_mat_2 forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = XX.grievance_id
	left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
	where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75)
	), fwd_atr as (
	    select fwd_union_data.sub_office_id,  count(fwd_union_data.grievance_id) as forwarded
	    from fwd_union_data
	    group by fwd_union_data.sub_office_id
	) select 
		coalesce(cmo_sub_office_master.suboffice_name,'N/A') as office_name,
	    cmo_sub_office_master.suboffice_id,
	    coalesce(pnd.pending, 0) AS atr_pending
	from fwd_atr
	left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
	full join pnd on fwd_atr.sub_office_id = pnd.sub_office_id 
	where 1=1 
	group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, pnd.pending
    
 -------------------------------------------------------------------------------------------------------------------------------------
    
    
    
with fwd_union_data as (		
    select 
        admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_by_office_id
        from
            (
            select forwarded_latest_3_bh_mat.grievance_id, forwarded_latest_3_bh_mat.assigned_on
                from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
                union
            select forwarded_latest_5_bh_mat.grievance_id, forwarded_latest_5_bh_mat.assigned_on
                from forwarded_latest_5_bh_mat_2 as forwarded_latest_5_bh_mat
            where forwarded_latest_5_bh_mat.assigned_to_office_id in (75) /* SSM CALL CENTER */ 
            ) as recev_cmo_othod
        inner join forwarded_latest_7_bh_mat_2 as forwarded_latest_7_bh_mat on forwarded_latest_7_bh_mat.grievance_id = recev_cmo_othod.grievance_id
        left join admin_position_master on forwarded_latest_7_bh_mat.assigned_to_position = admin_position_master.position_id
            where 1=1 and forwarded_latest_7_bh_mat.assigned_by_office_id in (75)
--        group by admin_position_master.sub_office_id, forwarded_latest_7_bh_mat.grievance_id, forwarded_latest_7_bh_mat.assigned_by_office_id   
),  fwd_atr as (
        select 
            count(fwd_union_data.grievance_id) as forwarded, fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
            from fwd_union_data
            group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
),  atr_recv as (
        select 
            fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, count(fwd_union_data.grievance_id) as atr_received
        from fwd_union_data
        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
        where atr_latest_11_bh_mat.assigned_to_office_id in (75)
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
),  pend as (		
        select 
            fwd_union_data.sub_office_id, count(1) as atrpending, sum(case when (ba.pending_days > 7) then 1 else 0 end) as more_7_days, fwd_union_data.assigned_by_office_id
        from fwd_union_data 
        inner join pending_at_hoso_mat_2 as ba on fwd_union_data.grievance_id = ba.grievance_id
        where not exists ( SELECT 1 FROM atr_latest_11_bh_mat_2 as bm where fwd_union_data.grievance_id = bm.grievance_id and bm.assigned_to_office_id in (75))
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
 ), ave_days as (
        select 
            fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id, avg(bh.days_to_resolve) as avg_days_to_resolved
        from fwd_union_data
        inner join atr_latest_11_bh_mat_2 as atr_latest_11_bh_mat on atr_latest_11_bh_mat.grievance_id = fwd_union_data.grievance_id
        inner join pending_at_hoso_mat_2 as bh on bh.grievance_id = fwd_union_data.grievance_id
        where 1=1 and atr_latest_11_bh_mat.assigned_to_office_id in (75)
        group by fwd_union_data.sub_office_id, fwd_union_data.assigned_by_office_id
)
select
    '2025-10-05 16:30:01.602693+00:00'::timestamp as refresh_time_utc,
    coalesce(cmo_sub_office_master.suboffice_name,'N/A') as sub_office_name,
    coalesce(cmo_sub_office_master.suboffice_id, 0) as sub_office_id_to,
    coalesce(com.office_id, 0) as office_id_by,
    coalesce(com.office_name, 'N/A') as office_name,
    coalesce(fwd_atr.forwarded, 0) as grv_forwarded,
    coalesce(atr_recv.atr_received, 0) as atr_received,
    coalesce(round(ave_days.avg_days_to_resolved, 2), 0) as avg_days_to_resolved,
    coalesce(pend.more_7_days, 0) as more_7_day,
    coalesce(pend.atrpending, 0) as atr_pending
    from fwd_atr
left join atr_recv on fwd_atr.sub_office_id = atr_recv.sub_office_id
left join cmo_sub_office_master on cmo_sub_office_master.suboffice_id = fwd_atr.sub_office_id
left join cmo_office_master com on com.office_id = fwd_atr.assigned_by_office_id
left join ave_days on fwd_atr.sub_office_id = ave_days.sub_office_id
left join pend on fwd_atr.sub_office_id = pend.sub_office_id
    where 1=1
group by cmo_sub_office_master.suboffice_name, cmo_sub_office_master.suboffice_id, fwd_atr.forwarded, atr_recv.atr_received, com.office_id, com.office_name, ave_days.avg_days_to_resolved, pend.atrpending, pend.more_7_days
order by cmo_sub_office_master.suboffice_name;

select  * from cmo_griev_cat_office_mapping cgcom where cgcom.office_id = 75;
select  * from cmo_griev_cat_office_mapping cgcom where cgcom.grievance_cat_id = 133;
select * from cmo_grievance_category_master cgcm ;
select * from cmo_office_master com ;
