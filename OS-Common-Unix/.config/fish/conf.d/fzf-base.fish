#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# Base file for all fzf functions & utilities

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

# Miminal style; short window with a border
# '+' key toggle preview
# Filter option is at the top, with the list reversed - recent results at the top
set --global fzf_common_options --height=1% --reverse --info=hidden --border --margin=1 --padding=1 --bind 'ctrl-space:toggle-preview' --style minimal

# Workaround known fish-shell bug with interactive exits
function exit_with_repaint
    commandline -f repaint
end

function exit_with_error
    set_color red >&2
    echo "‼️ $argv" >&2
    set_color normal >&2

    # Force a newline so the repainted prompt appears BELOW the error
    echo "" >&2

    exit_with_repaint
end
