# Failover
## Terminal 1
```
# ProxySQL's admin interface
SELECT hostgroup_id, hostname, status FROM mysql_servers
WHERE hostname IN ('master', 'slave')\G
SELECT * FROM mysql_replication_hostgroups\G


# ProxySQL's mysql interface
./mysql -h proxy-sql -u plam_rewrite
USE plam
CREATE TABLE foo (id tinyint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT);
INSERT INTO foo VALUES (NULL);
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
## Terminal 1

```
# proxy admin
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
```

## Terminal 2

```
# mysqla
SELECT * FROM foo;

# mysqlb
SELECT * FROM foo;
```
