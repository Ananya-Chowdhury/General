
-- public.mat_view_refresh_scheduler definition
-- Drop table
-- DROP TABLE public.mat_view_refresh_scheduler;

CREATE TABLE public.mat_view_refresh_scheduler (
	id serial4 NOT NULL,
	"key" int4 NOT NULL,
	table_name varchar NOT NULL,
	is_refresh_lock bool DEFAULT false NOT NULL,
	refreshed_on timestamptz NOT NULL
);




------- crerate refresh sheduler  ---------

-- DROP PROCEDURE public.refresh_materialized_view_v2();

CREATE OR REPLACE PROCEDURE public.refresh_materialized_view()
 LANGUAGE plpgsql
AS $procedure$

 DECLARE
	key_1_table_name text;
	key_1_query_construct text;

  begin
			-- KEY 1 >> sector_skill_by_district_mv >> Refresh
			with updated_id as (
				update mat_view_refresh_scheduler 
				set is_refresh_lock = false
				where key = 1 and is_refresh_lock = true 
				returning id
			)
			update mat_view_refresh_scheduler set is_refresh_lock = true, refreshed_on = now() -- interval '5 hour 30 Minutes'
			where key = 1 and id != (select id from updated_id);
		
		    -- COMMIT After Refresh LOCK
			COMMIT;
			
			-- Refresh MAT Views Queries
			select table_name into key_1_table_name from mat_view_refresh_scheduler where key = 1 and is_refresh_lock is true;
			key_1_query_construct := 'refresh materialized view ' || quote_ident(key_1_table_name);
		
		
			raise notice '%', key_1_query_construct;
		
			EXECUTE key_1_query_construct;
	
		END;
$procedure$
;




-- public.sector_skill_by_district_mv_2 source

CREATE MATERIALIZED VIEW public.sector_skill_by_district_mv_2
TABLESPACE pg_default
AS SELECT cpl.district_id,
    dm.is_required AS is_available,
    sm.id AS sector_id,
    sm.sector_name,
    im.icon_base64 AS sector_icon,
    jsonb_agg(DISTINCT jsonb_build_object('skill_id', sm2.id, 'skill_code', sm2.skill_code, 'skill_name', sm2.skill_name, 'skill_icon', im2.icon_base64)) FILTER (WHERE COALESCE(dac_skill.is_visible, true) = true) AS skills,
    now() AS last_refreshed
   FROM candidate_preferred_services cps
     JOIN candidate_preferred_location cpl ON cpl.candidate_id = cps.candidate_id
     LEFT JOIN district_master dm ON dm.id = cpl.district_id
     LEFT JOIN sector_master sm ON sm.id = cps.sector_id
     LEFT JOIN icon_master im ON im.entity_id = sm.id AND im.is_active = true
     LEFT JOIN skill_master sm2 ON sm2.id = cps.skill_id
     LEFT JOIN icon_master im2 ON im2.entity_id = sm2.id AND im2.is_active = true
     LEFT JOIN service_admin_control dac_sector ON dac_sector.district_id = cpl.district_id AND dac_sector.entity_type = 1 AND dac_sector.entity_id = sm.id
     LEFT JOIN service_admin_control dac_skill ON dac_skill.district_id = cpl.district_id AND dac_skill.entity_type = 2 AND dac_skill.entity_id = sm2.id
  WHERE cps.status = 1 AND sm.is_active = true AND COALESCE(dac_sector.is_visible, true) = true
  GROUP BY cpl.district_id, dm.is_required, sm.id, sm.sector_name, im.icon_base64
 HAVING count(sm2.id) FILTER (WHERE COALESCE(dac_skill.is_visible, true) = true) > 0
WITH DATA;

-- View indexes:
CREATE INDEX idx_sector_skill_by_district_mv_2_district ON public.sector_skill_by_district_mv_2 USING btree (district_id);
CREATE UNIQUE INDEX idx_sector_skill_by_district_mv_2_unique ON public.sector_skill_by_district_mv_2 USING btree (district_id, sector_id);