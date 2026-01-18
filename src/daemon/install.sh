#!/usr/bin/env bash
# src/containers/daemon/install.sh

set -e

apt-get update
apt-get install -y gettext-base
rm -rf /var/lib/apt/lists/*

readonly DAGSTER_HOME=/opt/dagster/dagster_home

mkdir -p "${DAGSTER_HOME}"

cd "${DAGSTER_HOME}" || exit 1

pip install -q --no-cache-dir \
    dagster \
    dagster-graphql \
    dagster-postgres \
    dagster-webserver\
    psycopg2-binary \
    python-box

chmod +x "${DAGSTER_HOME}/entrypoint.sh"

rm -f install.sh