### Debian setup scripts

Automatically install programs and configure your debian system.

## Usage

Run `main.sh` on fresh debian. All scripts safe to re-run.

```
os-provision/
├── main.sh               # orchestrator — runs all scripts in order
├── dotfiles.sh           # symlinks dotfiles from dotfiles/ to ~/.config
├── fonts.sh              # symlinks nerd fonts from assets/fonts/ to ~/.local/share/fonts
├── apps/                 # individual app installers (one per app)
│   ├── alacritty.sh      # terminal emulator
│   ├── alsa-utils.sh     # ALSA audio utilities
│   ├── bash-completion.sh # bash tab completion
│   ├── brave.sh          # brave browser (checks NAS cache, falls back to internet)
│   ├── cifs-utils.sh     # SMB/CIFS mount tools
│   ├── coreutils.sh      # core GNU utilities
│   ├── docker.sh         # Docker CE (adds Docker repo, installs from apt)
│   ├── fd.sh             # fd-find (fast find alternative)
│   ├── feh.sh            # image viewer (wallpapers)
│   ├── font-awesome.sh   # Font Awesome icons
│   ├── fzf.sh            # fuzzy finder
│   ├── gh.sh             # GitHub CLI (adds GitHub repo, installs from apt)
│   ├── git.sh            # git version control
│   ├── i3.sh             # i3 window manager
│   ├── keepassxc.sh      # password manager
│   ├── less.sh           # less pager
│   ├── lesspipe.sh       # less file type detection
│   ├── libreoffice.sh    # office suite (commented out in main.sh)
│   ├── libvirt-clients.sh # libvirt CLI tools
│   ├── libvirt-daemon-system.sh # libvirt daemon
│   ├── nfs-common.sh     # NFS client
│   ├── opencode.sh       # opencode CLI (checks NAS cache, falls back to internet)
│   ├── p7zip.sh          # 7zip archive tool
│   ├── picom.sh          # compositor for i3
│   ├── pipewire.sh       # PipeWire audio server
│   ├── pipewire-pulse.sh # PipeWire PulseAudio replacement
│   ├── polybar.sh        # status bar (needs font-awesome.sh)
│   ├── pyenv.sh          # Python version manager (checks NAS cache, falls back to internet)
│   ├── python.sh         # installs Python 3.12.12 via pyenv
│   ├── qemu-kvm.sh       # QEMU/KVM virtualization
│   ├── reprepro.sh       # Debian repo management tool (for package-manager)
│   ├── ripgrep.sh        # ripgrep (fast grep)
│   ├── rsync.sh          # file sync
│   ├── smbclient.sh      # SMB client
│   ├── ssh.sh            # OpenSSH server
│   ├── starship.sh       # starship prompt (checks NAS cache, falls back to internet)
│   ├── terraform.sh      # HashiCorp Terraform (adds HashiCorp repo, installs from apt)
│   ├── tmux.sh           # terminal multiplexer
│   ├── tree.sh           # directory tree viewer
│   ├── vim.sh            # Vim editor (vim-gtk3)
│   ├── virt-manager.sh   # libvirt GUI manager
│   ├── virtinst.sh       # virt-install tool
│   ├── wireplumber.sh    # WirePlumber session manager
│   └── xorriso.sh        # ISO creation tool
├── commands/
│   ├── logging.sh        # log() function with timestamps
│   ├── local-repo.sh     # mounts NAS, configures APT to prefer local repo (priority 900)
│   ├── server.sh         # interactive NAS mount (for manual use)
│   ├── build-iso.sh      # builds debtorchy.iso from iso/ directory
│   ├── start-vm.sh       # starts a VM for testing the ISO
│   └── sync-s.sh         # syncs main.kdbx from NAS to ~/Desktop
├── python/
│   └── python-packages.sh # pip installs (python-lsp-server)
├── dotfiles/             # config files (symlinked to ~/.config by dotfiles.sh)
│   ├── alacritty/        # alacritty.toml
│   ├── bash/             # .bashrc
│   ├── i3/               # i3 config
│   ├── opencode/         # opencode.json, tui.json, themes/
│   ├── picom/            # picom.conf
│   ├── polybar/          # polybar config
│   ├── starship/         # starship.toml
│   └── vim/              # .vimrc, .vim/
└── assets/
    ├── backgrounds/      # wallpaper.jpg
    └── fonts/            # Nerd Fonts (symlinked to ~/.local/share/fonts)
```

## Offline Packages

Apt packages and non-apt binaries are cached on the NAS via
`package-manager/`. During provisioning, `local-repo.sh` runs first
to:

1. Mount NAS via SMB
2. Add local repo as APT source (`file:///mnt/NAS2/.../apt-repo`)
3. Pin local repo at priority 900 (preferred over internet)
4. Run `apt-get update`

After this, all `apt install` commands in app scripts automatically
prefer the local repo. Non-apt scripts (starship, opencode, pyenv,
brave) explicitly check the NAS binary cache before downloading from
internet.

## Script Patterns

Every app script follows the same pattern:
1. Source `logging.sh`
2. Check if already installed (`dpkg -s` or `command -v`)
3. If installed → skip with log message
4. If not installed → install from NAS cache or internet
5. Log completion
