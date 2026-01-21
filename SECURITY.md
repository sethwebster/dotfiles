# Security Improvements

This document tracks security fixes and best practices implemented in this dotfiles repository.

## Recent Security Fixes (2026-01-21)

### Critical Fixes

1. **Added `set -euo pipefail` to all scripts**
   - `set -e`: Exit on error
   - `set -u`: Error on undefined variables
   - `set -o pipefail`: Catch errors in pipes
   - Prevents undefined variable expansion and silent failures

2. **Fixed unquoted variable expansions**
   - All `$(brew --prefix ...)` properly quoted
   - Prevents path injection and handles spaces correctly
   - All variable references use `"${VAR}"` or `"${VAR:-default}"`

3. **Removed hardcoded Docker credentials**
   - Moved to `.env` file (excluded from git)
   - `.env.example` provided as template
   - Users customize their own credentials

4. **Fixed .gitconfig dual-strategy conflict**
   - Removed symlink approach
   - Use only include directive: `[include] path = ...`
   - Prevents config corruption on re-runs

### Architecture Improvements

5. **Eliminated hardcoded paths**
   - Scripts derive dotfiles location from symlinks
   - Works regardless of clone location
   - Fallback to `~/dotfiles` if not symlinked

6. **Changed `alias cd='z'` to `alias j='z'`**
   - Avoids shadowing core `cd` command
   - Prevents script breakage
   - Use `j` for zoxide smart directory jumping

7. **Improved `killnamed` function safety**
   - Shows processes before killing
   - Requires confirmation
   - Tries SIGTERM before SIGKILL
   - Prevents accidental data loss

8. **Added sudo upfront request to macos.sh**
   - Caches credentials before script runs
   - Prevents mid-script password prompts
   - Sudo only used for legitimate system changes:
     - `nvram` (firmware)
     - `/Volumes` (system directory)

## Known Security Considerations

### curl | bash Pattern

**Status**: Present in 3 locations
**Risk**: MITM attacks, transient network issues
**Locations**:
- Homebrew installer
- Bun installer
- Oh-My-Zsh installer

**Mitigation**:
- These are official install scripts from trusted sources
- Uses HTTPS with certificate validation
- Common pattern in macOS ecosystem
- User should inspect URLs before running bootstrap

**Future**: Consider checksums or commit pinning

### Sudo Usage

**Audit**: Passed security review
**Details**: Only 2 sudo commands in macos.sh:
- `sudo nvram` - Legitimate (firmware access)
- `sudo chflags nohidden /Volumes` - Legitimate (system directory)

All Homebrew, file operations, and user configs run without sudo.

## Best Practices

1. **Secrets Management**
   - Never commit API tokens or passwords
   - Use `.env` files excluded from git
   - `.gitignore` includes: `*.key`, `*.pem`, `*.cert`, `.env`

2. **Script Hardening**
   - Always use `set -euo pipefail`
   - Quote all variable expansions
   - Check command existence before use
   - Validate user input

3. **Idempotency**
   - Check before creating/overwriting
   - Backup files before modification
   - Skip if already configured
   - Support multiple runs safely

4. **User Awareness**
   - Prompt before destructive actions
   - Clear messages about what's happening
   - Document sudo requirements
   - Warn about security implications

## Security Review History

| Date | Type | Status |
|------|------|--------|
| 2026-01-21 | Full code review (neckbeard agent) | PASS |
| 2026-01-21 | Sudo usage audit | PASS |
| 2026-01-21 | Shell script hardening | COMPLETE |

## Reporting Security Issues

Found a security issue? Please:
1. Do NOT open a public issue
2. Email security details privately
3. Allow reasonable time for fix before disclosure
