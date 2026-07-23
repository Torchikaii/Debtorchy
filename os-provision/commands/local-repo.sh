#!/bin/bash

set -e

source "$(dirname "$0")/../commands/logging.sh"
source "$(dirname "$0")/mount.sh"

LOCAL_REPO_LIST="/etc/apt/sources.list.d/debtorchy-local.list"
LOCAL_REPO_PIN="/etc/apt/preferences.d/debtorchy-local"
APT_REPO_DIR="$TARGET_DIR/homelab-assets/Debtorchy-assets/packages/apt-repo"

if [ "$NAS_MOUNTED" != "true" ]; then
    if [ -f "$LOCAL_REPO_LIST" ]; then
        log "NAS unavailable — removing stale local repo config"
        sudo rm -f "$LOCAL_REPO_LIST" "$LOCAL_REPO_PIN"
        sudo apt-get update -qq
    fi
    log "NAS not available, skipping local repo setup"
    exit 0
fi

if [ ! -d "$APT_REPO_DIR/dists" ]; then
    log "Local APT repo not found on NAS, skipping"
    exit 0
fi

log "Configuring APT to use local repo"

echo "deb [trusted=yes] file://$APT_REPO_DIR bookworm main" | sudo tee "$LOCAL_REPO_LIST" >/dev/null

sudo tee "$LOCAL_REPO_PIN" >/dev/null << 'EOF'
Package: *
Pin: release o=Debtorchy-Local
Pin-Priority: 900
EOF

log "Updating APT package lists"
sudo apt-get update -qq

log "local-repo.sh completed"
