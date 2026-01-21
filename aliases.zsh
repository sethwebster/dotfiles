# Command aliases

# Modern CLI replacements
alias ll='eza -la --git'
alias ls='eza'
alias cat='bat'
alias vim='nvim'
alias j='z'  # zoxide smart cd (use 'j' to avoid shadowing 'cd')

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# Docker aliases
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcb='docker compose build'
alias dps='docker ps'
alias dpsa='docker ps -a'

# Shortcuts
alias reload='source ~/.zshrc'
alias zshconfig='code ~/.zshrc'

# Dotfiles shortcut (derives location from .zshrc symlink)
dotfiles() {
    if [ -L "${HOME}/.zshrc" ]; then
        cd "$(dirname "$(readlink "${HOME}/.zshrc")")"
    else
        cd "${HOME}/dotfiles"
    fi
}

# Utilities
alias myip='curl ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias cleanup='find . -name ".DS_Store" -delete'
