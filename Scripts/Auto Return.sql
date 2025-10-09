
---- Retuen Eligible ------
with lastupdates as (
    select
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) as rn,
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_by_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_to_id,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.tentative_date,
        grievance_lifecycle.atn_id,
        grievance_lifecycle.closure_reason_id
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status = 14
        and grievance_lifecycle.atn_id in (9,12)
        and grievance_lifecycle.tentative_date is not null
        and grievance_lifecycle.tentative_date::date < current_timestamp::date
),
griev_data as (
    select distinct
        grievance_master.grievance_id,
        grievance_master.status as grievance_master_status,
        grievance_master.closure_reason_id,
        lastupdates.grievance_status,
        lastupdates.assigned_on,
        lastupdates.assigned_by_position,
        lastupdates.assigned_by_id,
        lastupdates.assigned_by_office_id,
        lastupdates.assigned_to_position,
        lastupdates.assigned_to_id,
        lastupdates.assigned_to_office_id,
        date(lastupdates.tentative_date) as tentative_date,
        lastupdates.closure_reason_id as griev_lc_closure_id,
        lastupdates.atn_id
    from grievance_master
    inner join lastupdates on lastupdates.rn = 1 and lastupdates.grievance_id = grievance_master.grievance_id
    where grievance_master.status = 15 
        and grievance_master.closure_reason_id in (5,9)
)
select
    griev_data.*
from griev_data
order by griev_data.tentative_date;



---- Office Wise Count For Auto Return -----
with lastupdates as (
    select
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) as rn,
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_by_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_to_id,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.tentative_date,
        grievance_lifecycle.atn_id,
        grievance_lifecycle.closure_reason_id
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status = 14
        and grievance_lifecycle.atn_id in (9,12)
        and grievance_lifecycle.tentative_date is not null
        and grievance_lifecycle.tentative_date::date < current_timestamp::date
),
griev_data as (
    select distinct
        grievance_master.grievance_id,
        grievance_master.status as grievance_master_status,
        grievance_master.closure_reason_id,
        lastupdates.grievance_status,
        lastupdates.assigned_on,
        lastupdates.assigned_by_position,
        lastupdates.assigned_by_id,
        lastupdates.assigned_by_office_id,
        lastupdates.assigned_to_position,
        lastupdates.assigned_to_id,
        lastupdates.assigned_to_office_id,
        date(lastupdates.tentative_date) as tentative_date,
        lastupdates.closure_reason_id as griev_lc_closure_id,
        lastupdates.atn_id
    from grievance_master
    inner join lastupdates on lastupdates.rn = 1 and lastupdates.grievance_id = grievance_master.grievance_id
    where grievance_master.status = 15 
        and grievance_master.closure_reason_id in (5,9)
)
select
	com.office_id as assigned_office,
	com.office_name as assigned_office_name,
    count(griev_data.*) as total_retunr_count
from griev_data
left join cmo_office_master com on com.office_id = griev_data.assigned_by_office_id
group by com.office_id, com.office_name
order by total_retunr_count desc
;



