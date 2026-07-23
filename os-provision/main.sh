#!/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

# ensure sudo is installed
if ! command -v sudo >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y -qq sudo
fi

# keep sudo prompt in front
sudo date

# configure local APT repo from NAS (if available)
# this step has to be skipped in CI
if [ -z "$CI" ]; then
    bash ./os-provision/commands/local-repo.sh
fi

cleanup_local_repo() {
    if [ "$NAS_MOUNTED" != "true" ]; then
        local local_repo_list="/etc/apt/sources.list.d/debtorchy-local.list"
        local local_repo_pin="/etc/apt/preferences.d/debtorchy-local"
        if [ -f "$local_repo_list" ]; then
            sudo rm -f "$local_repo_list" "$local_repo_pin"
            sudo apt-get update -qq 2>/dev/null || true
        fi
    fi
}
trap cleanup_local_repo EXIT

# core system packages
bash ./os-provision/apps/ca-certificates.sh

# audio
bash ./os-provision/apps/alsa-utils.sh
bash ./os-provision/apps/pipewire.sh
bash ./os-provision/apps/pipewire-pulse.sh
bash ./os-provision/apps/wireplumber.sh

# desktop
bash ./os-provision/apps/feh.sh
bash ./os-provision/apps/font-awesome.sh
bash ./os-provision/apps/i3.sh
bash ./os-provision/apps/picom.sh
bash ./os-provision/apps/polybar.sh # needs font-awesome.sh

# development
bash ./os-provision/apps/docker.sh
bash ./os-provision/apps/gh.sh
bash ./os-provision/apps/git.sh
bash ./os-provision/apps/opencode.sh
bash ./os-provision/apps/pyenv.sh
bash ./os-provision/apps/python.sh
bash ./os-provision/apps/terraform.sh
bash ./os-provision/apps/vim.sh
bash ./os-provision/apps/xorriso.sh

# virtualization
bash ./os-provision/apps/qemu-kvm.sh
bash ./os-provision/apps/libvirt-daemon-system.sh
bash ./os-provision/apps/libvirt-clients.sh
bash ./os-provision/apps/virtinst.sh
bash ./os-provision/apps/virt-manager.sh

# file tools
bash ./os-provision/apps/fd.sh
bash ./os-provision/apps/fzf.sh  # needs fd.sh
bash ./os-provision/apps/ripgrep.sh
bash ./os-provision/apps/rsync.sh
bash ./os-provision/apps/tree.sh

# networking
bash ./os-provision/apps/cifs-utils.sh
bash ./os-provision/apps/nfs-common.sh
bash ./os-provision/apps/smbclient.sh
bash ./os-provision/apps/ssh.sh

# shell
bash ./os-provision/apps/alacritty.sh
bash ./os-provision/apps/bash-completion.sh
bash ./os-provision/apps/starship.sh
bash ./os-provision/apps/tmux.sh

# package management
bash ./os-provision/apps/reprepro.sh

# system
bash ./os-provision/apps/brave.sh
bash ./os-provision/apps/coreutils.sh
bash ./os-provision/apps/keepassxc.sh
bash ./os-provision/apps/less.sh
bash ./os-provision/apps/lesspipe.sh
#bash ./os-provision/apps/libreoffice.sh
bash ./os-provision/apps/p7zip.sh

# system configuration
bash ./os-provision/dotfiles.sh
bash ./os-provision/fonts.sh

# python packages
# needs python.sh
bash ./os-provision/python/python-packages.sh
