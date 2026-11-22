#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------------
# Chander's FISH shell customizations for Windows (MSYS2)

if not set -q MSYSTEM
    exit 0
end

## Aliases --------------------------------------
alias pwd 'pwd -P'

function this --description "Display system and shell summary"
    set -l label (set_color --dim)
    set -l value (set_color -o)
    set -l reset (set_color normal)

    # Zero-fork Windows registry lookups via /proc/registry
    set -l reg_dir '/proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion'
    read -z prod < "$reg_dir/ProductName" 2>/dev/null
    read -z rel  < "$reg_dir/DisplayVersion" 2>/dev/null
    read -z bld  < "$reg_dir/CurrentBuild" 2>/dev/null

    set prod (string trim -c \0 -- "$prod")
    set rel  (string trim -c \0 -- "$rel")
    set bld  (string trim -c \0 -- "$bld")

    if test "$bld" -ge 22000 2>/dev/null
        set prod (string replace 'Windows 10' 'Windows 11' $prod)
    end

    set -l win_os ""
    if test -n "$prod" -o -n "$bld"
        set win_os (string trim "$prod $rel (Build $bld)")
    end

    echo -ns $label '        Host: ' $reset $value $HOST_FULL_NAME $reset \n
    test -n "$win_os"; and echo -ns $label '          OS: ' $reset $value '⊞ ' $win_os $reset \n
    echo -ns $label ' Environment: ' $reset $value "MSYS2 ($MSYSTEM)" $reset \n
    echo -ns $label 'Architecture: ' $reset $value (uname -m) $reset \n
    echo -ns $label '      Kernel: ' $reset $value (uname -sr) $reset \n
    echo -ns $label '       Shell: ' $reset $value '🐟 Fish ' $FISH_VERSION $reset \n

    if test -n "$WT_SESSION"
        echo -ns $label '    Terminal: ' $reset $value 'Windows Terminal' $reset \n
    else if test -n "$MINTTY_SHORTCUT" -o "$TERM_PROGRAM" = "mintty"
        echo -ns $label '    Terminal: ' $reset $value 'MinTTY' $reset \n
    end
end

function upgrade --description "Update MSYS2 packages"
    if type -q pacman
        echo -e "\n🔄 Updating MSYS2 packages..."
        pacman -Syu --noconfirm

        set -l orphans (pacman -Qdtq 2>/dev/null)
        if test -n "$orphans"
            echo -e "🧹 Removing orphaned packages..."
            pacman -Rns --noconfirm $orphans
        end

        echo -e "🧹 Cleaning up MSYS2 package cache..."
        pacman -Sc --noconfirm

        echo -e "\n✅ MSYS2 updates and cleanup complete!"
    end
end

function ipa --description "Display internal and public IP information"
    set -l green    (set_color brgreen)
    set -l brgreen  (set_color -o brgreen)
    set -l yellow   (set_color bryellow)
    set -l bryellow (set_color -o bryellow)
    set -l reset    (set_color normal)

    # --- 1. Internal IP Information (via .NET in PowerShell) ---
    set -l ps_cmd '
        $nic = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
            Where-Object {
                $_.OperationalStatus -eq "Up" -and
                $_.NetworkInterfaceType -ne "Loopback" -and
                ($_.GetIPProperties().GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq "InterNetwork" })
            } | Select-Object -First 1

        if ($nic) {
            $props  = $nic.GetIPProperties()
            $ip     = ($props.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq "InterNetwork" } | Select-Object -First 1).Address.IPAddressToString
            $gw     = ($props.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq "InterNetwork" } | Select-Object -First 1).Address.IPAddressToString
            $rawMac = $nic.GetPhysicalAddress().ToString()
            $mac    = if ($rawMac.Length -eq 12) { ($rawMac -replace "(.{2})(?!$)", "`$1:").ToLower() } else { "N/A" }
            $type   = switch ($nic.NetworkInterfaceType) {
                "Ethernet"        { "Ethernet" }
                "GigabitEthernet" { "Ethernet" }
                "FastEthernetT"   { "Ethernet" }
                "Wireless80211"   { "Wi-Fi" }
                "Wwanpp"          { "Mobile Broadband (WWAN)" }
                "Wwanpp2"         { "Mobile Broadband (WWAN)" }
                "Loopback"        { "Loopback" }
                default           { "Unknown/Virtual" }
            }
            "$ip|$($nic.Name)|$type|$mac|$gw"
        }
    '

    set -l raw_net (powershell.exe -NoProfile -NonInteractive -Command $ps_cmd 2>/dev/null | string trim)
    set -l parts (string split "|" -- "$raw_net")

    set -l ip_address   (test -n "$parts[1]"; and echo $parts[1]; or echo "N/A")
    set -l adapter      (test -n "$parts[2]"; and echo $parts[2]; or echo "N/A")
    set -l adapter_type (test -n "$parts[3]"; and echo $parts[3]; or echo "Unknown/Virtual")
    set -l mac_address  (test -n "$parts[4]"; and echo $parts[4]; or echo "N/A")
    set -l router_ip    (test -n "$parts[5]"; and echo $parts[5]; or echo "N/A")

    printf "\n%s🏠 Internal: %s\n" $green $reset
    printf "         IP:%s %s%s\n" $brgreen "$ip_address" $reset
    printf "    Adapter:%s %s [%s]%s\n" $green "$adapter" "$adapter_type" $reset
    printf "        MAC:%s %s%s\n" $green "$mac_address" $reset
    printf "    Gateway:%s %s%s\n" $green "$router_ip" $reset

    # --- 2. Public IP Information (Native MSYS2 curl + Fish string parsing) ---
    set -l ip      "N/A"
    set -l city    "N/A"
    set -l region  "N/A"
    set -l country "N/A"

    set -l data (curl -4 -fsS --max-time 3 https://ipinfo.io 2>/dev/null)
    if test -n "$data"
        for line in $data
            switch $line
                case '*"ip":*'
                    set ip (string replace -r '.*"ip":\s*"([^"]+)".*' '$1' -- $line)
                case '*"city":*'
                    set city (string replace -r '.*"city":\s*"([^"]+)".*' '$1' -- $line)
                case '*"region":*'
                    set region (string replace -r '.*"region":\s*"([^"]+)".*' '$1' -- $line)
                case '*"country":*'
                    set country (string replace -r '.*"country":\s*"([^"]+)".*' '$1' -- $line)
            end
        end
    end

    printf "\n%s  🌐 Public: %s\n" $yellow $reset
    printf "         IP:%s %s%s\n" $bryellow "$ip" $reset
    printf "   Location:%s %s, %s, %s%s\n" $yellow "$city" "$region" "$country" $reset
end
