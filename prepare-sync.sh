#!/usr/bin/env bash
# Prepare current Mac for syncing to new Mac
# Captures current state: apps, settings, versions

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Get dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
log_info "========================================"
log_info "Prepare Mac for Sync (Sending Mode)"
log_info "========================================"
echo ""
log_info "This will capture your current Mac's state:"
echo "  - Installed Homebrew packages → Brewfile"
echo "  - App settings → iCloud (via Mackup)"
echo "  - Tool versions → .tool-versions"
echo "  - Git config → .gitconfig"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled"
    exit 0
fi

# Backup current Brewfile
if [ -f "${DOTFILES_DIR}/Brewfile" ]; then
    log_info "Backing up current Brewfile..."
    cp "${DOTFILES_DIR}/Brewfile" "${DOTFILES_DIR}/Brewfile.backup"
    log_success "Backup saved to Brewfile.backup"
fi

# Generate new Brewfile from current system
log_info "Generating Brewfile from currently installed packages..."
cd "${DOTFILES_DIR}"

# Create temporary Brewfile
TEMP_BREWFILE=$(mktemp)

# Generate from system
brew bundle dump --file="$TEMP_BREWFILE" --force

# Show diff if Brewfile exists
if [ -f "${DOTFILES_DIR}/Brewfile" ]; then
    echo ""

    # Check if files are different
    if cmp -s "${DOTFILES_DIR}/Brewfile" "$TEMP_BREWFILE"; then
        log_success "No changes to Brewfile"
        rm -f "$TEMP_BREWFILE"
    else
        log_info "Changes detected:"
        diff -u "${DOTFILES_DIR}/Brewfile" "$TEMP_BREWFILE" || true
        echo ""

        read -p "Update Brewfile with these changes? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$TEMP_BREWFILE" "${DOTFILES_DIR}/Brewfile"
            log_success "Brewfile updated"
        else
            rm -f "$TEMP_BREWFILE"
            log_info "Brewfile unchanged"
        fi
    fi
else
    # No existing Brewfile, just create it
    mv "$TEMP_BREWFILE" "${DOTFILES_DIR}/Brewfile"
    log_success "Brewfile created"
fi

# Update .tool-versions from current asdf versions
if command -v asdf &> /dev/null; then
    log_info "Updating .tool-versions from current asdf installations..."

    # Get current global versions
    if [ -f ~/.tool-versions ]; then
        if ! cmp -s ~/.tool-versions "${DOTFILES_DIR}/.tool-versions"; then
            cp ~/.tool-versions "${DOTFILES_DIR}/.tool-versions"
            log_success ".tool-versions updated"
        else
            log_success ".tool-versions already up to date"
        fi
    else
        log_warning "No ~/.tool-versions found, skipping"
    fi
fi

# Mackup backup
if command -v mackup &> /dev/null; then
    echo ""
    log_info "Running Mackup backup..."
    log_warning "This will sync app settings to iCloud"
    echo ""

    read -p "Run mackup backup? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mackup backup
        log_success "Mackup backup complete"
        log_info "Settings synced to iCloud: $(mackup list | wc -l | xargs) apps"
    else
        log_info "Skipped Mackup backup"
    fi
else
    log_warning "Mackup not installed, skipping app settings backup"
fi

# Git config check
echo ""
log_info "Checking Git configuration..."
if [ -f "${DOTFILES_DIR}/.gitconfig" ]; then
    log_success "Git config exists in dotfiles"

    # Show current user info
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        echo "  Current: $current_name <$current_email>"
    fi
else
    log_warning "No .gitconfig in dotfiles"
fi

# Check for uncommitted changes
echo ""
log_info "Checking for uncommitted dotfiles changes..."
cd "${DOTFILES_DIR}"

if ! git diff --quiet || ! git diff --cached --quiet; then
    log_warning "You have uncommitted changes in dotfiles:"
    echo ""
    git status --short
    echo ""

    read -p "Commit and push changes now? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        read -p "Commit message: " commit_msg

        if [ -z "$commit_msg" ]; then
            commit_msg="Update dotfiles from $(hostname)"
        fi

        git commit -m "$commit_msg"
        git push
        log_success "Changes committed and pushed"
    else
        log_warning "Remember to commit and push before syncing to new Mac"
    fi
else
    log_success "No uncommitted changes"
fi

# Summary
echo ""
log_info "========================================"
log_info "Sync Preparation Complete"
log_info "========================================"
echo ""
log_success "Your Mac is ready to be cloned!"
echo ""
log_info "Next steps:"
echo "  1. Wait for iCloud to sync (check System Settings)"
echo "  2. On new Mac, clone dotfiles repo"
echo "  3. Run ./bootstrap.sh on new Mac"
echo "  4. Run mackup restore on new Mac"
echo ""
log_info "Your settings will be automatically synced via:"
echo "  ✓ Brewfile (apps)"
echo "  ✓ .tool-versions (Node/Python versions)"
echo "  ✓ Mackup → iCloud (app settings)"
echo "  ✓ Git → GitHub (dotfiles repo)"
echo ""
