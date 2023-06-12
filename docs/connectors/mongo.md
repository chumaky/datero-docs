---
description: Datero data platform Mongo connector. 
---

# Mongo
This section describes how to connect to Mongo database from Datero.

!!! info "Notice"
    Used approach is almost identical to the one described in the [MySQL](./mysql.md) and [Postgres](./postgres.md) sections.

## Environment
If not running, let's start `datero` container created in the [installation](../installation.md#running-the-container) section.
``` sh
docker start datero
```

!!! note "Connectivity pattern"
    To emulate external host connectivity, we will use [container 2 container](./index.md#container-to-container) approach.
    We will create `dm` network and connect `datero` container to it.
    Then we will run datasource `mongo` container and connect it to the `dm` network as well.
    
Now, let's create `dm` network and connect `datero` container to it.
Also make it resolvable under the `datero` hostname.
``` sh
docker network create dm
docker network connect --alias datero dm datero
```

To get Mongo database we can use official [mongo](https://hub.docker.com/_/mongo) docker image.
Let's pull the image first.
``` sh
docker pull mongo:jammy
```
Now run the container, connect it to the `dm` network and make it resolvable under the `mongo_db` hostname.
We also set password for the default `mongo` user to the `mongo` value.
``` sh
docker run -d --name mongo \
    --network dm --network-alias mongo_db \
    -e MONGO_INITDB_ROOT_USERNAME=root \
    -e MONGO_INITDB_ROOT_PASSWORD=root \
    mongo:jammy
```
Now we can access `mongo` container from the `datero` container by its hostname `mongo_db`.


## Mongo database
Having `mongo` container running, we can connect to it and create some test data.
``` sh
docker exec -it mongo mongosh -u root -p root
```

Mongo is a document-oriented NoSQL database.
Instead of tables and rows it operates by terms of collections and documents.
Collection creation in mongo is implemented by "at first usage" approach. 
If referenced object doesn't exist it gets created automatically. 

``` sql
test> db.forms.insertMany([{id: 1, name: 'square'}, {id: 2, name: 'circle'}, {id: 3, name: 'triangle'}])
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId("6480fc5badd81040247e9c51"),
    '1': ObjectId("6480fc5badd81040247e9c52"),
    '2': ObjectId("6480fc5badd81040247e9c53")
  }
}
test> db.forms.find()
[
  { _id: ObjectId("6480fc5badd81040247e9c51"), id: 1, name: 'square' },
  { _id: ObjectId("6480fc5badd81040247e9c52"), id: 2, name: 'circle' },
  { _id: ObjectId("6480fc5badd81040247e9c53"), id: 3, name: 'triangle' }
]
```

Now we are ready to connect to the `mongo` database from `datero`.


## Datero connection
Open `Datero` web ui at [http://localhost](http://localhost) and click on the `Mongo` entry in the the `Connectors` navigation section on the left.

Enter any descriptive name in the `Description` field. For example, `Mongo Server`.
Enter `mongo_db` as the `Host` value.
This is that custom hostname that we specified when were launching `mongo` container in the `dm` network.
This emulates external host connectivity.

In a real-world case, the situation would be similar.
If you have, for example, Mongo running on `mongo-host.my-company.com` hostname and
it's resolvable from the machine where `datero` container is running, you can use that hostname instead.

Specify `root` as the `User` value.
For the password use `root` as well. Because this is a value we set when were launching `mongo` container.

Click `Save` to create the Server logical object.

Connector|Connection Form
:---:|:---:
![Connectors](../images/connectors/mongo/connector.png){ loading=lazy }|![Create Server](../images/connectors/mongo/create_server.png){ loading=lazy }


## Import table (collection)
After the Server is created, connection wizard will switch the tab and open `Import Table` form.

!!! note "Import Table"
    Automatic fetch of the collections list is under development.
    Corresponding form is empty for now.
    User needs to define foreign table manually in the `Query Editor`.

Server Object|Import Schema
:---:|:---:
![Server Object](../images/connectors/mongo/server_entry.png){ loading=lazy }|![Import Schema](../images/connectors/mongo/import_table.png){ loading=lazy }

Because automatic fetching of the collections list is under development, we need to define foreign table manually.

![Servers list](../images/connectors/mongo/server_list.png){ loading=lazy; align=right }
Navigate to the `Query Editor` by clicking on the corresponding icon in the navigation section on the left.
Get the names of already created server objects via the query.
``` sql
select srvname from pg_foreign_server;
```

`mongo_fdw_1` is the internal name of the `Mongo Server` object that we created in the previous step.
We should use it in the `CREATE FOREIGN TABLE` statement.

```sql
DROP SCHEMA IF EXISTS mongo CASCADE;
CREATE SCHEMA IF NOT EXISTS mongo;

CREATE FOREIGN TABLE mongo.forms
( _id       name
, id        int
, name      varchar
) SERVER mongo_fdw_1;
```
Execute these commands one by one in the editor by pressing `Ctrl+Enter` or clicking green `Run` button above.


## Data Querying
Once table created we could query it.
```sql
select * from mongo.forms;
```

We could also see its structure in the `Query Editor` object navigator.

Foreign Table|Query Data
:---:|:---:
![Foreign Table](../images/connectors/mongo/foreign_table.png){ loading=lazy }|![Query Data](../images/connectors/mongo/query_data.png){ loading=lazy }

And that's it! You have successfully connected to the Mongo database from Datero and queried the data.

## Summary
Of course, having just a single datasource is not very interesting.
It's non-distinguishable from the direct connection to Mongo via any other tool, like DBeaver.
But the real power of Datero is in its ability to connect to multiple datasources and join data from them.

This is what is not possible via the "direct connection" tools.
Even if they support connecting to multiple datasources, they don't support joining the data from them.
