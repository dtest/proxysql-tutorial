#!/usr/bin/env python

# http://click.pocoo.org/5/quickstart/

import click
import MySQLdb as mdb
import os.path
import sys
import yaml

from pprint import pprint

@click.command()
@click.option("--host", default="master",
              help="The MySQL or ProxySQL host to connect with.")
def main(host):

    file = "/usr/local/ansible/group_vars/all.yml"

    with open(file, 'r') as f:
        doc = yaml.load(f)

    #   - proxy-admin: admin interface for proxysql
    #   - proxy-sql: SQL interface of proxysql
    #   - master: Master container for the rewrite and failover demonstrations
    #   - slave: Slave container for the rewrite and failover demonstrations
    #   - mysqla: MySQL 5.6 container for the mirror demonstration
    #   - mysqlb: MySQL 5.7 container for the mirror demonstration"

    if host == 'proxy-admin':
        print "[client]"
        print "user={0}".format(doc['proxysql_admin']['user'])
        print "password={0}".format(doc['proxysql_admin']['password'])
        print "host={0}".format("proxysql")
        print "port={0}".format(6032) 
    elif host == 'proxy-sql':
        print "[client]"
        print "user={0}".format(doc['proxysql_rewriteuser']['user'])
        print "password={0}".format(doc['proxysql_rewriteuser']['password'])
        print "host={0}".format("proxysql")
        print "port={0}".format(6033) 
    elif (host == 'master' or
         host == 'slave' or
         host == 'mysqla' or
         host == 'mysqlb'):
        print "[client]"
        print "user={0}".format("root")
        print "password={0}".format(doc['root_password'])
        print "host={0}".format(host)
        print "port={0}".format(3306) 
    else:
        print "Error: {0} is not a supported hostname.".format(host)

if __name__ == "__main__":

    main()

