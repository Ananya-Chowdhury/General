
--CALL seed_candidates(500);

CREATE OR REPLACE PROCEDURE register_candidates(p_count INT)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
    candidate_id BIGINT;
    lifecycle_count INT;
    status_num INT;
    sector_count INT;
    status_remark TEXT;

    -- Name arrays
    first_names TEXT[] := ARRAY['Amit','Rahul','Priya','Sneha','Kunal','Riya','Arjun','Neha','Vikash','Pooja'];
    last_names  TEXT[] := ARRAY['Das','Sharma','Singh','Roy','Bora','Deka','Ali','Khan','Paul','Gupta'];
    father_first TEXT[] := ARRAY['Ravi','Suresh','Kushal','Mahesh','Ramesh','Dilip','Anil','Manoj'];
    village_names TEXT[] := ARRAY['Agarpara','Gobindanagar','Borkhola','Sonapur','Barpeta Road','Rangia','Hajo','Boko','Nalbari','Tamulpur','Pathsala','Goreswar','Baihata','Chaygaon','Sarthebari'];

BEGIN

FOR i IN 1..10 LOOP

    INSERT INTO candidates (
        candidate_code,
        candidate_sys_code,
        kaushal_panjee_id,
        candidate_type,
        first_name,
        last_name,
        father_name,
        email,
        mobile_no,
        dob,
        gender,
        category,
        minority,
        pwd,
        religion,
        pincode,
        aadhar,
        bank_account,
        state_id,
        district_id,
        block_id,
        gp_id,
        qualification_id,
        passout_year,
        permanent_address,
        house_no,
        village,
        interest_freelancer,
        status,
        is_verified,
        is_show_details,
        is_active,
        created_by,
        updated_by,
        created_on,
        updated_on
    )
    VALUES (
        'CAND-' || LPAD(FLOOR(random()*99999)::text, 5, '0'),  -- candidate_code
        'CAND' || LPAD(i::text,4,'0'),            -- candidate_sys_code
        'KP' || FLOOR(random()*9999999999),       -- kaushal_panjee_id
        FLOOR(random()*2)+1,                      -- candidate_type (1 or 2)
        first_names[FLOOR(random()*array_length(first_names,1))+1],
        last_names[FLOOR(random()*array_length(last_names,1))+1],
        father_first[FLOOR(random()*array_length(father_first,1))+1]
            || ' ' ||
        last_names[FLOOR(random()*array_length(last_names,1))+1],
        'candidate' || i || '@test.com',
        '9' || FLOOR(random()*900000000 + 100000000),
        DATE '1990-01-01' + FLOOR(random() * 5844)::int,
        FLOOR(random()*2)+1,
        FLOOR(random()*5)+1,
        FLOOR(random()*2),
        FLOOR(random()*2),
        FLOOR(random()*5)+1,
        FLOOR(random()*999999)::int,
        FLOOR(random()*999999999999)::text,
        FLOOR(random()*9999999999)::text,
        1568,
        28,
        59,
        FLOOR(random()*100)+1,                    -- gp_id random
        FLOOR(random()*9)+1,                      -- qualification_id 1–9
        FLOOR(random()*8)+2015,
        FLOOR(random()*999)::text || ', Main Road, City Area',   -- permanent_address
        FLOOR(random()*200)::text,                -- house_no
        village_names[FLOOR(random()*array_length(village_names,1))+1],        -- village random
        false,                                    -- interest_freelancer
        1,
        true,
        false,                                    -- is_show_details
        true,
        1,
        1,
        NOW(),
        NOW()
    )
    RETURNING id INTO candidate_id;

    -- Random lifecycle stage between 3 and 12
    lifecycle_count := FLOOR(random()*10)+3;

    FOR status_num IN 1..lifecycle_count LOOP

        CASE status_num
            WHEN 1 THEN status_remark := 'Pre Registered';
            WHEN 2 THEN status_remark := 'Register Candidate With Preferred Training Sector';
            WHEN 3 THEN status_remark := 'Tagged with Training Center';
            WHEN 4 THEN status_remark := 'Batch Creation';
            WHEN 5 THEN status_remark := 'Assessment';
            WHEN 6 THEN status_remark := 'After Training Certificate Issued';
            WHEN 7 THEN status_remark := 'On Job Training';
            WHEN 8 THEN status_remark := 'Placement Done';
            WHEN 9 THEN status_remark := 'Training Complete';
            WHEN 10 THEN status_remark := 'Gig Worker Conversion';
            WHEN 11 THEN status_remark := 'Monitoring Period';
            WHEN 12 THEN status_remark := 'Training Closed';
            ELSE status_remark := 'Status Updated';
        END CASE;

        INSERT INTO candidate_lifecycle_status (
            candidate_id,
            candidate_lifecycle_status,
            assigned_to,
            assigned_by,
            remarks,
            created_by,
            updated_by,
            is_active,
            created_on,
            updated_on
        )
        VALUES (
            candidate_id,
            status_num,
            FLOOR(random()*5)+1,
            1,
            status_remark,
            1,
            1,
            true,
            NOW() - (interval '1 day' * (lifecycle_count - status_num)),
            NOW()
        );

    END LOOP;

    -- Preferred sectors
    sector_count := FLOOR(random()*3)+1;

    FOR status_num IN 1..sector_count LOOP
        INSERT INTO trainee_prefer_sectors (
            candidate_id,
            sector_id,
            created_by,
            updated_by,
            created_on,
            updated_on
        )
        VALUES (
            candidate_id,
            FLOOR(random()*5)+1,
            1,
            1,
            NOW(),
            NOW()
        );
    END LOOP;
END LOOP;
END $$;
