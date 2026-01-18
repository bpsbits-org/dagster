#!/usr/bin/env bash

set -e

# Locations
F_BUILD_PP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
D_BUILD_PP=$(dirname "${F_BUILD_PP}")
D_PRJ_PP=$(realpath "${D_BUILD_PP}/../../")

# Conf
source "${D_BUILD_PP}/build.conf"

# Actions
source "${D_PRJ_PP}/_scripts/fn.podman.sh"
build_container_from "${CN_PP_NAME}" "${CN_PP_TAG}" "${D_BUILD_PP}"