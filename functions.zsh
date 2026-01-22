# Custom functions

# mkcd - mkdir and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# extract - extract any archive type
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}

# Kill process by name (safer version)
killnamed() {
    if [ -z "$1" ]; then
        echo "Usage: killnamed <process-name>"
        return 1
    fi

    # Show matching processes
    echo "Matching processes:"
    pgrep -fil "$1"

    if [ $? -ne 0 ]; then
        echo "No processes found matching '$1'"
        return 1
    fi

    # Confirm before killing
    echo ""
    read -p "Kill these processes? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Try SIGTERM first (graceful)
        pkill -i "$1" && echo "Sent SIGTERM to processes"
        sleep 2

        # Check if any survived, then use SIGKILL
        if pgrep -fi "$1" >/dev/null; then
            echo "Some processes survived, sending SIGKILL..."
            pkill -9 -i "$1"
        fi
    else
        echo "Cancelled"
    fi
}

# Quick server for current directory
serve() {
    local port="${1:-8000}"
    open "http://localhost:${port}/"
    python3 -m http.server "$port"
}

# Git add all + commit with message
gac() {
    git add .
    git commit -m "$1"
}

# Create GitHub PR from current branch
ghpr() {
    gh pr create --fill
}

# Update dotfiles
dotfiles-update() {
    # Derive dotfiles location from .zshrc symlink
    if [ -L "${HOME}/.zshrc" ]; then
        DOTFILES_DIR="$(dirname "$(readlink "${HOME}/.zshrc")")"
    else
        DOTFILES_DIR="${HOME}/dotfiles"
    fi

    echo "Updating dotfiles..."
    (cd "$DOTFILES_DIR" && git pull && ./install.sh)
    echo "Updating Homebrew packages..."
    brew update && brew upgrade
    echo "Done!"
}

# Edit zsh profile and reload
edit-profile() {
    code ~/.zshrc --wait && source ~/.zshrc
}
