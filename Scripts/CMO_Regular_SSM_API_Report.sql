
---===============================================
----- SSM API PULL API QUERY UPGRADATION -----
---===============================================
--==
--==
--==================================================
--- Till Not Pulled Batches Aggre ---
---=================================================

--===========================================================


---- SSM PULL CHECK ----
SELECT * 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-12-31'  -- 43119
and status = 'S'
ORDER by batch_id desc; -- cbrd.batch_id; --4307 (total data 3433 in 5 status = 2823 data) --22.05.24

SELECT * 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2025-04-04'
and status = 'S'
ORDER by batch_id desc;

 
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 43119; --SSM5439798, SSM5439927 ====== SSM12345, SSM67890
select * from em;
select * from cmo_batch_run_details cbrd where cbrd.batch_date::date = '2025-11-06' and cbrd.status = 'S' order by batch_id asc;
select * from cmo_emp_batch_run_details cebrd where cebrd.batch_date::date = '2025-11-07' and cebrd.status = 'S';
select * from grievance_master limit 1;

select * from cmo_batch_run_details cbrd WHERE batch_date::date = '2025-11-10' and status = 'S' ORDER by batch_id desc;


select count(*) from grievance_master gm 
inner join cmo_batch_grievance_line_item cbgli on cbgli.griev_id = gm.grievance_no or cbgli.griev_id = gm.usb_unique_id 
where gm.grievance_no = 'SSM5403074'


select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM5470603'

select * from cmo_batch_grievance_line_item cbgli 
inner join cmo_batch_run_details cbrd on cbrd.cmo_batch_run_details_id = cbgli.cmo_batch_run_details_id 
where cbgli.status = 1 and cbrd.batch_date::date != '2025-11-26';


--==============================================================================
--======================= R E P R O C E S S ====================================
--==============================================================================

--- Failure Reprocessed Data Coumt ----
select * from cmo_batch_grievance_line_item cbgli 
--inner join cmo_batch_run_details cbrd on cbrd.cmo_batch_run_details_id = cbgli.cmo_batch_run_details_id 
where /*cbgli.status = 1 and*/ cbgli.error = 'REPROCESS';

select distinct count(cbgli.griev_id) from cmo_batch_grievance_line_item cbgli
where /*cbgli.status = 1 and*/ cbgli.error = 'REPROCESS';

select cbgli.cmo_batch_run_details_id from cmo_batch_grievance_line_item cbgli where cbgli.error = 'REPROCESS' order by cmo_batch_run_details_id asc;
select * from cmo_batch_grievance_line_item where status = 1 and error = 'REPROCESS' and cmo_batch_run_details_id in (11877) order by cmo_batch_run_details_id asc;

select distinct cbgli.cmo_batch_run_details_id from cmo_batch_grievance_line_item cbgli where cbgli.error = 'REPROCESS' /*and cbgli.cmo_batch_run_details_id in (11877) */ order by cbgli.cmo_batch_run_details_id asc;
select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM1011115';

select * from public.cmo_batch_grievance_line_item where status = 1 and error = 'REPROCESS' and cmo_batch_run_details_id in (41909) order by cmo_batch_run_details_id asc

select count(*) from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM3994762' and cbgli.status = 2

--==================================================================================

select * from cmo_batch_run_details cbrd where cbrd.cmo_batch_run_details_id in (15962);
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id in (15962);
select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM5389788';


select count(*) from public.grievance_master where grievance_no = 'SSM3288070' or usb_unique_id = 'SSM3288070';
select * from public.grievance_master where grievance_no = 'SSM3285002' or usb_unique_id = 'SSM3285002';
select * from public.grievance_master where grievance_no = 'SSM1111111' or usb_unique_id = 'SSM1111111';	

select * from grievance_master gm where gm.grievance_no like '%SSM%' order by gm.grievance_id desc limit 20;
select * from ssm_grievance_data_document_mapping sgddm ;


--=======================================================================================================================
---------------------------------------  SSM MASTER DATA VALIDATION -----------------------------------------------------
--=======================================================================================================================

select * from cmo_batch_grievance_line_item cbgli limit 1;
select * from cmo_emp_batch_run_details cebrd where cebrd.data_count > 10;
select * from cmo_batch_run_details cbrd limit 1;

select * from cmo_grivence_receive_mode_master ;
select * from cmo_domain_lookup_master where domain_type = 'received_at_location';
select domain_id, domain_code, domain_value, domain_abbr from public.cmo_domain_lookup_master where domain_type = 'gender';
select * from grievance_master gm where gm.applicant_name = ' ' limit 1 ;
select * from cmo_states_master csm ;
select * from public.cmo_municipality_master cmm;
select * from cmo_sub_divisions_master csdm where csdm.sub_division_id = 4;
select * from cmo_blocks_master cbm ;
select * from cmo_wards_master;
select * from cmo_grievance_category_master cgcm where cgcm.grievance_category_code = '08'

select * 
from cmo_blocks_master cbm 
inner join cmo_sub_divisions_master csdm on csdm.sub_division_id = cbm.sub_division_id 
where block_id = 26;


select * from document_master dm order by doc_id desc limit 5;
select * from cmo_domain_lookup_master cdlm ;


select * from ssm_grievance_data_document_mapping ;


select domain_code from cmo_domain_lookup_master cdlm where cdlm.domain_type = 'doc_type';

select parameter_value from cmo_parameter_master cpm where cpm.parameter_key = 'sftp_flag';


