#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "polybar.sh running"

if dpkg -s polybar >/dev/null 2>&1; then
    log "polybar already installed, skipping"
    exit 0
fi

log "Installing polybar"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq polybar

log "polybar.sh completed"
