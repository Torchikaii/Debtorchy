# Product Requirements Document: Debtorchy

**Version:** 1.0  
**Last Updated:** 2026-07-08

---

## 1. Executive Summary

Debtorchy is a monorepo that packages a complete Debian operating system together with its provisioning scripts, configuration, and documentation. The repository contains the full extracted Debian netinst ISO (versioned via git-lfs), post-install automation scripts, and build tooling — everything needed to produce a bootable, fully autonomous Debian installer.

The core value proposition is **full OS reproducibility**: a computer running Debtorchy carries no permanent important data. All user data, credentials, and assets live on redundant file servers. The OS itself is rebuilt and reprovisioned from this repo on every install, making each machine a stateless, disposable compute node that can be recreated at any time.

**Core Value Proposition:** One repository to rule the entire OS — from bare metal to productive workstation, fully automated, fully reproducible.

---

## 2. Mission & Principles

### Mission Statement

Build and maintain a complete, autonomous operating system deployment pipeline where a single repository contains the OS image, provisioning logic, and documentation — enabling instant, hands-free recreation of a production-ready workstation on any hardware.

### Core Principles

1. **Full Automation** — OS installation requires zero human interaction. Preseed configuration handles partitioning, user creation, and initial setup. Post-install scripts install programs, symlink dotfiles, and synchronise assets from file servers.
2. **Reproducibility** — Every install produces an identical system. No permanent state lives on the machine; all important data resides on redundant file servers.
3. **Idempotency** — All provisioning scripts are safe to re-run. No duplicate entries, no errors on re-execution.
4. **One Source of Truth** — The repository is the single authoritative source for the OS image, provisioning logic, and documentation.
5. **Self-Contained** — Minimal external dependencies. The repo holds everything needed to build and deploy.

---

## 3. Target Users

### Primary User

**The Solo Developer / Power User**
- Maintains one or more Debian workstations
- Wants to recreate a productive environment instantly after any reinstall
- Stores all permanent data on redundant file servers
- Comfortable with command line and shell scripting

### Problems Solved

| Problem | Solution |
|---------|----------|
| Time-consuming OS reinstallation | Fully autonomous preseed install |
| Manual post-install setup | Automated provisioning scripts |
| Scattered dotfiles and config | Centralised repo with symlinks |
| Irreproducible environments | Version-controlled OS image |

---

## 4. Scope

### In Scope ✅

- [ ] **ISO management** — Extracted Debian netinst ISO stored in `iso/` and version-controlled via git-lfs
- [ ] **ISO rebuilding** — `docs/build-iso.md` documents the xorriso command to produce a bootable ISO from the `iso/` directory
- [ ] **Preseed configuration** — `preseed.cfg` is baked into the ISO, enabling fully autonomous installation with no human intervention
- [ ] **Post-install provisioning** — `os-provision/` scripts run automatically after first boot to install programs, dotfiles, and assets
- [ ] **File server synchronisation** — Scripts mount NAS, sync password databases, fonts, wallpapers, and other assets from redundant file servers
- [ ] **PXE boot** — The OS can be installed over the network via PXE in addition to USB
- [ ] **Documentation** — `docs/` contains build instructions, usage guides, and reference material

### Out of Scope ❌

- [ ] GUI applications for system management (CLI-first approach)
- [ ] Cross-platform support (Debian only)
- [ ] Enterprise fleet management (targeting individual power users)

---

## 5. User Stories

**US-001:** As a power user, I want to build a bootable ISO from the repository, so I can install Debian on any machine.

**US-002:** As a power user, I want the OS installation to require zero interaction, so I can start the install and walk away.

**US-003:** As a power user, I want post-install scripts to automatically install my programs, dotfiles, and assets, so my workstation is ready to use immediately after first boot.

**US-004:** As a power user, I want my password database and other assets synchronised from a file server, so no permanent data lives on the local machine.

**US-005:** As a power user, I want to install the OS via PXE boot, so I don't need a USB stick for new installations.

**US-006:** As a power user, I want all provisioning scripts to be idempotent, so I can re-run them safely without duplicates or errors.

**US-007:** As a power user, I want the ISO content version-controlled with git-lfs, so I can track changes to the OS image over time.

---

## 6. Architecture & Design

### Directory Structure

```
Debtorchy/
├── iso/              # Extracted Debian netinst ISO (git-lfs tracked)
│   ├── boot/
│   ├── debian -> .   # ISO circular symlink (preserved from original)
│   ├── dists/
│   ├── install.amd/
│   ├── isolinux/
│   ├── pool/
│   └── ...
├── os-provision/     # Post-install scripts
│   ├── main.sh       # Orchestrator (runs after OS install)
│   ├── apps/         # Individual app installers
│   ├── commands/     # Utility commands (NAS mount, sync, logging)
│   ├── dotfiles/     # Config files (symlinked to ~/.config)
│   ├── dotfiles.sh   # Symlink creation
│   ├── fonts.sh      # Nerd font symlinking
│   └── python/       # Python package installation
├── docs/             # Usage documentation
│   └── build-iso.md  # ISO build instructions
└── README.md         # Repository entry point
```

### Data Flow

```
1. Build ISO        → xorriso packages iso/ → debtorchy.iso
2. Boot ISO         → USB stick or PXE
3. Preseed install  → Fully autonomous Debian installation
4. First boot       → os-provision/main.sh runs automatically
5. Provisioning     → Programs installed, dotfiles symlinked,
                       assets synced from file server
6. Ready            → Productive workstation, no permanent local data
```

