#!/usr/bin/env bash
# Seth's Mac Bootstrap Script
# Run this on a fresh Mac to set everything up
# This script is idempotent - safe to run multiple times

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}==>${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
log_info "========================================"
log_info "Mac Bootstrap Script"
log_info "========================================"
echo ""
log_info "Starting Mac bootstrap from ${DOTFILES_DIR}"
echo ""

# Check if we already have git config
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "${GIT_NAME}" ] || [ -z "${GIT_EMAIL}" ]; then
    # Only show collection message if we actually need info
    log_info "First, let's collect some information..."
    log_info "(Required for Git commits - stored in ~/.gitconfig)"
    echo ""
    log_warning "Git user information not configured"

    if [ -z "${GIT_NAME:-}" ]; then
        read -p "Enter your full name (for Git commits): " GIT_NAME
    else
        log_success "Using existing Git name: $GIT_NAME"
    fi

    if [ -z "${GIT_EMAIL:-}" ]; then
        read -p "Enter your email (for Git commits): " GIT_EMAIL
    else
        log_success "Using existing Git email: $GIT_EMAIL"
    fi

    echo ""
else
    log_success "Git already configured: $GIT_NAME <$GIT_EMAIL>"
    echo ""
fi

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is only for macOS"
    exit 1
fi

# Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo ""
    log_warning "MANUAL STEP REQUIRED:"
    log_warning "1. Complete the Xcode installation popup"
    log_warning "2. Wait for 'The software was installed' message"
    log_warning "3. Re-run this script: ./bootstrap.sh"
    echo ""
    log_info "Script will exit now. See you in ~5 minutes!"
    exit 0
else
    log_success "Xcode Command Line Tools installed"
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == 'arm64' ]]; then
        # Only add if not already present
        if ! grep -q "/opt/homebrew/bin/brew shellenv" ~/.zprofile 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    log_success "Homebrew installed"
else
    log_success "Homebrew already installed"
fi

# Update Homebrew
log_info "Updating Homebrew (this may take a minute)..."
brew update --quiet 2>&1 | grep -v "^Already up-to-date" || log_success "Homebrew updated"

# Install mas (Mac App Store CLI) first if not present
if ! command -v mas &> /dev/null; then
    log_info "Installing mas (Mac App Store CLI)..."
    brew install mas
    log_success "mas installed"
else
    log_success "mas already installed"
fi

# Verify App Store sign-in (mas account can be unreliable)
if ! mas account &> /dev/null; then
    log_warning "Cannot verify Mac App Store sign-in"
    echo ""
    log_info "Some apps require App Store authentication:"
    log_info "  - Things 3 (task manager)"
    log_info "  - Amphetamine (prevent sleep)"
    log_info "  - Bear, Fantastical, etc."
    echo ""
    log_info "To sign in: System Settings > Media & Purchases > Sign In"
    echo ""
    read -p "Are you signed into the App Store? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "App Store apps will be skipped (install manually later)"
        log_info "You can re-run bootstrap after signing in to retry"
    else
        log_success "Proceeding with App Store apps"
    fi
    echo ""
fi

