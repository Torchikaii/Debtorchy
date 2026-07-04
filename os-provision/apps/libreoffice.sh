#!/bin/bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

source "$(dirname "$0")/../commands/logging.sh"

log "libreoffice.sh running"

if dpkg -s libreoffice >/dev/null 2>&1; then
    log "LibreOffice already installed, skipping"
    exit 0
fi

log "Installing LibreOffice"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq libreoffice >/dev/null 2>&1

log "libreoffice.sh completed"
