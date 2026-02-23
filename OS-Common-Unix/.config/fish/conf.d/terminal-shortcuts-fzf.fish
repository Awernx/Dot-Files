#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# Chander's FISH shell shortcuts for fzf utilities

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

set --global fzf_global_options \
    --height=1% \
    --reverse \
    --info=hidden \
    --border \
    --margin=1 \
    --padding=1 \
    --bind 'p:toggle-preview'

function kl --description 'Pick a process to kill (supports kill args like -9)'
    set --local pids (
        ps axww -o user,pid,command | \
        fzf $fzf_global_options \
            --exact \
            --header-lines=1 \
            --with-nth=3.. \
            --color=prompt:#ff3b30 \
            --preview 'printf "\033[1;93mPID: \033[0m %s\n" {2}; printf "\033[1;93mUSER:\033[0m %s\n" {1}' \
            --preview-window=down:2:wrap \
            --prompt='⚠ Select process to kill ➤ ' | \
        awk '{print $2}'
    )

    # If you hit Esc / no selection, do nothing
    if test -z "$pids"
        return 0
    end

    # Pass through any args you provided (e.g., -9, -TERM)
    command kill $argv $pids
end

function gb --description 'Pick a git branch to checkout into'
    require_git_repo
    or return 1

    # Collect branches except current
    set --local branches (
        git branch --format='%(refname:short)' \
        | string match -v (git branch --show-current)
    )

    # Guard: no other branches exist
    if test (count $branches) -eq 0
        echo 'No other git branches available to switch to.'
        return 1
    end

    set --local branch (
        printf '%s\n' $branches \
        | fzf $fzf_global_options --header-lines=0 \
            --prompt='Select a git branch to switch to ➤ '
    )

    # If you hit Esc / no selection, do nothing
    if test -z "$branch"
        return 0
    end

    command git checkout "$branch"
end

function gr --description 'Pick a git commit to HARD reset into'
    require_git_repo
    or return 1

    set --local selection (
        git log --pretty=format:"%h │ %ad │ %s" --date=format:'%b %d %H:%M:%S' \
        | fzf $fzf_global_options --prompt="git> " \
            --preview 'git show --color=always {1}'\
            --preview-window=hidden \
            --prompt='Select a git branch to HARD reset to ➤ '
    )

    set --local commit_id (string split -m 1 ' ' -- $selection)[1]

    if test -z "$commit_id"
        return 0
    end

    command git reset --hard $commit_id
end

function require_git_repo --description 'Check if directory is a git repository'
    if not command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "This directory is not a git repository" >&2
        return 1
    end
end

function sf --description 'SSH hosts picker'
    set --local selection (
            awk '
              function clean(s) {
                gsub(/\r/, "", s)                 # remove Windows CR
                sub(/^[ \t]+/, "", s)             # ltrim
                sub(/[ \t]+$/, "", s)             # rtrim
                return s
              }

              function ok_host(s) {
                # skip wildcards/patterns/negations; allow normal host tokens
                return (s !~ /[\*\?]/) && (s !~ /^!/) && (s ~ /^[A-Za-z0-9._-]+$/)
              }

              function flush(i, h) {
                if (n == 0) return
                for (i = 1; i <= n; i++) {
                  h = clean(hosts[i])
                  if (!ok_host(h)) continue
                  print h
                }
              }

              BEGIN { n=0 }
                /^[[:space:]]*Host[[:space:]]+/ && $1=="Host" {
                    flush()
                    n=0
                    for (i=2; i<=NF; i++) hosts[++n] = $i
                    next
                }
              END { flush() }
              ' ~/.ssh/config |

              fzf $fzf_global_options \
                --prompt='Pick a host to SSH into ➤ ' \
                --border \
                --preview 'sh -lc '"'"'
                    h=$(printf %s "{}" | tr -d "\r" | sed "s/^[[:space:]]*//;s/[[:space:]]*$//")
                    ssh -G "$h" 2>/dev/null | awk "
                      BEGIN { hostname=user=port=identityfile=\"\" }
                        /^hostname /     { hostname=\$2 }
                        /^user /         { user=\$2 }
                        /^port /         { port=\$2 }
                        /^identityfile / { identityfile=\$2 }   # last one wins
                      END {
                        if (hostname)     printf \"\033[1;93mHOSTNAME: \033[1;0m %s\n\", hostname
                        if (user)         printf \"\033[1;93mUSER:     \033[1;0m %s\n\", user
                        if (port)         printf \"\033[1;93mPORT:     \033[0m %s\n\", port
                        if (identityfile) printf \"\033[1;93mIDENTITY: \033[0m %s\n\", identityfile
                      }
                    "
                '"'"'' \
                --preview-window=down:50%:border
        )

    test -z "$selection"; and return 0
    set --local host (string split -m 1 ' ' -- $selection)[1]
    command ssh $host
end
