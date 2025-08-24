select
    table1.office_id,
    table1.office_name,
    coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grievance_forwarded,
    coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recieved_count,
    coalesce(table5.total_disposed,0) as total_disposed,
    coalesce(table6.pending_with_hod,0) as atr_pending,
    coalesce(table10.days_diff,0) as average_resolution_days,
    coalesce(table11.benefit_provided,0) as benefit_provided,
    coalesce(table12.mater_taken_up,0) as mater_taken_up,
--  coalesce(table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS bsp_percentage,
--	'Good'::text AS performance
  --  coalesce(table8.grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
   -- coalesce(table9.grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
	-- coalesce(CAST((table11.benefit_provided / (table11.benefit_provided + table12.mater_taken_up ) * 100) AS INTEGER)) AS bsp_percentage,
    coalesce(CAST(((table11.benefit_provided::FLOAT / (table11.benefit_provided + table12.mater_taken_up)::FLOAT) * 100) AS INTEGER), 0) AS bsp_percentage,
    CASE
        WHEN COALESCE(table10.days_diff, 0) <= 7 THEN 'Good'
        WHEN COALESCE(table10.days_diff, 0) > 7 AND COALESCE(table10.days_diff, 0) <= 30 THEN 'Average'
        ELSE 'Poor'
    END AS performance
	FROM
        (
        select
            com.office_id ,
            com.office_name
        from
            cmo_office_master com
        where
            com.office_category = 2
                ) table1
        -- grv frwded
    left outer join(
        select
            count(distinct grievance_id) as grv_frwd,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            apm.office_id) table2
            on
        table1.office_id = table2.office_id
        -- atr recvd
    left outer join(
        select
            count(distinct grievance_id) as atr_recvd ,
            apm.office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.updated_by_position
        where
           gm.status = 14
        group by
            apm.office_id) table3
            on
        table1.office_id = table3.office_id
        -- total disposed 	
    left outer join(
        select
            count(1) as total_disposed,
            co.assigned_by_office_id
        from
            grievance_master gm
        join atr_submitted_max_records_clone co on
            co.grievance_id = gm.grievance_id
        where
        	gm.status = 15
        group by
            co.assigned_by_office_id) table5
            on
        table1.office_id = table5.assigned_by_office_id	
        -- grv pending with hod
    left outer join(
        select
            count(distinct grievance_id) as pending_with_hod ,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join admin_position_master apm on
            apm.position_id = gm.assigned_to_position
        where
           gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            gm.assigned_to_office_id) table6
            on
        table1.office_id = table6.assigned_to_office_id
 		-- average days for grievance
	left outer join (
	    select
	        ar.assigned_by_office_id,
	        extract (day
	    from
	        avg(ar.max_assigned_on - co.max_assigned_on)) as days_diff
	    from
	        atr_submitted_max_records_clone ar,
	        recvd_from_cmo_max_clone_view co,
	        grievance_master gm
	    where
	        ar.grievance_id = co.grievance_id
	        and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
	    group by
	        ar.assigned_by_office_id) table10
	        on
	    table10.assigned_by_office_id = table1.office_id
	    -- benifit provided
	left outer join (
	   select 
			count(distinct grievance_id) as benefit_provided,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.office_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id = 1
		group by 
			apm.office_id) table11
		on
		table1.office_id = table11.office_id
		-- matter taken up
	left outer join (
		select 
			count(distinct grievance_id) as mater_taken_up,
			apm.office_id
		from
		    grievance_master gm
		join admin_position_master apm on
			apm.position_id = gm.assigned_to_office_id 
		where 
			gm.closure_reason_id in (5,9)
		group by 
			apm.office_id) table12
		on
		table1.office_id = table12.office_id
		ORDER BY 
		    grievance_forwarded desc;
		   -- atr_recieved_count DESC,
		   -- total_disposed DESC,
		   -- atr_pending DESC,
		   -- average_resolution_days DESC,
		   -- benefit_provided DESC,
		   -- bsp_percentage DESC,
		   -- performance DESC;
		   
		   
		   
	select  
    table0.grievance_cat_id,
    table0.grievance_category_desc,
    coalesce(table0.office_name,'N/A') as office_name,
    table1.office_id,
    coalesce(table1.grv_uploaded,0) as griev_upload,
    coalesce(table2.grv_frwd_assigned,0) as grv_fwd,
    coalesce(table3.atr_recvd,0) as atr_rcvd,
    coalesce(table5.total_closed,0) as totl_dspsd,
    coalesce(table5.bnft_prvd,0) as srv_prvd,
    coalesce(table5.action_taken,0) as action_taken,
    coalesce(table5.not_elgbl,0) as not_elgbl,
    coalesce(table9.atr_pndg, 0) as atr_pndg,
 	COALESCE(ROUND(CASE 
        WHEN (bnft_prvd + action_taken) = 0 THEN 0
        ELSE (bnft_prvd::numeric / (bnft_prvd + action_taken)) * 100
        END,2),0) AS bnft_prcnt
    from
    (
     select distinct grievance_cat_id,grievance_category_desc, parent_office_id, com.office_name
    	from cmo_grievance_category_master cgcm
    	left join cmo_office_master com on cgcm.parent_office_id = com.office_id
    	where cgcm.status = 1
    )table0
    left outer join
    (
    select  cog.grievance_category_desc ,cog.office_name,cog.office_id,
        cog.grievance_cat_id,count(1) as grv_uploaded
        from cat_offc_grievances cog 
        where 
        grievance_generate_date between '2019-01-01' and '2024-11-14'
        and benefit_scheme_type = 1 
    group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id
    )table1
	on table0.grievance_cat_id = table1.grievance_cat_id
    -- griev frwded
    left outer join 
    (
	    select count(1) as grv_frwd_assigned, cog.grievance_cat_id  from cat_offc_grievances cog 
	    where 
		grievance_generate_date between '2019-01-01' and '2024-11-14' and
	    cog.status in (3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
	    and benefit_scheme_type = 1 
	    group by cog.grievance_cat_id) table2
	    on table2.grievance_cat_id=table0.grievance_cat_id
    -- total atr recieved
    left outer join 
    (
	    select count(1) as atr_recvd, cog.grievance_cat_id  from cat_offc_grievances cog 
	    where 
		grievance_generate_date between '2019-01-01' and '2024-11-14' and
	    cog.status in (14,15)
	    and benefit_scheme_type = 1 
	    group by cog.grievance_cat_id) table3
	    on table3.grievance_cat_id=table0.grievance_cat_id
    -- total closed
    left outer join 
    (
    select 
	    count(1) as total_closed, 
	    sum(case when cog.status = 15 and cog.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	    sum(case when cog.status = 15 and cog.closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
	    sum(case when cog.status = 15 and cog.closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl,
	    cog.grievance_cat_id  
	    from cat_offc_grievances cog 
	    where 
		grievance_generate_date between '2019-01-01' and '2024-11-14' and
	    cog.status = 15
	    and benefit_scheme_type = 1 
	    group by cog.grievance_cat_id) table5
	    on table5.grievance_cat_id=table0.grievance_cat_id
    -- atr pending
    left outer join 
    (
	    select count(1) as atr_pndg, cog.grievance_cat_id  from cat_offc_grievances cog 
	    where 
		grievance_generate_date between '2019-01-01' and '2024-11-14' and
	    cog.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)
	    and benefit_scheme_type = 1 
	    group by cog.grievance_cat_id) table9
	    on table9.grievance_cat_id=table0.grievance_cat_id;
	    
	 
	   
	   
WITH 
	forwarded_and_assigned_grievances AS (       
		 select 
		 	a.assigned_to_position, 
      		count(a.grievance_id) as grv_frwd_assigned 
		 from 
		 	(SELECT 
		 		grievance_lifecycle.grievance_id, 
		 		grievance_lifecycle.assigned_to_office_id,
		        grievance_lifecycle.assigned_to_position,
		        	row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on desc) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)
        	) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3
            group by a.assigned_to_position
		),       
	latest_atr_received AS (
         select 
         	a.assigned_by_position, 
            count(a.grievance_id) as atr_rcvd  
         from 
         	(SELECT 
         		grievance_lifecycle.grievance_id, 
         		grievance_lifecycle.assigned_to_office_id,
                grievance_lifecycle.assigned_by_position,
                    row_number() OVER 
                    	(PARTITION BY grievance_lifecycle.grievance_id 
                    		ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status in (1,4,5,11,14,16,17)
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3 
            group by a.assigned_by_position
   		), 
  	disposal AS (
        select 
        	a.assigned_to_position, 
        	count(a.grievance_id) as total_closed,
        	sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        	sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
        	sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl
       	from 
            (SELECT 
        		grievance_lifecycle.grievance_id, 
        		grievance_lifecycle.grievance_status,
        		grievance_lifecycle.assigned_to_position,
                grievance_lifecycle.assigned_to_office_id,
                row_number() OVER 
                    (PARTITION BY grievance_lifecycle.grievance_id 
                    	ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
            from grievance_master gm, grievance_lifecycle
            where grievance_lifecycle.grievance_status = 15
            and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
            and gm.status = 15
        	and gm.grievance_source IN (5)) a 
            inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
            where rn = 1 and a.assigned_to_office_id = 3    
            group by a.assigned_to_position
         ),
  pending AS (
    SELECT 
        a.assigned_to_position, 
        COUNT(DISTINCT a.grievance_id) AS atr_pndg,
        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days
    FROM 
        (
        SELECT 
            glc.grievance_id, 
            glc.assigned_to_position,
            glc.assigned_to_office_id,
            ROW_NUMBER() OVER 
            (PARTITION BY glc.grievance_id 
                ORDER BY glc.assigned_on DESC) AS rn
        FROM grievance_lifecycle glc
        JOIN grievance_master gm ON gm.grievance_id = glc.grievance_id
        WHERE 
            glc.grievance_status = 7
            AND NOT EXISTS (
                SELECT 1
                FROM grievance_lifecycle glc2
                WHERE 
                    glc2.grievance_id = glc.grievance_id
                    AND glc2.grievance_status = 11
            )
            AND gm.grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            and gm.status = 15
            AND gm.grievance_source IN (5)) a
    INNER JOIN grievance_master gm ON gm.grievance_id = a.grievance_id
    inner join grievance_lifecycle glc on glc.assigned_to_position = a.assigned_to_position
    WHERE rn = 1 and a.assigned_to_office_id = 3    
    GROUP BY a.assigned_to_position
  )
  	select  
		csom.suboffice_name, 
		coalesce(fag.grv_frwd_assigned,0) as grievances_forwarded_assigned, 
		coalesce(ltr.atr_rcvd, 0) as atr_received,
		coalesce(d.bnft_prvd, 0) as benefit_service_provided,
		coalesce(d.action_taken, 0) as action_taken,
		coalesce(d.not_elgbl, 0) as not_elgbl,
	    coalesce(d.total_closed, 0) as total_disposed,
	    coalesce(p.beyond_svn_days, 0) as beyond_svn_days,
	    coalesce(p.atr_pndg, 0) as cumulative   
 	from forwarded_and_assigned_grievances fag
    left join latest_atr_received ltr on ltr.assigned_by_position = fag.assigned_to_position
    left join disposal d on d.assigned_to_position = fag.assigned_to_position
    left join pending p on p.assigned_to_position = fag.assigned_to_position
    left join admin_position_master apm on apm.position_id = fag.assigned_to_position
    left join cmo_sub_office_master csom  on csom.suboffice_id = apm.sub_office_id and csom.office_id = apm.office_id
    group by csom.suboffice_name, fag.grv_frwd_assigned, ltr.atr_rcvd, d.bnft_prvd, d.action_taken, d.not_elgbl, d.total_closed, p.beyond_svn_days, p.atr_pndg;
    
  
   
   
   
   
   select 
	 	a.assigned_to_position, 
  		count(a.grievance_id) as grv_frwd_assigned 
	 from 
	 	(SELECT 
	 		grievance_lifecycle.grievance_id, 
	 		grievance_lifecycle.assigned_to_office_id,
	        grievance_lifecycle.assigned_to_position,
	        	row_number() OVER 
                	(PARTITION BY grievance_lifecycle.grievance_id 
                		ORDER BY grievance_lifecycle.assigned_on desc) AS rn
        from grievance_master gm, grievance_lifecycle
        where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
        and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 15
    	and gm.grievance_source IN (5)
    	) a 
        inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
        where /*rn = 1 and*/ a.assigned_to_office_id = 3
        group by a.assigned_to_position;
        
   select 
	 	a.assigned_to_position, 
  		count(a.grievance_id) as grv_frwd_assigned 
	 from 
	 	(SELECT 
	 		grievance_lifecycle.grievance_id, 
	 		grievance_lifecycle.assigned_to_office_id,
	        grievance_lifecycle.assigned_to_position,
	        	row_number() OVER 
                	(PARTITION BY grievance_lifecycle.grievance_id 
                		ORDER BY grievance_lifecycle.assigned_on desc) AS rn
        from grievance_master gm, grievance_lifecycle
        where grievance_lifecycle.grievance_status in (4,7,8,9,10,11,12,14,15,16,17)
        and gm.grievance_generate_date between '2019-01-01' and '2024-11-11'
        and gm.status = 15
    	and gm.grievance_source IN (5)
    	) a 
        inner join grievance_master gm  on gm.grievance_id = a.grievance_id 
        where rn = 1 and a.assigned_to_office_id = 3
        group by a.assigned_to_position;