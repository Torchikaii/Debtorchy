# Progress Report: Debtorchy

**Last Updated:** 2026-07-08

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
