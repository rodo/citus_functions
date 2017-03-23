DROP FUNCTION IF EXISTS citus_user_on_workers(text);
DROP FUNCTION IF EXISTS citus_create_user_on_workers(text);

CREATE OR REPLACE FUNCTION citus_user_on_workers(cmd text) RETURNS text AS $BODY$
DECLARE
    nodes RECORD;
    workers integer;
    connstr text;
    global_result boolean;
    text_var1 text;
    text_var2 text;
    text_var3 text;
BEGIN
    global_result := true;

    FOR nodes IN
        SELECT nodename, nodeport FROM pg_catalog.pg_dist_node
    LOOP
        connstr := 'dbname=postgres host=' || nodes.nodename || ' port=' || nodes.nodeport;

        RAISE NOTICE 'Create user on %s ...', quote_ident(connstr);

        BEGIN
            PERFORM (dblink_connect('citus_create_user', connstr));
        EXCEPTION WHEN OTHERS THEN
             GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
                                     text_var2 = PG_EXCEPTION_DETAIL,
                                     text_var3 = PG_EXCEPTION_HINT;
            global_result := false;
        END;

        BEGIN
        PERFORM (dblink_exec('citus_create_user', cmd));

        EXCEPTION WHEN OTHERS THEN
             GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
                                     text_var2 = PG_EXCEPTION_DETAIL,
                                     text_var3 = PG_EXCEPTION_HINT;

             global_result := false;
        END;

        BEGIN
        -- finally close the link
        PERFORM (dblink_disconnect('citus_create_user'));
            EXCEPTION WHEN OTHERS THEN
                global_result := false;
        END;
    END LOOP;

    RETURN text_var1;

END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION citus_create_user_on_workers(username text) RETURNS text AS $BODY$
DECLARE
    text_var1 text;

BEGIN

    text_var1 := citus_user_on_workers('CREATE USER ' || username);

    RETURN text_var1;

END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION citus_sync_user_on_workers(username text) RETURNS text AS $BODY$
DECLARE
    text_var1 text;

BEGIN

    text_var1 := citus_user_on_workers('CREATE USER ' || username);

    text_var1 := citus_user_on_workers('ALTER ROLE ' || username || ' ENCRYPTED PASSWORD ');

    RETURN text_var1;

END;
$BODY$ LANGUAGE plpgsql;
