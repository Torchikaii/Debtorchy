#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "libvirt-daemon-system.sh running"

if dpkg -s libvirt-daemon-system >/dev/null 2>&1; then
    log "libvirt-daemon-system already installed, skipping"
    exit 0
fi

log "Installing libvirt-daemon-system"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq libvirt-daemon-system >/dev/null 2>&1

log "Enabling libvirtd"
sudo systemctl enable --now libvirtd >/dev/null 2>&1

log "libvirt-daemon-system.sh completed"
