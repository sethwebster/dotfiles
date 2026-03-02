# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Seth's ZSH Configuration

# Path to oh-my-zsh (if installed)
export ZSH="$HOME/.oh-my-zsh"

# Set theme (if using oh-my-zsh)
ZSH_THEME="powerlevel10k/powerlevel10k"

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
export EDITOR='cursor'
export VISUAL='cursor'
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

. "$HOME/.cargo/env"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# AI Development CLI
ai() {
	local cmd="$1"
	shift

	# Helper: Register current directory
	_ai_register_directory() {
		local REGISTRY="$HOME/.ai-registry"
		local CURRENT_DIR="$(pwd)"

		# Create registry if it doesn't exist
		touch "$REGISTRY"

		# Check if already registered
		if grep -Fxq "$CURRENT_DIR" "$REGISTRY" 2>/dev/null; then
			return 0
		fi

		# Add to registry
		echo "$CURRENT_DIR" >> "$REGISTRY"
	}

	# Helper: Unregister current directory
	_ai_unregister_directory() {
		local REGISTRY="$HOME/.ai-registry"
		local CURRENT_DIR="$(pwd)"

		if [ ! -f "$REGISTRY" ]; then
			return 0
		fi

		# Remove from registry
		grep -Fxv "$CURRENT_DIR" "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
	}

	case "$cmd" in
		init)
			bat <<'EOF'

            ╔═══════════════════════════════════════════════════════╗
            ║                                                       ║
            ║    ┌────────┐                                        ║
            ║    │        │                    ___                 ║
            ║    │   ∥    │                   /   \                ║
            ║    │   ∥    │     👋           | o o |               ║
            ║    │   ∥    │                   \___/                ║
            ║    │   ∥   /│                    |||                 ║
            ║    │   ∥  / │                   /   \                ║
            ║    │   ∥ /  │                  |  ⚙  |               ║
            ║    │   ∥/   │                   \___/                ║
            ║    │   /    │                  //   \\               ║
            ║    │  /     │                 //     \\              ║
            ║    │ /      │                                        ║
            ║    │/       │          "Hello, Developer!"          ║
            ║    └────────┘                                        ║
            ║     [DOOR]              [FRIENDLY AI ROBOT]          ║
            ║                                                       ║
            ╚═══════════════════════════════════════════════════════╝

