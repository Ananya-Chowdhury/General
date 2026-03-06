select gm.grievance_id from grievance_master gm 
 where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10
order by gm.grievance_id limit 1000; 

select gm.grievance_id from grievance_master gm 
 where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10
order by gm.grievance_id;

select count(1) from grievance_master gm 
 where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10; --93916

select * from grievance_master gm where gm.status = 14 and gm.grievance_category = 133 and gm.atn_id = 10 and gm.grievance_id in (3793950)
order by gm.grievance_id limit 10;

select * from cmo_grievance_category_master cgcm  ;
select * from cmo_action_taken_note_master catnm ;


select * from grievance_master gm where gm.grievance_id in (438532);


select count(1) over() as total_length 
from grievance_master gm 
inner join admin_position_master apm on gm.assigned_to_position = apm.position_id 
where gm.status = 3 
      and apm.office_id = 53 and apm.sub_office_id is null
      and gm.grievance_generate_date::date between '{from_date_time}' and '{to_date_time}';
      
     
 -----------------------------------------------------------------------------------------------------------------------
----------------------------------------- Non-forwarded griveances ------------------------------------------------------
-------------------- previous code --------------------
     select count(1) 
        from master_district_block_grv md
        left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.grievance_id > 0 
                and md.status in (1) and md.assigned_to_office_id = 5 
                and replace(lower(md.emergency_flag),' ','') like '%n%'
                
 select count(1) 
        from master_district_block_grv md
        left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status in (1))
        and md.grievance_id > 0 
                and md.status in (1) and md.assigned_to_office_id = 5 
                and replace(lower(md.emergency_flag),' ','') like '%n%'

    ------------------------------------            
                
                
 select *
        from master_district_block_grv md
        left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where md.grievance_id > 0 
                and md.status in (1) and md.assigned_to_office_id = 5 
                and replace(lower(md.emergency_flag),' ','') like '%n%'
         
                
 select *
        from master_district_block_grv md
        left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status in (1))
        and md.grievance_id > 0 
                and md.status in (1) and md.assigned_to_office_id = 5 
                and replace(lower(md.emergency_flag),' ','') like '%n%'
                
                
select *
        from master_district_block_grv md
        left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status in (1))
        and md.grievance_id > 0 
                and md.status in (1) and md.assigned_to_office_id = 5 
                and replace(lower(md.emergency_flag),' ','') like '%n%'
                
                
   select count(1) 
        from master_district_block_grv md
        left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        where exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status = 1)
        and md.grievance_id > 0 
                and md.status in (1) and md.assigned_to_office_id = 5 
                and replace(lower(md.emergency_flag),' ','') like '%n%'
                

  


                
                  
                
                
    select distinct
        md.grievance_id,
        0 as received_from_other_hod_flag,
        0 as received_from_restricted_flag,
        null as last_grievance_status,
        null as last_assigned_on,
        null as last_assigned_to_office_id,
        null as last_assigned_by_position,
        null as last_assigned_to_position,
        md.grievance_no,
        md.grievance_description,
        md.grievance_source,
        null as grievance_source_name,
        md.applicant_name,
        md.pri_cont_no,
        md.grievance_generate_date,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        md.district_name,
        md.block_id,
        md.block_name,
        md.municipality_id,
        md.municipality_name,
        case 
            when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
            when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
            else null
        end as block_or_municipalty_name,
        md.gp_id,
        md.gp_name,
        md.ward_id,
        md.ward_name,
        case 
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
            ELSE NULL
        end as gp_or_ward_name,
        md.atn_id,
        case 
            when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
            when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
            ELSE 'N/A'
        end as atn_desc,
        md.action_taken_note,
        coalesce(md.current_atr_date,null) as current_atr_date,
        md.assigned_to_position,
        md.assigned_to_id,
        case 
            when md.assigned_to_position  is null then 'N/A'
            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ']' )
        end as assigned_to_name,
        md.grievance_generate_date,
        md.grievance_generate_date as updated_on,
        md.status,
        cdlm.domain_value as status_name,
        cdlm.domain_abbr as grievance_status_code,
        md.emergency_flag,
        md.police_station_id,
        cpsm.ps_name,
        case 
            when under_processing_ids.grievance_id is not null then 'Y' 
            else 'N'
        end as is_bulk_processing      
    from master_district_block_grv md
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
    where not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status in (1))
        and md.status in (1) and md.assigned_to_office_id = 5 
                and replace(lower(md.emergency_flag),' ','') like '%n%' 
--	                    order by grievance_generate_date asc limit 30 offset 0
                    

  ----------------------------------------------------------------------------------------------------------------------------------------------------------              
                
                ---- FOR ALL ----
                
