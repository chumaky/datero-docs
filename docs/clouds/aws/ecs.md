---
description: Running Datero on AWS Elastic Container Service (ECS).
---

Elastic Container Service is a managed service which allows you to run containers.
You start to work with ECS by creating a logical entity called `cluster`.
It's a place where you can run your containers.
Then you can run `tasks` or `services` on the cluster.

Exact procedure to create the cluster is out of scope of this guide.
Please refer to the [official documentation :octicons-tab-external-16:](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html){: target="_blank" rel="noopener noreferrer" } for that.


## ECS basics
Below is a _very condensed_ overview of ECS concepts.
Just to introduce you to the terminology. 

To run any container on a cluster you have first to create a `task definition`.
This is a blueprint for your container(s) that you want to run.
It includes information about the container image, CPU and memory requirements, networking and other parameters.

Basing on the task definition, you can run `tasks` or `services` on the cluster.
Task is more like a one-time job, while service is more suitable for a long-running task.
Service also provides extra capabilities like load balancing and auto-scaling.

Tasks and services are logical entities.
But actual execution must be done by some resources.
Two main resources that ECS can use are `Fargate` and `EC2`.
Fargate is a serverless approach.
EC2 is a more traditional way where you have to manage the underlying infrastructure yourself.

Easiest way to run containers on ECS is to use Fargate. But it's also the most expensive.
You pay an extra fee for the convenience of being serverless.

To run on EC2 you have to register instances with ECS first.
The most smooth way to do that is to create `capacity provider` and associate it with the cluster.
`Capacity provider` is yet another logical entity.
It defines EC2 resources that ECS tasks run on.
As part of its definition, you specify an `auto scaling group` which manages instances creation and termination.

!!! info "Demo infrastructure"
    In this guide we will run `task` and use `ec2` based capacity provider.


## Task Definition
Our task definition will be very simple.
We run single all-inclusive Datero container.
What we need to specify is image url, required CPU & RAM resources and port mapping.
To have an access to the web application we expose port `80`.
For the database access, you have to expose port `5432` as well.
Our main purpose is to show how to run Datero on ECS, so we will expose only web application port.

<figure markdown>
  ![Task definition](../../images/clouds/aws/ecs_datero_container.jpg){ loading=lazy }
  <figcaption>Task definition</figcaption>
</figure>

There is also a requirement to specify `POSTGRES_PASSWORD` environment variable.
It's dictated by the official image of underlying `postgres` database.
You could use whatever value you want, but for the demo purposes we will use `postgres` as a password.

<figure markdown>
  ![Superuser password](../../images/clouds/aws/ecs_datero_env_variable.jpg){ loading=lazy }
  <figcaption>Superuser password</figcaption>
</figure>

## Image URL
Datero is gonna be available soon on AWS marketplace.
To use it, you have to subscribe to the product and then you can use the image url from the AWS ECR.
--8<-- "include/datero_marketplace.md:version"

Alternatively, Datero image is available on [Docker Hub :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero){: target="_blank" rel="noopener noreferrer" }.

--8<-- "include/datero_marketplace.md:support"


## Run Task
![Run task](../../images/clouds/aws/ecs_run_task.jpg){ loading=lazy; align=right }
Once task definition is created, you can run the task on the cluster.
Open created task definition and click on the `Run Task` button.
You will see a plenty of options to specify.
As a minimum, you have to select the cluster and capacity provider strategy.
Because we created `ec2` based capacity provider, we will use it.
We also specify `1` as the number of tasks to run.


## Access Datero UI
ECS cluster will notify capacity provider to start new EC2 instance if there is not enough capacity.
Once the instance is up and running, the task will be scheduled on it.
If everything goes well, you will see the task in `Running` state.

<figure markdown>
  ![Running task](../../images/clouds/aws/ecs_running_task.jpg){ loading=lazy }
  <figcaption>Running task</figcaption>
</figure>

You can access Datero web application by clicking on the `Public IP` link in the Configuration section.

!!! note "Networking setup"
    In the screenshot above task is running in `host` networking mode.
    It's not the best practice for the production environment.
    But for the demo purposes it's fine.

    AWS advises to use `awsvpc` networking mode.
    It results into absence of public IP address for the task and separate ENI for each task.
    You have to access it over ec2 _private_ IP address from within your AWS environment.
    Or by IPv6 address if you have enabled IPv6 connectivity on the VPC level.

Datero is configured to listen on both IPv4 and IPv6 addresses.
For an example of how to serve Datero over IPv6, see [IPv6 Support](../../administration/ipv6.md).


Congratulations! You have successfully installed Datero on AWS ECS.

--8<-- "include/clouds_next_steps.md"