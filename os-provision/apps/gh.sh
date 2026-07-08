#!/bin/env bash
set -e

source "$(dirname "$0")/../commands/logging.sh"

log "gh.sh running"

if dpkg -s gh >/dev/null 2>&1; then
    log "GitHub CLI already installed, skipping"
    exit 0
fi

log "Installing GitHub CLI"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq gitleaks >/dev/null 2>&1 || true
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null 2>&1
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq gh >/dev/null 2>&1

log "gh.sh completed"
