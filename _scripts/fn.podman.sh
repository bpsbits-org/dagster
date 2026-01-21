#!/usr/bin/env bash
# fn.podman.sh
# Collection of helpful podman command shortcuts

set -e

podman_build() {
    local CONTAINER=$1
    local TAG=$2
    local FILE=$3
    echo -e "\nBuilding '${CONTAINER}:${TAG}'...\n"
    podman build --arch amd64 -t "${CONTAINER}":"${TAG}" -f "${FILE}"
    echo -e "\nBuild done"
}

podman_push() {
    local CONTAINER=$1
    local TAG=$2
    local REPO=$3
    podman_login
    echo -e "\nUploading '${CONTAINER}:${TAG}'...\n"
    podman push "${CONTAINER}":"${TAG}" "quay.io/${REPO}/${CONTAINER}":"${TAG}"
    echo -e "\nUpload done"
}

function build_container_from() {
    local CNT_NAME CNT_TAG CNT_DIR CNT_FILE
    CNT_NAME=$1
    CNT_TAG=$2
    CNT_DIR=$3
    CNT_FILE="${CNT_DIR}/Dockerfile"
    cd "${CNT_DIR}" || exit 1
    podman_build "${CNT_NAME}" "${CNT_TAG}" "${CNT_FILE}"
}

podman_cnt_exists() {
    podman container exists "$1" >/dev/null 2>&1
}

podman_cnt_running() {
    podman container inspect --format '{{.State.Running}}' "$1" 2>/dev/null | grep -q true
}

podman_s_exists() {
    podman secret exists "$1" >/dev/null 2>&1
}

podman_v_exists() {
    podman volume exists "$1" >/dev/null 2>&1
}

podman_v_create() {
    local name_vol
    name_vol=$1
    if ! podman_v_exists "${name_vol}"; then
        podman volume create "${name_vol}"
    fi
}

podman_s_save() {
    local name="$1"
    local value="$2"

    # Basic argument validation
    [[ -z "$name" ]] && {
        echo "Error: Secret name is required" >&2
        return 1
    }
    [[ -z "$value" ]] && {
        echo "Error: Secret value is required" >&2
        return 1
    }

    if ! podman_s_exists "$name"; then
        echo "Creating secret '$name'..."
        printf '%s' "$value" | podman secret create "$name" -
    fi
}