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
    $EDITOR ~/.zshrc && source ~/.zshrc
}

# Reload shell configuration
reload-shell() {
    echo "Reloading shell configuration..."
    source ~/.zshrc
    echo "✓ Shell reloaded"
}

# Network diagnostics and repair
fix-my-network() {
    # Colors
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local WHITE='\033[1;37m'
    local RESET='\033[0m'
    local BOLD='\033[1m'
    local DIM='\033[2m'

    # Symbols
    local CHECK="${GREEN}✓${RESET}"
    local CROSS="${RED}✗${RESET}"
    local WARN="${YELLOW}⚠${RESET}"
    local INFO="${BLUE}ℹ${RESET}"
    local GEAR="${CYAN}⚙${RESET}"
    local ROCKET="${MAGENTA}🚀${RESET}"

    # Header
    echo ""
    echo "${BOLD}${CYAN}╔═══════════════════════════════════════════╗${RESET}"
    echo "${BOLD}${CYAN}║${RESET}  ${ROCKET}  ${BOLD}Network Diagnostic & Repair${RESET}       ${BOLD}${CYAN}║${RESET}"
    echo "${BOLD}${CYAN}╚═══════════════════════════════════════════╝${RESET}"
    echo ""

    local issues_found=0
    local fixes_applied=0
    local -a test_results
    local -a test_names

    # Helper function for test output
    test_item() {
        echo -n "${DIM}[${RESET} ${GEAR} ${DIM}]${RESET} $1... "
        test_names+=("$1")
    }

    test_pass() {
        echo "${CHECK} ${GREEN}$1${RESET}"
        test_results+=("pass")
    }

    test_fail() {
        echo "${CROSS} ${RED}$1${RESET}"
        test_results+=("fail")
        ((issues_found++))
    }

    test_warn() {
        echo "${WARN} ${YELLOW}$1${RESET}"
        test_results+=("warn")
    }

    fix_applied() {
        echo "    ${GEAR} ${CYAN}Applied fix:${RESET} $1"
        ((fixes_applied++))
    }

    section() {
        echo ""
        echo "${BOLD}${BLUE}▶${RESET} ${BOLD}$1${RESET}"
        echo "${DIM}────────────────────────────────────────────${RESET}"
    }

    # 1. Check proxy environment variables
    section "Proxy Configuration"
    test_item "Checking for stale proxy settings"

    local proxy_vars=(HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY FTP_PROXY NO_PROXY)
    local found_proxies=0

    for var in "${proxy_vars[@]}"; do
        if [[ -n "${(P)var}" ]]; then
            found_proxies=1
            test_fail "Found: $var=${(P)var}"
            unset $var
            fix_applied "Cleared $var"
        fi
    done

    if [[ $found_proxies -eq 0 ]]; then
        test_pass "Clean"
    fi

    # 2. DNS Tests
    section "DNS Resolution"

    test_item "Testing DNS lookup (google.com)"
    if nslookup google.com >/dev/null 2>&1; then
        test_pass "Working"
    else
        test_fail "Failed"
        test_item "Flushing DNS cache"
        sudo dscacheutil -flushcache 2>/dev/null
        sudo killall -HUP mDNSResponder 2>/dev/null
        fix_applied "DNS cache flushed"
    fi

    test_item "Checking DNS servers"
    local dns_servers=$(scutil --dns | grep 'nameserver\[0\]' | head -1 | awk '{print $3}')
    if [[ -n "$dns_servers" ]]; then
        test_pass "Configured: $dns_servers"
    else
        test_warn "No DNS servers found"
    fi

    # 3. Network Interface
    section "Network Interfaces"

    test_item "Checking active interfaces"

    # Find interface with status: active
    local active_if=""
    for iface in $(ifconfig -l); do
        if ifconfig "$iface" | grep -q "status: active"; then
            active_if="$iface"
            break
        fi
    done

    if [[ -n "$active_if" ]]; then
        local ip_addr=$(ifconfig $active_if | grep 'inet ' | awk '{print $2}' | head -1)
        test_pass "Active: $active_if ($ip_addr)"
    else
        test_fail "No active interface"
        test_item "Attempting to restart primary interface"
        sudo ifconfig en0 down 2>/dev/null
        sleep 1
        sudo ifconfig en0 up 2>/dev/null
        fix_applied "Restarted en0"
    fi

    # 4. Basic Connectivity
    section "Connectivity Tests"

    test_item "Testing raw IP connectivity (8.8.8.8)"
    if ping -c 2 -W 2000 8.8.8.8 >/dev/null 2>&1; then
        test_pass "Reachable"
    else
        test_fail "Cannot reach external IPs"
    fi

    test_item "Testing internet connectivity (google.com)"
    if ping -c 2 -W 2000 google.com >/dev/null 2>&1; then
        test_pass "Reachable"
    else
        test_fail "Cannot resolve/reach domains"
    fi

    test_item "Testing HTTP/HTTPS (curl example.com)"
    if curl -s --connect-timeout 3 http://example.com >/dev/null 2>&1; then
        test_pass "Working"
    else
        test_fail "HTTP requests failing"
    fi

    # 5. System Resources
    section "System Resources"

    test_item "Checking open network connections"
    local conn_count=$(lsof -i 2>/dev/null | wc -l | tr -d ' ')
    local fd_limit=$(ulimit -n)

    if [[ $conn_count -lt $((fd_limit / 2)) ]]; then
        test_pass "$conn_count open (limit: $fd_limit)"
    else
        test_warn "$conn_count open (limit: $fd_limit) - approaching limit"
    fi

    # 6. Routing Table
    section "Routing"

    test_item "Checking default gateway"
    local gateway=$(netstat -rn | grep default | grep -v '::' | awk '{print $2}' | head -1)

    if [[ -n "$gateway" ]]; then
        test_pass "Gateway: $gateway"
    else
        test_fail "No default gateway"
    fi

    # Summary
    echo ""
    echo "${BOLD}${CYAN}╔═══════════════════════════════════════════╗${RESET}"
    echo "${BOLD}${CYAN}║${RESET}  ${BOLD}Summary${RESET}                                  ${BOLD}${CYAN}║${RESET}"
    echo "${BOLD}${CYAN}╚═══════════════════════════════════════════╝${RESET}"
    echo ""

    # Results table
    echo "${BOLD}${DIM}┌────────────────────────────────────────┬────────┐${RESET}"
    echo "${BOLD}${DIM}│${RESET} ${BOLD}Test${RESET}                                   ${BOLD}${DIM}│${RESET} ${BOLD}Result${RESET} ${BOLD}${DIM}│${RESET}"
    echo "${BOLD}${DIM}├────────────────────────────────────────┼────────┤${RESET}"

    for i in {1..${#test_names[@]}}; do
        local test_name="${test_names[$i]}"
        local result="${test_results[$i]}"

        # Truncate test name if too long
        if [[ ${#test_name} -gt 38 ]]; then
            test_name="${test_name:0:35}..."
        fi

        # Pad test name to 38 chars
        printf "${BOLD}${DIM}│${RESET} %-38s ${BOLD}${DIM}│${RESET} " "$test_name"

        # Show result with color
        case "$result" in
            pass)
                printf "${CHECK} ${GREEN}OK${RESET}  "
                ;;
            fail)
                printf "${CROSS} ${RED}FAIL${RESET}"
                ;;
            warn)
                printf "${WARN} ${YELLOW}WARN${RESET}"
                ;;
        esac
        echo " ${BOLD}${DIM}│${RESET}"
    done

    echo "${BOLD}${DIM}└────────────────────────────────────────┴────────┘${RESET}"
    echo ""

    # Overall status
    if [[ $issues_found -eq 0 ]]; then
        echo "  ${CHECK} ${GREEN}${BOLD}No issues detected${RESET}"
        echo "  ${INFO} Network appears healthy"
    else
        echo "  ${CROSS} ${YELLOW}Issues found:${RESET} $issues_found"
        echo "  ${GEAR} ${CYAN}Fixes applied:${RESET} $fixes_applied"

        if [[ $fixes_applied -lt $issues_found ]]; then
            echo ""
            echo "  ${WARN} ${YELLOW}Manual intervention may be needed:${RESET}"
            echo "      • Check VPN/firewall settings"
            echo "      • Verify WiFi/Ethernet connection"
            echo "      • Check System Settings > Network"
            echo "      • Review Console.app for network errors"
            echo "      • Consider: ${DIM}sudo killall -HUP mDNSResponder${RESET}"
        fi
    fi

    echo ""
    echo "${DIM}Run again with: ${BOLD}fix-my-network${RESET}"
    echo ""
}

# Port management
ports() {
    lsof -iTCP -sTCP:LISTEN -n -P
}

killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port>"
        return 1
    fi
    lsof -ti:$1 | xargs kill -9
}

# Find large files
findlarge() {
    find . -type f -size +${1:-100}M -exec ls -lh {} \; 2>/dev/null | awk '{print $9 ": " $5}'
}

# Git branch cleanup (delete merged branches)
gcleanup() {
    git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
}

# Quick backup
backup() {
    cp "$1"{,.backup-$(date +%Y%m%d-%H%M%S)}
}

# Directory size
dirsize() {
    du -sh "${1:-.}" | sort -hr
}

# Open project in editor
proj() {
    cd ~/Development/${1:-.} && $EDITOR .
}

# Quick search in code
codesearch() {
    rg -p "$1" | less -R
}

# Interactive command menu
use-my-mac() {
    # Check if fzf is installed
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required but not installed"
        echo "Install with: brew install fzf"
        return 1
    fi

    # Build command list with categories
    local commands=$(cat <<'EOF'
# Navigation
..                  → Go up one directory
...                 → Go up two directories
....                → Go up three directories
-                   → Go to previous directory
j <dir>             → Jump to directory (autojump)
dotfiles            → Navigate to dotfiles directory
proj <name>         → Open project in ~/Development

# File Operations
ll                  → List files (long format with git status)
ls                  → List files
cat <file>          → View file with syntax highlighting
extract <file>      → Extract any archive type
backup <file>       → Create timestamped backup
findlarge [size]    → Find large files (default >100M)
dirsize [path]      → Show directory sizes sorted
cleanup             → Delete all .DS_Store files

# Git - Basic
gs                  → git status
ga                  → git add
gc                  → git commit
gcm <msg>           → git commit -m
gca                 → git commit --amend
gcane               → git commit --amend --no-edit
gp                  → git push
gl                  → git pull
gd                  → git diff
glog                → git log (pretty graph)

# Git - Branches
gb                  → git branch
gbd <branch>        → git branch -d (delete)
gbD <branch>        → git branch -D (force delete)
gco <branch>        → git checkout
gm <branch>         → git merge
grb <branch>        → git rebase
grbi <ref>          → git rebase -i (interactive)
gcleanup            → Delete all merged branches

# Git - Advanced
gf                  → git fetch
gsh                 → git stash
gshp                → git stash pop
gcp <commit>        → git cherry-pick
grh                 → git reset HEAD~
gundo               → git reset --soft HEAD~1
gclean              → git clean -fd
gac <msg>           → git add . && commit -m
ghpr                → Create GitHub PR (gh pr create --fill)

# Docker
dc                  → docker compose
dcu                 → docker compose up
dcd                 → docker compose down
dcb                 → docker compose build
dcl                 → docker compose logs
dclf                → docker compose logs -f (follow)
dce                 → docker compose exec
dcr                 → docker compose restart
dps                 → docker ps
dpsa                → docker ps -a (all)
di                  → docker images
dprune              → docker system prune -af

# Bun
br <script>         → bun run
bi                  → bun install
ba <pkg>            → bun add
brm <pkg>           → bun remove
bt                  → bun test

# Network
myip                → Show public IP
localip             → Show local IP (en0)
ports               → Show all listening ports
killport <port>     → Kill process on port
fix-my-network      → Network diagnostic & repair tool

# Development
vim <file>          → nvim (neovim)
psgrep <name>       → Find process by name
killnamed <name>    → Kill process by name (with confirmation)
serve [port]        → Start HTTP server (default: 8000)
codesearch <term>   → Search code with ripgrep + pager

# System
c                   → clear
h                   → Show last 20 history items
path                → Show PATH entries (one per line)
hosts               → Edit /etc/hosts
reload-shell        → Reload zsh configuration
edit-profile        → Edit .zshrc and reload
zshconfig           → Open .zshrc in editor
brewup              → brew update + upgrade + cleanup
dotfiles-update     → Update dotfiles and Homebrew

# Utilities
mkcd <dir>          → mkdir + cd into it
use-my-mac          → This menu!
EOF
)

    # Use fzf to select command
    local selected=$(echo "$commands" | \
        grep -v '^#' | \
        grep -v '^$' | \
        fzf --height=80% \
            --border=rounded \
            --prompt="🔍 Search commands: " \
            --header="↑↓ navigate • enter: copy • ctrl-e: execute • esc: quit" \
            --preview='echo {}' \
            --preview-window=up:3:wrap \
            --bind='ctrl-e:execute-silent(echo {} | cut -d" " -f1 | pbcopy)+abort' \
            --color='header:italic:cyan,prompt:bold:blue,pointer:bold:magenta')

    if [ -n "$selected" ]; then
        # Extract command (before the arrow)
        local cmd=$(echo "$selected" | awk '{print $1}')

        # Copy to clipboard
        echo -n "$cmd" | pbcopy

        echo ""
        echo "✓ Copied to clipboard: $cmd"
        echo ""

        # Ask if user wants to execute
        read -p "Execute now? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Check if it needs arguments
            if echo "$selected" | grep -q '<.*>'; then
                echo "Command requires arguments. Paste and complete:"
                print -z "$cmd "
            else
                eval "$cmd"
            fi
        fi
    fi
}

# AI development best practices CLI
ai() {
    local cmd="$1"
    shift

    case "$cmd" in
        init)
            # ASCII Art: Robot peeking through opening door
            cat << 'EOF'

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

            # Check if AGENTS.md already exists
            if [ -f "AGENTS.md" ]; then
                echo "⚠️  AGENTS.md already exists in this directory"
                read -p "Overwrite? (y/N) " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo "❌ Cancelled"
                    return 1
                fi
            fi

            # Download AGENTS.md from GitHub
            echo "📥 Downloading AGENTS.md from github.com/sethwebster/AI..."
            if curl -fsSL "https://raw.githubusercontent.com/sethwebster/AI/main/AGENTS.md" -o "AGENTS.md"; then
                echo "✅ AGENTS.md initialized successfully"

                # Create symlink from CLAUDE.md to AGENTS.md
                if [ -e "CLAUDE.md" ] && [ ! -L "CLAUDE.md" ]; then
                    echo "⚠️  CLAUDE.md exists and is not a symlink"
                    read -p "Replace with symlink to AGENTS.md? (y/N) " -n 1 -r
                    echo ""
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        rm "CLAUDE.md"
                        ln -s "AGENTS.md" "CLAUDE.md"
                        echo "🔗 Created symlink: CLAUDE.md -> AGENTS.md"
                    fi
                elif [ -L "CLAUDE.md" ]; then
                    echo "ℹ️  CLAUDE.md symlink already exists"
                else
                    ln -s "AGENTS.md" "CLAUDE.md"
                    echo "🔗 Created symlink: CLAUDE.md -> AGENTS.md"
                fi

                echo ""
                echo "📖 Review the best practices: cat AGENTS.md"
                echo "🔗 Source: https://github.com/sethwebster/AI"
            else
                echo "❌ Failed to download AGENTS.md"
                echo "   Check network connection or repository availability"
                return 1
            fi
            ;;

        *)
            echo "AI Development Best Practices CLI"
            echo ""
            echo "Usage:"
            echo "  ai init    - Initialize directory with AGENTS.md from github.com/sethwebster/AI"
            echo ""
            echo "More commands coming soon..."
            return 1
            ;;
    esac
}

