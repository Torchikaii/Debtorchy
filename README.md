### Debtorchy

A monorepo containing full personal Debian operating system
and it's assets. A custom post-install provisioning scripts
handles installation of programs, symlinks dotfiles, fonts, etc.
Other custom scripts handle building of a custom offline apt
repository in the homelab, which allows to rebuild OS without
internet. 

WARNING: project is in it's early stage of development and not
every part of it works properly.

### Structure

```
├── .github/workflows/ CI/CD workflows
├── .opencode/         Context engineering (AI dev workflow)
├── iso/               Extracted Debian netinst ISO (git-lfs tracked)
├── os-provision/      Post-install scripts live here
│   ├── main.sh        Orchestrator — runs everything in order
│   ├── apps/          Individual app installers (one per app)
│   ├── commands/      Utilities (NAS mount, logging, ISO build)
│   ├── dotfiles/      Config files symlinked to ~/.config
│   └── assets/        Fonts, wallpapers
├── package-manager/   Offline apt cache builder
└── docs/              Documentation
```

### Prerequisites

- A NAS with SMB access (for offline packages and asset sync)
- `git-lfs` — required if working with the `iso/` directory (`sudo apt install git-lfs`)

### Documentation

- **[Getting Started](docs/getting-started.md)** — From bare metal to productive workstation
- **[Architecture](docs/architecture.md)** — How all the pieces fit together
- **[Provisioning](docs/provisioning.md)** — The `os-provision/` system and script patterns
- **[Package Manager](docs/package-manager.md)** — Offline package caching on NAS
- **[Customization](docs/customization.md)** — Adding apps, dotfiles, and assets
- **[Build ISO](docs/build-iso.md)** — Rebuilding the bootable ISO
- **[Troubleshooting](docs/troubleshooting.md)** — Common issues and fixes