/* TAB_ID: 1A4 | TBL: All >> Role: 1 Ofc: 5 | G_Codes: ('GM001', 'GM002', 'GM016') */  
with lastupdates AS (
    select 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select count(1) 
    from master_district_block_grv md
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    -- where exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status = 1)
    where md.status in (1,2,16)
)
select mdbgd.*
from master_district_block_grv_data mdbgd;
                

WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id 
            ORDER BY grievance_lifecycle.assigned_on DESC
        ) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status IN (3,5)
),
master_district_block_grv_data AS (
    SELECT md.*
    FROM master_district_block_grv md
    LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position
    LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
    LEFT JOIN lastupdates lu ON lu.rn = 1 AND lu.grievance_id = md.grievance_id AND lu.assigned_to_office_id = 5
    WHERE EXISTS ( SELECT 1 FROM grievance_auto_assign_map gam WHERE md.grievance_category = gam.grievance_cat_id AND gam.status = 1)
    AND md.status IN (1,2,16)
)
SELECT COUNT(*) 
FROM master_district_block_grv_data;

-------------------------------------------
        
WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id 
            ORDER BY grievance_lifecycle.assigned_on DESC
        ) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status IN (3,5)
),
master_district_block_grv_data AS (
    SELECT md.*
    FROM master_district_block_grv md
    LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position
    LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
    LEFT JOIN lastupdates lu ON lu.rn = 1 AND lu.grievance_id = md.grievance_id AND lu.assigned_to_office_id = 5
    WHERE EXISTS ( SELECT 1 FROM grievance_auto_assign_map gam WHERE md.grievance_category = gam.grievance_cat_id AND gam.status = 1)
    AND md.status IN (1,2,16)
)
SELECT *
FROM master_district_block_grv_data;        
    

-------- old count query for all -----
with lastupdates AS (
    select 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select *
    from master_district_block_grv md
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    where md.status in (1,2,16)
)
select mdbgd.*
from master_district_block_grv_data mdbgd;


--- all count query ---
with lastupdates as (
    select 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() over (
            PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id 
            order by grievance_lifecycle.assigned_on desc
        ) as rn
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select md.*
    from master_district_block_grv md
    left join admin_position_master apm on apm.position_id = md.updated_by_position
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    where (md.status = 1 and exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status = 1 ))
        or md.status in (2,16)
  )
select COUNT(*) 
from master_district_block_grv_data;

-----------------------------------------------


-- for all listing query update --
WITH lastupdates AS (
    select grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status in (3,5)
),
master_district_block_grv_data AS (
    select distinct
        md.grievance_id,
        case
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 5 then 0
            else 1
        end as received_from_other_hod_flag,
        case
            when apm.role_master_id = 6 and apm2.role_master_id in (4,5) and md.status = 11 and (md.current_atr_date is not null or md.action_taken_note is not null or md.atn_id is not null) then 1
            else 0
        end as received_from_restricted_flag,
        lu.grievance_status as last_grievance_status,
        lu.assigned_on as last_assigned_on,
        lu.assigned_to_office_id as last_assigned_to_office_id,
        lu.assigned_by_position as last_assigned_by_position,
        lu.assigned_to_position as last_assigned_to_position,
        md.grievance_no,
        md.grievance_description,
        md.grievance_source,
        null as grievance_source_name,
        md.applicant_name ,
        md.pri_cont_no,
        md.grievance_generate_date,
        md.grievance_category,
        cgcm.grievance_category_desc,
        md.assigned_to_office_id,
        com.office_name,
        md.district_id,
        md.district_name ,
        md.block_id ,
        md.block_name ,
        md.municipality_id ,
        md.municipality_name,
        case 
            when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
            when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
            else null
        end as block_or_municipalty_name,
        md.gp_id,
        md.gp_name,
        md.ward_id,
        md.ward_name,
        case 
            WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
            WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
            ELSE NULL
        end as gp_or_ward_name,
        md.atn_id,
        case 
            when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
            when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
            ELSE 'N/A'
        end as atn_desc,
        md.action_taken_note,
        coalesce(md.current_atr_date,null) as current_atr_date,
        md.assigned_to_position,
        md.assigned_to_id,
        case 
            when md.assigned_to_position  is null then 'N/A'
            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
        end as assigned_to_name,
        case
            when md.status = 1 then md.grievance_generate_date
            else md.updated_on -- + interval '5 hour 30 Minutes' 
        end as updated_on,
        md.status,
        cdlm.domain_value as status_name,
        cdlm.domain_abbr as grievance_status_code,
        md.emergency_flag,
        md.police_station_id,
        cpsm.ps_name,
        case 
            when under_processing_ids.grievance_id is not null then 'Y' 
            else 'N'
        end as is_bulk_processing
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
    left join admin_position_master apm on apm.position_id = md.updated_by_position 
    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
    where (md.status = 1 and exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status = 1 ))
        or md.status in (2,16)
--    order by updated_on asc limit 30 offset 0
)
select mdbgd.*
from master_district_block_grv_data mdbgd;



