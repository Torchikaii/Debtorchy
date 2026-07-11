### Build ISO

Rebuild the bootable Debian ISO from the `iso/` directory.

---

### Building

Use the helper script:

```bash
bash os-provision/commands/build-iso.sh
```

This runs `xorriso` to package the `iso/` directory into `debtorchy.iso` at the repo root. The ISO supports both BIOS (isolinux) and UEFI (GRUB) boot.

**Prerequisites:** `xorriso` must be installed. If it's not, run:

```bash
sudo apt install xorriso
```

Or let provisioning install it: `bash os-provision/apps/xorriso.sh`

---

### Testing in a VM

Before writing to USB, test the ISO in a virtual machine:

```bash
bash os-provision/commands/start-vm.sh
```

This creates a libvirt VM named `debtorchy` with:
- 2 GB RAM, 2 CPUs, 5 GB disk
- The ISO attached as a CD-ROM
- SPICE graphics for remote viewing

Connect with: `virt-viewer debtorchy` or `virsh console debtorchy` or
start a `virt-manager` to see OS listed there.

**Prerequisites:** `virt-install` and `libvirt` must be installed. Provisioning scripts install these
via `virtinst.sh` and `libvirt-daemon-system.sh`.

---

### Writing to USB

After testing, write the ISO to a USB stick:

```bash
sudo dd if=debtorchy.iso of=/dev/sdX bs=4M status=progress
```

Replace `/dev/sdX` with your USB device. Use `lsblk` to identify the correct device.

---

### Extracting the ISO

If you need to inspect or modify the ISO contents:

```bash
sudo rm -rf debian-iso-extracted
mkdir debian-iso-extracted
mount -o loop debtorchy.iso debian-iso-extracted
cp -a debian-iso-extracted/. ./iso
umount debian-iso-extracted
```

The `.gitignore` excludes temporary extraction folders.

---

### Read Further

- [Getting Started](getting-started.md) — Full installation walkthrough
- [Architecture](architecture.md) — How the ISO fits into the system
- [Troubleshooting](troubleshooting.md) — Common issues
