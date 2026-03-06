----- New District Wise MIS at CMO END -------
    
    select count(1) from grievance_master gm where gm.district_id = 1;
    select count(1) from grievance_master_bh_mat_2 gm where gm.district_id = 1;
   select * from grievance_master gm where gm.grievance_id = 5558560
   

   select 
--    	count(1) as grievance_lodged_cnt, 
   		bh.grievance_id,
    	bh.sub_division_id
    	from grievance_master_bh_mat_2 as bh
    where bh.sub_division_id is not null
    and bh.district_id in (22)
--    and bh.assigned_to_office_id in (35)
    order by bh.sub_division_id ;
   
---- DIstrict ---->>> Sub-Division Mismatch Query ================
   
   select count(1) as grievance_lodged_cnt 
   from grievance_master_bh_mat_2 as bh
   where bh.sub_division_id is not null
    and bh.district_id in (88)
    and bh.sub_division_id not in (95);
--    order by bh.sub_division_id;
   
   
   select  
   		bh.grievance_id,
    	bh.sub_division_id
    	from grievance_master_bh_mat_2 as bh
    where bh.sub_division_id is not null
    and bh.district_id in (16)
    and bh.sub_division_id not in (46,47,48,49,50,51)
--    and bh.assigned_to_office_id in (35)
    order by bh.sub_division_id ;

   
      select *
    	from grievance_master as bh
    where bh.sub_division_id is not null
    and bh.district_id in (23)
    and bh.sub_division_id not in (17,18,19);
   
   
   select * from grievance_master gm where gm.grievance_id in (241656);
 -----------------------------------------------------------------
  
  ---- DIstrict ---->>> Municipality Mismatch Query ================
   
   select count(1) as grievance_lodged_cnt 
   from grievance_master_bh_mat_2 as bh
   where bh.municipality_id is not null and bh.district_id is not null
    and bh.district_id in (9)
--    and bh.sub_division_id not in (67,67,66)
    and bh.municipality_id not in (5,6,7,8,133);
   
   
   select 
--    	count(1) as grievance_lodged_cnt, 
   		bh.grievance_id,
    	bh.sub_division_id
    	from grievance_master_bh_mat_2 as bh
    where bh.sub_division_id is not null
    and bh.district_id in (16)
    and bh.sub_division_id not in (46,47,48,49,50,51)
--    and bh.assigned_to_office_id in (35)
    order by bh.sub_division_id ;

   
      select *
    	from grievance_master as bh
    where bh.sub_division_id is not null
    and bh.district_id in (23)
    and bh.sub_division_id not in (17,18,19);
   
   
   select * from grievance_master gm where gm.grievance_id in (241656);
 -----------------------------------------------------------------
  
    select 
    	/*count(1) as grievance_lodged_cnt,*/ bh.gp_id, bh.grievance_id
    from grievance_master_bh_mat_2 as bh
    where bh.gp_id is not null
    and bh.block_id in (264)
--    and bh.assigned_to_office_id in (35)
    group by bh.gp_id, bh.grievance_id
    
    
    SELECT 
	    bh.gp_id, 
	    bh.grievance_id
	FROM grievance_master_bh_mat_2 AS bh
	WHERE bh.gp_id IS NOT NULL
	  AND bh.block_id IN (254)
--	  AND bh.gp_id NOT IN (2482, 2483, 2484, 2485, 2486, 2487, 2488, 2489, 2490, 2491, 2492, 3626)
	  AND bh.gp_id IN (2484)
	GROUP BY bh.gp_id, bh.grievance_id;

    SELECT 
	    bh.ward_id, 
	    bh.grievance_id
	FROM grievance_master_bh_mat_2 AS bh
	WHERE bh.ward_id IS NOT NULL
	  AND bh.municipality_id IN (104)
	  AND bh.ward_id NOT IN (
	    2288, 2289 ,2290 ,2291 ,2292 ,2293 ,2294 ,2295 ,2296 ,2297 ,2298 ,2299 ,2300 ,2301 ,2302 ,2303 ,2874
	  )
	GROUP BY bh.ward_id, bh.grievance_id;

    
select 
	bh.gp_id, bh.ward_id, bh.grievance_id
from grievance_master_bh_mat_2 as bh
where (bh.gp_id is not null or bh.ward_id is not null)
and (bh.block_id in (254) or bh.municipality_id in (104))
--    and bh.gp_id not in (2482, 2483, 2484, 2485, 2486, 2487, 2488, 2489, 2490, 2491, 2492, 3626)
and bh.ward_id not in (2288, 2289 ,2290 ,2291 ,2292 ,2293 ,2294 ,2295 ,2296 ,2297 ,2298 ,2299 ,2300 ,2301 ,2302 ,2303 ,2874)
--    and bh.assigned_to_office_id in (35)
group by bh.gp_id, bh.ward_id, bh.grievance_id

    
    select 
    	count(1) as grievance_lodged_cnt, bh.sub_district_id
    from grievance_master_bh_mat_2 as bh
    where bh.sub_district_id is not null
    and bh.district_id in (22)
--    and bh.police_station_id in (2) 
--    and bh.sub_district_id in (14)
--    and bh.assigned_to_office_id in (35)
    group by bh.sub_district_id    

    
   SELECT 
	    bh.police_station_id, 
	    bh.grievance_id
	FROM grievance_master_bh_mat_2 AS bh
	WHERE bh.police_station_id IS not null
	  AND bh.district_id IN (22)
	  AND bh.police_station_id not IN (489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534)
	GROUP BY bh.police_station_id, bh.grievance_id;
    

SELECT 
	    bh.assembly_const_id, 
	    bh.grievance_id
	FROM grievance_master_bh_mat_2 AS bh
	WHERE bh.assembly_const_id IS not null
	  AND bh.district_id IN (22)
	  AND bh.assembly_const_id not IN (127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157)
	GROUP BY bh.assembly_const_id, bh.grievance_id;



SELECT 
	    bh.district_id, bh.sub_district_id, bh.police_station_id,
	    bh.grievance_id
	FROM grievance_master_bh_mat_2 AS bh
	WHERE bh.district_id IS not null and  bh.sub_district_id is not null and bh.police_station_id is not null
	  AND bh.district_id IN (1)
	  AND bh.sub_district_id not IN (2, 56)
	GROUP BY bh.district_id, bh.sub_district_id, bh.police_station_id, bh.grievance_id;


select count(1) 
from grievance_master_bh_mat_2 AS bh
left join cmo_police_station_master cpsm on cpsm.ps_id = bh.police_station_id 
where bh.district_id = 1
AND bh.sub_district_id not IN (2, 56)
--AND bh.sub_district_id IN (7)
and bh.police_station_id not in (604,605,606,607,608,609,610,611,612,613,675);
--and bh.police_station_id in (776);


select count(1) 
from grievance_master_bh_mat_2 AS bh
left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id
where bh.district_id = 22
AND bh.assembly_const_id not IN (127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157);

 -----------------------------------------------------------------
---- DIstrict ---->>> Police Stations Mismatch Query ================
   
   select count(1) as grievance_lodged_cnt 
   from grievance_master_bh_mat_2 as bh
   where bh.police_station_id is not null
    and bh.district_id in (24)
    and bh.police_station_id not in (1);
--    order by bh.sub_division_id;

   
     select bh.grievance_id , bh.grievance_no, bh.applicant_name, bh.pri_cont_no, 
      bh.applicant_address, bh.state_id, bh.district_id, cdm.district_name, bh.sub_division_id, 
      csdm.sub_division_name, bh.block_id, cbm.block_name, bh.municipality_id, cmm.municipality_name, 
      bh.gp_id, cgpm.gp_name, bh.ward_id, cwm.ward_name, bh.police_station_id, cpsm.ps_name, 
      bh.assembly_const_id , cam.assembly_name, bh.grievance_description, bh.status 
    	from grievance_master as bh
    	left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
    	left join cmo_sub_divisions_master csdm on csdm.sub_division_id = bh.sub_division_id 
    	left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
		left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id 
		left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
		left join cmo_gram_panchayat_master cgpm on bh.gp_id = cgpm.gp_id 
		left join cmo_wards_master cwm on bh.ward_id = cwm.ward_id 
		left join cmo_police_station_master cpsm on bh.police_station_id = cpsm.ps_id 
    where bh.police_station_id is not null
    and bh.district_id in (24)
    and bh.police_station_id not in (1);
--LIMIT 100000 OFFSET 100000;
   
   
   select * from grievance_master gm where gm.grievance_id in (241656);
  select count(1) from grievance_master gm ;
 -----------------------------------------------------------------

---- DIstrict ---->>> Sub-Division Mismatch Query ================
   
   select count(1) as grievance_lodged_cnt 
   from grievance_master_bh_mat_2 as bh
   where bh.sub_division_id is not null
    and bh.district_id in (88)
    and bh.sub_division_id not in (95);
