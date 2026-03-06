 DROP FUNCTION public.cmo_atr_count_district_wise(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_atr_count_district_wise(ssm_id integer, dept_id integer)
 RETURNS TABLE(office_name text, atr_received_count bigint, atr_pending_count bigint, atr_received_count_percentage bigint, atr_pending_count_percentage bigint)
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT 
                com.office_name::text,
                COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) AS atr_received_count,
        		COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				CAST(COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_received_count_percentage,
        		CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_office_master com on com.office_id = gm.assigned_by_office_id 
            WHERE  
                 gm.grievance_source = ssm_id
                AND (gm.assigned_by_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ) OR gm.updated_by_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ))
            GROUP BY com.office_name
            ORDER BY
                atr_pending_count DESC;
        ELSE
            RETURN QUERY
            SELECT 
                com.office_name::text,
                COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) AS atr_received_count,
        		COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				CAST(COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_received_count_percentage,
        		CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_office_master com on com.office_id = gm.assigned_by_office_id 
            WHERE (gm.assigned_by_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ) OR gm.updated_by_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ))
            GROUP BY  com.office_name
            ORDER BY
                atr_pending_count DESC;
        END IF;
    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT 
                com.office_name::text,
                COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) AS atr_received_count,
        		COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				CAST(COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_received_count_percentage,
        		CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_office_master com on com.office_id = gm.assigned_by_office_id 
            WHERE 
				gm.grievance_source = ssm_id
            GROUP BY  com.office_name
            ORDER BY
                atr_pending_count DESC;
        ELSE
            RETURN QUERY
            SELECT 
                com.office_name::text,
                COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) AS atr_received_count,
        		COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				CAST(COUNT(CASE WHEN gm.status IN (14, 15) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_received_count_percentage,
        		CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_office_master com on com.office_id = gm.assigned_by_office_id 
            GROUP BY  com.office_name
            ORDER BY
                atr_pending_count DESC;
        END IF;
    END IF;
END;
$function$
;


-- public.grievance_lifecycle_latest_3 source

CREATE OR REPLACE VIEW public.grievance_lifecycle_latest_3
AS WITH latest_3 AS (
         SELECT a.row_number,
            a.grievance_id,
            a.assigned_by_position
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS row_number,
                    gl.grievance_id,
                    gl.assigned_by_position
                   FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = 3) a
          WHERE a.row_number = 1
        ), assign_to_cmo_user_new AS (
         SELECT grievance_master.assigned_to_position,
            count(grievance_master.grievance_id) AS new_pending_count
           FROM grievance_master
          WHERE grievance_master.status = 2
          GROUP BY grievance_master.assigned_to_position
        ), assign_to_cmo_user_new_ssm AS (
         SELECT grievance_master.assigned_to_position,
            count(grievance_master.grievance_id) AS new_pending_count_ssm
           FROM grievance_master
          WHERE grievance_master.status = 2 AND grievance_master.grievance_source = 5
          GROUP BY grievance_master.assigned_to_position
        ), assign_to_cmo_user_atr AS (
         SELECT grievance_master.assigned_to_position,
            count(grievance_master.grievance_id) AS atr_pending_count
           FROM grievance_master
          WHERE grievance_master.status = 14
          GROUP BY grievance_master.assigned_to_position
        )
 SELECT apm.position_id,
    count(1) AS fwd_count,
    sum(
        CASE
            WHEN gm_ssm.grievance_source = 5 THEN 1
            ELSE 0
        END) AS ssm_count,
    COALESCE(cte1.new_pending_count, 0::bigint) AS new_grievances_pending,
    COALESCE(cte2.atr_pending_count, 0::bigint) AS pending,
    COALESCE(cte3.new_pending_count_ssm, 0::bigint) AS new_pending_count_ssm
   FROM admin_position_master apm
     JOIN admin_user_position_mapping aupm ON apm.position_id = aupm.position_id
     JOIN admin_user_details aud ON aupm.admin_user_id = aud.admin_user_id
     JOIN admin_user au ON aud.admin_user_id = au.admin_user_id
     LEFT JOIN latest_3 lat3 ON lat3.assigned_by_position = apm.position_id
     LEFT JOIN grievance_master gm_ssm ON gm_ssm.grievance_id = lat3.grievance_id
     LEFT JOIN assign_to_cmo_user_new cte1 ON cte1.assigned_to_position = apm.position_id
     LEFT JOIN assign_to_cmo_user_atr cte2 ON cte2.assigned_to_position = apm.position_id
     LEFT JOIN assign_to_cmo_user_new_ssm cte3 ON cte3.assigned_to_position = apm.position_id
  WHERE (apm.role_master_id = ANY (ARRAY[1::bigint, 2::bigint, 3::bigint, 9::bigint])) AND au.status <> 3
  GROUP BY apm.position_id, cte1.new_pending_count, cte2.atr_pending_count, cte3.new_pending_count_ssm;
  
 
 
 
 
 
 DROP FUNCTION public.cmo_grievance_counts_socials(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_socials(ssm_id integer, dept_id integer)
RETURNS TABLE(category text, total_count bigint, applicant_type smallint, social_name varchar, percentage float)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                'Caste' AS category,
                COUNT(1) AS total_count,
                gm.applicant_caste,
                ccm.caste_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
            WHERE gm.created_on >= '2023-06-08'
              AND gm.grievance_source = ssm_id
              AND (gm.assigned_to_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
                  OR gm.updated_by_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
              )
            GROUP BY gm.applicant_caste, ccm.caste_name

            UNION ALL

            SELECT
                'Religion' AS category,
                COUNT(1) AS total_count,
                gm.applicant_reigion,
                crm.religion_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
            WHERE gm.created_on >= '2023-06-08'
              AND gm.grievance_source = ssm_id
              AND (gm.assigned_to_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
                  OR gm.updated_by_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
              )
            GROUP BY gm.applicant_reigion, crm.religion_name
            ORDER BY category, social_name;

        ELSE
            RETURN QUERY
            SELECT
                'Caste' AS category,
                COUNT(1) AS total_count,
                gm.applicant_caste,
                ccm.caste_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
            WHERE gm.created_on >= '2023-06-08'
              AND (gm.assigned_to_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
                  OR gm.updated_by_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
              )
            GROUP BY gm.applicant_caste, ccm.caste_name

            UNION ALL

            SELECT
                'Religion' AS category,
                COUNT(1) AS total_count,
                gm.applicant_reigion,
                crm.religion_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
            WHERE gm.created_on >= '2023-06-08'
              AND (gm.assigned_to_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
                  OR gm.updated_by_position IN (
                    SELECT apm.position_id
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id)
              )
            GROUP BY gm.applicant_reigion, crm.religion_name
            ORDER BY category, social_name;

        END IF;

    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                'Caste' AS category,
                COUNT(1) AS total_count,
                gm.applicant_caste,
                ccm.caste_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
            WHERE gm.created_on >= '2023-06-08'
              AND gm.grievance_source = ssm_id
            GROUP BY gm.applicant_caste, ccm.caste_name

            UNION ALL

            SELECT
                'Religion' AS category,
                COUNT(1) AS total_count,
                gm.applicant_reigion,
                crm.religion_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
            WHERE gm.created_on >= '2023-06-08'
              AND gm.grievance_source = ssm_id
            GROUP BY gm.applicant_reigion, crm.religion_name
            ORDER BY category, social_name;

        ELSE
            RETURN QUERY
            SELECT
                'Caste' AS category,
                COUNT(1) AS total_count,
                gm.applicant_caste,
                ccm.caste_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_caste_master ccm ON ccm.caste_id = gm.applicant_caste
            WHERE gm.created_on >= '2023-06-08'
            GROUP BY gm.applicant_caste, ccm.caste_name

            UNION ALL

            SELECT
                'Religion' AS category,
                COUNT(1) AS total_count,
                gm.applicant_reigion,
                crm.religion_name AS social_name,
                (COUNT(1)::float / SUM(COUNT(1)) OVER ()) * 100 AS percentage
            FROM grievance_master gm
            LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion
            WHERE gm.created_on >= '2023-06-08'
            GROUP BY gm.applicant_reigion, crm.religion_name
            ORDER BY category, social_name;
        END IF;
    END IF;
END;
$function$;




CREATE OR REPLACE FUNCTION public.cmo_atr_count_district_wise(ssm_id integer, dept_id integer)
 RETURNS TABLE(office_name text, atr_received_count bigint, atr_pending_count bigint, atr_received_count_percentage bigint, atr_pending_count_percentage bigint)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
	    select com.office_name::text,
		   coalesce(table1.atr_received_count,0) as atr_received_count,
		   coalesce(table2.atr_pending_count,0) as atr_pending_count,
		   coalesce(table1.atr_received_count_percentage,0) as atr_received_count_percentage,
		   coalesce(table2.atr_pending_count_percentage,0) as atr_pending_count_percentage
	from cmo_office_master com
	left join (SELECT 
				    com.office_name::text,com.office_id,
				    COUNT(CASE WHEN gm2.status IN (14, 15) THEN gm2.grievance_id END) AS atr_received_count,
				    CAST(COUNT(CASE WHEN gm2.status IN (14, 15) THEN gm2.grievance_id END) * 100.0 / NULLIF(COUNT(gm2.grievance_id), 0) AS bigint) AS atr_received_count_percentage
				FROM cmo_office_master com
				LEFT JOIN grievance_master gm2 ON com.office_id = gm2.atr_submit_by_lastest_office_id AND (gm2.grievance_source = ssm_id OR ssm_id >= 0)
				where com.office_category = 2
				GROUP BY com.office_name, com.office_id
			  ) as table1 on com.office_id = table1.office_id
	left join (SELECT 
				    com.office_name::text,com.office_id,
				    COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				    CAST(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / NULLIF(COUNT(gm.grievance_id), 0) AS bigint) AS atr_pending_count_percentage
				FROM cmo_office_master com
				LEFT JOIN grievance_master gm ON com.office_id = gm.assigned_to_office_id AND (gm.grievance_source = ssm_id OR ssm_id >= 0)
				where com.office_category = 2
				GROUP BY com.office_name, com.office_id
			  ) as table2 on com.office_id = table2.office_id
	where office_category = 2
    ORDER by table2.atr_pending_count DESC;
END;
$function$
;


 
select
            table1.office_id,
            table1.office_name,
            coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as grv_frwd,
            coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) as atr_recvd,
            coalesce(table5.total_disposed,0) as total_disposed,
            coalesce(table6.pending_with_hod,0) as pending_with_hod,
            coalesce(grv_pendng_upto_svn_d,0) as grv_pendng_upto_svn_d,
            coalesce(grv_pendng_more_svn_d,0) as grv_pendng_more_svn_d,
            coalesce(round(((table5.total_disposed::numeric /(coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0)))* 100),2),
            0) as qual_atr_recv ,
            coalesce(ROUND(CASE WHEN pending_with_hod = 0 THEN 0
            ELSE (grv_pendng_more_svn_d::numeric / (pending_with_hod)) * 100
            END,2),0) AS percent_bynd_svn_days,
            coalesce(extract(day from (atr_av_date + disposed_av_date)),0) as avg_no_days_to_submit_atr,
            coalesce(extract(day from (atr_av_date_six + disposed_av_date_six)),0) as avg_no_days_to_submit_atr_six,
            table1.office_type,
            case 
                when office_type = 1 then 8  
                when office_type = 2 then 1
                when office_type = 3 then 2
                when office_type = 4 then 3
                when office_type = 5 then 4
                when office_type = 6 then 5
                when office_type = 7 then 6
                when office_type = 8 then 7
            end as office_ord  
        from
        (
        ---------------------- OT START -------------------------
        -- select com.office_id ,com.office_name, apm.office_type from cmo_office_master com
        -- left join admin_position_master apm on apm.office_id = com.office_id
        -- where com.office_category = 2 and com.status = 1
        -- group by com.office_id ,com.office_name,apm.office_type
        ---------------------- OT END -------------------------
        select com.office_id ,com.office_name, apm.office_type from cmo_office_master com
        left join admin_position_master apm on apm.office_id = com.office_id
        where com.office_category = 2 and com.status = 1 
        group by com.office_id ,com.office_name,apm.office_type
        ) table1
        -- grv frwded
        left outer join(
            select
                count(distinct grievance_id) as grv_frwd,
                max(grievance_generate_date) as grievance_generate_date,
                gm.assigned_to_office_id as office_id
            from
                grievance_master gm
            where
                gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
            group by
                gm.assigned_to_office_id ) table2
        on
            table1.office_id = table2.office_id
        -- atr recvd
        left outer join(
            select
                count(distinct grievance_id) as atr_recvd ,
                avg(atr_recv_cmo_date - grievance_generate_date) as atr_av_date,
                max(grievance_generate_date) as grievance_generate_date,
                gm.assigned_by_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 14
            group by
                assigned_by_office_id) table3
        on
            table1.office_id = table3.office_id
        --  total disposed 	
        left outer join(
            select
                count(1) as total_disposed,
                avg(atr_recv_cmo_date - grievance_generate_date) as disposed_av_date,
                gm.atr_submit_by_lastest_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 15
            group by
                gm.atr_submit_by_lastest_office_id
        ) table5
        on
            table1.office_id = table5.office_id	
        -- grv pending with hod
        left outer join(
            select
                count(distinct grievance_id) as pending_with_hod ,
                sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as grv_pendng_more_svn_d,
                sum(case when  CURRENT_DATE - gm.updated_on <= interval '7 days' then 1 else 0 end) as grv_pendng_upto_svn_d,
                gm.assigned_to_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
            group by
                gm.assigned_to_office_id ) table6
        on
            table1.office_id = table6.office_id
        -- atr recvd / 6 
        left outer join(
            select        
                avg(atr_recv_cmo_date - grievance_generate_date) as atr_av_date_six,
                gm.assigned_by_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 14
            group by
                assigned_by_office_id) table7
        on
            table1.office_id = table7.office_id
        --  total disposed / 6
        left outer join(
            select
                avg(atr_recv_cmo_date - grievance_generate_date) as disposed_av_date_six,
                gm.atr_submit_by_lastest_office_id  as office_id
            from
                grievance_master gm
            where
                gm.status = 15
            group by
                gm.atr_submit_by_lastest_office_id
        ) table8
            table1.office_id = table8.office_id	
        where coalesce(table2.grv_frwd,0) + coalesce(table3.atr_recvd,0) + coalesce(table5.total_disposed,0) > 0;
       
       
       
       
       
       select
        table1.office_id,
        table1.office_name,
        coalesce(table2.grv_frwd,
        0) + coalesce(table3.atr_recvd,
        0) + coalesce(table5.total_disposed,
        0) as grv_frwd,
        coalesce(table3.atr_recvd,
        0) + coalesce(table5.total_disposed,
        0) as atr_recvd,
        coalesce(table5.total_disposed,
        0) as total_disposed,
        coalesce(table6.pending_with_hod,
        0) as pending_with_hod,
        coalesce(table8.grv_pendng_upto_svn_d,
        0) as grv_pendng_upto_svn_d,
        coalesce(table9.grv_pendng_more_svn_d,
        0) as grv_pendng_more_svn_d,
        coalesce(round(((grv_pendng_more_svn_d::numeric /pending_with_hod)* 100),
        2),
        0) as percent_bynd_svn_days,
        coalesce(round(((table5.total_disposed::numeric /(coalesce(table3.atr_recvd,
        0) + coalesce(table5.total_disposed,
        0)))* 100),
        2),
        0) as qual_atr_recv ,
        coalesce(days_diff,
        0) as avg_no_days_to_submit_atr,
        coalesce(days_diff_six,
        0) as avg_no_days_to_submit_atr_six
    from
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
        where gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            apm.office_id ) table2
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
        where gm.status = 14
        group by
            apm.office_id ) table3
            on
        table1.office_id = table3.office_id
        -- total disposed 	
    left outer join(
        select
            count(1) as total_disposed,
            co.assigned_by_office_id
        from
            grievance_master gm
        join hod_cat_ofc_griev_part_table_block_munc_atr_submit_max co on
            co.grievance_id = gm.grievance_id
        where gm.status = 15
        group by
            co.assigned_by_office_id
            ) table5
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
        where gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
        group by
            gm.assigned_to_office_id ) table6
            on
        table1.office_id = table6.assigned_to_office_id
        -- pending upto svn days
    left outer join
            (
        select
            count(1) as grv_pendng_upto_svn_d,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join recvd_from_cmo_max_records cm on
            gm.grievance_id = cm.grievance_id
        where gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
            group by
                gm.assigned_to_office_id )table8
            on
        table8.assigned_to_office_id = table1.office_id
        ----grv pending more than 7 days with hod
    left outer join
            (
        select
            count(1) as grv_pendng_more_svn_d,
            gm.assigned_to_office_id
        from
            grievance_master gm
        join recvd_from_cmo_max_records cm on
            gm.grievance_id = cm.grievance_id
        where gm.status in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
                and CURRENT_DATE - cm.max_assigned_on > interval '7 days'
            group by
                gm.assigned_to_office_id )table9
            on
        table9.assigned_to_office_id = table1.office_id
        -- avg no of days submit atr
    left outer join (
        select
            ar.assigned_by_office_id,
            extract (day
        from
            avg(ar.max_assigned_on - co.max_assigned_on)) as days_diff
        from
            hod_cat_ofc_griev_part_table_block_munc_atr_submit_max ar,
            recvd_from_cmo_max_records co,
            grievance_master gm
        where
            ar.grievance_id = co.grievance_id
            and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
        group by
            ar.assigned_by_office_id
            ) table10
            on
        table10.assigned_by_office_id = table1.office_id
        --    avg no of days submit atr last 6  
    left outer join (
        select
            ar.assigned_by_office_id,
            extract (day
        from
            avg(ar.max_assigned_on - co.max_assigned_on)) as days_diff_six
        from
            hod_cat_ofc_griev_part_table_block_munc_atr_submit_max ar,
            recvd_from_cmo_max_records co,
            grievance_master gm
        where
            ar.grievance_id = co.grievance_id
            and ar.grievance_id = gm.grievance_id and co.assigned_to_office_id = ar.assigned_by_office_id
            and date(grievance_generate_date) between date (CURRENT_TIMESTAMP) - interval '6 month' and CURRENT_TIMESTAMP
        group by
            ar.assigned_by_office_id
            ) table11
            on
        table11.assigned_by_office_id = table1.office_id
        order by office_ord;
        
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
   ------ mis cmo view update ----    
