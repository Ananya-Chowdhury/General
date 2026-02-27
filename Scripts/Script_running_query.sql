
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
    first_names TEXT[] := ARRAY['Amit','Rahul','Priya','Sneha','Kunal','Riya','Arjun','Neha','Vikash','Pooja','Sanjay','Anjali','Deepak','Nisha','Rohit','Swati','Manish','Komal','Abhishek','Meena',
						'Vivek','Suman','Ajay','Kavita','Nitin','Rekha','Gaurav','Sunita','Ankit','Preeti','Suraj','Payal','Lokesh','Divya','Sandeep','Shreya','Prakash','Varsha','Yogesh','Anita',
						'Tarun','Madhuri','Harish','Simran','Rajesh','Kiran','Hemant','Alka','Pankaj','Bhavna'];
    last_names TEXT[] := ARRAY['Das','Sharma','Singh','Roy','Bora','Deka','Ali','Khan','Paul','Gupta','Yadav','Thakur','Choudhury','Patel','Mehta','Verma','Saha','Nath','Baruah','Kalita',
 						'Saikia','Hazarika','Gogoi','Begum','Malik','Chauhan','Rawat','Tiwari','Dubey','Mishra','Rana','Prasad','Sarkar','Barman','Pathak','Rathore','Jain','Kumar','Mondal',
						'Pillai','Reddy','Naidu','Sheikh','Kapoor','Arora','Bansal','Tripathi','Mahato','Chatterjee','Lal'];
    father_first TEXT[] := ARRAY['Ravi','Suresh','Kushal','Mahesh','Ramesh','Dilip','Anil','Manoj','Ashok','Naresh','Bipin','Chandan','Devendra','Eknath','Firoz','Ganesh','Harendra','Indrajit','Jagdish','Kailash',
					'Lalit','Mukesh','Narayan','Omprakash','Pradeep','Qasim','Rajendra','Shankar','Tapan','Umesh','Vinod','Wasim','Yashpal','Zakir','Bhaskar','Chirag','Dhananjay','Gopal','Himanshu','Irfan',
					'Jitendra','Krishna','Loknath','Madan','Naveen','Owais','Prakash','Raghav','Subhash','Tushar'];
    village_names TEXT[] := ARRAY['Agarpara','Gobindanagar','Borkhola','Sonapur','Barpeta Road','Rangia','Hajo','Boko','Nalbari','Tamulpur','Pathsala','Goreswar','Baihata','Chaygaon','Sarthebari',
					'Balipara','Dhekiajuli','Mangaldoi','Udalguri','Tezpur','Morigaon','Jagiroad','Nagaon','Hailakandi','Karimganj','Silchar','Lakhipur','Badarpur','Goalpara','Dhubri',
					'Bilasipara','Kokrajhar','Bongaigaon','Tinsukia','Dibrugarh','Jorhat','Sivasagar','Golaghat','Diphu','Haflong','North Lakhimpur','Dhemaji','Majuli','Chirang','Baksa',
					'Barama','Bijni','Guwahati Rural','Dispur','Khanapara'];

BEGIN

