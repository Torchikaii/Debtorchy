# Phase 4: Autonomous First-Boot Provisioning + Build-Time Credential Baking + Offline Install

**Goal:** Make provisioning run fully automatically on first boot, bake passwords into the ISO at build time (prompted, never committed), and make the whole install work without internet.

**Invariant:** All provisioning commands must be safe to re-run after an interrupted execution. `main.sh` is idempotent; cleanup of the first-boot service happens only after provisioning completes successfully.

**Decisions (confirmed with user):**
- No preseed template. `iso/preseed.cfg` stays the tracked source of truth with `admin` defaults; `build-iso.sh` builds from a temporary copy of `iso/`, so the tracked files are never modified (no in-place substitution, no backup/restore).
- First boot runs as **root** via a systemd `oneshot` service. No NOPASSWD, no `lockdown.sh`, no sudoers churn. `pc` keeps normal password sudo (as today).
- Fully offline install: base system installed from the ISO's own pool (netinst carries it). `build-iso.sh` regenerates the trixie `Packages`/`Release` index and `md5sum.txt` so apt sees the pool additions and the built ISO passes an integrity check.
- **Absolute minimal package set** — exactly what the installer installs when everything is deselected, plus `sudo` and `cifs-utils` and nothing else. No Recommends. `pkgsel/include` stays empty; the two packages are installed in late_command with `--no-install-recommends`.
- NAS credential fallback: empty input at build time bakes nothing.
- **Default password is `admin`** (both root and pc) — defined here once, referenced everywhere below; only changeable via the build-time prompts.
- **Deferred to a separate phase:** bookworm→trixie drift of the NAS offline repo (`local-repo.sh`, `package-manager/apt/`). Do not touch in this phase.

**Prerequisites on build machine:** `xorriso`, `python3`, `apt-utils` (apt-ftparchive). No network needed at build time — the `sudo` + `cifs-utils` dep closures are already committed in the pool (verified: all hard Depends debs physically present).

---

### Phase-4 review fixes (2026-07-31)

- **No `keyutils`.** `keyutils` is only a *Recommends* of cifs-utils (kernel-keyring/Krb5 mounts — not needed for password SMB). The plan no longer adds it and no longer lets apt pull it: `pkgsel/include` is empty and `sudo`/`cifs-utils` are installed in late_command with `--no-install-recommends`. Installed set = deselect-everything base + `sudo` + `cifs-utils` + hard Depends.
- Index regen scoped to `pool/main` only (the pool also holds contrib + non-free-firmware, which have their own component indices).
- Debconf names use underscores: `apt-setup/cdrom/set_first` (not `set-first`).
- Installed system's apt sources written the way trixie does it: deb822 `*.sources` files in `/etc/apt/sources.list.d/`, not the classic `sources.list`.
- `apt-ftparchive release` called with Release field options matching the original file; component Release regenerated before top-level.
- `build-iso.sh` `read` calls tolerate EOF (non-interactive default builds) and injected credentials are shell-escaped.
- Task 8 split: offline install + first-boot mechanics verified now; full provisioning completion requires the deferred NAS migration.

---

#### Task 1: Preseed offline install + autonomy + NAS creds placeholder + service enable + minimal packages

**Files to modify:**
- `iso/preseed.cfg`

**Changes:**
1. `d-i pkgsel/include string cifs-utils` → `d-i pkgsel/include string` (empty — nothing extra beyond the deselect-everything base)
2. Remove `mirror/*` lines; add:
   - `d-i apt-setup/use_mirror boolean false`
   - `d-i apt-setup/cdrom/set_first boolean true`
   - `d-i apt-setup/security boolean false`
   - `d-i pkgsel/update_policy select none`
   - `d-i pkgsel/upgrade select none`
3. late_command — keep existing lines; append:
   - `chown -R pc:pc /target/home/pc/repos/Debtorchy;`
   - `chmod -R u+w /target/home/pc/repos/Debtorchy;`
   - `@@NAS_CREDS@@` placeholder line (replaced at build with the creds block, or removed)
   - `cp /target/home/pc/repos/Debtorchy/os-provision/firstboot/debtorchy-firstboot.service /target/etc/systemd/system/;`
   - `in-target systemctl enable debtorchy-firstboot`
   - Install the two required packages (offline, from CD, no Recommends):
     ```
     in-target env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sudo cifs-utils;
     ```
   - Rewrite apt sources the trixie/deb822 way (see below)