select * from cmo_batch_run_details cbrd limit 1;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------


---- Data Insert Checking -----
select count(cbgli.griev_id) 
from cmo_batch_run_details cbrd 
inner join cmo_batch_grievance_line_item cbgli on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id  
inner join grievance_master gm on  gm.grievance_no = cbgli.griev_id 
where cbrd.batch_date::date = '2025-11-08'



select cbgli.*, gm.status, gm.updated_on, gm.created_on  from cmo_batch_grievance_line_item cbgli 
inner join grievance_master gm on  gm.grievance_no  = cbgli.griev_id 
where cbgli.cmo_batch_run_details_id in (15835);


select * from cmo_batch_run_details cbrd where cbrd.batch_date::date = '2025-11-10' and cbrd.data_count > 0 order by data_count asc /*and cbrd.batch_id = 96*/;




select * 
from cmo_batch_grievance_line_item cbgli 
inner join cmo_batch_run_details cbrd on cbrd.cmo_batch_run_details_id = cbgli.cmo_batch_run_details_id 
where cbgli.griev_id = 'SSM4311094';
--where cbgli.cmo_batch_run_details_id = 41131;
--


select * from cmo_batch_run_details cbrd where cbrd.cmo_batch_run_details_id in (42056);
select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id in (42507)


select * from grievance_master gm where gm.grievance_no in ('SSM2955552','SSM2955721','SSM2958872','SSM2958892','SSM2958901');
select * from grievance_master gm where gm.usb_unique_id in ('SSM2955552','SSM2955721','SSM2958872','SSM2958892','SSM2958901')

---- For DATA CHECKING 
select * from cmo_batch_grievance_line_item cbgli 
inner join cmo_emp_batch_run_details cebrd on cebrd.cmo_batch_run_details_id = cbgli.cmo_batch_run_details_id and cebrd.status = 'S'
where cebrd.batch_date::date = '2025-11-10';

--update cmo_batch_grievance_line_item cbgli 
--set status = 2, error = 'SUCCESS' 
--from cmo_emp_batch_run_details cebrd
--where cebrd.cmo_batch_run_details_id = cbgli.cmo_batch_run_details_id and cebrd.status = 'S' and cebrd.batch_date::date = '2025-11-08' and cbgli.status = 5 and cbgli.error = 'DUPLICATE'


select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM4355314'; 


select cbgli.*
from cmo_batch_grievance_line_item cbgli 
inner join cmo_batch_run_details cbrd on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id 
where cbrd.batch_date::date = '2024-11-06' and cbrd.status = 'S';

select * from cmo_post_office_master cpom where cpom.po_code = '0160' and cpom.district_id = 2;
select * from cmo_districts_master cdm where cdm.district_code  = '13';
select * from cmo_districts_master cdm where cdm.district_id = 2;



--select cbgli.griev_id, cdm.district_name, cdm.district_id, cbgli.po_code, cpom.po_name
--from cmo_batch_grievance_line_item cbgli 
--inner join cmo_batch_run_details cbrd on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id 
--inner join cmo_districts_master cdm on cbgli.dist_code = cdm.district_code 
--inner join cmo_post_office_master cpom on cpom.po_code = cbgli.po_code and cdm.district_id = cpom.district_id
----where cbrd.batch_date::date = '2025-11-08'::date and cbrd.status = 'S' 
--and cbgli.status = 2 and cbgli.griev_received_date::date = '2025-11-08'
--order by cbgli.griev_id asc;



select
	cbgli.griev_id, cdm.district_name, cdm.district_id, cbgli.po_code, cpom.po_name, cpom.po_id  ,cbgli.emergency 
from cmo_batch_run_details cbrd
inner join cmo_batch_grievance_line_item cbgli on cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id and cbgli.status = 1
left join cmo_districts_master cdm on cbgli.dist_code = cdm.district_code
left join cmo_post_office_master cpom on cpom.po_code = cbgli.po_code and cpom.district_id = cdm.district_id
where cbrd.batch_date::date = '2025-11-10'::date and cdm.district_id = 22
order by cbgli.griev_id asc;





select * from cmo_domain_lookup_master cdlm where cdlm.domain_type = 'doc_type';
select * from cmo_post_office_master cpom where cpom.po_code = '0009'



--UPDATE cmo_batch_grievance_line_item AS cbgli
--SET status = 2, error = 'SUCCESS'
--from cmo_batch_run_details AS cbrd
--where cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id AND cbrd.batch_date::date = '2025-11-07' AND cbrd.status = 'S';


select * from cmo_emp_batch_run_details cebrd;
select * from cmo_batch_grievance_line_item cbgli where cbgli.education_qualification_code is not null limit 1;
select * from grievance_master gm limit 1;

select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_received_date::date = '2025-11-10';

select * from ssm_grievance_data_document_mapping sgddm ;

--===========================================================

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
    WHERE cbrd.status = 'S' and cbrd.batch_date::date >= '2024-12-19'::date
    GROUP BY cbrd.batch_date::date --, cbgli.cmo_batch_run_details_id::int
    ORDER BY cbrd.batch_date::date DESC
) a
 ) z_q WHERE pending_batches <> 0;

----------------------------------------------------------------------------

