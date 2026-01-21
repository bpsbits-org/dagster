#!/usr/bin/env bash
# setup.venv.sh
if [ -d ".venv" ]; then
    exit 0
fi
python3.13 -m venv .venv