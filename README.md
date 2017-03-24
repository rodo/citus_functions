# citus_functions
Some SQL functions for citus


## citus_relation_size(regclass)

Disk space usage by all shard of the specified table or index,
equivalent to `pg_relation_size()`

### Usage

On the primary node type

`db$ SELECT citus_relation_size('foobar');`
