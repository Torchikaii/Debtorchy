#!/bin/env bash

set -e

# keep sudo prompt in front
sudo date

# apps
bash ./ubuntu-utility/apps/docker.sh
bash ./ubuntu-utility/apps/terraform.sh
bash ./ubuntu-utility/apps/opencode.sh
bash ./ubuntu-utility/apps/brave.sh
bash ./ubuntu-utility/apps/alacritty.sh
bash ./ubuntu-utility/apps/keepassxc.sh
bash ./ubuntu-utility/apps/libreoffice.sh
bash ./ubuntu-utility/apps/p7zip.sh
bash ./ubuntu-utility/apps/git.sh
bash ./ubuntu-utility/apps/gh.sh
bash ./ubuntu-utility/apps/vim.sh
bash ./ubuntu-utility/apps/pyenv.sh
bash ./ubuntu-utility/apps/tmux.sh
bash ./ubuntu-utility/apps/tree.sh
bash ./ubuntu-utility/apps/python.sh
bash ./ubuntu-utility/apps/fd.sh
bash ./ubuntu-utility/apps/fzf.sh  # needs fd.sh
bash ./ubuntu-utility/apps/ripgrep.sh
bash ./ubuntu-utility/apps/rsync.sh
bash ./ubuntu-utility/apps/starship.sh

# desktop
bash ./ubuntu-utility/desktop/font-awesome.sh
bash ./ubuntu-utility/desktop/i3.sh
bash ./ubuntu-utility/desktop/feh.sh
bash ./ubuntu-utility/desktop/polybar.sh # needs font-awesome.sh
bash ./ubuntu-utility/desktop/picom.sh

# services
bash ./ubuntu-utility/services/ssh.sh
bash ./ubuntu-utility/services/cifs-utils.sh

# system configuration
bash ./ubuntu-utility/dotfiles.sh
bash ./ubuntu-utility/keyboard.sh
bash ./ubuntu-utility/fonts.sh

# python packages
# needs python.sh
bash ./ubuntu-utility/python/python-packages.sh
