#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "pipewire.sh running"

if dpkg -s pipewire >/dev/null 2>&1; then
    log "pipewire already installed, skipping"
    exit 0
fi

log "Installing pipewire"
sudo apt update >/dev/null 2>&1
sudo apt install pipewire -y -qq pipewire >/dev/null 2>&1

log "pipewire.sh completed"

