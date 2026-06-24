#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "nfs-common.sh running"

if dpkg -s nfs-common >/dev/null 2>&1; then
    log "nfs-common already installed, skipping"
    exit 0
fi

log "Installing nfs-common"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq nfs-common >/dev/null 2>&1

log "nfs-common.sh completed"

