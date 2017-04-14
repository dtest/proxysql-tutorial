#!/bin/bash

# TODO: Sanity checks

CWD=$(pwd)

# Ensure latest repo
time git pull

# Clear containers
time docker-compose stop && docker-compose rm -vf # kills the containers

time docker-compose up -d

echo "Giving time for containers to start; sleeping..." && sleep 50

cd ansible && time ansible-playbook -i inventory setup.yml

cd $CWD
