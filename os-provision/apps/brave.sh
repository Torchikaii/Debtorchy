#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "brave.sh running"

if dpkg -s brave-browser >/dev/null 2>&1; then
    log "Brave already installed, skipping"
    exit 0
fi

log "Installing Brave Browser"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq curl >/dev/null 2>&1
curl -fsS https://dl.brave.com/install.sh | bash

log "brave.sh completed"
