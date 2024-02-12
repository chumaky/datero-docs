# EC2 Instance
To run Datero on ec2 instance, you need to create it first.
Exact procedure to create an ec2 is out of scope of this guide.
Please refer to the [official documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html#ec2-launch-instance) for that.
You can use any OS you want, but we will use Ubuntu 22.04 in this guide.

One thing to note is that you need to open some HTTP/HTTPS port for the ec2.
Default `80` or `443` ports will work just fine.
You can do that by setting up a security group for the ec2 instance.
For the testing purposes, you can allow inbound traffic on port `80` from anywhere.

![Security group](../../images/clouds/aws/security_group.jpg){ loading=lazy;  }

This is to allow access to the Datero web application from the outside world.
Datero serves web application through `nginx` over HTTP on port `80`.
Injecting SSL certificate into container is doable, but it is out of scope of this guide.

To connect to the instance, you could use `ssh`.
Firstly, you need to add your private key to the agent.
Aftewards, you can login to the instance by its public IP address.:

![Connect to instance](../../images/clouds/aws/instance.jpg){ loading=lazy; align=right }

```sh
$ ssh-add ~/.ssh/dev.pem 
$ ssh ubuntu@18.196.64.88
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 6.2.0-1015-aws x86_64)
ubuntu@ip-172-31-19-185:~$  
```


## Docker installation
Once ec2 instance is created, you need to install `docker` on it.
Again, exact procedure is out of scope of this guide.
You could install it from the Ubuntu itself by using `apt` or `snap` package managers.
Alternatively, you could use official [docker documentation](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) for that.

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

If you subscribed to Datero on AWS Marketplace, you can download the image from the AWS ECR.

!!! info "Available version"
    The latest version of Datero at the time of writing is `1.0.2`.
    To use other version, just replace `1.0.2` with the desired version number.
    You can check the available versions on the [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-gmlxuzixyqtoq).

```sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 709825985650.dkr.ecr.us-east-1.amazonaws.com
docker pull 709825985650.dkr.ecr.us-east-1.amazonaws.com/datero/datero:1.0.2
```

Alternatively, you could download the image from the Docker Hub.
```sh
docker pull chumaky/datero
```

!!! info "Support modes"
    Datero product is free, but by default it comes with no support.
    Our team provides paid support plans. 
    Details on available plans could be found on our [website](https://datero.tech).

    As a benefit, if you install Datero from AWS Marketplace, you get a free support for 30 days.
    This is a great way to test Datero and have a help from the team if needed.

Having the image, you can run the container.
The only mandator parameter to specify during container run is `POSTGRES_PASSWORD`.
It's dictated by the official image of underlying `postgres` database.
To have an access to the web application and database we also exposure ports `80` and `5432`.
Flag `-d` will run the container in the background.
We also name the container `datero` to be able to refer to it later.

``` sh
docker run -d --name datero \
    -p 80:80 -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    709825985650.dkr.ecr.us-east-1.amazonaws.com/datero/datero:1.0.2
```

## Access Datero UI
Now just note down the public IP address of the ec2 instance and access web application on `http://<public_ip>`.
Underlying postgres database is exposured on `5432` port.
Because of security group rules, it won't be accessible by default. 
But you can access it over ec2 _internal_ IP address from within your AWS environment.

While not recommended, you could also open 5432 port in security group.
That will make the database accessible over `<public_ip>:5432`.
Of course, don't do it for production setup!

Congratulations! You have successfully installed Datero on AWS ec2 instance.

--8<-- "include/clouds_next_steps.md"