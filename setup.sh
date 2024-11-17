#!/bin/bash

sudo docker apt update
sudo apt-get install qemu-system binfmt-support qemu-user-static \
    docker-buildx docker-compose-v2 docker.io
sudo sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
