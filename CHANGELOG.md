# Changelog

## [2026-01-21] - Major Security & Architecture Update

### Added

- **Modular Zsh Configuration**
  - `path.zsh` - PATH modifications
  - `aliases.zsh` - Command shortcuts (30+ aliases)
  - `functions.zsh` - Utilities (mkcd, extract, serve, etc.)
  - `.zshrc` now loads these modules dynamically

- **Mackup Integration**
  - Added mackup to Brewfile
  - `.mackup.cfg` for syncing app settings via iCloud
  - Supports VS Code, iTerm2, SSH, and 500+ apps

- **Security Documentation**
  - `SECURITY.md` - Security practices and audit history
  - `CHANGELOG.md` - This file

- **Docker Environment Variables**
  - `.env.example` - Template for database credentials
  - `.env` - Local credentials (gitignored)

- **Useful Functions** (from old repo migration)
  - `edit-profile()` - Edit .zshrc and reload
  - Improved `killnamed()` - Safer process killing with confirmation

### Changed

#### Security Fixes (CRITICAL)

- **Added `set -euo pipefail` to all scripts**
  - Catches undefined variables
  - Exits on errors
  - Properly handles pipe failures

- **Fixed all unquoted variable expansions**
  - `$(brew --prefix asdf)` → `"$(brew --prefix asdf)"`
  - All variables properly quoted

- **Removed hardcoded Docker credentials**
  - Moved from docker-compose.yml to .env
  - Template provided in .env.example

#### Architecture Improvements

- **Eliminated hardcoded `~/dotfiles` paths**
  - Scripts derive location from .zshrc symlink
  - Works from any clone location
  - Fallback to ~/dotfiles if not symlinked

- **Fixed .gitconfig dual strategy**
  - Removed from symlink list
  - Use only include directive
  - Prevents config corruption

- **Changed `alias cd='z'` to `alias j='z'`**
  - Avoids shadowing core cd command
  - Prevents script breakage

- **Improved .zshrc for fresh systems**
  - Checks if brew exists before calling it
  - Graceful failure instead of errors

- **Added sudo upfront in macos.sh**
  - Requests credentials before running
  - Prevents mid-script password prompts
  - Only 2 legitimate sudo operations

- **Safer killnamed function**
  - Shows processes before killing
  - Requires confirmation
  - SIGTERM before SIGKILL

### Fixed

- Unquoted variables in bootstrap.sh, install.sh, auth-setup.sh
- Missing error handling for undefined variables
- Path issues when dotfiles cloned outside ~/dotfiles
- .zshrc failing on fresh systems before bootstrap
- Install.sh not properly quoting backup filenames
- Git config strategy conflicts

### Removed

- `.gitconfig` from symlink list (use include only)
- Hardcoded credentials from docker-compose.yml
- `cd` alias (replaced with `j`)

### Security Audit

- ✅ Sudo usage reviewed and approved
- ✅ No privilege escalation issues
- ✅ Homebrew runs as user
- ✅ All file operations in user space
- ✅ Shell script best practices applied

## [2026-01-20] - Initial Release

### Added

- Complete macOS bootstrap automation
- Brewfile with 40+ applications
- asdf version management
- Git configuration
- macOS defaults automation
- Docker Compose for PostgreSQL/Redis
- Comprehensive README documentation
- Interactive prompts for user info
- Idempotent scripts
- Authentication helper scripts
