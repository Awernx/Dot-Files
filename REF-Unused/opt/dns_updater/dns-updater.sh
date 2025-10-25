#!/bin/sh

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------------------
# Updates DNS record at freedns.afraid.org with missioncontrol's public IP address

THIS_SCRIPT_DIR=$(dirname $0)
REGISTERED_IP_FILE=$THIS_SCRIPT_DIR/last_registered.ip

IP_ADDRESS=$(curl -s ifconfig.me)

if ! echo "$IP_ADDRESS" | grep -qoE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"; then
    echo $(date +"%Y-%m-%d %H:%M:%S") --- ERROR: Could not determine public IP address
    exit 1
fi

if [ -e $REGISTERED_IP_FILE ] && grep -q $IP_ADDRESS $REGISTERED_IP_FILE; then
    echo $(date +"%Y-%m-%d %H:%M:%S") --- No change in IP address
else
    echo $(date +"%Y-%m-%d %H:%M:%S") --- IP address has changed to $IP_ADDRESS
    wget --no-check-certificate -O - https://freedns.afraid.org/dynamic/update.php?ZTZ4dUc5YjdoS3pYTTRMRmZQNFRzelZWOjE5MTI0MjE0
    echo $IP_ADDRESS > $REGISTERED_IP_FILE
fi
