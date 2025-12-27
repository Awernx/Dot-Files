#!/bin/bash

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
# NOTE: Ensure the script has execute previliges for root

log(){
  # Write to syslog
  logger -t "DeviceWakeUpEnabler" $1
}

case $1/$2 in
  pre/*)
    if [ "$EUID" -ne 0 ]
      then log "Please run this script as root"
      exit
    fi

    log "Identifying devices that are currently disabled"

    grep disabled /sys/bus/usb/devices/*/power/wakeup | while IFS=':' read -r -a device_details in ; do
        log "Enabling ${device_details[0]}"
        echo enabled > ${device_details[0]}
    done

    log "All devices are ready to trigger wakeup"
    ;;

  post/*)
    ;;

esac
