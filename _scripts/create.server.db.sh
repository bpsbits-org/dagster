#!/usr/bin/env bash
# create.server.db.sh
# Creates and starts a local database server instance
set -e

# Locations
F_CREATE_DB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
D_CREATE_DB=$(dirname "${F_CREATE_DB}")
D_PRJ_DB=$(realpath "${D_CREATE_DB}/../")
CNT_PG_DB='dagster_db'
VOL_PG_DB='vol_dagster_db'
readonly F_CREATE_DB D_CREATE_DB D_PRJ_DB CNT_PG_DB

source "${D_CREATE_DB}/fn.podman.sh"
source "${D_PRJ_DB}/.podman.secrets.sh" # You need to create this file first

# Checks if dagster db already exists
dagster_db_exists() {
    podman exec --user postgres "${CNT_PG_DB}" psql -U postgres -tAc \
        "SELECT 1 FROM pg_database WHERE datname = 'dagster'" 2>/dev/null | \
        grep -q 1
}

# Prepare SQL code
prepare_and_run_sql_code() {
    local db_name schema_dagster schema_storage usr_dagster usr_storage f_tpl_sql f_run_sql
    echo "Preparing SQL code..."
    db_name=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_dbn)
    schema_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_sch)
    schema_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dbs_pg_sch)
    usr_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_usr)
    usr_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dbs_pg_usr)
    f_tpl_sql="${D_CREATE_DB}/sql/tpl.dagster.sql"
    f_run_sql="${D_CREATE_DB}/sql/run.dagster.sql"
    cp "${f_tpl_sql}" "${f_run_sql}"
    # Update db
    perl -i -pe "s/\bdb_dagster\b/${db_name}/g" "${f_run_sql}"
    # Update schemas
    perl -i -pe "s/\bsch_dagster\b/${schema_dagster}/g" "${f_run_sql}"
    perl -i -pe "s/\bsch_storage\b/${schema_storage}/g" "${f_run_sql}"
    # Update users
    perl -i -pe "s/\busr_dagster\b/${usr_dagster}/g" "${f_run_sql}"
    perl -i -pe "s/\busr_storage\b/${usr_storage}/g" "${f_run_sql}"
    # Copy and execute command
    echo "Executing SQL code..."
    podman cp "${f_run_sql}" "${CNT_PG_DB}":/tmp/run.dagster.sql
    podman exec --user root "${CNT_PG_DB}" psql -U postgres -d "${db_name}" -f /tmp/run.dagster.sql
}

# Creates database for dagster
create_db_for_dagster() {
    local db_name schema_dagster schema_storage usr_dagster usr_storage
    if ! dagster_db_exists; then
        echo "Creating database for dagster..."
        # Configuration
        db_name=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_dbn)
        schema_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_sch)
        schema_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dbs_pg_sch)
        usr_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_usr)
        usr_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dbs_pg_usr)
        # Create a database
        podman exec --user root "${CNT_PG_DB}" createdb -U postgres "${db_name}" 2>/dev/null || true
        # Execute code on server
        prepare_and_run_sql_code
        # Update users
        podman exec --user root "${CNT_PG_DB}" psql -U postgres -d postgres \
            -c "ALTER ROLE ${usr_dagster} WITH PASSWORD '$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_psw)';" || true
        podman exec --user root "${CNT_PG_DB}" psql -U postgres -d postgres \
            -c "ALTER ROLE ${usr_storage} WITH PASSWORD '$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dbs_pg_psw)';" || true
    fi
}

# Create volume
create_volume_dagster_db() {
    if ! podman_v_exists "${VOL_PG_DB}"; then
        podman volume create "${VOL_PG_DB}"
    fi
}

# Creates PostgreSQL server
create_server_postgres() {
    local s_port
    if ! podman_cnt_exists "${CNT_PG_DB}"; then
        create_volume_dagster_db
        s_port=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pg_prt)
        echo "Creating ${CNT_PG_DB}..."
        podman create --name "${CNT_PG_DB}" \
            --secret s_dgs_postgres,type=env,target=POSTGRES_PASSWORD \
            -p "${s_port}":5432 \
            docker.io/library/postgres:latest
        #-v "${VOL_PG_DB}":/var/lib/postgresql/data \
    fi
}

# Starts Postgres DB server
start_server_postgres() {
    if ! podman_cnt_running "${CNT_PG_DB}"; then
        echo "Starting ${CNT_PG_DB}..."
        podman start "${CNT_PG_DB}"
        sleep 6
        create_db_for_dagster
    fi
}

create_and_start_server_postgres() {
    make_podman_secrets
    create_server_postgres
    start_server_postgres
}

create_and_start_server_postgres
