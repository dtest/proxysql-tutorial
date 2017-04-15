ProxySQL Tutorial
===

## Overview
Files for the ProxySQL Tutorial presented by René Cannaò, David Turner and Derek Downey

## Dependencies

- Docker
- Ansible (_version:_ 2.1.0+)
- [ProxySQL Ansible modules](https://github.com/bmildren/proxysql_ansible_modules)
    - Create a symlink in the ansible directory `library` to the ansible plugins previously copied

```bash
$ ls -l ansible/library
lrwxr-xr-x  1 dtest  staff  43 Sep 14 20:51 ansible/library -> /Users/dtest/devel/proxysql_ansible_modules
```
- Bash

## Setup

- ssh yourhost
- wget https://raw.githubusercontent.com/dtest/proxysql-tutorial/master/setup.sh
- chmod 755 setup.sh
- ./setup.sh
- ssh yourhost
- ./setup.sh

- Connect to ProxySQL Admin interface: `./mysql -h proxy-admin`
- Connect to ProxySQL SQL interface: `./mysql -h proxy-sql`
- Connect to hosts used for rewrite and failover demonstrations
    - master: `./mysql -h master`
    - slave: `./mysql -h slave`
- Connect to hosts used for mirroring demonstration
    - MySQL A (5.6): `./mysql -h mysqla`
    - MySQL B (5.7): `./mysql -h mysqlb`

## Presentation Links
This has been presented at the following events:

- [PerconaLive 2017 Santa Clara](https://www.percona.com/live/17/sessions/proxysql-tutorial)
- [PerconaLive 2016 Amsterdam](https://www.percona.com/live/plam16/sessions/proxysql-tutorial)