----- Indivitual Office Wise Count For Auto Return -----
with lastupdates as (
    select
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) as rn,
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_by_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_to_id,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.tentative_date,
        grievance_lifecycle.atn_id,
        grievance_lifecycle.closure_reason_id
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status = 14
        and grievance_lifecycle.atn_id in (9,12)
        and grievance_lifecycle.tentative_date is not null
        and grievance_lifecycle.tentative_date::date < current_timestamp::date
),
griev_data as (
    select distinct
        grievance_master.grievance_id,
        grievance_master.grievance_no,
        grievance_master.grievance_generate_date,
        grievance_master.grievence_close_date,
        grievance_master.status as grievance_master_status,
        grievance_master.closure_reason_id,
        grievance_master.grievance_source,
        grievance_master.grievance_category,
        grievance_master.grievance_description,
        grievance_master.applicant_name,        
        grievance_master.pri_cont_no,
        grievance_master.applicant_age,
        grievance_master.applicant_caste,
        grievance_master.applicant_reigion,
        grievance_master.applicant_gender,
        grievance_master.district_id,
        grievance_master.block_id,
        grievance_master.municipality_id,
        grievance_master.gp_id,
        grievance_master.ward_id,
        grievance_master.police_station_id,
        grievance_master.assembly_const_id,
        grievance_master.applicant_address,
        grievance_master.action_taken_note,
        grievance_master.atn_id as master_atn_id,
        grievance_master.status,
        grievance_master.closure_reason_id as master_closure_reason,
        lastupdates.grievance_status,
        lastupdates.assigned_on,
        lastupdates.assigned_by_position,
        lastupdates.assigned_by_id,
        lastupdates.assigned_by_office_id,
        lastupdates.assigned_to_position,
        lastupdates.assigned_to_id,
        lastupdates.assigned_to_office_id,
        date(lastupdates.tentative_date) as tentative_date,
        lastupdates.closure_reason_id as griev_lc_closure_id,
        lastupdates.atn_id
    from grievance_master
    inner join lastupdates on lastupdates.rn = 1 and lastupdates.grievance_id = grievance_master.grievance_id
    where grievance_master.status = 15 
        and grievance_master.closure_reason_id in (5,9)
)
select
    griev_data.grievance_id,
    griev_data.grievance_no,
    cdlm.domain_value as grievance_source,
    griev_data.grievance_generate_date as grievance_lodge_date,
    griev_data.grievence_close_date,
    cgcm.grievance_category_desc as grievance_category,
    griev_data.grievance_description,
    griev_data.applicant_name,
    griev_data.pri_cont_no as applicant_mobile,
    griev_data.applicant_age,
    ccm.caste_name as applicante_caste,
    crm.religion_name as applicante_religion,
    cdlm2.domain_value as applicant_gender,
    cdm.district_name as applicant_district,
    case 
    	when griev_data.block_id is not null then concat(cbm.block_name, ' - (Block) ') 
    	when griev_data.municipality_id is not null then concat(cmm.municipality_name, ' - (Municipality) ')
    	else 'N/A'
    end as applicant_block_municiple,
    case 
    	when griev_data.gp_id is not null then concat(cgpm.gp_name, ' - (GP) ') 
    	when griev_data.ward_id is not null then concat(cwm.ward_name, ' - (Ward) ')
    	else 'N/A'
    end as applicant_gp_ward,
    cpsm.ps_name as ps,
    cam.assembly_name as assembly,
    griev_data.applicant_address,
    griev_data.action_taken_note as HOD_remarks_last,
    catnm.atn_desc as action_taken_note,
    cdlm3.domain_value as current_status,
    ccrm.closure_reason_name as closure_reason_name
from griev_data
left join cmo_office_master com on com.office_id = griev_data.assigned_by_office_id
left join cmo_domain_lookup_master cdlm on cdlm.domain_type = 'grievance_source' and cdlm.domain_code = griev_data.grievance_source
left join cmo_domain_lookup_master cdlm2 on cdlm2.domain_type = 'gender' and cdlm2.domain_code = griev_data.applicant_gender
left join cmo_domain_lookup_master cdlm3 on cdlm3.domain_type = 'grievance_status' and cdlm3.domain_code = griev_data.status
left join cmo_grievance_category_master cgcm on cgcm.grievance_cat_id = griev_data.grievance_category
left join cmo_caste_master ccm on ccm.caste_id = griev_data.applicant_caste
left join cmo_religion_master crm  on crm.religion_id = griev_data.applicant_reigion 
left join cmo_districts_master cdm  on cdm.district_id = griev_data.district_id 
left join cmo_blocks_master cbm on cbm.block_id = griev_data.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = griev_data.municipality_id 
left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = griev_data.gp_id 
left join cmo_wards_master cwm on cwm.ward_id = griev_data.ward_id 
left join cmo_police_station_master cpsm on cpsm.ps_id = griev_data.police_station_id  
left join cmo_assembly_master cam on cam.assembly_id = griev_data.assembly_const_id  
left join cmo_action_taken_note_master catnm on catnm.atn_id = griev_data.master_atn_id   
left join cmo_closure_reason_master ccrm on ccrm.closure_reason_id = griev_data.master_closure_reason    
where com.office_id = 1
group by com.office_id, com.office_name, griev_data.grievance_id, griev_data.grievance_no, cdlm.domain_value, griev_data.grievance_generate_date, griev_data.grievence_close_date,
cgcm.grievance_category_desc, griev_data.grievance_description, griev_data.applicant_name, griev_data.pri_cont_no, griev_data.applicant_age, ccm.caste_name, crm.religion_name, 
cdlm2.domain_value, cdm.district_name, griev_data.block_id, griev_data.municipality_id, griev_data.gp_id, griev_data.ward_id, cpsm.ps_name, griev_data.applicant_address, 
griev_data.action_taken_note, catnm.atn_desc, griev_data.status, ccrm.closure_reason_name, cbm.block_name, cmm.municipality_name, cgpm.gp_name, cwm.ward_name, cdlm3.domain_value, cam.assembly_name
order by griev_data.grievance_id desc
;



