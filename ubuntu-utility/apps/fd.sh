#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "fd.sh running"

if dpkg -s fd >/dev/null 2>&1; then
    log "fd already installed, skipping"
    exit 0
fi

log "Installing fd"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq fd >/dev/null 2>&1

log "fd.sh completed"
