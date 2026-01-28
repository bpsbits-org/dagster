#!/usr/bin/env bash
# _scripts/launchpad/run.sh
# Installs Dagster Launchpad Demo

set -e

D_RUN_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

has_git() { command -v git >/dev/null 2>&1; }

fetch_dagster_repo() {
    local tmpdir repo_url repo_dir repo_name
    repo_url="https://github.com/bpsbits-org/dagster"
    tmpdir="$HOME/tmp/dagster-launchpad"
    repo_dir="$tmpdir/$(basename "$repo_url")"
    [ -d "$tmpdir" ] && rm -rf "$tmpdir"
    mkdir -p "$tmpdir" || {
        echo "Failed to create $tmpdir"
        exit 1
    }
    cd "$tmpdir" || {
        echo "Cannot cd to $tmpdir"
        exit 1
    }
    git clone -q "$repo_url" || {
        echo "Git clone failed"
        exit 1
    }
    echo "$repo_dir"
}

run_launchpad() {
    local repo_dir="$1"
    source "${repo_dir}/_scripts/launchpad/fn.install.sh" || {
        echo "Failed to load install functionality"
        exit 1
    }
    if [[ $(type -t install_dagster_demo) == "function" ]]; then
        install_dagster_demo
    else
        echo "install_dagster_demo not found"
    fi
}

fetch_and_install() {
    echo "Fetching Dagster Launchpad source..."
    has_git || {
        echo "Git not found."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "Try: brew install git"
        else
            echo "Try:"
            echo -e "\t sudo apt install git    (Ubuntu/Debian)"
            echo -e "\t sudo dnf install git    (Fedora)"
        fi
        exit 1
    }

    local repo_dir
    repo_dir=$(fetch_dagster_repo)
    echo -e "Source stored in:\t${repo_dir}"
    run_launchpad "${repo_dir}"
}

try_to_install() {
    echo "Initializing Dagster Launchpad install..."
    local path_project path_installer
    path_project=$(realpath "${D_RUN_SCRIPT}/../../")
    path_installer="${path_project}/_scripts/launchpad/fn.install.sh"
    if [ -f "${path_installer}" ]; then
        run_launchpad "${path_project}"
    else
        fetch_and_install
    fi
}

try_to_install