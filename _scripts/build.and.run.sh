#!/usr/bin/env bash

set -e

# Locations
D_RUN_ALL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Force remove containers (ignores if they don't exist)
podman rm -f dagster_web 2>/dev/null || true
podman rm -f dagster_daemon 2>/dev/null || true
podman rm -f dagster_pipes 2>/dev/null || true

# Remove volume (ignores if it doesn't exist)
podman volume rm vol_dagster_pipes 2>/dev/null || true

# Create and run a database server
chmod +x "${D_RUN_ALL}/create.server.db.sh"
"${D_RUN_ALL}/create.server.db.sh" 'dagster_db' 'vol_dagster_db' 'docker.io/library/postgres:latest'

# Build all images
chmod +x "${D_RUN_ALL}/build.images.all.sh"
"${D_RUN_ALL}/build.images.all.sh"

# Create and run dagster servers
chmod +x "${D_RUN_ALL}/create.server.dg.all.sh"
"${D_RUN_ALL}/create.server.dg.all.sh"
