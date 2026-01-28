#!/usr/bin/env bash
# create.server.dg.pipes.sh
# Helps to create and start a Dagster Pipes (user code) container

set -e

# Locations
D_CREATE_PI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${D_CREATE_PI}/fn.podman.sh"

# Creates Dagster Pipes (user code) server
create_dg_srv_pipes() {
    local s_port name_cnt name_vol_app name_vol_share name_img s_px
    name_cnt=$1
    s_port=$2
    name_vol_app=$3
    name_vol_share=$4
    name_img=$5
    s_px="${DGS_SEC_PRX:-s_dgs_}"
    if ! podman_cnt_exists "${name_cnt}"; then
        podman_v_create "${name_vol_app}"
        podman_v_create "${name_vol_share}"
        echo "Creating container of Dagster Pipes Server '${name_cnt}'..."
        podman create --name "${name_cnt}" \
            -p "${s_port}":4000 \
            -v "${name_vol_app}":/opt/dagster/app \
            -v "${name_vol_share}":/data/share \
            --secret "${s_px}pg_srv",type=env,target=DGS_PG_SRV \
            --secret "${s_px}pg_prt",type=env,target=DGS_PG_PRT \
            --secret "${s_px}pg_dbn",type=env,target=DGS_PG_DBN \
            --secret "${s_px}pg_sch",type=env,target=DGS_PG_SCH \
            --secret "${s_px}pg_usr",type=env,target=DGS_PG_USR \
            --secret "${s_px}pg_psw",type=env,target=DGS_PG_PSW \
            "${name_img}"
    else
        echo "Container of Dagster Pipes Server '${name_cnt}' already exists."
    fi
}

# Starts Pipes server
start_cnt_pipes() {
    local name_cnt=$1
    if ! podman_cnt_exists "${name_cnt}"; then
        echo "Container '${name_cnt}' (Dagster Pipes Server) does not exist. Aborted."
        return 1
    fi
    if ! podman_cnt_running "${name_cnt}"; then
        echo "Starting Dagster Pipes Server '${name_cnt}'..."
        podman start "${name_cnt}"
    fi
}