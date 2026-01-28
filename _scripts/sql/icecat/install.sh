#!/usr/bin/env bash
# Installs icecat extension files
set -e
D_INS_SCR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${D_INS_SCR}" || exit 1
source ./install.conf
[ -d "$D_INSTALL_DEST" ] || {
    echo "Missing: $D_INSTALL_DEST" >&2
    exit 1
}
echo "Installing icecat files..."
chown -R root:root .
cp icecat.control icecat--1.0.sql "${D_INSTALL_DEST}"/
echo "Done"