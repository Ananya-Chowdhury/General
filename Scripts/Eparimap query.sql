
-- USER DETAILS --
-- USER DETAILS --
select * from user where USER_LOGIN = "adhikary_mrml@rediffmail.com";
SELECT * FROM user where USER_LOGIN in ("ilmcad.07-wb@gov.in","ilmcad.09-wb@gov.in","ilmcad.16-wb@gov.in","ilmcad.33-wb@gov.in");
select * from user where USER_ID in ( 4864,5028);
select * from user where user_id = 2226;
select * from user where USER_LOGIN = "ilmcad.62-wb@gov.in";
select * from user where is_eodb = 0;
select * from user_info_private where USER_ID in (1187); -- (select user_id from user where is_eodb = 1);
-- update user_info_private set is_eodb = 1 where USER_ID in (select user_id from user where is_eodb = 1);

-- SET --
select * from user where user_id = 1187;
select * from departmental_user where HRMS_CODE = 2014002598; -- where user_id = 859;
select * from user_info_dept where USER_ID = 1187;


select * from user where USER_LOGIN in ("ilmcad.62-wb@gov.in");
select * from user_info_dept where USER_ID in (1187);
select * from departmental_user where DEPT_USER_ID in (1187);

-- For Signature --
select * from signature where Sign_id = 121;
select * from signature order by sign_id desc limit 5; -- where SIGN_ID = 1001;

-- DEPARTMENTAL USER
select * from departmental_user;
select * from departmental_user where USER_ID in (2272);
select * from departmental_user where DEPT_USER_ID in (1187);
select * from departmental_user where DEPT_USER_ID = 2008004031;
select * from departmental_user where FIRST_NAME in ("SK ROFIKUL","AJANTA","DIPTIMOY");
select * from departmental_user where HRMS_CODE in ("2023001855","2018009466");
select * from departmental_user where EMAIL = "ilmcad.80-wb@gov.in";
select * from departmental_user where PUNCH_NUMBER LIKE "%239%";
select * from departmental_user where FIRST_NAME in ("NABIN");

select * from user_info_dept;
select * from user_info_dept where USER_ID in (2272);
select * from user_info_dept where DEPT_USER_ID = 63;
select * from user_info_dept where DEPT_USER_ID = 48;
SELECT * FROM eparimap.user_info_dept where EMAIL = "ilmcad.07-wb@gov.in";

-- Select @@session.sql_mode;
-- SELECT @@sql_mode;
-- SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

select * from user where USER_ID in (5676,5671);
select * from user;

select * from transaction_details;

select * from payment_request_details;
select * from payment_response_details;

select * from user where USER_LOGIN = "arnab@mfcpl.com";
SELECT * FROM user where USER_LOGIN in ("ilmcad.07-wb@gov.in","ilmcad.09-wb@gov.in","ilmcad.16-wb@gov.in","ilmcad.33-wb@gov.in");
select * from user where USER_ID in (2626,484,488,490,3121,914);

-- USER INFO DEPT--
select * from user_info_dept;
select * from user_info_dept where USER_ID in (2272);
select * from user_info_dept where DEPT_USER_ID = 63;
select * from user_info_dept where DEPT_USER_ID = 48;
SELECT * FROM eparimap.user_info_dept where EMAIL = "ilmcad.80-wb@gov.in";

SELECT * FROM eparimap.user where status = 300;
SELECT * FROM eparimap.user;
select * from user where FIRST_NAME = "SOUMYA";

SELECT * FROM eparimap.user where USER_LOGIN = "ilmcad.80-wb@gov.in";
SELECT * FROM eparimap.user where USER_ID in (1187);
SELECT * FROM eparimap.user where USER_LOGIN = "office.suryaenterprise@gmail.com";
select now();

-- SIGNATURE IDDENTIFY -- 
select * from signature where SIGN_ID = 121;
select * from departmental_user where DEPT_USER_ID = 121; -- respective of ASSIGNED_BY_SIGN

select * from application_for_vc where email = "nabinkhanra2016@gmail.com";

-- PASSWORD -- Password@1
-- >> KovxF7GQAdp5+A0Q+d2gMw==
-- SALT
-- >> baaecc5b69ac4f78b11816a6906b9749


-- PASSWORD -- Password@1
-- >> KovxF7GQAdp5+A0Q+d2gMw==
-- SALT
-- >> baaecc5b69ac4f78b11816a6906b9749

-- Select @@session.sql_mode;
-- SELECT @@sql_mode;
-- SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

