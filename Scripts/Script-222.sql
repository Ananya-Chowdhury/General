select  * from public.cmo_grievance_counts_age(0,0);


CREATE OR REPLACE FUNCTION public.cmo_total_grievance_counts(ssm_id integer, dept_id integer)
 RETURNS TABLE(new_grievances bigint, assigned_to_cmo bigint, recieved_from_cmo bigint, assigned_to_hod bigint, recieved_from_other_hod bigint, atr_returend_to_hod_for_review bigint, forwarded_to_hoso bigint, assign_to_so bigint, atr_submitted_to_hoso bigint, atr_returned_so_for_review bigint, atr_submitted_to_hod bigint, atr_returned_to_hoso_for_review bigint, atr_submitted_to_other_hod bigint, atr_submitted_to_cmo bigint, disposed bigint, recalled bigint, returned bigint, grievances_recieved bigint, atr_pending bigint, age_0_10 bigint, age_11_20 bigint, age_21_30 bigint, age_31_40 bigint, age_41_50 bigint, age_51_60 bigint, age_61_70 bigint, age_71_80 bigint, age_81_90 bigint, age_91_100 bigint, age_101_120 bigint)
 LANGUAGE plpgsql
	AS $function$
begin
	if dept_id > 0	then 
		if ssm_id > 0 then
		    return query
		   SELECT  
                COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS new_grievances,
                COUNT(CASE WHEN gm.status = 2 THEN gm.grievance_id END) AS assigned_to_cmo,
                COUNT(CASE WHEN gm.status = 3 THEN gm.grievance_id END) AS recieved_from_cmo,
                COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id END) AS assigned_to_hod,
                COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id END) AS recieved_from_other_hod,
                COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id END) AS atr_returend_to_hod_for_review,
                COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id END) AS forwarded_to_hoso,
                COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id END) AS assign_to_so,
                COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id END) AS atr_submitted_to_hoso,
                COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id END) AS atr_returned_so_for_review,
                COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id END) AS atr_submitted_to_hod,
                COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id END) AS atr_returned_to_hoso_for_review,
                COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id END) AS atr_submitted_to_other_hod,
                COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_submitted_to_cmo,
                COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed,
                COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id END) AS recalled,
                COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id END) AS returned,
                COUNT(1) AS grievances_recieved,
                COUNT(CASE WHEN gm.status NOT IN (1,2,14,15) THEN gm.grievance_id END) AS atr_pending,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                -- COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120
            FROM grievance_master gm 
            WHERE gm.grievance_source = ssm_id AND (
                gm.assigned_to_position IN (
                    SELECT apm.position_id 
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id
                ) OR gm.updated_by_position IN (
                    SELECT apm.position_id 
                    FROM admin_position_master apm
                    WHERE apm.office_id = dept_id
                )
            );
      else
      		return query
		   SELECT  
                COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS new_grievances,
                COUNT(CASE WHEN gm.status = 2 THEN gm.grievance_id END) AS assigned_to_cmo,
                COUNT(CASE WHEN gm.status = 3 THEN gm.grievance_id END) AS recieved_from_cmo,
                COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id END) AS assigned_to_hod,
                COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id END) AS recieved_from_other_hod,
                COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id END) AS atr_returend_to_hod_for_review,
                COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id END) AS forwarded_to_hoso,
                COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id END) AS assign_to_so,
                COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id END) AS atr_submitted_to_hoso,
                COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id END) AS atr_returned_so_for_review,
                COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id END) AS atr_submitted_to_hod,
                COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id END) AS atr_returned_to_hoso_for_review,
                COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id END) AS atr_submitted_to_other_hod,
                COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_submitted_to_cmo,
                COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed,
                COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id END) AS recalled,
                COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id END) AS returned,
                COUNT(1) AS grievances_recieved,
                COUNT(CASE WHEN gm.status NOT IN (1,2,14,15) THEN gm.grievance_id END) AS atr_pending,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                 COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120
            FROM grievance_master gm 
            WHERE gm.assigned_to_position IN (
                SELECT apm.position_id 
                FROM admin_position_master apm
                WHERE apm.office_id = dept_id
            ) OR gm.updated_by_position IN (
                SELECT apm.position_id 
                FROM admin_position_master apm
                WHERE apm.office_id = dept_id
            );
	 end if;
      		
	else
		if ssm_id > 0 then
		 	return query
		    SELECT  
                    COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS new_grievances,
                    COUNT(CASE WHEN gm.status = 2 THEN gm.grievance_id END) AS assigned_to_cmo,
                    COUNT(CASE WHEN gm.status = 3 THEN gm.grievance_id END) AS recieved_from_cmo,
                    COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id END) AS assigned_to_hod,
                    COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id END) AS recieved_from_other_hod,
                    COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id END) AS atr_returend_to_hod_for_review,
                    COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id END) AS forwarded_to_hoso,
                    COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id END) AS assign_to_so,
                    COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id END) AS atr_submitted_to_hoso,
                    COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id END) AS atr_returned_so_for_review,
                    COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id END) AS atr_submitted_to_hod,
                    COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id END) AS atr_returned_to_hoso_for_review,
                    COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id END) AS atr_submitted_to_other_hod,
                    COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_submitted_to_cmo,
                    COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed,
                    COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id END) AS recalled,
                    COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id END) AS returned,
                    COUNT(1) AS grievances_recieved,
                    COUNT(CASE WHEN gm.status NOT IN (1,2,14,15) THEN gm.grievance_id END) AS atr_pending,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                    -- COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120
                FROM grievance_master gm where gm.grievance_source = ssm_id;
		else
			return query
		    SELECT  
                    COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS new_grievances,
                    COUNT(CASE WHEN gm.status = 2 THEN gm.grievance_id END) AS assigned_to_cmo,
                    COUNT(CASE WHEN gm.status = 3 THEN gm.grievance_id END) AS recieved_from_cmo,
                    COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id END) AS assigned_to_hod,
                    COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id END) AS recieved_from_other_hod,
                    COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id END) AS atr_returend_to_hod_for_review,
                    COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id END) AS forwarded_to_hoso,
                    COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id END) AS assign_to_so,
                    COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id END) AS atr_submitted_to_hoso,
                    COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id END) AS atr_returned_so_for_review,
                    COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id END) AS atr_submitted_to_hod,
                    COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id END) AS atr_returned_to_hoso_for_review,
                    COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id END) AS atr_submitted_to_other_hod,
                    COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_submitted_to_cmo,
                    COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed,
                    COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id END) AS recalled,
                    COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id END) AS returned,
                    COUNT(1) AS grievances_recieved,
                    COUNT(CASE WHEN gm.status NOT IN (1,2,14,15) THEN gm.grievance_id END) AS atr_pending,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
                     COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120
                FROM grievance_master gm;
	  end if ;
	end if;
		
