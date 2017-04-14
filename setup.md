ProxySQL
====

# Configuration


## Configure MySQL Server

```sql
mysql> INSERT INTO mysql_servers(hostgroup_id,hostname,port) VALUES (1,'mysql',3306);
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM mysql_servers;
+--------------+----------+------+--------+--------+-------------+-----------------+---------------------+
| hostgroup_id | hostname | port | status | weight | compression | max_connections | max_replication_lag |
+--------------+----------+------+--------+--------+-------------+-----------------+---------------------+
| 1            | mysql    | 3306 | ONLINE | 1      | 0           | 1000            | 0                   |
+--------------+----------+------+--------+--------+-------------+-----------------+---------------------+
1 row in set (0.00 sec)
```

## Configure monitoring

```sql
# On MySQL Backend
mysql> CREATE USER `proxysql`@`%` IDENTIFIED BY 'monitor';
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE DATABASE proxysql;
Query OK, 1 row affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON proxysql.* TO `proxysql`@`%`;
Query OK, 0 rows affected (0.00 sec)

# On ProxySQL
mysql> UPDATE global_variables SET variable_value='proxysql' WHERE variable_name='mysql-monitor_username';
Query OK, 1 row affected (0.00 sec)

mysql> UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_password';
Query OK, 1 row affected (0.00 sec)

mysql> UPDATE global_variables SET variable_value='2000' WHERE variable_name IN ('mysql-monitor_connect_interval','mysql-monitor_ping_interval','mysql-monitor_read_only_interval');
Query OK, 3 rows affected (0.01 sec)

mysql> SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-monitor_%';
+----------------------------------------+---------------------------------------------------+
| variable_name                          | variable_value                                    |
+----------------------------------------+---------------------------------------------------+
| mysql-monitor_history                  | 600000                                            |
| mysql-monitor_connect_interval         | 2000                                              |
| mysql-monitor_connect_timeout          | 200                                               |
| mysql-monitor_ping_interval            | 2000                                              |
| mysql-monitor_ping_timeout             | 100                                               |
| mysql-monitor_read_only_interval       | 2000                                              |
| mysql-monitor_read_only_timeout        | 100                                               |
| mysql-monitor_replication_lag_interval | 10000                                             |
| mysql-monitor_replication_lag_timeout  | 1000                                              |
| mysql-monitor_username                 | proxysql                                          |
| mysql-monitor_password                 | monitor                                           |
| mysql-monitor_query_variables          | SELECT * FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES |
| mysql-monitor_query_status             | SELECT * FROM INFORMATION_SCHEMA.GLOBAL_STATUS    |
| mysql-monitor_query_interval           | 60000                                             |
| mysql-monitor_query_timeout            | 100                                               |
| mysql-monitor_timer_cached             | true                                              |
| mysql-monitor_writer_is_also_reader    | true                                              |
+----------------------------------------+---------------------------------------------------+
17 rows in set (0.00 sec)

mysql> SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start DESC LIMIT 10;
+----------+------+------------------+----------------------+----------------------------------------------------------------------+
| hostname | port | time_start       | connect_success_time | connect_error                                                        |
+----------+------+------------------+----------------------+----------------------------------------------------------------------+
| mysql    | 3306 | 1461721642018086 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721640016054 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721638015883 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721636015329 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721634014988 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721632013987 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721630013139 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721628012512 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721626012316 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
| mysql    | 3306 | 1461721624011706 | 0                    | Access denied for user 'proxysql'@'172.17.0.3' (using password: YES) |
+----------+------+------------------+----------------------+----------------------------------------------------------------------+
10 rows in set (0.00 sec)

mysql> SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start DESC LIMIT 10;
+----------+------+------------------+----------------------+---------------+
| hostname | port | time_start       | connect_success_time | connect_error |
+----------+------+------------------+----------------------+---------------+
| mysql    | 3306 | 1461721700065634 | 614                  | NULL          |
| mysql    | 3306 | 1461721698064910 | 599                  | NULL          |
| mysql    | 3306 | 1461721696063772 | 499                  | NULL          |
| mysql    | 3306 | 1461721694062771 | 578                  | NULL          |
| mysql    | 3306 | 1461721692059852 | 582                  | NULL          |
| mysql    | 3306 | 1461721690056359 | 519                  | NULL          |
| mysql    | 3306 | 1461721688055673 | 623                  | NULL          |
| mysql    | 3306 | 1461721686049988 | 637                  | NULL          |
| mysql    | 3306 | 1461721684044156 | 830                  | NULL          |
| mysql    | 3306 | 1461721682042734 | 480                  | NULL          |
+----------+------+------------------+----------------------+---------------+
10 rows in set (0.00 sec)
```

## Configure MySQL Users

```sql
mysql> INSERT INTO mysql_users(username,password,default_hostgroup) VALUES ('proxysql','monitor',1);
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM mysql_users;
+----------+----------+--------+---------+-------------------+----------------+---------------+------------------------+--------------+---------+----------+-----------------+
| username | password | active | use_ssl | default_hostgroup | default_schema | schema_locked | transaction_persistent | fast_forward | backend | frontend | max_connections |
+----------+----------+--------+---------+-------------------+----------------+---------------+------------------------+--------------+---------+----------+-----------------+
| proxysql | monitor  | 1      | 0       | 1                 | NULL           | 0             | 0                      | 0            | 1       | 1        | 10000           |
+----------+----------+--------+---------+-------------------+----------------+---------------+------------------------+--------------+---------+----------+-----------------+
1 row in set (0.00 sec)

mysql> LOAD MYSQL USERS TO RUNTIME;
Query OK, 0 rows affected (0.00 sec)

mysql> SAVE MYSQL USERS TO DISK;
Query OK, 0 rows affected (0.01 sec)
```

## Configure mirroring

```sql
mysql> INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,destination_hostgroup,apply) VALUES (1,1,'proxysql','^SELECT',1,0);
Query OK, 1 row affected (0.00 sec)

mysql> INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,destination_hostgroup,apply) VALUES (2,1,'proxysql','^SELECT',2,0);
Query OK, 1 row affected (0.00 sec)

mysql> SELECT match_digest,destination_hostgroup FROM mysql_query_rules WHERE active=1 ORDER BY rule_id;
+--------------+-----------------------+
| match_digest | destination_hostgroup |
+--------------+-----------------------+
| ^SELECT      | 1                     |
| ^SELECT      | 2                     |
+--------------+-----------------------+
2 rows in set (0.00 sec)

docker run --link proxysql:proxysql -it dtestops/mysqldev mysql -uproxysql -p -h proxysql -P 6033 -e "SHOW TABLES;SELECT @@port;"
Enter password:
ERROR 1045 (#2800) at line 1: Max connect timeout reached while reaching hostgroup 1 after 10001ms
```
