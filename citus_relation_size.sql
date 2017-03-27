BEGIN;
    
DROP FUNCTION IF EXISTS citus_relation_size(regclass);


CREATE FUNCTION citus_relation_size(rel regclass) RETURNS text AS $BODY$
DECLARE
    nodes RECORD;
    connstr text;
    cmd text;
    global_result boolean;
    relsize bigint;
    cursize bigint;
    text_var1 text;
    text_var2 text;
    text_var3 text;
BEGIN
    global_result := true;
    relsize := 0;
    
    FOR nodes IN

        SELECT distinct on ( sh.shardid) sh.shardid::text,  nodename, nodeport
        FROM pg_dist_shard sh
        JOIN pg_dist_shard_placement sp ON sh.shardid = sp.shardid 
        WHERE logicalrelid = rel
    
    LOOP
        connstr := 'dbname=' || current_database() ||' host=' || nodes.nodename || ' port=' || nodes.nodeport;

        cmd := 'SELECT pg_relation_size(' || quote_literal (rel::text || '_' || nodes.shardid) || ')';
    
        BEGIN
        SELECT * FROM dblink(connstr, cmd )
        AS t1(relsize bigint)
        INTO cursize;

        relsize := relsize + cursize;
    
        EXCEPTION WHEN OTHERS THEN
             GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
                                     text_var2 = PG_EXCEPTION_DETAIL,
                                     text_var3 = PG_EXCEPTION_HINT;
        END;

    END LOOP;

    RETURN relsize;

END;
$BODY$ LANGUAGE plpgsql;
    
COMMIT;
