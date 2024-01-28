In a previous sections we described services that can be used to _install_ Datero on GCP.
You can do this on [VM instance](./vm_instance.md), [GKE](./gke.md), or [Cloud Run](./cloud_run.md).

Now let's overview service that can be used as a datasource for Datero.
The most traditional one is relational database.
In GCP you can use [Cloud SQL](https://cloud.google.com/sql) service for that.

We will create a PostgreSQL and MySQL databases in the Cloud SQL.
Afterwards, we will connect and join tables in them from Datero.

!!! info
    For the full fledged example, please refer to the [Tutorial](../../tutorial.md).
    For the list of supported datasources, please refer to the [Connectors](../../connectors/index.md) section.


## Cloud SQL instance
Firstly, we have to create Cloud SQL instance.
Exact procedure to create it is out of scope of this guide.
But you can refer to the official documentation how to spin up [postgres](https://cloud.google.com/sql/docs/postgres/create-instance#create-2nd-gen) and [mysql](https://cloud.google.com/sql/docs/mysql/create-instance#create-2nd-gen) instances.

During instance launch you could specify whether you want to have public IP or not.
General recommendation for databases is to use private IP.
Cloud SQL is a GCP managed service, that is run in a separate system VPC.
To allow access to your instance by its private IP, you have to create a peering connection between your VPC and the one that is used by Cloud SQL.

If you spin your instance via console, you have just to pick-up a subnet from your VPC where Cloud SQL, as a _service_, will be creating private connection to your VPC. Having done that, you will be able to connect to your instance by its private IP from VM launched in that subnet. This concept is similar to VPC _service endpoints_ in AWS.

<figure markdown>
  ![VPC Networking](../../images/clouds/gcp/cloud_sql_vpc_networking.jpg){ loading=lazy }
  <figcaption>VPC Networking</figcaption>
</figure>


## Postgres
Assuming you created a postgres instance and it has been assigned some private IP address.
During instance creation you must specify a password for the `postgres` user.
For simplicity, we used `postgres` as a password.

![Private IP](../../images/clouds/gcp/cloud_sql_postgres_ip.jpg){ loading=lazy; align=right }

To connect to it we can leverage VM named `instance` that we created in the [previous section](./vm_instance.md).
It is spin up in the same subnet that we picked up for private connection setup with Cloud SQL.
This guarantees that we can connect to our Cloud SQL instance by its private IP.

To connect to the instance, we have to leverage `psql` client on the VM.
To avoid direct installation of `psql` on the VM, we can use `postgres` docker image.
We can run it in the interactive mode and connect to the instance from there.

The following code abstract does the following:

- runs `postgres` docker image in the interactive mode with automatic removal of the container after exit
- instead of starting a database server, it runs just `bash` shell
- checks `psql` utility version
- sets `PGPASSWORD` environment variable to the password `postgres` that we specified during our Cloud SQL instance creation
- connects to the instance by its private IP `10.12.96.3` via `psql` client
- connection is done to the `postgres` database with `postgres` user

```sh
instance:~$ docker run --rm -it postgres:alpine bash
d2ccdd73d5fd:/# psql --version
psql (PostgreSQL) 16.1
d2ccdd73d5fd:/# export PGPASSWORD=postgres
d2ccdd73d5fd:/# psql -h 10.12.96.3 postgres postgres
psql (16.1, server 15.4)
postgres=>
```

We used latest `postgres:alpine` image which is `postgres` version `16.1`.
It has `psql` client of the same version installed in it.
In the same time our Cloud SQL instance is running `postgres` version `15.4`.
And output `psql (16.1, server 15.4)` says it explicitly. 
That we are using `psql` client version `16.1` connected to the `postgres` database server version `15.4`.

Once being connected, we create `finance` schema and `departments` table in it.
```sql
postgres=> create schema finance;
CREATE SCHEMA
postgres=> create table finance.departments(id int, name text);
CREATE TABLE
postgres=> insert into finance.departments values (1, 'Manufacturing'), (2, 'Sales'), (3, 'Management');
INSERT 0 3
postgres=> select * from finance.departments;
 id |     name      
----+---------------
  1 | Manufacturing
  2 | Sales
  3 | Management
(3 rows)
```

## Datero 2 Postgres connection
Now we can connect to the same instance from Datero.
All we need to do is to create a Postgres server entry and specify private IP address of our Cloud SQL instance.

!!! info
    Please see [Overview](../../overview.md#connectors) of how to create a server entry and import schema.
    For the full fledged example, please refer to the [Tutorial](../../tutorial.md).

<figure markdown>
  ![Postgres datasource](../../images/clouds/gcp/cloud_sql_postgres_server.jpg){ loading=lazy }
  <figcaption>Postgres datasource</figcaption>
</figure>

Once server entry is created, we can import a `finance` schema.
<figure markdown>
  ![Postgres import schema](../../images/clouds/gcp/cloud_sql_postgres_import_schema.jpg){ loading=lazy }
  <figcaption>Postgres import schema</figcaption>
</figure>

And finally, query the `departments` table.
<figure markdown>
  ![Query departments table](../../images/clouds/gcp/cloud_sql_postgres_query.jpg){ loading=lazy }
  <figcaption>Query departments table</figcaption>
</figure>
