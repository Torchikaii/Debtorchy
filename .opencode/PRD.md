# Product Requirements Document: Debtorchy

**Version:** 1.1  
**Last Updated:** 2026-07-31

---

## 1. Executive Summary

Debtorchy is a monorepo that packages a complete Debian operating system together with its provisioning scripts, configuration, and documentation. The repository contains the full extracted Debian netinst ISO (versioned via git-lfs), post-install automation scripts, and build tooling — everything needed to produce a bootable, fully autonomous Debian installer.

The core value proposition is **full OS reproducibility**: a computer running Debtorchy carries no permanent important data. All user data, credentials, and assets live on redundant file servers. The OS itself is rebuilt and reprovisioned from this repo on every install, making each machine a stateless, disposable compute node that can be recreated at any time.

In its ideal state the pipeline is completely hands-free: building the installer optionally takes credentials and bakes them in, the OS installs without interaction, provisioning runs automatically on first boot, and every change is verified by a layered automated test strategy (static analysis, unit tests against a mocked file server, and end-to-end VM validation).

**Core Value Proposition:** One repository to rule the entire OS — from bare metal to productive workstation, fully automated, fully reproducible.

---

## 2. Mission & Principles

### Mission Statement

Build and maintain a complete, autonomous operating system deployment pipeline where a single repository contains the OS image, provisioning logic, and documentation — enabling instant, hands-free recreation of a production-ready workstation on any hardware.

### Core Principles

1. **Full Automation** — OS installation requires zero human interaction. Preseed configuration handles partitioning, user creation, and initial setup. Post-install scripts install programs, symlink dotfiles, and synchronise assets from file servers. First-boot provisioning starts automatically.
2. **Reproducibility** — Every install produces an identical system. No permanent state lives on the machine; all important data resides on redundant file servers.
3. **Idempotency** — All provisioning scripts are safe to re-run. No duplicate entries, no errors on re-execution.
4. **One Source of Truth** — The repository is the single authoritative source for the OS image, provisioning logic, and documentation.
5. **Self-Contained** — Minimal external dependencies. The repo holds everything needed to build and deploy.
6. **Self-Hosting** — The OS carries the tools to rebuild itself. Like a self-compiling compiler, a running Debtorchy system contains everything needed to produce a new Debtorchy ISO, provision a VM, and iterate on itself.
7. **Testability** — Critical flows are covered by automated tests (static analysis, unit tests with a mocked file server, end-to-end VM validation) so changes can be verified safely as the project grows.

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
| Manual post-install setup | Automated, automatic first-boot provisioning |
| Scattered dotfiles and config | Centralised repo with symlinks |
| Irreproducible environments | Version-controlled OS image |
| Untrusted changes breaking installs | Layered automated testing |

---

## 4. Scope

### In Scope ✅

- [ ] **ISO management** — Extracted Debian netinst ISO stored in `iso/` and version-controlled via git-lfs
- [ ] **ISO rebuilding** — A build script produces a bootable ISO from the repository contents
- [ ] **Preseed configuration** — Baked into the ISO, enabling fully autonomous installation with no human intervention
- [ ] **Post-install provisioning** — Scripts that install programs, dotfiles, and assets; run automatically after first boot
- [ ] **Fully autonomous first boot** — Auto-login into a provisioning session that runs the post-install pipeline immediately, with no manual intervention
- [ ] **File server synchronisation** — Scripts mount NAS, sync password databases, fonts, wallpapers, and other assets from redundant file servers
- [ ] **Credential management** — Build-time baking of NAS credentials and password overrides with fallback to defaults; credentials persisted only after successful authentication
- [ ] **Centralized configuration** — A single canonical source for environment and configuration additions (e.g. `PATH`), managed idempotently by installers
- [ ] **Automated testing** — Static analysis, unit tests against a mocked file server, and an end-to-end VM test driver
- [ ] **PXE boot** — The OS can be installed over the network via PXE in addition to USB
- [ ] **Documentation** — Build instructions, usage guides, and reference material

