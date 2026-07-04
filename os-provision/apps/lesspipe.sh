#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "lesspipe.sh running"

if command -v lesspipe >/dev/null 2>&1; then
    log "lesspipe already installed, skipping"
    exit 0
fi

log "Installing lesspipe"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq less >/dev/null 2>&1

log "lesspipe.sh completed"

