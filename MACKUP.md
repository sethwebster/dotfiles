# Mackup Guide - Application Settings Sync

Mackup keeps your application settings in sync across multiple Macs via cloud storage (iCloud, Dropbox, etc.).

## What Mackup Does

**Backs up settings for 500+ apps:**
- VS Code (extensions, settings, keybindings)
- iTerm2 (profiles, colors, preferences)
- SSH (config, known_hosts)
- Git (global config)
- Sublime Text, Atom, and other editors
- Terminal apps (zsh, bash, vim, tmux)
- Many macOS apps (Slack, Notion, etc.)

**How it works:**
1. Moves app config files to cloud storage (e.g., `~/Library/Mobile Documents/com~apple~CloudDocs/Mackup/`)
2. Creates symlinks from original location to cloud storage
3. Cloud storage syncs to other Macs
4. Other Macs restore symlinks, instantly getting your settings

## Configuration

Your config is already set in `.mackup.cfg`:

```ini
[storage]
engine = icloud
directory = Mackup

[applications_to_sync]
vscode
iterm2
ssh
slack
notion
obsidian
google-chrome
arc
raycast
rectangle
```

### Change Storage Location

Edit `~/.mackup.cfg`:

```ini
# Use iCloud (default)
[storage]
engine = icloud

# Or use Dropbox
[storage]
engine = dropbox

# Or use Google Drive
[storage]
engine = google_drive

# Or custom path
[storage]
engine = file_system
path = /Users/you/Dropbox
directory = Mackup
```

## First Time Setup (Current Mac)

### Step 1: Check what will be backed up

```bash
mackup list
```

This shows all apps mackup knows about.

### Step 2: Backup your settings

```bash
mackup backup
```

This will:
- Find all supported app configs
- Move them to cloud storage
- Create symlinks in original locations
- Show you what was backed up

**Example output:**
```
Backing up VS Code...
Backing up iTerm2...
Backing up SSH...
✓ Backup done
```

### Step 3: Verify backup

```bash
ls -la ~/.ssh/config
# Should show: .ssh/config -> ~/Library/Mobile Documents/.../Mackup/ssh/config
```

The arrow `->` means it's now a symlink to cloud storage!

### Step 4: Wait for cloud sync

- **iCloud**: Check System Settings → iCloud → iCloud Drive → Manage → Mackup folder appears
- **Dropbox**: Check Dropbox app, wait for sync to complete

## On a New Mac

### Step 1: Install dotfiles first

```bash
git clone https://github.com/sethwebster/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

### Step 2: Wait for cloud storage to sync

- Open Finder → iCloud Drive (or Dropbox)
- Wait for `Mackup` folder to appear
- May take 5-30 minutes depending on connection

### Step 3: Restore settings

```bash
mackup restore
```

This will:
- Find backed up configs in cloud storage
- Create symlinks on new Mac
- Instantly apply all your settings

**Example output:**
```
Restoring VS Code...
Restoring iTerm2...
Restoring SSH...
✓ Restore done. Please restart affected apps.
```

### Step 4: Restart apps

Close and reopen VS Code, iTerm2, etc. Your settings are now active!

## Common Commands

### Backup (first Mac)
```bash
mackup backup
```

### Restore (new Mac)
```bash
mackup restore
```

### Uninstall (remove symlinks, restore files locally)
```bash
mackup uninstall
```

### List supported applications
```bash
mackup list
```

### Dry run (see what would happen)
```bash
mackup backup --dry-run
mackup restore --dry-run
```

## Workflow

### On Primary Mac (where you make changes)

```bash
# 1. Install apps and configure them
# 2. Backup to cloud
mackup backup

# That's it! Changes sync automatically via cloud storage
```

### On Secondary Mac

```bash
# 1. Install apps via dotfiles bootstrap
./bootstrap.sh

# 2. Wait for cloud sync
# 3. Restore settings
mackup restore

# 4. Restart apps to see changes
```

### Making Changes Later

Once backed up, changes are **automatic**:
- You change VS Code settings on Mac A
- Settings file is actually in iCloud (via symlink)
- iCloud syncs to Mac B
- Mac B's VS Code sees changes instantly (via its symlink)

**No need to run `mackup backup` again!**

## What Gets Synced

### Development Tools
- VS Code: Settings, extensions list, keybindings, snippets
- Git: Global config, ignore patterns
- SSH: Config, known_hosts (private keys NOT synced - good!)

### Terminal
- iTerm2: Complete profiles, colors, fonts, preferences
- Zsh/Bash: NOT synced (handled by dotfiles instead)

### Apps
- Slack: Preferences
- Notion: Settings
- Raycast: Hotkeys, extensions, preferences
- Rectangle: Window shortcuts

### Browsers
- Chrome: Bookmarks, extensions (if configured)
- Arc: Settings

## Troubleshooting

### "Conflict" error during restore

If mackup says files exist:

```bash
# Option 1: Backup existing files first
mv ~/.ssh/config ~/.ssh/config.local

# Then restore
mackup restore

# Option 2: Force overwrite (careful!)
mackup restore --force
```

### File not syncing

Check if symlink is correct:

```bash
ls -la ~/.config/Code/User/settings.json
# Should show: -> /path/to/iCloud/Mackup/vscode/...
```

If it's a regular file (not symlink), re-run:

```bash
mackup uninstall
mackup backup
```

### Symlinks broken after reinstalling macOS

Re-run restore:

```bash
mackup restore
```

### Want to stop syncing an app

Edit `.mackup.cfg`:

```ini
[applications_to_ignore]
vscode  # Stop syncing VS Code
```

Then:

```bash
mackup uninstall  # Removes ALL symlinks
mackup backup     # Re-creates symlinks except ignored apps
```

## Security Notes

**What Mackup syncs:**
- ✅ App preferences and settings
- ✅ SSH config files
- ✅ Git config

**What Mackup does NOT sync:**
- ❌ SSH private keys (only config)
- ❌ Passwords (use 1Password instead)
- ❌ API tokens (those stay in `.env` files)
- ❌ Browser passwords (use built-in sync)

**Cloud storage security:**
- iCloud: End-to-end encrypted
- Dropbox: Encrypted in transit, not at rest
- Google Drive: Encrypted in transit, not at rest

Don't put sensitive credentials in app configs!

## Advanced Usage

### Sync custom app

Create `~/.mackup/custom-app.cfg`:

```ini
[application]
name = My Custom App

[configuration_files]
.myapprc
.config/myapp/config.json
```

### Multiple Macs with different settings

Use machine-specific overrides:

```ini
# .mackup.cfg - shared config
[storage]
engine = icloud

# .mackup.local.cfg - machine-specific (not synced)
[applications_to_ignore]
iterm2  # Don't sync iTerm on this Mac
```

## Quick Reference

```bash
# First time (Mac A)
brew install mackup
mackup backup

# New Mac (Mac B)
brew install mackup
mackup restore

# Check status
mackup list

# Undo everything
mackup uninstall
```

## Integration with Dotfiles

This dotfiles repo already includes:
- ✅ Mackup in Brewfile (auto-installed)
- ✅ `.mackup.cfg` pre-configured
- ✅ Bootstrap script mentions mackup restore

After running `./bootstrap.sh`, just run:

```bash
# First Mac
mackup backup

# Other Macs
mackup restore
```

## Next Steps

1. **First Mac**: Run `mackup backup` right now
2. **Wait**: Let iCloud sync (check Finder → iCloud Drive → Mackup)
3. **Test**: Try `mackup restore` on another Mac (or VM)
4. **Verify**: Check if settings appear on other Mac

Your app settings will now sync forever! 🎉
