---
description: Datero data platform DuckDB connector.
---

# DuckDB
This section describes how to connect to DuckDB database from Datero.

Before delving into the implementation details, let's describe shortly what DuckDB is and why connecting to it from Datero is interesting.
It's a relational DBMS that could work in two modes: as an in-memory or a file-based database.
It has a lot of features and [capabilities  :octicons-tab-external-16:](https://duckdb.org/why_duckdb){: target="_blank" rel="noopener noreferrer" }, but one of the most interesting is its superior ability to work with the files.

DuckDB can read/write a variety of file formats like CSV, JSON, Excel, Parquet, Iceberg and plain files.
It can also work with remote files from AWS S3 or Azure Blob Storage.

Paired with Datero capabilities to connect to other datasources like Oracle, Mongo, Redis, etc., DuckDB opens doors to a whole new set of use cases. Such combination brings in a file-based world to the relational database world. And all with the power of old plain SQL!


## Environment
Environment setup for the DuckDB connector is similar to the [SQLite](./sqlite.md).
Main requirement is to have DuckDB database file accessible on the file system.
So, what we need is DuckDB database file itself.
Having that on hands, we just mount it to the `datero` container as a file in a local folder and connect to it from there.

We couldn't use `datero` container created in the [installation](../installation.md#running-the-container) section, because we created it without any mounts defined.
Let's spin up a new `datero_mount` container but this time specify a mount folder for the DuckDB database file.
We mount current folder `$(pwd)` to the `/data` folder inside the container.

??? warning "GitBash on Windows"
    If you are on Windows, you must specify absolute path to the current folder.
    For example, `c:/Users/user/some/path`.
    Or expand current directory with `%cd%` if you are running the command from `cmd`.

    **Do not** run docker commands with folder mounts specified from GitBash.
    Because GitBash is a Linux emulator for Windows, it will translate Windows paths to Linux paths.
    And `docker` will not be able to find the folder.

=== "Linux"
    ``` sh
    # stopping currently running container, if any, to free up ports
    docker stop datero
    # starting new container with current folder mounted to /data folder inside the container
    docker run -d --name datero_mount \
        -p 80:80 -p 5432:5432 \
        -e POSTGRES_PASSWORD=postgres \
        -v "$(pwd):/data" \
        chumaky/datero
    ```

=== "Windows (cmd.exe)"
    ``` sh
    # stopping currently running container, if any, to free up ports
    docker stop datero
    # starting new container with current folder mounted to /data folder inside the container
    docker run -d --name datero_mount ^
        -p 80:80 -p 5432:5432 ^
        -e POSTGRES_PASSWORD=postgres ^
        -v "%cd%:/data" ^
        chumaky/datero
    ```


### DuckDB database file
Now we need to create a DuckDB database file.
To do so, we have to install `duckdb` command line utility.
It's available for all major operating systems.
You can find installation instructions in the [official documentation :octicons-tab-external-16:](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=linux&download_method=direct){: target="_blank" rel="noopener noreferrer" }.

Once installed, make sure it's added to your `PATH`. It must be callable from the command line.
``` sh
duckdb --version
v0.10.2 1601d94f94
```

Now we can create a new database file `calendar.duckdb` and create some test table in it.
``` sh
duckdb calendar.duckdb
```
``` sql
D create table seasons(id int, name text);
D insert into seasons values (1, 'Spring'), (2, 'Summer'), (3, 'Autumn'), (4, 'Winter');
D .headers on
D select * from seasons;
┌───────┬─────────┐
│  id   │  name   │
│ int32 │ varchar │
├───────┼─────────┤
│     1 │ Spring  │
│     2 │ Summer  │
│     3 │ Autumn  │
│     4 │ Winter  │
└───────┴─────────┘
D .quit
```

While this setup is identical to the one described in the corresponding SQLite documentation [section](./sqlite.md#sqlite-database), the main difference is the next.
DuckDB allows not only to create a classic tables but also to work with files directly.
And do this in a _very_ efficient way.


### Source JSON file
Let's extend our example and introduce a JSON file _months.json_ which will contain list of months with the reference to the season.
``` sh
$ cat months.json
[
    {"id": 1, "name": "January", "season_id": 4},
    {"id": 2, "name": "February", "season_id": 4},
    {"id": 3, "name": "March", "season_id": 1},
    {"id": 4, "name": "April", "season_id": 1},
    {"id": 5, "name": "May", "season_id": 1},
    {"id": 6, "name": "June", "season_id": 2},
    {"id": 7, "name": "July", "season_id": 2},
    {"id": 8, "name": "August", "season_id": 2},
    {"id": 9, "name": "September", "season_id": 3},
    {"id": 10, "name": "October", "season_id": 3},
    {"id": 11, "name": "November", "season_id": 3},
    {"id": 12, "name": "December", "season_id": 4}
]
```

To feel the greatness of DuckDB, all you have to do to read the file as a table is to open the database and execute from it the following command.
``` sh
duckdb calendar.duckdb
```
``` sql
D select * from 'months.json';
┌───────┬───────────┬───────────┐
│  id   │   name    │ season_id │
│ int64 │  varchar  │   int64   │
├───────┼───────────┼───────────┤
│     1 │ January   │         4 │
│     2 │ February  │         4 │
│     3 │ March     │         1 │
│     4 │ April     │         1 │
│     5 │ May       │         1 │
│     6 │ June      │         2 │
│     7 │ July      │         2 │
│     8 │ August    │         2 │
│     9 │ September │         3 │
│    10 │ October   │         3 │
│    11 │ November  │         3 │
│    12 │ December  │         4 │
├───────┴───────────┴───────────┤
│ 12 rows             3 columns │
└───────────────────────────────┘
```

Isn't it great? You can work with JSON files as with ordinary tables via SQL!
And there is no data copying involved.
It's a direct access to the file by the database engine.
Data virtualization at its best.

We can go further and create a view on top of a file.
``` sql
D create view months as select * from 'months.json';
D select * from months;
┌───────┬───────────┬───────────┐
│  id   │   name    │ season_id │
│ int64 │  varchar  │   int64   │
├───────┼───────────┼───────────┤
│     1 │ January   │         4 │
│     2 │ February  │         4 │
│     3 │ March     │         1 │
│     4 │ April     │         1 │
│     5 │ May       │         1 │
│     6 │ June      │         2 │
│     7 │ July      │         2 │
│     8 │ August    │         2 │
│     9 │ September │         3 │
│    10 │ October   │         3 │
│    11 │ November  │         3 │
│    12 │ December  │         4 │
├───────┴───────────┴───────────┤
│ 12 rows             3 columns │
└───────────────────────────────┘
```

What this step does is it creates a data virtualization layer for files based data as a metadata object in the database.
In turn, DuckDB connector in Datero will be able to work with this view as an ordinary table already in Datero.
At the end, Datero will read directly from the file without any data copying.
And the chain will be: `Datero -> DuckDB -> file`.

But to make this approach work, we must mount into the `datero` container not only the database file but also the file we want to work with.
Path to the file that we specify in `CREATE VIEW` statement must be either relative to the current working directory or an absolute path.
But in both cases, if mounted to the container, the path will be resolved against the _container's_ file system.

And here comes a tricky part.
We created a view referencing a file in the current working directory.
Because file was present in it, we wrote just `select * from 'months.json'` and it worked.
But when we mount the current directory to the container, the file will be accessible under the `/data` folder.
And the path to the file in the view must be changed to `/data/months.json`.

``` sql
D create or replace view months as select * from '/data/months.json';
```

To make this command work on host, we must have the `months.json` file in the `/data` folder on the host.
Takeaway from this is following. In your file based views you must specify the path under which corresponding source files will be mounted into the container.
And you must put the files on your host into the same path to initially create a view on them.

So, if your current directory is `/home/mydir` and you mount it to the `/data` folder in the container, you must:

- copy `months.json` file located in `/home/mydir` into the `/data` folder on the host.
    - this is to allow you to create a view with  `/data/months.json` file path specified.
- open DuckDB database file and create a view that reads from the `/data/months.json` file.
- mount current `/home/mydir` with the `months.json` file to the `/data` folder in the container.
- from within the container, you will be able to query the view which will be correctly resolving to `/data/months.json` path already within _container's_ filesystem.


### Files mounting privileges
Having done that we should have in a current directory the following files.
``` sh
$ ls -l
total 784
drwxrwxr-x 2 some_user some_user   4096 тра  7 01:31 ./
drwxrwxr-x 3 some_user some_user   4096 тра  6 22:50 ../
-rw-rw-r-- 1 some_user some_user 798720 тра  7 01:31 calendar.duckdb
-rw-rw-r-- 1 some_user some_user    598 тра  7 00:51 months.json
```

Pay attention to the permissions for the files and current `./` working directory.
Files are created by the user `some_user` on the host and the directory is owned by the same `some_user` user.
By default, only read permissions are set for `other` for both files and the directory.

Thanks to the set `other` group read permissions `calendar.duckdb` file will be readable by the `postgres` user from inside the container.
But it looks like DuckDB connector always tries to open the file in the write mode as well.
If you will try to execute just `SELECT` query from the Datero, you will get the following error.
``` sh
ERROR:  failed to open SQLite DB. rc=1 path=/data/calendar.duckdb
```

So, to make it work you must make the `calendar.duckdb` file writable by the `postgres` user inside the container.
From the host perspective it means that you must make the file writable by `other` group.
```sh
$ chmod o+w calendar.duckdb
```

Yet another thing. Under some circumstances, there is also temporary WAL file might be generated alongside the main database file.
It's named as `calendar.duckdb.wal` and is being deleted after the connection is closed.
This file is created by the `postgres` process from inside the container.
To make it work, you must make the directory where the database file is located writable by the `postgres` user inside the container.
So, you have to execute over the mapped directory the following command.
```sh
$ chmod o+w .
```

And at the end, you will have such permissions set.
```sh
$ ll
drwxrwxrwx 2 toleg toleg   4096 тра  9 01:44 ./
-rw-rw-rw- 1 toleg toleg 798720 тра  9 01:41 calendar.duckdb
-rw-rw-r-- 1 toleg toleg    598 тра  7 00:51 months.json
```

Now we have granted `w` permission to `other` group over current `./` directory and `calendar.duckdb` file.
What is interesting, source `months.json` file doesn't need to be writable by `other` group.
It's not a database file and it's not being written by the `postgres` process as part of DuckDB connector operations.

With this setup you will be able to connect to the DuckDB database from Datero container and access the data from the file based view without errors.

??? warning "Write permissions on mounted files & folders"
    Mounted files are accessed by the user under which Postgres database engine is running inside `datero` container.
    By default it's `postgres` user.
    It has `999` value for the UID and GID inside the container in the `/etc/passwd` file.

    In addition, there is an intermediate `*.wal` file might be created alongside the main database file.
    Because it's created on a fly by the `postgres` process, you must make mounted folder where your database file is located writable by the `postgres` user as well.

    To add even more complexity, there is no such thing as `users` and `groups` by themselves in unix based systems.
    It's just a text labels for the numeric values stored in the `/etc/passwd` file.
    In reality, access is checked against the numeric values.
    This means that if you will have different numeric values for the same user on the host and in the container, you will still have a permission denied error.

    So, on your host you have either explicitly grant read/write access to the numeric values of the `postgres` user in the container or make the file readable/writable by _any_ user.
    And do the same for the directory containing the database file.
    This is what is implemented via `other` group in file permissions.

    In such scenario, you don't have to worry about the `postgres` user inside the container.
    And which numeric values it has for the UID and GID.
    Because the file and the directory are accessible by _any_ user on the host, they will also be accessible by _any_ user inside the container.


## Datero connection
Open `Datero` web ui at [http://localhost :octicons-tab-external-16:](http://localhost){: target="_blank" rel="noopener noreferrer" } and click on the `DuckDB` entry in the the `Connectors` navigation section on the left.

Enter any descriptive name in the `Description` field. For example, `DuckDB`.
Enter `/data/calendar.duckdb` as the `Database` value.
The `/data` folder is the folder within the container into which we mounted our current directory.
And `calendar.duckdb` is the database file we created earlier within current directory via `duckdb calendar.duckdb` command.

Click `Save` to create the Server logical object.

Connector|Connection Form
:---:|:---:
![Connectors](../images/connectors/duckdb/connector.png){ loading=lazy }|![Create Server](../images/connectors/duckdb/create_server.png){ loading=lazy }


## Schema import
After the Server is created, we can import database schema from it.
Connection wizard will switch the tab and open `Import Schema` form.
DuckDB doesn't have notations of databases or schemas.
Database file is a single database/schema which is referred to as `public` by DuckDB connector.

In the `Remote Schema` select `public` schema.
For example, we want to import our DuckDB database into the `duckdb` local schema.
To do that, type `duckdb` into the `Local Schema` input field and click `Import Schema` button.
If everything is correct, you will see the success notification message.

Server Object|Import Schema
:---:|:---:
![Server Object](../images/connectors/duckdb/server_entry.png){ loading=lazy }|![Import Schema](../images/connectors/duckdb/import_schema.png){ loading=lazy }


--8<-- "include/schema_import.md"

We are ready now to query our DuckDB database from Datero.

## Data Querying
Click on the `Query Editor` icon in the left navigation panel.
You will see `duckdb` schema in the `Datero` object tree.
If you expand it, you will see `seasons` and `months` tables from the original `DuckDB` database.
Their definitions were automatically imported.

To query data, just write a query in the editor and press `Ctrl+Enter` or click green `Run` button above.

<figure markdown>
  ![Query Data](../images/connectors/duckdb/query_data.png){ loading=lazy }
  <figcaption>Query Data</figcaption>
</figure>

And that's it! You have successfully connected to the DuckDB database from Datero and queried the data.
But you not only queried the data from the database file itself, you also queried data directly from JSON file and joined them!
The `seasons` table is a classic table, but the `months` table is a view on top of the JSON file.

We were able to join data from the classic table in database and the JSON file from the file system.
And all this was done via single SQL query in Datero.
Without any data copying or moving.


## Summary
DuckDB stands aside from the other single database connectors.
Apart from being classical relational database like SQLite, it is capable to work with files directly in a _very_ efficient way.
Because of this, it could be used as a bridge between the file-based world and the relational database world.
In conjunction with Datero and its sets of connectors, it enables a whole new set of use cases.

For example, you can join data from the Oracle database and the JSON file from the AWS S3 bucket.
Or, join data from your Excel files and MongoDB collections.
Or, join data from the Redis cache and the Parquet files from the Azure Blob Storage.

Sounds crazy, isnt' it? :smile:
But it's all possible with DuckDB and Datero!

Currently, setting up corresponding views in DuckDB is a bit tricky.
Datero team is working on the simplification of this process through the UI & YAML config file.
It will be allowed to create views on files directly from the Datero UI.
Or to specify the views in the YAML config file and mount it to the container.
It will be read and executed by the Datero on the container start.
But even now, with a bit of manual work, you can achieve a great results with DuckDB connector in Datero.
