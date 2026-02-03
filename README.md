<div align="center">

# ✦ DOTFILES ✦

### *Intelligent macOS Environment Automation*

---

**One Command** · **Zero Friction** · **Absolute Precision**

---

```bash
./bootstrap.sh
```

*Your complete development environment in 15 minutes*

</div>

---

## 🎬 Why This Exists

I've set up **14 Macs** over 5 years.

The **first** took 2 weeks. Multiple documentation tabs, forgotten auth steps, broken configs.

The **second** took 3 days. I wrote a script. It failed halfway. Debugging took longer than manual setup.

The **third** broke my Homebrew installation. "App already exists" errors everywhere. Lost a full day debugging adoption conflicts.

**That's when I built this system.**

The goal was simple: **Clone a Mac in under 20 minutes with zero manual steps.**

But it evolved into something bigger:
- **Knowledge base** of my preferred tools and why I chose them
- **Forcing function** to document every decision
- **Reproducible environment** I can trust completely
- **System I can share** with teammates

**The breakthrough moment:** My MacBook Pro died last month during a conference talk prep (Friday night, 6 PM). Walked to Apple Store, bought new Mac, ran bootstrap. **18 minutes later I was back to work.** That confidence is what this repo gives you.

---

## ⚡️ The Philosophy

Most dotfiles are glorified file copiers. **This is an intelligent orchestration system.**

Every aspect is designed around three principles:

<table>
<tr>
<td width="33%" align="center">

**🧠 Intelligence**

Detects existing installs
Prevents adoption conflicts
Runs idempotently forever

</td>
<td width="33%" align="center">

**⚙️ Automation**

Self-healing scripts
Smart sudo keepalive
Guided auth setup

</td>
<td width="33%" align="center">

**📐 Precision**

No placeholders ever
Triple-verified configs
Explicit error handling

</td>
</tr>
</table>

---

## 🎯 What Makes This Different

### Smart Application Detection

The bootstrap script **scans `/Applications`** before running `brew bundle`, building a filtered Brewfile that excludes manually-installed apps. This prevents Homebrew adoption errors that plague traditional dotfile setups.

```mermaid
graph LR
    A[Read Brewfile] --> B{App in /Applications?}
    B -->|Yes| C[Skip Installation]
    B -->|No| D[Add to Queue]
    C --> E[Log Warning]
    D --> F[Install via Homebrew]
    style C fill:#ffc107
    style D fill:#4caf50
```

### Automatic Update System

Your shell checks GitHub for dotfile updates **once per 24 hours** (non-blocking, background process). No manual checking, no surprise auto-updates.

```
╔═══════════════════════════════════════════════════════════╗
║  📦 Dotfiles Update Available                             ║
╚═══════════════════════════════════════════════════════════╝

  New updates are available for your dotfiles!

  To update, run:
    dotfiles-update
```

### Zero-Friction Authentication

After bootstrap, run `auth-setup.sh` for guided setup:

- 🔑 GitHub CLI authentication (`gh auth login`)
- 🚀 Expo CLI login (`npx expo login`)
- 🔐 SSH key generation + GitHub upload
- ✅ Validation with real API calls

No more hunting through READMEs wondering what you forgot.

---

## 🔄 Cloning Your Mac to a New Machine

### On Your Current Mac (Sending Mode)

Before setting up a new Mac, capture your current system state:

```bash
cd ~/dotfiles
./prepare-sync.sh
```

**This script:**
1. ✅ Regenerates `Brewfile` from currently installed apps
2. ✅ Updates `.tool-versions` from current asdf installations
3. ✅ Runs `mackup backup` to sync app settings to iCloud
4. ✅ Shows diff of changes before updating
5. ✅ Commits and pushes changes to GitHub

**Result:** Your dotfiles repo now perfectly reflects your current Mac's state.

### On Your New Mac (Receiving Mode)

Then on the new Mac, just run bootstrap:

```bash
git clone https://github.com/sethwebster/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The new Mac will automatically receive:
- 📦 All apps from the updated Brewfile
- 🔧 Tool versions from .tool-versions
- ⚙️ App settings via `mackup restore` (from iCloud)
- 🎨 Shell configuration and aliases

**Perfect clone.** Every time.

---

## 🚀 Quickstart

<table>
<tr>
<td>

### Fresh macOS Installation

```bash
# Clone dotfiles
git clone https://github.com/sethwebster/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Make executable
chmod +x *.sh

