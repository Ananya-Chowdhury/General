 DROP FUNCTION public.cmo_atr_district_wise(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_atr_district_wise(ssm_id integer, dept_id integer)
 RETURNS TABLE(district_name text, atr_received_count bigint, atr_pending_count bigint)
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_received_count,
                COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_districts_master cdm ON cdm.district_id = gm.district_id
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
                atr_received_count DESC,
                atr_pending_count DESC;

        ELSE
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_received_count,
                COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
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
                atr_received_count DESC,
                atr_pending_count DESC;
        END IF;
    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_received_count,
                COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
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
                atr_received_count DESC,
                atr_pending_count DESC;

        ELSE
            RETURN QUERY
            SELECT 
                cdm.district_name::text,
                COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_received_count,
                COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
            FROM 
                grievance_master gm
            LEFT JOIN
                grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
            LEFT JOIN 
                cmo_districts_master cdm ON cdm.district_id = gm.district_id 
            GROUP BY cdm.district_name
            ORDER BY
                atr_received_count DESC,
                atr_pending_count DESC;
        END IF;
    END IF;
END;
$function$
;
