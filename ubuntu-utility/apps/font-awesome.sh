#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "font-awesome.sh running"

if dpkg -s fonts-font-awesome >/dev/null 2>&1; then
    log "fonts-font-awesome already installed, skipping"
    exit 0
fi

log "Installing fonts-font-awesome"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq fonts-font-awesome

log "font-awesome.sh completed"
