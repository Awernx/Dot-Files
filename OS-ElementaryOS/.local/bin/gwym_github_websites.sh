#!/bin/sh
set -eu

WORKSPACE="$HOME/Workspace"

# List subdirectories in ~/Workspace
choice=$(
    for dir in "$WORKSPACE"/*/; do
        if [ -d "$dir/.git" ]; then
            basename "$dir"
        fi
    done | sort | gwym -i -p "GitHub Repo" --style "$HOME/.config/gwym/github.css"
) || exit 0

[ -z "$choice" ] && exit 0

remote_url=$(git -C "$WORKSPACE/$choice" remote get-url origin 2>/dev/null || true)

if [ -z "$remote_url" ]; then
    printf "No 'origin' remote found for %s\n" "$choice" >&2
    exit 1
fi

# Convert SSH (git@github.com:user/repo.git) or trailing .git into a clean HTTPS URL
web_url=$(printf '%s' "$remote_url" | sed -E '
    s|^git@([^:]+):|https://\1/|
    s|^ssh://git@([^/]+)/|https://\1/|
    s|\.git$||
')

nohup xdg-open "$web_url" >/dev/null 2>&1 &