-- for all listing query old  --
WITH lastupdates AS (
                    select grievance_lifecycle.grievance_id,
                        grievance_lifecycle.grievance_status,
                        grievance_lifecycle.assigned_on,
                        grievance_lifecycle.assigned_to_office_id,
                        grievance_lifecycle.assigned_by_position,
                        grievance_lifecycle.assigned_to_position,
                        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
                    FROM grievance_lifecycle
                    WHERE grievance_lifecycle.grievance_status in (3,5)
                ),
     
                master_district_block_grv_data AS (
                    select distinct
                        md.grievance_id,
                        case
                            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 5 then 0
                            else 1
                        end as received_from_other_hod_flag,
                        case
                            when apm.role_master_id = 6 and apm2.role_master_id in (4,5) and md.status = 11 and (md.current_atr_date is not null or md.action_taken_note is not null or md.atn_id is not null) then 1
                            else 0
                        end as received_from_restricted_flag,
                        lu.grievance_status as last_grievance_status,
                        lu.assigned_on as last_assigned_on,
                        lu.assigned_to_office_id as last_assigned_to_office_id,
                        lu.assigned_by_position as last_assigned_by_position,
                        lu.assigned_to_position as last_assigned_to_position,
                        md.grievance_no,
                        md.grievance_description,
                        md.grievance_source,
                        null as grievance_source_name,
                        md.applicant_name ,
                        md.pri_cont_no,
                        md.grievance_generate_date,
                        md.grievance_category,
                        cgcm.grievance_category_desc,
                        md.assigned_to_office_id,
                        com.office_name,
                        md.district_id,
                        md.district_name ,
                        md.block_id ,
                        md.block_name ,
                        md.municipality_id ,
                        md.municipality_name,
                        case 
                            when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
                            when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
                            else null
                        end as block_or_municipalty_name,
                        md.gp_id,
                        md.gp_name,
                        md.ward_id,
                        md.ward_name,
                        case 
                            WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
                            WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
                            ELSE NULL
                        end as gp_or_ward_name,
                        md.atn_id,
                        case 
                            when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
                            when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
                            ELSE 'N/A'
                        end as atn_desc,
                        md.action_taken_note,
                        coalesce(md.current_atr_date,null) as current_atr_date,
                        md.assigned_to_position,
                        md.assigned_to_id,
                        case 
                            when md.assigned_to_position  is null then 'N/A'
                            else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
                        end as assigned_to_name,
                        case
                            when md.status = 1 then md.grievance_generate_date
                            else md.updated_on -- + interval '5 hour 30 Minutes' 
                        end as updated_on,
                        md.status,
                        cdlm.domain_value as status_name,
                        cdlm.domain_abbr as grievance_status_code,
                        md.emergency_flag,
                        md.police_station_id,
                        cpsm.ps_name,
                        case 
                            when under_processing_ids.grievance_id is not null then 'Y' 
                            else 'N'
                        end as is_bulk_processing
                    from master_district_block_grv md
                    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
                    left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                    left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                    left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                    left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                    left join admin_position_master apm on apm.position_id = md.updated_by_position 
                    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                    left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                    left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
                    left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
                    where md.status in (1,2,16) 
                )
                select mdbgd.*
                from master_district_block_grv_data mdbgd
               	where not exists (mdbgd.grievance_category in 
               		(select 1 from grievance_auto_assign_map gam 
               		 where md.grievance_category = gam.grievance_cat_id
               			and gam.status = 1 and md.status = 1));
               	-- order by updated_on asc limit 30 offset 0;



















----------------------------------------------------
WITH lastupdates AS (
    SELECT 
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_to_position,
        ROW_NUMBER() OVER (
            PARTITION BY grievance_lifecycle.grievance_id, grievance_lifecycle.assigned_to_office_id 
            ORDER BY grievance_lifecycle.assigned_on DESC
        ) AS rn
    FROM grievance_lifecycle
    WHERE grievance_lifecycle.grievance_status IN (3,5)
),
master_district_block_grv_data AS (
    SELECT md.*
    FROM master_district_block_grv md
    LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position
    LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
    LEFT JOIN lastupdates lu ON lu.rn = 1 AND lu.grievance_id = md.grievance_id AND lu.assigned_to_office_id = 5
    WHERE (md.status = 1 AND EXISTS ( SELECT 1 FROM grievance_auto_assign_map gam WHERE md.grievance_category = gam.grievance_cat_id AND gam.status = 1 ))
        OR md.status IN (2,16)
  )
SELECT *
FROM master_district_block_grv_data;





























