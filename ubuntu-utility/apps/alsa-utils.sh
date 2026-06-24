#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "alsa-utils.sh running"

if dpkg -s alsa-utils >/dev/null 2>&1; then
    log "alsa-utils already installed, skipping"
    exit 0
fi

log "Installing alsa-utils"
sudo apt update >/dev/null 2>&1
sudo apt install alsa-utils -y -qq alsa-utils >/dev/null 2>&1

log "alsa-utils.sh completed"

