#!/usr/bin/env bash

set -e

# Locations
F_BUILD_WS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
D_BUILD_WS=$(dirname "${F_BUILD_WS}")
D_PRJ_WS=$(realpath "${D_BUILD_WS}/../../")

# Conf
source "${D_BUILD_WS}/build.conf"

# Actions
source "${D_PRJ_WS}/_scripts/fn.podman.sh"
build_container_from "${CN_WS_NAME}" "${CN_WS_TAG}" "${D_BUILD_WS}"