#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------
# Chander's BASH shell shortcuts for Linux

# XDG (Just in case they're not set already)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Color Controls        # Foreground Colors            # Bright Foreground Colors
reset=$(tput sgr0)      blackf=$(tput setaf 0)         blackb=$(tput setaf 8)
bold=$(tput bold)       redf=$(tput setaf 1)           redb=$(tput setaf 9)
dim=$(tput dim)         greenf=$(tput setaf 2)         greenb=$(tput setaf 10)
                        yellowf=$(tput setaf 3)        yellowb=$(tput setaf 11)
                        bluef=$(tput setaf 4)          blueb=$(tput setaf 12)
                        purplef=$(tput setaf 5)        purpleb=$(tput setaf 13)
                        cyanf=$(tput setaf 6)          cyanb=$(tput setaf 14)
                        whitef=$(tput setaf 7)         whiteb=$(tput setaf 15)

gui_shell_indicator="🅱 🅰 🆂 🅷 "

############################################################################
##  Aliases 
############################################################################
alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color=always'
alias path='echo -e ${PATH//:/\\n}'
alias ping='ping -c 5 -s.2'
alias clear='/usr/bin/clear; terminal_colors'
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
    alias l='ls -AgFth --color=always --group-directories-first'
    alias ll='ls -AgFth --color=never --group-directories-first'
fi

if type bat &> /dev/null
then 
    alias cat="bat --style=plain --color=always"
fi

############################################################################
##  Key bindings 
############################################################################

# Ctrl + L to 'clear' command
bind -x '"\C-l": "clear; echo "'

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

title() {
    printf "\033]0;$1 [$USER@$HOSTNAME]\007"
}

terminal_colors() {
    # Author: GekkoP
    # Source: http://linuxbbq.org/bbs/viewtopic.php?f=4&t=1656#p33189     
    cat << EOF

 ${redf}███${reset}${redb}▄ ${reset} ${greenf}███${reset}${greenb}▄ ${reset} ${yellowf}███${reset}${yellowb}▄ ${reset} ${bluef}███${reset}${blueb}▄ ${reset} ${purplef}███${reset}${purpleb}▄ ${reset} ${cyanf}███${reset}${cyanb}▄ ${reset}
 ${redf}███${reset}${redb}█ ${reset} ${greenf}███${reset}${greenb}█ ${reset} ${yellowf}███${reset}${yellowb}█ ${reset} ${bluef}███${reset}${blueb}█ ${reset} ${purplef}███${reset}${purpleb}█ ${reset} ${cyanf}███${reset}${cyanb}█ ${reset}
 ${redf}███${reset}${redb}█ ${reset} ${greenf}███${reset}${greenb}█ ${reset} ${yellowf}███${reset}${yellowb}█ ${reset} ${bluef}███${reset}${blueb}█ ${reset} ${purplef}███${reset}${purpleb}█ ${reset} ${cyanf}███${reset}${cyanb}█ ${reset}
 ${redf} ${reset}${redb}▀▀▀ ${reset} ${greenf} ${reset}${greenb}▀▀▀ ${reset} ${yellowf} ${reset}${yellowb}▀▀▀ ${reset} ${bluef} ${reset}${blueb}▀▀▀ ${reset} ${purplef} ${reset}${purpleb}▀▀▀ ${reset} ${cyanf} ${reset}${cyanb}▀▀▀ ${reset}
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

set_prompt() {
    LAST_RUN_COMMAND_STATUS=$?
    STATUS_INDICATOR=''
    if [ ${LAST_RUN_COMMAND_STATUS} -gt 0 ]
    then
        STATUS_INDICATOR=' ('${LAST_RUN_COMMAND_STATUS}')'
    fi

    PROMPT_INDICATOR=">>"
    if [[ $EUID -eq 0 ]]; then
        PROMPT_INDICATOR="!!"
        PREFIX="╦═╗╔═╗╔═╗╔╦╗ 
╠╦╝║ ║║ ║ ║   
╩╚═╚═╝╚═╝ ╩
"
    fi

    if [[ -z $TTY_MODE ]]; then
        PROMPT_INDICATOR="➤"
        if [[ $EUID -eq 0 ]]; then
            PROMPT_INDICATOR="⚠️"
        fi
    fi

    if [[ -z $TTY_MODE ]] && ([[ -z $SHELL_INDICATOR ]] || [[ $gui_shell_indicator == $SHELL_INDICATOR ]]) ; then
        SHELL_INDICATOR=$gui_shell_indicator
    else
        SHELL_INDICATOR="B.A.S.H"
    fi

    SHELL_LEVEL="[${cyanb}${bold}$SHLVL${reset}] "

    PS1="\n${PREFIX}${yellowb}${bold}$SHELL_INDICATOR${reset} $SHELL_LEVEL${dim}\$(pwd)${redb}${STATUS_INDICATOR}${reset} ${bold}$PROMPT_INDICATOR${reset} "
}

##  Startup actions
title
terminal_colors
PROMPT_COMMAND=set_prompt