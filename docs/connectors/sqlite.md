---
description: Datero data platform SQLite connector. 
---

# SQLite
This section describes how to connect to SQLite database from Datero.

## Environment
Environment setup for the SQLite connector is different from the other connectors like [MySQL](./mysql.md) or [Postgres](postgres.md).
Main reason is that SQLite is a file-based database. 
It doesn't require any server to run. And hence, it doesn't have any network interface to connect to.

Main requirement for the Datero sqlite connector is to have SQLite database file accessible on the file system.
So, what we need is `sqlite` database file itself.
Having that on hands, we just mount it to the `datero` container as a file in a local folder and connect to it from there.

We couldn't use `datero` container created in the [installation](../installation.md#running-the-container) section, because we created it without any mounts defined.
Let's spin up a new `datero_mount` container but this time specify a mount folder for the `sqlite` database file.
We mount current folder `$(pwd)` to the `/data` folder inside the container.

!!! note
    If you are on Windows, you need to specify absolute path to the current folder.
    For example, `c:/Users/user/some/path` if you are running the command from GitBash.

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

<!--
## SQLite database
Having `mysql` container running, we can connect to it and create some test database.
``` sh
docker exec -it mysql mysql -hlocalhost -uroot -proot
```

``` sql
mysql> create database finance;
Query OK, 1 row affected (0.02 sec)

mysql> use finance;
Database changed

mysql> create table users(id int, name text);
Query OK, 0 rows affected (0.05 sec)

mysql> insert into users values (1, 'John'), (2, 'Mary'), (3, 'Kyle');
Query OK, 3 rows affected (0.02 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> commit;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from users;
+------+------+
| id   | name |
+------+------+
|    1 | John |
|    2 | Mary |
|    3 | Kyle |
+------+------+
3 rows in set (0.00 sec)
```

Now we are ready to connect to the `mysql` database from `datero`.


## Datero connection
Open `Datero` web ui at [http://localhost](http://localhost) and click on the `SQLite` entry in the the `Connectors` navigation section on the left.

Enter `mysql_db` as the `Host` value. 
This is that custom hostname that we specified when were launching `mysql` container in the `dm` network.
This emulates external host connectivity. 

In a real-world case, the situation would be similar.
If you have, for example, SQLite running on `mysql-host.my-company.com` hostname and 
it's resolvable from the machine where `datero` container is running, you can use that hostname instead.

Specify `root` as the `User` value. 
For the password use `root` as well. Because this is a value we set when were launching `mysql` container.

Click `Save` to create the Server logical object.

Connector|Connection Form
:---:|:---:
![Connectors](../images/connectors.jpg){ loading=lazy }|![Create Server](../images/connectors/mysql/create_server.png){ loading=lazy }


## Schema import
After the Server is created, we can import database schema from it.
Connection wizard will switch the tab and open `Import Schema` form.
In the `Remote Schema` drop down select you will be able to pick-up `finance` database, 
that we created earlier in source `mysql` database.

Server Object|Import Schema
:---:|:---:
![Server Object](../images/connectors/mysql/server_entry.png){ loading=lazy }|![Import Schema](../images/connectors/mysql/import_schema.png){ loading=lazy }

For example, we want to import  `finance` database into the `mysql` local schema.
To do that, type `mysql` into the `Local Schema` input field and click `Import Schema` button.

!!! note "Important"
    Schema import doesn't physically copy any data.
    For every source table and view it creates an object of a special type in a local schema.
    This object type is called foreign table.
    It implements data virtualization pattern.

    Querying foreign table will automatically fetch data from the source database.
    If supported by connector, any filtering, sorting, grouping, etc. will be pushed down to the source database.
    This means that only the data that is needed will be fetched.
    
    If you change the schema in the source database, you will need to re-import it in `Datero` to reflect the changes.
    Thus, schema evolution is handled automatically just by re-importing the schema.

If everything is correct, you will see the success notification message.
<figure markdown>
  ![Import schema completed](../images/connectors/mysql/import_schema_completed.png){ loading=lazy }
  <figcaption>Completed Schema Import</figcaption>
</figure>

We are ready now to query our SQLite database from Datero.

## Data Querying
Click on the `Query Editor` icon in the left navigation panel.
You will see `mysql` schema in the `Datero` object tree.
If you expand it, you will see `users` table from original `mysql` database.
Its definition was automatically imported.

To query data just write a query in the editor and press `Ctrl+Enter` or click green `Run` button above.

<figure markdown>
  ![Query Data](../images/connectors/mysql/query_data.png){ loading=lazy }
  <figcaption>Query Data</figcaption>
</figure>

And that's it! You have successfully connected to the SQLite database from Datero and queried the data.

## Summary
Of course, having just a single datasource is not very interesting.
It's non-distinguishable from the direct connection to SQLite via any other tool, like DBeaver.
But the real power of Datero is in its ability to connect to multiple datasources and join data from them.

This is what is not possible via the "direct connection" tools.
Even if they support connecting to multiple datasources, they don't support joining the data from them.
-->