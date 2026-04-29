#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# FISH shell shortcuts for GIT specific fzf utilities

# Don't load this script for non-interactive shells
status is-interactive; or exit 0

# -----------------------------------------------------------------------------------------
# List of applications, their path and bundle ids
# Shortcut key - Alt + A
# -----------------------------------------------------------------------------------------
bind alt-a appsf
function appsf --description 'List applications and their bundle id'
    {
        printf "%s\t%s\t%s\t%s\n" "APP" "PATH" "TYPE" "BUNDLE_ID"
        scan_apps /Applications "System"
        scan_apps /System/Applications "System"
        scan_apps ~/Applications "User"
    } | column -t -s \t \
    | fzf $fzf_common_options --header-lines=1 --prompt='Pick an application ➤ '

    exit_with_repaint
end

function scan_apps
    set DIR $argv[1]
    set TYPE $argv[2]

    if not test -d $DIR
        return
    end

    for APP in (find $DIR -maxdepth 1 -type d -name "*.app" 2>/dev/null)
        set NAME (basename $APP .app)

        # Try to read bundle ID
        set BUNDLE_ID (defaults read "$APP/Contents/Info" CFBundleIdentifier ^/dev/null)

        if test -z "$BUNDLE_ID"
            set BUNDLE_ID "N/A"
        end

        printf "%s\t%s\t%s\t%s\n" "$NAME" "$APP" "$TYPE" "$BUNDLE_ID"
    end
end
