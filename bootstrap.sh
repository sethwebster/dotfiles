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

# Collect required information upfront
log_info "First, let's collect some information..."
echo ""

# Check if we already have git config
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "${GIT_NAME}" ] || [ -z "${GIT_EMAIL}" ]; then
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
    log_warning "Please complete the Xcode installation and re-run this script"
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
    log_warning "Cannot verify Mac App Store sign-in status"
    log_warning "If you see 'mas' errors below, sign in via:"
    log_warning "  System Settings > Media & Purchases > Sign In"
    echo ""
    read -p "Are you signed into the App Store? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "App Store apps (Things 3, Amphetamine) will be skipped"
    fi
fi

# Install from Brewfile
if [ -f "${DOTFILES_DIR}/Brewfile" ]; then
    log_info "Installing apps and tools from Brewfile (this may take several minutes)..."
    log_info "Homebrew will show progress for each app..."
    echo ""
    brew bundle --file="${DOTFILES_DIR}/Brewfile"
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

    # Read plugins from .tool-versions
    while IFS= read -r line; do
        if [[ ! -z "$line" && ! "$line" =~ ^# ]]; then
            plugin=$(echo "$line" | awk '{print $1}')

            # Add plugin if not exists
            if ! asdf plugin list | grep -q "^${plugin}$"; then
                log_info "Adding asdf plugin: ${plugin}"
                asdf plugin add "$plugin"
            fi
        fi
    done < "${DOTFILES_DIR}/.tool-versions"

    # Install all versions
    cd "${DOTFILES_DIR}"
    asdf install
    log_success "asdf tools installed"
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
        log_success "macOS defaults already applied (delete ~/.macos-defaults-applied to re-run)"
    else
        log_warning "About to configure macOS system defaults (Finder, Dock, etc.)"
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
echo "  1. Run: gh auth login"
echo "  2. Run: npx expo login"
echo "  3. Sign into Apple ID in System Settings"
echo "  4. Sign into Creative Cloud"
echo "  5. Wait for iCloud to sync, then run: mackup restore"
echo "  6. Restart your terminal or run: source ~/.zshrc"
echo ""
log_info "Run './auth-setup.sh' for guided authentication"
echo ""
log_success "All done! Enjoy your new Mac 🎉"
