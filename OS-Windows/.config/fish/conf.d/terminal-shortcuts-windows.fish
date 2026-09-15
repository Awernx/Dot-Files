#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------
# Chander's FISH shell customizations for Windows

# Set MSYS2's home directory to Windows home directory
# Update /etc/nsswitch.conf, and set "db_home: windows"

set --export --global HOST_SHORT_NAME (hostname)
set --export --global HOST_FULL_NAME $HOST_SHORT_NAME

if not set -q OS_ICON
    set --export --global OS_ICON '⊞ '
end

##  Aliases --------------------------------------
alias pwd     'pwd -P'
alias upgrade 'scoop update --all; scoop cleanup --all; scoop cache rm --all'
