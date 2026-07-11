### Customization

How to add your own apps, dotfiles, fonts, and binaries to Debtorchy.

---

### Adding a New App

#### APT package (most common)

1. Create a new script in `os-provision/apps/`:

```bash
#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "myapp.sh running"

if dpkg -s myapp >/dev/null 2>&1; then
    log "myapp already installed, skipping"
    exit 0
fi

log "Installing myapp"
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq myapp >/dev/null 2>&1

log "myapp.sh completed"
```

2. Add the package name to `package-manager/apt/packages.list` (if you want it cached on NAS)
3. Run `bash package-manager/apt/fetch.sh` to cache it
4. Add the script to `os-provision/main.sh` in the appropriate category:

```bash
bash ./os-provision/apps/myapp.sh
```

#### Binary (not in apt)

1. Create the script in `os-provision/apps/` with NAS cache + internet fallback:

```bash
#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "myapp.sh running"

if command -v myapp >/dev/null 2>&1; then
    log "myapp already installed, skipping"
    exit 0
fi

NAS_CACHE="/mnt/NAS2/Server/homelab-assets/Debtorchy-assets/packages/binaries/myapp/myapp"

if [ -f "$NAS_CACHE" ]; then
    log "Installing myapp from local cache"
    sudo cp "$NAS_CACHE" /usr/local/bin/myapp
    sudo chmod +x /usr/local/bin/myapp
else
    log "Installing myapp from internet"
    curl -fsSL https://example.com/install.sh | sh
fi

log "myapp.sh completed"
```

2. Add to `package-manager/binaries/binaries.list`:
```
myapp|https://example.com/myapp-linux-x64|binary
```

3. Run `bash package-manager/binaries/fetch.sh` to cache it

#### External repo + apt

For software that needs a third-party repository:

1. Add the repo definition to `package-manager/apt/external-repos.list`:
```
myapp|https://example.com/gpg-key.asc|deb [signed-by=/etc/apt/keyrings/myapp.gpg] https://repo.example.com stable main
```

2. Create the app script that adds the repo and installs:

```bash
#!/bin/bash

source "$(dirname "$0")/../commands/logging.sh"

log "myapp.sh running"

if dpkg -s myapp >/dev/null 2>&1; then
    log "myapp already installed, skipping"
    exit 0
fi

log "Installing myapp"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://example.com/gpg-key.asc -o /etc/apt/keyrings/myapp.asc
echo "deb [signed-by=/etc/apt/keyrings/myapp.gpg] https://repo.example.com stable main" \
    | sudo tee /etc/apt/sources.list.d/myapp.list
sudo apt update >/dev/null 2>&1
sudo apt install -y -qq myapp >/dev/null 2>&1

log "myapp.sh completed"
```

---

### Adding a New Dotfile

1. Place the config file in `os-provision/dotfiles/<app>/`:

```
os-provision/dotfiles/myapp/
└── config.toml
```

2. Add the symlink to `os-provision/dotfiles.sh`:

```bash
# myapp
mkdir -p ~/.config/myapp
rm -f ~/.config/myapp/config.toml
ln -s ~/repos/Debtorchy/os-provision/dotfiles/myapp/config.toml ~/.config/myapp/config.toml
```

3. Run `bash os-provision/dotfiles.sh` to apply

**Note:** All dotfile paths assume the repo is at `~/repos/Debtorchy`. Update if your path differs.

---

### Adding a New Font

1. Place the font file in `os-provision/assets/fonts/`:

```
os-provision/assets/fonts/
├── CodeNewRomanNerdFont-Regular.ttf
└── MyNewFont.ttf
```

2. The font is automatically symlinked to `~/.local/share/fonts/` by `fonts.sh`
3. Run `fc-cache -fv` to rebuild the font cache

---

### Adding a New Background/Wallpaper

1. Place the image in `os-provision/assets/backgrounds/`:

```
os-provision/assets/backgrounds/
├── wallpaper.jpg
└── my-wallpaper.png
```

2. Reference it in your i3 config or feh command (these are already configured to use `wallpaper.jpg`)

---

### Removing an App

1. Remove the script call from `os-provision/main.sh`
2. Optionally remove the script file from `os-provision/apps/`
3. Optionally remove the package from `package-manager/apt/packages.list`

The app will remain installed on existing systems. To remove it, run `sudo apt remove <package>` manually.

---

### Disabling an App

Comment out the line in `main.sh`:

```bash
# bash ./os-provision/apps/libreoffice.sh
```

The script will be skipped on next run.

---

### Changing the Repo Path

All scripts assume the repo lives at `~/repos/Debtorchy`. To change this:

1. Update paths in `os-provision/dotfiles.sh` (all `ln -s` commands)
2. Update paths in `os-provision/fonts.sh`
3. Update the clone instruction in `docs/getting-started.md`

---

### What's Next

- [Provisioning](provisioning.md) — Understanding the full script system
- [Package Manager](package-manager.md) — Caching new packages on NAS
- [Troubleshooting](troubleshooting.md) — Common issues and fixes
