---
description: Configuration of the Datero data platform.
---

# Configuration
Datero is a containerized application that is shipped as a single Docker image.
When you run it, you can provide configuration parameters to customize its behavior.
This document describes the configuration options available for Datero.


## Environment variables
Datero database engine is based on the official PostgreSQL Docker image.
It supports all the environment variables that are supported by the PostgreSQL image.


## Application configuration

```sh
docker run -d --rm --name datero_mount \
    -p 80:80 -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    -v "$(pwd)/data:/home/data" \
    -v "$(pwd)/mkdocs.yml:/home/instance/config.yaml" \
    chumaky/datero
```

## Data mounts


## Logs