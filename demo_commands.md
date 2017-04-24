# Failover

## How to use

```
cd ~/proxysql-tutorial/

# start containers
./run_proxy.sh

# connect to proxy-admin
./mysql -h proxy-admin

# connect to proxy-sql
./mysql -h proxy-sql -u plam_rewrite #FailoverDemo

# connect to master
./mysql -h master

# connect to slave
./mysql -h slave
```

## Terminal 1
```
# ProxySQL's admin interface
./mysql -h proxy-admin
SELECT hostgroup_id, hostname, status FROM mysql_servers
WHERE hostname IN ('master', 'slave')\G
SELECT * FROM mysql_replication_hostgroups\G


# ProxySQL's mysql interface
./mysql -h proxy-sql -u plam_rewrite
USE plam
CREATE TABLE foo (id tinyint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT);
INSERT INTO foo VALUES (NULL);

# mysql
./mysql -h master
SELECT * FROM plam.foo;
exit # logout #
docker-compose stop master

# set read_only on slave
./mysql -h slave
SET GLOBAL read_only=0;
```

## Terminal 2

```
./mysql -h master
USE plam
SELECT * FROM foo;
exit # logout #
docker-compose stop master

# set read_only on slave
./mysql -h slave
SET GLOBAL read_only=1;
```

# Mirroring
## How to use

```
cd ~/proxysql-tutorial/

# start containers
./run_proxy.sh

# connect to proxy-admin
./mysql -h proxy-admin

# connect to proxy-sql
./mysql -h proxy-sql -u plam_mirror

# connect to mysql 5.6
./mysql -h mysqla

# connect to mysql 5.7
./mysql -h mysqlb
```

## Terminal 1

```
# proxy admin
./mysql -h proxy-admin
SELECT hostgroup_id, hostname, status FROM mysql_servers
WHERE hostname IN ('mysqla', 'mysqlb')\G
SELECT username, default_hostgroup FROM mysql_users where username='plam_mirror'\G

SELECT username, mirror_hostgroup, mirror_flagOUT FROM mysql_query_rules WHERE username='plam_mirror'\G

# proxy-sql interface
USE plam
CREATE TABLE foo (id tinyint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT);
INSERT INTO foo VALUES (NULL);
INSERT INTO foo VALUES (NULL);
INSERT INTO foo VALUES (NULL);

# proxy admin
SELECT hostgroup_id, hostname, status FROM mysql_servers
WHERE hostname IN ('mysqla', 'mysqlb')\G
SELECT username, default_hostgroup FROM mysql_users where username='plam_mirror'\G

SELECT username, mirror_hostgroup, mirror_flagOUT FROM mysql_query_rules WHERE username='plam_mirror'\G

SELECT hostgroup hg, srv_host, Queries FROM stats_mysql_connection_pool WHERE hostgroup IN (3,4);

SELECT hostgroup hg, digest_text, count_star FROM stats_mysql_query_digest
WHERE hostgroup IN (3,4);

# proxy-sql interface
./mysql -h proxy-sql -u plam_mirror
USE plam
CREATE TABLE foo (id tinyint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT);
INSERT INTO foo VALUES (NULL);

SELECT * FROM stats_mysql_query_digest WHERE hostgroup IN (3,4) AND digest_text LIKE "INSERT%"\G
```

## Terminal 2

```
# mysqla
SELECT * FROM foo;

# mysqlb
SELECT * FROM foo;
```
