#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# Chander's FISH shell shortcuts for fzf functions & utilities

# Don't load this script for non-interactive shells
status is-interactive; or exit 0

# #########################################################################################
# All Unix related fzf shortcuts start with Alt + U, followed by the relevant character
# Shortcut keys - Alt + U, ..........
# #########################################################################################

# -----------------------------------------------------------------------------------------
# List systemd processes
# Shows 'Enabled' status, and service status as previews
# Shortcut key - Alt + U followed by Alt + Y
# -----------------------------------------------------------------------------------------
bind alt-u,alt-y sysdf
function sysdf --description 'Systemd services browser'
    if not type -q systemctl
        exit_with_error "systemd listing not supported on this OS"
        return 1
    end

    set --local selection (
        {
            echo "SERVICE Ignore STATE SUB-STATE"
            script -qec "systemctl list-units --type=service --all --plain --no-legend --no-pager" /dev/null
        } | grep -v '^systemd' | column -t \
        | fzf $fzf_common_options \
            --ansi --header-lines=1 --with-nth=1,3,4 --preview-window=right:50%:wrap \
            --preview 'SYSTEMD_COLORS=1 systemctl status {1} --lines=0 --no-pager'
    )

    if test -n "$selection"
        set --local service (echo $selection | string split -f1 " ")
        clear
        journalctl --no-tail --follow --no-pager -u $service | bat --style=grid,numbers --paging=never --language log
    end

    exit_with_repaint
end

# -----------------------------------------------------------------------------------------
# List attached block devices
# Shows 'Enebled' status, and service status as previews
# Shortcut key - Alt + U followed by Alt + D
# -----------------------------------------------------------------------------------------
bind alt-u,alt-d disksf
function disksf --description 'Block devices browser'
    if not type -q lsblk
        exit_with_error "Disk listing not supported on this OS"
        return 1
    end

    disks | fzf $fzf_window_options --ansi --header-lines=1 --preview-window=right:60%:wrap \
        --preview 'lsblk -e 7 -o "NAME,SIZE,FSTYPE,MOUNTPOINT,FSUSE%" /dev/{1}'

    exit_with_repaint
end
