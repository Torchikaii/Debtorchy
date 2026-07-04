#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "wireplumber.sh running"

if dpkg -s wireplumber >/dev/null 2>&1; then
    log "wireplumber already installed, skipping"
    exit 0
fi

log "Installing wireplumber"
sudo apt update >/dev/null 2>&1
sudo apt install wireplumber -y -qq wireplumber >/dev/null 2>&1

log "wireplumber.sh completed"

