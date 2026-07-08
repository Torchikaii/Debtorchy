#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "virt-manager.sh running"

if dpkg -s virt-manager >/dev/null 2>&1; then
    log "virt-manager already installed, skipping"
    exit 0
fi

log "Installing virt-manager"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq virt-manager >/dev/null 2>&1

log "virt-manager.sh completed"
