---
description: Running Datero on Azure Container Instances (ACI).
---

# Azure Container Instances

Azure Container Instances (ACI) is serverless platform which allows you to run your containers.
To run Datero on ACI, you have to create a container instance first.
Exact procedure to create it is out of scope of this guide.
Please refer to the [official documentation :octicons-tab-external-16:](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart-portal){: target="_blank" rel="noopener noreferrer" } for that.

## Configure instance
You can create a container instance in a various ways.
In this guide we will use Azure portal approach.
Just press _Create_ button on the main Container instances page.

Creation procedure is pretty straightforward multi-step wizard.
On each step you have to specify various parameters.
At the end of the process you will see review page with all the parameters you have specified.
A few parameters that you must to specify are as follow:

![Create service](../../images/clouds/azure/aci_container_settings.jpg){ loading=lazy; align="right" }

### 1. container image
To specify the image to run, it's required to specify repository and tag.
Here we specify our all-inclusive [chumaky/datero :octicons-tab-external-16:](https://hub.docker.com/r/chumaky/datero){: target="_blank" rel="noopener noreferrer" } image, which defaults to `latest` tag.

### 2. public IP
To make Datero web application accessible from the outside world we have to specify `Networking type: Public`.
That will assign a public IP to the container instance.
We also have to open `80` HTTP port to allow access to the Datero web application.

Optionally, you could specify a seed value for the dynamic FQDN that will be assigned to your deployment.

### 3. environment variables
There is also container parameters section.
It shows that we have one environment variable specified.


It corresponds to the `POSTGRES_PASSWORD` environment variable.
Which is the only mandator parameter to specify during container launch.
It's dictated by the official image of `postgres` database.

<figure markdown>
  ![Postgres password](../../images/clouds/azure/aci_postgres_password.jpg){ loading=lazy }
  <figcaption>Postgres password</figcaption>
</figure>


## Create deployment
When all the parameters are specified, you can press _Create_ button on the last _Review_ screen.
It will create a _Deployment_ which is a process of creating a container instance with the specified parameters.

<figure markdown>
  ![Container deployment](../../images/clouds/azure/aci_deployment_complete.jpg){ loading=lazy }
  <figcaption>Container deployment</figcaption>
</figure>

If everything is correct, you will get a _Resource_ created.
By clicking on it you will see its details.
We are interested in the public `IP address` of the container instance.
Alternatively, you could use the `FQDN` that was assigned to the resource.
As you could see, it got created with our `datero` seed value specified in `DNS name label` field put at first place.

<figure markdown>
  ![IP address & FQDN](../../images/clouds/azure/aci_ip_and_fqdn.jpg){ loading=lazy }
  <figcaption>IP address & FQDN</figcaption>
</figure>


## Access Datero UI
Once we got our public IP address or FQDN, we can access Datero web application.
Here we access it by the FQDN.

<figure markdown>
  ![Datero UI endpoint](../../images/clouds/azure/aci_datero_ui.jpg){ loading=lazy }
  <figcaption>Datero UI endpoint</figcaption>
</figure>

Congratulations! You have successfully installed Datero on Azure ACI.

--8<-- "include/clouds_next_steps.md"