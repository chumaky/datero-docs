## Google Kubernetes Engine
To run Datero on GKE, you have to create a cluster first.
Exact procedure to create it is out of scope of this guide.
Please refer to the [official documentation :octicons-tab-external-16:](https://cloud.google.com/kubernetes-engine/docs/quickstarts/create-cluster){: target="_blank" rel="noopener noreferrer" } for that.


![GKE cluster](../../images/clouds/gcp/gke_cluster.jpg){ loading=lazy; align=right }

Once you have a cluster, you have to create a deployment.
Deployment is a Kubernetes configuration object which specifies how specific application should be run on a cluster.
Deployed application constitutes a Workload.

## Create Deployment
You can create a deployment in a various ways.
In this guide we will use Google Cloud Console approach.
Start creating deployment by pressing `Deploy` button on the cluster page.

### Specify container image
First step is to specify container image(s) to run.
In our case, we want to run single Datero container.
All-inclusive Datero image is available on [Docker Hub :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero){: target="_blank" rel="noopener noreferrer" }.
To do that, we have to select "Existing container image" and specify its address `chumaky/datero` in the `Image path` input box.

The only mandator parameter to specify during container launch is `POSTGRES_PASSWORD`.
It's dictated by the official image of `postgres` database.

<figure markdown>
  ![Datero container](../../images/clouds/gcp/deployment_step1.jpg){ loading=lazy }
  <figcaption>Datero container</figcaption>
</figure>

After specifying the password, press `Done` button at the bottom.

### Deployment configuration
Next step is to configure resources.
By default, GKE will create a single node pool with 3 nodes.
You have possibility to specify labels for the nodes.
For the demo purposes, we will leave single default `app` label which will be the same as the deployment name.

<figure markdown>
  ![Deployment configuration](../../images/clouds/gcp/deployment_step2.jpg){ loading=lazy }
  <figcaption>Deployment configuration</figcaption>
</figure>

You should also pick-up a target cluster for the deployment.
We will select the `datero` cluster we have created in the previous step.

!!! note
    Full control over configuration is available via YAML file that could be submitted from the command line.
    But this is out of scope of this guide.

Press `Continue` button to proceed to the final step.

### Expose service
To have a possibility to access Datero web application, we have to expose it as a service. 
This is done by mapping the ports of the container to the ports of the cluster.
In our case, we want to expose port `80` of the container to the port `80` of the cluster.

For service type we will select `Load balancer`.
By default, GKE creates 3 container instances and automatically handles traffic load balancing for them.


<figure markdown>
  ![Port mapping](../../images/clouds/gcp/deployment_step3.jpg){ loading=lazy }
  <figcaption>Port mapping</figcaption>
</figure>

## Access Datero UI
Once deployment is created, you can access Datero web application by clicking on the `Endpoints` link in the `Exposing services` section of the cluster page.

<figure markdown>
  ![Datero UI endpoint](../../images/clouds/gcp/gke_datero_ui.jpg){ loading=lazy }
  <figcaption>Datero UI endpoint</figcaption>
</figure>

Congratulations! You have successfully installed Datero on GCP GKE cluster.

--8<-- "include/clouds_next_steps.md"