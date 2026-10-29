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
alias clk             'watch --no-title --precise --interval 0.1 '"'"'date +"%A %B %d, %Y %I:%M:%S,%N %p %Z"'"'"''
alias time_stat       'systemctl status systemd-timesyncd.service'
alias time_sync       'sudo timedatectl set-ntp off; sudo timedatectl set-ntp on'
alias mounts          'df -h --output=target,source,fstype,size,used,avail --exclude-type=tmpfs --exclude-type=efivarfs'

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

function upgrade --description "Upgrade installed package managers"
    if command -sq apt-get
        printf '\nUpgrading APT packages\n'
        sudo apt-get update; or return
        sudo apt-get --yes dist-upgrade; or return
    end

    if command -sq nix; and command -sq home-manager
        set -l hm_dir "$HOME/.config/home-manager"

        if test -f "$hm_dir/flake.nix"
            printf '\nUpgrading Home Manager\n'
            nix flake update --flake "$hm_dir"; or return
            home-manager switch --flake "$hm_dir"; or return
        else
            printf '\nSkipping Home Manager: no flake.nix in %s\n' "$hm_dir"
        end
    end

    if command -sq flatpak
        printf '\nUpgrading Flatpak packages\n'
        flatpak update --assumeyes; or return
    end

    if command -sq brew
        printf '\nUpgrading Homebrew packages\n'
        brew update; or return
        brew upgrade --greedy; or return
    end

    return 0
end

function clean --description "Remove unused packages and old generations"
    # Retain your original one-day Nix retention period.
    set -l retention_days 1

    if command -sq apt-get
        printf '\nCleaning APT packages\n'
        sudo apt-get --yes autoremove; or return
        sudo apt-get autoclean; or return
    end

    if command -sq home-manager
        printf '\nRemoving old Home Manager generations\n'
        home-manager expire-generations "-$retention_days days"; or return
    end

    if command -sq nix-collect-garbage
        printf '\nCleaning the Nix store\n'
        nix-collect-garbage --delete-older-than "$retention_days"d; or return
    end

    if command -sq flatpak
        printf '\nCleaning Flatpak packages\n'
        flatpak uninstall --unused --assumeyes; or return
    end

    if command -sq brew
        printf '\nCleaning Homebrew packages\n'
        brew autoremove; or return
        brew cleanup --prune=all; or return
    end

    return 0
end
