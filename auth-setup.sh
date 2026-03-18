#!/usr/bin/env bash
# Authentication setup helper
# Guides you through authenticating various services

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

echo ""
log_info "Authentication Setup Helper"
log_info "=============================="
echo ""
log_warning "This script will guide you through authenticating various services."
log_warning "Some steps require manual intervention."
echo ""

# ==============================================================================
# 1. SSH KEY (first — needed for GitHub SSH auth)
# ==============================================================================
echo ""
log_info "SSH Key Setup"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    log_success "SSH key already exists"
    echo ""
    echo "Your public key:"
    cat ~/.ssh/id_ed25519.pub
    echo ""
else
    read -p "Generate new SSH key? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your email: " ssh_email
        ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""
        eval "$(ssh-agent -s)"
        ssh-add --apple-use-keychain ~/.ssh/id_ed25519
        log_success "SSH key generated"
        echo ""
        echo "Your public key:"
        cat ~/.ssh/id_ed25519.pub
        echo ""
    fi
fi

# ==============================================================================
# 2. GITHUB CLI (second — lets us upload SSH key right after)
# ==============================================================================
if command -v gh &> /dev/null; then
    echo ""
    log_info "GitHub CLI Authentication"
    if gh auth status &> /dev/null; then
        log_success "Already authenticated with GitHub"
    else
        read -p "Authenticate with GitHub? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
            log_success "GitHub authenticated"
        fi
    fi

    # Upload SSH key to GitHub if we have one and are authenticated
    if [ -f ~/.ssh/id_ed25519.pub ] && gh auth status &> /dev/null; then
        # Check if key is already on GitHub
        key_content=$(cat ~/.ssh/id_ed25519.pub | awk '{print $2}')
        if gh ssh-key list 2>/dev/null | grep -q "$key_content"; then
            log_success "SSH key already on GitHub"
        else
            read -p "Upload SSH key to GitHub? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                default_title="$(scutil --get ComputerName 2>/dev/null || hostname)"
                read -p "Key title [$default_title]: " key_title
                key_title="${key_title:-$default_title}"
                gh ssh-key add ~/.ssh/id_ed25519.pub --title "$key_title"
                log_success "SSH key uploaded to GitHub"
            fi
        fi
    fi
else
    log_warning "GitHub CLI not installed. Run bootstrap.sh first."
fi

# ==============================================================================
# 3. DOCKER
# ==============================================================================
if command -v docker &> /dev/null; then
    echo ""
    log_info "Docker"
    if ! docker info &> /dev/null; then
        log_warning "Docker Desktop is not running — start it, then re-run this script"
    else
        log_success "Docker is running"
        read -p "Log in to Docker Hub? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker login
            log_success "Docker Hub authenticated"
        fi
    fi
else
    log_warning "Docker not installed. Run bootstrap.sh first."
fi

# ==============================================================================
# 4. EXPO
# ==============================================================================
if command -v npx &> /dev/null; then
    echo ""
    log_info "Expo Authentication"
    read -p "Authenticate with Expo? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        npx expo login
        log_success "Expo authenticated"
    fi
else
    log_warning "Node/npx not available. Install Node first."
fi

# ==============================================================================
# Manual steps reminder
# ==============================================================================
echo ""
log_info "=============================="
log_info "Manual Steps Remaining"
log_info "=============================="
echo ""
log_warning "Please complete these manually:"
echo "  1. Sign into Apple ID (System Settings > Apple ID)"
echo "  2. Sign into Adobe Creative Cloud"
echo "  3. Sign into Tailscale"
echo "  4. Import browser bookmarks/settings"
echo ""
log_success "Authentication setup complete!"
echo ""
