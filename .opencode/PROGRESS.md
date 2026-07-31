# Progress Report: Debtorchy

**Last Updated:** 2026-07-31

Tracks implementation status against `.opencode/PRD.md`.

---

## Scope — In Scope

- [x] **ISO management** — Extracted Debian netinst ISO stored in `iso/`, git-lfs tracked
- [x] **ISO rebuilding** — `docs/build-iso.md` documents the xorriso command
- [x] **Preseed configuration** — `preseed.cfg` baked into ISO for autonomous install
- [x] **Post-install provisioning** — `os-provision/` scripts run after first boot
- [~] **File server synchronisation** — NAS mount, password db, fonts, wallpapers sync (`server.sh` + `sync-s.sh` exist but only sync `main.kdbx`)
- [ ] **PXE boot** — Network installation via PXE
- [x] **Documentation** — `docs/` with build instructions, usage guides

---

## Success Criteria — Functional Acceptance

- [x] `xorriso` produces bootable ISO from `iso/`
- [ ] ISO installs Debian fully autonomously
- [x] `os-provision/main.sh` executes without errors
- [x] All app installers create working installations
- [x] Dotfile symlinks resolve correctly
- [~] File server mount and sync work end-to-end (SMB mount works; sync limited to `main.kdbx`)
- [ ] PXE boot loads the installer

---

## Risks — Mitigation Status

- [ ] Debian version drift
- [ ] git-lfs storage bloat
- [ ] Path dependencies (`~/repos/Debtorchy`)
- [ ] File server unreachable
- [ ] Circular `iso/debian` symlink

---

## Backlog — Pending Work

- [ ] **Fully autonomous first boot** — Auto-login and run post-install provisioning immediately after install, hands-free. Provisioning identity (auto-login user, auto-run trigger, running as non-root) not yet decided — under investigation.
- [ ] **Centralized PATH management** — One canonical base PATH plus managed, idempotent additions from app installers; remove duplicate/conflicting entries.
- [ ] **Credential baking at ISO build** — Build prompts for NAS credentials and root/user password overrides and bakes them into the ISO; falls back to defaults when no input is given.
- [ ] **NAS credential handling** — Persist SMB credentials only after a successful mount; discard stale/wrong credentials instead of reusing them forever.
- [ ] **Testing: static analysis** — Shell linting (shellcheck) across all scripts, run in CI.
- [ ] **Testing: unit tests with mocked file server** — Validate provisioning utilities against a local fixture mirroring the NAS layout (no real NAS required).
- [ ] **Testing: end-to-end driver** — Build ISO, boot in VM, verify provisioning completes, tear down. CI E2E deferred (requires self-hosted runner with KVM).
