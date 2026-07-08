### Ubuntu setup scripts

Automatically install programs and configure your ubuntu system.

```
os-provision/
├── main.sh           # runs all scripts below
├── dotfiles.sh       # symlinks dotfiles to ~/.config
├── fonts.sh          # symlinks nerd fonts from assets/
├── apps/
│   ├── alsa-utils.sh
│   ├── alacritty.sh
│   ├── bash-completion.sh
│   ├── brave.sh
│   ├── cifs-utils.sh
│   ├── coreutils.sh
│   ├── docker.sh
│   ├── fd.sh
│   ├── feh.sh
│   ├── font-awesome.sh
│   ├── fzf.sh
│   ├── gh.sh
│   ├── git.sh
│   ├── i3.sh
│   ├── keepassxc.sh
│   ├── less.sh
│   ├── lesspipe.sh
│   ├── libreoffice.sh
│   ├── nfs-common.sh
│   ├── opencode.sh
│   ├── p7zip.sh
│   ├── picom.sh
│   ├── pipewire-pulse.sh
│   ├── pipewire.sh
│   ├── polybar.sh
│   ├── pyenv.sh
│   ├── python.sh
│   ├── ripgrep.sh
│   ├── rsync.sh
│   ├── smbclient.sh
│   ├── ssh.sh
│   ├── starship.sh
│   ├── terraform.sh
│   ├── tmux.sh
│   ├── tree.sh
│   ├── vim.sh
│   └── wireplumber.sh
├── commands/
│   ├── logging.sh    # log helper
│   ├── server.sh     # mount NAS via SMB
│   └── sync-s.sh     # sync file(s) from NAS to ~/Desktop
├── python/
│   └── python-packages.sh
├── dotfiles/         # config files (symlinked to ~/.config)
│   ├── alacritty/
│   ├── bash/
│   ├── i3/
│   ├── opencode/
│   ├── picom/
│   ├── polybar/
│   ├── starship/
│   └── vim/
└── assets/
    └── backgrounds/
        └── wallpaper.jpg
```

Run `main.sh` on fresh Ubuntu. All scripts safe to re-run.
