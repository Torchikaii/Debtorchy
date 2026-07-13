#!/bin/bash

MOUNT_POINT="/mnt/NAS2"
SERVER="//192.168.1.97/nas2"
CREDENTIALS="$HOME/.smbcredentials-nas2"
TARGET_DIR="$MOUNT_POINT/Server"

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

if [ ! -f "$CREDENTIALS" ]; then
    if [ -n "$CI" ] || [ ! -t 0 ]; then
        echo "WARN: SMB credentials not found, skipping NAS mount"
        return 1 2>/dev/null || exit 1
    fi
    setup_credentials
fi

if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
fi

if ! mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    if ! sudo mount -t cifs "$SERVER" "$MOUNT_POINT" \
        -o credentials="$CREDENTIALS",uid=$(id -u),gid=$(id -g),iocharset=utf8,vers=3.0; then
        echo "ERROR: Failed to mount $SERVER at $MOUNT_POINT"
        return 1 2>/dev/null || exit 1
    fi
fi

export TARGET_DIR MOUNT_POINT SERVER
