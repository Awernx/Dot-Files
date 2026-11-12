#!/usr/bin/env zsh

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------------
# Chander's Z-shell customizations for Mac & BSD

##  Prompt
terminal_colors() {
    rows=(
      ' \e[31m██████████████████' # Dark Red
      ' \e[91m██████████████████' # Light Red
      ' \e[33m              ████' # Dark Yellow
      ' \e[93m            ████'   # Light Yellow
      ' \e[32m          ████'     # Dark Green
      ' \e[92m        ████'       # Light Green
      ' \e[36m      ████'         # Dark Cyan
      ' \e[96m    ████'           # Light Cyan
      ' \e[34m  ████'             # Dark Blue
      ' \e[94m████'               # Light Blue
      ' \e[35m██████████████████' # Dark Purple
      ' \e[95m██████████████████' # Light Purple
    )

    echo
    for row in "${rows[@]}"; do
      print -- "${row}\e[0m"
    done
}

terminal_colors
PROMPT='$GREETING'

setopt prompt_subst
function precmd() {
    GREETING=$'\n%B%F{#c678dd}%L%f%b┊%B%F{#e5c07b}🆉  %F{#5c6370}%/%f %B%F{#ffffff}➤ %f%b'
}

cls() {
    clear
    terminal_colors
    echo
    zle && zle reset-prompt
}

# Register the function as a ZLE widget and bind it to Ctrl + L
zle -N cls
bindkey '^L' cls

##  Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias path='echo -e ${PATH//:/\\n}'

if (( $+commands[eza] )); then
    local eza_opts='eza -almM --classify=always --color-scale=size --group-directories-first --sort=name --time-style=long-iso'
    alias l="$eza_opts"
    alias ll="$eza_opts -ghU@"
    alias lt="$eza_opts --tree"
else
    alias l='ls -AgFthG'
fi

if (( $+commands[zoxide] )); then
    alias cd="z"
fi

if (( $+commands[bat] )); then
    export MANROFFOPT="-c"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"

    alias cat="bat --plain --paging=never"
    alias bat="bat --style=grid,numbers,header-filesize"

    # Global ZSH alias override for 'help' option
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
fi

if (( $+commands[yazi] )); then
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
