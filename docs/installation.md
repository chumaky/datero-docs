# Installation

`Datero` is available in containerized format.
There are two ways to run it:

- Single all-inclusive container.
- Multiple containers to run with `docker-compose`. It includes the following services:
    - Datero database engine
    - API
    - Web application

## Single container
All inclusive image is a good choice for _try it out_ purposes. It encapsulates within itself all three components listed above.

Each service writes its logs to the standard output, so standard `docker logs` command will contain a merged view of them.

Image is available on [Docker Hub](https://hub.docker.com/r/chumaky/datero).

### Getting the image
To get the image, run the following command:

=== "docker"
    ``` sh
    docker pull chumaky/datero
    ```
=== "podman"
    ``` sh
    podman pull docker.io/chumaky/datero
    ```

All-inclusive container contains all three services, so it exposes a couple of ports.
One for the web application and one for the database.

You could run `datero` completely in CLI mode, but it's not handy.
As a minimum, you probably will want to have an access for the web UI.
Internally, the web application is running on port 80.
If you want to use the database, you will need to map also internal 5432 port for the database.

API is accessible through the web application under the `/api` path, so you don't need to expose it separately.
Alternatively, you could use [datero](https://pypi.org/project/datero/) python package to access the API directly.


### Running the container
The only mandator parameter to specify during container run is `POSTGRES_PASSWORD`.
It's dictated by the official image of `Postgres` database.
But as mentioned above, you probably will want to have an access to the web application and database.
Hence we also exposure ports 8080 and 5432.
Flag `-d` will run the container in the background.
We also name the container `datero` to be able to refer to it later.G

=== "docker"
    ``` sh
    docker run -d --name datero \
        -p 8080:80 -p 5432:5432 \
        -e POSTGRES_PASSWORD=postgres \
        chumaky/datero
    ```

=== "podman"
    ``` sh
    podman run -d --name datero \
        -p 8080:80 -p 5432:5432 \
        -e POSTGRES_PASSWORD=postgres \
        docker.io/chumaky/datero
    ```

Now you can access the web application on [http://localhost:8080](http://localhost:8080) and the database on `localhost:5432`.

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

You could check them by executing the following query in the SQL Editor that is available at [http://localhost:8080/editor](http://localhost:8080/editor):

``` sql
select * from pg_available_extensions where name like '%fdw%' order by name;
```

As mentioned earlier, `datero` is a fully functional `Postgres` database. To confirm this, just execute the following query:

``` sql
select version();
```

Alternatively, you could leverage the `psql` utility to connect to the database:


=== "docker"
    ``` sh
    $ docker exec -it datero psql postgres datero
    ```

=== "podman"
    ``` sh
    $ podman exec -it datero psql postgres datero
    ```

You will log in as a `datero` user and connect to the `postgres` database.
```
psql (15.2 (Debian 15.2-1.pgdg110+1))
Type "help" for help.

postgres=# select version();
                                                          version
-----------------------------------------------------------------------------------------------------------------------------
PostgreSQL 15.2 (Debian 15.2-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
(1 row)
```