select
	count(1) as atr_recieved
	from atr_latest_14_bh_mat bh;
	
EXPLAIN SELECT count(1) as atr_recieved FROM atr_latest_14_bh_mat bh;

SELECT pg_is_in_recovery();

ANALYZE atr_latest_14_bh_mat;
--EXPLAIN SELECT count(1) as atr_recieved FROM atr_latest_14_bh_mat bh;