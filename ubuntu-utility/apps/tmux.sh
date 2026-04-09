#!/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

source "$(dirname "$0")/../commands/logging.sh"

log "tmux.sh running"

if dpkg -s tmux >/dev/null 2>&1; then
    log "tmux already installed, skipping"
    exit 0
fi

log "Installing tmux"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq tmux >/dev/null 2>&1

log "tmux.sh completed"
