#!/bin/bash

# Install Docker and Docker Compose
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# Create directories for Nextcloud and ONLYOFFICE
sudo mkdir -p /opt/nextcloud
sudo mkdir -p /opt/onlyoffice

# Create a Docker network for Nextcloud and the external database
sudo docker network create nextcloud_network

# Create the external MariaDB database container
sudo docker run -d \
  --name=nextcloud_db \
  --restart=always \
  --network=nextcloud_network \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_DATABASE=nextcloud \
  -e MYSQL_USER=nextcloud \
  -v /opt/db:/var/lib/mysql \
  mariadb

# Clone the Nextcloud Docker image from the official repository
sudo docker pull nextcloud

# Clone the ONLYOFFICE Docker image from the official repository
sudo docker pull onlyoffice/documentserver

# Create a Docker Compose file for Nextcloud and ONLYOFFICE
sudo tee /opt/docker-compose.yaml <<EOF
version: '3'
services:
  app:
    image: nextcloud
    restart: always
    ports:
      - 80:80
    links:
      - db
    volumes:
      - /opt/nextcloud:/var/www/html
    environment:
      MYSQL_PASSWORD: password
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_HOST: nextcloud_db
  onlyoffice:
    image: onlyoffice/documentserver
    restart: always
    ports:
      - 8888:80
    volumes:
      - /opt/onlyoffice:/var/www/onlyoffice/Data
    environment:
      MYSQL_PASSWORD: password
      MYSQL_DATABASE: onlyoffice
      MYSQL_USER: onlyoffice
      MYSQL_HOST: nextcloud_db
networks:
  default:
    external:
      name: nextcloud_network
EOF

# Start the Nextcloud and ONLYOFFICE containers
sudo docker-compose -f /opt/docker-compose.yaml up -d