select * from grievance_master where grievance_id = 3255576;
select * from grievance_lifecycle gl limit 1;

-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
with lastupdates as (
    select
        row_number() OVER (PARTITION BY grievance_lifecycle.grievance_id,grievance_lifecycle.assigned_to_office_id ORDER BY grievance_lifecycle.assigned_on DESC) as rn,
        grievance_lifecycle.grievance_id,
        grievance_lifecycle.grievance_status,
        grievance_lifecycle.assigned_on,
        grievance_lifecycle.assigned_by_position,
        grievance_lifecycle.assigned_by_id,
        grievance_lifecycle.assigned_by_office_id,
        grievance_lifecycle.assigned_to_position,
        grievance_lifecycle.assigned_to_id,
        grievance_lifecycle.assigned_to_office_id,
        grievance_lifecycle.tentative_date,
        grievance_lifecycle.atn_id,
        grievance_lifecycle.closure_reason_id
    from grievance_lifecycle
    where grievance_lifecycle.grievance_status = 14
        and grievance_lifecycle.atn_id in (9,12)
        and grievance_lifecycle.tentative_date is not null
        and grievance_lifecycle.tentative_date::date < current_timestamp::date
),
griev_data as (
    select distinct
        grievance_master.grievance_id,
        grievance_master.status as grievance_master_status,
        grievance_master.closure_reason_id,
        lastupdates.grievance_status,
        lastupdates.assigned_on,
        lastupdates.assigned_by_position,
        lastupdates.assigned_by_id,
        lastupdates.assigned_by_office_id,
        lastupdates.assigned_to_position,
        lastupdates.assigned_to_id,
        lastupdates.assigned_to_office_id,
        date(lastupdates.tentative_date) as tentative_date,
        lastupdates.closure_reason_id as griev_lc_closure_id,
        lastupdates.atn_id
    from grievance_master
    inner join lastupdates on lastupdates.rn = 1 and lastupdates.grievance_id = grievance_master.grievance_id
    where grievance_master.status = 15 
        and grievance_master.closure_reason_id in (5,9)
)
select
    griev_data.*
from griev_data
 order by tentative_date  desc limit 2 offset 0;



select gm.status from grievance_master gm where gm.grievance_id = 5212; --

select * from admin_position_master apm where apm.position_id = 1227;
select * from cmo_office_master com where com.office_id = 35;
select * from admin_user_position_mapping aupm where aupm.position_id = 1227;
select * from admin_user_details aud where aud.admin_user_id = 1227;





--CREATE TABLE public.grievance_retruned_data (
--	id int8 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
--	grievance_id bigint not NULL,
--	is_returned boolean NOT NULL DEFAULT false,
--	status int2 not null default 1,
--	CONSTRAINT grievance_retruned_data_pkey PRIMARY KEY (id)
--);



--ALTER TABLE public.grievance_retruned_data ADD created_on timestamptz DEFAULT current_timestamp NOT NULL;
--ALTER TABLE public.grievance_retruned_data ADD updated_on timestamptz NULL;










---- Auto Return Listing ----
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
        left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
        where md.grievance_id > 0 
            and md.status in (17) and md.assigned_to_office_id = 35 
            and replace(lower(md.emergency_flag),' ','') like '%n%'
    )
    select mdbgd.*
    from master_district_block_grv_data mdbgd;
    
   
   
   
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
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 35 then 0
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
    -- ----------------------- OT ---------------------------------
    -- coalesce(catnm.atn_desc,'N/A') as atn_desc,
    -- coalesce(md.action_taken_note,'N/A') as action_taken_note,
    -- case
        -- when md.status = 15 and md.atn_id is not null then (select gl.action_taken_note from grievance_lifecycle gl where gl.grievance_id = md.grievance_id and gl.grievance_status = 14 order by gl.assigned_on desc limit 1)
        -- when md.status = 15 and md.closure_reason_id is not null and md.atn_id is null then coalesce(md.action_taken_note,'N/A')
        -- else coalesce(md.action_taken_note,'N/A')
    -- end as action_taken_note,
    -- ----------------------- OT ---------------------------------
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
        when under_processing_ids.grievance_id is not null then 'Y' else 'N'
    end as is_bulk_processing,
    md.receipt_mode,
    md.received_at,
    COALESCE(grd.is_returned, false) AS is_returned
