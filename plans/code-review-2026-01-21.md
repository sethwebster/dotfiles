# Dotfiles Code Review - 2026-01-21

## Executive Summary

This dotfiles repository provides macOS setup automation with reasonable structure but contains several security vulnerabilities, shell scripting issues, and architectural concerns that need attention before production use.

---

## Sudo Usage & Privilege Escalation Analysis

### Summary: PASS - No Security Regressions

The codebase demonstrates **correct privilege separation**. Sudo usage is minimal and appropriate.

### Detailed Findings

#### 1. Homebrew Operations - CORRECT (User-level)

**Location:** `/Users/sethwebster/dotfiles/bootstrap.sh`

All Homebrew commands run as current user without elevation:
- Line 90: `curl ... | bash` - Homebrew installer handles its own sudo internally only when needed
- Line 104: `brew update` - No sudo
- Line 109: `brew bundle` - No sudo
- Line 118: `brew install asdf` - No sudo

**Verdict:** Follows Homebrew security model correctly. Homebrew explicitly warns against running as root.

#### 2. File Operations in User Space - CORRECT (No elevation)

**Location:** `/Users/sethwebster/dotfiles/install.sh`

All operations target `$HOME`:
- Line 36: Symlinks to `$HOME_DIR` - No sudo
- Line 48: Backups in `$HOME_DIR` - No sudo
- Line 62-98: `.gitignore_global` creation - No sudo
- Line 101-122: Oh-My-Zsh in `~/.oh-my-zsh` - No sudo

**Verdict:** Correct. All user-space operations properly avoid elevation.

#### 3. auth-setup.sh - CORRECT (Zero sudo)

**Location:** `/Users/sethwebster/dotfiles/auth-setup.sh`

Entire script operates in user space:
- `gh auth login` - User-level GitHub CLI auth
- `npx expo login` - User-level Expo auth
- `ssh-keygen` - Creates keys in `~/.ssh/`
- `git config --global` - User-level git config

**Verdict:** No privilege escalation whatsoever. Correct.

#### 4. macos.sh - CORRECT (Minimal, legitimate sudo)

**Location:** `/Users/sethwebster/dotfiles/macos.sh`

Only TWO sudo commands, both legitimate:

1. **Line 10: `sudo -v`** - Credential caching (correct pattern)
2. **Line 20: `sudo nvram SystemAudioVolume=" "`** - REQUIRES sudo (nvram is system firmware)
3. **Line 83: `sudo chflags nohidden /Volumes`** - REQUIRES sudo (/Volumes is system directory)

