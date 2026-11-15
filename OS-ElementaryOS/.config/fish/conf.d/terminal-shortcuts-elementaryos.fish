#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------
# Bootstrapper script specific to elementaryOS

set --export --global BASE_OS (awk -F '=' '$1 == "UBUNTU_VERSION" {gsub(/"/, ""); BASE=$2} END {printf "🐧 Ubuntu %s", BASE}' /etc/os-release)

alias open "io.elementary.files"

function bootstrap
    # Clock settings
    gsettings set io.elementary.desktop.wingpanel.datetime clock-show-weekday true
    gsettings set io.elementary.desktop.wingpanel.datetime clock-show-seconds true

    busctl --system set-property \
        org.freedesktop.Accounts \
        /org/freedesktop/Accounts/User"$(id -u)" \
        io.elementary.pantheon.AccountsService \
        TimeFormat s '12h'

    # Special keys tray settings
    gsettings set io.elementary.wingpanel.keyboard numlock true
    gsettings set io.elementary.wingpanel.keyboard capslock true

    # Terminal settings + Gruvbox theme
    gsettings set io.elementary.terminal.settings cursor-shape 'I-Beam'
    gsettings set io.elementary.terminal.settings follow-system-style false
    gsettings set io.elementary.terminal.settings theme 'custom'
    gsettings set io.elementary.terminal.settings background 'rgba(40,40,40,0.936396)'
    gsettings set io.elementary.terminal.settings foreground 'rgb(235,219,178)'
    gsettings set io.elementary.terminal.settings palette 'rgb(40,40,40):rgb(204,36,29):rgb(152,151,26):rgb(215,153,33):rgb(69,133,136):rgb(177,98,134):rgb(104,157,106):rgb(168,153,132):rgb(146,131,116):rgb(251,73,52):rgb(184,187,38):rgb(250,189,47):rgb(131,165,152):rgb(211,134,155):rgb(142,192,124):rgb(235,219,178)'

    # Mouse pointer size & Reveal settings
    gsettings set org.gnome.desktop.interface cursor-size 32
    gsettings set org.gnome.desktop.interface locate-pointer true

    # Files settings
    gsettings set io.elementary.files.preferences show-hiddenfiles true
    gsettings set io.elementary.files.preferences singleclick-select true

    # echo
    # echo 'Setting up Logitech MX Keys'
    # sudo systemd-hwdb update
    # sudo udevadm trigger /dev/input/event*
    # echo 'Note: Restart computer to complete MX Keys set'

    echo '✅ Settings have been applied'
end

function register_keyboard_shortcuts
    set --local HYPER "<Control><Alt><Super>"
    set --local FINDER "<Control><Shift>"

    set --local apps
    set --append apps "T" "io.elementary.terminal.desktop"   # Terminal
    set --append apps "B" "org.mozilla.firefox.desktop"      # Firefox
    set --append apps "V" "dev.zed.Zed.desktop"              # Zed Editor

    set --local folders
    set --append folders "E" "/home/$USER"                   # Home
    set --append folders "J" "/home/$USER/Downloads"         # Downloads
    set --append folders "Y" "/home/$USER/Documents"         # Documents
    set --append folders "W" "/home/$USER/Workspace"         # Workspace
    set --append folders "S" "smb://mjolnir.local/svalbard"  # Svalbard SMB Share

    set --local entries

    for i in (seq 1 2 (count $apps))
        set --local key $apps[$i]
        set --local target $apps[(math $i + 1)]
        set --append entries "(0, '$target', @a{sv} {}, ['$HYPER$key'])"
    end

    for i in (seq 1 2 (count $folders))
        set --local key $folders[$i]
        set --local target $folders[(math $i + 1)]
        set --append entries "(1, 'io.elementary.files $target', @a{sv} {}, ['$FINDER$key'])"
    end

    set --local joined (string join ", " $entries)
    gsettings set io.elementary.settings-daemon.applications application-shortcuts "[$joined]"

    echo '✅ Keyboard shortcuts have been registered'
end
