select count(1) as griev_count ---------------->>> Nodal
        from grievance_master gm
        left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
        left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
        where gm.grievance_id > 0  and (gm.assigned_to_office_id = 58) and gm.status in (11,13,6);

select count(1) as griev_count
from grievance_master gm
left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (6);


select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (11);


select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_position = 12946) and gm.status in (13);



select count(1) as griev_count
    from grievance_master gm
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and gm.emergency_flag = 'N' and (gm.assigned_to_office_id = 58) and apm.role_master_id = 4 and gm.status in (6,11,13);   ----- ATR Submitted to HOD
-----------------------------------------------------------------------------------------------------------------------------------------------------------


select * from admin_user_role_master aurm;
select * from cmo_office_master com where com.office_id = 58;




--------------------------------------------

select count(1) as griev_count 
    from grievance_master gm 
    left join grievance_locking_history glh on glh.grievance_id = gm.grievance_id and glh.lock_status = 1
    left join admin_position_master apm on  gm.assigned_to_position = apm.position_id
    where gm.grievance_id > 0  and (gm.assigned_to_office_id = 58) and gm.status in (11,13,6) and ;




select  atr_type, atr_proposed_date, action_taken_note, gl.atn_id,
    catnm.atn_desc, gl.atn_reason_master_id, catnrm.atn_reason_master_desc,
    prev_atr_date, atr_submit_on, current_atr_date, gl.atr_doc_id,
    gl.assigned_on, gl.assigned_by_id, gl.assign_comment,
    gl.assigned_to_id, gl.assigned_by_position, gl.assigned_to_position,
    gl.action_taken_note, gl.action_proposed, gl.contact_date, gl.tentative_date
from grievance_lifecycle gl
left join cmo_action_taken_note_master catnm on gl.atn_id = catnm.atn_id
left join cmo_action_taken_note_reason_master catnrm on gl.atn_reason_master_id = catnrm.atn_reason_master_id
where gl.atn_id is not null and gl.lifecycle_id  = 64376032;




select
    apm.position_id,
    case
        when
            case
                when com.district_id = 999 then null
                when com.district_id = 99 then null
                else cdm2.district_name
            end is not null then concat(cdm.designation_name,' - ',
                case
                    when com.district_id = 999 then null
                    when com.district_id = 99 then null
                    else cdm2.district_name
                end,' - ',aurm.role_master_name)
        else concat(cdm.designation_name,' - ',aurm.role_master_name)
    end as position_name,
    apm.user_type,
    apm.role_master_id,
    apm.designation_id,
    apm.office_type,
    apm.office_category,
    apm.office_id,
    apm.sub_office_id,
    case
        when apm.sub_office_id is null then com.office_category
        else csom.office_category
    end as office_category_id,
    apm.record_status,
    cdlm3.domain_value as record_status_name,
    apm.phone_no,
    apm.created_by,
    apm.created_on + interval '5 hour 30 Minutes' as created_on,
    apm.updated_by,
    apm.updated_on + interval '5 hour 30 Minutes' as updated_on,
    aurm.role_master_name,
    aurm.role_code,
    com.office_name,
    cdlm.domain_value as office_category_name,
    cdlm2.domain_value as office_type_name,
    case
        when apm.sub_office_id is null then 'N/A'
        else csom.suboffice_name
    end as suboffice_name,
    aupm.admin_user_id,
    aud.official_name,
    cdm.designation_name
from admin_position_master apm
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
left join cmo_office_master com on com.office_id = apm.office_id
inner join cmo_domain_lookup_master cdlm on cdlm.domain_code = com.office_category and cdlm.domain_type = 'office_category'
inner join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = com.office_type and cdlm2.domain_type = 'office_type'
left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
inner join admin_user_position_mapping aupm on aupm.position_id = apm.position_id /*and aupm.status = 1*/
inner join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
inner join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
left join cmo_districts_master cdm2 on cdm2.district_id = com.district_id
inner join cmo_domain_lookup_master cdlm3 on apm.record_status = cdlm3.domain_code and cdlm3.domain_type = 'status'
where
    apm.position_id > 0 and
    case
        when ( select user_type  from admin_position_master where position_id = 10920 ) = 1 then apm.position_id::text like '%%'
            when ( select user_type  from admin_position_master where position_id = 10920 ) = 2 then apm.position_id in
            ( select position_id  from admin_position_master where office_id in
                ( select office_id from admin_position_master where position_id = 10920 ) )
            when ( select user_type  from admin_position_master where position_id = 10920) = 3 then apm.position_id in
                ( select position_id  from admin_position_master where sub_office_id in
                    ( select sub_office_id  from admin_position_master where position_id = 10920 ) )
        end
 order by com.office_name asc
 
 
 
