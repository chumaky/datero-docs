---
description: Datero Releases.
---

# Releases
Datero data platform consists of two major components: _Datero Engine_ and _Datero_ itself.

_Datero Engine_ is the core of the platform.
It's just a Postgres database image with a set of installed third party FDW extensions.
Because of that, its releases are kept in sync with the official Postgres [releases :octicons-tab-external-16:](https://www.postgresql.org/docs/current/release.html){: target="_blank" rel="noopener noreferrer" }.

_Datero_ is a web application that uses Datero Engine through the backend REST API.
It's released much more frequently than Datero Engine and follows the [SemVer :octicons-tab-external-16:](https://semver.org/){: target="_blank" rel="noopener noreferrer" } standard.

For each Datero release, there is a corresponding docker image tag created. 
To avoid flooding the Docker Hub with tags, only the latest and the last three releases are kept.
This is because UI changes are quite frequent, and most users are interested in the latest version only.


## Datero
### latest
Last updated: 2024-05-04  
Docker image: [chumaky/datero:latest :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero/tags?page=1&name=latest){: target="_blank" rel="noopener noreferrer" }

Changes:

- adding Redis connector  
    - it's possible now to connect to Redis databases and use them as data sources
- adding DuckDB connector  
    - DuckDB database opens doors to a whole new set of use cases. 
      It's possible now to use it as a proxy for a JSON, Excel, Parquet, or Iceberg files.
- switching to the FDW [specification :octicons-tab-external-16:](https://github.com/chumaky/postgres-fdw-spec){: target="_blank" rel="noopener noreferrer" } in default config.  
    - Leveraging the FDW specification allows more flexible and powerful configuration.
- adding servers initialization on startup from config file.
    - It's possible now to define data sources (servers) in a config file and have them automatically created on startup.


### 1.1.0
Release date: 2024-03-05    
Docker image: [chumaky/datero:1.1.0 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero/tags?page=1&name=1.1.0){: target="_blank" rel="noopener noreferrer" }

Latest release built on top of the Datero Engine 16.2.
Changes include bug fixes and minor improvements.


### 1.0.3
Release date: 2024-03-05  
Docker image: [chumaky/datero:1.0.3 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero/tags?page=1&name=1.0.3){: target="_blank" rel="noopener noreferrer" }

Latest release built on top of the Datero Engine 15.2.
Changes include bug fixes and minor improvements.

### 1.0.0
Release date: N/A  

Initial version. Was built on top of the Datero Engine 14.4.
Wasn't publicly released.


## Datero Engine
Latest Datero Engine release with the `latest` tag is identical to the `16.6` tag.

### 16.6
Release date: 2024-12-06  
Docker image: [chumaky/datero_engine:16.6 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero_engine/tags?page=1&name=16.6){: target="_blank" rel="noopener noreferrer" }

Included Foreign Data Wrappers:

FDW|Version
-|-
mysql_fdw|2.9.1
oracle_fdw|2.7.0
sqlite_fdw|2.4.0
mongo_fdw|5.5.1
tds_fdw|2.0.4
redis_fdw|16.6.0 (REL_16_STABLE branch)
duckdb_fdw|1.1.2
postgres_fdw|16.6.0 (built-in)
file_fdw|16.6.0 (built-in)


### 16.3
Release date: 2024-07-12  
Docker image: [chumaky/datero_engine:16.3 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero_engine/tags?page=1&name=16.3){: target="_blank" rel="noopener noreferrer" }

Features upgrade for the `duckdb_fdw` connector to the stable `1.0.0` DuckDB release.

Included Foreign Data Wrappers:

FDW|Version
-|-
mysql_fdw|2.9.1
oracle_fdw|2.6.0
sqlite_fdw|2.4.0
mongo_fdw|5.5.1
tds_fdw|2.0.3 (master branch)
redis_fdw|16.3.0 (REL_16_STABLE branch)
duckdb_fdw|1.0.0
postgres_fdw|16.3.0 (built-in)
file_fdw|16.3.0 (built-in)


### 16.2
Release date: 2024-03-01  
Docker image: [chumaky/datero_engine:16.2 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero_engine/tags?page=1&name=16.2){: target="_blank" rel="noopener noreferrer" }

Included Foreign Data Wrappers:

FDW|Version
-|-
mysql_fdw|2.9.1
oracle_fdw|2.6.0
sqlite_fdw|2.4.0
mongo_fdw|5.5.1
tds_fdw|2.0.3 (master branch)
redis_fdw|16.2.0 (REL_16_STABLE branch)
duckdb_fdw|2.1.1 (ahuarte47:main_9x-10x-support branch)
postgres_fdw|16.2.0 (built-in)
file_fdw|16.2.0 (built-in)


### 15.2
Release date: 2023-04-15  
Docker image: [chumaky/datero_engine:15.2 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero_engine/tags?page=1&name=15.2){: target="_blank" rel="noopener noreferrer" }

Included Foreign Data Wrappers:

FDW|Version
-|-
MySQL|2.9.0
Oracle|2.5.0
SQLite|2.3.0
Mongo|5.5.0
TDS|2.0.3
Postgres|built-in
Flat Files|built-in


### 14.4
Release date: 2023-04-15  
Docker image: [chumaky/datero_engine:14.4 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero_engine/tags?page=1&name=14.4){: target="_blank" rel="noopener noreferrer" }

Included Foreign Data Wrappers:

FDW|Version
-|-
MySQL|2.8.0
Oracle|2.4.0
SQLite|2.1.1
Mongo|5.4.0
TDS|2.0.2
Postgres|built-in
Flat Files|built-in

