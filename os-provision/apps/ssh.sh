#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "ssh.sh running"

if [ "$TESTING" != "true" ]; then
    log "TESTING not set, skipping SSH setup"
    exit 0
fi

if dpkg -s openssh-server >/dev/null 2>&1; then
    log "OpenSSH server already installed, skipping"
    exit 0
fi

log "Installing openssh-server"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq openssh-server >/dev/null 2>&1

log "Enabling password auth for all users (TESTING mode)"
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl enable ssh --now

log "ssh.sh completed"
