#!/usr/bin/env python

import time

from mysql_common import run_sql

if __name__ == "__main__":

    stmt = """
           SELECT /* My fts */ count(*) FROM sakila.rental
           """
    while True:
        run_sql(stmt, output=None)

