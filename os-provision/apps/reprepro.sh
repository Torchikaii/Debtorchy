#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "reprepro.sh running"

if dpkg -s reprepro >/dev/null 2>&1; then
    log "reprepro already installed, skipping"
    exit 0
fi

log "Installing reprepro"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq reprepro >/dev/null 2>&1

log "reprepro.sh completed"
