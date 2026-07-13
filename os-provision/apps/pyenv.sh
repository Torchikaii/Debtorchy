#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"
source "$(dirname "$0")/../commands/mount.sh"

log "pyenv.sh running"

if [ -d "$HOME/.pyenv" ]; then
    log "Pyenv already installed, skipping"
    exit 0
fi

NAS_CACHE="$TARGET_DIR/homelab-assets/Debtorchy-assets/packages/binaries/pyenv"

if [ -d "$NAS_CACHE" ] && [ -f "$NAS_CACHE/bin/pyenv" ]; then
    log "Installing pyenv from local cache"
    cp -a "$NAS_CACHE" "$HOME/.pyenv"
else
    log "Installing pyenv from internet"
    curl https://pyenv.run | bash
fi

log "pyenv.sh completed"
