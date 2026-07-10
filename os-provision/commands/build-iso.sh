#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ISO_DIR="$SCRIPT_DIR/iso"
OUTPUT="$SCRIPT_DIR/debtorchy.iso"

if [ ! -d "$ISO_DIR" ]; then
    echo "Error: iso/ directory not found at $ISO_DIR"
    exit 1
fi

if ! command -v xorriso >/dev/null 2>&1; then
    echo "Error: xorriso not found. Run os-provision/apps/xorriso.sh first."
    exit 1
fi

echo "Building $OUTPUT from $ISO_DIR"

xorriso \
  -as mkisofs \
  -r -J -joliet-long \
  -V "Debian Netinst" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -isohybrid-gpt-basdat \
  -o "$OUTPUT" \
  "$ISO_DIR"

echo "Done: $OUTPUT"