### Out of Scope ❌

- [ ] GUI applications for system management (CLI-first approach)
- [ ] Cross-platform support (Debian only)
- [ ] Enterprise fleet management (targeting individual power users)
- [ ] Full end-to-end testing on hosted CI runners (requires a self-hosted runner with KVM)

---

## 5. User Stories

**US-001:** As a power user, I want to build a bootable ISO from the repository, so I can install Debian on any machine.

**US-002:** As a power user, I want the OS installation to require zero interaction, so I can start the install and walk away.

**US-003:** As a power user, I want post-install scripts to automatically install my programs, dotfiles, and assets, so my workstation is ready to use immediately after first boot.

**US-004:** As a power user, I want my password database and other assets synchronised from a file server, so no permanent data lives on the local machine.

**US-005:** As a power user, I want to install the OS via PXE boot, so I don't need a USB stick for new installations.

**US-006:** As a power user, I want all provisioning scripts to be idempotent, so I can re-run them safely without duplicates or errors.

**US-007:** As a power user, I want the ISO content version-controlled with git-lfs, so I can track changes to the OS image over time.

**US-008:** As a power user, I want provisioning to start automatically on first boot, so I never have to log in or run anything manually.

**US-009:** As a power user, I want optional credentials (NAS access, passwords) baked in at build time, so the install stays hands-free without committing secrets to the repository.

**US-010:** As a power user, I want changes verified by automated tests before they ship, so I can trust that new changes don't break provisioning.

---

## 6. Architecture & Design

### Directory Structure

```
Debtorchy/
├── iso/              # Extracted Debian netinst ISO (git-lfs tracked)
│   └── preseed.cfg   # Autonomous install configuration
├── os-provision/     # Post-install provisioning
│   ├── apps/         # One installer per application
│   ├── commands/     # Shared utilities (mount, repository, build, VM)
│   ├── dotfiles/     # Config files symlinked into the user's home
│   └── assets/       # Fonts, wallpapers
├── package-manager/  # Offline apt repo + binary cache on the file server
├── tests/            # Automated tests (mocked file server, helpers)
├── docs/             # Documentation
└── README.md         # Repository entry point
```

### Data Flow

```
1. Build ISO        → build tool packages iso/ → debtorchy.iso
                     (optionally bakes credentials, falls back to defaults)
2. Boot ISO         → USB stick or PXE
3. Preseed install  → Fully autonomous Debian installation
4. First boot       → Auto-login, provisioning starts automatically
5. Provisioning     → Programs installed, dotfiles symlinked,
                       assets synced from file server
6. Ready            → Productive workstation, no permanent local data
```

### Design Patterns

| Pattern | Application |
|---------|-------------|
| **Facade** | An orchestrator runs all provisioning steps in order |
| **Single Responsibility** | Each installer handles one app or concern |
| **Idempotent Scripts** | All scripts check state before modifying |
| **Preseed Automation** | Debian installer fully configured via preseed |
| **Test Doubles** | A mocked file server substitutes the real NAS in unit tests |

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
| Static Analysis | shellcheck |
| Unit Testing | bats (Bash automated testing) |
| VM Automation | virt-install / libvirt |

---

## 8. Security & Configuration

### Authentication

| Utility | Method |
|---------|--------|
| NAS Mounting | Credentials baked into the ISO at build time or stored locally; persisted only after a successful mount |
| Password Database | KeePassXC (`main.kdbx`), synced from file server |
| Git | SSH keys / credential helpers |
| General | No sensitive data in repository |

### Configuration Management

- Dotfiles stored in the provisioning tree and symlinked into the user's home
- Preseed configuration baked into ISO for hands-off install
- Centralized environment/configuration additions (e.g. `PATH`) managed from a single canonical source by idempotent helpers
- Credentials provided at build time, never committed to the repository; empty input falls back to defaults

### Security Scope