--    order by bh.sub_division_id;
   
   
   select  
   		bh.grievance_id,
    	bh.sub_division_id
    	from grievance_master_bh_mat_2 as bh
    where bh.sub_division_id is not null
    and bh.district_id in (16)
    and bh.sub_division_id not in (46,47,48,49,50,51)
--    and bh.assigned_to_office_id in (35)
    order by bh.sub_division_id ;

   
      select *
    	from grievance_master as bh
    where bh.sub_division_id is not null
    and bh.district_id in (23)
    and bh.sub_division_id not in (17,18,19);
   
   
   select * from grievance_master gm where gm.grievance_id in (241656);
 -----------------------------------------------------------------
---- DIstrict ---->>> Assembly Constincy Mismatch Query ================
  
  select count(1) as grievance_lodged_cnt 
   from grievance_master_bh_mat_2 as bh
   where bh.assembly_const_id is not null
    and bh.district_id in (24)
    and bh.assembly_const_id not in (295);
--    order by bh.sub_division_id;
  
   select  
   		bh.grievance_id,
    	bh.assembly_const_id
    	from grievance_master_bh_mat_2 as bh
    where bh.assembly_const_id is not null
    and bh.district_id in (5)
    and bh.assembly_const_id not in (37,38,39,40,41,42)
--    and bh.assigned_to_office_id in (35)
    order by bh.assembly_const_id ;

   
      select bh.grievance_id , bh.grievance_no, bh.applicant_name, bh.pri_cont_no, 
      bh.applicant_address, bh.state_id, bh.district_id, cdm.district_name, bh.sub_division_id, 
      csdm.sub_division_name, bh.block_id, cbm.block_name, bh.municipality_id, cmm.municipality_name, 
      bh.gp_id, cgpm.gp_name, bh.ward_id, cwm.ward_name, bh.police_station_id, cpsm.ps_name, 
      bh.assembly_const_id , cam.assembly_name, bh.grievance_description, bh.status 
    	from grievance_master as bh
    	left join cmo_districts_master cdm on cdm.district_id = bh.district_id 
    	left join cmo_sub_divisions_master csdm on csdm.sub_division_id = bh.sub_division_id 
    	left join cmo_blocks_master cbm on cbm.block_id = bh.block_id 
		left join cmo_municipality_master cmm on cmm.municipality_id = bh.municipality_id 
		left join cmo_assembly_master cam on cam.assembly_id = bh.assembly_const_id 
		left join cmo_gram_panchayat_master cgpm on bh.gp_id = cgpm.gp_id 
		left join cmo_wards_master cwm on bh.ward_id = cwm.ward_id 
		left join cmo_police_station_master cpsm on bh.police_station_id = cpsm.ps_id 
    where bh.assembly_const_id is not null
    and bh.district_id in (24)
    and bh.assembly_const_id not in (295);
   
   
   select * from grievance_master gm where gm.grievance_id in (241656);

------------------------------------------------------------------------------------------------

--select  gm.block_id, cbm.block_name, gm.municipality_id, cmm.municipality_name, gm.assembly_const_id, cam.assembly_name, gm.gp_id, cgpm.gp_name, gm.ward_id, cwm.ward_name 
select  gm.grievance_id, gm.applicant_name, gm.district_id, gm.block_id, cbm.block_name, gm.municipality_id, cmm.municipality_name, gm.assembly_const_id, cam.assembly_name, gm.gp_id,  cgpm.gp_name, gm.ward_id, cwm.ward_name
--select  *
from grievance_master gm 
left join cmo_blocks_master cbm on cbm.block_id = gm.block_id 
left join cmo_municipality_master cmm on cmm.municipality_id = gm.municipality_id 
left join cmo_assembly_master cam on cam.assembly_id = gm.assembly_const_id 
left join cmo_gram_panchayat_master cgpm on gm.gp_id = cgpm.gp_id 
left join cmo_wards_master cwm on gm.ward_id = cwm.ward_id 
where gm.grievance_id in (2652582,
980968,
1216242,
2015456,
2756558,
993559,
1501486,
3454685,
4059259,
241656,
1945713,
397258,
1154252,
1944810,
3019422,
2272791,
3508238,
1528533,
702579,
3468405,
3470562,
3015759,
1998196,
3526729,
2280128,
1200543,
1437466,
2502399,
3562557,
1665033,
702058,
2273828,
3292478,
3514998,
3575296,
3604402,
3460370,
3458746,
1259462,
3456106,
111795,
1943367,
3016560,
2368215,
3058085,
1201003,
2496033,
2366956,
3020052,
114780,
3445540,
1776798,
2366195,
3294360,
2305834,
708775,
1777761,
3512722,
701250,
3019502,
1251843,
3443927,
3572768,
1437961,
2365440,
2296708,
3573237,
2221126,
1942510,
3444378,
1262124,
2299753,
3297673,
2299653,
3460047,
2504256,
1941424,
456047,
1436708,
3605132,
116648,
3292479,
2641001,
2465955,
2523125,
73372,
3287257,
3514378,
2311924,
1435576,
3547045,
699547,
3456088,
119346,
2643903,
2503687,
3011367,
1246843,
3554925,
3524551,
1147282,
1247978,
3514860,
2035324,
3546106,
3599919,
3468434,
388053,
2639742,
920325,
3562556,
123007,
3599855,
3602373,
2446864,
2272670,
2644474,
1943492,
3470894,
3607447,
1431479,
3601506,
3060059,
2000505,
2034322,
1435580,
457098,
2299752,
3600818,
1002108,
3525197,
1245242,
2301547,
557330,
3466504,
3517409,
114400,
1670602,
698974,
3299313,
3458465,
3301167,
1437960,
3514849,
3012786,
3469230,
3465693,
3601340,
457522,
1499744,
2645342,
1525420,
2530776,
4653780,
3468435,
3516430,
110501,
108154,
3451637,
3451636,
3297373,
3459678,
3061586,
555153,
3570312,
2301984,
3300642,
1942651,
3464552,
3543520,
3016987,
3545368,
2539247,
2466558,
1942652,
704574,
1097622,
556140,
1201054,
3467303,
1947532,
2564647,
98114,
1144387,
1202346,
3299341,
3458212,
1665275,
2538921,
3442940,
2644761,
1153744,
3451564,
3547399,
1262923,
2929118,
700279,
2020999,
2644469,
396237,
2222212,
2478368,
398039,
2641563,
2441833,
2639684,
1262924,
3448892,
458363,
3294647,
1147639,
3548918,
1201114,
2497443,
1522680,
3457593,
2548476,
3469491,
3543587,
3451563,
73215,
2532246,
1525475,
3466195,
1701261,
3548292,
2402742,
3544000,
86584,
2030366,
3176546,
3774776,
3155123,
1824456,
2541863,
2528485,
1950169,
1488944,
4986723,
3454270,
75530,
336743,
1326241,
3508393,
5074004,
4883871,
1728433,5498232,1685340)
order by gm.applicant_name asc;




--- ==================================================================================
--- =====================================================================================
    
    
--- =================== District level for CMO ==============================
with grievance_lodged as (
    select count(1) as grievance_lodged_cnt, bh.district_id
    	from grievance_master_bh_mat_2 as bh
    where 1 = 1 
--  and bh.assigned_to_office_id in (35)
    group by bh.district_id
), atr_received as (
    select count(distinct bh.grievance_id) as atr_received_cnt, bh.district_id
    	from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15)  
--    and bh.assigned_by_office_id in (35)
    group by bh.district_id
), close_count as (
    select gm.district_id, count(1) as closed,
        sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when gm.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as gm
        where gm.status = 15  
--        and gm.atr_submit_by_lastest_office_id in (35)
    group by gm.district_id
), pending_count as (
	select count(1) as pending_cnt, bh.district_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
--     and bh.assigned_by_office_id in (35)
    group by bh.district_id
) 
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cdm.district_name::text as unit_name,
    cdm.district_id as unit_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_districts_master cdm on gl.district_id = cdm.district_id
    left join atr_received ar on gl.district_id = ar.district_id
    left join pending_count pc on gl.district_id = pc.district_id
    left join close_count cc on gl.district_id = cc.district_id

    
--- =================== Sub-Divison level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.sub_division_id
    	from grievance_master_bh_mat_2 as bh
    where bh.sub_division_id is not null
    and bh.district_id in (22)
--    and bh.assigned_to_office_id in (35)
    group by bh.sub_division_id    
), atr_received as (
    select count(distinct bh.grievance_id) as atr_received_cnt, bh.sub_division_id
    	from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) and bh.sub_division_id is not null
    and bh.district_id in (22)