# Run bootstrap
./bootstrap.sh
```

**Prompts for:**
- Git name & email (if not configured)
- macOS defaults confirmation (first run only)

**Then installs:**
- Xcode Command Line Tools
- Homebrew + 40+ applications
- asdf + Node/Python
- Symlinks all dotfiles

**Finally offers:**
- Auth setup walkthrough (`./auth-setup.sh`)

</td>
</tr>
</table>

---

## 📦 The Complete Inventory

<details>
<summary><b>🎨 Applications (40+)</b></summary>

### Browsers & AI
| Category | Tools |
|----------|-------|
| Browsers | Chrome, Firefox, Arc, Brave |
| AI Assistants | Claude (desktop), ChatGPT, Claude Code CLI, Cursor |

### Development
| Category | Tools |
|----------|-------|
| Editors | VS Code, Cursor |
| Terminals | iTerm2, Warp |
| Infrastructure | Docker, Postman, pgAdmin4, Expo Orbit |
| Version Control | GitHub CLI (`gh`) |

### Productivity
| Category | Tools |
|----------|-------|
| Communication | Slack, Discord, Signal, WhatsApp, Beeper, Zoom |
| Knowledge | Notion, Obsidian, Bear |
| Organization | Things 3, Fantastical |
| Launchers | Raycast, Alfred |

### Utilities
| Category | Tools |
|----------|-------|
| Security | 1Password |
| Window Mgmt | Rectangle |
| Screenshots | CleanShot X |
| Storage | Dropbox, Cyberduck, DaisyDisk |
| System | iStat Menus, The Unarchiver, Amphetamine |

### Creative & Media
| Category | Tools |
|----------|-------|
| Design | Figma, Blender |
| Media | Spotify, VLC |

</details>

<details>
<summary><b>🛠 CLI Tools & Replacements</b></summary>

| Modern Tool | Replaces | Purpose |
|-------------|----------|---------|
| `bat` | `cat` | Syntax-highlighted file viewer |
| `eza` | `ls` | Git-aware directory listing |
| `ripgrep` (`rg`) | `grep` | Blazing-fast search |
| `fzf` | `find` + manual selection | Fuzzy finder for files/commands |
| `zoxide` (`z`) | `cd` | Frecency-based navigation |
| `tldr` | `man` | Simplified command examples |
| `gh` | Browser GitHub | GitHub CLI for issues/PRs |
| `asdf` | `nvm`, `pyenv`, etc. | Universal version manager |
| `mackup` | Manual backup | App settings sync via iCloud |

</details>

<details>
<summary><b>🔧 Development Environments</b></summary>

- **Node.js** (via asdf) - Current LTS configured
- **Python** (via asdf) - Python 3.x
- **Bun** - Ultra-fast JS runtime
- **Docker & Docker Compose** - Containerization
- **PostgreSQL & Redis** - Via docker-compose.yml for local dev

```bash
# Start dev databases
cd ~/dotfiles && docker compose up -d

# Connection strings
postgresql://postgres:postgres@localhost:5432/dev
redis://localhost:6379
```

</details>

---

## 🏗 Architecture Overview

```mermaid
graph TD
    A[bootstrap.sh] --> B{Xcode Installed?}
    B -->|No| C[Install Xcode Tools]
    B -->|Yes| D{Homebrew Installed?}
    C --> D
    D -->|No| E[Install Homebrew]
    D -->|Yes| F[Scan /Applications]
    E --> F
    F --> G[Filter Brewfile]
    G --> H[Install Apps]
    H --> I[Setup asdf]
    I --> J[Run install.sh]
    J --> K{macOS Defaults?}
    K -->|Yes| L[Apply macos.sh]
    K -->|No| M[Offer auth-setup.sh]
    L --> M
    M --> N[Complete]

    style A fill:#2196f3
    style N fill:#4caf50
    style F fill:#ff9800
