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
    left join lastupdates on lastupdates.rn = 1 and lastupdates.grievance_id = grievance_master.grievance_id
    where grievance_master.status = 15 
        and grievance_master.closure_reason_id in (5,9)
)
select
    griev_data.*
from griev_data
order by griev_data.grievance_id asc;