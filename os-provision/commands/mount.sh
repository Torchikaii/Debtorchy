#!/bin/bash

MOUNT_POINT="/mnt/NAS2"
SERVER="//192.168.1.97/nas2"
CREDENTIALS="$HOME/.smbcredentials-nas2"
TARGET_DIR="$MOUNT_POINT/Server"
NAS_MOUNTED=false

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
    setup_credentials
fi

if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT" 2>/dev/null || true
fi

if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    NAS_MOUNTED=true
elif sudo mount -t cifs "$SERVER" "$MOUNT_POINT" \
    -o credentials="$CREDENTIALS",uid=$(id -u),gid=$(id -g),iocharset=utf8,vers=3.0 2>/dev/null; then
    NAS_MOUNTED=true
else
    echo "WARNING: NAS unreachable, continuing without local cache"
fi

export TARGET_DIR MOUNT_POINT SERVER NAS_MOUNTED
