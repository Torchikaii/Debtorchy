### Package Manager

Offline package caching system. Stores apt packages and non-apt binaries on the NAS so provisioning works without internet.

---

### Why Offline Packages

During provisioning, every app script runs `apt install` or downloads a binary. Without a local cache, this means hundreds of individual downloads from the internet — slow and fragile.

The package manager pre-fetches everything onto the NAS. During provisioning, `local-repo.sh` configures APT to prefer the local repo (priority 900) over the internet. Non-apt scripts explicitly check the NAS binary cache first.

**Result:** Provisioning runs at LAN speed, works offline, and is resilient to internet outages.

---

### Components

```
package-manager/
├── apt/
│   ├── conf/distributions      # reprepro config (targets bookworm)
│   ├── packages.list            # apt packages to cache (42 packages)
│   ├── external-repos.list      # Docker, GitHub CLI, HashiCorp repos
│   ├── fetch.sh                 # Download all packages + build local repo
│   └── update.sh                # Check versions, download only outdated
├── binaries/
│   ├── binaries.list            # Non-apt binaries (starship, opencode, pyenv, brave)
│   └── fetch.sh                 # Download binaries to NAS
├── lib/
│   ├── common.sh                # Shared constants (NAS paths, staging dir, helpers)
│   └── nas.sh                   # NAS mount helpers (mount_nas, setup_credentials)
└── README.md
```

---

### First-Time Setup

Run on a machine with internet access:

```bash
# 1. Cache all apt packages + dependencies
bash package-manager/apt/fetch.sh

# 2. Cache non-apt binaries
bash package-manager/binaries/fetch.sh
```

**What `apt/fetch.sh` does:**
1. Mounts NAS via SMB
2. Temporarily adds external repos (Docker, GitHub CLI, HashiCorp)
3. Resolves full dependency closures for all packages in `packages.list`
4. Downloads every `.deb` to a staging directory
5. Cleans up temporary repos
6. Builds a local APT repository using `reprepro` on the NAS

**What `binaries/fetch.sh` does:**
1. Mounts NAS via SMB
2. Reads `binaries.list` (format: `name|url|type`)
3. Downloads and extracts each binary to the NAS

---

### Updating Packages

When upstream packages change:

```bash
bash package-manager/apt/update.sh
```

This compares upstream versions against the local cache and only downloads what's outdated. Non-apt binaries must be re-fetched manually via `binaries/fetch.sh`.

---

### NAS Storage Layout

```
/mnt/NAS2/Server/homelab-assets/Debtorchy-assets/packages/
├── apt-repo/                  # reprepro-managed Debian repo
│   ├── conf/distributions
│   ├── db/
│   ├── pool/main/             # All cached .deb files
│   └── dists/bookworm/        # APT metadata
└── binaries/                  # Cached non-apt binaries
    ├── starship/
    │   └── starship           # Binary
    ├── opencode/
    │   └── opencode           # Binary
    ├── pyenv/
    │   ├── bin/pyenv
    │   └── ...                # Full pyenv directory
    └── brave/
        └── brave-browser_*.deb
```

---

### How Provisioning Uses It

**Step 1:** `os-provision/commands/local-repo.sh` runs first in `main.sh`:

```bash
# Mount NAS
sudo mount -t cifs //192.168.1.97/nas2 /mnt/NAS2 \
    -o credentials=$HOME/.smbcredentials-nas2,...

# Add local repo as APT source
echo "deb [trusted=yes] file:///mnt/NAS2/.../apt-repo bookworm main" \
    > /etc/apt/sources.list.d/debtorchy-local.list

# Pin at priority 900 (preferred over internet)
cat > /etc/apt/preferences.d/debtorchy-local << 'EOF'
Package: *
Pin: release o=Debtorchy-Local
Pin-Priority: 900
EOF

# Update package lists
sudo apt-get update -qq
```

**Step 2:** All subsequent `apt install` commands in app scripts automatically prefer the local repo. No changes needed in individual scripts.

**Step 3:** Non-apt scripts (starship, opencode, pyenv, brave) explicitly check the NAS binary cache:

```bash
NAS_CACHE="/mnt/NAS2/Server/homelab-assets/Debtorchy-assets/packages/binaries/starship/starship"
if [ -f "$NAS_CACHE" ]; then
    # install from cache
else
    # download from internet
fi
```

---

### Package Lists

**apt/packages.list** — 42 packages covering:
- Desktop: i3, polybar, picom, alacritty, feh, font-awesome
- Development: git, docker, gh, vim, terraform, xorriso, reprepro
- Virtualization: qemu-kvm, libvirt, virt-manager, virtinst
- File tools: fd, fzf, ripgrep, rsync, tree, p7zip
- Networking: cifs-utils, nfs-common, smbclient, openssh-server
- Shell: bash-completion, tmux, less, lesspipe
- System: coreutils, keepassxc, brave (via external repo)
- Audio: pipewire, pipewire-pulse, wireplumber, alsa-utils

**binaries/binaries.list** — 4 non-apt binaries:
- `starship` — Cross-shell prompt (tarball)
- `opencode` — AI coding agent (tarball)
- `pyenv` — Python version manager (tarball)
- `brave` — Brave browser (deb)

**external-repos.list** — 3 external APT repositories:
- Docker CE
- GitHub CLI
- HashiCorp (Terraform)

---

### Adding New Packages

**Apt package:** Add the package name to `package-manager/apt/packages.list` (one per line), then run `fetch.sh` or `update.sh`.

**Binary:** Add a line to `package-manager/binaries/binaries.list` in format `name|url|type`, then run `fetch.sh`.

**External repo:** Add a line to `package-manager/apt/external-repos.list` in format `name|gpg-key-url|deb-line`.

---

### What's Next

- [Provisioning](provisioning.md) — How scripts use the cached packages
- [Customization](customization.md) — Adding your own packages and binaries
- [Architecture](architecture.md) — Full system overview
