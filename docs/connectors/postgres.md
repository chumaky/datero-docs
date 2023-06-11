---
description: Datero data platform Postgres connector. 
---

# Postgres
This section describes how to connect to Postgres database from Datero.

!!! info "Notice"
    Used approach is identical to the one described in the [MySQL](./mysql.md) section.

## Environment
If not running, let's start `datero` container created in the [installation](../installation.md#running-the-container) section.
``` sh
docker start datero
```

!!! note "Connectivity pattern"
    To emulate external host connectivity, we will use [container 2 container](./index.md#container-to-container) approach.
    We will create `dp` network and connect `datero` container to it.
    Then we will run datasource `postgres` container and connect it to the `dp` network as well.

Now, let's create `dp` network and connect `datero` container to it.
Also make it resolvable under the `datero` hostname.
``` sh
docker network create dp
docker network connect --alias datero dp datero
```

To get Postgres database we can use official [postgres](https://hub.docker.com/_/postgres) docker image.
Let's pull the image first. 
``` sh
docker pull postgres
```
Now run the container, connect it to the `dp` network and make it resolvable under the `postgres_db` hostname.
We also set password for the default `postgres` user to the `postgres` value.
``` sh
docker run -d --name postgres \
    --network dp --network-alias postgres_db \
    -e POSTGRES_PASSWORD=postgres \
    postgres
```
Now we can access `postgres` container from the `datero` container by its hostname `postgres_db`.


## Postgres database
Having `postgres` container running, we can connect to it and create some test data.
``` sh
docker exec -it postgres psql postgres postgres
```

``` sql
postgres=# create schema design;
CREATE SCHEMA
postgres=# create table design.colors(id int, name text);
CREATE TABLE
postgres=# insert into design.colors values (1, 'red'), (2, 'blue'), (3, 'green');
INSERT 0 3

postgres=# select * from design.colors;
 id | name  
----+-------
  1 | red
  2 | blue
  3 | green
(3 rows)
```

Now we are ready to connect to the `postgres` database from `datero`.


## Datero connection
Open `Datero` web ui at [http://localhost](http://localhost) and click on the `Postgres` entry in the the `Connectors` navigation section on the left.

Enter `postgres_db` as the `Host` value. 
This is that custom hostname that we specified when were launching `postgres` container in the `dp` network.
This emulates external host connectivity. 

In a real-world case, the situation would be similar.
If you have, for example, Postgres running on `postgres-host.my-company.com` hostname and 
it's resolvable from the machine where `datero` container is running, you can use that hostname instead.

Specify `postgres` as the `User` value. 
For the password use `postgres` as well. Because this is a value we set when were launching `postgres` container.

Click `Save` to create the Server logical object.

Connector|Connection Form
:---:|:---:
![Connectors](../images/connectors/postgres/connector.png){ loading=lazy }|![Create Server](../images/connectors/postgres/create_server.png){ loading=lazy }


## Schema import
After the Server is created, we can import database schema from it.
Connection wizard will switch the tab and open `Import Schema` form.
In the `Remote Schema` drop down select you will be able to pick-up `design` schema, 
that we created earlier in source `postgres` database.

Server Object|Import Schema
:---:|:---:
![Server Object](../images/connectors/postgres/server_entry.png){ loading=lazy }|![Import Schema](../images/connectors/postgres/import_schema.png){ loading=lazy }

For example, we want to import  `design` schema into the same `design` local schema.
To do that, type `design` into the `Local Schema` input field and click `Import Schema` button.

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
  ![Import schema completed](../images/connectors/postgres/import_schema_completed.png){ loading=lazy }
  <figcaption>Completed Schema Import</figcaption>
</figure>

We are ready now to query our Postgres database from Datero.

## Data Querying
Click on the `Query Editor` icon in the left navigation panel.
You will see `design` schema in the `Datero` object tree.
If you expand it, you will see `colors` table from original `postgres` database.
Its definition was automatically imported.

To query data just write a query in the editor and press `Ctrl+Enter` or click green `Run` button above.

<figure markdown>
  ![Query Data](../images/connectors/postgres/query_data.png){ loading=lazy }
  <figcaption>Query Data</figcaption>
</figure>

And that's it! You have successfully connected to the Postgres database from Datero and queried the data.

## Summary
Of course, having just a single datasource is not very interesting.
It's non-distinguishable from the direct connection to Postgres via any other tool, like DBeaver.
But the real power of Datero is in its ability to connect to multiple datasources and join data from them.

This is what is not possible via the "direct connection" tools.
Even if they support connecting to multiple datasources, they don't support joining the data from them.
