#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"
source "$(dirname "$0")/../commands/mount.sh"

log "opencode.sh running"

if command -v opencode >/dev/null 2>&1; then
    log "Opencode already installed, skipping"
    exit 0
fi

NAS_CACHE="$TARGET_DIR/homelab-assets/Debtorchy-assets/packages/binaries/opencode/opencode"

if [ -f "$NAS_CACHE" ]; then
    log "Installing opencode from local cache"
    sudo cp "$NAS_CACHE" /usr/local/bin/opencode
    sudo chmod +x /usr/local/bin/opencode
else
    log "Installing opencode from internet"
    curl -fsSL https://opencode.ai/install | bash
fi

log "opencode.sh completed"
