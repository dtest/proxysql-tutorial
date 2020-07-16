
### Installation
ProxySQL binaries are available from https://github.com/sysown/proxysql/releases.  
Just download and use the package manager to install it.  
Ex:
```bash
wget https://github.com/sysown/proxysql/releases/download/v1.3.5/proxysql_1.3.5-ubuntu14_amd64.deb
dpkg -i proxysql_1.3.5-ubuntu14_amd64.deb
```

### Service management
Once the software is installed, you can use `service` to start or stop it.  
#### Start:
```bash
service proxysql start
```
#### Stop:
```bash
service proxysql stop
```



### Check version
```bash
$ proxysql --version
```
```bash
ProxySQL version 1.3.5-0-g10bf524, codename Truls
```
A debug version has `_DEBUG` in its version string.
It is slower than non-debug version, but easier to debug in case of failures.

* check processes running:
```bash
ps aux | grep proxysql | grep -v grep
root      4261  0.0  0.1  31760  3080 ?        S    22:49   0:00 proxysql -c /etc/proxysql.cnf -D /var/lib/proxysql
root      4262  3.0  0.3 171628  6396 ?        Sl   22:49   0:00 proxysql -c /etc/proxysql.cnf -D /var/lib/proxysql
```
Why two processes?


* check which sockets are open:
```bash
netstat -nap | grep proxysql
```
Output:
```bash
tcp        0      0 127.0.0.1:6032          0.0.0.0:*               LISTEN      4262/proxysql
tcp        0      0 0.0.0.0:6033            0.0.0.0:*               LISTEN      4262/proxysql
unix  2      [ ACC ]     STREAM     LISTENING     8197     4262/proxysql       /tmp/proxysql.sock
unix  2      [ ACC ]     STREAM     LISTENING     8062     4262/proxysql       /tmp/proxysql_admin.sock
```

* check opened file
```bash
lsof -n -p 4261
lsof -n -p 3262
```

Why 2 processes? Angel process and real process.


## Admin Interface
#### login as `admin`
Use a mysql client and connect using standard credentials and endpoint. Ex:
```bash
mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='Admin> '
```
Output:
```
Warning: Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.5.30 (ProxySQL Admin Module)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

Admin>
```

#### check version
```mysql
Admin> SELECT @@version;
+------------------+
| @@version        |
+------------------+
| 1.3.5-0-g10bf524 |
+------------------+
1 row in set (0.00 sec)
```

#### list available schemas and tables
```mysql
Admin> SHOW DATABASES;
+-----+---------+-------------------------------+
| seq | name    | file                          |
+-----+---------+-------------------------------+
| 0   | main    |                               |
| 2   | disk    | /var/lib/proxysql/proxysql.db |
| 3   | stats   |                               |
| 4   | monitor |                               |
+-----+---------+-------------------------------+
4 rows in set (0.00 sec)
```
```mysql
Admin> SHOW TABLES FROM main;
+--------------------------------------+
| tables                               |
+--------------------------------------+
| global_variables                     |
| mysql_collations                     |
| mysql_query_rules                    |
| mysql_replication_hostgroups         |
| mysql_servers                        |
| mysql_users                          |
| runtime_global_variables             |
| runtime_mysql_query_rules            |
| runtime_mysql_replication_hostgroups |
| runtime_mysql_servers                |
| runtime_mysql_users                  |
| runtime_scheduler                    |
| scheduler                            |
+--------------------------------------+
13 rows in set (0.00 sec)
```
```mysql
Admin> SHOW TABLES LIKE 'runtime%';
+--------------------------------------+
| tables                               |
+--------------------------------------+
| runtime_mysql_servers                |
| runtime_mysql_users                  |
| runtime_mysql_replication_hostgroups |
| runtime_mysql_query_rules            |
| runtime_global_variables             |
| runtime_scheduler                    |
+--------------------------------------+
6 rows in set (0.00 sec)
```
```mysql
Admin> SHOW TABLES FROM disk;
+------------------------------+
| tables                       |
+------------------------------+
| global_variables             |
| mysql_collations             |
| mysql_query_rules            |
| mysql_replication_hostgroups |
| mysql_servers                |
| mysql_users                  |
| scheduler                    |
+------------------------------+
7 rows in set (0.00 sec)
```
```mysql
Admin> SHOW TABLES FROM stats;
+--------------------------------+
| tables                         |
+--------------------------------+
| global_variables               |
| stats_mysql_commands_counters  |
| stats_mysql_connection_pool    |
| stats_mysql_global             |
| stats_mysql_processlist        |
| stats_mysql_query_digest       |
| stats_mysql_query_digest_reset |
| stats_mysql_query_rules        |
+--------------------------------+
8 rows in set (0.00 sec)
```
```mysql
Admin> SHOW TABLES FROM monitor;
+----------------------------------+
| tables                           |
+----------------------------------+
| mysql_server_connect             |
| mysql_server_connect_log         |
| mysql_server_ping                |
| mysql_server_ping_log            |
| mysql_server_read_only_log       |
| mysql_server_replication_lag_log |
+----------------------------------+
6 rows in set (0.00 sec)
```
This is NOT really a MySQL server. Not all commands are supported.
For example, `USE` is not supported.
For example:
```mysql
USE main;
SHOW TABLES;
USE stats;
SHOW TABLES;
```

