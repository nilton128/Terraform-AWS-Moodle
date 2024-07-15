#!/bin/bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce -y
sudo service docker start
sudo systemctl enable docker

docker volume create --name mariadb_data
docker network create moodle-network
docker run -d --name mariadb --env ALLOW_EMPTY_PASSWORD=yes --env MARIADB_USER=bn_moodle --env MARIADB_PASSWORD=bitnami --env MARIADB_DATABASE=bitnami_moodle --network moodle-network --volume mariadb_data:/bitnami/mariadb bitnami/mariadb:latest
docker run -d --name moodle -p 8080:8080 -p 8443:8443 --env ALLOW_EMPTY_PASSWORD=yes --env MOODLE_DATABASE_USER=bn_moodle --env MOODLE_DATABASE_PASSWORD=bitnami --env MOODLE_DATABASE_NAME=bitnami_moodle --network moodle-network --volume moodle_data:/bitnami/moodle bitnami/moodle:latest






