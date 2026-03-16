#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# Chander's FISH shell shortcuts for fzf functions & utilities

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

# -----------------------------------------------------------------------------------------
# Kill system process - PID and USER are shown as previews on the right
# Shortcut key - Alt + K
# -----------------------------------------------------------------------------------------
bind alt-k klf
function klf --description 'Pick a process to kill (supports kill args like -9)'
    set --local selection (
        ps axww -o user,pid,command | tail -n +2 | \
        fzf $fzf_common_options --exact --with-nth=3.. --color=prompt:#ff3b30 --preview-window=right:20% \
            --preview 'printf "\033[1;93mPID: \033[0m %s\n" {2}; printf "\033[1;93mUSER:\033[0m %s\n" {1}' \
            --prompt='⚠ Select process to kill ➤ '
    )

    if test -n "$selection"
        set --local pids (echo $selection | awk '{print $2}')
        command kill $argv $pids
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
                hn=""; u=""; p=""; k=""

                cmd = "ssh -G " h " 2>/dev/null"

                while ((cmd | getline line) > 0) {
                    split(line, f, /[ \t]+/)

                    if (f[1] == "hostname")      hn = f[2]
                    else if (f[1] == "user")     u  = f[2]
                    else if (f[1] == "port")     p  = f[2]
                    else if (f[1] == "identityfile") k = f[2]   # keep last
                }

                close(cmd)

                if (p == "") p = "22"

                printf "%s\t%s\t%s\t%s\t%s\n", h, hn, u, p, k
            }

            function flush(i, h) {
                if (n == 0) return
                for (i = 1; i <= n; i++) {
                    h = clean(hosts[i])
                    if (!ok_host(h)) continue
                    if (!(h in seen)) {
                    seen[h]=1
                    emit_row(h)
                    }
                }
            }

            BEGIN {
                n=0
                print "HOST\tHOSTNAME\tUSER\tPORT\tIDENTITYFILE"
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
        fzf $fzf_common_options --border --header-lines=1 \
            --prompt='Pick a host to SSH into ➤ '
    )

    if test -n "$selection"
        set --local host (string split -m 1 ' ' -- $selection)[1]
        command ssh $host
    end

    exit_with_repaint
end
