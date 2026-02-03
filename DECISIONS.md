# Architecture Decision Records

This document captures the "why" behind major architectural choices in this dotfiles system.

---

## Decision 1: Smart App Detection Over Manual Brewfile Maintenance

**Date:** 2023-08-12

**Context:**
Homebrew adoption errors were killing bootstrap runs. When apps exist in `/Applications` but aren't tracked by Homebrew, `brew bundle` fails with:
```
Error: It seems there is already an App at '/Applications/Docker.app'
```

Manual resolution required `brew reinstall --cask docker --force` for every conflict. On a fresh Mac with 10 pre-installed apps, this meant 10 manual interventions.

**Decision:**
Scan `/Applications` before `brew bundle`, building filtered Brewfile that excludes already-installed apps.

**Implementation:**
```bash
# Map cask names to actual app bundle names
if [ -d "/Applications/Docker.app" ]; then
  # Skip docker cask in filtered Brewfile
fi
```

**Trade-offs:**
- **Pro:** Zero adoption errors across 50+ fresh Mac setups
- **Pro:** No manual Brewfile editing before each bootstrap
- **Con:** 40+ cask-to-app-name mappings to maintain
- **Con:** Extra 30 seconds scanning `/Applications`

**Result:**
Worth it. Went from 100% adoption error rate to 0%. The mapping table is one-time maintenance cost for permanent reliability.

**Alternatives Considered:**
1. `brew reinstall --cask --force` for everything → Slow, wasteful bandwidth
2. Manual Brewfile editing per machine → Error-prone, defeats automation
3. Remove apps before bootstrap → Data loss risk, unnecessary

---

## Decision 2: Modular ZSH Config Over Monolithic .zshrc

**Date:** 2024-01-15

**Context:**
My `.zshrc` grew to 400+ lines. When aliases broke, I'd spend 10 minutes searching through one giant file. Adding new functions meant scrolling past unrelated code. No organization.

**Decision:**
Split into focused modules:
- `path.zsh` - PATH configuration only
- `aliases.zsh` - Command shortcuts
- `functions.zsh` - Custom shell functions
- `prompt.zsh` - Prompt customization
- `check-updates.zsh` - Update checker
- `.zshrc.local` - Machine-specific overrides (gitignored)

**Trade-offs:**
- **Pro:** Found and fixed 3 bugs in first week (easy to scan 50-line files)
- **Pro:** New contributors immediately understand structure
- **Pro:** Can disable modules by commenting one `source` line
- **Con:** More files to manage
- **Con:** Load time increased by 0.01s (negligible)

**Result:**
Debugging time went from 10 minutes to 30 seconds. File organization mirrors mental model. Would never go back to monolithic config.

**Alternatives Considered:**
1. Comments/sections in single file → Still hard to navigate
2. Oh-My-Zsh framework → Too heavy, too opinionated
3. Zsh plugin manager → Unnecessary complexity for personal dotfiles

---

## Decision 3: asdf Over Individual Version Managers

**Date:** 2023-03-20

**Context:**
Managing `nvm` (Node), `pyenv` (Python), `rbenv` (Ruby), `gvm` (Go) separately was chaos:
- 5 different commands to remember
- 5 config files scattered across `~/.config`
- Each loads into shell = slow startup
- Version conflicts between tools

Running `nvm use` in one project, then `pyenv local` in another = cognitive overhead.

**Decision:**
Consolidate to `asdf` as universal version manager.

**Implementation:**
- Single `.tool-versions` file per project
- One command: `asdf install`
- Single shell init: `source $(brew --prefix asdf)/libexec/asdf.sh`

**Trade-offs:**
- **Pro:** One config file (`.tool-versions`)
- **Pro:** One tool, one mental model
- **Pro:** Faster shell startup (one plugin vs five)
- **Pro:** Cross-language consistency
- **Con:** Less mature than `nvm` for Node specifically
- **Con:** Requires plugin per language (but one-time setup)
- **Con:** Team members need to learn new tool

