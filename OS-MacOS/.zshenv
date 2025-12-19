# Set XDG Base Directories if not already set
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:=$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:=$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:=$HOME/.local/state}

# Disable Zsh's session restoration feature that creates a ~/.zsh_sessions
export SHELL_SESSIONS_DISABLE=1