## Global variables
```mysql
Admin> SHOW CREATE TABLE global_variables\G
*************************** 1. row ***************************
       table: global_variables
Create Table: CREATE TABLE global_variables (
    variable_name VARCHAR NOT NULL PRIMARY KEY,
    variable_value VARCHAR NOT NULL)
1 row in set (0.01 sec)
```

* list all variables
```mysql
SELECT * FROM global_variables;
```

* list all Admin related variables
```mysql
SELECT * FROM global_variables WHERE variable_name LIKE 'admin-%';
```

* list all MySQL related variables
```mysql
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-%';
```

* list all variables related to MySQL Monitor
```mysql
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-%monitor%' ORDER BY variable_name;
```

## How to change variable?

* method #1
```mysql
Admin> UPDATE global_variables SET variable_value=1000 WHERE variable_name='mysql-monitor_ping_interval';
Query OK, 1 row affected (0.01 sec)
```

* method #2
```mysql
Admin> SET mysql-monitor_ping_interval=1000;
Query OK, 1 row affected (0.00 sec)
```

* Some exception:
```mysql
Admin> SET mysql-init_connect='SET wait_timeout=100';
ERROR 1045 (#2800): ERROR: Global variable 'mysql-init_connect' is not configurable using SET command. You must run UPDATE global_variables
Admin> UPDATE global_variables SET variable_value="SET wait_timeout=100" WHERE variable_name='mysql-init_connect';
Query OK, 1 row affected (0.01 sec)
```