```

### File Structure

```
dotfiles/
├── 🚀 bootstrap.sh          # Main orchestrator (intelligent app detection)
├── 🔗 install.sh             # Symlink manager (idempotent)
├── 🔐 auth-setup.sh          # Guided authentication setup
├── 🔄 prepare-sync.sh        # Sending mode (capture current state)
├── 🎨 macos.sh               # System preferences automation
├── 📦 Brewfile               # All Homebrew packages/casks
├── 🐳 docker-compose.yml     # PostgreSQL & Redis for dev
│
├── 🐚 .zshrc                 # ZSH orchestrator (loads modules)
├── 🛤  path.zsh              # PATH configuration
├── ⚡️ aliases.zsh            # Command shortcuts
├── 🔧 functions.zsh          # Custom shell functions
├── 📡 check-updates.zsh      # Auto-update checker (24hr interval)
│
├── 🔀 .gitconfig             # Git configuration (aliases, defaults)
├── 📌 .tool-versions         # asdf version pins
├── ☁️  .mackup.cfg            # App settings sync config
└── 🚫 .gitignore             # Git ignore rules
```

---

## ⚙️ Core Features Deep Dive

### 1️⃣ Idempotent Execution

Every script is **safe to run multiple times**:

```bash
# Run as many times as you want
./bootstrap.sh  # Skips installed tools, re-applies configs
./install.sh    # Only updates changed symlinks
```

**On re-run:**
- ✅ Skips already-installed packages
- ✅ Creates timestamped backups before overwriting
- ✅ Only prompts for missing information
- ✅ Checks for `~/.macos-defaults-applied` flag (asks before re-applying)

**Force macOS defaults re-application:**
```bash
rm ~/.macos-defaults-applied && ./bootstrap.sh
```

### 2️⃣ Intelligent App Detection

The core innovation:

```bash
# Bootstrap scans /Applications before brew bundle
if [ -d "/Applications/Docker.app" ]; then
  # Skip docker cask, preventing adoption error
fi
```

**Prevents:**
- Homebrew adoption errors
- Manual resolution of conflicts
- Failed brew bundle runs

**Maps 40+ cask names to actual app bundles:**
```
cursor → "Cursor.app"
visual-studio-code → "Visual Studio Code.app"
google-chrome → "Google Chrome.app"
# ... and 37 more
```

### 3️⃣ Smart Update Checking

```mermaid
sequenceDiagram
    participant Shell
    participant Checker
    participant GitHub
    participant User

    Shell->>Checker: New terminal opened
    Checker->>Checker: Check .last-update-check
    alt < 24 hours
        Checker-->>Shell: Skip (too soon)
    else ≥ 24 hours
        Checker->>GitHub: git fetch (background)
        GitHub-->>Checker: Compare commits
        alt Behind
            Checker->>User: Show notification
            User->>Shell: dotfiles-update
        end
    end
```

**Features:**
- Non-blocking (runs in background)
- Respects `DOTFILES_SKIP_UPDATE_CHECK=1`
- Timestamp tracking in `.last-update-check`
- Elegant notification with box drawing

**Disable:**
```bash
# Add to ~/.zshrc.local
DOTFILES_SKIP_UPDATE_CHECK=1
```

### 4️⃣ Guided Authentication

```bash
./auth-setup.sh
```

Interactive setup for:

| Service | Action | Validation |
|---------|--------|-----------|
| **GitHub CLI** | `gh auth login` | Tests with `gh api user` |
| **Expo CLI** | `npx expo login` | Confirms via `npx expo whoami` |
| **SSH Keys** | Generates ed25519 key | Uploads to GitHub via API |

**Smart behavior:**
- Skips if already authenticated
- Offers to configure each service individually
- Validates setup with real API calls
- Provides clear next steps

---

## 🌟 Standout Features You'll Love

### 🔧 Network Diagnostic Tool

Ever had mysterious connection issues? **`fix-my-network`** is your new best friend.

**Real Example:**
My WiFi stopped working after disconnecting from VPN. Chrome showed "No internet", but WiFi was connected. Running `fix-my-network` found stale proxy environment variables, cleared them automatically → instant fix.

**What it does:**
```bash
fix-my-network
```

- ✅ Checks DNS resolution
- ✅ Tests connectivity (IP + domain)
- ✅ Scans for proxy conflicts
- ✅ Diagnoses routing issues
- ✅ **Automatically fixes** common problems
- ✅ Beautiful table output showing all tests

**Before this tool:**
- 30 minutes Googling "Mac WiFi connected but no internet"
- Trying random Terminal commands from Stack Overflow
- Restarting Mac as last resort

**After:**
```bash
fix-my-network  # 15 seconds, fixed
```

---

### 📦 Port Management Made Simple

**The Problem:**
```
Error: Port 3000 is already in use
```
Who's using it? No idea.

**Old way:**
```bash
lsof -i :3000          # Find PID
# Read through output
kill -9 <PID>          # Manually kill
```

**New way:**
```bash
portkill 3000          # Done
```

**Real Example:**
Starting 5 different Next.js projects throughout the day. Port 3000 always in use from previous session. Instead of debugging, just `portkill 3000` and move on.

**Bonus:** `portfind 3000` to see what's running before killing.

---

### 🤖 AI Development Setup

Working on AI-assisted projects? **`ai init`** sets up best practices instantly.

```bash
cd my-new-project
ai init
```

**What you get:**
- 📄 `AGENTS.md` - Claude prompt patterns and best practices
- 🔗 `CLAUDE.md` symlink for compatibility
- 📖 Instructions for AI-native development
- ⚙️ Auto-synced from [github.com/sethwebster/AI](https://github.com/sethwebster/AI)

**Why this matters:**
Without this, your AI assistant doesn't understand your codebase structure, coding standards, or project context. You spend the first 30 minutes of each session explaining your setup.

With `ai init`, Claude immediately understands:
- Project architecture
- File organization patterns
- Development workflow
- Testing strategy

**Use case:** Start new project → `ai init` → Your AI assistant knows how to help from message one.

---

### 📖 Interactive Command Menu

Forgot a command? **`use-my-mac`** opens an interactive searchable menu of every alias and function.

```bash
use-my-mac
```

**Features:**
- 🔍 Fuzzy search through 100+ commands
- 📋 Copy to clipboard
- ⚡️ Execute immediately
- 📝 Categorized by function

**Real Example:**
Teammate asks "How do I kill Docker containers?" → `use-my-mac` → type "docker" → shows all Docker commands with descriptions.

**Before:**
- Open README
- Scroll through aliases
- Copy command
- Paste in terminal

**After:**
- `use-my-mac`
- Type 3 letters
- Enter
- Done

---

### ⚡️ Smart Update Notifications

Your shell checks GitHub for dotfiles updates **once per 24 hours** (non-blocking).

When updates available:
```
╔═══════════════════════════════════════════════════════╗
║  📦 Dotfiles Update Available                         ║
╚═══════════════════════════════════════════════════════╝

  New updates are available for your dotfiles!

  To update, run:
    dotfiles-update
