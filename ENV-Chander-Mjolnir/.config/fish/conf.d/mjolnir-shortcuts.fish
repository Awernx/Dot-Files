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

function ntp_sources --description "Live-monitor chrony NTP sources with color highlighting"
    # Default to a 1-second refresh interval
    set -l interval 1

    # Build the awk script with inline set_color substitutions
    set -l awk_script '
        # Highlight the active winning sync source (* / =* / #*) in bold yellow
        /^[=^#]\*/    { print "'(set_color --bold yellow)'" $0 "'(set_color normal)'"; next }

        # Dim unusable (?), falseticker (x), or overly variable (~) sources
        /^[=^#][?x~]/ { print "'(set_color --dim)'" $0 "'(set_color normal)'"; next }

        # Print headers and healthy standby (+ / -) sources in default color
        { print }
    '

    # -c preserves ANSI color escape sequences inside `watch`
    watch -c -n $interval "chronyc sources | awk '$awk_script'"
end
