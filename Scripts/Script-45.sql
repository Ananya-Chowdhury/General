  -- Category Wise Resolution Status --> HOD --  

with fwd_count as (
        select forwarded_latest_3_bh.grievance_category, count(1) as fwd
        from forwarded_latest_3_bh
        /*** Filter ***/
        where forwarded_latest_3_bh.grievance_id > 0 
             and forwarded_latest_3_bh.assigned_on::date between '2019-01-01' and '2024-12-24' 
             and forwarded_latest_3_bh.grievance_source in (5) 
        group by forwarded_latest_3_bh.grievance_category
    ),atr_count as (
        select atr_latest_14_bh.grievance_category, count(1) as atr, 
                sum(case when atr_latest_14_bh.current_status = 15 then 1 else 0 end) as closed,
                sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
                sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
        from atr_latest_14_bh 
        /*** Filter ***/
        where atr_latest_14_bh.grievance_id > 0 
             and atr_latest_14_bh.assigned_on::date between '2019-01-01' and '2024-12-24'   
             and atr_latest_14_bh.grievance_source in (5)  
        group by atr_latest_14_bh.grievance_category
    ),upload_count as (
        select grievance_master.grievance_category, count(1) as uploded from grievance_master 
        /*** Filter ***/
        where grievance_master.grievance_id > 0 
             and grievance_master.grievance_generate_date::date between '2019-01-01' and '2024-12-24'  
             and grievance_master.grievance_source in (5) 
        group by grievance_master.grievance_category
    )  
    select cmo_grievance_category_master.grievance_cat_id, cmo_grievance_category_master.grievance_category_desc, 
        coalesce(cmo_office_master.office_name,'N/A') as office_name,  
        cmo_grievance_category_master.parent_office_id, cmo_office_master.office_id, 
        coalesce(upload_count.uploded, 0) as griev_upload, coalesce(fwd_count.fwd, 0) as grv_fwd, coalesce(atr_count.atr, 0) as atr_rcvd, 
        coalesce(atr_count.closed, 0) as totl_dspsd, coalesce(atr_count.bnft_prvd, 0) as srv_prvd, coalesce(atr_count.action_taken, 0) as action_taken,
        coalesce(atr_count.not_elgbl, 0) as not_elgbl, case when	(coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) <= 0 then 0
                                                            else (coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) 
                                                        end as atr_pndg,
        COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count.action_taken) = 0 THEN 0 
                            ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count.action_taken)) * 100 
                        END,2),0) AS bnft_prcnt
    from  cmo_grievance_category_master
    left join cmo_office_master on cmo_office_master.office_id = cmo_grievance_category_master.parent_office_id
    left join upload_count on cmo_grievance_category_master.grievance_cat_id = upload_count.grievance_category
    left join fwd_count on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category 
    left join atr_count on cmo_grievance_category_master.grievance_cat_id = atr_count.grievance_category
    /**** Filter ***/
    where cmo_grievance_category_master.grievance_cat_id > 0 
         and cmo_grievance_category_master.parent_office_id in (3) 
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
  -- Category Wise Resolution Status --> CMO --                   
