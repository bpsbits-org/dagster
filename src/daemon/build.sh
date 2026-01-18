#!/usr/bin/env bash

set -e

# Locations
F_BUILD_DM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
D_BUILD_DM=$(dirname "${F_BUILD_DM}")
D_PRJ_DM=$(realpath "${D_BUILD_DM}/../../")

# Conf
source "${D_BUILD_DM}/build.conf"

# Actions
source "${D_PRJ_DM}/_scripts/fn.podman.sh"
build_container_from "${CN_DM_NAME}" "${CN_DM_TAG}" "${D_BUILD_DM}"