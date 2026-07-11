### Debtorchy

A monorepo containing a full Debian operating system and its
assets — the OS itself, provisioning scripts, and
documentation in one version-controlled place.

### Prerequisites

- `git-lfs` — required if working with the `iso/` directory
  (`sudo apt install git-lfs` on Debian)

### Structure

```
Debtorchy/
├── .github/workflows/ # CI/CD workflows (linting, testing)
├── .opencode/         # Context engineering files (AI dev workflow)
├── iso/               # Extracted Debian netinst ISO (git-lfs tracked)
├── os-provision/      # Post-install scripts (programs, dotfiles, config)
├── package-manager/   # Offline package cache (apt repos + binaries on NAS)
└─── docs/              # Usage documentation
```

### Usage

- **Build ISO** — see `docs/build-iso.md`
- **Provision** — run `os-provision/main.sh` after OS installation
- **Offline packages** — run `package-manager/apt/fetch.sh` and `package-manager/binaries/fetch.sh` to cache packages on NAS
