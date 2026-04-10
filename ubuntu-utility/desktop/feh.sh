#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "feh.sh running"

if dpkg -s feh >/dev/null 2>&1; then
    log "feh already installed, skipping"
    exit 0
fi

log "Installing feh and related packages"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq feh

log "feh.sh completed"