# Install from Brewfile
if [ -f "${DOTFILES_DIR}/Brewfile" ]; then
    log_info "Checking which apps are already installed..."

    # Create temporary filtered Brewfile excluding manually-installed casks
    TEMP_BREWFILE=$(mktemp)

    # Copy Brewfile, filtering out casks where app already exists
    while IFS= read -r line; do
        # Check if line is a cask declaration
        if [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
            cask_name="${BASH_REMATCH[1]}"

            # Map cask name to app name (what appears in /Applications)
            case "$cask_name" in
                docker) app_name="Docker" ;;
                cursor) app_name="Cursor" ;;
                visual-studio-code) app_name="Visual Studio Code" ;;
                google-chrome) app_name="Google Chrome" ;;
                arc) app_name="Arc" ;;
                firefox) app_name="Firefox" ;;
                brave-browser) app_name="Brave Browser" ;;
                claude-code) app_name="Claude Code" ;;
                claude) app_name="Claude" ;;
                chatgpt) app_name="ChatGPT" ;;
                slack) app_name="Slack" ;;
                discord) app_name="Discord" ;;
                notion) app_name="Notion" ;;
                zoom) app_name="zoom.us" ;;
                raycast) app_name="Raycast" ;;
                alfred) app_name="Alfred 5" ;;
                obsidian) app_name="Obsidian" ;;
                bear) app_name="Bear" ;;
                fantastical) app_name="Fantastical" ;;
                signal) app_name="Signal" ;;
                whatsapp) app_name="WhatsApp" ;;
                beeper) app_name="Beeper Desktop" ;;
                1password) app_name="1Password" ;;
                rectangle) app_name="Rectangle" ;;
                multipass) app_name="Multipass" ;;
                cleanshot) app_name="CleanShot X" ;;
                ngrok) app_name="ngrok" ;;
                the-unarchiver) app_name="The Unarchiver" ;;
                dropbox) app_name="Dropbox" ;;
                cyberduck) app_name="Cyberduck" ;;
                istat-menus) app_name="iStat Menus" ;;
                daisydisk) app_name="DaisyDisk" ;;
                figma) app_name="Figma" ;;
                blender) app_name="Blender" ;;
                spotify) app_name="Spotify" ;;
                vlc) app_name="VLC" ;;
                iterm2) app_name="iTerm" ;;
                warp) app_name="Warp" ;;
                postman) app_name="Postman" ;;
                pgadmin4) app_name="pgAdmin 4" ;;
                expo-orbit) app_name="Expo Orbit" ;;
                *) app_name="" ;;
            esac

            # Check if app already exists in /Applications
            if [ -n "$app_name" ]; then
                if [ -d "/Applications/${app_name}.app" ]; then
                    log_warning "Skipping $cask_name (already installed)"
                    echo "# Skipped: $line" >> "$TEMP_BREWFILE"
                    continue
                fi
            fi
        fi
        echo "$line" >> "$TEMP_BREWFILE"
    done < "${DOTFILES_DIR}/Brewfile"

    # Count total items to install
    total_items=$(grep -E '^(brew|cask|mas|vscode)' "$TEMP_BREWFILE" | wc -l | xargs)

    log_info "Installing apps and tools from Brewfile"
    log_info "Queued: $total_items packages/apps to install"
    log_warning "This typically takes 5-10 minutes depending on what's new..."
    log_info "Progress will appear below (Homebrew shows each item)"
    log_warning "Large apps (Docker, Xcode, Chrome) may pause 1-2 minutes - this is normal"
    log_info "You may be prompted for your password once..."
    echo ""

    # Refresh sudo timestamp to avoid multiple password prompts
    sudo -v

    # Keep sudo alive in background during long install
    log_info "Starting background sudo keepalive (prevents repeated password prompts)"
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
    SUDO_KEEPALIVE_PID=$!

    echo ""
    log_info "Starting Homebrew installations (verbose mode - you'll see everything)..."
    log_warning "Initial phase: Homebrew may check package info for 1-2 minutes before installations start"
    echo ""

    # Use --no-upgrade to skip already-installed apps, --verbose to show progress immediately
    brew bundle --file="$TEMP_BREWFILE" --no-upgrade --verbose

    echo ""

    # Kill sudo keepalive
    log_info "Stopping sudo keepalive"
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true

    # Clean up
    rm -f "$TEMP_BREWFILE"

    echo ""
    log_success "Brewfile installed"
else
    log_warning "Brewfile not found, skipping..."
fi

# Check for existing version managers
EXISTING_VERSION_MANAGERS=""
command -v nvm &>/dev/null && EXISTING_VERSION_MANAGERS="${EXISTING_VERSION_MANAGERS}nvm "
command -v pyenv &>/dev/null && EXISTING_VERSION_MANAGERS="${EXISTING_VERSION_MANAGERS}pyenv "
command -v rbenv &>/dev/null && EXISTING_VERSION_MANAGERS="${EXISTING_VERSION_MANAGERS}rbenv "

if [ -n "$EXISTING_VERSION_MANAGERS" ]; then
    log_warning "Found existing version managers: ${EXISTING_VERSION_MANAGERS}"
    log_warning "These may conflict with asdf. Consider migrating or skipping asdf installation."
    echo ""
    read -p "Install asdf anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping asdf installation"
    else
        if ! command -v asdf &> /dev/null; then
            log_info "Installing asdf..."
            brew install asdf
            # Note: asdf sourcing handled in path.zsh, no need to modify ~/.zshrc
            log_success "asdf installed"
        else
            log_success "asdf already installed"
        fi
    fi
else
    # Install asdf if not present and no conflicts
    if ! command -v asdf &> /dev/null; then
        log_info "Installing asdf..."
        brew install asdf
        # Note: asdf sourcing handled in path.zsh, no need to modify ~/.zshrc
        log_success "asdf installed"
    else
        log_success "asdf already installed"
    fi
fi

# Symlink dotfiles
log_info "Symlinking dotfiles..."
bash "${DOTFILES_DIR}/install.sh"

