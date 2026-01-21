#!/usr/bin/env bash
# build.images.all.sh
# Builds all required Dagster-related container images

set -e

# Locations
D_BUILD_ALL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
D_PRJ_ALL=$(realpath "${D_BUILD_ALL}/../")

# Daemon
source "${D_PRJ_ALL}/src/daemon/build.sh"
# Pipes
source "${D_PRJ_ALL}/src/pipes/build.sh"
# Webserver
source "${D_PRJ_ALL}/src/webserver/build.sh"