with fwd_count as (
        select forwarded_latest_3_bh.grievance_category, count(1) as fwd
        from forwarded_latest_3_bh
        /*** Filter ***/
        where forwarded_latest_3_bh.grievance_id > 0 
             and forwarded_latest_3_bh.assigned_on::date between '2019-01-01' and '2024-12-24' 
             and forwarded_latest_3_bh.grievance_source in (5) 
        group by forwarded_latest_3_bh.grievance_category
    ),atr_count as (
        select atr_latest_14_bh.grievance_category, count(1) as atr, 
                sum(case when atr_latest_14_bh.current_status = 15 then 1 else 0 end) as closed,
                sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
                sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
        from atr_latest_14_bh 
        /*** Filter ***/
        where atr_latest_14_bh.grievance_id > 0 
             and atr_latest_14_bh.assigned_on::date between '2019-01-01' and '2024-12-24'   
             and atr_latest_14_bh.grievance_source in (5)  
        group by atr_latest_14_bh.grievance_category
    ),upload_count as (
        select grievance_master.grievance_category, count(1) as uploded from grievance_master 
        /*** Filter ***/
        where grievance_master.grievance_id > 0 
             and grievance_master.grievance_generate_date::date between '2019-01-01' and '2024-12-24'  
             and grievance_master.grievance_source in (5) 
        group by grievance_master.grievance_category
    )  
    select cmo_grievance_category_master.grievance_cat_id, cmo_grievance_category_master.grievance_category_desc, 
        coalesce(cmo_office_master.office_name,'N/A') as office_name,  
        cmo_grievance_category_master.parent_office_id, cmo_office_master.office_id, 
        coalesce(upload_count.uploded, 0) as griev_upload, coalesce(fwd_count.fwd, 0) as grv_fwd, coalesce(atr_count.atr, 0) as atr_rcvd, 
        coalesce(atr_count.closed, 0) as totl_dspsd, coalesce(atr_count.bnft_prvd, 0) as srv_prvd, coalesce(atr_count.action_taken, 0) as action_taken,
        coalesce(atr_count.not_elgbl, 0) as not_elgbl, case when	(coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) <= 0 then 0
                                                            else (coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) 
                                                        end as atr_pndg,
        COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count.action_taken) = 0 THEN 0 
                            ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count.action_taken)) * 100 
                        END,2),0) AS bnft_prcnt
    from  cmo_grievance_category_master
    left join cmo_office_master on cmo_office_master.office_id = cmo_grievance_category_master.parent_office_id
    left join upload_count on cmo_grievance_category_master.grievance_cat_id = upload_count.grievance_category
    left join fwd_count on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category 
    left join atr_count on cmo_grievance_category_master.grievance_cat_id = atr_count.grievance_category
    /**** Filter ***/
    where cmo_grievance_category_master.grievance_cat_id > 0 
                
   -- Category Wise Resolution Status --> CMO -- Without Filtte 
 with fwd_count as (
                    select forwarded_latest_3_bh.grievance_category, count(1) as fwd
                    from forwarded_latest_3_bh
                    /*** Filter ***/
                    where forwarded_latest_3_bh.grievance_id > 0 
											--                   	and forwarded_latest_3_bh.assigned_on::date between '2019-01-01' and '2024-12-24' 
											--                         and forwarded_latest_3_bh.grievance_source in (5)
                    group by forwarded_latest_3_bh.grievance_category
                ),atr_count as (
                    select atr_latest_14_bh.grievance_category, count(1) as atr, 
                            sum(case when atr_latest_14_bh.current_status = 15 then 1 else 0 end) as closed,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
                    from atr_latest_14_bh 
                    /*** Filter ***/
                    where atr_latest_14_bh.grievance_id > 0 
                          
                         
                    group by atr_latest_14_bh.grievance_category
                ),upload_count as (
                    select grievance_master.grievance_category, count(1) as uploded from grievance_master 
                    /*** Filter ***/
                    where grievance_master.grievance_id > 0 
                         
                        
                    group by grievance_master.grievance_category
                )  
                select cmo_grievance_category_master.grievance_cat_id, cmo_grievance_category_master.grievance_category_desc, 
                    coalesce(cmo_office_master.office_name,'N/A') as office_name,  
                    cmo_grievance_category_master.parent_office_id, cmo_office_master.office_id, 
                    coalesce(upload_count.uploded, 0) as griev_upload, coalesce(fwd_count.fwd, 0) as grv_fwd, coalesce(atr_count.atr, 0) as atr_rcvd, 
                    coalesce(atr_count.closed, 0) as totl_dspsd, coalesce(atr_count.bnft_prvd, 0) as srv_prvd, coalesce(atr_count.action_taken, 0) as action_taken,
                    coalesce(atr_count.not_elgbl, 0) as not_elgbl, case when	(coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) <= 0 then 0
                                                                        else (coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) 
                                                                    end as atr_pndg,
                    COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count.action_taken) = 0 THEN 0 
                                        ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count.action_taken)) * 100 
                                    END,2),0) AS bnft_prcnt
                from  cmo_grievance_category_master
                left join cmo_office_master on cmo_office_master.office_id = cmo_grievance_category_master.parent_office_id
                left join upload_count on cmo_grievance_category_master.grievance_cat_id = upload_count.grievance_category
                left join fwd_count on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category 
                left join atr_count on cmo_grievance_category_master.grievance_cat_id = atr_count.grievance_category
                /**** Filter ***/
                where cmo_grievance_category_master.grievance_cat_id > 0 
                
                
                
                
                
                
                
                
                
                
                
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------- MIS NEW REPORT BY ANANYA -----------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
-------- Office wise Grievance Resolution Status --> CMO ---------------