--================================ Batch Wise Timeslots ===========================================
SELECT *
FROM (
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
        '[' || array_to_string(
            ARRAY(
                SELECT g
                FROM generate_series(1, 96) g
                WHERE g <> ALL (string_to_array(a.batch_ids, ',')::int[])
                ORDER BY g
            ),
            ', '
        ) || ']' AS missing_batch_ids,
        CASE
            WHEN a.batchs >= 96 THEN 'Synced'
            ELSE array_to_string(
                ARRAY(
                    SELECT CONCAT(cbtm.from_time, ' - ', cbtm.to_time)
                    FROM generate_series(1, 96) g
                    INNER JOIN cmo_batch_time_master cbtm 
                        ON cbtm.batch_time_master_id = g
                    WHERE g <> ALL (string_to_array(a.batch_ids, ',')::int[])
                    ORDER BY g
                ),
                ', '
            )
        END AS missing_batch_timeslots,
        a.total_grievances_pulled
    FROM (
        SELECT 
            cbrd.batch_date::date,
            COUNT(cbrd.batch_id) AS batchs,
            array_to_string(
                ARRAY_AGG(cbrd.batch_id ORDER BY cbrd.batch_id ASC),
                ','
            ) AS batch_ids,
            SUM(cbrd.data_count) AS total_grievances_pulled
        FROM cmo_batch_run_details cbrd
        LEFT JOIN cmo_batch_time_master cbtm 
            ON cbtm.batch_time_master_id = cbrd.batch_id
        WHERE cbrd.status = 'S' 
        and cbrd.status = 'S' and cbrd.batch_date::date >= '2024-12-19'::date
        GROUP BY cbrd.batch_date::date
        ORDER BY cbrd.batch_date::date DESC
    ) a
) z_q
WHERE pending_batches <> 0;

---------------------------------------------------------------------------------

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
--        COUNT(*) FILTER (WHERE cbgli.status = 2) AS grievances_success_count,
--         ❌ failed grievances that do NOT exist in grievance_master
        COUNT(*) FILTER (WHERE cbgli.status = 3 AND NOT EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id)) AS grievances_failed_count
--        COUNT(*) FILTER (WHERE cbgli.status = 3) AS grievances_failed_count
    FROM cmo_batch_run_details cbrd
    INNER JOIN cmo_batch_grievance_line_item cbgli ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
    where cbrd.status = 'S'
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
--    COALESCE(s.initiate_count, 0) AS grievances_initiate_count,
    COALESCE(s.rectified_count, 0) AS grievances_rectified_count,
    COALESCE(s.total_records, 0) AS total_records
FROM batch_summary a
LEFT JOIN status_summary s ON a.batch_date = s.batch_date
LEFT JOIN pending_batches_summary pb ON a.batch_date = pb.batch_date
WHERE a.batch_date BETWEEN '2024-11-12' AND '2025-11-30'
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
		cbrd.batch_id,
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
	spdf.batch_id,
	spdf.from_time,
	spdf.to_time,
	spdf.error::varchar,
	spdf.griev_id,
	spdf.cmo_batch_run_details_id,
	count(spdf.error)::integer
from ssm_pull_data_failed spdf
--where spdf.batch_date between '2025-11-01'::date and '2025-11-20'::date --  - INTERVAL '1 day')::date
--where spdf.batch_date between '2025-11-24'::date and (current_timestamp::date  - INTERVAL '1 day')::date
--where spdf.batch_date::date = '2025-11-24'::date  - INTERVAL '1 day')::date
group by spdf.batch_date,spdf.error,spdf.from_time,spdf.to_time, spdf.griev_id, spdf.cmo_batch_run_details_id,spdf.batch_id
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
	WHERE spdf.batch_date BETWEEN '2025-11-01'::date AND current_date
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



select * from grievance_master gm where gm.grievance_no in ('SSM12345','SSM112233');
select * from grievance_lifecycle gl where gl.grievance_id in (6071960);
select * from cmo_batch_grievance_line_item cbgli where cbgli.status = 3;
select * from cmo_emp_batch_run_details order by cmo_emp_batch_run_details_id desc limit 1;

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

---------------------------  Data Checking --------------------------------------
--===============================================================================

