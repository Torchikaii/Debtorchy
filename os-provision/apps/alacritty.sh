#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "alacritty.sh running"

if dpkg -s alacritty >/dev/null 2>&1; then
    log "Alacritty already installed, skipping"
    exit 0
fi

log "Installing Alacritty"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq alacritty >/dev/null 2>&1

log "alacritty.sh completed"
