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
# Download all apt packages + dependencies to NAS
bash package-manager/apt/fetch.sh

# Download non-apt binaries to NAS
bash package-manager/binaries/fetch.sh
```

### Update packages (check for new versions, download only outdated)

```bash
# Check upstream vs cached versions, download only what changed
bash package-manager/apt/update.sh
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
│   ├── conf/
│   │   └── distributions      # reprepro config (Debian bookworm target)
│   ├── packages.list          # list of apt packages to cache
│   ├── external-repos.list    # docker, gh, hashicorp repo definitions
│   ├── fetch.sh               # download all packages + build local repo
│   └── update.sh              # check versions, download only outdated
├── binaries/
│   ├── binaries.list          # non-apt binaries to cache (name, url, type)
│   └── fetch.sh               # download binaries to NAS
├── lib/
│   ├── common.sh              # shared constants (NAS paths, staging dir)
│   └── nas.sh                 # NAS mount helpers (mount_nas, credentials)
└── README.md
```

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
