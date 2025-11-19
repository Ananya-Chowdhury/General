select * from grievance_master gm where gm.grievance_id in (22885,22886,22887,22888,22889);
select * from grievance_master gm where gm.grievance_no in ('SSM5341070','SSM5341071');
select * from grievance_lifecycle gl where gl.grievance_id in (22917,22918)




select * from cmo_parameter_master cpm;
select * from cmo_domain_lookup_master cdlm ;

select * from cmo_batch_grievance_line_item cbgli where cbgli.cmo_batch_run_details_id = 8;
select * from cmo_batch_run_details cbrd where cbrd.data_count > 1;

select * from document_master dm ;

--SSM5331204,c1   SSM5331727,c9