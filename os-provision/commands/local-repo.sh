#!/bin/bash

set -e

source "$(dirname "$0")/../commands/logging.sh"

NAS_BASE="//192.168.1.97/nas2"
NAS_MOUNT="/mnt/NAS2"
CREDENTIALS="$HOME/.smbcredentials-nas2"
NAS_PACKAGES="$NAS_MOUNT/Server/homelab-assets/Debtorchy-assets/packages"
APT_REPO_DIR="$NAS_PACKAGES/apt-repo"
LOCAL_REPO_LIST="/etc/apt/sources.list.d/debtorchy-local.list"
LOCAL_REPO_PIN="/etc/apt/preferences.d/debtorchy-local"

log "local-repo.sh running"

if [ ! -f "$CREDENTIALS" ]; then
    log "SMB credentials not found, skipping local repo setup"
    exit 0
fi

if [ ! -d "$NAS_MOUNT" ]; then
    sudo mkdir -p "$NAS_MOUNT"
fi

if ! mountpoint -q "$NAS_MOUNT" 2>/dev/null; then
    log "Mounting NAS..."
    sudo mount -t cifs "$NAS_BASE" "$NAS_MOUNT" \
        -o credentials="$CREDENTIALS",uid=$(id -u),gid=$(id -g),iocharset=utf8,vers=3.0
fi

if [ ! -d "$APT_REPO_DIR/dists" ]; then
    log "Local APT repo not found on NAS, skipping local repo setup"
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
