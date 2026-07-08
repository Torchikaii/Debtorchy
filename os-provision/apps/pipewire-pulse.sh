#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "pipewire-pulse.sh running"

if dpkg -s pipewire-pulse >/dev/null 2>&1; then
    log "pipewire-pulse already installed, skipping"
    exit 0
fi

log "Installing pipewire-pulse"
sudo apt update >/dev/null 2>&1
sudo apt install pipewire-pulse -y -qq pipewire-pulse >/dev/null 2>&1

log "pipewire-pulse.sh completed"

