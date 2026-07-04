#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "rsync.sh running"

if dpkg -s rsync >/dev/null 2>&1; then
    log "rsync already installed, skipping"
    exit 0
fi

log "Installing rsync"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq rsync >/dev/null 2>&1

log "rsync.sh completed"
