#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "=== apt/update.sh — refreshing package cache ==="

bash "$SCRIPT_DIR/fetch.sh"

log "=== apt/update.sh completed ==="
