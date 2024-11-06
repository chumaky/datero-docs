---
description: Configuration of the Datero data platform.
---

# Configuration
Datero is a containerized application that is shipped as a single Docker image.
When you run it, you can provide configuration parameters to customize its behavior.
This document describes the configuration options available for Datero.


## Environment variables
Datero database engine is based on the official PostgreSQL database.
More specifically, it is actually a PostgreSQL database with added set of FDW extensions.
It supports all the environment variables that are supported by the PostgreSQL docker [image :octicons-tab-external-16:](https://hub.docker.com/_/postgres){: target="_blank" rel="noopener noreferrer" }.

While all the environment variables supported by the PostgreSQL image are available and will act as expected, only a few of them are relevant to Datero.

- `POSTGRES_USER`
    - This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password.
      This variable will create the specified user with superuser power and a _database with the same name_.
      If it is not specified, then the default user of `postgres` will be used.
- `POSTGRES_PASSWORD` - **required**
    - The only _mandatory_ variable.
      It must not be empty or undefined.
      This environment variable sets the superuser password for PostgreSQL.
      The default superuser name is defined by the `POSTGRES_USER` environment variable listed above.
- `POSTGRES_DB`
    - This optional environment variable can be used to define a different name
      for the default database that is created when the image is first started.
      If it is not specified, then the value of `POSTGRES_USER` will be used.

In most cases, if you want to have standard "out of the box" behavior, you will only need to set the `POSTGRES_PASSWORD` environment variable.
That will provide you with a PostgreSQL instance with the default superuser name of `postgres` and the default database name of `postgres`.


## Folders structure
Datero layout is spread over two directories: `/home` and `/data`.
The `/home` directory contains the application code and instance runtime data.
The `/data` directory is used for file-based data sources.

!!! warning "Datero root directory"
    Datero root directory is located in the `/home` directory.
    **Do not** mount anything to it.
    By doing so, you might overwrite its content and the application will not work as expected.

    The only exception is the `/home/instance/config.yaml` file, which is application configuration file.
    You can mount your own configuration file to it.
    In such case, it will be used instead of the default one.

O/S layout:

```sh
/home               # app code. DO NOT mount anything to this directory.
    /instance       # app runtime data. DO NOT mount anything to this directory.
        config.yaml # app configuration file, can be mounted from the host
/data               # directory for file-based data, can be mounted from the host
```

## Application launch
The Datero instance creation is described in details in the [installation](../installation.md#running-the-container) guide.
A minimum and full formats of the `docker run` command with some explanations are shown below:

=== "min example"
    ```sh linenums="1"
    docker run -d --name datero \
        -p 80:80 -p 5432:5432 \
        -e POSTGRES_PASSWORD=postgres \
        chumaky/datero
    ```
=== "full example"
    ```sh linenums="1"
    --8<-- "include/docker_run.md"
    ```
=== "ports mapping"
    ```sh linenums="1" hl_lines="2"
    --8<-- "include/docker_run.md"
    ```
=== "superuser password"
    ```sh linenums="1" hl_lines="3"
    --8<-- "include/docker_run.md"
    ```
=== "data mount"
    ```sh linenums="1" hl_lines="4"
    --8<-- "include/docker_run.md"
    ```
=== "config mount"
    ```sh linenums="1" hl_lines="5"
    --8<-- "include/docker_run.md"
    ```


## Configuration file
You can provide a custom configuration file to the Datero instance.
It allows you to specify database connection parameters, data sources, and other settings.
By using it you could automate datasources creation and avoid manual configuration.

The default configuration file is located at the `/home/instance/config.yaml`.
To override it, you can mount your own configuration file to that path.

It supports two main sections: `postgres` and `servers`.
Both are optional and can be omitted if you are satisfied with the default settings.
```yaml
# Datero configuration file
postgres:
servers:
```

### Postgres section
The `postgres` section is used to define the connection parameters to the underlying PostgreSQL database.
They are used by the Datero backend API.

It consists of the following parameters:
```yaml
postgres:
  hostname:
  port:
  database:
  username:
  password:
```

Default values are:
```yaml
postgres:
  hostname: localhost
  port: 5432
  database: postgres
  username: postgres
  password: postgres
```

What this mean is that if you do not provide a custom configuration file,
the Datero backend will connect to the PostgreSQL database running on the same host,
using the default superuser name and password.

For all inclusive Datero image the backend API and the database are running in the same container.
Postgres default security settings is set to `trust` mode for all connections initiated from `localhost`.
This means, that in case of all inclusive Datero image the backend API can connect to the database without providing a password.
And `password` field in the `postgres` section of the configuration file is not actually used.

But all the other params are used and have an impact.
If you specified some non-default values in environment variables during container creation,
like `POSTGRES_USER` or `POSTGRES_DB`, AND you use configuration file with `postgres` section specified,
then you must provide the same values in the corresponding attributes.


### Servers section
The `servers` section is used to define the data sources that Datero will use.
It's a list where each entry defines a single data source.
It has user defined name and a set of parameters that are specific to the data source type.
Datasource type is defined by the underlying FDW extension.

Server definition starts with its name as an entry key.
One mandatory parameter is `fdw_name` that defines the FDW extension to be used.
The `description` parameter is optional and can be used to provide a human-readable description of the data source.
```yaml
servers:
  server_name:
    description:
    fdw_name:
```

For the `fdw_name` parameter value you can use one of the following values:

- mysql_fdw
- postgres_fdw
- mongo_fdw
- oracle_fdw
- tds_fdw
- sqlite_fdw
- duckdb_fdw
- file_fdw
- redis_fdw

This is the list of the currently supported FDW extensions in Datero.
Every extension has its own set of parameters.
But all of them adhere to the [Postgres FDW specification](https://github.com/chumaky/postgres-fdw-spec/blob/master/README.md).
It's YAML based and has a common structure for all FDWs.

In short, it consists of the following sections:

- `foreign_server`
- `user_mapping`
- `import_foreign_schema`
- `create_foreign_table`
- `foreign_table_column`

Only `foreign_server` section is required.
In a sense that you must create a foreign server to be able to use the FDW.
All other sections are optional and subject to the specific FDW implementation.
Each section can have zero, one or set of options that can be used to configure the FDW.


Below is a full specification for every FDW extension supported by Datero. You can use it as a reference when creating your own configuration file.

??? abstract "FDW specification"
    === "mysql_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/mysql_fdw/2.9.1.yaml"
        ```
    === "postgres_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/postgres_fdw/16.2.0.yaml"
        ```
    === "mongo_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/mongo_fdw/5.5.1.yaml"
        ```
    === "oracle_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/oracle_fdw/2.6.0.yaml"
        ```
    === "tds_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/tds_fdw/master_2.0.3.yaml"
        ```
    === "sqlite_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/sqlite_fdw/2.4.0.yaml"
        ```
    === "duckdb_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/duckdb_fdw/2.1.1.yaml"
        ```
    === "file_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/file_fdw/16.2.0.yaml"
        ```
    === "redis_fdw"
        ```yaml
        --8<-- "https://raw.githubusercontent.com/chumaky/postgres-fdw-spec/refs/heads/master/redis_fdw/16.2.0.yaml"
        ```

### Example
Here is an example of a configuration file that defines a Postgres, Mysql and DuckDB datasources.

??? info "Example configuration file"
    ```yaml
    postgres:
      hostname: localhost
      port: 5432
      database: postgres
      username: postgres
      password: postgres
    
    servers:
      factory-db:
        description: Factory database
        fdw_name: postgres_fdw
        foreign_server:
          host: factory.mycompany.com
          port: 5432
          dbname: factory
          sslmode: require
          sslcertmode: disable
        user_mapping:
          user: postgres
          password: postgres
    
       financial_reporting:
         description: Financial regulatory reporting
         fdw_name: mysql_fdw
         foreign_server:
           host: reporting.mycompany.com
           port: 3306
         user_mapping:
           username: some_user
           password: password
    
      orders_data:
        description: Orders data dump from e-commerse
        fdw_name: duckdb_fdw
        foreign_server:
          database: /home/data/json_files.duckdb
    ```

Datero backend will connect to the local Postgres database with mentioned settings in `postgres` section.
Postgres datasource `factory-db` is used to connect to the factory database.
In the `financial_reporting` datasource, the `mysql_fdw` extension is used to connect to the financial regulatory reporting database.
The `orders_data` datasource uses the `duckdb_fdw` extension to connect to the orders data dump from e-commerce stored in json files on a local storage (must be mounted into the Datero container as volume).
