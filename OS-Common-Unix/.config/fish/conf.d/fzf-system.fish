#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# FISH shell shortcuts for fzf functions & utilities

# Don't load this script for non-interactive shells
status is-interactive; or exit 0

# -----------------------------------------------------------------------------------------
# Kill system process - PID and USER are shown as previews on the right
# Shortcut key - Alt + K
# -----------------------------------------------------------------------------------------
bind alt-k kf
function kf --description 'Pick a process to kill (supports kill args like -9)'
    set --local selection (
        ps axww -o user,pid,command | \
        awk '{printf "%s|%s|", $1, $2; $1=$2=""; sub(/^  */, ""); print}' | \
        column -t -s '|' | \
        fzf $fzf_common_options --exact --header-lines=1 --prompt='Select process to kill ➤ '
    )

    if test -n "$selection"
        set pid (string split -n ' ' $selection)[2]
        command kill $argv $pid
    end

    exit_with_repaint
end

# -----------------------------------------------------------------------------------------
# List SSH hosts along with HOSTNAME, PORT, USER and IDENTITY
# Shortcut key - Alt + H
# -----------------------------------------------------------------------------------------
bind alt-h sshf
function sshf --description 'SSH hosts fzf-picker'
    set --local selection (
        awk '
            function clean(s) {
                gsub(/\r/, "", s)
                sub(/^[ \t]+/, "", s)
                sub(/[ \t]+$/, "", s)
                return s
            }

            function ok_host(s) {
                return (s !~ /[\*\?]/) && (s !~ /^!/) && (s ~ /^[A-Za-z0-9._-]+$/)
            }

            function emit_row(h, cmd, line, hn, u, p, k, f) {
                hn=""; u=""; k=""

                cmd = "ssh -G " h " 2>/dev/null"

                while ((cmd | getline line) > 0) {
                    split(line, f, /[ \t]+/)

                    if (f[1] == "hostname")      hn = f[2]
                    else if (f[1] == "user")     u  = f[2]
                    else if (f[1] == "identityfile") {
                        # Only assign if k is empty, effectively keeping the first entry
                        if (k == "") k = f[2]
                    }
                }

                close(cmd)

                if (p == "") p = "22"

                printf "%s\t%s\t%s\t%s\n", h, hn, u, k
            }

            function flush(i, h) {
                if (n == 0) return
                for (i = 1; i <= n; i++) {
                    h = clean(hosts[i])
                    if (tolower(h) ~ /^github/) continue
                    if (!ok_host(h)) continue
                    if (!(h in seen)) {
                    seen[h]=1
                    emit_row(h)
                    }
                }
            }

            BEGIN {
                n=0
                print "HOST\tHOSTNAME\tUSER\tIDENTITY_FILE"
            }

            /^[[:space:]]*Host[[:space:]]+/ && $1=="Host" {
                flush()
                n=0
                for (i=2; i<=NF; i++) hosts[++n] = $i
                next
            }

            END { flush() }
        ' ~/.ssh/config |
        column -t |
        fzf $fzf_window_options --header-lines=1 --prompt='Pick a SSH host ➤ '
    )

    if test -n "$selection"
        set --local host (string split -m 1 ' ' -- $selection)[1]
        command ssh $host
    end

    exit_with_repaint
end
