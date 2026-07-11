#!/bin/bash

MOUNT_POINT="/mnt/NAS2"
SMB_SERVER="//192.168.1.97/nas2"
CREDENTIALS="$HOME/.smbcredentials-nas2"
SOURCE_FILE="$MOUNT_POINT/Server/main-subset/s/main.kdbx"
DEST_FILE="$HOME/Desktop/main.kbdx"

if ! mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    echo "NAS not mounted, mounting..."
    if [ ! -f "$CREDENTIALS" ]; then
        read -rp "Username: " username
        read -rsp "Password: " password
        echo ""
        cat > "$CREDENTIALS" << EOF
username=$username
password=$password
EOF
        chmod 600 "$CREDENTIALS"
    fi

    if [ ! -d "$MOUNT_POINT" ]; then
        sudo mkdir -p "$MOUNT_POINT"
    fi

    sudo mount -t cifs "$SMB_SERVER" "$MOUNT_POINT" \
        -o credentials="$CREDENTIALS",uid=$(id -u),gid=$(id -g),iocharset=utf8,vers=3.0
fi

if [ ! -f "$SOURCE_FILE" ]; then
    echo "ERROR: $SOURCE_FILE not found on NAS"
    return 1
fi

rsync -avhP "$SOURCE_FILE" "$DEST_FILE"
