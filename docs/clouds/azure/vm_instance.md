---
description: Running Datero on Azure VM instance.
---

To run Datero on Azure VM instance, you need to create it first.
Exact procedure of doing this is out of scope of this guide.
Please refer to the [official documentation :octicons-tab-external-16:](https://learn.microsoft.com/en-us/azure/virtual-machines/){: target="_blank" rel="noopener noreferrer" } for that.
You can use any o/s you want, but we will use [Ubuntu 22.04 :octicons-tab-external-16:](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu){: target="_blank" rel="noopener noreferrer" } in this guide.

<figure markdown>
  ![VM instance](../../images/clouds/azure/vm_instance.jpg){ loading=lazy; }
  <figcaption>VM instance</figcaption>
</figure>

Once you will create a VM you will also need to open some HTTP/HTTPS port(s).
This is to allow access to the Datero web application from the outside world.
Datero serves web application through `nginx` over HTTP on port `80`.
So, default `80` or `443` ports will work just fine.
Injecting an SSL certificate into a container is doable, but it is out of scope of this guide.
You can open ports in the `Networking` section of the VM instance settings.

<figure markdown>
  ![Firewall settings](../../images/clouds/azure/vm_firewall.jpg){ loading=lazy; }
  <figcaption>Firewall settings</figcaption>
</figure>

Datero is run as a container, so you need to have `docker` installed on the VM instance.
To install it, we should have a ssh access to the VM instance.
That's why we also have opened default ssh port `22`.

During the VM instance creation, we can override default username and create a new SSH key pair.
Azure will allow us to download the private key after the instance is created.
Assuming, that we changed username to `azure-user` and downloaded the private key to `~/.ssh/datero_azure.pem`.

To connect to our instance by its public IP we should add the private key to the ssh-agent.
Afterwards, we can connect to the instance using the `ssh` command and its public IP.

```sh
ssh-add ~/.ssh/datero_azure.pem 
ssh azure-user@20.218.144.27
```

## Docker installation
After we logged into VM, we need to install `docker` on it.
Again, exact procedure is out of scope of this guide.
You could install it from the Ubuntu itself by using `apt` or `snap` package managers.
Alternatively, you could use official [docker documentation :octicons-tab-external-16:](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository){: target="_blank" rel="noopener noreferrer" } for that.

We would advise to stick with Docker's official documentation.
For your convenience, below is a compiled version which extends official guide a bit.
Except installing docker itself, it also adds currently logged in user to the `docker` group.
This is to allow running docker commands without `sudo` prefix.

??? abstract "Docker installation on Ubuntu 22.04"
    ```sh  linenums="1"
    --8<-- "docs/clouds/gcp/vm_setup.sh"
    ```


## Datero installation
Once you have `docker` installed, you can run Datero container.
Firstly, download the image.
```sh
docker pull chumaky/datero
```

Having the image, you can run the container.
The only mandator parameter to specify during container run is `POSTGRES_PASSWORD`.
It's dictated by the official image of `postgres` database.
To have an access to the web application and database we also exposure ports `80` and `5432`.
Flag `-d` will run the container in the background.
We also name the container `datero` to be able to refer to it later.

``` sh
docker run -d --name datero \
    -p 80:80 -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    chumaky/datero
```

## Access Datero UI
Now just note down the public `20.218.144.27` IP address of the VM instance and access web application on `http://<public_ip>`.

<figure markdown>
  ![Access Datero UI](../../images/clouds/azure/vm_datero_ui.jpg){ loading=lazy; }
  <figcaption>Access Datero UI</figcaption>
</figure>

Underlying postgres database is exposured on `5432` port.
Because of firewall, it won't be accessible by default. 
But you can access it over your VM instance _private_ IP address from within your Azure environment.
While not recommended, you could also open 5432 port on your instance firewall.
That will make the database accessible over `<public_ip>:5432`.
Of course, don't do it for production setup!

Congratulations! You have successfully installed Datero on Azure VM instance.

--8<-- "include/clouds_next_steps.md"