---- SSM Batches 
select * from cmo_batch_grievance_line_item cbgli where /*cbgli.status = 3 and*/ cbgli.griev_id = 'SSM5471146';  -- FAILURE >> |Police Station not found in grievance number SSM4295850
select * from cmo_batch_run_details cbrd where cbrd.cmo_batch_run_details_id = 14975;
select cbgli.ps_code, cbgli.griev_id, cbgli.error from cmo_batch_grievance_line_item cbgli 
where cbgli.griev_id in ('SSM4352563','SSM4352782','SSM4352712','SSM4352641','SSM4344439','SSM4344321','SSM4343619','SSM4343494','SSM4343116','SSM4342890','SSM4342859',
'SSM4342472','SSM4342260','SSM4341795','SSM4340729','SSM4340656','SSM4340161','SSM4342579','SSM4315952','SSM4325769','SSM4344501','SSM4340021','SSM4339528','SSM4339215',
'SSM4338903','SSM4338843','SSM4338645','SSM4338572','SSM4338401','SSM4338252','SSM4337807','SSM4337515','SSM4337106','SSM4344670','SSM4329122','SSM4322647','SSM4336832',
'SSM4336106','SSM4336074','SSM4336023','SSM4335547','SSM4335361','SSM4334701','SSM4334665','SSM4328494','SSM4327366','SSM4328368','SSM4334076','SSM4333100','SSM4332777',
'SSM4328087','SSM4332152','SSM4332070','SSM4330411','SSM4330329','SSM4329669','SSM4322199','SSM4321681','SSM4288634','SSM4303624','SSM4309799','SSM4312981','SSM4313705',
'SSM4315288','SSM4317856','SSM4317949','SSM4318429','SSM4319105','SSM4319226','SSM4319381','SSM4319567','SSM4319610','SSM4320709','SSM4320789','SSM4320834','SSM4320856',
'SSM4320890','SSM4320911','SSM4321385','SSM4321759','SSM4321783','SSM4321899','SSM4321910','SSM4321997','SSM4322383','SSM4322391','SSM4322425','SSM4322539','SSM4322565',
'SSM4322606','SSM4322627','SSM4323802','SSM4324719','SSM4324926','SSM4325647','SSM4326245','SSM4326254','SSM4326480','SSM4326536','SSM4326627','SSM4326964','SSM4307376',
'SSM4316630','SSM4316524','SSM4316217','SSM4315542','SSM4315365','SSM4315198','SSM4314477','SSM4314269','SSM4314185','SSM4314086','SSM4313914','SSM4313663','SSM4313600',
'SSM4313466','SSM4312342','SSM4311736','SSM4311544','SSM4310975','SSM4310818','SSM4310593','SSM4317017','SSM4310012','SSM4310007','SSM4309761','SSM4309260','SSM4296590',
'SSM4288373','SSM4307358','SSM4306857','SSM4306366','SSM4305039','SSM4304768','SSM4304730','SSM4304404','SSM4303970','SSM4303585','SSM4303448','SSM4302695','SSM4302527',
'SSM4288300','SSM4302172','SSM4300534','SSM4300435','SSM4300411','SSM4299906','SSM4299275','SSM4299159','SSM4298982','SSM4298853','SSM4298783','SSM4298162','SSM4297260',
'SSM4296761','SSM4295993','SSM4296003'
);  -- FAILURE >> |Police Station not found in grievance number SSM4295850


select cbrd.cmo_batch_run_details_id from cmo_batch_run_details cbrd where cbrd.status = 'S' and cbrd.batch_date::date between '2025-11-07'::date and '2025-12-01' and cbrd.processed = true order by cbrd.batch_id asc

select * from cmo_batch_grievance_line_item limit 1;
select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM4314269';
select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_date::date = '2025-01-16';
select * from cmo_batch_run_details cbrd order by cmo_batch_run_details_id desc limit 1;

select griev_cat_code from cmo_batch_grievance_line_item order by griev_cat_code;
select count(1), error from cmo_batch_grievance_line_item where griev_cat_code = '9' group by error;
select count(1), error from cmo_batch_grievance_line_item where gp_code group by error;

select * from grievance_master gm where gm.applicant_address = 'Landmark: Kotalpara Mallikpara Mosque';


---- District Master 
select * from cmo_districts_master cdm where cdm.district_code = '03';
select * from cmo_districts_master cdm;
select * from cmo_districts_master cdm where cdm.district_name = 'Birbhum';

---- Grievance Category  
select * from cmo_grievance_category_master cgcm where cgcm.grievance_category_code = 'OT3';
select * from cmo_grievance_category_master cgcm ;
select * from cmo_grievance_category_master cgcm where cgcm.grievance_category_desc = 'Employment Prayer';

---- Block Master 
select * from cmo_blocks_master cbm where cbm.block_code = '525';
select * from cmo_blocks_master cbm ;
select * from cmo_blocks_master cbm where cbm.block_name = 'NALHATI-I';

----- Sub Divition ------
select * from cmo_sub_divisions_master csdm where csdm.sub_division_name = 'Rampurhat SDO';

---- Police Station 
select * from cmo_police_station_master cpsm where cpsm.ps_code = '0623' and cpsm.district_id = 18;
select * from cmo_police_station_master cpsm where cpsm.ps_name = 'Nalhati';
select * from cmo_police_station_master cpsm where cpsm.sub_district_id = 8 ; -- ps_id = 1 for not known 
--
---- Gram Panchayet 
select * from cmo_gram_panchayat_master cgpm where cgpm.gp_code = '006321';
select * from cmo_gram_panchayat_master cgpm ;
select * from cmo_gram_panchayat_master cgpm where cgpm.gp_name = 'BANIOR';

---- Sub Divition -----
select * from cmo_sub_divisions_master csdm where csdm.district_id = 4;
select * from cmo_sub_divisions_master csdm where csdm.sub_division_id = 60;


---- Ward Master 
select * from cmo_wards_master cwm ;	
select * from cmo_wards_master cwm where cwm.ward_code ='007069'	

------ Municipality -----
select * from cmo_municipality_master cmm where cmm.municipality_code = '517';

---- Post Office
select * from cmo_post_office_master cpom where cpom.po_code = '0287' and cpom.district_id = 4;
select * from cmo_post_office_master cpom where cpom.po_name = 'Sagrai B.O';

---- Skills Master 
select * from cmo_skill_master csm where csm.skill_code = '01' ;


---- Professional Qualification 
select * from cmo_professional_qualification_master cpqm where cpqm.professional_qualification_code = 'AB';


---- Education Qualification
select * from cmo_educational_qualification_master ceqm ;


----- Assembly Constitution -----
select * from cmo_assembly_master cam where cam.assembly_code = '000' and cam.district_id = 20;
select * from cmo_assembly_master cam where cam.assembly_name = 'Nalhati';


--------- Sub District --------
select * from cmo_sub_districts_master csdm ;


---------- Emplyment Status ---------
select * from cmo_employment_status_master cesm where cesm.employment_status_name = 'Employed';

