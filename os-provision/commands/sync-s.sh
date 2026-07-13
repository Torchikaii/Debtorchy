#!/bin/bash

source "$(dirname "$0")/mount.sh"

SOURCE_FILE="$TARGET_DIR/main-subset/s/main.kdbx"
DEST_FILE="$HOME/Desktop/main.kbdx"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "ERROR: $SOURCE_FILE not found on NAS"
    exit 1
fi

rsync -avhP "$SOURCE_FILE" "$DEST_FILE"
