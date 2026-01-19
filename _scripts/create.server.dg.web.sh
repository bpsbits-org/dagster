#!/usr/bin/env bash
# create.server.dg.web.sh
# Helps to create and start the Dagster Webserver container

set -e

# Locations
F_CREATE_WB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
D_CREATE_WB=$(dirname "${F_CREATE_WB}")

readonly F_CREATE_WB D_CREATE_WB

source "${D_CREATE_WB}/fn.podman.sh"

# Creates Dagster Pipes (user code) server
create_dg_srv_web() {
    local s_port name_cnt name_img
    name_cnt=$1
    s_port=$2
    name_img=$3
    if ! podman_cnt_exists "${CNT_DG_WS}"; then
        echo "Creating container of Dagster Web Server '${name_cnt}'..."
        podman create --name "${name_cnt}" \
            -p "${s_port}":3000 \
            --secret s_dgs_pg_dbn,type=env,target=DGS_PG_DBN \
            --secret s_dgs_pg_prt,type=env,target=DGS_PG_PRT \
            --secret s_dgs_pg_psw,type=env,target=DGS_PG_PSW \
            --secret s_dgs_pg_srv,type=env,target=DGS_PG_SRV \
            --secret s_dgs_pg_usr,type=env,target=DGS_PG_USR \
            --secret s_dgs_pl_prt,type=env,target=DGS_CODE_PORT \
            "${name_img}"
    else
        echo "Container of Dagster Web Server '${name_cnt}' already exists."
    fi
}

# Starts Pipes server
start_cnt_web() {
    local name_cnt=$1
    if ! podman_cnt_exists "${name_cnt}"; then
        echo "Container '${name_cnt}' (Dagster Web Server) does not exist. Aborted."
        return 1
    fi
    if ! podman_cnt_running "${name_cnt}"; then
        echo "Starting Dagster Web Server '${name_cnt}'..."
        podman start "${name_cnt}"
    fi
}