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

function ipa --description "Display internal and public IP information"
    set -l green    "\033[0;92m"
    set -l brgreen  "\033[1;92m"
    set -l yellow   "\033[0;93m"
    set -l bryellow "\033[1;93m"
    set -l reset    "\033[0m"

    # --- 1. Internal IP Information (via .NET in PowerShell, ~30ms) ---
    set -l ps_cmd '
        $nic = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
            Where-Object {
                $_.OperationalStatus -eq "Up" -and
                $_.NetworkInterfaceType -ne "Loopback" -and
                ($_.GetIPProperties().GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq "InterNetwork" })
            } | Select-Object -First 1

        if ($nic) {
            $props = $nic.GetIPProperties()
            $ip    = ($props.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq "InterNetwork" } | Select-Object -First 1).Address.IPAddressToString
            $gw    = ($props.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq "InterNetwork" } | Select-Object -First 1).Address.IPAddressToString
            $rawMac = $nic.GetPhysicalAddress().ToString()
            $mac   = if ($rawMac.Length -eq 12) { ($rawMac -replace "(.{2})(?!$)", "`$1:").ToLower() } else { "N/A" }
            $type  = switch ($nic.NetworkInterfaceType) {
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

    # Print internal info immediately before running curl
    printf "\n%b🏠 Internal: %b\n" $green $reset
    printf "         IP:%b %s            %b\n" $brgreen "$ip_address" $reset
    printf "    Adapter:%b %s [%s] %b\n" $green "$adapter" "$adapter_type" $reset
    printf "        MAC:%b %s             %b\n" $green "$mac_address" $reset
    printf "    Gateway:%b %s               %b\n" $green "$router_ip" $reset

    # --- 2. Public IP Information (Native MSYS2 curl + awk) ---
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

    printf "\n%b  🌐 Public: %b\n" $yellow $reset
    printf "         IP:%b %s                    %b\n" $bryellow "$ip" $reset
    printf "   Location:%b %s, %s, %s %b\n" $yellow "$city" "$region" "$country" $reset
end
