#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "software-properties-common.sh running"

if dpkg -s software-properties-common >/dev/null 2>&1; then
    log "software-properties-common already installed, skipping"
    exit 0
fi

log "Installing software-properties-common"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq software-properties-common >/dev/null 2>&1

log "software-properties-common.sh completed"
