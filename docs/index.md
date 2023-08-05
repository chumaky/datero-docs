---
description: Datero data platform documentation.
---

# About

`Datero` is an open-source data platform which allows to query heterogeneous datasources via plain `SQL`.

It can join data from different sources such as `CSV` files, `SQL` and `NoSQL` databases via single `SELECT` statement.


Data is fetched from the source via connector.
If supported by corresponding connector, it is possible to _write_ data back to datasource. Thus implementing reverse ETL feature.

Built on top of official `Postgres` database `Datero` is also a fully functional RDBMS system.
Its releases are kept in sync with official `Postgres` releases.
This means, that you can use all the latest features of `Postgres` in `Datero`.


## Next steps
If you're uncertain about whether to proceed, you might find it useful to begin with the [Overview](./overview.md) section.
It will make you familiar with what you will get after the installation.

If you are already convinced, you can go straight to [Installation](./installation.md) section.

For use-case example, please go to [Tutorial](./tutorial.md) section.

For individual datasources configuration, please refer to [Connectors](./connectors/index.md) section.