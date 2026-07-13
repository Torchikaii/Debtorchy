#!/bin/env bash

source "$(dirname "$0")/../commands/logging.sh"
source "$(dirname "$0")/../commands/mount.sh"

log "starship.sh running"

if command -v starship >/dev/null 2>&1; then
    log "starship already installed, skipping"
    exit 0
fi

NAS_CACHE="$TARGET_DIR/homelab-assets/Debtorchy-assets/packages/binaries/starship/starship"

if [ -f "$NAS_CACHE" ]; then
    log "Installing starship from local cache"
    sudo cp "$NAS_CACHE" /usr/local/bin/starship
    sudo chmod +x /usr/local/bin/starship
else
    log "Installing starship from internet"
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
fi

log "starship.sh completed"
