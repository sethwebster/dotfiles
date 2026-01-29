# Seth's ZSH Configuration

# Path to oh-my-zsh (if installed)
export ZSH="$HOME/.oh-my-zsh"

# Set theme (if using oh-my-zsh)
# ZSH_THEME="robbyrussell"

# Load modular configs
# Derive dotfiles location from .zshrc symlink
if [ -L "${HOME}/.zshrc" ]; then
    DOTFILES="$(dirname "$(readlink "${HOME}/.zshrc")")"
else
    DOTFILES="${HOME}/dotfiles"
fi

[ -f "$DOTFILES/path.zsh" ] && source "$DOTFILES/path.zsh"
[ -f "$DOTFILES/aliases.zsh" ] && source "$DOTFILES/aliases.zsh"

# Unalias git if it's set (hub wraps git but causes function definition conflicts)
unalias git 2>/dev/null || true

[ -f "$DOTFILES/functions.zsh" ] && source "$DOTFILES/functions.zsh"
[ -f "$DOTFILES/check-updates.zsh" ] && source "$DOTFILES/check-updates.zsh"

# asdf (check if brew exists first)
if command -v brew &>/dev/null; then
    ASDF_INIT="$(brew --prefix asdf)/libexec/asdf.sh"
    # shellcheck disable=SC1090
    [ -f "$ASDF_INIT" ] && . "$ASDF_INIT"
fi

# fzf (fuzzy finder) - check if installed
if command -v fzf &>/dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    eval "$(fzf --zsh)" 2>/dev/null
fi

# autojump (smart cd) - check if installed
[ -f "$(brew --prefix)/etc/profile.d/autojump.sh" ] && . "$(brew --prefix)/etc/profile.d/autojump.sh"

# Environment variables
export EDITOR='code -w'
export VISUAL='code'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export WARP_HONOR_PS1=1

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# Case-insensitive completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Initialize oh-my-zsh if installed
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    # Plugins (only add if installed)
    plugins=(git docker docker-compose node npm python)

    # Add optional plugins if they exist
    [ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions" ] && plugins+=(zsh-autosuggestions)
    [ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting" ] && plugins+=(zsh-syntax-highlighting)

    source "$ZSH/oh-my-zsh.sh"
fi

# Custom prompt (must be after oh-my-zsh to override)
[ -f "$DOTFILES/prompt.zsh" ] && source "$DOTFILES/prompt.zsh"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Load any local overrides (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Added by Antigravity
export PATH="/Users/sethwebster/.antigravity/antigravity/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sethwebster/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
