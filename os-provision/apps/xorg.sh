#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "xorg.sh running"

if dpkg -s xorg >/dev/null 2>&1; then
    log "xorg already installed, skipping"
    exit 0
fi

log "Installing xorg"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq xorg >/dev/null 2>&1

log "xorg.sh completed"
