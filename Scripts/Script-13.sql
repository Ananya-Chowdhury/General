DROP FUNCTION public.cmo_grievance_counts_socials(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_socials(ssm_id integer, dept_id integer)
 RETURNS TABLE( grievances_received_hindu bigint, grievances_received_muslim bigint, grievances_received_christian bigint, grievances_received_buddhist bigint, grievances_received_sikh bigint, 
 grievances_received_jain bigint, grievances_received_other bigint, grievances_received_not_known bigint, grievances_received_test_religion bigint, 
 grievances_received_hindu_percentage bigint, grievances_received_muslim_percentage bigint, grievances_received_christian_percentage bigint, 
 grievances_received_buddhist_percentage bigint, grievances_received_sikh_percentage bigint, grievances_received_jain_percentage bigint, 
 grievances_received_other_percentage bigint, grievances_received_not_known_percentage bigint, grievances_received_test_religion_percentage bigint, 
 total_general_count bigint, total_sc_count bigint, total_st_count bigint, total_obc_a_count bigint, total_obc_b_count bigint, 
 total_not_disclosed_count bigint, total_test_caste_count bigint, total_general_count_percentage bigint, total_sc_count_percentage bigint, 
 total_st_count_percentage bigint, total_obc_a_count_percentage bigint, total_obc_b_count_percentage bigint, total_not_disclosed_count_percentage bigint, 
 total_test_caste_count_percentage bigint)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		if dept_id > 0 then
			if ssm_id > 0 then
				return query
				select
--					COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
--					COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
--					COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
--					COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
--					COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
--					COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
--					COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
--					COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
--					COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
--					COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
--					COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
--					COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
--					COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
--					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
--					COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
--					COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
--					COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
--					COUNT(1) as grievances_recieved,
--					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
--					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
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
				    cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage
				from grievance_master gm
				where gm.grievance_source = ssm_id
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
--					COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
--					COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
--					COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
--					COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
--					COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
--					COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
--					COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
--					COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
--					COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
--					COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
--					COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
--					COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
--					COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
--					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
--					COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
--					COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
--					COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
--					COUNT(1) as grievances_recieved,
--					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
--					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
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
				    cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage
				from grievance_master gm
				where gm.assigned_to_position in
				(select apm.position_id
				from admin_position_master apm
				where apm.office_id = dept_id)
				or gm.updated_by_position in
				(select apm.position_id
				from admin_position_master apm
				where apm.office_id = dept_id);
			end if;
		else
			if ssm_id > 0 then
				return query
				select
--					COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
--					COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
--					COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
--					COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
--					COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
--					COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
--					COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
--					COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
--					COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
--					COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
--					COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
--					COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
--					COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
--					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
--					COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
--					COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
--					COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
--					COUNT(1) as grievances_recieved,
--					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
--					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
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
				    cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage
					from grievance_master gm where gm.grievance_source = ssm_id;
			else
					return query
				select
--					COUNT(case when gm.status = 1 then gm.grievance_id end) as new_grievances,
--					COUNT(case when gm.status = 2 then gm.grievance_id end) as assigned_to_cmo,
--					COUNT(case when gm.status = 3 then gm.grievance_id end) as recieved_from_cmo,
--					COUNT(case when gm.status = 4 then gm.grievance_id end) as assigned_to_hod,
--					COUNT(case when gm.status = 5 then gm.grievance_id end) as recieved_from_other_hod,
--					COUNT(case when gm.status = 6 then gm.grievance_id end) as atr_returend_to_hod_for_review,
--					COUNT(case when gm.status = 7 then gm.grievance_id end) as forwarded_to_hoso,
--					COUNT(case when gm.status = 8 then gm.grievance_id end) as assign_to_so,
--					COUNT(case when gm.status = 9 then gm.grievance_id end) as atr_submitted_to_hoso,
--					COUNT(case when gm.status = 10 then gm.grievance_id end) as atr_returned_so_for_review,
--					COUNT(case when gm.status = 11 then gm.grievance_id end) as atr_submitted_to_hod,
--					COUNT(case when gm.status = 12 then gm.grievance_id end) as atr_returned_to_hoso_for_review,
--					COUNT(case when gm.status = 13 then gm.grievance_id end) as atr_submitted_to_other_hod,
--					COUNT(case when gm.status = 14 then gm.grievance_id end) as atr_submitted_to_cmo,
--					COUNT(case when gm.status = 15 then gm.grievance_id end) as disposed,
--					COUNT(case when gm.status = 16 then gm.grievance_id end) as recalled,
--					COUNT(case when gm.status = 17 then gm.grievance_id end) as returned,
--					COUNT(1) as grievances_recieved,
--					COUNT(case when gm.status not in (1,2,14,15) then gm.grievance_id end) as atr_pending,
--					COUNT(case when gm.status not in (14,15) then gm.grievance_id end) as pending_grievance,
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
				    cast(COUNT(CASE WHEN gm.applicant_caste = 7 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS total_test_caste_count_percentage
					from grievance_master gm;
			end if;
		end if;			
	END;
$function$
;