END
$function$
;
 
WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod+k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.atr_pending_at_cmo+k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod+k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod ) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable
FROM (
    SELECT  
        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
        COUNT(1) AS total_grievance,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        lu.assigned_to_office_id
    FROM 
        lastupdates lu
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = lu.grievance_id 
    LEFT JOIN 
        cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
    WHERE 
        lu.rn = 1 
        AND lu.assigned_to_office_id =  84
        AND gm.status IS NOT NULL and gm.grievance_source = 5
        AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
    GROUP BY 
        lu.assigned_to_office_id, gm.applicant_age
) k;




WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable
FROM (
    SELECT  
        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
        COUNT(1) AS total_grievance,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120,
        lu.assigned_to_office_id  -- Missing comma was added here
    FROM 
        lastupdates lu
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = lu.grievance_id 
    LEFT JOIN 
        cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
    WHERE 
        lu.rn = 1 
        AND lu.assigned_to_office_id = 84
        AND gm.status IS NOT NULL 
        AND gm.grievance_source = 5
        AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
    GROUP BY 
        lu.assigned_to_office_id
) k;



WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable,
    SUM(k.age_0_10) AS age_0_10,
    SUM(k.age_11_20) AS age_11_20,
    SUM(k.age_21_30) AS age_21_30,
    SUM(k.age_31_40) AS age_31_40,
    SUM(k.age_41_50) AS age_41_50,
    SUM(k.age_51_60) AS age_51_60,
    SUM(k.age_61_70) AS age_61_70,
    SUM(k.age_71_80) AS age_71_80,
    SUM(k.age_81_90) AS age_81_90,
    SUM(k.age_91_100) AS age_91_100,
    SUM(k.age_101_120) AS age_101_120
FROM (
    SELECT  
        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
        COUNT(1) AS total_grievance,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 10 THEN gm.grievance_id END) AS age_0_10,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 11 AND 20 THEN gm.grievance_id END) AS age_11_20,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 21 AND 30 THEN gm.grievance_id END) AS age_21_30,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 40 THEN gm.grievance_id END) AS age_31_40,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 41 AND 50 THEN gm.grievance_id END) AS age_41_50,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 51 AND 60 THEN gm.grievance_id END) AS age_51_60,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 70 THEN gm.grievance_id END) AS age_61_70,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 71 AND 80 THEN gm.grievance_id END) AS age_71_80,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 81 AND 90 THEN gm.grievance_id END) AS age_81_90,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 91 AND 100 THEN gm.grievance_id END) AS age_91_100,
        COUNT(CASE WHEN gm.applicant_age BETWEEN 101 AND 120 THEN gm.grievance_id END) AS age_101_120,
        lu.assigned_to_office_id
    FROM 
        lastupdates lu
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = lu.grievance_id 
    LEFT JOIN 
        cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
    WHERE 
        lu.rn = 1 
        AND lu.assigned_to_office_id =  84
        AND gm.status IS NOT NULL 
        AND gm.grievance_source = 5
        AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
    GROUP BY 
        lu.assigned_to_office_id
) k;





WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable,
    cast(SUM(k.grievances_recieved_male) as INTEGER ) as grievances_recieved_male,
    cast(SUM(k.grievances_recieved_female) as INTEGER ) as grievances_recieved_female,
    cast(SUM(k.grievances_recieved_others) as INTEGER ) as grievances_recieved_others
FROM(
	   SELECT  
	        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
	        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
	        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
	        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
	        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
	        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
	        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
	        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
	        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
	        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
	        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
	        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
	        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
	        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
	        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
	        COUNT(1) AS total_grievance,
	        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
	        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
	        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
	        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
	        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
	        COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
		   	COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END)AS grievances_recieved_female,
		    COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others,
	FROM 
	    lastupdates lu
	INNER JOIN 
	    grievance_master gm ON gm.grievance_id = lu.grievance_id 
	LEFT JOIN 
	    cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
	WHERE 
	    lu.rn = 1 
	    AND lu.assigned_to_office_id =  84
	    AND gm.status IS NOT NULL 
	    AND gm.grievance_source = 5
	    AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
	GROUP BY 
	    lu.assigned_to_office_id
	)k;





WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable,
    cast(SUM(k.total_rural_count) as INTEGER ) as total_rural_count,
    cast(SUM(k.total_urban_count) as INTEGER ) as total_urban_count
FROM (
    SELECT  
        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
        COUNT(1) AS total_grievance,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
		COUNT(CASE WHEN gm.address_type = 2 THEN 1 END)AS total_urban_count,
        lu.assigned_to_office_id  -- Missing comma was added here
    FROM 
        lastupdates lu
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = lu.grievance_id 
    LEFT JOIN 
        cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
    WHERE 
        lu.rn = 1 
        AND lu.assigned_to_office_id = 84
        AND gm.status IS NOT NULL  
        AND gm.grievance_source = 5
        AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
    GROUP BY 
        lu.assigned_to_office_id
) k;






WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on AS max_assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_by_office_id,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM 
        grievance_lifecycle
    WHERE 
        grievance_lifecycle.grievance_status = 3
)
SELECT 
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod+k.atr_pending_at_cmo) AS total_grievance_forward_count,
    SUM(k.total_grievance) AS total_grievance_recieved_count,
    SUM(k.total_grievance + k.total_closed ) AS total_grievance,
    SUM(k.atr_pending_at_cmo+k.total_closed) AS grievance_recieved_count_cmo,
    SUM(k.received_from_other_hod+k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
    SUM(k.received_from_other_hod ) AS atr_pending_at_other_hod,
    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
    SUM(k.total_closed) AS total_closed,
    SUM(k.matter_taken_up) AS matter_taken_up,
    SUM(k.benifit_service_provided) AS benifit_service_provided,
    SUM(k.non_actionable) AS non_actionable
FROM (
    SELECT  
        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
        COUNT(1) AS total_grievance,
        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
        lu.assigned_to_office_id
    FROM 
        lastupdates lu
    INNER JOIN 
        grievance_master gm ON gm.grievance_id = lu.grievance_id 
    LEFT JOIN 
        cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
    WHERE 
        lu.rn = 1 
        AND lu.assigned_to_office_id = 79
        AND (gm.status = 15 OR gm.assigned_to_office_id = 79) 
    GROUP BY 
        lu.assigned_to_office_id
) k;






SELECT 
    COUNT(1) AS grievances_recieved,
    COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed
FROM grievance_master gm
    inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
    inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
    gm.grievance_source = 5 
-- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
    and gm.status IS NOT null
-- and assigned_to_office_id =  3
    and apm.sub_office_id = 1510 and apm.office_id = 27;

select * from cmo_office_master com where com.office_id=2; 

select * from admin_position_master apm where apm.office_id = 2;

select * from cmo_sub_office_master csom;

select * from grievance_master gm where grievance_source = 1;

select grievance_source from grievance_master gm limit 5;

select * from cmo_domain_lookup_master cdlm ;

select 
COUNT(grievance_id > 0) as total 
from grievance_master gm
inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id  
	 where grievance_source = 5
	 and apm.sub_office_id = 1510 and apm.office_id = 27;
	 
select 
COUNT(grievance_id > 0 AND gm.status = 15) as total_close
from grievance_master gm
inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id  
	 where grievance_source = 5
	 and apm.sub_office_id = 1510 and apm.office_id = 27;
	 
SELECT COUNT(*) 
FROM grievance_master 
WHERE grievance_id > 0;

SELECT COUNT(*) 
FROM grievance_master 
WHERE grievance_id > 0 AND status = 15 and grievance_source = 5;

SELECT COUNT(*) as male
FROM grievance_master 
WHERE grievance_id > 0 AND applicant_gender = 1;




select 
COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
COUNT(CASE WHEN gm.address_type = 2 THEN 1 END) AS total_rural_count,
COUNT(CASE WHEN gm.applicant_caste = 1 THEN 1 END) AS total_general_count,
COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance
from grievance_master gm;




SELECT 
	SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
    COUNT(CASE WHEN gm.applicant_gender = 1 THEN 1 END) AS grievances_recieved_male,
    COUNT(CASE WHEN gm.applicant_gender = 2 THEN 1 END) AS grievances_recieved_female,
    COUNT(CASE WHEN gm.applicant_gender = 3 THEN 1 END) AS grievances_recieved_others,
    COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
    COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count,
    COUNT(CASE WHEN gm.applicant_caste   = 1 THEN 1 END) AS total_general_count,
    COUNT(CASE WHEN gm.applicant_caste   = 2 THEN 1 END) AS total_sc_count,
    COUNT(CASE WHEN gm.applicant_caste   = 3 THEN 1 END) AS total_st_count,
    COUNT(CASE WHEN gm.applicant_caste   = 4 THEN 1 END) AS total_obc_a_count,
    COUNT(CASE WHEN gm.applicant_caste   = 5 THEN 1 END) AS total_obc_b_count,
    COUNT(CASE WHEN gm.applicant_caste   = 6 THEN 1 END) AS total_not_disclosed_count,
    COUNT(CASE WHEN gm.applicant_caste   = 7 THEN 1 END) AS total_test_caste_count
--address_type, *
FROM grievance_master gm
    inner join admin_position_master apm on apm.position_id = gm.assigned_to_position 
    inner join cmo_sub_office_master csom on apm.office_id = csom.office_id and apm.sub_office_id = csom.suboffice_id 
WHERE
    gm.grievance_source = 5 
-- AND (gm.status = 15 OR gm.assigned_to_office_id = 1)
    and gm.status IS NOT null
-- and assigned_to_office_id =  3
    and apm.sub_office_id = 1510 and apm.office_id = 27;

 
   SELECT COUNT(*) 
   	FROM grievance_master gm,
		WHERE grievance_id > 0 
		and grievance_source = 5
		AND address_type = 1;
   

SELECT COUNT(*) 
FROM grievance_master 
WHERE grievance_id > 0 
  AND applicant_caste = 1;

 
WITH lastupdates AS (
        SELECT 
            grievance_lifecycle.grievance_id,
            grievance_lifecycle.grievance_status,
            grievance_lifecycle.assigned_on AS max_assigned_on,
            grievance_lifecycle.assigned_to_office_id,
            grievance_lifecycle.assigned_by_position,
            grievance_lifecycle.assigned_to_position,
            grievance_lifecycle.assigned_by_office_id,
            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM 
            grievance_lifecycle
        WHERE 
            grievance_lifecycle.grievance_status = 3
    )
    SELECT 
        SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
        SUM(k.total_grievance) AS total_grievance_recieved_count,
        SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
        SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
        SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
        SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
        SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
        SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
        SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
        SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
        SUM(k.total_closed) AS total_closed,
        SUM(k.matter_taken_up) AS matter_taken_up,
        SUM(k.benifit_service_provided) AS benifit_service_provided,
        SUM(k.non_actionable) AS non_actionable,
        cast(SUM(k.age_0_10) as INTEGER) as age_0_10,
        cast(SUM(k.age_11_20) as INTEGER) as age_11_20,
        cast(SUM(k.age_21_30) as INTEGER) as age_21_30,
        cast(SUM(k.age_31_40) as INTEGER) as age_31_40,
        cast(SUM(k.age_41_50) as INTEGER) as age_41_50,
        cast(SUM(k.age_51_60) as INTEGER) as age_51_60,
        cast(SUM(k.age_61_70) as INTEGER) as age_61_70,
        cast(SUM(k.age_71_80) as INTEGER) as age_71_80,
        cast(SUM(k.age_81_90) as INTEGER) as age_81_90,
        cast(SUM(k.age_91_100) as INTEGER) as age_91_100,
        cast(SUM(k.age_101_120) as INTEGER) as age_101_120,
        cast(SUM(k.grievances_received_male) as INTEGER ) as grievances_recieved_male,
    	cast(SUM(k.grievances_received_female) as INTEGER ) as grievances_recieved_female,
    	cast(SUM(k.grievances_received_others) as INTEGER ) as grievances_recieved_others,
    	cast(sum(k.grievances_recieved_male_percentage) as integer) AS grievances_recieved_male_percentage,
		cast(sum(k.grievances_recieved_female_percentage) as integer) AS grievances_recieved_female_percentage,
		cast(sum(k.grievances_recieved_others_percentage) as integer) AS grievances_recieved_others_percentage,
        cast(SUM(k.total_rural_count) as INTEGER) as total_rural_count,
        cast(SUM(k.total_urban_count) as INTEGER) as total_urban_count,
        cast(SUM(k.total_general_count) as INTEGER) as total_general_count,
        cast(SUM(k.total_sc_count) as INTEGER) as total_sc_count,
        cast(SUM(k.total_st_count) as INTEGER) as total_st_count,
        cast(SUM(k.total_obc_a_count) as INTEGER) as total_obc_a_count,
        cast(SUM(k.total_obc_b_count) as INTEGER) as total_obc_b_count,
        cast(SUM(k.total_not_disclosed_count) as INTEGER) as total_not_disclosed_count,
        cast(SUM(k.total_test_caste_count) as INTEGER) as total_test_caste_count
    FROM(
        SELECT  
            SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
            COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
            COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
            COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
            COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
            COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
            COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
            COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
            COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
            COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
            COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
            COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
            COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
            COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
            COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
            COUNT(1) AS total_grievance,
            COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
            SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
            -- cast(SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) as INTEGER) AS atr_pending_at_cmo,
            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
            COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
            COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) AS age_below_18,
            COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) AS age_18_30,
            COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) AS age_31_45,
            COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) AS age_46_60,
            COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) AS age_above_60,
            (COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_below_18_percentage,
			(COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_18_30_percentage,
		    (COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_31_45_percentage,
		    (COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_46_60_percentage,
			(COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_above_60_percentage,
            COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
			COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
			COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
			(COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1)) AS grievances_recieved_male_percentage,
			(COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1)) AS grievances_recieved_female_percentage,
		    (COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1)) AS grievances_recieved_others_percentage,
            COUNT(CASE WHEN gm.address_type  = 1 THEN 1 END) AS total_rural_count,
            COUNT(CASE WHEN gm.address_type  = 2 THEN 1 END) AS total_urban_count,
            COUNT(CASE WHEN gm.applicant_caste   = 1 THEN 1 END) AS total_general_count,
            COUNT(CASE WHEN gm.applicant_caste   = 2 THEN 1 END) AS total_sc_count,
            COUNT(CASE WHEN gm.applicant_caste   = 3 THEN 1 END) AS total_st_count,
            COUNT(CASE WHEN gm.applicant_caste   = 4 THEN 1 END) AS total_obc_a_count,
            COUNT(CASE WHEN gm.applicant_caste   = 5 THEN 1 END) AS total_obc_b_count,
            COUNT(CASE WHEN gm.applicant_caste   = 6 THEN 1 END) AS total_not_disclosed_count,
            COUNT(CASE WHEN gm.applicant_caste   = 7 THEN 1 END) AS total_test_caste_count,
            lu.assigned_to_office_id
        FROM 
            lastupdates lu
        INNER JOIN 
            grievance_master gm ON gm.grievance_id = lu.grievance_id 
        LEFT JOIN 
            cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
        WHERE 
            lu.rn = 1 
            AND lu.assigned_to_office_id = 84
            AND gm.status IS NOT NULL 
            AND gm.grievance_source = 5
            AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
        GROUP BY 
            lu.assigned_to_office_id)k;
            
           
SELECT cgcm.grievance_cat_id AS grievance_category, 
       cgcm.grievance_category_desc, 
       COUNT(gl.grievance_id) AS category_pending_grievance_count
FROM grievance_lifecycle gl  
INNER JOIN grievance_master gm 
    ON gm.grievance_id = gl.grievance_id 
    AND gm.status > 2 
    AND gm.status <= 13
INNER JOIN cmo_griev_cat_office_mapping cgcom 
    ON gm.grievance_category = cgcom.grievance_cat_id 
INNER JOIN cmo_grievance_category_master cgcm 
    ON cgcm.grievance_cat_id = gm.grievance_category 
WHERE gl.grievance_status = 3
  AND gm.grievance_source = 5
  AND gl.assigned_to_position IN (
        SELECT apm.position_id 
        FROM admin_position_master apm
        WHERE apm.office_id =53
  )
GROUP BY cgcm.grievance_category_desc, cgcm.grievance_cat_id 
ORDER BY category_pending_grievance_count DESC 
LIMIT 10;

SELECT gm.grievance_category,
       cgcm.grievance_category_desc,
       COUNT(DISTINCT gm.grievance_id) AS category_pending_grievance_count
FROM grievance_master gm 
INNER JOIN cmo_grievance_category_master cgcm 
    ON cgcm.grievance_cat_id = gm.grievance_category
WHERE gm.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
  AND gm.grievance_source = 5
GROUP BY gm.grievance_category, cgcm.grievance_category_desc
ORDER BY category_pending_grievance_count DESC 
LIMIT 10;



SELECT 
    COUNT(CASE WHEN gm.address_type = 2 THEN 1 END) AS total_urban_count,
    (
        SELECT STRING_AGG(category_pending_grievance_count::text, ', ')
        from 
        ( SELECT 
                cgcm.grievance_category_desc || ' (' || COUNT(DISTINCT gm_inner.grievance_id) || ')' AS category_pending_grievance_count
            FROM grievance_master gm_inner
            INNER JOIN cmo_grievance_category_master cgcm 
                ON cgcm.grievance_cat_id = gm_inner.grievance_category
            WHERE gm_inner.status IN (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
              AND gm_inner.grievance_source = 5 -- Replace this with your `ssm_id`
            GROUP BY gm_inner.grievance_category, cgcm.grievance_category_desc
            ORDER BY COUNT(DISTINCT gm_inner.grievance_id) DESC
            LIMIT 10
        ) AS top_categories
    ) AS top_category
FROM grievance_master gm
WHERE gm.grievance_source = 5 -- Replace this with your `ssm_id`
  AND (gm.assigned_to_position IN (
        SELECT apm.position_id
        FROM admin_position_master apm
        WHERE apm.office_id = 53) -- Replace with your `dept_id`
    OR gm.updated_by_position IN (
        SELECT apm.position_id
        FROM admin_position_master apm
        WHERE apm.office_id = 53)) -- Replace with your `dept_id`
        ;
       
       

SELECT
    COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS new_grievances,
    COUNT(CASE WHEN gm.status = 2 THEN gm.grievance_id END) AS assigned_to_cmo,
    COUNT(CASE WHEN gm.status = 3 THEN gm.grievance_id END) AS recieved_from_cmo,
    COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id END) AS assigned_to_hod,
    COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id END) AS recieved_from_other_hod,
    COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id END) AS atr_returned_to_hod_for_review,
    COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id END) AS forwarded_to_hoso,
    COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id END) AS assign_to_so,
    COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id END) AS atr_submitted_to_hoso,
    COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id END) AS atr_returned_so_for_review,
    COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id END) AS atr_submitted_to_hod,
    COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id END) AS atr_returned_to_hoso_for_review,
    COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id END) AS atr_submitted_to_other_hod,
    COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS atr_submitted_to_cmo,
    COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id END) AS disposed,
    COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id END) AS recalled,
    COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id END) AS returned,
    COUNT(1) AS grievances_received,
    COUNT(CASE WHEN gm.status NOT IN (1,2,14,15) THEN gm.grievance_id END) AS atr_pending,
    COUNT(CASE WHEN gm.status NOT IN (14,15) THEN gm.grievance_id END) AS pending_grievance,
    COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female,
    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
    cast(COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_recieved_others_percentage,
    cast(COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_recieved_male_percentage,
    cast(COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_recieved_female_percentage,
    COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_hindu,
    COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_muslim,
    COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_christian,
    COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_buddhist,
    COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_sikh,
    COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_jain,
    COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_other,
    COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_not_known,
    COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_test_religion,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_hindu_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_muslim_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_christian_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_buddhist_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_sikh_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_jain_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_other_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_not_known_percentage,
    cast(COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_test_religion_percentage,
    COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_general_count,
    COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_sc_count,
    COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_st_count,
    COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_a_count,
    COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_b_count,
    COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_not_disclosed_count,
    COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_test_caste_count,
    cast(COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_general_count_percentage,
    cast(COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_sc_count_percentage,
    cast(COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_st_count_percentage,
    cast(COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_a_count_percentage,
    cast(COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_b_count_percentage,
    cast(COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_not_disclosed_count_percentage,
    cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) AS age_below_18,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) AS age_18_30,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) AS age_31_45,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) AS age_46_60,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) AS age_above_60,
    round(COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_below_18_percentage,
	round(COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_18_30_percentage,
    round(COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_31_45_percentage,
    round(COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_46_60_percentage,
	round(COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_above_60_percentage,
    (COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_below_18_percentage,
	(COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_18_30_percentage,
    (COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_31_45_percentage,
    (COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_46_60_percentage,
	(COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN gm.grievance_id END) * 100.0 / COUNT(1)) AS age_above_60_percentage,
	COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_below_18_male,
	COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_below_18_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_18_30_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_18_30_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_31_45_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_31_45_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_46_60_male,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_46_60_female,
    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 1 THEN gm.grievance_id END) AS age_above_60_male,
	COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 2 THEN gm.grievance_id END) AS age_above_60_female
--	COUNT(case when gm.status = 02 and gl.grievance_status = 14 then gm.grievance_id end) as atr_pending_count
FROM
    grievance_master gm, grievance_lifecycle gl;
--where
--	gm.grievance_source = 5;
--    gm.created_on >= '2024-03-25';-- Replace 'date_received' with the actual column name for the date in your table

select
	COUNT(distinct case when gm.status = 2 and gl.grievance_status = 14 then gm.grievance_id end) as atr_pending_count
FROM
    grievance_master gm, grievance_lifecycle gl;

SELECT 
    COUNT(CASE WHEN gm.status = 2 AND gl.grievance_status = 14 THEN gm.grievance_id END) AS atr_pending_count
FROM 
    grievance_master gm
JOIN 
    grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id;
--WHERE 
--    gm.status = 2
--    AND gl.grievance_status = 14;

SELECT 
    COUNT(DISTINCT gm.grievance_id) AS atr_pending_count
FROM 
    grievance_master gm
JOIN 
    grievance_lifecycle gl ON gm.grievance_id = gl.grievance_id
WHERE 
    gm.status = 2
    AND gl.grievance_status = 14;
   

SELECT 
	COUNT(CASE WHEN gm.status = 1 THEN gm.grievance_id END) AS unassigned_grievance,
    COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id END) AS unassigned_atr
FROM grievance_master gm;



WITH lastupdates AS (
                                    SELECT 
                                        grievance_lifecycle.grievance_id,
                                        grievance_lifecycle.grievance_status,
                                        grievance_lifecycle.assigned_on AS max_assigned_on,
                                        grievance_lifecycle.assigned_to_office_id,
                                        grievance_lifecycle.assigned_by_position,
                                        grievance_lifecycle.assigned_to_position,
                                        grievance_lifecycle.assigned_by_office_id,
                                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                                    FROM 
                                        grievance_lifecycle
                                    WHERE 
                                        grievance_lifecycle.grievance_status = 3
                                )
                                SELECT 
                                    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod + k.atr_pending_at_cmo) AS total_grievance_forward_count,
                                    SUM(k.total_grievance) AS total_grievance_recieved_count,
                                    SUM(k.atr_pending_at_cmo + k.total_closed) AS grievance_recieved_count_cmo,
                                    SUM(k.received_from_other_hod + k.atr_submitted_to_other_hod) AS grievance_recieved_count_other_hod,
                                    SUM(k.atr_submitted_to_cmo + k.total_closed) AS atr_submited_to_cmo,
                                    SUM(k.atr_submitted_to_other_hod) AS atr_submited_to_other_hod,
                                    SUM(k.atr_submitted_to_cmo + k.total_closed + k.atr_submitted_to_other_hod) AS total_atr_submited_count,
                                    SUM(k.atr_pending_at_cmo) AS atr_pending_at_cmo,
                                    SUM(k.received_from_other_hod) AS atr_pending_at_other_hod,
                                    SUM(k.atr_pending_at_cmo + k.received_from_other_hod) AS total_atr_pending_count,
                                    SUM(k.total_closed) AS total_closed,
                                    SUM(k.matter_taken_up) AS matter_taken_up,
                                    SUM(k.benifit_service_provided) AS benifit_service_provided,
                                    SUM(k.non_actionable) AS non_actionable,
                                    cast(SUM(k.total_general_count) as INTEGER) as total_general_count,
                                    cast(SUM(k.total_sc_count) as INTEGER) as total_sc_count,
                                    cast(SUM(k.total_st_count) as INTEGER) as total_st_count,
                                    cast(SUM(k.total_obc_a_count) as INTEGER) as total_obc_a_count,
                                    cast(SUM(k.total_obc_b_count) as INTEGER) as total_obc_b_count,
                                    cast(SUM(k.total_not_disclosed_count) as INTEGER) as total_not_disclosed_count,
                                    cast(SUM(k.total_test_caste_count) as INTEGER) as total_test_caste_count,
                                    cast(sum(k.total_general_count_percentage) as integer) AS total_general_count_percentage,
                                    cast(sum(k.total_sc_count_percentage) as integer) AS total_sc_count_percentage,
                                    cast(sum(k.total_st_count_percentage) as integer) AS total_st_count_percentage,
                                    cast(sum(k.total_obc_a_count_percentage) as integer) AS total_obc_a_count_percentage,
                                    cast(sum(k.total_obc_b_count_percentage) as integer) AS total_obc_b_count_percentage,
                                    cast(sum(k.total_not_disclosed_count_percentage) as integer) AS total_not_disclosed_count_percentage,
                                    cast(sum(k.total_test_caste_count_percentage) as integer) AS total_test_caste_count_percentage,
                                    cast(SUM(k.grievances_received_hindu) as INTEGER) as grievances_received_hindu,
                                    cast(SUM(k.grievances_received_muslim) as INTEGER) as grievances_received_muslim,
                                    cast(SUM(k.grievances_received_christian) as INTEGER) as grievances_received_christian,
                                    cast(SUM(k.grievances_received_buddhist) as INTEGER) as grievances_received_buddhist,
                                    cast(SUM(k.grievances_received_sikh) as INTEGER) as grievances_received_sikh,
                                    cast(SUM(k.grievances_received_jain) as INTEGER) as grievances_received_jain,
                                    cast(SUM(k.grievances_received_other) as INTEGER) as grievances_received_other,
                                    cast(sum(k.grievances_received_not_known) as integer) AS grievances_received_not_known,
                                    cast(sum(k.grievances_received_test_religion) as integer) AS grievances_received_test_religion,
                                    cast(sum(k.grievances_received_hindu_percentage) as integer) AS grievances_received_hindu_percentage,
                                    cast(sum(k.grievances_received_muslim_percentage) as integer) AS grievances_received_muslim_percentage,
                                    cast(sum(k.grievances_received_christian_percentage) as integer) AS grievances_received_christian_percentage,
                                    cast(sum(k.grievances_received_buddhist_percentage) as integer) AS grievances_received_buddhist_percentage,
                                    cast(sum(k.grievances_received_sikh_percentage) as integer) AS grievances_received_sikh_percentage,
                                    cast(sum(k.grievances_received_jain_percentage) as integer) AS grievances_received_jain_percentage,
                                    cast(sum(k.grievances_received_other_percentage) as integer) AS grievances_received_other_percentage,
                                    cast(sum(k.grievances_received_not_known_percentage) as integer) AS grievances_received_not_known_percentage,
                                    cast(sum(k.grievances_received_test_religion_percentage) as integer) AS grievances_received_test_religion_percentage
                                FROM (
                                    SELECT  
                                        SUM(CASE WHEN gm.status = 3 THEN 1 ELSE 0 END) AS received_from_cmo,
                                        COUNT(CASE WHEN gm.status = 4 THEN gm.grievance_id ELSE NULL END) AS assign_to_hod,
                                        COUNT(CASE WHEN gm.status = 5 THEN gm.grievance_id ELSE NULL END) AS received_from_other_hod,
                                        COUNT(CASE WHEN gm.status = 6 THEN gm.grievance_id ELSE NULL END) AS atr_returned_to_hod,
                                        COUNT(CASE WHEN gm.status = 7 THEN gm.grievance_id ELSE NULL END) AS forward_to_hoso,
                                        COUNT(CASE WHEN gm.status = 8 THEN gm.grievance_id ELSE NULL END) AS assign_to_so,
                                        COUNT(CASE WHEN gm.status = 9 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso,
                                        COUNT(CASE WHEN gm.status = 10 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hoso_for_review,
                                        COUNT(CASE WHEN gm.status = 11 THEN gm.grievance_id ELSE NULL END) AS atr_submit_to_hod,
                                        COUNT(CASE WHEN gm.status = 12 THEN gm.grievance_id ELSE NULL END) AS atr_return_hoso_review,
                                        COUNT(CASE WHEN gm.status = 13 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_other_hod,
                                        COUNT(CASE WHEN gm.status = 14 THEN gm.grievance_id ELSE NULL END) AS atr_submitted_to_cmo,
                                        COUNT(CASE WHEN gm.status = 15 THEN gm.grievance_id ELSE NULL END) AS total_closed,
                                        COUNT(CASE WHEN gm.status = 16 THEN gm.grievance_id ELSE NULL END) AS recall,
                                        COUNT(CASE WHEN gm.status = 17 THEN gm.grievance_id ELSE NULL END) AS returned,
                                        COUNT(1) AS total_grievance,
                                        COUNT(CASE WHEN gm.status IS NULL THEN gm.grievance_id ELSE NULL END) AS none_count,
                                        SUM(CASE WHEN gm.status IN (3, 4, 6, 7, 8, 9, 10, 11, 12, 16, 17) THEN 1 ELSE 0 END) AS atr_pending_at_cmo,
                                        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (5, 9) THEN gm.grievance_id ELSE NULL END) AS matter_taken_up,
                                        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id = 1 THEN gm.grievance_id ELSE NULL END) AS benifit_service_provided,
                                        COUNT(DISTINCT CASE WHEN gm.status = 15 AND gm.closure_reason_id IN (2, 3, 4, 6, 7, 8, 10, 11, 12) THEN gm.grievance_id ELSE NULL END) AS non_actionable,
                                        COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_hindu,
                                        COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_muslim,
                                        COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_christian,
                                        COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_buddhist,
                                        COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_sikh,
                                        COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_jain,
                                        COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_other,
                                        COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_not_known,
                                        COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_test_religion,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_hindu_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_muslim_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_christian_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_buddhist_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_sikh_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_jain_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_other_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 8 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_not_known_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_reigion = 9 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_received_test_religion_percentage,
                                        COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_general_count,
                                        COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_sc_count,
                                        COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_st_count,
                                        COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_a_count,
                                        COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_obc_b_count,
                                        COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_not_disclosed_count,
                                        COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) AS total_test_caste_count,
                                        cast(COUNT(CASE WHEN gm.applicant_caste = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_general_count_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_caste = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_sc_count_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_caste = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_st_count_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_caste = 4 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_a_count_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_caste = 5 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_obc_b_count_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_caste = 6 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_not_disclosed_count_percentage,
                                        cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage,
                                        lu.assigned_to_office_id 
                                    FROM 
                                        lastupdates lu
                                    INNER JOIN 
                                        grievance_master gm ON gm.grievance_id = lu.grievance_id 
                                    LEFT JOIN 
                                        cmo_closure_reason_master ccrm ON ccrm.closure_reason_id = gm.closure_reason_id
                                    WHERE 
                                        lu.rn = 1 
                                        AND lu.assigned_to_office_id = 84
                                        AND gm.status IS NOT NULL  
                                        AND gm.grievance_source = 5
                                        AND (gm.status = 15 OR gm.assigned_to_office_id = 84) 
                                    GROUP BY 
                                        lu.assigned_to_office_id
                                ) k;