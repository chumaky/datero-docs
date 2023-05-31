# Connectors

As described in [installation](../installation.md) section, `datero` is served in containerized format.
To get data via some connector we will need to create a connection to the source.
Hence, we need to establish a connection between `datero` container and the source.

There are three possible scenarios when it comes to containers networking:

- container to container
- container to host (localhost)
- container to external host

Description of these scenarios is a bit out of scope of this documentation.
But we will describe it shortly for the sake of clarity of the examples below.
You can find detailed information about the topic in the official [docker documentation](https://docs.docker.com/network/).


## Container to container
If your datasource is also containerized, you could leverage bridge networking.
It could be created implicitly when using `docker compose` or explicitly by `docker network create` command.
This approach is easiest to use for demo purposes and throughout this documentation we will leverage mostly on it.

Let's start `datero` container created in the [installation](../installation.md#running-the-container) section.

=== "docker"
    ``` sh
    docker start datero
    ```
=== "podman"
    ``` sh
    podman start datero
    ```

Now, let's create a docker network and attach `datero` container to it.
=== "docker"
    ``` sh
    docker network create dm
    ```
=== "podman"
    ``` sh
    podman network create dm
    ```
