-- MIS query 
select  
            table0.grievance_cat_id,
            table0.grievance_category_desc,
            coalesce(table0.office_name,'N/A') as office_name,
            --  table1.office_id,
            coalesce(table1.grv_rcvd,0) as grievances_received_from_cmo,
            coalesce(table2.grv_frwd_to_suboff,0) as grievances_forwarded_to_suboffice,
            coalesce(table3.grv_frwd_to_othr_hod,0) as grievances_forwarded_to_other_hod,
            coalesce(table2.grv_frwd_to_suboff, 0) + coalesce(table3.grv_frwd_to_othr_hod, 0) as total_grievance_forwarded,		-- total_griv_frwd
            coalesce(table4.atr_rcvd_from_suboff,0) as atr_received_from_sub_office,
            coalesce(table5.atr_rcvd_from_othr_hods,0) as atr_received_from_other_hods,
            coalesce(table4.atr_rcvd_from_suboff,0) + coalesce(table5.atr_rcvd_from_othr_hods,0) as total_atr_received, 		-- total_atr_rcvd
            coalesce(table6.atr_rcvd_from_cmo,0) as atr_received_from_cmo
                from(
        select 
            distinct cgcm.grievance_cat_id, 
            cgcm.grievance_category_desc, 
            cgcm.parent_office_id, 
            com.office_name
                    from cmo_grievance_category_master cgcm
                        left join cmo_office_master com on cgcm.parent_office_id = com.office_id
                        where cgcm.status = 1
                    )table0
            -- griv received from cmo --    
        left outer join(
            select 
                cog.grievance_category_desc,
                cog.office_name,
                cog.office_id,
                cog.grievance_cat_id, 
                count(1) as grv_rcvd
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status not in (1,2) 
                {office}
                {data_source} 
                {received_at}
            group by grievance_cat_id,grievance_category_desc,office_name,cog.office_id) table1
                    on table0.grievance_cat_id = table1.grievance_cat_id
            -- griev frwded to suboffice
        left outer join (
            select 
                count(1) as grv_frwd_to_suboff, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status not in (1,2,3,4)
                {office}
                {data_source}
                {received_at}
            group by cog.grievance_cat_id) table2
                    on table2.grievance_cat_id = table0.grievance_cat_id
            -- griev frwded to other hod
        left outer join (
            select 
                count(1) as grv_frwd_to_othr_hod, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (5,6,13,14,15,16,17)
                {office}
                {data_source}
                {received_at}
            group by cog.grievance_cat_id) table3
                    on table3.grievance_cat_id = table0.grievance_cat_id
            -- atr received from suboffice
        left outer join (
            select 
                count(1) as atr_rcvd_from_suboff, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (9,10,11,12,14,15)
                    {office}
                    {data_source}
                    {received_at}
                group by cog.grievance_cat_id) table4
                    on table4.grievance_cat_id = table0.grievance_cat_id
            -- atr received from other hods
        left outer join (
            select 
                count(1) as atr_rcvd_from_othr_hods, 
                cog.grievance_cat_id 
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (13,14,15,16,17)
                    {office}
                    {data_source}
                    {received_at}
                group by cog.grievance_cat_id) table5
                    on table5.grievance_cat_id = table0.grievance_cat_id
            -- atr sent to cmo
        left outer join (
            select 
                count(1) as atr_rcvd_from_cmo, 
                cog.grievance_cat_id  
            from cat_offc_grievances cog 
                where grievance_generate_date between {from_date} and {to_date} 
                and cog.status in (14,15)
                    {office}
                    {data_source}
                    {received_at}
                group by cog.grievance_cat_id) table6
                    on table6.grievance_cat_id = table0.grievance_cat_id;