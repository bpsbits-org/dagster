#!/usr/bin/env bash
# src/containers/pipes/install.sh
set -e

readonly DAGSTER_WD=/opt/dagster/app
readonly DAGSTER_SD=/data/share

mkdir -p "${DAGSTER_WD}"
mkdir -p "${DAGSTER_SD}"/{in,out,store}
chmod -R 777 "${DAGSTER_SD}"

cd "${DAGSTER_WD}" || exit 1

pip install -q --no-cache-dir \
    dagster \
    dagster-postgres \
    psycopg2-binary \
    python-box

rm -f install.sh