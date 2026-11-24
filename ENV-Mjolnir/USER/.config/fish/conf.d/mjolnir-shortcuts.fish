#!/usr/bin/env fish

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

#------------------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------------------
set --export --global HOST_BANNER "\

  ▄▄▄▄███▄▄▄▄        ▄█  ▄██████▄   ▄█       ███▄▄▄▄    ▄█     ▄████████
▄██▀▀▀███▀▀▀██▄     ███ ███    ███ ███       ███▀▀▀██▄ ███    ███    ███
███   ███   ███     ███ ███    ███ ███       ███   ███ ███▌   ███    ███
███   ███   ███     ███ ███    ███ ███       ███   ███ ███▌  ▄███▄▄▄▄██▀
███   ███   ███     ███ ███    ███ ███       ███   ███ ███▌ ▀▀███▀▀▀▀▀
███   ███   ███     ███ ███    ███ ███       ███   ███ ███  ▀███████████
███   ███   ███     ███ ███    ███ ███▌    ▄ ███   ███ ███    ███    ███
 ▀█   ███   █▀  █▄ ▄███  ▀██████▀  █████▄▄██  ▀█   █▀  █▀     ███    ███
                ▀▀▀▀▀▀             ▀                          ███    ███
"

#------------------------------------------------------------------------------------------
# Abbreviations
#------------------------------------------------------------------------------------------
abbr sleep 'systemctl suspend'
abbr vol   'wpctl get-volume @DEFAULT_AUDIO_SINK@'
abbr wol   'sudo ethtool eno1 | grep Wake' # Understand output https://askubuntu.com/questions/1267124/wake-on-lan-issues

#------------------------------------------------------------------------------------------
# Aliases
#------------------------------------------------------------------------------------------
alias tinn-vol  'wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.6'

#------------------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------------------

function mj-help --description "List all Tinn-related shortcuts"
    printf '\nMjolnir shorcuts\n'
    printf '----------------------------------------------------------------\n'
    printf 'vol          --> Gets current volume level \n'
    printf 'wol          --> Prints Wake-On-Lan status \n'
    printf 'sleep        --> Suspends the system \n\n'

    printf 'tinn-vol     --> Sets system volume to max level  \n'
end

function ntp --description "List chrony NTP sources, and current clock offset"
    # Highlight the active winning sync source (* / =* / #*) in bold yellow
    # Highlight backup sources (+ / =+ / #+) in bright purple
    # Dim unusable (?), falseticker (x), or overly variable (~) sources
    chronyc sources | awk \
        -v y=(set_color --bold yellow) \
        -v p=(set_color brpurple) \
        -v d=(set_color --dim) \
        -v n=(set_color normal) \
        '{ print (/^[=^#]\*/ ? y : /^[=^#]\+/ ? p : /^[=^#][?x~]/ ? d : "") $0 n }'
    and echo
    and chronyc tracking | awk -F': ' -v b=(set_color --bold) -v n=(set_color normal) '
        /^Stratum/ { printf "%-14s %s%s%s\n", $1":", b, $2, n }
        /^System time/ {
            split($2, a, " ")
            v = a[1] + 0
            if (v < 0.001)      val = sprintf("%.1fus", v * 1e6)
            else if (v < 1.0)   val = sprintf("%.2fms", v * 1e3)
            else                val = sprintf("%.3fs", v)
            sub(a[1] " seconds", val, $2)
            printf "%-14s %s%s%s\n", $1":", b, $2, n
        }
    '
end
