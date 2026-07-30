#!/bin/env bash

source "$(dirname "$0")/commands/logging.sh"

log "fonts.sh running"

HOME_DIR="/home/pc"

# set up Nerd Font
rm -rf "$HOME_DIR/.local/share/fonts"
ln -s "$HOME_DIR/repos/Debtorchy/os-provision/assets/fonts" "$HOME_DIR/.local/share/fonts"

log "fonts.sh completed"
