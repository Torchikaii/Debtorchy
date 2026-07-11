#!/bin/bash

set -e

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$LIB_DIR/../.." && pwd)"

NAS_BASE="//192.168.1.97/nas2"
NAS_MOUNT="/mnt/NAS2"
NAS_PACKAGES="$NAS_MOUNT/Server/homelab-assets/Debtorchy-assets/packages"
CREDENTIALS="$HOME/.smbcredentials-nas2"

APT_REPO_DIR="$NAS_PACKAGES/apt-repo"
BINARIES_DIR="$NAS_PACKAGES/binaries"

STAGING_DIR="/tmp/debtorchy-pkg-staging"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

cleanup_staging() {
    if [ -d "$STAGING_DIR" ]; then
        rm -rf "$STAGING_DIR"
    fi
}

ensure_reprepro() {
    if ! command -v reprepro >/dev/null 2>&1; then
        log "Installing reprepro"
        sudo apt-get update -qq
        sudo apt-get install -y -qq reprepro
    fi
}
