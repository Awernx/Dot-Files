# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ----------------------------------------------------------------------------------------------
# This file is read only for interactive shells (when a human opens a terminal window or prompt)
# Zsh does not read .zshrc for non-interactive shells

# Set the history file location to obey the XDG spec
export HISTFILE=$XDG_STATE_HOME/zsh/history
[[ ! -d "$XDG_STATE_HOME/zsh" ]] && mkdir -p "$XDG_STATE_HOME/zsh"

# Load Homebrew if it is available
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Load all available .zsh scripts from config folder
for file in "$XDG_CONFIG_HOME"/zsh/*.zsh(N); do
    source "$file"
done

# Load these staple tools if they're available
(( $+commands[fzf] ))    && eval "$(fzf   --zsh)"
(( $+commands[mcfly] ))  && eval "$(mcfly init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
