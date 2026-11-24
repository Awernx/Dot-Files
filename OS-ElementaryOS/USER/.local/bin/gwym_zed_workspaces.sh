#!/bin/sh
set -eu

WORKSPACE="$HOME/Workspace"

choice=$(
    for dir in "$WORKSPACE"/*/; do
        if [ -d "$dir" ]; then
            basename "$dir"
        fi
    done | sort | gwym -i -p "Zed Workspace" --style "$HOME/.config/gwym/tokyo_night_storm.css"
) || exit 0

[ -z "$choice" ] && exit 0

nohup flatpak run dev.zed.Zed "$WORKSPACE/$choice" >/dev/null 2>&1 &
