#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "i3.sh running"

if dpkg -s i3 >/dev/null 2>&1; then
    log "i3 already installed, skipping"
    exit 0
fi

log "Installing i3 and related packages"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq i3

log "i3.sh completed"
