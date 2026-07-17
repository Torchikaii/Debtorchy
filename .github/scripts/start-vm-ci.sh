#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ISO="$SCRIPT_DIR/debtorchy.iso"
VM_NAME="debtorchy"
RAM=2048
CPUS=2
DISK_SIZE=5
LIBVIRT_ISO="/var/lib/libvirt/images/debtorchy.iso"

if [ ! -f "$ISO" ]; then
    echo "Error: ISO not found at $ISO"
    exit 1
fi

if sudo virsh list --all --name 2>/dev/null | grep -qx "$VM_NAME"; then
    echo "VM '$VM_NAME' already exists. Removing..."
    sudo virsh destroy "$VM_NAME" 2>/dev/null || true
    sudo virsh undefine "$VM_NAME" --nvram 2>/dev/null || true
fi

echo "Copying ISO to $LIBVIRT_ISO for libvirt-qemu access..."
sudo cp "$ISO" "$LIBVIRT_ISO"

echo "Starting VM '$VM_NAME' with $RAM MB RAM, $CPUS CPUs, ${DISK_SIZE}G disk"

sudo virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$CPUS" \
  --disk size="$DISK_SIZE",boot_order=1 \
  --cdrom "$LIBVIRT_ISO" \
  --os-variant debian13 \
  --network default \
  --nographics \
  --serial stdio \
  --boot menu=on \
  --noautoconsole

echo "VM '$VM_NAME' started."
