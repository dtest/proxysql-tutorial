#!/usr/bin/env python

# http://click.pocoo.org/5/quickstart/

import click
import MySQLdb as mdb
import os.path
import sys
import yaml


def get_login_info():
    # this needs to be changed for when it hits 
    # proxy client directly within the container
    filename = "/usr/local/ansible/group_vars/all.yml"

    if not os.path.exists(filename):
        sys.exit("Error: {0} not found.".format(filename))

    with open(filename, 'r') as f:
        doc = yaml.load(f)

    return {"user": doc["proxysql_rewriteuser"]["user"],
            "password": doc["proxysql_rewriteuser"]["password"],
            "host":"proxysql",
            "port":6033,
           }

def connect():
    login_info = get_login_info()

    if login_info['password'] == "unset":
        return mdb.connect(host=login_info['host'],
                           port=login_info['port'],
                           user=login_info['user'],
                          )

    return mdb.connect(host=login_info['host'],
                       port=login_info['port'],
                       user=login_info['user'],
                       passwd=login_info['password'],
                      )

def run_sql(stmt, output="stdout"):
    """
    Run any sql passed via stmt
    stmt = the sql stmt to run
    output = valid options are return, stdout, and None
    """
    conn = connect()

    cur = conn.cursor(mdb.cursors.DictCursor)
    cur.execute(stmt)
    rows = cur.fetchall()

    if output == "stdout":
        for row in rows:
            print row
    elif output == "return":
        return rows
