# https://github.com/percona/proxysql_exporter.git
#
# Takes about 2 1/2 minutes to run the following
# docker ps -a |grep -v CONTAINER |awk '{print $1}' |xargs docker stop
# docker ps -a |grep -v CONTAINER |awk '{print $1}' |xargs docker rm
# docker rmi --force proxysql-exporter; docker build -t proxysql-exporter .
# docker run --name px -d proxysql-exporter
# docker exec -it px bash uptime

# docker stop mgr; docker rm mgr; docker rmi mgr

# sudo docker save -o proxysql-exporter proxysql-exporter
# sudo docker load -i <path to image tar file>

# https://github.com/dockerfile/ubuntu
# Sysbench info
# https://packagecloud.io/akopytov/sysbench/install

FROM  ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  apt-get install -y dnsutils && \
  apt-get install -y python && \
  apt-get install -y jq && \
  apt-get install -y python-mysqldb && \
  apt-get install -y python-yaml && \
  apt-get -y install python-pip && \
  pip install click && \
  apt-get install -y mysql-client-5.6 && \
  curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | bash && \
  apt-get update && \
  apt-get install -y sysbench && \
  rm -rf /var/lib/apt/lists/*

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Append to .bashrc
RUN \
echo '# Setup connection aliases' >> /root/.bashrc && \
echo 'set -o vi' >> /root/.bashrc && \
echo 'alias proxy-admin="mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin)"' >> /root/.bashrc && \
echo 'alias proxy-sql="mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-sql)"' >> /root/.bashrc && \
echo 'alias master="mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=master)"' >> /root/.bashrc && \
echo 'alias slave="mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=slave)"' >> /root/.bashrc && \
echo 'alias mysqla="mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=mysqla)"' >> /root/.bashrc && \
echo 'alias mysqlb="mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=mysqlb)"' >> /root/.bashrc && \
echo 'export PATH="${PATH}:/usr/local/scripts"' >> /root/.bashrc

CMD /bin/bash -c "while true; do uptime; sleep 60;done"