WITH filtered_data AS (
            SELECT *
            FROM grievance_master gm
            WHERE grievance_generate_date BETWEEN '2019-01-01' AND '2024-11-11'
            and gm.status = 3 
            and gm.grievance_source in (5)
            and gm.received_at in (2)
                )
                SELECT  
                    table0.office_id,
                    COALESCE(table0.office_name, 'N/A') AS office_name,
                    COALESCE(table1.grv_frwd_assigned, 0) AS grievances_forwarded_assigned,
                    COALESCE(table2.atr_rcvd, 0) AS atr_received,
                    COALESCE(table3.bnft_prvd, 0) AS benefit_service_provided,
                    COALESCE(table3.action_taken, 0) AS action_taken,
                    COALESCE(table3.not_elgbl, 0) AS not_elgbl,
                    COALESCE(table3.total_closed, 0) AS total_disposed,
                    COALESCE(table4.beyond_svn_days, 0) AS beyond_svn_days,
                    COALESCE(table4.atr_pndg, 0) AS cumulative,
                    COALESCE(table5.atr_retrn_reviw_frm_cmo, 0) AS atr_return_for_review_from_cmo
                FROM
                    (SELECT 
                        DISTINCT com.office_id, 
                        com.office_name
                    FROM cmo_office_master com
                    LEFT JOIN admin_position_master apm ON apm.office_id = com.office_id
                    WHERE com.office_category = 2 AND com.status = 1
                    GROUP BY com.office_id, com.office_name) AS table0
                -- Grievances forwarded/assigned
        LEFT OUTER JOIN (
                SELECT 
                    COUNT(DISTINCT grievance_id) AS grv_frwd_assigned, 
                    gm.assigned_to_office_id AS office_id
                FROM filtered_data gm
                GROUP BY gm.assigned_to_office_id
            ) table1 ON table1.office_id = table0.office_id
                -- ATR received
        LEFT OUTER JOIN (
                    SELECT 
                        COUNT(DISTINCT grievance_id) AS atr_rcvd,
                        gm.assigned_to_office_id AS office_id
                    FROM filtered_data gm
                    WHERE gm.status IN (14, 15, 16, 17)
                    GROUP BY gm.assigned_to_office_id
                ) table2 ON table2.office_id = table0.office_id
                -- ATR closed
        LEFT OUTER JOIN (
                    SELECT 
                        COUNT(1) AS total_closed, 
                        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN 1 ELSE 0 END) AS bnft_prvd,
                        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN 1 ELSE 0 END) AS action_taken,
                        SUM(CASE WHEN gm.status = 15 AND gm.closure_reason_id NOT IN (1, 5, 9) THEN 1 ELSE 0 END) AS not_elgbl,
                        gm.atr_submit_by_lastest_office_id AS office_id 
                    FROM filtered_data gm
                    WHERE gm.status = 15
                    GROUP BY gm.atr_submit_by_lastest_office_id
                ) table3 ON table3.office_id = table0.office_id
                -- ATR pending
        LEFT OUTER JOIN (
                    SELECT 
                        COUNT(DISTINCT grievance_id) AS atr_pndg, 
                        SUM(CASE WHEN CURRENT_DATE - gm.updated_on > INTERVAL '7 days' THEN 1 ELSE 0 END) AS beyond_svn_days,
                        gm.assigned_to_office_id AS office_id
                    FROM filtered_data gm
                    WHERE gm.status NOT IN (1, 2, 14, 15, 16)
                    GROUP BY gm.assigned_to_office_id
                ) table4 ON table4.office_id = table0.office_id
                -- ATR returned for review from CMO
        LEFT OUTER JOIN (
                SELECT 
                    COUNT(grievance_id) AS atr_retrn_reviw_frm_cmo,
                    gm.assigned_to_office_id AS office_id
                FROM filtered_data gm
                WHERE gm.status = 6
                GROUP BY gm.assigned_to_office_id
            ) table5 ON table5.office_id = table0.office_id;

           
