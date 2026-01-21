# 🚀 Quickstart Guide

**Complete macOS setup in 3 commands.**

---

## New Mac Setup

```bash
# 1. Clone this repo
git clone https://github.com/sethwebster/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Make scripts executable
chmod +x *.sh

# 3. Run bootstrap
./bootstrap.sh
```

**That's it.** The script will:
- Install Xcode Command Line Tools
- Install Homebrew + 160+ packages/apps
- Set up development tools (Node, Python, etc.)
- Configure macOS defaults
- Offer guided authentication setup

**Time:** 20-35 minutes (mostly downloads)

---

## Cloning Your Current Mac to New Mac

### On Your Current Mac (Sending Mode)

```bash
cd ~/dotfiles
./prepare-sync.sh
```

This captures:
- All installed Homebrew packages → Brewfile
- Tool versions (Node, Python, etc.) → .tool-versions
- App settings → iCloud (via Mackup)

### On Your New Mac (Receiving Mode)

```bash
git clone https://github.com/sethwebster/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x *.sh
./bootstrap.sh
```

**Perfect clone every time.**

---

## What Gets Installed

### Applications (~40)
- **Browsers:** Chrome, Firefox, Arc, Brave
- **AI Tools:** Claude, ChatGPT, Cursor, Claude Code
- **Dev Tools:** VS Code, iTerm2, Docker, Postman
- **Productivity:** Slack, Notion, Things 3, Raycast

### CLI Tools (~70)
- Git, GitHub CLI, awscli, fastlane
- Modern tools: bat, eza, ripgrep, fzf, zoxide
- Development: PostgreSQL, Redis, Ollama

### Mac App Store (~15)
- Things 3, Bear, Fantastical, Xcode
- Amphetamine, Kindle, WhatsApp

---

## After Bootstrap

The script will prompt to run authentication setup:

```bash
./auth-setup.sh
```

This guides you through:
- GitHub authentication (`gh auth login`)
- Expo login (`npx expo login`)
- SSH key generation + GitHub upload
- Docker verification

---

## Re-running Bootstrap

**Safe to run multiple times.** Bootstrap is idempotent:
- Skips already-installed apps
- Only prompts for missing info
- Won't break existing setup

```bash
cd ~/dotfiles
git pull
./bootstrap.sh
```

---

## Manual Steps

A few apps can't be automated:
- **TestFlight** - Install from App Store (macOS security restrictions)
- **Sign into:**
  - Apple ID (System Settings)
  - Adobe Creative Cloud

---

## Troubleshooting

### Git keeps asking for name/email
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Homebrew not in PATH
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
eval "$(/usr/local/bin/brew shellenv)"     # Intel
```

### asdf command not found
```bash
source ~/.zshrc
```

---

## Files Overview

```
~/dotfiles/
├── bootstrap.sh        # Main setup script
├── prepare-sync.sh     # Capture current Mac state
├── auth-setup.sh       # Guided authentication
├── install.sh          # Symlink dotfiles
├── macos.sh            # macOS defaults
├── Brewfile            # All packages/apps
├── .zshrc              # Shell config
├── .gitconfig          # Git config
└── .tool-versions      # Node/Python versions
```

---

## Next Steps

1. **Read the full [README.md](README.md)** for detailed info
2. **Check [SECURITY.md](SECURITY.md)** for best practices
3. **See [MACKUP.md](MACKUP.md)** for app settings sync

---

**Need help?** Open an issue: https://github.com/sethwebster/dotfiles/issues