--    and bh.assigned_by_office_id in (35)
    group by bh.sub_division_id    
), close_count as (
    select bh.sub_division_id, count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 and bh.sub_division_id is not null
        and bh.district_id in (22)
--        and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.sub_division_id   
), pending_count as (
	select count(1) as pending_cnt, bh.sub_division_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null and bh.sub_division_id is not null
     and bh.district_id in (22)
--     and bh.assigned_to_office_id in (35)
    group by bh.sub_division_id
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    csdm.sub_division_name::text as unit_name,
    csdm.sub_division_id as unit_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_sub_divisions_master csdm on csdm.sub_division_id = gl.sub_division_id
    left join cmo_districts_master cdm on cdm.district_id = csdm.district_id
    left join atr_received ar on csdm.sub_division_id = ar.sub_division_id
    left join pending_count pc on ar.sub_division_id = pc.sub_division_id
    left join close_count cc on pc.sub_division_id = cc.sub_division_id 
--    where cdm.district_id in (22)
    
    
--- =================== Block / Municipality level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.block_id, bh.municipality_id
    from grievance_master_bh_mat_2 as bh
    where 1 = 1
    and bh.district_id in (22) and bh.sub_division_id in (72)
--    and bh.assigned_to_office_id in (35)
    group by bh.block_id, bh.municipality_id 
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, bh.block_id, bh.municipality_id
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
    and bh.district_id in (22) and bh.sub_division_id in (72)
--    and bh.assigned_by_office_id in (35)
    group by bh.block_id, bh.municipality_id   
), close_count as (
    select bh.block_id, bh.municipality_id, count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
        and bh.district_id in (22) and bh.sub_division_id in (72)
--        and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.block_id, bh.municipality_id   
), pending_count as (
	select count(1) as pending_cnt, bh.block_id, bh.municipality_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
     and bh.district_id in (22) and bh.sub_division_id in (72)
--     and bh.assigned_to_office_id in (35)
    group by bh.block_id, bh.municipality_id
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    case
        when cbm.block_name is not null then concat(cbm.block_name,'(B)')
        when cmm.municipality_name is not null then concat(cmm.municipality_name, '(M)')
    end as unit_name,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_blocks_master cbm on cbm.block_id = gl.block_id
    left join cmo_municipality_master cmm on cmm.municipality_id = gl.municipality_id
    left join atr_received ar on gl.block_id = ar.block_id or gl.municipality_id = ar.municipality_id
    left join pending_count pc on ar.block_id = pc.block_id or ar.municipality_id = pc.municipality_id
    left join close_count cc on pc.block_id = cc.block_id or pc.municipality_id = cc.municipality_id  
    
    
--- =================== Gram Panchayat -->> Block level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.gp_id
    from grievance_master_bh_mat_2 as bh
    where bh.gp_id is not null
    and bh.block_id in (264)
--    and bh.assigned_to_office_id in (35)
    group by bh.gp_id     
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, 
    	bh.gp_id
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
    and bh.block_id in (264)
--    and bh.assigned_by_office_id in (35)
    group by bh.gp_id      
), close_count as (
    select 
    	bh.gp_id,
    	count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
        and bh.block_id in (264)
--        and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.gp_id 
), pending_count as (
	select 
		count(1) as pending_cnt, bh.gp_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
     and bh.block_id in (264)
--     and bh.assigned_to_office_id in (35)
    group by bh.gp_id
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cgpm.gp_name as unit_name,
    cgpm.gp_id as unit_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gl.gp_id
    left join atr_received ar on gl.gp_id = ar.gp_id []
    left join pending_count pc on ar.gp_id = pc.gp_id 
    left join close_count cc on pc.gp_id = cc.gp_id  
    
 
--- =================== Ward -->> Municipality level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.ward_id
    from grievance_master_bh_mat_2 as bh
    where ward_id is not null
    and bh.municipality_id in (104)
--    and bh.assigned_to_office_id in (35)
    group by bh.ward_id  
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, 
    	bh.ward_id
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
    and bh.municipality_id in (104)
--    and bh.assigned_by_office_id in (35)
    group by bh.ward_id    
), close_count as (
    select 
    	bh.ward_id,
    	count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
        and bh.municipality_id in (104)
--        and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.ward_id  
), pending_count as (
	select 
		count(1) as pending_cnt, bh.ward_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
     and bh.municipality_id in (104)
--     and bh.assigned_to_office_id in (35)
    group by bh.ward_id  
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cwm.ward_name as unit_name,
    cwm.ward_id as unit_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_wards_master cwm on cwm.ward_id = gl.ward_id
    left join atr_received ar on gl.ward_id = ar.ward_id 
    left join pending_count pc on ar.ward_id = pc.ward_id 
    left join close_count cc on pc.ward_id = cc.ward_id
    
    
--- =================== Ward & Gram Panchayat --->> Block & Municipality level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.gp_id, bh.ward_id
    from grievance_master_bh_mat_2 as bh
    where (bh.gp_id is not null or bh.ward_id is not null)
    and (bh.block_id in (254) or bh.municipality_id in (104))
--    and bh.assigned_to_office_id in (35)
    group by bh.gp_id, bh.ward_id  
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, 
    	bh.gp_id, bh.ward_id
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
    and (bh.block_id in (254) or bh.municipality_id in (104))
--    and bh.assigned_by_office_id in (35)
    group by bh.gp_id, bh.ward_id    
), close_count as (
    select 
    	bh.gp_id, bh.ward_id,
    	count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
        and (bh.block_id in (254) or bh.municipality_id in (104))
--        and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.gp_id, bh.ward_id   
), pending_count as (
	select 
		count(1) as pending_cnt, bh.gp_id, bh.ward_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
     and (bh.block_id in (254) or bh.municipality_id in (104))
--     and bh.assigned_to_office_id in (35)
    group by bh.gp_id, bh.ward_id
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
     case
        when cwm.ward_name is not null then concat(cwm.ward_name, ' (W)')
        when cgpm.gp_name is not null then concat(cgpm.gp_name, ' (G)')
    end as unit_name,
    case 
    	when cwm.ward_id is not null then cwm.ward_id
    	when cgpm.gp_id is not null then cgpm.gp_id
    end as unit_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_wards_master cwm on cwm.ward_id = gl.ward_id
    left join cmo_gram_panchayat_master cgpm on cgpm.gp_id = gl.gp_id
    left join atr_received ar on gl.ward_id = ar.ward_id or gl.gp_id = ar.gp_id
    left join pending_count pc on ar.ward_id = pc.ward_id or gl.gp_id = pc.gp_id
    left join close_count cc on pc.ward_id = cc.ward_id or gl.gp_id = cc.gp_id;
    
  
  --- =================== District --->> Sub-District  --->> Police Station level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
    from grievance_master_bh_mat_2 as bh
    where bh.district_id is not null 
    and bh.sub_district_id is not null
--    and bh.district_id in (22)
--    and bh.police_station_id in (504) 
--    and bh.sub_district_id in (7)
--    and bh.assigned_to_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id   
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
--	  and bh.district_id in (22)
--    and bh.police_station_id in (504) 
--	  and bh.sub_district_id in (7)
--    and bh.assigned_by_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id
), close_count as (
    select 
    	bh.district_id, bh.sub_district_id, bh.police_station_id,
    	count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
--		and bh.district_id in (22)
--      and bh.police_station_id in (504) 
--	    and bh.sub_district_id in (7)
--      and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id
), pending_count as (
	select 
		count(1) as pending_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
--	  and bh.district_id in (22)
--    and bh.police_station_id in (504) 
--	  and bh.sub_district_id in (7)
--    and bh.assigned_to_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
     cdm.district_name as unit_name,
     cdm.district_id as unit_id,
     csdm.sub_district_name as sub_district_name,
     csdm.sub_district_id as sub_district_id,
     case 
        when gl.police_station_id is not NULL then cpsm.ps_name 
        else NULL 
    end as police_station_name,
    case 
        when gl.police_station_id is not NULL then cpsm.ps_id 
        else NULL 
    end as police_station_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_police_station_master cpsm on gl.police_station_id = cpsm.ps_id 
    left join cmo_districts_master cdm on gl.district_id = cdm.district_id
    left join cmo_sub_districts_master csdm on csdm.sub_district_id = gl.sub_district_id
    left join atr_received ar on gl.police_station_id = ar.police_station_id and gl.district_id = ar.district_id and gl.sub_district_id = ar.sub_district_id
    left join pending_count pc on gl.police_station_id = pc.police_station_id and gl.district_id = pc.district_id and gl.sub_district_id = pc.sub_district_id
    left join close_count cc on gl.police_station_id = cc.police_station_id and gl.district_id = cc.district_id and gl.sub_district_id = cc.sub_district_id;
    
   
--- =================== District --->> Sub-District --->> Police Stations level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
    from grievance_master_bh_mat_2 as bh
    where bh.district_id is not null 
    and bh.sub_district_id is not null
--    and bh.district_id in (22)
--    and bh.police_station_id in (504) 
--    and bh.sub_district_id in (7)
--    and bh.assigned_to_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id   
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
--	  and bh.district_id in (22)
--    and bh.police_station_id in (504) 
--	  and bh.sub_district_id in (7)
--    and bh.assigned_by_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id
), close_count as (
    select 
    	bh.district_id, bh.sub_district_id, bh.police_station_id,
    	count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
--		and bh.district_id in (22)
--      and bh.police_station_id in (504) 
--	    and bh.sub_district_id in (7)
--      and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id
), pending_count as (
	select 
		count(1) as pending_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
--	  and bh.district_id in (22)
--    and bh.police_station_id in (504) 
--	  and bh.sub_district_id in (7)
--    and bh.assigned_to_office_id in (35)
    group by bh.district_id, bh.sub_district_id, bh.police_station_id
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
     cdm.district_name as unit_name,
     cdm.district_id as unit_id,
     csdm.sub_district_name as sub_district_name,
     csdm.sub_district_id as sub_district_id,
     case 
        when gl.police_station_id is not NULL then cpsm.ps_name 
        else NULL 
    end as police_station_name,
    case 
        when gl.police_station_id is not NULL then cpsm.ps_id 
        else NULL 
    end as police_station_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_police_station_master cpsm on gl.police_station_id = cpsm.ps_id 
    left join cmo_districts_master cdm on gl.district_id = cdm.district_id
    left join cmo_sub_districts_master csdm on csdm.sub_district_id = gl.sub_district_id
    left join atr_received ar on gl.police_station_id = ar.police_station_id and gl.district_id = ar.district_id and gl.sub_district_id = ar.sub_district_id
    left join pending_count pc on gl.police_station_id = pc.police_station_id and gl.district_id = pc.district_id and gl.sub_district_id = pc.sub_district_id
    left join close_count cc on gl.police_station_id = cc.police_station_id and gl.district_id = cc.district_id and gl.sub_district_id = cc.sub_district_id;
   
   
--- =================== District --->> Assembly Master level for CMO ==============================
with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, bh.assembly_const_id, bh.district_id
    from grievance_master_bh_mat_2 as bh
    where bh.assembly_const_id is not null
    and bh.district_id in (22)
    and bh.assembly_const_id in (127)
--    and bh.assigned_to_office_id in (35)
    group by bh.assembly_const_id, bh.district_id 
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, bh.assembly_const_id, bh.district_id
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
	and bh.district_id in (22) 
	and bh.assembly_const_id in (127)
	--    and bh.assigned_by_office_id in (35)
    group by bh.assembly_const_id, bh.district_id    
), close_count as (
    select 
    	bh.assembly_const_id, bh.district_id,
    	count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
		and bh.district_id in (22)
	    and bh.assembly_const_id in (127)
	--    and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.assembly_const_id, bh.district_id
), pending_count as (
	select 
		count(1) as pending_cnt, bh.assembly_const_id, bh.district_id
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
	and bh.district_id in (22)
	and bh.assembly_const_id in (127)
--     and bh.assigned_to_office_id in (35)
    group by bh.assembly_const_id, bh.district_id
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
     cdm.district_name as unit_name,
     cdm.district_id as unit_id,
     cam.assembly_name as assembly_name,
     cam.assembly_id as assembly_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_assembly_master cam on cam.assembly_id = gl.assembly_const_id
    left join cmo_districts_master cdm on gl.district_id = cdm.district_id
    left join atr_received ar on gl.assembly_const_id = ar.assembly_const_id and gl.district_id = ar.district_id
    left join pending_count pc on gl.assembly_const_id = pc.assembly_const_id and gl.district_id = pc.district_id
    left join close_count cc on gl.assembly_const_id = cc.assembly_const_id and gl.district_id = cc.district_id; 
   
   
   
   
   
      
--     CASE 
--        WHEN :police_station_id IS NOT NULL THEN cpsm.ps_name
--        ELSE NULL
--    END AS police_station_name,
--    CASE 
--        WHEN :police_station_id IS NOT NULL THEN cpsm.ps_id
--        ELSE NULL
--    END AS police_station_id,   
   
--    WHERE 
--    (:police_station_id IS NOT NULL AND gl.police_station_id = :police_station_id);
   
   
   ---==============================================================================================
  
   
   
  with grievance_lodged as (
    select 
    	count(1) as grievance_lodged_cnt, 
    	bh.police_station_id, bh.sub_district_id
    from grievance_master_bh_mat_2 as bh
    where (bh.police_station_id is not null or bh.sub_district_id is not null)
--    and (bh.block_id in (254) or bh.municipality_id in (104))
    and (bh.police_station_id in (2) or bh.sub_district_id in (14))
--    and bh.assigned_to_office_id in (35)
    group by bh.police_station_id, bh.sub_district_id    
), atr_received as (
    select 
    	count(distinct bh.grievance_id) as atr_received_cnt, 
    	bh.police_station_id, bh.sub_district_id  
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15) 
--    and (bh.block_id in (254) or bh.municipality_id in (104))
--    and bh.assigned_by_office_id in (35)
    group by bh.police_station_id, bh.sub_district_id      
), close_count as (
    select 
    	bh.police_station_id, bh.sub_district_id,
    	count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
        where bh.status = 15 
--        and (bh.block_id in (254) or bh.municipality_id in (104))
--        and bh.atr_submit_by_lastest_office_id in (35)
    group by bh.police_station_id, bh.sub_district_id   
), pending_count as (
	select 
		count(1) as pending_cnt, 
		bh.police_station_id, bh.sub_district_id,
    	from forwarded_latest_3_bh_mat_2 as bh
    	left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
--     and (bh.block_id in (254) or bh.municipality_id in (104))
--     and bh.assigned_to_office_id in (35)
    group by bh.police_station_id, bh.sub_district_id,
)
select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
     cmo_police_station_master.ps_name as unit_name,
     cmo_police_station_master.ps_id as unit_id,
    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
    coalesce(ar.atr_received_cnt, 0) as atr_received,
    coalesce(cc.closed, 0) as total_disposed,
    coalesce(cc.bnft_prvd, 0) as benefit_provided,
    coalesce(cc.act_inti, 0) as action_initiated,
    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(cc.not_elgbl, 0) as non_actionable,
    coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_police_station_master cpsm on cpsm.ps_id = gl.police_station_id
    left join cmo_sub_districts_master csdm on csdm.sub_district_id = gl.sub_district_id
    left join atr_received ar on gl.ps_id = ar.ps_id or gl.sub_district_id = ar.sub_district_id
    left join pending_count pc on ar.ps_id = pc.ps_id or gl.sub_district_id = pc.sub_district_id
    left join close_count cc on pc.ps_id = cc.ps_id or gl.sub_district_id = cc.sub_district_id; 
   
   
   select * from cmo_sub_districts_master csdm ;
    
