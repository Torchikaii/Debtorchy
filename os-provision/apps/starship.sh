#!/bin/env bash

source "$(dirname "$0")/../commands/logging.sh"

log "starship.sh running"

if command -v starship >/dev/null 2>&1; then
    log "starship already installed, skipping"
    exit 0
fi

log "Installing starship from internet"
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

log "starship.sh completed"