-------- Employemnt Type ---------
select * from cmo_employment_type_master cetm where cetm.employment_type_name = 'Not Disclosed';


-------- State --------
select * from cmo_states_master csm ;



------- Social Category ------
select * from cmo_caste_master ccm where ccm.caste_name = 'SC';


------ religion -----
select * from cmo_religion_master crm where crm.religion_name = 'Hindu';
select * from cmo_religion_master crm where crm.religion_code = '02';



select * from cmo_batch_grievance_line_item cbgli where cbgli.griev_id = 'SSM4292981';




------- ALL MASTER DATA VALIDATED QUERY FOR CROSS CHECK ---------


select 
	cbgli.griev_id,
	cbgli.griev_date,
	cbgli.received_mode,
	cgrmm.grivence_source_name as received_mode_name,
	cbgli.received_at,
	cdlm.domain_value as received_at_name,
	cbgli.mobile_number,
	cbgli.citizen_name,
	cbgli.citizen_address,
	cbgli.dist_code,
	cdm.district_name,
	case 
		when cbm.block_id is not null then cbgli.blockm_code
		else null 
	end block_code,
	coalesce(cbm.block_name, 'N/A') as block_name,
	case 
		when cmm.municipality_id is not null then cbgli.blockm_code
		else null 
	end municip_code,
	coalesce(cmm.municipality_name, 'N/A') as municiply_name,
--	csdm.sub_division_name,
	case 
		when cgpm.gp_id is not null then cbgli.gp_code
		else null 
	end gp_code,
	coalesce(cgpm.gp_name, 'N/A') as gp_name,
	case 
		when cwm.ward_id is not null then cbgli.gp_code
		else null 
	end ward_code,
	coalesce(cwm.ward_name, 'N/A') as ward_name,
	cbgli.ps_code,
	coalesce(cpsm.ps_name, 'N/A') as police_name,
	cbgli.assembly_code,
	coalesce(cam.assembly_name, 'N/A') as assembly_name,
	cbgli.po_code,
	coalesce(cpom.po_name, 'N/A') as post_name,
	cbgli.gender,
	cdlm2.domain_value as gender_name,
	cbgli.citizen_age,
	cbgli.citizen_email,
	coalesce(cbgli.alternate_mobile, null) as alter_num,
	cbgli.citizen_caste,
	ccm.caste_name,
	cbgli.citizen_religion,
	crm.religion_name,
	cbgli.griev_cat_code,
	coalesce(cgcm.grievance_category_desc, 'N/A') as grievance_category 
from cmo_batch_grievance_line_item cbgli 
left join cmo_grivence_receive_mode_master cgrmm on cgrmm.grivence_source_code = cbgli.received_mode
left join cmo_domain_lookup_master cdlm on LOWER(REPLACE(cdlm.domain_value, ' ', '')) = LOWER(REPLACE(cbgli.received_at, '_', '')) and cdlm.domain_type = 'grievance_source'
left join cmo_districts_master cdm on cdm.district_code = cbgli.dist_code
left join cmo_blocks_master cbm on cbm.block_code = cbgli.blockm_code 
left join cmo_municipality_master cmm on cmm.municipality_code = cbgli.blockm_code
--left join cmo_sub_divisions_master csdm on csdm.district_id = cdm.district_id 
left join cmo_gram_panchayat_master cgpm on cgpm.gp_code = cbgli.gp_code 
left join cmo_wards_master cwm on cwm.ward_code = cbgli.gp_code 
left join cmo_police_station_master cpsm on cpsm.ps_code = cbgli.ps_code and cpsm.district_id = cdm.district_id 
left join cmo_assembly_master cam on cam.assembly_code = cbgli.assembly_code and cam.district_id = cdm.district_id 
left join cmo_post_office_master cpom on cpom.po_code = cbgli.po_code and cpom.district_id = cdm.district_id 
left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_abbr = cbgli.gender and cdlm2.domain_type = 'gender'
left join cmo_caste_master ccm on ccm.caste_code = cbgli.citizen_caste 
left join cmo_religion_master crm on crm.religion_code = cbgli.citizen_religion 
left join cmo_grievance_category_master cgcm on cgcm.grievance_category_code = cbgli.griev_cat_code 
where cbgli.griev_id = 'SSM5424637';



-------------------------------------------------------------------------------------------------

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
WHERE spd.batch_date BETWEEN '2024-11-12'::date AND '2025-10-16'::date
--WHERE spd.batch_date = '2025-10-16'::date
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

---- ========================= SSM DATA CHECKING QUERY SET ======================

select count(*) from cmo_batch_grievance_line_item 
where cmo_batch_run_details_id = 37890 and griev_id = 'SSM5236014' and status = 3;


select 
	griev_id,
	griev_date,
	griev_received_date,
	processed_on,
	status
from cmo_batch_grievance_line_item 
where griev_id in ('SSM1011144', 'SSM1011146', 'SSM1011147', 'SSM1011154', 'SSM1011158', 'SSM1011173', 'SSM1011174', 'SSM1011178', 'SSM1011179', 'SSM1011193', 'SSM1011198', 'SSM1011200', 'SSM1011206', 'SSM1011208', 'SSM1011210', 'SSM1011215', 'SSM1011216', 'SSM1011221', 'SSM1011223', 'SSM1011236', 'SSM1011239', 'SSM1011241', 'SSM1011246', 'SSM1011249', 'SSM1011251', 'SSM1011252', 'SSM1011253', 'SSM1011254', 'SSM1011258', 'SSM1011277', 'SSM1011282', 'SSM1011289', 'SSM1011293', 'SSM1011294', 'SSM1011297', 'SSM1011298', 'SSM1011302', 'SSM1011314', 'SSM1011320', 'SSM1011322', 'SSM1011327', 'SSM1011332', 'SSM1011334', 'SSM1011337', 'SSM1011338', 'SSM1011339', 'SSM1011344', 'SSM1011354', 'SSM1011360', 'SSM1011367', 'SSM1011369', 'SSM1011371', 'SSM1011372', 'SSM1011374', 'SSM1011376', 'SSM1011377', 'SSM1011394') ;



