#!/usr/bin/env zsh

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------------
# Chander's Z-shell customizations for Mac & BSD

## Local variables
dim=$'\e[2m'
newline=$'\n'
bold=$(tput bold)
normal=$(tput sgr0)

##  Prompt
PROMPT='$GREETING'

setopt prompt_subst
function precmd() {
	GREETING="${newline}${bold}$SHLVL┊🅉 ${normal} ${dim}$PWD${normal} ${bold}➤ ${normal}"
}

##  Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias path='echo -e ${PATH//:/\\n}'

if type eza &> /dev/null
then
    LS_COMMAND='eza -almM --classify=always --color-scale=size --group-directories-first --sort=name --time-style=long-iso'
    alias l="${LS_COMMAND}"
    alias ll="${LS_COMMAND} -ghU@"
    alias lt="${LS_COMMAND} --tree"
else
    alias l="ls -AgFthG"
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

    # Global ZSH alias override for 'help' option
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
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

this() {
	printf "        User: ${bold}$USER${normal}\n"
	printf "    Hostname: ${bold}$HOST${normal}\n"
    printf "Architecture: ${bold}$(uname -m)${normal}\n"
    printf "       macOS: ${bold}$(sw_vers -productVersion)${normal} $(grep -oE 'SOFTWARE LICENSE AGREEMENT FOR macOS [A-Z]*[a-z]*' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | awk -F 'macOS ' '{print $NF}') \n"
    printf "      Kernel: ${bold}$(uname -sr)${normal}\n"
	printf "       Shell: ${bold}Z-Shell $ZSH_VERSION${normal}\n"
}
