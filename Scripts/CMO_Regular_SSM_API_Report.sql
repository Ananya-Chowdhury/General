
---===============================================
----- SSM API PULL API QUERY UPGRADATION -----
---===============================================
--==
--==
--==================================================
--- Till Not Pulled Batches Aggre ---
---=================================================
--==
--================================================================================================
----------------------- SSM APi PULL CHecK IF Any ID NOT Processed -------------------------------
--================================================================================================
select * from cmo_batch_time_master c;

select
	a.*
from 
	(select 
		distinct(cbrd.batch_date::date),
		count(cbrd.batch_id) as batchs,
		ARRAY_AGG(cbrd.batch_id)
	from cmo_batch_run_details cbrd
	left join cmo_batch_time_master cbtm on cbtm.batch_time_master_id = cbrd.batch_id
	where status = 'S'
	group by cbrd.batch_date::date
	order by cbrd.batch_date desc) a
where a.batchs < 96;


--=============================================================================================
--========================== SSM API Regular Pulled Batches Check =============================
--=============================================================================================
SELECT
    a.*,
    '[' || array_to_string(
        ARRAY(
            SELECT g
            FROM generate_series(1, 96) g
            WHERE g <> ALL (string_to_array(a.batch_ids, ', ')::int[])
            ORDER BY g
        ),
        ', '
    ) || ']' AS missing_batch_ids,
    case
    	when a.batchs >= 96 then 'Synced'
    	else
    		array_to_string(
		        ARRAY(
		            SELECT CONCAT(cbtm.from_time,' - ',cbtm.to_time)
		            FROM generate_series(1, 96) g
		            inner join cmo_batch_time_master cbtm on cbtm.batch_time_master_id = g
		            WHERE g <> ALL (string_to_array(a.batch_ids, ', ')::int[])
		            ORDER BY g
		        ),
		        ', '
		    )
    end AS missing_batch_timeslots
FROM 
    (
    SELECT 
        cbrd.batch_date::date,
        COUNT(cbrd.batch_id) AS batchs,
        array_to_string(
            ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
            ', '
        ) AS batch_ids
    FROM cmo_batch_run_details cbrd
    LEFT JOIN cmo_batch_time_master cbtm 
        ON cbtm.batch_time_master_id = cbrd.batch_id
    WHERE status = 'S'
    GROUP BY cbrd.batch_date::date
    ORDER BY cbrd.batch_date::date DESC
) a
WHERE (a.batchs <= 96 or a.batchs > 96) ;
------------------------------------------------------------------------------------------------------

--====================================================================================================
--------------- Error Not Pulled Batches Pulled & Missing Batches Report -----------------------------
--====================================================================================================
SELECT
    a.*,
    '[' || array_to_string(
        ARRAY(
            SELECT g
            FROM generate_series(1, 96) g
            WHERE g <> ALL (string_to_array(a.batch_ids, ', ')::int[])
            ORDER BY g
        ),
        ', '
    ) || ']' AS missing_batch_ids
FROM 
    (
        SELECT 
            cbrd.batch_date::date,
            COUNT(cbrd.batch_id) AS batchs,
            array_to_string(
                ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
                ', '
            ) AS batch_ids
        FROM cmo_batch_run_details cbrd
        LEFT JOIN cmo_batch_time_master cbtm 
            ON cbtm.batch_time_master_id = cbrd.batch_id
        WHERE status = 'S'
        GROUP BY cbrd.batch_date::date
        ORDER BY cbrd.batch_date::date DESC
    ) a
WHERE a.batchs < 96;


------------------------------------------------------------------
--================================================================
SELECT
    a.*,
    '[' || array_to_string(
        ARRAY(
            SELECT g
            FROM generate_series(1, 96) g
            WHERE g <> ALL (string_to_array(a.batch_ids, ', ')::int[])
            ORDER BY g
        ),
        ', '
    ) || ']' AS missing_batch_ids
FROM 
    (
        SELECT 
            cbrd.batch_date::date,
            COUNT(cbrd.batch_id) AS batchs,
            array_to_string(
                ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
                ', '
            ) AS batch_ids
        FROM cmo_batch_run_details cbrd
        LEFT JOIN cmo_batch_time_master cbtm 
            ON cbtm.batch_time_master_id = cbrd.batch_id
        WHERE status = 'S'
        GROUP BY cbrd.batch_date::date
        ORDER BY cbrd.batch_date::date DESC
    ) a
WHERE a.batchs <= 96;
--====================================================================
----------------------------------------------------------------------


--============================================================================================
--============================================================================================
--===================  P  E  N  D  I  N  G    B  A  T  C  H  E  S  ===========================
--============================================================================================
--============================================================================================


