-- Check PostgreSQL version
select version();

-- Create main schemas if needed
create schema if not exists sch_dagster;
create schema if not exists sch_storage;

-- Add a search path to a database
alter database db_dagster set search_path to public, sch_dagster, sch_storage;

-- Create roles
create role usr_dagster with login;
create role usr_storage with login;

-- Dagster role configuration
grant all on database db_dagster to usr_dagster;
alter schema sch_dagster owner to usr_dagster;
grant all on schema sch_dagster to usr_dagster;
grant execute on all functions in schema sch_dagster to usr_dagster;

-- Storage role configuration
grant connect on database db_dagster to usr_storage;
grant usage on schema sch_storage to usr_storage;
grant execute on all functions in schema sch_storage to usr_storage;

-- Install extensions dagster_extender in dagster schema
do
$$
    begin
        if exists (select 1 from pg_available_extensions where name = 'dagster_extender') then
            create extension if not exists dagster_extender schema sch_dagster;
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
            create extension if not exists icecat schema sch_storage;
            raise notice 'Extension "icecat" is installed.';
        else
            raise notice 'Extension "icecat" is not available.';
        end if;
    end
$$;