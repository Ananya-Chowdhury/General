

select 
	
	from candidate_preferred_location cpl 
	left join candidates c on c.id = cpl.candidate_id 
	left join district_master dm on dm.id = cpl.district_id and dm.is_active = true
	left join candidate_preferred_services cps on cps.candidate_id = c.id 
	order by 
	
	
	
--====================================Candidates summary district/block wise================
SELECT
    dm.district_name,
    bm.block_name,
    COUNT(
        CASE
            WHEN c.candidate_type = 1 THEN 1
        END
    ) AS ddugky_total,
    COUNT(
        CASE
            WHEN c.candidate_type = 1
             AND c.is_verified = TRUE
            THEN 1
        END
    ) AS ddugky_total_verified,
    COUNT(
        CASE
            WHEN c.candidate_type = 1
             AND c.is_verified = TRUE
             AND c.interest_freelancer = TRUE
            THEN 1
        END
    ) AS ddugky_verified_work_freelancer_yes,
    COUNT(
        CASE
            WHEN c.candidate_type = 1
             AND c.is_verified = TRUE
             AND c.interest_freelancer = FALSE
            THEN 1
        END
    ) AS ddugky_verified_work_freelancer_no,
    COUNT(
        CASE
            WHEN c.candidate_type = 2 THEN 1
        END
    ) AS rseti_total,
    COUNT(
        CASE
            WHEN c.candidate_type = 2
             AND c.is_verified = TRUE
            THEN 1
        END
    ) AS rseti_total_verified,
    COUNT(
        CASE
            WHEN c.candidate_type = 2
             AND c.is_verified = TRUE
             AND c.interest_freelancer = TRUE
            THEN 1
        END
    ) AS rseti_verified_work_freelancer_yes,
    COUNT(
        CASE
            WHEN c.candidate_type = 2
             AND c.is_verified = TRUE
             AND c.interest_freelancer = FALSE
            THEN 1
        END
    ) AS rseti_verified_work_freelancer_no
FROM candidates c
left JOIN block_master bm ON c.block_id = bm.id
left JOIN district_master dm ON dm.id = bm.district_id
--WHERE dm.state_id = 14
GROUP by dm.district_name, bm.block_name
ORDER by dm.district_name, bm.block_name