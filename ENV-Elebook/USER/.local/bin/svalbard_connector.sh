#!/bin/sh

HOST="mjolnir.local"
SHARE_URI="smb://mjolnir.local/svalbard"

# Check if the share is already mounted; if not, wait for mDNS and connect
if ! gio mount -l | grep -Fq "$SHARE_URI"; then
    i=0
    while [ "$i" -lt 15 ]; do
        if getent hosts "$HOST" >/dev/null 2>&1; then
            break
        fi
        i=$((i + 1))
        sleep 1
    done

    gio mount "$SHARE_URI" || exit 1
fi

# Open the mounted share in elementary OS Files (backgrounded so the terminal frees up)
io.elementary.files "$SHARE_URI" >/dev/null 2>&1 &
