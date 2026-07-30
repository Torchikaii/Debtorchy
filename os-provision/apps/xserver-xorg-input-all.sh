#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "xserver-xorg-input-all.sh running"

if dpkg -s xserver-xorg-input-all >/dev/null 2>&1; then
    log "xserver-xorg-input-all already installed, skipping"
    exit 0
fi

log "Installing xserver-xorg-input-all"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq xserver-xorg-input-all >/dev/null 2>&1

log "xserver-xorg-input-all.sh completed"
