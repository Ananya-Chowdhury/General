refresh materialized view pending_for_hod_wise_mat;
refresh materialized view pending_for_hod_wise_mat_2;
refresh materialized view pending_for_hod_wise_last_six_months_mat;
refresh materialized view pending_for_hod_wise_last_six_months_mat_2;
refresh materialized view forwarded_latest_8_bh_mat_1;
refresh materialized view forwarded_latest_8_bh_mat_2;
refresh materialized view forwarded_latest_7_bh_mat_1;
refresh materialized view forwarded_latest_7_bh_mat_2;
refresh materialized view atr_latest_9_bh_mat_1;
refresh materialized view atr_latest_9_bh_mat_2;
refresh materialized view atr_latest_11_bh_mat_1;
refresh materialized view atr_latest_11_bh_mat_2;
refresh materialized view pending_for_so_wise_mat_1;
refresh materialized view pending_for_so_wise_mat_2;
refresh materialized view pending_for_hoso_wise_mat_1;
refresh materialized view pending_for_hoso_wise_mat_2;
refresh materialized view pending_for_other_hod_wise_mat_;
refresh materialized view pending_for_other_hod_wise_mat_2;
refresh materialized view pending_for_other_hod_wise_last_six_months_mat_;
refresh materialized view pending_for_other_hod_wise_last_six_months_mat_2;
refresh materialized view atr_latest_13_14_bh_mat;
refresh materialized view atr_latest_13_bh_mat;
refresh materialized view atr_latest_13_bh_mat_2;
refresh materialized view atr_latest_14_bh_mat;
refresh materialized view atr_latest_14_bh_mat_2;
refresh materialized view atr_review_latest_6_mat_view1;
refresh materialized view atr_review_latest_6_mat_view2;
refresh materialized view direct_close_bh_mat;
refresh materialized view direct_close_bh_mat_v1;
refresh materialized view forwarded_latest_3_5_bh_mat;
refresh materialized view forwarded_latest_3_bh_mat;
refresh materialized view forwarded_latest_3_bh_mat_2;
refresh materialized view forwarded_latest_5_bh_mat;
refresh materialized view forwarded_latest_5_bh_mat_2;
refresh materialized view grievance_lifecycle_bh_mat;
refresh materialized view grievance_master_bh_mat;
refresh materialized view grievance_master_bh_mat_2;
refresh materialized view master_district_block_grv_mat_view;


SELECT * 
FROM public.user_otp uo  
WHERE uo.u_phone = '6292222444'
ORDER BY created_on desc limit 5;
 --9932145454 HOD 
-- 8373069006 HOSO of DM south 24 paragana office 59
-- 6292222444 DM south 24 paragana





--- Category Wise Pending Grievances at Other HoDs [ HoD ] QUERY :: --
with forwarded_count as (
    select bh.grievance_category, bh.assigned_to_office_id, count(1) as forwarded 	
    from forwarded_latest_5_bh_mat_2 as bh  
    where 1 = 1  and bh.assigned_by_office_id in (75)   and bh.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP::date 
    group by bh.grievance_category, bh.assigned_to_office_id
), atr_received as (
    select bh.grievance_category, bh.assigned_by_office_id, count(1) as atr_received 
    from atr_latest_13_bh_mat_2 as bh 
    where 1 = 1  and bh.assigned_to_office_id in (75)   and bh.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP::date 
    group by bh.grievance_category, bh.assigned_by_office_id
), pending_count as (
        select bh.grievance_category, bh.assigned_to_office_id, count(1) as pending,
        sum(case when ba.days_diff >= 7 then 1 else 0 end) as beyond_7_d
    from forwarded_latest_5_bh_mat_2 as bh
    left join pending_for_other_hod_wise_mat_2 as ba on bh.grievance_id = ba.grievance_id
    where not exists (select 1 from atr_latest_13_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
     and bh.assigned_by_office_id in (75)   and bh.assigned_on::date between '2019-01-01'::date and CURRENT_TIMESTAMP::date 
    group by bh.assigned_to_office_id, bh.grievance_category 
), processing_unit as (
    select 
        '2025-02-04 12:30:02.038000+00:00':: timestamp as refresh_time_utc,
        '2025-02-04 12:30:02.038000+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        coalesce(com.office_name,'N/A') as office_name,
        cgcm.grievance_category_desc,
        com.office_id,
        cgcm.parent_office_id,
            coalesce(fc.forwarded, 0) AS grv_forwarded,
            coalesce(atr.atr_received, 0) AS atr_received,
            coalesce(pc.beyond_7_d, 0) AS atr_pending_beyond_7d,
            coalesce(pc.pending, 0) AS atr_pending
        from forwarded_count fc
        left join cmo_office_master com on com.office_id = fc.assigned_to_office_id    
        left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = fc.grievance_category
        left join atr_received atr on atr.assigned_by_office_id = com.office_id and cgcm.grievance_cat_id = atr.grievance_category
        left join pending_count pc on pc.assigned_to_office_id = com.office_id and cgcm.grievance_cat_id = pc.grievance_category
        where 1 = 1
            
            
        order by com.office_name, cgcm.grievance_category_desc
)
select
    row_number() over() as sl_no,
    processing_unit.*
from processing_unit;

