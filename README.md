### Debtorchy

A monorepo containing a full Debian operating system and its
assets — the OS itself, provisioning scripts, and
documentation in one version-controlled place.

## Prerequisites

- `git-lfs` — required if working with the `iso/` directory
  (`sudo apt install git-lfs` on Debian)

## Structure

```
Debtorchy/
├── .github/workflows/ # CI/CD workflows (linting, testing)
├── .opencode/         # Context engineering files (AI dev workflow)
├── iso/               # Extracted Debian netinst ISO (git-lfs tracked)
├── os-provision/      # Post-install scripts (programs, dotfiles, config)
├── package-manager/   # Offline package cache (apt repos + binaries on NAS)
├── docs/              # Usage documentation
└── README.md
```

### Key files

| File | Purpose |
|------|---------|
| `os-provision/main.sh` | Main orchestrator — runs all provisioning scripts |
| `os-provision/commands/local-repo.sh` | Mounts NAS, configures APT for local repo |
| `package-manager/apt/fetch.sh` | Downloads all apt packages + deps to NAS |
| `package-manager/apt/update.sh` | Incremental update (only outdated packages) |
| `package-manager/binaries/fetch.sh` | Downloads non-apt binaries to NAS |
| `docs/build-iso.md` | How to rebuild the ISO from `iso/` |

## Usage

- **Build ISO** — see `docs/build-iso.md`
- **Provision** — run `os-provision/main.sh` after OS installation
- **Offline packages** — run `package-manager/apt/fetch.sh` and `package-manager/binaries/fetch.sh` to cache packages on NAS