--------------------------------------------------------------------------------------------------------------------------------------------        
/* TAB_ID: 1A1 | TBL: New (Unassigned) >> Role: 1 Ofc: 5 | G_Codes: ('GM001') */  
select distinct
    md.grievance_id,
    0 as received_from_other_hod_flag,
    0 as received_from_restricted_flag,
    null as last_grievance_status,
    null as last_assigned_on,
    null as last_assigned_to_office_id,
    null as last_assigned_by_position,
    null as last_assigned_to_position,
    md.grievance_no,
    md.grievance_description,
    md.grievance_source,
    null as grievance_source_name,
    md.applicant_name,
    md.pri_cont_no,
    md.grievance_generate_date,
    md.grievance_category,
    cgcm.grievance_category_desc,
    md.assigned_to_office_id,
    com.office_name,
    md.district_id,
    md.district_name,
    md.block_id,
    md.block_name,
    md.municipality_id,
    md.municipality_name,
    case 
        when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
        when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
        else null
    end as block_or_municipalty_name,
    md.gp_id,
    md.gp_name,
    md.ward_id,
    md.ward_name,
    case 
        WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
        WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
        ELSE NULL
    end as gp_or_ward_name,
    md.atn_id,
    case 
        when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
        when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
        ELSE 'N/A'
    end as atn_desc,
    md.action_taken_note,
    coalesce(md.current_atr_date,null) as current_atr_date,
    md.assigned_to_position,
    md.assigned_to_id,
    case 
        when md.assigned_to_position  is null then 'N/A'
        else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, ']' )
    end as assigned_to_name,
    md.grievance_generate_date,
    md.grievance_generate_date as updated_on,
    md.status,
    cdlm.domain_value as status_name,
    cdlm.domain_abbr as grievance_status_code,
    md.emergency_flag,
    md.police_station_id,
    cpsm.ps_name,
    case 
        when under_processing_ids.grievance_id is not null then 'Y' 
        else 'N'
    end as is_bulk_processing      
from master_district_block_grv md
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
left join cmo_office_master com on com.office_id = md.assigned_to_office_id
left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
left join admin_position_master apm on apm.position_id = md.updated_by_position 
left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
left join cmo_office_master com2 on com2.office_id = apm2.office_id 
left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
where md.status in (1) and md.assigned_to_office_id = 5 
        and replace(lower(md.emergency_flag),' ','') like '%n%' 
order by grievance_generate_date asc limit 50 offset 0


------------------------------- testing -----
with lastupdates AS (
        select 
            grievance_lifecycle.grievance_id,
            grievance_lifecycle.grievance_status,
            grievance_lifecycle.assigned_on,
            grievance_lifecycle.assigned_to_office_id,
            grievance_lifecycle.assigned_by_position,
            grievance_lifecycle.assigned_to_position,
            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        from grievance_lifecycle
        where grievance_lifecycle.grievance_status in (3,5)
    ),
    master_district_block_grv_data AS (
        select md.* 
        from master_district_block_grv md
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
        where (md.status = 1 and not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status = 1 )) or md.status in (2,16) 
    )
    select count(*) 
    from master_district_block_grv_data;
                
               
               
 WITH lastupdates AS (
        select grievance_lifecycle.grievance_id,
            grievance_lifecycle.grievance_status,
            grievance_lifecycle.assigned_on,
            grievance_lifecycle.assigned_to_office_id,
            grievance_lifecycle.assigned_by_position,
            grievance_lifecycle.assigned_to_position,
            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        FROM grievance_lifecycle
        WHERE grievance_lifecycle.grievance_status in (3,5)
    ),
    master_district_block_grv_data AS (
        select distinct
            md.grievance_id,
            case
                when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 5 then 0
                else 1
            end as received_from_other_hod_flag,
            case
                when apm.role_master_id = 6 and apm2.role_master_id in (4,5) and md.status = 11 and (md.current_atr_date is not null or md.action_taken_note is not null or md.atn_id is not null) then 1
                else 0
            end as received_from_restricted_flag,
            lu.grievance_status as last_grievance_status,
            lu.assigned_on as last_assigned_on,
            lu.assigned_to_office_id as last_assigned_to_office_id,
            lu.assigned_by_position as last_assigned_by_position,
            lu.assigned_to_position as last_assigned_to_position,
            md.grievance_no,
            md.grievance_description,
            md.grievance_source,
            null as grievance_source_name,
            md.applicant_name ,
            md.pri_cont_no,
            md.grievance_generate_date,
            md.grievance_category,
            cgcm.grievance_category_desc,
            md.assigned_to_office_id,
            com.office_name,
            md.district_id,
            md.district_name ,
            md.block_id ,
            md.block_name ,
            md.municipality_id ,
            md.municipality_name,
            case 
                when md.address_type = 2 then CONCAT(md.municipality_name, ' ', '(M)')
                when md.address_type = 1 then CONCAT(md.block_name, ' ', '(B)')
                else null
            end as block_or_municipalty_name,
            md.gp_id,
            md.gp_name,
            md.ward_id,
            md.ward_name,
            case 
                WHEN md.municipality_id IS NOT NULL THEN CONCAT(md.ward_name, ' ', '(W)')
                WHEN md.block_id IS NOT NULL THEN CONCAT(md.gp_name,' ', '(GP)')
                ELSE NULL
            end as gp_or_ward_name,
            md.atn_id,
            case 
                when md.atn_id is not null then coalesce(catnm.atn_desc,'N/A')
                when md.closure_reason_id is not null and md.atn_id is null then coalesce(ccrm.closure_reason_name,'N/A')
                ELSE 'N/A'
            end as atn_desc,
            md.action_taken_note,
            coalesce(md.current_atr_date,null) as current_atr_date,
            md.assigned_to_position,
            md.assigned_to_id,
            case 
                when md.assigned_to_position  is null then 'N/A'
                else concat(ad.official_name, ' [', cdm.designation_name, ' (', com2.office_name, ') - ', aurm.role_master_name, '] '  )  
            end as assigned_to_name,
            case
                when md.status = 1 then md.grievance_generate_date
                else md.updated_on -- + interval '5 hour 30 Minutes' 
            end as updated_on,
            md.status,
            cdlm.domain_value as status_name,
            cdlm.domain_abbr as grievance_status_code,
            md.emergency_flag,
            md.police_station_id,
            cpsm.ps_name,
            case 
                when under_processing_ids.grievance_id is not null then 'Y' 
                else 'N'
            end as is_bulk_processing
        from master_district_block_grv md
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
        left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
        left join cmo_office_master com on com.office_id = md.assigned_to_office_id
        left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
        left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
        left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
        left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
        left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
        left join admin_position_master apm on apm.position_id = md.updated_by_position 
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
        left join cmo_office_master com2 on com2.office_id = apm2.office_id 
        left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
        left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = md.closure_reason_id
        left join under_processing_ids on under_processing_ids.grievance_id = md.grievance_id
        where (md.status = 1 and not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status = 1 )) or md.status in (2,16) 
