#!/bin/bash

source "$(dirname "$0")/commands/logging.sh"

log "dotfiles.sh running"

# alacritty
mkdir -p ~/.config/alacritty
rm -f ~/.config/alacritty/alacritty.toml
ln -s ~/repos/Debtorchy/os-provision/dotfiles/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml

# bash
rm -f ~/.bashrc
ln -s ~/repos/Debtorchy/os-provision/dotfiles/bash/.bashrc ~/.bashrc

# vim
rm -f ~/.vimrc
ln -s ~/repos/Debtorchy/os-provision/dotfiles/vim/.vimrc ~/.vimrc
rm -rf ~/.vim
ln -s ~/repos/Debtorchy/os-provision/dotfiles/vim/.vim ~/.vim

# i3
mkdir -p ~/.config/i3
rm -f ~/.config/i3/config
ln -s ~/repos/Debtorchy/os-provision/dotfiles/i3/config ~/.config/i3/config

# polybar
mkdir -p ~/.config/polybar
rm -f ~/.config/polybar/config
ln -s ~/repos/Debtorchy/os-provision/dotfiles/polybar/config ~/.config/polybar/config

# picom
mkdir -p ~/.config/picom
rm -f ~/.config/picom/picom.conf
ln -s ~/repos/Debtorchy/os-provision/dotfiles/picom/picom.conf ~/.config/picom/picom.conf

# opencode
mkdir -p ~/.config/opencode
rm -f ~/.config/opencode/opencode.json
ln -s ~/repos/Debtorchy/os-provision/dotfiles/opencode/opencode.json ~/.config/opencode/opencode.json
rm -f ~/.config/opencode/tui.json
ln -s ~/repos/Debtorchy/os-provision/dotfiles/opencode/tui.json ~/.config/opencode/tui.json
rm -rf ~/.config/opencode/themes
ln -s ~/repos/Debtorchy/os-provision/dotfiles/opencode/themes ~/.config/opencode/themes

# starship
rm -f ~/.config/starship.toml
ln -s ~/repos/Debtorchy/os-provision/dotfiles/starship/starship.toml ~/.config/starship.toml

log "dotfiles.sh completed"
