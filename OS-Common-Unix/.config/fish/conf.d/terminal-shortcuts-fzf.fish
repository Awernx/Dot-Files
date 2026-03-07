#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# Chander's FISH shell shortcuts for fzf utilities

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

# Miminal style; short window with a border
# '+' key toggle preview
# Filter option is at the top, with the list reversed - recent results at the top
set --global fzf_common_options --height=1% --reverse --info=hidden --border --margin=1 --padding=1 --bind '+:toggle-preview' --style minimal

# #########################################################################################
# KILL PROCESS
# List system system processes and kill any one at a time
# PID and USER are shown as previews on the right
# #########################################################################################

# Shortcut key - Alt + K
bind \ek klf

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

    commandline -f repaint # Workaround known fish-shell bug
end

# #########################################################################################
# SSH
# List SSH hosts along with HOSTNAME, PORT, USER and IDENTITY
# #########################################################################################

# Shortcut key - Alt + S
bind \es sshf

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

    commandline -f repaint # Workaround known fish-shell bug
end

# #########################################################################################
# SYSTEMCTL
# List systemd processes
# Shows 'Enebled' status, and service status as previews
# #########################################################################################

# Shortcut key - Alt + D
bind \ed sysd

function sysd --description 'Systemd services browser'
    if not type -q systemctl
        echo "This OS doesn't support 'systemd' services"
        return 1
    end

    set --local selection (
        {
        echo "SERVICE Ignore STATE SUB-STATE"
        systemctl list-units --type=service --all --plain --no-legend --no-pager
        } | grep -v '^systemd' | column -t \
        | fzf $fzf_common_options \
            --header-lines=1 --with-nth=1,3,4 --preview-window=right:50%:wrap \
            --preview '
                desc=$(echo {5..} | xargs)
                printf "\033[1;33m%s\033[0m%s\n\n" "$desc"
                {
                    printf "\033[0;36m%s %s %s\033[0m\n" "SERVICE_FILE" "START_UP" "PRESET"
                    printf "\033[1;37m"
                    systemctl list-unit-files --no-legend {1}
                    printf "\033[0m"
                } | column -t
                systemctl status {1} --lines=0 --no-pager | tail -n +2
            '
    )

    if test -n "$selection"
        set --local service (echo $selection | awk '{print $1}')
        command journalctl -u $service -f | fzf --tac --reverse
    end

    commandline -f repaint # Workaround known fish-shell bug
end

# #########################################################################################
# GIT BRANCH
# Select a local git branch to checkout into
# #########################################################################################

# Shortcut key - Alt + B
bind \eb gb

function gb --description 'Pick a git branch to checkout into'
    require_git_repo; or return 1

    set --local current (command git symbolic-ref --quiet --short HEAD 2>/dev/null)

    set --local branches (command git for-each-ref --format='%(refname:short)' refs/heads)

    if test (count $branches) -le 1
        echo 'No other git branches available to switch to'
        return 1
    end

    set --local selection (
        printf '%s\n' $branches |
        string match -v -- "$current" |
        fzf $fzf_common_options --prompt='Select a git branch to switch to ➤ '
    )

    if test -n "$selection"
        command git switch "$selection"
    end

    commandline -f repaint # Workaround known fish-shell bug
end

# #########################################################################################
# GIT RESET --HARD
# Select a commit to hard reset to
# #########################################################################################

# Shortcut key - Alt + R
bind \er gr

function gr --description 'Pick a git commit to HARD reset to'
    require_git_repo; or return 1

    set --local selection (
        git log --pretty=format:"%h │ %ad │ %s" --date=format:'%b %d %H:%M:%S' | \
        fzf $fzf_common_options --prompt="git> " --preview-window=hidden \
            --prompt='Select a git branch to HARD reset to ➤ ' \
            --preview 'git show --color=always {1}'
    )

    if test -n "$selection"
        set --local commit_id (string split -m 1 ' ' -- $selection)[1]
        command git reset --hard $commit_id
    end

    commandline -f repaint # Workaround known fish-shell bug
end

function require_git_repo --description 'Check if directory is a git repository'
    if not command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "This directory is not a git repository" >&2
        return 1
    end
end
