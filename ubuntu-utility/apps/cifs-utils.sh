#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "cifs-utils.sh running"

if dpkg -s cifs-utils >/dev/null 2>&1; then
    log "cifs-utils already installed, skipping"
    exit 0
fi

log "Installing cifs-utils"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq cifs-utils >/dev/null 2>&1

log "cifs-utils.sh completed"
