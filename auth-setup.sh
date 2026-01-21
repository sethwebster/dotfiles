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

# GitHub CLI
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
else
    log_warning "GitHub CLI not installed. Run bootstrap.sh first."
fi

# Expo
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

# Docker
if command -v docker &> /dev/null; then
    echo ""
    log_info "Docker Authentication"
    if docker info &> /dev/null; then
        log_success "Docker is running"
    else
        log_warning "Docker is not running. Start Docker Desktop manually."
    fi
else
    log_warning "Docker not installed. Run bootstrap.sh first."
fi

# SSH Key Generation
echo ""
log_info "SSH Key Setup"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    log_success "SSH key already exists"
    echo ""
    echo "Your public key:"
    cat ~/.ssh/id_ed25519.pub
    echo ""

    # Offer to upload existing key to GitHub
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        read -p "Upload SSH key to GitHub? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter title for this key (e.g., 'MacBook Pro'): " key_title
            gh ssh-key add ~/.ssh/id_ed25519.pub --title "$key_title"
            log_success "SSH key uploaded to GitHub"
        fi
    else
        log_info "Add this to GitHub manually: https://github.com/settings/keys"
    fi
else
    read -p "Generate new SSH key? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your email: " email
        ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        log_success "SSH key generated"
        echo ""
        echo "Your public key:"
        cat ~/.ssh/id_ed25519.pub
        echo ""

        # Auto-upload to GitHub if authenticated
        if command -v gh &> /dev/null && gh auth status &> /dev/null; then
            read -p "Upload SSH key to GitHub? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                read -p "Enter title for this key (e.g., 'MacBook Pro'): " key_title
                gh ssh-key add ~/.ssh/id_ed25519.pub --title "$key_title"
                log_success "SSH key uploaded to GitHub"
            fi
        else
            log_info "Add this to GitHub manually: https://github.com/settings/keys"
        fi
    fi
fi

# Git config
echo ""
log_info "Git Configuration"
current_name=$(git config --global user.name 2>/dev/null || echo "")
current_email=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "$current_name" ] || [ -z "$current_email" ]; then
    log_warning "Git user not configured"
    read -p "Enter your full name: " name
    read -p "Enter your email: " email
    git config --global user.name "$name"
    git config --global user.email "$email"
    log_success "Git configured"
else
    log_success "Git already configured as: $current_name <$current_email>"
fi

# Manual steps reminder
echo ""
log_info "=============================="
log_info "Manual Steps Remaining"
log_info "=============================="
echo ""
log_warning "Please complete these manually:"
echo "  1. Sign into Apple ID (System Settings > Apple ID)"
echo "  2. Sign into Adobe Creative Cloud"
echo "  3. Configure any app-specific settings"
echo "  4. Import browser bookmarks/settings"
echo ""
log_success "Authentication setup complete!"
echo ""
