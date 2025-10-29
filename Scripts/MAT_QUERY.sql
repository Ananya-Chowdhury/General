-- public.atr_latest_4_11_bh_mat_2 source
--DROP MATERIALIZED VIEW IF EXISTS atr_latest_4_11_bh_mat_2; 

CREATE MATERIALIZED VIEW public.atr_latest_4_11_bh_mat_2
AS WITH latest_4 AS (
         SELECT a.grievance_id,
            a.assigned_on
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                    gl.grievance_id,
                    gl.assigned_on
                   FROM grievance_lifecycle gl
          		   JOIN admin_position_master apm ON apm.position_id = gl.assigned_by_position
                   JOIN admin_position_master apm2 ON apm2.position_id = gl.assigned_to_position
                  WHERE gl.grievance_status = 4 AND (apm.role_master_id = ANY (ARRAY[4::bigint, 5::bigint])) AND apm2.role_master_id = 6) a
               WHERE a.rnn = 1
        ), latest_11 AS (
         SELECT a.rnn,
            a.lifecycle_id,
            a.comment,
            a.grievance_status,
            a.assigned_on,
            a.assigned_by_id,
            a.assign_comment,
            a.assigned_to_id,
            a.assign_reply,
            a.accepted_on,
            a.atr_type,
            a.atr_proposed_date,
            a.official_code,
            a.action_taken_note,
            a.atn_id,
            a.atn_reason_master_id,
            a.action_proposed,
            a.contact_date,
            a.tentative_date,
            a.prev_recv_date,
            a.prev_atr_date,
            a.closure_reason_id,
            a.atr_submit_on,
            a.created_by,
            a.created_on,
            a.grievance_id,
            a.assigned_by_position,
            a.assigned_to_position,
            a.urgency_type,
            a.addl_doc_id,
            a.current_atr_date,
            a.atr_doc_id,
            a.assigned_by_office_id,
            a.assigned_to_office_id,
            a.assigned_by_office_cat,
            a.assigned_to_office_cat,
            a.migration_id,
            a.migration_id_ac_tkn,
            a.role_master_id
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                    gl.lifecycle_id,
                    gl.comment,
                    gl.grievance_status,
                    gl.assigned_on,
                    gl.assigned_by_id,
                    gl.assign_comment,
                    gl.assigned_to_id,
                    gl.assign_reply,
                    gl.accepted_on,
                    gl.atr_type,
                    gl.atr_proposed_date,
                    gl.official_code,
                    gl.action_taken_note,
                    gl.atn_id,
                    gl.atn_reason_master_id,
                    gl.action_proposed,
                    gl.contact_date,
                    gl.tentative_date,
                    gl.prev_recv_date,
                    gl.prev_atr_date,
                    gl.closure_reason_id,
                    gl.atr_submit_on,
                    gl.created_by,
                    gl.created_on,
                    gl.grievance_id,
                    gl.assigned_by_position,
                    gl.assigned_to_position,
                    gl.urgency_type,
                    gl.addl_doc_id,
                    gl.current_atr_date,
                    gl.atr_doc_id,
                    gl.assigned_by_office_id,
                    gl.assigned_to_office_id,
                    gl.assigned_by_office_cat,
                    gl.assigned_to_office_cat,
                    gl.migration_id,
                    gl.migration_id_ac_tkn,
                    apm.role_master_id
                   FROM grievance_lifecycle gl
                     JOIN admin_position_master apm ON apm.position_id = gl.assigned_by_position
                     JOIN admin_position_master apm2 ON apm2.position_id = gl.assigned_to_position
                  WHERE gl.grievance_status = 11 AND apm.role_master_id = 6 AND (apm2.role_master_id = ANY (ARRAY[4::bigint, 5::bigint]))) a
          WHERE a.rnn = 1 AND latest_4.assigned_on < a.assigned_on
        )
 SELECT cmo_police_station_master.sub_district_id,
    grievance_master.district_id,
    grievance_master.block_id,
    grievance_master.municipality_id,
    grievance_master.gp_id,
    grievance_master.ward_id,
    grievance_master.police_station_id,
    grievance_master.assembly_const_id,
    grievance_master.postoffice_id,
    grievance_master.grievance_category,
    grievance_master.sub_division_id,
    grievance_master.status AS current_status,
    grievance_master.grievance_source,
    grievance_master.closure_reason_id AS grievance_master_closure_reason_id,
    grievance_master.grievance_generate_date,
    grievance_master.applicant_gender,
    grievance_master.applicant_caste,
    grievance_master.applicant_reigion,
    grievance_master.applicant_age,
    grievance_master.atr_submit_by_lastest_office_id,
    grievance_master.receipt_mode,
    grievance_master.received_at,
    latest_11.rnn,
    latest_11.lifecycle_id,
    latest_11.comment,
    latest_11.grievance_status,
    latest_11.assigned_on,
    latest_11.assigned_by_id,
    latest_11.assign_comment,
    latest_11.assigned_to_id,
    latest_11.assign_reply,
    latest_11.accepted_on,
    latest_11.atr_type,
    latest_11.atr_proposed_date,
    latest_11.official_code,
    latest_11.action_taken_note,
    latest_11.atn_id,
    latest_11.atn_reason_master_id,
    latest_11.action_proposed,
    latest_11.contact_date,
    latest_11.tentative_date,
    latest_11.prev_recv_date,
    latest_11.prev_atr_date,
    latest_11.closure_reason_id,
    latest_11.atr_submit_on,
    latest_11.created_by,
    latest_11.created_on,
    latest_11.grievance_id,
    latest_11.assigned_by_position,
    latest_11.assigned_to_position,
    latest_11.urgency_type,
    latest_11.addl_doc_id,
    latest_11.current_atr_date,
    latest_11.atr_doc_id,
    latest_11.assigned_by_office_id,
    latest_11.assigned_to_office_id,
    latest_11.assigned_by_office_cat,
    latest_11.assigned_to_office_cat,
    latest_11.migration_id,
    latest_11.migration_id_ac_tkn,
    latest_11.role_master_id
   FROM latest_11
     JOIN grievance_master ON latest_11.grievance_id = grievance_master.grievance_id
     LEFT JOIN cmo_police_station_master ON cmo_police_station_master.ps_id = grievance_master.police_station_id
     inner join latest_4 on latest_4.grievance_id = latest_11.grievance_id /*and latest_11.assigned_on > latest_4.assigned_on*/