--===================================================================
----------- Total Pending SSM PULL Batches Count Query --------------
--===================================================================
 select * from (
SELECT
    a.batch_date,
    a.batchs AS successful_batches,
    cardinality(
        ARRAY(
            SELECT g
            FROM generate_series(1, 96) g
            WHERE g <> ALL (string_to_array(a.batch_ids, ',')::int[])
        )
    ) AS pending_batches,
    a.total_grievances_pulled
    -- a.grievance_count
FROM (
    SELECT 
        cbrd.batch_date::date,
        COUNT(cbrd.batch_id) AS batchs,
        array_to_string(
            ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
            ','
        ) AS batch_ids,
        sum(cbrd.data_count) as total_grievances_pulled
        -- count(distinct cbgli.griev_id) as grievance_count
    FROM cmo_batch_run_details cbrd
    LEFT JOIN cmo_batch_time_master cbtm ON cbtm.batch_time_master_id = cbrd.batch_id
--     inner join cmo_batch_grievance_line_item cbgli on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    WHERE cbrd.status = 'S'
    GROUP BY cbrd.batch_date::date --, cbgli.cmo_batch_run_details_id::int
    ORDER BY cbrd.batch_date::date DESC
) a
 ) z_q WHERE pending_batches <> 0;

----------------------------------------------------------------------------

--============================================================================================
--============================================================================================
--=====================  R  E  G  U  L  A  R    R  E  P  O  R  T  ============================
--============================================================================================
--============================================================================================

--=========================================================================
--- Overall SSM Pull Status ---- Day Wise --->>>>>> [OLD Query Decrepted] --
--=========================================================================
WITH batch_summary AS (
    SELECT 
        cbrd.batch_date::date,
        COUNT(cbrd.batch_id) AS batchs,
        COUNT(*) FILTER (WHERE cbrd.status = 'S') AS success_pull_count,
        COUNT(*) FILTER (WHERE cbrd.status = 'F') AS failed_pull_count,
        array_to_string(
            ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
            ','
        ) AS batch_ids,
        SUM(cbrd.data_count) AS total_grievances_pulled
    FROM cmo_batch_run_details cbrd
    LEFT JOIN cmo_batch_time_master cbtm 
        ON cbtm.batch_time_master_id = cbrd.batch_id
    GROUP BY cbrd.batch_date::date
),
status_summary AS (
    SELECT
        cbrd.batch_date::date,
        COUNT(*) FILTER (WHERE cbgli.status = 1) AS initiate_count,
        COUNT(*) FILTER (WHERE cbgli.status = 2) AS success_count,
        COUNT(*) FILTER (WHERE cbgli.status = 3) AS failed_count,
        COUNT(*) FILTER (WHERE cbgli.status = 4) AS rectified_count,
        COUNT(*) FILTER (WHERE cbgli.status = 5) AS duplicate_count,
        COUNT(*) AS total_records
    FROM cmo_batch_run_details cbrd
    INNER JOIN cmo_batch_grievance_line_item cbgli 
        ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    GROUP BY cbrd.batch_date::date
)
SELECT 
    a.batch_date,
    a.batchs AS total_batches_pulled,
    coalesce(a.success_pull_count, 0) as success_pull_count,
    coalesce(a.failed_pull_count, 0) as failed_pull_count,
    cardinality(
        ARRAY(
            SELECT g
            FROM generate_series(1, 96) g
            WHERE g <> ALL (string_to_array(a.batch_ids, ',')::int[])
        )
    ) AS pending_batches,
    COALESCE(a.total_grievances_pulled, 0) AS total_grievances_pulled,
    COALESCE(s.initiate_count, 0) AS initiate_count,
    COALESCE(s.success_count, 0) AS success_count,
    COALESCE(s.failed_count, 0) AS failed_count,
    COALESCE(s.rectified_count, 0) AS rectified_count,
    COALESCE(s.duplicate_count, 0) AS duplicate_count,
    COALESCE(s.total_records, 0) AS total_records
FROM batch_summary a
LEFT JOIN status_summary s 
    ON a.batch_date = s.batch_date
WHERE (a.batchs <= 96 or a.batchs > 96)  
	-- and a.batch_date >= '2025-01-01'
	and a.batch_date between '2024-11-12' and '2025-10-10'
ORDER BY a.batch_date desc;


select distinct
	cbrd.status, 
	count(cbrd.status) as status_count
from cmo_batch_run_details cbrd
group by cbrd.status ;
--where cbrd.status = 'S';
-------------------------------------------------------------------

