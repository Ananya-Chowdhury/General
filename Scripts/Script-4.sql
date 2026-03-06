CREATE OR REPLACE FUNCTION public.cmo_total_grievance_count(ssm_id integer, dept_id integer)
	RETURNS TABLE(new_grievances bigint, assigned_to_cmo bigint, recieved_from_cmo bigint, assigned_to_hod bigint, recieved_from_other_hod bigint, atr_returend_to_hod_for_review bigint, forwarded_to_hoso bigint, assign_to_so bigint, atr_submitted_to_hoso bigint, atr_returned_so_for_review bigint, atr_submitted_to_hod bigint, atr_returned_to_hoso_for_review bigint, atr_submitted_to_other_hod bigint, atr_submitted_to_cmo bigint, disposed bigint, recalled bigint, returned bigint, grievances_recieved bigint, atr_pending bigint)
	LANGUAGE plpgsql
AS $function$
	BEGIN
			if dept_id > 0	then 
			if ssm_id > 0 then
			    return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending
				from grievance_master gm 
				where gm.grievance_source = ssm_id and (gm.assigned_to_position  in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            ) or gm.updated_by_position in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            ));
	      else
	      		return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending
				from grievance_master gm 
				where (gm.assigned_to_position  in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            ) or gm.updated_by_position in (
		                            SELECT apm.position_id 
		                                FROM admin_position_master apm
		                                WHERE apm.office_id = dept_id
		                            ));
		 end if;
	      		
		else
			if ssm_id > 0 then
			 	return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending
				from grievance_master gm 
				where gm.grievance_source = ssm_id;
			else
				return query
			    select  
				COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
				COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
				COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
				COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
				COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
				COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
				COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
				COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
				COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
				COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
				COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
				COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
				COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
				COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
				COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
				COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
				COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
				COUNT(1) as grievances_recieved,
				COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending
				from grievance_master gm;
		  end if ;
		end if;
	END;
$function$
;