with fwd_count as (
                    select forwarded_latest_3_bh.assigned_to_office_id, count(1) as fwd
                    from forwarded_latest_3_bh
                    /*** Filter ***/
                    where forwarded_latest_3_bh.grievance_id > 0 
--                         and forwarded_latest_3_bh.assigned_on::date between '2019-01-01' and '2024-12-24' 
--                         and forwarded_latest_3_bh.grievance_source in (5) 
                    group by forwarded_latest_3_bh.assigned_to_office_id
                ),atr_count as (
                    select atr_latest_14_bh.assigned_by_office_id, count(1) as atr, 
                            sum(case when atr_latest_14_bh.current_status = 15 then 1 else 0 end) as closed,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
                    from atr_latest_14_bh 
                    /*** Filter ***/
                    where atr_latest_14_bh.grievance_id > 0 
--                         and atr_latest_14_bh.assigned_on::date between '2019-01-01' and '2024-12-24'   
--                         and atr_latest_14_bh.grievance_source in (5)  
                    group by atr_latest_14_bh.assigned_by_office_id
                ),atr_return_for_review as (
                    select grievance_lifecycle.assigned_to_office_id, count(1) as atr_return from grievance_lifecycle 
                    /*** Filter ***/
                    where grievance_lifecycle.grievance_id > 0 and grievance_lifecycle.grievance_status = 6
--                         and grievance_lifecycle.grievance_generate_date::date between '2019-01-01' and '2024-12-24'  
--                         and grievance_lifecycle.grievance_source in (5) 
                    group by grievance_lifecycle.assigned_to_office_id 
                )  
                select cmo_office_master.office_id,
                    coalesce(cmo_office_master.office_name,'N/A') as office_name,
                    coalesce(fwd_count.fwd, 0) as grv_fwd, 
                    coalesce(atr_count.atr, 0) as atr_rcvd,
                    coalesce(atr_count.bnft_prvd, 0) as srv_prvd,
                    coalesce(atr_count.action_taken, 0) as action_taken,
                    coalesce(atr_count.not_elgbl, 0) as not_elgbl,
                    coalesce(atr_count.closed, 0) as totl_dspsd,  
                    case when(coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) <= 0 then 0
                      else (coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) end as atr_pndg,
                    coalesce(atr_return_for_review.atr_return, 0) as atr_returned_for_reviw
--                    COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count.action_taken) = 0 THEN 0 
--                                   ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count.action_taken)) * 100 END,2),0) AS bnft_prcnt
                from cmo_office_master
                -- left join forwarded_latest_3_bh on cmo_office_master.office_id = forwarded_latest_3_bh.assigned_to_office_id
                left join atr_return_for_review on cmo_office_master.office_id = atr_return_for_review.assigned_to_office_id
                left join fwd_count on cmo_office_master.office_id = fwd_count.assigned_to_office_id 
                left join atr_count on cmo_office_master.office_id = atr_count.assigned_by_office_id
                /**** Filter ***/
--                where cmo_grievance_category_master.grievance_cat_id > 0
--                where cmo_office_master.office_id in (1)   
 
                
                
                
                
                
                -------------------------------------------------------------------------------------------------------------------------------------
 -------------------------------- Office wise Grievance Resolution Status --> CMO for perticular HOD user wise ----------------------------------------------
                -------------------------------------------------------------------------------------------------------------------------------------