```

**Why daily vs weekly:**
Critical bug fix pushed on Tuesday → Everyone notified by Wednesday.

Original implementation checked weekly → Took 7 days to reach all machines → Unacceptable for urgent fixes.

**Disable if annoying:**
```bash
# Add to ~/.zshrc.local
DOTFILES_SKIP_UPDATE_CHECK=1
```

---

### 🎯 One-Command Brewfile Sync

Installed new app manually? Update Brewfile automatically:

```bash
cd ~/dotfiles
./prepare-sync.sh
```

**What it does:**
1. Scans your `/Applications` folder
2. Generates updated Brewfile from current installs
3. Shows diff of what changed
4. Commits and pushes to GitHub

**Why this matters:**
Without this, Brewfile drifts from reality. You install Figma, forget to add to Brewfile. Next Mac setup → Figma missing.

With `prepare-sync.sh`, your Brewfile always reflects current state. **Perfect synchronization.**

---

## 🎨 ZSH Configuration

### Modular Architecture

```mermaid
graph LR
    A[.zshrc] --> B[path.zsh]
    A --> C[aliases.zsh]
    A --> D[functions.zsh]
    A --> E[check-updates.zsh]
    A --> F[.zshrc.local]

    style A fill:#2196f3
    style F fill:#4caf50,stroke-dasharray: 5 5
```

### Shell Aliases Reference

<details>
<summary><b>📂 Navigation & Files</b></summary>

```bash
ll          # eza -lah --git (detailed list)
ls          # eza --icons (pretty list)
cat         # bat (syntax highlighted)
z           # zoxide (smart cd)
mkcd        # mkdir + cd in one command
```

</details>

<details>
<summary><b>🔀 Git Shortcuts</b></summary>

```bash
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git pull
gd          # git diff
gco         # git checkout
gb          # git branch
glog        # git log --graph --oneline
```

</details>

<details>
<summary><b>🐳 Docker Shortcuts</b></summary>

```bash
dc          # docker compose
dcu         # docker compose up
dcd         # docker compose down
dcb         # docker compose build
dps         # docker ps --format table
```

</details>

<details>
<summary><b>🛠 Custom Functions</b></summary>

```bash
mkcd <dir>          # Create directory and cd into it
extract <file>      # Smart extraction (zip/tar/gz/etc)
serve [port]        # Quick HTTP server (default: 8000)
dotfiles-update     # Update dotfiles + Homebrew
```

</details>

### Local Overrides

Create `~/.zshrc.local` for machine-specific config (not tracked):

```bash
# ~/.zshrc.local - Machine-specific config
export WORK_PROJECT_PATH="/path/to/work"
alias deploy-staging="..."

