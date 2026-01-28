-- DAGSTER EXTENDER 1.0

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    User configurations
 */
create table if not exists user_configurations
(
    cid varchar(36) default uuidv7()::varchar not null
        constraint pk_cid_user_configurations
            primary key,
    cnf jsonb       default '{}'::jsonb       not null
);
comment on table user_configurations is 'User configurations';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Returns specified user configuration
 */
create or replace function get_user_conf(key varchar(36))
    returns jsonb
    security definer
    stable
    language sql as
$func$
select coalesce((select cnf from @extschema@.user_configurations where cid = trim(key)), '{}'::jsonb);
$func$;
comment on function get_user_conf is 'Returns specified configuration';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Saves given user configuration
 */
create or replace function set_user_conf(in_key varchar(36), in_value jsonb)
    returns jsonb
    security definer
    volatile
    language plpgsql as
$func$
begin
    if coalesce(trim(in_key), '') = '' then
        raise exception 'Key is not provided';
    end if;
    if (jsonb_typeof(in_value) = 'object') = false then
        raise exception 'Value should be JSON object';
    end if;
    insert into @extschema@.user_configurations (cid, cnf)
    values (in_key, in_value)
    on conflict (cid) do update
        set cnf = excluded.cnf;
    return in_value;
end;
$func$;
comment on function set_user_conf is 'Saves given configuration';