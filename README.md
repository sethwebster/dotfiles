# Seth's Dotfiles

Complete macOS setup automation. One script to rule them all.

## ✨ Features

- **Fully Automated** - Single command sets up everything
- **Idempotent** - Safe to run multiple times (won't break existing setup)
- **Interactive Prompts** - Collects required info (name, email) automatically
- **No Placeholders** - Script ensures all config values are filled in
- **Comprehensive** - 40+ apps, CLI tools, dev environments, macOS defaults
- **Modular Zsh** - Clean separation: path, aliases, functions
- **Mackup Integration** - Sync app settings via iCloud across machines
- **Secure** - No hardcoded credentials, proper quoting, set -euo pipefail

## Quick Start (Fresh Mac)

```bash
# Clone this repo
git clone https://github.com/sethwebster/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Make scripts executable
chmod +x *.sh

# Run bootstrap (prompts for name/email)
./bootstrap.sh
```

The script will:
1. ✅ Prompt for your Git name and email
2. ✅ Install Xcode Command Line Tools (if needed)
3. ✅ Install Homebrew (if needed)
4. ✅ Install all apps from Brewfile
5. ✅ Set up asdf and install Node/Python
6. ✅ Symlink dotfiles to your home directory
7. ✅ Optionally configure macOS defaults
8. ✅ Guide you through authentication setup

## What Gets Installed

### Applications (via Homebrew)
- **Browsers**: Chrome, Firefox, Arc, Brave
- **AI Tools**: Claude (desktop), ChatGPT, Claude Code (CLI), Cursor (AI editor)
- **Development**: VS Code, iTerm2, Warp, Docker, Postman, pgAdmin4, Expo Orbit
- **Productivity**: Slack, Discord, Notion, Zoom, Obsidian, Bear, Things, Fantastical
- **Launchers**: Raycast, Alfred
- **Communication**: Signal, WhatsApp, Beeper
- **Security**: 1Password
- **Utilities**: Rectangle, CleanShot X, The Unarchiver, Dropbox, Cyberduck, iStat Menus, DaisyDisk, Amphetamine
- **Creative**: Figma, Blender
- **Media**: Spotify, VLC

### CLI Tools
- Git & GitHub CLI (`gh`)
- asdf (version manager for Node, Python, etc.)
- Modern CLI replacements: `bat`, `eza`, `ripgrep`, `fzf`, `zoxide`
- PostgreSQL client
- ngrok

### Development Environments
- Node.js (via asdf)
- Python (via asdf)
- Bun
- Docker & Docker Compose
- PostgreSQL & Redis (via docker-compose.yml)

## Files Overview

```
dotfiles/
├── bootstrap.sh          # Main setup script
├── install.sh            # Symlink dotfiles
├── auth-setup.sh         # Guided authentication
├── macos.sh              # macOS defaults config
├── Brewfile              # Homebrew packages
├── docker-compose.yml    # PostgreSQL & Redis
├── .zshrc                # ZSH main config (loads modules)
├── path.zsh              # PATH modifications
├── aliases.zsh           # Command shortcuts
├── functions.zsh         # Custom shell functions
├── .gitconfig            # Git configuration
├── .tool-versions        # asdf versions
├── .mackup.cfg           # App settings sync config
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## What Gets Configured

### ZSH
- **Modular configuration** - Separated into path.zsh, aliases.zsh, functions.zsh
- Modern aliases (`ll`, `ls`, `cat` → `bat`, `cd` → `zoxide`)
- Git aliases (`gs`, `ga`, `gc`, `gp`, `glog`)
- Docker shortcuts (`dc`, `dcu`, `dcd`)
- Custom functions (`mkcd`, `extract`, `serve`, `dotfiles-update`)
- fzf fuzzy finding
- Auto-suggestions & syntax highlighting (if oh-my-zsh installed)

### Git
- Sensible defaults
- Useful aliases
- Global `.gitignore`
- Default branch: `main`

### macOS
- Finder: Show hidden files, extensions, path bar
- Dock: Auto-hide, custom size, no recents
- Screenshots: Save to `~/Screenshots` as PNG
- Keyboard: Fast repeat rate
- Trackpad: Tap to click

## Interactive Prompts

The bootstrap script will prompt for:

1. **Git name and email** (only if not already configured)
   - Used for all Git commits
   - Stored in global Git config

2. **macOS defaults** (only on first run)
   - Confirm before modifying system settings
   - Creates `~/.macos-defaults-applied` flag to skip on re-runs

3. **Oh-My-Zsh** (optional, during install.sh)
   - Enhanced shell experience with plugins

No other user input required - everything else is automatic!

## Manual Steps After Bootstrap

1. **GitHub**: `gh auth login`
2. **Expo**: `npx expo login`
3. **Apple ID**: System Settings → Sign in
4. **Creative Cloud**: Sign in to Adobe app
5. **Mackup**: Wait for iCloud sync, then `mackup restore`
6. **SSH**: Run `./auth-setup.sh` for guided setup

Or run the guided helper:
```bash
./auth-setup.sh
```

## Mackup - App Settings Sync

Mackup backs up and syncs app settings via iCloud:

### First Time Setup (After Installing Apps)
```bash
mackup backup
```

This saves settings for:
- VS Code (extensions, keybindings, settings)
- iTerm2 (profiles, colors)
- SSH config
- App preferences (Slack, Notion, etc.)

### On New Mac (After Bootstrap)
```bash
mackup restore
```

All your app settings are instantly back! 🎉

### Supported Apps
Mackup syncs 500+ apps automatically. See: https://github.com/lra/mackup#supported-applications

## Idempotency & Re-running

All scripts are **idempotent** - safe to run multiple times:

```bash
# Safe to re-run anytime
./bootstrap.sh  # Skips already-installed tools, re-applies config
./install.sh    # Only updates changed symlinks
```

**What happens on re-run:**
- ✅ Skips already-installed packages
- ✅ Preserves existing configs (creates backups if needed)
- ✅ Only prompts for missing information
- ✅ Asks before re-applying macOS defaults (creates `~/.macos-defaults-applied` flag)

**To force macOS defaults re-application:**
```bash
rm ~/.macos-defaults-applied
./bootstrap.sh
```

## Automatic Update Checking

Your dotfiles automatically check for updates **once per day** when you open a new terminal.

**How it works:**
- Checks GitHub for new commits (non-blocking, runs in background)
- Shows a notification if updates available
- Never auto-updates (you control when to pull)

**Update notification:**
```
╔═══════════════════════════════════════════════════════════╗
║  📦 Dotfiles Update Available                             ║
╚═══════════════════════════════════════════════════════════╝

  New updates are available for your dotfiles!

  To update, run:
    dotfiles-update
```

**To disable automatic checking:**
```bash
# Add to ~/.zshrc.local (not tracked in git)
DOTFILES_SKIP_UPDATE_CHECK=1
```

**To force a check now:**
```bash
rm ~/dotfiles/.last-update-check
source ~/.zshrc
```

## Updating Manually

```bash
# Easy way (updates dotfiles + Homebrew)
dotfiles-update

# Or manually
cd ~/dotfiles
git pull
./install.sh  # Re-symlink any new files
brew bundle   # Install new packages
```

## Customization

### Add Your Own Dotfiles
1. Add file to `~/dotfiles/` (e.g., `.vimrc`)
2. Add filename to `files` array in `install.sh`
3. Run `./install.sh`

### Modify Installed Apps
Edit `Brewfile` and run:
```bash
brew bundle --file=~/dotfiles/Brewfile
```

### Local Overrides
Create `~/.zshrc.local` for machine-specific config (not tracked in git):
```bash
# ~/.zshrc.local
export WORK_SPECIFIC_VAR="value"
alias work-command="..."
```

## Tools & Aliases Reference

### Modern CLI Tools
```bash
bat           # Syntax-highlighted cat
eza           # Better ls with git integration
rg            # Fast grep (ripgrep)
fzf           # Fuzzy finder
zoxide        # Smart cd (tracks frecency)
tldr          # Simplified man pages
```

### Git Aliases
```bash
gs            # git status
ga            # git add
gc            # git commit
gp            # git push
gl            # git pull
gd            # git diff
gco           # git checkout
gb            # git branch
glog          # pretty git log graph
```

### Docker Aliases
```bash
dc            # docker compose
dcu           # docker compose up
dcd           # docker compose down
dcb           # docker compose build
dps           # docker ps
```

## Maintenance

### Update Homebrew Packages
```bash
brew update && brew upgrade
```

### Update asdf Plugins
```bash
asdf plugin update --all
```

### Update Node/Python Versions
Edit `.tool-versions`, then:
```bash
asdf install
```

## Backup Current Config

Before running bootstrap, backup your existing configs:
```bash
cp ~/.zshrc ~/.zshrc.backup
cp ~/.gitconfig ~/.gitconfig.backup
```

The install script automatically creates timestamped backups.

## Docker Development Databases

Start PostgreSQL and Redis:
```bash
cd ~/dotfiles
docker compose up -d
```

Connection strings:
- **PostgreSQL**: `postgresql://postgres:postgres@localhost:5432/dev`
- **Redis**: `redis://localhost:6379`

Stop databases:
```bash
docker compose down
```

## Troubleshooting

### Bootstrap fails at Xcode
Install manually: `xcode-select --install`, then re-run.

### Homebrew not in PATH
Run: `eval "$(/opt/homebrew/bin/brew shellenv)"` (Apple Silicon)

### asdf command not found
Restart terminal or: `source ~/.zshrc`

### Git user not set
Edit `.gitconfig` or run:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Docker databases not starting
Ensure Docker Desktop is running, then:
```bash
docker compose restart
```

## License

MIT - Do whatever you want with this.
