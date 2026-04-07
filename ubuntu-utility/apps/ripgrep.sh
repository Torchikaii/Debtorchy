#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "ripgrep.sh running"

if dpkg -s ripgrep >/dev/null 2>&1; then
    log "ripgrep already installed, skipping"
    exit 0
fi

log "Installing ripgrep"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq ripgrep >/dev/null 2>&1

log "ripgrep.sh completed"