----- mis cmo view code with out update ----
select  
    table0.office_id,
    coalesce(table0.office_name,'N/A') as office_name,
    coalesce(table1.grv_frwd_assigned,0) as grievances_forwarded_assigned,
    coalesce(table2.atr_rcvd,0) as atr_received,
    coalesce(table3.bnft_prvd,0) as benefit_service_provided,
    coalesce(table3.action_taken,0) as action_taken,
    coalesce(table3.not_elgbl,0) as not_elgbl,
    coalesce(table3.total_closed,0) as total_disposed,
    coalesce(table4.beyond_svn_days, 0) as beyond_svn_days,
    coalesce(table4.atr_pndg, 0) as cumulative,
    coalesce(table5.atr_retrn_reviw_frm_cmo, 0) as atr_return_for_review_from_cmo
    from
        (SELECT 
            DISTINCT com.office_id , com.office_name
        from cmo_office_master com
        left join admin_position_master apm on apm.office_id = com.office_id
        where com.office_category = 2 and com.status = 1
        group by com.office_id, com.office_name
    ) AS table0
    -- griev frwded
    left outer join (
        select 
            count(distinct grievance_id) as grv_frwd_assigned, 
            gm.assigned_to_office_id as office_id
        from grievance_master gm 
        where grievance_generate_date between {to_date} and {from_date} 
        and gm.status NOT IN (1,2)
        {data_source}
        {received_at}
        {griv_stat}
        group by gm.assigned_to_office_id) table1 on table1.office_id = table0.office_id
