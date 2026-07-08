#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "git.sh running"

if dpkg -s git >/dev/null 2>&1; then
    log "Git already installed, skipping"
    exit 0
fi

log "Installing Git"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq git >/dev/null 2>&1

log "git.sh completed"
