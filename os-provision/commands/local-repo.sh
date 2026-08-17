#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/logging.sh"
source "$SCRIPT_DIR/mount.sh"

LOCAL_REPO_LIST="/etc/apt/sources.list.d/debtorchy-local.list"
LOCAL_REPO_PIN="/etc/apt/preferences.d/debtorchy-local"
NAS_PACKAGES="$TARGET_DIR/homelab-assets/Debtorchy-assets/packages"
APT_REPO_DIR="$NAS_PACKAGES/apt-repo"
BINARIES_LIST="$REPO_ROOT/package-manager/binaries/binaries.list"

if [ "$NAS_MOUNTED" != "true" ]; then
    if [ -f "$LOCAL_REPO_LIST" ]; then
        log "NAS unavailable — removing stale local repo config"
        sudo rm -f "$LOCAL_REPO_LIST" "$LOCAL_REPO_PIN"
        sudo apt-get update -qq 2>/dev/null || true
    fi
    log "NAS not available, skipping local repo setup"
    exit 0
fi

log "Configuring APT to use local repo"

echo "deb [trusted=yes] file://$APT_REPO_DIR bookworm main" | sudo tee "$LOCAL_REPO_LIST" >/dev/null

sudo tee "$LOCAL_REPO_PIN" >/dev/null << 'EOF'
Package: *
Pin: release o=Debtorchy-Local
Pin-Priority: 900
EOF

log "Updating APT package lists"
sudo apt-get update -qq || log "apt-get update: some sources failed"

log "Installing non-apt binaries from NAS cache"

while IFS='|' read -r name url type; do
    [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue

    case "$type" in
        binary)
            if [ -f "/usr/local/bin/$name" ]; then
                log "$name: already installed, skipping"
                continue
            fi
            NAS_CACHE="$NAS_PACKAGES/binaries/$name/$name"
            if [ -f "$NAS_CACHE" ]; then
                log "Installing $name from NAS cache"
                sudo cp "$NAS_CACHE" "/usr/local/bin/$name"
                sudo chmod +x "/usr/local/bin/$name"
            else
                log "$name: not in NAS cache, will be installed from internet"
            fi
            ;;
        tarball)
            case "$name" in
                starship)
                    if command -v starship >/dev/null 2>&1; then
                        log "$name: already installed, skipping"
                        continue
                    fi
                    ;;
                pyenv)
                    if [ -d "$HOME/.pyenv" ]; then
                        log "$name: already installed, skipping"
                        continue
                    fi
                    ;;
                opencode)
                    if command -v opencode >/dev/null 2>&1; then
                        log "$name: already installed, skipping"
                        continue
                    fi
                    ;;
            esac
            NAS_CACHE="$NAS_PACKAGES/binaries/$name"
            if [ -d "$NAS_CACHE" ]; then
                log "Installing $name from NAS cache"
                case "$name" in
                    pyenv)
                        cp -a "$NAS_CACHE" "$HOME/.pyenv"
                        ;;
                    starship)
                        sudo cp "$NAS_CACHE/starship" /usr/local/bin/starship
                        sudo chmod +x /usr/local/bin/starship
                        ;;
                    opencode)
                        sudo cp "$NAS_CACHE/opencode" /usr/local/bin/opencode
                        sudo chmod +x /usr/local/bin/opencode
                        ;;
                esac
            else
                log "$name: not in NAS cache, will be installed from internet"
            fi
            ;;
        deb)
            if dpkg -s "$name" >/dev/null 2>&1; then
                log "$name: already installed, skipping"
                continue
            fi
            NAS_CACHE="$NAS_PACKAGES/binaries/$name"
            if ls "$NAS_CACHE"/*.deb >/dev/null 2>&1; then
                log "Installing $name from NAS cache"
                sudo dpkg -i "$NAS_CACHE"/*.deb
                sudo apt-get install -y -qq -f
            else
                log "$name: not in NAS cache, will be installed from internet"
            fi
            ;;
    esac
done < "$BINARIES_LIST"

log "local-repo.sh completed"