-- total atr recieved
    left outer join (
        select 
            count(distinct grievance_id) as atr_rcvd,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm
        where grievance_generate_date between {to_date} and {from_date} 
        and gm.status in (14,15,16,17)
        {data_source}
        {received_at}
        {griv_stat}
        group by gm.assigned_to_office_id) table2 on table2.office_id = table0.office_id   
    -- atr closed
    left outer join (
        select 
            count(1) as total_closed, 
            sum(case when gm.status = 15 and gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.status = 15 and gm.closure_reason_id in (5,9) then 1 else 0 end) as action_taken,
            sum(case when gm.status = 15 and gm.closure_reason_id not in (1,5,9) then 1 else 0 end) as not_elgbl,
            gm.atr_submit_by_lastest_office_id  as office_id 
        from grievance_master gm 
        where grievance_generate_date between {to_date} and {from_date} 
        and gm.status = 15
        {data_source}
        {received_at}
        {griv_stat}
        group by gm.atr_submit_by_lastest_office_id) table3 on table3.office_id = table0.office_id      
-- atr pending
left outer join (
        select 
            count(distinct grievance_id) as atr_pndg, 
            sum(case when CURRENT_DATE - gm.updated_on > interval '7 days' then 1 else 0 end) as beyond_svn_days,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm 
        where grievance_generate_date between {to_date} and {from_date} 
        and gm.status not in (1,2,14,15,16)
        {data_source}
        {received_at}
        {griv_stat}
        group by gm.assigned_to_office_id) table4 on table4.office_id = table0.office_id      
