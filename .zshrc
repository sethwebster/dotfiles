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
[ -f "$DOTFILES/functions.zsh" ] && source "$DOTFILES/functions.zsh"

# asdf (check if brew exists first)
if command -v brew &>/dev/null; then
    ASDF_INIT="$(brew --prefix asdf)/libexec/asdf.sh"
    # shellcheck disable=SC1090
    [ -f "$ASDF_INIT" ] && . "$ASDF_INIT"
fi

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# fzf (fuzzy finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)" 2>/dev/null

# zoxide (smart cd)
eval "$(zoxide init zsh)" 2>/dev/null

# Environment variables
export EDITOR='code -w'
export VISUAL='code'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

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
    # Plugins
    plugins=(
        git
        docker
        docker-compose
        node
        npm
        python
        zsh-autosuggestions
        zsh-syntax-highlighting
    )
    source $ZSH/oh-my-zsh.sh
fi

# Load any local overrides (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
