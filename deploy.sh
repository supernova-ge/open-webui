image_name="wui"
container_name="wui"
host_port=8080
container_port=8080

docker build -t $image_name .
docker stop $container_name &>/dev/null || true
docker rm $container_name &>/dev/null || true

docker run -d -p $host_port:$container_port \
    --env-file .env \
    --name $container_name \
    $image_name

docker image prune -f