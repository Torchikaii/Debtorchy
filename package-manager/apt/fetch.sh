#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/nas.sh"

PACKAGES_LIST="$SCRIPT_DIR/packages.list"
EXTERNAL_REPOS="$SCRIPT_DIR/external-repos.list"

trap cleanup_staging EXIT

log "=== apt/fetch.sh started ==="

mount_nas
ensure_nas_packages_dir
ensure_reprepro

cleanup_staging
mkdir -p "$STAGING_DIR/debs"
mkdir -p "$STAGING_DIR/repos"

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

log "Resolving dependency closures"

ALL_PACKAGES=""
while IFS= read -r pkg; do
    [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
    ALL_PACKAGES="$ALL_PACKAGES $pkg"
done < "$PACKAGES_LIST"

DEPS=$(apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances \
    $ALL_PACKAGES 2>/dev/null \
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
cp "$SCRIPT_DIR/conf/distributions" "$APT_REPO_DIR/conf/distributions"

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

log "=== apt/fetch.sh completed ==="
