# Introduction

`Datero` is an open-source data platform which allows to query heterogeneous datasources via plain `SQL`.

It can join data from different sources such as `CSV` files, `SQL` and `NoSQL` databases via single `SELECT` statement.


Data is fetched from the source via connector.
If supported by corresponding connector, it is possible to _write_ data back to datasource. Thus implementing reverse ETL feature.

Built on top of official `Postgres` database `Datero` is also a fully functional RDBMS system.
Its releases are kept in sync with official `Postgres` releases.
This means, that you can use all the latest features of `Postgres` in `Datero`.


## Quickstart
All you have to do is to create connection to the source either via web based UI or through `YAML` config.


<figure markdown>
  ![Default Datero dashboard](./images/datero_dashboard.jpg){ loading=lazy }
  <figcaption>Datero dashboard</figcaption>
</figure>


Depending on connector, `Datero` will be able to automatically scan datasource and generate schema definition.
But you will have to say which source schema/database do you want to scan.


Generated meta layer is stored as an `external` tables within local postgres `schema`.
From accessing perspective, they are non-distinguishable from basic tables in postgres.

And that's it. You are ready to query and join your data.


## Example
Assume, you created connections to your `MySQL`, `SQLite`, `Postgres` and `Mongo` databases.
`MySQL` contains data about users. All the other databases contain different data related to these users.

```sql title="Individual datasources"
SELECT * FROM mysql.users;        -- main dict of users
SELECT * FROM sqlite.profiles;    -- user profiles
SELECT * FROM postgres.salaries;  -- user salaries
SELECT * FROM mongo.orders;       -- user orders
```

Now, to query all these data, just use plain `SQL`.

```sql title="Join data from 4 different databases"
SELECT *
FROM mysql.users        u
JOIN sqlite.profiles    p ON p.user_id = u.id
JOIN postgres.salaries  s ON s.user_id = u.id
JOIN mongo.orders       o ON o.user_id = u.id
;
```

## Highlights
`Datero` leverages _no ETL_ approach. Data are not copied to the system.
Only requested data are brought in and joined.
Depending on used connectors, filtering predicates are pushed to the source.
This allows you to easily query multimillion tables assuming you have a selective filtering criteria.

Another exciting feature is capability to implement reverse ETL.
Many connectors support _write_ mode. This means, that you could change data in multiple databases right from the `Datero`.

`Postgres` has an exciting feature of CTE which could do DML operations.
This allows to do such a crazy thing as changing the data in multiple sources from within single `SQL` statement!
