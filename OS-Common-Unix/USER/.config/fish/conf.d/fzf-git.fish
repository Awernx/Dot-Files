#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# FISH shell shortcuts for GIT specific fzf utilities

# Don't load this script for non-interactive shells
status is-interactive; or exit 0

function require_git_repo --description 'Check if directory is a git repository'
    if not command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        exit_with_error "This directory is not a git repository" >&2
        return 1
    end
end

# #########################################################################################
# All GIT related fzf shortcuts start with Alt + G, followed by the relevant character
# Shortcut keys - Alt + G, ..........
# #########################################################################################

# -----------------------------------------------------------------------------------------
# Select a local git branch to checkout into
# Shortcut key - Alt + G followed by Alt +B
# -----------------------------------------------------------------------------------------
bind alt-g,alt-b gb
function gb --description 'Pick a git branch to checkout into'
    require_git_repo; or return 1

    set --local current (command git symbolic-ref --quiet --short HEAD 2>/dev/null)

    set --local branches (command git for-each-ref --format='%(refname:short)' refs/heads)

    if test (count $branches) -le 1
        exit_with_error 'No other git branches available to switch to'
        return 1
    end

    set --local selection (
        printf '%s\n' $branches |
        string match -v -- "$current" |
        fzf $fzf_window_options --prompt='Select a git branch to switch to ➤ '
    )

    if test -n "$selection"
        command git switch "$selection"
    end

    exit_with_repaint
end

# -----------------------------------------------------------------------------------------
# Select a commit to HARD RESET to
# Shortcut key - Alt + G followed by Alt +R
# -----------------------------------------------------------------------------------------
bind alt-g,alt-r gr
function gr --description 'Pick a git commit to HARD reset to'
    require_git_repo; or return 1

    set --local selection (
        git log --pretty=format:"%h │ %ad │ %s" --date=format:'%b %d %H:%M:%S' | \
        fzf $fzf_common_options --prompt="git> " \
            --prompt='Pick a git commit to HARD reset to ➤ ' \
            --preview 'git show --color=always {1}'
    )

    if test -n "$selection"
        set --local commit_id (string split -m 1 ' ' -- $selection)[1]
        command git reset --hard $commit_id
    end

    exit_with_repaint
end