/*where USER_LOGIN in ("ilmcad.128-wb@gov.in","ilmcad.52-wb@gov.in","ilmcad.02-wb@gov.in","ilmcad.09-wb@gov.in","ilmcad.03-wb@gov.in",
"ilmcad.16-wb@gov.in","ilmcad.121-wb@gov.in","ilmcad.81-wb@gov.in","ilmcad.18-wb@gov.in","ilmcad.82-wb@gov.in","ilmcad.07-wb@gov.in",
"ilmcad.86-wb@gov.in","ilmcad.01-wb@gov.in");*/

-- Password - KovxF7GQAdp5+A0Q+d2gMw==
-- Salt - baaecc5b69ac4f78b11816a6906b9749

-- 2024-05-14 11:20:34

select USER_ID,USER_LOGIN,CREATE_DATE,is_eodb from user where USER_LOGIN in ("rajib.office12@gmail.com","niltechdgp@gmail.com","haldartumpa80@gmail.com","halderdigitalcentre@gmail.com",
"shenterprise4696@gmail.com","msbikalpa24@gmail.com","rmelectronics82@gmail.com","arnab@mfcpl.com","foodproductsmakhanbhog@gmail.com","navinjairamka@gmail.com",
"asthaagrigenetics@gmail.com","anamikakhanna.sgs@gmail.com","gsasphait12@gmail.com","shibrampurskusltd.namkhana@gmail.com","palco.aquadiamond@gmail.com");

-- USER SWAP
-- USER TABLE
-- '5671', 'brunokalikotay86@gmail.com', 'Bruno', '', 'Kalikotay', 'brunokalikotay86@gmail.com', '', '8906256589', '2', 'fgn3gNJ6xQeewmY+VqTdPw==', '5c361cab3ed341d8905bc7a535b0f642', NULL, NULL, NULL, NULL, '0', '2024-05-27 12:54:46', '0', '2024-05-27 12:54:46', '200', '0', '0'
-- '5717', 'foodproductsmakhanbhog@gmail.com', 'PAWAN', 'KUMAR', 'GOYAL', 'foodproductsmakhanbhog@gmail.com', '', '9832338410', '2', 'CN+ujIl0xRWIsPtdIrqInw==', '9918665a00624d20890f2d33fc365e6a', NULL, NULL, NULL, NULL, '0', '2024-06-27 16:06:29', '0', '2024-06-27 16:06:29', '200', '0', '0'
-- USER INFO PRIVATE
-- '5671', 'Bruno', '', 'Kalikotay', NULL, 'Shastri Nagar ITI Road Ward No 41 ', 'Po Sevoke Road Siliguri', '62', 'Sevoke Road', '12', NULL, '7', 'West Bengal', 'India', '734001', 'brunokalikotay86@gmail.com', '8906256589', '', 'N', 'Y', '781418296206', 'BOEPK7979D', '0', '2024-05-27 12:54:46', '5671', '2024-05-27 12:55:31', '200', '0'
-- '5717', 'PAWAN', 'KUMAR', 'GOYAL', NULL, 'SEVOKE ROAD', '', '416', 'SILIGURI', '4', NULL, '4', 'West Bengal', 'India', '734001', 'foodproductsmakhanbhog@gmail.com', '9832338410', '', 'N', 'Y', '', 'AADCM7981L', '0', '2024-06-27 16:06:29', '5717', '2024-06-27 16:11:01', '200', '0'

-- USER PASSWORD CHANGE
-- '5671', 'foodproductsmakhanbhog@gmail.com', 'PAWAN', 'KUMAR', 'GOYAL', 'foodproductsmakhanbhog@gmail.com', '', '9832338410', '2', 'CN+ujIl0xRWIsPtdIrqInw==', '9918665a00624d20890f2d33fc365e6a', NULL, NULL, NULL, NULL, '0', '2024-06-27 16:06:29', '0', '2024-06-27 16:06:29', '200', '1', '0'
-- '5676', 'rmelectronics82@gmail.com', 'Rousan ', '', 'Molla', 'rmelectronics82@gmail.com', '', '9732435178', '2', 'LhwBVPjO8b42m0P5QX4HYQ==', 'b1844d7cae1a4f5a974b454966557758', NULL, NULL, NULL, NULL, '0', '2024-05-31 18:20:49', '0', '2024-05-31 18:20:49', '200', '0', '0'

-- 5671 New Password > 37!@H!mU --> Salt :- f610b64c7aa34d258426e67aaba91217 | Password :- iGs+s0iiJnPkiKxnMeLsfg==
-- 5676 New Password > Ky66yX#@ --> Salt :- f10a4a3ee7be481f9f06f24fab1384a2 | Password :- LtJQMwUxef2Yr88y+M2X1Q==


select * from application where APPLICATION_NUMBER = "WB/21/0057/2/00127";
select * from user where user_id = 6084;
call eparimap.get_application_status(18166);
