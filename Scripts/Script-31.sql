SELECT * 
FROM cmo_batch_run_details cbrd
WHERE batch_date::date = '2026-02-23'  -- 02.06 in process
and status = 'S'
ORDER by batch_id desc;