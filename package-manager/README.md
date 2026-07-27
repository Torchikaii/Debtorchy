### Package Manager

Offline package database for Debtorchy. Caches apt packages and
non-apt binaries on the NAS so provisioning works without internet.

## Prerequisites

- `reprepro` — required on the machine running fetch scripts
  (`sudo apt install reprepro`)
- NAS mounted at `/mnt/NAS2` with SMB credentials configured

## Usage

### First-time setup (run on machine with internet)

```bash
# Sync all apt packages + dependencies to NAS
bash package-manager/apt/sync.sh

# Download non-apt binaries to NAS
bash package-manager/binaries/fetch.sh
```

### Update packages

```bash
# Re-run sync — checks upstream vs cached, downloads only missing/outdated
bash package-manager/apt/sync.sh
```

### Provisioning (automatic)

`os-provision/main.sh` automatically:
1. Mounts NAS
2. Configures APT to prefer local repo (priority 900)
3. Installs packages from local cache first, falls back to internet

Non-apt scripts (starship, opencode, pyenv, brave) check NAS cache
before downloading from internet.

## Structure

```
package-manager/
├── apt/
│   ├── distributions          # reprepro config (Debian bookworm target)
│   ├── packages.list          # list of apt packages to cache
│   ├── external-repos.list    # docker, gh, hashicorp repo definitions
│   └── sync.sh               # check versions, download only missing/outdated, build repo
├── binaries/
│   ├── binaries.list          # non-apt binaries to cache (name, url, type)
│   └── fetch.sh               # download binaries to NAS
└── README.md
```

All scripts reuse shared utilities from `os-provision/commands/`:
- `logging.sh` — `log()` function
- `mount.sh` — NAS mount with stale detection

## NAS Storage

```
/mnt/NAS2/Server/homelab-assets/Debtorchy-assets/packages/
├── apt-repo/                  # reprepro-managed Debian repo
│   ├── conf/distributions
│   ├── db/
│   ├── pool/main/
│   └── dists/bookworm/
└── binaries/                  # cached non-apt binaries
    ├── starship/
    ├── opencode/
    ├── pyenv/
    └── brave/
```
