# If BASH is not running interactively, return immediately
# and stop loading additional scripts
case $- in
    *i*) ;;
      *) return;;
esac

# Move bash history file to XDG directory
history_location=~/.local/state/bash
mkdir -p $history_location
export HISTFILE=$history_location/history
export HISTCONTROL=ignoreboth:erasedups

# Add Homebrew to the PATH, required for fish, fzf, etc.
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin

# Drop to fish shell for interactive shell,
# or when bash is requested at SHELL LEVEL 2
source ~/.config/bash/use-fish-for-interactive-shell.bash

source ~/.config/bash/terminal-shortcuts.bash
source ~/.config/bash/terminal-shortcuts-linux-debian.bash

eval "$(fzf --bash)"
