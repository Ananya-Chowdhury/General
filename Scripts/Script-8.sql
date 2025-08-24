--ALTER TABLE public.cmo_districts_master DROP COLUMN population;
ALTER TABLE public.cmo_districts_master ADD population int NOT NULL;
