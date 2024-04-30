USE ROLE SYSADMIN;

--CREATE LOCAL ADMIN USER
CREATE OR REPLACE USER ADMIN_USER
LOGIN_NAME = 'ADMIN' PASSWORD = 'ADMIN'
DEFAULT_ROLE = LOCAL_ADMIN_ROLE
DEFAULT_WAREHOUSE = POC_1_WH;

USE ROLE SECURITYADMIN;

--GRANT ROLE TO LOCAL_ADMIN
GRANT ROLE LOCAL_ADMIN_ROLE TO USER ADMIN_USER;