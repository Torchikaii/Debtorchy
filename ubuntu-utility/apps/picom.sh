#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "picom.sh running"

if dpkg -s picom >/dev/null 2>&1; then
    log "picom already installed, skipping"
    exit 0
fi

log "Installing picom"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq picom

log "picom.sh completed"
