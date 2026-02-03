#!/usr/bin/env bash
# Symlink dotfiles from dotfiles directory to home directory
# This script is idempotent - safe to run multiple times

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Files to symlink
files=(
    ".zshrc"
    ".tool-versions"
    ".mackup.cfg"
    ".nanorc"
    "path.zsh"
    "aliases.zsh"
    "functions.zsh"
    "check-updates.zsh"
)

# Create symlinks
for file in "${files[@]}"; do
    source="$DOTFILES_DIR/$file"
    target="$HOME_DIR/$file"

    if [ -f "$source" ]; then
        # Check if already correctly symlinked
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            log_success "$file already linked"
            continue
        fi

        # Backup existing file if it exists and is not a symlink
        if [ -f "$target" ] && [ ! -L "$target" ]; then
            backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$target" "$backup"
            log_warning "Backed up existing $file to $(basename "$backup")"
        fi

        # Remove existing symlink if it's wrong
        [ -L "$target" ] && rm "$target"

        # Create symlink
        ln -s "$source" "$target"
        log_success "Linked $file"
    fi
done

# Create .gitignore_global
if [ ! -f "$HOME_DIR/.gitignore_global" ]; then
    cat > "$HOME_DIR/.gitignore_global" << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Editors
.vscode/
.idea/
*.swp
*.swo
*~
.*.sw[a-z]

# Node
node_modules/
npm-debug.log*
.npm

# Env files
.env
.env.local
.env.*.local

# Logs
*.log

# Temporary
tmp/
temp/
EOF
    log_success "Created .gitignore_global"
else
    log_success ".gitignore_global already exists"
fi

# Oh-My-Zsh installation (optional)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ""
    read -p "Install Oh-My-Zsh? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh-My-Zsh installed"

        # Oh-My-Zsh overwrites ~/.zshrc - restore our symlink
        if [ -f "$HOME_DIR/.zshrc" ] && [ ! -L "$HOME_DIR/.zshrc" ]; then
            backup="$HOME_DIR/.zshrc.ohmyzsh.backup"
            mv "$HOME_DIR/.zshrc" "$backup"
            log_warning "Backed up Oh-My-Zsh .zshrc to .zshrc.ohmyzsh.backup"
        fi
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME_DIR/.zshrc"
        log_success "Restored .zshrc symlink"

        # Install popular plugins
        PLUGIN_DIR="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"
        if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
            log_success "Installed zsh-autosuggestions"
        fi
        if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR/zsh-syntax-highlighting"
            log_success "Installed zsh-syntax-highlighting"
        fi
    fi
else
    log_success "Oh-My-Zsh already installed"
fi

log_success "Dotfiles installation complete!"
