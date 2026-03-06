CREATE OR REPLACE FUNCTION cmo_griveance_test3()
RETURNS TEXT AS $$
DECLARE
    query TEXT := 'SELECT ';
    rec RECORD;
BEGIN
    -- Loop through each religion code in cmo_religion_master
    FOR rec IN 
        SELECT religion_code, religion_name 
        FROM cmo_religion_master 
    LOOP
        query := query || 
            'MAX(CASE WHEN gm.applicant_reigion = ' || rec.religion_code || ' THEN gm.religionwise_count END) AS grievances_received_' || LOWER(rec.religion_name) || ', ';
    END LOOP;

    -- Add additional cases for other conditions
    query := query ||
        'MAX(CASE WHEN gm.applicant_reigion IS NULL THEN 1 END) AS grievances_received_no_religion ' ||
        'FROM (SELECT count(1) AS religionwise_count, gm.applicant_reigion, crm.religion_name ' ||
        'FROM grievance_master gm ' ||
        'LEFT JOIN cmo_religion_master crm ON crm.religion_id = gm.applicant_reigion ' ||
        'WHERE gm.created_on >= ''2023-06-08'' ' ||
        'GROUP BY gm.applicant_reigion, crm.religion_name) AS gm;';

    RETURN query;
END;
$$ LANGUAGE plpgsql;
