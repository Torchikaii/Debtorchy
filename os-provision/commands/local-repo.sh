#!/bin/bash

set -e

source "$(dirname "$0")/../commands/logging.sh"
source "$(dirname "$0")/mount.sh"

if [ "$NAS_MOUNTED" != "true" ]; then
    log "NAS not available, skipping local repo setup"
    exit 0
fi

APT_REPO_DIR="$TARGET_DIR/homelab-assets/Debtorchy-assets/packages/apt-repo"
LOCAL_REPO_LIST="/etc/apt/sources.list.d/debtorchy-local.list"
LOCAL_REPO_PIN="/etc/apt/preferences.d/debtorchy-local"

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
