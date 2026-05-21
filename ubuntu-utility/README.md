### Ubuntu setup scripts

Automatically install programs and configure your ubuntu system.

```
ubuntu-utility/
├── main.sh           # runs all scripts below
├── keyboard.sh       # keyboard layouts (console + GNOME)
├── dotfiles.sh       # symlinks dotfiles to ~/.config
├── apps/
│   ├── docker.sh     # docker
│   ├── terraform.sh  # terraform
│   ├── brave.sh      # brave browser
│   ├── alacritty.sh  # alacritty config symlink
│   ├── opencode.sh   # opencode CLI
│   ├── keepassxc.sh  # keepassxc
│   ├── libreoffice.sh # libreoffice
│   ├── vim.sh        # vim
│   ├── git.sh        # git
│   └── p7zip.sh      # p7zip
├── services/
│   ├── ssh.sh        # ssh config
│   ├── cifs-utils.sh # cifs-utils
│   └── nfs-common.sh # nfs-common
├── commands/
│   ├── logging.sh    # log helper
│   ├── server.sh     # mount NAS via SMB
│   └── sync-s.sh     # sync file(s) from NAS to ~/Desktop
└── dotfiles/         # config files (symlinked to ~/.config)
    ├── bash/.bashrc
    ├── vim/.vimrc
    ├── keyboard.dconf
    └── alacritty/
        ├── alacritty.toml
        └── themes/
            ├── catppuccin-frappe.toml
            ├── catppuccin-mocha.toml
            ├── gruvbox-material-medium-dark.toml
            └── miasma.toml
```


Run `main.sh` on fresh Ubuntu. All scripts safe to re-run.

**Alacritty setup:**
- Installs alacritty via apt
- Creates symlink: `~/.config/alacritty/alacritty.toml` -> `~/repos/utils/ubuntu-utility/dotfiles/alacritty/alacritty.toml`
- Safe to re-run (uses `rm -f` before symlink)
- Will fail if utils is not at `~/repos/utils`

**cifs-utils.sh:** Installs cifs-utils and smbclient.

**sync-s:** Pulls `<file>` from NAS to `~/Desktop/`. Mounts NAS automatically if needed. Alias: `sync-s`.
