---
description: Datero data platform Redis connector. 
---

# Redis
This section describes how to connect to Redis in-memory database from Datero.

!!! info "Notice"
    Used approach is almost identical to the one described in the [Mongo](./mongo.md) section.

## Environment
If not running, let's start `datero` container created in the [installation](../installation.md#running-the-container) section.
``` sh
docker start datero
```

!!! note "Connectivity pattern"
    To emulate external host connectivity, we will use [container 2 container](./index.md#container-to-container) approach.
    We will create `dr` network and connect `datero` container to it.
    Then we will run datasource `redis` container and connect it to the `dr` network as well.
    
Now, let's create `dr` network and connect `datero` container to it.
Also make it resolvable under the `datero` hostname.
``` sh
docker network create dr
docker network connect --alias datero dr datero
```

To get Redis database we can use official [redis :octicons-tab-external-16:](https://hub.docker.com/_/redis){: target="_blank" rel="noopener noreferrer" } docker image.
Let's pull the image first.
``` sh
docker pull redis
```
Now run the container, connect it to the `dr` network and make it resolvable under the `redis_db` hostname.
We also don't to set any password for database access.
``` sh
docker run -d --name redis \
    --network dr --network-alias redis_db \
    redis
```
Now we can access `redis` container from the `datero` container by its hostname `redis_db`.


## Redis database
Having `redis` container running, we can connect to it and create some test data.
``` sh
$ docker exec -it redis redis-cli 
127.0.0.1:6379> 
```

Redis is a key-value store.
Instead of tables and rows it operates by terms of keys and values.
Key-value creation in Redis is implemented by `SET` command. 
To setup a "record" like object we could use `HSET` command.
It sets multiple fields in a hash stored at key.

``` sh
127.0.0.1:6379> hset furniture:1 id 1 name table
(integer) 2
127.0.0.1:6379> hset furniture:2 id 2 name chair
(integer) 2
127.0.0.1:6379> hset furniture:3 id 3 name bed
(integer) 2
```

To check the data of a specific "record" we could leverage `hgetall` command.
``` sh
27.0.0.1:6379> hgetall furniture:1
1) "id"
2) "1"
3) "name"
4) "table"
```

Now we are ready to connect to the `redis` database from `datero`.


## Datero connection
Open `Datero` web ui at [http://localhost :octicons-tab-external-16:](http://localhost){: target="_blank" rel="noopener noreferrer" } and click on the `Redis` entry in the the `Connectors` navigation section on the left.

Enter any descriptive name in the `Description` field. For example, `Redis Server`.
Enter `redis_db` as the `Host` value.
This is that custom hostname that we specified when were launching `redis` container in the `dr` network.
This emulates external host connectivity.

In a real-world case, the situation would be similar.
If you have, for example, Redis running on `redis-host.my-company.com` hostname and
it's resolvable from the machine where `datero` container is running, you can use that hostname instead.

For the testing purposes we won't set any `Password` value.
`Port` value is set to the `6379` by default.

Click `Save` to create the Server logical object.

Connector|Connection Form
:---:|:---:
![Connectors](../images/connectors/redis/connector.png){ loading=lazy }|![Create Server](../images/connectors/redis/create_server.png){ loading=lazy }


## Import table (collection)
After the Server is created, connection wizard will switch the tab and open `Import Table` form.

!!! note "Import Table"
    Automatic fetch of the hashes list is under development.
    Corresponding form is empty for now.
    User needs to define foreign table manually in the `Query Editor`.

Server Object|Import Schema
:---:|:---:
![Server Object](../images/connectors/redis/server_entry.png){ loading=lazy }|![Import Schema](../images/connectors/redis/import_table.png){ loading=lazy }

Because automatic fetching of the collections list is under development, we need to define foreign table manually.

![Servers list](../images/connectors/redis/server_list.png){ loading=lazy; align=right }
Navigate to the `Query Editor` by clicking on the corresponding icon in the navigation section on the left.
Get the names of already created server objects via the query.
``` sql
select srvname from pg_foreign_server;
```

`redis_fdw_1` is the internal name of the `Redis Server` object that we created in the previous step.
We should use it in the `CREATE FOREIGN TABLE` statement.

```sql
DROP SCHEMA IF EXISTS redis CASCADE;
CREATE SCHEMA IF NOT EXISTS redis;

CREATE FOREIGN TABLE redis.furniture
( key       text
, val       text[]
) 
SERVER redis_fdw_1
OPTIONS (database '0', tabletype 'hash', tablekeyprefix 'furniture:')
;
```
Execute these commands one by one in the editor by pressing `Ctrl+Enter` or clicking green `Run` button above.


## Data Querying
Once table created we could query it.
```sql
select * from redis.furniture;
```

We could also see its structure in the `Query Editor` object navigator.

Foreign Table|Query Data
:---:|:---:
![Foreign Table](../images/connectors/redis/foreign_table.png){ loading=lazy }|![Query Data](../images/connectors/redis/query_data.png){ loading=lazy }

And that's it! You have successfully connected to the Redis database from Datero and queried the data.

## Summary
Of course, having just a single datasource is not very interesting.
It's non-distinguishable from the direct connection to Redis via any other tool, like DBeaver.
But the real power of Datero is in its ability to connect to multiple datasources and join data from them.

This is what is not possible via the "direct connection" tools.
Even if they support connecting to multiple datasources, they don't support joining the data from them.
