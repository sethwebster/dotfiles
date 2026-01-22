# Seth's Powerline ZSH Prompt
# Requires a Nerd Font (e.g., "MesloLGS NF", "JetBrainsMono Nerd Font")

setopt PROMPT_SUBST

# Powerline characters
local PL_SEP=$'\ue0b0'      #

# Icons (Nerd Font)
local ICON_APPLE=$'\uf179'   #
local ICON_BRANCH=$'\ue725'  #
local ICON_BATTERY=$'\uf240' #
local ICON_CHARGING=$'\uf0e7' #

# Colors (background, foreground)
local C_RESET="%f%k"
local C_USER_BG="%K{black}"
local C_USER_FG="%F{white}"
local C_DIR_BG="%K{blue}"
local C_DIR_FG="%F{white}"
local C_GIT_BG="%K{green}"
local C_GIT_DIRTY_BG="%K{yellow}"
local C_BATT_BG="%K{magenta}"
local C_BATT_FG="%F{white}"

# Get shortened directory
_pl_dir() {
    local pwd="${PWD/#$HOME/~}"
    if [[ ${#pwd} -gt 30 ]]; then
        local parts=(${(s:/:)pwd})
        if [[ ${#parts[@]} -gt 2 ]]; then
            echo "…/${parts[-2]}/${parts[-1]}"
        else
            echo "$pwd"
        fi
    else
        echo "$pwd"
    fi
}

# Get git info
_pl_git() {
    local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    [[ -z "$git_dir" ]] && return 1
    git symbolic-ref --short HEAD 2>/dev/null || \
    git describe --tags --exact-match 2>/dev/null || \
    git rev-parse --short HEAD 2>/dev/null
}

# Check if git is dirty
_pl_git_dirty() {
    [[ -n "$(git status --porcelain 2>/dev/null)" ]]
}

# Get battery info
_pl_battery() {
    local batt_info="$(pmset -g batt 2>/dev/null)"
    local pct="$(echo "$batt_info" | grep -oE '[0-9]+%' | head -1 | tr -d '%')"
    [[ -z "$pct" ]] && return 1

    local icon="$ICON_BATTERY"
    [[ "$batt_info" == *"AC Power"* ]] && icon="$ICON_CHARGING"

    echo "${icon} ${pct}%%"
}

# Build the prompt
_build_prompt() {
    local prompt=""
    local last_bg=""

    # User segment
    prompt+="${C_USER_BG}${C_USER_FG} ${ICON_APPLE} %n "
    prompt+="%F{black}${C_DIR_BG}${PL_SEP}"

    # Directory segment
    prompt+="${C_DIR_FG} $(_pl_dir) "
    last_bg="blue"

    # Git segment (if in repo)
    local git_branch="$(_pl_git)"
    if [[ -n "$git_branch" ]]; then
        if _pl_git_dirty; then
            prompt+="%F{blue}${C_GIT_DIRTY_BG}${PL_SEP}"
            prompt+="%F{black} ${ICON_BRANCH} ${git_branch} "
            last_bg="yellow"
        else
            prompt+="%F{blue}${C_GIT_BG}${PL_SEP}"
            prompt+="%F{black} ${ICON_BRANCH} ${git_branch} "
            last_bg="green"
        fi
    fi

    # Battery segment
    local batt="$(_pl_battery)"
    if [[ -n "$batt" ]]; then
        prompt+="%F{${last_bg}}${C_BATT_BG}${PL_SEP}"
        prompt+="${C_BATT_FG} ${batt} "
        last_bg="magenta"
    fi

    # End cap
    prompt+="%F{${last_bg}}%k${PL_SEP}${C_RESET}"

    echo "$prompt"
}

PROMPT='$(_build_prompt) %(?.%F{cyan}.%F{red})❯%f '
RPROMPT=''
