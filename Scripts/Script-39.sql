with cte1 as (
                select a.assigned_to_id, a.grievance_id, a.assigned_on from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn,  
                        assigned_to_id, grievance_id, assigned_on 
                    from grievance_lifecycle gl 
                    where gl.grievance_status in (8,10) and gl.assigned_by_position = 9904
                )a 
                inner join grievance_master gm on gm.grievance_id = a.grievance_id and gm.grievance_source in (5)
                where a.rnn = 1
            ), cte2 as (
                select assigned_by_id, count(1) as atr_count, sum(case when atn_id = 6 then 1 else 0 end) as bnft_provided,
                    sum(case when atn_id IN (9,12) then 1 else 0 end) as actn_intiated, sum(case when atn_id NOT IN (6,9,12) then 1 else 0 end) as non_actnable  
                from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, assigned_by_id, atn_id
                    from grievance_lifecycle gl 
                    where gl.grievance_status = 9 and gl.assigned_to_position = 9904 
                )a 
                where a.rnn = 1 group by 1
            ),cte3 as (
                select assigned_to_id , count(1) as send_for_review from grievance_lifecycle gl where gl.grievance_status = 10 and gl.assigned_by_position = 9904 group by 1
            )
            select aud.official_name as office_name, 
                cte1.assigned_to_id as admin_user_id, 
                coalesce(count(cte1.assigned_to_id),0) as grievances_assigned,
                coalesce(cte2.bnft_provided,0) as benefit_service_provided, 
                coalesce(cte2.actn_intiated,0) as action_taken, 
                coalesce(cte2.non_actnable,0) as not_elgbl, 
                coalesce(cte2.atr_count,0) as total_received,
                sum(case when pndg.days_diff > 7 then 1 else 0 end) as beyond_svn_days,
                sum(case when gm.status in (8,10) and gm.assigned_to_id = cte1.assigned_to_id then 1 else 0 end) as cumulative_pendency,
                coalesce(cte3.send_for_review,0) as atr_return_for_review_to_so_user
            from cte1
            left join cte2 on cte1.assigned_to_id = cte2.assigned_by_id
            left join cte3 on cte1.assigned_to_id = cte3.assigned_to_id
            left join grievance_master gm on gm.grievance_id = cte1.grievance_id
            left join pending_for_so_user_wise pndg on gm.grievance_id = pndg.grievance_id
            left join admin_user_details aud on aud.admin_user_id = cte1.assigned_to_id
            where assigned_on::date between '2019-01-01' and '2024-12-04' 
            group by aud.official_name, cte1.assigned_to_id, cte2.atr_count, cte2.bnft_provided, cte2.actn_intiated, cte2.non_actnable, cte3.send_for_review;
            
           
           
           
      with receive_from as (
                select assigned_by_office_id, assigned_by_position, count(a.grievance_id) as total_grievances_rcv 
                from (SELECT gl.grievance_id, gl.assigned_by_office_id, gl.assigned_by_position,
                        row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
                FROM grievance_lifecycle gl
                inner join admin_position_master apm on apm.position_id = gl.assigned_to_position 
                where gl.grievance_status in (7,12) and apm.sub_office_id = 2
            	      and exists (select 1 from grievance_master gm where date(grievance_generate_date) between '2024-12-04' and '2024-12-04' and gl.grievance_id = gm.grievance_id  ) 
                )a 
                where rn = 1
                group by 1,2
            ),atr_submit as (
                select assigned_to_office_id, assigned_to_position, count(grievance_id) as total_grievances_atr  
                from (SELECT gl.grievance_id, gl.assigned_to_office_id, gl.assigned_to_position,
                        row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
                FROM grievance_lifecycle gl
                inner join admin_position_master apm on apm.position_id = gl.assigned_by_position 
                where gl.grievance_status = 11 and apm.sub_office_id = 2
                      and exists (select 1 from grievance_master gm where date(grievance_generate_date) between '2024-12-04' and '2024-12-04' and gl.grievance_id = gm.grievance_id  ) 
                )a where rn = 1
                group by 1,2
            ), atr_pending as (
                select gm.assigned_by_office_id, gm.updated_by_position, count(gm.grievance_id) as pending ,
                        sum(case when pfsow.days_diff > 7 then 1 else 0 end) as beyond_7_days
                from grievance_master gm 
                    inner join admin_position_master apm on gm.assigned_to_position = apm.position_id 
                    left join pending_for_sub_office_wise pfsow on pfsow.grievance_id = gm.grievance_id
                    where apm.sub_office_id = 2 and gm.status in (7,8,10,12) and date(grievance_generate_date) between '2024-12-04' and '2024-12-04'  
                group by 1,2
            )
            select com.office_name,aud.official_name, 
                coalesce(rf.total_grievances_rcv,0) as  grv_rcvd, 
                coalesce(asub.total_grievances_atr,0) as  atr_submit,
                coalesce(apen.beyond_7_days, 0) as atr_pending_bynd_svn,
                coalesce(apen.pending, 0) as atr_pending
            from receive_from rf
            left join atr_submit asub on asub.assigned_to_office_id = rf.assigned_by_office_id and asub.assigned_to_position = rf.assigned_by_position
            left join atr_pending apen on apen.assigned_by_office_id = rf.assigned_by_office_id and apen.updated_by_position = rf.assigned_by_position
            left join cmo_office_master com on com.office_id = rf.assigned_by_office_id
            left join admin_user_position_mapping aupm on aupm.position_id = rf.assigned_by_position
            left join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
            left join admin_user au on aud.admin_user_id = au.admin_user_id
            where au.status != 3;
            
           
           
           
           
           with cte1 as (
            select  a.grievance_id, a.assigned_on, a.assigned_by_office_id, a.assigned_to_office_id from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, 
                        assigned_by_office_id, assigned_on ,grievance_id, gl.assigned_to_office_id
                    from grievance_lifecycle gl where gl.grievance_status in (3,5) and gl.assigned_to_office_id = 2
            )a 
            inner join grievance_master gm on gm.grievance_id = a.grievance_id and gm.grievance_source in (5)
            where a.rnn = 1
        ),cte2 as (
            select a.assigned_to_office_id, count(1) as atr_sent, sum(case when atn_id = 6 then 1 else 0 end) as bnft_provided,
                sum(case when atn_id IN (9,12) then 1 else 0 end) as actn_intiated, sum(case when atn_id NOT IN (6,9,12) then 1 else 0 end) as non_actnable  
                from (
                    select row_number() over(partition by grievance_id order by assigned_on desc) as rnn, assigned_to_office_id,atn_id
                        from grievance_lifecycle gl 
                    where gl.grievance_status in (14,13) and gl.assigned_by_office_id = 2
            )a 
            where a.rnn = 1 group by 1
        ),cte3 as (
            select assigned_by_office_id, count(1) as review_send
            from grievance_lifecycle gl where gl.grievance_status = 6 and gl.assigned_to_office_id = 2
            group by 1
        ) select 
                com.office_name,count(1) as grievances_received, 
                coalesce(cte2.bnft_provided,0) as benefit_service_provided,
                coalesce(cte2.actn_intiated,0) as action_taken,
                coalesce(cte2.non_actnable,0) as not_elgbl,
                coalesce(cte2.atr_sent,0) as total_submitted,
                sum(case 
                        when com.office_category = 1 and pndhd.days_diff > 7 then 1
                        when com.office_category = 2 and pndohd.days_diff > 7 then 1 
                        else 0 
                    end) as beyond_svn_days,   
                sum(case when gm.assigned_to_office_id = cte1.assigned_to_office_id then 1 else 0 end) as cumulative_pendency,
                coalesce(cte3.review_send,0) as atr_return_for_review_from_cmo_other_hod
        from cte1
        left join cte2 on cte1.assigned_by_office_id = cte2.assigned_to_office_id
        left join cte3 on cte1.assigned_by_office_id = cte3.assigned_by_office_id
        left join cmo_office_master com on com.office_id = cte1.assigned_by_office_id
        left join grievance_master gm on gm.grievance_id = cte1.grievance_id
        left join pending_for_hod_wise pndhd on gm.grievance_id = pndhd.grievance_id and com.office_category = 1
        left join pending_for_other_hod_wise pndohd on gm.grievance_id = pndohd.grievance_id and com.office_category != 1
        where cte1.assigned_on::date between date (CURRENT_TIMESTAMP) - interval '1 month' and CURRENT_TIMESTAMP 
        group by com.office_name,cte2.atr_sent,cte2.bnft_provided, cte2.actn_intiated, cte2.non_actnable, cte3.review_send;
        
       
       
 WITH latest_row AS (
                    SELECT 
                        COUNT(a.grievance_id) AS grievances_forwarded, 
                        a.assigned_to_office_id, 
                        a.assigned_by_office_id
                    FROM(select 
                            gl.assigned_to_office_id, 
                            gl.assigned_by_office_id, 
                            gl.grievance_status, 
                            gl.grievance_id,
                            ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn 
                        FROM grievance_lifecycle gl
                        WHERE gl.assigned_by_office_id = 2 
                        AND gl.grievance_status IN (4, 5, 6, 13, 14, 15)
                        and gl.assigned_to_office_id != 2
                        ) a 
                    WHERE rnn = 1     
                    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
                ),
                return_for_review AS (
                    SELECT 
                        COUNT(a.grievance_id) AS atr_returned_for_review, 
                        a.assigned_to_office_id, 
                        a.assigned_by_office_id
                    FROM(select 
                            gl.assigned_to_office_id, 
                            gl.assigned_by_office_id, 
                            gl.grievance_status, 
                            gl.grievance_id,
                            ROW_NUMBER() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn
                        FROM grievance_lifecycle gl
                        WHERE gl.assigned_by_office_id = 2 
                        AND gl.grievance_status = 6 
                        and gl.assigned_to_office_id != 2
                        ) a 
                    WHERE rnn = 1 
                    GROUP BY a.assigned_to_office_id, a.assigned_by_office_id
                )
                SELECT  
                    com.office_name as office_name,
                    latest_row.assigned_to_office_id,
                    latest_row.assigned_by_office_id,
                    latest_row.grievances_forwarded as grievances_forwarded,
                    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END), 0) AS benefit_service_provided,
                    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END), 0) AS action_taken,
                    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END), 0) AS not_elgbl,
                    COALESCE(SUM(CASE WHEN gm.status = 15 AND gm.atr_submit_by_lastest_office_id = latest_row.assigned_by_office_id THEN 1 ELSE 0 END), 0) AS total_disposed,
                    COALESCE(SUM(CASE WHEN gm.assigned_by_office_id = 2 AND gm.status IN (1, 2, 14, 15, 16, 17) THEN 1 ELSE 0 END), 0) AS pending,
                    return_for_review.atr_returned_for_review as atr_returned_for_review
                FROM latest_row 
                left join return_for_review on return_for_review.assigned_to_office_id = latest_row.assigned_to_office_id
                left JOIN grievance_master gm ON gm.assigned_to_office_id = latest_row.assigned_to_office_id
                left JOIN cmo_office_master com ON com.office_id = latest_row.assigned_to_office_id
                and (case 
                        when gm.status = 1 then gm.grievance_generate_date::date 
                        else gm.updated_on::date 
			        end) between '2019-01-01' and '2024-12-04'
                GROUP BY 
                    com.office_name, 
                    latest_row.grievances_forwarded,
                    return_for_review.atr_returned_for_review, 
                    latest_row.assigned_to_office_id,
                    latest_row.assigned_by_office_id;
                    
   SELECT  
                table0.grievance_cat_id,
                table0.grievance_category_desc,
                table0.office_id,
                COALESCE(table0.office_name, 'N/A') AS office_name,
                COALESCE(table1.grv_rcvd, 0) AS grievances_received_from_cmo,
                COALESCE(table2.grv_frwd_to_suboff, 0) AS grievances_forwarded_to_suboffice,
                COALESCE(table3.grv_frwd_to_othr_hod, 0) AS grievances_forwarded_to_other_hod,
                COALESCE(table2.grv_frwd_to_suboff, 0) + COALESCE(table3.grv_frwd_to_othr_hod, 0) AS total_grievance_forwarded,
                COALESCE(table4.atr_rcvd_from_suboff, 0) AS atr_received_from_sub_office,
                COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS atr_received_from_other_hods,
                COALESCE(table4.atr_rcvd_from_suboff, 0) + COALESCE(table5.atr_rcvd_from_othr_hods, 0) AS total_atr_received,
                COALESCE(table6.atr_rcvd_from_cmo, 0) AS atr_received_from_cmo
            FROM (
                SELECT 
                    DISTINCT cgcm.grievance_cat_id, 
                    cgcm.grievance_category_desc, 
                    com.office_id AS office_id,
                    com.office_name
                FROM cmo_grievance_category_master cgcm
                LEFT JOIN cmo_office_master com ON cgcm.parent_office_id = com.office_id
                WHERE cgcm.status = 1
            ) table0
            -- Grievances received from CMO
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS grv_rcvd
                FROM cat_offc_grievances cog 
                where (case 
                        when cog.status = 1 then cog.grievance_generate_date::date 
                        else cog.updated_on::date 
			    end) between '2019-01-01' and '2024-12-04'
                and cog.status NOT IN (3)
              GROUP BY cog.grievance_cat_id
            ) table1 ON table0.grievance_cat_id = table1.grievance_cat_id
            -- Grievances forwarded to suboffice
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS grv_frwd_to_suboff
                FROM cat_offc_grievances cog 
                where (case 
                        when cog.status = 1 then cog.grievance_generate_date::date 
                        else cog.updated_on::date 
			    end) between '2019-01-01' and '2024-12-04'  
                and cog.status NOT IN (1, 2, 3, 4)
               GROUP BY cog.grievance_cat_id
            ) table2 ON table0.grievance_cat_id = table2.grievance_cat_id
            -- Grievances forwarded to other HOD
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS grv_frwd_to_othr_hod
                FROM cat_offc_grievances cog 
                where (case 
                        when cog.status = 1 then cog.grievance_generate_date::date 
                        else cog.updated_on::date 
			    end) between '2019-01-01' and '2024-12-04'  
                and cog.status IN (5, 6, 13, 14, 15, 16, 17)
               GROUP BY cog.grievance_cat_id
            ) table3 ON table0.grievance_cat_id = table3.grievance_cat_id
            -- ATR received from suboffice
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS atr_rcvd_from_suboff
                FROM cat_offc_grievances cog 
                where (case 
                        when cog.status = 1 then cog.grievance_generate_date::date 
                        else cog.updated_on::date 
			    end) between '2019-01-01' and '2024-12-04'  
                and cog.status IN (9, 10, 11, 12, 14, 15)
               GROUP BY cog.grievance_cat_id
            ) table4 ON table0.grievance_cat_id = table4.grievance_cat_id
            -- ATR received from other HODs
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS atr_rcvd_from_othr_hods
                FROM cat_offc_grievances cog 
                where (case 
                        when cog.status = 1 then cog.grievance_generate_date::date 
                        else cog.updated_on::date 
			    end) between '2019-01-01' and '2024-12-04'  
                and cog.status IN (13, 14, 15, 16, 17)
              GROUP BY cog.grievance_cat_id
            ) table5 ON table0.grievance_cat_id = table5.grievance_cat_id
            -- ATR sent to CMO
            LEFT JOIN (
                SELECT 
                    cog.grievance_cat_id,
                    COUNT(1) AS atr_rcvd_from_cmo
                FROM cat_offc_grievances cog 
                where (case 
                        when cog.status = 1 then cog.grievance_generate_date::date 
                        else cog.updated_on::date 
			    end) between '2019-01-01' and '2024-12-04' 
                and cog.status IN (14, 15)
                GROUP BY cog.grievance_cat_id
            ) table6 ON table0.grievance_cat_id = table6.grievance_cat_id where table0.office_id in (1);                
                   
                   
