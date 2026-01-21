#!/usr/bin/env bash
# _scripts/launchpad/fn.install.sh
# Functionality for installing Dagster Launchpad Demo

D_LP_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -e

check_that_podman_is_installed() {
    command -v podman >/dev/null 2>&1 || {
        echo "Error: Podman is not installed" >&2
        echo "Podman Desktop available at: https://podman-desktop.io" >&2
        exit 1
    }
}

report_pull_failure() {
    local cnt_path
    cnt_path=$1
    echo "Failed to pull ${cnt_path}"
    exit 1
}

pull_launchpad_images() {
    echo "Trying to pull required images..."
    podman pull "${LP_IMG_DAEMON}" &>/dev/null || report_pull_failure "${LP_IMG_DAEMON}"
    podman pull "${LP_IMG_WEBSERVER}" &>/dev/null || report_pull_failure "${LP_IMG_WEBSERVER}"
    podman pull "${LP_IMG_PIPES}" &>/dev/null || report_pull_failure "${LP_IMG_PIPES}"
}

set_variables() {
    export CNT_LP_DAEMON="${LP_PRX}${LP_CNT_DAEMON}"
    export CNT_LP_PGDB="${LP_PRX}${LP_CNT_PGDB}"
    export CNT_LP_PIPES="${LP_PRX}${LP_CNT_PIPES}"
    export CNT_LP_WEBSERVER="${LP_PRX}${LP_CNT_WEBSERVER}"
    export CNT_LP_WEBSERVER="${LP_PRX}${LP_CNT_WEBSERVER}"
    export VOL_LP_PIPES="${LP_PRX}${LP_VOL_PIPES}"
    export VOL_LP_SHARE="${LP_PRX}${LP_VOL_SHARE}"
    export VOL_LP_PG="${LP_PRX}${LP_VOL_PG}"
    export DGS_SEC_PRX="${LP_PRX}"
}

unset_variables() {
    unset CNT_LP_DAEMON CNT_LP_PGDB CNT_LP_PIPES CNT_LP_WEBSERVER
    unset CNT_LP_WEBSERVER VOL_LP_PIPES VOL_LP_SHARE DGS_SEC_PRX
}

create_secrets() {
    echo "Creating secrets if needed..."
    # PSQL Server
    podman_s_save "${DGS_SEC_PRX}postgres" "$(uuidgen)" # Postgres root password
    podman_s_save "${DGS_SEC_PRX}pg_prt" "${LP_DB_PORT}" # PostgreSQL server port

    # Dagster DB
    podman_s_save "${DGS_SEC_PRX}pg_srv" "${LP_GATEWAY}" # Gateway
    podman_s_save "${DGS_SEC_PRX}pg_usr" "${LP_DB_USER}" # Name of Dagster DB user
    podman_s_save "${DGS_SEC_PRX}pg_psw" "$(uuidgen)" # Dagster DB user password
    podman_s_save "${DGS_SEC_PRX}pg_dbn" "${LP_DB_DB}" # Name of Dagster DB
    podman_s_save "${DGS_SEC_PRX}pg_sch" "${LP_DB_SHEMA}" # Name of Dagster DB schema
    podman_s_save "${DGS_SEC_PRX}pl_prt" "${LP_PORT_PS}" # Pipes server port
    podman_s_save "${DGS_SEC_PRX}ws_prt" "${LP_PORT_WS}" # Web Sever port

    # Storage DB
    podman_s_save "${DGS_SEC_PRX}pg_st_sch" "${LP_ST_DB_SHEMA}" # Schema of storage
    podman_s_save "${DGS_SEC_PRX}pg_st_usr" "${LP_ST_DB_USER}" # Storage user
    podman_s_save "${DGS_SEC_PRX}pg_st_psw" "$(uuidgen)" # Storage user Password
}

create_launchpad_containers() {
    # Run when any of the containers is missing
    if ! podman_cnt_exists "${CNT_LP_PGDB}" || ! podman_cnt_exists "${CNT_LP_WEBSERVER}" ||
        ! podman_cnt_exists "${CNT_LP_PIPES}" || ! podman_cnt_exists "${CNT_LP_DAEMON}"; then
        echo "Trying to create required containers..."
        # Prepare
        check_that_podman_is_installed
        create_secrets
        pull_launchpad_images
        # Make containers
        create_dg_srv_pipes "${CNT_LP_PIPES}" "${LP_PORT_PS}" "${VOL_LP_PIPES}" "${VOL_LP_SHARE}" "${LP_IMG_PIPES}"
        create_dg_srv_daemon "${CNT_LP_DAEMON}" "${LP_IMG_DAEMON}"
        create_dg_srv_web "${CNT_LP_WEBSERVER}" "${LP_PORT_WS}" "${LP_IMG_WEBSERVER}"
    fi
}

start_launchpad_containers() {
    create_launchpad_containers
    echo "Trying to start required containers..."
    create_and_start_server_postgres "${CNT_LP_PGDB}" "${VOL_LP_PG}" "${LP_IMG_POSTGRES}"
    start_cnt_daemon "${CNT_LP_DAEMON}"
    start_cnt_pipes "${CNT_LP_PIPES}"
    start_cnt_web "${CNT_LP_WEBSERVER}"
}

install_dagster_demo() {
    local path_project
    path_project=$(realpath "${D_LP_SCRIPT}/../../")
    source "${path_project}/_scripts/launchpad/launchpad.conf"
    source "${path_project}/_scripts/fn.podman.sh"
    source "${path_project}/_scripts/create.server.db.sh"
    source "${path_project}/_scripts/create.server.dg.daemon.sh"
    source "${path_project}/_scripts/create.server.dg.pipes.sh"
    source "${path_project}/_scripts/create.server.dg.web.sh"
    set_variables
    start_launchpad_containers
    unset_variables
    sleep 2
    open_dagster_ui "${LP_PORT_WS}"
}