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


## Datero
### 1.1.0
Release date: 05-03-2024  
Docker image: [chumaky/datero:1.1.0 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero/tags?page=1&name=1.1.0){: target="_blank" rel="noopener noreferrer" }

Latest release built on top of the Datero Engine 16.2.
Changes include bug fixes and minor improvements.


### 1.0.3
Release date: 05-03-2024  
Docker image: [chumaky/datero:1.0.3 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero/tags?page=1&name=1.0.3){: target="_blank" rel="noopener noreferrer" }

Latest release built on top of the Datero Engine 15.2.
Changes include bug fixes and minor improvements.

### 1.0.0
Release date: N/A  

Initial version. Was built on top of the Datero Engine 14.4.
Wasn't publicly released.


## Datero Engine

### 16.2
Release date: 01-03-2024  
Docker image: [chumaky/datero_engine:16.2 :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero_engine/tags?page=1&name=16.2){: target="_blank" rel="noopener noreferrer" }

Included Foreign Data Wrappers:

FDW|Version
-|-
MySQL|2.9.1
Oracle|2.6.0
SQLite|2.4.0
Mongo|5.5.1
TDS|master branch (2.0.3)
Postgres|built-in
Flat Files|built-in


### 15.2
Release date: 15-04-2023  
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
Release date: 15-04-2023  
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