with fwd_count as (
            select forwarded_latest_3_bh.assigned_to_office_id, count(1) as fwd
                    from forwarded_latest_3_bh
                    /*** Filter ***/
                    where forwarded_latest_3_bh.grievance_id > 0 
--                         and forwarded_latest_3_bh.assigned_on::date between '2019-01-01' and '2024-12-24' 
--                         and forwarded_latest_3_bh.grievance_source in (5) 
                    group by forwarded_latest_3_bh.assigned_to_office_id
       ),atr_count as (
                    select atr_latest_14_bh.assigned_by_office_id, count(1) as atr, 
                            sum(case when atr_latest_14_bh.current_status = 15 then 1 else 0 end) as closed,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
                    from atr_latest_14_bh 
                    /*** Filter ***/
                    where atr_latest_14_bh.grievance_id > 0 
--                         and atr_latest_14_bh.assigned_on::date between '2019-01-01' and '2024-12-24'
--                         and atr_latest_14_bh.grievance_source in (5)
                    group by atr_latest_14_bh.assigned_by_office_id
     ),atr_return_for_review as (
                    select grievance_lifecycle.assigned_to_office_id, count(1) as atr_return from grievance_lifecycle 
                    /*** Filter ***/
                    where grievance_lifecycle.grievance_id > 0 and grievance_lifecycle.grievance_status = 6
--                         and grievance_lifecycle.grievance_generate_date::date between '2019-01-01' and '2024-12-24'  
--                         and grievance_lifecycle.grievance_source in (5)
                    group by grievance_lifecycle.assigned_to_office_id 
                )  
                select 
                    com.office_id,
                    com.office_name,
                    coalesce(aud.official_name,'N/A') as office_name,
                    aud.admin_user_dtls_id as admin_user_id,
                    coalesce(fwd_count.fwd, 0) as grv_fwd, 
                    coalesce(atr_count.atr, 0) as atr_rcvd,
                    coalesce(atr_count.bnft_prvd, 0) as srv_prvd,
                    coalesce(atr_count.action_taken, 0) as action_taken,
                    coalesce(atr_count.not_elgbl, 0) as not_elgbl,
                    coalesce(atr_count.closed, 0) as totl_dspsd,  
                    case when(coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) <= 0 then 0
                                                            else (coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) end as atr_pndg,
                    coalesce(atr_return_for_review.atr_return, 0) as atr_returned_for_reviw
--                    COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count.action_taken) = 0 THEN 0 
--                                   ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count.action_taken)) * 100 END,2),0) AS bnft_prcnt
                from cmo_office_master com
                left join atr_return_for_review on com.office_id = atr_return_for_review.assigned_to_office_id
                left join fwd_count on com.office_id = fwd_count.assigned_to_office_id
                left join atr_count on com.office_id = atr_count.assigned_by_office_id
                left join admin_position_master apm on apm.office_id = com.office_id and apm.record_status = 1
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
                /**** Filter ***/
                where com.office_id in (1)

                
                
                
               -------------------------------------------------------------------------------------------------------------------------------------
 -------------------------------- Office wise Grievance Resolution Status --> CMO for perticular Other HOD user wise ----------------------------------------------
                -------------------------------------------------------------------------------------------------------------------------------------

