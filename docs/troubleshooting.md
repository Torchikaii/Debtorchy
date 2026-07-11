### Troubleshooting

Common issues and how to fix them.

---

### NAS / File Server Issues

#### "SMB credentials not found, skipping local repo setup"

The provisioning scripts look for `~/.smbcredentials-nas2`. Create it:

```bash
cat > ~/.smbcredentials-nas2 << EOF
username=yourusername
password=yourpassword
EOF
chmod 600 ~/.smbcredentials-nas2
```

#### "NAS not mounting"

Check that:
1. The NAS is powered on and accessible on your network
2. The SMB server address is correct (`//192.168.1.97/nas2` in `local-repo.sh`)
3. You have the `cifs-utils` package installed: `sudo apt install cifs-utils`
4. Credentials are correct

Mount manually to debug:

```bash
sudo mount -t cifs //192.168.1.97/nas2 /mnt/NAS2 \
    -o credentials=$HOME/.smbcredentials-nas2,uid=$(id -u),gid=$(id -g),iocharset=utf8,vers=3.0
```

#### "Local APT repo not found on NAS"

The repo must be populated first. Run on a machine with internet:

```bash
bash package-manager/apt/fetch.sh
```

---

### Path Dependencies

#### Scripts assume `~/repos/Debtorchy`

All `dotfiles.sh` and `fonts.sh` symlink paths are hardcoded to `~/repos/Debtorchy`. If your repo lives elsewhere, update these files:

- `os-provision/dotfiles.sh` — all `ln -s` commands
- `os-provision/fonts.sh` — the font symlink

---

### Provisioning Scripts

#### "apt install" fails with lock errors

Another process is using APT. Wait for it to finish or kill it:

```bash
sudo kill $(sudo fuser /var/lib/dpkg/lock-frontend 2>/dev/null) 2>/dev/null
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock
sudo dpkg --configure -a
```

#### Script fails mid-run

Since `main.sh` uses `set -e`, it stops on the first error. Fix the issue and re-run — all scripts are idempotent, so completed scripts will skip automatically.

---

### git-lfs

#### "git lfs clone" is slow or fails

The `iso/` directory is tracked by git-lfs. Ensure `git-lfs` is installed:

```bash
sudo apt install git-lfs
git lfs install
```

If the ISO files are large, the initial clone may take time. You can clone without LFS objects first:

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone <repo-url>
```

Then fetch LFS objects when needed:

```bash
git lfs pull
```

---

### ISO Build

#### "xorriso not found"

Install it:

```bash
sudo apt install xorriso
```

Or run provisioning first: `bash os-provision/apps/xorriso.sh`

#### ISO doesn't boot

1. Verify the ISO was built correctly: `file debtorchy.iso` should show "ISO 9660"
2. Try the VM test: `bash os-provision/commands/start-vm.sh`
3. If writing to USB, use `dd` with `bs=4M` and verify the write completed

---

### VM Testing

#### "virt-install not found"

Install the virtualization packages:

```bash
sudo apt install virtinst libvirt-daemon-system
sudo systemctl enable --now libvirtd
```

Or let provisioning install them: `bash os-provision/apps/virtinst.sh`

#### VM has no display

Connect with `virt-viewer debtorchy` or check `virsh list --all` to see if the VM is running.

---

### Re-running Provisioning

All scripts are idempotent — safe to re-run. Completed scripts detect their state and skip:

- APT scripts check `dpkg -s <package>`
- Binary scripts check `command -v <binary>`
- Directory scripts check for existing directories

Re-run the full provisioning:

```bash
cd ~/repos/Debtorchy
bash os-provision/main.sh
```

Or run individual scripts:

```bash
bash os-provision/apps/docker.sh
bash os-provision/dotfiles.sh
```

---

### What's Next

- [Getting Started](getting-started.md) — Full walkthrough from scratch
- [Provisioning](provisioning.md) — Understanding the script system
- [Architecture](architecture.md) — How everything fits together
