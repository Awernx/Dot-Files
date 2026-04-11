#!/usr/bin/env fish

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

#------------------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------------------
set --export --global HOST_BANNER "\
▗▄▄▄▖▗▖  ▗▖▗▄▄▄ ▗▄▄▄▖ ▗▄▖    ▗▄▄▄▖▗▖ ▗▖▗▖  ▗▖▗▖  ▗▖▗▄▄▄▖▗▖
  █  ▐▛▚▖▐▌▐▌  █  █  ▐▌ ▐▌     █  ▐▌ ▐▌▐▛▚▖▐▌▐▛▚▖▐▌▐▌   ▐▌
  █  ▐▌ ▝▜▌▐▌  █  █  ▐▛▀▜▌     █  ▐▌ ▐▌▐▌ ▝▜▌▐▌ ▝▜▌▐▛▀▀▘▐▌
▗▄█▄▖▐▌  ▐▌▐▙▄▄▀▗▄█▄▖▐▌ ▐▌     █  ▝▚▄▞▘▐▌  ▐▌▐▌  ▐▌▐▙▄▄▖▐▙▄▄▖
"

# This is not normally required, and would be lost on restart
# Use this as a nuclear option to add a firewall rule (at the top) to ACCEPT all requests on port 51820
# and let it through. "it's checked before any "deny" rules. open the firewall
function open-wg-port --description 'Opens firewall to accept requests on port 51820'
    sudo iptables -I INPUT -p udp --dport 51820 -j ACCEPT
end

# These rules are already embedded in the wg0 conf file
# If those are not loaded for some internal failure reason, these can be used for force load these rules
function flush-vpn-rules --description 'Force-create vpn rules'
    # 1. Ensure the kernel allows packet switching
    sudo sysctl -w net.ipv4.ip_forward=1

    # 2. Clear any restrictive rules and set up the bridge
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -F FORWARD
    sudo iptables -t nat -F POSTROUTING

    # 3. The "Magic" NAT Rule
    sudo iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
end
