### Getting Started

From bare metal to a fully provisioned Debian workstation — autonomous, zero interaction (almost).

### Prerequisites

- A **NAS** (SMB/CIFS) accessible on your local network — this stores offline packages, password databases, and assets
- `git` and `git-lfs` on the target machine

---

### First-Time Setup

#### 1. Cache packages on NAS

On a machine with internet access, populate the NAS with apt packages and binaries:

```bash
# Download all apt packages + dependencies to NAS
bash package-manager/apt/fetch.sh

# Download non-apt binaries (starship, opencode, pyenv, brave)
bash package-manager/binaries/fetch.sh
```

This creates a local Debian repo on the NAS that provisioning will prefer over the internet. See [Package Manager](package-manager.md) for details.

#### 2. Build the ISO

See [Build ISO](build-iso.md) for the full process. Quick version:

```bash
bash os-provision/commands/build-iso.sh
```

#### 3. Install Debian

Boot the ISO via USB or PXE. The preseed configuration handles everything — partitioning, user creation, package selection — with zero human interaction.

#### 4. First boot provisioning

After the install completes and the system reboots, clone the repo and run the orchestrator:

```bash
git clone git@github.com:youruser/Debtorchy.git ~/repos/Debtorchy
cd ~/repos/Debtorchy
bash os-provision/main.sh
```

This installs all programs, symlinks dotfiles, installs fonts, and syncs assets from the NAS. See [Provisioning](provisioning.md) for what happens under the hood.

---

### What You Get

A complete workstation with:

| Category | Software |
|----------|----------|
| **Desktop** | i3, polybar, picom, alacritty, feh |
| **Development** | git, docker, gh, vim, pyenv, python 3.12, terraform, opencode |
| **Shell** | starship prompt, tmux, bash-completion |
| **Virtualization** | QEMU/KVM, libvirt, virt-manager |
| **File tools** | fd, fzf, ripgrep, rsync, tree, p7zip |
| **Networking** | cifs-utils, nfs-common, smbclient, openssh-server |
| **System** | brave, keepassxc, coreutils, less |
| **Audio** | pipewire, pipewire-pulse, wireplumber, alsa-utils |
| **Fonts** | Nerd Fonts (Code New Roman) + Font Awesome icons |

Dotfiles for i3, polybar, alacritty, picom, starship, vim, bash, and opencode are automatically symlinked to `~/.config`.

---

### What's Next

- [Architecture](architecture.md) — How all the pieces fit together
- [Customization](customization.md) — Adding your own apps, dotfiles, and assets
- [Troubleshooting](troubleshooting.md) — Common issues and fixes
