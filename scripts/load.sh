#!/bin/bash

stmt="
DELETE FROM
  mysql_query_rules
WHERE
  rule_id=101
"
mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin) -e "$stmt"

# Example sql to rewrite:
#     SELECT /* Sleeping process */ sleep(5)
#
stmt="
    INSERT INTO
        mysql_query_rules (rule_id,
                           active,
                           flagIN,
                           match_pattern,
                           replace_pattern)
    VALUES (101,1,0,
           '(SELECT .*) sleep\((\d+)\)',
           '\1 sleep(1)'
           )
"
# confirmed works
#
#            'SELECT .* sleep\((\d+)\)',
#            'SELECT /* Sleeping process \1 */ sleep(1)'
#
#            'SELECT .* sleep\((\d+)\)',
#            'SELECT /* Sleeping process \1 */ sleep(\1+9)'
#
#            'SELECT .* sleep\((\d+)\)',
#            'SELECT /* Sweeping process */ sleep(\1)'
#
#            'SELECT .* sleep\(\d+\)',
#            'SELECT /* Sweeping process */ sleep(2)'
#
#            'SELECT .* sleep\(5\)',
#            'SELECT /* Sweeping process */ sleep(5)'

mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin) -e "$stmt"

stmt="LOAD MYSQL QUERY RULES TO RUNTIME"
mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin) -e "$stmt"

stmt="SAVE MYSQL QUERY RULES TO DISK;"
mysql --defaults-file=<(/usr/local/scripts/get_pass.py --host=proxy-admin) -e "$stmt"