EOF
			echo "🤖 Initializing directory with AI development best practices..."
			echo ""

			local REPO_CLONE="$HOME/.ai-repo-local-clone"
			local REPO_URL="https://github.com/sethwebster/AI.git"

			# Clone or update the repo
			if [ -d "$REPO_CLONE" ]; then
				echo "📥 Updating local repo at $REPO_CLONE..."
				if ! (cd "$REPO_CLONE" && git pull --depth 1); then
					echo ""
					echo "⚠️  Local clone is out of sync with remote"
					echo "   This will delete $REPO_CLONE and re-clone fresh"
					printf "Force reset? (y/N) "
					read -r REPLY < /dev/tty
					echo ""
					if [[ ! $REPLY =~ ^[Yy]$ ]]; then
						echo "❌ Cancelled - local clone unchanged"
						return 1
					fi
					rm -rf "$REPO_CLONE"
					git clone --depth 1 "$REPO_URL" "$REPO_CLONE"
				fi
			else
				echo "📥 Cloning repo to $REPO_CLONE..."
				git clone --depth 1 "$REPO_URL" "$REPO_CLONE"
			fi

			# Create symlinks for AGENTS.md
			if [ -e "AGENTS.md" ] && [ ! -L "AGENTS.md" ]; then
				echo ""
				echo "⚠️  AGENTS.md exists and is not a symlink"
				printf "Replace with symlink? (y/N) "
				read -r REPLY < /dev/tty
				echo ""
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					rm "AGENTS.md"
					ln -s "$REPO_CLONE/AGENTS.md" "AGENTS.md"
					echo "🔗 Created symlink: AGENTS.md -> $REPO_CLONE/AGENTS.md"
				fi
			elif [ -L "AGENTS.md" ]; then
				echo "ℹ️  AGENTS.md symlink already exists"
			else
				ln -s "$REPO_CLONE/AGENTS.md" "AGENTS.md"
				echo "🔗 Created symlink: AGENTS.md -> $REPO_CLONE/AGENTS.md"
			fi

			# Create symlink for CLAUDE.md
			if [ -e "CLAUDE.md" ] && [ ! -L "CLAUDE.md" ]; then
				echo ""
				echo "⚠️  CLAUDE.md exists and is not a symlink"
				printf "Replace with symlink? (y/N) "
				read -r REPLY < /dev/tty
				echo ""
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					rm "CLAUDE.md"
					ln -s "$REPO_CLONE/CLAUDE.md" "CLAUDE.md"
					echo "🔗 Created symlink: CLAUDE.md -> $REPO_CLONE/CLAUDE.md"
				fi
			elif [ -L "CLAUDE.md" ]; then
				echo "ℹ️  CLAUDE.md symlink already exists"
			else
				ln -s "$REPO_CLONE/CLAUDE.md" "CLAUDE.md"
				echo "🔗 Created symlink: CLAUDE.md -> $REPO_CLONE/CLAUDE.md"
			fi

			# Copy AGENT-WORKSPACE.md if it doesn't exist
			if [ ! -e "AGENT-WORKSPACE.md" ]; then
				echo "📄 Copying AGENT-WORKSPACE.md template..."
				cp "$REPO_CLONE/AGENT-WORKSPACE.md" "AGENT-WORKSPACE.md"
				echo "✅ AGENT-WORKSPACE.md initialized"
				echo "   ℹ️  Edit this file to add workspace-specific information"
			else
				echo "ℹ️  AGENT-WORKSPACE.md already exists, skipping"
			fi

			# Register this directory
			_ai_register_directory

			echo ""
			echo "📖 Review the best practices:"
			echo "   cat AGENTS.md"
			echo "   cat AGENT-WORKSPACE.md"
			echo ""
			echo "🔗 Source: https://github.com/sethwebster/AI"
			;;

		update)
			local REPO_CLONE="$HOME/.ai-repo-local-clone"
			local REPO_URL="https://github.com/sethwebster/AI.git"

			if [ ! -d "$REPO_CLONE" ]; then
				echo "❌ Local repo not found at $REPO_CLONE"
				echo "   Run 'ai init' first to set up the local repo"
				return 1
			fi

			echo "🔄 Updating AI development best practices..."
			if ! (cd "$REPO_CLONE" && git pull --depth 1); then
				echo ""
				echo "⚠️  Local clone is out of sync with remote"
				echo "   This will delete $REPO_CLONE and re-clone fresh"
				printf "Force reset? (y/N) "
				read -r REPLY < /dev/tty
				echo ""
				if [[ ! $REPLY =~ ^[Yy]$ ]]; then
					echo "❌ Cancelled - local clone unchanged"
					return 1
				fi
				rm -rf "$REPO_CLONE"
				if ! git clone --depth 1 "$REPO_URL" "$REPO_CLONE"; then
					echo "❌ Failed to clone repo"
					return 1
				fi
			fi

			echo "✅ Successfully updated local repo"
			echo "   Symlinked files (AGENTS.md, CLAUDE.md) now reflect latest changes"

			# Detect shell
			local SHELL_NAME=$(basename "$SHELL")
			case "$SHELL_NAME" in
				bash)
					local SHELL_RC="$HOME/.bashrc"
					;;
				zsh)
					local SHELL_RC="$HOME/.zshrc"
					;;
				*)
					echo "⚠️  Unknown shell: $SHELL_NAME, skipping function update"
					return 0
					;;
			esac

			# Check if ai function is installed
			if ! grep -q "# AI Development CLI" "$SHELL_RC" 2>/dev/null; then
				echo "⚠️  AI function not found in $SHELL_RC"
				echo "   Skipping function update"
				return 0
			fi

			echo ""
			echo "🔄 Updating ai function in $SHELL_RC..."

			# Remove old function
			sed '/# AI Development CLI/,/^}$/d' "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"

			# Add new function
			cat "$REPO_CLONE/ai-function.sh" >> "$SHELL_RC"

			echo "✅ AI function updated"
			echo ""
			echo "⚠️  Reload your shell to use the updated function:"
			echo "   source $SHELL_RC"
			;;

		update-all)
			local REGISTRY="$HOME/.ai-registry"

			if [ ! -f "$REGISTRY" ]; then
				echo "❌ No registered directories found"
				echo "   Run 'ai init' in a directory first"
				return 1
			fi

			local TOTAL=$(wc -l < "$REGISTRY" | tr -d ' ')
			if [ "$TOTAL" -eq 0 ]; then
				echo "❌ No registered directories found"
				return 1
			fi

			echo "🔄 Updating all $TOTAL registered directories..."
			echo ""

			local SUCCESS=0
			local FAILED=0
			local CURRENT_DIR="$(pwd)"

			while IFS= read -r dir; do
				if [ ! -d "$dir" ]; then
					echo "⚠️  Skipping (not found): $dir"
					((FAILED++))
					continue
				fi

				echo "📁 $dir"
				(cd "$dir" && ai update 2>&1 | sed 's/^/   /')

				if [ $? -eq 0 ]; then
					((SUCCESS++))
				else
					((FAILED++))
				fi
				echo ""
			done < "$REGISTRY"

			cd "$CURRENT_DIR"

			echo "✅ Update complete: $SUCCESS succeeded, $FAILED failed"
			;;

		list)
			local REGISTRY="$HOME/.ai-registry"

			if [ ! -f "$REGISTRY" ] || [ ! -s "$REGISTRY" ]; then
				echo "No registered directories"
				return 0
			fi

			echo "Registered directories:"
			echo ""
			cat "$REGISTRY" | while IFS= read -r dir; do
				if [ -d "$dir" ]; then
					echo "  ✓ $dir"
				else
					echo "  ✗ $dir (not found)"
				fi
			done
			;;

		forget)
			local CURRENT_DIR="$(pwd)"
			_ai_unregister_directory
			echo "✅ Removed $CURRENT_DIR from registry"
			;;

		*)
			echo "AI Development Best Practices CLI"
			echo ""
			echo "Usage:"
			echo "  ai init        - Initialize directory with AI dev best practices"
			echo "  ai update      - Update local repo and ai function"
			echo "  ai update-all  - Update all registered directories"
			echo "  ai list        - List registered directories"
			echo "  ai forget      - Remove current directory from registry"
			echo ""
			echo "Source: https://github.com/sethwebster/AI"
			return 1
			;;
	esac
}

# OpenClaw Completion
source "/Users/sethwebster/.openclaw/completions/openclaw.zsh"
