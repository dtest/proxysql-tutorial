#!/bin/bash
#
# Instructions:
#     From your vm wget this file.
#     o wget https://raw.githubusercontent.com/dtest/proxysql-tutorial/master/setup.sh
#     o chmod 755 setup.sh
#     o ./setup.sh
#
# Misc:
#     To remove all containers
#     cd <the plam dir>
#     docker-compose stop && docker-compose rm -vf # kills the containers
#

CWD=$(pwd)
PLAM_DIR="proxysql-tutorial"
ANSIBLE_DIR="proxysql_ansible_modules"
DATE=$(date +"%s")
LOG_FILE="setup_${DATE}.log"

# Do the permissions as very first thing.
if [ $(grep docker /etc/group |wc -l) -lt 1 ];then
    sudo groupadd docker
    sudo usermod -aG docker $USER
    echo
    echo "========================================================================"
    echo "Permissions need updating. Will exit in 5s for changes to take effect"
    echo "Log back in and re-run script to continue."
    echo "========================================================================"
    echo
    echo "Sleeping 5 before exiting."
    sleep 5
    kill -HUP $PPID
fi

echo "Confirmed permissions. Continuing"
echo
sleep 1

if [ ! -e ${PLAM_DIR} ];then

    echo "Updating apt"
    echo
    sudo apt-get update
    echo

    echo "Installing git"
    echo
    sudo apt-get -y install git
    echo

    echo "Cloning ${PLAM_DIR} repo"
    echo
    git clone https://github.com/dtest/${PLAM_DIR}.git
    echo
fi

echo "Confirmed ${PLAM_DIR} exist."
echo
echo

if [ $(dpkg -l |grep python |grep pip| wc -l) -lt 1 ];then

    exec > >(tee ${LOG_FILE}) 2>&1

    echo "============================================="
    echo "Running everything required to install docker"
    echo "============================================="
    echo
    # From: https://docs.docker.com/engine/installation/linux/ubuntulinux/
    sudo apt-get install apt-transport-https ca-certificates
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    sudo sh -c 'echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list'
    sudo apt-get update
    sudo apt-get purge lxc-docker
    apt-cache policy docker-engine
    sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual
    sudo apt-get -y install docker-engine
    sudo service docker start
    sudo docker run hello-world


    echo "============================================="
    echo "Installing pip, ansible, git, etc"
    echo "============================================="
    echo
    sudo apt-get -y install python-pip
    # Both python-dev and markupsafe appear to be required by ansible
    sudo  apt-get -y install python-dev
    sudo apt-get -y install build-essential
    sudo apt-get -y install libssl-dev
    sudo apt-get -y install libffi-dev
    sudo pip install markupsafe
    sudo pip install ansible
    sudo pip install docker-compose

    echo
    echo
    echo "=================================================="
    echo "Prep completed"
    echo "=================================================="

fi

if  [ $(docker ps |grep -v CONTAINER |wc -l) -lt 4 ] || [ $(docker ps |grep master |wc -l) -lt 1 ];then

    echo "=================================================="
    echo "Setting up docker containers"
    echo "=================================================="
    echo
    sleep 5

    cd ${PLAM_DIR}

    exec ./run_proxy.sh
    # time docker-compose pull # updates latest containers
    # time docker-compose up -d

    # echo "Giving time for containers to start; sleeping..." && sleep 50

    # cd ansible && time ansible-playbook -i inventory setup.yml

fi

cd ${CWD}/${PLAM_DIR}
exec bash
