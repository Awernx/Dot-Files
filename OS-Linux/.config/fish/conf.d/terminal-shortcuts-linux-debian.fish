#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# --------------------------------------------------------
# Chander's FISH shell shortcuts for Debian-based distros

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

##  Aliases ---------------------------
alias apt     'sudo apt'

## Abbreviations-----------------------
abbr install  'apt update && apt --yes install'
abbr purge    'apt --yes purge'

function upgrade
    sudo -v

    echo "Upgrading 'Apt' packages"
    apt update
    apt --yes full-upgrade

    echo "Cleaning 'Apt' packages"
    apt --yes autoremove
    apt --yes autoclean

    if type -q flatpak
        echo
        echo "Upgrading 'Flatpak' packages"
        flatpak update

        echo "Cleaning 'Flatpak' packages"
        flatpak uninstall --unused -y
    end

    if type -q brew
        echo
        echo "Upgrading 'Homebrew' packages"
        brew update
        brew upgrade --formula
        brew upgrade --cask --greedy

        echo
        echo "Cleaning 'Homebrew' packages"
        brew doctor
        brew autoremove
        brew cleanup --prune=all
    end
end
