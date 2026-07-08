#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "libvirt-clients.sh running"

if dpkg -s libvirt-clients >/dev/null 2>&1; then
    log "libvirt-clients already installed, skipping"
    exit 0
fi

log "Installing libvirt-clients"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq libvirt-clients >/dev/null 2>&1

log "libvirt-clients.sh completed"
