# Add App: Add a New Application to Debtorchy

## Purpose

Guidelines for adding a new application, package, or system component to the Debtorchy provisioning pipeline.

---

## Input

Package name(s) provided as `$ARGUMENTS`. If multiple, space-separated.

---

## Where Things Live

| What | Location | Required |
|------|----------|----------|
| Install script | `os-provision/apps/<name>.sh` | Yes |
| Dotfiles | `os-provision/dotfiles/<name>/` | Only if app has config |
| Dotfile symlink | `os-provision/dotfiles.sh` | Only if dotfiles exist |
| APT cache entry | `package-manager/apt/packages.list` | Yes (apt packages only) |
| Orchestrator entry | `os-provision/main.sh` | Yes |

---

## Steps

### Step 1: Create install script

Create `os-provision/apps/<name>.sh` following this template:

```bash
#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "<name>.sh running"

if dpkg -s <package> >/dev/null 2>&1; then
    log "<package> already installed, skipping"
    exit 0
fi

log "Installing <package>"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq <package> >/dev/null 2>&1

log "<name>.sh completed"
```

**Rules:**
- One script per package. Dependencies are handled by apt automatically.
- Script must be idempotent (check `dpkg -s` before installing).
- Use `logging.sh` for output.
- Make script executable: `chmod +x`.

### Step 2: Add to package-manager (apt packages only)

Add package name to `package-manager/apt/packages.list` in alphabetical order.

Skip this step for:
- Meta-packages or virtual packages
- Packages that are dependencies of other packages (apt handles these)

### Step 3: Add dotfiles (only if needed)

Only if the app has a user-facing config file that should be version-controlled:

1. Create `os-provision/dotfiles/<name>/` with config files
2. Add symlink entry to `os-provision/dotfiles.sh`:
   ```bash
   # <name>
   mkdir -p ~/.config/<name>
   rm -f ~/.config/<name>/<config-file>
   ln -s ~/repos/Debtorchy/os-provision/dotfiles/<name>/<config-file> ~/.config/<name>/<config-file>
   ```

Skip dotfiles for:
- Simple CLI tools with no config (git, curl, wget)
- System packages where default config is fine

### Step 4: Add to orchestrator

Add entry to `os-provision/main.sh` in the appropriate section:

```
# section name
bash ./os-provision/apps/<name>.sh
```

**Ordering matters:**
- Place in the section matching the app's category (audio, desktop, development, etc.)
- If app B depends on app A, B must come after A in the list
- For system/display servers (xorg, xinit), place before window managers (i3)

### Step 5: Verify

- Script is executable
- Script is idempotent (safe to re-run)
- Package added to `packages.list` (if apt package)
- Entry added to `main.sh`
- Dotfiles added (if needed)

---

## Edge Cases

### System packages with no user config (xorg, xinit)
- Create install script
- Add to `packages.list`
- Add to `main.sh`
- No dotfiles needed

### Packages that need custom dotfiles for OTHER apps
Example: xorg provides X11 but needs a `.xinitrc` (which is a dotfile for xinit, not xorg).
- Create dotfile in the consuming app's dotfile dir (e.g., `dotfiles/x/xinitrc`)
- Add symlink in `dotfiles.sh`

### Meta-packages or package groups
- Still create one install script
- Use the meta-package name in `dpkg -s` check
- Add to `packages.list` under the meta-package name

### Non-apt packages (tarballs, binaries)
- Create install script in `os-provision/apps/`
- Add entry to `package-manager/binaries/binaries.list`
- Do NOT add to `package-manager/apt/packages.list`

### Very rare edge cases
- Consider consulting repo owner in case app cannot be added by
following guideliness provided.
- Sometimes it may be better to not follow this strict patter
e.g. apps with PPA repos, maybe flatpaks or something), but in
this case you must consult the repo owner.

---

## Checklist

- [ ] Install script created and executable
- [ ] Idempotent (dpkg check at start)
- [ ] Uses logging.sh
- [ ] Added to `package-manager/apt/packages.list` (if apt package)
- [ ] Added to `os-provision/main.sh` (correct section, correct order)
- [ ] Dotfiles created + symlinked (if needed)
- [ ] No duplicate entries
