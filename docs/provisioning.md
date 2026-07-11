### Provisioning

Deep dive into the `os-provision/` system — the post-install automation that turns a fresh Debian install into a productive workstation.

---

### Overview

`os-provision/main.sh` is the master orchestrator. It calls every sub-script in a specific order, grouped by category. The entire process is idempotent — safe to re-run at any time.

```
main.sh
├── commands/local-repo.sh    ← runs first (mount NAS, configure APT)
├── apps/*                    ← install programs (44 scripts)
├── dotfiles.sh               ← symlink configs to ~/.config
├── fonts.sh                  ← symlink Nerd Fonts
└── python/python-packages.sh ← pip installs
```

---

### main.sh Execution Order

Scripts run in the order defined in `main.sh`. Some scripts have dependencies on earlier scripts (noted in comments).

| Order | Category | Scripts |
|-------|----------|---------|
| 1 | Local repo | `local-repo.sh` — mount NAS, configure APT priority |
| 2 | Audio | `alsa-utils.sh`, `pipewire.sh`, `pipewire-pulse.sh`, `wireplumber.sh` |
| 3 | Desktop | `feh.sh`, `font-awesome.sh`, `i3.sh`, `picom.sh`, `polybar.sh` |
| 4 | Development | `docker.sh`, `gh.sh`, `git.sh`, `opencode.sh`, `pyenv.sh`, `python.sh`, `terraform.sh`, `vim.sh`, `xorriso.sh` |
| 5 | Virtualization | `qemu-kvm.sh`, `libvirt-daemon-system.sh`, `libvirt-clients.sh`, `virtinst.sh`, `virt-manager.sh` |
| 6 | File tools | `fd.sh`, `fzf.sh`, `ripgrep.sh`, `rsync.sh`, `tree.sh` |
| 7 | Networking | `cifs-utils.sh`, `nfs-common.sh`, `smbclient.sh`, `ssh.sh` |
| 8 | Shell | `alacritty.sh`, `bash-completion.sh`, `starship.sh`, `tmux.sh` |
| 9 | Package mgmt | `reprepro.sh` |
| 10 | System | `brave.sh`, `coreutils.sh`, `keepassxc.sh`, `less.sh`, `lesspipe.sh`, `p7zip.sh` |
| 11 | Config | `dotfiles.sh`, `fonts.sh` |
| 12 | Python | `python-packages.sh` |

---

### Script Anatomy

Every app script follows the same pattern. Here's a minimal example:

```bash
#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "git.sh running"

if dpkg -s git >/dev/null 2>&1; then
    log "Git already installed, skipping"
    exit 0
fi

log "Installing Git"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq git >/dev/null 2>&1

log "git.sh completed"
```

**The pattern:**
1. Source `logging.sh` for `log()` function with timestamps
2. Check if already installed → skip if yes
3. Install if not present
4. Log completion

All output is suppressed (`>/dev/null 2>&1`) except log messages. The `set -e` in `main.sh` ensures any failure halts execution.

---

### Installation Strategies

Scripts use one of three strategies depending on the software:

#### Strategy 1: APT install (most scripts)

For packages available in Debian repos or external repos (Docker, GitHub CLI, HashiCorp):

```bash
if dpkg -s package-name >/dev/null 2>&1; then
    log "Already installed, skipping"
    exit 0
fi
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq package-name >/dev/null 2>&1
```

When `local-repo.sh` has run, APT automatically prefers the NAS-cached packages (priority 900).

#### Strategy 2: NAS cache + internet fallback

For non-apt binaries (starship, opencode, brave, pyenv):

```bash
NAS_CACHE="/mnt/NAS2/.../binaries/starship/starship"

if [ -f "$NAS_CACHE" ]; then
    log "Installing from local cache"
    sudo cp "$NAS_CACHE" /usr/local/bin/starship
    sudo chmod +x /usr/local/bin/starship
else
    log "Installing from internet"
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
fi
```

#### Strategy 3: External repo add + apt install

For software that needs a third-party repository (Docker, GitHub CLI, Terraform):

```bash
# Add GPG key and repo
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
echo "deb [arch=amd64 signed-by=...] ..." | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq docker-ce ...
```

---

### Commands Directory

Utility scripts in `os-provision/commands/`:

| Script | Purpose |
|--------|---------|
| `logging.sh` | `log()` function — `[YYYY-MM-DD HH:MM:SS] message` |
| `local-repo.sh` | Mount NAS, add local APT repo, pin at priority 900 |
| `server.sh` | Interactive NAS mount (for manual use) |
| `build-iso.sh` | Build `debtorchy.iso` from `iso/` directory |
| `start-vm.sh` | Start a libvirt VM for testing the ISO |
| `sync-s.sh` | Sync `main.kdbx` password database from NAS to desktop |

---

### Dotfiles System

`dotfiles.sh` symlinks config files from `os-provision/dotfiles/` to their expected locations.

**How it works:**

```bash
mkdir -p ~/.config/alacritty
rm -f ~/.config/alacritty/alacritty.toml
ln -s ~/repos/Debtorchy/os-provision/dotfiles/alacritty/alacritty.toml \
    ~/.config/alacritty/alacritty.toml
```

**Managed dotfiles:**

| App | Source | Target |
|-----|--------|--------|
| Alacritty | `dotfiles/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
| Bash | `dotfiles/bash/.bashrc` | `~/.bashrc` |
| Vim | `dotfiles/vim/.vimrc` | `~/.vimrc` |
| Vim | `dotfiles/vim/.vim/` | `~/.vim/` |
| i3 | `dotfiles/i3/config` | `~/.config/i3/config` |
| Polybar | `dotfiles/polybar/config` | `~/.config/polybar/config` |
| Picom | `dotfiles/picom/picom.conf` | `~/.config/picom/picom.conf` |
| Starship | `dotfiles/starship/starship.toml` | `~/.config/starship.toml` |
| OpenCode | `dotfiles/opencode/opencode.json` | `~/.config/opencode/opencode.json` |
| OpenCode | `dotfiles/opencode/tui.json` | `~/.config/opencode/tui.json` |
| OpenCode | `dotfiles/opencode/themes/` | `~/.config/opencode/themes/` |

All symlinks use `rm -f` before `ln -s` — safe to re-run.

**Important:** The dotfiles target `~/repos/Debtorchy` as the repo path. If your repo lives elsewhere, update the paths in `dotfiles.sh`.

---

### Fonts

`fonts.sh` symlinks the Nerd Fonts from `os-provision/assets/fonts/` to `~/.local/share/fonts`.

The bundled font is **Code New Roman Nerd Font** (v3.4.0). Font Awesome icons are installed as a separate apt package.

---

### Python Packages

`python/python-packages.sh` runs after `pyenv.sh` and `python.sh` have installed Python 3.12.12 via pyenv. It pip-installs:

- `python-lsp-server` — Language server for vim/IDE integration

---

### What's Next

- [Customization](customization.md) — Adding your own apps, dotfiles, and assets
- [Package Manager](package-manager.md) — How the offline cache works
- [Architecture](architecture.md) — Full system overview
