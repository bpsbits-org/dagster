#!/usr/bin/env bash
# create.server.db.sh
# Creates and starts a local database server instance
set -e

# Locations
D_CREATE_DB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
D_PRJ_DB=$(realpath "${D_CREATE_DB}/../")

source "${D_CREATE_DB}/fn.podman.sh"

use_secrets_maker() {
    if [ -f "${D_PRJ_DB}/.podman.secrets.sh" ]; then
        source "${D_PRJ_DB}/.podman.secrets.sh"
    else
        make_podman_secrets() {
            echo "The .podman.secrets.sh is not used."
        }
    fi
}

# Checks if dagster db already exists
dagster_db_exists() {
    local cnt_name=$1
    podman exec --user postgres "${cnt_name}" psql -U postgres -tAc \
        "SELECT 1 FROM pg_database WHERE datname = 'dagster'" 2>/dev/null | \
        grep -q 1
}

# Prepare SQL code
prepare_and_run_sql_code() {
    local db_name schema_dagster schema_storage usr_dagster usr_storage f_tpl_sql f_run_sql s_px cnt_name
    cnt_name=$1
    s_px="${DGS_SEC_PRX:-s_dgs_}"
    echo "Preparing SQL code..."
    db_name=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_dbn")
    schema_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_sch")
    schema_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_sch")
    usr_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_usr")
    usr_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_usr")
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
    podman cp "${f_run_sql}" "${cnt_name}":/tmp/run.dagster.sql
    podman exec --user root "${cnt_name}" psql -U postgres -d "${db_name}" -f /tmp/run.dagster.sql
}

# Creates database for dagster
create_db_for_dagster() {
    local db_name schema_dagster schema_storage usr_dagster usr_storage cnt_name s_px
    cnt_name=$1
    s_px="${DGS_SEC_PRX:-s_dgs_}"
    if ! dagster_db_exists "${cnt_name}"; then
        echo "Creating database for Dagster..."
        # Configuration
        db_name=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_dbn")
        schema_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_sch")
        schema_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_sch")
        usr_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_usr")
        usr_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_usr")
        # Create a database
        podman exec --user root "${cnt_name}" createdb -U postgres "${db_name}" 2>/dev/null || true
        # Execute code on server
        prepare_and_run_sql_code "${cnt_name}"
        # Update users
        podman exec --user root "${cnt_name}" psql -U postgres -d postgres \
            -c "ALTER ROLE ${usr_dagster} WITH PASSWORD '$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_psw")';" || true
        podman exec --user root "${cnt_name}" psql -U postgres -d postgres \
            -c "ALTER ROLE ${usr_storage} WITH PASSWORD '$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_psw")';" || true
    fi
}

# Create volume
create_volume_dagster_db() {
    local vol_name=$1
    if ! podman_v_exists "${vol_name}"; then
        podman volume create "${vol_name}"
    fi
}

# Creates PostgreSQL server
create_server_postgres() {
    local cnt_name vol_name img_path
    cnt_name=$1 vol_name=$2 img_path=$3
    if ! podman_cnt_exists "${cnt_name}"; then
        local s_port s_px
        s_px="${DGS_SEC_PRX:-s_dgs_}"
        create_volume_dagster_db "${vol_name}"
        s_port=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_prt")
        echo "Creating ${cnt_name}..."
        podman create --name "${cnt_name}" \
            --secret "${s_px}postgres",type=env,target=POSTGRES_PASSWORD \
            -p "${s_port}":5432 \
            "${img_path}"
        #-v "${vol_name}":/var/lib/postgresql/data \
    fi
}

# Starts Postgres DB server
start_server_postgres() {
    local cnt_name=$1
    if ! podman_cnt_running "${cnt_name}"; then
        echo "Starting ${cnt_name}..."
        podman start "${cnt_name}"
        sleep 6
        create_db_for_dagster "${cnt_name}"
    fi
}

create_and_start_server_postgres() {
    local cnt_name vol_name img_path
    cnt_name=$1 vol_name=$2 img_path=$3
    create_server_postgres "${cnt_name}" "${vol_name}" "${img_path}"
    start_server_postgres "${cnt_name}"
}

if [[ $# -eq 3 ]]; then
    use_secrets_maker
    make_podman_secrets
    create_and_start_server_postgres "$1" "$2" "$3"
fi