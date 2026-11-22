#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------------
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

function upgrade --description "Update MSYS2 packages"
    if type -q pacman
        echo -e "\n🔄 Updating MSYS2 packages..."
        pacman -Syu --noconfirm

        set -l orphans (pacman -Qdtq)
        if test -n "$orphans"
            echo -e "🧹 Removing orphaned packages..."
            pacman -Rns --noconfirm $orphans
        end

        echo -e "🧹 Cleaning up MSYS2 package cache..."
        pacman -Sc --noconfirm

        echo -e "\n✅ MSYS2 updates and cleanup complete!"
    end
end
