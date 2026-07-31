#!/bin/bash

source "$(dirname "$0")/commands/logging.sh"

log "dotfiles.sh running"

HOME_DIR="/home/pc"

# alacritty
mkdir -p "$HOME_DIR/.config/alacritty"
rm -f "$HOME_DIR/.config/alacritty/alacritty.toml"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/alacritty/alacritty.toml" "$HOME_DIR/.config/alacritty/alacritty.toml"

# bash
rm -f "$HOME_DIR/.bashrc"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/bash/.bashrc" "$HOME_DIR/.bashrc"

# vim
rm -f "$HOME_DIR/.vimrc"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/vim/.vimrc" "$HOME_DIR/.vimrc"
rm -rf "$HOME_DIR/.vim"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/vim/.vim" "$HOME_DIR/.vim"

# i3
mkdir -p "$HOME_DIR/.config/i3"
rm -f "$HOME_DIR/.config/i3/config"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/i3/config" "$HOME_DIR/.config/i3/config"

# polybar
mkdir -p "$HOME_DIR/.config/polybar"
rm -f "$HOME_DIR/.config/polybar/config"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/polybar/config" "$HOME_DIR/.config/polybar/config"

# picom
mkdir -p "$HOME_DIR/.config/picom"
rm -f "$HOME_DIR/.config/picom/picom.conf"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/picom/picom.conf" "$HOME_DIR/.config/picom/picom.conf"

# opencode
mkdir -p "$HOME_DIR/.config/opencode"
rm -f "$HOME_DIR/.config/opencode/opencode.json"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/opencode/opencode.json" "$HOME_DIR/.config/opencode/opencode.json"
rm -f "$HOME_DIR/.config/opencode/tui.json"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/opencode/tui.json" "$HOME_DIR/.config/opencode/tui.json"
rm -rf "$HOME_DIR/.config/opencode/themes"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/opencode/themes" "$HOME_DIR/.config/opencode/themes"

# starship
rm -f "$HOME_DIR/.config/starship.toml"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/starship/starship.toml" "$HOME_DIR/.config/starship.toml"

# x
rm -f "$HOME_DIR/.xinitrc"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/dotfiles/x/xinitrc" "$HOME_DIR/.xinitrc"

log "dotfiles.sh completed"
