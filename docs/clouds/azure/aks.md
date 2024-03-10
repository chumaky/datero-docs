---
description: Running Datero on Azure Kubernetes Service (AKS).
---

# Azure Kubernetes Service
To run Datero on AKS, you have to create a cluster first.
Exact procedure to create it is out of scope of this guide.
Please refer to the [official documentation :octicons-tab-external-16:](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli){: target="_blank" rel="noopener noreferrer" } for that.

![AKS cluster](../../images/clouds/azure/aks_cluster.jpg){ loading=lazy; align=right }

Once you have a cluster, you have to create a workload.
Workload is a Kubernetes configuration object which specifies how specific application should be run on a cluster.
In our case, we want to run single Datero container.

Also, for the demo purposes, we will want to expose Datero web application to the outside world.
To do that, we have to create a service which will map the ports of the container to the ports of the cluster.
Service will also assign a public IP to the container instance.

## Configuration
Azure Portal allows you to create a service in a wizard-like manner.
Drawback of this approach is that you don't have a possibility to specify all the potentially required parameters.
For example, there is no possibility to specify environment variables for the container.

Datero container requires at least one environment variable to be specified.
It's `POSTGRES_PASSWORD` which is dictated by the underlying official image of `postgres` database.
Luckily, there is a possibility to specify YAML config directly in the Azure Portal.

The following snippet is a very basic but workable example of the YAML configuration for the Datero service.

??? abstract "service configuration"
    ```yaml linenums="1"
    --8<-- "docs/clouds/azure/aks_service.yml"
    ```

It specifies the deployment named `datero-deployment` with `docker.io/chumaky/datero` image to run.
Required environment variable `POSTGRES_PASSWORD` is set explicitly.
Finally, there is service named `datero-service` which exposes the `80` port of the container to the outside world.

!!! note
    YAML file allows to have a full control over configuration.
    It's preferred way to specify the configuration for the production deployments.

After copypasting the configuration into the Portal, you can press `Deploy` button to initiate the deployment.


## Deployment verification
If everything is correct, you will get a `datero-deployment` successfully created.

<figure markdown>
  ![Completed Deployment](../../images/clouds/azure/aks_deployment.jpg){ loading=lazy }
  <figcaption>Completed Deployment</figcaption>
</figure>

Deployment consist of a pod which runs the container.

<figure markdown>
  ![Running container](../../images/clouds/azure/aks_container.jpg){ loading=lazy }
  <figcaption>Running container</figcaption>
</figure>

It could be seen that the container was created from the `docker.io/chumaky/datero` image.
And that `POSTGRES_PASSWORD` environment variable was set to the value specified in the YAML configuration.


## Service verification
We also created service of a LoadBalancer type.
It has assigned a public IP address `108.141.10.93` and has exposed `80` port to the outside world.

<figure markdown>
  ![Datero Service](../../images/clouds/azure/aks_service.jpg){ loading=lazy }
  <figcaption>Datero Service</figcaption>
</figure>


## Access Datero UI
Once we got our public IP address & port, we can access Datero web application.

<figure markdown>
  ![Datero UI](../../images/clouds/azure/aks_datero_ui.jpg){ loading=lazy }
  <figcaption>Datero UI</figcaption>
</figure>

Congratulations! You have successfully installed Datero on Azure AKS cluster.

--8<-- "include/clouds_next_steps.md"