---
description: Datero data platform overview.
---

`Datero` has web based UI which allows to manage connections and query data.
Default dashboard has navigation panel on the left with the list of available `connectors`.
You create a connection to the source which is shown as a `server` logical entry right above the connectors in the navigation pane.

Main content of default dashboard shows some graphs of available connectors and the number of created connections to them.


<figure markdown>
  ![Default Datero dashboard](./images/datero_dashboard.jpg){ loading=lazy }
  <figcaption>Datero dashboard</figcaption>
</figure>


### Connectors
To create connection to the source, click on the corresponding connector entry in the navigation pane.
This will open a form where you can specify connection parameters.

Connector|Connection Form
:---:|:---:
![Connectors](./images/connectors.jpg){ loading=lazy }|![Connection form](./images/connection_form.jpg){ loading=lazy }


Connection form itself is a multi step wizard.
After specifying connection parameters, next step is to scan datasource.
Depending on a connector, it may or may not support schema import out of a box.
In any case, `Datero` tries to get list of remote schemas available for import automatically.


If schema import is not supported by connector, `Datero` will try to fetch a list of individual objects for each schema.
By selecting specific object, `Datero` will try to fetch its definition automatically.

!!! info
    Fetching individual object definition is under development.

And finally, if all the above fails, you will have to specify table definition manually.


### Import Schema
After pressing `Save` button, `Datero` will create logical `server` entry in the navigation pane and activate either `Import Schema` or `Import Table` tabs.
Activated tab will be dictated by the connector capabilities: whether or not it supports schema scanning.

<figure markdown>
  ![Import schema](./images/import_schema.jpg){ loading=lazy }
  <figcaption>Import Schema</figcaption>
</figure>

In the `Remote Schema` select box you will see a list of available schemas in the source. You should pick-up the one you want to import.

In the `Local Schema` input box you should specify a name of the _local_ schema within `Datero` where metadata will be stored. Generated meta layer is stored as an `external` tables. From accessing perspective, they are non-distinguishable from basic tables in postgres.

And that's it. You are ready to query and join your data.


### Import Table
Suppose you don't want to import the whole schema, but only a specific table.
In this case, you could use `Import Table` tab in the connection form.
It is very similar to `Import Schema` tab, but instead of selecting schema, you should select a table or view in a specific schema.

!!! info
    `Import Table` tab functionality is under development.

### Advanced Settings
`Datero` supports full set of the connector parameters.
In this section user will be able to override any of them.
There is a FDW specification project which specifies all the parameters for each connector.
It's available on [github :octicons-tab-external-16:](https://github.com/chumaky/postgres-fdw-spec){: target="_blank" rel="noopener noreferrer" }.
Datero uses this specification to generate displayed list of options.

<figure markdown>
  ![Connector settings](./images/advanced_settings.jpg){ loading=lazy }
  <figcaption>Connector settings</figcaption>
</figure>

## Query Data
After you created connections to the sources, you can query data from them.
`Datero` has a built-in `SQL` editor which allows to write and execute queries.

Also, as mentioned earlier, `Datero` is a fully functional `Postgres` database.
This means that you could use any `Postgres` supported client or protocol to connect to `Datero` and query data.

<figure markdown>
  ![Query Editor](./images/query_editor.jpg){ loading=lazy }
  <figcaption>Query Editor</figcaption>
</figure>

### Example
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
Data Virtualization
:   `Datero` leverages data virtualization approach. Data are not copied to the system.
Only requested data are brought in and joined.
Depending on used connectors, filtering predicates are pushed to the source.
This allows you to easily query multimillion tables assuming you have a selective filtering criteria.

Reverse ETL
:   Another exciting feature is capability to implement reverse ETL.
Many connectors support _write_ mode. This means, that you could change data in multiple databases right from the `Datero`.

    !!! tip
        `Postgres` has an exciting feature of CTE which could do DML operations.
        This allows to do such a crazy thing as changing the data in multiple sources from within single `SQL` statement!

        I.e., it's possible to code some business logic in _single_ `SQL` statement and execute it in `Datero` to change data in multiple sources.

Data Platform
:    `Datero` is built on top of `Postgres` and is served as an opened system.
     You have a fully functional RDBMS at your disposal that could be used as a base for any type of database applications.