from master_district_block_grv md
left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 35
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
left join grievance_retruned_data grd on grd.grievance_id = md.grievance_id and grd.status = 1
where md.grievance_id > 0 
    and md.status in (17) and md.assigned_to_office_id = 35 
    and replace(lower(md.emergency_flag),' ','') like '%n%'
    order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc limit 30 offset 0
)
select mdbgd.*
from master_district_block_grv_data mdbgd;



------------------------------------------------------------------------------------------------------------------------------

        
 with lastupdates_17 AS (
    select
        grd.is_returned,
        gl.grievance_id,
        gl.grievance_status,
        gl.assigned_on,
        gl.assigned_to_office_id,
        gl.assigned_by_position,
        gl.assigned_to_position,
        gl.assigned_by_office_id,
        row_number() OVER (PARTITION BY gl.grievance_id,gl.assigned_to_office_id ORDER BY gl.assigned_on DESC) AS rn
    from grievance_retruned_data grd 
    inner join grievance_lifecycle gl on gl.grievance_id = grd.grievance_id
    where grd.status = 1 and grd.is_returned = true
        and gl.grievance_status in (17)   
), lastupdates_14 AS (
    select
    	*
		from lastupdates_17 
),
master_district_block_grv_data AS (
    select
        md.grievance_id,
        md.status as griev_current_status,
        lu.grievance_status as last_grievance_status,
        lu.assigned_on as last_assigned_on,
        lu.assigned_to_office_id as last_assigned_to_office_id,
        lu.assigned_by_position as last_assigned_by_position,
        lu.assigned_to_position as last_assigned_to_position
    from master_district_block_grv md
    inner join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_by_office_id <> md.assigned_to_office_id
)
select mdbgd.*
from master_district_block_grv_data mdbgd;



     
     
WITH latest_17 AS (
     SELECT a.grievance_id,
        a.assigned_on,
        a.is_returned
     FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
            gl.grievance_id,
            gl.assigned_on,
            grd.is_returned 
           FROM grievance_retruned_data grd
           inner join grievance_lifecycle gl on gl.grievance_id = grd.grievance_id 
          WHERE grd.status = 1 and grd.is_returned = true and gl.grievance_status = 17) a
     WHERE a.rnn = 1
), latest_14 AS (
         SELECT 
			a.grievance_id,
         	a.assigned_on
          FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                gl.grievance_id,
                gl.assigned_on
                FROM grievance_lifecycle gl
              WHERE gl.grievance_status = 14) a
          JOIN latest_17 ON latest_17.grievance_id = a.grievance_id
          WHERE a.rnn = 1 AND latest_17.assigned_on < a.assigned_on
  ), latest_3 AS (
         SELECT 
         	a.grievance_id,
         	a.assigned_on
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                    gl.grievance_id,
                    gl.assigned_on
                    FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = 3) a
             JOIN latest_14 ON latest_14.grievance_id = a.grievance_id
          WHERE a.rnn = 1 AND latest_14.assigned_on < a.assigned_on
        )
 SELECT 
    grievance_master.status AS current_status,
    latest_3.grievance_id,
    latest_17.is_returned
   FROM latest_3
     JOIN grievance_master ON latest_3.grievance_id = grievance_master.grievance_id
     
     
     
---------------------------------------------------------------
     