--                    order by updated_on asc limit 30 offset 0
    )
    select mdbgd.*
    from master_district_block_grv_data mdbgd;
    
   
   ------------------------------------------------------
   
 with lastupdates AS (
        select 
            grievance_lifecycle.grievance_id,
            grievance_lifecycle.grievance_status,
            grievance_lifecycle.assigned_on,
            grievance_lifecycle.assigned_to_office_id,
            grievance_lifecycle.assigned_by_position,
            grievance_lifecycle.assigned_to_position,
            row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) AS rn
        from grievance_lifecycle
        where grievance_lifecycle.grievance_status in (3,5)
    ),
    master_district_block_grv_data AS (
        select md.*
        from master_district_block_grv md
        left join admin_position_master apm on apm.position_id = md.updated_by_position
        left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 5
        where (md.status = 1 and not exists ( select 1 from grievance_auto_assign_map gam where md.grievance_category = gam.grievance_cat_id and gam.status = 1 )) or md.status in (2,16) and md.grievance_id > 0  
            and replace(lower(md.emergency_flag),' ','') like '%y%'
    )
    select * 
    from master_district_block_grv_data mdbgd;
    
   
   
   ---------------------------------------------------------   Excel update for pending case   --------------------------------------------------------------
   
   select * from cmo_office_master com where com.office_id = 25;
   select * from cmo_office_master com;
  ;
   
   --------- grievancer register --------
   WITH lastupdates AS (
                SELECT gl.grievance_id,
                    gl.grievance_status,
                    gl.assigned_on,
                    gl.assigned_to_office_id,
                    gl.assigned_by_position,
                    gl.assigned_to_position,
                    row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
                FROM grievance_lifecycle gl
                WHERE gl.grievance_status in (3)
                 and gl.assigned_to_office_id = 16    
            )
                Select Count(1)  
                from grievance_master md
                inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id 
                left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
                left join cmo_office_master com on com.office_id = md.assigned_to_office_id
                left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
                left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
                left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
                left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
                left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
                left join admin_position_master apm on apm.position_id = md.updated_by_position 
                left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
                left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
                left join cmo_office_master com2 on com2.office_id = apm2.office_id 
                left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
                left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
                left join cmo_blocks_master cbm on cbm.block_id = md.block_id 
                left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
                left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
                left join cmo_wards_master cwm on cwm.ward_id = md.ward_id;
               
  -------------------------- updated version ------------------------------ 
