---
description: Datero data platform MSSQL connector. 
---

# MSSQL
This section describes how to connect to MSSQL database from Datero.

!!! info "Notice"
    Used approach is identical to the one described in the [MySQL](./mysql.md) section.

## Environment
If not running, let's start `datero` container created in the [installation](../installation.md#running-the-container) section.
``` sh
docker start datero
```

!!! note "Connectivity pattern"
    To emulate external host connectivity, we will use [container 2 container](./index.md#container-to-container) approach.
    We will create `dm` network and connect `datero` container to it.
    Then we will run datasource `mssql` container and connect it to the `dm` network as well.

Now, let's create `dm` network and connect `datero` container to it.
Also make it resolvable under the `datero` hostname.
``` sh
docker network create dm
docker network connect --alias datero dm datero
```

[mssql_registry]: https://mcr.microsoft.com/en-us/product/mssql/server/about

To get MSSQL database we can use official Microsoft [SQL Server][mssql_registry] Ubuntu based image.
One specific note about this image is that it requires at least 2GB of RAM.
This check is done by the entrypoint script and container will fail to start if there is not enough memory.

Let's pull the image first. 
``` sh
docker pull mcr.microsoft.com/mssql/server:2022-latest
```

Now run the container, connect it to the `dm` network and make it resolvable under the `mssql_db` hostname.
We also confirm the EULA and set password for the default `sa` user to the `Mssql_22` value.
``` sh
docker run -d --name mssql \
    --network dm --network-alias mssql_db \
    -e ACCEPT_EULA=Y \
    -e MSSQL_SA_PASSWORD=Mssql_22 \
    mcr.microsoft.com/mssql/server:2022-latest
```
Now we can access `mssql` container from the `datero` container by its hostname `mssql_db`.


## MSSQL database
Having `mssql` container running, we can connect to it and create some test database.
``` sh
docker exec -it mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Mssql_22
```

``` sql
1> create database cosmo;
2> go
1> use cosmo;
2> go
Changed database context to 'cosmo'.
1> create table planets (id int, name varchar(20));
2> go
1> insert into planets values (1, 'Earth'), (2, 'Mars'), (3, 'Jupiter');
2> go
(3 rows affected)
```

Now we are ready to connect to the `mssql` database from `datero`.

## Datero connection
Open `Datero` web ui at [http://localhost](http://localhost) and click on the `MSSQL` entry in the the `Connectors` navigation section on the left.

Enter `mssql_db` as the `Servername` value. 
This is that custom hostname that we specified when were launching `mssql` container in the `dm` network.
This emulates external host connectivity. 

In a real-world case, the situation would be similar.
If you have, for example, MSSQL running on `mssql-host.my-company.com` hostname and 
it's resolvable from the machine where `datero` container is running, you can use that hostname instead.

Specify `sa` as the `User` value. For the password use `Mssql_22` value. 
We specified this password when were launching `mssql` container.

Click `Save` to create the Server logical object.

!!! warning "Work in progress"
    Datero UI for the MSSQL connector is under development.
    Provided "Connection Form" screenshot is obsolete and will be updated soon.

Connector|Connection Form
:---:|:---:
![Connectors](../images/connectors/mssql/connector.png){ loading=lazy }|![Create Server](../images/connectors/mssql/create_server.png){ loading=lazy }


!!! info "Work in progress"
    Documentation for the MSSQL connector is under development.
    Schema import and query examples will be added soon.

<!--
## Schema import
After the Server is created, we can import database schema from it.
Connection wizard will switch the tab and open `Import Schema` form.
In the `Remote Schema` drop down select you will be able to pick-up `pets` schema, 
that we created earlier in source `mssql` database.

!!! info "User vs Schema"
    In MSSQL, user and schema are the same thing.
    So, when we created `pets` user, we also created `pets` schema.

Server Object|Import Schema
:---:|:---:
![Server Object](../images/connectors/mssql/server_entry.png){ loading=lazy }|![Import Schema](../images/connectors/mssql/import_schema.png){ loading=lazy }

For example, we want to import  `pets` schema into the same `pets` local schema.
To do that, type `pets` into the `Local Schema` input field and click `Import Schema` button.

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
  ![Import schema completed](../images/connectors/mssql/import_schema_completed.png){ loading=lazy }
  <figcaption>Completed Schema Import</figcaption>
</figure>

We are ready now to query our MSSQL database from Datero.

## Data Querying
Click on the `Query Editor` icon in the left navigation panel.
You will see `pets` schema in the `Datero` object tree.
If you expand it, you will see `animals` table from original `mssql` database.
Its definition was automatically imported.

To query data just write a query in the editor and press `Ctrl+Enter` or click green `Run` button above.

<figure markdown>
  ![Query Data](../images/connectors/mssql/query_data.png){ loading=lazy }
  <figcaption>Query Data</figcaption>
</figure>

And that's it! You have successfully connected to the MSSQL database from Datero and queried the data.

## Summary
Of course, having just a single datasource is not very interesting.
It's non-distinguishable from the direct connection to MSSQL via any other tool, like DBeaver.
But the real power of Datero is in its ability to connect to multiple datasources and join data from them.

This is what is not possible via the "direct connection" tools.
Even if they support connecting to multiple datasources, they don't support joining the data from them.
-->