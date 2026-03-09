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


# OpenClaw Completion
source "/Users/sethwebster/.openclaw/completions/openclaw.zsh"

# AI Development CLI
AI_VERSION="1.3.1"

ai() {
	local cmd="$1"
	shift

	# ═══════════════════════════════════════════════════════════════════════════
	# COLOR SYSTEM - Matches landing page design language
	# ═══════════════════════════════════════════════════════════════════════════

	# Check if terminal supports colors
	local USE_COLOR=true
	if [[ ! -t 1 ]] || [[ "$TERM" == "dumb" ]]; then
		USE_COLOR=false
	fi

	# Reset
	local RESET="\033[0m"
	local BOLD="\033[1m"
	local DIM="\033[2m"
	local ITALIC="\033[3m"

	# Primary palette (from landing page)
	local CYAN="\033[38;5;51m"        # Cyan-400 - Primary accent
	local CYAN_BRIGHT="\033[38;5;123m" # Cyan-300 - Highlights
	local BLUE="\033[38;5;33m"        # Blue-500 - Secondary accent
	local GREEN="\033[38;5;84m"       # Green-400 - Success
	local GREEN_BRIGHT="\033[38;5;120m" # Green-300 - Success highlight
	local WHITE="\033[38;5;255m"      # White - Primary text
	local GRAY="\033[38;5;245m"       # Zinc-400 - Secondary text
	local GRAY_DIM="\033[38;5;240m"   # Zinc-500 - Tertiary text
	local GRAY_DARK="\033[38;5;236m"  # Zinc-600 - Borders

	# Agent colors (from agents.tsx)
	local RED="\033[38;5;203m"        # Red-500 - Sentinel
	local ORANGE="\033[38;5;208m"     # Orange-500 - Sentinel gradient
	local PURPLE="\033[38;5;135m"     # Purple-500 - Product/UX Designer
	local PINK="\033[38;5;205m"       # Pink-500 - Product/UX gradient
	local EMERALD="\033[38;5;48m"     # Emerald-500 - Docs Architect
	local TEAL="\033[38;5;44m"        # Teal-500 - Docs Architect gradient
	local AMBER="\033[38;5;214m"      # Amber-500 - Systems Thinker
	local YELLOW="\033[38;5;227m"     # Yellow-500 - Systems gradient

	# Status colors
	local ERROR="\033[38;5;196m"      # Red - Error
	local WARNING="\033[38;5;214m"    # Amber - Warning
	local SUCCESS="\033[38;5;84m"     # Green - Success
	local INFO="\033[38;5;51m"        # Cyan - Info

	# Background colors for highlights
	local BG_CYAN="\033[48;5;23m"     # Dark cyan background
	local BG_GREEN="\033[48;5;22m"    # Dark green background
	local BG_RED="\033[48;5;52m"      # Dark red background
	local BG_GRAY="\033[48;5;236m"    # Dark gray background

	# Disable colors if not supported
	if [[ "$USE_COLOR" == "false" ]]; then
		RESET="" BOLD="" DIM="" ITALIC=""
		CYAN="" CYAN_BRIGHT="" BLUE="" GREEN="" GREEN_BRIGHT=""
		WHITE="" GRAY="" GRAY_DIM="" GRAY_DARK=""
		RED="" ORANGE="" PURPLE="" PINK="" EMERALD="" TEAL="" AMBER="" YELLOW=""
		ERROR="" WARNING="" SUCCESS="" INFO=""
		BG_CYAN="" BG_GREEN="" BG_RED="" BG_GRAY=""
	fi

	# ═══════════════════════════════════════════════════════════════════════════
	# BOX DRAWING CHARACTERS
	# ═══════════════════════════════════════════════════════════════════════════

	local BOX_TL="╭"  # Top-left rounded
	local BOX_TR="╮"  # Top-right rounded
	local BOX_BL="╰"  # Bottom-left rounded
	local BOX_BR="╯"  # Bottom-right rounded
	local BOX_H="─"   # Horizontal
	local BOX_V="│"   # Vertical
	local BOX_T="┬"   # T-down
	local BOX_B="┴"   # T-up
	local BOX_L="├"   # T-right
	local BOX_R="┤"   # T-left
	local BOX_X="┼"   # Cross

	# Block characters
	local BLOCK_FULL="█"
	local BLOCK_LIGHT="░"
	local BLOCK_MEDIUM="▒"
	local BLOCK_DARK="▓"

	# Progress/status symbols
	local SYM_CHECK="✓"
	local SYM_CROSS="✗"
	local SYM_DOT="●"
	local SYM_RING="○"
	local SYM_ARROW="→"
	local SYM_BULLET="•"
	local SYM_SPARK="✦"
	local SYM_STAR="★"

	# ═══════════════════════════════════════════════════════════════════════════
	# HELPER FUNCTIONS
	# ═══════════════════════════════════════════════════════════════════════════

	# Print gradient text (simulated with alternating colors)
	_ai_gradient_text() {
		local text="$1"
		local len=${#text}
		local result=""
		local colors=("$CYAN" "$CYAN_BRIGHT" "$CYAN" "$BLUE")
		local num_colors=${#colors[@]}

		for ((i=0; i<len; i++)); do
			local char="${text:$i:1}"
			local color_idx=$((i * num_colors / len))
			result+="${colors[$color_idx]}${char}"
		done

		echo -e "${result}${RESET}"
	}

	# Print a styled header box
	_ai_header() {
		local title="$1"
		local subtitle="$2"
		local width=60

		echo ""
		echo -e "${GRAY_DARK}${BOX_TL}$(printf '%0.s─' $(seq 1 $width))${BOX_TR}${RESET}"
		echo -e "${GRAY_DARK}${BOX_V}${RESET}  ${BOLD}${CYAN}${title}${RESET}$(printf '%*s' $((width - ${#title} - 2)) '')${GRAY_DARK}${BOX_V}${RESET}"
		if [[ -n "$subtitle" ]]; then
			echo -e "${GRAY_DARK}${BOX_V}${RESET}  ${GRAY}${subtitle}${RESET}$(printf '%*s' $((width - ${#subtitle} - 2)) '')${GRAY_DARK}${BOX_V}${RESET}"
		fi
		echo -e "${GRAY_DARK}${BOX_BL}$(printf '%0.s─' $(seq 1 $width))${BOX_BR}${RESET}"
		echo ""
	}

	# Print a styled section header
	_ai_section() {
		local title="$1"
		echo ""
		echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}${title}${RESET}"
		echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 50))${RESET}"
	}

	# Print success message
	_ai_success() {
		echo -e "${GREEN}${SYM_CHECK}${RESET} ${WHITE}$1${RESET}"
	}

	# Print error message
	_ai_error() {
		echo -e "${ERROR}${SYM_CROSS}${RESET} ${WHITE}$1${RESET}"
	}

	# Print warning message
	_ai_warn() {
		echo -e "${WARNING}${SYM_DOT}${RESET} ${GRAY}$1${RESET}"
	}

	# Print info message
	_ai_info() {
		echo -e "${CYAN}${SYM_BULLET}${RESET} ${GRAY}$1${RESET}"
	}

	# Print step indicator
	_ai_step() {
		local num="$1"
		local text="$2"
		echo -e "${GRAY_DIM}${num}${RESET}  ${WHITE}${text}${RESET}"
	}

	# Spinner animation (runs command in background, shows spinner)
	_ai_spinner() {
		local pid=$1
		local message="$2"
		local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
		local i=0

		while kill -0 $pid 2>/dev/null; do
			printf "\r${CYAN}${frames[$i]}${RESET} ${GRAY}${message}${RESET}"
			i=$(( (i + 1) % ${#frames[@]} ))
			sleep 0.08
		done

		# Clear the spinner line
		printf "\r$(printf '%*s' $((${#message} + 4)) '')\r"
	}

	# Progress bar
	_ai_progress() {
		local current=$1
		local total=$2
		local width=30
		local percent=$((current * 100 / total))
		local filled=$((current * width / total))
		local empty=$((width - filled))

		printf "\r${GRAY}[${RESET}"
		printf "${CYAN}$(printf '%0.s█' $(seq 1 $filled 2>/dev/null || true))${RESET}"
		printf "${GRAY_DARK}$(printf '%0.s░' $(seq 1 $empty 2>/dev/null || true))${RESET}"
		printf "${GRAY}]${RESET} ${WHITE}${percent}%%${RESET}"
	}

	# Print the ASCII logo
	_ai_logo() {
		echo -e "${CYAN}"
		echo '    ___    ____   ____              '
		echo '   /   |  /  _/  / __ \___ _   __   '
		echo '  / /| |  / /   / / / / _ \ | / /   '
		echo ' / ___ |_/ /   / /_/ /  __/ |/ /    '
		echo '/_/  |_/___/  /_____/\___/|___/     '
		echo -e "${RESET}"
	}

	# Print styled logo with gradient effect
	_ai_logo_gradient() {
		echo ""
		echo -e "${CYAN_BRIGHT}    ___    ${CYAN}____   ${CYAN}____              ${RESET}"
		echo -e "${CYAN_BRIGHT}   /   |  ${CYAN}/  _/  ${CYAN}/ __ \\${BLUE}___ _   __   ${RESET}"
		echo -e "${CYAN}  / /| |  ${CYAN}/ /   ${BLUE}/ / / /${BLUE} _ \\ | / /   ${RESET}"
		echo -e "${CYAN} / ___ |${BLUE}_/ /   ${BLUE}/ /_/ /  ${BLUE}__/ |/ /    ${RESET}"
		echo -e "${BLUE}/_/  |_/${BLUE}___/  ${BLUE}/_____/\\___/|___/     ${RESET}"
		echo ""
	}

	# Print version badge (like landing page)
	_ai_version_badge() {
		echo -e "${GRAY_DARK}${BOX_TL}────────────────────────${BOX_TR}${RESET}"
		echo -e "${GRAY_DARK}${BOX_V}${RESET} ${GREEN}${SYM_DOT}${RESET} ${GREEN_BRIGHT}v${AI_VERSION}${RESET} ${GRAY}AI Dev Tools${RESET}  ${GRAY_DARK}${BOX_V}${RESET}"
		echo -e "${GRAY_DARK}${BOX_BL}────────────────────────${BOX_BR}${RESET}"
	}

	# Print a styled command hint
	_ai_cmd_hint() {
		local cmd="$1"
		local desc="$2"
		echo -e "  ${GRAY_DIM}\$${RESET} ${CYAN}${cmd}${RESET}"
		if [[ -n "$desc" ]]; then
			echo -e "    ${GRAY_DIM}${desc}${RESET}"
		fi
	}

	# Print agent card
	_ai_agent_card() {
		local num="$1"
		local name="$2"
		local codename="$3"
		local color="$4"
		local desc="$5"

		echo -e "  ${WHITE}${num}.${RESET} ${color}${SYM_DOT}${RESET} ${BOLD}${WHITE}${name}${RESET} ${GRAY_DIM}(${codename})${RESET}"
		echo -e "     ${GRAY}${desc}${RESET}"
		echo ""
	}

	# ═══════════════════════════════════════════════════════════════════════════
	# DIRECTORY REGISTRY HELPERS
	# ═══════════════════════════════════════════════════════════════════════════

	_ai_register_directory() {
		local REGISTRY="$HOME/.ai-registry"
		local CURRENT_DIR="$(pwd)"
		touch "$REGISTRY"
		if grep -Fxq "$CURRENT_DIR" "$REGISTRY" 2>/dev/null; then
			return 0
		fi
		echo "$CURRENT_DIR" >> "$REGISTRY"
	}

	_ai_unregister_directory() {
		local REGISTRY="$HOME/.ai-registry"
		local CURRENT_DIR="$(pwd)"
		if [ ! -f "$REGISTRY" ]; then
			return 0
		fi
		grep -Fxv "$CURRENT_DIR" "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
	}

	# ═══════════════════════════════════════════════════════════════════════════
	# COMMAND HANDLERS
	# ═══════════════════════════════════════════════════════════════════════════

	case "$cmd" in
		init)
			clear 2>/dev/null || true

			# Animated welcome
			_ai_logo_gradient
			_ai_version_badge

			echo ""
			echo -e "${BOLD}${WHITE}Welcome to AI Dev Tools${RESET}"
			echo -e "${GRAY}Expert AI agents for Claude Code & Codex${RESET}"
			echo ""

			# Horizontal divider
			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 50))${RESET}"
			echo ""

			local REPO_CLONE="$HOME/.ai-repo-local-clone"
			local REPO_URL="https://github.com/sethwebster/AI.git"

			# Step 1: Clone/Update repo
			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Setting up local repository${RESET}"
			echo ""

			if [ -d "$REPO_CLONE" ]; then
				echo -e "  ${GRAY}Updating existing repo...${RESET}"
				rm -rf "$REPO_CLONE"
			else
				echo -e "  ${GRAY}Cloning fresh repo...${RESET}"
			fi

			# Clone with visual feedback
			if git clone --depth 1 "$REPO_URL" "$REPO_CLONE" 2>/dev/null; then
				rm -rf "$REPO_CLONE/.git"
				_ai_success "Repository ready"
			else
				_ai_error "Failed to clone repository"
				return 1
			fi

			echo ""

			# Step 2: Symlinks
			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Creating symlinks${RESET}"
			echo ""

			# AGENTS.md
			if [ -e "AGENTS.md" ] && [ ! -L "AGENTS.md" ]; then
				echo -e "  ${WARNING}${SYM_DOT}${RESET} ${WHITE}AGENTS.md${RESET} exists (not a symlink)"
				printf "  ${GRAY}Replace with symlink?${RESET} ${GRAY_DIM}(y/N)${RESET} "
				read -r REPLY < /dev/tty
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					rm "AGENTS.md"
					ln -s "$REPO_CLONE/AGENTS.md" "AGENTS.md"
					_ai_success "AGENTS.md ${SYM_ARROW} symlinked"
				else
					_ai_warn "Skipped AGENTS.md"
				fi
			elif [ -L "AGENTS.md" ]; then
				_ai_info "AGENTS.md already symlinked"
			else
				ln -s "$REPO_CLONE/AGENTS.md" "AGENTS.md"
				_ai_success "AGENTS.md ${SYM_ARROW} symlinked"
			fi

			# CLAUDE.md
			if [ -e "CLAUDE.md" ] && [ ! -L "CLAUDE.md" ]; then
				echo -e "  ${WARNING}${SYM_DOT}${RESET} ${WHITE}CLAUDE.md${RESET} exists (not a symlink)"
				printf "  ${GRAY}Replace with symlink?${RESET} ${GRAY_DIM}(y/N)${RESET} "
				read -r REPLY < /dev/tty
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					rm "CLAUDE.md"
					ln -s "$REPO_CLONE/CLAUDE.md" "CLAUDE.md"
					_ai_success "CLAUDE.md ${SYM_ARROW} symlinked"
				else
					_ai_warn "Skipped CLAUDE.md"
				fi
			elif [ -L "CLAUDE.md" ]; then
				_ai_info "CLAUDE.md already symlinked"
			else
				ln -s "$REPO_CLONE/CLAUDE.md" "CLAUDE.md"
				_ai_success "CLAUDE.md ${SYM_ARROW} symlinked"
			fi

			# AGENT-WORKSPACE.md
			if [ ! -e "AGENT-WORKSPACE.md" ]; then
				cp "$REPO_CLONE/AGENT-WORKSPACE.md" "AGENT-WORKSPACE.md"
				_ai_success "AGENT-WORKSPACE.md ${SYM_ARROW} created"
				_ai_info "Edit this file to add workspace-specific info"
			else
				_ai_info "AGENT-WORKSPACE.md already exists"
			fi

			_ai_register_directory

			# Next steps
			echo ""
			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 50))${RESET}"
			echo ""
			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Next steps${RESET}"
			echo ""
			_ai_cmd_hint "cat AGENTS.md" "Review agent guidelines"
			_ai_cmd_hint "ai install agents" "Install agents to Claude/Codex"
			_ai_cmd_hint "ai update" "Keep everything up to date"
			echo ""
			echo -e "${GRAY_DIM}Source: ${CYAN}github.com/sethwebster/AI${RESET}"
			echo ""
			;;

		update)
			local REPO_CLONE="$HOME/.ai-repo-local-clone"
			local REPO_URL="https://github.com/sethwebster/AI.git"

			echo ""
			_ai_version_badge
			echo ""

			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Updating AI Dev Tools${RESET}"
			echo ""

			if [ ! -d "$REPO_CLONE" ]; then
				_ai_error "Local repo not found at $REPO_CLONE"
				_ai_info "Run 'ai init' first to set up the local repo"
				return 1
			fi

			echo -e "  ${GRAY}Fetching latest changes...${RESET}"
			rm -rf "$REPO_CLONE"

			if ! git clone --depth 1 "$REPO_URL" "$REPO_CLONE" 2>/dev/null; then
				_ai_error "Failed to clone repo"
				return 1
			fi

			rm -rf "$REPO_CLONE/.git"
			_ai_success "Repository updated"
			_ai_info "Symlinked files now reflect latest changes"

			echo ""

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
					_ai_warn "Unknown shell: $SHELL_NAME"
					return 0
					;;
			esac

			# Resolve symlink if needed
			if [ -L "$SHELL_RC" ]; then
				local ACTUAL_RC=$(readlink "$SHELL_RC")
				if [[ "$ACTUAL_RC" != /* ]]; then
					ACTUAL_RC="$(dirname "$SHELL_RC")/$ACTUAL_RC"
				fi
				SHELL_RC="$ACTUAL_RC"
			fi

			# Check if ai function is installed
			if ! grep -q "# AI Development CLI" "$SHELL_RC" 2>/dev/null; then
				_ai_warn "AI function not found in $SHELL_RC"
				return 0
			fi

			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Updating shell function${RESET}"
			echo ""

			# Remove old function using temp file
			sed '/# AI Development CLI/,/^}$/d' "$SHELL_RC" > /tmp/shell_rc_temp
			chmod --reference="$SHELL_RC" /tmp/shell_rc_temp 2>/dev/null || chmod 644 /tmp/shell_rc_temp
			cat /tmp/shell_rc_temp > "$SHELL_RC"
			rm /tmp/shell_rc_temp

			# Add new function
			cat "$REPO_CLONE/ai-function.sh" >> "$SHELL_RC"
			_ai_success "Shell function updated"

			echo ""
			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 50))${RESET}"
			echo ""
			echo -e "${WARNING}${SYM_DOT}${RESET} ${WHITE}Reload your shell to use updated function:${RESET}"
			_ai_cmd_hint "source $SHELL_RC"
			echo ""

			# Run migrations
			if [ -d "$REPO_CLONE/migrations" ]; then
				echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Checking migrations${RESET}"
				source "$SHELL_RC"
				ai migrate up
			fi
			;;

		update-all)
			local REGISTRY="$HOME/.ai-registry"

			echo ""
			_ai_version_badge
			echo ""

			if [ ! -f "$REGISTRY" ]; then
				_ai_error "No registered directories found"
				_ai_info "Run 'ai init' in a directory first"
				return 1
			fi

			local TOTAL=$(wc -l < "$REGISTRY" | tr -d ' ')
			if [ "$TOTAL" -eq 0 ]; then
				_ai_error "No registered directories found"
				return 1
			fi

			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Updating ${TOTAL} registered directories${RESET}"
			echo ""

			local SUCCESS=0
			local FAILED=0
			local CURRENT_DIR="$(pwd)"
			local COUNT=0

			while IFS= read -r dir; do
				((COUNT++))

				if [ ! -d "$dir" ]; then
					_ai_warn "Skipping (not found): ${GRAY_DIM}$dir${RESET}"
					((FAILED++))
					continue
				fi

				echo -e "  ${GRAY_DIM}[$COUNT/$TOTAL]${RESET} ${WHITE}$dir${RESET}"
				(cd "$dir" && ai update 2>&1 | sed 's/^/       /')

				if [ $? -eq 0 ]; then
					((SUCCESS++))
				else
					((FAILED++))
				fi
			done < "$REGISTRY"

			cd "$CURRENT_DIR"

			echo ""
			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 50))${RESET}"
			echo ""

			if [ $FAILED -eq 0 ]; then
				_ai_success "All $SUCCESS directories updated"
			else
				_ai_success "$SUCCESS updated"
				_ai_error "$FAILED failed"
			fi
			echo ""
			;;

		list)
			local REGISTRY="$HOME/.ai-registry"

			echo ""
			_ai_version_badge
			echo ""

			if [ ! -f "$REGISTRY" ] || [ ! -s "$REGISTRY" ]; then
				_ai_info "No registered directories"
				echo ""
				_ai_cmd_hint "ai init" "Initialize a directory"
				echo ""
				return 0
			fi

			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Registered Directories${RESET}"
			echo ""

			cat "$REGISTRY" | while IFS= read -r dir; do
				if [ -d "$dir" ]; then
					echo -e "  ${GREEN}${SYM_CHECK}${RESET} ${WHITE}$dir${RESET}"
				else
					echo -e "  ${ERROR}${SYM_CROSS}${RESET} ${GRAY}$dir${RESET} ${GRAY_DIM}(not found)${RESET}"
				fi
			done
			echo ""
			;;

		forget)
			local CURRENT_DIR="$(pwd)"
			_ai_unregister_directory

			echo ""
			_ai_success "Removed from registry"
			echo -e "  ${GRAY_DIM}$CURRENT_DIR${RESET}"
			echo ""
			;;

		version|--version|-v)
			echo ""
			_ai_logo_gradient
			_ai_version_badge
			echo ""
			echo -e "  ${GRAY}Source:${RESET} ${CYAN}github.com/sethwebster/AI${RESET}"
			echo ""
			;;

		migrate)
			local direction="${1:-up}"
			local REPO_CLONE="$HOME/.ai-repo-local-clone"
			local MIGRATION_STATE="$HOME/.ai-migration-state"

			echo ""

			if [ ! -d "$REPO_CLONE/migrations" ]; then
				_ai_error "No migrations directory found"
				return 1
			fi

			touch "$MIGRATION_STATE"

			case "$direction" in
				up)
					echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Running Migrations${RESET}"
					echo ""

					local applied_migrations=$(cat "$MIGRATION_STATE" 2>/dev/null || echo "")
					local ran_count=0
					local skip_count=0

					for migration_file in "$REPO_CLONE/migrations"/*.sh; do
						if [ ! -f "$migration_file" ]; then
							continue
						fi

						local migration_id=$(basename "$migration_file" .sh)

						if echo "$applied_migrations" | grep -q "^${migration_id}$"; then
							echo -e "  ${GRAY_DIM}${SYM_CHECK}${RESET} ${GRAY}${migration_id}${RESET} ${GRAY_DIM}(applied)${RESET}"
							((skip_count++))
							continue
						fi

						echo -e "  ${CYAN}${SYM_ARROW}${RESET} ${WHITE}${migration_id}${RESET}"

						source "$migration_file"

						if migration_up; then
							echo "$migration_id" >> "$MIGRATION_STATE"
							((ran_count++))
						else
							_ai_error "Migration failed"
							return 1
						fi
					done

					echo ""
					if [ $ran_count -gt 0 ]; then
						_ai_success "$ran_count migration(s) applied"
					else
						_ai_info "No pending migrations"
					fi
					echo ""
					;;

				down)
					echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Rolling Back Migration${RESET}"
					echo ""

					local last_migration=$(tail -1 "$MIGRATION_STATE" 2>/dev/null)

					if [ -z "$last_migration" ]; then
						_ai_info "No migrations to roll back"
						echo ""
						return 0
					fi

					local migration_file="$REPO_CLONE/migrations/${last_migration}.sh"

					if [ ! -f "$migration_file" ]; then
						_ai_error "Migration file not found: $migration_file"
						return 1
					fi

					echo -e "  ${CYAN}${SYM_ARROW}${RESET} ${WHITE}${last_migration}${RESET}"

					source "$migration_file"

					if migration_down; then
						grep -v "^${last_migration}$" "$MIGRATION_STATE" > "$MIGRATION_STATE.tmp"
						mv "$MIGRATION_STATE.tmp" "$MIGRATION_STATE"
						echo ""
						_ai_success "Rollback complete"
					else
						_ai_error "Rollback failed"
						return 1
					fi
					echo ""
					;;

				status)
					echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Migration Status${RESET}"
					echo ""

					echo -e "${GRAY}Applied:${RESET}"
					if [ -s "$MIGRATION_STATE" ]; then
						cat "$MIGRATION_STATE" | while read -r m; do
							echo -e "  ${GREEN}${SYM_CHECK}${RESET} ${WHITE}$m${RESET}"
						done
					else
						echo -e "  ${GRAY_DIM}(none)${RESET}"
					fi

					echo ""
					echo -e "${GRAY}Pending:${RESET}"
					local has_pending=0
					for migration_file in "$REPO_CLONE/migrations"/*.sh; do
						if [ ! -f "$migration_file" ]; then
							continue
						fi
						local migration_id=$(basename "$migration_file" .sh)
						if ! grep -q "^${migration_id}$" "$MIGRATION_STATE" 2>/dev/null; then
							echo -e "  ${CYAN}${SYM_RING}${RESET} ${GRAY}$migration_id${RESET}"
							has_pending=1
						fi
					done
					if [ $has_pending -eq 0 ]; then
						echo -e "  ${GRAY_DIM}(none)${RESET}"
					fi
					echo ""
					;;

				*)
					echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Migration Commands${RESET}"
					echo ""
					echo -e "  ${WHITE}ai migrate up${RESET}      ${GRAY}Apply pending migrations${RESET}"
					echo -e "  ${WHITE}ai migrate down${RESET}    ${GRAY}Rollback last migration${RESET}"
					echo -e "  ${WHITE}ai migrate status${RESET}  ${GRAY}Show migration status${RESET}"
					echo ""
					return 1
					;;
			esac
			;;

		install)
			local target="$1"

			if [ "$target" != "agents" ]; then
				_ai_error "Unknown install target: $target"
				_ai_info "Available: agents"
				return 1
			fi

			local REPO_CLONE="$HOME/.ai-repo-local-clone"

			if [ ! -d "$REPO_CLONE/agents" ]; then
				_ai_error "Agents not found in local repo"
				_ai_info "Run 'ai init' first"
				return 1
			fi

			echo ""
			_ai_logo_gradient

			echo -e "${BOLD}${WHITE}Agent Installation${RESET}"
			echo -e "${GRAY}Install specialized AI agents to your coding tools${RESET}"
			echo ""
			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 55))${RESET}"
			echo ""

			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Detecting AI Tools${RESET}"
			echo ""

			local DETECTED_TOOLS=()

			if command -v claude &> /dev/null || [ -d "$HOME/.claude" ]; then
				DETECTED_TOOLS+=("claude")
				echo -e "  ${GREEN}${SYM_CHECK}${RESET} ${WHITE}Claude Code${RESET} ${GRAY_DIM}detected${RESET}"
			fi

			if command -v codex &> /dev/null; then
				DETECTED_TOOLS+=("codex")
				echo -e "  ${GREEN}${SYM_CHECK}${RESET} ${WHITE}Codex${RESET} ${GRAY_DIM}detected${RESET}"
			fi

			if [ ${#DETECTED_TOOLS[@]} -eq 0 ]; then
				echo -e "  ${WARNING}${SYM_DOT}${RESET} ${GRAY}No AI coding tools detected${RESET}"
				echo ""
				echo -e "${GRAY}Supported tools:${RESET}"
				echo -e "  ${GRAY_DIM}${SYM_BULLET}${RESET} ${WHITE}Claude Code${RESET} ${GRAY_DIM}claude.com/claude-code${RESET}"
				echo -e "  ${GRAY_DIM}${SYM_BULLET}${RESET} ${WHITE}Codex${RESET}"
				echo ""
				return 1
			fi

			echo ""
			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Available Agents${RESET}"
			echo ""

			_ai_agent_card "1" "Sentinel" "Morgan" "$RED" "Code review, security analysis, architecture oversight"
			_ai_agent_card "2" "Product/UX Designer" "Avery" "$PURPLE" "User-centered design, interface excellence"
			_ai_agent_card "3" "Docs Engineer" "Sam" "$CYAN" "Clear, accurate, shippable documentation"
			_ai_agent_card "4" "Docs Architect" "Emerson" "$EMERALD" "Narrative-driven, award-worthy docs"
			_ai_agent_card "5" "Systems Thinker" "Jan" "$AMBER" "Deep problem solving, first-principles"

			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 55))${RESET}"
			echo ""
			printf "${WHITE}Select agents ${GRAY_DIM}(space-separated numbers or 'all')${RESET}: "
			read -r SELECTION < /dev/tty
			echo ""

			local -a AGENTS=(
				"sentinel:Sentinel (Morgan):sentinel"
				"product-ux-designer:Product/UX Designer (Avery):product-ux-designer"
				"docs-engineer:Docs Engineer (Sam):docs-engineer"
				"docs-architect:Docs Architect (Emerson):docs-architect"
				"systems-thinker:Systems Thinker (Jan):systems-thinker"
			"compiler-expert:Compiler Expert (Kai):compiler-expert"
			"systems-engineer:Systems Engineer (Riley):systems-engineer"
			"hardware-engineer:Hardware Engineer (Quinn):hardware-engineer"
			)

			local -a SELECTED_AGENTS=()

			if [[ "$SELECTION" == "all" ]]; then
				SELECTED_AGENTS=("${AGENTS[@]}")
			else
				for num in $SELECTION; do
					case $num in
						1) SELECTED_AGENTS+=("${AGENTS[0]}") ;;
						2) SELECTED_AGENTS+=("${AGENTS[1]}") ;;
						3) SELECTED_AGENTS+=("${AGENTS[2]}") ;;
						4) SELECTED_AGENTS+=("${AGENTS[3]}") ;;
						5) SELECTED_AGENTS+=("${AGENTS[4]}") ;;
						*) _ai_warn "Invalid selection: $num" ;;
					esac
				done
			fi

			if [ ${#SELECTED_AGENTS[@]} -eq 0 ]; then
				_ai_error "No agents selected"
				return 1
			fi

			for tool in "${DETECTED_TOOLS[@]}"; do
				case "$tool" in
					claude)
						echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Installing for Claude Code${RESET}"
						echo ""
						echo -e "  ${WHITE}1${RESET}  Project-level ${GRAY_DIM}.claude/agents/${RESET}"
						echo -e "     ${GRAY}Shared with team via git${RESET}"
						echo ""
						echo -e "  ${WHITE}2${RESET}  User-level ${GRAY_DIM}~/.claude/agents/${RESET}"
						echo -e "     ${GRAY}Personal only, all projects${RESET}"
						echo ""
						printf "  ${WHITE}Selection${RESET} ${GRAY_DIM}(1/2)${RESET}: "
						read -r LOCATION < /dev/tty
						echo ""

						local AGENT_DIR
						if [ "$LOCATION" = "1" ]; then
							AGENT_DIR=".claude/agents"
						else
							AGENT_DIR="$HOME/.claude/agents"
						fi

						mkdir -p "$AGENT_DIR"

						for agent_info in "${SELECTED_AGENTS[@]}"; do
							IFS=':' read -r agent_type agent_name skill_name <<< "$agent_info"
							local source_file="$REPO_CLONE/agents/${agent_type}.md"
							local dest_file="$AGENT_DIR/${skill_name}.md"

							if [ -f "$source_file" ]; then
								local description=$(grep -A 1 "^## Role" "$source_file" | tail -1)

								cat > "$dest_file" <<EOF
---
name: ${skill_name}
description: ${description}
tools: Read, Write, Edit, Glob, Grep, Bash, LSP
model: sonnet
---

EOF
								tail -n +6 "$source_file" >> "$dest_file"
								_ai_success "$agent_name"
							else
								_ai_error "$agent_name ${GRAY_DIM}(source not found)${RESET}"
							fi
						done
						echo ""
						;;

					codex)
						echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Installing for Codex${RESET}"
						echo ""
						echo -e "  ${WHITE}1${RESET}  Project-scoped ${GRAY_DIM}.codex/skills/${RESET}"
						echo -e "     ${GRAY}This repo only${RESET}"
						echo ""
						echo -e "  ${WHITE}2${RESET}  User-scoped ${GRAY_DIM}~/.codex/skills/${RESET}"
						echo -e "     ${GRAY}All repos${RESET}"
						echo ""
						printf "  ${WHITE}Selection${RESET} ${GRAY_DIM}(1/2)${RESET}: "
						read -r SCOPE < /dev/tty
						echo ""

						local SKILLS_DIR
						if [ "$SCOPE" = "1" ]; then
							SKILLS_DIR=".codex/skills"
						else
							SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
						fi

						mkdir -p "$SKILLS_DIR"

						for agent_info in "${SELECTED_AGENTS[@]}"; do
							IFS=':' read -r agent_type agent_name skill_name <<< "$agent_info"
							local source_file="$REPO_CLONE/agents/${agent_type}.md"
							local skill_dir="$SKILLS_DIR/${skill_name}"
							local dest_file="$skill_dir/SKILL.md"

							if [ -f "$source_file" ]; then
								mkdir -p "$skill_dir"
								local description=$(grep -A 1 "^## Role" "$source_file" | tail -1)

								cat > "$dest_file" <<EOF
---
name: ${skill_name}
description: ${description}
---

EOF
								tail -n +6 "$source_file" >> "$dest_file"
								_ai_success "$agent_name"
							else
								_ai_error "$agent_name ${GRAY_DIM}(source not found)${RESET}"
							fi
						done
						echo ""
						;;
				esac
			done

			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 55))${RESET}"
			echo ""
			_ai_success "Installation complete"
			echo ""

			for tool in "${DETECTED_TOOLS[@]}"; do
				case "$tool" in
					claude)
						_ai_info "Restart Claude Code to load agents"
						;;
					codex)
						_ai_info "Restart Codex to load skills"
						;;
				esac
			done

			echo ""
			echo -e "${GRAY}Learn more:${RESET} ${CYAN}cat $REPO_CLONE/agents/README.md${RESET}"
			echo ""
			;;

		help|--help|-h|"")
			echo ""
			_ai_logo_gradient
			_ai_version_badge
			echo ""
			echo -e "${BOLD}${WHITE}Expert AI agents for Claude Code & Codex${RESET}"
			echo ""
			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 55))${RESET}"
			echo ""
			echo -e "${CYAN}${SYM_SPARK}${RESET} ${BOLD}${WHITE}Commands${RESET}"
			echo ""
			echo -e "  ${CYAN}ai init${RESET}             ${GRAY}Initialize directory with AI dev best practices${RESET}"
			echo -e "  ${CYAN}ai install agents${RESET}   ${GRAY}Install agent definitions into Claude/Codex${RESET}"
			echo ""
			echo -e "  ${CYAN}ai update${RESET}           ${GRAY}Update local repo, shell function & migrations${RESET}"
			echo -e "  ${CYAN}ai update-all${RESET}       ${GRAY}Update all registered directories${RESET}"
			echo ""
			echo -e "  ${CYAN}ai migrate${RESET}          ${GRAY}Run pending migrations (up|down|status)${RESET}"
			echo ""
			echo -e "  ${CYAN}ai list${RESET}             ${GRAY}List registered directories${RESET}"
			echo -e "  ${CYAN}ai forget${RESET}           ${GRAY}Remove current directory from registry${RESET}"
			echo ""
			echo -e "  ${CYAN}ai version${RESET}          ${GRAY}Show version information${RESET}"
			echo -e "  ${CYAN}ai help${RESET}             ${GRAY}Show this help message${RESET}"
			echo ""
			echo -e "${GRAY_DARK}$(printf '%0.s─' $(seq 1 55))${RESET}"
			echo ""
			echo -e "${GRAY}Get started:${RESET}"
			_ai_cmd_hint "ai init" "Set up your project"
			echo ""
			echo -e "${GRAY_DIM}Source: ${CYAN}github.com/sethwebster/AI${RESET}"
			echo ""
			;;

		*)
			_ai_error "Unknown command: $cmd"
			echo ""
			_ai_info "Run 'ai help' for available commands"
			echo ""
			return 1
			;;
	esac
}