## runtime variables
```mysql
Admin> SELECT * FROM runtime_global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%' ORDER BY variable_name;
+---------------------------------+----------------+
| variable_name                   | variable_value |
+---------------------------------+----------------+
| mysql-monitor_ping_interval     | 10000          |
| mysql-monitor_ping_max_failures | 3              |
| mysql-monitor_ping_timeout      | 1000           |
+---------------------------------+----------------+
3 rows in set (0.01 sec)
```
Why aren't variables loaded at runtime immediately?
See [wiki](https://github.com/sysown/proxysql/wiki/Multi-layer-configuration-system)

- allows to verify changes before applying them.
- all changes are loaded atomically.
- allows rollback in case of mistakes (`UPDATE global_variables SET variable_value=2000` ... without `WHERE`).

```mysql
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM disk.global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM runtime_global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
LOAD MYSQL VARIABLES TO RUNTIME;
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM disk.global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM runtime_global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SAVE MYSQL VARIABLES TO DISK;
SET mysql-monitor_ping_interval=100000;
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM disk.global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM runtime_global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SAVE MYSQL VARIABLES FROM RUNTIME;
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM disk.global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM runtime_global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
LOAD MYSQL VARIABLES FROM DISK;
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM disk.global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
SELECT * FROM runtime_global_variables WHERE variable_name LIKE 'mysql-%monitor%ping%val' ORDER BY variable_name;
```

## MySQL Servers : backends
```mysql
Admin> SELECT * FROM mysql_servers;
Empty set (0.00 sec)

Admin> SHOW CREATE TABLE mysql_servers\G
*************************** 1. row ***************************
       table: mysql_servers
Create Table: CREATE TABLE mysql_servers (
    hostgroup_id INT NOT NULL DEFAULT 0,
    hostname VARCHAR NOT NULL,
    port INT NOT NULL DEFAULT 3306,
    status VARCHAR CHECK (UPPER(status) IN ('ONLINE','SHUNNED','OFFLINE_SOFT', 'OFFLINE_HARD')) NOT NULL DEFAULT 'ONLINE',
    weight INT CHECK (weight >= 0) NOT NULL DEFAULT 1,
    compression INT CHECK (compression >=0 AND compression <= 102400) NOT NULL DEFAULT 0,
    max_connections INT CHECK (max_connections >=0) NOT NULL DEFAULT 1000,
    max_replication_lag INT CHECK (max_replication_lag >= 0 AND max_replication_lag <= 126144000) NOT NULL DEFAULT 0,
    use_ssl INT CHECK (use_ssl IN(0,1)) NOT NULL DEFAULT 0,
    max_latency_ms INT UNSIGNED CHECK (max_latency_ms>=0) NOT NULL DEFAULT 0,
    comment VARCHAR NOT NULL DEFAULT '',
    PRIMARY KEY (hostgroup_id, hostname, port) )
1 row in set (0.00 sec)
```
```mysql
Admin> SELECT * FROM mysql_servers;
Empty set (0.00 sec)

Admin> INSERT INTO mysql_servers (hostgroup_id, hostname, port, weight) VALUES (0,'127.0.0.1',3306,10);
Query OK, 1 row affected (0.00 sec)

Admin> SELECT * FROM mysql_servers\G
*************************** 1. row ***************************
       hostgroup_id: 0
           hostname: 127.0.0.1
               port: 3306
             status: ONLINE
             weight: 10
        compression: 0
    max_connections: 1000
max_replication_lag: 0
            use_ssl: 0
     max_latency_ms: 0
            comment:
1 row in set (0.00 sec)

Admin> SELECT * FROM runtime_mysql_servers;
Empty set (0.00 sec)
```
```mysql
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
LOAD MYSQL SERVERS FROM DISK;
SAVE MYSQL SERVERS FROM RUNTIME;
```
```mysql
Admin> SHOW CREATE TABLE mysql_users\G
*************************** 1. row ***************************
       table: mysql_users
Create Table: CREATE TABLE mysql_users (
    username VARCHAR NOT NULL,
    password VARCHAR,
    active INT CHECK (active IN (0,1)) NOT NULL DEFAULT 1,
    use_ssl INT CHECK (use_ssl IN (0,1)) NOT NULL DEFAULT 0,
    default_hostgroup INT NOT NULL DEFAULT 0,
    default_schema VARCHAR,
    schema_locked INT CHECK (schema_locked IN (0,1)) NOT NULL DEFAULT 0,
    transaction_persistent INT CHECK (transaction_persistent IN (0,1)) NOT NULL DEFAULT 0,
    fast_forward INT CHECK (fast_forward IN (0,1)) NOT NULL DEFAULT 0,
    backend INT CHECK (backend IN (0,1)) NOT NULL DEFAULT 1,
    frontend INT CHECK (frontend IN (0,1)) NOT NULL DEFAULT 1,
    max_connections INT CHECK (max_connections >=0) NOT NULL DEFAULT 10000,
    PRIMARY KEY (username, backend),
    UNIQUE (username, frontend))
1 row in set (0.00 sec)
```

## update config file
#### (and why doesn't work)

```bash
vi /etc/proxysql.cnf
service proxysql restart
```
```mysql
Admin> SHOW VARIABLES LIKE 'mysql-default_query_timeout';
```


### Upgrade
Install the new package and restart.  
Ex:
```bash
wget https://github.com/sysown/proxysql/releases/download/v1.3.6/proxysql_1.3.6-ubuntu14_amd64.deb
dpkg -i proxysql_1.3.6-ubuntu14_amd64.deb
service proxysql restart
```
