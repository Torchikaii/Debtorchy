### Package Manager

Offline package database for Debtorchy. Caches apt packages and
non-apt binaries on the NAS so provisioning works without internet.

## Prerequisites

- `reprepro` — required on the machine running fetch scripts
  (`sudo apt install reprepro`)
- NAS mounted at `/mnt/NAS2` with SMB credentials configured

## Usage

### Fetch packages (run on machine with internet)

```bash
# Download all apt packages + dependencies to NAS
bash package-manager/apt/fetch.sh

# Download non-apt binaries to NAS
bash package-manager/binaries/fetch.sh
```

### Update packages

```bash
# Refresh apt package cache
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
│   │   └── distributions      # reprepro config
│   ├── packages.list          # apt packages to cache
│   ├── external-repos.list    # docker, gh, hashicorp repos
│   ├── fetch.sh               # download packages + build repo
│   └── update.sh              # refresh cache
├── binaries/
│   ├── binaries.list          # non-apt binaries to cache
│   └── fetch.sh               # download binaries
├── lib/
│   ├── common.sh              # shared functions
│   └── nas.sh                 # NAS mount helpers
└── README.md
```

## NAS Storage

```
/mnt/NAS2/Server/homelab-assets/Debtorchy-assets/packages/
├── apt-repo/                  # reprepro-managed Debian repo
└── binaries/                  # cached non-apt binaries
    ├── starship/
    ├── opencode/
    ├── pyenv/
    └── brave/
```
