#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "brave.sh running"

if dpkg -s brave-browser >/dev/null 2>&1; then
    log "Brave already installed, skipping"
    exit 0
fi

NAS_CACHE="/mnt/NAS2/Server/homelab-assets/Debtorchy-assets/packages/binaries/brave"

if ls "$NAS_CACHE"/*.deb >/dev/null 2>&1; then
    log "Installing Brave from local cache"
    sudo dpkg -i "$NAS_CACHE"/*.deb
    sudo apt-get install -y -qq -f
else
    log "Installing Brave from internet"
    sudo apt-get install -y -qq curl >/dev/null 2>&1
    curl -fsS https://dl.brave.com/install.sh | bash
fi

log "brave.sh completed"
