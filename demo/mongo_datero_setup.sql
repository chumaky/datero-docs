-- create foreign tables. mongo_fdw doesn't support IMPORT FOREIGN SCHEMA
DROP SCHEMA IF EXISTS mongo CASCADE;
CREATE SCHEMA IF NOT EXISTS mongo;

CREATE FOREIGN TABLE mongo.orders
( _id       name
, id        int
, user_id   int
, amount    int
) SERVER mongo;