-- atr returned for review from CMO during the time
left outer join (
        SELECT 
            count(grievance_id) AS atr_retrn_reviw_frm_cmo,
            gm.assigned_to_office_id  as office_id
        from grievance_master gm 
        where grievance_generate_date between {to_date} and {from_date} 
        and gm.status = 6
        {data_source}
        {received_at}
        {griv_stat}
        group by gm.assigned_to_office_id) table5 on table5.office_id = table0.office_id; 
        
       
       
       
       
       
       
       
       
       
       
       
       
       
       
create materialized view migration_testing.public.fix_hod_to_hod_atr as
select * from(
select row_number() over(partition by gl.grievance_id order by gl.assigned_on desc) as rnn,gl.* from public.grievance_lifecycle gl 
where 
	exists (select 1 from public.grievance_master gm where gl.grievance_id = gm.grievance_id and gm.status = 5))a 
where a.rnn = 1
with data;



select * from migration_testing.public.fix_hod_to_hod_atr;

select gl.grievance_id from migration_testing.public.grievance_lifecycle gl 
inner join	migration_testing.public.fix_hod_to_hod_atr mat_view on gl.grievance_id = mat_view.grievance_id 
																	and gl.grievance_status = 5
																	and gl.assigned_to_office_id = mat_view.assigned_by_office_id 
																	and gl.assigned_by_office_id = mat_view.assigned_to_office_id;
																	
																
																
select * from migration_testing.public.grievance_lifecycle gl where gl.grievance_id = 1707 order by assigned_on;












WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
         Select Count(1)  
                    from grievance_master md
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id     
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 3 
                                where (exists (select 1 from grievance_lifecycle gl where md.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 3));
--                      and replace(lower(md.pri_cont_no),' ','') like '%8101859077%' and ( md.assigned_to_office_id in ('84') or md.assigned_by_office_id in ('84')));
      
                                
                                
  ----- REal ---------                             
WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id 
                        ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
                    select distinct
                    md.grievance_id, 
                        case 
                            when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                            when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                            else null
                        end as received_from_other_hod_flag,
                        lu.grievance_status as last_grievance_status,
                        lu.assigned_on as last_assigned_on,
                        lu.assigned_to_office_id as last_assigned_to_office_id,
                        lu.assigned_by_position as last_assigned_by_position,
                        lu.assigned_to_position as last_assigned_to_position,
                        md.grievance_no ,
                        md.grievance_description,
                        md.grievance_source ,
                        null as grievance_source_name,
                        md.applicant_name ,
                        md.pri_cont_no,
                        md.grievance_generate_date ,
                        md.grievance_category,
                        cgcm.grievance_category_desc,
                        md.assigned_to_office_id,
                        com.office_name,
                        md.district_id,
                        cdm2.district_name ,
                        md.block_id ,
                        cbm.block_name ,
                        md.municipality_id ,
                        cmm.municipality_name,
                        case 
                            when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
                        when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
                        else null
                    end as block_or_municipalty_name,
                    md.gp_id,
                    cgpm.gp_name,
                    md.ward_id,
                    cwm.ward_name,
                    case 
                        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
                        ELSE NULL
                    end as gp_or_ward_name,
                    md.atn_id,
                    coalesce(catnm.atn_desc,'N/A') as atn_desc,
                    coalesce(md.action_taken_note,'N/A') as action_taken_note,
                    coalesce(md.current_atr_date,null) as current_atr_date,
                    md.assigned_to_position,
                    md.assigned_to_id,
                    case 
                        when md.assigned_to_position is null then 'N/A'
                        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                    end as assigned_to_name,
                    case
                        when md.status = 1 then md.grievance_generate_date
                        else md.updated_on -- + interval '5 hour 30 Minutes' 
                    end as updated_on,
                    md.status,
                    cdlm.domain_value as status_name,
                    cdlm.domain_abbr as grievance_status_code,
                    md.emergency_flag,
                    md.police_station_id,
                    cpsm.ps_name  
                from grievance_master md
                left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                left join admin_position_master apm on apm.position_id = md.updated_by_position 
                left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                left join cmo_wards_master cwm on cwm.ward_id = md.ward_id      
                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 3 
                            where (exists (
                                select 1
                                from grievance_lifecycle gl 
                                where md.grievance_id = gl.grievance_id 
                         and gl.assigned_to_office_id = 3
                    )
                  and replace(lower(md.pri_cont_no),' ','') like '%8101859077%' and ( md.assigned_to_office_id in ('84') or md.assigned_by_office_id in ('84'))) 
                 order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 5; 


