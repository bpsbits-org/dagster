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

copy_extension_dagster() {
    local cnt_name
    cnt_name=$1
    podman exec "${cnt_name}" rm -rf /tmp/dagster_extender
    podman cp "${D_PRJ_DB}/_scripts/sql/dagster_extender" "${cnt_name}":/tmp/dagster_extender
    podman exec -it "${cnt_name}" bash /tmp/dagster_extender/install.sh
    podman exec "${cnt_name}" rm -rf /tmp/dagster_extender
}

copy_extension_icecat() {
    local cnt_name
    cnt_name=$1
    podman exec "${cnt_name}" rm -rf /tmp/icecat
    podman cp "${D_PRJ_DB}/_scripts/sql/icecat" "${cnt_name}":/tmp/icecat
    podman exec -it "${cnt_name}" bash /tmp/icecat/install.sh
    podman exec "${cnt_name}" rm -rf /tmp/icecat
}

save_storage_db_conn() {
    local cnt_name s_px db_dagster sc_dagster json srv prt dbn sch usr psw
    cnt_name=$1
    s_px="${DGS_SEC_PRX:-s_dgs_}"
    db_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_dbn")
    sc_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_sch")
    # podman_s_save "s_dgs_pg_sch" "dagster" # Name of Dagster DB
    srv=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_srv")
    prt=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_prt")
    dbn=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_dbn")
    sch=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_sch")
    usr=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_usr")
    psw=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_psw")
    json="{\"host\":\"${srv}\",\"port\":\"${prt}\",\"database\":\"${dbn}\",\"db_schema\":\"${sch}\",\"user\":\"${usr}\",\"password\":\"${psw}\"}"
    echo -e "Saving 'db_storage' configuration...\n"
    podman exec --user root "${cnt_name}" psql -U postgres -d "${db_dagster}" \
        -c "select length(${sc_dagster}.set_user_conf('db_storage'::varchar, '${json}'::jsonb)::varchar) > 0 as conf_saved;"
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
    local db_name usr_dagster usr_storage cnt_name s_px
    cnt_name=$1
    s_px="${DGS_SEC_PRX:-s_dgs_}"
    if ! dagster_db_exists "${cnt_name}"; then
        echo "Creating database for Dagster..."
        # Configuration
        db_name=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_dbn")
        usr_dagster=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_usr")
        usr_storage=$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_usr")
        # Create a database
        podman exec --user root "${cnt_name}" createdb -U postgres "${db_name}" 2>/dev/null || true
        # Execute code on server
        prepare_and_run_sql_code "${cnt_name}"
        # Update users
        podman exec --user root "${cnt_name}" psql -U postgres -d postgres \
            -c "ALTER ROLE ${usr_dagster} WITH PASSWORD '$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_psw")';" || true
        podman exec --user root "${cnt_name}" psql -U postgres -d postgres \
            -c "ALTER ROLE ${usr_storage} WITH PASSWORD '$(podman secret inspect --showsecret --format '{{.SecretData}}' "${s_px}pg_st_psw")';" || true
        # Save connection configuration for db_storage
        save_storage_db_conn "${cnt_name}"
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
        echo -e "\tWaiting for server to launch..."
        sleep 6
        # Copy extensions
        copy_extension_dagster "${cnt_name}"
        copy_extension_icecat "${cnt_name}"
        # Create a database and configure
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