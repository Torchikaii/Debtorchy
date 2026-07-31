#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "gnupg.sh running"

if dpkg -s gnupg >/dev/null 2>&1; then
    log "gnupg already installed, skipping"
    exit 0
fi

log "Installing gnupg"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq gnupg >/dev/null 2>&1

log "gnupg.sh completed"
