### Build ISO

Rebuild the bootable Debian ISO from the `iso/` directory.

---

### Building

Use the helper script:

```bash
bash os-provision/commands/build-iso.sh
```

This packages the `iso/` directory into `debtorchy.iso` at the repo root. The ISO supports both BIOS (isolinux) and UEFI (GRUB) boot.

The build is fully non-interactive if you press Enter on every prompt: it stages a temporary copy of `iso/` (the tracked `iso/` tree is never modified), regenerates the `pool/main` package index and `md5sum.txt`, and runs `xorriso`.

**Prerequisites:**

- `xorriso` — `sudo apt install xorriso`, or `bash os-provision/apps/xorriso.sh`
- `apt-ftparchive` (from `apt-utils`) — `sudo apt install apt-utils`

### Credential prompts

The build asks for four values. Every prompt falls back to a default when left empty (press Enter / non-interactive builds):

| Prompt | Default |
|--------|---------|
| Root password | `admin` |
| pc password | `admin` |
| NAS username | none (nothing baked) |
| NAS password | none (nothing baked) |

Only if both NAS username and password are provided are they baked into the preseed's `late_command`, which writes `~/.smbcredentials-nas2` (chmod 600) into the installed system. Empty NAS input bakes nothing. Credentials are never committed to the repository — they only ever land inside the built `debtorchy.iso`.

> **Security note:** anything baked into the ISO is readable by anyone holding the installer. For a trusted homelab this is acceptable; leave the prompts empty to avoid it.
>
> Passwords must be printable ASCII (no newlines, tabs, or non-ASCII) and must not end with a backslash; otherwise the build aborts.

### Post-install system

The preseed configures the installed system to:
- Install a minimal set offline from the ISO's own pool: the deselect-everything base plus `sudo` and `cifs-utils` (with `--no-install-recommends`, so `keyutils` is not pulled in)
- Write Debian's modern deb822 apt sources (`*.sources` in `/etc/apt/sources.list.d/`) pointing at `deb.debian.org` / `security.debian.org` as internet fallback
- Copy `os-provision/` and `package-manager/` to `/home/pc/repos/Debtorchy/`
- Enable the `debtorchy-firstboot` systemd service so provisioning auto-runs on first boot

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

