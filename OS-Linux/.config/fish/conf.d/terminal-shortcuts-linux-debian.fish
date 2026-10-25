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
abbr sw       'home-manager switch'

function upgrade
    sudo -v

    echo "Upgrading 'Apt' packages"
    apt update
    apt --yes full-upgrade

    if type -q nix
        cd ~/.config/home-manager
        nix flake update
        home-manager switch --flake .
        cd -
    end

    if type -q flatpak
        echo
        echo "Upgrading 'Flatpak' packages"
        flatpak update
    end

    if type -q brew
        echo
        echo "Upgrading 'Homebrew' packages"
        brew update
        yes | brew upgrade --greedy
    end
end

function clean
    sudo -v

    echo "Cleaning 'Apt' packages"
    apt --yes autoremove
    apt --yes autoclean

    if type -q nix
        home-manager expire-generations "-1 days"
        nix-collect-garbage --delete-older-than 1d
    end

    if type -q flatpak
        echo
        echo "Cleaning 'Flatpak' packages"
        flatpak uninstall --unused -y
    end

    if type -q brew
        echo
        echo "Cleaning 'Homebrew' packages"
        brew doctor
        brew autoremove
        brew cleanup --prune=all
    end
end
