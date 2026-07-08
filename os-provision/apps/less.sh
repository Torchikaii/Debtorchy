#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "less.sh running"

if dpkg -s "less" >/dev/null 2>&1; then
    log "less already installed, skipping"
    exit 0
fi

log "Installing less"
sudo apt update >/dev/null 2>&1
sudo apt install "less" -y -qq "less" >/dev/null 2>&1

log "less.sh completed"

