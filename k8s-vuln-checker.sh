#!/bin/bash


CLUSTERS=(
    s24-infinity-cluster-dev
)

get_log4j_locations () {
    local directory=$1
    sudo find $directory -type f -iname *log4j*
}

parse_container_id () {
    local CONTAINER_ID=$(sudo docker ps -a | grep $1 | awk '{print $1}')
    echo $CONTAINER_ID
}

get_docker_containers () {
    sudo docker ps -q
}

get_docker_images () {
    sudo docker images|tail -n+2
}

get_storage_directories_for () {
    local CONTAINER_ID=$1
    sudo docker inspect $CONTAINER_ID | grep -i '"/var/lib/docker/overlay2' | awk '{print $2}' | sed 's/[",]//g' |tr ':' '\n'
}
IFS=$'\n'
images=$(get_docker_images)
for image in $images; do
    IMG_NAME=$(echo $image | awk '{print $1}')
    echo "Image: $IMG_NAME"
    IMG_ID=$(echo $image | awk '{print $3}')
    storage_directories=$(get_storage_directories_for $IMG_ID)
    for storage_directory in $storage_directories; do
        # echo "Storage Directory: $storage_directory"
        if [ -d "$storage_directory" ]; then
            get_log4j_locations $storage_directory
        fi
    done
done