--- =======================================================================================
--- ======================================================================================= 
    
--- =================== District level for HOD ==============================
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.district_id
        FROM forwarded_latest_3_bh_mat_2 as bh
        where 1 = 1
         and bh.assigned_to_office_id in (35)
        group by bh.district_id
), atr_submitted as (
    SELECT bh.district_id,
        count(distinct bh.grievance_id) as atr_sent_cn
        /*sum(case when bh.current_status = 15 then 1 else 0 end) as _close_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl*/
    FROM atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15)  and bh.assigned_by_office_id in (35)
    group by bh.district_id
), close_count as (
    select  gm.district_id, count(1) as _close_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from  grievance_master_bh_mat_2 as gm
        inner join  forwarded_latest_3_bh_mat_2 as bh on gm.grievance_id = bh.grievance_id
            where gm.status = 15  and gm.atr_submit_by_lastest_office_id in (35)
    group by gm.district_id
), pending_count as (
    select count(1) as _pndddd_, bh.district_id
    from forwarded_latest_3_bh_mat_2 as bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
     and bh.assigned_to_office_id in (35)
    group by bh.district_id
) select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cdm.district_name::text as unit_name,
    cdm.district_id as unit_id,
    coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
    coalesce(ats.atr_sent_cn, 0) as atr_submitted,
    coalesce(close_count._close_, 0) as total_disposed,
    coalesce(close_count.bnft_prvd, 0) as benefit_provided,
    coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
    coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90,
    coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
    coalesce(close_count.not_elgbl, 0) as non_actionable,
    coalesce(pc._pndddd_, 0) as total_pending
    from grievances_recieved gr
    left join cmo_districts_master cdm on gr.district_id = cdm.district_id
    left join atr_submitted ats on gr.district_id = ats.district_id
    left join pending_count pc on gr.district_id = pc.district_id
    left join close_count on gr.district_id = close_count.district_id
