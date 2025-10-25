#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# --------------------------------------------------------
# Chander's FISH shell shortcuts for Debian-based distros

# IMPORTANT: Do not load this script for non-interactive shells
if not status is-interactive
    exit 0
end

##  Aliases ---------------------------
alias apt     'sudo apt'

## Abbreviations-----------------------
abbr install  'apt update && apt --yes install'
abbr purge    'apt --yes purge'

function upgrade
  echo "Upgrading 'Apt' packages"
  apt update
  apt --yes full-upgrade

  if type -q flatpak
    echo 
    echo "Upgrading 'Flatpak' packages"
    flatpak update
  end

  if type -q brew
    echo 
    echo "Upgrading 'Homebrew' packages"
    brew update
    brew upgrade --formula
    brew upgrade --cask --greedy
  end

end

function clean
  echo "Cleaning 'Apt' packages"
  apt --yes autoremove
  apt --yes clean

  if type -q brew
    echo 
    echo "Cleaning 'Homebrew' packages"
    brew autoremove
    brew cleanup --prune=all
    brew doctor
  end

end