FOR i IN 1..p_count LOOP

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
        'CAND-' || LPAD(FLOOR(random()*99999)::text, 5, '0'),
        'CAND' || LPAD(FLOOR(random()*9999)::text,4,'0'),
        'KP' || LPAD(FLOOR(random()*9999999999)::text,10,'0'),
        FLOOR(random()*2)+1,
        first_names[FLOOR(random()*array_length(first_names,1))+1],
        last_names[FLOOR(random()*array_length(last_names,1))+1],
        father_first[FLOOR(random()*array_length(father_first,1))+1]
            || ' ' ||
        last_names[FLOOR(random()*array_length(last_names,1))+1],
        'candidate' || FLOOR(random()*99999) || '@test.com',
        '9' || FLOOR(random()*900000000 + 100000000),
        DATE '1985-01-01' + FLOOR(random()*7300)::int, -- ensures DOB < 2006
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
        FLOOR(random()*100)+1,
        FLOOR(random()*9)+1,
        FLOOR(random()*8)+2015,
        FLOOR(random()*999)::text || ', Main Road, City Area',
        FLOOR(random()*200)::text,
        village_names[FLOOR(random()*array_length(village_names,1))+1],
        false,
        1,
        true,
        false,
        true,
        1,
        1,
        NOW(),
        NOW()
    )
    RETURNING id INTO candidate_id;

    -- Random lifecycle stage between 3 and 12
    lifecycle_count := FLOOR(random()*10)+1;

    FOR status_num IN 1..lifecycle_count LOOP

        CASE status_num
		    WHEN 1 THEN status_remark := 'Pre Registered';                                    -- Registered 1
		    WHEN 2 THEN status_remark := 'Register Candidate With Preffred Tranning Sector';  -- Counselling (2)
		    WHEN 3 THEN status_remark := 'Tagged with Training center';                       -- Mobilization (3)
		    WHEN 4 THEN status_remark := 'Re-Counselling';                					  -- Re-Counselling (4)
		    WHEN 5 THEN status_remark := 'Batch Creation';                					  -- Enrollment & Batch Generate (5)
		    WHEN 6 THEN status_remark := 'On Going Training';             					  -- On Going Training (6)
		    WHEN 7 THEN status_remark := 'Assessment';                       				  -- Assessment (7)
		    WHEN 8 THEN status_remark := 'After Training Certificate Issued';                 -- Certificate Issued (8)
		    WHEN 9 THEN status_remark := 'On job training';               					  -- On Job Training (9)
		    WHEN 10 THEN status_remark := 'Placement done';                					  -- Placement Confirmation (10)
		    WHEN 11 THEN status_remark := 'Training complete';               				  -- Training Completion (11)
		    WHEN 12 THEN status_remark := 'Monitoring Period';                				  -- Monitoring Period (12)
		    WHEN 13 THEN status_remark := 'Training Closed';                             	  -- Training Closed (13)
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

        -- ✅ Insert into candidate_training ONLY when status = 5
        IF status_num = 5 THEN

            INSERT INTO candidate_training (
                candidate_id,
                batch_id,
                training_center_id,
                pi_id,
                sector_id,
                skill_id,
                created_on,
                updated_on,
                created_by,
                updated_by,
                status,
                is_active
            )
            VALUES (
                candidate_id,
                FLOOR(random()*10)+1,
                FLOOR(random()*5)+1,
                FLOOR(random()*5)+1,
                FLOOR(random()*5)+1,
                FLOOR(random()*10)+1,
                NOW(),
                NOW(),
                1,
                1,
                FLOOR(random()*2)+1,  -- random 1 or 2
                true
            );

        END IF;

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

END;
$$;

-----------------------------------------------------------------------------------------------------------------------------

--==============================
--- Gp Master Script 
--==============================
INSERT INTO gp_master (
    name,
    code,
    block_id,
    is_active,
    status,
    created_on
)
SELECT DISTINCT
    INITCAP(TRIM(dump.gp_name)) AS name,
    TRIM(dump.gp_code) AS code,
    bm.id AS block_id,
    TRUE AS is_active,
    1 AS status,
    NOW() AS created_on

FROM asrlm_uat.district_block_gp_master_dump dump

JOIN block_master bm
    ON LOWER(TRIM(bm.block_name)) 
       = LOWER(TRIM(dump.block_name))

WHERE dump.gp_name IS NOT NULL
  AND dump.gp_code IS NOT NULL;

--select * from district_block_gp_master_dump;

--------------------------------------------------------------------------------------------------------------------------



-- =========================
-- ADMIN ROLE MASTER DATA
-- =========================
INSERT INTO admin_role_master 
(role_name, role_code, description, is_active, created_at, updated_at, created_by, updated_by)
VALUES
('State Admin', 'STATE_ADMIN', 'Top level state administration role', true, NOW(), NOW(), 1, 1),
('District Officer', 'DISTRICT_OFFICER', 'District level administration role', true, NOW(), NOW(), 1, 1),
('Block Officer', 'BLOCK_OFFICER', 'Block level administration role', true, NOW(), NOW(), 1, 1),
('Cadres', 'CADRES', 'Field level cadres and community workers', true, NOW(), NOW(), 1, 1);


-- ===============================
-- ADMIN DESIGNATION MASTER DATA
-- ===============================

INSERT INTO admin_designation_master
(designation_name, designation_code, role_id, level, description, is_active, created_at, updated_at, created_by, updated_by)

-- ================= STATE LEVEL =================
SELECT 'State Chief Operating Officer', 'STATE_COO', id, 1,
       'Super Admin at State Level', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'STATE_ADMIN'

UNION ALL
SELECT 'State Project Manager', 'STATE_PM', id, 2,
       'Manages state level projects', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'STATE_ADMIN'

