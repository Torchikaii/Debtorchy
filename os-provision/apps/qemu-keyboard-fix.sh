#!/bin/bash

# This script is just a temporary fix, and should be moved
# somewhere else or refactored one day.

source "$(dirname "$0")/../commands/logging.sh"

log "qemu-keyboard-fix.sh running"

if [ -f /etc/X11/xorg.conf.d/90-qemu-keyboard-fix.conf ]; then
    log "QEMU keyboard fix already applied, skipping"
    exit 0
fi

log "Installing evdev input driver"
sudo apt install -y -qq xserver-xorg-input-evdev >/dev/null 2>&1

log "Applying QEMU AT keyboard evdev override"
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/90-qemu-keyboard-fix.conf > /dev/null << 'EOF'
Section "InputClass"
    Identifier "QEMU AT keyboard fix"
    MatchProduct "AT Translated Set 2 keyboard"
    Driver "evdev"
    Option "XkbLayout" "us,lt"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
EOF

log "qemu-keyboard-fix.sh completed"