# Port Find - Find process by port number
portfind() {
    if [ -z "$1" ]; then
        echo "Usage: portfind <port>"
        echo "Example: portfind 3000"
        return 1
    fi

    local PORT="$1"

    # Find processes using the port
    local RESULTS=$(lsof -i :$PORT 2>/dev/null)

    if [ -z "$RESULTS" ]; then
        echo "No process found on port $PORT"
        return 1
    fi

    echo "$RESULTS"
}

# Port Kill - Kill process by port number
portkill() {
    if [ -z "$1" ]; then
        echo "Usage: portkill <port>"
        echo "Example: portkill 3000"
        return 1
    fi

    local PORT="$1"

    # Find PIDs using the port
    local PIDS=$(lsof -ti :$PORT 2>/dev/null)

    if [ -z "$PIDS" ]; then
        echo "No process found on port $PORT"
        return 1
    fi

    echo "Killing process(es) on port $PORT..."
    echo "$PIDS" | xargs kill -9 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✅ Process(es) killed: $PIDS"
    else
        echo "❌ Failed to kill process(es)"
        return 1
    fi
}

# Reset a tart VM by deleting it and re-cloning from tahoe-base
# Usage: tart-reset <vm-name> [--run]
tart-reset() {
    local vm_name="$1"
    local run_after=false

    if [ -z "$vm_name" ]; then
        echo "Usage: tart-reset <vm-name> [--run]"
        return 1
    fi

    shift
    while [ $# -gt 0 ]; do
        case "$1" in
            --run) run_after=true ;;
            *) echo "Unknown flag: $1"; return 1 ;;
        esac
        shift
    done

    if tart list | grep -q "^$vm_name "; then
        echo "Deleting existing VM '$vm_name'..."
        tart delete "$vm_name"
    fi

    echo "Cloning tahoe-base -> $vm_name..."
    tart clone tahoe-base "$vm_name" || { echo "Clone failed"; return 1; }

    echo "VM '$vm_name' ready."

    if $run_after; then
        echo "Starting '$vm_name'..."
        tart run "$vm_name"
    fi
}
