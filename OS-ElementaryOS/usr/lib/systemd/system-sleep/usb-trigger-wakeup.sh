#!/bin/sh

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------------------------------------
# Script that enables wake up from suspend using wireless USB keyboard or mouse
#
# Reference:
# https://askubuntu.com/questions/848698/wake-up-from-suspend-using-wireless-usb-keyboard-or-mouse-for-any-linux-distro
#
# Note: This script should be invoked prior to every suspend
# Reference: https://itectec.com/ubuntu/ubuntu-how-to-make-changes-to-proc-acpi-wakeup-permanent/
#
# Location: /lib/systemd/system-sleep/
# NOTE:
#      1. /lib is typically symlink to /usr/lib on modern Linux distributions.
#         Since stow cannot work with a symlink it didn't create, adding to /usr/lib/....
#      2. Ensure the script has execute previliges for root

log() {
  # Write to syslog
  logger -t "DeviceWakeUpEnabler" "$1"
}

case "$1/$2" in

    pre/*) # Run before sleeping
        if [ "$(id -u)" -ne 0 ]; then
            log "Please run this script as root"
            exit 1
        fi

        log "Activating currently disabled devices to trigger wakeup"

        for wakeup_file in /sys/bus/usb/devices/*/power/wakeup; do
            [ -f "$wakeup_file" ] || continue
            read -r status < "$wakeup_file"

            if [ "$status" = "disabled" ]; then
                log "  -> Enabling $wakeup_file"
                echo enabled > "$wakeup_file"
            fi
        done

        log "All devices are ready to trigger wakeup"
        ;;

    post/*) # Run after waking up
        ;;
esac
