-- Check PostgreSQL version
select version();

-- Create main schemas if needed
create schema if not exists sch_dagster;
create schema if not exists sch_storage;

-- Users configuration
create role usr_dagster with login;
create role usr_storage with login;

grant all on database db_dagster to usr_dagster;
alter schema sch_dagster owner to usr_dagster;
grant all on schema sch_dagster to usr_dagster;
grant execute on all functions in schema sch_dagster to usr_dagster;

grant connect on database db_dagster to usr_storage;
grant usage on schema sch_storage to usr_storage;

-- Table for user configurations
create table if not exists sch_dagster.user_configurations
(
    cid varchar(36) default gen_random_uuid()::varchar not null
        constraint pk_cid_user_configurations
            primary key,
    cnf jsonb       default '{}'::jsonb                not null
);

comment on table sch_dagster.user_configurations is 'Misc user configurations';

-- Function for retrieving user configuration
create or replace function sch_dagster.get_user_conf(key varchar(36))
    returns jsonb
    security definer
    stable
    language sql as
$func$
select coalesce((select cnf from sch_dagster.user_configurations where cid = trim(key)), '{}'::jsonb);
$func$;

comment on function sch_dagster.get_user_conf
    is 'Returns specified configuration';

alter function sch_dagster.sch_dagster.get_user_conf(varchar) owner to postgres;

grant execute on function sch_dagster.get_user_conf(varchar) to usr_dagster;

-- Function for setting user configuration
create or replace function sch_dagster.set_user_conf(in_key varchar(36), in_value jsonb)
    returns jsonb
    security definer
    language plpgsql as
$func$
begin
    if coalesce(trim(in_key), '') = '' then
        raise exception 'Key is not provided';
    end if;
    if (jsonb_typeof(in_value) = 'object') = false then
        raise exception 'Value should be JSON object';
    end if;
    insert into sch_dagster.user_configurations (cid, cnf)
    values (in_key, in_value)
    on conflict (cid) do update
        set cnf = excluded.cnf;
    return in_value;
end;
$func$;

comment on function sch_dagster.set_user_conf
    is 'Sets specified configuration';

alter function sch_dagster.set_user_conf(varchar, jsonb) owner to postgres;

grant execute on function sch_dagster.set_user_conf(varchar, jsonb) to dbu_dagster;