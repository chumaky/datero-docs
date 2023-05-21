# Installation

`Datero` is available in containerized format.
There are two ways to run it:

- Single all-inclusive container
- Multiple containers with `docker-compose`. It includes the following services:
    - Datero database engine
    - API
    - Web application

## Single container
All inclusive image is a good choice for _try it out_ purposes. It encapsulates within itself all three components listed above.

Each service writes its logs to the standard output, so standard `docker logs` command will contain a merged view of them.

Image is available on [Docker Hub](https://hub.docker.com/r/chumaky/datero).

### Running
To get the image, run the following command:

=== "docker"
    ``` sh
    docker pull chumaky/datero
    ```
=== "podman"
    ``` sh
    podman pull docker.io/chumaky/datero
    ```

All-inclusive container contains all three services, so it exposes a couple of ports.
One for the web application and one for the database.

As a minimum, you will need at least one port for the web application.
Internally, the web application is running on port 80, so you can map it to any port you want.
If you want to use the database, you will need to map also internal 5432 port for the database.

API is accessible through the web application under the `/api` path, so you don't need to expose it separately.
Alternatively, you could use [datero](https://pypi.org/project/datero/) python package to access the API directly.


=== "docker"
    ``` sh
    docker run -d --name datero \
        -p 8080:80 -p 5432:5432 \
        -e POSTGRES_PASSWORD=postgres \
        chumaky/datero
    ```

=== "podman"
    ``` sh
    podman run -d --name datero \
        -p 8080:80 -p 5432:5432 \
        -e POSTGRES_PASSWORD=postgres \
        docker.io/chumaky/datero
    ```