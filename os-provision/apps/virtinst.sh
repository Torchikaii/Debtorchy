#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "virtinst.sh running"

if dpkg -s virtinst >/dev/null 2>&1; then
    log "virtinst already installed, skipping"
    exit 0
fi

log "Installing virtinst"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq virtinst >/dev/null 2>&1

log "virtinst.sh completed"
