### Phase 3: Xorg — dotfiles home fix, input packages, SSH testing toggle

**Goal:** Fix dotfile symlinks landing in root's home, resolve Xorg keyboard input issue in VM, and add safe SSH for testing.

**PR context:** Working on Xorg support — VM loses keyboard input after `startx`; dotfiles symlink to `/root/` when provisioning runs as root.

---

#### Task 1: Hardcode `/home/pc` in dotfiles and fonts scripts

**Description:** `dotfiles.sh` and `fonts.sh` use `~` which resolves to `/root/` when `main.sh` runs as root. Hardcode the `pc` user's home path so symlinks always target the correct user.

**Files modified:**
- `os-provision/dotfiles.sh` — replace all `~` with `"/home/pc"`
- `os-provision/fonts.sh` — replace `~` with `"/home/pc"`

**Validation:**
- [ ] `ls -la /home/pc/.config/` shows symlinks pointing to `/home/pc/repos/Debtorchy/os-provision/dotfiles/...`
- [ ] `ls -la /home/pc/.local/share/fonts` is a symlink to `/home/pc/repos/Debtorchy/os-provision/assets/fonts`
- [ ] `ls -la /home/pc/.bashrc`, `.vimrc`, `.xinitrc` exist and point to repo paths
- [ ] Re-running the script is safe (idempotent — `rm -f` before `ln -s`)

**Estimated complexity:** Low

---

#### Task 2: Remove dead polkit reference from i3 config

**Description:** The i3 config tries to exec `polkit-gnome-authentication-agent-1` which is not installed on Debtorchy VMs. The ISO pool only has base policykit libs, not the gnome agent. The user confirmed this is leftover from testing another app.

**Files modified:**
- `os-provision/dotfiles/i3/config` — delete lines 20-21 (polkit exec)

**Validation:**
- [ ] `grep polkit os-provision/dotfiles/i3/config` returns no matches
- [ ] No error about missing `/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1` at i3 startup

**Estimated complexity:** Low

---

#### Task 3: Add X input driver and X11 utils packages

**Description:** The `xorg` meta-package should pull these in, but on minimal netinst installs they may be missing. Create separate app scripts (one package per script) and add to orchestrator and package cache list.

**New files created:**
- `os-provision/apps/xserver-xorg-input-all.sh` — input drivers (libinput, evdev)
- `os-provision/apps/x11-xserver-utils.sh` — `xset`, `xrandr`, `setxkbmap`, etc.

**Files modified:**
- `os-provision/main.sh` — add new scripts to desktop section (after xinit, before i3)
- `package-manager/apt/packages.list` — add `x11-xserver-utils`, `xserver-xorg-input-all`

**Validation:**
- [ ] All 2 scripts executable (`chmod +x`)
- [ ] Scripts follow project pattern (idempotent, logging, no comments)
- [ ] New packages listed in `packages.list` (alphabetical order)
- [ ] `main.sh` calls scripts in correct order

**Estimated complexity:** Low

---

#### Task 4: Guard SSH behind TESTING env var

**Description:** `ssh.sh` installs `openssh-server`. Only enable it with password auth (including root) when `TESTING=true` is explicitly exported. Without the var, just skip SSH setup entirely — no service started, no config touched.

**Files modified:**
- `os-provision/apps/ssh.sh`

**Logic:**
- If `TESTING != true` → log "skipping" and exit (no SSH installed)
- If `TESTING=true` → install, set `PermitRootLogin yes` + `PasswordAuthentication yes`, enable service

**Usage:**
```bash
# Testing VM — SSH enabled with password auth
TESTING=true bash ~/repos/Debtorchy/os-provision/main.sh

# Production — SSH not set up
bash ~/repos/Debtorchy/os-provision/main.sh
```

**Validation:**
- [ ] Without `TESTING=true`: `dpkg -s openssh-server` shows not installed
- [ ] With `TESTING=true`: SSH enabled, root can login with password `admin`
- [ ] Re-running with `TESTING=true` is safe (idempotent — dpkg check before install)

**Estimated complexity:** Low

---

### Execution Order

```
Task 1 (dotfiles hardcode)         ← no dependencies
Task 2 (polkit removal)            ← no dependencies
Task 3 (X input packages)          ← no dependencies
Task 4 (SSH TESTING guard)         ← no dependencies
```

All tasks are independent and can run in parallel.

---

### Investigation Note

The Xorg keyboard issue needs manual diagnosis on the VM. Before/after running `main.sh` with the new packages, inspect:

```bash
dpkg -l | grep -E "xserver|xorg|libinput|x11-utils"
grep -iE "(keyboard|input|libinput|evdev|error|failed)" /var/log/Xorg.0.log
cat /proc/bus/input/devices
```

If keyboard still doesn't work after installing the new packages, check `.xinitrc` is correct (`exec i3`) and that i3 config keyboard bindings work (`setxkbmap` from `x11-xserver-utils`).
