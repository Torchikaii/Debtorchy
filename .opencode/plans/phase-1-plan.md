### Phase 1: package-manager/ Refactoring

**Goal:** Eliminate duplicated NAS mount code, reuse shared logging, and merge `apt/fetch.sh` + `apt/update.sh` into one script.

**Prerequisites:**
- `os-provision/commands/logging.sh` — already exists, provides `log()`
- `os-provision/commands/mount.sh` — already exists, provides NAS mount with stale detection

---

#### Task 1: Move `apt/conf/distributions` up and create `apt/sync.sh`

**Description:** Move `conf/distributions` up one level to `package-manager/apt/distributions` and delete the empty `conf/` directory. Then merge `apt/fetch.sh` and `apt/update.sh` into a single `apt/sync.sh`. The script checks which packages from `packages.list` are missing or outdated in the local repo, downloads only those, and rebuilds with reprepro. If everything is current, exits silently.

**Files to modify:**
- `package-manager/apt/conf/distributions` → move to `package-manager/apt/distributions`
- Delete `package-manager/apt/conf/` (empty after move)

**New files to create:**
- `package-manager/apt/sync.sh`

**Logic:**
1. Source `os-provision/commands/logging.sh` and `../../os-provision/commands/mount.sh`
2. Mount NAS, ensure apt-repo and binaries dirs exist, ensure reprepro installed
3. Add external repos temporarily (docker, gh, hashicorp) to `/etc/apt/sources.list.d/`
4. Run `apt-get update`
5. Get current repo state: `reprepro -b "$APT_REPO_DIR" list bookworm`
6. For each package in `packages.list`:
   - If not in local repo → mark missing
   - If in local repo but upstream version newer → mark outdated
   - If current → skip silently
7. If nothing to download → clean up temp repos, log "all packages current", exit 0
8. Resolve dependency closures for marked packages
9. Download to staging dir
10. Build/update local repo: copy `$SCRIPT_DIR/distributions` to `$APT_REPO_DIR/conf/distributions`, then `reprepro includedeb`
11. Clean up temp repos, log completion

**Validation:**
- [ ] `package-manager/apt/conf/` directory no longer exists
- [ ] `package-manager/apt/distributions` exists with correct content
- [ ] `bash package-manager/apt/sync.sh` runs without errors on a system with NAS access
- [ ] First run (empty repo) downloads all packages and builds repo
- [ ] Second run (nothing changed) exits early with "all packages current"
- [ ] After adding a new package to `packages.list`, re-run downloads only the new package
- [ ] Temp external repo files (`*-fetch.list`) are cleaned up in all code paths (success, early exit, error)

**Estimated complexity:** Medium

---

#### Task 2: Update `package-manager/binaries/fetch.sh`

**Description:** Replace sourced `lib/common.sh` and `lib/nas.sh` with `os-provision/commands/logging.sh` and `os-provision/commands/mount.sh`. Add skip logic: if binary already exists on NAS at expected path, skip download silently.

**Files to modify:**
- `package-manager/binaries/fetch.sh`

**Changes:**
- Remove: `source "$SCRIPT_DIR/../lib/common.sh"` and `source "$SCRIPT_DIR/../lib/nas.sh"`
- Add: `source "$REPO_ROOT/os-provision/commands/logging.sh"` and `source "$REPO_ROOT/os-provision/commands/mount.sh"`
- Inline the constants that were in `common.sh` (`NAS_PACKAGES`, `BINARIES_DIR`, `STAGING_DIR`)
- Inline `ensure_nas_packages_dir()` (just `mkdir -p`)
- Add skip check: before downloading each binary, check if `$BINARIES_DIR/$name/` already contains files. If yes, log "already cached, skipping" and continue.

**Validation:**
- [ ] `bash package-manager/binaries/fetch.sh` runs without errors
- [ ] First run downloads all binaries to NAS
- [ ] Second run skips all binaries (already cached)
- [ ] No references to `lib/common.sh` or `lib/nas.sh` remain

**Estimated complexity:** Low

---

#### Task 3: Delete `package-manager/lib/` directory

**Description:** Remove `package-manager/lib/common.sh` and `package-manager/lib/nas.sh` — both are now superseded by shared scripts in `os-provision/commands/`.

**Files to delete:**
- `package-manager/lib/common.sh`
- `package-manager/lib/nas.sh`
- `package-manager/lib/` (directory)

**Validation:**
- [ ] `ls package-manager/lib/` returns "No such file or directory"
- [ ] `grep -r "lib/common.sh\|lib/nas.sh" package-manager/` returns no matches
- [ ] No script sources the deleted files

**Estimated complexity:** Low

---

#### Task 4: Delete old `apt/fetch.sh` and `apt/update.sh`

**Description:** Remove the now-replaced scripts after confirming `sync.sh` works.

**Files to delete:**
- `package-manager/apt/fetch.sh`
- `package-manager/apt/update.sh`

**Validation:**
- [ ] `ls package-manager/apt/fetch.sh package-manager/apt/update.sh` returns "No such file or directory"
- [ ] `grep -r "apt/fetch.sh\|apt/update.sh" package-manager/` returns no matches (except maybe README)

**Estimated complexity:** Low

---

#### Task 5: Update `package-manager/README.md`

**Description:** Update documentation to reflect the new structure: no `lib/` directory, single `sync.sh` instead of separate `fetch.sh`/`update.sh`.

**Files to modify:**
- `package-manager/README.md`

**Changes:**
- Remove `lib/` from the structure tree
- Replace `apt/fetch.sh` and `apt/update.sh` references with `apt/sync.sh`
- Update usage examples: single `bash package-manager/apt/sync.sh` command
- Note that scripts now reuse `os-provision/commands/logging.sh` and `mount.sh`

**Validation:**
- [ ] README structure tree matches actual file layout
- [ ] All referenced scripts exist
- [ ] No references to deleted files remain

**Estimated complexity:** Low

---

### Execution Order

```
Task 1 (move distributions + create sync.sh)  ← no dependencies
Task 2 (update binaries/fetch.sh)             ← no dependencies
    ↓
Task 3 (delete lib/)                          ← depends on Task 1 + Task 2
Task 4 (delete old apt scripts)               ← depends on Task 1
    ↓
Task 5 (update README)                        ← depends on all above
```

Tasks 1 and 2 can run in parallel. Tasks 3 and 4 can run in parallel after 1+2 complete. Task 5 is last.
