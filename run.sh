image_name="open-webui"
container_name="open-webui"
host_port=3003
container_port=8080

docker build -t "$image_name" .
docker stop "$container_name" &>/dev/null || true
docker rm "$container_name" &>/dev/null || true

docker run -d -p "$host_port":"$container_port" \
    --name "$container_name" \
    --env-file .env \
    --cpus 2.0 \
    --memory 1g \
    "$image_name"

docker image prune -f
