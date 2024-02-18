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
First step is to specify container image(s) to run.
In our case, we want to run single Datero container.
All-inclusive Datero image is available on [Docker Hub :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero){: target="_blank" rel="noopener noreferrer" }.

To do that, we have to select _Deploy one revision from an existing container image_ option and specify `chumaky/datero` as a container image.

<figure markdown>
  ![Create service](../../images/clouds/gcp/cloud_run_create_service.jpg){ loading=lazy }
  <figcaption>Create service</figcaption>
</figure>

For the demo purposes, we will make our service publicibly accessible.
To do that, we have to accept all _Ingress_ traffic and select _Allow unauthenticated invocations_ checkbox.

<figure markdown>
  ![Public access](../../images/clouds/gcp/cloud_run_public_access.jpg){ loading=lazy }
  <figcaption>Public access</figcaption>
</figure>

### Container configuration
Next step is to configure container details.
The only mandator parameter to specify during container launch is `POSTGRES_PASSWORD`.
It's dictated by the official image of `postgres` database.

Also, we want to access Datero web application over HTTP, so we have to expose port `80` of the container.

<figure markdown>
  ![Datero container](../../images/clouds/gcp/cloud_run_container.jpg){ loading=lazy }
  <figcaption>Datero container</figcaption>
</figure>

Most probably, datasources that you want to access from Datero will be located in the VPC.
To allow Datero to access them, you have to specify VPC connector.
You can do that in the _Networking_ tab of the service page.

<figure markdown>
  ![Container networking](../../images/clouds/gcp/cloud_run_vpc_networking.jpg){ loading=lazy }
  <figcaption>Container networking</figcaption>
</figure>

And finally, press _Create_ button to create the service.

## Access Datero UI
Once service is created, you can access Datero web application by clicking on the `URL` link in the service details page.

<figure markdown>
  ![Datero UI endpoint](../../images/clouds/gcp/cloud_run_deployment_success.jpg){ loading=lazy }
  <figcaption>Datero UI endpoint</figcaption>
</figure>

Congratulations! You have successfully installed Datero on GCP Cloud Run.

--8<-- "include/clouds_next_steps.md"