# If BASH is not running interactively, return immediately
# and stop loading additional scripts
case $- in
    *i*) ;;
      *) return;;
esac

# Adds 'brew' to PATH
# Needs to be executed first thing, so tools can be discovered by other scripts
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Drop to Fish if BASH is requested at shell level 1 AND in an interactive mode
source ~/.config/bash/use-fish-for-interactive-shell.bash

# Move bash & less history file to XDG directory
history_location=~/.local/state/history
mkdir --parents $history_location

export HISTCONTROL=ignoreboth:erasedups
export HISTFILE=$history_location/bash_history
export LESSHISTFILE=$history_location/less_history

source ~/.config/bash/terminal-shortcuts.bash
source ~/.config/bash/terminal-shortcuts-linux-debian.bash

eval "$(fzf    --bash)"
eval "$(mcfly  init bash)"
eval "$(direnv hook bash)"
eval "$(zoxide init bash)"
