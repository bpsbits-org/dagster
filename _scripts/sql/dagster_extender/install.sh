#!/usr/bin/env bash
# Installs dagster_extender extension files
set -e
D_INS_SCR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${D_INS_SCR}" || exit 1
source ./install.conf
[ -d "$D_INSTALL_DEST" ] || {
    echo "Missing: $D_INSTALL_DEST" >&2
    exit 1
}
echo "Installing dagster_extender files..."
chown -R root:root .
cp dagster_extender.control dagster_extender--1.0.sql "${D_INSTALL_DEST}"/
echo "Done"