---- Updated -----
WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id 
                        ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
                    select distinct
                    md.grievance_id, 
                        case 
                            when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                            when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                            else null
                        end as received_from_other_hod_flag,
                        lu.grievance_status as last_grievance_status,
                        lu.assigned_on as last_assigned_on,
                        lu.assigned_to_office_id as last_assigned_to_office_id,
                        lu.assigned_by_office_id as last_assigned_by_office_id,
                        lu.assigned_by_position as last_assigned_by_position,
                        lu.assigned_to_position as last_assigned_to_position,
                        md.grievance_no ,
                        md.grievance_description,
                        md.grievance_source ,
                        null as grievance_source_name,
                        md.applicant_name ,
                        md.pri_cont_no,
                        md.grievance_generate_date ,
                        md.grievance_category,
                        cgcm.grievance_category_desc,
                        md.assigned_to_office_id,
                        com.office_name,
                        md.district_id,
                        cdm2.district_name ,
                        md.block_id ,
                        cbm.block_name ,
                        md.municipality_id ,
                        cmm.municipality_name,
                        case 
                            when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
                        when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
                        else null
                    end as block_or_municipalty_name,
                    md.gp_id,
                    cgpm.gp_name,
                    md.ward_id,
                    cwm.ward_name,
                    case 
                        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
                        ELSE NULL
                    end as gp_or_ward_name,
                    md.atn_id,
                    coalesce(catnm.atn_desc,'N/A') as atn_desc,
                    coalesce(md.action_taken_note,'N/A') as action_taken_note,
                    coalesce(md.current_atr_date,null) as current_atr_date,
                    md.assigned_to_position,
                    case 
                        when md.assigned_to_office_id is null then 'N/A'
                        when md.assigned_to_office_id = 1 then 'Pending At CMO'
                        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                    end as assigned_to_office_name,
                    md.assigned_to_id,
--                    case 
--                        when md.assigned_to_position is null then 'N/A'
--                        when md.assigned_to_position = 1 then 'Pending At CMO'
--                        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
--                    end as assigned_to_name,
                    case
                        when md.status = 1 then md.grievance_generate_date
                        else md.updated_on -- + interval '5 hour 30 Minutes' 
                    end as updated_on,
                    md.status,
                    cdlm.domain_value as status_name,
                    cdlm.domain_abbr as grievance_status_code,
                    md.emergency_flag,
                    md.police_station_id,
                    cpsm.ps_name  
                from grievance_master md
                left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                left join admin_position_master apm on apm.position_id = md.updated_by_position 
                left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                left join cmo_wards_master cwm on cwm.ward_id = md.ward_id      
                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 3 
                    where (exists (select 1 from grievance_lifecycle gl where md.grievance_id = gl.grievance_id and gl.assigned_to_office_id = 3)
                  and replace(lower(md.pri_cont_no),' ','') like '%8101859077%' and (md.assigned_to_office_id in ('84') or md.assigned_by_office_id in ('84'))) 
                 order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc offset 0 limit 5;                
                
                
                
                
                
select * from cmo_office_master com order by office_id asc;  
select * from admin_position_master apm where office_id = 1;
                
                
                 
                 
                 
 SELECT 
    grievance_id,
    grievance_status,
    assigned_on,
    assigned_to_office_id,
    assigned_by_office_id,
    assigned_by_position,
    assigned_to_position
FROM (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY grievance_lifecycle.grievance_id
            ORDER BY grievance_lifecycle.assigned_on DESC -- Latest row first
        ) AS rn
    FROM grievance_lifecycle
    WHERE /*grievance_lifecycle.grievance_status IN (3, 5) -- Only consider statuses 3 and 5
      AND*/ grievance_lifecycle.grievance_id = 2166
     /* and grievance_lifecycle.assigned_by_office_id = 3*/
    and grievance_lifecycle.assigned_to_office_id = 3
) AS filtered;
WHERE rn = 1; -- Pick the overall latest row
             
      



