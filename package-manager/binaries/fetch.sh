#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_ROOT/os-provision/commands/logging.sh"
source "$REPO_ROOT/os-provision/commands/mount.sh"

NAS_PACKAGES="$MOUNT_POINT/Server/homelab-assets/Debtorchy-assets/packages"
BINARIES_DIR="$NAS_PACKAGES/binaries"
STAGING_DIR="/tmp/debtorchy-pkg-staging"

BINARIES_LIST="$SCRIPT_DIR/binaries.list"

cleanup_staging() {
    if [ -d "$STAGING_DIR" ]; then
        rm -rf "$STAGING_DIR"
    fi
}

trap cleanup_staging EXIT

log "=== binaries/fetch.sh started ==="

if [ "$NAS_MOUNTED" != "true" ]; then
    log "NAS not available, cannot fetch binaries"
    exit 1
fi

mkdir -p "$BINARIES_DIR"

cleanup_staging
mkdir -p "$STAGING_DIR/binaries"

while IFS='|' read -r name url type; do
    [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue

    DEST_DIR="$BINARIES_DIR/$name"

    if [ -d "$DEST_DIR" ] && [ "$(ls -A "$DEST_DIR" 2>/dev/null)" ]; then
        log "$name: already cached, skipping"
        continue
    fi

    log "Fetching: $name ($type)"

    mkdir -p "$DEST_DIR"

    case "$type" in
        binary)
            curl -fsSL "$url" -o "$DEST_DIR/$name"
            chmod +x "$DEST_DIR/$name"
            log "Downloaded binary: $name"
            ;;
        tarball)
            ARCHIVE="$STAGING_DIR/binaries/$name.tar.gz"
            EXTRACT_DIR="$STAGING_DIR/binaries/$name-extract"
            curl -fsSL "$url" -o "$ARCHIVE"
            rm -rf "$EXTRACT_DIR"
            mkdir -p "$EXTRACT_DIR"
            if [ "$name" = "pyenv" ]; then
                tar -xzf "$ARCHIVE" -C "$EXTRACT_DIR" --strip-components=1
            else
                tar -xzf "$ARCHIVE" -C "$EXTRACT_DIR"
            fi
            rm -rf "$DEST_DIR"
            cp -aL "$EXTRACT_DIR" "$DEST_DIR"
            rm -rf "$EXTRACT_DIR"
            log "Extracted tarball: $name"
            ;;
        deb)
            DEB_FILE="$STAGING_DIR/binaries/$name.deb"
            curl -fsSL "$url" -o "$DEB_FILE"
            cp "$DEB_FILE" "$DEST_DIR/"
            log "Downloaded deb: $name"
            ;;
        *)
            log "Unknown type: $type for $name, skipping"
            ;;
    esac
done < "$BINARIES_LIST"

log "=== binaries/fetch.sh completed ==="
