#!/usr/bin/env bash
# src/containers/webserver/entrypoint.sh

set -euo pipefail

WORKSPACE_FINAL="${DAGSTER_HOME}/workspace.yaml"
WORKSPACE_TEMPLATE="${DAGSTER_HOME}/workspace.tpl.yaml"

# Generate workspace.yaml if needed
if [ ! -f "${WORKSPACE_FINAL}" ]; then
    dagster --version
    envsubst '$DGS_CODE_HOST $DGS_CODE_PORT $DGS_CODE_LOCATION_NAME' \
        <"${WORKSPACE_TEMPLATE}" \
        >"${WORKSPACE_FINAL}"
fi

# Run
exec "$@" -w "${WORKSPACE_FINAL}"