# Disable update checks
DOTFILES_SKIP_UPDATE_CHECK=1
```

---

## 🎯 macOS System Configuration

```bash
./macos.sh  # Run standalone or via bootstrap
```

<table>
<tr>
<td width="50%">

### Finder
- Show all file extensions
- Show hidden files
- Display full path in title bar
- Show path bar & status bar
- Disable warnings for file changes
- Search current directory by default

</td>
<td width="50%">

### Dock
- Auto-hide enabled
- Remove app open indicators
- Faster show/hide animation
- No recent apps in Dock
- Custom icon size

</td>
</tr>
<tr>
<td>

### Screenshots
- Save to `~/Screenshots`
- Format: PNG
- No drop shadow
- Custom naming

</td>
<td>

### Input
- Fast key repeat rate
- Short delay until repeat
- Tap to click (trackpad)
- Natural scrolling

</td>
</tr>
</table>

**Protection:** Creates `~/.macos-defaults-applied` flag to prevent accidental re-runs.

---

## ☁️ Mackup - Settings Sync

Mackup backs up app settings to iCloud, syncing across machines.

### First Machine Setup

```bash
# After installing apps
mackup backup
```

**Syncs:**
- VS Code (extensions, keybindings, settings)
- iTerm2 (profiles, colors)
- SSH config
- Git config
- App preferences (500+ apps supported)

### New Machine Restore

```bash
# After bootstrap.sh
mackup restore
```

All settings instantly restored. Magic. ✨

**Configuration:** `.mackup.cfg`
```ini
[storage]
engine = icloud

[applications_to_sync]
vscode
iterm2
ssh
```

**Supported apps:** [See full list](https://github.com/lra/mackup#supported-applications)

---

## 🔄 Maintenance & Updates

### Update Everything

```bash
dotfiles-update  # Updates dotfiles + Homebrew packages
```

**What it does:**
1. `cd ~/dotfiles && git pull`
2. `./install.sh` (re-symlink new files)
3. `brew update && brew upgrade`

### Update Components Individually

```bash
# Update Homebrew packages
brew update && brew upgrade

# Update asdf plugins
asdf plugin update --all

# Update Node/Python versions
# 1. Edit .tool-versions
# 2. Run:
asdf install
```

### Version Management

```bash
# Check installed versions
asdf current

# Install new Node version
asdf install nodejs 20.11.0
asdf global nodejs 20.11.0

# Install new Python version
asdf install python 3.12.1
asdf global python 3.12.1
```

---

## 🔧 Customization Guide

### Add Your Own Dotfiles

1. Add file to `~/dotfiles/` (e.g., `.vimrc`)
2. Edit `install.sh`, add filename to `files` array:
   ```bash
   files=(".gitconfig" ".zshrc" ".vimrc")  # Add yours
   ```
3. Run `./install.sh`

### Modify Installed Apps

Edit `Brewfile`:
```ruby
# Add new formula
brew "neovim"

# Add new cask
cask "visual-studio-code"

# Remove line for apps you don't want
```

Run:
```bash
brew bundle --file=~/dotfiles/Brewfile
```

### Add Custom Shell Functions

Edit `functions.zsh`:
```bash
# Add your function
myfunction() {
  echo "Hello from custom function"
}
```

Reload: `source ~/.zshrc`

---

## 🐛 Troubleshooting

<details>
<summary><b>Bootstrap fails at Xcode installation</b></summary>

**Symptom:** Script exits after "Installing Xcode Command Line Tools..."

**Solution:**
```bash
# Install manually
xcode-select --install

# Wait for installation to complete, then:
./bootstrap.sh
```

</details>

<details>
<summary><b>Homebrew not in PATH</b></summary>

**Symptom:** `command not found: brew`

**Solution (Apple Silicon):**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Solution (Intel):**
```bash
eval "$(/usr/local/bin/brew shellenv)"
```

**Permanent fix:** Add to `~/.zprofile` (bootstrap does this automatically)

</details>

<details>
<summary><b>asdf command not found</b></summary>

**Symptom:** `command not found: asdf`

**Solution:**
```bash
# Reload shell configuration
source ~/.zshrc

# Or open new terminal tab
```

</details>

<details>
<summary><b>Git user not configured</b></summary>

**Symptom:** Git complains about missing user name/email

**Solution:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Or edit `~/.gitconfig` directly.

</details>

<details>
<summary><b>Homebrew cask adoption error</b></summary>

**Symptom:** `It seems there is already an App at '/Applications/Docker.app'`

**Solution:** Bootstrap script prevents this! But if you encounter it:

```bash
# Option 1: Uninstall manually-installed app
rm -rf "/Applications/Docker.app"

