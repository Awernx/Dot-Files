#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# --------------------------------------------------------
# Chander's BASH shell shortcuts for Debian-based distros

alias time_stat='systemctl status systemd-timesyncd.service'
alias time_sync='sudo systemctl restart systemd-timesyncd'

alias shutdown='sudo /sbin/shutdown -h now'
alias reboot='sudo /sbin/reboot'

alias apt='sudo apt'
alias upgrade='apt update && apt --yes full-upgrade && apt --yes autoremove && apt --yes autoclean'
alias install='apt update && apt --yes install'
alias purge='apt --yes purge'

clk() {
    watch --no-title --precise --interval 0.05 'date +"%A %B %d, %Y %I:%M:%S,%N %p %Z "'
}
