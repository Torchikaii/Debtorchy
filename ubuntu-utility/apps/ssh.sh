#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "ssh.sh running"

if dpkg -s openssh-server >/dev/null 2>&1; then
    log "OpenSSH server already installed, skipping"
    exit 0
fi

log "Installing openssh-server"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq openssh-server >/dev/null 2>&1
sudo systemctl enable ssh --now

log "ssh.sh completed"