select 
	gm.grievance_id,
	gm.grievance_no,
	gm.grievance_generate_date,
	gm.created_on 
from grievance_master gm 
where gm.grievance_no in ('SSM1011144', 'SSM1011146', 'SSM1011147', 'SSM1011154', 'SSM1011158', 'SSM1011173', 'SSM1011174', 'SSM1011178', 'SSM1011179', 'SSM1011193', 'SSM1011198', 'SSM1011200', 'SSM1011206', 'SSM1011208', 'SSM1011210', 'SSM1011215', 'SSM1011216', 'SSM1011221', 'SSM1011223', 'SSM1011236', 'SSM1011239', 'SSM1011241', 'SSM1011246', 'SSM1011249', 'SSM1011251', 'SSM1011252', 'SSM1011253', 'SSM1011254', 'SSM1011258', 'SSM1011277', 'SSM1011282', 'SSM1011289', 'SSM1011293', 'SSM1011294', 'SSM1011297', 'SSM1011298', 'SSM1011302', 'SSM1011314', 'SSM1011320', 'SSM1011322', 'SSM1011327', 'SSM1011332', 'SSM1011334', 'SSM1011337', 'SSM1011338', 'SSM1011339', 'SSM1011344', 'SSM1011354', 'SSM1011360', 'SSM1011367', 'SSM1011369', 'SSM1011371', 'SSM1011372', 'SSM1011374', 'SSM1011376', 'SSM1011377', 'SSM1011394') ;



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




---================================================================================================================
--==================================== Failed Batches Retrival Count Batch Date Wise ==============================

select * 
	from cmo_batch_run_details cbrd where cbrd.;

	
	
	
	
---================================================================
	select count(1) as total_count
	from grievance_master gm 
--	where gm.created_on::date = '2025-10-17';
	where gm.grievance_generate_date::date between '2023-06-08' and '2025-11-06'
	and gm.grievance_source = 5;
	

	select count(*) as total from grievance_lifecycle gl ;
	
	select * from grievance_master gm limit 1;
	
	
--========================================================
	
	select 
        count(distinct com.office_id) 
    from cmo_office_master com 
    where com.status = 1 and com.district_id != 999
    union
    select 
    	count(distinct csom.office_id) 
    from cmo_sub_office_master csom
    where csom.status = 1 and csom.mapping_district_id != 999
    
    
---====================== HOME PAGE COUNT ===================
     select * from home_page_grievance_counts;   --- mat view 
     
     
     select count(*) as cou from grievance_master gm where gm.status = 15;
     
     
     SELECT count(1) AS total_grievance_count,
    sum(
        CASE
            WHEN gm.status = 15 THEN 1
            ELSE 0
        END) AS grievance_redressed_count
   FROM grievance_master gm
   
   --=======================================================================
   
   	select count(1) as total_count
	from grievance_master gm 
--	where gm.created_on::date = '2025-10-17';
	where gm.grievance_generate_date::date between '2023-06-08' and '2025-11-05'
	and gm.grievance_source = 5;
   
   	
   	select 
   		grievance_no,
   		grievance_id,
   		grievance_generate_date,
   		created_on,
   		usb_unique_id
--	count(*) as ssm_data 
	from grievance_master gm 
--	where gm.grievance_generate_date::date = '2023-06-08'
	where gm.grievance_generate_date::date between '2023-06-08' and '2025-10-30'
	and gm.grievance_source = 5
	   order by grievance_generate_date asc
   
	  
--------- Updated Query For CMO Department SSM TEAM ----------
select 
	case 
		when grievance_no like 'SSM%' then grievance_no
		else usb_unique_id
	end as unique_grievance_no,
--  grievance_no,
	grievance_id,
	grievance_generate_date,
	created_on
--  usb_unique_id
--	count(*)
from grievance_master gm 
where gm.grievance_generate_date::date between '2023-06-08' and '2025-10-30'
	and gm.grievance_source = 5
order by grievance_generate_date asc
	   
	   
	   
   	select count(*) as total_number
	from grievance_master gm 
--	where gm.created_on::date = '2025-10-17';
	where gm.grievance_generate_date::date ='2023-06-08'
--	where gm.grievance_generate_date::date between '2023-06-08' and '2025-10-30'
	and gm.grievance_source = 5
--	   order by grievance_generate_date
   
   
   ------ SOHINI DI --
	select 
count(*) 
--		grievance_no,usb_unique_id,grievance_generate_date,direct_close 
	from grievance_master gm 
	where /*gm.usb_unique_id like '%SSM%' and */grievance_generate_date::date between '2023-06-08' and '2024-11-12 12:00:00' and grievance_source =5 
--	order by grievance_generate_date 
	
	
	select 
