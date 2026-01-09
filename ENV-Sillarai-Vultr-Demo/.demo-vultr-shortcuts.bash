#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------
# Chander's BASH shell shortcuts for DEMO

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

alias l='ls -AgFth --color=always --group-directories-first'
alias ll='ls -AgFth --color=never --group-directories-first'

alias app='dash /opt/sillarai_network/app_control.sh'

alias drm='docker image rm -f'                              # Remove a specific image (pass image id)
alias dclean='docker image prune --force; docker container prune --force; docker network prune --force' # Removes dangling images, stopped containers and unused networks
alias dpurge='docker system prune --all --volumes --force'  # "dclean" + unused images and anonymous volumes

############################################################################
##  Key bindings
############################################################################

# Ctrl + L to 'clear' command
bind -x '"\C-l": "clear; echo "'

############################################################################
##  Functions
############################################################################
# --- help text for the docker shortcuts ---
dhelp() {
    printf '\n🐳 DOCKER shortcuts\n\n'
    printf 'dl     --> Lists all images and containers\n'
    printf 'drm    --> Removes a specific image - pass image id as param\n'
    printf 'dclean --> Removes dangling images, stopped containers and unused networks \n'
    printf 'dpurge --> All of "dclean" + unused images and anonymous volumes \n'
}

this() {
    printf "        Host: ${bold}$HOSTNAME${reset}\n"
    printf "          OS: ${bold}$(lsb_release -d | awk -F : '{print $2}' | xargs)${reset}\n"
    printf "Architecture: ${bold}$(uname -m)${reset}\n"
    printf "      Kernel: ${bold}$(uname -sr)${reset}\n"
    printf "       Shell: ${bold}BASH $BASH_VERSION${reset}\n"
}

dl() {
    printf '📸 I M A G E S\n'
    printf '==========================================================================\n'
    docker images

    printf '\n🐳 C O N T A I N E R S\n'
    printf '==========================================================================\n'
    docker container ls -a

    printf '\n🛜 N E T W O R K S\n'
    printf '==========================================================================\n'
    docker network ls
}

terminal_colors() {
    cat << EOF

▗▄▄▄ ▗▄▄▄▖▗▖  ▗▖ ▗▄▖     ▗▖  ▗▖▗▖ ▗▖▗▖ ▗▄▄▄▖▗▄▄▖
▐▌  █▐▌   ▐▛▚▞▜▌▐▌ ▐▌    ▐▌  ▐▌▐▌ ▐▌▐▌   █  ▐▌ ▐▌
▐▌  █▐▛▀▀▘▐▌  ▐▌▐▌ ▐▌    ▐▌  ▐▌▐▌ ▐▌▐▌   █  ▐▛▀▚▖
▐▙▄▄▀▐▙▄▄▖▐▌  ▐▌▝▚▄▞▘     ▝▚▞▘ ▝▚▄▞▘▐▙▄▄▖█  ▐▌ ▐▌
${redf}▄▄▄▄${redb}▄▄▄▄${purplef}▄▄▄▄${purpleb}▄▄▄▄▄${yellowf}▄▄▄▄${yellowb}▄▄▄▄${greenf}▄▄▄▄${greenb}▄▄▄▄${cyanf}▄▄▄▄${cyanb}▄▄▄▄${blueb}▄▄▄▄${bluef}▄▄▄▄${reset}
EOF
}

title() {
    printf "\033]0;$1 [$USER@$HOSTNAME]\007"
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
    fi

    if [[ -z $TTY_MODE ]]; then
        PROMPT_INDICATOR="➤"
    fi

    if [[ -z $TTY_MODE ]] && ([[ -z $SHELL_INDICATOR ]] || [[ $gui_shell_indicator == $SHELL_INDICATOR ]]) ; then
        SHELL_INDICATOR=$gui_shell_indicator
    else
        SHELL_INDICATOR="B.A.S.H"
    fi

    SHELL_LEVEL="[${cyanf}${bold}$SHLVL${reset}] "

    PS1="\n${yellowf}${bold}$SHELL_INDICATOR${reset} $SHELL_LEVEL${dim}\$(pwd)${redf}${STATUS_INDICATOR}${reset} ${bold}$PROMPT_INDICATOR${reset} "
}

##  Startup actions
title
terminal_colors
PROMPT_COMMAND=set_prompt