User-space operations correctly avoid sudo:
- Line 38: `mkdir -p "${HOME}/Screenshots"` - No sudo (correct)
- Line 80: `chflags nohidden ~/Library` - No sudo (correct, user's Library)
- All `defaults write` commands - No sudo (user preferences)

**Verdict:** Proper privilege separation. Sudo only where macOS genuinely requires it.

### Potential Improvements (Non-critical)

#### 1. Missing sudo authentication failure handling

**Location:** `/Users/sethwebster/dotfiles/macos.sh:10`

```bash
# Current
sudo -v

# Better
if ! sudo -v; then
    echo "Error: sudo authentication failed. Exiting."
    exit 1
fi
```

**Impact:** Low. Script continues on failed auth, subsequent commands fail confusingly.

#### 2. No sudo keep-alive for long scripts

**Location:** `/Users/sethwebster/dotfiles/macos.sh:10`

Comment claims to "avoid mid-script password prompts" but doesn't implement keep-alive. macOS sudo timeout is ~5 minutes.

```bash
# Optional keep-alive pattern
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
```

**Impact:** Low. Only matters if script takes >5 minutes.

### Security Grade for Privilege Escalation: A

- No unnecessary sudo in user-space operations
- Homebrew runs as user (correct)
- install.sh has zero sudo (correct)
- auth-setup.sh has zero sudo (correct)
- macos.sh sudo limited to genuinely system-level operations

---

## Critical Issues

### 1. Unsafe curl pipe to shell pattern

**Location**: `/Users/sethwebster/dotfiles/bootstrap.sh:90`, `/Users/sethwebster/dotfiles/bootstrap.sh:156`, `/Users/sethwebster/dotfiles/install.sh:107`

**Problem**: Multiple instances of `curl | bash` pattern which is fundamentally insecure:
```bash
# bootstrap.sh:90
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# bootstrap.sh:156
curl -fsSL https://bun.sh/install | bash

# install.sh:107
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

**Impact**:
- MITM attacks can inject malicious code
- Transient network issues can cause partial script execution
- No integrity verification (checksums/signatures)
- GitHub/CDN compromise would affect all users

**Solution**:
- Download scripts first, verify checksum, then execute
- Pin to specific commit hashes instead of `HEAD`
- At minimum, warn users about this risk

---

### 2. Missing `set -u` (undefined variable check)

**Location**: All shell scripts (`bootstrap.sh`, `install.sh`, `auth-setup.sh`, `macos.sh`)

**Problem**: Scripts use `set -e` but not `set -u`. Undefined variables silently expand to empty strings, potentially causing:
- Unexpected behavior (`rm -rf $UNDEFINED/` could delete `/`)
- Silent failures when expected variables are missing

**Impact**: High risk of unintended side effects from typos or missing env vars.

**Solution**: Add `set -u` after `set -e` in all scripts. Use `${VAR:-default}` for optional variables.

---

### 3. Docker Compose hardcoded credentials

**Location**: `/Users/sethwebster/dotfiles/docker-compose.yml:9-11`

```yaml
environment:
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
  POSTGRES_DB: dev
```

**Problem**: Hardcoded credentials committed to version control.

**Impact**:
- If this repo is ever public, credentials are exposed
- Encourages bad practice of using `postgres:postgres` in development
- Credentials often leaked via shell history, logs

**Solution**:
- Use env file (`docker-compose.yml` should reference `.env`)
- Add `.env` to `.gitignore` (already present)
- Document that users should create their own `.env`

---

### 4. Unquoted variable expansion in multiple locations

**Location**: Multiple files

**Problem**: Unsafe variable expansion without quotes:

```bash
# bootstrap.sh:120 - unquoted brew prefix
. $(brew --prefix asdf)/libexec/asdf.sh

# .zshrc:16 - unquoted in source
. $(brew --prefix asdf)/libexec/asdf.sh

# install.sh:50 - unquoted basename
log_warning "Backed up existing $file to $(basename $backup)"

# functions.zsh:61 - unquoted cd
cd ~/dotfiles && git pull && ./install.sh && cd -
```

**Impact**: Paths with spaces will break. While macOS paths rarely have spaces, Homebrew's prefix is user-configurable.

**Solution**: Always quote: `"$(brew --prefix asdf)"`, `"$(basename "$backup")"`, `cd "$HOME/dotfiles"`

---

### 5. SSH key generation without passphrase prompt

**Location**: `/Users/sethwebster/dotfiles/auth-setup.sh:93`

```bash
ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519
```

**Problem**: No `-N` flag provided, so SSH key passphrase is prompted but not enforced or guided. Script doesn't validate email input either.

**Impact**: Users might skip passphrase, leaving SSH key unencrypted on disk.

**Solution**:
- Add explicit passphrase guidance
- Validate email format before use
- Consider `-N ""` with prominent warning OR require passphrase

---

## Architecture Concerns

### 1. `.gitconfig` symlink + include creates fragile setup

**Location**: `/Users/sethwebster/dotfiles/bootstrap.sh:192-203`, `/Users/sethwebster/dotfiles/install.sh:24-32`

**Problem**:
- `install.sh` symlinks `.gitconfig` to home
- `bootstrap.sh` appends include directive to `~/.gitconfig`
- If `.gitconfig` is symlinked, appending writes to the repo file
- Creates chicken-egg problem and potential config corruption

**Impact**: Git config could get duplicated includes on re-runs.

**Solution**:
- Don't symlink `.gitconfig` - only use include pattern
- Or symlink, but don't also append include directives
- Pick one strategy, not both

---

### 2. Hardcoded assumption `~/dotfiles` location

**Location**: Multiple files

```bash
# .zshrc:10
DOTFILES="$HOME/dotfiles"

# functions.zsh:61
cd ~/dotfiles && git pull

# bootstrap.sh:199
echo "    path = ~/dotfiles/.gitconfig" >> ~/.gitconfig
```

**Problem**: User must clone to exactly `~/dotfiles` or shell config breaks silently.

**Impact**: Users who clone to different location get broken setup without clear error.

**Solution**:
- Derive dotfiles location from symlink target: `DOTFILES="$(dirname "$(readlink -f ~/.zshrc)")"`
- Or fail fast with clear error if `~/dotfiles` doesn't exist

---

### 3. Oh-My-Zsh plugin installation via git clone

**Location**: `/Users/sethwebster/dotfiles/install.sh:113-119`

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR/zsh-syntax-highlighting"
```

**Problem**:
- No version pinning (always clones HEAD)
- No way to update these plugins
- Homebrew alternative exists (`brew install zsh-autosuggestions`)

**Impact**: Plugin updates require manual `git pull` in each directory.

**Solution**: Use Homebrew versions: `brew install zsh-autosuggestions zsh-syntax-highlighting`

---

### 4. Missing error handling for external commands

**Location**: Multiple files

**Problem**: No error handling when external tools fail:

```bash
# bootstrap.sh:104 - what if brew update fails?
brew update

# bootstrap.sh:109 - no handling of partial bundle install
brew bundle --file="${DOTFILES_DIR}/Brewfile"

# auth-setup.sh:43 - no check if gh auth succeeds
gh auth login
log_success "GitHub authenticated"  # Logs success regardless
```

**Impact**: Script continues after failures, leaving system in inconsistent state.

**Solution**: Check exit codes explicitly or use `set -o pipefail`:
```bash
if ! brew update; then
    log_error "brew update failed"
    exit 1
fi
```

---

### 5. Alias shadowing core commands is dangerous

**Location**: `/Users/sethwebster/dotfiles/aliases.zsh:8`

```bash
alias cd='z'
```

**Problem**: Shadowing `cd` with `zoxide` breaks:
- Scripts that expect POSIX `cd` behavior
- `cd -` (go to previous directory) behavior differs
- Tab completion changes
- Error handling differs

**Impact**: Subtle breakage in scripts and unexpected behavior.

**Solution**: Use distinct alias like `j='z'` instead of shadowing `cd`.

---

## DRY Opportunities

### 1. Duplicate logging functions across scripts

**Location**:
- `/Users/sethwebster/dotfiles/bootstrap.sh:15-29`
- `/Users/sethwebster/dotfiles/install.sh:12-18`
- `/Users/sethwebster/dotfiles/auth-setup.sh:13-23`

**Problem**: Same color codes and log functions duplicated in every script.

**Solution**: Create `lib/logging.sh` and source it:
```bash
source "${DOTFILES_DIR}/lib/logging.sh"
```

---

### 2. Repeated homebrew architecture detection

**Location**:
- `/Users/sethwebster/dotfiles/bootstrap.sh:93-96`
- `/Users/sethwebster/dotfiles/path.zsh:4-8`

**Problem**: Same ARM64 vs Intel check in multiple places.

**Solution**: Single function in shared lib, or just use `brew shellenv` which handles this automatically.

---

### 3. Git config duplication

**Location**:
- Bootstrap script configures git
- auth-setup.sh also configures git

**Problem**: Two scripts can both prompt for and set git user config.

**Solution**: Single source of truth for git configuration.

---

## Maintenance Improvements

### 1. Missing `shellcheck` compliance

**Problem**: Scripts would fail `shellcheck` linting:
- Unquoted variables
- Missing `set -u`
- Using `[ ]` instead of `[[ ]]`
- Useless use of `echo`

**Solution**: Run `shellcheck *.sh` and fix all warnings. Add to CI.

---

### 2. No version pinning for anything

**Location**: Multiple files

**Problem**:
- Brewfile has no version constraints
- `.tool-versions` pins versions but asdf plugins aren't pinned
- curl scripts fetch HEAD
- Git clones fetch HEAD

**Impact**: Setup behavior changes unpredictably over time. "Worked last week" failures.

**Solution**:
- Consider `Brewfile.lock.json`
- Pin asdf plugin versions
- Pin curl script commits

---

### 3. `macos.sh` requires sudo without warning

**Location**: `/Users/sethwebster/dotfiles/macos.sh:17,80`

```bash
sudo nvram SystemAudioVolume=" "
sudo chflags nohidden /Volumes
```

**Problem**: Script uses `sudo` for some commands but doesn't check/cache credentials upfront.

**Impact**: User might walk away, script hangs on password prompt mid-execution.

**Solution**: Add `sudo -v` at start with clear message, or group sudo commands.

---

### 4. `.zshrc` fails on fresh system

**Location**: `/Users/sethwebster/dotfiles/.zshrc:16`

```bash
. $(brew --prefix asdf)/libexec/asdf.sh
```

**Problem**: On fresh system before bootstrap runs, Homebrew doesn't exist. This line errors without conditional check.

**Impact**: Terminal errors on every new shell until bootstrap completes.

**Solution**: Wrap in existence check:
```bash
if command -v brew &>/dev/null; then
    . "$(brew --prefix asdf)/libexec/asdf.sh"
fi
```

---

### 5. `killnamed` function is dangerous

**Location**: `/Users/sethwebster/dotfiles/functions.zsh:36-38`

```bash
killnamed() {
    ps aux | grep -v grep | grep -i "$1" | awk '{print $2}' | xargs kill -9
}
```

**Problem**:
- Uses `kill -9` (SIGKILL) which prevents graceful shutdown
- Pattern matching is greedy (`killnamed "a"` kills many processes)
- No confirmation before killing
- `xargs` with no `-r` flag may kill process 0 on empty input

**Impact**: Accidental process termination, data loss from ungraceful kills.

**Solution**:
- Use `pkill -i "$1"` instead (handles the grep/awk dance)
- Use SIGTERM first, SIGKILL as fallback
- Add confirmation prompt
- Use `xargs -r` to prevent empty input issues

---

## Nitpicks

### 1. Inconsistent shebang style

**Location**: All scripts

**Problem**: Mix of `#!/usr/bin/env bash` and `#!/bin/bash`. The env version is more portable.

**Solution**: Standardize on `#!/usr/bin/env bash`.

---

### 2. Emoji in shell output

**Location**: `/Users/sethwebster/dotfiles/bootstrap.sh:221`

```bash
log_success "All done! Enjoy your new Mac [emoji]"
```

**Problem**: Emoji rendering depends on terminal font support. Minor but can look broken.

---

### 3. Brewfile tap is deprecated

**Location**: `/Users/sethwebster/dotfiles/Brewfile:5`

```bash
tap "homebrew/cask-fonts"
```

**Problem**: `homebrew/cask-fonts` is deprecated. Fonts moved to `homebrew/cask`.

**Solution**: Remove this tap, just use `cask "font-fira-code"` directly.

---

### 4. README placeholder URL

**Location**: `/Users/sethwebster/dotfiles/README.md:18`

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
```

**Problem**: Placeholder URL suggests this isn't personalized.

---

### 5. Missing newline at end of some files

**Location**: Several files

**Problem**: POSIX compliance requires newline at EOF.

---

## Strengths

1. **Clear modular structure** - Separation of path, aliases, functions is clean
2. **Idempotency claims** - Scripts check for existing state before acting
3. **Backup before overwrite** - install.sh backs up existing files with timestamps
4. **Interactive prompts for destructive actions** - macOS defaults asks before applying
5. **Local override support** - `.zshrc.local` pattern for machine-specific config
6. **Comprehensive tooling** - Good selection of modern CLI tools (bat, eza, ripgrep, fzf, zoxide)
7. **asdf for version management** - Solid choice over nvm/pyenv fragmentation
8. **Mackup integration** - Smart approach to app settings sync
9. **Healthchecks on docker services** - docker-compose.yml includes proper healthchecks
10. **Git config sensible defaults** - Good choices like `fetch.prune`, `push.autoSetupRemote`

---

## Unresolved Questions

1. Why both `alfred` and `raycast` in Brewfile? Redundant launchers.
2. Node installed via both asdf AND brew formula? Conflict risk.
3. Python same - asdf AND `brew "python@3.12"`. Which takes precedence?
4. `gcm` function does `git add .` unconditionally - intentional footgun?
5. No SSH config template in mackup despite `ssh` in sync list?
6. `.claude/settings.local.json` exists but wasn't in files to symlink - oversight?

---

## Priority Matrix

| Issue | Severity | Effort | Priority |
|-------|----------|--------|----------|
| curl pipe to bash | Critical | Medium | P0 |
| Unquoted variables | Critical | Low | P0 |
| Missing `set -u` | High | Low | P1 |
| Docker hardcoded creds | High | Low | P1 |
| .gitconfig dual strategy | Medium | Medium | P2 |
| Hardcoded ~/dotfiles | Medium | Medium | P2 |
| `cd` alias shadowing | Medium | Low | P2 |
| DRY logging functions | Low | Medium | P3 |
| killnamed dangers | Medium | Low | P2 |
| .zshrc fresh system fail | Medium | Low | P2 |

---

## Recommendations

1. **Immediate**: Fix quoting issues and add `set -u` - low effort, high impact
2. **This week**: Address curl-pipe-to-bash security concern at minimum with warnings
3. **This week**: Choose one .gitconfig strategy (symlink XOR include, not both)
4. **Soon**: Extract shared functions to lib/
5. **Soon**: Add `shellcheck` to any CI/pre-commit hooks
6. **Eventually**: Consider version pinning strategy for reproducibility
