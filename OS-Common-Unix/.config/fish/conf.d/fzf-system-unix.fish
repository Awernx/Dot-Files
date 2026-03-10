#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# Chander's FISH shell shortcuts for fzf functions & utilities

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

# #########################################################################################
# All Unix related fzf shortcuts start with Alt + U, followed by the relevant character
# Shortcut keys - Alt + U, ..........
# #########################################################################################

# -----------------------------------------------------------------------------------------
# List systemd processes
# Shows 'Enebled' status, and service status as previews
# Shortcut key - Alt + U, D
# -----------------------------------------------------------------------------------------
bind \eud sysd
function sysd --description 'Systemd services browser'
    if not type -q systemctl
        exit_with_error "This OS doesn't support 'systemd' services"
        return 1
    end

    set --local selection (
        {
        echo "SERVICE Ignore STATE SUB-STATE"
        systemctl list-units --type=service --all --plain --no-legend --no-pager
        } | grep -v '^systemd' | column -t \
        | fzf $fzf_common_options \
            --header-lines=1 --with-nth=1,3,4 --preview-window=right:50%:wrap \
            --preview '
                desc=$(echo {5..} | xargs)
                printf "\033[1;33m%s\033[0m%s\n\n" "$desc"
                {
                    printf "\033[0;36m%s %s %s\033[0m\n" "SERVICE_FILE" "START_UP" "PRESET"
                    printf "\033[1;37m"
                    systemctl list-unit-files --no-legend {1}
                    printf "\033[0m"
                } | column -t
                systemctl status {1} --lines=0 --no-pager | tail -n +2
            '
    )

    if test -n "$selection"
        set --local service (echo $selection | awk '{print $1}')
        command journalctl -u $service -f | fzf --tac --reverse
    end

    exit_with_repaint
end
