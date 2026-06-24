#!/bin/env bash

set -e

# keep sudo prompt in front
sudo date

# audio
bash ./ubuntu-utility/apps/alsa-utils.sh
bash ./ubuntu-utility/apps/pipewire.sh
bash ./ubuntu-utility/apps/pipewire-pulse.sh
bash ./ubuntu-utility/apps/wireplumber.sh

# desktop
bash ./ubuntu-utility/apps/feh.sh
bash ./ubuntu-utility/apps/font-awesome.sh
bash ./ubuntu-utility/apps/i3.sh
bash ./ubuntu-utility/apps/picom.sh
bash ./ubuntu-utility/apps/polybar.sh # needs font-awesome.sh

# development
bash ./ubuntu-utility/apps/docker.sh
bash ./ubuntu-utility/apps/gh.sh
bash ./ubuntu-utility/apps/git.sh
bash ./ubuntu-utility/apps/opencode.sh
bash ./ubuntu-utility/apps/pyenv.sh
bash ./ubuntu-utility/apps/python.sh
bash ./ubuntu-utility/apps/terraform.sh
bash ./ubuntu-utility/apps/vim.sh

# file tools
bash ./ubuntu-utility/apps/fd.sh
bash ./ubuntu-utility/apps/fzf.sh  # needs fd.sh
bash ./ubuntu-utility/apps/ripgrep.sh
bash ./ubuntu-utility/apps/rsync.sh
bash ./ubuntu-utility/apps/tree.sh

# networking
bash ./ubuntu-utility/apps/cifs-utils.sh
bash ./ubuntu-utility/apps/nfs-common.sh
bash ./ubuntu-utility/apps/smbclient.sh
bash ./ubuntu-utility/apps/ssh.sh

# shell
bash ./ubuntu-utility/apps/alacritty.sh
bash ./ubuntu-utility/apps/bash-completion.sh
bash ./ubuntu-utility/apps/starship.sh
bash ./ubuntu-utility/apps/tmux.sh

# system
bash ./ubuntu-utility/apps/brave.sh
bash ./ubuntu-utility/apps/coreutils.sh
bash ./ubuntu-utility/apps/keepassxc.sh
bash ./ubuntu-utility/apps/less.sh
bash ./ubuntu-utility/apps/lesspipe.sh
bash ./ubuntu-utility/apps/libreoffice.sh
bash ./ubuntu-utility/apps/p7zip.sh

# system configuration
bash ./ubuntu-utility/dotfiles.sh
bash ./ubuntu-utility/keyboard.sh
bash ./ubuntu-utility/fonts.sh

# python packages
# needs python.sh
bash ./ubuntu-utility/python/python-packages.sh
