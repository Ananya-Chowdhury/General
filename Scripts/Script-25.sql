 DROP FUNCTION public.cmo_grievance_counts_gender(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_gender(ssm_id integer, dept_id integer)
 RETURNS TABLE(total_count bigint, grievances_recieved_male bigint, grievances_recieved_female bigint, grievances_recieved_others bigint, grievances_recieved_male_percentage bigint, grievances_recieved_female_percentage bigint, grievances_recieved_others_percentage bigint)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		if dept_id > 0 then
			if ssm_id > 0 then
				return query
				select
--					count(1) as gender_wise_count,
--					SUM(gender_wise_count) as total_count,
--					SUM(count(1)) as total_count
					COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_received_male_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_female_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_others_percentage
					cast((COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_male_percentage,
					cast((COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_female_percentage,
				    cast((COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_others_percentage
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
--					count(1) as gender_wise_count,
--					SUM(gender_wise_count) as total_count,
--					SUM(count(1)) as total_count,
					COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_received_male_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_female_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_others_percentage
--					COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
					cast((COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_male_percentage,
					cast((COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_female_percentage,
				    cast((COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_others_percentage
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
--					count(1) as gender_wise_count,
--					SUM(gender_wise_count) as total_count,
					SUM(count(1)) as total_count,
					COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_received_male_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_female_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_others_percentage
--				    COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
					cast(COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_recieved_male_percentage,
					cast(COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_recieved_female_percentage,
				    cast(COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) * 100.0 / COUNT(1) as bigint) AS grievances_recieved_others_percentage
					from grievance_master gm where gm.grievance_source = ssm_id;
			else
					return query
				select
--					count(1) as gender_wise_count,
--					SUM(gender_wise_count) as total_count,
--					SUM(count(1)) as total_count
					COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_received_male_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_female_percentage,
--					cast(COUNT(grievances_received_male/total_count::float) * 100 as grievances_recieved_others_percentage
--					COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--				    COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--				    COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
					cast((COUNT(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_male_percentage,
					cast((COUNT(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_female_percentage,
				    cast((COUNT(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END)  / sum(COUNT(1)) * 100) as bigint) AS grievances_recieved_others_percentagevances_recieved_others_percentage
					from grievance_master gm;
			end if;
		end if;			
	END;
$function$
;


--DROP FUNCTION public.cmo_grievance_counts_gender(int4, int4);

--CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_gender(ssm_id integer, dept_id integer)
-- RETURNS TABLE(total_count bigint, grievances_recieved_male bigint, grievances_recieved_female bigint, grievances_recieved_others bigint, grievances_recieved_male_percentage bigint, grievances_recieved_female_percentage bigint, grievances_recieved_others_percentage bigint)
-- LANGUAGE plpgsql
--AS $function$
--	BEGIN
--		if dept_id > 0 then
--			if ssm_id > 0 then
--				return query
--				select
--	g2.grievances_received_male,
--	g2.grievances_received_female,
--	g2.grievances_received_others,
--	(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--	(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--	(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--from
--	(select
--					SUM(g1.gender_wise_count) as total_count,
--					MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--				    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--				    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--					MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--	from 
--		(select
--			count(1) as gender_wise_count,
--				from grievance_master gm
--				where gm.grievance_source = ssm_id
--				and (gm.assigned_to_position in 
--					(select apm.position_id
--					from admin_position_master apm
--					where apm.office_id = dept_id)
--					or gm.updated_by_position in 
--						(select apm.position_id
--						from admin_position_master apm
--						where apm.office_id = dept_id))gl) g2;
--			else
--				return query
--					select
--						g2.grievances_received_male,
--						g2.grievances_received_female,
--						g2.grievances_received_others,
--						(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--					from
--						(select
--							SUM(g1.gender_wise_count) as total_count,
--							MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--						    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--						    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--							MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--						from 
--							(select
--								count(1) as gender_wise_count,
--									from grievance_master gm
--									where gm.assigned_to_position in
--										(select apm.position_id
--										from admin_position_master apm
--										where apm.office_id = dept_id)
--										or gm.updated_by_position in
--										(select apm.position_id
--										from admin_position_master apm
--										where apm.office_id = dept_id) gl) g2;
--			end if;
--		else
--			return query
--				select
--						g2.grievances_received_male,
--						g2.grievances_received_female,
--						g2.grievances_received_others,
--						(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--					from
--						(select
--							SUM(g1.gender_wise_count) as total_count,
--							MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--						    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--						    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--							MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--						from 
--							(select
--								count(1) as gender_wise_count,
--									from grievance_master gm where gm.grievance_source = ssm_id) gl) g2;
--			else
--					return query
--				select
--					g2.grievances_received_male,
--					g2.grievances_received_female,
--					g2.grievances_received_others,
--					(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--					(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--					(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--				from
--					(select
--						SUM(g1.gender_wise_count) as total_count,
--						MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--					    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--					    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--						MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--					from 
--						(select
--							count(1) as gender_wise_count,
--									from grievance_master gm) gl) g2;
--			end if;
--		end if;			
--	END;
--$function$
--;



 DROP FUNCTION public.cmo_grievance_counts_gender(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_gender(ssm_id integer, dept_id integer)
RETURNS TABLE(
    total_count bigint,
    grievances_received_male bigint,
    grievances_received_female bigint,
    grievances_received_others bigint,
    grievances_received_male_percentage float,
    grievances_received_female_percentage float,
    grievances_received_others_percentage float
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
                  AND (gm.assigned_to_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                  )
            ) AS g2;

        ELSE
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others
                FROM grievance_master gm
                WHERE (gm.assigned_to_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                )
            ) AS g2;
        END IF;
    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
            ) AS g2;

        ELSE
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_received_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others
                FROM grievance_master gm
            ) AS g2;
        END IF;
    END IF;
END;
$function$;





--DROP FUNCTION public.cmo_grievance_counts_gender(int4, int4);

--CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_gender(ssm_id integer, dept_id integer)
-- RETURNS TABLE(total_count bigint, grievances_recieved_male bigint, grievances_recieved_female bigint, grievances_recieved_others bigint, grievances_recieved_male_percentage bigint, grievances_recieved_female_percentage bigint, grievances_recieved_others_percentage bigint)
-- LANGUAGE plpgsql
--AS $function$
--	BEGIN
--		if dept_id > 0 then
--			if ssm_id > 0 then
--				return query
--				select
--	g2.grievances_received_male,
--	g2.grievances_received_female,
--	g2.grievances_received_others,
--	(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--	(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--	(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--from
--	(select
--					SUM(g1.gender_wise_count) as total_count,
--					MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--				    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--				    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--					MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--	from 
--		(select
--			count(1) as gender_wise_count,
--				from grievance_master gm
--				where gm.grievance_source = ssm_id
--				and (gm.assigned_to_position in 
--					(select apm.position_id
--					from admin_position_master apm
--					where apm.office_id = dept_id)
--					or gm.updated_by_position in 
--						(select apm.position_id
--						from admin_position_master apm
--						where apm.office_id = dept_id))gl) g2;
--			else
--				return query
--					select
--						g2.grievances_received_male,
--						g2.grievances_received_female,
--						g2.grievances_received_others,
--						(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--					from
--						(select
--							SUM(g1.gender_wise_count) as total_count,
--							MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--						    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--						    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--							MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--						from 
--							(select
--								count(1) as gender_wise_count,
--									from grievance_master gm
--									where gm.assigned_to_position in
--										(select apm.position_id
--										from admin_position_master apm
--										where apm.office_id = dept_id)
--										or gm.updated_by_position in
--										(select apm.position_id
--										from admin_position_master apm
--										where apm.office_id = dept_id) gl) g2;
--			end if;
--		else
--			return query
--				select
--						g2.grievances_received_male,
--						g2.grievances_received_female,
--						g2.grievances_received_others,
--						(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--						(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--					from
--						(select
--							SUM(g1.gender_wise_count) as total_count,
--							MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--						    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--						    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--							MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--						from 
--							(select
--								count(1) as gender_wise_count,
--									from grievance_master gm where gm.grievance_source = ssm_id) gl) g2;
--			else
--					return query
--				select
--					g2.grievances_received_male,
--					g2.grievances_received_female,
--					g2.grievances_received_others,
--					(g2.grievances_received_male/g2.total_count::float)*100 as grievances_received_male_percentage,
--					(g2.grievances_received_female/g2.total_count::float)*100 as grievances_received_male_percentage,
--					(g2.grievances_received_others/g2.total_count::float)*100 as grievances_received_male_percentage
--				from
--					(select
--						SUM(g1.gender_wise_count) as total_count,
--						MAX(CASE WHEN gm.applicant_gender = 1 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_male,
--					    MAX(CASE WHEN gm.applicant_gender = 2 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_female, 
--					    MAX(CASE WHEN gm.applicant_gender = 3 and gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_received_others,
--						MAX(CASE WHEN g1.applicant_gender is null  THEN g1.gender_wise_count END) AS grievances_received_no_gender
--					from 
--						(select
--							count(1) as gender_wise_count,
--									from grievance_master gm) gl) g2;
--			end if;
--		end if;			
--	END;
--$function$
--;





DROP FUNCTION public.cmo_grievance_counts_gender(int4, int4);

CREATE OR REPLACE FUNCTION public.cmo_grievance_counts_gender(ssm_id integer, dept_id integer)
RETURNS TABLE(
    total_count bigint,
    grievances_recieved_male bigint,
    grievances_recieved_female bigint,
    grievances_recieved_others bigint,
    grievances_recieved_male_percentage float,
    grievances_recieved_female_percentage float,
    grievances_recieved_others_percentage float
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_others
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
                  AND (gm.assigned_to_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                  )
            ) AS g2;

        ELSE
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_others
                FROM grievance_master gm
                WHERE (gm.assigned_to_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                )
            ) AS g2;
        END IF;
    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_others
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
            ) AS g2;

        ELSE
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.grievances_received_male,
                g2.grievances_received_female,
                g2.grievances_received_others,
                (g2.grievances_received_male::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_male_percentage,
                (g2.grievances_received_female::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_female_percentage,
                (g2.grievances_received_others::float / NULLIF(g2.total_count, 0)) * 100 AS grievances_recieved_others_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_gender = 1 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_male,
                    COUNT(CASE WHEN gm.applicant_gender = 2 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_female,
                    COUNT(CASE WHEN gm.applicant_gender = 3 AND gm.created_on >= '2023-06-08' THEN 1 END) AS grievances_recieved_others
                FROM grievance_master gm
            ) AS g2;
        END IF;
    END IF;
END;
$function$;



 DROP FUNCTION public.cmo_grievance_counts_age(int4, int4);

CREATE OR REPLACE public.cmo_grievance_counts_age(ssm_id integer, dept_id integer)
RETURNS TABLE(
    total_count bigint,
    age_below_18 bigint,
    age_18_30 bigint,
    age_31_45 bigint,
    age_46_60 bigint,
    age_above_60 bigint,
    age_below_18_percentage float,
    age_18_30_percentage float,
    age_31_45_percentage float,
    age_46_60_percentage float,
    age_above_60_percentage float
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
                  AND (gm.assigned_to_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                  )
            ) g2;
        ELSE
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60
                FROM grievance_master gm
                WHERE (gm.assigned_to_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                )
            ) g2;
        END IF;
    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
            ) g2;
        ELSE
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60
                FROM grievance_master gm
            ) g2;
        END IF;
    END IF;
END;
$function$;



 DROP FUNCTION public.cmo_grievance_counts_age(int4, int4);

CREATE OR REPLACE FUNCTION cmo_grievance_counts_age(ssm_id integer, dept_id integer)
RETURNS TABLE(
    total_count bigint,
    age_below_18 bigint,
    age_18_30 bigint,
    age_31_45 bigint,
    age_46_60 bigint,
    age_above_60 bigint,
    age_below_18_male bigint,
    age_18_30_male bigint,
    age_31_45_male bigint,
    age_46_60_male bigint,
    age_above_60_male bigint,
    age_below_18_female bigint,
    age_18_30_female bigint,
    age_31_45_female bigint,
    age_46_60_female bigint,
    age_above_60_female bigint,
    age_below_18_male_percentage float,
    age_18_30_male_percentage float,
    age_31_45_male_percentage float,
    age_46_60_male_percentage float,
    age_above_60_male_percentage float,
    age_below_18_female_percentage float,
    age_18_30_female_percentage float,
    age_31_45_female_percentage float,
    age_46_60_female_percentage float,
    age_above_60_female_percentage float,
    age_below_18_percentage float,
    age_18_30_percentage float,
    age_31_45_percentage float,
    age_46_60_percentage float,
    age_above_60_percentage float
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF dept_id > 0 THEN
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
				g2.age_below_18_male,
			    g2.age_18_30_male,
			    g2.age_31_45_male,
			    g2.age_46_60_male,
			    g2.age_above_60_male,
			    g2.age_below_18_female,
			    g2.age_18_30_female,
			    g2.age_31_45_female,
			    g2.age_46_60_female,
			    g2.age_above_60_female,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage,
				(g2.age_below_18_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_male_percentage,
                (g2.age_18_30_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_male_percentage,
                (g2.age_31_45_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_male_percentage,
				(g2.age_46_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_male_percentage,
                (g2.age_above_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_male_percentage,
				(g2.age_below_18_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_female_percentage,
                (g2.age_18_30_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_female_percentage,
                (g2.age_31_45_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_female_percentage,
				(g2.age_46_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_female_percentage,
                (g2.age_above_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_female_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
                  AND (gm.assigned_to_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                        SELECT apm.position_id
                        FROM admin_position_master apm
                        WHERE apm.office_id = dept_id)
                  )
            ) g2;

        ELSE
            RETURN QUERY
            SELECT
               g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
				g2.age_below_18_male,
			    g2.age_18_30_male,
			    g2.age_31_45_male,
			    g2.age_46_60_male,
			    g2.age_above_60_male,
			    g2.age_below_18_female,
			    g2.age_18_30_female,
			    g2.age_31_45_female,
			    g2.age_46_60_female,
			    g2.age_above_60_female,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage,
				(g2.age_below_18_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_male_percentage,
                (g2.age_18_30_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_male_percentage,
                (g2.age_31_45_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_male_percentage,
				(g2.age_46_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_male_percentage,
                (g2.age_above_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_male_percentage,
				(g2.age_below_18_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_female_percentage,
                (g2.age_18_30_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_female_percentage,
                (g2.age_31_45_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_female_percentage,
				(g2.age_46_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_female_percentage,
                (g2.age_above_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_female_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
                FROM grievance_master gm
                WHERE (gm.assigned_to_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                       OR gm.updated_by_position IN (
                          SELECT apm.position_id
                          FROM admin_position_master apm
                          WHERE apm.office_id = dept_id)
                )
            ) g2;
        END IF;
    ELSE
        IF ssm_id > 0 THEN
            RETURN QUERY
            SELECT
                g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
				g2.age_below_18_male,
			    g2.age_18_30_male,
			    g2.age_31_45_male,
			    g2.age_46_60_male,
			    g2.age_above_60_male,
			    g2.age_below_18_female,
			    g2.age_18_30_female,
			    g2.age_31_45_female,
			    g2.age_46_60_female,
			    g2.age_above_60_female,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage,
				(g2.age_below_18_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_male_percentage,
                (g2.age_18_30_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_male_percentage,
                (g2.age_31_45_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_male_percentage,
				(g2.age_46_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_male_percentage,
                (g2.age_above_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_male_percentage,
				(g2.age_below_18_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_female_percentage,
                (g2.age_18_30_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_female_percentage,
                (g2.age_31_45_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_female_percentage,
				(g2.age_46_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_female_percentage,
                (g2.age_above_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_female_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
                FROM grievance_master gm
                WHERE gm.grievance_source = ssm_id
            ) g2;

        ELSE
            RETURN QUERY
            SELECT
               g2.total_count,
                g2.age_below_18,
                g2.age_18_30,
                g2.age_31_45,
				g2.age_46_60,
                g2.age_above_60,
				g2.age_below_18_male,
			    g2.age_18_30_male,
			    g2.age_31_45_male,
			    g2.age_46_60_male,
			    g2.age_above_60_male,
			    g2.age_below_18_female,
			    g2.age_18_30_female,
			    g2.age_31_45_female,
			    g2.age_46_60_female,
			    g2.age_above_60_female,
                (g2.age_below_18::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_percentage,
                (g2.age_18_30::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_percentage,
                (g2.age_31_45::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_percentage,
				(g2.age_46_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_percentage,
                (g2.age_above_60::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_percentage,
				(g2.age_below_18_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_male_percentage,
                (g2.age_18_30_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_male_percentage,
                (g2.age_31_45_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_male_percentage,
				(g2.age_46_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_male_percentage,
                (g2.age_above_60_male::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_male_percentage,
				(g2.age_below_18_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_below_18_female_percentage,
                (g2.age_18_30_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_18_30_female_percentage,
                (g2.age_31_45_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_31_45_female_percentage,
				(g2.age_46_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_46_60_female_percentage,
                (g2.age_above_60_female::float / NULLIF(g2.total_count, 0)) * 100 AS age_above_60_female_percentage
            FROM (
                SELECT
                    COUNT(*) AS total_count,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 THEN 1 END) AS age_below_18,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 THEN 1 END) AS age_18_30,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 THEN 1 END) AS age_31_45,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 THEN 1 END) AS age_46_60,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 THEN 1 END) AS age_above_60,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 1 THEN 1 END) AS age_below_18_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 1 THEN 1 END) AS age_18_30_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 1 THEN 1 END) AS age_31_45_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 1 THEN 1 END) AS age_46_60_male,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 1 THEN 1 END) AS age_above_60_male,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 0 AND 17 and gm.applicant_gender = 2 THEN 1 END) AS age_below_18_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 18 AND 30 and gm.applicant_gender = 2 THEN 1 END) AS age_18_30_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 31 AND 45 and gm.applicant_gender = 2 THEN 1 END) AS age_31_45_female,
					COUNT(CASE WHEN gm.applicant_age BETWEEN 46 AND 60 and gm.applicant_gender = 2 THEN 1 END) AS age_46_60_female,
                    COUNT(CASE WHEN gm.applicant_age BETWEEN 61 AND 120 and gm.applicant_gender = 2 THEN 1 END) AS age_above_60_female
                FROM grievance_master gm
            ) g2;
        END IF;
    END IF;
END;
$function$;