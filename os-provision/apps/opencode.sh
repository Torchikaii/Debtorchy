#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "opencode.sh running"

if command -v opencode >/dev/null 2>&1; then
    log "Opencode already installed, skipping"
    exit 0
fi

log "Installing Opencode"
curl -fsSL https://opencode.ai/install | bash

log "opencode.sh completed"
