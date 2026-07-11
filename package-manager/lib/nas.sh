#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

setup_credentials() {
    echo "First-time setup: SMB credentials not found."
    read -rp "Username: " username
    read -rsp "Password: " password
    echo ""

    cat > "$CREDENTIALS" << EOF
username=$username
password=$password
EOF
    chmod 600 "$CREDENTIALS"
    echo "Credentials saved to $CREDENTIALS"
}

mount_nas() {
    if [ ! -f "$CREDENTIALS" ]; then
        setup_credentials
    fi

    if [ ! -d "$NAS_MOUNT" ]; then
        sudo mkdir -p "$NAS_MOUNT"
    fi

    if ! mountpoint -q "$NAS_MOUNT" 2>/dev/null; then
        log "Mounting NAS..."
        sudo mount -t cifs "$NAS_BASE" "$NAS_MOUNT" \
            -o credentials="$CREDENTIALS",uid=$(id -u),gid=$(id -g),iocharset=utf8,vers=3.0
        log "NAS mounted at $NAS_MOUNT"
    else
        log "NAS already mounted at $NAS_MOUNT"
    fi
}

ensure_nas_packages_dir() {
    mkdir -p "$APT_REPO_DIR"
    mkdir -p "$BINARIES_DIR"
}
