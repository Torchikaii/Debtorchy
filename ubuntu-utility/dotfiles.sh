#!/bin/bash

source "$(dirname "$0")/commands/logging.sh"

log "dotfiles.sh running"

# alacritty
mkdir -p ~/.config/alacritty
rm -f ~/.config/alacritty/alacritty.toml
ln -s ~/repos/utils/ubuntu-utility/dotfiles/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml

# bash
rm -f ~/.bashrc
ln -s ~/repos/utils/ubuntu-utility/dotfiles/bash/.bashrc ~/.bashrc

# vim
rm -f ~/.vimrc
ln -s ~/repos/utils/ubuntu-utility/dotfiles/vim/.vimrc ~/.vimrc
rm -rf ~/.vim
ln -s ~/repos/utils/ubuntu-utility/dotfiles/vim/.vim ~/.vim

# i3
mkdir -p ~/.config/i3
rm -f ~/.config/i3/config
ln -s ~/repos/utils/ubuntu-utility/dotfiles/i3/config ~/.config/i3/config

# polybar
mkdir -p ~/.config/polybar
rm -f ~/.config/polybar/config
ln -s ~/repos/utils/ubuntu-utility/dotfiles/polybar/config ~/.config/polybar/config

log "dotfiles.sh completed"