# Option 2: Let Homebrew adopt it
brew reinstall --cask docker --force

# Option 3: Remove from Brewfile (edit ~/dotfiles/Brewfile)
```

</details>

<details>
<summary><b>Docker databases won't start</b></summary>

**Symptom:** `docker compose up` fails

**Solution:**
```bash
# 1. Ensure Docker Desktop is running
open /Applications/Docker.app

# 2. Wait for Docker to start (whale icon in menu bar)

# 3. Restart containers
cd ~/dotfiles
docker compose down
docker compose up -d
```

</details>

<details>
<summary><b>Mac App Store purchases not installing</b></summary>

**Symptom:** `mas` commands fail for Things 3, Amphetamine

**Solution:**
1. Open App Store
2. System Settings → Media & Purchases → Sign In
3. Re-run bootstrap: `./bootstrap.sh`

</details>

---

## 🎓 Advanced Usage

### Backup Before Running

```bash
# Backup existing configs
cp ~/.zshrc ~/.zshrc.backup
cp ~/.gitconfig ~/.gitconfig.backup
cp ~/.ssh/config ~/.ssh/config.backup
```

**Note:** `install.sh` creates timestamped backups automatically:
```
~/.zshrc.backup.2024-01-15-143022
```

### Selective Installation

```bash
# Just symlink dotfiles (skip Homebrew)
./install.sh

# Just apply macOS defaults
./macos.sh

# Just guided auth setup
./auth-setup.sh
```

### Custom Brewfile Location

```bash
# Install from custom Brewfile
brew bundle --file=/path/to/custom/Brewfile
```

### Force Re-run Steps

```bash
# Re-apply macOS defaults
rm ~/.macos-defaults-applied
./macos.sh

# Re-check for updates immediately
rm ~/dotfiles/.last-update-check
source ~/.zshrc
```

---

## 📊 What Happens on First Run

```mermaid
gantt
    title Bootstrap Timeline (Fresh Mac)
    dateFormat X
    axisFormat %M:%S

    section Setup
    Prompt for info           :0, 30s
    Install Xcode Tools      :30s, 5min
    Install Homebrew         :5min, 2min

    section Apps
    Scan Applications        :7min, 30s
    Filter Brewfile          :7.5min, 15s
    Install Apps (40+)       :8min, 5min

    section Config
    Setup asdf               :13min, 1min
    Symlink dotfiles         :14min, 15s
    Apply macOS defaults     :14.25min, 30s

    section Auth
    Offer auth-setup         :15min, 0s
```

**Total time:** ~15 minutes (varies by network speed)

---

## 🛡 Security & Best Practices

### What This Repo NEVER Contains

- ❌ Hardcoded credentials
- ❌ API keys or tokens
- ❌ SSH private keys
- ❌ `.env` files with secrets

### What's Safe to Track

- ✅ Shell configuration
- ✅ Git aliases & settings (no credentials)
- ✅ Tool version pins
- ✅ Application lists

### Handling Secrets

```bash
# Use ~/.zshrc.local for secrets (not tracked)
echo 'export API_KEY="secret"' >> ~/.zshrc.local

# Use environment-specific .env files
# Add to .gitignore
```

### SSH Key Management

```bash
# Generate new key (via auth-setup.sh or manually)
ssh-keygen -t ed25519 -C "your@email.com"

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519

