#!/usr/bin/env bash
# create.server.dg.all.sh
# Creates and starts all Dagster containers

set -e

# Locations
F_CREATE_ALL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
D_CREATE_ALL=$(dirname "${F_CREATE_ALL}")
D_PRJ_ALL=$(realpath "${D_CREATE_ALL}/../")

cd "${D_PRJ_ALL}" || exit 1

# Load images configuration
source "${D_PRJ_ALL}/src/daemon/build.conf"
source "${D_PRJ_ALL}/src/pipes/build.conf"
source "${D_PRJ_ALL}/src/webserver/build.conf"

# Load functionality
source "${D_CREATE_ALL}/create.server.dg.pipes.sh"
source "${D_CREATE_ALL}/create.server.dg.daemon.sh"
source "${D_CREATE_ALL}/create.server.dg.web.sh"

# Configuration
DG_SRV_PIPES='dagster_pipes'
DG_VOL_PIPES='vol_dagster_pipes'
DG_VOL_SHARE='vol_dagster_share'
DG_IMG_PIPES="localhost/${CN_PP_NAME}:${CN_PP_TAG}"
#
DG_SRV_DAEMON='dagster_daemon'
DG_IMG_DAEMON="localhost/${CN_DM_NAME}:${CN_DM_TAG}"
#
DG_SRV_WEB='dagster_web'
DG_IMG_WEB="localhost/${CN_WS_NAME}:${CN_WS_TAG}"

echo "Project directory: ${D_PRJ_ALL}"

create_dg_servers() {
    local srv_web_port srv_pip_port
    srv_web_port=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_ws_prt)
    srv_pip_port=$(podman secret inspect --showsecret --format '{{.SecretData}}' s_dgs_pl_prt)
    create_dg_srv_pipes "${DG_SRV_PIPES}" "${srv_pip_port}" "${DG_VOL_PIPES}" "${DG_VOL_SHARE}" "${DG_IMG_PIPES}"
    create_dg_srv_daemon "${DG_SRV_DAEMON}" "${DG_IMG_DAEMON}"
    create_dg_srv_web "${DG_SRV_WEB}" "${srv_web_port}" "${DG_IMG_WEB}"
}

start_dg_servers() {
    start_cnt_pipes "${DG_SRV_PIPES}"
    start_cnt_daemon "${DG_SRV_DAEMON}"
    start_cnt_web "${DG_SRV_WEB}"
}

create_and_start() {
    create_dg_servers
    start_dg_servers
}

chek_env_vars() {
    echo "Env vars in: '${DG_SRV_PIPES}'"
    podman exec "${DG_SRV_PIPES}" env | sort
    echo "Env vars in: '${DG_SRV_DAEMON}'"
    podman exec "${DG_SRV_DAEMON}" env | sort
    echo "Env vars in: '${DG_SRV_WEB}'"
    podman exec "${DG_SRV_WEB}" env | sort
}

create_and_start
chek_env_vars