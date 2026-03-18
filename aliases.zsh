# Command aliases

# Modern CLI replacements
alias ll='eza -la --git'
alias ls='eza'
alias cat='bat'
alias vim='nvim'
# Note: 'j' command provided by autojump (initialized in .zshrc)

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcane='git commit --amend --no-edit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gm='git merge'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gf='git fetch'
alias gsh='git stash'
alias gshp='git stash pop'
alias gcp='git cherry-pick'
alias grh='git reset HEAD~'
alias gundo='git reset --soft HEAD~1'
alias gclean='git clean -fd'
alias glog='git log --oneline --graph --decorate'

# Docker aliases
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcb='docker compose build'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
alias dce='docker compose exec'
alias dcr='docker compose restart'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dprune='docker system prune -af'

# Shortcuts
alias zshconfig='$EDITOR ~/.zshrc'
alias help='use-my-mac'

# Dotfiles shortcut (derives location from .zshrc symlink)
dotfiles() {
    if [ -L "${HOME}/.zshrc" ]; then
        cd "$(dirname "$(readlink "${HOME}/.zshrc")")"
    else
        cd "${HOME}/dotfiles"
    fi
}

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# System Utilities
alias c='clear'
alias h='history | tail -20'
alias path='echo $PATH | tr ":" "\n"'
alias myip='curl ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias cleanup='find . -name ".DS_Store" -delete'
alias hosts='sudo nvim /etc/hosts'
alias brewup='brew update && brew upgrade && brew cleanup'

# Network Diagnostics
alias domaininfo='bun /Users/sethwebster/dotfiles/scripts/domain-info.ts'

# Claude
_claude_bin() {
  local bin="${HOME}/.local/bin/claude"
  if [[ -x "$bin" ]]; then
    echo "$bin"
  else
    find /opt/homebrew/Caskroom/claude-code -maxdepth 2 -name "claude" -type f 2>/dev/null | sort -V | tail -1
  fi
}
claude() {
  local bin
  bin=$(_claude_bin)
  [[ -z "$bin" ]] && { echo "claude: binary not found" >&2; return 1; }
  "$bin" --dangerously-skip-permissions "$@"
}
claude-safe() {
  local bin
  bin=$(_claude_bin)
  [[ -z "$bin" ]] && { echo "claude: binary not found" >&2; return 1; }
  "$bin" "$@"
}
alias cc='claude'
alias cc-safe='claude-safe'

# Bun shortcuts
alias br='bun run'
alias bi='bun install'
alias ba='bun add'
alias brm='bun remove'
alias bt='bun test'
