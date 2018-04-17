#!/bin/bash

docker-compose up -d

ansible-playbook -i inventory proxysql.yml
