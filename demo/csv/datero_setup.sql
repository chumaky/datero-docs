DROP SCHEMA IF EXISTS csv CASCADE;
CREATE SCHEMA IF NOT EXISTS csv;

CREATE FOREIGN TABLE csv.departments
( id        int
, name      varchar
)
SERVER file_fdw_1
OPTIONS (filename '/data/departments.csv', format 'csv', header 'true')
;
