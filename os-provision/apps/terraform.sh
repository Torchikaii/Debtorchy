#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "terraform.sh running"

if dpkg -s terraform >/dev/null 2>&1; then
    log "Terraform already installed, skipping"
    exit 0
fi

log "Installing Terraform"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq wget gnupg >/dev/null 2>&1
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg
echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq terraform >/dev/null 2>&1

log "terraform.sh completed"
