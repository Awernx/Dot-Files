#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------
# Chander's FISH shell shortcuts for Mac & BSD

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end


set -Ux MAC_CACHE_HOME $HOME/Library/Caches

set --export --global OS_ICON ''
set --export --global OS $OS_ICON ' ' (sw_vers -productName) ' ' (sw_vers -productVersion) ' ' (grep -oE 'SOFTWARE LICENSE AGREEMENT FOR macOS [A-Z]*[a-z]*' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | awk -F 'macOS ' '{print $NF}')

## Abbreviations-----------------------
abbr ports               'sudo lsof -PiTCP -sTCP:LISTEN'
abbr clean               'brew autoremove && brew cleanup --prune=all && brew doctor'
abbr upgrade             'brew update && brew upgrade --greedy'
abbr clear-favicon-cache 'rm -rf ~/Library/Safari/Favicon\ Cache/'
abbr clear-network-cache 'sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

function ipa
    print_internal_ip_addresses    

    echo -ns '🌐 External:                              ' \n
    echo -ns '      IP v4: ' (set_color -o) (dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"') (set_color normal) \n
    echo -ns '      IP v6: ' (set_color -o) (dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"') (set_color normal) \n
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
    echo 'Changing hammerspoon\'s config location to be XDG compliant'
    defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
end

##  Internal IP address & adapter info -----------------
function print_internal_ip_addresses
    if not type -q scutil
        echo "scutil not found" >&2; return 1
    end
    if not type -q networksetup
        echo "networksetup not found" >&2; return 1
    end

    # Collect outputs into single strings we can reuse
    set -l SC (scutil --nwi | string collect)
    set -l NS (networksetup -listallhardwareports | string collect)

    # Get adapter list 
    set -l adapters (printf '%s\n' "$SC" | awk '
        /^Network interfaces:/ {
            for (i=3; i<=NF; i++) print $i
            found=1
        }
        END { if (!found) print "" }
    ')

    if test (count $adapters) -eq 0
        set adapters (printf '%s\n' "$SC" | awk '
            /^IPv4 network interface information/ { ipv4=1; next }
            ipv4 && /^[[:space:]]+[a-z0-9]+[[:space:]]+:/ {
                gsub(/^ +/,""); split($1,a,":"); print a[1]
            }
        ' | sort -u)
    end

    echo -ns \n'🏠 Internal:                              ' \n

    for iface in $adapters
        # IPv4 for iface (first "address" line under iface in IPv4 section)
        set -l ipv4 (printf '%s\n' "$SC" | awk -v IFACE="$iface" '
            /^IPv4 network interface information/ { m=1; next }
            m && $1==IFACE && $2==":" { want=1; next }
            want && /address/ { print $3; exit }
        ')

        # IPv6 for iface (first "address" line under iface in IPv6 section)
        set -l ipv6 (printf '%s\n' "$SC" | awk -v IFACE="$iface" '
            /^IPv6 network interface information/ { m=1; next }
            m && $1==IFACE && $2==":" { want=1; next }
            want && /address/ { print $3; exit }
        ')

        # Hardware Port & MAC from networksetup output
        set -l port_mac (printf '%s\n' "$NS" | awk -v IFACE="$iface" '
            /^Hardware Port:/ { port=$0; sub(/^Hardware Port: /,"",port) }
            $0 ~ "^Device: "IFACE"$" {
                getline;                                # expect "Ethernet Address: ..."
                gsub(/^Ethernet Address: /,"");
                print port "|" $0; exit
            }
        ')

        set -l port (string split -m1 '|' "$port_mac")[1]
        set -l mac  (string split -m1 '|' "$port_mac")[2]

        echo -ns '    Adapter: ' (set_color -o) $port ' ['$iface']' (set_color normal) \n
        echo -ns '      IP v4: ' (set_color -o) $ipv4               (set_color normal) \n
        echo -ns '      IP v6: ' (set_color -o) $ipv6               (set_color normal) \n
        echo -ns '        MAC: ' (set_color -o) $mac                (set_color normal) \n\n
    end
end
