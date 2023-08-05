---
description: Datero data platform tutorial.
---

Major feature of a Datero data platform is its ability to join data from different sources within a single query.
In this tutorial we will demonstrate how Datero could empower your data analytics without any ETL development.

## Scenario
Let's assume we work for an imaginary `Enterprise` company.

As a usual company, it has multiple departments, like `Production`, `Sales`, `Finance`, etc.
Each department has its own data sources, like databases, spreadsheets, etc.
And there is a need to join data from different sources to get a complete picture of the company sales data.

This company has the following datasources:

- Customers are stored in `MySQL` database
- Products are stored in `PostgreSQL` database
- Employees are stored in `MSSQL` database
- Orders are stored in `MongoDB` database
- Job roles are stored in `SQLite` database
- Company departments are stored in `CSV` file

And we need to figure out in sales data who sold what product to which customer.
As well as what job role and department this employee belongs to.


## Logical Data Model
Below is a logical structure of data sources and their relations.
Sales data is stored in the `orders` table.
Customers place an orders which contain products. Employees serve the orders.
Employees belong to job roles and job roles belong to departments.

``` mermaid
erDiagram
  customers ||--o{ orders : places
  orders ||--|{ products : contains
  employees ||--o{ orders : serves
  employees o{--|| job_roles : belongs
  job_roles o{--|| departments : belongs
```

In terms of datasources, this diagram looks like this:

``` mermaid
flowchart BT
  customers[("customers\n\nMySQL")]
  orders[("orders\n\nMongoDB")]
  products[(products\n\nPostgreSQL)]
  employees[(employees\n\nMSSQL)]
  job_roles[(job_roles\n\nSQLite)]
  departments[(departments\n\nCSV)]

  customers --> orders
  products --> orders
  employees --> orders
  job_roles --> employees
  departments --> job_roles
```

## Test Data
The data that are stored in each data source are as follow.

=== "customers"
    {{ read_csv('./data/tutorial/customers.csv') }}
=== "products"
    {{ read_csv('./data/tutorial/products.csv') }}
=== "orders"
    {{ read_csv('./data/tutorial/orders.csv') }}
=== "employees"
    {{ read_csv('./data/tutorial/employees.csv') }}
=== "job_roles"
    {{ read_csv('./data/tutorial/job_roles.csv') }}
=== "departments"
    {{ read_csv('./data/tutorial/departments.csv') }}


## Infrastructure Setup
!!! info "source files"
    All the sources used in this tutorial are available in the [demo](https://github.com/chumaky/datero-docs/tree/master/demo) folder of this documentation repository.

To emulate multiple data sources, we will use docker containers orchestrated by `docker-compose`.
It will spin up `datero` container and several other containers for relevant datasources.

??? abstract "docker-compose"
    ```yaml linenums="1"
    --8<-- "demo/docker-compose.yml"
    ```

Here is per-service breakdown of a compose file.
=== "datero"
    ```yaml linenums="1"
    --8<-- "demo/docker-compose.yml:datero"
    ```
=== "mysql"
    ```yaml linenums="1"
    --8<-- "demo/docker-compose.yml:mysql"
    ```
=== "postgres"
    ```yaml linenums="1"
    --8<-- "demo/docker-compose.yml:postgres"
    ```
=== "mongo"
    ```yaml linenums="1"
    --8<-- "demo/docker-compose.yml:mongo"
    ```
=== "mssql"
    ```yaml linenums="1"
    --8<-- "demo/docker-compose.yml:mssql"
    ```
=== "sqlite"
    ```yaml linenums="1" hl_lines="10"
    --8<-- "demo/docker-compose.yml:datero"
    ```

    !!! info "file based data source"
        SQLite database is single file based.
        It doesn't have any listener over some port to connect to.
        Hence, we must mount it into the `datero` container to enable access to it through file system.

=== "csv"
    ```yaml linenums="1" hl_lines="11"
    --8<-- "demo/docker-compose.yml:datero"
    ```

    !!! info "file based data source"
        To enable access to a file it must be accessible from local file system of the `datero` container.
