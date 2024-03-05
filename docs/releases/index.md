---
description: Datero Releases.
---

# Releases
There are two major components exist: _Datero Engine_ and _Datero_ itself.

_Datero Engine_ is the core of the Datero data platform.
It's just a Postgres database image with a set of installed third party FDW extensions.
Because of that, its releases are kept in sync with the official Postgres releases.

_Datero_ is a web application that uses Datero Engine through the backend REST API.
It's released much more frequently than Datero Engine and follow the [SemVer](https://semver.org/) standard.


## Datero
### 1.1.0
Release date: 05-03-2024

Latest release of Datero built on top of the Datero Engine 16.2.
Changes include bug fixes and minor improvements.


### 1.0.3
Release date: 05-03-2024

Latest release of Datero built on top of the Datero Engine 15.2.
Changes include bug fixes and minor improvements.

### 1.0.0
Release date: N/A

Initial version of Datero. Was built on top of the Datero Engine 14.4.
Wasn't publicly released.


## Datero Engine

### 16.2
Release date: 01-03-2024

Datero|FDW|Version
-|-|-
16.2|MySQL|2.9.1
16.2|Oracle|2.6.0
16.2|SQLite|2.4.0
16.2|Mongo|5.5.1
16.2|TDS|master branch (2.0.3)
16.2|Postgres|built-in
16.2|Flat Files|built-in


### 15.2
Release date: 15-04-2023

Datero|FDW|Version
-|-|-
15.2|MySQL|2.9.0
15.2|Oracle|2.5.0
15.2|SQLite|2.3.0
15.2|Mongo|5.5.0
15.2|TDS|2.0.3
15.2|Postgres|built-in
15.2|Flat Files|built-in


### 14.4
Release date: 15-04-2023

Datero|FDW|Version
-|-|-
14.4|MySQL|2.8.0
14.4|Oracle|2.4.0
14.4|SQLite|2.1.1
14.4|Mongo|5.4.0
14.4|TDS|2.0.2
14.4|Postgres|built-in
14.4|Flat Files|built-in