--========================================================================================
    
    
--- =================== Sub-District level for HOD ==============================
with grievances_recieved as (
	    SELECT COUNT(1) as grievances_recieved_cnt, bh.sub_division_id
	        FROM forwarded_latest_3_bh_mat_2 as bh
	        where bh.sub_division_id is not null  and bh.assigned_to_office_id in (35)
	         and bh.district_id in (22)
	        group by bh.sub_division_id
	), atr_submitted as (
	    SELECT bh.sub_division_id, count(distinct bh.grievance_id) as atr_sent_cn
	        FROM atr_latest_14_bh_mat_2 as bh
	        inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
	        where bh.current_status in (14,15) and bh.sub_division_id is not null  and bh.assigned_by_office_id in (35)
	         and bh.district_id in (22)
	        group by bh.sub_division_id
	), close_count as (
	    select bh.sub_division_id, count(1) as _close_,
	        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
	        sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
	        sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
	        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
	        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
	        from grievance_master_bh_mat_2 as bh
	        inner join forwarded_latest_3_bh_mat_2 as bm on bh.grievance_id = bm.grievance_id
	        where bh.status = 15 and bh.sub_division_id is not null  and bh.atr_submit_by_lastest_office_id in (35)
	         and bh.district_id in (22)
	    group by bh.sub_division_id
	), pending_count as (
	    select count(1) as _pndddd_ , bh.sub_division_id
	        from forwarded_latest_3_bh_mat_2 as bh
	        where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
	              and bh.sub_division_id is not null
	         and bh.assigned_to_office_id in (35)  and bh.district_id in (22)
	    group by bh.sub_division_id
	) select
	    row_number() over() as sl_no,
	    '2025-06-05 16:30:01.203135+00:00'::timestamp as refresh_time_utc,
	    '2025-06-05 16:30:01.203135+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
	    csdm.sub_division_name::text as unit_name,
	    csdm.sub_division_id as unit_id,
	    coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
	    coalesce(ats.atr_sent_cn, 0) as atr_submitted,
	    coalesce(cc.bnft_prvd, 0) as benefit_provided,
	    coalesce(cc._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
	    coalesce(cc._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90,
	    coalesce(cc._pnd_policy_dec_, 0) as pending_for_policy_decision,
	    coalesce(cc.not_elgbl, 0) as non_actionable,
	    coalesce(cc._close_, 0) as total_disposed,
	    coalesce(pc._pndddd_, 0) as total_pending
	    from grievances_recieved gr
	    left join cmo_sub_divisions_master csdm on csdm.sub_division_id = gr.sub_division_id
	    left join cmo_districts_master cdm on csdm.district_id = cdm.district_id
	    left join atr_submitted ats on csdm.sub_division_id = ats.sub_division_id
	    left join pending_count pc on ats.sub_division_id = pc.sub_division_id
	    left join close_count cc on pc.sub_division_id = cc.sub_division_id;

	   
--- =================== Block / Municipality level for HOD ==============================
 with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.block_id, bh.municipality_id
            FROM forwarded_latest_3_bh_mat_2 as bh
            where 1 = 1    and bh.assigned_to_office_id in (35)   and bh.district_id in (22)   and bh.sub_division_id in (72)
        group by bh.block_id, bh.municipality_id
    ), atr_submitted as (
        SELECT count(1) as atr_sent_cn, bh.block_id, bh.municipality_id
            FROM atr_latest_14_bh_mat_2 as bh
            inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
            where bh.current_status in (14,15)  and bh.assigned_by_office_id in (35)     and bh.district_id in (22)   and bh.sub_division_id in (72)
        group by bh.block_id, bh.municipality_id
    ), close_count as (
        select bh.block_id, bh.municipality_id,
                count(1) as _close_,
                sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
                sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
                sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
                sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
            from grievance_master_bh_mat_2 as bh
            inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
            where bh.status = 15  and bh.atr_submit_by_lastest_office_id in (35)     and bh.district_id in (22)   and bh.sub_division_id in (72)
        group by bh.block_id, bh.municipality_id
    ), pending_count as (
        select count(1) as _pndddd_ , bh.block_id, bh.municipality_id
            from forwarded_latest_3_bh_mat_2 as bh
            where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
               and bh.assigned_to_office_id in (35)   and bh.district_id in (22)   and bh.sub_division_id in (72)
        group by bh.block_id, bh.municipality_id
    ) select
        row_number() over() as sl_no,
        '2025-06-05 16:30:01.203135+00:00':: timestamp as refresh_time_utc,
        '2025-06-05 16:30:01.203135+00:00':: timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        case
            when cmo_blocks_master.block_name is not null then concat(cmo_blocks_master.block_name,'(B)')
            when cmo_municipality_master.municipality_name is not null then concat(cmo_municipality_master.municipality_name, '(M)')
        end as unit_name,
        coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted,
        coalesce(close_count.bnft_prvd, 0) as benefit_provided,
        coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
        coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90,
        coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
        coalesce(close_count.not_elgbl) as non_actionable,
        coalesce(close_count._close_, 0) as total_disposed,
        coalesce(pending_count._pndddd_, 0) as total_pending
        from grievances_recieved
        left join cmo_blocks_master on cmo_blocks_master.block_id = grievances_recieved.block_id
        left join cmo_municipality_master on cmo_municipality_master.municipality_id = grievances_recieved.municipality_id
        left join atr_submitted on grievances_recieved.block_id = atr_submitted.block_id or grievances_recieved.municipality_id = atr_submitted.municipality_id
        left join pending_count on grievances_recieved.block_id = pending_count.block_id or grievances_recieved.municipality_id = pending_count.municipality_id
        left join close_count on grievances_recieved.block_id = close_count.block_id or grievances_recieved.municipality_id = close_count.municipality_id;   
	   
	   
--- =================== Gram Panchayat --->> Block level for HOD ==============================
 with grievances_recieved as (
    SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id
        FROM forwarded_latest_3_bh_mat_2 as bh
        where bh.gp_id is not null    
        and bh.assigned_to_office_id in (35)   and bh.block_id in (264)
    group by bh.gp_id
), atr_submitted as (
    SELECT count(1) as atr_sent_cn, bh.gp_id
        FROM atr_latest_14_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
        where bh.current_status in (14,15)    and bh.assigned_by_office_id in (35)   and bh.block_id in (264)
    group by bh.gp_id
), close_count as (
    select bh.gp_id,
            count(1) as close,
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15    and bh.atr_submit_by_lastest_office_id in (35)   and bh.block_id in (264)
    group by bh.gp_id
), pending_count as (
    select count(1) as pndddd , bh.gp_id
        from forwarded_latest_3_bh_mat_2 as bh
        where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
           and bh.assigned_to_office_id in (35)   and bh.block_id in (264)
    group by bh.gp_id
) select
row_number() over() as sl_no,
'2025-06-05 16:30:01.203135+00:00'::timestamp as refresh_time_utc,
'2025-06-05 16:30:01.203135+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cmo_gram_panchayat_master.gp_name as unit_name,
    cmo_gram_panchayat_master.gp_id as unit_id,
    coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
    coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted,
    coalesce(close_count.bnft_prvd, 0) as benefit_provided,
    coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
    coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90,
    coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(close_count.not_elgbl) as non_actionable,
    coalesce(close_count.close, 0) as total_disposed,
    coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved
left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
left join atr_submitted on grievances_recieved.gp_id = atr_submitted.gp_id
left join pending_count on grievances_recieved.gp_id = pending_count.gp_id
left join close_count on grievances_recieved.gp_id = close_count.gp_id;
	   

--- =================== Ward --->> Municipality level for HOD ==============================
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.ward_id
            FROM forwarded_latest_3_bh_mat_2 as bh
            where ward_id is not null    and bh.assigned_to_office_id in (35)   and bh.municipality_id in (104)
        group by bh.ward_id
    ), atr_submitted as (
        SELECT count(1) as atr_sent_cn, bh.ward_id
            FROM atr_latest_14_bh_mat_2 as bh
            inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
            where bh.current_status in (14,15)    and bh.assigned_by_office_id in (35)   and bh.municipality_id in (104)
        group by bh.ward_id
    ), close_count as (
        select bh.ward_id,
                count(1) as close,
                sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
                sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
                sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
                sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
            from grievance_master_bh_mat_2 as bh
            inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
            where bh.status = 15    and bh.atr_submit_by_lastest_office_id in (35)   and bh.municipality_id in (104)
        group by bh.ward_id
    ), pending_count as (
        select count(1) as pndddd , bh.ward_id
            from forwarded_latest_3_bh_mat_2 as bh
            where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
               and bh.assigned_to_office_id in (35)   and bh.municipality_id in (104)
        group by bh.ward_id
    ) select
        row_number() over() as sl_no,
        '2025-06-05 16:30:01.203135+00:00'::timestamp as refresh_time_utc,
        '2025-06-05 16:30:01.203135+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        cmo_wards_master.ward_name as unit_name,
        coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
        coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted,
        coalesce(close_count.bnft_prvd, 0) as benefit_provided,
        coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
        coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90,
        coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
        coalesce(close_count.not_elgbl, 0) as non_actionable,
        coalesce(close_count.close, 0) as total_disposed,
        coalesce(pending_count.pndddd, 0) as total_pending
    from grievances_recieved
    left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
    left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id
    left join pending_count on grievances_recieved.ward_id = pending_count.ward_id
    left join close_count on grievances_recieved.ward_id = close_count.ward_id;

   