**Result:**
Shell startup time dropped from 2.1s to 0.8s. Never think about version managers anymore. Just works.

**Metrics:**
- Before: 5 version managers, 2.1s shell startup
- After: 1 version manager, 0.8s shell startup
- Setup time: 2 minutes to install asdf + plugins

**Alternatives Considered:**
1. Docker for everything → Overkill for scripting, slow feedback loop
2. Keep all 5 managers → Continued chaos
3. Mise (rtx) → Too new in 2023, asdf more stable

---

## Decision 4: Mackup + iCloud Over Manual rsync

**Date:** 2023-11-08

**Context:**
Before Mackup, I had a 200-line `sync-settings.sh` script:
- Manually rsync'd `~/.ssh/config`
- Copied VS Code settings JSON
- Backed up iTerm2 profiles
- Tracked git config manually

Every time I changed a setting, I'd forget to run the sync script. New Macs always missing some config. "Why isn't my VS Code theme syncing?"

**Decision:**
Use Mackup to automatically sync 500+ app settings via iCloud.

**Configuration:**
```ini
[storage]
engine = icloud

[applications_to_sync]
vscode
iterm2
ssh
```

**Trade-offs:**
- **Pro:** Zero-maintenance after initial setup
- **Pro:** Automatic sync (no manual script)
- **Pro:** 500+ apps supported out-of-box
- **Pro:** Symlinks = changes propagate immediately
- **Con:** iCloud sync slower than Dropbox
- **Con:** Less control over what syncs
- **Con:** iCloud Desktop & Documents must be enabled

**Result:**
Rebuilt VS Code 3 times before Mackup. Zero times after. Settings sync "just works" now.

**Alternatives Considered:**
1. Dropbox backend → Faster but one more service to maintain
2. Git-based sync → Too manual, conflicts on simultaneous edits
3. Custom sync script → Already tried, failed at maintenance

---

## Decision 5: Docker Compose for Dev Databases

**Date:** 2023-06-15

**Context:**
Local Postgres/Redis installs caused problems:
- Conflicted with project-specific versions (Postgres 13 vs 15)
- Polluted global namespace (port 5432 always taken)
- Hard to reset to clean state
- Teammates on different versions = "works on my machine"

**Decision:**
Ship `docker-compose.yml` with PostgreSQL + Redis for local dev.

**Configuration:**
```yaml
services:
  postgres:
    image: postgres:15-alpine
    ports: ["5432:5432"]
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: dev

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
```

**Trade-offs:**
- **Pro:** Isolated per-project (can run multiple Postgres versions)
- **Pro:** Disposable (`docker compose down -v` = clean slate)
- **Pro:** Version-controlled in dotfiles
- **Pro:** Team consistency (everyone runs same image)
- **Con:** Requires Docker Desktop (60s startup time)
- **Con:** Extra RAM usage (~500MB for both services)
- **Con:** Slightly slower than native Postgres

**Result:**
Zero version conflicts in 6 months. `docker compose up -d` → instant dev environment. Can test migrations on Postgres 14 and 15 side-by-side.

**Alternatives Considered:**
1. Homebrew Postgres → Global state, version conflicts
2. Postgres.app → macOS only, manual start/stop
3. Cloud dev database → Network latency, costs money

---

## Decision 6: Idempotency as Core Design Principle

**Date:** 2023-01-10 (Initial design)

**Context:**
My first dotfiles script would:
- Append to `PATH` every run (ended up with 10 duplicates)
- Re-download Homebrew if check failed
- Overwrite configs without backups
- Fail halfway, leaving broken state

I'd run it once, it'd fail, I'd fix something, re-run, and **it would break differently**.

**Decision:**
Every script must be safe to run 100 times with same result.

