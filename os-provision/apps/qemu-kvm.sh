#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "qemu-kvm.sh running"

if command -v kvm >/dev/null 2>&1; then
    log "qemu-kvm already installed, skipping"
    exit 0
fi

log "Installing qemu-kvm"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq qemu-kvm >/dev/null 2>&1

log "qemu-kvm.sh completed"