--		count(*) as previous_ssm_data
	grievance_no,
   		grievance_id,
   		grievance_generate_date,
   		created_on,
   		usb_unique_id 
	from grievance_master gm 
	where /*gm.usb_unique_id like '%SSM%' and*/ grievance_generate_date::date ='2023-06-08'and grievance_source =5 
	order by grievance_generate_date 
	
   union all
   select 
	count(*) as new_ssm_data 
--   	grievance_no,grievance_id,grievance_generate_date,usb_unique_id 
   		from grievance_master gm 
   	where gm.grievance_generate_date::date between '2024-11-12 12:00:01' and '2025-10-30' and grievance_no like '%SSM%' and grievance_source =5 
--   order by grievance_generate_date
	
	
	
	
	
	
	
	
	
	
	
   select 
   	grievance_no,
   	usb_unique_id,
   	grievance_generate_date,
   	direct_close 
   from grievance_master gm 
   where gm.usb_unique_id like '%SSM%' and grievance_generate_date::date between '2023-06-08' and '2024-11-12' and grievance_source =5 
   order by grievance_generate_date 
   
   select 
   	count(*)
   from grievance_master gm 
   where gm.usb_unique_id like '%SSM%' and grievance_generate_date::date between '2023-06-08' and '2024-11-12' and grievance_source =5 
--   order by grievance_generate_date 
   
   
   
   
   select 
   	grievance_no,grievance_id,grievance_generate_date,usb_unique_id 
   from grievance_master gm 
   where gm.grievance_generate_date::date between '2024-11-12' and '2025-10-30' and grievance_no like '%SSM%' and grievance_source =5 
   order by grievance_generate_date
   
   
   
  --======================================================================================================================
  --============================== SSM FEEDBACK API QUERY --- as on 04.11.2025 ====================================
  --======================================================================================================================

 ------ P U L L -----
   select
 	distinct cbgli.griev_id,
-- 	(CURRENT_DATE - INTERVAL '1 day')::date AS batch_pull_date,
 	'2025-11-01'::date AS batch_pull_date,
 	cbgli.griev_received_date as grievnace_lodge_date,
 	case 
 		when cbgli.status = 2 AND EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id) then true
 		else false
 	end as grievance_successed,
 	case 
 		when cbgli.status = 3 AND NOT EXISTS (SELECT 1 FROM grievance_master gm WHERE gm.grievance_no = cbgli.griev_id) then true
 		else false
 	end as grievance_falied,
	cbgli.error as error_status
FROM cmo_batch_run_details cbrd
INNER JOIN cmo_batch_grievance_line_item cbgli ON cbgli.cmo_batch_run_details_id = cbrd.cmo_batch_run_details_id
--WHERE batch_date::date = CURRENT_DATE - INTERVAL '1 day'
WHERE batch_date::date = '2025-11-01'
and cbrd.status = 'S'
    

----- P U S H -----
select 
	count(1) as ssm_push_count 
from grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
where gl.assigned_on::date = '2025-11-03'::DATE
and gl.grievance_status != 1
and (gm.grievance_source = 5 or gm.received_at = 6);


select 
	gl.lifecycle_id as transaction_id
--	gl.grievance_id as grievance_id,
--	gm.grievance_no as grievance_no,
--	cspd.response as ssm_response,
--	cspd.actual_push_date as actual_push_date,
--	cspd.status as push_data_status,
--	cspd.push_date as data_push_date
from grievance_lifecycle gl 
inner join grievance_master gm on gm.grievance_id = gl.grievance_id 
--inner join cmo_ssm_push_details cspd on cspd.actual_push_date::date = gl.assigned_on::date
where gl.assigned_on::date = '2025-11-03'::DATE
and gl.grievance_status != 1
and (gm.grievance_source = 5 or gm.received_at = 6);
   


select * from cmo_ssm_push_details cspd where cspd.actual_push_date::date = '2025-11-03' limit 1;

select sgddm.*, dm.* from ssm_grievance_data_document_mapping sgddm
inner join document_master dm on dm.doc_id = sgddm.doc_id
where batch_date::date = '2025-11-08'::date;





---Re-Process For SSM Failure Pull ----
with
    batch_line as (
        select 
            cbgli.cmo_batch_run_details_id
        from cmo_batch_grievance_line_item cbgli
        where cbgli.status = 3 
        group by cbgli.cmo_batch_run_details_id
    )
select
    bl.cmo_batch_run_details_id,
    cbrd.batch_id,
    cbrd.batch_date,
    cbrd.from_time,
    cbrd.to_time,
    cebrd.cmo_emp_batch_run_details_id,
    cbrd.data_count
from batch_line bl
inner join cmo_batch_run_details cbrd on cbrd.cmo_batch_run_details_id = bl.cmo_batch_run_details_id
    and cbrd.batch_date::date between '2025-03-25'::date and '2025-03-25'::date and cbrd.batch_id = 63 /*bl.cmo_batch_run_details_id = 15962*/
inner join cmo_emp_batch_run_details cebrd on cbrd.batch_date = cebrd.batch_date and cbrd.batch_id = cebrd.batch_id
order by cbrd.batch_date asc;




--
--UPDATE cmo_batch_grievance_line_item set
--education_qualification = 'Class 8',
--other_profession = 'NA',
--other_qualification = 'NA',
--em_employment_type_code = 'None',
--em_employment_status_code = '02',
--professional_qualification = '28',
--other_professional_qualification = 'NA',
--professional_qualification_name = 'Class 8',
--skills = '11', other_skills = 'NA',
--sub_category_code = '33', education_qualification_code = '18'
--where cmo_batch_run_details_id = 14975 and griev_id = 'SSM4292981' and status = 3;