--- =================== Ward & Gram Panchayat --->> Block & Municipality level for HOD ==============================
with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.gp_id, bh.ward_id
        FROM forwarded_latest_3_bh_mat_2 as bh
        where (bh.gp_id is not null or bh.ward_id is not null)    and bh.assigned_to_office_id in (35)
         and (bh.block_id in (254) or bh.municipality_id in (104))
    group by bh.gp_id, bh.ward_id
), atr_submitted as (
    SELECT count(1) as atr_sent_cn, bh.gp_id, bh.ward_id
        FROM atr_latest_14_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm ON bm.grievance_id = bh.grievance_id
        where bh.current_status in (14,15)    and bh.assigned_by_office_id in (35)
         and (bh.block_id in (254) or bh.municipality_id in (104))
    group by bh.gp_id, bh.ward_id
), close_count as (
    select bh.gp_id, bh.ward_id,
            count(1) as close,
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id = 5 then 1 else 0 end) as mt_t_up_win_90,
            sum(case when bh.closure_reason_id = 9 then 1 else 0 end) as mt_t_up_bey_90,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id
        where bh.status = 15    and bh.atr_submit_by_lastest_office_id in (35)
         and (bh.block_id in (254) or bh.municipality_id in (104))
    group by bh.gp_id, bh.ward_id
), pending_count as (
    select count(1) as pndddd , bh.gp_id, bh.ward_id
        from forwarded_latest_3_bh_mat_2 as bh
        where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
           and bh.assigned_to_office_id in (35)
         and (bh.block_id in (254) or bh.municipality_id in (104))
    group by bh.gp_id, bh.ward_id
) select
    row_number() over() as sl_no,
    '2025-06-08 16:30:01.704149+00:00'::timestamp as refresh_time_utc,
    '2025-06-08 16:30:01.704149+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    case
        when cmo_wards_master.ward_name is not null then concat(cmo_wards_master.ward_name, ' (W)')
        when cmo_gram_panchayat_master.gp_name is not null then concat(cmo_gram_panchayat_master.gp_name, ' (G)')
    end as unit_name,
    coalesce(grievances_recieved.grievances_recieved_cnt, 0) as grievances_recieved,
    coalesce(atr_submitted.atr_sent_cn, 0) as atr_submitted,
    coalesce(close_count.bnft_prvd, 0) as benefit_provided,
    coalesce(close_count.mt_t_up_win_90, 0) as matter_taken_up_with_in_90,
    coalesce(close_count.mt_t_up_bey_90, 0) as matter_taken_up_beyond_90,
    coalesce(close_count.pnd_policy_dec, 0) as pending_for_policy_decision,
    coalesce(close_count.not_elgbl, 0) as non_actionable,
    coalesce(close_count.close, 0) as total_disposed,
    coalesce(pending_count.pndddd, 0) as total_pending
from grievances_recieved
left join cmo_wards_master on cmo_wards_master.ward_id = grievances_recieved.ward_id
left join cmo_gram_panchayat_master on cmo_gram_panchayat_master.gp_id = grievances_recieved.gp_id
left join atr_submitted on grievances_recieved.ward_id = atr_submitted.ward_id or grievances_recieved.gp_id = atr_submitted.gp_id
left join pending_count on grievances_recieved.ward_id = pending_count.ward_id or grievances_recieved.gp_id = pending_count.gp_id
left join close_count on grievances_recieved.ward_id = close_count.ward_id or grievances_recieved.gp_id = close_count.gp_id;




