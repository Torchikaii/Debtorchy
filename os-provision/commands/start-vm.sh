#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ISO="$SCRIPT_DIR/debtorchy.iso"
VM_NAME="debtorchy"
VM_MAC="52:54:00:de:b0:01"
VM_IP="192.168.122.100"
RAM=2048
CPUS=2
DISK_SIZE=5

if [ ! -f "$ISO" ]; then
    echo "Error: ISO not found at $ISO"
    echo "Run os-provision/commands/build-iso.sh first."
    exit 1
fi

if ! command -v virt-install >/dev/null 2>&1; then
    echo "Error: virt-install not found. Run os-provision/apps/virtinst.sh first."
    exit 1
fi

# Register static DHCP lease for the VM (idempotent)
sudo virsh net-update default add ip-dhcp-host \
  "<host mac='$VM_MAC' ip='$VM_IP'/>" \
  --live --config 2>/dev/null || true

if sudo virsh list --all --name 2>/dev/null | grep -qx "$VM_NAME"; then
    echo "VM '$VM_NAME' already exists. Removing..."
    sudo virsh destroy "$VM_NAME" 2>/dev/null || true
    sudo virsh undefine "$VM_NAME" --nvram 2>/dev/null || true
fi

echo "Starting VM '$VM_NAME' with $RAM MB RAM, $CPUS CPUs, ${DISK_SIZE}G disk"

sudo virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$CPUS" \
  --disk size="$DISK_SIZE",boot_order=1 \
  --disk path="$ISO",device=cdrom,bus=sata,readonly=yes,boot_order=2 \
  --os-variant debian13 \
  --network default,mac="$VM_MAC" \
  --graphics spice \
  --boot menu=on \
  --noautoconsole

echo "VM '$VM_NAME' started"
echo "VM IP: $VM_IP (DHCP reservation)"
echo "After installing + provisioning, SSH: ssh root@$VM_IP  (password: admin)"
echo "Connect with: virsh console $VM_NAME"
