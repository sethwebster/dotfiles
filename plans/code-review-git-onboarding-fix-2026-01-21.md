# Code Review: Git Onboarding Fix

**Date:** 2026-01-21
**File:** `/Users/sethwebster/dotfiles/bootstrap.sh`
**Issue:** User repeatedly prompted for git name/email; ~/.gitconfig never created

---

## Root Cause Analysis

### The Bug

The git configuration was being written at **lines 395-447** (end of script), but `set -euo pipefail` (line 6) causes immediate script termination on any command failure. Multiple commands between collecting git info and writing it could fail:

1. `brew bundle` (line 259) - network issues, mas auth failures, cask conflicts
2. `asdf plugin add` (line 333) - network issues
3. `asdf install` (line 351) - compilation failures, missing dependencies

When ANY of these failed, the script exited before reaching the git config write section.

### Scenario 1: First Run (No Xcode)

```
Line 43-44: git config fails silently (git binary doesn't exist)
Line 54-77: User prompted for name/email
Line 96:    Script EXITS to wait for Xcode installation
            --> Variables GIT_NAME/GIT_EMAIL are LOST
```

### Scenario 2: Second Run (Xcode Installed)

```
Line 43-44: git config returns empty (no ~/.gitconfig exists)
Line 54-77: User prompted AGAIN
...
Line 259:   brew bundle FAILS (mas auth, network, etc)
            --> set -e triggers immediate exit
            --> Lines 395-447 NEVER EXECUTE
            --> ~/.gitconfig NEVER CREATED
```

### Why Previous Fixes Failed

The "fallback" at lines 424-432 was dead code - if the script failed before line 395, it would never reach line 424 either. Same failure path.

---

## The Fix

### Strategy: Write Config Immediately After Collection

Moved git config write to happen **immediately** after collecting user input, BEFORE any potentially failing commands (brew, asdf, etc).

### Changes Made

#### 1. Early Git Config Block (Lines 42-139)

- Check if git binary available (`command -v git`)
- Collect user input if needed
- **Write config IMMEDIATELY** while we have the values
- Add include directive for dotfiles/.gitconfig

#### 2. Post-Xcode Fallback (Lines 169-199)

Handles edge case where git wasn't available on first pass:
- After Xcode confirmed installed, check if we collected values but couldn't write
- Write config now that git is available

#### 3. End-of-Script Verification (Lines 489-504)

Replaced the redundant write logic with a simple verification that confirms config was written correctly. Provides clear error message if something went wrong.

---

## Testing Performed

### Test 1: Fresh State (No ~/.gitconfig)

```bash
rm -f ~/.gitconfig
# Simulated new config write
# Result: ~/.gitconfig created with user.name, user.email, and include directive
```

### Test 2: Idempotency (Config Already Exists)

```bash
# Re-run with existing config
# Result: "Git already configured" - NO prompt shown
```

### Test 3: Syntax Validation

```bash
bash -n /Users/sethwebster/dotfiles/bootstrap.sh
# Result: Syntax OK
```

---

## Edge Cases Handled

| Scenario | Behavior |
|----------|----------|
| Fresh Mac, no Xcode | Collect info, exit for Xcode, write on re-run |
| Git available, no config | Write immediately after collection |
| Git available, config exists | Skip prompt, verify config |
| brew/asdf fails mid-script | Config already written - survives failure |
| Permission issues with ~ | `touch ~/.gitconfig` will fail visibly |

---

## Files Changed

- `/Users/sethwebster/dotfiles/bootstrap.sh`
  - Lines 42-139: New early git config block
  - Lines 169-199: Post-Xcode fallback
  - Lines 489-504: Verification (replaces old redundant write logic)

---

## Verification Commands

After running bootstrap on a fresh Mac:

```bash
# Verify file exists
ls -la ~/.gitconfig

# Verify contents
cat ~/.gitconfig

# Verify git can read values
git config --global user.name
git config --global user.email
```

---

## Summary

**Problem:** Git config written at end of script; `set -e` + any mid-script failure = config never written.

**Solution:** Write git config IMMEDIATELY after collecting values, not at end of script.

**Result:** Config persists even if brew/asdf/other commands fail later.
