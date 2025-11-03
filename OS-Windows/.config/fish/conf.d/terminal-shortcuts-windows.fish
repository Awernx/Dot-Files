#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------
# Chander's FISH shell customizations for Windows

set --export --global HOST_SHORT_NAME (hostname)
set --export --global HOST_FULL_NAME $HOST_SHORT_NAME

if not set -q OS_ICON
    set --export --global OS_ICON '⊞ '
end

##  Aliases --------------------------------------
alias upgrade 'scoop update --all'
alias clean   'scoop cleanup --all; scoop cache rm --all'
