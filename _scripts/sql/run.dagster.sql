-- Check PostgreSQL version
select version();

-- Create main schemas if needed
create schema if not exists dagster;
create schema if not exists storage;

-- Add a search path to a database
alter database dagster set search_path to public, dagster, storage;

-- Create roles
create role dbu_dagster with login;
create role dbu_storage with login;

-- Dagster role configuration
grant all on database dagster to dbu_dagster;
alter schema dagster owner to dbu_dagster;
grant all on schema dagster to dbu_dagster;
grant execute on all functions in schema dagster to dbu_dagster;

-- Storage role configuration
grant connect on database dagster to dbu_storage;
grant usage on schema storage to dbu_storage;
grant execute on all functions in schema storage to dbu_storage;

-- Install extensions dagster_extender in dagster schema
do
$$
    begin
        if exists (select 1 from pg_available_extensions where name = 'dagster_extender') then
            create extension if not exists dagster_extender schema dagster;
            raise notice 'Extension "dagster_extender" is installed.';
        else
            raise notice 'Extension "dagster_extender" is not available.';
        end if;
    end
$$;

-- Install extensions dagster_extender in storage schema
do
$$
    begin
        if exists (select 1 from pg_available_extensions where name = 'icecat') then
            create extension if not exists icecat schema storage;
            raise notice 'Extension "icecat" is installed.';
        else
            raise notice 'Extension "icecat" is not available.';
        end if;
    end
$$;