### Design Patterns

| Pattern | Application |
|---------|-------------|
| **Facade** | `main.sh` orchestrates all sub-scripts |
| **Single Responsibility** | Each `.sh` file handles one app or concern |
| **Idempotent Scripts** | All scripts check state before modifying |
| **Preseed Automation** | Debian installer fully configured via preseed |

---

## 7. Technology Stack

| Component | Technology |
|-----------|------------|
| Operating System | Debian (netinst, current stable) |
| ISO Build | xorriso / mkisofs |
| Version Control | Git + git-lfs (for iso/) |
| Provisioning | Shell scripts (bash) |
| File Server Access | CIFS/SMB, NFS |
| Preseed | debian-installer preseed configuration |
| PXE | dnsmasq / isc-dhcp-server + tftpd-hpa |

---

## 8. Security & Configuration

### Authentication

| Utility | Method |
|---------|--------|
| NAS Mounting | Stored credentials (`~/.smbcredentials-*`) |
| Password Database | KeePassXC (`main.kdbx`), synced from file server |
| Git | SSH keys / credential helpers |
| General | No sensitive data in repository |

### Configuration Management

- Dotfiles stored in `os-provision/dotfiles/` and symlinked to `~/.config`
- Preseed configuration baked into ISO for hands-off install
- File server paths and credentials configured via environment variables or credential files

### Security Scope

- No production secrets stored in repository
- No API keys or tokens committed
- `.gitignore` excludes sensitive files
- Credentials handled by local credential files with `chmod 600`

---

## 9. API Specification

Not applicable — this is a collection of build tooling and provisioning scripts, not an API-driven service.

---

## 10. Success Criteria

### Functional Acceptance Criteria ✅

- [ ] `xorriso` command produces a bootable ISO from `iso/` directory
- [ ] ISO installs Debian fully autonomously with preseed configuration
- [ ] `os-provision/main.sh` executes without errors on a fresh Debian system
- [ ] All app installers create working installations
- [ ] Dotfile symlinks resolve correctly
- [ ] File server mount and sync commands work end-to-end
- [ ] PXE boot loads the installer successfully

### Quality Indicators

| Metric | Target |
|--------|--------|
| Scripts re-run safely | 100% idempotent |
| ISO builds | Reproducible from committed `iso/` content |
| Install autonomy | Zero human interactions required |
| Setup time (bare metal) | < 30 minutes total |

---

## 11. Implementation Phases

### Phase 1: Foundation
**Goal:** Extract and version-control the Debian ISO, establish build documentation.

- [x] Debian netinst ISO extracted to `iso/` directory
- [x] `iso/` content tracked via git-lfs
- [x] `docs/build-iso.md` documents ISO rebuild procedure
- [x] Basic `os-provision/` scripts for program installation

**Validation:** ISO rebuilds from `iso/` directory and boots successfully.

### Phase 2: Autonomous Installation
**Goal:** Bake preseed configuration into ISO for fully hands-off install.

- [ ] `preseed.cfg` created and injected into ISO during build
- [ ] Post-install trigger runs `os-provision/main.sh` on first boot
- [ ] File server sync scripts operational

**Validation:** Boot ISO → walk away → return to fully provisioned workstation.

### Phase 3: PXE Boot
**Goal:** Support network-based installation without USB media.

- [ ] PXE server configuration documented
- [ ] Network boot chain tested and working
- [ ] Preseed + PXE combined for fully remote install

**Validation:** Machine PXE-boots and completes autonomous install.

### Phase 4: Offline & Optimisation
**Goal:** Reduce internet dependency during installation.

- [ ] `.apt` package cache stored on file server
- [ ] Optional: programs baked directly into ISO
- [ ] Optional: offline-reproducible-workstation mode

**Validation:** Full install possible without internet access (cache served from LAN).

---

## 12. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Debian version drift** — New stable releases break preseed or package compatibility | High | Medium | Test on current stable; maintain upgrade notes |
| **git-lfs storage bloat** — ISO content changes inflate repository size | Medium | High | Prune old LFS objects periodically; document storage expectations |
| **Path dependencies** — Scripts assume `~/repos/Debtorchy` | Medium | High | Add path detection; document requirement in README |
| **File server unreachable** — Install fails without NAS access | High | Low | Graceful fallback; cache critical assets locally |
| **Circular iso/debian symlink** — Tools may infinite-loop when traversing `iso/` | Low | Medium | Document the symlink behaviour; add note in README |

---

## 13. Future Considerations

### Post-MVP Enhancements

- **Offline package cache** — Host a local Debian mirror or cached `.apt` packages on the file server for internet-independent installation
- **Baked programs** — Include commonly needed `.deb` packages directly in the ISO to reduce post-install downloads
- **Docker-based build** — Containerised ISO build environment for reproducibility across hosts
- **Automated testing** — CI pipeline that builds the ISO and boots it in a VM to validate the full install

### Integration Opportunities

- **GitHub Codespaces / VS Code Remote** — Access the repo from anywhere
- **Tailscale/Headscale** — Secure remote access to the file server
- **Ansible / Terraform** — Infrastructure-as-code for workstation provisioning (if complexity warrants it)
