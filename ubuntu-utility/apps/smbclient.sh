#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "smbclient.sh running"

if dpkg -s smbclient >/dev/null 2>&1; then
    log "smbclient already installed, skipping"
    exit 0
fi

log "Installing smbclient"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq smbclient >/dev/null 2>&1

log "smbclient.sh completed"
