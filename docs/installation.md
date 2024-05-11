---
description: Datero data platform installation guide.
---

`Datero` is available in containerized format.
There are two ways to run it:

- Single all-inclusive container.
- Multiple containers to run with `docker-compose`. It includes the following services:
    - Datero database engine
    - API
    - Web application

## Single container
All inclusive image encapsulates within itself all three components listed above.

Each service writes its logs to the standard output, so standard `docker logs` command will contain a merged view of them.

Image is available on [Docker Hub :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero){: target="_blank" rel="noopener noreferrer" }.

### Getting the image
To get the image, run the following command:

??? note "podman users"
    Some linux distributions use `podman` instead of `docker`.
    In addition, in case your are on SE Linux system like `Fedora`, usage of ports less than 1024 requries superuser privileges.
    To get one-to-one experience, instead of `docker` command you will need to run `sudo podman`.
    This will execute command in a rootfull mode, allowing to use ports less than 1024.

    Another thing is that `podman` considers mutliple container registries by default,
    so you will need to specify the registry explicitly when you do the `pull`.
    If you don't specify it explicitly, `podman` will ask you to select the registry from the list.

    In all other aspects, `podman` is a drop-in replacement for `docker`.
    So most probably, `docker` => `sudo podman` is the only change that you will need to make commands below work for you.


=== "docker"
    ``` sh
    docker pull chumaky/datero
    ```
=== "podman"
    ``` sh
    sudo podman pull docker.io/chumaky/datero
    ```

All-inclusive container contains all three services, so it exposes a couple of ports.
One for the web application and one for the database.

You could run `datero` completely in CLI mode, but it's not handy.
As a minimum, you will probably want to have an access to the web UI.
Internally, the web application is running on standard HTTP port `80`.
If you want to use the database, you will also need to map internal `5432` port for the database.

API is accessible through the web application under the `/api` path, so you don't need to expose it separately.
Alternatively, you could use [datero :octicons-tab-external-16:](https://pypi.org/project/datero/){: target="_blank" rel="noopener noreferrer" } python package to access the API directly.


### Running the container
The only mandator parameter to specify during container run is `POSTGRES_PASSWORD`.
It's dictated by the underlying official image of `postgres` database.
But you will probably want to have an access also to the web application and database.
Hence we also exposure ports `80` and `5432`.
Flag `-d` will run the container in the background.
We name the container `datero` to be able to refer to it later.

``` sh
docker run -d --name datero \
    -p 80:80 -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    chumaky/datero
```

Now you can access the web application on [http://localhost :octicons-tab-external-16:](http://localhost){: target="_blank" rel="noopener noreferrer" } and the database on `localhost:5432`.

By default, `datero` contains compiled and installed connectors for the following databases:

![Connectors](./images/connectors.jpg){ loading=lazy; align=right }

- MySQL
- PostgreSQL
- MongoDB
- Oracle
- SQL Server
- SQLite
- File access
- MariaDB (not tested yet, but should work)
- Sybase (not tested yet, but should work)

You could check them by executing the following query in the SQL Editor that is available at [http://localhost/editor :octicons-tab-external-16:](http://localhost/editor){: target="_blank" rel="noopener noreferrer" }:
``` sql
select * from pg_available_extensions where name like '%fdw%' order by name;
```

As mentioned earlier, `Datero` is a fully functional `Postgres` database. To confirm this, just execute the following query:
``` sql
select version();
```

Alternatively, you could leverage the `psql` utility to connect to the database:
``` sh
$ docker exec -it datero psql postgres postgres
```

You will log in as a `postgres` user and connect to the `postgres` database.
```
psql (15.2 (Debian 15.2-1.pgdg110+1))
Type "help" for help.

postgres=# select version();
                                                          version
-----------------------------------------------------------------------------------------------------------------------------
PostgreSQL 15.2 (Debian 15.2-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
(1 row)
```

#### Database Configuration
Official postgres image specifies a few environment variables that could be used to configure the superuser account and default database.
As stated in the [official documentation :octicons-tab-external-16:](https://hub.docker.com/_/postgres){: target="_blank" rel="noopener noreferrer" }:

- `POSTGRES_USER`
    - This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password.
      This variable will create the specified user with superuser power and a database with the same name.
      If it is not specified, then the default user of `postgres` will be used.
- `POSTGRES_PASSWORD`
    - The only _required_ variable.
      It must not be empty or undefined.
      This environment variable sets the superuser password for PostgreSQL.
      The default superuser name is defined by the `POSTGRES_USER` environment variable listed above.
- `POSTGRES_DB`
    - This optional environment variable can be used to define a different name
      for the default database that is created when the image is first started.
      If it is not specified, then the value of `POSTGRES_USER` will be used.


We started our image with specified only mandatory `POSTGRES_PASSWORD` environment variable.
This means that the default superuser name is `postgres` and the default database name is also `postgres`.

Commands below show that we have single `postgres` database created and single `postgres` user with superuser privileges.
The output produced is the same as what you would receive if you ran a container using the official postgres image.
So, apart of added value of `Datero` functionality, it's also a fully functional postgres database.

```
postgres=# \l
                                                List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    | ICU Locale | Locale Provider |   Access privileges
-----------+----------+----------+------------+------------+------------+-----------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            | =c/postgres          +
           |          |          |            |            |            |                 | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            | =c/postgres          +
           |          |          |            |            |            |                 | postgres=CTc/postgres
(3 rows)

postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
```

#### File based data sources
If you want to leverage functionality of the file based data sources, you will need to mount a volume to the container.
Datero supports two types of file based connectors: `file_fdw` and `sqlite_fdw`.
When using these connectors you will have to specify a path to the file that you want to access.
You can mount a volume to whatever path you want, but it's recommended to use `/data` path within container.

!!! info "Reserved path"
    `/data` path is considered by Datero as a root path for all file based connectors.
    It's not a requirement, but it's a best practice to use it.

``` sh
docker run -d --name datero \
    -p 80:80 -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    -v "$(pwd):/data" \
    chumaky/datero
```

#### Logging
By default, all logs are written to the standard output.
This behavior allows access them with the `docker logs` command.
All cloud services like AWS, GCP, Azure, etc. have a built-in support for this kind of logs.
For example, in AWS if you enable `awslogs` log driver for your ECS task, all logs will be automatically sent to the AWS CloudWatch.

Single container encapsulates all three services: database, API and web application.
So, you will see a merged view of all logs in output stream.

If you want to redirect them to a file, you could slightly modify the command above.
Firstly, you disable the `-d` flag to run the container in the foreground.
Then you redirect the output and error streams to a file.
Finally, you append `&` to emulate the `-d` option back again and run the command in the background.
``` sh
docker run --name datero \
    -p 80:80 -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    -v "$(pwd):/data" \
    chumaky/datero > datero.log 2>&1 &
```


## Multiple containers
This form of deployment adheres to the _service per container_ principle and is better for more advanced use cases.
It consist of the following services:

- Datero database engine
- API
- Web application

Currently, only the database engine is available as a public image.
You could get it from [Docker Hub :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero_engine){: target="_blank" rel="noopener noreferrer" }.

Individual images for API and web application are part of the Datero Enterprise offering and are not available publicly.
Datero free and enterprise options will be available soon in a clouds like AWS, GCP, Azure, etc.