#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_ROOT/os-provision/commands/logging.sh"
source "$REPO_ROOT/os-provision/commands/mount.sh"

NAS_PACKAGES="$MOUNT_POINT/Server/homelab-assets/Debtorchy-assets/packages"
APT_REPO_DIR="$NAS_PACKAGES/apt-repo"
STAGING_DIR="/tmp/debtorchy-pkg-staging"

PACKAGES_LIST="$SCRIPT_DIR/packages.list"
EXTERNAL_REPOS="$SCRIPT_DIR/external-repos.list"

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

ensure_dirs() {
    mkdir -p "$NAS_PACKAGES/binaries"
    mkdir -p "$APT_REPO_DIR"
}

trap cleanup_staging EXIT

log "=== apt/sync.sh started ==="

if [ "$NAS_MOUNTED" != "true" ]; then
    log "NAS not available, cannot sync"
    exit 1
fi

ensure_dirs
ensure_reprepro

cleanup_staging
mkdir -p "$STAGING_DIR/debs"

log "Adding external repositories temporarily"

while IFS='|' read -r name gpg_url deb_line; do
    [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue

    log "Adding repo: $name"
    eval "deb_line=\"$deb_line\""

    if [[ "$name" == "docker" ]]; then
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL "$gpg_url" -o /etc/apt/keyrings/docker.asc
    elif [[ "$name" == "gh" ]]; then
        curl -fsSL "$gpg_url" | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null 2>&1
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    elif [[ "$name" == "hashicorp" ]]; then
        sudo wget -qO- "$gpg_url" | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg
    fi

    echo "$deb_line" | sudo tee "/etc/apt/sources.list.d/${name}-fetch.list" >/dev/null
done < "$EXTERNAL_REPOS"

log "Running apt-get update"
sudo apt-get update -qq

log "Checking package status against local repo"

REPREPRO_LIST=""
if [ -d "$APT_REPO_DIR/dists" ]; then
    REPREPRO_LIST=$(reprepro -b "$APT_REPO_DIR" list bookworm 2>/dev/null)
fi

MISSING=""
OUTDATED=""
while IFS= read -r pkg; do
    [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

    UPSTREAM=$(apt-cache policy "$pkg" 2>/dev/null | grep "Candidate:" | awk '{print $2}')

    if [ -z "$UPSTREAM" ]; then
        log "Package $pkg not found in upstream repos, skipping"
        continue
    fi

    if [ -z "$REPREPRO_LIST" ]; then
        log "$pkg: no local repo, will download"
        MISSING="$MISSING $pkg"
        continue
    fi

    CACHED=$(echo "$REPREPRO_LIST" | grep " $pkg " | awk '{print $NF}' | head -1)

    if [ -z "$CACHED" ]; then
        log "$pkg: not in local cache, will download"
        MISSING="$MISSING $pkg"
    elif [ "$UPSTREAM" != "$CACHED" ]; then
        log "$pkg: outdated ($CACHED -> $UPSTREAM)"
        OUTDATED="$OUTDATED $pkg"
    fi
done < "$PACKAGES_LIST"

TO_DOWNLOAD="$MISSING $OUTDATED"

if [ -z "$TO_DOWNLOAD" ]; then
    log "Cleaning up temporary external repos"
    for f in /etc/apt/sources.list.d/*-fetch.list; do
        [ -f "$f" ] && sudo rm -f "$f"
    done
    log "All packages current"
    log "=== apt/sync.sh completed ==="
    exit 0
fi

log "Resolving dependency closures for $(echo "$TO_DOWNLOAD" | wc -w) packages"

DEPS=$(apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances \
    $TO_DOWNLOAD 2>/dev/null \
    | grep "^\w" | sort -u)

log "Downloading $(echo "$DEPS" | wc -l) packages (including dependencies)"

cd "$STAGING_DIR/debs"
echo "$DEPS" | xargs -r apt-get download 2>/dev/null || true

log "Cleaning up temporary external repos"
for f in /etc/apt/sources.list.d/*-fetch.list; do
    [ -f "$f" ] && sudo rm -f "$f"
done

log "Building local APT repository with reprepro"

mkdir -p "$APT_REPO_DIR/conf"
cp "$SCRIPT_DIR/distributions" "$APT_REPO_DIR/conf/distributions"

if [ -d "$APT_REPO_DIR/db" ]; then
    log "Updating existing repo"
    reprepro -b "$APT_REPO_DIR" includedeb bookworm "$STAGING_DIR/debs"/*.deb 2>/dev/null || true
else
    log "Creating new repo"
    reprepro -b "$APT_REPO_DIR" includedeb bookworm "$STAGING_DIR/debs"/*.deb
fi

log "Repository updated at $APT_REPO_DIR"
log "Total packages in repo:"
reprepro -b "$APT_REPO_DIR" list bookworm 2>/dev/null | wc -l

log "=== apt/sync.sh completed ==="