WITH DATA;
------------------------------------------------------------------------------------------------------------------------------------

-- public.forwarded_latest_3_4_bh_mat_2 source

CREATE MATERIALIZED VIEW public.forwarded_latest_3_4_bh_mat
TABLESPACE pg_default
AS SELECT t.grievance_id,
    t.previous_status,
    t.assigned_to_office_id,
    t.assigned_to_position,
    t.assigned_to_id,
    t.grievance_source,
    t.current_status,
    t.next_status,
    t.next_status_assigned_to_office,
    t.next_status_assigned_to_position,
    t.next_status_assigned_to_id
   FROM ( SELECT gl.grievance_id,
            gl.grievance_status AS previous_status,
            gl.assigned_to_office_id,
            gl.assigned_to_position,
            gl.assigned_to_id,
            gm.grievance_source,
            gm.status AS current_status,
            lead(gl.grievance_status) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status,
            lead(gl.assigned_to_office_id) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status_assigned_to_office,
            lead(gl.assigned_to_position) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status_assigned_to_position,
            lead(gl.assigned_to_id) OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on) AS next_status_assigned_to_id
           FROM grievance_lifecycle gl
             JOIN grievance_master gm ON gm.grievance_id = gl.grievance_id) t




-----------------------------------------------------------------------------------------------------
WITH latest_4 AS (
         SELECT 
         	a.rnn,
            a.lifecycle_id,
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                    gl.lifecycle_id,
                   FROM grievance_lifecycle gl
                     JOIN admin_position_master apm ON apm.position_id = gl.assigned_by_position
                     JOIN admin_position_master apm2 ON apm2.position_id = gl.assigned_to_position
                  WHERE gl.grievance_status = 4 AND (apm.role_master_id = ANY (ARRAY[4::bigint, 5::bigint])) AND apm2.role_master_id = 6) a
          WHERE a.rnn = 1
        )
 SELECT 
 	count(*)
   FROM latest_4
   
   
   
   WITH latest_4 AS (
         SELECT a.grievance_id,
            a.assigned_on
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                    gl.grievance_id,
                    gl.assigned_on
                   FROM grievance_lifecycle gl
                  WHERE gl.grievance_status = 4) a
          WHERE a.rnn = 1
        ), latest_11 AS (
         SELECT a.rnn,
            a.lifecycle_id
           FROM ( SELECT row_number() OVER (PARTITION BY gl.grievance_id ORDER BY gl.assigned_on DESC) AS rnn,
                    gl.lifecycle_id
                   FROM grievance_lifecycle gl
                     JOIN admin_position_master apm ON apm.position_id = gl.assigned_by_position
                     JOIN admin_position_master apm2 ON apm2.position_id = gl.assigned_to_position
                  WHERE gl.grievance_status = 11 AND apm.role_master_id = 6 AND (apm2.role_master_id = ANY (ARRAY[4::bigint, 5::bigint]))) a
             JOIN latest_4 ON latest_4.grievance_id = a.grievance_id
          WHERE a.rnn = 1 AND latest_4.assigned_on < a.assigned_on
        )
 SELECT 
 	count(*)
   FROM latest_11