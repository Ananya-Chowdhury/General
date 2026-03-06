
CREATE MATERIALIZED VIEW public.pending_for_other_hod_wise_last_six_months_mat_
TABLESPACE pg_default
AS WITH latest_5 AS (
         SELECT a.rn,
            a.grievance_id,
            a.assigned_on,
            a.assigned_by_office_id,
            a.assigned_by_position,
            a.assigned_to_position,
            a.assigned_to_office_id,
            a.grievance_status
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn,
                    gl.grievance_id,
                    gl.assigned_on,
                    gl.assigned_by_office_id,
                    gl.assigned_by_position,
                    gl.assigned_to_position,
                    gl.assigned_to_office_id,
                    gl.grievance_status
                   FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = ANY (ARRAY[3, 5])) a
          WHERE a.rn = 1 AND a.grievance_status = 5 AND a.assigned_on::date >= (now() - '6 mons'::interval)::date AND a.assigned_on::date <= now()::date
        ), latest_13 AS (
         SELECT a.rn,
            a.grievance_id,
            a.assigned_on,
            a.assigned_by_office_id,
            a.assigned_by_position,
            a.assigned_to_position,
            a.assigned_to_office_id,
            a.grievance_status
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn,
                    gl.grievance_id,
                    gl.assigned_on,
                    gl.assigned_by_office_id,
                    gl.assigned_by_position,
                    gl.assigned_to_position,
                    gl.assigned_to_office_id,
                    gl.grievance_status
                   FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = 13) a
             JOIN latest_5 ON latest_5.grievance_id = a.grievance_id AND latest_5.assigned_on < a.assigned_on
          WHERE a.rn = 1
        )
 SELECT cte1.grievance_id,
    COALESCE(EXTRACT(day FROM
        CASE
            WHEN cte2.assigned_on IS NULL THEN now()
            WHEN cte2.assigned_on < cte1.assigned_on THEN now()
            ELSE cte2.assigned_on
        END - cte1.assigned_on)::integer, 0) AS days_diff,
    cte1.assigned_on AS rcv_assigned_on,
    cte1.assigned_by_office_id AS rcv_assigned_by_office_id,
    cte1.assigned_by_position AS rcv_assigned_by_position,
    cte1.assigned_to_position AS rcv_assigned_to_position,
    cte1.assigned_to_office_id AS rcv_assigned_to_office_id,
    cte2.assigned_on AS atr_assigned_on,
    cte2.assigned_by_office_id AS atr_assigned_by_office_id,
    cte2.assigned_by_position AS atr_assigned_by_position,
    cte2.assigned_to_position AS atr_assigned_to_position,
    cte2.assigned_to_office_id AS atr_assigned_to_office_id
   FROM latest_5 cte1
     LEFT JOIN latest_13 cte2 ON cte1.grievance_id = cte2.grievance_id
WITH DATA;