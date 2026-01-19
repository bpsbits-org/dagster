#!/usr/bin/env bash
# create.server.dg.daemon.sh
# Helps to create and start the Dagster Daemon container

set -e

# Locations
F_CREATE_DM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
D_CREATE_DM=$(dirname "${F_CREATE_DM}")

readonly F_CREATE_DM D_CREATE_DM

source "${D_CREATE_DM}/fn.podman.sh"

# Creates Dagster Daemon (user code) server
create_dg_srv_daemon() {
    local name_cnt name_img
    name_cnt=$1
    name_img=$2
    if ! podman_cnt_exists "${name_cnt}"; then
        echo "Creating container of Dagster Daemon Server ${name_cnt}..."
        podman create --name "${name_cnt}" \
            --secret s_dgs_pg_db,type=env,target=DGS_PG_DBN \
            --secret s_dgs_pg_prt,type=env,target=DGS_PG_PRT \
            --secret s_dgs_pg_psw,type=env,target=DGS_PG_PSW \
            --secret s_dgs_pg_srv,type=env,target=DGS_PG_SRV \
            --secret s_dgs_pg_usr,type=env,target=DGS_PG_USR \
            --secret s_dgs_pl_prt,type=env,target=DGS_CODE_PORT \
            "${name_img}"
    else
        echo "Container of Dagster Daemon Server ${name_cnt} already exists."
    fi
}

# Starts Daemon server
start_cnt_daemon() {
    local name_cnt=$1
    if ! podman_cnt_exists "${name_cnt}"; then
        echo "Container ${name_cnt} (Dagster Daemon Server) does not exist. Aborted."
        return 1
    fi
    if ! podman_cnt_running "${name_cnt}"; then
        echo "Starting Dagster Daemon Server ${name_cnt}..."
        podman start "${name_cnt}"
    fi
}