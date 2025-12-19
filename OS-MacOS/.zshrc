# Set the history file location to obey the XDG spec
export HISTFILE=$XDG_STATE_HOME/zsh/history
[[ ! -d "$XDG_STATE_HOME/zsh" ]] && mkdir -p "$XDG_STATE_HOME/zsh"

export PATH="/opt/homebrew/bin:$PATH"

source ~/.config/zsh/terminal-shortcuts-macos.zsh