--=================================================================
-- Overall SSM Pull Status ---->>>  Day Wise Latest Upadate ---->>
--=================================================================
WITH batch_summary AS (
    SELECT 
        cbrd.batch_date::date,
        COUNT(cbrd.batch_id) AS batchs,
        COUNT(*) FILTER (WHERE cbrd.status = 'S') AS success_pull_count,
        COUNT(*) FILTER (WHERE cbrd.status = 'F') AS failed_pull_count,
        array_to_string(
            ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
            ','
        ) AS batch_ids,
        SUM(cbrd.data_count) AS total_grievances_pulled
    FROM cmo_batch_run_details cbrd
    LEFT JOIN cmo_batch_time_master cbtm 
        ON cbtm.batch_time_master_id = cbrd.batch_id
    GROUP BY cbrd.batch_date::date
),
status_summary AS (
    SELECT
        cbrd.batch_date::date,
        -- status wise counts
        COUNT(*) FILTER (WHERE cbgli.status = 1) AS initiate_count,
        COUNT(*) FILTER (WHERE cbgli.status = 2) AS success_count,
        COUNT(*) FILTER (WHERE cbgli.status = 3) AS failed_count,
        COUNT(*) FILTER (WHERE cbgli.status = 4) AS rectified_count,
        COUNT(*) FILTER (WHERE cbgli.status = 5) AS duplicate_count,
        -- total count of grievances processed
        COUNT(*) AS total_records,
        -- ✅ success grievances that exist in grievance_master
        COUNT(*) FILTER (WHERE cbgli.status = 2 AND EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id)) AS grievances_success_count,
        -- ❌ failed grievances that do NOT exist in grievance_master
        COUNT(*) FILTER (WHERE cbgli.status = 3 AND NOT EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id)) AS grievances_failed_count
    FROM cmo_batch_run_details cbrd
    INNER JOIN cmo_batch_grievance_line_item cbgli ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    GROUP BY cbrd.batch_date::date  
),
pending_batches_summary AS (
    SELECT
        a.batch_date,
        cardinality(
            ARRAY(
                SELECT g
                FROM generate_series(1, 96) g
                WHERE g <> ALL (string_to_array(a.batch_ids, ',')::int[])
            )
        ) AS pending_batches
    FROM (
        SELECT 
            cbrd.batch_date::date,
            array_to_string(
                ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
                ','
            ) AS batch_ids
        FROM cmo_batch_run_details cbrd
        WHERE cbrd.status = 'S'
        GROUP BY cbrd.batch_date::date
    ) a
)
SELECT 
    a.batch_date,
    a.batchs AS total_batches_pulled,
    COALESCE(a.success_pull_count, 0) AS success_pull_count,
    COALESCE(a.failed_pull_count, 0) AS failed_pull_count,
    COALESCE(pb.pending_batches, 0) AS pending_batches,
    COALESCE(a.total_grievances_pulled, 0) AS total_grievances_pulled,
    -- ✅ values from modified status_summary
    COALESCE(s.grievances_success_count, 0) AS grievances_success_count,
    COALESCE(s.grievances_failed_count, 0) AS grievances_failed_count,
    COALESCE(s.duplicate_count, 0) AS grievances_duplicate_count,
    COALESCE(s.initiate_count, 0) AS grievances_initiate_count,
    COALESCE(s.rectified_count, 0) AS grievances_rectified_count,
    COALESCE(s.total_records, 0) AS total_records
FROM batch_summary a
LEFT JOIN status_summary s ON a.batch_date = s.batch_date
LEFT JOIN pending_batches_summary pb ON a.batch_date = pb.batch_date
WHERE a.batch_date BETWEEN '2024-11-12' AND '2025-10-14'
ORDER BY a.batch_date DESC;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--============================================================================================
--============================================================================================
--=================================  F A I L E D  ============================================
--============================================================================================
--============================================================================================


--===============================================================================
----------- Total SSM PUSH FAILED ---->>> Unprocessed Grievance Count -----------
--===============================================================================
with ssm_pull_data_failed as (
	-- Failed Entry (Not validated) - 4215
	select
		cbrd.batch_date,
		cbrd.from_time,
		cbrd.to_time,
		cbrd.created_no,
		cbrd.processed,
		cbgli.cmo_batch_run_details_id,
		cbgli.griev_id,
		cbgli.status,
		cbgli.error,
		cbgli.processed_on
	from cmo_batch_grievance_line_item cbgli
	inner join cmo_batch_run_details cbrd on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
	where cbgli.status = 3 and not exists (select 1 from grievance_master gm where gm.grievance_no = cbgli.griev_id)
)
select distinct
	spdf.batch_date::date,
	spdf.from_time,
	spdf.to_time,
	spdf.error::varchar,
	spdf.griev_id,
	spdf.cmo_batch_run_details_id,
	count(spdf.error)::integer
from ssm_pull_data_failed spdf
where spdf.batch_date between '2024-11-12'::date and (current_timestamp::date) --  - INTERVAL '1 day')::date
group by spdf.batch_date,spdf.error,spdf.from_time,spdf.to_time, spdf.griev_id, spdf.cmo_batch_run_details_id
order by spdf.batch_date desc;


WITH ssm_pull_data_failed AS (
	SELECT
		cbrd.batch_date,
		cbrd.from_time,
		cbrd.to_time,
		cbrd.created_no,
		cbrd.processed,
		cbgli.cmo_batch_run_details_id,
		cbgli.griev_id,
		cbgli.status,
		cbgli.error,
		cbgli.processed_on
	FROM cmo_batch_grievance_line_item cbgli
	INNER JOIN cmo_batch_run_details cbrd 
		ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
	WHERE cbgli.status = 3 
	  AND NOT EXISTS (
		SELECT 1 
		FROM grievance_master gm 
		WHERE gm.grievance_no = cbgli.griev_id
	  )
),
latest_failed AS (
	SELECT
		spdf.*,
		ROW_NUMBER() OVER (
			PARTITION BY spdf.griev_id
			ORDER BY spdf.processed_on DESC NULLS LAST
		) AS rn
	FROM ssm_pull_data_failed spdf
	WHERE spdf.batch_date BETWEEN '2024-11-12'::date AND current_date
)
SELECT
	lf.batch_date::date,
	lf.from_time,
	lf.to_time,
	lf.error::varchar,
	lf.griev_id,
	lf.cmo_batch_run_details_id,
	1 AS total_count
FROM latest_failed lf
WHERE lf.rn = 1
ORDER BY lf.batch_date DESC;



select * from grievance_master gm where gm.grievance_no = 'SSM3994762';
select * from cmo_batch_grievance_line_item cbgli where cbgli.status = 3;
select * from cmo_emp_batch_run_details order by cmo_emp_batch_run_details_id desc limit 1;

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

---------------------------  Data Checking --------------------------------------
--===============================================================================

---- SSM Batches 
select * from cmo_batch_grievance_line_item cbgli where /*cbgli.status = 3 and*/ cbgli.griev_id = 'SSM4295850';  -- FAILURE >> |Police Station not found in grievance number SSM4295850
select * from cmo_batch_run_details cbrd where cbrd.cmo_batch_run_details_id = 38204;
select cbgli.ps_code, cbgli.griev_id, cbgli.error from cmo_batch_grievance_line_item cbgli where cbgli.griev_id in ('SSM4352563','SSM4352782','SSM4352712','SSM4352641','SSM4344439','SSM4344321','SSM4343619','SSM4343494','SSM4343116','SSM4342890','SSM4342859','SSM4342472','SSM4342260','SSM4341795','SSM4340729','SSM4340656','SSM4340161','SSM4342579','SSM4315952','SSM4325769','SSM4344501','SSM4340021','SSM4339528','SSM4339215','SSM4338903','SSM4338843','SSM4338645','SSM4338572','SSM4338401','SSM4338252','SSM4337807','SSM4337515','SSM4337106','SSM4344670','SSM4329122','SSM4322647','SSM4336832','SSM4336106','SSM4336074','SSM4336023','SSM4335547','SSM4335361','SSM4334701','SSM4334665','SSM4328494','SSM4327366','SSM4328368','SSM4334076','SSM4333100','SSM4332777','SSM4328087','SSM4332152','SSM4332070','SSM4330411','SSM4330329','SSM4329669','SSM4322199','SSM4321681','SSM4288634','SSM4303624','SSM4309799','SSM4312981','SSM4313705','SSM4315288','SSM4317856','SSM4317949','SSM4318429','SSM4319105','SSM4319226','SSM4319381','SSM4319567','SSM4319610','SSM4320709','SSM4320789','SSM4320834','SSM4320856','SSM4320890','SSM4320911','SSM4321385','SSM4321759','SSM4321783','SSM4321899','SSM4321910','SSM4321997','SSM4322383','SSM4322391','SSM4322425','SSM4322539','SSM4322565','SSM4322606','SSM4322627','SSM4323802','SSM4324719','SSM4324926','SSM4325647','SSM4326245','SSM4326254','SSM4326480','SSM4326536','SSM4326627','SSM4326964','SSM4307376','SSM4316630','SSM4316524','SSM4316217','SSM4315542','SSM4315365','SSM4315198','SSM4314477','SSM4314269','SSM4314185','SSM4314086','SSM4313914','SSM4313663','SSM4313600','SSM4313466','SSM4312342','SSM4311736','SSM4311544','SSM4310975','SSM4310818','SSM4310593','SSM4317017','SSM4310012','SSM4310007','SSM4309761','SSM4309260','SSM4296590','SSM4288373','SSM4307358','SSM4306857','SSM4306366','SSM4305039','SSM4304768','SSM4304730','SSM4304404','SSM4303970','SSM4303585','SSM4303448','SSM4302695','SSM4302527','SSM4288300','SSM4302172','SSM4300534','SSM4300435','SSM4300411','SSM4299906','SSM4299275','SSM4299159','SSM4298982','SSM4298853','SSM4298783','SSM4298162','SSM4297260','SSM4296761','SSM4295993','SSM4296003'
);  -- FAILURE >> |Police Station not found in grievance number SSM4295850


select * from cmo_batch_grievance_line_item limit 1;
select * from cmo_batch_run_details cbrd order by cmo_batch_run_details_id desc limit 1;

select griev_cat_code from cmo_batch_grievance_line_item order by griev_cat_code;
select count(1), error from cmo_batch_grievance_line_item where griev_cat_code = '9' group by error;
select count(1), error from cmo_batch_grievance_line_item where gp_code group by error;

---- District Master 
select * from cmo_districts_master cdm where cdm.district_code = '11';
select * from cmo_districts_master cdm;

---- Grievance Category 
select * from cmo_grievance_category_master cgcm where cgcm.grievance_category_code = '18';
select * from cmo_grievance_category_master cgcm ;

---- Block Master 
select * from cmo_blocks_master cbm where cbm.block_code = '117';
select * from cmo_blocks_master cbm ;

---- Police Station 
select * from cmo_police_station_master cpsm where cpsm.ps_code = '527';
select * from cmo_police_station_master cpsm ; -- ps_id = 1 for not known 

---- Gram Panchayet 
select * from cmo_gram_panchayat_master cgpm where cgpm.gp_code = '001143';
select * from cmo_gram_panchayat_master cgpm ;

---- Ward Master 
select * from cmo_wards_master cwm ;


---- Post Office
select * from cmo_post_office_master cpom where cpom.po_code = '0286';

---- Skills Master 
select * from cmo_skill_master csm ;


---- Professional Qualification 
select * from cmo_professional_qualification_master cpqm;


---- Education Qualification
select * from cmo_educational_qualification_master ceqm ;


---------------------------------------------------------------------------------------------------

--==================================================================================================
--      ------------------- Month Wise Failure Of SSM PULL Failed Grievances -------------------
--==================================================================================================
WITH ssm_pull_data_failed AS (
	-- Failed Entry (Not validated)
	SELECT
		cbrd.batch_date,
		cbrd.from_time,
		cbrd.to_time,
		cbrd.created_no,
		cbrd.processed,
		cbgli.cmo_batch_run_details_id,
		cbgli.griev_id,
		cbgli.status,
		cbgli.error,
		cbgli.processed_on
	FROM cmo_batch_grievance_line_item cbgli
	INNER JOIN cmo_batch_run_details cbrd 
		ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
	WHERE cbgli.status = 3 
	  AND NOT EXISTS (
		SELECT 1 
		FROM grievance_master gm 
		WHERE gm.grievance_no = cbgli.griev_id
	  )
)
SELECT 
	TO_CHAR(spdf.batch_date, 'Month YYYY') AS month_year,
	COUNT(*) AS total_failures
FROM ssm_pull_data_failed spdf
WHERE spdf.batch_date BETWEEN '2024-11-12'::date AND current_date
GROUP BY TO_CHAR(spdf.batch_date, 'Month YYYY')
ORDER BY MIN(spdf.batch_date) DESC;

--=====================================================================

with ssm_pull_data_failed AS (
    select
        cbrd.batch_date,
        cbrd.from_time,
        cbrd.to_time,
        cbrd.created_no,
        cbrd.processed,
        cbgli.cmo_batch_run_details_id,
        cbgli.griev_id,
        cbgli.status,
        cbgli.error,
        cbgli.processed_on
    from cmo_batch_grievance_line_item cbgli
    inner join cmo_batch_run_details cbrd 
        on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    where cbgli.status = 3
      and not exists (
          select 1 
          from grievance_master gm 
          where gm.grievance_no = cbgli.griev_id
      )
)
select 
  distinct spdf.griev_id, 
    spdf.error
from ssm_pull_data_failed spdf
where spdf.error = 'false'
order by spdf.griev_id, spdf.error;


--==========================================================================

SELECT
    cbrd.batch_date,
	cbgli.griev_id,
    count(cbgli.griev_id) as total_count,
    COUNT(*) FILTER (WHERE cbgli.status = 2) AS success_count,
    COUNT(*) FILTER (WHERE cbgli.status = 3) AS failure_count,
    case
    	when cbgli.error is not null then cbgli.error
    	else 'No Error'
    end as failure_reason
FROM cmo_batch_run_details cbrd
INNER JOIN cmo_batch_grievance_line_item cbgli
    ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
WHERE cbrd.batch_date
	-- >= '2025-01-01' 
	between '2025-01-01'::date and current_timestamp::date
GROUP BY cbrd.batch_date,cbgli.griev_id, cbgli.error
having count(cbgli.griev_id) > 0 and COUNT(*) FILTER (WHERE cbgli.status = 3) > 0
ORDER BY cbrd.batch_date,cbgli.griev_id asc;


select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM1011115';

-- Failure Reason
select
	cbrd.batch_date,
	cbrd.batch_id,
	concat(cbrd.from_time,' - ',cbrd.to_time) as time_slot,
	cbgli.griev_id,
	cbgli.error
from cmo_batch_grievance_line_item cbgli
inner join cmo_batch_run_details cbrd on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
where cbrd.batch_date = '2025-10-08' and cbgli.status = 3;

--------------------------------------------------------------------


----- Master Entry Check For SSM Pull Grievance ----
select * from grievance_master where grievance_no = 'SSM5232741';


--------------------------------------------------------------------------------------------

--============================================================================================
--============================================================================================
--============================  D  U  P  L  I  C  A  T  E  ===================================
--============================================================================================
--============================================================================================

--===========================================================================================
----------------- Total Number of Duplicate Entry Count For SSM PULL Data -------------------
--===========================================================================================

---- Date Wise Duplicate Count ----
WITH ssm_pull_data_duplicate AS (
	SELECT
		cbrd.batch_date,
		cbrd.from_time,
		cbrd.to_time,
		cbrd.created_no,
		cbrd.processed,
		cbgli.cmo_batch_run_details_id,
		cbgli.griev_id,
		cbgli.status,
		cbgli.error,
		cbgli.processed_on,
		cbrd.batch_id
	FROM cmo_batch_grievance_line_item cbgli
	INNER JOIN cmo_batch_run_details cbrd ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
	WHERE cbgli.status = 5
)
select
	spd.batch_date,
		spd.from_time,
		spd.to_time,
		case 
			when spd.processed is true then 'True'
			else 'N/A'
		end as is_in_master,
		case 
			when spd.status = 5 then 'Duplicate'
			else 'N/A'
		end as status,
		spd.batch_id,
	spd.griev_id,
	COUNT(*) AS total_count
FROM ssm_pull_data_duplicate spd
--WHERE spd.batch_date BETWEEN '2025-10-01'::date AND '2025-10-12'::date
WHERE spd.batch_date = '2025-10-14'::date
GROUP BY spd.griev_id, spd.batch_date, spd.from_time, spd.to_time, spd.processed, spd.status, spd.batch_id
ORDER BY spd.batch_date DESC;

--===================================================================================
---- Batch Wise Duplicate Count ----
WITH ssm_pull_data_duplicate AS (
	SELECT
		cbrd.batch_date,
		cbrd.from_time,
		cbrd.to_time,
		cbrd.created_no,
		cbrd.processed,
		cbgli.cmo_batch_run_details_id,
		cbgli.griev_id,
		cbgli.status,
		cbgli.error,
		cbgli.processed_on,
		cbrd.batch_id
	FROM cmo_batch_grievance_line_item cbgli
	INNER JOIN cmo_batch_run_details cbrd 
		ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
	WHERE cbgli.status = 5
)
SELECT
	spd.griev_id,
	STRING_AGG(DISTINCT spd.batch_id::text, ', ') AS batch_ids,
	STRING_AGG(DISTINCT to_char(spd.batch_date, 'YYYY-MM-DD'), ', ') AS batch_dates,
	STRING_AGG(DISTINCT spd.from_time::text, ', ') AS from_times,
	STRING_AGG(DISTINCT spd.to_time::text, ', ') AS to_times,
	CASE 
		WHEN bool_or(spd.processed IS TRUE) THEN 'True'
		ELSE 'N/A'
	END AS is_in_master,
	'Duplicate' AS status,
	COUNT(*) AS total_count
FROM ssm_pull_data_duplicate spd
WHERE spd.batch_date BETWEEN '2025-10-01'::date AND '2025-10-12'::date
GROUP BY spd.griev_id
ORDER BY total_count DESC;

--========================================================================================

WITH ssm_pull_data_duplicate AS (
	SELECT
		cbrd.batch_date,
		cbrd.from_time,
		cbrd.to_time,
		cbrd.created_no,
		cbrd.processed,
		cbgli.cmo_batch_run_details_id,
		cbgli.griev_id,
		cbgli.status,
		cbgli.error,
		cbgli.processed_on,
		cbrd.batch_id
	FROM cmo_batch_grievance_line_item cbgli
	INNER JOIN cmo_batch_run_details cbrd ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
	WHERE cbgli.status = 5
)
SELECT
	spd.griev_id,
	'[' || STRING_AGG(DISTINCT spd.batch_id::text, ', ') || ']' AS batch_ids,
	'[' || STRING_AGG(DISTINCT to_char(spd.batch_date, 'YYYY-MM-DD'), ', ') || ']' AS batch_dates,
	'[' || STRING_AGG(DISTINCT spd.from_time::text, ', ') || ']' AS from_times,
	'[' || STRING_AGG(DISTINCT spd.to_time::text, ', ') || ']' AS to_times,
	CASE 
		WHEN bool_or(spd.processed IS TRUE) THEN 'True'
		ELSE 'N/A'
	END AS is_in_master,
	'Duplicate' AS status,
	COUNT(*) AS total_count
FROM ssm_pull_data_duplicate spd
WHERE spd.batch_date BETWEEN '2024-11-12'::date AND '2025-10-13'::date
GROUP BY spd.griev_id
ORDER BY total_count DESC;

--=====================================================================================
--- ----------------- Query Version Update ------------------

WITH ssm_pull_data_duplicate AS (
    SELECT
        cbrd.batch_date,
        cbrd.from_time,
        cbrd.to_time,
        cbrd.created_no,
        cbrd.processed,
        cbgli.cmo_batch_run_details_id,
        cbgli.griev_id,
        cbgli.status,
        cbgli.error,
        cbgli.processed_on,
        cbrd.batch_id
    FROM cmo_batch_grievance_line_item cbgli
    INNER JOIN cmo_batch_run_details cbrd ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    WHERE cbgli.status = 5
),
success_data AS (
    SELECT 
        cbgli.griev_id,
        cbrd.batch_id,
        MAX(cbgli.processed_on) AS success_processed_on
    FROM cmo_batch_grievance_line_item cbgli
    INNER JOIN cmo_batch_run_details cbrd ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    WHERE cbgli.status = 2
    GROUP BY cbgli.griev_id,cbrd.batch_id
)
SELECT
    spd.griev_id,
    '[' || STRING_AGG(DISTINCT spd.batch_id::text, ', ') || ']' AS batch_ids,
    '[' || STRING_AGG(DISTINCT s.batch_id::text, ', ') || ']' AS batch_ids_status_2,
    '[' || STRING_AGG(DISTINCT to_char(spd.batch_date, 'YYYY-MM-DD'), ', ') || ']' AS batch_dates,
    '[' || STRING_AGG(DISTINCT spd.from_time::text, ', ') || ']' AS from_times,
    '[' || STRING_AGG(DISTINCT spd.to_time::text, ', ') || ']' AS to_times,
    s.success_processed_on AS processed_on_status_2,
    CASE 
        WHEN bool_or(spd.processed IS TRUE) THEN 'True'
        ELSE 'N/A'
    END AS is_in_master,
    case 
		when spd.status = 5 then 'Duplicate'
		else 'N/A'
	end as status,
    COUNT(*) AS total_count
FROM ssm_pull_data_duplicate spd
LEFT JOIN success_data s ON s.griev_id = spd.griev_id
WHERE spd.batch_date BETWEEN '2024-11-12'::date AND '2025-10-13'::date
GROUP BY spd.griev_id, s.success_processed_on, spd.status
ORDER BY total_count DESC;


--============================================================================================
-- --------------------------- Grievance ID Wise Duplicate Count -----------------------------

WITH ssm_pull_data_duplicate AS (
    SELECT
        cbrd.batch_date,
        cbrd.from_time,
        cbrd.to_time,
        cbrd.created_no,
        cbrd.processed,
        cbgli.cmo_batch_run_details_id,
        cbgli.griev_id,
        cbgli.status,
        cbgli.error,
        cbgli.processed_on,
        cbrd.batch_id
    FROM cmo_batch_grievance_line_item cbgli
    INNER JOIN cmo_batch_run_details cbrd 
        ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    WHERE cbgli.status = 5
),
success_data AS (
    SELECT 
        cbgli.griev_id,
        cbrd.batch_id,
        MAX(cbgli.processed_on) AS success_processed_on
    FROM cmo_batch_grievance_line_item cbgli
    INNER JOIN cmo_batch_run_details cbrd 
        ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    WHERE cbgli.status = 2
    GROUP BY cbgli.griev_id, cbrd.batch_id
)
SELECT
    spd.griev_id,
    '[' || STRING_AGG(
        DISTINCT '({batch:' || spd.batch_id || 
        ', batch_date:' || to_char(spd.batch_date, 'YYYY-MM-DD') || 
        ', from_time:' || COALESCE(spd.from_time::text, 'NULL') || 
        ', to_time:' || COALESCE(spd.to_time::text, 'NULL') || '})', 
        ', '
    ) || ']' AS batch_details_status_5,
    '[' || STRING_AGG(DISTINCT s.batch_id::text, ', ') || ']' AS batch_ids_status_2,
    s.success_processed_on AS processed_on_status_2,
    CASE 
        WHEN bool_or(spd.processed IS TRUE) THEN 'True'
        ELSE 'N/A'
    END AS is_in_master,
    CASE 
        WHEN spd.status = 5 THEN 'Duplicate'
        ELSE 'N/A'
    END AS status,
    COUNT(*) AS total_count
FROM ssm_pull_data_duplicate spd
LEFT JOIN success_data s 
    ON s.griev_id = spd.griev_id
WHERE spd.batch_date BETWEEN '2024-11-12'::date AND '2025-10-13'::date
GROUP BY spd.griev_id, s.success_processed_on, spd.status
ORDER BY total_count DESC;