select count(1) from grievance_lifecycle gl where gl.assigned_by_position = 10439 and gl.grievance_status in (8,10);



















 select 
            table1.unit_id as unit_id,
            table1.unit_name as unit_name,
            table1.district_id,
            coalesce(table1.grv_lodged ,0) + coalesce(table6.total_disposed,0) + coalesce(table2.atr_recvd,0) as grv_lodged,
            coalesce(table3.grv_frwded,0) + coalesce(table6.total_disposed,0) + coalesce(table2.atr_recvd,0) as grv_frwded,
            -- atr submitted
            coalesce(table2.atr_recvd,0) + coalesce(table6.total_disposed,0) as atr_recvd,
            coalesce(table10.atr_pedng,0) as atr_pedng,
            coalesce(table6.total_disposed,0) as total_disclosed,
            coalesce(table6.srvc_prvd,0) as bnft_prvd,
            coalesce(table6.action_initiated,0) as action_taken,
            coalesce(table6.not_elgbl,0) as not_elgbl
    from
        (select
            count(1) as grv_lodged,
            md_grv.district_id,
            md_grv.office_id,
            case 
                WHEN md_grv.municipality_id IS NOT NULL THEN md_grv.ward_id
                WHEN md_grv.block_id IS NOT NULL THEN md_grv.gp_id
                ELSE NULL
            end as unit_id,
            case 
                WHEN md_grv.municipality_id IS NOT NULL THEN CONCAT(md_grv.ward_name, ' ', '(W)',' (',md_grv.municipality_name,')')
                WHEN md_grv.block_id IS NOT NULL THEN CONCAT(md_grv.gp_name, ' ', '(GP)',' (',md_grv.block_name,')')
                ELSE NULL
            end as unit_name,
            md_grv.address_type
        from
            hod_cat_offc_grievances_partitioned_table_block_munc md_grv
        where
            date(grievance_generate_date) between '2019-01-01' and '2024-12-04' and
            md_grv.status in (3, 4, 5, 6, 7, 8, 9, 10, 11,12,13,16,17)
            and md_grv.office_id in (1) 
            and md_grv.district_id in (9)
            and md_grv.sub_division_id in (8) 
            and md_grv.police_station_id in (35)
             and md_grv.municipality_id in (6) or md_grv.block_id in (15) 
             and md_grv.ward_id in (113) or  md_grv.gp_id in (146) 
             and md_grv.grievance_source in (1)       
        group by
            unit_name,
            unit_id,
            md_grv.district_id,
            md_grv.office_id,
            md_grv.address_type,
            ----
            md_grv.municipality_id,
            md_grv.ward_id,
            md_grv.block_id,
            md_grv.gp_id,
            md_grv.ward_name,
            md_grv.municipality_name,
            md_grv.gp_name,
            md_grv.block_name
            ---------
        order by
        unit_name
    ) table1 
    left outer join 
    (
        select
            count(1) as atr_recvd,
             case 
                WHEN md_grv.municipality_id IS NOT NULL THEN md_grv.ward_id
                WHEN md_grv.block_id IS NOT NULL THEN md_grv.gp_id
                ELSE NULL
            end as unit_id,
            md_grv.by_office_id,
            md_grv.address_type
        from
            hod_cat_offc_grievances_partitioned_table_block_munc md_grv
        where
            date(grievance_generate_date) between '2019-01-01' and '2024-12-04' and
            md_grv.status in (14)
             and md_grv.grievance_source in (1) 
        group by
            unit_id,
            md_grv.by_office_id,
            md_grv.address_type,
            -----
               md_grv.municipality_id,
            md_grv.ward_id,
            md_grv.block_id,
            md_grv.gp_id
            ---------
    )table2
    on table2.unit_id = table1.unit_id  and table2.by_office_id = table1.office_id
    left outer join 
    (
        select
            count(1) as grv_frwded,
            case 
                WHEN md_grv.municipality_id IS NOT NULL THEN md_grv.ward_id
                WHEN md_grv.block_id IS NOT NULL THEN md_grv.gp_id
                ELSE NULL
            end as unit_id,
            md_grv.office_id,
            md_grv.address_type
        from
            hod_cat_offc_grievances_partitioned_table_block_munc md_grv
        where
            date(grievance_generate_date) between '2019-01-01' and '2024-12-04' and
            md_grv.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,16,17)
             and md_grv.grievance_source in (1) 
        group by
            unit_id,
            md_grv.office_id,
            md_grv.address_type,
              ----
            md_grv.municipality_id,
            md_grv.ward_id,
            md_grv.block_id,
            md_grv.gp_id
            ---------
    )table3
    on table3.unit_id = table1.unit_id  and table3.office_id = table1.office_id
    left outer join 
    (
    select
        count(1) as total_disposed,
        sum(case when md_grv.status = 15 and md_grv.closure_reason_id = 1 then 1 else 0 end) as srvc_prvd,
        sum(case when md_grv.status = 15 and md_grv.closure_reason_id in (5, 9) then 1 else 0 end) as action_initiated,
        sum(case when md_grv.status = 15 and md_grv.closure_reason_id not in (1, 5, 9) then 1 else 0 end) as not_elgbl,
        case 
            WHEN md_grv.municipality_id IS NOT NULL THEN md_grv.ward_id
            WHEN md_grv.block_id IS NOT NULL THEN md_grv.gp_id
            ELSE NULL
        end as unit_id,
        md_grv.address_type,
        md_grv.atr_submit_by_lastest_office_id
    from
        hod_cat_offc_grievances_partitioned_table_block_munc md_grv
    where
        date(grievance_generate_date) between '2019-01-01' and '2024-12-04' and
        md_grv.status = 15 
         and md_grv.grievance_source in (1) 
    group by 
        unit_id,
        md_grv.address_type,
        md_grv.atr_submit_by_lastest_office_id,
          ----
            md_grv.municipality_id,
            md_grv.ward_id,
            md_grv.block_id,
            md_grv.gp_id
            ---------
    )table6 
    on table6.unit_id = table1.unit_id and table6.atr_submit_by_lastest_office_id = table1.office_id
    left outer join 
    (
    select
        count(1) as atr_pedng,
        md_grv.office_id,
        case 
            WHEN md_grv.municipality_id IS NOT NULL THEN md_grv.ward_id
            WHEN md_grv.block_id IS NOT NULL THEN md_grv.gp_id
            ELSE NULL
        end as unit_id,
        md_grv.address_type
    from
        hod_cat_offc_grievances_partitioned_table_block_munc md_grv
    where
        date(grievance_generate_date) between '2019-01-01' and '2024-12-04' and
        md_grv.status in (3,4,5,6,7,8,9,10,11,12,13,16,17)
         and md_grv.grievance_source in (1) 
    group by 
        unit_id,
        md_grv.office_id,
        md_grv.address_type,
          ----
            md_grv.municipality_id,
            md_grv.ward_id,
            md_grv.block_id,
            md_grv.gp_id
            ---------
    )table10
    on table10.unit_id = table1.unit_id and table10.office_id = table1.office_id