WITH lastupdates AS (
    SELECT gl.grievance_id,
           gl.grievance_status,
           gl.assigned_on,
           gl.assigned_to_office_id,
           gl.assigned_by_position,
           gl.assigned_to_position,
           row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rn
    FROM grievance_lifecycle gl
    WHERE gl.grievance_status IN (3) 
          AND gl.assigned_to_office_id = 35  /*variable*/ 
)
SELECT COUNT(1)  
FROM grievance_master md
INNER JOIN lastupdates lu ON lu.rn = 1 AND lu.grievance_id = md.grievance_id 
LEFT JOIN cmo_grievance_category_master cgcm ON cgcm.grievance_cat_id = md.grievance_category
LEFT JOIN cmo_office_master com ON com.office_id = md.assigned_to_office_id
LEFT JOIN cmo_action_taken_note_master catnm ON catnm.atn_id = md.atn_id
LEFT JOIN cmo_domain_lookup_master cdlm ON cdlm.domain_type = 'grievance_status' AND cdlm.domain_code = md.status
LEFT JOIN admin_user_position_mapping aupm ON aupm.position_id = md.assigned_to_position AND aupm.status = 1
LEFT JOIN admin_user_details ad ON ad.admin_user_id = aupm.admin_user_id
LEFT JOIN cmo_police_station_master cpsm ON cpsm.ps_id = md.police_station_id
LEFT JOIN admin_position_master apm ON apm.position_id = md.updated_by_position 
LEFT JOIN admin_position_master apm2 ON apm2.position_id = md.assigned_to_position
LEFT JOIN cmo_designation_master cdm ON cdm.designation_id = apm2.designation_id
LEFT JOIN cmo_office_master com2 ON com2.office_id = apm2.office_id 
LEFT JOIN admin_user_role_master aurm ON aurm.role_master_id = apm2.role_master_id
LEFT JOIN cmo_districts_master cdm2 ON cdm2.district_id = md.district_id
LEFT JOIN cmo_blocks_master cbm ON cbm.block_id = md.block_id 
LEFT JOIN cmo_municipality_master cmm ON cmm.municipality_id = md.municipality_id
LEFT JOIN cmo_gram_panchayat_master cgpm ON cgpm.gp_id = md.gp_id
LEFT JOIN cmo_wards_master cwm ON cwm.ward_id = md.ward_id
WHERE md.status NOT IN (14, 15);
----------------------------------------------- Update by Bhandari da -------------------------------------------------

Select Count(1), com3.office_name, 
	from grievance_master_bh_mat md
	inner join forwarded_latest_3_bh_mat as lu on lu.grievance_id = md.grievance_id
	left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = md.grievance_category
	left join cmo_office_master com on com.office_id = md.assigned_to_office_id
	left join cmo_office_master com3 on com3.office_id = lu.assigned_to_office_id
	left join cmo_action_taken_note_master catnm on catnm.atn_id = md.atn_id
	left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_status' and cdlm.domain_code = md.status
	    left join admin_user_position_mapping aupm on aupm.position_id = md.assigned_to_position and aupm.status = 1
	    left join admin_user_details ad on ad.admin_user_id = aupm.admin_user_id
	    left join cmo_police_station_master cpsm on cpsm.ps_id = md.police_station_id
	    left join admin_position_master apm on apm.position_id = md.updated_by_position
	    left join admin_position_master apm2 on apm2.position_id = md.assigned_to_position
	    left join cmo_designation_master cdm on cdm.designation_id = apm2.designation_id
	    left join cmo_office_master com2 on com2.office_id = apm2.office_id
	    left join admin_user_role_master aurm on aurm.role_master_id = apm2.role_master_id
	    left join cmo_districts_master cdm2 on cdm2.district_id = md.district_id
	    left join cmo_blocks_master cbm on cbm.block_id = md.block_id
	    left join cmo_municipality_master cmm on cmm.municipality_id = md.municipality_id
	    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = md.gp_id
	    left join cmo_wards_master cwm on cwm.ward_id = md.ward_id
	  where md.status not in (14,15)
	 group by com3.office_name;

