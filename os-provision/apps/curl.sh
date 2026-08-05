#!/bin/bash

set -e

source "$(dirname "$0")/../commands/logging.sh"

log "curl.sh running"

if dpkg -s curl >/dev/null 2>&1; then
    log "curl already installed, skipping"
    exit 0
fi

log "Installing curl"
sudo apt-get update -qq
sudo apt install -y -qq curl

log "curl.sh completed"
