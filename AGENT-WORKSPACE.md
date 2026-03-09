# Agent Workspace Instructions

**This file contains workspace-specific context for AI agents working in this repository.**

## Quick Start

When you start working in this workspace:

1. Read the general guidelines in [AGENTS.md](./AGENTS.md)
2. Read this file for workspace-specific context
3. Review recent commits to understand current work

## Workspace Context

### Repository Information

- **Repository**: Personal macOS dotfiles — intelligent environment automation for macOS
- **Primary Language**: Bash (all core scripts), ZSH (shell config)
- **Package Manager**: Homebrew (apps/tools), asdf (language runtimes)
- **Purpose**: Clone a complete Mac development environment in ~15 minutes with zero manual steps

### Key Files

```
dotfiles/
├── bootstrap.sh          # Main orchestrator — run this on a fresh Mac
├── install.sh            # Symlink manager (idempotent)
├── auth-setup.sh         # Guided GitHub/Expo/SSH authentication
├── prepare-sync.sh       # Capture current Mac state before cloning
├── macos.sh              # macOS system preferences automation
├── Brewfile              # All Homebrew formulas, casks, and mas apps
├── docker-compose.yml    # Local dev databases (PostgreSQL + Redis)
│
├── .zshrc                # ZSH entry point — sources all modules
├── path.zsh              # PATH configuration
├── aliases.zsh           # Shell aliases (gs, ga, gc, ll, dc, etc.)
├── functions.zsh         # Custom functions (mkcd, extract, portkill, etc.)
├── check-updates.zsh     # 24-hour update check (non-blocking)
│
├── .gitconfig            # Git configuration and aliases
├── .tool-versions        # asdf version pins (Node, Python)
├── .mackup.cfg           # App settings sync via iCloud
│
├── DECISIONS.md          # Architecture decision records
├── CHANGELOG.md          # Version history
├── SECURITY.md           # Security practices
└── MACKUP.md             # Mackup deep dive
```

### Development Commands

```bash
# Fresh Mac setup
./bootstrap.sh

# Re-symlink dotfiles only (safe to re-run)
./install.sh

# Apply macOS system preferences
./macos.sh

# Guided auth setup (GitHub CLI, Expo, SSH)
./auth-setup.sh

# Capture current Mac state + push to GitHub
./prepare-sync.sh

# Update dotfiles + Homebrew
dotfiles-update

# Start local dev databases
cd ~/dotfiles && docker compose up -d
```

## Critical Invariants

### All Scripts Must Be Idempotent

**UNBREACHABLE CONSTRAINT**: Every script must be safe to run multiple times with the same result.

- Check before acting — skip if already done
- Never overwrite without backing up (`*.backup.YYYYMMDD_HHMMSS`)
- Use flags (e.g., `~/.macos-defaults-applied`) for one-time operations

```bash
# ✅ CORRECT - Check before acting
if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
  log_success "$file already linked"
  continue
fi

# ❌ WRONG - Blindly overwrite
ln -sf "$source" "$target"
```

### Smart App Detection Pattern

Bootstrap scans `/Applications` before `brew bundle` to avoid adoption errors. Any changes to Brewfile cask additions must maintain a corresponding entry in the cask-to-app-name mapping table in `bootstrap.sh`.

```bash
# Mapping format: cask-name → App Bundle Name
if [ -d "/Applications/Docker.app" ]; then
  # Exclude docker from filtered Brewfile
fi
```

### No Secrets in Repo

- Never commit credentials, tokens, API keys, or SSH private keys
- Machine-specific secrets → `~/.zshrc.local` (gitignored)
- `install.sh` symlinks tracked dotfiles only

## Project-Specific Guidelines

### Tech Stack

- **Shell**: ZSH with modular config (`.zshrc` sources `path.zsh`, `aliases.zsh`, `functions.zsh`, `check-updates.zsh`)
- **Package management**: Homebrew for system packages/apps, asdf for language runtimes
- **Settings sync**: Mackup via iCloud
- **Local databases**: Docker Compose (PostgreSQL port 5432, Redis port 6379)
- **No frontend, no backend, no database schema** — this is shell infrastructure only

### Environment Setup

No environment variables required to work in this repo. Machine-specific vars go in `~/.zshrc.local`.

### Testing Strategy

- No automated test suite
- Idempotency is the primary correctness guarantee — test by running scripts twice
- Validate by running on a fresh macOS environment (Multipass VM or actual new Mac)

### Editing Shell Files

- `aliases.zsh` — add aliases here (short command shortcuts)
- `functions.zsh` — add functions here (multi-line logic)
- `path.zsh` — add PATH entries here only
- `check-updates.zsh` — do not modify unless changing update check behavior
- `.zshrc` — orchestrator only; sources modules, sets environment vars, configures plugins

### Adding to Brewfile

```ruby
# Formula (CLI tool)
brew "tool-name"

# Cask (GUI app)
cask "app-name"

# Mac App Store
mas "App Name", id: 123456789
```

After adding a cask, add the app-bundle mapping to `bootstrap.sh`'s detection block.

### Symlinked Files

Files symlinked by `install.sh` to `~/`:
- `.zshrc`, `path.zsh`, `aliases.zsh`, `functions.zsh`, `check-updates.zsh`
- `.tool-versions`, `.mackup.cfg`, `.nanorc`

To add a new symlinked file: add filename to the `files` array in `install.sh`.

## Common Pitfalls

- **Don't use `brew bundle --force`** — bootstrap's app detection exists to avoid this
- **Don't edit `.zshrc` for new commands** — put aliases in `aliases.zsh`, functions in `functions.zsh`
- **Don't hardcode paths** — use `$HOME`, `$DOTFILES_DIR`, etc.
- **Don't skip the idempotency check** — running twice must produce same result
- **Don't commit `~/.zshrc.local`** — it's gitignored for a reason (machine-specific secrets)

## Current Work

Check `git log --oneline -10` for recent changes. No standing active features.

---

**Note**: Keep this file updated as the project evolves.