--------------------- Pending Grievance at hod ----------------------
with unassigned_cmo as (
        select 
            grievance_master_bh_mat.assigned_to_office_id,  
            'Unassigned (CMO)' as status,
            'N/A' as office,
            null as name_and_esignation_of_the_user,
            null as user_status,
            count(1) as pending_grievances,
            null::int as pending_atrs,
            null::int as atr_returned_for_review,
            null::int as atr_auto_returned_from_cmo,
            count(1) as total_count
        from grievance_master_bh_mat_2 as grievance_master_bh_mat 
        where grievance_master_bh_mat.status = 3 
                and grievance_master_bh_mat.assigned_to_office_id in (133) /*Variable*/
        group by grievance_master_bh_mat.assigned_to_office_id
    ), unassigned_other_hod as (
        select 
            grievance_master_bh_mat.assigned_to_office_id,  
            'Unassigned (Other HoD)' as status,
            'N/A' as office,
            null as name_and_esignation_of_the_user,
            null as user_status,
            0 as pending_grievances,
            null::int as pending_atrs,
            null::int as atr_returned_for_review,
            null::int as atr_auto_returned_from_cmo,
            0 as total_count
        from grievance_master_bh_mat_2 as grievance_master_bh_mat 
        where grievance_master_bh_mat.status = 5 
                and grievance_master_bh_mat.assigned_to_office_id in (133) /*Variable*/
        group by grievance_master_bh_mat.assigned_to_office_id
    ), recalled as (
        select 
            grievance_master_bh_mat.assigned_by_office_id,  
            'Recalled' as status,
            'N/A' as office,
            null as name_and_esignation_of_the_user,
            null as user_status,
            count(1) as pending_grievances,
            null::int as pending_atrs,
            null::int as atr_returned_for_review,
            null::int as atr_auto_returned_from_cmo,
            count(1) as total_count
        from grievance_master_bh_mat_2 as grievance_master_bh_mat 
        where grievance_master_bh_mat.status = 16
                and grievance_master_bh_mat.assigned_by_office_id in (133) /*Variable*/
        group by grievance_master_bh_mat.assigned_by_office_id
    ), user_wise_atr_pendancy as (
        select               
            grievance_master_bh_mat.assigned_to_office_id,  
            'User wise ATR Pendency' as status,
            case 
                when csom.suboffice_id is not null then csom.suboffice_name
                when com.office_id is not null then com.office_name
                else 'N/A'
            end as office_or_suboffice_name,
            concat(admin_user_details.official_name,' (', cmo_designation_master.designation_name, ') ')as name_and_esignation_of_the_user,
            admin_user_role_master.role_master_name as user_status,
            sum(case when grievance_master_bh_mat.status in (4,7,8) then 1 else 0 end) as pending_grievances,
            sum(case when grievance_master_bh_mat.status in (9,11) then 1 else 0 end) as pending_atrs,
            sum(case when grievance_master_bh_mat.status in (6,10,12) then 1 else 0 end) as atr_returned_for_review,
            case
                when admin_user_role_master.role_master_id in (4,5) then sum(case when grievance_master_bh_mat.status in (16,17) then 1 else 0 end)
                else null
            end::int as atr_auto_returned_from_cmo,
            sum(case when grievance_master_bh_mat.status in (4,7,8,9,11,6,10,12) then 1 else 0 end) as total_count
        from grievance_master_bh_mat_2 as grievance_master_bh_mat 
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_master_bh_mat.grievance_id
        left join admin_position_master on grievance_master_bh_mat.assigned_to_position = admin_position_master.position_id
        left join cmo_designation_master on admin_position_master.designation_id = cmo_designation_master.designation_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        left join admin_user_details on grievance_master_bh_mat.assigned_to_id = admin_user_details.admin_user_id
        left join cmo_office_master com on com.office_id = admin_position_master.office_id
        left join cmo_sub_office_master csom on csom.suboffice_id = admin_position_master.sub_office_id and  csom.office_id = admin_position_master.office_id
        where grievance_master_bh_mat.assigned_to_office_id in (133) /*Variable*/
        group by grievance_master_bh_mat.assigned_to_office_id, csom.suboffice_id, com.office_id, admin_user_details.official_name, cmo_designation_master.designation_name,
                admin_user_role_master.role_master_name, admin_user_role_master.role_master_id
        order by admin_user_role_master.role_master_id
    ), user_wise_atr_pendancy_otr_hod as (
        select               
            grievance_master_bh_mat.assigned_by_office_id,  
            'User wise ATR Pendency' as status7,
            case 
                when csom.suboffice_id is not null then csom.suboffice_name
                when com.office_id is not null then com.office_name
                else 'N/A'
            end as office_or_suboffice_name,
            concat(admin_user_details.official_name,' (', cmo_designation_master.designation_name, ') ')as name_and_esignation_of_the_user,
            concat(admin_user_role_master.role_master_name, ' (Other HOD)') as user_status,
            count(1) as pending_grievances,
            null::int as pending_atrs,
            sum(case when grievance_master_bh_mat.status in (6) then 1 else 0 end) as atr_returned_for_review,
            null::int as atr_auto_returned_from_cmo,
            count(1) as total_count
        from grievance_master_bh_mat_2 as grievance_master_bh_mat 
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = grievance_master_bh_mat.grievance_id
        left join admin_position_master on grievance_master_bh_mat.assigned_to_position = admin_position_master.position_id
        left join cmo_designation_master on admin_position_master.designation_id = cmo_designation_master.designation_id
        left join admin_user_role_master on admin_position_master.role_master_id = admin_user_role_master.role_master_id
        left join admin_user_details on grievance_master_bh_mat.assigned_to_id = admin_user_details.admin_user_id
        left join cmo_office_master com on com.office_id = admin_position_master.office_id
        left join cmo_sub_office_master csom on csom.suboffice_id = admin_position_master.sub_office_id and  csom.office_id = admin_position_master.office_id
        where grievance_master_bh_mat.assigned_by_office_id in (133) /*Variable*/
            and grievance_master_bh_mat.assigned_to_office_id not in (133) /*Variable*/
            and grievance_master_bh_mat.assigned_to_office_cat != 1
        group by grievance_master_bh_mat.assigned_by_office_id, csom.suboffice_id, com.office_id, admin_user_details.official_name, cmo_designation_master.designation_name, admin_user_role_master.role_master_name, admin_user_role_master.role_master_id
        order by admin_user_role_master.role_master_id
    ), union_part as (
        select * from unassigned_cmo
            union all 
        select * from unassigned_other_hod
            union all
        select * from recalled
            union all
        select * from user_wise_atr_pendancy
            union all
        select * from user_wise_atr_pendancy_otr_hod
    )
    select
        row_number() over() as sl_no,
        '2025-03-22 02:30:01.891687+00:00'::timestamp as refresh_time_utc,
        '2025-03-22 02:30:01.891687+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        * 
    from union_part
    
    
    ------------------------------------------------ category wise pending -----------=================================
