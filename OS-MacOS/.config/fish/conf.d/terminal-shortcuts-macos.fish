#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------
# Chander's FISH shell shortcuts for Mac & BSD

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

set --export --global OS_ICON ''
set --export --global OS $OS_ICON ' ' (sw_vers -productName) ' ' (sw_vers -productVersion) ' ' (grep -oE 'SOFTWARE LICENSE AGREEMENT FOR macOS [A-Z]*[a-z]*' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | awk -F 'macOS ' '{print $NF}')

# Initialize homebrew ENV before registering aliases to enable identification of brew-installed binaries
set --local homebrew_location '/opt/homebrew/bin/brew'
if test -f $homebrew_location
    $homebrew_location shellenv | source
end

## Abbreviations-----------------------
abbr ports               'sudo lsof -PiTCP -sTCP:LISTEN'
abbr clear-favicon-cache 'rm -rf ~/Library/Safari/Favicon\ Cache/'
abbr clear-network-cache 'sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

function upgrade
    brew update
    brew upgrade --formula
    brew upgrade --cask --greedy
end

function clean
    brew doctor
    brew autoremove
    brew cleanup --prune=all
end

##  Get the Bundle Id -----------------
function bid
    if test (count $argv) -lt 1
        echo "⚠️ Application name is a required argument";
        return 1
    else
        osascript -e 'id of app "'$argv[1]'"'
    end
end

##  Set sane defaults on macOS --------
function sane-defaults
    defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
    defaults write com.apple.Terminal AutoMarkPromptLines -bool NO
end

##  Print local and public IP info-----
function ipa
    if not type -q jq
        echo "Error: 'jq' is required. Install it with 'brew install jq'."
        exit 1
    end

    # Get Local Adapter Info
    set -l interface (route -n get default | awk '/interface: / {print $2}')
    set -l service (networksetup -listnetworkserviceorder | grep -B1 "$interface" | head -n1 | string replace -r '^\(\d+\)\s+' '')
    set -l local_ip (ipconfig getifaddr $interface)
    set -l mac_addr (networksetup -getmacaddress "$service" | awk '{print $3}')
    set -l router_ip (route -n get default | awk '/gateway: / {print $2}')

    echo
    echo -ns (set_color -o brgreen) '🏠 Internal: ' (set_color normal) \n
    echo -ns                        '         IP: ' (set_color -o brgreen) $local_ip                 (set_color normal) \n
    echo -ns                        '    Adapter: ' (set_color brgreen)    $interface ' ' [$service] (set_color normal) \n
    echo -ns                        '        MAC: ' (set_color brgreen)    $mac_addr                 (set_color normal) \n
    echo -ns                        '    Gateway: ' (set_color brgreen)    $router_ip                (set_color normal) \n

    # Get Public IP Info
    set -l public_json (curl -s ipinfo.io)
    set -l pub_ip (echo $public_json | jq -r '.ip')
    set -l pub_host (echo $public_json | jq -r '.hostname // "N/A"')
    set -l pub_loc (echo $public_json | jq -r '"\(.city), \(.region), \(.country)"')

    echo
    echo -ns (set_color -o bryellow) '  🌐 Public: ' (set_color normal) \n
    echo -ns                         '         IP: ' (set_color -o bryellow) $pub_ip   (set_color normal) \n
    echo -ns                         '        FQN: ' (set_color bryellow)    $pub_host (set_color normal) \n
    echo -ns                         '   Location: ' (set_color bryellow)    $pub_loc  (set_color normal) \n
end
