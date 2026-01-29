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
    echo "${BOLD}${CYAN}║${RESET}  ${BOLD}Summary${RESET}                                   ${BOLD}${CYAN}║${RESET}"
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
