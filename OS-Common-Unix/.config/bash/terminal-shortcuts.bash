#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------
# Chander's BASH shell shortcuts for Linux

# XDG (Just in case they're not set already)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Color Controls        # Foreground Colors          # Bright Foreground Colors    # Background Colors
reset=$(tput sgr0)      blackf=$(tput setaf 0)       blackb=$(tput setaf 8)        redbg=$(tput setab 9)
bold=$(tput bold)       redf=$(tput setaf 1)         redb=$(tput setaf 9)          purplebg=$(tput setab 5)
dim=$(tput dim)         greenf=$(tput setaf 2)       greenb=$(tput setaf 10)
                        yellowf=$(tput setaf 3)      yellowb=$(tput setaf 11)
                        bluef=$(tput setaf 4)        blueb=$(tput setaf 12)
                        purplef=$(tput setaf 5)      purpleb=$(tput setaf 13)
                        cyanf=$(tput setaf 6)        cyanb=$(tput setaf 14)
                        whitef=$(tput setaf 7)       whiteb=$(tput setaf 15)

gui_shell_indicator="🅱 🅰 🆂 🅷 "

############################################################################
##  Aliases
############################################################################
alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color=always'
alias path='echo -e ${PATH//:/\\n}'
alias ping='ping -c 5 -s.2'
alias ttymode='export TTY_MODE=1; set_prompt'
alias guimode='unset TTY_MODE; set_prompt'
alias root='sudo -i'
alias ls='l'

if type eza &> /dev/null
then
    LS_COMMAND='eza -almM --classify=always --color-scale=size --group-directories-first --sort=name --time-style=long-iso'
    alias l="${LS_COMMAND}"
    alias ll="${LS_COMMAND} -ghU@"
    alias lt="${LS_COMMAND} --tree"
else
    # No . & .. folders
    # long format, classify, sort by time, readable file sizes
    alias l="ls -AgFth --color=always --group-directories-first"
    alias ll="ls -AgFth --color=never --group-directories-first"
fi

if type zoxide &> /dev/null
then
    alias cd="z"
fi

if type bat &> /dev/null
then
    export MANROFFOPT="-c"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"

    alias cat="bat --plain --paging=never"
    alias bat="bat --style=grid,numbers,header-filesize"
fi

if type yazi &> /dev/null
then
    function y() {
    	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    	command yazi "$@" --cwd-file="$tmp"
    	IFS= read -r -d '' cwd < "$tmp"
    	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    	rm -f -- "$tmp"
        # Restore cursor to I-beam
        printf '\e[5 q'
    }
fi

############################################################################
##  Key bindings
############################################################################

cls() {
    clear
    terminal_colors
    echo
}

# Ctrl + L to 'clear' command
bind -x '"\C-l": "cls"'

############################################################################
##  Functions
############################################################################
this() {
    printf "        Host: ${bold}$HOSTNAME${reset}\n"
    printf "          OS: ${bold}$(lsb_release -d | awk -F : '{print $2}' | xargs)${reset}\n"
    printf "Architecture: ${bold}$(uname -m)${reset}\n"
    printf "      Kernel: ${bold}$(uname -sr)${reset}\n"
    printf "       Shell: ${bold}BASH $BASH_VERSION${reset}\n"
}

terminal_colors() {
    # Author: GekkoP
    cat << EOF

${redf}█${reset}${redb}█ ${greenf}█${greenb}█ ${yellowf}█${yellowb}█ ${bluef}█${blueb}█ ${purplef}█${purpleb}█ ${cyanf}█${cyanb}█
${redf}█${reset}${redb}█ ${greenf}█${greenb}█ ${yellowf}█${yellowb}█ ${bluef}█${blueb}█ ${purplef}█${purpleb}█ ${cyanf}█${cyanb}█
${redf}█${reset}${redb}█ ${greenf}█${greenb}█ ${yellowf}█${yellowb}█ ${bluef}█${blueb}█ ${purplef}█${purpleb}█ ${cyanf}█${cyanb}█
${redf}█${reset}${redb}█ ${greenf}█${greenb}█ ${yellowf}█${yellowb}█ ${bluef}█${blueb}█ ${purplef}█${purpleb}█ ${cyanf}█${cyanb}█
${redf}█${reset}${redb}█ ${greenf}█${greenb}█ ${yellowf}█${yellowb}█ ${bluef}█${blueb}█ ${purplef}█${purpleb}█ ${cyanf}█${cyanb}█ ${reset}
EOF
}

# Add shortcut to Yazi - if available
if type yazi &> /dev/null; then
    y() {
    	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    	yazi "$@" --cwd-file="$tmp"
    	IFS= read -r -d '' cwd < "$tmp"
    	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    	rm -f -- "$tmp"
    }
fi

is_ssh_session() {
  local pid=$PPID
  while [[ "$pid" -gt 1 ]]; do
    local comm
    comm=$(ps -o comm= -p "$pid" 2>/dev/null) || break
    case "$comm" in
      sshd|ssh)
        return 0
        ;;
      *)
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        ;;
    esac
  done
  return 1
}

set_prompt() {
    local LAST_RUN_COMMAND_STATUS=$?
    local STATUS_INDICATOR="🅱 🅰 🆂 🅷 "
    local PROMPT_INDICATOR=" ➤ "

    if [[ -n "$TTY_MODE" ]]; then
        STATUS_INDICATOR="BASH"
        PROMPT_INDICATOR=" >> "
    fi

    if [[ $EUID -eq 0 ]]; then
        PROMPT_INDICATOR=" ${bold}${redbg}${white_fg}ROOT${reset}${redb}${reset} "
    fi

    local prompt="\n"

    if is_ssh_session; then
        prompt+="${bold}${purplebg}${whiteb}SSH${reset}${purplef}${reset} "
    fi

    prompt+="${bold}${purpleb}${SHLVL}${reset}┊${yellowb}${STATUS_INDICATOR} "
    prompt+="${whitef}$(pwd)${reset}"

    if [[ $LAST_RUN_COMMAND_STATUS -gt 0 ]]; then
        prompt+=" ${bold}${redb}[${LAST_RUN_COMMAND_STATUS}]${reset}"
    fi

    # Prompt symbol
    prompt+="${bold}${brwhite}${PROMPT_INDICATOR}${reset}"

    PS1="$prompt"
}

##  Startup actions
terminal_colors
PROMPT_COMMAND=set_prompt
