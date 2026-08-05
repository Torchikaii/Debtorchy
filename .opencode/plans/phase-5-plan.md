# Phase 5: Restore the Working Build — Golden First-Boot Path

**Goal:** Restore the autonomous install pipeline: the OS installs unattended, reboots, and the `debtorchy-firstboot` oneshot service reliably auto-starts `main.sh` on first boot. Whether `main.sh` completes is explicitly out of scope.

**Regression under investigation (issue #91):** Since `613c79f` (last known-working build) the first-boot service stopped auto-running. The only change affecting the golden path since then is `db4d5ba`, which flipped the service unit from `Wants=network-online.target` to `Requires=network-online.target`. On the minimal preseed install there is no `*-wait-online` unit to activate `network-online.target`, so a `Requires=`+`After=` unit is never started. `Wants=` (the `e55d956`/`613c79f` state) is best-effort and is proven to work.

**Prerequisites:**
- Clean git tree on `sec/78-credentials` (verified: clean at start)
- Build machine with `xorriso`, `apt-ftparchive` (apt-utils), `python3` (all present)
- KVM + libvirt host for the VM E2E (present: `/dev/kvm`, `virt-install`, `virsh`)

---

#### Task 1: Fix the first-boot service network dependency

**Description:** Revert the oneshot unit's network dependency from `Requires=` back to `Wants=` so the service starts even though `network-online.target` is never activated on the minimal install.

**Files to modify:**
- `os-provision/firstboot/debtorchy-firstboot.service` (line 4)

**Changes:**
```
-Wants=network-online.target
+Requires=network-online.target
```
→ restore `Wants=network-online.target`, keeping `After=network-online.target`.

**Validation:**
- [ ] `bash -n os-provision/firstboot/firstboot.sh`
- [ ] `systemd-analyze verify os-provision/firstboot/debtorchy-firstboot.service` passes
- [ ] `grep -n network-online os-provision/firstboot/debtorchy-firstboot.service` shows `Wants=` (not `Requires=`)

**Estimated complexity:** Low

---

#### Task 2: Rebuild the ISO with defaults

**Description:** Produce a fresh `debtorchy.iso` non-interactively (all prompts default: `admin` passwords, no NAS credentials baked).

**Command:**
```bash
bash os-provision/commands/build-iso.sh
```

**Validation:**
- [ ] Exit code 0
- [ ] `git status` clean — tracked `iso/` tree unmodified, no build artifacts
- [ ] `debtorchy.iso` freshly written at repo root

**Estimated complexity:** Low

---

#### Task 3: Verify built ISO contents

**Description:** Confirm the staged ISO carries the corrected service unit, a fully-substituted preseed, and a valid checksum file.

**Validation:**
- [ ] Mount/extract `debtorchy.iso`
- [ ] `os-provision/firstboot/debtorchy-firstboot.service` on the ISO contains `Wants=network-online.target`
- [ ] `os-provision/firstboot/firstboot.sh` present
- [ ] No `@@` tokens remain in the rendered `preseed.cfg`
- [ ] `md5sum -c md5sum.txt` passes (against the extracted ISO)

**Estimated complexity:** Low

---

#### Task 4: End-to-end VM test — golden first-boot path

**Description:** Boot the freshly built ISO in a libvirt VM, let the unattended install run, confirm the system reboots and that the first-boot service auto-starts `main.sh`. Completion of `main.sh` is not a success criterion; `main.sh` starting automatically is.

**Command:**
```bash
bash os-provision/commands/start-vm.sh
```

**Validation:**
- [ ] Install completes unattended (no interaction)
- [ ] VM auto-reboots after install
- [ ] After boot, `journalctl -u debtorchy-firstboot -b 0` shows the service ran and `main.sh` started (first `main.sh running` / app logs)
- [ ] Expected and acceptable: `main.sh` stops at the first apt install (`curl.sh`) because the no-NAS path has empty apt lists — out of scope
- [ ] Service unit left enabled (retry-on-next-boot behaviour intact, since `main.sh` did not exit 0)

**Estimated complexity:** High

---

#### Task 5: Teardown

**Description:** Remove the test VM and any libvirt artifacts.

**Command:**
```bash
sudo virsh destroy debtorchy 2>/dev/null || true
sudo virsh undefine debtorchy --nvram 2>/dev/null || true
```

**Validation:**
- [ ] `virsh list --all` shows no `debtorchy` VM

**Estimated complexity:** Low

---

### Execution Order

```
Task 1 (service fix)              ← no dependencies
Task 2 (rebuild ISO)              ← depends on 1
Task 3 (ISO verification)         ← depends on 2
Task 4 (VM E2E)                   ← depends on 2, 3
Task 5 (teardown)                 ← depends on 4
```

---

### Summary

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 1 | Service `Requires=` → `Wants=` | `os-provision/firstboot/debtorchy-firstboot.service` | Low |
| 2 | Rebuild ISO (defaults) | — | Low |
| 3 | Verify ISO contents | — | Low |
| 4 | VM E2E golden path | — | High |
| 5 | VM teardown | — | Low |

---

### Out of Scope (explicit deferrals)

- `main.sh` completing provisioning (apt-lists/curl fix, NAS bookworm→trixie drift #89, brave failure) — user-confirmed out of scope
- Issue #90 `daemon-reload` bus error in `firstboot.sh` (cosmetic log noise)
- Any git operations (commit/push/branch) — done by hand per AGENTS.md
