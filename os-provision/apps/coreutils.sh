#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "coreutils.sh running"

if dpkg -s coreutils >/dev/null 2>&1; then
    log "coreutils already installed, skipping"
    exit 0
fi

log "Installing coreutils"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq coreutils >/dev/null 2>&1

log "coreutils.sh completed"