# Install asdf plugins and versions
if [ -f "${DOTFILES_DIR}/.tool-versions" ]; then
    log_info "Installing asdf tools from .tool-versions..."
    log_warning "Each tool may take 2-5 minutes to compile (especially Python/Ruby)"
    echo ""

    log_info "Tools to install:"
    # Read plugins from .tool-versions
    while IFS= read -r line; do
        if [[ ! -z "$line" && ! "$line" =~ ^# ]]; then
            plugin=$(echo "$line" | awk '{print $1}')
            version=$(echo "$line" | awk '{print $2}')

            # Add plugin if not exists
            if ! asdf plugin list | grep -q "^${plugin}$"; then
                log_info "  Adding plugin: ${plugin}"
                asdf plugin add "$plugin"
            fi

            # Check if already installed
            if asdf list "$plugin" 2>/dev/null | grep -q "$version"; then
                log_success "  $plugin $version (already installed)"
            else
                log_info "  $plugin $version (will install)"
            fi
        fi
    done < "${DOTFILES_DIR}/.tool-versions"

    echo ""
    log_info "Starting installations (this may take 5-15 minutes total)..."
    echo ""

    # Install all versions
    cd "${DOTFILES_DIR}"
    asdf install

    echo ""
    log_success "All asdf tools installed"
fi

# Set up Bun (if not via asdf)
if ! command -v bun &> /dev/null; then
    log_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    log_success "Bun installed"
else
    log_success "Bun already installed"
fi

# Configure macOS defaults
if [ -f "${DOTFILES_DIR}/macos.sh" ]; then
    if [ -f ~/.macos-defaults-applied ]; then
        log_success "macOS defaults already applied"
        log_info "(Delete ~/.macos-defaults-applied to re-apply)"
    else
        echo ""
        log_warning "macOS System Defaults Configuration"
        log_info "This will change:"
        log_info "  ✓ Finder: show hidden files, extensions, path bar"
        log_info "  ✓ Dock: auto-hide, faster animations, smaller icons"
        log_info "  ✓ Screenshots: save to ~/Screenshots as PNG"
        log_info "  ✓ Keyboard: faster key repeat, disable autocorrect"
        log_info "  ✓ Trackpad: tap to click enabled"
        echo ""
        log_warning "Some changes require restart to take effect"
        echo ""
        read -p "Apply macOS defaults? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            bash "${DOTFILES_DIR}/macos.sh"
            touch ~/.macos-defaults-applied
            log_success "macOS defaults configured"
        else
            log_info "Skipped macOS defaults configuration"
        fi
    fi
fi

# Setup Git
log_info "Configuring Git..."

# Set user name and email
if [ -n "${GIT_NAME:-}" ]; then
    git config --global user.name "$GIT_NAME"
fi
if [ -n "${GIT_EMAIL:-}" ]; then
    git config --global user.email "$GIT_EMAIL"
fi

# Include dotfiles gitconfig (do not symlink, use include directive)
if [ -f "${DOTFILES_DIR}/.gitconfig" ]; then
    if [ ! -f ~/.gitconfig ] || ! grep -q "path = ${DOTFILES_DIR}/.gitconfig" ~/.gitconfig; then
        # Preserve any existing config by appending include
        if [ -f ~/.gitconfig ]; then
            echo "" >> ~/.gitconfig
        fi
        echo "[include]" >> ~/.gitconfig
        echo "    path = ${DOTFILES_DIR}/.gitconfig" >> ~/.gitconfig
        log_success "Git configured to include ${DOTFILES_DIR}/.gitconfig"
    else
        log_success "Git already includes dotfiles/.gitconfig"
    fi
fi

# Post-install authentication setup
log_info "========================================"
log_info "Bootstrap complete! Next steps:"
log_info "========================================"
echo ""
log_warning "Manual authentication required:"
echo "  1. gh auth login"
echo "  2. npx expo login"
echo "  3. Sign into Apple ID in System Settings"
echo "  4. Sign into Creative Cloud"
echo "  5. Wait for iCloud to sync, then run: mackup restore"
echo "  6. Restart your terminal or run: source ~/.zshrc"
echo ""
log_success "All done! Enjoy your new Mac 🎉"
echo ""

# Offer to run auth-setup
if [ -f "${DOTFILES_DIR}/auth-setup.sh" ]; then
    read -p "Run guided authentication setup now? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "${DOTFILES_DIR}/auth-setup.sh"
    else
        log_info "You can run authentication setup later with: ./auth-setup.sh"
    fi
fi
