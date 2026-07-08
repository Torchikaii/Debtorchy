#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "bash-completion.sh running"

if dpkg -s bash-completion >/dev/null 2>&1; then
    log "bash-completion already installed, skipping"
    exit 0
fi

log "Installing bash-completion"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq bash-completion >/dev/null 2>&1

log "bash-completion.sh completed"