with uploaded_count as (
    select grievance_master.grievance_category, count(1) as _uploaded_ 	from grievance_master_bh_mat_2 as grievance_master 
        where grievance_master.grievance_category > 0
   group by grievance_master.grievance_category
), fwd_count as (
    select forwarded_latest_3_bh_mat.grievance_category, cmo_office_master.office_name, count(1) as _fwd_ 
            from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
            left join cmo_office_master on cmo_office_master.office_id = forwarded_latest_3_bh_mat.assigned_by_office_id 
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (29) /*variable*/
  		group by forwarded_latest_3_bh_mat.grievance_category , cmo_office_master.office_name
), atr_count as (
    select atr_latest_14_bh_mat.grievance_category, count(1) as _atr_
        /*, -- COMMENT OUT --
        sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        */
    from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat 
    inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat  on forwarded_latest_3_bh_mat.grievance_id = atr_latest_14_bh_mat.grievance_id
        where atr_latest_14_bh_mat.assigned_by_office_id in (29)/*variable*/  and atr_latest_14_bh_mat.current_status in (14,15)
  		group by atr_latest_14_bh_mat.grievance_category
), close_count as (
    select  gm.grievance_category, count(1) as _clse_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from  grievance_master_bh_mat_2 as gm
        inner join  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
            where gm.status = 15  and gm.atr_submit_by_lastest_office_id in (29) /*variable*/
		group by gm.grievance_category
), pending_count as ( /*NEED*/
    select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (133) /*variable*/
            and not exists (select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id 
                                                                        and atr_latest_14_bh_mat.current_status in (14,15)
                                                                        /*and atr_latest_14_bh_mat.assigned_by_office_id in (16)*/ )
       group by forwarded_latest_3_bh_mat.grievance_category
)
select  
        row_number() over() as sl_no, '2025-03-22 02:30:01.891687+00:00'::timestamp as refresh_time_utc, '2025-03-22 02:30:01.891687+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        cmo_grievance_category_master.grievance_cat_id, 
        cmo_grievance_category_master.grievance_category_desc, 
        fwd_count.office_name,
        coalesce(uploaded_count._uploaded_, 0) as griev_upload, 
        coalesce(fwd_count._fwd_, 0) as grv_fwd, 
        coalesce(atr_count._atr_, 0) as atr_rcvd, 
        coalesce(close_count._clse_, 0) as totl_dspsd,  
        coalesce(close_count.bnft_prvd, 0) as srv_prvd, 
        coalesce(close_count._mt_t_up_win_90_, 0) as mt_t_up_win_90,
        coalesce(close_count._mt_t_up_bey_90_, 0) as mt_t_up_bey_90, 
        coalesce(close_count._pnd_policy_dec_, 0) as pnd_policy_dec,
        coalesce(close_count.not_elgbl, 0) as not_elgbl, 
        coalesce(pending_count._pndddd_, 0) as atr_pndg,
        COALESCE(ROUND(CASE WHEN (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_) = 0 THEN 0 
                            ELSE (close_count.bnft_prvd::numeric / (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_)) * 100 
                    END,2),0) AS bnft_prcnt
from fwd_count 
left join cmo_grievance_category_master on fwd_count.grievance_category = cmo_grievance_category_master.grievance_cat_id 
left join uploaded_count on fwd_count.grievance_category = uploaded_count.grievance_category 
left join atr_count on fwd_count.grievance_category = atr_count.grievance_category
left join pending_count on fwd_count.grievance_category = pending_count.grievance_category
left join close_count on fwd_count.grievance_category = close_count.grievance_category;
/***** FILTER *****/

-------------
select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat 
        where forwarded_latest_3_bh_mat.assigned_to_office_id in (42) /*variable*/
            and not exists (select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id 
                                                                        and atr_latest_14_bh_mat.current_status in (14,15) group by forwarded_latest_3_bh_mat.grievance_category;