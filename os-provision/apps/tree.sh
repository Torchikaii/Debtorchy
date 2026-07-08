#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "tree.sh running"

if dpkg -s tree >/dev/null 2>&1; then
    log "Tree already installed, skipping"
    exit 0
fi

log "Installing Tree"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq tree >/dev/null 2>&1

log "tree.sh completed"
