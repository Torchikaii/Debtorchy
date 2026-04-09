#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "fzf.sh running"

if dpkg -s fzf >/dev/null 2>&1; then
    log "fzf already installed, skipping"
    exit 0
fi

log "Installing fzf"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq fzf >/dev/null 2>&1

log "fzf.sh completed"