with fwd_count as (
            select forwarded_latest_3_bh.assigned_to_office_id, count(1) as fwd
                    from forwarded_latest_3_bh
                    /*** Filter ***/
                    where forwarded_latest_3_bh.grievance_id > 0 
--                         and forwarded_latest_3_bh.assigned_on::date between '2019-01-01' and '2024-12-24' 
--                         and forwarded_latest_3_bh.grievance_source in (5) 
                    group by forwarded_latest_3_bh.assigned_to_office_id
       ),atr_count as (
                    select atr_latest_14_bh.assigned_by_office_id, count(1) as atr, 
                            sum(case when atr_latest_14_bh.current_status = 15 then 1 else 0 end) as closed,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
                            sum(case when atr_latest_14_bh.current_status = 15 and atr_latest_14_bh.grievance_master_closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl
                    from atr_latest_14_bh 
                    /*** Filter ***/
                    where atr_latest_14_bh.grievance_id > 0 
--                         and atr_latest_14_bh.assigned_on::date between '2019-01-01' and '2024-12-24'
--                         and atr_latest_14_bh.grievance_source in (5)
                    group by atr_latest_14_bh.assigned_by_office_id
     ),atr_return_for_review as (
                    select grievance_lifecycle.assigned_to_office_id, count(1) as atr_return from grievance_lifecycle 
                    /*** Filter ***/
                    where grievance_lifecycle.grievance_id > 0 and grievance_lifecycle.grievance_status = 6
--                         and grievance_lifecycle.grievance_generate_date::date between '2019-01-01' and '2024-12-24'  
--                         and grievance_lifecycle.grievance_source in (5)
                    group by grievance_lifecycle.assigned_to_office_id 
                )  
                select 
                    com.office_id,
                    com.office_name,
                    coalesce(aud.official_name,'N/A') as office_name,
                    aud.admin_user_dtls_id as admin_user_id,
                    coalesce(fwd_count.fwd, 0) as grv_fwd, 
                    coalesce(atr_count.atr, 0) as atr_rcvd,
                    coalesce(atr_count.bnft_prvd, 0) as srv_prvd,
                    coalesce(atr_count.action_taken, 0) as action_taken,
                    coalesce(atr_count.not_elgbl, 0) as not_elgbl,
                    coalesce(atr_count.closed, 0) as totl_dspsd,  
                    case when(coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) <= 0 then 0
                                                            else (coalesce(fwd_count.fwd, 0) - coalesce(atr_count.atr, 0)) end as atr_pndg,
                    coalesce(atr_return_for_review.atr_return, 0) as atr_returned_for_reviw
--                    COALESCE(ROUND(CASE WHEN (atr_count.bnft_prvd + atr_count.action_taken) = 0 THEN 0 
--                                   ELSE (atr_count.bnft_prvd::numeric / (atr_count.bnft_prvd + atr_count.action_taken)) * 100 END,2),0) AS bnft_prcnt
                from cmo_office_master com
                left join atr_return_for_review on com.office_id = atr_return_for_review.assigned_to_office_id
                left join fwd_count on com.office_id = fwd_count.assigned_to_office_id
                left join atr_count on com.office_id = atr_count.assigned_by_office_id
                left join admin_position_master apm on apm.office_id = com.office_id and apm.record_status = 1
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
                /**** Filter ***/
                where com.office_id in (1)
                
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------               
                
                
                

   from cmo_office_master com
                left join fwd_count on com.office_id = fwd_count.assigned_to_office_id
                left join admin_position_master apm on apm.office_id = com.office_id and apm.record_status = 1
                left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
                left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
                /**** Filter ***/
                where com.office_id in (1);
                
   select forwarded_latest_3_bh.assigned_to_office_id, count(1) as fwd, aud.official_name, aud.admin_user_dtls_id
   from forwarded_latest_3_bh
   left join cmo_office_master com on com.office_id = forwarded_latest_3_bh.assigned_to_office_id
   left join admin_position_master apm on apm.office_id = com.office_id and apm.record_status = 1
	left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
	left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
	group by forwarded_latest_3_bh.assigned_to_office_id,aud.official_name, aud.admin_user_dtls_id
   	
from admin_user_details aud
left join admin_user_position_mapping aupm on aupm.admin_user_id = aud.admin_user_id
left join admin_position_master apm on apm.position_id = aupm.position_id and apm.record_status = 1
left join cmo_office_master com on apm.office_id = com.office_id 
left join atr_return_for_review on com.office_id = atr_return_for_review.assigned_to_office_id
left join fwd_count on com.office_id = fwd_count.assigned_to_office_id
left join atr_count on com.office_id = atr_count.assigned_by_office_id
where com.office_id in (1)
                
                
 from cmo_office_master
    left join atr_return_for_review on cmo_office_master.office_id = atr_return_for_review.assigned_to_office_id
    left join fwd_count on cmo_office_master.office_id = fwd_count.assigned_to_office_id
    left join atr_count on cmo_office_master.office_id = atr_count.assigned_by_office_id
    left join admin_position_master apm on apm.office_id = cmo_office_master.office_id and apm.record_status = 1
    left join admin_user_position_mapping aupm on aupm.position_id = apm.position_id
    left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
    /**** Filter ***/
 
    
    
    
select * from grievance_lifecycle gl limit 1;

select * from admin_position_master apm where apm.office_id = 1 and apm.record_status = 1;               
select * from admin_user_position_mapping aupm where aupm.position_id in (3171);
select * from admin_user au where au.admin_user_id in (3171);
select * from admin_user_details aud where aud.admin_user_id in (1610,2526,2587,2698,2873,4);


------------------------------------------------------------------------------------------------------------------------------------------------------------------


select * from admin_position_master apm where apm.position_id = 3171;
select * from admin_user_details aud;
select * from admin_user_role_master ;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------




