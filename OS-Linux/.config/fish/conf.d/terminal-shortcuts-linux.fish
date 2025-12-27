#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ----------------------------------------------
# Chander's FISH shell customizations for Linux

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

if not set -q OS_ICON
    set --export --global OS_ICON '🐧'
end

# Evaluate OS
if not set -q OS
    cat /etc/os-release | string replace -r '^([^#]\w+)=(.*)' 'set $1 $2' | source

    # Convert VERSION_CODENAME to Title Case
    if set -q VERSION_CODENAME
        set -l words (string match -r '\S+' -- $VERSION_CODENAME)
        set -l result
        for w in $words
            set result $result (string upper (string sub -l 1 -- $w))(string sub -s 2 -- $w)
        end
        set VERSION_CODENAME (string join ' ' -- $result)
    end

    if not string match -qi "*$VERSION_CODENAME*" "$VERSION"
        set --export --global OS "🐧 $NAME $VERSION ($VERSION_CODENAME)"
    else
        set --export --global OS "🐧 $NAME $VERSION"
    end
end

## Abbreviations-----------------------
abbr shutdown 'sudo /sbin/shutdown -h now'
abbr reboot   'sudo /sbin/reboot'

##  Aliases ---------------------------
alias listening_ports 'ss -tupln | awk -f $PORTS_AWK_FILE | column -t'
alias clk             'watch --no-title --precise --interval 0.1 '"'"'date +"%A %B %d, %Y %I:%M:%S,%N %p %Z"'"'"''
alias time_stat       'systemctl status systemd-timesyncd.service'
alias time_sync       'sudo timedatectl set-ntp off; sudo timedatectl set-ntp on'
alias partitions      'lsblk -no "NAME,LABEL,SIZE,FSTYPE,MOUNTPOINT"'
