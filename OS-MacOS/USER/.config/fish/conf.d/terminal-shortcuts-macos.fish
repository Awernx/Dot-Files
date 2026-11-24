#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------
# Chander's FISH shell shortcuts for Mac & BSD

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

# Initialize homebrew ENV before registering aliases to enable identification of brew-installed binaries
set --local homebrew_location '/opt/homebrew/bin/brew'
if test -f $homebrew_location
    $homebrew_location shellenv | source
end

## Load these staple tools if they exist
if command -sq fzf
    fzf --fish | source
end

if command -sq mcfly
    mcfly init fish | source
end

if command -sq direnv
    direnv hook fish | source
end

if command -sq zoxide
    zoxide init fish | source
end

## Abbreviations
abbr clear-favicon-cache 'rm -rf ~/Library/Safari/Favicon\ Cache/'
abbr clear-network-cache 'sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

## Functions

function macos_info
    set -l plist "/System/Library/CoreServices/SystemVersion"
    set -l os_name (defaults read $plist ProductName)
    set -l os_ver  (defaults read $plist ProductVersion)
    set -l os_bld  (defaults read $plist ProductBuildVersion)
    set -l major   (string split '.' $os_ver | head -n 1)
    set -l code    ""

    # 1. Use cached codename if it matches the current OS build and isn't blank
    if set -q _cached_macos_build; and test "$_cached_macos_build" = "$os_bld"; and test -n "$_cached_macos_name"; and test "$_cached_macos_name" != "(Beta)"
        set code $_cached_macos_name
    else
        # 2. Fetch marketing name from endoflife.date API
        set -l url (string join / "https:/" "endoflife.date" "api" "v1" "products" "macos" "releases" "$major")
        set code (curl -fsSL --max-time 3 "$url" 2>/dev/null | string match -rg '"label"\s*:\s*"[^"]*\(([^)]+)\)"')

        # 3. Fallback to local RTF license if offline or API is unreachable
        if test -z "$code"
            set -l rtf "/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf"
            set -l rtf_name (textutil -convert txt -stdout "$rtf" 2>/dev/null | string match -ir 'SOFTWARE LICENSE AGREEMENT FOR macOS\s+\K.+' | head -n 1)
            if test -n "$rtf_name"; and not string match -qi '*PRE-RELEASE*' "$rtf_name"
                set code $rtf_name
            end
        end

        # 4. Append (Beta) if build ends with a lowercase seed letter (e.g., 26C5035r)
        if string match -qr '[a-z]$' "$os_bld"
            set code (string trim "$code (Beta)")
        end

        # 5. Cache in Fish universal variables only when a real name was resolved
        if test -n "$code"; and test "$code" != "(Beta)"
            set -U _cached_macos_build "$os_bld"
            set -U _cached_macos_name "$code"
        end
    end

    string trim "$OS_ICON $os_name $os_ver $code"
end

function upgrade
    brew update
    yes | brew upgrade --greedy

    brew doctor
    brew autoremove
    brew cleanup --prune=all
end

##  Get the Bundle Id
function bid
    if test (count $argv) -lt 1
        echo "⚠️ Application name is a required argument";
        return 1
    else
        osascript -e 'id of app "'$argv[1]'"'
    end
end

##  Set sane defaults on macOS
function sane-defaults
    defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
    defaults write com.apple.Terminal AutoMarkPromptLines -bool NO
end

##  Print local and public IP info
function ipa
    set -l route_out (route -n get default 2>/dev/null)
    set -l interface (printf '%s\n' $route_out | awk '/interface: / {print $2}')
    set -l router_ip (printf '%s\n' $route_out | awk '/gateway: / {print $2}')

    set -l service (networksetup -listnetworkserviceorder | grep -B1 "$interface" | head -n1 | string replace -r '^\(\d+\)\s+' '')
    set -l local_ip (ipconfig getifaddr $interface)
    set -l mac_addr (networksetup -getmacaddress "$service" | awk '{print $3}')

    echo
    echo -ns (set_color -o brgreen) '🏠 Internal: ' (set_color normal) \n
    echo -ns                        '         IP: ' (set_color -o brgreen) $local_ip                 (set_color normal) \n
    echo -ns                        '    Adapter: ' (set_color brgreen)    $interface ' ' [$service] (set_color normal) \n
    echo -ns                        '        MAC: ' (set_color brgreen)    $mac_addr                 (set_color normal) \n
    echo -ns                        '    Gateway: ' (set_color -o brgreen) $router_ip                (set_color normal) \n

    # Get Public IP Info
    set -l public_json (curl -fsS --max-time 5 https://ipinfo.io 2>/dev/null)
    set -l pub_ip (string match -r '"ip":\s*"\K[^"]+' -- $public_json)
    set -l city (string match -r '"city":\s*"\K[^"]+' -- $public_json)
    set -l region (string match -r '"region":\s*"\K[^"]+' -- $public_json)
    set -l country (string match -r '"country":\s*"\K[^"]+' -- $public_json)

    set -l pub_loc "N/A"
    if test -n "$city"
        set pub_loc "$city, $region, $country"
    end

    echo
    echo -ns (set_color -o bryellow) '  🌐 Public: ' (set_color normal) \n
    echo -ns                         '         IP: ' (set_color -o bryellow) (string collect $pub_ip; or echo "N/A") (set_color normal) \n
    echo -ns                         '   Location: ' (set_color bryellow)    $pub_loc                                (set_color normal) \n
end

# Populate OS environment variables
set -gx OS_ICON ''
set -gx OS (macos_info)
