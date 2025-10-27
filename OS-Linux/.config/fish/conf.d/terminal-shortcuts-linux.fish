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

set --export --global OS $OS_ICON ' ' (lsb_release -d | awk -F : '{print $2}' | string trim)

## Abbreviations-----------------------
abbr shutdown 'sudo /sbin/shutdown -h now'
abbr reboot   'sudo /sbin/reboot'

##  Aliases ---------------------------
alias listening_ports 'ss -tupln | awk -f $PORTS_AWK_FILE | column -t'
alias clk             'watch --no-title --precise --interval 0.1 '"'"'date +"%A %B %d, %Y %I:%M:%S,%N %p %Z"'"'"''
alias time_stat       'systemctl status systemd-timesyncd.service'
alias time_sync       'sudo timedatectl set-ntp off; sudo timedatectl set-ntp on'
alias partitions      'lsblk -no "NAME,LABEL,SIZE,FSTYPE,MOUNTPOINT"'
