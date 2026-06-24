#!/bin/env bash

source "$(dirname "$0")/commands/logging.sh"

log "fonts.sh running"

# set up Nerd Font
rm -rf ~/.local/share/fonts
ln -s ~/repos/utils/ubuntu-utility/assets/fonts ~/.local/share/fonts

log "fonts.sh completed"
