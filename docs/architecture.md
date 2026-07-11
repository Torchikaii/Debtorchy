### Architecture

How Debtorchy's layers fit together to produce a reproducible, disposable workstation.

---

### The Idea

A machine running Debtorchy carries no permanent important data. All user data, credentials, and assets live on redundant file servers. The OS itself is scaffolding — rebuilt and reprovisioned from this repo on every install. Each machine is a stateless, disposable compute node.

```
┌─────────────────────────────────────────────────────┐
│                    This Repository                  │
│                                                     │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   iso/   │  │ os-provision/│  │package-manager│  │
│  │  (OS)    │  │  (provision) │  │   (offline)   │  │
│  └────┬─────┘  └──────┬───────┘  └───────┬───────┘  │
│       │               │                  │          │
└───────┼───────────────┼──────────────────┼──────────┘
        │               │                  │
        ▼               ▼                  ▼
   ┌─────────┐   ┌───────────┐      ┌──────────┐
   │  ISO    │   │  Scripts  │      │   NAS    │
   │  Build  │   │  Run on   │      │  (SMB)   │
   │  xorriso│   │  first    │      │  Stores  │
   │         │   │  boot     │      │  pkgs +  │
   └─────────┘   └───────────┘      │  assets  │
                                    └──────────┘
```

---

### Layer 1: The ISO (`iso/`)

The extracted Debian netinst ISO, version-controlled via git-lfs. This is the starting point — a standard Debian installer with a preseed configuration baked in.

**Key files:**
- `iso/` — Full extracted ISO contents (boot loaders, packages, preseed)
- `iso/install.amd/preseed.cfg` — Preseed configuration for autonomous install

**How it works:**
The preseed file tells the Debian installer exactly how to partition, what to install, and how to configure the system — all without human interaction. When you boot the ISO, Debian installs itself hands-free.

See [Build ISO](build-iso.md) for how to rebuild the ISO.

---

### Layer 2: Provisioning (`os-provision/`)

Post-install scripts that run after the first boot. This is where the workstation gets its identity.

**Entry point:** `os-provision/main.sh`

`main.sh` is a facade — it calls every sub-script in order. Each script is a standalone, idempotent unit that handles one app or concern.

**Script categories:**

| Directory | Purpose |
|-----------|---------|
| `apps/` | Individual app installers (one per app) |
| `commands/` | Utilities (NAS mount, logging, ISO build, VM start) |
| `dotfiles/` | Config files symlinked to `~/.config` |
| `dotfiles.sh` | Creates all dotfile symlinks |
| `fonts.sh` | Symlinks Nerd Fonts to `~/.local/share/fonts` |
| `python/` | Python package installation via pip |

**Script patterns:**

Every app script follows the same idempotent pattern:
1. Source `logging.sh` for timestamped output
2. Check if already installed (`dpkg -s` or `command -v`)
3. If installed → skip with log message
4. If not installed → install from local cache (NAS) or internet
5. Log completion

There are three types of app scripts:

**Type 1: APT packages** (most common) — Check with `dpkg -s`, install with `apt install`:
```bash
# git.sh, alacritty.sh, docker.sh, etc.
if dpkg -s git >/dev/null 2>&1; then
    log "Git already installed, skipping"
    exit 0
fi
sudo apt install -y -qq git
```

**Type 2: NAS-cached binaries** — Check NAS first, fall back to internet:
```bash
# starship.sh, opencode.sh, pyenv.sh, brave.sh
NAS_CACHE="/mnt/NAS2/.../binaries/starship/starship"
if [ -f "$NAS_CACHE" ]; then
    sudo cp "$NAS_CACHE" /usr/local/bin/starship
else
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
fi
```

**Type 3: Directory-based installs** — Check for a directory, copy from NAS or download:
```bash
# pyenv.sh
if [ -d "$HOME/.pyenv" ]; then
    log "Pyenv already installed, skipping"
    exit 0
fi
if [ -d "$NAS_CACHE" ]; then
    cp -a "$NAS_CACHE" "$HOME/.pyenv"
else
    curl https://pyenv.run | bash
fi
```

See [Provisioning](provisioning.md) for the full deep dive.

---

### Layer 3: Package Manager (`package-manager/`)

Offline package cache stored on the NAS. Enables provisioning without internet.

**Components:**

| File | Purpose |
|------|---------|
| `apt/packages.list` | List of apt packages to cache |
| `apt/fetch.sh` | Download all packages + build local repo |
| `apt/update.sh` | Check versions, download only outdated |
| `apt/external-repos.list` | Docker, GitHub CLI, HashiCorp repo definitions |
| `binaries/binaries.list` | Non-apt binaries (starship, opencode, pyenv, brave) |
| `binaries/fetch.sh` | Download binaries to NAS |
| `lib/common.sh` | Shared constants (NAS paths, staging dir) |
| `lib/nas.sh` | NAS mount helpers |

**How provisioning uses it:**

1. `local-repo.sh` runs first (before any app scripts)
2. Mounts NAS via SMB
3. Adds the local repo as an APT source (`file:///mnt/NAS2/.../apt-repo`)
4. Pins it at priority 900 (preferred over internet)
5. All subsequent `apt install` commands automatically prefer the local cache

Non-apt scripts (starship, opencode, pyenv, brave) explicitly check the NAS binary cache before downloading from the internet.

See [Package Manager](package-manager.md) for the full picture.

---

### Data Flow: Bare Metal to Productive Workstation

```
1. Build ISO        → xorriso packages iso/ → debtorchy.iso
2. Boot ISO         → USB stick or PXE
3. Preseed install  → Fully autonomous Debian installation
4. First boot       → Clone repo, run os-provision/main.sh
5. local-repo.sh   → Mount NAS, configure APT to prefer local repo
6. App scripts      → Install programs (from NAS cache or internet)
7. dotfiles.sh      → Symlink configs to ~/.config
8. fonts.sh         → Symlink Nerd Fonts
9. python-packages  → pip install python-lsp-server
10. Ready           → Productive workstation, no permanent local data
```

---

### Design Principles

| Principle | How It's Applied |
|-----------|-----------------|
| **Idempotency** | Every script checks state before modifying. Safe to re-run. |
| **Single Responsibility** | Each `.sh` file does one thing. |
| **Facade** | `main.sh` orchestrates everything; individual scripts are independent. |
| **Offline-first** | NAS cache preferred; internet is fallback only. |
| **Disposable OS** | No permanent data on machine. All assets on file server. |

---

### What's Next

- [Provisioning](provisioning.md) — Deep dive into the os-provision system
- [Package Manager](package-manager.md) — How offline caching works
- [Customization](customization.md) — Adding your own apps and dotfiles
