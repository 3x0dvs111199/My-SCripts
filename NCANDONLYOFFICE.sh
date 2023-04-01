#!/bin/bash

# Install Docker and Docker Compose
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# Create directories for Nextcloud and ONLYOFFICE
sudo mkdir -p /opt/nextcloud
sudo mkdir -p /opt/onlyoffice

# Clone the Nextcloud Docker image from the official repository
sudo docker pull nextcloud

# Clone the ONLYOFFICE Docker image from the official repository
sudo docker pull onlyoffice/documentserver

# Create a Docker Compose file for Nextcloud and ONLYOFFICE
sudo tee /opt/docker-compose.yaml <<EOF
version: '3'
services:
  db:
    image: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_PASSWORD: password
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
    volumes:
      - /opt/db:/var/lib/mysql
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
      MYSQL_HOST: db
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
      MYSQL_HOST: db
EOF

# Start the Nextcloud and ONLYOFFICE containers
sudo docker-compose -f /opt/docker-compose.yaml up -d