- No production secrets stored in repository
- No API keys or tokens committed
- `.gitignore` excludes sensitive files
- Credentials handled by local credential files with `chmod 600`
- Baked credentials are readable by anyone holding the ISO — acceptable for a trusted homelab, and avoidable by leaving the prompts empty

---

## 9. Testing Strategy

Automated testing protects the reproducibility guarantee as the project grows. Tests are organised in layers, each validating a different risk:

| Layer | Scope | Runs |
|-------|-------|------|
| **Static analysis** | Syntax and quality linting of all shell scripts | CI, on every change |
| **Unit tests (mocked file server)** | Individual utilities (mounting, local repository setup, asset sync, configuration) against a local fixture that mirrors the file server layout — no real NAS or internet required | CI and locally |
| **End-to-end (VM)** | Full pipeline: build the ISO, boot it in a VM, verify provisioning completes and the system is usable, then tear down | Locally via a driver script; CI requires a self-hosted runner with KVM |

Test principles:

- **Isolation** — unit tests must not depend on a real NAS, internet access, or a real install.
- **Idempotency coverage** — every script's re-run safety is exercised by the tests.
- **Failure realism** — tests cover degraded paths (file server unreachable, stale credentials, empty credential input), not just happy paths.
- **Regression safety** — changes must not silently break previously working behaviour. The exact regression-testing mechanism is not decided yet.

---

## 10. API Specification

Not applicable — this is a collection of build tooling and provisioning scripts, not an API-driven service.

---

## 11. Success Criteria

### Functional Acceptance Criteria ✅

- [ ] `xorriso` command produces a bootable ISO from `iso/` directory
- [ ] ISO installs Debian fully autonomously with preseed configuration
- [ ] Provisioning runs automatically on first boot with zero interaction
- [ ] Build accepts optional credentials and falls back to defaults when input is empty
- [ ] All app installers create working installations
- [ ] Dotfile symlinks resolve correctly
- [ ] File server mount and sync commands work end-to-end
- [ ] PXE boot loads the installer successfully
- [ ] All shell scripts pass static analysis (shellcheck)
- [ ] Provisioning utilities pass unit tests against a mocked file server
- [ ] End-to-end driver boots the ISO in a VM, verifies provisioning, and tears down

### Quality Indicators

| Metric | Target |
|--------|--------|
| Scripts re-run safely | 100% idempotent |
| ISO builds | Reproducible from committed `iso/` content |
| Install autonomy | Zero human interactions required |
| Setup time (bare metal) | < 30 minutes total |
| Test coverage of critical paths | Verified by automated tests on every change |

---

## 12. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Debian version drift** — New stable releases break preseed or package compatibility | High | Medium | Test on current stable; maintain upgrade notes |
| **git-lfs storage bloat** — ISO content changes inflate repository size | Medium | High | Prune old LFS objects periodically; document storage expectations |
| **Path dependencies** — Scripts assume `~/repos/Debtorchy` | Medium | High | Add path detection; document requirement in README |
| **File server unreachable** — Install fails without NAS access | High | Low | Graceful fallback; cache critical assets locally |
| **Circular iso/debian symlink** — Tools may infinite-loop when traversing `iso/` | Low | Medium | Document the symlink behaviour; add note in README |
| **Credential exposure in ISO** — Baked secrets readable by anyone with the installer | Medium | Medium | Document the tradeoff; empty input bakes nothing; homelab-only trust model |

---

## 13. Future Considerations

### Post-MVP Enhancements

- **Offline package cache** — Host a local Debian mirror or cached `.apt` packages on the file server for internet-independent installation
- **Baked programs** — Include commonly needed `.deb` packages directly in the ISO to reduce post-install downloads
- **Automated testing in CI** — Full pipeline CI that builds the ISO and boots it in a VM to validate the entire install (requires a self-hosted runner with KVM)
- **Fleet deployment** — Reuse the autonomous pipeline to roll out identical machines
