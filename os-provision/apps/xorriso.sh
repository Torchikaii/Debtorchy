#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "xorriso.sh running"

if dpkg -s xorriso >/dev/null 2>&1; then
    log "xorriso already installed, skipping"
    exit 0
fi

log "Installing xorriso"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq xorriso >/dev/null 2>&1

log "xorriso.sh completed"
