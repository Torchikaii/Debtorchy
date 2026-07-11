#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/nas.sh"

PACKAGES_LIST="$SCRIPT_DIR/packages.list"
EXTERNAL_REPOS="$SCRIPT_DIR/external-repos.list"

trap cleanup_staging EXIT

log "=== apt/update.sh started ==="

mount_nas
ensure_reprepro

if [ ! -d "$APT_REPO_DIR/dists" ]; then
    log "Local repo not found, run fetch.sh first"
    exit 1
fi

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

log "Checking for outdated packages"

REPREPRO_LIST=$(reprepro -b "$APT_REPO_DIR" list bookworm 2>/dev/null)

OUTDATED=""
while IFS= read -r pkg; do
    [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

    UPSTREAM=$(apt-cache policy "$pkg" 2>/dev/null | grep "Candidate:" | awk '{print $2}')
    CACHED=$(echo "$REPREPRO_LIST" | grep " $pkg " | awk '{print $NF}' | head -1)

    if [ -z "$UPSTREAM" ]; then
        log "Package $pkg not found in upstream repos, skipping"
        continue
    fi

    if [ -z "$CACHED" ]; then
        log "$pkg: not in local cache, will download"
        OUTDATED="$OUTDATED $pkg"
    elif [ "$UPSTREAM" != "$CACHED" ]; then
        log "$pkg: outdated ($CACHED -> $UPSTREAM)"
        OUTDATED="$OUTDATED $pkg"
    fi
done < "$PACKAGES_LIST"

if [ -z "$OUTDATED" ]; then
    log "All packages up to date, nothing to do"
    for f in /etc/apt/sources.list.d/*-fetch.list; do
        [ -f "$f" ] && sudo rm -f "$f"
    done
    log "=== apt/update.sh completed ==="
    exit 0
fi

log "Resolving dependency closures for outdated packages"

DEPS=$(apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances \
    $OUTDATED 2>/dev/null \
    | grep "^\w" | sort -u)

log "Downloading $(echo "$DEPS" | wc -l) packages"

cd "$STAGING_DIR/debs"
echo "$DEPS" | xargs -r apt-get download 2>/dev/null || true

log "Cleaning up temporary external repos"
for f in /etc/apt/sources.list.d/*-fetch.list; do
    [ -f "$f" ] && sudo rm -f "$f"
done

log "Updating local APT repository"

mkdir -p "$APT_REPO_DIR/conf"
cp "$SCRIPT_DIR/conf/distributions" "$APT_REPO_DIR/conf/distributions"

reprepro -b "$APT_REPO_DIR" includedeb bookworm "$STAGING_DIR/debs"/*.deb 2>/dev/null || true

log "Total packages in repo:"
reprepro -b "$APT_REPO_DIR" list bookworm 2>/dev/null | wc -l

log "=== apt/update.sh completed ==="