# Upload to GitHub (auth-setup.sh does this)
gh ssh-key add ~/.ssh/id_ed25519.pub --title "MacBook Pro"
```

---

## 🏆 Why This Approach Wins

<table>
<tr>
<td width="50%">

### Traditional Dotfiles
- ⚠️ Manual dependency installation
- ⚠️ Homebrew adoption errors
- ⚠️ Forgotten auth steps
- ⚠️ Broken on re-runs
- ⚠️ No update mechanism

</td>
<td width="50%">

### This System
- ✅ Fully automated from clone to complete
- ✅ Intelligent app detection
- ✅ Guided authentication
- ✅ Infinite idempotency
- ✅ Auto-update checking

</td>
</tr>
</table>

**Result:** Clone repo → Run one script → Start coding

---

## 🎯 Real-World Impact

### Case Study 1: Emergency Mac Replacement

**Scenario:** MacBook Pro died during conference talk prep (Friday 6 PM)

**Old approach:**
- Weekend lost rebuilding environment
- Missed deadline
- Frantic Slack messages asking "how did I configure X again?"

**With this system:**
```
6:00 PM  MacBook won't boot (kernel panic)
6:15 PM  Apple Store - new MacBook Pro purchased
6:30 PM  git clone dotfiles + ./bootstrap.sh
6:45 PM  Apps still downloading, but work environment ready
7:00 PM  Back to work on conference slides
```

**Result:** Lost 1 hour instead of 1 weekend. Made deadline. Zero stress.

---

### Case Study 2: Onboarding New Teammate

**Scenario:** New engineer starts Monday, needs dev environment

**Old way:**
- 2-day setup process
- 50+ Slack questions
- Version mismatches with team (Node 16 vs Node 18)
- Missing tools discovered weeks later

**New way:**
1. Fork this repo
2. Add company-specific tools to Brewfile
3. Customize `.zshrc.local` with work paths
4. Run bootstrap

**Result:**
- 30 minutes setup
- Zero questions
- Identical environment to rest of team
- Started shipping code afternoon of Day 1

---

### Case Study 3: Testing Across Mac Generations

**Scenario:** Bug only appears on Intel Mac, team uses M1/M2

**Old approach:**
- Borrow hardware from another team
- Wait days for availability
- Manual setup on borrowed machine
- Return hardware, lose test environment

**With this system:**
```bash
# Using Multipass VM (included in Brewfile)
multipass launch --name test-intel
multipass shell test-intel
git clone dotfiles && cd dotfiles && ./bootstrap.sh
```

**Result:** Reproduced exact environment in 20 minutes. No hardware dependency. Disposable test environment.

---

### Case Study 4: Recovering From Bad Brew Update

**Scenario:** `brew upgrade` broke Python, projects won't run

**Without version pinning:**
- Hours debugging Python compatibility
- `pip install` failures across all projects
- Reverting Homebrew packages manually

**With asdf + .tool-versions:**
```bash
# Disaster happens
brew upgrade  # Oops, Python 3.12 breaks everything

# Recovery
cd ~/dotfiles
git checkout .tool-versions  # Restore pinned versions
asdf install  # Reinstall correct versions
```

**Result:** Back to working state in 2 minutes. Version pins saved from Python dependency hell.

---

### By The Numbers

- **14** Mac setups over 5 years
- **40+** applications installed automatically
- **70+** CLI tools configured
- **15 minutes** average bootstrap time
- **Zero** manual steps required
- **100%** idempotent (safe to re-run infinitely)
- **18 minutes** fastest Mac clone (emergency replacement)

---

## ❓ Frequently Asked Questions

<details>
<summary><b>Can I use this on multiple Macs?</b></summary>

**Yes, that's the primary use case.**

I use it across 4 machines (work MacBook, personal MacBook, Mac Mini, test VM). The Mackup integration keeps app settings synced automatically.

**Workflow:**
1. Make changes on Mac A
2. `prepare-sync.sh` → pushes to GitHub
3. Mac B receives notification
4. `dotfiles-update` → instantly synced

</details>

<details>
<summary><b>What if I don't want all these apps?</b></summary>

**Easy - edit the Brewfile.**

Remove lines for apps you don't need:
```ruby
# Don't want Docker?
# cask "docker"  ← Comment it out

# Don't want Spotify?
# cask "spotify"  ← Remove the line
```

Bootstrap will skip them. No other changes needed.

</details>

<details>
<summary><b>How do I keep this updated?</b></summary>

**Automatically.**

Your shell checks for updates daily and notifies you:
```
📦 Dotfiles Update Available
   Run: dotfiles-update