UNION ALL
SELECT 'Project Executive', 'STATE_EXEC', id, 3,
       'Executes project operations at state level', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'STATE_ADMIN'

UNION ALL
SELECT 'Officer Assistant', 'STATE_ASSIST', id, 4,
       'Administrative assistant at state level', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'STATE_ADMIN'

UNION ALL
SELECT 'Accountant (State)', 'STATE_ACC', id, 5,
       'State level accountant', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'STATE_ADMIN'

-- ================= DISTRICT LEVEL =================
UNION ALL
SELECT 'Project Manager (District)', 'DIST_PM', id, 1,
       'District project manager', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'DISTRICT_OFFICER'

UNION ALL
SELECT 'District Functional & Expert (DFE)', 'DIST_DFE', id, 2,
       'District Functional Expert and Skill Coordinator', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'DISTRICT_OFFICER'

UNION ALL
SELECT 'Accountant (District)', 'DIST_ACC', id, 3,
       'District accountant', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'DISTRICT_OFFICER'

-- ================= BLOCK LEVEL =================
UNION ALL
SELECT 'Block Coordinator', 'BLOCK_COORD', id, 1,
       'Block level coordinator', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'BLOCK_OFFICER'

UNION ALL
SELECT 'Block Skill Officer', 'BLOCK_SKILL', id, 2,
       'Handles block level skill programs', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'BLOCK_OFFICER'

UNION ALL
SELECT 'Block Staff', 'BLOCK_STAFF', id, 3,
       'General block staff member', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'BLOCK_OFFICER'

-- ================= CADRES =================
UNION ALL
SELECT 'Book Keeper', 'CADRE_BOOK_KEEPER', id, 1,
       'Maintains SHG financial records', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'Jibika Sakhi', 'CADRE_JIBIKA', id, 2,
       'Community livelihood worker', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'Krishi Sakhi', 'CADRE_KRISHI', id, 3,
       'Agriculture support cadre', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'Bank Sakhi', 'CADRE_BANK', id, 4,
       'Banking support cadre', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'Bima Sakhi', 'CADRE_BIMA', id, 5,
       'Insurance support cadre', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'DDSP', 'CADRE_DDSP', id, 6,
       'District Development Support Personnel', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'PRPEP', 'CADRE_PRPEP', id, 7,
       'Program Resource Person', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'Sanjog Sakhi', 'CADRE_SANJOG', id, 8,
       'Community mobilization cadre', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES'

UNION ALL
SELECT 'Internal Mentor', 'CADRE_MENTOR', id, 9,
       'Provides internal mentoring support', true, NOW(), NOW(), 1, 1
FROM admin_role_master WHERE role_code = 'CADRES';



-----------------------------------------------------------------------------------------------------------------------

