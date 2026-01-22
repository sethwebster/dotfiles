# Missing Apps Analysis - 2026-01-21

## Executive Summary

Bootstrap ran successfully but many apps weren't installed because **they're not in the Brewfile**. The README documents apps that don't exist in the actual Brewfile, creating a significant gap between documentation and reality.

---

## Root Cause

The Brewfile and README are **out of sync**. The README (lines 189-229) lists 40+ applications, but the actual Brewfile only contains ~20 casks. Many apps were either:
1. Never added to the Brewfile
2. Removed at some point without updating README
3. Intended to be added via `prepare-sync.sh` from another machine

---

## Apps NOT in Brewfile (Must Add)

### Confirmed Missing - Available via Homebrew

| App | Cask Name | Status |
|-----|-----------|--------|
| Adobe Creative Cloud | `adobe-creative-cloud` | **NOT IN BREWFILE** |
| Raycast | `raycast` | **NOT IN BREWFILE** |
| Slack | `slack` | **NOT IN BREWFILE** |
| Discord | `discord` | **NOT IN BREWFILE** |
| Zoom | `zoom` | **NOT IN BREWFILE** |
| Alfred | `alfred` | **NOT IN BREWFILE** |
| Obsidian | `obsidian` | **NOT IN BREWFILE** |
| Signal | `signal` | **NOT IN BREWFILE** |
| 1Password | `1password` | **NOT IN BREWFILE** |
| Rectangle | `rectangle` | **NOT IN BREWFILE** |
| CleanShot X | `cleanshot` | **NOT IN BREWFILE** |
| Dropbox | `dropbox` | **NOT IN BREWFILE** |
| Cyberduck | `cyberduck` | **NOT IN BREWFILE** |
| iStat Menus | `istat-menus` | **NOT IN BREWFILE** |
| DaisyDisk | `daisydisk` | **NOT IN BREWFILE** |
| Figma | `figma` | **NOT IN BREWFILE** |
| Blender | `blender` | **NOT IN BREWFILE** |
| Spotify | `spotify` | **NOT IN BREWFILE** |
| VLC | `vlc` | **NOT IN BREWFILE** |
| Expo Orbit | `expo-orbit` | **NOT IN BREWFILE** |
| pgAdmin 4 | `pgadmin4` | **NOT IN BREWFILE** |

---

## Apps ALREADY in Brewfile (Working)

These are confirmed present and should install:

| App | Cask Name | Line |
|-----|-----------|------|
| Arc | `arc` | 80 |
| Beeper | `beeper` | 81 |
| Brave Browser | `brave-browser` | 82 |
| ChatGPT | `chatgpt` | 83 |
| Claude | `claude` | 84 |
| Claude Code | `claude-code` | 85 |
| Cursor | `cursor` | 86 |
| Docker Desktop | `docker-desktop` | 87 |
| Firefox | `firefox` | 88 |
| Google Chrome | `google-chrome` | 92 |
| iTerm2 | `iterm2` | 93 |
| Multipass | `multipass` | 94 |
| ngrok | `ngrok` | 95 |
| Notion | `notion` | 96 |
| Postman | `postman` | 97 |
| VS Code | `visual-studio-code` | 98 |
| Warp | `warp` | 99 |

---

## Detection Logic Analysis (bootstrap.sh lines 263-324)

The detection logic is **correctly implemented** but irrelevant to your issue:

```bash
# Line 265-266: Extracts cask name from Brewfile lines
if [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
    cask_name="${BASH_REMATCH[1]}"
```

```bash
# Lines 269-311: Maps cask names to /Applications paths
case "$cask_name" in
    raycast) app_name="Raycast" ;;
    adobe-creative-cloud) app_name="Adobe Creative Cloud" ;;
    # ... etc
```

The issue: **These mappings exist for apps that aren't in the Brewfile.**

The detection logic includes mappings for:
- `raycast` (line 284)
- `adobe-creative-cloud` (not mapped, would need adding)
- `slack` (line 280)
- `discord` (line 281)
- etc.

But since these casks aren't in the Brewfile, the detection code never runs for them.

---

## Why This Happened

Looking at the repo structure:

1. **`prepare-sync.sh`** (mentioned in README line 117-125) is supposed to regenerate Brewfile from currently installed apps on an existing Mac
2. The Brewfile appears to be from a **minimal base state**, not from running `prepare-sync.sh` on a fully-configured machine
3. The README was written describing the **intended** state, not the actual Brewfile contents

---

## Fix: Add Missing Casks to Brewfile

Add these lines to `/Users/sethwebster/dotfiles/Brewfile` after line 99:

```ruby
# Communication
cask "slack"
cask "discord"
cask "signal"
cask "zoom"

# Productivity
cask "raycast"
cask "alfred"
cask "obsidian"
cask "1password"
cask "rectangle"

# Creative
cask "adobe-creative-cloud"
cask "figma"
cask "blender"

# Media
cask "spotify"
cask "vlc"

# Development
cask "expo-orbit"
cask "pgadmin4"

# Utilities
cask "cleanshot"
cask "dropbox"
cask "cyberduck"
cask "istat-menus"
cask "daisydisk"
```

---

## Apps That CANNOT Be Automated

### Requires Manual Installation

| App | Reason |
|-----|--------|
| TestFlight | macOS security restrictions (noted in Brewfile line 112) |
| Apple apps (Pages, Numbers, etc.) | Already handled via `mas` |

### Requires License/Login After Install

| App | Post-Install Action |
|-----|---------------------|
| Adobe Creative Cloud | Sign into Adobe account |
| 1Password | Sign into 1Password account |
| Dropbox | Sign into Dropbox account |
| iStat Menus | Enter license key |
| CleanShot X | Enter license key |
| DaisyDisk | Enter license key |

---

## Recommended Actions

### Immediate Fix

1. Add missing casks to Brewfile (see list above)
2. Update detection logic in bootstrap.sh to include `adobe-creative-cloud` mapping
3. Re-run `brew bundle --file=~/dotfiles/Brewfile` to install missing apps

### Long-Term Fix

1. Run `prepare-sync.sh` on your fully-configured Mac to capture actual state
2. Audit README against Brewfile contents
3. Consider splitting Brewfile into:
   - `Brewfile.base` (essentials)
   - `Brewfile.full` (everything)

---

## Quick Install Commands

Install the missing apps right now:

```bash
# Install all missing casks
brew install --cask \
  adobe-creative-cloud \
  raycast \
  slack \
  discord \
  zoom \
  alfred \
  obsidian \
  signal \
  1password \
  rectangle \
  cleanshot \
  dropbox \
  cyberduck \
  istat-menus \
  daisydisk \
  figma \
  blender \
  spotify \
  vlc \
  expo-orbit \
  pgadmin4
```

Or install individually:

```bash
brew install --cask adobe-creative-cloud
brew install --cask raycast
```

---

## Summary

| Category | Count |
|----------|-------|
| Apps in Brewfile | 17 casks |
| Apps missing from Brewfile | 21 casks |
| Apps in README but not Brewfile | 21 |
| Apps requiring manual install | 1 (TestFlight) |

**Root cause**: Brewfile doesn't match README documentation. Apps weren't skipped by detection logic - they were never listed in Brewfile to begin with.
