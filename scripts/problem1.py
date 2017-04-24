#!/usr/bin/env python

from datetime import datetime
import time

from mysql_common import run_sql

if __name__ == "__main__":

    stmt = """
           SELECT /* Sleeping process */ sleep(5)
           """
    while True:
        run_sql(stmt, output=None)
        time.sleep(.3)
        print datetime.now().strftime('%Y-%m-%d %H:%M:%S')