WITH lastupdates AS (
    SELECT 
        gl.grievance_id,
        gl.grievance_status,
        gl.assigned_on,
        gl.assigned_to_office_id,
        gl.assigned_by_position,
        gl.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY gl.grievance_id, gl.assigned_to_office_id 
            ORDER BY gl.assigned_on DESC
        ) AS rn
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status IN (3, 5)
)
SELECT DISTINCT
    md.grievance_id,
    CASE 
        WHEN (lu.grievance_status = 3 OR 
             (SELECT glsubq.grievance_status 
              FROM grievance_lifecycle glsubq 
              WHERE glsubq.grievance_id = md.grievance_id 
                AND glsubq.grievance_status IN (14, 13) 
              ORDER BY glsubq.assigned_on DESC 
              LIMIT 1) = 14) THEN 0
        WHEN (lu.grievance_status = 5 OR 
             (SELECT glsubq.grievance_status 
              FROM grievance_lifecycle glsubq 
              WHERE glsubq.grievance_id = md.grievance_id 
                AND glsubq.grievance_status IN (14, 13) 
              ORDER BY glsubq.assigned_on DESC 
              LIMIT 1) = 13) THEN 1
        ELSE NULL
    END AS received_from_other_hod_flag,
    lu.grievance_status AS last_grievance_status,
    lu.assigned_on AS last_assigned_on,
    lu.assigned_to_office_id AS last_assigned_to_office_id,
    lu.assigned_by_position AS last_assigned_by_position,
    lu.assigned_to_position AS last_assigned_to_position,
    md.grievance_no,
    md.grievance_description,
    md.grievance_source,
    NULL AS grievance_source_name,
    md.applicant_name,
    md.pri_cont_no,
    md.grievance_generate_date,
    md.grievance_category,
    cgcm.grievance_category_desc,
    md.assigned_to_office_id,
    com.office_name,
    md.district_id,
    cdm2.district_name,
    md.block_id,
    cbm.block_name,
    md.municipality_id,
    cmm.municipality_name,
    CASE 
        WHEN md.address_type = 2 THEN CONCAT(cmm.municipality_name, ' ', '(M)')
        WHEN md.address_type = 1 THEN CONCAT(cbm.block_name, ' ', '(B)')
        ELSE NULL
    END AS block_or_municipalty_name,
    md.gp_id,
    cgpm.gp_name,
    md.ward_id,
    cwm.ward_name,
    CASE 
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name, ' ', '(GP)')
        ELSE NULL
    END AS gp_or_ward_name,
    md.atn_id,
    COALESCE(catnm.atn_desc, 'N/A') AS atn_desc,
    COALESCE(md.action_taken_note, 'N/A') AS action_taken_note,
    COALESCE(md.current_atr_date, NULL) AS current_atr_date,
    md.assigned_to_position,
    md.assigned_to_id,
    CASE 
        WHEN md.assigned_to_position IS NULL THEN 'N/A'
        ELSE CONCAT(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] ')
    END AS assigned_to_name,
    CASE
        WHEN md.status = 1 THEN md.grievance_generate_date
        ELSE md.updated_on
    END AS updated_on,
    md.status,
    cdlm.domain_value AS status_name,
    cdlm.domain_abbr AS grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name
FROM grievance_master md
LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
LEFT JOIN cmo_office_master com ON com.office_id = md.assigned_to_office_id
LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
LEFT JOIN cmo_domain_lookup_master cdlm 
    ON cdlm.domain_type = 'grievance_status' 
    AND cdlm.domain_code = md.status
LEFT JOIN admin_user_position_mapping aupm 
    ON aupm.position_id = md.assigned_to_position 
    AND aupm.status = 1
LEFT JOIN admin_user_details ad ON ad.admin_user_id = aupm.admin_user_id
LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position 
LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm2.designation_id
LEFT JOIN cmo_office_master com2 ON com2.office_id = apm2.office_id 
LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm2.role_master_id
LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id 
LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id
LEFT JOIN lastupdates lu 
    ON lu.rn = 1 
    AND lu.grievance_id = md.grievance_id 
    AND lu.assigned_to_office_id = 3
WHERE EXISTS (
    SELECT 1
    FROM grievance_lifecycle gl 
    WHERE md.grievance_id = gl.grievance_id 
    AND gl.assigned_to_office_id = 3
) and replace(lower(md.pri_cont_no),' ','') like '%8101859077%' and ( md.assigned_to_office_id in ('84') or md.assigned_by_office_id in ('84')) order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 5; 









SELECT 
    grievance_id,
    grievance_status,
    assigned_on,
    assigned_to_office_id,
    assigned_by_position,
    assigned_to_position
FROM (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY grievance_lifecycle.grievance_id 
            ORDER BY grievance_lifecycle.assigned_on DESC -- Latest row first
        ) AS rn
    FROM grievance_lifecycle
    WHERE /*grievance_lifecycle.grievance_status IN (3, 5) -- Only consider statuses 3 and 5
      AND*/ grievance_lifecycle.grievance_id = 2166
) AS filtered;
WHERE rn = 1; 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 

                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE /*grievance_lifecycle.grievance_status in (3,5) and*/ grievance_lifecycle.grievance_id = 2166;
                


SELECT 
    filtered.grievance_id,
    filtered.grievance_status,
    filtered.assigned_on,
    filtered.assigned_to_office_id,
    filtered.assigned_by_position,
    filtered.assigned_to_position
FROM (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id 
            ORDER BY grievance_lifecycle.assigned_on DESC
        ) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status IN (3, 5) -- Only consider statuses 3 and 5
      AND grievance_lifecycle.grievance_id = 2166
) AS filtered
WHERE filtered.rn = 1; -- Take the most recent row


SELECT 
    filtered.grievance_id,
    filtered.grievance_status,
    filtered.assigned_on,
    filtered.assigned_to_office_id,
    filtered.assigned_by_position,
    filtered.assigned_to_position
FROM (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id 
            ORDER BY 
                CASE 
                    WHEN grievance_lifecycle.grievance_status = 5 THEN 1 -- Rank 3 higher
                    WHEN grievance_lifecycle.grievance_status = 3 THEN 2 -- Rank 5 lower
                    ELSE grievance_status -- Any other statuses (if applicable)
                END,
                grievance_lifecycle.assigned_on DESC -- Then by most recent timestamp
        ) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status IN (3, 5) -- Only consider statuses 3 and 5
      AND grievance_lifecycle.grievance_id = 2166
) AS filtered
WHERE filtered.rn = 1; -- Take the highest-ranked row







WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
         Select Count(1)  
                    from grievance_master md
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id





WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
                    select distinct
                    	md.grievance_id, 
                        case 
                            when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                            when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13) then 1
                            else null
                        end as received_from_other_hod_flag,
                        lu.grievance_status as last_grievance_status,
                        lu.assigned_on as last_assigned_on,
                        lu.assigned_to_office_id as last_assigned_to_office_id,
                        lu.assigned_by_position as last_assigned_by_position,
                        lu.assigned_to_position as last_assigned_to_position,
                        md.grievance_no ,
                        md.grievance_description,
                        md.grievance_source ,
                        null as grievance_source_name,
                        md.applicant_name ,
                        md.pri_cont_no,
                        md.grievance_generate_date ,
                        md.grievance_category,
                        cgcm.grievance_category_desc,
                        md.assigned_to_office_id,
                        com.office_name,
                        md.district_id,
                        cdm2.district_name ,
                        md.block_id ,
                        cbm.block_name ,
                        md.municipality_id ,
                        cmm.municipality_name,
                        case 
                            when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
                            when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
                            else null
                        end as block_or_municipalty_name,
                        md.gp_id,
                        cgpm.gp_name,
                        md.ward_id,
                        cwm.ward_name,
                        case 
                            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
                            ELSE NULL
                        end as gp_or_ward_name,
                        md.atn_id,
                        coalesce(catnm.atn_desc,'N/A') as atn_desc,
                        coalesce(md.action_taken_note,'N/A') as action_taken_note,
                        coalesce(md.current_atr_date,null) as current_atr_date,
                        md.assigned_to_position,
                        md.assigned_to_id,
                        case 
                            when md.assigned_to_position  is null then 'N/A'
                            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                        end as assigned_to_name,
                        case
                            when md.status = 1 then md.grievance_generate_date
                            else md.updated_on -- + interval '5 hour 30 Minutes' 
                        end as updated_on,
                        md.status,
                        cdlm.domain_value as status_name,
                        cdlm.domain_abbr as grievance_status_code,
                        md.emergency_flag,
                        md.police_station_id,
                        cpsm.ps_name  
                    from grievance_master md
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id     
                                -- left join ai_validated_atn_result avar on  avar.grievance_id = md.grievance_id and avar.is_latest is true  
                                left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 3 
                                where (exists (
                                    select 1
                                    from grievance_lifecycle gl 
                                    where md.grievance_id = gl.grievance_id 
                             and gl.assigned_to_office_id = 3
                        )
                      and md.status::integer in ('3') and ( md.assigned_to_office_id in ('84') or md.assigned_by_office_id in ('84')) ) order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc  offset 0 limit 50 



                      
                      
                      
                       WITH lastupdates AS (
                    SELECT grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                )
                 Select Count(1)  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
          where lu.assigned_to_office_id = 3   and lu.grievance_status::integer in ('5')
          
          
          
          
          
          
          WITH lastupdates AS (
                        SELECT grievance_lifecycle.grievance_id,
                            grievance_lifecycle.grievance_status,
                            grievance_lifecycle.assigned_on,
                            grievance_lifecycle.assigned_to_office_id,
                            grievance_lifecycle.assigned_by_office_id,
                            grievance_lifecycle.assigned_by_position,
                            grievance_lifecycle.assigned_to_position,
                            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id 
                            ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                        FROM grievance_lifecycle
                        WHERE grievance_lifecycle.grievance_status in (3,5)
                    )
                        select distinct
                        md.grievance_id, 
                            case 
                                when (lu.grievance_status = 3 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 14) then 0
                                when (lu.grievance_status = 5 or (select glsubq.grievance_status from grievance_lifecycle glsubq where glsubq.grievance_id = md.grievance_id and glsubq.grievance_status in (14,13) order by glsubq.assigned_on desc limit 1) = 13)then 1
                                else null
                            end as received_from_other_hod_flag,
                            lu.grievance_status as last_grievance_status,
                            lu.assigned_on as last_assigned_on,
                            lu.assigned_to_office_id as last_assigned_to_office_id,
                            lu.assigned_by_office_id as last_assigned_by_office_id,
                            lu.assigned_by_position as last_assigned_by_position,
                            lu.assigned_to_position as last_assigned_to_position,
                            md.grievance_no ,
                            md.grievance_description,
                            md.grievance_source ,
                            null as grievance_source_name,
                            md.applicant_name ,
                            md.pri_cont_no,
                            md.grievance_generate_date ,
                            md.grievance_category,
                            cgcm.grievance_category_desc,
                            md.assigned_to_office_id,
                            com.office_name,
                            md.district_id,
                            cdm2.district_name ,
                            md.block_id ,
                            cbm.block_name ,
                            md.municipality_id ,
                            cmm.municipality_name,
                            case 
                                when md.address_type = 2 then CONCAT(cmm.municipality_name, ' ', '(M)')
                            when md.address_type = 1 then CONCAT(cbm.block_name, ' ', '(B)')
                            else null
                        end as block_or_municipalty_name,
                        md.gp_id,
                        cgpm.gp_name,
                        md.ward_id,
                        cwm.ward_name,
                        case 
                            WHEN md.municipality_id IS NOT NULL THEN CONCAT(cwm.ward_name, ' ', '(W)')
                            WHEN md.block_id IS NOT NULL THEN CONCAT(cgpm.gp_name,' ', '(GP)')
                            ELSE NULL
                        end as gp_or_ward_name,
                        md.atn_id,
                        coalesce(catnm.atn_desc,'N/A') as atn_desc,
                        coalesce(md.action_taken_note,'N/A') as action_taken_note,
                        coalesce(md.current_atr_date,null) as current_atr_date,
                        md.assigned_to_position,
                        case 
                            when md.assigned_to_office_id is null then 'N/A'
                            when md.assigned_to_office_id = 5 then 'Pending At CMO'
                            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                        end as assigned_to_office_name,
                        md.assigned_to_id,
    --                    case 
    --                        when md.assigned_to_position is null then 'N/A'
    --                        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
    --                    end as assigned_to_name,
                        case
                            when md.status = 1 then md.grievance_generate_date
                            else md.updated_on -- + interval '5 hour 30 Minutes' 
                        end as updated_on,
                        md.status,
                        cdlm.domain_value as status_name,
                        cdlm.domain_abbr as grievance_status_code,
                        md.emergency_flag,
                        md.police_station_id,
                        cpsm.ps_name  
                    from grievance_master md
                    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                    left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
                       where lu.assigned_to_office_id = 3  

                       
    select * from cmo_grievance_category_master cgcm ;