select cbrd.cmo_batch_run_details_id , cbrd.batch_id, cbrd.processed  from cmo_batch_grievance_line_item cbgli 
inner join cmo_batch_run_details cbrd on cbrd.cmo_batch_run_details_id = cbgli.cmo_batch_run_details_id 
where cbgli.griev_id  in ('SSM5466330'
,'SSM5465774'
,'SSM5465203'
,'SSM5465598'
,'SSM5466194'
,'SSM5466631'
,'SSM5466696'
,'SSM5466804'
,'SSM5466873'
,'SSM5466851'
,'SSM5466842'
,'SSM5466829'
,'SSM5466757'
,'SSM5466980'
,'SSM5467627'
,'SSM5467243'
,'SSM5467227'
,'SSM5466718'
,'SSM5466888'
,'SSM5466900'
,'SSM5467070'
,'SSM5467139'
,'SSM5466768'
,'SSM5467054'
,'SSM5467215'
,'SSM5467233'
,'SSM5467431'
,'SSM5467468'
,'SSM5467501'
,'SSM5467641'
,'SSM5467709'
,'SSM5467757'
,'SSM5467853'
,'SSM5467862'
,'SSM5467111'
,'SSM5467664'
,'SSM5467791'
,'SSM5467816'
,'SSM5467850'
,'SSM5468032'
,'SSM5467916'
,'SSM5467355'
,'SSM5468206'
,'SSM5468342'
,'SSM5468476'
,'SSM5468534'
,'SSM5466692'
,'SSM5467424'
,'SSM5467666'
,'SSM5467730'
,'SSM5468244'
,'SSM5467704'
,'SSM5466954'
,'SSM5466940'
,'SSM5466876'
,'SSM5466785'
,'SSM5466762'
,'SSM5468078'
,'SSM5467519'
,'SSM5467303'
,'SSM5465398'
,'SSM5467843'
,'SSM5465458'
,'SSM5465464'
,'SSM5465540'
,'SSM5466761'
,'SSM5467011'
,'SSM5468217'
,'SSM5468536'
,'SSM5468555'
,'SSM5468632'
,'SSM5468614'
,'SSM5468482'
,'SSM5467505'
,'SSM5467734'
,'SSM5467832'
,'SSM5468402'
,'SSM5468379'
,'SSM5468359'
,'SSM5467970'
,'SSM5468752'
,'SSM5468187'
,'SSM5465941'
,'SSM5466351'
,'SSM5467244'
,'SSM5468623'
,'SSM5468994'
,'SSM5469018'
,'SSM5466874'
,'SSM5468928'
,'SSM5467268'
,'SSM5467985'
,'SSM5468508'
,'SSM5468732'
,'SSM5468577'
,'SSM5468609'
,'SSM5468708'
,'SSM5468756'
,'SSM5468776'
,'SSM5468886'
,'SSM5468952'
,'SSM5469011'
,'SSM5469132'
,'SSM5469185'
,'SSM5469201'
,'SSM5468340'
,'SSM5468509'
,'SSM5468692'
,'SSM5468765'
,'SSM5468889'
,'SSM5468919'
,'SSM5465512'
,'SSM5469019'
,'SSM5469159'
,'SSM5469357'
,'SSM5469391'
,'SSM5469520'
,'SSM5466979'
,'SSM5468151'
,'SSM5468175'
,'SSM5468829'
,'SSM5468839'
,'SSM5468887'
,'SSM5468942'
,'SSM5469576'
,'SSM5468899'
,'SSM5467356'
,'SSM5469608'
,'SSM5469662'
,'SSM5469679'
,'SSM5469860'
,'SSM5467131'
,'SSM5467415'
,'SSM5467463'
,'SSM5469675'
,'SSM5469819'
,'SSM5469824'
,'SSM5469868'
,'SSM5469884'
,'SSM5469984'
,'SSM5469994'
,'SSM5470015'
,'SSM5467983'
,'SSM5469292'
,'SSM5469312'
,'SSM5469507'
,'SSM5469600'
,'SSM5469818'
,'SSM5469912'
,'SSM5470106'
,'SSM5470212'
,'SSM5468514'
,'SSM5469423'
,'SSM5469905'
,'SSM5470227'
,'SSM5470237'
,'SSM5470281'
,'SSM5469255'
,'SSM5469455'
,'SSM5470132'
,'SSM5470236'
,'SSM5470304'
,'SSM5470465'
,'SSM5470326'
,'SSM5470612'
,'SSM5467306'
,'SSM5468545'
,'SSM5469232'
,'SSM5469240'
,'SSM5469344'
,'SSM5469552'
,'SSM5470052'
,'SSM5470190'
,'SSM5470327'
,'SSM5470494'
,'SSM5470498'
,'SSM5469220'
,'SSM5469850'
,'SSM5470619'
,'SSM5468425'
,'SSM5469082'
,'SSM5470691'
,'SSM5465518'
,'SSM5465520'
,'SSM5467073'
,'SSM5467170'
,'SSM5467230'
,'SSM5470173'
,'SSM5466778'
,'SSM5470495'
,'SSM5470550'
,'SSM5465496'
,'SSM5465562'
,'SSM5468355'
,'SSM5469916'
,'SSM5465354'
,'SSM5465418'
,'SSM5465516'
,'SSM5469055'
,'SSM5470261'
)
group by cbrd.cmo_batch_run_details_id, cbrd.batch_id, cbrd.processed

