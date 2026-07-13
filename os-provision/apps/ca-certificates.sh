#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "ca-certificates.sh running"

if dpkg -s ca-certificates >/dev/null 2>&1; then
    log "ca-certificates already installed, skipping"
    exit 0
fi

log "Installing ca-certificates"
sudo apt-get install -y -qq ca-certificates >/dev/null 2>&1

log "ca-certificates.sh completed"
