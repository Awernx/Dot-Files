# If BASH is not running interactively, return immediately
# and stop loading additional scripts
case $- in
    *i*) ;;
      *) return;;
esac

# Move bash & less history file to XDG directory
history_location=~/.local/state/history
mkdir -p $history_location

export HISTCONTROL=ignoreboth:erasedups
export HISTFILE=$history_location/bash_history
export LESSHISTFILE=$history_location/less_history

# Drop to fish shell for interactive shell,
# or when bash is requested at SHELL LEVEL 2
source ~/.config/bash/use-fish-for-interactive-shell.bash

source ~/.config/bash/terminal-shortcuts.bash
source ~/.config/bash/terminal-shortcuts-linux-debian.bash

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(fzf --bash)"
