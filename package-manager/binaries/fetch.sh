#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/nas.sh"

BINARIES_LIST="$SCRIPT_DIR/binaries.list"

trap cleanup_staging EXIT

log "=== binaries/fetch.sh started ==="

mount_nas
ensure_nas_packages_dir

cleanup_staging
mkdir -p "$STAGING_DIR/binaries"

while IFS='|' read -r name url type; do
    [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue

    log "Fetching: $name ($type)"

    DEST_DIR="$BINARIES_DIR/$name"
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