--CREATE OR REPLACE PROCEDURE register_candidates(p_count INT)
--LANGUAGE plpgsql
--AS $$
--DECLARE
--    i INT;
--    candidate_id BIGINT;
--    lifecycle_count INT;
--    status_num INT;
--    sector_count INT;
--    status_remark TEXT;
--
--    -- Name arrays
--    first_names TEXT[] := ARRAY['Amit','Rahul','Priya','Sneha','Kunal','Riya','Arjun','Neha','Vikash','Pooja'];
--    last_names  TEXT[] := ARRAY['Das','Sharma','Singh','Roy','Bora','Deka','Ali','Khan','Paul','Gupta'];
--    father_first TEXT[] := ARRAY['Ravi','Suresh','Kushal','Mahesh','Ramesh','Dilip','Anil','Manoj'];
--    village_names TEXT[] := ARRAY['Agarpara','Gobindanagar','Borkhola','Sonapur','Barpeta Road','Rangia','Hajo','Boko','Nalbari','Tamulpur','Pathsala','Goreswar','Baihata','Chaygaon','Sarthebari'];
--BEGIN
--FOR i IN 1..10 LOOP
--
--    INSERT INTO candidates (
--        candidate_code,
--        candidate_sys_code,
--        kaushal_panjee_id,
--        candidate_type,
--        first_name,
--        last_name,
--        father_name,
--        email,
--        mobile_no,
--        dob,
--        gender,
--        category,
--        minority,
--        pwd,
--        religion,
--        pincode,
--        aadhar,
--        bank_account,
--        state_id,
--        district_id,
--        block_id,
--        gp_id,
--        qualification_id,
--        passout_year,
--        permanent_address,
--        house_no,
--        village,
--        interest_freelancer,
--        status,
--        is_verified,
--        is_show_details,
--        is_active,
--        created_by,
--        updated_by,
--        created_on,
--        updated_on
--    )
--    VALUES (
--        'CAND-' || LPAD(FLOOR(random()*99999)::text, 5, '0'),  -- candidate_code
--        'CAND' || LPAD(i::text,4,'0'),            -- candidate_sys_code
--        'KP' || FLOOR(random()*9999999999),       -- kaushal_panjee_id
--        FLOOR(random()*2)+1,                      -- candidate_type (1 or 2)
--        first_names[FLOOR(random()*array_length(first_names,1))+1],
--        last_names[FLOOR(random()*array_length(last_names,1))+1],
--        father_first[FLOOR(random()*array_length(father_first,1))+1]
--            || ' ' ||
--        last_names[FLOOR(random()*array_length(last_names,1))+1],
--        'candidate' || i || '@test.com',
--        '9' || FLOOR(random()*900000000 + 100000000),
--        DATE '1990-01-01' + FLOOR(random() * 5844)::int,
--        FLOOR(random()*2)+1,
--        FLOOR(random()*5)+1,
--        FLOOR(random()*2),
--        FLOOR(random()*2),
--        FLOOR(random()*5)+1,
--        FLOOR(random()*999999)::int,
--        FLOOR(random()*999999999999)::text,
--        FLOOR(random()*9999999999)::text,
--        1568,
--        28,
--        59,
--        FLOOR(random()*100)+1,                    -- gp_id random
--        FLOOR(random()*9)+1,                      -- qualification_id 1–9
--        FLOOR(random()*8)+2015,
--        FLOOR(random()*999)::text || ', Main Road, City Area',   -- permanent_address
--        FLOOR(random()*200)::text,                -- house_no
--        village_names[FLOOR(random()*array_length(village_names,1))+1],        -- village random
--        false,                                    -- interest_freelancer
--        1,
--        true,
--        false,                                    -- is_show_details
--        true,
--        1,
--        1,
--        NOW(),
--        NOW()
--    )
--    RETURNING id INTO candidate_id;
--
--    -- Random lifecycle stage between 3 and 12
--    lifecycle_count := FLOOR(random()*10)+3;
--
--    FOR status_num IN 1..lifecycle_count LOOP
--
--        CASE status_num
--            WHEN 1 THEN status_remark := 'Pre Registered';
--            WHEN 2 THEN status_remark := 'Register Candidate With Preferred Training Sector';
--            WHEN 3 THEN status_remark := 'Tagged with Training Center';
--            WHEN 4 THEN status_remark := 'Batch Creation';
--            WHEN 5 THEN status_remark := 'Assessment';
--            WHEN 6 THEN status_remark := 'After Training Certificate Issued';
--            WHEN 7 THEN status_remark := 'On Job Training';
--            WHEN 8 THEN status_remark := 'Placement Done';
--            WHEN 9 THEN status_remark := 'Training Complete';
--            WHEN 10 THEN status_remark := 'Gig Worker Conversion';
--            WHEN 11 THEN status_remark := 'Monitoring Period';
--            WHEN 12 THEN status_remark := 'Training Closed';
--            ELSE status_remark := 'Status Updated';
--        END CASE;
--
--        INSERT INTO candidate_lifecycle_status (
--            candidate_id,
--            candidate_lifecycle_status,
--            assigned_to,
--            assigned_by,
--            remarks,
--            created_by,
--            updated_by,
--            is_active,
--            created_on,
--            updated_on
--        )
--        VALUES (
--            candidate_id,
--            status_num,
--            FLOOR(random()*5)+1,
--            1,
--            status_remark,
--            1,
--            1,
--            true,
--            NOW() - (interval '1 day' * (lifecycle_count - status_num)),
--            NOW()
--        );
--
--    END LOOP;
--
--    -- Preferred sectors
--    sector_count := FLOOR(random()*3)+1;
--
--    FOR status_num IN 1..sector_count LOOP
--        INSERT INTO trainee_prefer_sectors (
--            candidate_id,
--            sector_id,
--            created_by,
--            updated_by,
--            created_on,
--            updated_on
--        )
--        VALUES (
--            candidate_id,
--            FLOOR(random()*5)+1,
--            1,
--            1,
--            NOW(),
--            NOW()
--        );
--    END LOOP;
--END LOOP;
--END $$;
