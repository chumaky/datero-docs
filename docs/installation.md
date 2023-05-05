# Installation

`Datero` is available in containerized format.
There are two ways to run it:

- Single all-inclusive container
- Multiple containers spin-up with `docker-compose`. It includes the following services:
  * Datero database engine
  * API
  * Web application

## Single container
All inclusive image is a good choice for _try it out_ purposes. It encapsulates within itself all three components listed above.

Each service writes its logs to the standard output, so standard `docker logs` command will contain a merged view of them.

Image is available on [Docker Hub](https://hub.docker.com/r/chumaky/datero).

### Running
To execute the image, run the following command:

```bash

```
