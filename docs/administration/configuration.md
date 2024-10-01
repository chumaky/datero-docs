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
Postgres default security settings for all connections initiated from `localhost` is set to `trust` mode.
This means, that in case of all inclusive Datero image the backend API can connect to the database without providing a password.
And `password` field in the `postgres` section of the configuration file is not actually used.

But all the other params are used and have an impact.
If you specified some non-default values in environment variables during container creation,
like `POSTGRES_USER` or `POSTGRES_DB` AND you use configuration file, 
then you must provide the same values in the configuration file.

