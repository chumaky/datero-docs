docker run -d --name datero \
    -p 80:80 -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    -v "$(pwd)/data:/data" \
    -v "$(pwd)/config.yaml:/home/instance/config.yaml" \
    chumaky/datero