**Implementation:**
```bash
# Check before installing
if ! command -v brew &> /dev/null; then
  install_homebrew
fi

# Check before appending
if ! grep -q "dotfiles/.gitconfig" ~/.gitconfig; then
  echo "[include] path = ~/dotfiles/.gitconfig" >> ~/.gitconfig
fi

# Backup before overwriting
if [ -f ~/.zshrc ]; then
  cp ~/.zshrc ~/.zshrc.backup.$(date +%Y-%m-%d-%H%M%S)
fi
```

**Trade-offs:**
- **Pro:** Run script 5 times debugging? No problem
- **Pro:** Bootstrap fails mid-way? Re-run from same state
- **Pro:** Confidence in automation
- **Con:** More checks = slightly slower
- **Con:** More complex logic

**Result:**
Went from "never re-run the script" to "run it every week to verify." Confidence in automation is everything.

**Philosophy:**
> "A script you can't re-run is a script you can't trust."

**Alternatives Considered:**
1. Document "run once only" → User error inevitable
2. Add `--force` flag → Still risky, easy to forget state
3. Full state management system → Overkill for dotfiles

---

## Decision 7: Git Config Written Immediately (Not at End)

**Date:** 2024-01-08

**Context:**
Bootstrap script collected git name/email at start, then wrote to `.gitconfig` at end. If Homebrew installation failed mid-script, git config never written. User had to re-enter info on next run.

With `set -e` (fail on error), any failure = exit immediately = lost git config.

**Decision:**
Write git config **immediately** after collecting it, before any potentially-failing commands.

**Implementation:**
```bash
# Collect info
read -p "Enter your name: " GIT_NAME

# Write IMMEDIATELY (before Xcode, Homebrew, etc)
git config --global user.name "$GIT_NAME"

# Now safe to run potentially-failing commands
install_xcode_tools
```

**Trade-offs:**
- **Pro:** Git config persists even if script fails later
- **Pro:** User never re-enters same info twice
- **Con:** More complex control flow (early write)
- **Con:** Git config written before dotfiles cloned

**Result:**
Zero frustrated users re-entering git config after bootstrap failures.

**Alternatives Considered:**
1. Write at end → Lost on failures (original problem)
2. Save to temp file → Extra file management, risk of orphan files
3. Remove `set -e` → Silently continue on errors (unacceptable)

---

## Decision 8: Daily Update Check (Not Weekly)

**Date:** 2024-02-10

**Context:**
Original implementation checked for dotfiles updates weekly. Missed critical fixes for days. When bug hit, I'd already pushed fix, but users wouldn't see update notification until next Sunday.

**Decision:**
Check for updates every 24 hours (daily) with `.last-update-check` timestamp.

**Implementation:**
```bash
# check-updates.zsh
if [ -f ~/.last-update-check ]; then
  last_check=$(cat ~/.last-update-check)
  hours_since=$(($(date +%s) - last_check) / 3600))
  if [ $hours_since -lt 24 ]; then
    return  # Skip check
  fi
fi

# Check GitHub for updates
git fetch origin main
if [ "$(git rev-list HEAD..origin/main --count)" -gt 0 ]; then
  show_update_notification
fi

date +%s > ~/.last-update-check
```

**Trade-offs:**
- **Pro:** Critical fixes reach users within 24 hours
- **Pro:** More frequent feedback on dotfiles evolution
- **Con:** Daily git fetch = 0.5s overhead per shell launch
- **Con:** Daily notification possible (if actively developing)

**Result:**
Fixed critical bootstrap bug on Tuesday, all users notified by Wednesday. Previously would've waited until Sunday.

**Opt-out:**
```bash
# Add to ~/.zshrc.local
DOTFILES_SKIP_UPDATE_CHECK=1
```

**Alternatives Considered:**
1. Weekly checks → Too slow for critical fixes
2. Hourly checks → Annoying for active development
3. Manual checks only → Nobody remembers

---