WITH latest_14 AS (
     SELECT a.grievance_id,
        a.assigned_on,
        a.is_returned,
        a.assigned_by_office_id
     FROM ( select
        grd.is_returned,
        gl.grievance_id,
        gl.grievance_status,
        gl.assigned_on,
        gl.assigned_to_office_id,
        gl.assigned_by_position,
        gl.assigned_to_position,
        gl.assigned_by_office_id,
        row_number() OVER (PARTITION BY gl.grievance_id,gl.assigned_to_office_id ORDER BY gl.assigned_on DESC) AS rn
    from grievance_retruned_data grd 
    inner join grievance_lifecycle gl on gl.grievance_id = grd.grievance_id
    where grd.status = 1 and grd.is_returned = true
        and gl.grievance_status in (14)
        and gl.assigned_on > grd.created_on ) a
     WHERE a.rn = 1       
), latest_3 AS (
         SELECT 
         	a.grievance_id,
         	a.assigned_on,
         	a.assigned_to_office_id,
         	latest_14.is_returned
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                    gl.grievance_id,
                    gl.assigned_on,
                    gl.assigned_to_office_id
                    FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = 3) a
             JOIN latest_14 ON latest_14.grievance_id = a.grievance_id AND a.assigned_on > latest_14.assigned_on and a.assigned_to_office_id != latest_14.assigned_by_office_id 
          WHERE a.rnn = 1 
 )
 	select 
 		l3.grievance_id,
 		l3.is_returned,
 		l3.assigned_on
 	from latest_3 l3
 	inner join latest_14 l14 on l14.grievance_id = l3.grievance_id;



------ ==================== Perfect Query For Auto Return Update =========================== -------
with main as (
	select 
		gl.grievance_id , 
		gl.grievance_status as current_sts,
		LEAD(gl.grievance_status, 1) OVER(partition by gl.grievance_id order by gl.assigned_on asc) as second_sts,
		LEAD(gl.assigned_by_office_id, 1) OVER(partition by gl.grievance_id order by gl.assigned_on asc) as second_ofc_id,
		LEAD(gl.grievance_status, 2) OVER(partition by gl.grievance_id order by gl.assigned_on asc ) as third_sts,
		LEAD(gl.assigned_to_office_id, 2) OVER(partition by gl.grievance_id order by gl.assigned_on asc) as thir_ofc_to
	from grievance_lifecycle gl 
	inner join grievance_retruned_data grd on grd.grievance_id = gl.grievance_id 
	where gl.grievance_status in (17, 14, 3)
	order by assigned_on asc
) 
select * from main where current_sts = 17 and second_sts = 14 and third_sts = 3 and second_ofc_id  != thir_ofc_to;




select * from grievance_lifecycle where grievance_id = 115180 order by assigned_on ;
 	
 ------------ Auto Return Listing ---------------
/* TAB_ID: 2A7 | TBL: Return due to time line expiry >> Role: 4 Ofc: 75 | G_Codes: ('GM017') */  
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
            when (select grievance_lifecycle.assigned_to_office_id from grievance_lifecycle where grievance_lifecycle.grievance_id = md.grievance_id and grievance_lifecycle.grievance_status = 3 order by grievance_lifecycle.assigned_on desc limit 1) = 75 then 0
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
        -- ----------------------- OT ---------------------------------
        -- coalesce(catnm.atn_desc,'N/A') as atn_desc,
        -- coalesce(md.action_taken_note,'N/A') as action_taken_note,
        -- case
            -- when md.status = 15 and md.atn_id is not null then (select gl.action_taken_note from grievance_lifecycle gl where gl.grievance_id = md.grievance_id and gl.grievance_status = 14 order by gl.assigned_on desc limit 1)
            -- when md.status = 15 and md.closure_reason_id is not null and md.atn_id is null then coalesce(md.action_taken_note,'N/A')
            -- else coalesce(md.action_taken_note,'N/A')
        -- end as action_taken_note,
        -- ----------------------- OT ---------------------------------
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
            when under_processing_ids.grievance_id is not null then 'Y' else 'N'
        end as is_bulk_processing,
        md.receipt_mode,
        md.received_at,
        coalesce(grd.is_returned, false) as is_returned
    from master_district_block_grv md
    left join lastupdates lu on lu.rn = 1 and lu.grievance_id = md.grievance_id and lu.assigned_to_office_id = 75
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
    left join grievance_retruned_data grd on grd.grievance_id = md.grievance_id and grd.status = 1
    where md.grievance_id > 0 
        and md.status in (17) and md.assigned_to_office_id = 75 
        and replace(lower(md.emergency_flag),' ','') like '%n%'
    order by (case when md.status = 1 then md.grievance_generate_date else md.updated_on end) asc limit 30 offset 0
)
select mdbgd.*
from master_district_block_grv_data mdbgd;


select gm.status, gm.assigned_to_office_id  from grievance_master gm where gm.grievance_id in (12139,62621) ;
select * from grievance_retruned_data;
select * from cmo_office_master com where com.office_id = 35;
select * from cmo_parameter_master cpm;