select
apm.position_id,
case
    when
        case
            when com.district_id = 999 then null
            when com.district_id = 99 then null
            else cdm2.district_name
        end is not null then concat(cdm.designation_name,' - ',
            case
                when com.district_id = 999 then null
                when com.district_id = 99 then null
                else cdm2.district_name
            end,' - ',aurm.role_master_name)
    else concat(cdm.designation_name,' - ',aurm.role_master_name)
end as position_name,
apm.user_type,
apm.role_master_id,
apm.designation_id,
apm.office_type,
apm.office_category,
apm.office_id,
apm.sub_office_id,
case
    when apm.sub_office_id is null then com.office_category
    else csom.office_category
end as office_category_id,
apm.record_status,
cdlm3.domain_value as record_status_name,
apm.phone_no,
apm.created_by,
apm.created_on + interval '5 hour 30 Minutes' as created_on,
apm.updated_by,
apm.updated_on + interval '5 hour 30 Minutes' as updated_on,
aurm.role_master_name,
aurm.role_code,
com.office_name,
cdlm.domain_value as office_category_name,
cdlm2.domain_value as office_type_name,
case
    when apm.sub_office_id is null then 'N/A'
        else csom.suboffice_name
    end as suboffice_name,
    aupm.admin_user_id,
    aud.official_name,
    cdm.designation_name
from admin_position_master apm
inner join admin_user_role_master aurm on aurm.role_master_id = apm.role_master_id
left join cmo_office_master com on com.office_id = apm.office_id
inner join cmo_domain_lookup_master cdlm on cdlm.domain_code = com.office_category and cdlm.domain_type = 'office_category'
inner join cmo_domain_lookup_master cdlm2 on cdlm2.domain_code = com.office_type and cdlm2.domain_type = 'office_type'
left join cmo_sub_office_master csom on csom.suboffice_id = apm.sub_office_id
inner join admin_user_position_mapping aupm on aupm.position_id = apm.position_id /*and aupm.status = 1*/
inner join admin_user_details aud on aud.admin_user_id = aupm.admin_user_id
inner join cmo_designation_master cdm on cdm.designation_id = apm.designation_id
left join cmo_districts_master cdm2 on cdm2.district_id = com.district_id
inner join cmo_domain_lookup_master cdlm3 on apm.record_status = cdlm3.domain_code and cdlm3.domain_type = 'status'
where
    apm.position_id > 0 and
    case
        when ( select user_type  from admin_position_master where position_id = 10920 ) = 1 then apm.position_id::text like '%%'
            when ( select user_type  from admin_position_master where position_id = 10920 ) = 2 then apm.position_id in
            ( select position_id  from admin_position_master where office_id in
                ( select office_id from admin_position_master where position_id = 10920 ) )
            when ( select user_type  from admin_position_master where position_id = 10920) = 3 then apm.position_id in
                ( select position_id  from admin_position_master where sub_office_id in
                    ( select sub_office_id  from admin_position_master where position_id = 10920 ) )
        end
 and (replace(lower(aurm.role_master_name),' ','') like '%mufti%' 
 	or  replace(lower(com.office_name),' ','') like '%mufti%' 
 		or replace(lower(csom.suboffice_name),' ','') like '%mufti%' 
 			or replace(lower(aud.official_name),' ','') like '%mufti%' 
 				or replace(lower(aud.official_phone),' ','') like '%mufti%') 
 order by com.office_name asc

 
 
 