## Decision 9: Include Both Cursor AND VS Code

**Date:** 2024-09-15

**Context:**
Cursor launched as AI-native editor. Some said "just use Cursor, remove VS Code." But Cursor lacks extension marketplace maturity.

**Decision:**
Install both. Use each for different contexts.

**Usage:**
- **Cursor** → AI-assisted development, pair programming with Claude
- **VS Code** → Extensions (GitLens, Thunder Client, DB viewers), debugging, mature tooling

**Trade-offs:**
- **Pro:** Best tool for each job
- **Pro:** Cursor crashes? VS Code as fallback
- **Pro:** VS Code extensions not yet in Cursor
- **Con:** 1GB extra disk space
- **Con:** Two editors to maintain settings for

**Result:**
Cursor for new feature development (AI autocomplete), VS Code for debugging and complex extensions. Not wasting time with "either/or" false choice.

**Alternatives Considered:**
1. Cursor only → Missing critical extensions
2. VS Code only → Missing AI assistance
3. Vim/Neovim → Too much config, prefer GUI for complex projects

---

## Decision 10: LaunchAgent for Brew Updates (Not Manual)

**Date:** 2024-03-20

**Context:**
`brew update && brew upgrade` every Monday took 10 minutes. I'd forget for weeks, then have 50+ outdated packages. Security vulnerabilities piling up.

**Decision:**
Create LaunchAgent that runs `brew update && brew upgrade` automatically on Mondays at 8 AM.

**Implementation:**
```xml
<!-- ~/Library/LaunchAgents/com.seth.brew-update.plist -->
<key>StartCalendarInterval</key>
<dict>
  <key>Weekday</key>
  <integer>1</integer>  <!-- Monday -->
  <key>Hour</key>
  <integer>8</integer>
</dict>
```

**Trade-offs:**
- **Pro:** Never forget to update
- **Pro:** Security patches applied within 1 week
- **Pro:** Notification appears when updates complete
- **Con:** Surprise breakages possible (rare)
- **Con:** Uses bandwidth automatically
- **Con:** System notifications on Monday mornings

**Result:**
Brew always up-to-date. Caught OpenSSL security vulnerability within 3 days of announcement vs previous 3 weeks.

**Alternatives Considered:**
1. Manual updates → Forgetfulness
2. Daily updates → Too disruptive
3. Homebrew auto-update → Only runs on `brew install`, not comprehensive

---

## Decision Philosophy

Every decision follows these principles:

1. **Optimize for Future Me** - I will forget why I did this in 6 months
2. **Explicit Over Implicit** - No hidden magic, log everything
3. **Fail Loudly** - `set -euo pipefail` on all scripts
4. **Document Trade-offs** - No silver bullets, acknowledge costs
5. **Measure Impact** - "Feels better" isn't good enough

**When to Record a Decision:**
- Debated multiple approaches for >10 minutes
- Someone will ask "why not X?" in the future
- Trade-offs are non-obvious
- Failed experiments worth remembering

---

## Template for New Decisions

```markdown
## Decision N: [Title]

**Date:** YYYY-MM-DD

**Context:**
What problem was I solving? What was painful?

**Decision:**
What did I choose and why?

**Implementation:**
Code snippet showing the approach.

**Trade-offs:**
- **Pro:** Benefits gained
- **Con:** Costs paid

**Result:**
What actually happened? Would I do it again?

**Alternatives Considered:**
1. Option A → Why not?
2. Option B → Why not?
```

---

## Questions This Document Answers

- Why smart app detection instead of manual Brewfile edits?
- Why modular ZSH instead of one big `.zshrc`?
- Why asdf instead of nvm/pyenv/rbenv?
- Why Mackup instead of custom sync script?
- Why Docker Compose for databases?
- Why write git config immediately?
- Why both Cursor AND VS Code?
- Why daily update checks?

**If you're asking "why" about anything in this repo, the answer should be here.**
