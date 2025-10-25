#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# --------------------------------------------------------
# Chander's BASH shell shortcuts for Debian-based distros

alias clk='watch --no-title --precise --interval 0.1 '"'"'date +"%A %B %d, %Y %I:%M:%S,%N %p %Z"'"'"''

alias time_stat='systemctl status systemd-timesyncd.service'
alias time_sync='sudo systemctl restart systemd-timesyncd'

alias shutdown='sudo /sbin/shutdown -h now'
alias reboot='sudo /sbin/reboot'

alias apt-get='sudo apt-get'
alias upgrade='apt-get update && apt-get --yes dist-upgrade'
alias clean='apt-get --yes autoremove && apt-get --yes clean'

alias partitions='lsblk -no "NAME,LABEL,SIZE,FSTYPE,MOUNTPOINT"'
