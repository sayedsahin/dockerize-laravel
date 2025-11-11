# Build Laravel app
docker run --rm -v "$(pwd)":/app -w /app composer:2 create-project laravel/laravel src/

# Create ssl for local
mkcert -key-file ./docker/nginx/ssl/server.key -cert-file ./docker/nginx/ssl/server.crt localhost 127.0.0.1 ::1

# run in bash
docker compose exec app bash

# All image remove
docker rmi $(docker images -a -q)

# All container and images remove
docker compose down --rmi all --volumes --remove-orphans

# container stop and start
docker compose down
docker compose up -d
<!-- rebuild -->
docker-compose up -d --build

# Permission
sudo chown -R $USER:$USER src