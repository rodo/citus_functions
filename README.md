# citus_functions
Some SQL functions for citus


## citus_relation_size(regclass)

Disk space usage by all shard of the specified table or index,
equivalent to `pg_relation_size()`

### Usage

On the primary node type

```
citus# SELECT pg_relation_size('foobar');
 pg_relation_size
 ------------------
                 0
                 (1 row)

citus# SELECT citus_relation_size('foobar');
 citus_relation_size
 ---------------------
  65536
  (1 row)
```

## User management

* citus_user_on_workers(command);
* citus_drop_user_on_workers(username);
* citus_create_user_on_workers(username);
* citus_user_set_password_on_workers(username, password);
* citus_sync_user_on_workers(username);
