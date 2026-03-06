with fwd_count as (
                        select bh.grievance_category, count(1) as _fwd_ 
                        from forwarded_latest_3_bh_mat as bh
                        where bh.grievance_category > 0    and bh.assigned_to_office_id = 3 
                        group by bh.grievance_category
                    ), atr_count as (
                        select bh.grievance_category, count(1) as _atr_, 
                            sum(case when bh.current_status = 15 then 1 else 0 end) as _clse_,
                            sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                            sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as matter_taken_up
                        from atr_latest_14_bh_mat as bh
                        where bh.grievance_category > 0 and bh.current_status in (14,15)    and bh.assigned_by_office_id = 3 
                        group by bh.grievance_category
                    ), pending_count as (
                        select bh.grievance_category, count(1) as _pndddd_ , avg(pm.days_diff) as _avg_pending_
                        from forwarded_latest_3_bh_mat as bh
                        inner join pending_for_hod_wise_mat as pm on bh.grievance_id = pm.grievance_id
                        where not exists (select 1 from atr_latest_14_bh_mat as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
                           and bh.assigned_to_office_id = 3 
                        group by bh.grievance_category
                    ) select 
                            '2025-01-22 11:30:01.225606+00:00'::timestamp as refresh_time_utc,
                            row_number() over() as sl_no,
                            cgcm.grievance_cat_id, 
                            cgcm.grievance_category_desc, 
                            coalesce(com.office_name,'N/A') as office_name,
                            cgcm.parent_office_id, 
                            com.office_id, 
                            coalesce(fc._fwd_, 0) as grievances_received,
                            coalesce(ac._clse_, 0) as grievances_disposed,  
                            coalesce(ac.bnft_prvd, 0) as benefit_provided, 
                            coalesce(ac.matter_taken_up, 0) as matter_taken_up,
                            coalesce(pc._pndddd_, 2) as grievances_pending,
                            coalesce(round(pc._avg_pending_, 0)) as days_diff,
                            coalesce(ROUND(CASE WHEN (ac.bnft_prvd + ac.matter_taken_up) = 0 THEN 0 
                            ELSE (ac.bnft_prvd::numeric / (ac.bnft_prvd + ac.matter_taken_up)) * 100 END,2),0) AS bsp_percentage
                    from cmo_grievance_category_master cgcm
                    left join cmo_office_master com on com.office_id = cgcm.parent_office_id
                    left join atr_count ac on cgcm.grievance_cat_id = ac.grievance_category
                    left join pending_count pc on cgcm.grievance_cat_id = pc.grievance_category
                    left join fwd_count fc on cgcm.grievance_cat_id = fc.grievance_category
                    where cgcm.grievance_cat_id  > 0 and coalesce(fc._fwd_, 0) > 0
                    order by cgcm.grievance_category_desc;