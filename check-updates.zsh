# Automatic dotfiles update checker
# Checks for updates on shell startup (max once per day)

# Skip if disabled by user
[ -n "$DOTFILES_SKIP_UPDATE_CHECK" ] && return

# Only run in interactive shells
[[ $- != *i* ]] && return

# Derive dotfiles location
if [ -L "${HOME}/.zshrc" ]; then
    DOTFILES_DIR="$(dirname "$(readlink "${HOME}/.zshrc")")"
else
    DOTFILES_DIR="${HOME}/dotfiles"
fi

# Check if dotfiles directory exists and is a git repo
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    return
fi

# Timestamp file to track last check
LAST_CHECK_FILE="${DOTFILES_DIR}/.last-update-check"
CURRENT_TIME=$(date +%s)
CHECK_INTERVAL=$((24 * 60 * 60))  # 24 hours in seconds

# Check if we need to run (once per day)
if [ -f "$LAST_CHECK_FILE" ]; then
    LAST_CHECK=$(command cat "$LAST_CHECK_FILE")
    TIME_SINCE_CHECK=$((CURRENT_TIME - LAST_CHECK))

    if [ $TIME_SINCE_CHECK -lt $CHECK_INTERVAL ]; then
        return  # Too soon, skip check
    fi
fi

# Update timestamp
echo "$CURRENT_TIME" > "$LAST_CHECK_FILE"

# Check for updates in background to avoid blocking shell startup
(
    cd "$DOTFILES_DIR" || exit

    # Fetch updates quietly
    git fetch origin main --quiet 2>/dev/null || exit

    # Check if behind
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null)

    if [ "$LOCAL" != "$REMOTE" ]; then
        # Show notification (use echo if cat fails)
        if command -v cat &>/dev/null; then
            cat << 'EOF'

╔═══════════════════════════════════════════════════════════╗
║  📦 Dotfiles Update Available                             ║
╚═══════════════════════════════════════════════════════════╝

  New updates are available for your dotfiles!

  To update, run:
    dotfiles-update

  Or pull manually:
    cd ~/dotfiles && git pull

EOF
        else
            echo ""
            echo "📦 Dotfiles Update Available"
            echo ""
            echo "  New updates are available!"
            echo "  To update, run: dotfiles-update"
            echo ""
        fi
    fi
) &
