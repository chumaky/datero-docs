---
description: Datero data platform available connectors. 
---

# Connectors
As described in [installation](../installation.md) section, `datero` is served in containerized format.
To get data via some connector we will need to create a connection to the source.
Hence, we need to establish a connection between `datero` container and the source.

There are three possible scenarios when it comes to containers networking:

- container to container
- container to host (localhost)
- container to external host

Description of these scenarios is a bit out of scope of this documentation.
But we will describe it shortly for the sake of clarity of the examples in next sections.
You can find detailed information about the topic in the official [docker documentation :octicons-tab-external-16:](https://docs.docker.com/network/){: target="_blank" rel="noopener noreferrer" }.


## Container to container
If your datasource is also containerized, you could leverage `bridge` networking.
It could be created implicitly when using `docker compose` or explicitly by `docker network create` command.
This approach is easiest to use for demo purposes and throughout this documentation we will leverage mostly on it.

Let's create network `c2c`.
``` sh
docker network create c2c
```

Let's spin up `nginx` web server container and connect it to the `c2c` network under the `nginx` hostname.
``` sh
docker run -d --rm --name nginx --network c2c --network-alias nginx nginx:alpine
```

Now, let's create `client` container and connect it to the `c2c` network under the `client` hostname.
It's based on `alpine` image which is very lightweight Linux distribution.
We also login into the container on startup
``` sh
docker run --rm -it --name client --network c2c --network-alias client alpine
```

Because both containers are connected to the same `c2c` network, they can communicate with each other by their hostnames.
From the `client` container we can access `nginx` container by its hostname `nginx`.
``` sh
/ # wget http://nginx
Connecting to nginx (172.20.0.3:80)
saving to 'index.html'
index.html           100% |************************************************************************************************|   615  0:00:00 ETA 
'index.html' saved
```

As you can see, we successfully connected to the `nginx` container and requested it's root page from `http://nginx` address.


## Container to host (localhost)
If your datasource is running on the host machine, there are a few possible approaches.
We will consider the most common ones.

### Host networking
It's possible to run container in a `host` network mode.
In this mode your `datero` container is not isolated from the host machine and can access its interfaces directly.
Such mode is not recommended for production usage, because has a lot of security implications.
In addition, it doesn't work on Windows or macOS. Only on Linux.

### host.docker.internal
This method will work only for Windows and macOS.
`host.docker.internal` is a special name which resolves to the internal IP address used by the host.
By using this name, you can connect to a service running on the host machine right from the container.

Let's spin up `nginx` web server container and map its 80 port to the same 80 port on a host machine (localhost).
``` sh
docker run -d --rm --name nginx -p 80:80 nginx:alpine
```
If you will now navigate to the [http://localhost](http://localhost) you will see the default `nginx` page.

Now, let's create `client` container and login into it.
``` sh
docker run --rm -it --name client alpine
```
This time there is no network connection between the `client` container and the `nginx` container.

If now we will try to access `nginx` container from the `client` container by its hostname `nginx`, we will get an error.
Same will happen for `localhost` hostname.
``` sh
/ # wget http://localhost
Connecting to localhost (127.0.0.1:80)
wget: can't connect to remote host (127.0.0.1): Connection refused
/ # wget http://nginx
wget: bad address 'nginx'
```

But if we will use `host.docker.internal` hostname, we will be able to access `nginx` container from the `client` container.
``` sh
/ # wget http://host.docker.internal
Connecting to host.docker.internal (192.168.65.2:80)
saving to 'index.html'
index.html           100% |************************************************************************************************|   615  0:00:00 ETA 
'index.html' saved
```

### Other methods
Other methods include defining host's actual IP from the network settings or using `172.17.0.1` IP address.
These aren't the only methods left. But describing them is out of scope of `datero` documentation.
You could find more information about it in the official `docker` [guide](https://docs.docker.com/network/).
For linux based `podman` - in the RedHat [blog](https://www.redhat.com/sysadmin/container-networking-podman).

## Container to external host
We already considered [container 2 container](#container-to-container) and [container 2 localhost](#container-to-host-localhost) connection scenarios.
However, the most common scenario is when your datasource is running on some _external_ host.
For example, your database is running on AWS RDS or your web server is running on some VPS.

Luckily, it's the most easiest scenario to implement.
Just because it should work out of a box for both `docker` and `podman` on _all_ operating systems: Windows, Linux, macOS.

Let's start standalone `alpine` container and login into it.
``` sh
docker run --rm -it --name standalone alpine
```

By default container is connected to the `bridge` network and could leverage DNS of the host machine.
If there is internet connection on the host machine, we can access any external host from the container.
``` sh
/ # wget https://google.com
Connecting to google.com (142.250.186.206:443)
Connecting to www.google.com (216.58.209.4:443)
saving to 'index.html'
index.html           100% |************************************************************************************************| 19246  0:00:00 ETA
'index.html' saved
```

As simply as that. 
!!! info "Connectivity to external hosts"
    You can access any external host from the container by its hostname.


## Summary
We considered three possible scenarios of containers networking.
Further sections will use [container 2 container](#container-to-container) scenario for simplicity.
By providing to container custom hostname within `bridge` netwrok we could emulate [external host connection](#container-to-external-host) scenario.
Which is the most common scenario in real cases.
