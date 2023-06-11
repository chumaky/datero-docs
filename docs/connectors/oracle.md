---
description: Datero data platform Oracle connector. 
---

# Oracle
This section describes how to connect to Oracle database from Datero.

!!! info "Notice"
    Used approach is identical to the one described in the [MySQL](./mysql.md) section.

## Environment
If not running, let's start `datero` container created in the [installation](../installation.md#running-the-container) section.
``` sh
docker start datero
```

!!! note "Connectivity pattern"
    To emulate external host connectivity, we will use [container 2 container](./index.md#container-to-container) approach.
    We will create `do` network and connect `datero` container to it.
    Then we will run datasource `oracle` container and connect it to the `do` network as well.

Now, let's create `do` network and connect `datero` container to it.
Also make it resolvable under the `datero` hostname.
``` sh
docker network create do
docker network connect --alias datero do datero
```

[oracle_registry]: https://container-registry.oracle.com/ords/f?p=113:10:2179520783643:::RP::&cs=36sd3OxDgsDvwtMtbLqK4eGwYWQ0a5VMzYR4VB58w1ti_mmYd4h01sUd3vHD2pe68wKUyofdXr8PUixxFu755AA

To get Oracle database we can use official [oracle][oracle_registry] container registry.
On that page there is a `Database` product category tile.
Inside this category there is a `Oracle Database Free` repository.

As everything with Oracle, image is big. It's about 3Gb in compressed size. Let's pull the image first. 
``` sh
docker pull container-registry.oracle.com/database/free:latest
```

Now run the container, connect it to the `do` network and make it resolvable under the `oracle_db` hostname.
We also set password for the `sys`, `system` and `pdbadmin` users to the `admin` value.
``` sh
docker run -d --name oracle \
    --network do --network-alias oracle_db \
    -e ORACLE_PWD=admin \
    container-registry.oracle.com/database/free:latest
```
Now we can access `oracle` container from the `datero` container by its hostname `oracle_db`.


## Oracle database
Since version 12c, Oracle installation is already multitenant architecture with main Container (CDB) and Pluggable (PDB) databases.
From architecture point of view it became similar to Postgres or MySQL. 
Where single installation is a cluster which could have multiple databases.

Inside Oracle Database Free installation CDB is served over `FREE` listener service. While PDB is served over `FREEPDB1` service.

Having `oracle` container running, we can connect to the default pluggable database and create some test data.
``` sh
docker exec -it oracle sqlplus sys/admin@freepdb1 as sysdba
```

``` sql
SQL*Plus: Release 23.0.0.0.0 - Developer-Release on Sat Jun 10 16:00:08 2023
Version 23.2.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.

Connected to:
Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0

SQL> create user pets identified by pets 
    default tablespace users temporary tablespace temp 
    quota unlimited on users;
User created.

SQL> grant connect to pets;
Grant succeeded.

SQL> grant create table to pets;
Grant succeeded.
```

Now reconnecting already under `pets` user.
Because we are inside `sqlplus` session within the container we can use `localhost` as the hostname.
```sql
SQL> conn pets/pets@//localhost:1521/freepdb1
Connected.

SQL> create table animals(id number, name varchar2(100));
Table created.

SQL> insert into animals values (1, 'dog'), (2, 'cat'), (3, 'parrot');
3 rows created.

SQL> commit;
Commit complete.
```

Now we are ready to connect to the `oracle` database from `datero`.

## Datero connection
Open `Datero` web ui at [http://localhost](http://localhost) and click on the `Oracle` entry in the the `Connectors` navigation section on the left.

Enter `//oracle_db:1521/freepdb1` as the `Dbserver` value. 
Where `oracle_db` is that custom hostname that we specified when were launching `oracle` container in the `do` network.
And `freepdb1` is the name of the pluggable database service that we want to connect to.
This emulates external host connectivity. 

In a real-world case, the situation would be similar.
If you have, for example, Oracle running on `oracle-host.my-company.com` hostname and 
it's resolvable from the machine where `datero` container is running, you can use that hostname instead.

Specify `pets` as the `User` value. For the password use `pets` as well. 
We created this user when connected under the `sys` user to the `freepdb1` database in the previous section.

Click `Save` to create the Server logical object.

Connector|Connection Form
:---:|:---:
![Connectors](../images/connectors/oracle/connector.png){ loading=lazy }|![Create Server](../images/connectors/oracle/create_server.png){ loading=lazy }

## Schema import
After the Server is created, we can import database schema from it.
Connection wizard will switch the tab and open `Import Schema` form.
In the `Remote Schema` drop down select you will be able to pick-up `pets` schema, 
that we created earlier in source `oracle` database.

!!! info "User vs Schema"
    In Oracle, user and schema are the same thing.
    So, when we created `pets` user, we also created `pets` schema.

Server Object|Import Schema
:---:|:---:
![Server Object](../images/connectors/oracle/server_entry.png){ loading=lazy }|![Import Schema](../images/connectors/oracle/import_schema.png){ loading=lazy }

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
  ![Import schema completed](../images/connectors/oracle/import_schema_completed.png){ loading=lazy }
  <figcaption>Completed Schema Import</figcaption>
</figure>

We are ready now to query our Oracle database from Datero.

## Data Querying
Click on the `Query Editor` icon in the left navigation panel.
You will see `pets` schema in the `Datero` object tree.
If you expand it, you will see `animals` table from original `oracle` database.
Its definition was automatically imported.

To query data just write a query in the editor and press `Ctrl+Enter` or click green `Run` button above.

<figure markdown>
  ![Query Data](../images/connectors/oracle/query_data.png){ loading=lazy }
  <figcaption>Query Data</figcaption>
</figure>

And that's it! You have successfully connected to the Oracle database from Datero and queried the data.

## Summary
Of course, having just a single datasource is not very interesting.
It's non-distinguishable from the direct connection to Oracle via any other tool, like DBeaver.
But the real power of Datero is in its ability to connect to multiple datasources and join data from them.

This is what is not possible via the "direct connection" tools.
Even if they support connecting to multiple datasources, they don't support joining the data from them.