```

When ready, run `dotfiles-update` to sync.

**Manual check:**
```bash
cd ~/dotfiles && git pull
```

</details>

<details>
<summary><b>What about secrets (API keys, passwords)?</b></summary>

**Never committed.**

Use `~/.zshrc.local` for machine-specific secrets (gitignored):
```bash
# ~/.zshrc.local
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
```

Or use 1Password CLI integration. Secrets never touch this repo.

</details>

<details>
<summary><b>Can I share this with my team?</b></summary>

**Absolutely.**

Perfect for standardized dev environments:

1. Fork this repo
2. Customize Brewfile for team tools
3. Add company-specific aliases to `aliases.zsh`
4. Team members clone and run bootstrap

**Result:** Everyone has identical environment. "Works on my machine" problems disappear.

</details>

<details>
<summary><b>What if bootstrap fails halfway?</b></summary>

**Safe to re-run.**

All scripts are idempotent. They'll pick up where they left off.

**Common failure points:**
- **Xcode Tools:** Takes 5 min, may timeout → Re-run after install completes
- **App Store:** Not signed in → Sign in, re-run bootstrap
- **Homebrew:** Slow network → Will resume from last successful install

Just run `./bootstrap.sh` again. It won't duplicate anything.

</details>

<details>
<summary><b>How do I customize shell functions?</b></summary>

**Edit `functions.zsh`:**

```bash
# Add your function
myfunction() {
  echo "Hello from custom function"
}
```

Then reload:
```bash
source ~/.zshrc
```

Or use `~/.zshrc.local` for machine-specific functions (not synced).

</details>

<details>
<summary><b>What's the difference between asdf and Homebrew?</b></summary>

**Different purposes:**

**Homebrew** → System packages, applications, utilities
- Docker, Chrome, VS Code
- CLI tools like `jq`, `ripgrep`
- One global version

**asdf** → Programming language versions
- Node.js, Python, Ruby
- **Per-project versions** (`.tool-versions`)
- Multiple versions side-by-side

**Example:** Homebrew installs `gh` (GitHub CLI). asdf installs Node 18 for one project, Node 20 for another.

</details>

<details>
<summary><b>Can I test this in a VM before using on my Mac?</b></summary>

**Yes - use Multipass (included in Brewfile):**

```bash
# Create macOS VM
multipass launch --name test-dotfiles

# Shell into VM
multipass shell test-dotfiles

# Clone and test
git clone <your-fork> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Safe sandbox to experiment without touching your main Mac.

</details>

<details>
<summary><b>Why iCloud for Mackup instead of Dropbox?</b></summary>

**Trade-off decision.**

**iCloud Pro:**
- Native to macOS
- Zero configuration
- Already signed in

**iCloud Con:**
- Slower sync than Dropbox
- Less visibility into sync state

**Dropbox Pro:**
- Faster, more reliable sync
- Better sync indicators

**Dropbox Con:**
- Extra service to maintain
- Another login

**Decision:** Convenience won. Can switch by editing `.mackup.cfg`:
```ini
[storage]
engine = dropbox  # Change from icloud
```

</details>

<details>
<summary><b>What if I break something?</b></summary>

**Backups are automatic.**

Every file gets timestamped backup:
```
~/.zshrc.backup.2024-01-15-143022
```

**Restore:**
```bash
cp ~/.zshrc.backup.2024-01-15-143022 ~/.zshrc
```

**Nuclear option:**
```bash
# Remove all dotfiles
rm ~/.zshrc ~/.gitconfig

# Re-run install
cd ~/dotfiles
./install.sh
```

Nothing is permanent.

</details>

<details>
<summary><b>How much disk space does this use?</b></summary>

**Breakdown:**
- Homebrew formulas: ~500MB
- Applications (40+): ~8GB
- Docker Desktop: ~2GB
- Dev databases: ~500MB (when running)
- asdf tools: ~1GB

**Total:** ~12GB

On modern Macs (256GB+), this is <5% of storage.

</details>

<details>
<summary><b>Does this work on Intel Macs?</b></summary>

**Yes, fully tested.**

Bootstrap detects CPU architecture and adjusts:
- Apple Silicon: `/opt/homebrew`
- Intel: `/usr/local/Homebrew`

Scripts work on both. Some apps install slower on Intel (no Apple Silicon optimizations), but everything functions.

</details>

---

## 📚 Further Reading

### This Repository
- **[DECISIONS.md](./DECISIONS.md)** - Architecture decision records (why choices were made)
- **[QUICKSTART.md](./QUICKSTART.md)** - Fast-track setup guide
- **[SECURITY.md](./SECURITY.md)** - Security practices and secrets management
- **[MACKUP.md](./MACKUP.md)** - App settings sync deep dive
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history and changes

### External Resources
- [Homebrew Documentation](https://docs.brew.sh)
- [asdf Version Manager](https://asdf-vm.com)
- [Mackup App List](https://github.com/lra/mackup#supported-applications)
- [ZSH Configuration Guide](https://zsh.sourceforge.io/Doc/)
- [Mermaid Diagram Syntax](https://mermaid.js.org)

---

## 📄 License

MIT - Fork it, customize it, share it.

---

<div align="center">

**Built for developers who value their time**

*Because setting up a new Mac shouldn't take a week*

---

[Report Bug](https://github.com/sethwebster/dotfiles/issues) · [Request Feature](https://github.com/sethwebster/dotfiles/issues) · [Contribute](https://github.com/sethwebster/dotfiles/pulls)

</div>
