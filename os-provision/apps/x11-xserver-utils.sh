#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "x11-xserver-utils.sh running"

if dpkg -s x11-xserver-utils >/dev/null 2>&1; then
    log "x11-xserver-utils already installed, skipping"
    exit 0
fi

log "Installing x11-xserver-utils"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq x11-xserver-utils >/dev/null 2>&1

log "x11-xserver-utils.sh completed"