--=============================================================================
with ssm_pull_data_failed as (
	-- Failed Entry (Not validated) - 4215
	select
		cbrd.batch_date,
		cbrd.from_time,
		cbrd.to_time,
		cbrd.created_no,
		cbrd.processed,
		cbgli.cmo_batch_run_details_id,
		cbgli.griev_id,
		cbgli.status,
		cbgli.error,
		cbgli.processed_on
	from cmo_batch_grievance_line_item cbgli
	inner join cmo_batch_run_details cbrd on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
	where cbgli.status = 5 and exists (select 1 from grievance_master gm where gm.grievance_no = cbgli.griev_id)
)
select distinct
	spdf.batch_date::date,
	spdf.from_time,
	spdf.to_time,
	spdf.error::varchar,
	spdf.griev_id,
	count(spdf.error)::integer
from ssm_pull_data_failed spdf
--where spdf.batch_date between '2025-10-01'::date and (current_timestamp::date) --  - INTERVAL '1 day')::date
where spdf.batch_date = '2025-10-11'::date --  - INTERVAL '1 day')::date
group by spdf.batch_date,spdf.error,spdf.from_time,spdf.to_time, spdf.griev_id
order by spdf.batch_date desc;

-----------------------------------------------
--- Duplicate Grievnace Chceking Query -----
-----------------------------------------------
select 
	cbgli.* , cbrd.batch_id 
	from cmo_batch_grievance_line_item cbgli 
inner join cmo_batch_run_details cbrd on cbrd.cmo_batch_run_details_id = cbgli.cmo_batch_run_details_id 
where /*cbgli.status = 5 and*/ cbgli.griev_id = 'SSM5247567';


--==========================================================================================================
-----------------------------------------------------------------------------------------------------------
-- ------------------------------- Daywise Batch Wise Grievance Status ------------------------------------
-----------------------------------------------------------------------------------------------------------
--===========================================================================================================


select * from (
SELECT
    a.batch_date,
    a.batchs AS successful_batches,
    cardinality(
        ARRAY(
            SELECT g
            FROM generate_series(1, 96) g
            WHERE g <> ALL (string_to_array(a.batch_ids, ',')::int[])
        )
    ) AS pending_batches
FROM (
    SELECT 
        cbrd.batch_date::date,
        COUNT(cbrd.batch_id) AS batchs,
        array_to_string(
            ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
            ','
        ) AS batch_ids
    FROM cmo_batch_run_details cbrd
    LEFT JOIN cmo_batch_time_master cbtm 
        ON cbtm.batch_time_master_id = cbrd.batch_id
    WHERE status = 'S'
    GROUP BY cbrd.batch_date::date
    ORDER BY cbrd.batch_date::date DESC
) a
) z_q WHERE pending_batches <> 0;

---------------------------------------------------------------------

---=====================================================================================================================================================================================================
---=====================================================================================================================================================================================================
---=====================================================================================================================================================================================================



select count(*) from cmo_batch_grievance_line_item 
where cmo_batch_run_details_id = 37890 and griev_id = 'SSM5236014' and status = 3;

select cmo_batch_run_details_id from cmo_batch_run_details where data_count > 0 and processed = false;

select count(*) as count_ii, griev_id from cmo_batch_grievance_line_item cbgli 
inner join grievance_master gm on gm.grievance_no = griev_id 
where cbgli.status = 1 group by griev_id ;


--update cmo_batch_grievance_line_item set status = 5
--where status = 1 and griev_id in (select distinct griev_id from cmo_batch_grievance_line_item cbgli 
--inner join grievance_master gm on gm.grievance_no = griev_id 
--where cbgli.status = 1)


------- Kinnar Da'''ssss Query -------
with
    batch_line as (
        select 
            cbgli.cmo_batch_run_details_id,
            cbgli.griev_id
        from cmo_batch_grievance_line_item cbgli
        where cbgli.status = 3 
        group by cbgli.cmo_batch_run_details_id, cbgli.griev_id
    )
select
    bl.cmo_batch_run_details_id,
    cbrd.batch_id,
    cbrd.batch_date,
    cbrd.from_time,
    cbrd.to_time,
    cebrd.cmo_emp_batch_run_details_id,
    bl.griev_id
from batch_line bl
--inner join grievance_master gm on gm.grievance_no = bl.griev_id
inner join cmo_batch_run_details cbrd on cbrd.cmo_batch_run_details_id = bl.cmo_batch_run_details_id and cbrd.batch_date::date between '2025-10-01'::date and '2025-10-12'::date
left join cmo_emp_batch_run_details cebrd on cbrd.batch_date = cebrd.batch_date and cbrd.batch_id = cebrd.batch_id
where not exists (select 1 from grievance_master gm where gm.grievance_no = bl.griev_id)
order by cbrd.batch_date asc;

