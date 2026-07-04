#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "python.sh running"

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"

if pyenv versions | grep -q "3.12.12"; then
    log "Python 3.12.12 already installed, skipping"
else
    log "Installing Python 3.12.12"
    pyenv install 3.12.12
fi

pyenv global 3.12.12

log "python.sh completed"
