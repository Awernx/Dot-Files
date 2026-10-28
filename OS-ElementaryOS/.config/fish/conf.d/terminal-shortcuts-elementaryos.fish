#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -------------------------------------
# Bootstrapper script specific to ergo

# ElementaryOS files shortcut
alias open "io.elementary.files"

set --export --global BASE_OS (awk -F '=' '$1 == "UBUNTU_VERSION" {gsub(/"/, ""); BASE=$2} END {printf "🐧 Ubuntu %s", BASE}' /etc/os-release)

function bootstrap
    echo 'Setting up Clock'
    # Clock settings
    gsettings set io.elementary.desktop.wingpanel.datetime clock-show-weekday true
    gsettings set io.elementary.desktop.wingpanel.datetime clock-show-seconds true

    busctl --system set-property \
        org.freedesktop.Accounts \
        /org/freedesktop/Accounts/User"$(id -u)" \
        io.elementary.pantheon.AccountsService \
        TimeFormat s '12h'

    # Special keys tray settings
    echo 'Setting up Tray icons'
    gsettings set io.elementary.wingpanel.keyboard numlock true
    gsettings set io.elementary.wingpanel.keyboard capslock true

    gsettings set io.elementary.files.preferences show-hiddenfiles true
    gsettings set io.elementary.files.preferences singleclick-select true

    # Terminal settings
    echo 'Setting up Terminal icons & colors'
    gsettings set io.elementary.terminal.settings cursor-shape 'I-Beam'
    # Gruvbox color theme
    gsettings set io.elementary.terminal.settings follow-system-style false
    gsettings set io.elementary.terminal.settings theme 'custom'
    gsettings set io.elementary.terminal.settings background 'rgba(40,40,40,0.936396)'
    gsettings set io.elementary.terminal.settings foreground 'rgb(235,219,178)'
    gsettings set io.elementary.terminal.settings palette 'rgb(40,40,40):rgb(204,36,29):rgb(152,151,26):rgb(215,153,33):rgb(69,133,136):rgb(177,98,134):rgb(104,157,106):rgb(168,153,132):rgb(146,131,116):rgb(251,73,52):rgb(184,187,38):rgb(250,189,47):rgb(131,165,152):rgb(211,134,155):rgb(142,192,124):rgb(235,219,178)'

    # echo
    # echo 'Setting up Logitech MX Keys'
    # sudo systemd-hwdb update
    # sudo udevadm trigger /dev/input/event*
    # echo 'Note: Restart computer to complete MX Keys set'
end
