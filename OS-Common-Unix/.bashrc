# If BASH is not running interactively, return immediately
# and stop loading additional scripts
case $- in
    *i*) ;;
      *) return;;
esac

# XDG (Just in case they're not set already)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Move bash & less history file to XDG directory
history_location=$XDG_STATE_HOME/history
mkdir -p $history_location

export HISTCONTROL=ignoreboth:erasedups
export HISTFILE=$history_location/bash_history
export LESSHISTFILE=$history_location/less_history
# Internal variables used exclusively by Bash shell process and
# does not pass them down to sub-processes or external programs
HISTSIZE=1000
HISTFILESIZE=2000

# Pattern "**" used in a pathname expansion context will match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable Tab completions, if available
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Load homebrew env if installed
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Source custom bash configuration scripts if they exist
if [ -d "$XDG_CONFIG_HOME/bash" ]; then
  for script in "$XDG_CONFIG_HOME/bash"/*; do
      source "$script"
  done
  unset script
fi

#Initialize these staple tools - if they are found
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi

if command -v mcfly >/dev/null 2>&1; then
    eval "$(mcfly init bash)"
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi
