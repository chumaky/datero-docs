Cloud Run is serverless platform which allows you to run your containers as a service.
To run Datero on Cloud Run, it's required to create such service.
Exact procedure to create it is out of scope of this guide.
Please refer to the [official documentation](https://cloud.google.com/run/docs/quickstarts/deploy-container) for that.

## Create Service
You can create a service in a various ways.
In this guide we will use Google Cloud Console approach.
Start by pressing _Create service_ button on the main Cloud Run Services page.

### Specify container image
First step is to specify container image(s) to run.
In our case, we want to run single Datero container.
All-inclusive Datero image is available on [Docker Hub](https://hub.docker.com/r/chumaky/datero).
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