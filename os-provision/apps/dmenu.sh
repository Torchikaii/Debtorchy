#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "dmenu.sh running"

if command -v dmenu_run >/dev/null 2>&1; then
    log "dmenu already installed, skipping"
    exit 0
fi

log "Installing dmenu"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq dmenu >/dev/null 2>&1

log "dmenu.sh completed"
