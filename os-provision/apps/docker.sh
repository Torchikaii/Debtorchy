#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "docker.sh running"

if dpkg -s docker-ce >/dev/null 2>&1; then
    log "Docker already installed, skipping"
    exit 0
fi

log "Installing Docker"
sudo apt remove -y docker.io docker-compose podman-docker >/dev/null 2>&1 || true
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq ca-certificates curl >/dev/null 2>&1
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1
sudo systemctl enable docker --now

log "docker.sh completed"