------------------ District Level With date range ---------------------
    with grievances_recieved as (
        SELECT COUNT(1) as grievances_recieved_cnt, bh.district_id
        FROM forwarded_latest_3_bh_mat_2 as bh
        where 1 = 1  and bh.assigned_on::date between '2025-05-05' and '2025-06-04'
         and bh.assigned_to_office_id in (35)
        group by bh.district_id
), atr_submitted as (
    SELECT bh.district_id,
        count(distinct bh.grievance_id) as atr_sent_cn
        /*sum(case when bh.current_status = 15 then 1 else 0 end) as _close_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
        sum(case when bh.current_status = 15 and bh.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl*/
    FROM atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15)  and bh.assigned_by_office_id in (35)  and bm.assigned_on::date between '2025-05-05' and '2025-06-04'
    group by bh.district_id
), close_count as (
    select  gm.district_id, count(1) as _close_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from  grievance_master_bh_mat_2 as gm
        inner join  forwarded_latest_3_bh_mat_2 as bh on gm.grievance_id = bh.grievance_id
            where gm.status = 15  and gm.atr_submit_by_lastest_office_id in (35)  and bh.assigned_on::date between '2025-05-05' and '2025-06-04'
    group by gm.district_id
), pending_count as (
    select count(1) as _pndddd_, bh.district_id
    from forwarded_latest_3_bh_mat_2 as bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
     and bh.assigned_to_office_id in (35)  and bh.assigned_on::date between '2025-05-05' and '2025-06-04'
    group by bh.district_id
) select
    row_number() over() as sl_no,
    '2025-06-04 16:30:01.298436+00:00'::timestamp as refresh_time_utc,
    '2025-06-04 16:30:01.298436+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
    cdm.district_name::text as unit_name,
    cdm.district_id as unit_id,
    coalesce(gr.grievances_recieved_cnt, 0) as grievances_recieved,
    coalesce(ats.atr_sent_cn, 0) as atr_submitted,
    coalesce(close_count._close_, 0) as total_disposed,
    coalesce(close_count.bnft_prvd, 0) as benefit_provided,
    coalesce(close_count._mt_t_up_win_90_, 0) as matter_taken_up_with_in_90,
    coalesce(close_count._mt_t_up_bey_90_, 0) as matter_taken_up_beyond_90,
    coalesce(close_count._pnd_policy_dec_, 0) as pending_for_policy_decision,
    coalesce(close_count.not_elgbl, 0) as non_actionable,
    coalesce(pc._pndddd_, 0) as total_pending
    from grievances_recieved gr
    left join cmo_districts_master cdm on gr.district_id = cdm.district_id
    left join atr_submitted ats on gr.district_id = ats.district_id
    left join pending_count pc on gr.district_id = pc.district_id
    left join close_count on gr.district_id = close_count.district_id
    
    
    
    
    with uploaded_count as (
        select grievance_master.grievance_category, count(1) as _uploaded_      from grievance_master_bh_mat_2 as grievance_master
            where grievance_master.grievance_category > 0
                    /***** FILTER *****/
                     and grievance_master.grievance_generate_date::date between '2025-05-06' and '2025-06-10'
        group by grievance_master.grievance_category
    ), direct_close as (
        select direct_close_bh_mat.grievance_category, count(1) as _drct_cls_cnt_ from direct_close_bh_mat
            where direct_close_bh_mat.grievance_category > 0
            /***** FILTER *****/
                     and direct_close_bh_mat.grievance_generate_date::date between '2025-05-06' and '2025-06-10'
        group by direct_close_bh_mat.grievance_category
    ), fwd_count as (
        select forwarded_latest_3_bh_mat.grievance_category, count(1) as _fwd_ from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
            where forwarded_latest_3_bh_mat.grievance_category > 0
                    /***** FILTER *****/
                     and forwarded_latest_3_bh_mat.assigned_on::date between '2025-05-06' and '2025-06-10'
        group by forwarded_latest_3_bh_mat.grievance_category
    ), atr_count as (
        select atr_latest_14_bh_mat.grievance_category, count(1) as _atr_ /*,
            sum(case when atr_latest_14_bh_mat.current_status = 15 then 1 else 0 end) as _clse_,
            sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
    --        sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id in (5, 9) then 1 else 0 end) as action_taken,
            sum(case when atr_latest_14_bh_mat.current_status = 15 and atr_latest_14_bh_mat.grievance_master_closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_*/
        from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat
        inner join forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on forwarded_latest_3_bh_mat.grievance_id = atr_latest_14_bh_mat.grievance_id
            where atr_latest_14_bh_mat.grievance_category > 0 and atr_latest_14_bh_mat.current_status in (14,15)
                    /***** FILTER *****/
                     and forwarded_latest_3_bh_mat.assigned_on::date between '2025-05-06' and '2025-06-10'
        group by atr_latest_14_bh_mat.grievance_category
    ), pending_count as (
        select forwarded_latest_3_bh_mat.grievance_category, count(1) as _pndddd_ ,
            sum(case when pending_for_hod_wise_mat.days_diff < 7 then 1 else 0 end) as _within_7_d_,
            sum(case when (pending_for_hod_wise_mat.days_diff >= 7 and pending_for_hod_wise_mat.days_diff <= 15)then 1 else 0 end) as _within_7_t_15_d_,
            sum(case when (pending_for_hod_wise_mat.days_diff > 15 and pending_for_hod_wise_mat.days_diff <= 30)then 1 else 0 end) as _within_16_t_30_d_
        from forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat
        inner join pending_for_hod_wise_mat_2 as pending_for_hod_wise_mat on forwarded_latest_3_bh_mat.grievance_id = pending_for_hod_wise_mat.grievance_id
            where not exists (select 1 from atr_latest_14_bh_mat_2 as atr_latest_14_bh_mat where atr_latest_14_bh_mat.grievance_id = forwarded_latest_3_bh_mat.grievance_id and atr_latest_14_bh_mat.current_status in (14,15))
                    /***** FILTER *****/
                     and forwarded_latest_3_bh_mat.assigned_on::date between '2025-05-06' and '2025-06-10'


        group by forwarded_latest_3_bh_mat.grievance_category
    ), close_count as (
        select gm.grievance_category, count(1) as _clse_,
            sum(case when gm.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when gm.closure_reason_id = 5 then 1 else 0 end) as _mt_t_up_win_90_,
            sum(case when gm.closure_reason_id = 9 then 1 else 0 end) as _mt_t_up_bey_90_,
            sum(case when gm.closure_reason_id = 2 then 1 else 0 end) as _pnd_policy_dec_,
            sum(case when gm.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as _non_actionable_
        from  grievance_master_bh_mat_2 as gm
        inner join  forwarded_latest_3_bh_mat_2 as forwarded_latest_3_bh_mat on gm.grievance_id = forwarded_latest_3_bh_mat.grievance_id
            where gm.status = 15
            /******* filter *********/
                     and forwarded_latest_3_bh_mat.assigned_on::date between '2025-05-06' and '2025-06-10'


        group by gm.grievance_category
    )
    select
        row_number() over() as sl_no, '2025-06-10 16:30:01.211511+00:00'::timestamp as refresh_time_utc, '2025-06-10 16:30:01.211511+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, cmo_grievance_category_master.grievance_cat_id,
        cmo_grievance_category_master.grievance_category_desc, coalesce(cmo_office_master.office_name,'N/A') as office_name,
        cmo_grievance_category_master.parent_office_id, cmo_office_master.office_id,
        coalesce(uploaded_count._uploaded_, 0) as griev_upload, coalesce(fwd_count._fwd_, 0) as grv_fwd, coalesce(atr_count._atr_, 0) as atr_rcvd,
        coalesce(close_count._clse_, 0) as totl_dspsd,  coalesce(close_count.bnft_prvd, 0) as srv_prvd, coalesce(close_count._mt_t_up_win_90_, 0) as mt_t_up_win_90,
        coalesce(close_count._mt_t_up_bey_90_, 0) as mt_t_up_bey_90, coalesce(close_count._pnd_policy_dec_, 0) as pnd_policy_dec,
        coalesce(close_count._non_actionable_, 0) as non_actionable,
        coalesce(pending_count._pndddd_, 0) as atr_pndg, coalesce(pending_count._within_7_d_, 0) as within_7_d,
        coalesce(pending_count._within_7_t_15_d_, 0) as within_7_t_15_d, coalesce(pending_count._within_16_t_30_d_, 0) as within_16_t_30_d,
        (coalesce(pending_count._pndddd_, 0) - (coalesce(pending_count._within_7_d_, 0) + coalesce(pending_count._within_7_t_15_d_, 0) +  coalesce(pending_count._within_16_t_30_d_, 0))) as beyond_30_d,
        COALESCE(ROUND(CASE WHEN (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_) = 0 THEN 0
                                ELSE (close_count.bnft_prvd::numeric / (close_count.bnft_prvd + close_count._mt_t_up_win_90_ + close_count._mt_t_up_bey_90_ + close_count._pnd_policy_dec_)) * 100
                            END,2),0) AS bnft_prcnt,
        coalesce(direct_close._drct_cls_cnt_ ,0) as drct_cls_cnt
    from cmo_grievance_category_master
    left join cmo_office_master on cmo_office_master.office_id = cmo_grievance_category_master.parent_office_id
    left join uploaded_count on cmo_grievance_category_master.grievance_cat_id = uploaded_count.grievance_category
    left join fwd_count on cmo_grievance_category_master.grievance_cat_id = fwd_count.grievance_category
    left join atr_count on cmo_grievance_category_master.grievance_cat_id = atr_count.grievance_category
    left join pending_count on cmo_grievance_category_master.grievance_cat_id = pending_count.grievance_category
    left join close_count on cmo_grievance_category_master.grievance_cat_id = close_count.grievance_category
    left join direct_close on cmo_grievance_category_master.grievance_cat_id = direct_close.grievance_category
    /***** FILTER *****/
    where cmo_grievance_category_master.grievance_cat_id  > 0

    
-----------------------------------------------------------------------------------------------------------------------

   
--=========================================== Not Exist Rewrite Query ========================================
    
    select count(1) as pending_cnt, bh.district_id
    from forwarded_latest_3_bh_mat_2 as bh
    where not exists (select 1 from atr_latest_14_bh_mat_2 as bm where bm.grievance_id = bh.grievance_id and bm.current_status in (14,15))
--     and bh.assigned_by_office_id in (35)
    group by bh.district_id
    
    
    select count(1) as pending_cnt, bh.district_id
    from forwarded_latest_3_bh_mat_2 as bh
    left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
    group by bh.district_id

  ---==============================================================================================================
    
select * from mat_view_refresh_scheduler mvrs where is_refresh_lock is false ;
    
    
    
with grievance_lodged as (
    select count(1) as grievance_lodged_cnt, bh.district_id from grievance_master_bh_mat_2 as bh where 1 = 1 group by bh.district_id
), atr_received as (
    select count(1) as atr_received_cnt, bh.district_id 
    from atr_latest_14_bh_mat_2 as bh
    inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
    where bh.current_status in (14,15)      
    group by bh.district_id
), close_count as (
    select bh.district_id, count(1) as closed,
        sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
        sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
        sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
        sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
    from grievance_master_bh_mat_2 as bh
    where bh.status = 15      
    group by bh.district_id
), pending_count as (
    select count(1) as pending_cnt, bh.district_id
    from forwarded_latest_3_bh_mat_2 as bh
    left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
    where bm.grievance_id is null 
    group by bh.district_id
) 
select 	row_number() over() as sl_no,
    	'2025-06-10 16:30:01.211511+00:00'::timestamp as refresh_time_utc,
		'2025-06-10 16:30:01.211511+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
		cdm.district_name::text as unit_name, cdm.district_id as unit_id, 
	    coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
		coalesce(ar.atr_received_cnt, 0) as atr_received,
		coalesce(cc.closed, 0) as total_disposed,
	    coalesce(cc.bnft_prvd, 0) as benefit_provided,
	    coalesce(cc.act_inti, 0) as action_initiated,
	    coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
	    coalesce(cc.not_elgbl, 0) as non_actionable,
	    coalesce(pc.pending_cnt, 0) as total_pending
from grievance_lodged gl
left join cmo_districts_master cdm on gl.district_id = cdm.district_id
left join atr_received ar on gl.district_id = ar.district_id
left join pending_count pc on gl.district_id = pc.district_id
left join close_count cc on gl.district_id = cc.district_id;
    

SELECT 
	COUNT(1) as grievances_recieved_cnt, bh.police_station_id
        FROM grievance_master_bh_mat_2 as bh
        where 1=1 and bh.sub_district_id in (7)
    group by bh.police_station_id


    
 with grievance_lodged as (
        select 
            count(1) as grievance_lodged_cnt, bh.district_id
        from grievance_master_bh_mat_2 as bh
            where 1 = 1 
             and bh.received_at in (1)  and bh.receipt_mode in (5) 
        group by bh.district_id
    ), atr_received as (
        select 
            count(distinct bh.grievance_id) as atr_received_cnt, bh.district_id
            from atr_latest_14_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
            where bh.current_status in (14,15) 
             and bh.received_at in (1)  and bh.receipt_mode in (5)  
        group by bh.district_id
    ), close_count as (
        select 
            bh.district_id, count(1) as closed,
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl	
        from grievance_master_bh_mat_2 as bh
            where bh.status = 15  
             and bh.received_at in (1)  and bh.receipt_mode in (5) 
        group by bh.district_id
    ), pending_count as (
        select 
            count(1) as pending_cnt, bh.district_id
        from forwarded_latest_3_bh_mat_2 as bh
        left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
            where bm.grievance_id is null 
             and bh.received_at in (1)  and bh.receipt_mode in (5) 
        group by bh.district_id
    ) 
    select
        row_number() over() as sl_no,
        '2025-06-11 16:30:01.664030+00:00'::timestamp as refresh_time_utc,
        '2025-06-11 16:30:01.664030+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist, 
        cdm.district_name::text as unit_name,
        cdm.district_id as unit_id,
        coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
        coalesce(ar.atr_received_cnt, 0) as atr_received,
        coalesce(cc.closed, 0) as total_disposed,
        coalesce(cc.bnft_prvd, 0) as benefit_provided,
        coalesce(cc.act_inti, 0) as action_initiated,
        coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
        coalesce(cc.not_elgbl, 0) as non_actionable,
        coalesce(pc.pending_cnt, 0) as total_pending
    from grievance_lodged gl
    left join cmo_districts_master cdm on gl.district_id = cdm.district_id
    left join atr_received ar on gl.district_id = ar.district_id
    left join pending_count pc on gl.district_id = pc.district_id
    left join close_count cc on gl.district_id = cc.district_id
    
    
    ---------------------------------------------------------------------------------
    
with grievance_lodged as (
        select
            count(1) as grievance_lodged_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
        from grievance_master_bh_mat_2 as bh
        where bh.district_id is not null
        and bh.sub_district_id is not null
--         and bh.grievance_generate_date::date between '2021-06-08' and '2025-07-01'
        group by bh.district_id, bh.sub_district_id, bh.police_station_id
--        order by bh.district_id, bh.sub_district_id
    ), atr_received as (
        select
            count(distinct bh.grievance_id) as atr_received_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
        from atr_latest_14_bh_mat_2 as bh
        inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
        where bh.current_status in (14,15)
--         and bm.assigned_on::date between '2021-06-08' and '2025-07-01'
        group by bh.district_id, bh.sub_district_id, bh.police_station_id
--        order by bh.district_id, bh.sub_district_id
    ), close_count as (
        select
            bh.district_id, bh.sub_district_id, bh.police_station_id,
            count(1) as closed,
            sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
            sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
            sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
            sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
        from grievance_master_bh_mat_2 as bh
            where bh.status = 15
--             and bh.grievance_generate_date::date between '2021-06-08' and '2025-07-01'
        group by bh.district_id, bh.sub_district_id, bh.police_station_id
--        order by bh.district_id, bh.sub_district_id
    ), pending_count as (
        select
            count(1) as pending_cnt, bh.district_id, bh.sub_district_id, bh.police_station_id
            from forwarded_latest_3_bh_mat_2 as bh
            left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
        where bm.grievance_id is null
--         and bh.assigned_on::date between '2021-06-08' and '2025-07-01'
        group by bh.district_id, bh.sub_district_id, bh.police_station_id
--        order by bh.district_id, bh.sub_district_id
    )
    select
        row_number() over(
        	order by cdm.district_name, csdm.sub_district_name, cpsm.ps_name
        ) as sl_no,
        '2025-06-30 16:30:01.359662+00:00'::timestamp as refresh_time_utc,
        '2025-06-30 16:30:01.359662+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
        cdm.district_name as unit_name,
        cdm.district_id as unit_id,
        csdm.sub_district_name as sub_district_name,
        csdm.sub_district_id as sub_district_id,
        case
            when gl.police_station_id is not NULL then cpsm.ps_name
            else NULL
        end as police_station_name,
        case
            when gl.police_station_id is not NULL then cpsm.ps_id
            else NULL
        end as police_station_id,
        coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
        coalesce(ar.atr_received_cnt, 0) as atr_received,
        coalesce(cc.closed, 0) as total_disposed,
        coalesce(cc.bnft_prvd, 0) as benefit_provided,
        coalesce(cc.act_inti, 0) as action_initiated,
        coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
        coalesce(cc.not_elgbl, 0) as non_actionable,
        coalesce(pc.pending_cnt, 0) as total_pending
        from grievance_lodged gl
        left join cmo_police_station_master cpsm on gl.police_station_id = cpsm.ps_id
        left join cmo_districts_master cdm on gl.district_id = cdm.district_id
        left join cmo_sub_districts_master csdm on csdm.sub_district_id = gl.sub_district_id
        left join atr_received ar on gl.police_station_id = ar.police_station_id and gl.district_id = ar.district_id and gl.sub_district_id = ar.sub_district_id
        left join pending_count pc on gl.police_station_id = pc.police_station_id and gl.district_id = pc.district_id and gl.sub_district_id = pc.sub_district_id
        left join close_count cc on gl.police_station_id = cc.police_station_id and gl.district_id = cc.district_id and gl.sub_district_id = cc.sub_district_id
--        order by cdm.district_name, csdm.sub_district_name, cpsm.ps_name 
        
        
        
        
        
       with grievance_lodged as (
                select
                    count(1) as grievance_lodged_cnt, bh.assembly_const_id, bh.district_id
                from grievance_master_bh_mat_2 as bh
                where bh.assembly_const_id is not null
                 and bh.district_id in (22)
                 and bh.grievance_generate_date::date between '2021-06-08' and '2025-07-01'
                group by bh.assembly_const_id, bh.district_id
            ), atr_received as (
                select
                    count(distinct bh.grievance_id) as atr_received_cnt, bh.assembly_const_id, bh.district_id
                from atr_latest_14_bh_mat_2 as bh
                inner join forwarded_latest_3_bh_mat_2 as bm ON bh.grievance_id = bm.grievance_id
                where bh.current_status in (14,15)
                 and bh.district_id in (22)
                 and bm.assigned_on::date between '2021-06-08' and '2025-07-01'
                group by bh.assembly_const_id, bh.district_id
            ), close_count as (
                select
                    bh.assembly_const_id, bh.district_id,
                    count(1) as closed,
                    sum(case when bh.closure_reason_id = 1 then 1 else 0 end) as bnft_prvd,
                    sum(case when bh.closure_reason_id in (5, 9) then 1 else 0 end) as act_inti,
                    sum(case when bh.closure_reason_id = 2 then 1 else 0 end) as pnd_policy_dec,
                    sum(case when bh.closure_reason_id not in (1, 2, 5, 9) then 1 else 0 end) as not_elgbl
                from grievance_master_bh_mat_2 as bh
                    where bh.status = 15
                     and bh.district_id in (22)
                     and bh.grievance_generate_date::date between '2021-06-08' and '2025-07-01'
                group by bh.assembly_const_id, bh.district_id
            ), pending_count as (
                select
                    count(1) as pending_cnt, bh.assembly_const_id, bh.district_id
                    from forwarded_latest_3_bh_mat_2 as bh
                    left join atr_latest_14_bh_mat_2 as bm on bm.grievance_id = bh.grievance_id and bm.current_status in (14,15)
                where bm.grievance_id is null
                 and bh.district_id in (22)
                 and bh.assigned_on::date between '2021-06-08' and '2025-07-01'
                group by bh.assembly_const_id, bh.district_id
            )
            select
                row_number() over(
                    order by cdm.district_name, cam.assembly_name asc
                ) as sl_no,
                '2025-06-30 16:30:01.359662+00:00'::timestamp as refresh_time_utc,
                '2025-06-30 16:30:01.359662+00:00'::timestamp + interval '5 hour 30 minutes' as refresh_time_ist,
                cdm.district_name as unit_name,
                cdm.district_id as unit_id,
                cam.assembly_name as assembly_name,
                cam.assembly_id as assembly_id,
                coalesce(gl.grievance_lodged_cnt, 0) as grievance_lodged,
                coalesce(ar.atr_received_cnt, 0) as atr_received,
                coalesce(cc.closed, 0) as total_disposed,
                coalesce(cc.bnft_prvd, 0) as benefit_provided,
                coalesce(cc.act_inti, 0) as action_initiated,
                coalesce(cc.pnd_policy_dec, 0) as pending_for_policy_decision,
                coalesce(cc.not_elgbl, 0) as non_actionable,
                coalesce(pc.pending_cnt, 0) as total_pending
                from grievance_lodged gl
                left join cmo_assembly_master cam on cam.assembly_id = gl.assembly_const_id
                left join cmo_districts_master cdm on gl.district_id = cdm.district_id
                left join atr_received ar on gl.assembly_const_id = ar.assembly_const_id and gl.district_id = ar.district_id
                left join pending_count pc on gl.assembly_const_id = pc.assembly_const_id and gl.district_id = pc.district_id
                left join close_count cc on gl.assembly_const_id = cc.assembly_const_id and gl.district_id = cc.district_id


                
 -----------------------------------------------------------------------------------------------------------------------------------------
                
                