4. Keep the 4 `d-i passwd/*password*` lines as the default password (`admin`, see Decisions) — substituted at build
**Sources rewrite (deb822, matching trixie's default layout):**
```
rm -f /target/etc/apt/sources.list /target/etc/apt/sources.list.d/*.sources /target/etc/apt/sources.list.d/*.list; \
printf '%s\n' 'Types: deb' 'URIs: http://deb.debian.org/debian' 'Suites: trixie trixie-updates' 'Components: main contrib non-free-firmware' 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' > /target/etc/apt/sources.list.d/debian.sources; \
printf '%s\n' 'Types: deb' 'URIs: http://security.debian.org/debian-security' 'Suites: trixie-security' 'Components: main contrib non-free-firmware' 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' > /target/etc/apt/sources.list.d/debian-security.sources; \
```
This removes the stale cdrom source and provides internet fallback for provisioning. The `@@NAS_CREDS@@` placeholder stays as its own `\`-continued physical line so removing it (empty input) never leaves a dangling continuation.

**Validation:**
- [ ] Preseed has empty `pkgsel/include`, no `mirror/http` lines
- [ ] Debconf names use underscores (`set_first`)
- [ ] late_command is entirely local (no curl/wget/internet); the apt-get install resolves from CD only
- [ ] Placeholder `@@NAS_CREDS@@` present
- [ ] `d-i` offline options present

**Estimated complexity:** Low

---

#### Task 2: First-boot service + script (run as root)

**New files to create:**
- `os-provision/firstboot/debtorchy-firstboot.service`
- `os-provision/firstboot/firstboot.sh` (executable: `chmod +x`)

**Service unit content:**
```ini
[Unit]
Description=Debtorchy first-boot provisioning
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
Environment=HOME=/home/pc
Environment=USER=pc
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/home/pc/repos/Debtorchy/os-provision/firstboot/firstboot.sh
TimeoutStartSec=infinity
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
```
(No `User=` line → runs as root. `HOME=/home/pc` required — `mount.sh`/`local-repo.sh`/`pyenv.sh` rely on `$HOME`.)

**`firstboot.sh` logic (root):**
1. `set -e`
2. `bash /home/pc/repos/Debtorchy/os-provision/main.sh`
3. `chown -R pc:pc /home/pc`
4. `systemctl disable debtorchy-firstboot`
5. `rm -f /etc/systemd/system/debtorchy-firstboot.service`
6. `systemctl daemon-reload`
7. `systemctl reboot`

On failure `set -e` exits; unit stays enabled → retried next boot (`main.sh` is idempotent). Cleanup (disable service, remove unit, daemon-reload, reboot) runs **only** after `main.sh` exits 0 — a partially-provisioned system is always retried, never half-cleaned.

**Validation:**
- [ ] `bash -n` passes on `firstboot.sh`
- [ ] `systemd-analyze verify` passes on the unit
- [ ] Re-run safe (chown/re-enable disabled service safe)

**Estimated complexity:** Medium

---

#### Task 3: `mount.sh` — no interactive prompt when not a TTY

**Files to modify:**
- `os-provision/commands/mount.sh`

**Changes:**
- In `setup_credentials`, skip prompting when `[ ! -t 0 ]` (systemd service has no TTY). Log a warning and leave `NAS_MOUNTED=false` instead of writing an empty creds file.

**Validation:**
- [ ] `bash os-provision/commands/mount.sh < /dev/null` creates no creds file
- [ ] First-boot service with no baked NAS creds produces no bogus `~/.smbcredentials-nas2`

**Estimated complexity:** Low

---

#### Task 4: `build-iso.sh` — credential prompts, preseed substitution, package embedding, rebuild from a temp copy

**Files to modify:**
- `os-provision/commands/build-iso.sh`

**Changes:**
1. Copy `iso/` to a temp build dir and stage the scripts there. The git-tracked `iso/` tree is never modified, so no backup/restore machinery and no risk of dirty git state:
   ```bash
   TMP_ISO="$(mktemp -d)"
   cp -a "$ISO_DIR/." "$TMP_ISO/"
   cp -a "$SCRIPT_DIR/os-provision" "$TMP_ISO/os-provision"
   cp -a "$SCRIPT_DIR/package-manager" "$TMP_ISO/package-manager"
   trap 'rm -rf "$TMP_ISO"' EXIT
   ```
2. Prompt for:
   - Root password (default `admin` — see Decisions)
   - pc password (default `admin`)
   - NAS username (default empty)
   - NAS password (default empty)
   Every `read` tolerates EOF so default builds work non-interactively:
   ```bash
   read -rp "Root password [admin]: " root_pass || true; root_pass="${root_pass:-admin}"
   ```
3. python3-substitute `$TMP_ISO/preseed.cfg`:
   - the 4 `d-i passwd/*password` lines → given values
   - `@@NAS_CREDS@@` → when creds given:
     ```
     printf 'username=%s\npassword=%s\n' 'U' 'P' > /target/home/pc/.smbcredentials-nas2; chown pc:pc /target/home/pc/.smbcredentials-nas2; chmod 600 /target/home/pc/.smbcredentials-nas2; \
     ```
     where `U`/`P` are single-quote-shell-escaped (embedded `'` → `'\''`) — the late_command is one `\`-joined busybox-sh line, so unescaped metacharacters in a password would break it.
   - when NAS creds empty → remove the placeholder line
4. Regenerate the package index in the temp copy. **`pool/main` only** (contrib and non-free-firmware have their own component indices under `dists/trixie/`):
   ```bash
   cd "$TMP_ISO"
   apt-ftparchive packages pool/main > dists/trixie/main/binary-amd64/Packages
   gzip -9 -f dists/trixie/main/binary-amd64/Packages
   ```
   Keep the uncompressed `Packages` alongside `Packages.gz` on the ISO so every file referenced by the regenerated `Release` physically exists (matches the committed top-level Release, which hashes both). Then regenerate the component Release before the top-level Release (the top-level one hashes it):
   ```bash
   apt-ftparchive release -o APT::FTPArchive::Release::Origin=Debian -o APT::FTPArchive::Release::Label=Debian -o APT::FTPArchive::Release::Suite=stable -o APT::FTPArchive::Release::Version=13.4 -o APT::FTPArchive::Release::Codename=trixie -o APT::FTPArchive::Release::Component=main -o APT::FTPArchive::Release::Architecture=amd64 dists/trixie/main/binary-amd64 > dists/trixie/main/binary-amd64/Release
   apt-ftparchive release -o APT::FTPArchive::Release::Origin=Debian -o APT::FTPArchive::Release::Label=Debian -o APT::FTPArchive::Release::Suite=stable -o APT::FTPArchive::Release::Version=13.4 -o APT::FTPArchive::Release::Codename=trixie -o APT::FTPArchive::Release::Components='main contrib' -o APT::FTPArchive::Release::Architectures=amd64 dists/trixie > dists/trixie/Release
   ```
   `Components` is `main contrib` — matching the committed top-level Release. Deliberately drop `Acquire-By-Hash` (no `by-hash/` dirs exist on the ISO, even though the committed Release advertises it). contrib / non-free-firmware / debian-installer / i18n indices untouched. `dists/stable -> trixie` follows automatically. The ISO has no `InRelease` (unsigned) — the regenerated `Release` stays unsigned, consistent.
5. Regenerate `md5sum.txt` in the temp copy (same format as the original: relative `./` paths, `find -type f` without `-follow` so the `debian -> .` symlink is not traversed). Generate to a temp file first so the file is not listed in its own checksum:
   ```bash
   cd "$TMP_ISO"
   find . -type f ! -name md5sum.txt -print0 | sort -z | xargs -0 md5sum > "$TMP_ISO.md5sum.txt"
   mv "$TMP_ISO.md5sum.txt" "$TMP_ISO/md5sum.txt"
   ```
6. `xorriso` as today, pointing at `$TMP_ISO`.

**Validation:**
- [ ] `bash os-provision/commands/build-iso.sh` (all defaults, non-interactive) → exit 0, `git status` clean (`iso/` untouched, preseed unchanged)
- [ ] With custom values → built ISO's preseed contains them; no `@@` tokens remain
- [ ] Mount built ISO → `apt-cache policy cifs-utils sudo` resolve; `keyutils` NOT pulled; closure satisfiable offline
- [ ] `md5sum -c md5sum.txt` on the mounted built ISO passes
- [ ] `debtorchy.iso` builds with exit 0

**Estimated complexity:** High

---

#### Task 5: `local-repo.sh` — tolerant apt-get update

**Files to modify:**
- `os-provision/commands/local-repo.sh`

**Changes:**
- Line 38: `sudo apt-get update -qq` → tolerate partial failure (`|| log "apt-get update: some sources failed"`), so NAS-only machines with no internet still refresh the `file://` lists and provision.

**Validation:**
- [ ] NAS-only + no internet: `main.sh` completes
- [ ] NAS down + internet up: fallback still works

**Estimated complexity:** Low

---

#### Task 6: Documentation

**Files to modify:**
- `docs/build-iso.md` — credential prompts, defaults, embedding, prerequisites (apt-utils), deb822 source note
- `docs/getting-started.md` — provisioning auto-runs on first boot; troubleshooting hint: first-boot logs are in `journalctl -u debtorchy-firstboot`
- `os-provision/commands/start-vm.sh` — SSH hint text (password no longer always `admin`)

**Estimated complexity:** Low

---

#### Task 7: Static analysis + rebuild

**Validation:**
- [ ] `shellcheck` + `bash -n` on all new/changed scripts
- [ ] Rendered preseed has no `@@` left
- [ ] `bash os-provision/commands/build-iso.sh` exit 0; `debtorchy.iso` fresh; `git status` clean

**Estimated complexity:** Low

---

#### Task 8: End-to-end VM test (manual)

Manual because Debian Installer execution, ISO boot, and libvirt VM integration are not currently automated — no CI harness exists for them yet (self-hosted KVM runner deferred per PRD).

**8a — Offline install (runs now).** libvirt network WITHOUT internet forwarding (true offline test).
- [ ] Install completes fully offline (deselect-everything base + `sudo` + `cifs-utils` from ISO pool)
- [ ] `dpkg -s sudo cifs-utils` installed; `dpkg -s keyutils` NOT installed (minimal set holds)
- [ ] `/home/pc/repos/Debtorchy` owned `pc:pc`, writable
- [ ] First boot: `journalctl -u debtorchy-firstboot` shows provisioning attempted as root; it stops at the first internet-dependent app (expected — see note)
- [ ] NAS creds (if baked) land in `/home/pc/.smbcredentials-nas2`, chmod 600

**8b — First-boot mechanics + provisioning (runs now).** Same VM, enable internet (NAT) and keep NAS unreachable/blocked from the VM (the stale bookworm repo pinned at priority 900 would otherwise break trixie resolution).
- [ ] Provisioning completes end-to-end from internet
- [ ] After reboot: service disabled + removed; `sudo -n true` fails (password required); pc login with baked/default password works
- [ ] Manual `main.sh` re-run as pc is idempotent

**Note:** NAS-backed offline provisioning validation is deferred with the bookworm→trixie NAS repo migration (original deferral). 8b uses internet + NAS-blocked so completion is testable now.

**Estimated complexity:** High

---

### Execution Order

```
Task 1 (preseed)                   ← no dependencies
Task 2 (firstboot service)         ← no dependencies
Task 3 (mount.sh TTY guard)        ← no dependencies
    ↓
Task 4 (build-iso.sh)              ← depends on 1 (placeholder), 2 (copies firstboot into ISO)
Task 5 (local-repo.sh)             ← no dependencies
Task 6 (docs)                      ← depends on 1-5
    ↓
Task 7 (static analysis)           ← depends on 1-6
    ↓
Task 8 (VM E2E)                    ← depends on 7
```

Tasks 1, 2, 3, 5 can run in parallel. Task 4 follows 1 + 2.

---

### PR Boundaries (advisory)

Git operations are done by hand per AGENTS.md — this only sketches how the work naturally groups into reviewable PRs. Dependencies matter: Task 4 touches the `@@NAS_CREDS@@` placeholder (1) and copies `firstboot/` into the ISO (2), so 4 cannot land before 1 and 2.

| PR | Tasks | Notes |
|----|-------|-------|
| 1 | 1, 3, 5 | Independent, small, lowest risk — good first merge |
| 2 | 2 | Independent; unit + script, no preseed |
| 3 | 4 | Depends on PR1 + PR2 — the big one, review in isolation |
| 4 | 6, 7 | Docs + static analysis over everything merged so far |
| 5 | 8 | Manual E2E; no code changes |

Not a hard contract — if a task grows a bug-fix follow-up, split it out rather than holding the sequence.

---

### Summary

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 1 | Preseed offline install + autonomy + NAS placeholder + minimal packages + service enable | `iso/preseed.cfg` | Low |
| 2 | First-boot service + script (root) | `os-provision/firstboot/{debtorchy-firstboot.service,firstboot.sh}` (new) | Medium |
| 3 | mount.sh non-TTY guard | `os-provision/commands/mount.sh` | Low |
| 4 | build-iso.sh prompts + substitution + index regen | `os-provision/commands/build-iso.sh` | High |
| 5 | local-repo.sh tolerant update | `os-provision/commands/local-repo.sh` | Low |
| 6 | Documentation | `docs/build-iso.md`, `docs/getting-started.md`, `start-vm.sh` | Low |
| 7 | Static analysis + rebuild | — | Low |
| 8 | VM end-to-end test | — | High |

---

### Security Rationale

Passwords are baked at build time via interactive prompt (empty → defaults `admin`), never committed to the repository. `debtorchy.iso` is gitignored (`*.iso`), and builds run on a temporary copy of `iso/`, so the committed `iso/preseed.cfg` is never modified. The transient build-time root window self-terminates: after provisioning the service is disabled and removed, and `pc` retains only normal password sudo. Baked secrets are readable by anyone holding the ISO — accepted homelab tradeoff, avoidable by leaving the prompts empty.
