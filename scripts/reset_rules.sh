#!/bin/bash

stmt="
DELETE FROM
  mysql_query_rules
WHERE
  rule_id in (2,101)
"
mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin) -e "$stmt"

stmt="LOAD MYSQL QUERY RULES TO RUNTIME"
mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin) -e "$stmt"

stmt="SAVE MYSQL QUERY RULES TO DISK;"
mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin) -e "$stmt"
