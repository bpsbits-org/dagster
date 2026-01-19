select version();

-- User configuration
create role dbu_dagster with login;
create role dbu_storage with login;

create schema if not exists dagster;
create schema if not exists storage;

grant all on database dagster to dbu_dagster;
alter schema dagster owner to dbu_dagster;
grant all on schema dagster to dbu_dagster;

grant connect on database dagster to dbu_storage;
grant usage on schema storage to dbu_storage;

-- Table for user configurations
create table if not exists dagster.user_configurations
(
    cid varchar(36) default gen_random_uuid()::varchar not null
        constraint pk_cid_user_configurations
            primary key,
    cnf jsonb       default '{}'::jsonb                not null
);

comment on table dagster.user_configurations is 'Misc user configurations';

-- Function for retrieving user configuration
create or replace function dagster.get_user_conf(key varchar(36))
    returns jsonb
    security definer
    stable
    language sql as
$func$
select coalesce((select cnf from dagster.user_configurations where cid = trim(key)), '{}'::jsonb);
$func$;

comment on function dagster.get_user_conf
    is 'Returns specified configuration';

alter function dagster.dagster.get_user_conf(varchar) owner to postgres;

grant execute on function dagster.get_user_conf(varchar) to dbu_dagster;

-- Function for setting user configuration
create or replace function dagster.set_user_conf(in_key varchar(36), in_value jsonb)
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
    insert into dagster.user_configurations (cid, cnf)
    values (in_key, in_value)
    on conflict (cid) do update
        set cnf = excluded.cnf;
    return in_value;
end;
$func$;

comment on function dagster.set_user_conf
    is 'Sets specified configuration';

alter function dagster.set_user_conf(varchar, jsonb) owner to postgres;

grant execute on function dagster.set_user_conf(varchar, jsonb) to dbu_dagster;