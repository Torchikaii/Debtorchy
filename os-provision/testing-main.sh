#!/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

if ! command -v sudo >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y -qq sudo
fi

sudo date

if [ -z "$CI" ]; then
    bash ./os-provision/commands/local-repo.sh
fi

bash ./os-provision/apps/git.sh
bash ./os-provision/apps/vim.sh
