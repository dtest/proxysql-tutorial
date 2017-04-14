#!/bin/bash
#
# Instructions:
#     From your vm wget this file.
#     o wget https://github.com/dtest/plam16-proxysql/blob/master/setup.sh
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


if [ ! -e ${PLAM_DIR} ] || [ ! -e ${ANSIBLE_DIR} ];then

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

    echo "Cloning Proxysql_ansible_modules repo"
    echo
    git clone https://github.com/bmildren/${ANSIBLE_DIR}.git
    echo

    echo "Linking in ${ANSIBLE_DIR}"
    echo
    ln -s ${CWD}/${ANSIBLE_DIR} ${CWD}/${PLAM_DIR}/ansible/library
    echo

    # echo "Getting sakila database."
    # echo
    # wget http://downloads.mysql.com/docs/sakila-db.tar.gz
    # echo

fi

echo "Confirmed ${PLAM_DIR} and ${ANSIBLE_DIR} exist."
echo
echo

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
    # This seemed to fail..
    # sudo apt-get -y install ansible
    # Was having an issue with current version of ansible
    sudo pip install ansible==2.1.1.0
    # sudo pip install ansible
    # Installed above
    # sudo apt-get -y install git
    #
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
    time docker-compose pull # updates latest containers
    time docker-compose up -d

    echo "Giving time for containers to start; sleeping..." && sleep 50

    cd ansible && time ansible-playbook -i inventory setup.yml

fi

# echo
# echo "Sleeping 5s to ensure master container is ready for sakila"
# echo
# sleep 5

# if  [ $(docker ps |grep master |wc -l) -gt 0 ];then
#     echo "Copying sakila db to master container."
#     echo
#     docker cp ${CWD}/sakila-db.tar.gz master:/var/tmp
#     echo

# fi

cd $CWD