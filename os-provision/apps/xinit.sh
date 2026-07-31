#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "xinit.sh running"

if dpkg -s xinit >/dev/null 2>&1; then
    log "xinit already installed, skipping"
    exit 0
fi

log "Installing xinit"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq xinit >/dev/null 2>&1

log "xinit.sh completed"
