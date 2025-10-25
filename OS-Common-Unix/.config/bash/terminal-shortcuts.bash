#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------
# Chander's BASH shell shortcuts for Linux

# XDG (Just in case they're not set already)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# formatting
reset=$(tput sgr0)
bold=$(tput bold)
dim=$(tput dim)

# foreground colors
blackf=$(tput setaf 0)
redf=$(tput setaf 1)
greenf=$(tput setaf 2)
yellowf=$(tput setaf 3)
bluef=$(tput setaf 4)
purplef=$(tput setaf 5)
cyanf=$(tput setaf 6)
whitef=$(tput setaf 7)

# bright foreground colors
blackb=$(tput setaf 8)
redb=$(tput setaf 9)
greenb=$(tput setaf 10)
yellowb=$(tput setaf 11)
blueb=$(tput setaf 12)
purpleb=$(tput setaf 13)
cyanb=$(tput setaf 14)
whiteb=$(tput setaf 15)

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

# Ctrl + B --> launch 'broot' if it is installed
if type broot &> /dev/null
then 
    bind -x '"\C-b": "broot"'
fi

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