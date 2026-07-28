### Phase 2: Pre-install cifs-utils in ISO for offline NAS access

**Goal:** Enable NAS mounting during provisioning without internet by pre-installing cifs-utils via preseed.

**Prerequisites:**
- `iso/preseed.cfg` — exists, controls base install packages
- `iso/pool/` — exists, contains trixie packages for CD-ROM install
- `os-provision/commands/mount.sh` — exists, uses `mount -t cifs` (requires cifs-utils)

---

#### Task 1: Download trixie packages from Debian repos

**Description:** Download 3 .deb files (cifs-utils + 2 deps not in ISO) from `deb.debian.org/debian` trixie pool. These are the only packages missing from the ISO that cifs-utils needs at runtime.

**Files to create:**
- `iso/pool/main/c/cifs-utils/cifs-utils_7.4-1_amd64.deb`
- `iso/pool/main/s/samba/libtalloc2_2.4.4+samba4.24.4+dfsg-1_amd64.deb`
- `iso/pool/main/s/samba/libwbclient0_4.24.4+dfsg-1_amd64.deb`

**Download commands:**
```bash
# Create directories
mkdir -p iso/pool/main/c/cifs-utils
mkdir -p iso/pool/main/s/samba

# Download packages
wget -P iso/pool/main/c/cifs-utils/ https://deb.debian.org/debian/pool/main/c/cifs-utils/cifs-utils_7.4-1_amd64.deb
wget -P iso/pool/main/s/samba/ https://deb.debian.org/debian/pool/main/s/samba/libtalloc2_2.4.4+samba4.24.4+dfsg-1_amd64.deb
wget -P iso/pool/main/s/samba/ https://deb.debian.org/debian/pool/main/s/samba/libwbclient0_4.24.4+dfsg-1_amd64.deb
```

**Validation:**
- [ ] All 3 .deb files exist in correct pool subdirectories
- [ ] `dpkg-deb -I` on each file shows valid Debian package info
- [ ] File sizes roughly match: cifs-utils ~98K, libtalloc2 ~44K, libwbclient0 ~50K

**Estimated complexity:** Low

---

#### Task 2: Add cifs-utils to preseed package list

**Description:** Modify `preseed.cfg` to install cifs-utils during base OS installation from the CD-ROM pool.

**Files to modify:**
- `iso/preseed.cfg`

**Changes:**
- Line 47: Change `d-i pkgsel/include string` to `d-i pkgsel/include string cifs-utils`

**Validation:**
- [ ] `grep "pkgsel/include" iso/preseed.cfg` shows `cifs-utils`
- [ ] No other changes to preseed.cfg

**Estimated complexity:** Low

---

#### Task 3: Rebuild ISO

**Description:** Rebuild the bootable ISO to include the new packages in the pool and the updated preseed configuration.

**Files to modify:**
- `debtorchy.iso` (output, overwritten)

**Command:**
```bash
bash os-provision/commands/build-iso.sh
```

**Validation:**
- [ ] `debtorchy.iso` is regenerated (check timestamp)
- [ ] Mount ISO and verify `pool/main/c/cifs-utils/cifs-utils_7.4-1_amd64.deb` exists
- [ ] Mount ISO and verify `iso/pool/main/s/samba/libtalloc2_*.deb` exists
- [ ] Mount ISO and verify `iso/pool/main/s/samba/libwbclient0_*.deb` exists
- [ ] Mount ISO and verify `preseed.cfg` contains `cifs-utils` in pkgsel/include

**Estimated complexity:** Low

---

#### Task 4: Test provisioning flow

**Description:** Boot the ISO in a VM and verify cifs-utils is installed during base install, allowing NAS mount to work immediately when main.sh runs.

**Validation:**
- [ ] VM boots from ISO and installs Debian autonomously (preseed)
- [ ] After first login, `dpkg -s cifs-utils` shows installed
- [ ] `os-provision/main.sh` runs and `local-repo.sh` successfully mounts NAS
- [ ] `mount | grep cifs` shows NAS mounted at `/mnt/NAS2`
- [ ] All subsequent app installations use local repo (no internet needed for cached packages)

**Estimated complexity:** Medium (requires VM testing)

---

### Execution Order

```
Task 1 (download packages)          ← no dependencies
Task 2 (update preseed.cfg)         ← no dependencies
    ↓
Task 3 (rebuild ISO)                ← depends on Task 1 + Task 2
    ↓
Task 4 (test provisioning)          ← depends on Task 3
```

Tasks 1 and 2 can run in parallel. Task 3 requires both complete. Task 4 is manual verification.

---

### Summary

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 1 | Download trixie .debs | 3 new files in `iso/pool/` | Low |
| 2 | Update preseed.cfg | `iso/preseed.cfg` | Low |
| 3 | Rebuild ISO | `debtorchy.iso` | Low |
| 4 | Test in VM | none (manual) | Medium |
