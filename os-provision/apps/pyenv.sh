#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "pyenv.sh running"

if [ -d "$HOME/.pyenv" ]; then
    log "Pyenv already installed, skipping"
    exit 0
fi

log "Installing pyenv"
curl https://pyenv.run | bash

log "pyenv.sh completed"
