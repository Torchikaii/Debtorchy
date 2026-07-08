#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "keepassxc.sh running"

if dpkg -s keepassxc >/dev/null 2>&1; then
    log "KeePassXC already installed, skipping"
    exit 0
fi

log "Installing KeePassXC"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq software-properties-common >/dev/null 2>&1
sudo add-apt-repository -y ppa:phoerious/keepassxc
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq keepassxc >/dev/null 2>&1

log "keepassxc.sh completed"
