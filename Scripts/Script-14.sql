DROP FUNCTION public.cmo_atr_count_district_wise(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_atr_count_district_wise(ssm_id integer, dept_id integer)
 RETURNS TABLE(atr_recevied_count bigint, atr_pending_count bigint, grievances_recieved bigint, atr_pending bigint,
 pending_grievance bigint, total_rural_count bigint, total_urban_count bigint)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		if dept_id > 0 then
			if ssm_id > 0 then
				return query
				select
--					gm.district_id,
--   					cdm.district_name,
					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    				COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
					COUNT(1) as grievances_recieved,
					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
					COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
					COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count
				from grievance_master gm
				left join grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
				LEFT JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
				where gm.grievance_source = ssm_id
				and gm.district_id IS NOT NULL
				and (gm.assigned_to_position in 
					(select apm.position_id
					from admin_position_master apm
					where apm.office_id = dept_id)
					or gm.updated_by_position in 
						(select apm.position_id
						from admin_position_master apm
						where apm.office_id = dept_id)
					);
			else
				return query
				select
--					gm.district_id,
--   					cdm.district_name,
					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    				COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
					COUNT(1) as grievances_recieved,
					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
					COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
					COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count
				from grievance_master gm
				left join grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
				LEFT JOIN cmo_districts_master cdm ON cdm.district_id = gm.district_id
				where gm.assigned_to_position in
				(select apm.position_id
				from admin_position_master apm
				where apm.office_id = dept_id)
				or gm.updated_by_position in
				(select apm.position_id
				from admin_position_master apm
				where apm.office_id = dept_id)
				and gm.district_id IS NOT NULL;
			end if;
		else
			if ssm_id > 0 then
				return query
				select
--					gm.district_id,
--   					cdm.district_name,
					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    				COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
					COUNT(1) as grievances_recieved,
					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
					COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
					COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count
					from grievance_master gm where gm.grievance_source = ssm_id;
			else
					return query
				select
--					gm.district_id,
--   					cdm.district_name,
					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_recevied_count,
    				COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
					COUNT(1) as grievances_recieved,
					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
					COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
					COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count
					from grievance_master gm;
			end if;
		end if;			
	END;
$function$
;





-- DROP FUNCTION public.cmo_atr_district_wise(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_atr_district_wise(ssm_id integer, dept_id integer)
 RETURNS TABLE(district_name text, atr_received_count bigint, atr_pending_count bigint, atr_received_count_percentage bigint, atr_pending_count_percentage bigint)
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) AS atr_received_count,
--                COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
				COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				cast(COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS atr_received_count_percentage,
				cast(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / COUNT(gm.grievance_id) as bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
               admin_position_master apm ON apm.position_id = gm.assigned_by_position
            WHERE  
                 gm.grievance_source = ssm_id
                AND (gm.assigned_to_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ) OR gm.updated_by_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ))
            GROUP BY cdm.district_name
            ORDER BY
                atr_pending_count DESC;
        ELSE
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) AS atr_received_count,
                -- COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
				COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				cast(COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS atr_received_count_percentage,
				cast(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / COUNT(gm.grievance_id) as bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_districts_master cdm ON cdm.district_id = gm.district_id
            WHERE 
                (gm.assigned_to_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ) OR gm.updated_by_position IN (
                        SELECT apm.position_id 
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id
                    ))
            GROUP BY  cdm.district_name
            ORDER BY
                atr_pending_count DESC;
        END IF;
    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) AS atr_received_count,
                -- COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
				COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				cast(COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS atr_received_count_percentage,
				cast(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / COUNT(gm.grievance_id) as bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_districts_master cdm ON cdm.district_id = gm.district_id 
            WHERE 
                gm.grievance_source = ssm_id
            GROUP BY  cdm.district_name
            ORDER BY
                atr_pending_count DESC;
        ELSE
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) AS atr_received_count,
                -- COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count,
				COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) AS atr_pending_count,
				cast(COUNT(CASE WHEN gm.status in (14, 15) THEN gm.grievance_id END) * 100.0 / COUNT(1) as bigint) AS atr_received_count_percentage,
				cast(COUNT(CASE WHEN gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17) THEN gm.grievance_id END) * 100.0 / COUNT(gm.grievance_id) as bigint) AS atr_pending_count_percentage
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_districts_master cdm ON cdm.district_id = gm.district_id 
            GROUP BY cdm.district_name
            ORDER BY
                atr_pending_count DESC;
        END IF;
    END IF;
END;
$function$
;







select * from admin_user au;
select * from cmo_office















